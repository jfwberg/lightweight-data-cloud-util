/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           October 2023
 * @copyright      (c) 2023 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    LWC JS Class
 */
// Lightning stuff
import { api }               from 'lwc';
import LightningModal        from 'lightning/modal';

// Custom Utils
import {handleError}         from 'c/util';
import {handleDownload}      from 'c/util';
import {copyTextToClipboard} from 'c/util';

// Apex methods
import getDcQueryCsv         from "@salesforce/apex/DataCloudUtilLwcCtrl.getDcQueryCsv";
import getDcQueryTable       from "@salesforce/apex/DataCloudUtilLwcCtrl.getDcQueryTable";
import getDcQueryRaw         from "@salesforce/apex/DataCloudUtilLwcCtrl.getDcQueryRaw";


// Main class
export default class DataCloudQueryResultModal extends LightningModal  {

    // Configuration
    @api config;
    
    // Loading indicator for the spinner
    loading = false;

    // Copy button style
    copyVariant     = 'brand';
    downloadVariant = 'brand';
    prettifyVariant = 'brand';
    
    // The CSV string that will be loaded
    csvData;

    // The Raw API response
    rawData;

    // Lightning data table response
    ldt = {};

    // Define apexResponse type visibility for CSV
    get isCsv(){
        return this.config.resultFormat === 'csv'  && this.loading  === false;
    }

    // Define apexResponse type visibility for an LWC Data table
    get isTable(){
        return this.config.resultFormat === 'table' && this.loading === false;
    }

    // Define apexResponse type visibility for Raw API Response
    get isRaw(){
        return this.config.resultFormat === 'raw'   && this.loading === false;
    }


    /** **************************************************************************************************** **
     **                                         LIFECYCLE HANDLERS                                           **
     ** **************************************************************************************************** **/
    connectedCallback() {
        try{
            // Handle CSV
            if(this.config.resultFormat       === 'csv'){
                this.handleGetDcQueryCsv();
            
            // Handle data table
            }else if(this.config.resultFormat === 'table'){
                this.handleGetDcQueryTable();
        
            // Handle raw response
            }else if(this.config.resultFormat === 'raw'){
                this.handleGetDcQueryRaw();
            }
        }catch(error){
            handleError(error);
            this.loading = false;
            this.close();
        }
    }


    /** **************************************************************************************************** **
     **                                        INPUT CHANGE HANDLERS                                         **
     ** **************************************************************************************************** **/
    handleChangeCsvData(){
        this.csvData = this.template.querySelector(".ta").value;
    }

    handleChangeRawData(){
        this.rawData = this.template.querySelector(".ta").value;
    }


    /** **************************************************************************************************** **
     **                                            APEX HANDLERS                                             **
     ** **************************************************************************************************** **/
    handleGetDcQueryCsv(){
        try{
            this.loading = true;
            getDcQueryCsv({
                mdtConfigName : this.config.mdtConfigName,
                query         : this.config.query,
                apiVersion    : this.config.apiVersion
            })
            .then((apexResponse) => {
                this.csvData = apexResponse;
            })
            .catch((error) => {
                handleError(error);
                this.close();
            })
            .finally(()=>{
                this.loading = false;
            });
        }catch(error){
            handleError(error);
            this.loading = false;
            this.close();
        }
    }


    handleGetDcQueryTable(){
        try{
            this.loading = true;
            getDcQueryTable({
                mdtConfigName : this.config.mdtConfigName,
                query         : this.config.query,
                apiVersion    : this.config.apiVersion
            })
            .then((apexResponse) => {
                this.ldt = apexResponse;
            })
            .catch((error) => {
                handleError(error);
                this.close();
            })
            .finally(()=>{
                this.loading = false;
            });
        }catch(error){
            handleError(error);
            this.loading = false;
            this.close();
        }
    }

    handleGetDcQueryRaw(){
        try{
            this.loading = true;
            getDcQueryRaw({
                mdtConfigName : this.config.mdtConfigName,
                query         : this.config.query,
                apiVersion    : this.config.apiVersion
            })
            .then((apexResponse) => {
                this.rawData = apexResponse; 
            })
            .catch((error) => {
                handleError(error);
                this.close();
            })
            .finally(()=>{
                this.loading = false;
            });
        }catch(error){
            handleError(error);
            this.loading = false;
            this.close();
        }
    }


    /** **************************************************************************************************** **
     **                                        CLICK BUTTON HANDLERS                                         **
     ** **************************************************************************************************** **/
    handleClickClose() {
        this.close();
    }


    handleClickCopy(){
        try{
            // Execute copy
            copyTextToClipboard(this.csvData);

            // Change color to green
            this.copyVariant = 'success';
        }catch(error){
            // Change color to red
            this.copyVariant = 'destructive';
            handleError(error);
        }
    }

    handleClickDownload() {
        try{
            this.loading = true;

            handleDownload(
                this.template,
                'Data_Cloud_Query',
                '.csv',
                'text/csv; charset=utf-8;',
                this.csvData,
                true
            );

            // change button color to green
            this.downloadVariant = 'success';

        }catch(error){
            // Change color to red
            this.copyVariant = 'destructive';
            handleError(error);

        }finally{
            this.loading = false;
        }
    }

    handleClickCopyRaw(){
        try{
            // Execute copy
            copyTextToClipboard(this.rawData);

            // Change color to green
            this.copyVariant = 'success';
        }catch(error){
            // Change color to red
            this.copyVariant = 'destructive';
            handleError(error);
        }
    }

    handleClickDownloadRaw() {
        try{
            this.loading = true;

            handleDownload(
                this.template,
                'Data_Cloud_Query',
                '.json',
                'application/json; charset=utf-8;',
                this.rawData,
                true
            );

            // change button color to green
            this.downloadVariant = 'success';

        }catch(error){
            // Change color to red
            this.copyVariant = 'destructive';
            handleError(error);

        }finally{
            this.loading = false;
        }
    }

    handleClickPrettify(){
        try{
            this.loading = true;

            // change button color to green
            this.prettifyVariant = 'success';
            
            // Make it pretty
            this.rawData = JSON.stringify(JSON.parse(this.rawData),null,4);

        }catch(error){
            // Change color to red
            this.prettifyVariant = 'destructive';
            handleError(error);
        }finally{
            this.loading = false;
        }
    }
}