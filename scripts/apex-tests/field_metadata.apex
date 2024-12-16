


// Cast the response as an object so we can get both the data and metadata
Map<String,Object> response = (Map<String,Object>) JSON.deserializeUntyped(
    Dc.executeQuery(
        'TDX_DC_ORG', 
        'SELECT DateField__c, EmailField__c, TextField__c, BooleanField__c, UrlField__c, Name__c, PercentField__c, Id__c, PhoneField__c, UUID__c, CreatedDate__c, DateTimeField__c, NumberField__c FROM Smart_Bill_02_Smart_Bill_3FCF6D01__dll LIMIT 10'
    )
    .getResponse()
    .getBody()
);


System.debug(JSON.serializePretty(
    Dc.getFieldMetadata(utl.Jsn.getObjectMap('metadata', response), false)
));

/*
[ {
  "typeCode" : 3,
  "type" : "DECIMAL",
  "placeInOrder" : 12,
  "name" : "NumberField__c"
}, {
  "typeCode" : 12,
  "type" : "VARCHAR",
  "placeInOrder" : 5,
  "name" : "Name__c"
}, {
  "typeCode" : 12,
  "type" : "VARCHAR",
  "placeInOrder" : 4,
  "name" : "UrlField__c"
}, {
  "typeCode" : 12,
  "type" : "VARCHAR",
  "placeInOrder" : 9,
  "name" : "UUID__c"
}, {
  "typeCode" : 3,
  "type" : "DECIMAL",
  "placeInOrder" : 6,
  "name" : "PercentField__c"
}, {
  "typeCode" : 91,
  "type" : "DATE",
  "placeInOrder" : 0,
  "name" : "DateField__c"
}, {
  "typeCode" : 2014,
  "type" : "TIMESTAMP WITH TIME ZONE",
  "placeInOrder" : 11,
  "name" : "DateTimeField__c"
}, {
  "typeCode" : 12,
  "type" : "VARCHAR",
  "placeInOrder" : 1,
  "name" : "EmailField__c"
}, {
  "typeCode" : 2014,
  "type" : "TIMESTAMP WITH TIME ZONE",
  "placeInOrder" : 10,
  "name" : "CreatedDate__c"
}, {
  "typeCode" : 12,
  "type" : "VARCHAR",
  "placeInOrder" : 2,
  "name" : "TextField__c"
}, {
  "typeCode" : 12,
  "type" : "VARCHAR",
  "placeInOrder" : 8,
  "name" : "PhoneField__c"
}, {
  "typeCode" : 12,
  "type" : "VARCHAR",
  "placeInOrder" : 7,
  "name" : "Id__c"
}, {
  "typeCode" : 12,
  "type" : "VARCHAR",
  "placeInOrder" : 3,
  "name" : "BooleanField__c"
} ]
*/