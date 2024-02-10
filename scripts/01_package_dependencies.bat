REM --------------------------------------------------------
REM MANGED DEPENDENCIES (PICK EITHER MANAGED OR UNLOCKED)  -
REM --------------------------------------------------------
rem Lightweight - Apex Unit Test Util v2@2.4.0-2
call sf package install -p "04tP3000000M6OXIA0" -w 30

rem Lightweight - REST Util@0.11.0-1
call sf package install -p "04tP3000000M6gHIAS" -w 30

REM Lightweight - JSON Util@0.5.0-1
call sf package install --package "04tP3000000M6mjIAC" -w 30

REM ----------------- OPTIONAL BUT ADVICED -----------------
REM Managed package - Lightweight - Auth Provider Util v2@0.11.0-1
call sf package install --package "04tP3000000M7FlIAK" -w 30

REM Managed package - Lightweight - Data Cloud Auth Provider@0.5.0-1
call sf package install --package "04tP3000000M6y1IAC" -w 30

REM Unlocked package - Lightweight - Salesforce Auth Provider@0.2.0-1
call sf package install --package "" -w 30






REM --------------------------------------------------------
REM UNLOCKED DEPENDENCIES (PICK EITHER MANAGED OR UNLOCKED)-
REM --------------------------------------------------------
rem Lightweight - Apex Unit Test Util v2 (Unlocked)@2.4.0-2
sf package install -p "04tP3000000M6Q9IAK" -w 30

rem Lightweight - REST Util (Unlocked)@0.11.0-1
sf package install -p "04tP3000000M6htIAC" -w 30

rem Lightweight - JSON Util (Unlocked)@0.5.0-1
sf package install --package "04tP3000000M6pxIAC" -w 30

REM ----------------- OPTIONAL BUT ADVICED -----------------
REM Managed package - Lightweight - Auth Provider Util v2 (Unlocked)@0.11.0-1
sf package install --package "04tP3000000M7HNIA0" -w 30

REM Unlocked package - Lightweight - Data Cloud Auth Provider (Unlocked)@0.5.0-1
sf package install --package "04tP3000000M6zdIAC" -w 30

REM Unlocked package - Lightweight - Salesforce Auth Provider (Unlocked)@0.2.0-1
sf package install --package "" -w 30




REM --------------------------------------------------------
REM                  ASSIGN PERMISSION SETS                -
REM --------------------------------------------------------
call sf org assign permset --name "Lightweight_Apex_Unit_Test_Util_v2"
call sf org assign permset --name "Lightweight_REST_Util"
call sf org assign permset --name "Lightweight_JSON_Util"

call sf org assign permset --name "Lightweight_Data_Cloud_Auth_Provider"
call sf org assign permset --name "Lightweight_Auth_Provider_Util"

call sf org assign permset --name "Lightweight_Data_Cloud_Util"
call sf org assign permset --name "Lightweight_Data_Cloud_Util_UI"
call sf org assign permset --name "Smart_Device_Event_Demo"



