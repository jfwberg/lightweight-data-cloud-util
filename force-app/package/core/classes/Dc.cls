/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           August 2023
 * @copyright      (c) 2023 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Class that contains a set of Data Cloud Utilities
 * @false-positive PMD.AvoidGlobalModifier  This is a utility that is designed to be called from a
 *                                          managed package. It can be used for a user's own custom
 *                                          Implementation, so global is the way to open up this
 *                                          utility for global use.
 * @note           This class is to be used in a managed package and contains Global methods that
 *                 should be made public or private in org based implementations or unlocked
 *                 packages
 */
@SuppressWarnings('PMD.OneDeclarationPerLine, PMD.AvoidGlobalModifier, PMD.ExcessiveParameterList, PMD.CyclomaticComplexity')
global with sharing class Dc {

    /** **************************************************************************************************** **
     **                                          PRIVATE VARIABLES                                           **
     ** **************************************************************************************************** **/
    // Variable to hold the callout details so it can be asserted during a unit test
    @TestVisible private static utl.Rst testCallout;


    /** **************************************************************************************************** **
     **                                          PRIVATE CONSTANTS                                           **
     ** **************************************************************************************************** **/
    // Query (Error) Messages
    @TestVisible private final static String QUERY_CANNOT_BE_BLANK_MSG  = 'The input query cannot be empty';
    @TestVisible private final static String QUERY_EXCEPTION_MSG        = 'Something when wrong whilst executing the Data Cloud Query: {0}';
    @TestVisible private final static String INVALID_API_EXCEPTION_MSG  = 'Invalid API version: "{0}"';

    // Streaming Ingestion (Error) Messages
    @TestVisible private static final String NO_MDT_RECORD_FOUND_MSG    = 'No Data_Cloud_Ingestion_API_Configuration__mdt record with the name "{0}" exists.';
    @TestVisible private static final String CALLOUT_EXCEPTION_MSG      = 'Something went wrong during the callout to the Ingest API endpoint: {0}';

    // Get ordered colum names (Error) Messages
    @TestVisible private static final String INVALID_MTD_JSON_ERROR_MSG = 'Something went wrong extracting the column data from the metadata JSON Object: {0}';
    @TestVisible private static final String INVALID_MTD_INPUT_ERROR_MSG= 'The input metadata map cannot be empty';

    // Bulk Ingestion Utils (Error) Messages
    @TestVisible private static final String CSV_LIST_INPUT_ERROR_MSG   = 'There should be at least 1 CSV file and no more than 8 csv files in a synchronous transaction';
    @TestVisible private static final String LIST_BULK_JOBS_ERROR_MSG   = 'Something went wrong whilst fetching the list of ingestion API Bulk Jobs: {0}';
    @TestVisible private static final String BULK_JOB_DETAILS_ERROR_MSG = 'Something went wrong whilst fetching the details for the ingestion API Bulk Job: {0}';

    // Create Bulk Job (Error) Messages
    @TestVisible private static final String INVALID_OPERATION_ERROR_MSG= 'Invalid operation type for the bulk ingestion job. "{0}". Valid values are "upsert" or "delete" (case sensitive)';
    @TestVisible private static final String CREATE_BULK_JOB_ERROR_MSG  = 'There was an error creating the Bulk Ingestion Job: {0}';

    // Add CSV to Bulk Job (Error) Messages
    @TestVisible private static final String INVALID_CSV_ERROR_MSG      = 'You cannot add a blank CSV file to the Ingestion Job';
    @TestVisible private static final String ADD_CSV_ERROR_MSG          = 'There was an error whilst adding CSV Data to the Bulk Ingestion Job: {0}';

    // Add CSV to Bulk Job (Error) Messages
    @TestVisible private static final String INVALID_STATE_ERROR_MSG    = 'Invalid state type for the bulk ingestion job. "{0}". Valid values are "UploadComplete" or "Aborted" (case sensitive)';
    @TestVisible private static final String UPDATE_STATE_ERROR_MSG     = 'There was an error whilst updating the state of the Bulk Ingestion Job: {0}';

    // Delete Bulk Job (Error) Messages
    @TestVisible private static final String DELETE_ERROR_MSG           = 'There was an error whilst updating the state of the Bulk Ingestion Job: {0}';


    /** **************************************************************************************************** **
     **                                        GLOBAL SUPPORT METHODS                                        **
     ** **************************************************************************************************** **/
    /**
     * @description Method to get a single Data_Cloud_Ingestion_API_Configuration__mdt
     *              record based on the DeveloperName
     * @param  mdtRecordName The Developer Name of the metadata record
     * @return      Full info for the ingestion API configuration
     * @throws DataCloudUtilException When no record is found
     */
    global static Data_Cloud_Ingestion_API_Configuration__mdt getMetadataRecord(String mdtRecordName){
        for(Data_Cloud_Ingestion_API_Configuration__mdt record : [
                                                                SELECT
                                                                    DeveloperName, Ingestion_API_Connector_Name__c, Ingestion_API_Target_Object_Name__c,
                                                                    Named_Credential_Name__c, Salesforce_Named_Credential_Name__c, sObject_Name__c, Data_Lake_Object_Name__c,
                                                                    (   
                                                                        SELECT Source__c, Target__c, Data_Cloud_Field_Type__c, Is_Primary_Key__c, Is_Event_Time_Field__c 
                                                                        FROM Data_Cloud_Ingestion_API_Field_Mappings__r ORDER BY DeveloperName
                                                                    )
                                                                FROM
                                                                    Data_Cloud_Ingestion_API_Configuration__mdt
                                                                WHERE
                                                                    DeveloperName = :mdtRecordName
                                                                WITH USER_MODE
                                                                LIMIT 1]){
            // When a record is found return the first record
            return record; 
        }

        // If no records are found throw an eception
        throw new DataCloudUtilException(String.format(NO_MDT_RECORD_FOUND_MSG,new String[]{mdtRecordName}));
    }


    /**
     * @description Method to get a set of column names in the correct from a metadata
     *              response. This can be used to generate CSV or table headers
     * @param metadataMap   The parsed metadata response map from
     * @param removePostfix Remove the __c postfix from the end of the column names
     * @return      A set of column names in the correct order
     */
    global static Set<String> getOrderedColumnNamesFromMetadata(Map<String,Object> metadataMap, Boolean removePostfix){

        // Input validation for the columns
        if(metadataMap == null){
            throw new DataCloudUtilException(INVALID_MTD_INPUT_ERROR_MSG);
        }

        try{
            // Force exception for testing
            utl.Tst.forceException('ORDER_COLUMNS');

            // Create a map for the output
            Set<String> columnNamesInOrder = new Set<String>{};

            // Get the field metadata and sort the objects
            FieldMetadata[] fMdt = getFieldMetadata(metadataMap,removePostfix);
            fMdt.sort();

            // Create an ordered list
            for(Integer i=0,max=fMdt.size(); i<max;i++){
                columnNamesInOrder.add(fMdt[i].name);
            }

            // Return the column Names in the correct order based on the metadata
            return columnNamesInOrder;

        }catch(Exception e){
            throw new DataCloudUtilException(String.format(INVALID_MTD_JSON_ERROR_MSG, new String[]{e.getMessage()}));
        }
    }


    /**
     * @description Overload method to get a set of column names in the correct from a metadata
     *              response. This can be used to generate CSV or table headers
     * @param metadataMap The parsed metadata response map from
     * @return      A set of column names in the correct order
     */
    global static Set<String> getOrderedColumnNamesFromMetadata(Map<String,Object> metadataMap){
        return getOrderedColumnNamesFromMetadata(metadataMap, false);
    }


    /**
     * @description Method to get a full set set of column metadata
     * @param metadataMap   The parsed metadata response map from
     * @param removePostfix Remove the __c postfix from the end of the column names
     * @return      A set of column names in the correct order
     */
    global static FieldMetadata[] getFieldMetadata(Map<String,Object> metadataMap, Boolean removePostfix){

        // Input validation for the columns
        if(metadataMap == null){
            throw new DataCloudUtilException(INVALID_MTD_INPUT_ERROR_MSG);
        }

        try{
            // Force exception for testing
            utl.Tst.forceException('FIELD_METADATA');

            // Output list
            FieldMetadata[] fieldMetadata = new FieldMetadata[]{};

            // Iterate the metadata to get the columns
            for(String key : metadataMap.keySet()){
                fieldMetadata.add(
                    new FieldMetadata(
                        (removePostfix) ? key?.removeEnd('__c') : key,
                        (Map<String,Object>) metadataMap.get(key)
                    )
                );
            }

            // Sort the field metadata based on the place in the order
            fieldMetadata.sort();

            // Return the column Names in the correct order based on the metadata
            return fieldMetadata;

        }catch(Exception e){
            throw new DataCloudUtilException(String.format(INVALID_MTD_JSON_ERROR_MSG, new String[]{e.getMessage()}));
        }
    }


    /**
    * @description         Method to get a full set set of column metadata
     * @param  metadataMap The parsed metadata response map from
     * @return             A set of column names in the correct order
     */
    global static FieldMetadata[] getFieldMetadata(Map<String,Object> metadataMap){
        return getFieldMetadata(metadataMap, false);
    }


    /**
     * @description Method to get the metadata configuration labels and names in an LWC
     *              picklist values.
     * @return      An LWC ready to use set of picklist values
     */
    global static List<Map<String,String>> getConfigMetadataRecordsPicklistOptions(){

        // Filter out the test metadata, except whilst testing
        Set<String> testFilter = (!Test.isRunningTest()) ? new Set<String>{'Apex_Unit_Test'} : new Set<String>();

        List<Map<String,String>> output = new List<Map<String,String>>();
        for(Data_Cloud_Ingestion_API_Configuration__mdt record : [  SELECT Label,DeveloperName
                                                                    FROM Data_Cloud_Ingestion_API_Configuration__mdt
                                                                    WHERE (NOT DeveloperName IN :testFilter)
                                                                    WITH USER_MODE ORDER BY Label LIMIT 1000]){
            output.add(new Map<String,String>{
                'label' => record.Label,
                'value' => record.DeveloperName
            });
        }
        return output;
    }


    /**
     * @description Method to get the metadata configuration labels and names in an LWC
     *              picklist values for a specific named credential only.
     * @param namedCredentialName The name of the named credential
     * @return      An LWC ready to use set of picklist values
     */
    global static List<Map<String,String>> getConfigMetadataRecordsPicklistOptions(String namedCredentialName){

        // Filter out the test metadata, except whilst testing
        Set<String> testFilter = (!Test.isRunningTest()) ? new Set<String>{'Apex_Unit_Test'} : new Set<String>();

        List<Map<String,String>> output = new List<Map<String,String>>();
        for(Data_Cloud_Ingestion_API_Configuration__mdt record : [  SELECT Label,DeveloperName
                                                                    FROM Data_Cloud_Ingestion_API_Configuration__mdt
                                                                    WHERE 
                                                                        (NOT DeveloperName IN :testFilter) AND
                                                                        Named_Credential_Name__c = :namedCredentialName
                                                                    WITH USER_MODE ORDER BY Label LIMIT 1000]){
            output.add(new Map<String,String>{
                'label' => record.Label,
                'value' => record.DeveloperName
            });
        }
        return output;
    }


    /**
     * @description Method to query named credential parameters to get the list of
     *              Data Cloud Related Named Credentials on the current org
     * @return      Ready to use picklist values for a data cloud named credential picklist
     */
    global static List<Map<String,String>> getDataCloudNamedCredentialPicklistOptions(){

        // List containing the output
        List<Map<String,String>> output = new List<Map<String,String>>();
  
        // Create a tooling query to get the named credential parameters for 
        String  query  = 'SELECT NamedCredential.MasterLabel,NamedCredential.DeveloperName, ParameterValue FROM NamedCredentialParameter ';
                query += 'WHERE ParameterType = \'Url\' ';
                query += 'ORDER BY NamedCredential.MasterLabel';

        // Execute the tooling query and iterate the results
        for(Object o : utl.Jsn.getObjectList(
            'records',
            (Map<String,Object>) JSON.deserializeUntyped(new utl.Rst(true)
                .setEndpoint('/tooling/query?q=' + EncodingUtil.urlEncode(query,'UTF-8'))
                .setMethod('GET')
                .call()
                .getResponse()
                .getBody()
            ))
        ){
            // Rudimentary way of getting the Data Cloud based on the endpoint name 
            if(((String) utl.Jsn.getObject('ParameterValue', (Map<String,Object>) o )).contains('.c360a.salesforce.com')){
                output.add(new Map<String,String>{
                    'label' => (String) utl.Jsn.getObject('NamedCredential.MasterLabel',   (Map<String,Object>) o),
                    'value' => (String) utl.Jsn.getObject('NamedCredential.DeveloperName', (Map<String,Object>) o)
                });
            }
        }
        
        // Return the picklist values
        return output;
    }

    /** **************************************************************************************************** **
     **                                         GLOBAL QUERY METHODS                                         **
     ** **************************************************************************************************** **/

    /**
     * @description Overload method
     */
     global static utl.Rst executeQuery(String namedCredentialName, String query){
        return executeQuery(namedCredentialName, query, 'v1');
    }


    /**
     * @description Method to execute a query against data cloud
     * @param  namedCredentialName The Developer Name of the named credential
     * @param  query               The SQL query to run against Data Cloud
     * @return The execution result of the Rest Execution  (utl.Rst)
     */
    global static utl.Rst executeQuery(String namedCredentialName, String query, String apiVersion){

        // Input validation
        if(String.isBlank(query)){
            throw new DataCloudUtilException(QUERY_CANNOT_BE_BLANK_MSG);
        }

        // Validate API version for the Query endpoint
        if(String.isBlank(apiVersion) || !(new Set<String>{'v1','v2'}).contains(apiVersion)){
            throw new DataCloudUtilException(String.format(INVALID_API_EXCEPTION_MSG,new String[]{apiVersion}));
        }

        try{
            // Force an exception for testing purposes
            utl.Tst.forceException('DC_QUERY');

            // Sanatize the query as the api is very sensitive to line breaks and tabs for some reason
            query = query.replaceAll('\n', ' ');
            query = query.replaceAll('\t', ' ');
            query = query.trim();

            // Execute the query
            return new utl.Rst(namedCredentialName, true)
                .setHandleSfEndpoint(false)
                .setEndpoint('/api/' + apiVersion + '/query')
                .setMethod('POST')
                .setBody(JSON.serialize(new Map<String,String>{'sql'=>query}))
                .call()
            ;
        }catch(Exception e){
            throw new DataCloudUtilException(String.format(QUERY_EXCEPTION_MSG, new String[]{e.getMessage()}));
        }
    }


    /** **************************************************************************************************** **
     **                                      GLOBAL DATA GRAPH METHODS                                       **
     ** **************************************************************************************************** **/
    /**
     * @description               Method to get the list of all data graph metadata
     * @param namedCredentialName The name of the data cloud named credential
     * @return                    A list of ALL data graph metadata 
     */
    global static List<Map<String,Object>> getAllDataGraphMetadata(String namedCredentialName){

        // List to hold the converted output
        List<Map<String,Object>> output = new List<Map<String,Object>>();

        // Get the objects from the metadata
        for(Object o : utl.Jsn.getObjectList(
            'metadata',
            (Map<String, Object>) JSON.deserializeUntyped(
                new utl.Rst(namedCredentialName, true)
                .setHandleSfEndpoint(false)
                .setEndpoint('/api/v1/dataGraph/metadata')
                .setMethod('GET')
                .call()
                .getResponse()
                .getBody()
            )
        )){
            // Cast the objects to untyped maps and add to the output
            output.add((Map<String,Object>) o);
        }

        // Return the list of graph metadata
        return output;
    }


    /**
     * @description               Method to get the list of all data graph metadata
     * @param namedCredentialName The name of the data cloud named credential
     * @param dataGraphName       The name of the specific Graph API details
     * @return                    A single data graph's metadata 
     */
    global static Map<String,Object> getDetailedDataGraphMetadata(String namedCredentialName, String dataGraphName){
        return (Map<String,Object>) utl.Jsn.getObjectList(
            'metadata',
            (Map<String, Object>) JSON.deserializeUntyped(
                new utl.Rst(namedCredentialName, true)
                .setHandleSfEndpoint(false)
                .setEndpoint(String.format('/api/v1/dataGraph/metadata?entityName={0}', new String[]{dataGraphName}))
                .setMethod('GET')
                .call()
                .getResponse()
                .getBody()
            )
        )[0];
    }


    /**
     * @description               Method to get the blob JSON for a data graph
     * @param namedCredentialName The name of the data cloud named credential
     * @param dataGraphName       The name of the specific Graph API details
     * @param dataGraphRecordId   The record Id of the primary object's Primary key field
     * @return                    A single data graph's metadata 
     */
    global static String getDataGraphJsonBlob(String namedCredentialName, String dataGraphName, String dataGraphRecordId){
        return (String) utl.Jsn.getObject(
            'json_blob__c',
            (Map<String, Object>) utl.Jsn.getObjectList(
                'data',
                (Map<String, Object>) JSON.deserializeUntyped(
                    getDataGraph(namedCredentialName, dataGraphName, dataGraphRecordId)
                )
            )[0]
        );
    }


    /**
     * @description               Method to get the blob JSON for a data graph
     * @param namedCredentialName The name of the data cloud named credential
     * @param dataGraphName       The name of the specific Graph API details
     * @param dataGraphRecordId   The record Id of the primary object's Primary key field
     * @return                    The raw data graph API response
     */
    global static String getDataGraph(String namedCredentialName, String dataGraphName, String dataGraphRecordId){
        return new utl.Rst(namedCredentialName, true)
            .setHandleSfEndpoint(false)
            .setEndpoint(
                String.format(
                    '/api/v1/dataGraph/{0}/{1}',
                    new String[]{dataGraphName,dataGraphRecordId})
                )
            .setMethod('GET')
            .call()
            .getResponse()
            .getBody()
        ;
    }


    /** **************************************************************************************************** **
     **                                  GLOBAL STREAMING INGESTION METHODS                                  **
     ** **************************************************************************************************** **/
    /**
     * @description Method to stream records to data cloud Asynchrounously
     * @param  mdtConfigName    The API name of the metadata configuration record
     * @param serializedRecords The JSON.serialize(records) version of the records to
     *                          be streamed to data cloud
     */
    @future(callout=true)
    global static void streamRecordsToDataCloudAsync(String mdtConfigName, String serializedRecords){

        // We need to rebuilt the records from the JSON
        streamRecordsToDataCloud(
            mdtConfigName,
            (SObject[]) JSON.deserialize(serializedRecords, Type.forName('List<SObject>'))
        );
    }


    /**
     * @description Method to stream a list of records to data cloud based on a mtd configuration
     * @param  mdtConfigName          The API name of the metadata configuration record
     * @param  records                The list of sObjects you want to stream
     * @throws DataCloudUtilException In any unexpected event
     */
    global static void streamRecordsToDataCloud(String mdtConfigName, sObject[] records){

        // Get all record info
        Data_Cloud_Ingestion_API_Configuration__mdt config = getMetadataRecord(mdtConfigName);

        // Create the payload
        String payload = createIngestStreamPayload(
            records,
            createFieldMapping(config.Data_Cloud_Ingestion_API_Field_Mappings__r),
            false
        );

        // Stream the data with the generated payload
        streamDataToDataCloud(mdtConfigName, payload, false);
    }


    /**
     * @description Method to stream a list of records to data cloud based on a mtd configuration
     * @param  mdtConfigName          The API name of the metadata configuration record
     * @param  records                The list of Object maps you want to stream
     * @throws DataCloudUtilException In any unexpected event
     */
    global static void streamRecordsToDataCloud(String mdtConfigName, List<Map<String,Object>> records){

        // Get all record info
        Data_Cloud_Ingestion_API_Configuration__mdt config = getMetadataRecord(mdtConfigName);

        // Create the payload
        String payload = createIngestStreamPayload(
            records,
            createFieldMapping(config.Data_Cloud_Ingestion_API_Field_Mappings__r),
            false
        );

        // Stream the data with the generated payload
        streamDataToDataCloud(mdtConfigName, payload, false);
    }


    /**
     * @description Method to stream a list of records to data cloud based on a mtd configuration
     * @param  mdtConfigName The API name of the metadata configuration record
     * @param  payload       The streaming JSON payload
     * @param  isTest        Indicator if the test endpoint needs to be called or the data needs to be send
     * @throws DataCloudUtilException In any unexpected event
     */
    global static void streamDataToDataCloud(String mdtConfigName, String payload, Boolean isTest){
        try{
            // Get all record info
            Data_Cloud_Ingestion_API_Configuration__mdt config = getMetadataRecord(mdtConfigName);

            // Create the ingestion URL endpoint
            String endpoint = String.format('/api/v1/ingest/sources/{0}/{1}{2}',
                new String[]{
                    config.Ingestion_API_Connector_Name__c,
                    config.Ingestion_API_Target_Object_Name__c,
                    (isTest) ? '/actions/test' : ''
                }
            );

            // Execute the call out for a specific named credential
            utl.Rst callout = new utl.Rst(config.Named_Credential_Name__c, true)
            .setHandleSfEndpoint(false)
            .setRequestIdHeader(null)
            .setEndpoint(endpoint)
            .setMethod('POST')
            .setBody(payload)
            .call();

            // For unit test assertions during a test copy the callout data
            if(Test.isRunningTest()){testCallout = callout;}

        }catch(Exception e){
            throw new DataCloudUtilException(String.format(CALLOUT_EXCEPTION_MSG, new String[]{e.getMessage()}));
        }
    }


    /**
     * @description Method to create a mapping between sObject and Data Ingestion Object
     * @param  fieldMappingRecords List of Data_Cloud_Ingestion_API_Field_Mapping__c records
     * @return A string string map with the mapping
     */
    global static Map<String,String> createFieldMapping(Data_Cloud_Ingestion_API_Field_Mapping__mdt[] fieldMappingRecords){

        // Create the output map
        Map<String,String> mapping = new Map<String,String>();

        // Populate the mapping
        if(fieldMappingRecords != null && !fieldMappingRecords.isEmpty()){
            for (Integer i = 0, length=fieldMappingRecords.size(); i < length; i++) {
                mapping.put(fieldMappingRecords[i].Source__c, fieldMappingRecords[i].Target__c);
            }
        }

        // Return the populated mapping
        return mapping;
    }


    /**
     * @description Method to create an ingestion stream payload from records and
     *              a field mapping
     * @param  records      List of any sObject or Platform Event
     * @param  fieldMapping Source field to target field mapping
     * @param  prettyPrint  Indicator if the payload should be serialized pretty
     * @return A JSON String with an ingest API payload format
     */
    global static String createIngestStreamPayload(sObject[] records, Map<String,String> fieldMapping, Boolean prettyPrint){

        // Create the base payload ({"data" : [] })
        Map<String,List<Map<String,Object>>> data = new Map<String,List<Map<String,Object>>>{
            'data' => new List<Map<String,Object>>()
        };

        // Iterate all records, again, beware of the max payload size of 200kb
        for (Integer i = 0, length=records.size(); i < length; i++) {

            // A data item to add to the payload
            Map<String,Object> dataItem = new Map<String,Object>();

            // Populate the data item
            for(String sourceField : fieldMapping.keyset()){

                // populate target field / value
                dataItem.put(
                    fieldMapping.get(sourceField),
                    records[i].get(sourceField)
                );
            }

            // Add the data to the data items list
            data.get('data').add(dataItem);
        }

        // return the JSON String
        return prettyPrint ? JSON.serializePretty(data) : JSON.serialize(data);
    }



    /**
     * @description Method to create an ingestion stream payload from records and
     *              a field mapping. Overload method of the records object
     * @param  records      List of any Object Maps for generating a payload
     * @param  fieldMapping Source field to target field mapping
     * @param  prettyPrint  Indicator if the payload should be serialized pretty
     * @return      A JSON String with an ingest API payload format
     */
    global static String createIngestStreamPayload(List<Map<String,Object>> records, Map<String,String> fieldMapping, Boolean prettyPrint){

        // Create the base payload ({"data" : [] })
        Map<String,List<Map<String,Object>>> data = new Map<String,List<Map<String,Object>>>{
            'data' => new List<Map<String,Object>>()
        };

        // Iterate all records, again, beware of the max payload size of 200kb
        for (Integer i = 0, length=records.size(); i < length; i++) {

            // A data item to add to the payload
            Map<String,Object> dataItem = new Map<String,Object>();

            // Populate the data item
            for(String sourceField : fieldMapping.keyset()){

                // populate target field / value
                dataItem.put(
                    fieldMapping.get(sourceField),
                    records[i].get(sourceField)
                );
            }

            // Add the data to the data items list
            data.get('data').add(dataItem);
        }

        // return the JSON String
        return prettyPrint ? JSON.serializePretty(data) : JSON.serialize(data);
    }


    /** **************************************************************************************************** **
     **                                    GLOBAL BULK INGESTION METHODS                                     **
     ** **************************************************************************************************** **/
    /**
     * @description Method that orchestrates the creation of a bulk API in a single synchronous operation.
     *              !! This is mainly for testing and should be used with caution and small data sets only !!
     * @param mdtConfigName The metadata configuration record name
     * @param operation     Either upsert or delete
     * @param csvFiles      A list of CSV Files to upload to Data Cloud
     */
    global static void ingestBulkCsvDataInDataCloud(String mdtConfigName, String operation, String[] csvFiles){

        // Input validation for the file list
        if(csvFiles == null || csvFiles.size() > 8){
            throw new DataCloudUtilException(CSV_LIST_INPUT_ERROR_MSG);
        }

        // Get all record info
        Data_Cloud_Ingestion_API_Configuration__mdt config = getMetadataRecord(mdtConfigName);

        // Get the NC from the configuration to handle the upsert completely start to finish
        String namedCredentialName = config.Named_Credential_Name__c;

        // Create a correlation Id that can be used in the entire job chain to find messages in the debug logs
        String correlationId = utl.Rst.guid();

        /* --------- STEP 01 - CREATE THE JOB --------- */
        // Create the job ID
        String jobId = createIngestionBulkJob(mdtConfigName, correlationId, operation);

        /* --------- STEP 02 - ADD CSV FILES --------- */
        try{
            // Add all the files
            for (Integer i = 0; i < csvFiles.size(); i++) {
                addCsvToIngestionBulkJob(namedCredentialName, correlationId, jobId, csvFiles[i]);
            }
        }catch(Exception e){
            // If one of the CSV fiels fails, abort the job
            updateIngestionBulkJobState(namedCredentialName, correlationId, jobId, 'Aborted');
            throw new DataCloudUtilException(e.getMessage());
        }

        /* --------- STEP 03 - CLOSE THE JOB --------- */
        try{
            // Finally close the job when ingestion is complete
            updateIngestionBulkJobState(namedCredentialName, correlationId, jobId, 'UploadComplete');
        }catch(Exception e){

            // If the upload complete fails, delete the job so we can start over again
            // If one of the CSV fiels fails, abort the job
            updateIngestionBulkJobState(namedCredentialName, correlationId, jobId, 'Aborted');
            throw new DataCloudUtilException(e.getMessage());
        }
    }


    /**
     * @description Method to add a CSV file (from data) to a Ingestion Job
     * @param mdtConfigName The name of the metadata configuration record
     * @return A list of key value maps with the job details for all jobs
     */
    global static List<Map<String,Object>> getBulkIngestionJobs(String namedCredentialName){
        try{
            // Force an exception for testing purposes
            utl.Tst.forceException('LIST_BULK_JOBS');

            // Output of lists
            List<Map<String,Object>> output = new List<Map<String,Object>>();

            // Get all jobs and iterate the response list
            for(Object record : utl.Jsn.getObjectList('data', (Map<String,Object>) JSON.deserializeUntyped(
                new utl.Rst(namedCredentialName, true)
                    .setHandleSfEndpoint(false)
                    .setRequestIdHeader(null)
                    .setEndpoint('/api/v1/ingest/jobs')
                    .call()
                    .getResponse()
                    .getBody()
                ))
            ){
                //Cnvert records to object map and add to the otuput.
                output.add((Map<String,Object>) record);
            }

            // Return the map
            return output;

        }catch(Exception e){
            throw new DataCloudUtilException(String.format(LIST_BULK_JOBS_ERROR_MSG, new String[]{e.getMessage()}));
        }
    }


    /**
     * @description Method to add a CSV file (from data) to a Ingestion Job
     * @param mdtConfigName The name of the metadata configuration record
     * @param jobId         The Id for the bulk job
     * @return A key value map with the job details
     */
    global static Map<String,Object> getBulkIngestionJobDetails(String namedCredentialName, String jobId){
        try{
            // Force an exception for testing purposes
            utl.Tst.forceException('BULK_JOB_DETAILS');

            // Get all jobs and iterate the response list
            return (Map<String,Object>) JSON.deserializeUntyped(
                new utl.Rst(namedCredentialName, true)
                    .setHandleSfEndpoint(false)
                    .setRequestIdHeader(null)
                    .setEndpoint(String.format('/api/v1/ingest/jobs/{0}', new String[]{jobId}))
                    .call()
                    .getResponse()
                    .getBody()
                );
        }catch(Exception e){
            throw new DataCloudUtilException(String.format(BULK_JOB_DETAILS_ERROR_MSG, new String[]{e.getMessage()}));
        }
    }


    /**
     * @description Method to add a CSV file (from data) to a Ingestion Job
     * @param mdtConfigName The name of the metadata configuration record
     * @param correlationId The correlation Id for the API calls
     * @param operation     The type of operation, either: "upsert" or "delete"
     * @return The Id of the ingestion job
     */
    global static String createIngestionBulkJob(String mdtConfigName, String correlationId, String operation){

        // Validate operation types
        if(!(new Set<String>{'upsert','delete'}).contains(operation)){
            throw new DataCloudUtilException(
                String.format(
                    INVALID_OPERATION_ERROR_MSG,
                    new String[]{operation}
                )
            );
        }

        // Get all record info
        Data_Cloud_Ingestion_API_Configuration__mdt config = getMetadataRecord(mdtConfigName);

        try{
            // Force an exception for testing purposes
            utl.Tst.forceException('CREATE_BULK_JOB');

            // Create the body
            String body = JSON.serialize(new Map<String,String>{
                'object'    => config.Ingestion_API_Target_Object_Name__c,
                'sourceName'=> config.Ingestion_API_Connector_Name__c,
                'operation' => operation
            });

            // Execute the call out for a specific named credential
            utl.Rst callout = new utl.Rst(config.Named_Credential_Name__c, true)
                .setMockResponseIdentifier('CREATE_BULK_JOB')
                .setCorrelationIdHeader(correlationId)
                .setHandleSfEndpoint(false)
                .setRequestIdHeader(null)
                .setEndpoint('/api/v1/ingest/jobs')
                .setMethod('POST')
                .setBody(body)
                .call();

            // Set the callout during tests, so it can be asserted
            if(Test.isRunningTest()){testCallout = callout;}

            // Return the ingestion job Id
            return (String) utl.Jsn.getObject('id', (Map<String,Object>) JSON.deserializeUntyped(callout.getResponse().getBody()));

        }catch(Exception e){
            throw new DataCloudUtilException(String.format(CREATE_BULK_JOB_ERROR_MSG, new String[]{e.getMessage()}));
        }
    }


    /**
     * @description Method to add a CSV file (from data) to a Ingestion Job
     * @param mdtConfigName The name of the metadata configuration record
     * @param correlationId The correlation Id for the API calls
     * @param jobId         The Id for the bulk job
     * @param csvData       The Raw CSV data
     */
    global static void addCsvToIngestionBulkJob(String namedCredentialName, String correlationId, String jobId, String csvData){

        // Input validation for the files
        if(csvData == null || String.isBlank(csvData)){
            throw new DataCloudUtilException(INVALID_CSV_ERROR_MSG);
        }


        try{
            // Force an exception for testing purposes
            utl.Tst.forceException('ADD_CSV_TO_BULK_JOB');

            // Execute the call out for a specific named credential
            utl.Rst callout = new utl.Rst(namedCredentialName, true)
                .setMockResponseIdentifier('ADD_CSV_TO_BULK_JOB')
                .setCorrelationIdHeader(correlationId)
                .setHandleSfEndpoint(false)
                .setRequestIdHeader(null)
                .setEndpoint(String.format('/api/v1/ingest/jobs/{0}/batches', new String[]{jobId}))
                .setMethod('PUT')
                .setHeader('Content-Type','text/csv')
                .setBody(csvData)
                .call();

            // Set the callout during tests, so it can be asserted
            if(Test.isRunningTest()){testCallout = callout;}

        }catch(Exception e){
            throw new DataCloudUtilException(String.format(ADD_CSV_ERROR_MSG, new String[]{e.getMessage()}));
        }
    }


    /**
     * @description Method to update the ingestion Bulk Job state
     * @param mdtConfigName The name of the metadata configuration record
     * @param correlationId The correlation Id for the API calls
     * @param jobId         The Id for the bulk job
     * @param state         The new state ('UploadComplete','Aborted')
     */
    global static void updateIngestionBulkJobState(String namedCredentialName, String correlationId, String jobId, String state){

        // Validate operation types
        if(!(new Set<String>{'UploadComplete','Aborted'}).contains(state)){
            throw new DataCloudUtilException(
                String.format(
                    INVALID_STATE_ERROR_MSG,
                    new String[]{state}
                )
            );
        }

        try{
            // Force an exception for testing purposes
            utl.Tst.forceException('UPDATE_BULK_JOB');

            // Create the body
            String body = JSON.serialize(new Map<String,String>{
                'state' => state
            });

            // Execute the call out for a specific named credential
            utl.Rst callout = new utl.Rst(namedCredentialName, true)
                .setMockResponseIdentifier('UPDATE_BULK_JOB')
                .setCorrelationIdHeader(correlationId)
                .setHandleSfEndpoint(false)
                .setRequestIdHeader(null)
                .setEndpoint(String.format('/api/v1/ingest/jobs/{0}', new String[]{jobId}))
                .setMethod('PATCH')
                .setBody(body)
                .call();

            // Set the callout during tests, so it can be asserted
            if(Test.isRunningTest()){testCallout = callout;}

        }catch(Exception e){
            throw new DataCloudUtilException(String.format(UPDATE_STATE_ERROR_MSG, new String[]{e.getMessage()}));
        }
    }


    /**
     * @description Method to delete the ingestion Bulk Job
     * @param mdtConfigName The name of the metadata configuration record
     * @param correlationId The correlation Id for the API calls
     * @param jobId         The Id for the bulk job
     */
    global static void deleteIngestionBulkJob(String namedCredentialName, String correlationId, String jobId){
        try{
            // Force an exception for testing purposes
            utl.Tst.forceException('DELETE_BULK_JOB');

            // Execute the call out for a specific named credential
            utl.Rst callout = new utl.Rst(namedCredentialName, true)
                .setMockResponseIdentifier('DELETE_BULK_JOB')
                .setCorrelationIdHeader(correlationId)
                .setHandleSfEndpoint(false)
                .setRequestIdHeader(null)
                .setEndpoint(String.format('/api/v1/ingest/jobs/{0}', new String[]{jobId}))
                .setMethod('DELETE')
                .call();

            // Set the callout during tests, so it can be asserted
            if(Test.isRunningTest()){testCallout = callout;}

        }catch(Exception e){
            throw new DataCloudUtilException(String.format(DELETE_ERROR_MSG, new String[]{e.getMessage()}));
        }
    }


    /** **************************************************************************************************** **
     **                                    GLOBAL DATA STRUCTURE CLASSES                                     **
     ** **************************************************************************************************** **/
    /**
     * @description Data structure representing Data Cloud field metadata
     *              Implements comparable to sort on place in order ASC
     */
     global class FieldMetadata implements Comparable{

        // Variables
        global String  name;
        global String  type;
        global Integer typeCode;
        global Integer placeInOrder;
        
        // Main Constructor
        global FieldMetadata(String name, Map<String,Object> metadata){
            this.name         = name;
            this.type         = (String)  metadata.get('type');
            this.typeCode     = (Integer) metadata.get('typeCode');
            this.placeInOrder = (Integer) metadata.get('placeInOrder');
        }

        // Compare order, note that the same order will never occur, so does not need to be checked
        global Integer compareTo(Object compareTo) {
            return (this.placeInOrder > ((FieldMetadata) compareTo).placeInOrder) ? 1 : -1;        
        }
    }


    /** **************************************************************************************************** **
     **                                       GLOBAL EXCEPTION CLASSES                                       **
     ** **************************************************************************************************** **/
    /**
     * @description Exception that is thrown on any generic issue in the Data Cloud Util
     */
    global class DataCloudUtilException extends Exception {}
}