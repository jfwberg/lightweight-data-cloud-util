// Lightning stuff
import { api }         from 'lwc';
import LightningAlert  from 'lightning/alert';
import LightningModal  from 'lightning/modal';

// Custom Utils
import {handleError}   from 'c/dataCloudUtils';

// Mapping for the YAML
const fieldTypeMapping = {
    "textField"     : "string",
    "numberField"   : "number",
    "dateField"     : "string\n          format: date",
    "dateTimeField" : "string\n          format: date-time"
};

// Main class
export default class DataCloudYamlModal extends LightningModal {

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


    /** **************************************************************************************************** **
     **                                           SUPPORT METHODS                                            **
     ** **************************************************************************************************** **/
    handleClose(){
        this.close('ok');
    }
}