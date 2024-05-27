/**
* @description       : Test Class for OpportunitySearchControllerLogi  
* @author            : waris.m@samsung.com
* @group             : 
* @last modified on  : 2024-04-23
* @last modified by  : waris.m@samsung.com 
* Modifications Log 
* Ver   Date         Author                      Modification
* 1.0   2024-04-23   waris.m@samsung.com   Initial Version for MYSALES-472
**/
@isTest
public class OpportunitySearchControllerLogiTest {
    static User u;
    static Company__c comp;
    static Account acc;
    static Account mdgAcc;
    static Master_Service__c svc;
    static Master_Service__c svc1; 
    static Master_Solution__c sol;
    static CostCenter__c cc;
    static Opportunity opp;
    static Opportunity opp1;
    static Service__c opp_svc;
    static Solution__c opp_sol;
    static Organization__c org;
    static{
    TriggerSwitch__c trSwitch_default = new TriggerSwitch__c(
            All__c = false,
            Opportunity__c = false,
            OpportunityActivity__c = false
        );
        insert trSwitch_default;
    }
    
    static RecordType rcdType;

    static{
        user admin = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		system.runAs (admin) {
			Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = '시스템 관리자'];
			list<User> lu = new list<User>();
			u = new User(Alias = 'standt1', Email='user0001@samsung.com', 
						EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
						LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Seoul', 
						UserName='user0001@samsung.com');
			insert u;
        }

        comp = new Company__c(
            Name = 'Test Company',
            CompanyCode__c = 'T100'
        );
        insert comp;

        acc = new Account(
            Name = 'Test Account',
            AccountNumber = 'A1234567',
            mDomesticForeign__c = '20',
            mCountry__c = 'US'
        );
        insert acc;
        
        RecordType mdgRcdType = [SELECT Id, Name, DeveloperName, SobjectType, IsActive FROM RecordType WHERE SobjectType = 'Account' AND IsActive = TRUE AND Name LIKE '%MDG%'];
        mdgAcc = new Account(
			Name = 'Test MDG Account',
            AccountNumber = 'M1234567',
            mDomesticForeign__c = '20',
            mCountry__c = 'US',
            RecordTypeId = mdgRcdType.Id,
            MDGCheck__c = true
       	);
        insert mdgAcc;

        svc = new Master_Service__c(
            //Name = 'Test Service 1',
            Name = 'ERP',
            //Code__c = '20000001',
            Use__c = true,
            ValidityStartDate__c = Date.today(),
            ValidityEndDate__c = Date.today(),
            Code__c = '20000028'
            
        );
        insert svc;
        
        //Added by Anish - v 1.1
        svc1 = new Master_Service__c(
            Name = 'Test Service 1',
            Code__c = '20000002',
            Use__c = true,
            ValidityStartDate__c = Date.today().AddDays(-11),
            ValidityEndDate__c = Date.today().AddDays(11)
        );
        insert svc1;

        sol = new Master_Solution__c(
            Name = 'Test Solution', 
            Code__c = '30000001', 
            Service__c = svc.Id,
            Use__c = true,
            ValidityStartDate__c = Date.today().AddDays(-11), 
            ValidityEndDate__c = Date.today().AddDays(11) 
        );
        insert sol;

        cc = new CostCenter__c(
            Name = 'Test Cost Center', 
            Company__c = comp.Id,
            CompanyCode__c = 'T100', 
            Text2__c = '테스트'
        );
        insert cc;

         org = new Organization__c(name='SDSAE');
        insert org;

        rcdType = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'Opportunity' AND Name = 'Logistics'];

        opp = new Opportunity(
            Name = 'Test Opportunity', 
            RecordTypeId = rcdType.Id,
            OpportunityStatus__c = 'E0002', 
            CspMspType__c = 'CSP',
            StageName = 'Z01', 
            CMBizType__c = 'CSP_SCP',
            AccountId = mdgAcc.Id, 
            cOriginAcc__c = mdgAcc.Id, 
            OwnerId = u.Id, 
            SalesDepartment__c = cc.Id, 
            cPrimarySalesDepartment__c = cc.Id, 
            BusinessType__c = 'TI', 
            DealBreak__c = false, 
            CloseDate = Date.today(),
            SalesOrganization__c=Org.Id,
            DeliveryOrganization__c=Org.Id
        );
        insert opp;
        
        opp1 = new Opportunity(
            Name = 'Test Opportunity', 
            RecordTypeId = rcdType.Id,
            OpportunityStatus__c = 'E0002', 
            CspMspType__c = 'MSP',
            StageName = 'Z01', 
            AccountId = mdgAcc.Id, 
            cOriginAcc__c = mdgAcc.Id, 
            OwnerId = u.Id, 
            SalesDepartment__c = cc.Id, 
            cPrimarySalesDepartment__c = cc.Id, 
            BusinessType__c = 'TI', 
            DealBreak__c = false, 
            CloseDate = Date.today(),
            SalesOrganization__c=Org.Id,
            DeliveryOrganization__c=Org.Id
        );
        insert opp1;

        opp_svc = new Service__c(
            Service__c = svc.Id, 
            Opportunity__c = opp.Id,
            DeletionFlag__c = false,  
            TechAttribute__c = true, 
            sendSAP__c = true
        );
        insert opp_svc;

        opp_sol = new Solution__c(
            Service__c = opp_svc.Id,
            Solution__c = sol.Id, 
            Opportunity__c = opp.Id
        );
        insert opp_sol;
    }

    @isTest static void test_method_01(){
        Test.startTest();
        Opportunity oppty = [SELECT Id, Name, OpportunityCode__c, OpportunityStatus__c, StageName, CompanyCode__c, AccountId, Account.Name, Account.AccountNumber, cOriginAcc__c, cOriginAcc__r.Name, cOriginAcc__r.AccountNumber, BusinessLevel__c, OwnerId, Owner.Name, SalesDivision__c, SalesDepartment__c, SalesDepartment__r.Name, cPrimaryDeliveryDivision__c, cPrimarySalesDepartment__c, cPrimarySalesDepartment__r.Name, Collaboration__c, GroupInternal__c, KoreaDomestic__c, BusinessType__c, DealBreak__c, CloseDate FROM Opportunity WHERE Id =: opp.Id];
        System.debug('oppty : ' + oppty);

        OpportunitySearchControllerLogi.customObject custom_comp = new OpportunitySearchControllerLogi.customObject();
        custom_comp.Id = comp.Id;
        custom_comp.Name = comp.Name;

        OpportunitySearchControllerLogi.customObject custom_acc = new OpportunitySearchControllerLogi.customObject();
        custom_acc.Id = mdgAcc.Id;
        custom_acc.Name = mdgAcc.Name;

        OpportunitySearchControllerLogi.customObject custom_originAcc = new OpportunitySearchControllerLogi.customObject();
        custom_originAcc.Id = mdgAcc.Id;
        custom_originAcc.Name = mdgAcc.Name;
        
        OpportunitySearchControllerLogi.customObject custom_owner = new OpportunitySearchControllerLogi.customObject();
        custom_owner.Id = u.Id;
        custom_owner.Name = u.Name;
        
        OpportunitySearchControllerLogi.customObject custom_sDept = new OpportunitySearchControllerLogi.customObject();
        custom_sDept.Id = cc.Id;
        custom_sDept.Name = cc.Name;
        
        OpportunitySearchControllerLogi.customObject custom_dDept = new OpportunitySearchControllerLogi.customObject();
        custom_dDept.Id = cc.Id;
        custom_dDept.Name = cc.Name;

        OpportunitySearchControllerLogi.customObject SalesOrganization = new OpportunitySearchControllerLogi.customObject();
        SalesOrganization.Id = org.Id;
        SalesOrganization.Name = org.Name; 

         OpportunitySearchControllerLogi.customObject DeliveryOrganization = new OpportunitySearchControllerLogi.customObject();
        DeliveryOrganization.Id = org.Id;
        DeliveryOrganization.Name = org.Name;

        OpportunitySearchControllerLogi.selectedValue sv = new OpportunitySearchControllerLogi.selectedValue();
        sv.Company = custom_comp;
        sv.Account = custom_acc;
        sv.OriginAccount = custom_originAcc;
        sv.BOName = '';
        sv.Collaboration = 'false';
        sv.GroupInternal = 'false';
        sv.Service = svc.Id;
        sv.Solution = sol.Id;
        sv.Status = 'E0002';
        sv.StartDate = Date.today();
        sv.EndDate = Date.today();
        sv.Owner = custom_owner;
        sv.OpptyCode = '';
        sv.SalesDept = custom_sDept;
        sv.PrimarySalesDept = custom_dDept;
        sv.RecordType = rcdType.Id;
        sv.SalesOrganization=SalesOrganization;
        sv.DeliveryOrganization=DeliveryOrganization;
        sv.lbsExceptionType='';
        sv.bizDevelopment='';
        sv.opportunityType='';
        sv.customerType='';

        
        
        
        OpportunitySearchControllerLogi.selectedValue sv1 = new OpportunitySearchControllerLogi.selectedValue();
        sv1.Company = custom_comp;
        sv1.Account = custom_acc;
        sv1.OriginAccount = custom_originAcc;
        sv1.BOName = '';
        sv1.Collaboration = 'false';
        sv1.GroupInternal = 'false';
        sv1.Service = '';
        sv1.Solution = '';
        sv1.Status = 'E0002';
        sv1.StartDate = Date.today();
        sv1.EndDate = Date.today();
        sv1.Owner = custom_owner;
        sv1.OpptyCode = '';
        sv1.SalesDept = custom_sDept;
        sv1.PrimarySalesDept = custom_dDept;
        sv1.RecordType = rcdType.Id;
        sv1.SalesOrganization=SalesOrganization;
        sv1.DeliveryOrganization=DeliveryOrganization;
        sv1.lbsExceptionType='';
        sv1.bizDevelopment='';
        sv1.opportunityType='';
        sv1.customerType='';
        
        OpportunitySearchControllerLogi.defaultSetting();
   
        OpportunitySearchControllerLogi.getOpptyList('20', '', 'Next', JSON.serialize(sv), true);  
        OpportunitySearchControllerLogi.getOpptyList('20', '', 'Prev', JSON.serialize(sv1), true);  
        OpportunitySearchControllerLogi.getOpptyList('20', '', 'Next', JSON.serialize(sv), true);  
        OpportunitySearchControllerLogi.getOpptyList('20', '', 'Prev', JSON.serialize(sv1), true);  
        OpportunitySearchControllerLogi.getOpptyList('20', '', 'Next', JSON.serialize(sv), true);  
        OpportunitySearchControllerLogi.getOpptyList('20', '', 'Prev', JSON.serialize(sv1), true);  
        OpportunitySearchControllerLogi.getOpptyList('20', '', 'Next', JSON.serialize(sv), true);  
      
            
        PageReference opptyExcelPage = Page.OpportunityExcelLogistic;
        Test.setCurrentPage(opptyExcelPage);

        // Put Id into the current page Parameters
        ApexPages.currentPage().getParameters().put('searchKeywords', JSON.serialize(sv));

        OpportunitySearchControllerLogi osc = new OpportunitySearchControllerLogi();
        osc.getOpptyListAll();

        Test.stopTest();
    }
}