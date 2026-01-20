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
        //Simple field validations can be managed using Validation Rules, However we will implement a use case where we will combine it with related record logic to justify Apex use
        //To allow this  logic to scalate correctly for mass DML operations we will use a query to search for related records first
        //Query for the tasks related to the cases being updated.
        //We will only query the task that are not completed, as we will only allow the status change if there is at least one open task
        List<Task> tasks = [
            SELECT Id, Status,WhatId
            FROM Task
            WHERE WhatId IN :newCases
            AND ( NOT (Status = 'Completed' ))
        ];
        
        //Create a map to store the related tasks for each case
        Map<Id, List<Task>> caseTasksMap = new Map<Id, List<Task>>();

        //Populate the map with the related tasks for each case
        for (Task t : tasks) {
            if (!caseTasksMap.containsKey(t.WhatId)) {
                caseTasksMap.put(t.WhatId, new List<Task>());
            }
            caseTasksMap.get(t.WhatId).add(t);
        }

        for (Case c : newCases) {
            Case oldCase = oldMap.get(c.Id);
            //Check for status change from closed to open
            system.debug('Oldcase: '+oldCase.Status );
            system.debug('NewCase'+c.Status);
            if (oldCase != null &&
                oldCase.Status == 'Closed' &&
                c.Status != 'Closed'
            ) {
                system.debug('From closed to open case');
                //If a case exists in the map, it means there are open tasks for this case, allowing the status change, else an error pops up
                if (caseTasksMap.containsKey(c.Id)) {
                    
                } else {
                        c.addError('The case cannot be reopened as there are no open tasks');
                }
            }
        
       
        }
    }
}
