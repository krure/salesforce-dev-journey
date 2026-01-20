public with sharing class CasePortalController {

    @AuraEnabled
    public static Id createCase(String subject, String description, String priority) {
        Case c = new Case(
            Subject = subject,
            Description = description,
            Priority = priority,
            Status = 'New'
        );
        insert c;
        return c.Id;
    }

    @AuraEnabled(cacheable=true)
    public static List<Case> getMyCases() {
        return [
            SELECT Id, CaseNumber, Subject, Status, CreatedDate
            FROM Case
            WHERE CreatedById = :UserInfo.getUserId()
            ORDER BY CreatedDate DESC
        ];
    }
}
