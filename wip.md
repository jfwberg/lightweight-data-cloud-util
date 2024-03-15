Changes
- Fixed bug in query placeholder generation
- Updated all tables to utl.Ldt
- Removed help modals and replaced with textModal
- Added multi object support to YAML
- Moved YAML modal logic to main component



TODO - DEMO
- Extract all demo data

TODO - LWC
- Upgrade all data tables (yaml / streaming ingestion)
- Delete dataCloudUtil LWC
- Delete help modal LWC


- Move YAML generation logic to apex and build support for multiple objects
- Move the modal logic out of the modals and use the modals for visibility only


TODO - APEX
- Tidy Code, (utility methods, comments, test classes, constants for v1 v2 etc, error messages)
- Fix AuraException thrown inside aura exception
- Update field mappings for more detailed type support


TODO - LWC Util
- Create a textarea modal with copy / save function (show copy / show save / saveName editable) (dataCloudYamlModal...)
- Create a modal with multiple ldts tables in the LWC package (also add add settor for visibility or editiablity)
- Create a picklist class utl.Pkls
- Add a dynamic compare function

TODO - DataTable
- Give the option to add a type to a datatype to a column, admin only, not really functionality
