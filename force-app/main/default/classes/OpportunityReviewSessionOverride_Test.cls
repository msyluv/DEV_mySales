/**
* @description       : Test class of OpportunityReviewSessionOverride
* @author            : akash.g@samsung.com
* @group             : 
* @last modified on  : 2024-05-09
* @last modified by  : akash.g@samsung.com 
* Modifications Log 
* Ver   Date         Author                              Modification
* 1.0   2024-05-09   akash.g@samsung.com                 Initial Version(MYSALES-499)
**/
@isTest (SeeAllData = false)
public class OpportunityReviewSessionOverride_Test {
    private static Boolean isSandbox = Utils.getIsSandbox();
    
    @isTest
    public static void createOpportunityReviewSessionRecord(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales Rep.(HQ)' ];
        List<user> ulist = new List<user>();
        ulist = [ Select Id , name, Profile.Name,Email from User where Profile.Name = 'Sales Rep.(HQ)'  AND IsActive = true ];
        User u = new User(Alias = '박 재만', Email='Test@Test.com', 
                          EmailEncodingKey='UTF-8', LastName='박 재만', FirstName='박 재만', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Seoul', 
                          UserName='user0001@samsung.com' ,IsActive = true);
        insert u;
        ulist[0].companycode__c = 'T100';
        update ulist;
        Id HQRecId =  Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('HQ').getRecordTypeId(); //Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('HQ').getRecordTypeId();
        
        Account acc = new Account( 
            Name = 'Test Account',
            MDGCheck__c = true,
            mDomesticForeign__c = '20'
        );
        insert acc;
        DateTime dt = DateTime.now().addDays(-7);
        
        Organization__c org = new Organization__c(name='SDSAE');
        insert org;
        Opportunity opptyHQ1 = new Opportunity(
            Name = 'Test Opportunity',
            SalesOrganization__c = org.id,
            amount=1356,
            MigData__c = True,  //Anish v-1.2
            CloseDate = Date.today(),
            AccountId = acc.Id,
            cLeadID__c = NULL,
            ownerid = ulist[0].id,
            BO1stRegistrationDate__c = dt,
            StageName = 'Z05'
        );
        
        system.runAs(ulist[0]){
            insert opptyHQ1;
        } 
        OpportunityReviewSession__c oppReview = new OpportunityReviewSession__c();
        oppReview.Name = 'test';
        oppReview.Session_Date__c = date.today();
        oppReview.Session_Result__c = 'testSession';
        oppReview.Note__c = 'Note';
        Insert oppReview;
        OpportunityReviewSessionOverride.createOpportunityReviewSessionRecord('Test',date.today(),'TestNote','TestSessionResult','[{"BoId" :"'+ opptyHQ1.Id+'","Checked" : true}]');
        OpportunityReviewSessionOverride.getListViews();
        OpportunityReviewSessionOverride.updateOpportunityReviewSessionRecord('Test',date.today(),'TestNote','TestSessionResult','[{"BoId" :"'+ opptyHQ1.Id+'","Checked" : true}]',oppReview.Id);
        OpportunityReviewSessionOverride.getExistingReviewSession(oppReview.Id);
        OpportunityReviewSessionOverride.getOpportunityReviewTarget(oppReview.Id);
    }
}