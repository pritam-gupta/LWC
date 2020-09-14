import { LightningElement,track, wire } from 'lwc';
import Name_field from '@salesforce/schema/Account.Name';
import sObjectName from '@salesforce/schema/Account';
import getContactList from '@salesforce/apex/ContactController.contactList';
export default class HelloWorld extends LightningElement {
  @track greeting = 'World';
  @track name = Name_field;
  @track objName = sObjectName; 
  @wire(getContactList) contact; 
  contacts =[
    {
        Id:'98098u98232',
        Name:'Developer',
        Title:'Koti'
    },
    {
        Id:'98098u923238',
        Name:'Developer',
        Title:'Pritam'
    },
    {
        Id:'98098u983232',
        Name:'Rahul',
        Title:'Tester'
    },
    {
        Id:'98098u9wqwq8',
        Name:'Ankit',
        Title:'Tester'
    }
];
  changeHandler(event) {
    this.greeting = event.target.value;
  }
}