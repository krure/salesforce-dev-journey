import { createElement } from '@lwc/engine-dom';
import MassUserCreator from 'c/massUserCreator';

const flushPromises = () => Promise.resolve();

describe('c-mass-user-creator', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    const setup = () => {
        const element = createElement('c-mass-user-creator', { is: MassUserCreator });
        document.body.appendChild(element);
        return element;
    };

    const rows = (element) => element.shadowRoot.querySelectorAll('tbody tr');

    // label, type y variant son propiedades (no atributos) en LWC: se busca por propiedad.
    const buttonByLabel = (element, startsWith) =>
        Array.from(element.shadowRoot.querySelectorAll('lightning-button')).find((b) =>
            b.label.startsWith(startsWith)
        );
    const countInput = (element) => element.shadowRoot.querySelector('lightning-input.count-input');

    it('inicia con una sola fila', () => {
        const element = setup();
        expect(rows(element).length).toBe(1);
    });

    it('agrega una fila al pulsar "Añadir fila"', async () => {
        const element = setup();
        buttonByLabel(element, 'Añadir fila').click();
        await flushPromises();
        expect(rows(element).length).toBe(2);
    });

    it('ajusta la cantidad de filas con el input numérico', async () => {
        const element = setup();
        countInput(element).dispatchEvent(new CustomEvent('change', { detail: { value: '3' } }));
        await flushPromises();
        expect(rows(element).length).toBe(3);

        countInput(element).dispatchEvent(new CustomEvent('change', { detail: { value: '2' } }));
        await flushPromises();
        expect(rows(element).length).toBe(2);
    });

    it('ignora cantidades fuera de rango (máx. 50)', async () => {
        const element = setup();
        countInput(element).dispatchEvent(new CustomEvent('change', { detail: { value: '99' } }));
        await flushPromises();
        expect(rows(element).length).toBe(1);
    });

    it('muestra errores de validación al enviar con campos vacíos', async () => {
        const element = setup();
        buttonByLabel(element, 'Crear').click();
        await flushPromises();
        await flushPromises();

        const alert = element.shadowRoot.querySelector('.slds-alert_error');
        expect(alert).not.toBeNull();
        const fieldErrors = element.shadowRoot.querySelectorAll('.slds-text-color_error');
        // Nombre, apellido, correo y perfil
        expect(fieldErrors.length).toBe(4);
    });

    it('no permite eliminar la última fila', () => {
        const element = setup();
        const deleteButton = element.shadowRoot.querySelector('lightning-button-icon');
        expect(deleteButton.disabled).toBe(true);
    });
});
