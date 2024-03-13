/**
 * @description       : Test class of BOReportCtrl 
 * @author            : d.ashish@samsung.com
 * @group             : 
 * @last modified on  : 2023-07-05
 * @last modified by  : d.ashish@samsung.com
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   2023-07-05   d.ashish@samsung.com   Initial Version
**/
@isTest
public class BOReportCtrl_Test {
    
    @isTest
    public static void BOReportTest(){
        Account acc = new Account( 
            Name = 'Test Account',
            MDGCheck__c = true
        );
        insert acc;
        Id logiRecId =  Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('Logistics').getRecordTypeId();
   
        Organization__c org = new Organization__c(name='SDSAE');
        insert org;
       Opportunity opptyLogi = new Opportunity(
            Name = 'Test Opportunity',
            RecordTypeId = logiRecId,
           SalesOrganization__c = org.id,
           amount=1356,
            //ProposalPM_User__c = migUser.Id, //Anish v-1.2
            MigData__c = True,  //Anish v-1.2
            StageName = OpportunityActivityHelper.OPP_STAGE_IDENTIFIED,
            CloseDate = Date.today(),
            AccountId = acc.Id,
            cLeadID__c = NULL
        );
insert opptyLogi;
        
        Event myevent= new event(whatid = opptyLogi.id,startdatetime = system.now(),DurationInMinutes =20);
        insert myevent;
        
        Event myeventlastWeek= new event(whatid = opptyLogi.id,startdatetime = system.now(),DurationInMinutes =20);
        insert myeventlastWeek;
        DateTime testCreatedDate = DateTime.now().addDays(-7);

        Test.setCreatedDate(myeventlastWeek.id, testCreatedDate);
		Test.startTest();        
        BOReportCtrl obj= new BOReportCtrl();
        obj.orgName= 'SDSAE';
        obj.runcode();
        BOReportCtrl obj1= new BOReportCtrl();
        obj1.orgName= 'SDSEG';
        obj1.runcode();
        BOReportCtrl obj2= new BOReportCtrl();
        obj2.orgName= 'SDSI-CNL';
        obj2.runcode();
        BOReportCtrl obj3= new BOReportCtrl();
        obj3.orgName= 'SDSI-NDL';
        obj3.runcode();
        BOReportCtrl obj4= new BOReportCtrl();
        obj4.orgName= 'SDSTR';
        obj4.runcode();
        BOReportCtrl obj5= new BOReportCtrl();
        obj5.orgName= 'SDSZA';
        obj5.runcode();
        obj5.getOrgName();
                obj5.setOrgName('SDSZA');
        Test.stopTest();
        
    }
}