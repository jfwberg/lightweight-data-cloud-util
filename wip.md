Changes
- Upgraded aura:if to lwc:if
- Completed Metadata details modal
- Deleted unecesarry modals (help, yaml, mapping, query preview, query result)
- Delete unrequired data cloud utils LWC
- Upgraded Salesforce Query to match Data Cloud Query functionality (added raw, single button)
- Moved all modal logic outside of display only modals


FIX Job details modal, delete the modal



TODO - LWC
 Delete dataCloudUtil LWC
- Delete help modal LWC
- Delete yamlModal modal LWC
- Delete mappingModal LWC
+ delete queryResultModal LWC
- delete dataCloudQueryPreviewModal LWC
- dlete dataCloudCsvResultModal


TODO - APEX
- Fix test classes

TODO -LWC UTIL
- Fix Class Name
- Fix copy button variant...
- Create new package aarghghghgh

TODO - DEMO
- Extract all demo data

DOCUMENTATION - DC UTIL
- Package dependncies
- List<Map<String,String>> getDataCloudNamedCredentialPicklistOptions()
- FieldMetadata[] getFieldMetadata(Map<String,Object> metadataMap, Boolean removePostfix)
- FieldMetadata class
- getAllDataGraphMetadata
- Map<String,Object> getDetailedDataGraphMetadata(String namedCredentialName, String dataGraphName){
- List<Map<String,Object>> getAllDataGraphMetadata(String namedCredentialName){

DOCUMENTATION - BLOG
- Add functionality description to blog
- Update the package versions in the manual and add screenshots


I have updated the Data Cloud Util Apex Library to v0.5 with added support for the Data Graph API, Multi Object YAML files generation and a lot of little overdue code "tidy ups".
You'll have to upgrade the LWC Util package to v0.20 before upgrading to v0.5.
And to answer why not use the Data Cloud Query Builder... That is (currently) working for the home org only and this is an example of a custom implementation an LWC, not a really a functional tool.
