/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           October 2023
 * @copyright      (c) 2023 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    LWC JS Class
 */
// Lightning stuff
import   LightningAlert        from 'lightning/alert';
import { LightningElement }    from 'lwc';

// Custom Utils
import { handleError }         from 'c/util';

// Modals
import textModal               from 'c/textModal';
import multiLdtModal           from 'c/multiLdtModal';

// Apex methods
import getDcNamedCredentialOptions from "@salesforce/apex/DataCloudUtilLwcCtrl.getDcNamedCredentialOptions";
import getMtdConfigOptions         from "@salesforce/apex/DataCloudUtilLwcCtrl.getMtdConfigOptions";
import getMetadataInfo             from "@salesforce/apex/DataCloudUtilLwcCtrl.getMetadataInfo";
import getStreamingPlaceholder     from "@salesforce/apex/DataCloudUtilLwcCtrl.getStreamingPlaceholder";
import getDeletePlaceholder        from "@salesforce/apex/DataCloudUtilLwcCtrl.getDeletePlaceholder";
import sendDataStream              from "@salesforce/apex/DataCloudUtilLwcCtrl.sendDataStream";
import testDataStream              from "@salesforce/apex/DataCloudUtilLwcCtrl.testDataStream";

// Main class
export default class DataCloudBulkIngestionUtil extends LightningElement {

    // Loading indicator for the spinner
    loading = false;

    // Indicator if we are running a delete or ingestion
    isDelete = false;

    // Named Credentials picklist details / button indicators
    ncName;
    ncOptions;
    ncOptionsLoaded  = false;
    ncOptionSelected = false;

    // Indicator to view the button
    mdtConfigOptionsLoaded = false;
    mdtConfigSelected      = false;

    // Config record picklist details
    mdtConfigRecord;
    mdtConfigOptions = [];

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

    get deleteButtonVariant(){
        return this.isDelete ? 'destructive' : 'neutral';
    }

    // Disabled when not loaded yet from apex
    get dcNcDisabled(){
        return !this.ncOptionsLoaded;
    }

    // Disabled when not loaded yet from apex
    get mdtConfigDisabled(){
        return !this.mdtConfigOptionsLoaded;
    }

    // Disable buttons
    get actionButtonsDisabled(){
        return !this.mdtConfigSelected;
    }

    // Disable buttons, testing is disabled for deletes
    get testButtonDisabled(){
        return this.actionButtonsDisabled || this.isDelete;
    }

    // Disable buttons, refreshing is disabled for deletes
    get refreshButtonDisabled(){
        return this.actionButtonsDisabled || this.isDelete;
    }

    // Method to get the CodeMirror Textarea Child component
    getCmTa(){
        return this.template.querySelector('c-cm-textarea');
    }


    /** **************************************************************************************************** **
     **                                         LIFECYCLE HANDLERS                                           **
     ** **************************************************************************************************** **/
    connectedCallback(){
        this.handleGetDcNamedCredentialOptions();
    }


    /** **************************************************************************************************** **
     **                                            APEX HANDLERS                                             **
     ** **************************************************************************************************** **/
    handleGetDcNamedCredentialOptions(){
        try{
            this.loading = true;
            getDcNamedCredentialOptions()
                .then((apexResponse) => {
                    this.ncOptions      = apexResponse;
                    this.ncOptionsLoaded= true;
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


    handleGetMdtOptions(){
        try{
            getMtdConfigOptions({namedCredentialName : this.ncName})
                .then((apexResponse) => {
                    this.mdtConfigOptions       = apexResponse;
                    this.mdtConfigOptionsLoaded = true;
                })
                .catch((error) => {
                    handleError(error);
                })
                .finally(()=>{
                    this.loading = false;
                });
        }catch(error){
            handleError(error); 
        }
    }


    handleGetMetadataInfo(){
        try{
            this.loading = true;
            getMetadataInfo({
                mdtConfigName  : this.mdtConfigRecord
            })
            .then((apexResponse) => {
                this.handleOpenMappingModal(apexResponse);
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


    handleGetStreamingPlaceholder(){
        try{
            getStreamingPlaceholder({ mdtConfigName : this.mdtConfigRecord})
                .then((apexResponse) => {
                    this.getCmTa().value = apexResponse;
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


    handleGetDeletePlaceholder(){
        try{
            getDeletePlaceholder()
                .then((apexResponse) => {
                    this.getCmTa().value = apexResponse;
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
    

    handleSendDataStream(){
        try{
            this.loading = true;
            sendDataStream(
                { 
                    mdtConfigName : this.mdtConfigRecord,
                    payload       : this.getCmTa().value,
                    isDelete      : this.isDelete
                }
            )
            .then((apexResponse) => {
                if(apexResponse==true){
                    LightningAlert.open({
                        message: 'Message SENT successfully',
                        label  : 'Success',
                        theme  : 'success'
                    });
                }
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


    handleTestDataStream(){
        try{
            this.loading = true;
            testDataStream({ 
                mdtConfigName : this.mdtConfigRecord, 
                payload       : this.getCmTa().value}
            )
            .then((apexResponse) => {
                if(apexResponse === true){
                    LightningAlert.open({
                        message: 'Message TESTED successfully',
                        label  : 'Success',
                        theme  : 'success'
                    });
                }
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


    handleChangeDelete(){
        try{
            
            // Invert delete
            this.isDelete = !this.isDelete;
            
            // pre-populate with example
            if(this.isDelete){
                this.handleGetDeletePlaceholder();
            }else{
                this.handleGetStreamingPlaceholder();
            }
        }catch(error){
            handleError(error);
        }
    }
   
    /** **************************************************************************************************** **
     **                                        INPUT CHANGE HANDLERS                                         **
     ** **************************************************************************************************** **/
     handleChangeNcName(event) {
        try{
            // On a change reset the metadata settings
            this.mdtConfigSelected      = false;
            this.mdtConfigOptionsLoaded = false;
            this.mdtConfigOptions       = [];
            this.mdtConfigRecord        = '';
            
            // Update named credential
            this.ncName           = event.detail.value;
            this.ncOptionSelected = true;

        }catch(error){
            handleError(error);
        }

        // Get the org's data graph options
        this.handleGetMdtOptions();
    }

    /**
     * Set the config record name and update the table
     */
    handleChangeMtdConfig(event) {
        try{
            this.mdtConfigRecord   = event.detail.value;
            this.mdtConfigSelected = true;
            this.handleGetStreamingPlaceholder();
        }catch(error){
            handleError(error);
        }
    }


    /** **************************************************************************************************** **
     **                                        CLICK BUTTON HANDLERS                                         **
     ** **************************************************************************************************** **/
    handleClickDelete(){
        this.handleChangeDelete();
    }

    handleClickSend(){
        this.handleSendDataStream();
    }

    handleClickTest(){
        this.handleTestDataStream();
    }

    handleClickShowMapping(){
        this.handleGetMetadataInfo();
    }

    handleClickRefresh(){
        this.handleGetStreamingPlaceholder();
     }

    handleClickHelp(){
       this.handleOpenHelpModal() ;
    }


    /** **************************************************************************************************** **
     **                                            MODAL METHODS                                             **
     ** **************************************************************************************************** **/
    /**
     * Open the Mapping Modal
     */
    handleOpenMappingModal(apexResponse){
        try{
            multiLdtModal.open({
                header    : "Data Cloud Configuration Metadata Details",
                tableList : apexResponse,
                size      : 'medium'
            });
        }catch(error){
            handleError(error);
        }
    }

    
    /**
     * Open the help modal
     */
    handleOpenHelpModal(){
        try{
            textModal.open({
                header  : "Data Cloud - Streaming Ingestion Utility - Help",
                content : "Tool to send an ingestion streaming payload to Data Cloud. Based on the Metadata Configuration a sample payload is automatically generated based on the target fields in the mapping.",
                size    : 'small'
            });
        }catch(error){
            handleError(error);
        }
    }
}