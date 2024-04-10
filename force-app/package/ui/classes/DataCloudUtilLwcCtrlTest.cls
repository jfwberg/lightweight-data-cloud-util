/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           August 2023
 * @copyright      (c) 2023 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Test Class for the Data Cloud LWC Controller Methods
 */
@IsTest
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts, PMD.CyclomaticComplexity, PMD.ApexDoc')
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
    private static final String SOQL_RESPONSE           = '{"totalSize":1,"done":true,"records":[{"attributes":{"type":"User","url":"/services/data/v53.0/sobjects/User/005Q1000000RJtBIAW"},"Id":"005Q1000000RJtBIAW","CreatedDate" : "2024-03-11T13:40:23.000+0000","Extra" : "Becomes Textfield"}]}';
    private static final String DC_QUERY_RESPONSE       = '{ "data": [ [ "0_1", "0_2" ], [ "1_1", "1_2" ] ], "startTime": "2021-10-06T13:36:30.33265Z", "endTime": "2021-10-06T13:36:32.81927Z", "rowCount": 2, "queryId": "20211006_133630_00059_9adm3", "nextBatchId": "09151b49-54ed-4948-8139-1f4c7c3a9581", "done": false, "metadata": { "Field_00__c": { "type": "VARCHAR", "placeInOrder": 0, "typeCode": 12 }, "Field_01__c": { "type": "TIMESTAMP WITH TIME ZONE", "placeInOrder": 1, "typeCode": 12 } } }';
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
            DataCloudUtilLwcCtrl.getMtdConfigOptions('Apex_Unit_Test');

            // Forced error path
            try{
                // Force the exception
                utl.Tst.addForcedException('AURA_EXCEPTION');

                // Execute method
                DataCloudUtilLwcCtrl.getMtdConfigOptions('Apex_Unit_Test');

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
            DataCloudUtilLwcCtrl.newJob('Apex_Unit_Test','delete');

            // Forced error path
            try{
                // Force the exception
                utl.Tst.addForcedException('AURA_EXCEPTION');

                // Execute method
                DataCloudUtilLwcCtrl.newJob('Apex_Unit_Test','upsert');

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


    @IsTest
    static void testAddCsvFromFile(){
        // Variable to hold the test Exceptions
        Exception auraException;

        // Run test
        Test.startTest();
        System.runAs(TST_USER){
            // Happy Path
            utl.Mck.addResponse('ADD_CSV_TO_BULK_JOB', 202, INGESTION_RESPONSE);

            // Create a test document
            ContentVersion cv = new ContentVersion(
                    Title          = 'data',
                    PathOnClient   = 'data.csv',
                    VersionData    = Blob.valueOf('data'),
                    IsMajorVersion = true
            );
            insert cv;

            // Get the document Id
            String contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id]?.ContentDocumentId;
            
            // Execute happy path
            DataCloudUtilLwcCtrl.addCsvFromFile('Apex_Unit_Test','4d5a4477-e27f-4bc1-a219-31e79407eade', ContentDocumentId,  cv.Id);

            // Forced error path
            try{
                // Force the exception
                utl.Tst.addForcedException('AURA_EXCEPTION');

                // Execute method
                DataCloudUtilLwcCtrl.addCsvFromFile('Apex_Unit_Test','4d5a4477-e27f-4bc1-a219-31e79407eade', ContentDocumentId,  cv.Id);

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
    static void testDeleteDocument(){
        // Variable to hold the test Exceptions
        Exception auraException;

        // Run test
        Test.startTest();
        System.runAs(TST_USER){
            
            // Create a test document
            ContentVersion cv = new ContentVersion(
                    Title          = 'data',
                    PathOnClient   = 'data.csv',
                    VersionData    = Blob.valueOf('data'),
                    IsMajorVersion = true
            );
            insert cv;

            // Get the document Id
            String contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id]?.ContentDocumentId;
            
            // Execute happy path
            DataCloudUtilLwcCtrl.deleteDocument(ContentDocumentId);

            // Forced error path
            try{
                // Force the exception
                utl.Tst.addForcedException('AURA_EXCEPTION');

                // Execute method
                DataCloudUtilLwcCtrl.deleteDocument(ContentDocumentId);

                // This method will fail the test as it should not be reached
                utl.Tst.assertExceptionHasBeenThrow();

            }catch(Exception e){
                auraException = e;
            }
        }
        Test.stopTest();

        // Test happy path
        Assert.areEqual(0, [SELECT COUNT() FROM ContentVersion], 'Expected document to have been deleted');

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
        Exception auraException2;

        // Run test
        Test.startTest();
        System.runAs(TST_USER){
            // Happy Path
            DataCloudUtilLwcCtrl.getSObjectFieldInfo('User');

            // Forced error path
            try{
                // Execute method
                DataCloudUtilLwcCtrl.getSObjectFieldInfo('Invalid');

                // This method will fail the test as it should not be reached
                utl.Tst.assertExceptionHasBeenThrow();
            }catch(Exception e){
                auraException2 = e;
            }

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
            DataCloudUtilLwcCtrl.getDcQueryCsv('Apex_Unit_Test','SELECT 1','v1');

            // Forced error path
            try{
                // Force the exception
                utl.Tst.addForcedException('AURA_EXCEPTION');

                // Execute method
                DataCloudUtilLwcCtrl.getDcQueryCsv('Apex_Unit_Test','SELECT 1', 'v2');

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
    static void testGetDcQueryRaw(){
        // Variable to hold the test Exceptions
        Exception auraException;

        // Run test
        Test.startTest();
        System.runAs(TST_USER){
            // Happy Path
            utl.Mck.setResponse(DC_QUERY_RESPONSE);
            DataCloudUtilLwcCtrl.getDcQueryRaw('Apex_Unit_Test','SELECT 1','v1');

            // Forced error path
            try{
                // Force the exception
                utl.Tst.addForcedException('AURA_EXCEPTION');

                // Execute method
                DataCloudUtilLwcCtrl.getDcQueryRaw('Apex_Unit_Test','SELECT 1', 'v2');

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
            DataCloudUtilLwcCtrl.getDcQueryTable('Apex_Unit_Test','SELECT 1','v1');
            DataCloudUtilLwcCtrl.getDcQueryTable('Apex_Unit_Test','SELECT 1','v2');

            // Forced error path
            try{
                // Force the exception
                utl.Tst.addForcedException('AURA_EXCEPTION');

                // Execute method
                DataCloudUtilLwcCtrl.getDcQueryTable('Apex_Unit_Test','SELECT 1', 'v2');

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
    static void testGetQueryPlaceholder(){
        // Variable to hold the test Exceptions
        Exception auraException;
        
        // The query that is generated
        String query;
        String query2;
        String query3;

       // Run test
       Test.startTest();
       System.runAs(TST_USER){
            
            // Generate the query
            query  = DataCloudUtilLwcCtrl.getQueryPlaceholder('Apex_Unit_Test', 'all');
            query2 = DataCloudUtilLwcCtrl.getQueryPlaceholder('Apex_Unit_Test', 'pk');
            query3 = DataCloudUtilLwcCtrl.getQueryPlaceholder('Apex_Unit_Test', 'pket');

            // Forced error path
            try{
                // Force the exception
                utl.Tst.addForcedException('AURA_EXCEPTION');

                // Execute method
                DataCloudUtilLwcCtrl.getQueryPlaceholder('Apex_Unit_Test','pk');

                // This method will fail the test as it should not be reached
                utl.Tst.assertExceptionHasBeenThrow();

            }catch(Exception e){
                auraException = e;
            }
        }
        Test.stopTest();

        // Assert the generated query
        Assert.areEqual('SELECT Target_Id__c, Target_Username__c FROM Data_Lake_Object__dll LIMIT 100', query, 'Unexpected Exception Message');

        // Assert exception message
        Assert.areEqual('Script-thrown exception', auraException.getMessage(), 'Unexpected Exception Message');
    }


    /** **************************************************************************************************** **
     **                                       DATA GRAPH AURA METHODS                                        **
     ** **************************************************************************************************** **/
    @IsTest
    static void testGetDcNamedCredentialOptions(){

        // Variable to hold the test Exceptions
        Exception auraException;

        // Run test
        Test.startTest();
        System.runAs(TST_USER){
            // Happy Path
            utl.Mck.setResponse(200, '{ "records": [ { "NamedCredential": { "MasterLabel": "LB1", "DeveloperName": "DN1" }, "ParameterValue": "https://DCO01.c360a.salesforce.com" }, { "NamedCredential": { "MasterLabel": "LB2", "DeveloperName": "DN2" }, "ParameterValue": "https://DCO02.c360a.salesforce.com" } ] }');
            DataCloudUtilLwcCtrl.getDcNamedCredentialOptions();

            // Forced error path
            try{
                // Force the exception
                utl.Tst.addForcedException('AURA_EXCEPTION');

                // Execute method
                DataCloudUtilLwcCtrl.getDcNamedCredentialOptions();

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
    static void testGetDataGraphOptions(){

        // Variable to hold the test Exceptions
        Exception auraException;

        // Run test
        Test.startTest();
        System.runAs(TST_USER){
            // Happy Path
            utl.Mck.setResponse('{"metadata" : [{},{}]}');
            DataCloudUtilLwcCtrl.getDataGraphOptions('NC01');

            // Forced error path
            try{
                // Force the exception
                utl.Tst.addForcedException('AURA_EXCEPTION');

                // Execute method
                DataCloudUtilLwcCtrl.getDataGraphOptions('NC01');

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
    static void testGetDataGraphDetails(){

        // Variable to hold the test Exceptions
        Exception auraException;

        // Run test
        Test.startTest();
        System.runAs(TST_USER){

            // Set the API Response
            utl.Mck.setResponse('{ "metadata": [ { "test": "test", "object": { "fields": [ { "developerName": "field", "keyCol": "true" } ], "relatedObjects": [ { "developerName": "relObj", "fields": [ { "developerName": "field", "keyCol": "true" } ] } ] } } ] }');
            DataCloudUtilLwcCtrl.getDataGraphDetails('NC01','DG01');

            // Forced error path
            try{
                // Force the exception
                utl.Tst.addForcedException('AURA_EXCEPTION');

                // Execute method
                DataCloudUtilLwcCtrl.getDataGraphDetails('NC01','DG01');

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
    static void testGetDataGraph(){

        // Variable to hold the test Exceptions
        Exception auraException;

        // Run test
        Test.startTest();
        System.runAs(TST_USER){

            // Set the API Response
            utl.Mck.setResponse('{"data":[{"json_blob__c":"{\\"ssot__Id__c\\":\\"0038d00000fkClnAAE\\",\\"KQ_Id__c\\":\\" \\",\\"ssot__LastName__c\\":\\"Cooke\\",\\"Individual_SM_1676899826474__dlm\\":[{\\"Id__c\\":\\"0038d00000fkClnAAE\\",\\"KQ_Id__c\\":\\" \\",\\"Segment_Id__c\\":\\"1sg8d000000CaXZ\\"}]}"}],"done":true}');
            DataCloudUtilLwcCtrl.getDataGraph('NC01','DG01','DG_RC_ID_01','jsonblob');
            DataCloudUtilLwcCtrl.getDataGraph('NC01','DG01','DG_RC_ID_01','raw');
            DataCloudUtilLwcCtrl.getDataGraph('NC01','DG01','DG_RC_ID_01','table');
            DataCloudUtilLwcCtrl.getDataGraph('NC01','DG01','DG_RC_ID_01','csv');
            DataCloudUtilLwcCtrl.getDataGraph('NC01','DG01','DG_RC_ID_01','keyvalue');

            // Forced error path
            try{
                // Execute method
                DataCloudUtilLwcCtrl.getDataGraph('NC01','DG01','DG_RC_ID_01','invalid');

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
    static void testGetSoqlQueryRaw(){

        // Variable to hold the test Exceptions
        Exception auraException;

        // Run test
        Test.startTest();
        System.runAs(TST_USER){
            // Happy Path
            utl.Mck.setResponse(SOQL_RESPONSE);
            DataCloudUtilLwcCtrl.getSoqlQueryRaw('Apex_Unit_Test','SELECT Id FROM User', false);

            // Forced error path
            try{
                // Force the exception
                utl.Tst.addForcedException('AURA_EXCEPTION');

                // Execute method
                DataCloudUtilLwcCtrl.getSoqlQueryRaw('Apex_Unit_Test','SELECT Id FROM User', false);

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
        Exception auraException2;

        // Run test
        Test.startTest();
        System.runAs(TST_USER){
            // Happy Path
            utl.Mck.setResponse(SOQL_RESPONSE);
            DataCloudUtilLwcCtrl.getSoqlQueryTable('Apex_Unit_Test','SELECT Id FROM User', false);

            // Forced error path
            try{
                // Execute method
                DataCloudUtilLwcCtrl.getSoqlQueryTable('Apex_Unit_Test','SELECT Id FROM Invalid', false);

                // This method will fail the test as it should not be reached
                utl.Tst.assertExceptionHasBeenThrow();

            }catch(Exception e){
                auraException2 = e;
            }

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


    @IsTest
    static void testExecuteSoqlQuery(){
        
        // Variable to hold the test Exceptions
        Exception auraException;

        Test.startTest();
        System.runAs(TST_USER){
            // Forced error path
            try{
                // Execute method
                DataCloudUtilLwcCtrl.executeSoqlQuery('',true);

                // This method will fail the test as it should not be reached
                utl.Tst.assertExceptionHasBeenThrow();

            }catch(Exception e){
                auraException = e;
            }
        }
        Test.stopTest();

        // Assert exception message
        Assert.areEqual('SOQL Query cannot be empty', auraException.getMessage(), 'Unexpected Exception Message');
    }


    @IsTest
    static void testGenerateSampleData(){
        Test.startTest();
        System.runAs(TST_USER){
            DataCloudUtilLwcCtrl.generateSampleData('numberField');
            DataCloudUtilLwcCtrl.generateSampleData('dateField');
            DataCloudUtilLwcCtrl.generateSampleData('dateTimeField');
            DataCloudUtilLwcCtrl.generateSampleData('uuidField');
            DataCloudUtilLwcCtrl.generateSampleData('urlField');
            DataCloudUtilLwcCtrl.generateSampleData('emailField');
            DataCloudUtilLwcCtrl.generateSampleData('phoneField');
            DataCloudUtilLwcCtrl.generateSampleData('booleanField');
            DataCloudUtilLwcCtrl.generateSampleData('percentField');
            DataCloudUtilLwcCtrl.generateSampleData('textField');
        }
        Test.stopTest();
    }
}