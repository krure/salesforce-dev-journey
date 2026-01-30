import { LightningElement,api } from 'lwc';
import createCase from '@salesforce/apex/CasePortalController.createCase';

export default class CaseCreateForm extends LightningElement {
    @api title = 'Create Case';
    subject;
    description;
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
            await createCase({
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
                    message: 'Case created successfully',
                    variant: 'success',
                }),
            );
        } catch (error) {
            // error handling
            console.error(error);
        }
    }
}
