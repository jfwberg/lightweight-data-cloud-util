REM --------------------------------------------------------
REM MANGED DEPENDENCIES (PICK EITHER MANAGED OR UNLOCKED)  -
REM --------------------------------------------------------
REM Managed package - Lightweight - Apex Unit Test Util v2@2.2.0-1
sf package install --package 04tP30000007Ez7IAE -w 30

REM Managed package - Lightweight - REST Util@0.9.0-1
sf package install --package 04tP30000007FOvIAM -w 30

REM Managed package - Lightweight - JSON Util@0.1.0-1
sf package install --package 04tP30000005PYrIAM -w 30

REM ----------------- OPTIONAL BUT ADVICED -----------------
REM Managed package - Lightweight - Data Cloud Auth Provider@0.2.0-1
sf package install --package 04tP30000007FvBIAU -w 30

REM Managed package - Lightweight - Auth Provider Util v2@0.5.0-1
sf package install --package 04tP30000007GUfIAM -w 30


REM --------------------------------------------------------
REM UNLOCKED DEPENDENCIES (PICK EITHER MANAGED OR UNLOCKED)-
REM --------------------------------------------------------
REM Unlocked package - Lightweight - Apex Unit Test Util v2 (Unlocked)@2.2.0-1
sf package install --package 04tP30000007F3xIAE -w 30

REM Unlocked package - Lightweight - REST Util (Unlocked)0.9.0-1
sf package install --package 04tP30000007FVNIA2 -w 30

REM Managed package - Lightweight - JSON Util (Unlocked)@0.1.0-1
sf package install --package xx -w 30

REM ----------------- OPTIONAL BUT ADVICED -----------------
REM Unlocked package - Lightweight - Data Cloud Auth Provider (Unlocked)@0.2.0-1
sf package install --package 04tP30000007GCvIAM -w 30

REM Managed package - Lightweight - Auth Provider Util v2 (Unlocked)@0.5.0-1
sf package install --package 04tP30000007GXtIAM -w 30


REM --------------------------------------------------------
REM                  ASSIGN PERMISSION SETS                -
REM --------------------------------------------------------
sf org assign permset --name "Apex_Unit_Test_Util_v2"
sf org assign permset --name "Lightweight_REST_Util"
sf org assign permset --name "Auth_Provider_Util_Admin"

