// Configuration
String namedCredentialName    = 'TDX_DC_ORG';
String ingestionApiName       = 'Smart_Bill';
String ingestionApiObjectName = 'Smart_Bill'

// Does not send any data, but just tests the payload 
Boolean testPayloadFormat     = true;

// Update the body JSON according to your ingestion API objects
// This is the streaming API payload (terrible way of doing it, but you can fix that)
String body = '';
body += '{';
body += '   "data" :[ {';
body += '       "Amount"      : 12345,';
body += '       "Id"          : "82aec0cc922017d",';
body += '       "UUID"        : "8bb7cabc-1111-2222-a86a-b701fa2d881b",';
body += '       "CreatedDate" : "2024-07-06T03:09:27.017Z",';
body += '       "CreatedDate" : "2024-07-06T03:09:27.017Z",';
body += '       "Name"        : "1dc682a4d2d82f2",';
body += '       "Invoice_Date": "2024-04-11"';
body += '   }]';
body += '}';

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
request.setBody(body);

// Execute
HttpResponse res = new HTTP().send(request);
System.debug(res.getStatusCode());
System.debug(res.getBody());