/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2021-10-05
 * @last modified by  : younghoon.kim@dkbmc.com
**/
@isTest
public class LeadTrigger_Test {
    static TriggerSwitch__c ts;
    static User salesRep1;
    static User salesRep2;
    static Employee__c emp1;
    static Employee__c emp2;
    static Lead lead1;
    static Lead lead2;

    static{
        ts = new TriggerSwitch__c(
            Migration__c = false
        );
        insert ts;

        List<User> userList = new List<User>();
        Profile profile_SalesRep =  [SELECT Id FROM Profile WHERE Name = 'Sales Rep.(HQ)' limit 1];
        salesRep1 = new User(
            Alias = 'SR1'
            , Email = 'SalesRep1@leadTrigger.com'
            , EmailEncodingKey = 'UTF-8'
            , LastName = 'SalesRep1'
            , LanguageLocaleKey = 'en_US'
            , LocaleSidKey = 'en_US'
            , TimeZoneSidKey = 'Asia/Seoul'
            , ProfileId = profile_SalesRep.Id
            , UserName = 'SalesRep1@leadTrigger.com'
            , FederationIdentifier = 'SalesRep1_EPID_1'
        );
        userList.add(salesRep1);

        salesRep2 = new User(
            Alias = 'SR2'
            , Email = 'SalesRep2@leadTrigger.com'
            , EmailEncodingKey = 'UTF-8'
            , LastName = 'SalesRep2'
            , LanguageLocaleKey = 'en_US'
            , LocaleSidKey = 'en_US'
            , TimeZoneSidKey = 'Asia/Seoul'
            , ProfileId = profile_SalesRep.Id
            , UserName = 'SalesRep2@leadTrigger.com'
            , FederationIdentifier = 'SalesRep2_EPID_1'
        );
        userList.add(salesRep2);
        insert userList;

        List<Employee__c> empList = new List<Employee__c>();
        emp1 = new Employee__c(
            Name = 'SalesRep1'
            , EvKostl__c = 'T100-12345'
            , EvUniqID__c = 'SalesRep1_EPID_1'
            , EvSapBukrs__c = 'T100'
            , EvMailAddr__c = 'SalesRep1@leadTrigger.com'
        );
        empList.add(emp1);

        emp2 = new Employee__c(
            Name = 'SalesRep2'
            , EvKostl__c = 'T100-12345'
            , EvUniqID__c = 'SalesRep2_EPID_1'
            , EvSapBukrs__c = 'T100'
            , EvMailAddr__c = 'SalesRep2@leadTrigger.com'
        );
        empList.add(emp2);
        insert empList;

        lead1 = new Lead(
            FirstName = 'Fitst Name'
            , LastName = 'Last Name'
            , Status = 'In Process'
            , LeadType__c = '04'
            , Company = 'Test Company'
        );

        lead2 = new Lead(
            FirstName = 'Fitst Name'
            , LastName = 'Last Name'
            , Status = 'Close'
            , LeadType__c = '04'
            , Company = 'Test Company'
        );
    }

    @isTest
    public static void lead_Test_1() {
        insert lead1;
    }

    @isTest
    public static void lead_Test_2() {
        System.runAs(salesRep1){
            insert lead2;
    
            lead2.Status = 'In Process';
            lead2.OwnerId = salesRep2.Id;
            update lead2;
        }
    }
}