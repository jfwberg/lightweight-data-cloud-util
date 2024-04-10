/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           October 2023
 * @copyright      (c) 2023 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    LWC JS Class
 */
// Lightning stuff
import { api, track }    from 'lwc';
import LightningAlert    from 'lightning/alert';
import LightningModal    from 'lightning/modal';

// Custom Utils
import {handleError}     from 'c/util';

// Apex methods
import addCsv            from "@salesforce/apex/DataCloudUtilLwcCtrl.addCsv";
import addCsvFromFile    from "@salesforce/apex/DataCloudUtilLwcCtrl.addCsvFromFile";
import deleteDocument    from "@salesforce/apex/DataCloudUtilLwcCtrl.deleteDocument";
import getCsvPlaceholder from "@salesforce/apex/DataCloudUtilLwcCtrl.getCsvPlaceholder";

// Status variables
const STATUS_UPLOAD_COMPLETE    = 'Upload Complete';

// Data cloud action statusses
const STATUS_SEND_TO_DC         = 'Sending data to Data Cloud';
const STATUS_SEND_TO_DC_SUCCESS = 'CSV File Successfully sent to Data Cloud';
const STATUS_SEND_TO_DC_ERROR   = 'An error occurred whilst sending the CSV File to Data Cloud. Please try again.';

// Document deletion action statusses
// Data cloud action statusses
const STATUS_DELETE_DOCUMENT         = 'Deleting input document';
const STATUS_DELETE_DOCUMENT_SUCCESS = 'CSV File Successfully sent to Data Cloud and succesfully deleted';
const STATUS_DELETE_DOCUMENT_ERROR   = 'An error occurred whilst deleting the CSV File. Please delete the uploaded file manually.';


// Main class
export default class DataCloudAddCsvModal extends LightningModal  {

    // Configuration received from parent object
    @api config;
    
    // Loading indicator for the spinner
    loading = false;

    // Add CSV button variant
    variant = 'brand';
    
    // The CSV string that will be loaded
    csvData;

    // Local class codemirror options
    codemirrorLoaded	= false;

    // CodeMirror configuration
    codemirrorTheme	    	  = 'default';
    codemirrorMode	    	  = 'csv';
    codemirrorValue	    	  = '';
    codemirrorSize	      	  = {width : '100%', height: 250};
    codemirrorDisabled        = false;
    codemirrorClass           = "cm";
    codemirrorSave            = () => {
        this.handleAddCsv();
    };
    codemirrorLoadingComplete = () => {
        this.codemirrorLoaded = true;
        this.getCmTa().size   = {width : '100%', height: 500};
    }

    // Document details used for uploading
    @track document = {
        id               : null,
        name             : null,
        status           : null,
        contentBodyId    : null,
        contentVersionId : null
    };

    // Upload formats
    get acceptedFormats() {
        return ['.txt', '.csv'];
    }

    // Indicator if this is an upload or data as plain text
    get isUpload(){
        return this.config.isUpload == true;
    }

    get fileUploadDisabled(){
        return (this.document.status == STATUS_UPLOAD_COMPLETE || this.document.status == STATUS_SEND_TO_DC);
    }

    // Indicator if the document table should be visible
    get documentInfoVisible(){
        return this.document.status != null;
    }

    // Method to get the CodeMirror Textarea Child component
    getCmTa(){
        return this.template.querySelector('c-cm-textarea');
    }


    /** **************************************************************************************************** **
     **                                         LIFECYCLE HANDLERS                                           **
     ** **************************************************************************************************** **/
    connectedCallback() {
        try{
            // Generate sample data if a config record has been selected
            if(this.config.mdtConfigRecord){

                this.loading = true;
                getCsvPlaceholder({
                    mdtConfigName : this.config.mdtConfigRecord
                })
                .then((apexResponse) => {
                    this.codemirrorValue = apexResponse;
                })
                .catch((error) => {
                    handleError(error);
                })
                .finally(()=>{
                    this.loading = false;
                });
            }else{
                this.codemirrorValue = 'Select a metadata configuration to generate a sample payload based on the confugred mapping fields';
            }
        }catch(error){
            handleError(error);
            this.loading = false;
        }
    }


    /** **************************************************************************************************** **
     **                                        INPUT CHANGE HANDLERS                                         **
     ** **************************************************************************************************** **/
  

    handleUploadFinished(event) {
        try{
            // Get the list of uploaded files
            const uploadedFiles = event.detail.files;
            
            // Update the status
            this.document.status = STATUS_UPLOAD_COMPLETE;
            
            // Last uploaded document Id
            this.document.id               = uploadedFiles[0].documentId;
            this.document.name             = uploadedFiles[0].name;
            this.document.contentBodyId    = uploadedFiles[0].contentBodyId;
            this.document.contentVersionId = uploadedFiles[0].contentVersionId;
            
            // Handle the upload
            this.handleAddCsvFromFile();

        }catch(error){
            handleError(error);
        }
    }


    /** **************************************************************************************************** **
     **                                            APEX HANDLERS                                             **
     ** **************************************************************************************************** **/
    handleAddCsv() {
        try{
            this.loading = true;

            addCsv({
                namedCredentialName : this.config.namedCredentialName,
                jobId               : this.config.jobId,
                csvData             : this.codemirrorValue
            })
            .then(() => {
                this.close('ok');
            })
            .catch((error) => {
                handleError(error);
            })
            .finally(()=>{
                this.loading = false;
            });
            
        }catch(error){
            handleError(error);
            this.loading = false;
        }
    }


    handleAddCsvFromFile() {
        try{
            this.loading = true;
            
            // Update the status
            this.document.status = STATUS_SEND_TO_DC;

            addCsvFromFile({
                namedCredentialName : this.config.namedCredentialName,
                jobId               : this.config.jobId,
                documentId          : this.document.id,
                contentVersionId    : this.document.contentVersionId
            })
            .then((event) => {
                if(event === true){
                    
                    // Update the status
                    this.document.status = STATUS_SEND_TO_DC_SUCCESS;

                    // User friendly popup
                    LightningAlert.open({
                        message: 'Succesfully added the CSV File "' + this.document.name +'" to the Bulk Ingestion Job',
                        label  : 'Success',
                        theme  : 'success'
                    });

                }
            })
            .catch((error) => {
                handleError(error);
                this.document.status = STATUS_SEND_TO_DC_ERROR;
            })
            .finally(()=>{
                this.loading = false;
            });
        }catch(error){
            handleError(error);
            this.loading = false;
            this.document.status = STATUS_SEND_TO_DC_ERROR;
        }finally{
            this.handleDeleteDocument();
        }
    }


    handleDeleteDocument() {
        try{
            this.loading = true;
            
            // Update the status
            this.document.status = STATUS_DELETE_DOCUMENT;

            deleteDocument({
                documentId : this.document.id,
            })
            .then(() => {
                // Update the status
                this.document.status = STATUS_DELETE_DOCUMENT_SUCCESS;
            })
            .catch((error) => {
                handleError(error);
                this.document.status = STATUS_DELETE_DOCUMENT_ERROR;
            })
            .finally(()=>{
                this.loading = false;
            });
        }catch(error){
            handleError(error);
            this.loading = false;
            this.document.status = STATUS_DELETE_DOCUMENT_ERROR;
        }
    }


    /** **************************************************************************************************** **
     **                                        CLICK BUTTON HANDLERS                                         **
     ** **************************************************************************************************** **/
    handleClickAddCsv() {
        this.handleAddCsv();
    }

    handleClickClose() {
        this.close();
    }
}