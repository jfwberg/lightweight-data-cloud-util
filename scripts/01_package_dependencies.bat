REM --------------------------------------------------------
REM MANGED DEPENDENCIES (PICK EITHER MANAGED OR UNLOCKED)  -
REM --------------------------------------------------------
rem Lightweight - Apex Unit Test Util v2@2.5.0-2
sf package install -p "04tP3000000rUmLIAU" -w 30

REM Lightweight - Apex LWC Util@0.7.0-2
sf package install --package "04tP3000000t8rNIAQ" -w 30

rem Lightweight - REST Util@0.12.0-1
sf package install -p "04tP3000000tD33IAE" -w 30

rem Lightweight - JSON Util@0.8.0-1
sf package install -p "04tP3000000tDMPIA2" -w 30

REM ----------------- OPTIONAL BUT ADVICED -----------------
rem Lightweight - Auth Provider Util v2@0.12.0-1
sf package install -p "04tP3000000MVUzIAO" -w 30

REM Lightweight - Data Cloud Auth Provider@0.5.0-1
sf package install --package "04tP3000000M6y1IAC" -w 30

REM Lightweight - Salesforce Auth Provider@0.3.0-1
sf package install --package "04tP3000000MCLtIAO" -w 30

REM Lightweight - Data Cloud Util@0.8.0-1
rem sf package install --package "04tP3000000TKD3IAO" -w 30




REM -------------------------------------------------------------------------------------------
REM                   UNLOCKED DEPENDENCIES (PICK EITHER MANAGED OR UNLOCKED)                 -
REM -------------------------------------------------------------------------------------------
rem Lightweight - Apex Unit Test Util v2 (Unlocked)@2.5.0-2
sf package install -p "04tP3000000rUpZIAU" -w 30

REM Lightweight - Apex LWC Util@0.7.0-1 (Unlocked)
sf package install --package "04tP3000000t94HIAQ" -w 30

rem Lightweight - REST Util (Unlocked)@0.12.0-1
sf package install -p "04tP3000000tD6HIAU" -w 30

rem Lightweight - JSON Util (Unlocked)@0.8.0-1
sf package install -p "04tP3000000tDRFIA2" -w 30

REM ----------------- OPTIONAL BUT ADVICED -----------------
rem Lightweight - Auth Provider Util v2 (Unlocked)@0.12.0-1
sf package install -p "04tP3000000MW1FIAW" -w 30

REM Lightweight - Data Cloud Auth Provider (Unlocked)@0.5.0-1
sf package install --package "04tP3000000M6zdIAC" -w 30

REM Lightweight - Salesforce Auth Provider (Unlocked)@0.3.0-1
sf package install --package "04tP3000000MCNVIA4" -w 30

REM Lightweight - Data Cloud Util (Unlocked)@0.8.0-1
rem sf package install --package "04tP3000000TK9pIAG" -w 30





REM --------------------------------------------------------
REM                  ASSIGN PERMISSION SETS                -
REM --------------------------------------------------------
REM DEPENDENCIES
sf org assign permset --name "Lightweight_Apex_Unit_Test_Util_v2"
sf org assign permset --name "Lightweight_LWC_Util"
sf org assign permset --name "Lightweight_JSON_Util"
sf org assign permset --name "Lightweight_REST_Util"
sf org assign permset --name "Lightweight_XML_Util"
sf org assign permset --name "Lightweight_SOAP_Util"

REM OPTIONAL PACKAGES
sf org assign permset --name "Lightweight_Auth_Provider_Util"
sf org assign permset --name "Lightweight_Data_Cloud_Auth_Provider"
sf org assign permset --name "Lightweight_Salesforce_Auth_Provider"

REM POST CODE DEPLOYMENT
sf org assign permset --name "Lightweight_Data_Cloud_Util"
sf org assign permset --name "Lightweight_Data_Cloud_Util_UI"
