// Does not send any data, but just tests the payload 
Boolean testPayloadFormat = false;

// Configuration
String namedCredentialName    = 'TDX_DC_ORG';
String ingestionApiName       = 'Smart_Bill';
String ingestionApiObjectName = 'Smart_Bill';

// Create a payload
String streamingIngestionPayload = JSON.serializePretty(new Map<String,List<Map<String,Object>>>{
    'data' => new List<Map<String,Object>>{
        new Map<String,Object>{
            'Amount'       => 'id',
            'Id'           => utl.Rst.Guid(),
            'UUID'         => utl.Rst.Guid(),
            'CreatedDate'  => String.valueOf(Datetime.now()),
            'Name'         => JSON.serialize([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()]),
            'Invoice_Date' => String.valueOf(Date.today())
        }
    }
});
 
// Create the request endpoint based on the NC and Named Credential details
HttpRequest request = new HttpRequest();
request.setEndPoint(String.format(
    'callout:{0}/api/v1/ingest/sources/{1}/{2}{3}',
    new String[]{
        namedCredentialName,
        ingestionApiName,
        ingestionApiObjectName,
        (testPayloadFormat) ? '/actions/test' : ''
    }
));
request.setHeader('Content-Type','application/json');
request.setMethod('POST');
request.setBody(streamingIngestionPayload);
 
// Execute
HttpResponse res = new HTTP().send(request);
System.debug(res.getStatusCode());
System.debug(res.getBody());