/**
 * @description       : 
 * @author            : Junghwa.Kim@dkbmc.com
 * @group             : 
 * @last modified on  : 2021-10-05
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                  Modification
 * 1.0   11-11-2020   Junghwa.Kim@dkbmc.com   Initial Version
**/
@isTest
public class LeadToSalesLeadsModalController_Test {
    static User admin;
    static User salesRep;
    static Employee__c emp;
    static CostCenter__c costCenter;
    static Lead lead;

    static{
        Profile profile_Admin =  [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = '시스템 관리자' limit 1];
        admin = new User(
            Alias = 'Admin'
            , Email = 'Admin@leadconvert.com'
            , EmailEncodingKey = 'UTF-8'
            , LastName = 'Admin'
            , LanguageLocaleKey = 'en_US'
            , LocaleSidKey = 'en_US'
            , TimeZoneSidKey = 'Asia/Seoul'
            , ProfileId = profile_Admin.Id
            , UserName = 'Admin@leadconvert.com'
            , FederationIdentifier = 'Admin_EPID_1'
        );
        insert admin;

        Profile profile_SalesRep =  [SELECT Id FROM Profile WHERE Name = 'Sales Rep.(HQ)' limit 1];
        salesRep = new User(
            Alias = 'SalesRep'
            , Email = 'SalesRep@leadconvert.com'
            , EmailEncodingKey = 'UTF-8'
            , LastName = 'SalesRep'
            , LanguageLocaleKey = 'en_US'
            , LocaleSidKey = 'en_US'
            , TimeZoneSidKey = 'Asia/Seoul'
            , ProfileId = profile_SalesRep.Id
            , UserName = 'SalesRep@leadconvert.com'
            , FederationIdentifier = 'SalesRep_EPID_1'
        );
        insert salesRep;

        emp = new Employee__c(
            Name = 'SalesRep'
            , EvKostl__c = 'T100-12345'
            , EvUniqID__c = 'SalesRep_EPID_1'
            , EvSapBukrs__c = 'T100'
        );
        insert emp;

        costCenter = new CostCenter__c(
            CompanyCode__c = 'T100'
            , CostCenter__c = 'T100-12345'
            , ZZCheck__c = true
        );
        insert costCenter;

        lead = new Lead(
            FirstName = 'Fitst Name'
            , LastName = 'Last Name'
            , Status = 'In Process'
            , LeadType__c = '01'
            , Company = 'Test Company'
        );
        insert lead;
    }

    @isTest
    public static void leadCheck_Test_1() {
        System.runAs(admin){
            LeadToSalesLeadsModalController.leadCheck(lead.Id);
        }
    }

    @isTest
    public static void getFieldLabel_Test_1() {
        System.runAs(admin){
            LeadToSalesLeadsModalController.getFieldLabel(lead.Id);
        }
    }

    @isTest
    public static void convertLead_Test_1() {
        System.runAs(admin){
            LeadToSalesLeadsModalController.convertLead(lead.Id, salesRep.Id);
        }
    }
}