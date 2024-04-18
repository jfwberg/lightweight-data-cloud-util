REM --------------------------------------------------------
REM MANGED DEPENDENCIES (PICK EITHER MANAGED OR UNLOCKED)  -
REM --------------------------------------------------------
rem Lightweight - Apex Unit Test Util v2@2.4.0-2
sf package install -p "04tP3000000M6OXIA0" -w 30

REM Lightweight - Apex LWC Util@0.6.0-2
sf package install --package "04tP3000000T7ZBIA0" -w 30

rem Lightweight - JSON Util@0.7.0-1
sf package install -p "04tP3000000T7m5IAC" -w 30

rem Lightweight - REST Util@0.11.0-1
sf package install -p "04tP3000000M6gHIAS" -w 30

rem Lightweight - XML Util@0.3.0-1
rem sf package install -p "04tP3000000MlUvIAK" -w 30

rem Lightweight - SOAP Util@0.2.0-1
rem sf package install -p "04tP3000000MlebIAC" -w 30

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
rem Lightweight - Apex Unit Test Util v2 (Unlocked)@2.4.0-2
sf package install -p "04tP3000000M6Q9IAK" -w 30

REM Lightweight - Apex LWC Util@0.6.0-1 (Unlocked)
sf package install --package "04tP3000000T7cPIAS" -w 30

rem Lightweight - REST Util (Unlocked)@0.11.0-1
sf package install -p "04tP3000000M6htIAC" -w 30

rem Lightweight - JSON Util (Unlocked)@0.7.0-1
sf package install -p "04tP3000000T7nhIAC" -w 30

rem Lightweight - XML Util (Unlocked)@0.3.0-1
sf package install -p "" -w 30

rem Lightweight - SOAP Util (Unlocked)@0.2.0-1
sf package install -p "" -w 30

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
