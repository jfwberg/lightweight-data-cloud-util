# Changes
## General
- Added method getConfigMetadataRecordsPicklistOptions(String namedCredentialName)
- Rename all buttons to metadata info instead of mapping
- Updated documentation

## Query Utility
- Changed query methods and UI to work of named credential name instead of metadata record

## Graph API 
- Implemented a CodeMirror input
- Added additional output formats
- Created a Dc.getDataGraph() method to get the RAW api response

## Ingestion APIs
- Added a refresh button to generate a new streaming payload
- Implemented code mirror for code highlighting to make it more easily to read responses
- Updated BULK ingestion methods to use named credential instead of a metadata configuration with the exception of creating a new job, as this requires the ingestino API Name

## YAML
- Implemented a CodeMirror


-----------------------------------------------------------------------
# TODO Graph API
- Add tabs with input and output options for better UI clariry
- Generate base demo query

# TOD Query
- Add tabs with input and output options for better UI clariry

# SOQL Query
- Update to codemirrors

# TODO YAML
- Add additional data types

# GENERAL
- Update text areas to be the same
- Move files to demo folder
- fix file names for flexi-pages before packaging
- Add CDO2 to sample data

# Update blogs fml
- Images
- Descriptions
- package versions
- method signatures (named credentials)










```html
 <c-cm-textarea
                            theme             = {codemirrorTheme}
                            mode              = {codemirrorMode} 
                            value             = {codemirrorValue} 
                            size              = {codemirrorSize}
                            disabled          = {codemirrorDisabled}
                            class             = {codemirrorClass}
                            onsave            = {codemirrorSave}
                            onloadingcomplete = {codemirrorLoadingComplete}
                        ></c-cm-textarea>
```
```javascript
    
    // Local class codemirror options
    codemirrorLoaded	= false;

    // CodeMirror configuration
    codemirrorTheme	    	  = 'default';
    codemirrorMode	    	  = 'application/json';
    codemirrorValue	    	  = '';
    codemirrorSize	      	  = {width : '100%', height: 250};
    codemirrorDisabled        = false;
    codemirrorClass           = "cm";
    codemirrorSave            = () => {
        this.handleSendDataStream();
    };
    codemirrorLoadingComplete = () => {
        this.codemirrorLoaded = true;
        this.getCmTa().size   = {width : '100%', height: 365};
    }


    // Method to get the CodeMirror Textarea Child component
    getCmTa(){
        return this.template.querySelector('c-cm-textarea');
    }
    ```
