import { LightningElement,track } from 'lwc';
export default class helloWorld extends LightningElement {
  greeting = 'World';
  changeHandler(event) {
    this.greeting = event.target.value;
  }
}