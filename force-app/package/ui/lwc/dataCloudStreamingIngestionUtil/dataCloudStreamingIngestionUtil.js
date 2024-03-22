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
import getMtdConfigOptions     from "@salesforce/apex/DataCloudUtilLwcCtrl.getMtdConfigOptions";
import getMetadataInfo         from "@salesforce/apex/DataCloudUtilLwcCtrl.getMetadataInfo";
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
        this.handleGetMdtOptions();
    }


    /** **************************************************************************************************** **
     **                                            APEX HANDLERS                                             **
     ** **************************************************************************************************** **/
    handleGetMdtOptions(){
        try{
            getMtdConfigOptions()
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
                    this.payload                             = apexResponse;
                    this.template.querySelector(".ta").value = apexResponse;
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
                { mdtConfigName : this.mdtConfigRecord,
                    payload     : this.payload}
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
                payload       : this.payload}
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

   
    /** **************************************************************************************************** **
     **                                        INPUT CHANGE HANDLERS                                         **
     ** **************************************************************************************************** **/
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


    /**
     * Update changes in the payload textarea
     */
    handleChangePayload() {
        try{
            this.payload = this.template.querySelector(".ta").value;
        }catch(error){
            handleError(error);
        }
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
        this.handleGetMetadataInfo();
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