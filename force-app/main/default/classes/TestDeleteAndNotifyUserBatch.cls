@istest
public class TestDeleteAndNotifyUserBatch {
    
    @testSetup
    static void setup() {
        
            
            
            User u = new User(
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
                LastName = 'last' + 'ii',
                Email = 'test1232dffs3rwefs@samsung.com.sds',
                Username = 'ii'+'test@sample.com.sdspartner',
                CompanyName = 'TEST',
                Title = 'title',
                Alias = 'alias',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                Date_Last_Login__c = Date.newInstance(2021, 04, 17),
                Last_Notification_Date__c = null,
                LocaleSidKey = 'en_US'
            );
            
            insert u;
        
        User uu = new User(
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
                LastName = 'last' + 'i',
                Email = 'test1232dffs3rwefs@samsung.com.sds',
                Username = 'i'+'test@sample.com.sdspartner',
                CompanyName = 'TEST',
                Title = 'title',
                Alias = 'alias',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                Date_Last_Login__c = Date.newInstance(2021, 03, 17),
                Last_Notification_Date__c = null,
                LocaleSidKey = 'en_US'
            );
            
            insert uu;
        
    }
    
    static testMethod void testDeleteBatch()
    {
        
       user uu = new user();
        uu = [select id from user limit 1];
        
        
        
        Test.startTest();
        
            // Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
            String cronexpression = '0 0 0 1 3 ?';
            
            String jobId = System.schedule('Update Contacts', cronexpression, new DeleteAndNotifyUserBatchScheduler());
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            System.assertEquals(cronexpression, ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);
            
        
        
        Test.stopTest();
        
        // EmailNotificationBatchScheduler e = new EmailNotificationBatchScheduler();
        
    }
    
}