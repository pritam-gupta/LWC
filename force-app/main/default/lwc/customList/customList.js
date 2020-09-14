/**
* **********************************************************************************************************
* Lightning Wec Component   :   customList
* Includes                  :   customList.html, customList.js, customList.css, customList.js-meta.xml files.
* ***********************************************************************************************************
* @author       Extentia Information Technology
* @created      2019-Apr-08
* @version      1.0
* @description  The lightning web component "customList" renders the UI for related list which is dynamic and 
                supported for any object. This component also provides functionality for searching on specific 
                fields, sorting columns, viewing, editing, deleting specific record, creating new record. 
                Also it provides the pagination on scrolling the list.
*/

import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import getRecords from '@salesforce/apex/CustomListController.getRecords';
import loadConfig from '@salesforce/apex/CustomListController.loadConfig';
import { RecordUtil, ListUtil } from 'c/util';

/** The delay used when debouncing event handlers before invoking Apex. */
const DELAY = 300;


export default class CustomList extends NavigationMixin(LightningElement) {
    //Record page properties --
    @api currenRecordId;
    @api recordId = '';
    //Design properties --
    @api listTitle = '';
    @api listObjApiName = '';
    @api listFields = '';
    @api relatedField = '';
    @api filterLogic = '';
    @api listIcon;
    @api sortedBy = '';
    @api limitSize = 30;
    
    @track listFilterFields = '';
    @track searchTerm = '';
    @track searchOptions = [];
    @track tableData = [];
    @track columns = [];
    @track offset = 0;
    @track totalNumberOfRows = 0;
    @track tableLoadingState = false;
    @track sortedDirection = 'asc';
    @track enableInfiniteLoading = false;
    @track deleteIndex = -1;
    @track record = undefined;

    @track modalHeader;
    @track modalContent;
    @track modalAction;
    @track isShowDialog = false;
    @track renderTable = true;
    @track isCreateable = false;
    @track error;
 
    /** Wired Apex result so it can be refreshed programmatically */
    wiredTableResult;

    get customTitle() {
        return `${this.listTitle} (${this.tableData.length})`;
    }

    @wire( getRecords, { 
        objApi: '$listObjApiName', 
        fields: '$listFilterFields',
        relatedId: '$recordId',
        relatedField: '$relatedField',
        filterLogic: '$filterLogic',
        searchTerm: '$searchTerm',
        orderBy: '$sortedBy',
        offset: '$offset',
        limitSize: '$limitSize'
    })
    wiredGetRecords(result) {
        this.tableLoadingState = false;
        this.wiredTableResult = result;
        console.log('...result L 2: ', result);
        /* eslint-disable no-alert */
        // window.alert('result= C ==> ',result);
        
         //window.alert('recordId= c ==> ',this.recordId);

        //console.log('...recordId L 2: '+ recordId);
        
        
        
        if( undefined === result.data ||  undefined === result.data.records) {
            this.renderTable = false;

        } else if (result.data) {
            this.renderTable = true;

            if(this.offset !== 0 
            && this.tableData.length < this.totalNumberOfRows ) {
                const currentData = this.tableData;
                //Appends new data to the end of the table
                const newData = currentData.concat(result.data.records);
                this.tableData = newData;
            } else if(this.offset === 0) {
                this.tableData = result.data.records;
                this.totalNumberOfRows = result.data.totalRecordCount;
            }
            //Disable infinite scrolling to load more data if all records have been fetched --
            if(this.tableData.length >= this.totalNumberOfRows) {
                this.enableInfiniteLoading = false;
            } else {
                this.enableInfiniteLoading = true;
            }
            this.error = undefined;
        } else if (result.error) {
            console.log('...here 1', result.error);
            if( this.error === undefined) {
                this.error = result.error;
            }
        }
    }
   
    connectedCallback() {
       /* eslint-disable no-alert */
       //window.alert('currenRecordId 3==> '+this.recordId);

        /* eslint-disable no-console */
        //console.log('test currenRecordId'+recordId);
        // Call Apex method to load initial config required for data table --
        loadConfig({
                objApi: this.listObjApiName,
                fields: this.listFields,
            })
            .then(result => {
                console.log('result 1', result);
                if(!this.listTitle || this.listTitle === '') {
                    this.listTitle = result.listTitle;
                }
                this.columns = JSON.parse(JSON.stringify(result.listColumns));
                this.columns.push({
                    type: 'action',
                    typeAttributes: { rowActions: result.accessActionList },
                });

                this.searchOptions = result.searchableFields;
                this.listFilterFields = result.listFilterFields;
                this.isCreateable = result.isCreateable;

            })
            .catch(error => {
                console.log('...here 2', error.body.message);
                this.renderTable = false;
                if(undefined !== error.body) {
                    this.error = error.body.message;
                }
            });
    }

    handleRefresh() {
        //Reset search and offset --
        this.searchTerm = '';
        this.offset = 0;

        this.template.querySelector('[data-id="txtSearch"]').value = '';
        this.template.querySelector('[data-id="cmbxSearch"]').value = 'NONE';
        console.log('thi pick change value>>'+this.template.querySelector('[data-id="cmbxSearch"]').value);

        const txtSearch = this.template.querySelector('[data-id="txtSearch"]');
        txtSearch.reportValidity();
        const cmbxField = this.template.querySelector('[data-id="cmbxSearch"]');
        cmbxField.reportValidity();
        this.template.querySelector('[data-id="cmbxSearch"]').value = '';
       
        return refreshApex(this.wiredTableResult);
    }

    handleSearchFieldChange(event) {
        const searchField = event.detail.value;
        console.log('searchField>>'+searchField);

        const txtSearch = this.template.querySelector('[data-id="txtSearch"]');
        if( searchField !== '' & txtSearch !== undefined && (txtSearch.value === undefined || txtSearch.value === null || txtSearch.value === '' || txtSearch.value.length < 2)) {
            //If search text is not yet entered or contains less than 2 characters, then report its validity and focus on search text --
            txtSearch.reportValidity();
            txtSearch.focus();
        } else if(searchField !== '') {
            //Clear the error message and call a function to generate search term using search field and search text --
            event.target.reportValidity();
            this.generateSearchTerm(searchField, txtSearch.value);
        }
    }

    handleSearchTxtChange(event) {
        const searchKey = event.target.value;
        console.log('searchKey>>'+searchKey);
        const cmbxField = this.template.querySelector('[data-id="cmbxSearch"]');
        if(cmbxField !== undefined && ( cmbxField.value === '' || cmbxField.value === undefined || cmbxField.value === null)) {
            //If search field is not yet entered, then report its validity and focus on search field --
            cmbxField.reportValidity();
            cmbxField.focus();
        } else if(  (searchKey !== undefined && searchKey !== null && searchKey.length >=2) ||
                    (   (this.searchTerm !== undefined && this.searchTerm !== null && this.searchTerm !== '') &&
                        (searchKey === undefined || searchKey === null || searchKey === '')
                    ) ) {
                            //Clear the error message and call a function to generate search term using search field and search text --
                            event.target.reportValidity();
                            this.generateSearchTerm(cmbxField.value, searchKey);
        } else {
            event.target.reportValidity();
        }
    }

    generateSearchTerm(searchField, searchText) {
        // Debouncing this method: Do not update the reactive property as long as this function is
        // being called within a delay of DELAY. This is to avoid a very large number of Apex method calls.
        window.clearTimeout(this.delayTimeout);
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => {
            if( searchText !== undefined && searchText !== null && searchText !== '' ) {
                   // this.searchTerm = searchField + ' LIKE \'%' + searchText + '%\'';
                   this.searchTerm = searchField + '###'+ searchText  ;
            } else {
                this.searchTerm = '';
            }
            this.offset = 0;
        }, DELAY);
    }

    handleColumnSorting(event) {
        let sortByField = event.detail.fieldName;
        let sortDirection = event.detail.sortDirection;
        //Assign the latest attribute with the sorted column sortByField and sorted direction --
        this.sortedBy = sortByField;
        this.sortedDirection = sortDirection;

        this.tableData = ListUtil.sortData(sortByField, sortDirection, JSON.parse(JSON.stringify(this.tableData)));
    }

    handleLoadMoreData() {
        if(this.enableInfiniteLoading === false) return;
        //Display a spinner to signal that data is being loaded and set the offset to number of records currently in table --
        this.tableLoadingState = true;
        this.offset = (this.tableData).length;
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const rec = event.detail.row;
        console.log('>>>rec>>'+rec.Id);
        switch (actionName) {
            case 'view':
                RecordUtil.viewRecord(this.listObjApiName, rec.Id, this);
                break;
            case 'edit':
                RecordUtil.editRecord(this.listObjApiName, rec.Id, this);
                break;
            case 'delete':
                this.showDeleteModal(rec);
                break;
            default:
        }
    }

    createRecord() {
         RecordUtil.createRecord(this.listObjApiName, this,this.recordId);
    }

    showDeleteModal(rec) {
        //This will show dialog with below content on modal --
        this.record = rec;
        this.modalHeader = 'Delete Record';
        this.modalContent = 'Are you sure you want to delete this Contact?';
        this.modalAction = 'Delete';
        this.isShowDialog = true;
    }
    
    handleModalAction(event) {
        if(event.detail === 'delete') {
            const index = this.findRowIndexById(this.record.Id);
            if (index !== -1) {
                RecordUtil.deleteRec(this.record.Id, this, this.handleAfterDelete);
                this.deleteIndex = index;
            }
        }
        this.isShowDialog = false;
    }

    findRowIndexById(id) {
        let ret = -1;
        this.tableData.some((row, index) => {
            if (row.Id === id) {
                ret = index;
                return true;
            }
            return false;
        });
        return ret;
    }

    handleAfterDelete(self) {
        //Remove the row from table which is deleted --
        self.tableData = self.tableData
                                .slice(0, self.deleteIndex)
                                .concat(self.tableData.slice(self.deleteIndex + 1));
        self.deleteIndex = -1;
        self.record = undefined;
    }
}