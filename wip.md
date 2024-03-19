Changes



## yamlModal == textareaModal
## 


TODO - DEMO
- Extract all demo data

TODO - LWC
- Upgrade all data tables (yaml / streaming ingestion)
- Delete dataCloudUtil LWC
- Delete help modal LWC
- upgrade aura ifs to lwc:if
- fix picklist options for metadata configuration (own picklist component?)
- check all loading items in the apex methods
- Move the modal logic out of the modals and use the modals for visibility only


TODO - APEX
- Tidy Code, (utility methods, comments, test classes, constants for v1 v2 etc, error messages)
- Fix AuraException thrown inside aura exception
- Update field mappings for more detailed type support


TODO - LWC Util
// - Create a textarea modal with copy / save function (show copy / show save / saveName editable) (dataCloudYamlModal...)
// - Create a modal with multiple ldts tables in the LWC package (also add add settor for visibility or editiablity)
- Create a picklist class utl.Pkls



TODO - DataTable
- Give the option to add a type to a datatype to a column, admin only, not really functionality
- Add function to setAllColumns

TODO - BLOG
- Update reasons for multi org 


DOCUMENTATION
- List<Map<String,String>> getDataCloudNamedCredentialPicklistOptions()
- FieldMetadata[] getFieldMetadata(Map<String,Object> metadataMap, Boolean removePostfix)
- FieldMetadata class
- getAllDataGraphMetadata
- Map<String,Object> getDetailedDataGraphMetadata(String namedCredentialName, String dataGraphName){
- List<Map<String,Object>> getAllDataGraphMetadata(String namedCredentialName){