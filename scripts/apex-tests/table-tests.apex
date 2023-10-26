
//String query = 'SELECT utl__Action__c, utl__Device_Type__c, utl__Status_Code__c, utl__Status_Reason__c, utl__Timestamp__c FROM utl__Smart_Device_Event_History__c  LIMIT 100';
String query = 'SELECT NamedCredential.DeveloperName, NamedCredential.MasterLabel FROM NamedCredentialParameter WHERE ParameterName = \'Url\' ORDER BY ExternalCredential.MasterLabel';
	
	
String jsonString = new utl.Rst(true)
    .setEndpoint('/tooling/query?q=' + EncodingUtil.urlEncode(query, 'UTF-8'))
    .call()
	.getResponse()
	.getBody();


System.debug(
		new utl.JsnTbl()
		.setAttributeFilter(new Set<String>{'totalSize','done','attributes','size','queryLocator', 'entityTypeName'})
		.setListNameFilter(new Set<String>{'records'})
		.create(JSON.deserializeUntyped(jsonString))
		.getConsoleString()
);