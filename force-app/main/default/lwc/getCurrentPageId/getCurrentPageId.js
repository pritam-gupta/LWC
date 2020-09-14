import { LightningElement, api, track } from 'lwc';

export default class LWCDemo extends LightningElement {
    @api objectApiName;
    @api recordId;
    @track currenObjectName;
    @track currenRecordId;

    connectedCallback() {
        this.currenRecordId = this.recordId;
        this.currenObjectName = this.objectApiName;
         /* eslint-disable no-console */
         console.log('>>>currenRecordId>>>'+this.currenRecordId);

    }
}