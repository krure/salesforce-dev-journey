import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getProfiles from '@salesforce/apex/MassUserCreatorController.getProfiles';
import getUserRoles from '@salesforce/apex/MassUserCreatorController.getUserRoles';
import getPermissionSets from '@salesforce/apex/MassUserCreatorController.getPermissionSets';
import createUsers from '@salesforce/apex/MassUserCreatorController.createUsers';

const MAX_USERS = 50;
const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
let rowCounter = 0;

const emptyRow = () => ({
    id: `row_${++rowCounter}`,
    index: 0,
    firstName: '',
    lastName: '',
    email: '',
    roleId: '',
    profileId: '',
    permissionSetIds: [],
    errors: {}
});

export default class MassUserCreator extends LightningElement {
    profileOptions = [];
    roleOptions = [];
    permSetOptions = [];

    @track userRows = [{ ...emptyRow(), index: 1 }];
    isLoading = false;
    globalErrorMessage = '';
    successMessage = '';

    // ── Datos de la org ──────────────────────────────────────────────────────
    @wire(getProfiles)
    wiredProfiles({ data, error }) {
        if (data) {
            this.profileOptions = data.map((o) => ({ label: o.label, value: o.value }));
        } else if (error) {
            this.showToast(
                'Error',
                'No se pudieron cargar los perfiles: ' + this.extractError(error),
                'error'
            );
        }
    }

    @wire(getUserRoles)
    wiredRoles({ data, error }) {
        if (data) {
            this.roleOptions = data.map((o) => ({ label: o.label, value: o.value }));
        } else if (error) {
            this.showToast(
                'Error',
                'No se pudieron cargar los roles: ' + this.extractError(error),
                'error'
            );
        }
    }

    @wire(getPermissionSets)
    wiredPermSets({ data, error }) {
        if (data) {
            this.permSetOptions = data.map((o) => ({ label: o.label, value: o.value }));
        } else if (error) {
            this.showToast(
                'Error',
                'No se pudieron cargar los conjuntos de permisos: ' + this.extractError(error),
                'error'
            );
        }
    }

    // ── Getters ──────────────────────────────────────────────────────────────
    get displayRows() {
        return this.userRows.map((r) => ({
            ...r,
            firstNameClass: r.errors.firstName ? 'slds-has-error' : '',
            lastNameClass: r.errors.lastName ? 'slds-has-error' : '',
            emailClass: r.errors.email ? 'slds-has-error' : '',
            profileClass: r.errors.profileId ? 'slds-has-error' : ''
        }));
    }

    get userCount() {
        return this.userRows.length;
    }
    get totalCount() {
        return this.userRows.length;
    }
    get isSingleRow() {
        return this.userRows.length <= 1;
    }
    get hasErrors() {
        return !!this.globalErrorMessage;
    }
    get hasSuccess() {
        return !!this.successMessage;
    }

    get completedCount() {
        return this.userRows.filter((r) => r.firstName && r.lastName && r.email && r.profileId)
            .length;
    }

    get progressPercent() {
        return this.userRows.length
            ? Math.round((this.completedCount / this.userRows.length) * 100)
            : 0;
    }

    get progressStyle() {
        return `width: ${this.progressPercent}%`;
    }

    get submitLabel() {
        return this.isLoading ? 'Creando...' : `Crear ${this.userRows.length} usuario(s)`;
    }

    // ── Eventos ──────────────────────────────────────────────────────────────
    handleCountChange(event) {
        const n = parseInt(event.detail.value, 10);
        if (isNaN(n) || n < 1 || n > MAX_USERS) return;

        const current = this.userRows.length;
        if (n > current) {
            const extra = Array.from({ length: n - current }, () => emptyRow());
            this.userRows = [...this.userRows, ...extra];
        } else if (n < current) {
            this.userRows = this.userRows.slice(0, n);
        }
        this.recalcIndexes();
    }

    handleAddRow() {
        if (this.userRows.length >= MAX_USERS) {
            this.showToast(
                'Límite alcanzado',
                `No puedes crear más de ${MAX_USERS} usuarios a la vez.`,
                'warning'
            );
            return;
        }
        this.userRows = [...this.userRows, emptyRow()];
        this.recalcIndexes();
    }

    handleRemoveRow(event) {
        const rowId = event.currentTarget.dataset.id;
        this.userRows = this.userRows.filter((r) => r.id !== rowId);
        this.recalcIndexes();
    }

    handleFieldChange(event) {
        const rowId = event.currentTarget.dataset.id;
        const field = event.currentTarget.dataset.field;
        const value = event.detail.value;

        this.userRows = this.userRows.map((row) => {
            if (row.id !== rowId) return row;
            const errors = { ...row.errors };
            delete errors[field];
            return { ...row, [field]: value, errors };
        });
    }

    async handleSubmit() {
        this.globalErrorMessage = '';
        this.successMessage = '';

        if (!this.validate()) {
            this.globalErrorMessage = 'Revisa los campos obligatorios antes de continuar.';
            return;
        }

        this.isLoading = true;
        try {
            const payload = this.userRows.map((r) => {
                const email = r.email.trim().toLowerCase();
                return {
                    firstName: r.firstName.trim(),
                    lastName: r.lastName.trim(),
                    email,
                    username: email,
                    profileId: r.profileId,
                    roleId: r.roleId || null,
                    permissionSetIds: r.permissionSetIds
                };
            });

            const results = await createUsers({ userInputs: payload });
            const created = results.filter((r) => r.success);
            const failed = results.filter((r) => !r.success);

            if (failed.length === 0) {
                this.successMessage = `${created.length} usuario(s) creado(s) correctamente.`;
                this.showToast('Éxito', this.successMessage, 'success');
                this.userRows = [{ ...emptyRow(), index: 1 }];
            } else {
                // Conserva solo las filas que fallaron para poder corregirlas y reintentar
                const failedEmails = new Set(failed.map((f) => f.email));
                this.userRows = this.userRows.filter((r) =>
                    failedEmails.has(r.email.trim().toLowerCase())
                );
                this.recalcIndexes();

                const detail = failed.map((r) => `${r.fullName}: ${r.errorMessage}`).join(' | ');
                this.globalErrorMessage = `${created.length} creado(s), ${failed.length} con error — ${detail}`;
                this.showToast(
                    'Creación parcial',
                    `${created.length} creados, ${failed.length} con errores.`,
                    'warning'
                );
            }
        } catch (err) {
            const msg = this.extractError(err);
            this.globalErrorMessage = `Error al crear usuarios: ${msg}`;
            this.showToast('Error', msg, 'error');
        } finally {
            this.isLoading = false;
        }
    }

    // ── Helpers ──────────────────────────────────────────────────────────────
    recalcIndexes() {
        this.userRows = this.userRows.map((r, i) => ({ ...r, index: i + 1 }));
    }

    validate() {
        let valid = true;
        this.userRows = this.userRows.map((row) => {
            const errors = {};
            if (!row.firstName.trim()) errors.firstName = 'Requerido';
            if (!row.lastName.trim()) errors.lastName = 'Requerido';
            if (!row.email.trim()) {
                errors.email = 'Requerido';
            } else if (!EMAIL_REGEX.test(row.email.trim())) {
                errors.email = 'Email inválido';
            }
            if (!row.profileId) errors.profileId = 'Requerido';
            if (Object.keys(errors).length) valid = false;
            return { ...row, errors };
        });
        return valid;
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    extractError(error) {
        if (typeof error === 'string') return error;
        if (error?.body?.message) return error.body.message;
        if (error?.message) return error.message;
        return JSON.stringify(error);
    }
}
