/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 * 
 */
/***
 * @description: This class contains unit tests for validating the behavior of Case Triggers.
 * @Author: Krure 
 * @Creation: 13/01/2026
 * @LastUpdate: 14/06/2023
 * 
 */
@IsTest
private class CaseTriggerHandlerTest {

    @IsTest
    static void shouldPreventCaseWithoutSubject() {
        Case c = new Case(Status = 'New');

        Test.startTest();
        try {
            insert c;
            System.assert(false, 'Expected validation error');
        } catch (DmlException e) {
            System.assert(
                e.getMessage().contains('Case Subject is required'),
                'Validation message not found'
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void shouldPreventReopeningClosedCase() {
        Case c = new Case(
            Subject = 'Test Case',
            Status = 'Closed'
        );
        insert c;

        c.Status = 'New';

        Test.startTest();
        try {
            update c;
            System.assert(false, 'Expected status validation error');
        } catch (DmlException e) {
            System.assert(
                e.getMessage().contains('cannot be reopened'),
                'Status validation failed'
            );
        }
        Test.stopTest();
    }

    /*
    @MethodName: shouldSyncCase
    @Description: This method tests the integration of the Case Trigger Handler with the Integration Service.
    @Author:Krure
    */
    @IsTest
    static void shouldSyncCase() {
        Case c = new Case(
            Subject = 'Test Case',
            Status = 'New'
        );
        insert c;
        //We will only test the successful scenario for now
        Test.startTest();
        update c;
        Test.stopTest();
        
        System.Assert.areEqual(c, [SELECT Id,Status,Subject FROM Case WHERE Id = :c.Id]);
    }

}
