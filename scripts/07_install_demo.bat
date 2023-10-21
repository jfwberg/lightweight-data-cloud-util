REM Deploy the custom implementation files
sf project deploy start --source-dir force-app/demo

REM Assign the permission set
sf org assign permset --name "Smart_Device_Event_Demo"