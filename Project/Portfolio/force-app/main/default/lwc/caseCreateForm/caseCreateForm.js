import { LightningElement } from 'lwc';
import createCase from '@salesforce/apex/CasePortalController.createCase';

export default class CaseCreateForm extends LightningElement {
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
            // success handling (toast luego)
        } catch (error) {
            // error handling
            console.error(error);
        }
    }
}
