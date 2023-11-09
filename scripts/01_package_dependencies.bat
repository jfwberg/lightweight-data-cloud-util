REM --------------------------------------------------------
REM MANGED DEPENDENCIES (PICK EITHER MANAGED OR UNLOCKED)  -
REM --------------------------------------------------------
REM Managed package - Lightweight - Apex Unit Test Util v2@2.3.0-1
call sf package install --package 04tP30000007oePIAQ -w 30

REM Managed package - Lightweight - REST Util@0.10.0-1
call sf package install --package 04tP30000007sN3IAI -w 30

REM Managed package - Lightweight - JSON Util@0.4.0-1
call sf package install --package 04tP30000008cL3IAI -w 30

REM ----------------- OPTIONAL BUT ADVICED -----------------
REM Managed package - Lightweight - Data Cloud Auth Provider@0.3.0-1
call sf package install --package 04tP30000007slFIAQ -w 30

REM Managed package - Lightweight - Auth Provider Util v2@0.6.0-1
call sf package install --package 04tP30000007t1NIAQ -w 30


REM --------------------------------------------------------
REM UNLOCKED DEPENDENCIES (PICK EITHER MANAGED OR UNLOCKED)-
REM --------------------------------------------------------
REM Unlocked package - Lightweight - Apex Unit Test Util v2 (Unlocked)@2.3.0-1
sf package install --package 04tP30000007og1IAA -w 30

REM Unlocked package - Lightweight - REST Util (Unlocked)0.10.0-1
sf package install --package 04tP30000007sQHIAY -w 30

REM Managed package - Lightweight - JSON Util (Unlocked)@0.4.0-1
sf package install --package 04tP30000008cMfIAI -w 30

REM ----------------- OPTIONAL BUT ADVICED -----------------
REM Unlocked package - Lightweight - Data Cloud Auth Provider (Unlocked)@0.3.0-1
sf package install --package 04tP30000007stJIAQ -w 30

REM Managed package - Lightweight - Auth Provider Util v2 (Unlocked)@0.6.0-1
sf package install --package 04tP30000007tB3IAI -w 30


REM --------------------------------------------------------
REM                  ASSIGN PERMISSION SETS                -
REM --------------------------------------------------------
call sf org assign permset --name "Lightweight_Apex_Unit_Test_Util_v2"
call sf org assign permset --name "Lightweight_REST_Util"
call sf org assign permset --name "Lightweight_JSON_Util"

call sf org assign permset --name "Lightweight_Data_Cloud_Auth_Provider"
call sf org assign permset --name "Lightweight_Auth_Provider_Util_Admin"

call sf org assign permset --name "Lightweight_Data_Cloud_Util"
call sf org assign permset --name "Lightweight_Data_Cloud_Util_UI"


