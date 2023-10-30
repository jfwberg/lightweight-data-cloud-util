/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           August 2023
 * @copyright      (c) 2023 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Test class for the "Dc" Apex Class
 */
@IsTest
private with sharing class DcTest {

    /** **************************************************************************************************** **
     **                                          PRIVATE CONSTANTS                                           **
     ** **************************************************************************************************** **/
    // Permission set to test with
    private static final String PERMISSION_SET_NAME = 'Lightweight_Data_Cloud_Util';

    // Create a test user
    private static final User TST_USER = utl.Tst.createRunAsUser(
        utl.Tst.MINIMUM_ACCESS_PROFILE,
        PERMISSION_SET_NAME
    );

    /** **************************************************************************************************** **
     **                                        GLOBAL SUPPORT METHODS                                        **
     ** **************************************************************************************************** **/
    @IsTest
    static void testGetMetadataRecord(){

        // Variable to hold the metadata config record
        Data_Cloud_Ingestion_API_Configuration__mdt mdtRecord;

        // Variable to hold the test Exception
        Exception testException;

        // Run test
        Test.startTest();
        System.runAs(TST_USER){

            // Query the record
            mdtRecord = Dc.getMetadataRecord('Apex_Unit_Test');

            // Test exception
            try{
                // Invalid id
                Dc.getMetadataRecord('utl__Invalid');

                // This method will fail the test as it should not be reached
                utl.Tst.assertExceptionHasBeenThrow();

            }catch(Exception e){
                testException = e;
            }
        }
        Test.stopTest();

        // Check there are 2 mapping fields
        Assert.areEqual(2, mdtRecord.Data_Cloud_Ingestion_API_Field_Mappings__r.size(), 'Unexpected number of field mappings');

        // Validate the exception message
        utl.Tst.assertExceptionMessage(Dc.NO_MDT_RECORD_FOUND_MSG, 'utl__Invalid', testException);
    }


    @IsTest
    static void testGetOrderedColumnNamesFromMetadata(){

        // Columns to assert
        Set<String> columns;

        // Variable to hold the test Exceptions
        Exception validationException;
        Exception generalException;

        // Run test
        Test.startTest();
        System.runAs(TST_USER){
            // Typical metadata String
            String metadataJSON = '{ "metadata": { "ssot__CreatedDate__c": { "type": "TIMESTAMP WITH TIME ZONE", "placeInOrder": 1, "typeCode": 2014 }, "ssot__Name__c": { "type": "VARCHAR", "placeInOrder": 2, "typeCode": 12 }, "ssot__Id__c": { "type": "VARCHAR", "placeInOrder": 0, "typeCode": 12 } } }';

            // Get the metadata from the JSON String
            columns = Dc.getOrderedColumnNamesFromMetadata(utl.Jsn.getObjectMap('metadata',(Map<String,Object>) JSON.deserializeUntyped(metadataJSON)));

            // Exception path
            try{
                Dc.getOrderedColumnNamesFromMetadata(null);

                // This method will fail the test as it should not be reached
                utl.Tst.assertExceptionHasBeenThrow();

            }catch(Exception e){
                validationException = e;
            }

            // Exception path
            try{
                // Force exception
                utl.Tst.addForcedException('ORDER_COLUMNS');
                Dc.getOrderedColumnNamesFromMetadata(new Map<String,Object>());

                // This method will fail the test as it should not be reached
                utl.Tst.assertExceptionHasBeenThrow();

            }catch(Exception e){
                generalException = e;
            }
        }
        Test.stopTest();

        // Assert the list of column names is ordered
        Assert.areEqual(
            new Set<String>{'ssot__Id__c', 'ssot__CreatedDate__c', 'ssot__Name__c'},
            columns,
            'Unexpected column order'
        );

        // Assert exception
        utl.Tst.assertExceptionMessage(Dc.INVALID_MTD_INPUT_ERROR_MSG, validationException);

        // Assert exception
        utl.Tst.assertExceptionMessage(
            Dc.INVALID_MTD_JSON_ERROR_MSG,
            utl.Tst.getForcedExceptionMessage(),
            generalException
        );

    }

    /** **************************************************************************************************** **
     **                                  GLOBAL STREAMING INGESTION METHODS                                  **
     ** **************************************************************************************************** **/
    @IsTest
    static void testStreamRecordsToDataCloudAsync(){

        // Run test
        Test.startTest();

        System.runAs(TST_USER){

            // Setup the callout response
            utl.Mck.setResponse(202, '{"accepted" : true}');

            Dc.streamRecordsToDataCloudAsync(
                JSON.serialize([SELECT Id, Username From User WHERE Id=:UserInfo.getUserId()]),
                'Apex_Unit_Test'
            );
        }
        Test.stopTest();

        // Handle asserts
        assertSuccessfullCallout();
    }


    @IsTest
    static void testStreamRecordsToDataCloud(){

        // Run test
        Test.startTest();

        System.runAs(TST_USER){

            // Setup the callout response
            utl.Mck.setResponse(202, '{"accepted" : true}');

            // No exception should have been thrown
            Dc.streamRecordsToDataCloud(
                'Apex_Unit_Test',
                [SELECT Id, Username From User WHERE Id=:UserInfo.getUserId()]
            );
        }
        Test.stopTest();

        // Handle asserts
        assertSuccessfullCallout();
    }


    @IsTest
    static void testStreamRecordsToDataCloudErrorResponse(){

        // Variable to hold the test Exception
        Exception testException;

        // Run test
        Test.startTest();
        System.runAs(TST_USER){
            try{
                // Setup the callout response
                utl.Mck.setResponse(429, '{"error": "Bad Request", "message": "JSON is properly formatted but has a mismatch with Schema."}');

                // No exception should have been thrown
                Dc.streamRecordsToDataCloud(
                    'Apex_Unit_Test',
                    [SELECT Id, Username From User WHERE Id=:UserInfo.getUserId()]
                );

                // This method will fail the test as it should not be reached
                utl.Tst.assertExceptionHasBeenThrow();

            }catch(Exception e){
                testException = e;
            }
        }
        Test.stopTest();

        // Assert exception
        utl.Tst.assertExceptionMessage(Dc.CALLOUT_EXCEPTION_MSG,'Bad Request :: JSON is properly formatted but has a mismatch with Schema.', testException);
    }


    /** **************************************************************************************************** **
     **                                    GLOBAL BULK INGESTION METHODS                                     **
     ** **************************************************************************************************** **/
    @IsTest
    static void testIngestBulkCsvDataInDataCloud(){

        // Variable to hold the test Exceptions
        Exception validationException;
        Exception addCsvException;
        Exception closeException;

        // Run test
        Test.startTest();
        System.runAs(TST_USER){
            // Setup the callout responses
            utl.Mck.addResponse('CREATE_BULK_JOB',     202, '{"id": "4d5a4477-e27f-4bc1-a219-31e79407eade", "operation": "upsert", "object": "my_object", "sourceName": "my_api_connector", "createdById": "005R0000000sJ1hIAE", "createdDate": "2021-04-05T13:35:31.000Z", "systemModstamp": "2021-04-05T13:35:31.000Z", "state": "Open", "contentType": "CSV", "apiVersion": "v1", "contentUrl": "api/v1/ingest/jobs/4d5a4477-e27f-4bc1-a219-31e79407eade/batches"}');
            utl.Mck.addResponse('ADD_CSV_TO_BULK_JOB', 202, null);
            utl.Mck.addResponse('UPDATE_BULK_JOB',     200, '{ "id": "7505e000001NLkPAAW", "operation": "upsert", "object": "Contact", "createdById": "0055e000003PfMYAA0", "createdDate": "2021-06-10T13:25:40.000Z", "systemModstamp": "2021-06-10T13:25:40.000Z", "state": "UploadComplete", "contentType": "CSV", "apiVersion": "v1" }');
            utl.Mck.addResponse('DELETE_BULK_JOB',     204, null);

            // Happy path
            Dc.ingestBulkCsvDataInDataCloud( 'Apex_Unit_Test', 'upsert', new String[]{'TEST_CSV_DATA'});

            // Validation error path
            try{
                Dc.ingestBulkCsvDataInDataCloud( 'Apex_Unit_Test', 'upsert', null);

                // This method will fail the test as it should not be reached
                utl.Tst.assertExceptionHasBeenThrow();
            }catch(Exception e){
                validationException = e;
            }

            // CSV error path
            try{
                utl.Mck.addResponse('ADD_CSV_TO_BULK_JOB', 429, '{"error": "Bad Request", "message": "Data Cloud Error Message Add CSV"}');
                Dc.ingestBulkCsvDataInDataCloud( 'Apex_Unit_Test', 'upsert', new String[]{'TEST_CSV_DATA'});

                // This method will fail the test as it should not be reached
                utl.Tst.assertExceptionHasBeenThrow();
            }catch(Exception e){
                addCsvException = e;
            }

            // Close error path
            try{
                utl.Mck.addResponse('ADD_CSV_TO_BULK_JOB', 202, null);
                utl.Mck.addResponse('UPDATE_BULK_JOB', 429, '{"error": "Bad Request", "message": "Data Cloud Error Message Update"}');
                Dc.ingestBulkCsvDataInDataCloud( 'Apex_Unit_Test', 'upsert', new String[]{'TEST_CSV_DATA'});

                // This method will fail the test as it should not be reached
                utl.Tst.assertExceptionHasBeenThrow();
            }catch(Exception e){
                closeException = e;
            }
        }
        Test.stopTest();

        // Assert the add CSV error
        utl.Tst.assertExceptionMessage(Dc.ADD_CSV_ERROR_MSG, 'Bad Request :: Data Cloud Error Message Add CSV', addCsvException);

        // Assert the add CSV error
        utl.Tst.assertExceptionMessage(Dc.UPDATE_STATE_ERROR_MSG, 'Bad Request :: Data Cloud Error Message Update', closeException);
    }


    @IsTest
    static void testCreateIngestionBulkJob(){

        // Variable to hold the test Exception
        Exception validationException;
        Exception generalException;

        // Variable to assert the job id
        String jobId;

        // Run test
        Test.startTest();
        System.runAs(TST_USER){

            // Setup the callout responses
            utl.Mck.addResponse('CREATE_BULK_JOB', 202, '{"id": "4d5a4477-e27f-4bc1-a219-31e79407eade", "operation": "upsert", "object": "my_object", "sourceName": "my_api_connector", "createdById": "005R0000000sJ1hIAE", "createdDate": "2021-04-05T13:35:31.000Z", "systemModstamp": "2021-04-05T13:35:31.000Z", "state": "Open", "contentType": "CSV", "apiVersion": "v1", "contentUrl": "api/v1/ingest/jobs/4d5a4477-e27f-4bc1-a219-31e79407eade/batches"}');

            // Happy path
            jobId = Dc.createIngestionBulkJob( 'Apex_Unit_Test', 'CORRELATION_ID', 'upsert');

            // Error path
            try{
                jobId = Dc.createIngestionBulkJob( 'Apex_Unit_Test', 'CORRELATION_ID','invalid');

                // This method will fail the test as it should not be reached
                utl.Tst.assertExceptionHasBeenThrow();

            }catch(Exception e){
                validationException = e;
            }

            // Forced error path
            try{
                // Force the exception
                utl.Tst.addForcedException('CREATE_BULK_JOB');

                jobId = Dc.createIngestionBulkJob( 'Apex_Unit_Test', 'CORRELATION_ID','delete');

                // This method will fail the test as it should not be reached
                utl.Tst.assertExceptionHasBeenThrow();

            }catch(Exception e){
                generalException = e;
            }
        }
        Test.stopTest();

        // This test validates all calls run correctly
        Assert.areEqual('4d5a4477-e27f-4bc1-a219-31e79407eade', jobId, 'Unexpected jobId');

        // Assert the expected response code has been given
        Assert.areEqual(202, Dc.testCallout.getResponse().getStatusCode(), 'Unexpected response code');

        // Assert the validation exception message
        utl.Tst.assertExceptionMessage(Dc.INVALID_OPERATION_ERROR_MSG, 'invalid', validationException);

        // Assert the general exception message
        utl.Tst.assertExceptionMessage(Dc.CREATE_BULK_JOB_ERROR_MSG, utl.Tst.getForcedExceptionMessage(), generalException);
    }


    @IsTest
    static void testAddCsvToIngestionBulkJob(){

        // Variable to hold the test Exception
        Exception validationException;
        Exception generalException;

        // Run test
        Test.startTest();
        System.runAs(TST_USER){

            // Setup the callout responses
            utl.Mck.addResponse('ADD_CSV_TO_BULK_JOB', 202, null);

            // Happy path
            Dc.addCsvToIngestionBulkJob( 'Apex_Unit_Test', 'CORRELATION_ID','jobId', 'CSV_DATA');

            // Error path
            try{
                Dc.addCsvToIngestionBulkJob( 'Apex_Unit_Test', 'CORRELATION_ID','jobId', null);

                // This method will fail the test as it should not be reached
                utl.Tst.assertExceptionHasBeenThrow();

            }catch(Exception e){
                validationException = e;
            }

            // Forced error path
            try{
                // Force the exception
                utl.Tst.addForcedException('ADD_CSV_TO_BULK_JOB');

                Dc.addCsvToIngestionBulkJob( 'Apex_Unit_Test', 'CORRELATION_ID','jobId', 'CSV_DATA');

                // This method will fail the test as it should not be reached
                utl.Tst.assertExceptionHasBeenThrow();

            }catch(Exception e){
                generalException = e;
            }
        }
        Test.stopTest();

        // Assert the expected response code has been given
        Assert.areEqual(202, Dc.testCallout.getResponse().getStatusCode(), 'Unexpected response code');

        // Assert the validation exception message
        utl.Tst.assertExceptionMessage(Dc.INVALID_CSV_ERROR_MSG, 'invalid', validationException);

        // Assert the general exception message
        utl.Tst.assertExceptionMessage(Dc.ADD_CSV_ERROR_MSG, utl.Tst.getForcedExceptionMessage(), generalException);
    }


    @IsTest
    static void testUpdateIngestionBulkJobState(){

        // Variable to hold the test Exception
        Exception validationException;
        Exception generalException;

        // Run test
        Test.startTest();
        System.runAs(TST_USER){

            // Setup the callout responses
            utl.Mck.addResponse('UPDATE_BULK_JOB', 200, '{ "id": "7505e000001NLkPAAW", "operation": "upsert", "object": "Contact", "createdById": "0055e000003PfMYAA0", "createdDate": "2021-06-10T13:25:40.000Z", "systemModstamp": "2021-06-10T13:25:40.000Z", "state": "UploadComplete", "contentType": "CSV", "apiVersion": "v1" }');

            // Happy path
            Dc.updateIngestionBulkJobState( 'Apex_Unit_Test', 'CORRELATION_ID','jobId', 'UploadComplete');

            // Error path
            try{
                Dc.updateIngestionBulkJobState( 'Apex_Unit_Test', 'CORRELATION_ID','jobId', 'invalid');

                // This method will fail the test as it should not be reached
                utl.Tst.assertExceptionHasBeenThrow();

            }catch(Exception e){
                validationException = e;
            }

            // Forced error path
            try{
                // Force the exception
                utl.Tst.addForcedException('UPDATE_BULK_JOB');

                Dc.updateIngestionBulkJobState( 'Apex_Unit_Test', 'CORRELATION_ID','jobId', 'UploadComplete');

                // This method will fail the test as it should not be reached
                utl.Tst.assertExceptionHasBeenThrow();

            }catch(Exception e){
                generalException = e;
            }
        }
        Test.stopTest();

        // Assert the expected response code has been given
        Assert.areEqual(200, Dc.testCallout.getResponse().getStatusCode(), 'Unexpected response code');

        // Assert the validation exception message
        utl.Tst.assertExceptionMessage(Dc.INVALID_STATE_ERROR_MSG, 'invalid', validationException);

        // Assert the general exception message
        utl.Tst.assertExceptionMessage(Dc.UPDATE_STATE_ERROR_MSG, utl.Tst.getForcedExceptionMessage(), generalException);
    }


    @IsTest
    static void testDeleteIngestionBulkJob(){

        // Variable to hold the test Exception
        Exception generalException;

        // Run test
        Test.startTest();
        System.runAs(TST_USER){
            // Setup the callout responses
            utl.Mck.addResponse('DELETE_BULK_JOB', 204, null);

            // Happy path
            Dc.deleteIngestionBulkJob( 'Apex_Unit_Test', 'CORRELATION_ID','jobId');

            // Forced error path
            try{
                // Force the exception
                utl.Tst.addForcedException('DELETE_BULK_JOB');

                Dc.deleteIngestionBulkJob( 'Apex_Unit_Test', 'CORRELATION_ID','jobId');

                // This method will fail the test as it should not be reached
                utl.Tst.assertExceptionHasBeenThrow();

            }catch(Exception e){
                generalException = e;
            }
        }
        Test.stopTest();

        // Assert the expected response code has been given
        Assert.areEqual(204, Dc.testCallout.getResponse().getStatusCode(), 'Unexpected response code');

        // Assert the general exception message
        utl.Tst.assertExceptionMessage(Dc.DELETE_ERROR_MSG, utl.Tst.getForcedExceptionMessage(), generalException);
    }



    /** **************************************************************************************************** **
     **                                     PRIVATE TEST SUPPORT METHODS                                     **
     ** **************************************************************************************************** **/
    private static void assertSuccessfullCallout(){
        // Assert the status code
        Assert.areEqual(
            202,
            Dc.testCallout.getResponse().getStatusCode(),
            'Unexpected status code'
        );

        // Assert the response
        Assert.areEqual(
            '{"accepted" : true}',
            Dc.testCallout.getResponse().getBody(),
            'Unexpected response body'
        );

        // Assert the status code
        Assert.areEqual(
            Dc.testCallout.getRequest().getBody(),
            '{"data":[{"Target_Username":"'+TST_USER.Username+'","Target_Id":"'+TST_USER.Id+'"}]}'
        );
    }

}