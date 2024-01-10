utl.Soap lsAction = new utl.MdtWsdl('listMetadata')
    .addListMetadata('DataStreamTemplate')
    .call()
;

utl.MdtRes.Ls lsResult = utl.MdtRes.handleLs(lsAction);

String[] ingestionApiNames = new String[]{};


for(utl.MdtRes.FileProperty fp : lsResult.fileProperties){
	ingestionApiNames.add(fp.fullName);
}

ingestionApiNames.sort();

for(String s : ingestionApiNames){
	System.debug(s);		
}


Data_Connector_Ingest_Api_02_Ex_681BDA0C__dll
Data_Connector_Ingest_Api_02_Ex_new__dll
JTest__dll
Test_Connector_01_Test_Object_01__dll




utl.Soap dlAction = new utl.MdtWsdl('deleteMetadata')
    .setItemMetadataType('DataStreamDefinition')
    .addItemMetadataFullName('Data_Connector_Ingest_Api_02_External_Data_Tran_Object_02_681BDA0C')
    //.setItemMetadataType('CustomObject')
    //.addItemMetadataFullName('Data_Connector_Ingest_Api_02_Ex_681BDA0C__dll')
    .call() 
;

utl.MdtRes.Dl dlResult = utl.MdtRes.handleDl(dlAction);


System.debug(dlAction.getResponse().getBody());






utl.Soap rdAction = new utl.MdtWsdl('readMetadata')
    .setItemMetadataType('CustomObject')
    .addItemMetadataFullName('Test_Connector_01_Test_Object_01__dll')
    .call() 
;

utl.MdtRes.Rd rdResult = utl.MdtRes.handleRd(rdAction);


System.debug(rdAction.getResponse().getBody());


System.debug(utl.Xml.getElementList('dataSource.dataSource',rdResult.records[0])[0].text);
System.debug(utl.Xml.getElementList('dataSource.fullName',rdResult.records[0])[0].text);
System.debug(utl.Xml.getElementList('dataSource.externalRecordIdentifier',rdResult.records[0])[0].text);


// <?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><readMetadataResponse><result><records xsi:type="DataSourceObject"><fullName>Smart_Device_Event_Connector_Sm_53B73EA1_dll</fullName><dataSource>Smart_Device_Event_Connector_3f405a38_70e9_41fb_9d72_f1fb23dfb19f</dataSource><externalRecordIdentifier>Smart_Device_Event_Connector_Smart_Device_Event_53B73EA1</externalRecordIdentifier><masterLabel>Smart_Device_Event_Connector_Smart_Device_Event_53B73EA1</masterLabel></records></result></readMetadataResponse></soapenv:Body></soapenv:Envelope>


utl.Soap rdAction = new utl.MdtWsdl('readMetadata')
    .setItemMetadataType('CustomObject')
    .addItemMetadataFullName('Data_Connector_Ingest_Api_02_Ex_new__dll')
    .call() 
;

utl.MdtRes.Rd rdResult = utl.MdtRes.handleRd(rdAction);


System.debug(rdAction.getResponse().getBody());


System.debug('Data source name:         ' + utl.Xml.getElementList('dataSource.dataSource',rdResult.records[0])[0].text);
System.debug('Data source Object name:  ' + utl.Xml.getElementList('dataSource.fullName',rdResult.records[0])[0].text);
System.debug('Data source Object extId: ' + utl.Xml.getElementList('dataSource.externalRecordIdentifier',rdResult.records[0])[0].text);