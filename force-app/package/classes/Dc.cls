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


    /**
     * @description Exception that is thrown on any generic issue in the Data Cloud Util
     */
    global class DataCloudUtilException extends Exception {}
}