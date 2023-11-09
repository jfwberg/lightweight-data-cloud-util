// Lightning stuff
import   LightningAlert        from 'lightning/alert';
import { LightningElement }    from "lwc";

// Custom Utils
import {handleError}           from 'c/dataCloudUtils';
import {openHelpModal}         from 'c/dataCloudUtils';

// Modals
import mappingModal            from 'c/dataCloudMappingModal';

// Apex methods
import getMtdConfigOptions     from "@salesforce/apex/DataCloudUtilLwcCtrl.getMtdConfigOptions";
import getStreamingPlaceholder from "@salesforce/apex/DataCloudUtilLwcCtrl.getStreamingPlaceholder";
import sendDataStream          from "@salesforce/apex/DataCloudUtilLwcCtrl.sendDataStream";
import testDataStream          from "@salesforce/apex/DataCloudUtilLwcCtrl.testDataStream";

// Main class
export default class DataCloudBulkIngestionUtil extends LightningElement {

    // Loading indicator for the spinner
    loading = false;

    // Indicator to view the button
    mdtConfigOptionsLoaded = false;
    mdtConfigSelected      = false;

    // Config record picklist details
    mdtConfigRecord;
    mdtConfigOptions = [];

    // The payload of the streaming event
    payload='';

    // Disable buttons
    get buttonsEnabled(){
        return !this.mdtConfigSelected;
    }


    /** **************************************************************************************************** **
     **                                         LIFECYCLE HANDLERS                                           **
     ** **************************************************************************************************** **/
    connectedCallback(){
        // Start with getting the metadata configurations
        this.handleGetMdtOptions();
    }


    /** **************************************************************************************************** **
     **                                            APEX HANDLERS                                             **
     ** **************************************************************************************************** **/
    handleGetMdtOptions(){
        try{
            getMtdConfigOptions()
                .then((result) => {
                    this.mdtConfigOptions = result;
                })
                .catch((error) => {
                    handleError(error);
                })
                .finally(()=>{
                    this.mdtConfigOptionsLoaded = true;
                    this.loading = false;
                });
        }catch(error){
            handleError(error); 
        }
    }

    handleGetStreamingPlaceholder(){
        try{
            getStreamingPlaceholder({ mdtConfigName : this.mdtConfigRecord})
                .then((result) => {
                    this.payload = result;
                })
                .catch((error) => {
                    handleError(error);
                })
                .finally(()=>{
                    this.mdtConfigOptionsLoaded = true;
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
            sendDataStream({ mdtConfigName : this.mdtConfigRecord, payload : this.payload})
                .then((result) => {
                    if(result==true){
                        LightningAlert.open({
                            message: 'Message SENT successfully ',
                            label  : 'Success',
                            theme  : 'success'
                        });
                    }
                })
                .catch((error) => {
                    handleError(error);
                    this.loading = false;
                })
                .finally(()=>{
                    this.mdtConfigOptionsLoaded = true;
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
            testDataStream({ mdtConfigName : this.mdtConfigRecord, payload : this.payload})
                .then((result) => {
                    if(result === true){
                        LightningAlert.open({
                            message: 'Message TESTED successfully ',
                            label  : 'Success',
                            theme  : 'success'
                        });
                    }
                })
                .catch((error) => {
                    handleError(error);
                })
                .finally(()=>{
                    this.mdtConfigOptionsLoaded = true;
                    this.loading = false;
                });
        }catch(error){
            handleError(error);
            this.loading = false;
        }
    }

   
    /** **************************************************************************************************** **
     **                                        INPUT CHANGE HANDLERS                                         **
     ** **************************************************************************************************** **/
    // Set the config record name and update the table
    handleChangeMtdConfig(event) {
        this.mdtConfigRecord = event.detail.value;
        this.mdtConfigSelected = true;
        this.handleGetStreamingPlaceholder();
    }


    /** **************************************************************************************************** **
     **                                        CLICK BUTTON HANDLERS                                         **
     ** **************************************************************************************************** **/
    handleClickSend(){
        this.handleSendDataStream();
    }
    handleClickTest(){
        this.handleTestDataStream();
    }

    handleClickShowMapping(){
        this.handleOpenMappingModal({
            mdtConfigRecord : this.mdtConfigRecord
        });
    }

    handleClickHelp(){
        openHelpModal(
            'Tool to send an ingestion streaming payload to Data Cloud. Based on the Metadata Configuration a sample payload is automatically generated based on the target fields in the mapping.'
        );
    }


    /** **************************************************************************************************** **
     **                                            MODAL METHODS                                             **
     ** **************************************************************************************************** **/
    /**
     * Open the Mapping Modal
     */
    async handleOpenMappingModal (config) {
        mappingModal.open({
            config: config,
            size: 'small',
        }).then((result) => {
            
        });
    }
}