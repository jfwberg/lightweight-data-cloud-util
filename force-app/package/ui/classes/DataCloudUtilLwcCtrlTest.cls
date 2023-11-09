/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           August 2023
 * @copyright      (c) 2023 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Test Class for the Data Cloud LWC Controller Methods
 */
@IsTest
private with sharing class DataCloudUtilLwcCtrlTest {

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

    // API Responses
    private static final String SOQL_RESPONSE           = '{"totalSize":1,"done":true,"records":[{"attributes":{"type":"User","url":"/services/data/v53.0/sobjects/User/005Q1000000RJtBIAW"},"Id":"005Q1000000RJtBIAW"}]}';
    private static final String DC_QUERY_RESPONSE       = '{ "data": [ [ "0_1", "0_2" ], [ "1_1", "1_2" ] ], "startTime": "2021-10-06T13:36:30.33265Z", "endTime": "2021-10-06T13:36:32.81927Z", "rowCount": 2, "queryId": "20211006_133630_00059_9adm3", "nextBatchId": "09151b49-54ed-4948-8139-1f4c7c3a9581", "done": false, "metadata": { "Field_00__c": { "type": "VARCHAR", "placeInOrder": 0, "typeCode": 12 }, "Field_01__c": { "type": "VARCHAR", "placeInOrder": 1, "typeCode": 12 } } }';
    private static final String INGESTION_RESPONSE      = '{"accepted" : true}';
    private static final String CREATE_BULK_JOB_RESPONSE= '{"id": "4d5a4477-e27f-4bc1-a219-31e79407eade", "operation": "upsert", "object": "my_object", "sourceName": "my_api_connector", "createdById": "005R0000000sJ1hIAE", "createdDate": "2021-04-05T13:35:31.000Z", "systemModstamp": "2021-04-05T13:35:31.000Z", "state": "Open", "contentType": "CSV", "apiVersion": "v1", "contentUrl": "api/v1/ingest/jobs/4d5a4477-e27f-4bc1-a219-31e79407eade/batches"}';
    private static final String SINGLE_JOB_RESPONSE     = '{ "id": "4d5a4477-e27f-4bc1-a219-31e79407eade" }';
    private static final String MULTI_JOB_RESPONSE      = '{ "data": [ { "id": "4d5a4477-e27f-4bc1-a219-31e79407eade" }, { "id": "9d5a4477-e27f-4bc1-a219-31e79407eade" } ] }';


    /** **************************************************************************************************** **
     **                                    CUSTOM METADATA AURA METHODS                                      **
     ** **************************************************************************************************** **/
    @IsTest
    static void testGetMtdConfigOptions(){
        // Variable to hold the test Exceptions
        Exception auraException;

        // Run test
        Test.startTest();
        System.runAs(TST_USER){
            // Happy Path
            DataCloudUtilLwcCtrl.getMtdConfigOptions();

            // Forced error path
            try{
                // Force the exception
                utl.Tst.addForcedException('AURA_EXCEPTION');

                // Execute method
                DataCloudUtilLwcCtrl.getMtdConfigOptions();

                // This method will fail the test as it should not be reached
                utl.Tst.assertExceptionHasBeenThrow();

            }catch(Exception e){
                auraException = e;
            }
        }
        Test.stopTest();

        // Assert exception message
        Assert.areEqual('Script-thrown exception', auraException.getMessage(), 'Unexpected Exception Message');
    }


    @IsTest
    static void testGetMetadataInfo(){
        // Variable to hold the test Exceptions
        Exception auraException;

        // Run test
        Test.startTest();
        System.runAs(TST_USER){
            // Happy Path
            DataCloudUtilLwcCtrl.getMetadataInfo('Apex_Unit_Test','4d5a4477-e27f-4bc1-a219-31e79407eade');

            // Forced error path
            try{
                // Force the exception
                utl.Tst.addForcedException('AURA_EXCEPTION');

                // Execute method
                DataCloudUtilLwcCtrl.getMetadataInfo('Apex_Unit_Test','4d5a4477-e27f-4bc1-a219-31e79407eade');

                // This method will fail the test as it should not be reached
                utl.Tst.assertExceptionHasBeenThrow();

            }catch(Exception e){
                auraException = e;
            }
        }
        Test.stopTest();

        // Assert exception message
        Assert.areEqual('Script-thrown exception', auraException.getMessage(), 'Unexpected Exception Message');
    }


    /** **************************************************************************************************** **
     **                                     BULK INGESTION AURA METHODS                                      **
     ** **************************************************************************************************** **/
    @IsTest
    static void testGetCsvPlaceholder(){
        // Variable to hold the test Exceptions
        Exception auraException;

        // Run test
        Test.startTest();
        System.runAs(TST_USER){
            // Happy Path
            DataCloudUtilLwcCtrl.getCsvPlaceholder('Apex_Unit_Test');

            // Forced error path
            try{
                // Force the exception
                utl.Tst.addForcedException('AURA_EXCEPTION');

                // Execute method
                DataCloudUtilLwcCtrl.getCsvPlaceholder('Apex_Unit_Test');

                // This method will fail the test as it should not be reached
                utl.Tst.assertExceptionHasBeenThrow();

            }catch(Exception e){
                auraException = e;
            }
        }
    }


    @IsTest
    static void testGetJobInfo(){
        // Variable to hold the test Exceptions
        Exception auraException;

        // Run test
        Test.startTest();
        System.runAs(TST_USER){
            // Happy Path
            utl.Mck.setResponse(SINGLE_JOB_RESPONSE);
            DataCloudUtilLwcCtrl.getJobInfo('Apex_Unit_Test','4d5a4477-e27f-4bc1-a219-31e79407eade');

            // Forced error path
            try{
                // Force the exception
                utl.Tst.addForcedException('AURA_EXCEPTION');

                // Execute method
                DataCloudUtilLwcCtrl.getJobInfo('Apex_Unit_Test','4d5a4477-e27f-4bc1-a219-31e79407eade');

                // This method will fail the test as it should not be reached
                utl.Tst.assertExceptionHasBeenThrow();

            }catch(Exception e){
                auraException = e;
            }
        }
        Test.stopTest();

        // Assert exception message
        Assert.areEqual('Script-thrown exception', auraException.getMessage(), 'Unexpected Exception Message');
    }


    @IsTest
    static void testGetIngestionJobTable(){
        // Variable to hold the test Exceptions
        Exception auraException;

        // Run test
        Test.startTest();
        System.runAs(TST_USER){
            // Happy Path
            utl.Mck.setResponse(MULTI_JOB_RESPONSE);
            DataCloudUtilLwcCtrl.getIngestionJobTable('Apex_Unit_Test');

            // Forced error path
            try{
                // Force the exception
                utl.Tst.addForcedException('AURA_EXCEPTION');

                // Execute method
                DataCloudUtilLwcCtrl.getIngestionJobTable('Apex_Unit_Test');

                // This method will fail the test as it should not be reached
                utl.Tst.assertExceptionHasBeenThrow();

            }catch(Exception e){
                auraException = e;
            }
        }
        Test.stopTest();

        // Assert exception message
        Assert.areEqual('Script-thrown exception', auraException.getMessage(), 'Unexpected Exception Message');
    }


    @IsTest
    static void testNewJob(){
        // Variable to hold the test Exceptions
        Exception auraException;

        // Run test
        Test.startTest();
        System.runAs(TST_USER){
            // Happy Path
            utl.Mck.addResponse('CREATE_BULK_JOB', 202, CREATE_BULK_JOB_RESPONSE);
            DataCloudUtilLwcCtrl.newJob('Apex_Unit_Test');

            // Forced error path
            try{
                // Force the exception
                utl.Tst.addForcedException('AURA_EXCEPTION');

                // Execute method
                DataCloudUtilLwcCtrl.newJob('Apex_Unit_Test');

                // This method will fail the test as it should not be reached
                utl.Tst.assertExceptionHasBeenThrow();

            }catch(Exception e){
                auraException = e;
            }
        }
        Test.stopTest();

        // Assert exception message
        Assert.areEqual('Script-thrown exception', auraException.getMessage(), 'Unexpected Exception Message');
    }


    @IsTest
    static void testAbortJob(){
        // Variable to hold the test Exceptions
        Exception auraException;

        // Run test
        Test.startTest();
        System.runAs(TST_USER){
            // Happy Path
            utl.Mck.addResponse('UPDATE_BULK_JOB', 202, INGESTION_RESPONSE);
            DataCloudUtilLwcCtrl.abortJob('Apex_Unit_Test','4d5a4477-e27f-4bc1-a219-31e79407eade');

            // Forced error path
            try{
                // Force the exception
                utl.Tst.addForcedException('AURA_EXCEPTION');

                // Execute method
                DataCloudUtilLwcCtrl.abortJob('Apex_Unit_Test','4d5a4477-e27f-4bc1-a219-31e79407eade');

                // This method will fail the test as it should not be reached
                utl.Tst.assertExceptionHasBeenThrow();

            }catch(Exception e){
                auraException = e;
            }
        }
        Test.stopTest();

        // Assert exception message
        Assert.areEqual('Script-thrown exception', auraException.getMessage(), 'Unexpected Exception Message');
    }


    @IsTest
    static void testCompleteJob(){
        // Variable to hold the test Exceptions
        Exception auraException;

        // Run test
        Test.startTest();
        System.runAs(TST_USER){
            // Happy Path
            utl.Mck.addResponse('UPDATE_BULK_JOB', 202, INGESTION_RESPONSE);
            DataCloudUtilLwcCtrl.completeJob('Apex_Unit_Test','4d5a4477-e27f-4bc1-a219-31e79407eade');

            // Forced error path
            try{
                // Force the exception
                utl.Tst.addForcedException('AURA_EXCEPTION');

                // Execute method
                DataCloudUtilLwcCtrl.completeJob('Apex_Unit_Test','4d5a4477-e27f-4bc1-a219-31e79407eade');

                // This method will fail the test as it should not be reached
                utl.Tst.assertExceptionHasBeenThrow();

            }catch(Exception e){
                auraException = e;
            }
        }
        Test.stopTest();

        // Assert exception message
        Assert.areEqual('Script-thrown exception', auraException.getMessage(), 'Unexpected Exception Message');
    }


    @IsTest
    static void testDeleteJob(){
        // Variable to hold the test Exceptions
        Exception auraException;

        // Run test
        Test.startTest();
        System.runAs(TST_USER){
            // Happy Path
            utl.Mck.addResponse('DELETE_BULK_JOB', 202, INGESTION_RESPONSE);
            DataCloudUtilLwcCtrl.deleteJob('Apex_Unit_Test','4d5a4477-e27f-4bc1-a219-31e79407eade');

            // Forced error path
            try{
                // Force the exception
                utl.Tst.addForcedException('AURA_EXCEPTION');

                // Execute method
                DataCloudUtilLwcCtrl.deleteJob('Apex_Unit_Test','4d5a4477-e27f-4bc1-a219-31e79407eade');

                // This method will fail the test as it should not be reached
                utl.Tst.assertExceptionHasBeenThrow();

            }catch(Exception e){
                auraException = e;
            }
        }
        Test.stopTest();

        // Assert exception message
        Assert.areEqual('Script-thrown exception', auraException.getMessage(), 'Unexpected Exception Message');
    }


    @IsTest
    static void testAddCsv(){
        // Variable to hold the test Exceptions
        Exception auraException;

        // Run test
        Test.startTest();
        System.runAs(TST_USER){
            // Happy Path
            utl.Mck.addResponse('ADD_CSV_TO_BULK_JOB', 202, INGESTION_RESPONSE);
            DataCloudUtilLwcCtrl.addCsv('Apex_Unit_Test','4d5a4477-e27f-4bc1-a219-31e79407eade','a,b,c\n1,2,3');

            // Forced error path
            try{
                // Force the exception
                utl.Tst.addForcedException('AURA_EXCEPTION');

                // Execute method
                DataCloudUtilLwcCtrl.addCsv('Apex_Unit_Test','4d5a4477-e27f-4bc1-a219-31e79407eade','a,b,c\n1,2,3');

                // This method will fail the test as it should not be reached
                utl.Tst.assertExceptionHasBeenThrow();

            }catch(Exception e){
                auraException = e;
            }
        }
        Test.stopTest();

        // Assert exception message
        Assert.areEqual('Script-thrown exception', auraException.getMessage(), 'Unexpected Exception Message');
    }


    /** **************************************************************************************************** **
     **                                  STREAMING INGESTION AURA METHODS                                    **
     ** **************************************************************************************************** **/
    @IsTest
    static void testGetStreamingPlaceholder(){
        // Variable to hold the test Exceptions
        Exception auraException;

        // Run test
        Test.startTest();
        System.runAs(TST_USER){
            // Happy Path
            DataCloudUtilLwcCtrl.getStreamingPlaceholder('Apex_Unit_Test');

            // Forced error path
            try{
                // Force the exception
                utl.Tst.addForcedException('AURA_EXCEPTION');

                // Execute method
                DataCloudUtilLwcCtrl.getStreamingPlaceholder('Apex_Unit_Test');

                // This method will fail the test as it should not be reached
                utl.Tst.assertExceptionHasBeenThrow();

            }catch(Exception e){
                auraException = e;
            }
        }
        Test.stopTest();

        // Assert exception message
        Assert.areEqual('Script-thrown exception', auraException.getMessage(), 'Unexpected Exception Message');
    }


    @IsTest
    static void testSendDataStream(){
        // Variable to hold the test Exceptions
        Exception auraException;

        // Run test
        Test.startTest();
        System.runAs(TST_USER){
            // Happy Path
            utl.Mck.setResponse(INGESTION_RESPONSE);
            DataCloudUtilLwcCtrl.sendDataStream('Apex_Unit_Test','{}');

            // Forced error path
            try{
                // Force the exception
                utl.Tst.addForcedException('AURA_EXCEPTION');

                // Execute method
                DataCloudUtilLwcCtrl.sendDataStream('Apex_Unit_Test','{}');

                // This method will fail the test as it should not be reached
                utl.Tst.assertExceptionHasBeenThrow();

            }catch(Exception e){
                auraException = e;
            }
        }
        Test.stopTest();

        // Assert exception message
        Assert.areEqual('Script-thrown exception', auraException.getMessage(), 'Unexpected Exception Message');
    }


    @IsTest
    static void testTestDataStream(){
        // Variable to hold the test Exceptions
        Exception auraException;

        // Run test
        Test.startTest();
        System.runAs(TST_USER){
            // Happy Path
            utl.Mck.setResponse(INGESTION_RESPONSE);
            DataCloudUtilLwcCtrl.testDataStream('Apex_Unit_Test','{}');

            // Forced error path
            try{
                // Force the exception
                utl.Tst.addForcedException('AURA_EXCEPTION');

                // Execute method
                DataCloudUtilLwcCtrl.testDataStream('Apex_Unit_Test','{}');

                // This method will fail the test as it should not be reached
                utl.Tst.assertExceptionHasBeenThrow();

            }catch(Exception e){
                auraException = e;
            }
        }
        Test.stopTest();

        // Assert exception message
        Assert.areEqual('Script-thrown exception', auraException.getMessage(), 'Unexpected Exception Message');
    }


    /** **************************************************************************************************** **
     **                                     GENERATE YAML AURA METHODS                                       **
     ** **************************************************************************************************** **/
    @IsTest
    static void testGetSObjectOptions(){
        // Variable to hold the test Exceptions
        Exception auraException;

        // Run test
        Test.startTest();
        System.runAs(TST_USER){
            // Happy Path
            DataCloudUtilLwcCtrl.getSObjectOptions(true);

            // Forced error path
            try{
                // Force the exception
                utl.Tst.addForcedException('AURA_EXCEPTION');

                // Execute method
                DataCloudUtilLwcCtrl.getSObjectOptions(true);

                // This method will fail the test as it should not be reached
                utl.Tst.assertExceptionHasBeenThrow();

            }catch(Exception e){
                auraException = e;
            }
        }
        Test.stopTest();

        // Assert exception message
        Assert.areEqual('Script-thrown exception', auraException.getMessage(), 'Unexpected Exception Message');
    }


    @IsTest
    static void testGetSObjectFieldInfo(){
        // Variable to hold the test Exceptions
        Exception auraException;

        // Run test
        Test.startTest();
        System.runAs(TST_USER){
            // Happy Path
            DataCloudUtilLwcCtrl.getSObjectFieldInfo('User');

            // Forced error path
            try{
                // Force the exception
                utl.Tst.addForcedException('AURA_EXCEPTION');

                // Execute method
                DataCloudUtilLwcCtrl.getSObjectFieldInfo('User');

                // This method will fail the test as it should not be reached
                utl.Tst.assertExceptionHasBeenThrow();

            }catch(Exception e){
                auraException = e;
            }
        }
        Test.stopTest();

        // Assert exception message
        Assert.areEqual('Script-thrown exception', auraException.getMessage(), 'Unexpected Exception Message');
    }


    /** **************************************************************************************************** **
     **                                   DATA CLOUD QUERY AURA METHODS                                      **
     ** **************************************************************************************************** **/
    @IsTest
    static void testGetDcQueryCsv(){
        // Variable to hold the test Exceptions
        Exception auraException;

        // Run test
        Test.startTest();
        System.runAs(TST_USER){
            // Happy Path
            utl.Mck.setResponse(DC_QUERY_RESPONSE);
            DataCloudUtilLwcCtrl.getDcQueryCsv('Apex_Unit_Test','SELECT 1');

            // Forced error path
            try{
                // Force the exception
                utl.Tst.addForcedException('AURA_EXCEPTION');

                // Execute method
                DataCloudUtilLwcCtrl.getDcQueryCsv('Apex_Unit_Test','SELECT 1');

                // This method will fail the test as it should not be reached
                utl.Tst.assertExceptionHasBeenThrow();

            }catch(Exception e){
                auraException = e;
            }
        }
        Test.stopTest();

        // Assert exception message
        Assert.areEqual('Script-thrown exception', auraException.getMessage(), 'Unexpected Exception Message');
    }


    @IsTest
    static void testGetDcQueryTable(){
       // Variable to hold the test Exceptions
       Exception auraException;

       // Run test
       Test.startTest();
       System.runAs(TST_USER){
           // Happy Path
            utl.Mck.setResponse(DC_QUERY_RESPONSE);
            DataCloudUtilLwcCtrl.getDcQueryTable('Apex_Unit_Test','SELECT 1');

            // Forced error path
            try{
                // Force the exception
                utl.Tst.addForcedException('AURA_EXCEPTION');

                // Execute method
                DataCloudUtilLwcCtrl.getDcQueryTable('Apex_Unit_Test','SELECT 1');

                // This method will fail the test as it should not be reached
                utl.Tst.assertExceptionHasBeenThrow();

            }catch(Exception e){
                auraException = e;
            }
        }
        Test.stopTest();

        // Assert exception message
        Assert.areEqual('Script-thrown exception', auraException.getMessage(), 'Unexpected Exception Message');
    }


    /** **************************************************************************************************** **
     **                                      SOQL QUERY AURA METHODS                                         **
     ** **************************************************************************************************** **/
    @IsTest
    static void testGetSoqlQueryCsv(){

        // Variable to hold the test Exceptions
        Exception auraException;

        // Run test
        Test.startTest();
        System.runAs(TST_USER){
            // Happy Path
            utl.Mck.setResponse(SOQL_RESPONSE);
            DataCloudUtilLwcCtrl.getSoqlQueryCsv('Apex_Unit_Test','SELECT Id FROM User', false);

            // Forced error path
            try{
                // Force the exception
                utl.Tst.addForcedException('AURA_EXCEPTION');

                // Execute method
                DataCloudUtilLwcCtrl.getSoqlQueryCsv('Apex_Unit_Test','SELECT Id FROM User', false);

                // This method will fail the test as it should not be reached
                utl.Tst.assertExceptionHasBeenThrow();

            }catch(Exception e){
                auraException = e;
            }
        }
        Test.stopTest();

        // Assert exception message
        Assert.areEqual('Script-thrown exception', auraException.getMessage(), 'Unexpected Exception Message');
    }


    @IsTest
    static void testGetSoqlQueryTable(){

        // Variable to hold the test Exceptions
        Exception auraException;

        // Run test
        Test.startTest();
        System.runAs(TST_USER){
            // Happy Path
            utl.Mck.setResponse(SOQL_RESPONSE);
            DataCloudUtilLwcCtrl.getSoqlQueryTable('Apex_Unit_Test','SELECT Id FROM User', false);

            // Forced error path
            try{
                // Force the exception
                utl.Tst.addForcedException('AURA_EXCEPTION');

                // Execute method
                DataCloudUtilLwcCtrl.getSoqlQueryTable('Apex_Unit_Test','SELECT Id FROM User', false);

                // This method will fail the test as it should not be reached
                utl.Tst.assertExceptionHasBeenThrow();

            }catch(Exception e){
                auraException = e;
            }
        }
        Test.stopTest();

        // Assert exception message
        Assert.areEqual('Script-thrown exception', auraException.getMessage(), 'Unexpected Exception Message');
    }


    @IsTest
    static void testGenerateQueryFromMapping(){

        // Variable to hold the test Exceptions
        Exception auraException;

        // Run test
        Test.startTest();
        System.runAs(TST_USER){
            // Happy Path
            DataCloudUtilLwcCtrl.generateQueryFromMapping('Apex_Unit_Test');

            // Forced error path
            try{
                // Force the exception
                utl.Tst.addForcedException('AURA_EXCEPTION');

                // Execute method
                DataCloudUtilLwcCtrl.generateQueryFromMapping('Apex_Unit_Test');

                // This method will fail the test as it should not be reached
                utl.Tst.assertExceptionHasBeenThrow();

            }catch(Exception e){
                auraException = e;
            }
        }
        Test.stopTest();

        // Assert exception message
        Assert.areEqual('Script-thrown exception', auraException.getMessage(), 'Unexpected Exception Message');

    }
}