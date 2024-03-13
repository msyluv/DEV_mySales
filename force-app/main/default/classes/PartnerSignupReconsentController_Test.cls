/**
 * @description       : 
 * @author            : zenith21c@test.com
 * @group             : 
 * @last modified on  : 03-23-2022
 * @last modified by  : zenith21c@test.com
**/
@isTest
private class PartnerSignupReconsentController_Test {

    @testSetup static void testPartnerRequests() {

        for(integer i =0 ; i<3 ; i++){
            Partner_T_C_Master__c rec = new Partner_T_C_Master__c();
            
            rec.isActive__c  = true;
            rec.Apply_Date__c = date.today();
            rec.T_C_Use__c = 'Sign Up';
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
            Username = 'test1232dffs3rwefs@samsung.com.sds.sdspartner',
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

    @isTest
    static void getPartnerTCAgreement_Test() {
        User user = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        Test.startTest();
        PartnerSignupReconsentController.getPartnerTCAgreement(user.Id);
		Test.stopTest();
    }

    @isTest
    static void getReconsentTCList_Test() {
        User user1 = [SELECT Id FROM User WHERE Username LIKE '%sdspartner' LIMIT 1];
        Test.startTest();
        PartnerSignupReconsentController.getReconsentTCList(user1.Id);
		Test.stopTest();
    }

    @isTest
    static void updatePartnerTCAgreement_Test() {
        Test.startTest();
        List<Partner_T_C_Master__c> pT1 = new list<Partner_T_C_Master__c>();

        pT1 = [select id, name, T_C_Detail__c , T_C_Type__c, T_C_Use__c from Partner_T_C_Master__c where isActive__c =true and T_C_Use__c = 'Sign Up'];
        List<String> pTIds1 = new list<String>();
        String tempId = '';
        for(Partner_T_C_Master__c pp : pT1){
            tempId = pp.id;
            pTIds1.add(pp.id);
        }
        // String Idrec = tempId;//'a1W0w000000TNb8EAG';


        Partner_T_C_Master__c ptcmaster = new Partner_T_C_Master__c();
        ptcmaster.Name = '서비스약관동의';
        ptcmaster.isActive__c = true;
        ptcmaster.T_C_Use__c = 'Sign Up';
        ptcmaster.Apply_Date__c = Date.today();
        ptcmaster.isMandatory__c = true;
        ptcmaster.T_C_Detail__c = 'sdf';
        ptcmaster.T_C_Type__c = 'Terms of Service';
        insert ptcmaster;

        Partner_Signup_Request__c psr = new Partner_Signup_Request__c();
        psr.Company_Name__c = 'cName';
        psr.First_Name__c = 'fname';
        psr.Last_Name__c = 'lname';
        psr.User_Email__c = 'emailEntered@emailentered.com';
        psr.Partner_ID__c = 'emailEntered@emailentered.com.sdspartner';
        psr.Mobile_Phone__c = '010-1234-1234';
        psr.status__c = 'Requested';
        psr.Create_Date__c = Date.today();

        insert psr;


        Partner_Signup_T_C_Agreement__c ps = new Partner_Signup_T_C_Agreement__c();
        ps.isAgree__c = true;
        ps.Partner_Signup__c = psr.id;
        ps.Agreement_Date__c = Date.today();
        ps.Partner_T_C_Name__c = ptcmaster.id;
        insert ps;

        PartnerSignupReconsentController.updatePartnerTCAgreement(psr.id, pTIds1);
		Test.stopTest();
    }
}