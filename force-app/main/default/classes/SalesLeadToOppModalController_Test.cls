/**
 * @description       : 
 * @author            : Junghwa.Kim@dkbmc.com
 * @group             : 
 * @last modified on  : 2021-10-18
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                  Modification
 * 1.0   11-11-2020   Junghwa.Kim@dkbmc.com   Initial Version
**/
@isTest(SeeAllData = false)
public with sharing class SalesLeadToOppModalController_Test {
    static Lead l;
   	static Sales_Lead__c sl;
   	static Sales_Lead__c sl2;
   	static Sales_Lead__c sl3;
    static Account acc;
    static Employee__c emp;
    static User adminUser;
    static User logiUser;
    static Profile adminpf;
    static Profile logipf;
    static MasterActivity__c ma;
    static OpptyCodeSetting__c ocs;
    static CostCenter__c costCenter;
    static {
        adminpf =  [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = '시스템 관리자' limit 1];
        logipf = [SELECT Id FROM Profile WHERE Name Like '%Logi%' LIMIT 1];   
        
        adminUser = new User(
            Alias = 'testUser'
            , Email = 'admin11User@test.com.test'
            , EmailEncodingKey = 'UTF-8'
            , LastName = 'Testing'
            , LanguageLocaleKey = 'en_US'
            , LocaleSidKey = 'en_US'
            , EmployeeNumber = 'AC100000'
            , TimeZoneSidKey = 'Asia/Seoul'
            , ProfileId = adminpf.Id
            , UserName = 'admin11User@test.com.test'
            , FederationIdentifier = 'epId1'
        );
                                
        insert adminUser;
        logiUser = new User(
            Alias = 'testUser'
            , Email = 'logi12User@test.com.test'
            , EmailEncodingKey = 'UTF-8'
            , LastName = 'Testing'
            , LanguageLocaleKey = 'en_US'
            , LocaleSidKey = 'en_US'
            , EmployeeNumber = 'AC100000'
            , TimeZoneSidKey = 'Asia/Seoul'
            , ProfileId = adminpf.Id
            , UserName = 'logi12User@test.com.test'
            , FederationIdentifier = 'epId2'
        );
                                
        insert logiUser;

        emp = new Employee__c(
            Name = 'logi12User',
            EvMailAddr__c = 'logi12User' + '@samsung.com',
            EvUniqID__c = 'epId2'            
        );
        insert emp;

        acc = new Account(
            Name = 'testAccount',
            MDGCheck__c = true
        );
        
        insert acc;
        
    	l = new Lead(LastName = 'TestLead', 
                     PersonalInfoAgreementExpireDate__c = Date.today(), 
                     PersonalInfoAgreement__c = true, 
                     Company='TestCompany');
        insert l;
        costCenter = new CostCenter__c(CostCenterName__c = 'Test1', Name ='Test1');
        insert costCenter;
        
        List<Sales_Lead__c> slList = new List<Sales_Lead__c>();
        sl = new Sales_Lead__c(
            Name = 'TestSalesLead', 
            LeadStage__c = 'Hot',
            LeadStatus__c = 'In Process',
            Lead__c = L.Id, 
            Amount__c = 5000, 
            CloseDate__c = Date.today().addDays(1),  
            RevenueEndDate__c = Date.today().addDays(3), 
            RevenueStartDate__c = Date.today().addDays(2),
            Budget__c = true,
            Authority__c = true,
            LeadChannel__c = 'Marketing Lead Converted',
            Internal_External__c = 'Internal',
            SalesDepartment__c = costCenter.Id,
            CustomerContactDate__c = DateTime.now()
        );
        insert sl;

        sl2 = new Sales_Lead__c(
            Name = 'TestSalesLead', 
            LeadStage__c = 'Warm',
            LeadStatus__c = 'In Process',
            Amount__c = 5000,
            Lead__c = L.Id, 
            RevenueEndDate__c = Date.today().addDays(3), 
            RevenueStartDate__c = Date.today().addDays(2),
            LeadChannel__c = 'Marketing Lead Converted',
            Internal_External__c = 'Internal'
        );
        insert sl2;

        sl3 = new Sales_Lead__c(
            Name = 'TestSalesLead', 
            LeadStage__c = 'Hot',
            LeadStatus__c = 'In Process',
            Amount__c = 5000, 
            AccountId__c = acc.Id,
            CloseDate__c = Date.today().addDays(1),  
            RevenueEndDate__c = Date.today().addDays(3), 
            RevenueStartDate__c = Date.today().addDays(2),
            Budget__c = true,
            Authority__c = true,
            Internal_External__c = 'Internal',
            SalesDepartment__c = costCenter.Id
        );
        insert sl3;
        //insert slList;

        L.SalesLeadID__c = sl.Id;
        update L;
        
        ma = new MasterActivity__c(TransactionName__c = Utils.getPicklistOptionType('Opportunity_Activity__c','TransactionName__c')[0].get('value'), Stage__c = 'Z01');
        insert ma;

        ocs = new OpptyCodeSetting__c(Name = 'test', CodeSetting__c  = false);
        insert ocs;
    }
    @isTest
    public static void SalesLeadToOppModalController_Test() {
        try{
            SalesLeadToOppModalController.ReturnWrapper rw = SalesLeadToOppModalController.getOppLabel(String.valueOf(sl.Id));
            //String recordId, List<Map<String, String>> opplist
            List<Map<String, String>> opplist1 = new List<Map<String, String>>();
            List<Map<String, String>> opplist2 = new List<Map<String, String>>();
            RecordType rtlist = [SELECT Id,Name, DeveloperName FROM RecordType WHERE sObjectType='Opportunity' AND DeveloperName = 'Logistics' LIMIT 1];
            for(Map<String, String> r : rw.sflist){
                Map<String, String> maps = new Map<String, String>();
                maps.put('Api', r.get('oppApi'));
                maps.put('Value', r.get('oppValue'));
                opplist1.add(maps);
                opplist2.add(maps);
            }
            Map<String, String> recordtype = new Map<String, String>();
            recordtype.put('Api', 'RecordTypeId');
            recordtype.put('Value', String.valueOf(rtlist.Id));
            
            Map<String, String> OwnerMap1 = new Map<String, String>();
            Map<String, String> OwnerMap2 = new Map<String, String>();
            OwnerMap1.put('Api', 'OwnerId');
            OwnerMap1.put('Value', String.valueOf(logiUser.Id));
            opplist1.add(OwnerMap1);
            System.debug('convertOpp 1 ');
            SalesLeadToOppModalController.convertOpp(String.valueOf(sl.Id), opplist1);
            SalesLeadToOppModalController.convertOpp(String.valueOf(sl3.Id), opplist1);
            OwnerMap2.put('Api', 'OwnerId');
            OwnerMap2.put('Value', String.valueOf(adminUser.Id));
            opplist2.add(OwnerMap2);
            System.debug('convertOpp 2 ');
            SalesLeadToOppModalController.convertOpp(String.valueOf(sl.Id), opplist2);
        } catch(Exception e){
            System.debug(e);
        }
        SalesLeadToOppModalController.getRecordType(logipf.Id, logiUser.Id);
        SalesLeadToOppModalController.isConverted(String.valueOf(sl.Id));	
        SalesLeadToOppModalController.isConverted(String.valueOf(sl2.Id));	
    }
}