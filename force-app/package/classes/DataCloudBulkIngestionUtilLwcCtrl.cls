public with sharing class DataCloudBulkIngestionUtilLwcCtrl {
    
    /** **************************************************************************************************** **
     **                                          PRIVATE CONSTANTS                                           **
     ** **************************************************************************************************** **/
    // Mapping between field soap types and data cloud field types, used for YAML generation
    private final static Map<Schema.SOAPType,String> SOAP_TYPE_DATA_CLOUD_DATA_TYPE_MAP = new Map<Schema.SOAPType,String>{
        SOAPType.anytype      => 'textField',
        SOAPType.base64binary => 'textField',
        SOAPType.Boolean      => 'textField',
        SOAPType.Date         => 'dateField',
        SOAPType.DateTime     => 'dateTimeField',
        SOAPType.Double       => 'numberField',
        SOAPType.ID           => 'textField',
        SOAPType.Integer      => 'numberField',
        SOAPType.String       => 'textField',
        SOAPType.Time         => 'textField',
        SOAPType.Address      => 'textField'
    };

    // Mapping between field soap types and data cloud field types, used for YAML generation
    private final static Map<String,String> CLOUD_DATA_TYPE_DATA_TABLE_TYPE_MAP = new Map<String,String>{
        'CHAR'                          => 'text',
        'VARCHAR'                       => 'text',
        'STRING'                        => 'text',
        'BLOB'                          => 'text',
        'DATE'                          => 'date',
        'DATE_TIME'                     => 'date',
        'TIMESTAMP'                     => 'date',
        'TIMESTAMP WITH TIME ZONE'      => 'date',
        'TIMESTAMP WITH LOCAL TIME ZONE'=> 'date',
        'DECIMAL'                       => 'number',
        'NUMBER'                        => 'number',
        'INT'                           => 'number',
        'INTEGER'                       => 'number'
    };


    @AuraEnabled
    public static List<Map<String,String>>  getMtdConfigOptions(){
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
    

    @AuraEnabled(cacheable=true)
    public static List<Map<String,Object>>  getSObjectOptions(Boolean invertLabel){
        try {            
            
            // List of select options
            List< Map<String,Object>> options = new List< Map<String,Object> >();

            /**
             * This method will get all sObject that are not like a share or feed 
             * and that are queryable
             */
            for(SObjectType result : Schema.getGlobalDescribe().values()){
                
                DescribeSObjectResult sdr = result.getDescribe(SObjectDescribeOptions.DEFERRED);
                
                if(sdr.associateEntityType == null && sdr.isQueryable()){
                    options.add(new Map<String,Object>{
                        'label' => (invertLabel) ? sdr.name + ' - (' + sdr.label +')' : sdr.label + ' - (' + sdr.name +')',
                        'value' =>  sdr.name
                    });
                }
            }

            // Return a list of options
            return options;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String getYamlInfo(String sObjectName){
        try {
            return sObjectName;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


         /**
     * @description Method to get the metadata configuration labels and names in an LWC
     *              picklist values.
     * @return      An LWC ready to use set data set with source and target mappings
     */
    @AuraEnabled
    public static List<Map<String,Object>> getSObjectFieldInfo(String sObjectName){
        
        // Input validation
        if(Type.forName('Schema', sObjectName) == null){
            throw new AuraHandledException(String.format('sObject of type "{0}" does not exist in the metadata', new String[]{sObjectName}));
        }

        // Table data map
        List<Map<String,Object>> output = new List<Map<String,Object>>();

        try {
            // Get the describe for the fields
            DescribeSObjectResult sdr = ((sObject) Type.forName('Schema', sObjectName).newInstance()).getSObjectType().getDescribe(SObjectDescribeOptions.DEFERRED);
            
            // Iterate the fields and add the results to an output table
            for(SObjectField field : sdr.fields.getMap().values()){
                
                DescribeFieldResult sfr = field.getDescribe();

                output.add(new Map<String,Object>{
                    'source'  => sfr.name,
                    'sfFtype' => String.valueOf(sfr.SoapType),
                    'custom'  => sfr.custom,
                    'target'  => (sfr.name.contains('__')) ? sfr.name.substringBeforeLast('__') : sfr.name,
                    'dcFtype' => SOAP_TYPE_DATA_CLOUD_DATA_TYPE_MAP.get(sfr.SoapType)
                });   
            }
            // Return the data
            return output;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    private static utl.JsnTbl executeQuery(String mdtConfigName, String query){

        // Query the record
        Data_Cloud_Ingestion_API_Configuration__mdt record = utl.Dc.getMetadataRecord(mdtConfigName);

        // Sanatize the query as the api is very sensitive
        query = query.replaceAll('\n', ' ');
        query = query.replaceAll('\t', ' ');
        query = query.trim();
        
        // Execute the query
        utl.Rst callout = new utl.Rst(record.Named_Credential_Name__c, true)
            .setHandleSfEndpoint(false)
            .setEndpoint('/api/v2/query')
            .setMethod('POST')
            .setBody(JSON.serialize(new Map<String,String>{'sql'=>query}))
            .call()
        ;

        // Cast the response as an object so we can get both the data and metadata
        Map<String,Object> response = (Map<String,Object>) JSON.deserializeUntyped(callout.getResponse().getBody());

        // Create a datatable
        utl.JsnTbl table = new utl.JsnTbl()
            .setAttributeFilter(new Set<String>{'startTime','endTime','rowCount','queryId','done','metadata','nextBatchId'})
            .setListNameFilter(new Set<String>{'data'})
            .create(utl.Jsn.getObjectList('data',response))
            .updateColumnNames(Dc.getOrderedColumnNamesFromMetadata(utl.Jsn.getObjectMap('metadata', response)))
        ;
         
        // Return the output as a CSV string
        return table;
    }


    @AuraEnabled
    public static String getDcQueryCsv(String mdtConfigName, String query){
        try {
            // Return the CSV string
            return executeQuery(mdtConfigName, query).getCsvString();
           
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static Map<String,Object> getDcQueryTable(String mdtConfigName, String query){
        try {
            // Execute the query
            utl.JsnTbl table = executeQuery(mdtConfigName, query);
            
            // Return the columns and the data
            return new Map<String,Object>{
                'columns' => table.getColumnNames(),
                'data'    => table.getKeyValueData()
            };

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    


    
}