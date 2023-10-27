public with sharing class DataCloudBulkIngestionUtilLwcCtrl {
    
    @AuraEnabled
    public static List<Map<String,String>>  getConfigMetadataRecordsPicklistOptions(){
        try {            
            return utl.Dc.getConfigMetadataRecordsPicklistOptions();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<Map<String,Object>> getIngestionJobTable(String mdtConfigName){
        try {
            return utl.Dc.getBulkIngestionJobs(mdtConfigName);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String newJob(String mdtConfigName){
        try {
            return utl.Dc.createIngestionBulkJob(mdtConfigName, utl.Rst.guid(), 'upsert');
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean abortJob(String mdtConfigName, String jobId){
        try {
            utl.Dc.updateIngestionBulkJobState(mdtConfigName, utl.Rst.guid(), jobId, 'Aborted');
            return true;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean completeJob(String mdtConfigName, String jobId){
        try {
            utl.Dc.updateIngestionBulkJobState(mdtConfigName, utl.Rst.guid(), jobId, 'UploadComplete');
            return true;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean deleteJob(String mdtConfigName, String jobId){
        try {
            utl.Dc.deleteIngestionBulkJob(mdtConfigName, utl.Rst.guid(), jobId);
            return true;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean addCsv(String mdtConfigName, String jobId, String csvData){
        try {
            utl.Dc.addCsvToIngestionBulkJob(mdtConfigName, jobId, jobId, csvData);
            return true;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Map<String,Object>> getJobInfo(String mdtConfigName, String jobId){
        try {
            
            Map<String,Object> jobInfo = utl.Dc.getBulkIngestionJobDetails(mdtConfigName,jobId);

            List<Map<String,Object>> output = new List<Map<String,Object>>();

            // Convert to a lightning data table output
            for(String key : jobInfo.keySet()){
                output.add(new Map<String,Object>{
                    'key'  => key,
                    'value'=> jobInfo.get(key)
                });
            }
            return output;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static Map<String,Object> getMetadataInfo(String mdtConfigName, String jobId){
        try {
            // Table usable mapping data
            List<Map<String,Object>> recordData  = new List<Map<String,Object>> ();
            List<Map<String,Object>> mappingData = new List<Map<String,Object>>();

            // Query the record
            Data_Cloud_Ingestion_API_Configuration__mdt record = utl.Dc.getMetadataRecord(mdtConfigName);

            // Add record details
            recordData.add(new Map<String,Object>{'key'  => 'Configuration Record Name',       'value'=> record.DeveloperName});
            recordData.add(new Map<String,Object>{'key'  => 'Data Cloud Named Credential',     'value'=> record.Named_Credential_Name__c});
            recordData.add(new Map<String,Object>{'key'  => 'Ingestion API Connector Name',    'value'=> record.Ingestion_API_Connector_Name__c});
            recordData.add(new Map<String,Object>{'key'  => 'Ingestion API Target Object Name','value'=> record.Ingestion_API_Target_Object_Name__c});

            // Add mapping details
            for(Data_Cloud_Ingestion_API_Field_Mapping__mdt mapping : record.Data_Cloud_Ingestion_API_Field_Mappings__r){
                mappingData.add(
                    new Map<String,Object>{
                        'source' => mapping.Source__c,
                        'target' => mapping.Target__c,
                        'ftype'  => mapping.Data_Cloud_Field_Type__c
                    });
            }

            // Return the combined
            return new Map<String,Object>{
                'recordData' => recordData,
                'mappingData'=> mappingData
            };
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String getCsvPlaceholder(String mdtConfigName){
        try{
            // Query the record
            Data_Cloud_Ingestion_API_Configuration__mdt record = utl.Dc.getMetadataRecord(mdtConfigName);

            // Dummy data place holder
            String placeholder = '';

            // Sample data
            String header = '';
            String data   = '';
            
            // Add mapping details
            for(Data_Cloud_Ingestion_API_Field_Mapping__mdt mapping : record.Data_Cloud_Ingestion_API_Field_Mappings__r){
                header+=',' + mapping.Target__c;
            }
            header+='\n';
            header = header.removeStart(',');
            
            // Add mapping details
            for(Data_Cloud_Ingestion_API_Field_Mapping__mdt mapping : record.Data_Cloud_Ingestion_API_Field_Mappings__r){
                
                String value='';

                switch on mapping.Data_Cloud_Field_Type__c{
                    when 'textField' {
                        data+=',' + String.valueOf(EncodingUtil.base64encode(crypto.generateAesKey(192)).substring(0,15)).escapeCsv();
                    }
                    when  'numberField'{
                        data+=',' + String.valueOf(Integer.valueof((Math.random() * 10000))).escapeCsv();
                    }
                    when  'dateField'{
                        data+=',' + String.valueOf(Date.today().addDays(Integer.valueof((Math.random() * 100)))).escapeCsv();
                    }
                    when  'dateTimeField'{
                        data+=',' + String.valueOf(Datetime.now().addDays(Integer.valueof((Math.random() * 100)))).escapeCsv();
                    }
                    when  'uuidField'{
                        data+=',' + String.valueOf(utl.Rst.guid()).escapeCsv();
                    }
                    when else{
                        data+=',';
                    }
                    
                }
            }
            data = data.removeStart(',');
            
            // Use the utility to generate an ingestion stream payload
            return header + data;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String getStreamingPlaceholder(String mdtConfigName){
        try{
            // Query the record
            Data_Cloud_Ingestion_API_Configuration__mdt record = utl.Dc.getMetadataRecord(mdtConfigName);

            // Dummy data place holder
            Map<String,Object> placeholder = new Map<String,Object>();

            // Types of dummy data
            Map<String,Object> fieldTypeDemoData = new Map<String,Object>{
                'textField'    => 'Text Value',
                'numberField'  => Integer.valueof((Math.random() * 10000)),
                'dateField'    => Date.today().addDays(Integer.valueof((Math.random() * 100))),
                'dateTimeField'=> Datetime.now().addDays(Integer.valueof((Math.random() * 100))),
                'uuidField'    => utl.Rst.guid()
            };

            // Add mapping details
            for(Data_Cloud_Ingestion_API_Field_Mapping__mdt mapping : record.Data_Cloud_Ingestion_API_Field_Mappings__r){
                placeholder.put(mapping.Source__c,fieldTypeDemoData.get(mapping.Data_Cloud_Field_Type__c));
            }

            // Use the utility to generate an ingestion stream payload
            return Dc.createIngestStreamPayload(
                new List<Map<String,Object>>{placeholder},
                Dc.createFieldMapping(record.Data_Cloud_Ingestion_API_Field_Mappings__r),
                true
            );

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Boolean sendDataStream(String mdtConfigName, String payload){
        try {
            Dc.streamDataToDataCloud(mdtConfigName, payload, false);
            return true;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    } 

    @AuraEnabled
    public static Boolean testDataStream(String mdtConfigName, String payload){
        try {
            Dc.streamDataToDataCloud(mdtConfigName, payload, true);
            return true;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
}