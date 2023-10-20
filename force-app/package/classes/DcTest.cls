/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           August 2023
 * @copyright      (c) 2023 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Test class for the "Dc" Apex Class
 */
@IsTest
private with sharing class DcTest {
    
    @IsTest
    static void getMetadataRecord(){
        
        // Variable to hold the test Exception
        Exception testException;

        Test.startTest();
        
        // Query the record
        Data_Cloud_Ingestion_API_Configuration__mdt mdtRecord = Dc.getMetadataRecord('Apex_Unit_Test');

        // Test exception
        try{
            // Invalid id
            Dc.getMetadataRecord('utl__Invalid');

            // This method will fail the test as it should not be reached
            utl.Tst.assertExceptionHasBeenThrow();

        }catch(Exception e){
            testException  =e; 
        }

        Test.stopTest();

        // Check there are 2 mapping fields
        Assert.areEqual(2, mdtRecord.Data_Cloud_Ingestion_API_Field_Mappings__r.size(), 'Unexpected number of field mappings');

        // Validate the exception message
        utl.Tst.assertExceptionMessage(Dc.NO_MDT_RECORD_FOUND_MSG, 'utl__Invalid', testException);
    }


    @IsTest
    static void testStreamRecordsToDataCloudAsync(){
        
        // Setup the callout response
        utl.Mck.setResponse(202, '{"accepted" : true}');
        
        Test.startTest();

        // No exception should have been thrown
        Dc.streamRecordsToDataCloudAsync(
            JSON.serialize([SELECT Id, Username From User WHERE Id=:UserInfo.getUserId()]),
            'Apex_Unit_Test'
        );

        Test.stopTest();

        // Handle asserts
        assertSuccessfullCallout();
    }


    @IsTest
    static void testStreamRecordsToDataCloud(){
        
        // Setup the callout response
        utl.Mck.setResponse(202, '{"accepted" : true}');
        
        Test.startTest();
        
        // No exception should have been thrown
        Dc.streamRecordsToDataCloud(
            [SELECT Id, Username From User WHERE Id=:UserInfo.getUserId()],
            'Apex_Unit_Test'
        );

        Test.stopTest();
        
        // Handle asserts
        assertSuccessfullCallout();
    }


    @IsTest
    static void testStreamRecordsToDataCloudErrorResponse(){
        
        // Variable to hold the test Exception
        Exception testException;

        // Setup the callout response
        utl.Mck.setResponse(429, '{ "timestamp": "2021-08-20T16:34:26.047666Z", "error": "Bad Request", "message": "Bad Request: JSON is properly formatted but has a mismatch with Schema.", "path": "uri=/api/v1/ingest/sources/ecomm/Orders/actions/test", "tenantId": "{tenantId}", "internalErrorCode": "COMMON_ERROR_GENERIC", "details": { "validationReport": [ { "record": { "contact_name": "Joe Smith", "total": 77506, "tax_exempt": false, "id": "f19cae7e-5cdb-41ce-92ba-539afea04f9d", "created_date": "2021-07-22T08:57:08.118Z", "ship_address": "9818 Main", "modified_date": "2021-07-05T09:31:44.457Z", "tax_rate": 84 }, "causingExceptions": [ "#/id: expected type: Number, found: String" ] }, { "record": { "contact_name": "Tina Smith", "total": 16986, "tax_exempt": false, "id": "48c8b6a6-8179-4a15-ba19-ec5c8206ce28", "created_date": "2021-07-08T22:57:02.008Z", "ship_address": "245 Main", "modified_date": "2021-07-03T06:20:52.886Z", "tax_rate": 61 }, "causingExceptions": [ "#/id: expected type: Number, found: String" ] } ] } }');
        
        Test.startTest();
        
        try{
            // No exception should have been thrown
            Dc.streamRecordsToDataCloud(
                [SELECT Id, Username From User WHERE Id=:UserInfo.getUserId()],
                'Apex_Unit_Test'
            );
            // This method will fail the test as it should not be reached
            utl.Tst.assertExceptionHasBeenThrow();
        }catch(Exception e){
            testException = e;
            
        }
        Test.stopTest();

        // Check the error message is present
        Assert.areEqual(true, testException.getMessage().contains('Bad Request: JSON is properly formatted but has a mismatch with Schema.'));
    }


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
            '{"data":[{"Target_Username":"'+UserInfo.getUserName()+'","Target_Id":"'+UserInfo.getUserId()+'"}]}'
        );
    }
    
}