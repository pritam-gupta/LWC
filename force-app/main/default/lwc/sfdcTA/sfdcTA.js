import { LightningElement, track, wire,api } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

export default class SfdcTA extends LightningElement {
    @api recordId;
    @track record;
    @track error;
    @wire(getRecord, { recordId: '$recordId', fields: ['Account.Name','Account.BillingStreet','Account.BillingCity'] })
    wiredAccount({ error, data }) {
        if (data) {
            this.record = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.record = undefined;
        }
    }
    get name() {
        return this.record.fields.Name.value;
    }
  
    get billingCity() {
        if(this.record.fields.BillingCity.value!=null && this.record.fields.BillingCity.value!=''){
            return this.record.fields.BillingCity.value;
        } 
        else{
            return "None Specified";
        }
    }
}