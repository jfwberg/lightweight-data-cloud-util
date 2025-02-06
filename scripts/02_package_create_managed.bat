REM *****************************
REM        PACKAGE CREATION   
REM *****************************

REM Package Create Config
SET devHub=devHubAlias
SET packageName=Lightweight - Data Cloud Util
SET packageDescription=A lightweight set of Data Cloud API and mapping utilities for streaming and bulk data ingestion.
SET packageType=Managed
SET packagePath=force-app/package

REM Package Config
SET packageId=0HoP300000000BJKAY
SET packageVersionId=04tP30000012T5NIAU

REM Create package
sf package create --name "%packageName%" --description "%packageDescription%" --package-type "%packageType%" --path "%packagePath%" --target-dev-hub %devHub%

REM Create package version
sf package version create --package "%packageName%"  --target-dev-hub %devHub% --code-coverage --installation-key-bypass --wait 30

REM Delete package
sf package:delete -p %packageId% --target-dev-hub %devHub% --no-prompt

REM Delete package version
sf package:version:delete -p %packageVersionId% --target-dev-hub %devHub% --no-prompt

REM Promote package version
sf package:version:promote -p %packageVersionId% --target-dev-hub %devHub% --no-prompt

REM /packaging/installPackage.apexp?p0=04tP30000012T5NIAU