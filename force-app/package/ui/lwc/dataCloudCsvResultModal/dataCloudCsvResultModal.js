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
import getSoqlQueryCsv       from "@salesforce/apex/DataCloudUtilLwcCtrl.getSoqlQueryCsv";


// Main class
export default class DataCloudCsvResultModal extends LightningModal  {

    // Configuration
    @api config;

    // Loading indicator for the spinner
    loading = false;

    // Copy button style
    variant         = 'brand';
    downloadVariant = 'brand';
    
    // Visibility getter
    get csvVisible(){
        return !this.loading;
    }


    /** **************************************************************************************************** **
     **                                         LIFECYCLE HANDLERS                                           **
     ** **************************************************************************************************** **/
    connectedCallback() {
        try{
            this.handleGetSoqlQueryCsv();
        }catch(error){
            handleError(error);
            this.loading = false;
        }
    }


    /** **************************************************************************************************** **
     **                                            APEX HANDLERS                                             **
     ** **************************************************************************************************** **/
    handleGetSoqlQueryCsv(){
        try{
            this.loading = true;
            getSoqlQueryCsv({
                mdtConfigName : this.config.mdtConfigName,
                query         : this.config.query,
                tooling       : this.config.tooling
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


    /** **************************************************************************************************** **
     **                                        CLICK BUTTON HANDLERS                                         **
     ** **************************************************************************************************** **/
    handleClickClose() {
        this.close();
    }

    handleClickCopy(){
        try{
            // Execute copy
            copyTextToClipboard(this.template.querySelector('.csvData').innerHTML);

            // Change color to green
            this.variant = 'success';
        }catch(error){
            // Change color to red
            this.variant = 'destructive';
            handleError(error);
        }
    }

    handleClickDownload() {
        try{
            this.loading = true;

            handleDownload(
                this.template,
                'Soql_Query',
                '.csv',
                'text/csv; charset=utf-8;',
                this.template.querySelector('.csvData').innerHTML,
                true
            );

            // change button color to green
            this.downloadVariant = 'success';

        }catch(error){
            // Change color to red
            this.variant = 'destructive';
            handleError(error);

        }finally{
            this.loading = false;
        }
    }
}