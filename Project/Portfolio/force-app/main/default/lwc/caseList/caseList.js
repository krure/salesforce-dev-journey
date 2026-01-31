/*
 * Author: Krure
 * CreatedDate: 28/01/26
 * LastModifiedDate: 30/01/26
 * Description: Case List Component
 *
*/

import { LightningElement, wire,api } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getMyCases from '@salesforce/apex/CasePortalController.getMyCases';
import { subscribe, MessageContext,unsubscribe } from 'lightning/messageService';
import CASE_CHANNEL from '@salesforce/messageChannel/CaseMessageChannel__c';

export default class CaseList extends LightningElement {
   //For communication between deattached LWC (Siblings; CaseList and caseCreateForm)
    @wire(MessageContext)
    messageContext;

    subscription = null;
    //When the component is disconnected from the DOM, unsubscribe from the message channel
    disconnectedCallback() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }
    //title property
    @api title = 'My Cases';
    cases;
    wiredCaseResult;
    columns = [
        { label: 'Case Number', fieldName: 'CaseNumber', type: 'text' },
        { label: 'Subject', fieldName: 'Subject' , type: 'text' },
        { label: 'Status', fieldName: 'Status' , type: 'text'},
        { label: 'Created Date', fieldName: 'CreatedDate', type: 'date' }
    ];
    @wire(getMyCases)
    wiredCases(result) {
        this.wiredCaseResult = result;
        if (result.data) {
            this.cases = result.data;
        }
    }

connectedCallback() {
    this.subscription = subscribe(
        this.messageContext,
        CASE_CHANNEL,
        (message) => {
            console.log('Mensaje recibido:', message.caseId);
            this.refreshCases();
        }
    );
}
refreshCases() {
    console.log('Actualizando casos...');
    refreshApex(this.wiredCaseResult);
}


}
