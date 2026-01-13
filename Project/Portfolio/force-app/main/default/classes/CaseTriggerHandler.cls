public class CaseTriggerHandler {

    public static void beforeInsert(List<Case> newCases) {
        CaseService.validateCases(newCases);
    }

    public static void beforeUpdate(List<Case> newCases, Map<Id, Case> oldMap) {
        CaseService.validateStatusChange(newCases, oldMap);
    }

    public static void afterInsert(List<Case> newCases) {
        IntegrationService.syncCases(newCases);
    }

    public static void afterUpdate(List<Case> newCases, Map<Id, Case> oldMap) {
        IntegrationService.syncCases(newCases);
    }
}
