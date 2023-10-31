import   LightningAlert     from 'lightning/alert';


export function handleError(error){
        
    // If something really weird happens have a default message
    let msg = 'Unknown error message';

    // LWC Controller error
    if(error.body !== undefined){
        msg = 'Apex Controller Error : ' + error.body.message;
    
    // Javascript error
    }else if(error.message !==undefined){
        msg = 'Javascript Error : ' + error.message;
    }

    // Open the lightning alert;
    LightningAlert.open({
        message: msg,
        label: 'Error',
        theme : 'error'
    });
}