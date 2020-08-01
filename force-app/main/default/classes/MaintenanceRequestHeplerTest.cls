@isTest
public class MaintenanceRequestHeplerTest {

    @isTest public static void shouldInsertCases(){
        Product2 equipment1 = new Product2(name='Test', maintenance_cycle__c = 1, Replacement_Part__c = true);
        insert equipment1;
        
        Product2 equipment2 = new Product2(name='Test', maintenance_cycle__c = 10, Replacement_Part__c = true);
        insert equipment2;

        
        Case repairCase = new Case(Subject = 'Test', Status = MaintenanceRequestHelper.STATUS_NEW,
                                  Type = MaintenanceRequestHelper.TYPE_REPAIR);
        insert repairCase;

        List<Work_Part__c> workParts = new List<Work_Part__c>();
        workParts.add(new Work_Part__c(Maintenance_Request__c = repairCase.Id, Equipment__c = equipment1.Id));
        workParts.add(new Work_Part__c(Maintenance_Request__c = repairCase.Id, Equipment__c = equipment2.Id));

        insert workParts; 
        
        Test.startTest();
        repairCase.Status = MaintenanceRequestHelper.STATUS_CLOSED;
        update repairCase;
        Test.stopTest();

        List<Case> allCases = [SELECT Id FROM Case];
        System.assertEquals(2, allCases.size());
        
           for ( Case c : [SELECT Date_Reported__c, Equipment__c, Date_Due__c, Subject  
                        FROM Case WHERE Type = 'Routine Maintenance']) {
            System.assertEquals(System.today(), c.Date_Reported__c);
            System.assert(true, c.Equipment__c != null);
            System.assert(true, c.Subject != null);
            System.assertEquals(c.Date_Due__c, System.today().addDays(1));
        }
    }

    @isTest public static void shouldNotInsertCasesWithOtherType() {
        Case otherCase = new Case(Subject = 'Test', Type = 'Other',
                             Status = MaintenanceRequestHelper.STATUS_NEW);
        insert otherCase;
        Test.startTest();
        otherCase.Status = MaintenanceRequestHelper.STATUS_CLOSED;
        update otherCase;
        Test.stopTest();

        List<Case> allCases = [SELECT Id FROM Case];

        System.assertEquals(1, allCases.size());
    }


    
    @isTest public static void shouldInsertCasesBulk() {
        List<Case> cases = new List<Case>();
        for (Integer i = 0; i < 100; i++) {
            cases.add(new Case(Subject = 'Test', Status = MaintenanceRequestHelper.STATUS_NEW,
                      Type = MaintenanceRequestHelper.TYPE_REPAIR));
            cases.add(new Case(Subject = 'Test', Status = MaintenanceRequestHelper.STATUS_NEW,
                      Type = MaintenanceRequestHelper.TYPE_ROUTINE_MAINTENANCE));
            cases.add(new Case(Subject = 'Test', Type = 'Other',
                      Status = MaintenanceRequestHelper.STATUS_NEW));
        }

        insert cases;

        Test.startTest();
        for (Case i : cases) {
            i.Status = MaintenanceRequestHelper.STATUS_CLOSED;
        }
        update cases;
        Test.stopTest();
 		for (Case c : [SELECT Equipment__c, Subject  
                        FROM Case WHERE Type = 'Routine Maintenance']) {
            System.assert(true, c.Equipment__c != null);
            System.assert(true, c.Subject != null);
        }
    }
}