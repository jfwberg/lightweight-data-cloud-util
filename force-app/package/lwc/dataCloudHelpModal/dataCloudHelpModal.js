// Lightning stuff
import { api }           from 'lwc';
import LightningModal    from 'lightning/modal';

// Main class
export default class DataCloudHelpModal extends LightningModal  {

    @api header  ='';
    @api content ='';
    
   
    /** **************************************************************************************************** **
     **                                        CLICK BUTTON HANDLERS                                         **
     ** **************************************************************************************************** **/
    handleClickClose() {
        this.close();
    }
}