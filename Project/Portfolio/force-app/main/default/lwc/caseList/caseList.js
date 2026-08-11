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
//To navigate to the available Case records
import { NavigationMixin } from 'lightning/navigation';



export default class CaseList extends NavigationMixin(LightningElement) {
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
        { label: 'Case Number', fieldName: 'CaseLink', type: 'url' , typeAttributes: { label: { fieldName: 'CaseNumber' }, target: '_blank' } },
        { label: 'Subject', fieldName: 'Subject' , type: 'text' },
        { label: 'Status', fieldName: 'Status' , type: 'text'},
        { label: 'Created Date', fieldName: 'CreatedDate', type: 'date' },
        { label: 'Priority', fieldName: 'Priority' , type: 'text'},
        { label: 'Integration Status', fieldName: 'integration_status__c' , type: 'text'},
        { label: 'Last Integration Error', fieldName: 'Last_Integration_Error__c' , type: 'text'}
    ];
    @wire(getMyCases)
    wiredCases({data,error}) {
        this.wiredCaseResult = {data,error};
        if (data) {
            // Generate record URLs for each contact
            Promise.all(
                data.map(record =>
                    this[NavigationMixin.GenerateUrl]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: record.Id,
                            objectApiName: 'Case',
                            actionName: 'view'
                        }
                    }).then(url => ({
                        ...record,
                        CaseLink: url
                    }))
                )
            ).then(results => {
                this.cases = results;
            });
        } else if (error) {
            console.error('Error fetching contacts:', error);
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
