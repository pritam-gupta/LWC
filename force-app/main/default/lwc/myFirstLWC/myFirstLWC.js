import { LightningElement, api, track } from 'lwc';
import Id from '@salesforce/user/Id';
export default class MyFirstLWC extends LightningElement {
    @api name='Pritam';
    @track title='Salesforce Developer';
    phone=90909090;
    @track email='pritam1628@gmail.com';
    userId=Id;

    handleClick(){
        /* eslint-disable no-console */
        console.log('I am inside JS file');
        this.name='Shalu';
        this.title='My Love';
    }

}