import { LightningElement} from "lwc";
import createSmartEvent from "@salesforce/apex/SmartDeviceEventDemoLwcCtrl.createSmartEvent";
import LightningAlert from 'lightning/alert';

export default class SmartDeviceEventDemo extends LightningElement {
	

    device = 'Lightbulb';
    action = 'on';

    get deviceOptions() {
        return [
            { label: 'Lightbulb',  value: 'Lightbulb' },
            { label: 'Heating',  value: 'Heating'},
            { label: 'Car Charger',  value: 'Car Charger'}
        ];
    }

    get actionOptions() {
        return [
            { label: 'On',  value: 'on' },
            { label: 'Off', value: 'off'}
        ];
    }

    handleChangeAction(event) {
        this.action = event.detail.value;
    }

    handleChangeDevice(event) {
        this.device = event.detail.value;
    }

    handleClickCreate() {
        try{
            createSmartEvent({ device: this.device, action:this.action})
                .then((result) => {
                    LightningAlert.open({
                        message: result,
                        label: 'Success',
                        theme : 'success'
                    });   
                })
                .catch((error) => {
                    LightningAlert.open({
                        message: 'An unexpected error occurred: ' + error.body.message,
                        label: 'Error',
                        theme : 'error'
                    });
                });
        }catch(error){
            LightningAlert.open({
                message: 'An unexpected error occurred: ' + error.body.message,
                label: 'Error',
                theme : 'error'
            });  
        }
    }



}