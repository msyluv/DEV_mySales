@istest
public class TestEmailNotificationBatch {
    
    
    @testSetup
    static void setup() {
        for(integer i=0 ; i< 10 ; i++){
            
            
            User u = new User(
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
                LastName = 'last' + i,
                Email = 'test1232dffs3rwefs@samsung.com.sds',
                Username = i+'test@sample.com.sdspartner',
                CompanyName = 'TEST',
                Title = 'title',
                Alias = 'alias',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US'
            );
            
            insert u;
        }
    }
    
    
    static testMethod void testAttachments()
    {
        
        
        
        // Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
        String cronexpression = '0 0 0 1 3 ?';
        
        Test.startTest();
        
        String jobId = System.schedule('Update Contacts', cronexpression, new EmailNotificationBatchScheduler());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(cronexpression, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        
        Test.stopTest();
        
        // EmailNotificationBatchScheduler e = new EmailNotificationBatchScheduler();
        
    }
}