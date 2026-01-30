import { LightningElement, wire,api } from 'lwc';
import getMyCases from '@salesforce/apex/CasePortalController.getMyCases';

export default class CaseList extends LightningElement {
    //title property
    @api title = 'My Cases';
    columns = [
        { label: 'Case Number', fieldName: 'CaseNumber', type: 'text' },
        { label: 'Subject', fieldName: 'Subject' , type: 'text' },
        { label: 'Status', fieldName: 'Status' , type: 'text'},
        { label: 'Created Date', fieldName: 'CreatedDate', type: 'date' }
    ];
    @wire(getMyCases)
    cases;
}
