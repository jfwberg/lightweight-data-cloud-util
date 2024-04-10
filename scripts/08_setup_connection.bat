REM 01 - Update the executing user
sf org display user 

REM 02 - Update the executing user in the auth provider

REM 03 - Update the force ignore file (Comment the connection section)

REM 04 - Potentially remove or add the utl__ namespace in the permission set

REM 05 - Deploy the custom implementation files
sf project deploy start --source-dir force-app/connection/ukta_dc_org
sf project deploy start --source-dir force-app/connection/tdx_dc_org


REM 06 - Assign the permission set
sf org assign permset --name "UKTA_DC_ORG"
sf org assign permset --name "UKTA_SF_ORG"
sf org assign permset --name "TDX_DC_ORG"
sf org assign permset --name "TDX_SF_ORG"

REM 07 - Fix the force ignore again

REM 06 - Connect the external credential in setup
REM 07 - Run test Apex


test-rv2oqqw3hoir@example.com