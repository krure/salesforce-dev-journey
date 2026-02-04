/**
 * @Class: CaseTriggerHandler
 * @Description: This class handles the trigger logic for the Case object.
 * @Creation: 13/01/2026
 * @LastUpdate: 14/06/2023
 * @Version: 1.0
 * @Author:Krure
 */


public class CaseTriggerHandler {

  
    public static void beforeInsert(List<Case> newCases) {
        CaseService.validateCases(newCases);
    }

    public static void beforeUpdate(List<Case> newCases, Map<Id, Case> oldMap) {
        CaseService.validateStatusChange(newCases, oldMap);
    }

   public static void afterInsert(List<Case> newCases) {

    List<Id> caseIds = new List<Id>();
    for (Case c : newCases) {
        caseIds.add(c.Id);
    }

    System.enqueueJob(new CaseIntegrationQueueable(caseIds));
    }


    public static void afterUpdate(List<Case> newCases, Map<Id, Case> oldMap) {
        List<Id> caseIds = new List<Id>();
    for (Case c : newCases) {
        caseIds.add(c.Id);
    }

    System.enqueueJob(new CaseIntegrationQueueable(caseIds));
    }
}
