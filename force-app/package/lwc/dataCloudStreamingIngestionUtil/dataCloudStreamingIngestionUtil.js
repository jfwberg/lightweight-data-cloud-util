// Lightning stuff
import   LightningAlert        from 'lightning/alert';
import { LightningElement }    from "lwc";

// Modals
import mappingModal            from 'c/dataCloudMappingModal';

// Apex methods
import getMtdConfigOptions     from "@salesforce/apex/DataCloudBulkIngestionUtilLwcCtrl.getConfigMetadataRecordsPicklistOptions";
import getStreamingPlaceholder from "@salesforce/apex/DataCloudBulkIngestionUtilLwcCtrl.getStreamingPlaceholder";
import sendDataStream          from "@salesforce/apex/DataCloudBulkIngestionUtilLwcCtrl.sendDataStream";
import testDataStream          from "@salesforce/apex/DataCloudBulkIngestionUtilLwcCtrl.testDataStream";

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
                    this.handleError(error.body.message);
                })
                .finally(()=>{
                    this.mdtConfigOptionsLoaded = true;
                });
        }catch(error){
            this.handleError(error.message); 
        }
    }

    handleGetStreamingPlaceholder(){
        try{
            getStreamingPlaceholder({ mdtConfigName : this.mdtConfigRecord})
                .then((result) => {
                    this.payload = result;
                })
                .catch((error) => {
                    this.handleError(error.body.message);
                })
                .finally(()=>{
                    this.mdtConfigOptionsLoaded = true;
                });
        }catch(error){
            this.handleError(error.message); 
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
                    this.handleError(error.body.message);
                })
                .finally(()=>{
                    this.mdtConfigOptionsLoaded = true;
                    this.loading = false;
                });
        }catch(error){
            this.handleError(error.message); 
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
                    this.handleError(error.body.message);
                })
                .finally(()=>{
                    this.mdtConfigOptionsLoaded = true;
                    this.loading = false;
                });
        }catch(error){
            this.handleError(error.message); 
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



    /** **************************************************************************************************** **
     **                                           SUPPORT METHODS                                            **
     ** **************************************************************************************************** **/
    handleError(msg){
        LightningAlert.open({
            message: 'An unexpected error occurred: ' + msg,
            label  : 'Error',
            theme : 'error'
        }); 
        this.loading = false;
    }
}