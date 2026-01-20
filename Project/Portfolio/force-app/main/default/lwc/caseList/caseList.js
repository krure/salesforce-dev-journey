import { LightningElement, wire } from 'lwc';
import getMyCases from '@salesforce/apex/CasePortalController.getMyCases';

export default class CaseList extends LightningElement {
    columns = [
        { label: 'Case Number', fieldName: 'CaseNumber' },
        { label: 'Subject', fieldName: 'Subject' },
        { label: 'Status', fieldName: 'Status' },
        { label: 'Created Date', fieldName: 'CreatedDate', type: 'date' }
    ];

    @wire(getMyCases)
    cases;
}
