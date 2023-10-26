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
                mappingData.add(new Map<String,Object>{'source'  => mapping.Source__c, 'target'=> mapping.Target__c});
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
    
    
}