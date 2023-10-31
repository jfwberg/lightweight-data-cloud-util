// Lightning stuff
import { LightningElement }from "lwc";

// Custom Utils
import {handleError}       from 'c/dataCloudUtils';

// Modals
import queryResultModal    from 'c/dataCloudQueryResultModal';

// Apex methods
import getMtdConfigOptions from "@salesforce/apex/DataCloudBulkIngestionUtilLwcCtrl.getMtdConfigOptions";

// Main class
export default class DataCloudQueryUtil extends LightningElement {

    // The query
    query = ''; //'SELECT\n\tactivity_category__c,\n\tactivity_detail__c,\n\tactivity_duration__c,\n\tactivity_id__c,\n\tactivity_name__c,\n\tcategory__c,\n\tDataSource__c,\n\tDataSourceObject__c,\n\tdate__c,\n\tdateTime__c\nFROM\n\tAC_Demo_Web_Streaming_activity_796CF__dlm\nLIMIT 1';

    // Indicator to view the button
    mdtConfigOptionsLoaded = false;
    mdtConfigSelected      = false;

    // Config record picklist details
    mdtConfigRecord;
    mdtConfigOptions;

    // Output as either csv or LWC data table
    resultFormat = 'table';
    resultFormatOptions = [
        {label : 'Datatable', value:'table'},
        {label : 'CSV',       value:'csv'}
    ];


    /** **************************************************************************************************** **
     **                                            GETTER METHODS                                            **
     ** **************************************************************************************************** **/
    // Disable buttons
    get actionDisabled(){
        return !this.mdtConfigSelected;
    }

    get inputDisabled(){
        return !this.mdtConfigOptionsLoaded;
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
    }

    handleChangeQuery(){
        this.query = this.template.querySelector(".ta").value;
    }

    handlechangeResultFormat(event) {
        this.resultFormat = event.detail.value;
    }


    /** **************************************************************************************************** **
     **                                        CLICK BUTTON HANDLERS                                         **
     ** **************************************************************************************************** **/
    handleClickExecuteQuery(){
        this.handleOpenQueryResultModal();
    }


    /** **************************************************************************************************** **
     **                                            MODAL METHODS                                             **
     ** **************************************************************************************************** **/
    /**
     * Open the Mapping Modal
     */
    async handleOpenQueryResultModal() {
        queryResultModal.open({
            config: {
                mdtConfigName : this.mdtConfigRecord,
                resultFormat : this.resultFormat,
                query : this.query
            },
            size: 'large',
        }).then((result) => {
            
        });
    }
}