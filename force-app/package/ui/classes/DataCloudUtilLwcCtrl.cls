/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           August 2023
 * @copyright      (c) 2023 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Class that contains the Data Cloud LWC Controller Methods
 */
@SuppressWarnings('PMD.ExcessivePublicCount, PMD.CyclomaticComplexity, PMD.ApexDoc')
public with sharing class DataCloudUtilLwcCtrl {

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


    /** **************************************************************************************************** **
     **                                    CUSTOM METADATA AURA METHODS                                      **
     ** **************************************************************************************************** **/
    @AuraEnabled
    public static List<Map<String,String>>  getMtdConfigOptions(){
        try{
           // Force an exception for testing purposes
           utl.Tst.forceException('AURA_EXCEPTION');

            return Dc.getConfigMetadataRecordsPicklistOptions();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String,Object> getMetadataInfo(String mdtConfigName, String jobId){
        try{
           // Force an exception for testing purposes
           utl.Tst.forceException('AURA_EXCEPTION');

            // Table usable mapping data
            List<Map<String,Object>> recordData  = new List<Map<String,Object>> ();
            List<Map<String,Object>> mappingData = new List<Map<String,Object>>();

            // Query the record
            Data_Cloud_Ingestion_API_Configuration__mdt record = Dc.getMetadataRecord(mdtConfigName);

            // Add record details
            recordData.add(new Map<String,Object>{'key'  => 'Configuration Record Name',       'value'=> record.DeveloperName});
            recordData.add(new Map<String,Object>{'key'  => 'Salesforce Named Credential',     'value'=> record.Salesforce_Named_Credential_Name__c});
            recordData.add(new Map<String,Object>{'key'  => 'Data Cloud Named Credential',     'value'=> record.Named_Credential_Name__c});
            recordData.add(new Map<String,Object>{'key'  => 'Salesforce sObject Name',         'value'=> record.sObject_Name__c});
            recordData.add(new Map<String,Object>{'key'  => 'Ingestion API Connector Name',    'value'=> record.Ingestion_API_Connector_Name__c});
            recordData.add(new Map<String,Object>{'key'  => 'Ingestion API Target Object Name','value'=> record.Ingestion_API_Target_Object_Name__c});
            recordData.add(new Map<String,Object>{'key'  => 'Data Lake Object Name',            'value'=> record.Data_Lake_Object_Name__c});

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


    /** **************************************************************************************************** **
     **                                     BULK INGESTION AURA METHODS                                      **
     ** **************************************************************************************************** **/
    @AuraEnabled
    public static String getCsvPlaceholder(String mdtConfigName){
        try{
           // Force an exception for testing purposes
           utl.Tst.forceException('AURA_EXCEPTION');

            // Query the record
            Data_Cloud_Ingestion_API_Configuration__mdt record = Dc.getMetadataRecord(mdtConfigName);

            // Sample data
            String header = '';
            String data   = '';

            // Add mapping details
            for(Data_Cloud_Ingestion_API_Field_Mapping__mdt mapping : record.Data_Cloud_Ingestion_API_Field_Mappings__r){
                header+=',' + mapping.Target__c;
            }
            header+='\n';
            header = header.removeStart(',');

            // Create some sample data lines
            for(Integer i=0;i<5;i++){
                String line = '';
                
                // Add each fields
                for(Data_Cloud_Ingestion_API_Field_Mapping__mdt mapping : record.Data_Cloud_Ingestion_API_Field_Mappings__r){
                    line += (String.isNotBlank(line) ? ',' : '' ) + generateSampleData(mapping.Data_Cloud_Field_Type__c);
                }
                
                // Add the line to the data
                data+= line + '\n';
            }

            // Use the utility to generate an ingestion stream payload
            return header + data;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Map<String,Object>> getJobInfo(String mdtConfigName, String jobId){
        try{
           // Force an exception for testing purposes
           utl.Tst.forceException('AURA_EXCEPTION');

            Map<String,Object> jobInfo = Dc.getBulkIngestionJobDetails(mdtConfigName,jobId);

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
    public static List<Map<String,Object>> getIngestionJobTable(String mdtConfigName){
        try{
           // Force an exception for testing purposes
           utl.Tst.forceException('AURA_EXCEPTION');

            return Dc.getBulkIngestionJobs(mdtConfigName);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static String newJob(String mdtConfigName, String jobType){
        try{
           // Force an exception for testing purposes
           utl.Tst.forceException('AURA_EXCEPTION');

            return Dc.createIngestionBulkJob(mdtConfigName, utl.Rst.guid(), jobType);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static Boolean abortJob(String mdtConfigName, String jobId){
        try{
           // Force an exception for testing purposes
           utl.Tst.forceException('AURA_EXCEPTION');

            Dc.updateIngestionBulkJobState(mdtConfigName, jobId, jobId, 'Aborted');
            return true;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static Boolean completeJob(String mdtConfigName, String jobId){
        try{
           // Force an exception for testing purposes
           utl.Tst.forceException('AURA_EXCEPTION');

            Dc.updateIngestionBulkJobState(mdtConfigName, jobId, jobId, 'UploadComplete');
            return true;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static Boolean deleteJob(String mdtConfigName, String jobId){
        try{
           // Force an exception for testing purposes
           utl.Tst.forceException('AURA_EXCEPTION');

            Dc.deleteIngestionBulkJob(mdtConfigName, jobId, jobId);
            return true;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static Boolean addCsv(String mdtConfigName, String jobId, String csvData){
        try{
           // Force an exception for testing purposes
           utl.Tst.forceException('AURA_EXCEPTION');

            Dc.addCsvToIngestionBulkJob(mdtConfigName, jobId, jobId, csvData);
            return true;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static Boolean addCsvFromFile(String mdtConfigName, String jobId, String documentId, String contentVersionId){
        try{
            // Force an exception for testing purposes
            utl.Tst.forceException('AURA_EXCEPTION');

            // Send the file content to Data Cloud
            Dc.addCsvToIngestionBulkJob(
                mdtConfigName,
                jobId,
                jobId,
                [SELECT VersionData FROM ContentVersion WHERE Id = :contentVersionId WITH USER_MODE LIMIT 1]?.VersionData?.toString()
            );
            
            // return true when all is good
            return true;

        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static Boolean deleteDocument(String documentId){
        try{
            // Force an exception for testing purposes
            utl.Tst.forceException('AURA_EXCEPTION');

            // Delete the uploaded document (finally doesnt work well with AuraHandled Exceptions)
            delete as user [SELECT Id FROM ContentDocument WHERE Id = :documentId LIMIT 1];
            
            // return true when all is good
            return true;

        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    


    /** **************************************************************************************************** **
     **                                  STREAMING INGESTION AURA METHODS                                    **
     ** **************************************************************************************************** **/
    @AuraEnabled
    public static String getStreamingPlaceholder(String mdtConfigName){
        try{
           // Force an exception for testing purposes
           utl.Tst.forceException('AURA_EXCEPTION');

            // Query the record
            Data_Cloud_Ingestion_API_Configuration__mdt record = Dc.getMetadataRecord(mdtConfigName);

            // Dummy data place holder
            Map<String,Object> placeholder = new Map<String,Object>();

            

            // Add mapping details
            for(Data_Cloud_Ingestion_API_Field_Mapping__mdt mapping : record.Data_Cloud_Ingestion_API_Field_Mappings__r){
                placeholder.put(mapping.Source__c, generateSampleData(mapping.Data_Cloud_Field_Type__c));
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
        try{
           // Force an exception for testing purposes
           utl.Tst.forceException('AURA_EXCEPTION');

            Dc.streamDataToDataCloud(mdtConfigName, payload, false);
            return true;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static Boolean testDataStream(String mdtConfigName, String payload){
        try{
           // Force an exception for testing purposes
           utl.Tst.forceException('AURA_EXCEPTION');

            Dc.streamDataToDataCloud(mdtConfigName, payload, true);
            return true;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    /** **************************************************************************************************** **
     **                                     GENERATE YAML AURA METHODS                                       **
     ** **************************************************************************************************** **/

    @AuraEnabled(cacheable=true)
    public static List<Map<String,Object>>  getSObjectOptions(Boolean invertLabel){
        try{
           // Force an exception for testing purposes
           utl.Tst.forceException('AURA_EXCEPTION');


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
    public static List<Map<String,Object>> getSObjectFieldInfo(String sObjectName){

        // Input validation
        if(Type.forName('Schema', sObjectName) == null){
            throw new AuraHandledException(String.format('sObject of type "{0}" does not exist in the metadata', new String[]{sObjectName}));
        }

        // Table data map
        List<Map<String,Object>> output = new List<Map<String,Object>>();

        try{
           // Force an exception for testing purposes
           utl.Tst.forceException('AURA_EXCEPTION');

            // Get the describe for the fields
            DescribeSObjectResult sdr = ((sObject) Type.forName('Schema', sObjectName).newInstance()).getSObjectType().getDescribe(SObjectDescribeOptions.DEFERRED);

            // Iterate the fields and add the results to an output table
            for(SObjectField field : sdr.fields.getMap().values()){

                DescribeFieldResult sfr = field.getDescribe();

                output.add(new Map<String,Object>{
                    'source'  => sfr.name,
                    'sfFtype' => String.valueOf(sfr.SoapType),
                    'custom'  => sfr.custom,
                    'target'  => sfr.name,
                    'dcFtype' => SOAP_TYPE_DATA_CLOUD_DATA_TYPE_MAP.get(sfr.SoapType)
                });
            }
            // Return the data
            return output;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }




    /** **************************************************************************************************** **
     **                                   DATA CLOUD QUERY AURA METHODS                                      **
     ** **************************************************************************************************** **/
    @AuraEnabled
    public static String getDcQueryCsv(String mdtConfigName, String query){
        try{
           // Force an exception for testing purposes
           utl.Tst.forceException('AURA_EXCEPTION');

            // Return the CSV string
            return getQueryTable(mdtConfigName, query).getCsvString();

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static Map<String,Object> getDcQueryTable(String mdtConfigName, String query){
        try{
           // Force an exception for testing purposes
           utl.Tst.forceException('AURA_EXCEPTION');

            // Execute the query
            utl.JsnTbl table = getQueryTable(mdtConfigName, query);

            // Return the columns and the data
            return new Map<String,Object>{
                'columns' => table.getColumnNames(),
                'data'    => table.getKeyValueData()
            };

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String getQueryPlaceholder(String mdtConfigName){
        try{
           // Force an exception for testing purposes
           utl.Tst.forceException('AURA_EXCEPTION');

            // Query the record
            Data_Cloud_Ingestion_API_Configuration__mdt record = Dc.getMetadataRecord(mdtConfigName);

            // Create a query 
            String query = 'SELECT ';
          
            // Add mapping details
            for(Data_Cloud_Ingestion_API_Field_Mapping__mdt mapping : record.Data_Cloud_Ingestion_API_Field_Mappings__r){
                query+=(query == 'SELECT ' ? '' : ', ') + mapping.Target__c + '__c';
            }
            
            // Use the utility to generate a sample query
            return query + ' FROM ' + record.Data_Lake_Object_Name__c + ' LIMIT 100';

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    /** **************************************************************************************************** **
     **                                      SOQL QUERY AURA METHODS                                         **
     ** **************************************************************************************************** **/
    @AuraEnabled
    public static String getSoqlQueryCsv(String mdtConfigName, String query, Boolean tooling){
        try{
           // Force an exception for testing purposes
           utl.Tst.forceException('AURA_EXCEPTION');

            // Map to hold the mappings
            Map<String,String> mapping = new Map<String,String>();

            if(mdtConfigName != null){
                // Create the mapping
                mapping = Dc.createFieldMapping(Dc.getMetadataRecord(mdtConfigName).Data_Cloud_Ingestion_API_Field_Mappings__r);
            }

            // Execute the query
            utl.JsnTbl table = executeSoqlQuery(query, tooling);
            table.updateColumnNames(mapping);

            // Return the table as CSV
            return table.getCsvString();

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static Map<String,Object> getSoqlQueryTable(String mdtConfigName, String query, Boolean tooling){

        try{
           // Force an exception for testing purposes
           utl.Tst.forceException('AURA_EXCEPTION');

            // Map to hold the mappings
            Map<String,String> mapping = new Map<String,String>();

            // Create a mapping between label and field name (not ideal, but just how the )
            List<Map<String,String>> columnDetailsList = new List<Map<String,String>>();

            // Execute the query
            utl.JsnTbl table = executeSoqlQuery(query, tooling);

            // Create the mapping
            if(mdtConfigName != null){
                mapping = Dc.createFieldMapping(Dc.getMetadataRecord(mdtConfigName).Data_Cloud_Ingestion_API_Field_Mappings__r);
            }

            // Set the column names
            for(String columnName : table.getColumnNames()){
                columnDetailsList.add( new Map<String,String>{
                    'columnName' => columnName,
                    'columnLabel'=> (mapping.containsKey(columnName)) ? mapping.get(columnName) : columnName
                });
            }

            // Update the columns in the table
            table.updateColumnNames(mapping);

            // Return the columns and the data
            return new Map<String,Object>{
                'columns'      => columnDetailsList,
                'data'         => table.getKeyValueData()
            };

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static String generateQueryFromMapping(String mdtConfigName){
        try{
           // Force an exception for testing purposes
           utl.Tst.forceException('AURA_EXCEPTION');

            // Query the record
            Data_Cloud_Ingestion_API_Configuration__mdt record = Dc.getMetadataRecord(mdtConfigName);

            // Return the query string
            String query = 'SELECT ';
                   query+= String.join(Dc.createFieldMapping(record.Data_Cloud_Ingestion_API_Field_Mappings__r).keySet(),', ');
                   query+= ' FROM ' + record.sObject_Name__c + ' ORDER BY CreatedDate DESC LIMIT 2000';

            // Return the query string
            return query;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + e.getStackTraceString());
        }
    }


    /** **************************************************************************************************** **
     **                                       PRIVATE SUPPORT METHODS                                        **
     ** **************************************************************************************************** **/
    private static utl.JsnTbl getQueryTable(String mdtConfigName, String query){

        // Cast the response as an object so we can get both the data and metadata
        Map<String,Object> response = (Map<String,Object>) JSON.deserializeUntyped(
            Dc.executeQuery(mdtConfigName, query)
                .getResponse()
                .getBody()
        );

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


    private static utl.JsnTbl executeSoqlQuery(String query, Boolean tooling){

        // Input validation
        if(String.isBlank(query)){
            throw new Dc.DataCloudUtilException('SOQL Query cannot be empty');
        }

        // Execute the query
        utl.Rst callout = new utl.Rst(true)
            .setEndpoint(((tooling) ? '/tooling/' : '' ) +  '/query?q=' + EncodingUtil.urlEncode(query,'UTF-8'))
            .setMethod('GET')
            .call()
        ;

        // Create a datatable
        utl.JsnTbl table = new utl.JsnTbl()
            .setAttributeFilter(new Set<String>{'attributes', 'done', 'totalSize'})
            .setListNameFilter(new Set<String>{'records'})
            .create(utl.Jsn.getObjectList('records',(Map<String,Object>)JSON.deserializeUntyped(callout.getResponse().getBody())))
        ;

        // Return the output as a CSV string
        return table;
    }


    /**
     * @description Method for generating sample data based on the data type
     */
    private static Object generateSampleData(String dataType){
        switch on dataType {
            when 'numberField' {
                return Integer.valueof((Math.random() * 10000));
            }
            when 'dateField' {
                return Date.today().addDays(Integer.valueof((Math.random() * 100)));
            }
            when 'dateTimeField' {
                return Datetime.now().addDays(Integer.valueof((Math.random() * 100))).addHours(Integer.valueof((Math.random() * 100))).addMinutes(Integer.valueof((Math.random() * 100)));
            }
            when 'uuidField' {
                return utl.Rst.guid();
            }
        }
        return String.valueOf(EncodingUtil.convertToHex(crypto.generateAesKey(192)).substring(0,15)).escapeCsv();
    }
}