/**
 * @Class: CaseService
 * @Description: This class contains business logic for the Case object.
 * @Creation: 13/01/2026
 * @LastUpdate: 14/06/2023
 * @Version: 1.0
 * @Note:
 * /**
 * NOTE:
 * Basic field-level validations like this could also be implemented
 * using Salesforce Validation Rules.
 *
 * Apex is used here intentionally to:
 * - Centralize complex or conditional business logic
 * - Enable reuse across different entry points (UI, integrations, batch)
 * - Facilitate unit testing and future extensibility
 */



public class CaseService {

    public static void validateCases(List<Case> casesToValidate) {
        for (Case c : casesToValidate) {
            if (String.isBlank(c.Subject)) {
                c.addError('Case Subject is required.');
            }
        }
    }

    /**
     * @MethodName: validateStatusChange
     * @Description: This method validates the status change of a case.
     * @Creation: 13/01/2026
     * @LastUpdate: 14/06/2023
     * @Version: 1.0
     * @Note:
     * /**
        * NOTE:
        * Status transition rules can be enforced via Validation Rules.
        *
        * Apex validation is preferred in this scenario to:
        * - Support more complex state transition logic
        * - Enable integration-aware validations
        * - Keep business rules version-controlled and testable
    */

    public static void validateStatusChange(
        List<Case> newCases,
        Map<Id, Case> oldMap
    ) {
        for (Case c : newCases) {
            Case oldCase = oldMap.get(c.Id);

            if (oldCase != null &&
                oldCase.Status == 'Closed' &&
                c.Status != 'Closed'
            ) {
                c.addError('Closed cases cannot be reopened.');
            }
        }
    }
}
