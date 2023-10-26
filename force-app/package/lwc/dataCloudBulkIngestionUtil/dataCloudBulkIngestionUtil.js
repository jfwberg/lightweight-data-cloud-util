import { LightningElement } from "lwc";
import getMtdConfigOptions  from "@salesforce/apex/DataCloudBulkIngestionUtilLwcCtrl.getConfigMetadataRecordsPicklistOptions";
import getIngestionJobTable from "@salesforce/apex/DataCloudBulkIngestionUtilLwcCtrl.getIngestionJobTable";
import newJob         from "@salesforce/apex/DataCloudBulkIngestionUtilLwcCtrl.newJob";
import abortJob             from "@salesforce/apex/DataCloudBulkIngestionUtilLwcCtrl.abortJob";
import completeJob          from "@salesforce/apex/DataCloudBulkIngestionUtilLwcCtrl.completeJob";
import deleteJob            from "@salesforce/apex/DataCloudBulkIngestionUtilLwcCtrl.deleteJob";


import LightningAlert from 'lightning/alert';

const actions = [
    { label: 'Details', name: 'details' },
    { label: 'Add CSV', name: 'csv'     },
    { label: 'Complete',name: 'complete'},
    { label: 'Abort',   name: 'abort'   },
    { label: 'Delete',  name: 'delete'  }
];

const columns = [
    { label: 'Created Date', fieldName: 'createdDate' },
    { label: 'Job Id',       fieldName: 'id' },
    { label: 'Operation',    fieldName: 'operation' },
    { label: 'Object',       fieldName: 'object' },
    { label: 'Job State',    fieldName: 'state' },
    { type: 'action', typeAttributes: { rowActions: actions, menuAlignment: 'auto' } }
];


export default class DataCloudBulkIngestionUtil extends LightningElement {

    loading = false;

    // Bulk job column details
    jobTableData = [];
    columns = columns;

    // Indicator to view the button
    mdtConfigOptionsLoaded = false;
    mdtConfigSelected      = false;

    // Config record picklist details
    mdtConfigRecord;
    mdtConfigOptions = [];

    // Disable buttons
    get configSelected(){
        return !this.mdtConfigSelected;
    }

    // Start with getting the metadata configurations
    connectedCallback(){
        this.handleGetMdtOptions();
    }

    // Set the confgi record name and update the table
    handleChangeMtdConfig(event) {
        this.jobTableData = [];
        this.mdtConfigRecord = event.detail.value;
        this.mdtConfigSelected = true;
        this.handleGetIngestionJobTable();
    }


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

    handleGetIngestionJobTable(){
        try{
            this.loading = true;
            getIngestionJobTable({mdtConfigName : this.mdtConfigRecord})
                .then((result) => {
                    this.jobTableData = result;
                    console.log(this.jobTableData);
                })
                .catch((error) => {
                    this.handleError(error.body.message);
                    
                    // Disable buttons on fault state
                    this.mdtConfigSelected = false;
                })
                .finally(()=>{
                    this.loading = false;
                });
        }catch(error){
            this.handleError(error.message);
        }
    }

    handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;
        switch (action.name) {
            case 'details':
                alert('Csv: ' + row.id);
            break;

            case 'csv':
                alert('Csv: ' + row.id);
            break;

            case 'complete':
                this.handleComplete(row.id);
            break;

            case 'abort':
                this.handleAbort(row.id);
            break;
            
            case 'delete':
                this.handleDelete(row.id);
            break;
        }
    }


    handleAbort(jobId){
        try{
            this.loading = true;
            abortJob({mdtConfigName : this.mdtConfigRecord, jobId : jobId})
                .then((result) => {
                    LightningAlert.open({
                        message: 'Succesfully ABORTED the a bulk job with Id : "' + jobId +'"',
                        label: 'Success',
                        theme : 'success'
                    });
                    
                    // Update the job table after creation
                    this.handleGetIngestionJobTable();
                })
                .catch((error) => {
                    this.handleError(error.body.message);
                })
                .finally(()=>{
                    this.loading = false;
                });
        }catch(error){
            this.handleError(error.message);
        }
    }

    handleDelete(jobId){
        try{
            this.loading = true;
            deleteJob({mdtConfigName : this.mdtConfigRecord, jobId : jobId})
                .then((result) => {
                    LightningAlert.open({
                        message: 'Succesfully DELETED the a bulk job with Id : "' + jobId +'"',
                        label: 'Success',
                        theme : 'success'
                    });
                    
                    // Update the job table after creation
                    this.handleGetIngestionJobTable();
                })
                .catch((error) => {
                    this.handleError(error.body.message);
                })
                .finally(()=>{
                    this.loading = false;
                });
        }catch(error){
            this.handleError(error.message);
        }
    }

    handleComplete(jobId){
        try{
            this.loading = true;
            completeJob({mdtConfigName : this.mdtConfigRecord, jobId : jobId})
                .then((result) => {
                    LightningAlert.open({
                        message: 'Succesfully COMPLETED the a bulk job with Id : "' + jobId +'"',
                        label: 'Success',
                        theme : 'success'
                    });
                    
                    // Update the job table after creation
                    this.handleGetIngestionJobTable();
                })
                .catch((error) => {
                    this.handleError(error.body.message);
                })
                .finally(()=>{
                    this.loading = false;
                });
        }catch(error){
            this.handleError(error.message);
        }
    }



    handleClickShowMapping(event){
        console.log(this.mdtConfigRecord);
    }

    handleClickNew(event){
        try{
            newJob( {mdtConfigName : this.mdtConfigRecord})
                .then((result) => {
                    LightningAlert.open({
                        message: 'Succesfully created a new bulk job with Id : "' + result +'"',
                        label: 'Success',
                        theme : 'success'
                    });
                    
                    // Update the job table after creation
                    this.handleGetIngestionJobTable();
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

    handleError(msg){
        LightningAlert.open({
            message: 'An unexpected error occurred: ' + msg,
            label: 'Error',
            theme : 'error'
        }); 
    }
}