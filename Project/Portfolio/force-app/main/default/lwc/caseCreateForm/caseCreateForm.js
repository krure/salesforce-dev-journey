/*
 * Author: Krure
 * CreatedDate: 28/01/26
 * LastModifiedDate: 30/01/26
 * Description: Case creation LWC
 *
*/


import { LightningElement,api } from 'lwc';
import createCase from '@salesforce/apex/CasePortalController.createCase';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from 'lightning/navigation';
import { publish, MessageContext } from 'lightning/messageService';
import CASE_CHANNEL from '@salesforce/messageChannel/CaseMessageChannel__c';
import { wire } from 'lwc';

export default class CaseCreateForm extends LightningElement {
    @api title = 'Create Case';
    subject;
    description;
    @wire(MessageContext)
messageContext;


    priority = 'Medium';

    priorityOptions = [
        { label: 'Low', value: 'Low' },
        { label: 'Medium', value: 'Medium' },
        { label: 'High', value: 'High' }
    ];

    handleSubjectChange(event) {
        this.subject = event.target.value;
    }

    handleDescriptionChange(event) {
        this.description = event.target.value;
    }

    handlePriorityChange(event) {
        this.priority = event.target.value;
    }

    async handleSubmit() {
        try {
            const caseId = await createCase({
                subject: this.subject,
                description: this.description,
                priority: this.priority
            });
            //Success
            console.log('Case created successfully');
            //Insert case into database with the createCase
            
            //Toast to notify Case creation
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Case created successfully: {0}',
                    messageData: [
                    {
                        url: `/s/detail/${caseId}`,
                        label: caseId
                    }
                    ],  
                    variant: 'success',
                })
            );
          publish(this.messageContext, CASE_CHANNEL, {
            caseId: caseId
            });


        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Case failed to be created: ' + error.body.pageErrors[0].message,
                    messageData: error.body.pageErrors[0].message,
                    mode: 'sticky',
                    variant: 'error'
                })
            );
            // error handling
            console.error(error);
        }
    }
}
