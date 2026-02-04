public class CaseIntegrationQueueable implements Queueable, Database.AllowsCallouts {

    private List<Id> caseIds;

    public CaseIntegrationQueueable(List<Id> caseIds) {
        this.caseIds = caseIds;
    }

    public void execute(QueueableContext context) {

        List<Case> casesToSync = [
            SELECT Id, CaseNumber, Subject, Priority, Status
            FROM Case
            WHERE Id IN :caseIds
        ];

        IntegrationService.syncCases(casesToSync);
    }
}
