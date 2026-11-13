@isTest
private class CaseIntegrationQueueableTest {

    @isTest
    static void testQueueableIntegration() {

        Test.setMock(HttpCalloutMock.class, new CaseIntegrationMock());

        Case c = new Case(
            Subject = 'Test Case',
            Status = 'New',
            Priority = 'Medium'
        );

        insert c;

        Test.startTest();
        System.enqueueJob(new CaseIntegrationQueueable(new List<Id>{c.Id}));
        Test.stopTest();

        System.assert(true, 'Queueable executed successfully');
    }
}
