REM 01 - Update the executing user
sf org display user 

REM 02 - Update the force ignore file

REM 03 - Deploy the custom implementation files
sf project deploy start --source-dir force-app/connection

REM 04 - Assign the permission set
sf org assign permset --name "DC_ORG_01"

REM 05 - Connect the external credential in setup
REM 06 - Run test Apex