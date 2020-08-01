@isTest
public class WarehouseSyncScheduleTest {
    
    private static String CRON_EXP = '1 0 0 * * ? 2020';


    @isTest static void testSyncSchedule () {
        Test.SetMock(HttpCallOutMock.class, new WarehouseCalloutServiceMock());
        Test.startTest();
        WarehouseSyncSchedule warehouseSyncSchedule = new WarehouseSyncSchedule();
        String jobId = System.schedule('Test Scheduler', CRON_EXP, warehouseSyncSchedule);
        Test.stopTest();

        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
            
        System.assertEquals(CRON_EXP, ct.CronExpression);
    }
    
}