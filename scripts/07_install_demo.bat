REM Deploy the custom implementation files
sf project deploy start --source-dir force-app/demo

REM Assign the permission set
sf org assign permset --name "Smart_Device_Event_Demo"


sf project deploy start --source-dir force-app/tdx-demo
sf org assign permset --name "Data_Cloud_Smart_Demo"