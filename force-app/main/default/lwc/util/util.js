/**
* **********************************************************************************************************
* Lightning Wec Component   :   util
* Includes                  :   util.html, util.js, util.js-meta.xml files.
* ***********************************************************************************************************
* @author       Extentia Information Technology
* @created      2019-Apr-19
* @version      1.0
* @description  The lightning web component "util" does not render any custom UI but act as a library for providing 
                many functionalities which can be accessed by any other component. Functions such as provides 
                Salesforce's std. UI for creating, editing, viewing any type of record. Deletes the specific 
                record mentioned by record id. Also it performs sorting the list of data provided.
*/
import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';

export class RecordUtil extends NavigationMixin(LightningElement) {

    static createRecord(objApi, compRef,recordIdVal) {
        // Opens the modal to create a new record --
        const defaultValues = encodeDefaultFieldValues({
            AccountId: recordIdVal
        });
        compRef[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
               objectApiName: objApi,
                actionName: 'new'
            },
            state: {
                defaultFieldValues: defaultValues
            }
        });
    }

    static viewRecord(objApi, recId, compRef) {
        // View the record --
        compRef[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recId,
                objectApiName: objApi,
                actionName: 'view'
            }
        });
    }

    static editRecord(objApi, recId, compRef) {
        // Opens the modal to edit a particular record --
        compRef[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recId,
                objectApiName: objApi,
                actionName: 'edit'
            }
        });
    }

    static deleteRec(recordId, compRef, callback) {
        // call deleteRecord api of uiRecordApi --
        deleteRecord(recordId)
            .then(() => {
                compRef.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Record Is  Deleted',
                        variant: 'success'
                    }),
                );
                if(callback) {
                    callback(compRef);
                }
            })
            .catch(error => {
                compRef.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error While Deleting record',
                        message: error.message,
                        variant: 'error'
                    }),
                );
            });
    }
}

export class ListUtil extends LightningElement {

    static sortData(sortByField, sortDirection, listData) {
        //function to return the value stored in the field
        let key = function(a) { return a[sortByField]; }
        let reverse = sortDirection === 'asc' ? 1: -1;
        
        listData.sort(function(a,b) { 
            a = key(a) ? key(a) : '';
            b = key(b) ? key(b) : '';
            return reverse * ((a>b) - (b>a));
        });
        //return the sorted data to calling function --
        console.log('...listData: ' , listData.length + ' == ' , listData);
        return listData;
    }
}