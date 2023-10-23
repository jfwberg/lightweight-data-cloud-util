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
@SuppressWarnings('PMD.OneDeclarationPerLine, PMD.AvoidGlobalModifier')
global with sharing class Dc {


    // Variable to hold the callout details so it can be asserted during a unit test
    @TestVisible private static utl.Rst testCallout;

    // Messages
    @TestVisible private static final String NO_MDT_RECORD_FOUND_MSG = 'No Data_Cloud_Ingestion_API_Configuration__mdt record with the name "{0}" exists.';
    @TestVisible private static final String CALLOUT_EXCEPTION_MSG   = 'Something went wrong during the callout to the Ingest API endpoint: {0}';

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
                                                                    Ingestion_API_Connector_Name__c, Ingestion_API_Target_Object_Name__c, Named_Credential_Name__c,
                                                                    (SELECT Source__c, Target__c FROM Data_Cloud_Ingestion_API_Field_Mappings__r)
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


    /** **************************************************************************************************** **
     **                                  GLOBAL STREAMING INGESTION METHODS                                  **
     ** **************************************************************************************************** **/
    /**
     * @description Method to stream records to data cloud Asynchrounously
     * @param serializedRecords The JSON.serialize(records) version of the records to
     *                          be streamed to data cloud
     * @param  mdtConfigName    The API name of the metadata configuration record
     */
    @future(callout=true)
    global static void streamRecordsToDataCloudAsync(String serializedRecords, String mdtConfigName){

        // We need to rebuilt the records from the JSON
        streamRecordsToDataCloud(
            (SObject[]) JSON.deserialize(serializedRecords, Type.forName('List<SObject>')),
            mdtConfigName
        );
    }


    /**
     * @description Method to stream a list of records to data cloud based on a mtd configuration
     * @param  records                The list of sObjects you want to stream
     * @param  mdtConfigName          The API name of the metadata configuration record
     * @throws DataCloudUtilException In any unexpected event
     */
    global static void streamRecordsToDataCloud(sObject[] records, String mdtConfigName){
        try{
            // Get all record info
            Data_Cloud_Ingestion_API_Configuration__mdt config = getMetadataRecord(mdtConfigName);

            // Create the payload
            String payload = createIngestStreamPayload(
                records,
                createFieldMapping(config.Data_Cloud_Ingestion_API_Field_Mappings__r)
            );

            // Create the ingestion URL endpoint
            String endpoint = String.format('/api/v1/ingest/sources/{0}/{1}',
                new String[]{
                    config.Ingestion_API_Connector_Name__c,
                    config.Ingestion_API_Target_Object_Name__c
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
            throw new DataCloudUtilException(String.format(CALLOUT_EXCEPTION_MSG,new String[]{e.getMessage()}));
        }
    }




    // Bulk objects from query (with mapping)
    // ingestBulkCsvDataToDataCloudAsync
    // ingestBulkCsvFilesToDataCloudAsync



    /** **************************************************************************************************** **
     **                                    GLOBAL BULK INGESTION METHODS                                     **
     ** **************************************************************************************************** **/
    /**
     * @description Method that orchestrates the creation of a bulk API in a single synchronous operation.
     *              !! This is mainly for testing and should be used with caution and small data sets only !!
     */
    global void ingestBulkCsvDataInDataCloud(String mdtConfigName, String operation, String[] csvFiles){

        // Input validation for the file list
        if(csvFiles == null || csvFiles.size() > 8){
            throw new DataCloudUtilException('There should be at least 1 CSV file and no more than 8 csv files in a synchronous transaction');
        }

        // Create a correlation Id that can be used in the entire job chain to find messages in the debug logs
        String correlationId = utl.Rst.guid();

        // Create the job ID
        String jobId = createIngestionBulkJob(mdtConfigName, correlationId, operation);

        try{
            // Add all the files
            for (Integer i = 0; i < csvFiles.size(); i++) {
                addCsvToIngestionBulkJob(mdtConfigName, correlationId, jobId, csvFiles[i]);
            }
        }catch(Exception e){
            // If one of the CSV fiels fails, abort the job
            updateIngestionBulkJobState(mdtConfigName, correlationId, jobId, 'Aborted');
            throw new DataCloudUtilException(e.getMessage());
        }

        try{
            // Finally close the job when ingestion is complete
            updateIngestionBulkJobState(mdtConfigName, correlationId, jobId, 'UploadComplete');
        }catch(Exception e){

            // If the upload complete fails, delete the job so we can start over again
            // If one of the CSV fiels fails, abort the job
            deleteIngestionBulkJob(mdtConfigName, correlationId, jobId);
            throw new DataCloudUtilException(e.getMessage());
        }
    }



    /**
     * @description Method to add a CSV file (from data) to a Ingestion Job
     * @param mdtConfigName The name of the metadata configuration record
     * @param correlationId The correlation Id for the API calls
     * @param jobId         The Id for the bulk job
     * @param csvData       The Raw CSV data
     */
    global static String createIngestionBulkJob(String mdtConfigName, String correlationId, String operation){

        // Validate operation types
        if(!(new Set<String>{'upsert','delete'}).contains(operation)){
            throw new DataCloudUtilException(
                String.format(
                    'Invalid operation type for the bulk ingestion job. "{0}". Valid values are "upsert" or "delete" (case sensitive)',
                    new String[]{operation}
                )
            );
        }

        // Get all record info
        Data_Cloud_Ingestion_API_Configuration__mdt config = getMetadataRecord(mdtConfigName);

        try{
            // Create the body
            String body = JSON.serialize(new Map<String,String>{
                'Object'    => config.Ingestion_API_Target_Object_Name__c,
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

            // Return the ingestion job Id
            return (String) utl.Jsn.getObject('id', (Map<String,Object>) JSON.deserializeUntyped(callout.getResponse().getBody()));

        }catch(Exception e){
            throw new DataCloudUtilException('There was an error creating the Bulk Ingestion Job: ' + e.getMessage());
        }
    }

    
    /**
     * @description Method to add a CSV file (from data) to a Ingestion Job
     * @param mdtConfigName The name of the metadata configuration record
     * @param correlationId The correlation Id for the API calls
     * @param jobId         The Id for the bulk job
     * @param csvData       The Raw CSV data
     */
    global static void addCsvToIngestionBulkJob(String mdtConfigName, String correlationId, String jobId, String csvData){

        // Input validation for the files
        if(csvData == null || String.isBlank(csvData)){
            throw new DataCloudUtilException('You cannot add a blank CSV file to the Ingestion Job');
        }

        // Get all record info
        Data_Cloud_Ingestion_API_Configuration__mdt config = getMetadataRecord(mdtConfigName);

        try{
            // Execute the call out for a specific named credential
            utl.Rst callout = new utl.Rst(config.Named_Credential_Name__c, true)
                .setMockResponseIdentifier('ADD_CSV_TO_BULK_JOB')    
                .setCorrelationIdHeader(correlationId)
                .setHandleSfEndpoint(false)
                .setRequestIdHeader(null)
                .setEndpoint(String.format('/api/v1/ingest/jobs/{0}/batches', new String[]{jobId}))
                .setMethod('PUT')
                .setHeader('Content-Type','text/csv')
                .setBody(csvData)
                .call();

        }catch(Exception e){
            throw new DataCloudUtilException('There was an error whilst adding CSV Data to the Bulk Ingestion Job: ' + e.getMessage());
        }
    }


    /**
     * @description Method to update the ingestion Bulk Job state
     * @param mdtConfigName The name of the metadata configuration record
     * @param correlationId The correlation Id for the API calls
     * @param jobId         The Id for the bulk job
     * @param state         The new state ('UploadComplete','Aborted')
     */
    global static void updateIngestionBulkJobState(String mdtConfigName, String correlationId, String jobId, String state){

        // Validate operation types
        if(!(new Set<String>{'UploadComplete','Aborted'}).contains(state)){
            throw new DataCloudUtilException(
                String.format(
                    'Invalid state type for the bulk ingestion job. "{0}". Valid values are "UploadComplete" or "Aborted" (case sensitive)',
                    new String[]{state}
                )
            );
        }

        // Get all record info
        Data_Cloud_Ingestion_API_Configuration__mdt config = getMetadataRecord(mdtConfigName);

        try{
            // Create the body
            String body = JSON.serialize(new Map<String,String>{
                'state' => state
            });

            // Execute the call out for a specific named credential
            utl.Rst callout = new utl.Rst(config.Named_Credential_Name__c, true)
                .setMockResponseIdentifier('UPDATE_BULK_JOB')    
                .setCorrelationIdHeader(correlationId)
                .setHandleSfEndpoint(false)
                .setRequestIdHeader(null)
                .setEndpoint(String.format('/api/v1/ingest/jobs/{0}', new String[]{jobId}))
                .setMethod('PATCH')
                .setBody(body)
                .call();
        }catch(Exception e){
            throw new DataCloudUtilException('There was an error whilst updating the state of the Bulk Ingestion Job: ' + e.getMessage());
        }
    }


    /** **************************************************************************************************** **
     **                                       PRIVATE SUPPORT METHODS                                        **
     ** **************************************************************************************************** **/
    /**
     * @description Method to delete the ingestion Bulk Job
     * @param mdtConfigName The name of the metadata configuration record
     * @param correlationId The correlation Id for the API calls
     * @param jobId         The Id for the bulk job
     */
    private static void deleteIngestionBulkJob(String mdtConfigName, String correlationId, String jobId){
        // Get all record info
        Data_Cloud_Ingestion_API_Configuration__mdt config = getMetadataRecord(mdtConfigName);

        try{
            // Execute the call out for a specific named credential
            utl.Rst callout = new utl.Rst(config.Named_Credential_Name__c, true)
                .setMockResponseIdentifier('DELETE_BULK_JOB')    
                .setCorrelationIdHeader(correlationId)
                .setHandleSfEndpoint(false)
                .setRequestIdHeader(null)
                .setEndpoint(String.format('/api/v1/ingest/jobs/{0}', new String[]{jobId}))
                .setMethod('DELETE')
                .call();
        }catch(Exception e){
            throw new DataCloudUtilException('There was an error whilst deleting the Bulk Ingestion Job: ' + e.getMessage());
        }
    }


    /**
     * @description Method to create a mapping between sObject and Data Ingestion Object
     * @param  fieldMappingRecords List of Data_Cloud_Ingestion_API_Field_Mapping__c records
     * @return      A string string map with the mapping
     */
    private static Map<String,String> createFieldMapping(Data_Cloud_Ingestion_API_Field_Mapping__mdt[] fieldMappingRecords){

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
     * @return A JSON String with an ingest API payload format
     */
    private static String createIngestStreamPayload(sObject[] records, Map<String,String> fieldMapping){

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
        return JSON.serialize(data);
    }


    /** **************************************************************************************************** **
     **                                       GLOBAL EXCEPTION METHODS                                       **
     ** **************************************************************************************************** **/
    /**
     * @description Exception that is thrown on any generic issue in the Data Cloud Util
     */
    global class DataCloudUtilException extends Exception {}
}