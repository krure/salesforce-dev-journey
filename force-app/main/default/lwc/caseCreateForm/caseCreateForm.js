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

export default class CaseCreateForm extends NavigationMixin(LightningElement) {
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
            console.log('Case created successfully : '+caseId);
            //Create new record page reference
            const pageRef = {
                type: "standard__recordPage",
                attributes: {
                    recordId: `${caseId}`,
                    actionName: "view"
                }
            };
            var recordUrl;
            this[NavigationMixin.GenerateUrl](pageRef)
            .then(url => {
                 console.log('Generated URL:', url);
                 recordUrl=url; 
                 // Optionally navigate this[NavigationMixin.Navigate](pageReference);
                  console.log('Generated URL2:', recordUrl);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Case created successfully: {0}',
                            messageData: [
                            {
                                url: `${recordUrl}`,
                                label: caseId
                            }
                            ],  
                            variant: 'success',
                        })
                );
                })
            .catch(error => { 
                console.error('Error generating URL:', error);
            });
            //Toast to notify Case creation
            
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
