/**
* **********************************************************************************************************
* Lightning Wec Component   :   customModal
* Includes                  :   customModal.html, customModal.js, customModal.js-meta.xml files.
* ***********************************************************************************************************
* @author       Extentia Information Technology
* @created      2019-Apr-18
* @version      1.0
* @description  The lightning web component "customModal" renders the UI for showing modal which is dynamic and 
                can be used/composed in any other lightning component. You have to specify the header, content 
                and main action dynamically as an attribute to this component.
*/
import { LightningElement, api } from 'lwc';

export default class CustomModal extends LightningElement {
    @api header;
    @api content;
    @api action;

    get actionLowerCase() {
        return `${this.action}`.toLowerCase();
    }

    handleClick(event) {
        // Creates the event with the action name.
        const modalActionEvent = new CustomEvent('modalaction', { detail: event.target.name });
        // Dispatches the event.
        this.dispatchEvent(modalActionEvent);
    }
}