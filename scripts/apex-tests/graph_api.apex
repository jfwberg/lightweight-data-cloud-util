/*
System.debug(
    JSON.serializePretty(
        Dc.getAllDataGraphMetadata('UKTA_DC_ORG')
    )
);
*/


System.debug(
    JSON.serializePretty(
        Dc.getDetailedDataGraphMetadata('UKTA_DC_ORG', 'DG2')
    )
);


/*
System.debug(
    JSON.serializePretty(
        JSON.deserializeUntyped(
            Dc.getDataGraphJsonBlob('UKTA_DC_ORG', 'DG2', '0038d00000fkCwkAAE')
        )
    )
);
*/

System.debug(Dc.getDataCloudNamedCredentialPicklistOptions());








