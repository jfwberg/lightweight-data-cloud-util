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
import {handleError}         from 'c/dataCloudUtils';
import {handleDownload}      from 'c/dataCloudUtils';
import {copyTextToClipboard} from 'c/dataCloudUtils';


// Mapping for the YAML
const fieldTypeMapping = {
    "textField"     : "string",
    "numberField"   : "number",
    "dateField"     : "string\n          format: date",
    "dateTimeField" : "string\n          format: date-time"
};

// Main class
export default class DataCloudYamlModal extends LightningModal {

    loading = false;

    // Copy button style
    variant         = 'brand';
    downloadVariant = 'brand';

    // Config
    @api sObjectName;
    @api currentlySelectedData;

    // Variable for the YAML data
    yamlData;

    /** **************************************************************************************************** **
     **                                         LIFECYCLE HANDLERS                                           **
     ** **************************************************************************************************** **/
    connectedCallback(){
        try{
            // Set the base string for the yaml data
            this.yamlData='openapi: 3.0.3\ncomponents:\n  schemas:\n    ' + this.sObjectName + ':\n      type: object\n      properties:\n';

            // Add the yaml field data, don't mess with the spaces :)
            for (let index = 0; index < this.currentlySelectedData.length; index++) {
                const element = this.currentlySelectedData[index];
                this.yamlData += '        '   + element.target + ':\n';
                this.yamlData += '          type: ' + fieldTypeMapping[element.dcFtype] + '\n';
            }
        }catch(error){
            handleError(error);
        }
    }

    /** **************************************************************************************************** **
     **                                        INPUT CHANGE HANDLERS                                         **
     ** **************************************************************************************************** **/
     handleChangeYamlData(event){
        this.yamlData = event.target.value;
    }

    handleClickClose() {
        this.close();
    }


    handleClickCopy() {
        try{
            this.loading = true;

            copyTextToClipboard(this.yamlData);
            
            // Change color to green
            this.variant = 'success';

        }catch(error){
            // Change color to red
            this.variant = 'destructive';
            handleError(error);
        }finally{
            this.loading = false;
        }
    }


    handleClickDownload() {
        try{
            this.loading = true;

            handleDownload(
                this.template,
                this.sObjectName,
                '.yaml',
                'text/x-yaml; charset=utf-8;',
                this.yamlData,
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


    /** **************************************************************************************************** **
     **                                           SUPPORT METHODS                                            **
     ** **************************************************************************************************** **/
    handleClose(){
        this.close('ok');
    }
}