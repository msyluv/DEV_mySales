/**
 * @description       : 
 * @author            : zenith21c@test.com
 * @group             : 
 * @last modified on  : 02-28-2022
 * @last modified by  : zenith21c@test.com
**/
@isTest
private class TestPartnerEnrollmentController {
    
    
    @testSetup static void setup() {
        // Create common test accounts
        
        for(integer i =0 ; i<3 ; i++){
            
            
            
            Partner_T_C_Master__c rec =new Partner_T_C_Master__c();
            
            rec.isActive__c  = true;
            rec.Apply_Date__c = date.today();
            rec.T_C_Use__c = 'Enrollment';
            rec.Cannot_Uncheck__c = false;
            rec.isMandatory__c = true;
            rec.Name = 'test data';
            rec.T_C_Detail__c = 'this is sample data';
            if(i ==0){
                rec.T_C_Type__c = 'Cross-border Transfer of Personal Information';
            }
            if(i ==1){
                rec.T_C_Type__c = 'Collection and Use of Personal Information';
            }
            if(i ==2){
                rec.T_C_Type__c = 'Terms of Service';
            }
            
            
            insert rec;
            
        }
        
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = 'test1232dffs3rwefs@samsung.com.sds',
            Username = 'test1232dffs3rwefs@samsung.com.sds.test',
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
    static testMethod void testgetData()
    {
        
        List<Partner_T_C_Master__c> pT = new list<Partner_T_C_Master__c>();
        
        pT = [select id, T_C_Detail__c , T_C_Type__c, T_C_Use__c from Partner_T_C_Master__c where isActive__c =true and T_C_Use__c = 'Enrollment'];
        List<String> pTIds = new list<String>();
        for(Partner_T_C_Master__c pp : pT){
            pTIds.add(pp.id);
        }
        PartnerEnrollmentRequestFormController.getData();
        
        user uu = new user();
        user uu2 = new user();
        
        uu = [select id, username from user order by username desc limit 1];
        uu2 = [select id, username from user order by username asc limit 1];
        PartnerEnrollmentRequestFormController.isDuplicate(uu.username , uu2.username,true);
        PartnerEnrollmentRequestFormController.isDuplicate(uu.username , uu2.username,false);
        
        //system.assertEquals(true, returnVar);
        
        PartnerEnrollmentRequestFormController.insertedInfo Idrec = PartnerEnrollmentRequestFormController.createPerRec('rakshit.s@samsung.com.sdspartner', 'Value Added Reseller', 'sub', 'test@sample.com', '1234567890', 'description', 'fname', 'lname', 'http://www.sample.com', '1234567890', 'cName', '11234567890',false);
        PartnerEnrollmentRequestFormController.insertedInfo Idrec2 = PartnerEnrollmentRequestFormController.createPerRec('rakshit.s@samsung.com.sdspartner', 'Value Added Reseller', 'sub', 'test@sample.com', '1234567890', 'description', 'fname', 'lname', 'http://www.sample.com', '1234567890', 'cName', '11234567890',true);
        system.assertEquals(Idrec.insertedId, Idrec.insertedId);
        PartnerEnrollmentRequestFormController.createRelatedTnCRec(Idrec.insertedId, pTIds);
    }
}