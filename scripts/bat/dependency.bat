REM Target ORG
SET targetOrg=[TARGET_ORG]
SET targetUser=[TARGET_USER]

REM Managed package - Lightweight - Apex Unit Test Util v2@2.3.0-1
call sf package install --package 04tP30000007oePIAQ --target-org %targetOrg% --wait 30

REM Managed package - Lightweight - REST Util@0.10.0-1
call sf package install --package 04tP30000007sN3IAI --target-org %targetOrg% --wait 30

REM Managed package - Lightweight - JSON Util@0.4.0-1
call sf package install --package 04tP30000008cL3IAI --target-org %targetOrg% --wait 30

REM Managed package - Lightweight - Data Cloud Util v2@0.1.0-1
call sf package install --package 04tP3000000AIoTIAW --target-org %targetOrg% --wait 30

REM Managed package - Lightweight - Data Cloud Auth Provider@0.3.0-1
call sf package install --package 04tP30000007slFIAQ --target-org %targetOrg% --wait 30

REM Managed package - Lightweight - Auth Provider Util v2@0.6.0-1
call sf package install --package 04tP30000007t1NIAQ --target-org %targetOrg% --wait 30

REM Assign permission sets
call sf org assign permset --name "Lightweight_Apex_Unit_Test_Util_v2"   --target-org %targetOrg% --on-behalf-of %targetUser%
call sf org assign permset --name "Lightweight_REST_Util"                --target-org %targetOrg% --on-behalf-of %targetUser%
call sf org assign permset --name "Lightweight_JSON_Util"                --target-org %targetOrg% --on-behalf-of %targetUser%
call sf org assign permset --name "Lightweight_Data_Cloud_Util"          --target-org %targetOrg% --on-behalf-of %targetUser%
call sf org assign permset --name "Lightweight_Data_Cloud_Util_UI"       --target-org %targetOrg% --on-behalf-of %targetUser%
call sf org assign permset --name "Lightweight_Data_Cloud_Auth_Provider" --target-org %targetOrg% --on-behalf-of %targetUser%
call sf org assign permset --name "Lightweight_Auth_Provider_Util_Admin" --target-org %targetOrg% --on-behalf-of %targetUser%

REM Deploy the test connection (for security reasons not in the GIT Repo)
sf project deploy start --source-dir ../force-app/connection --target-org %targetOrg%

REM Assign the permission set for the connection
sf org assign permset --name "UKTA_DC_ORG" --target-org %targetOrg% --on-behalf-of %targetUser%

REM Deploy the sample data
sf project deploy start --source-dir "../force-app/demo/package/custommetadata" --target-org %targetOrg%