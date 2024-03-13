/**
 * @description       : OpportunitySearchController Test
 * @author            : seonju.jin@dkbmc.com
 * @group             : 
 * @last modified on  : 2023-02-15
 * @last modified by  : anish.jain@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                 Modification
 * 1.0   2020-11-12   seonju.jin@dkbmc.com   Initial Version
 * 1.1   2023-02-15   anish.jain@partner.samsung.com   Test class coverage for data mismatch for TA checkbox and other scenarios (My Sales - 125)
**/
@isTest
public class OpportunitySearchControllerAdminTest {
    static User u;
    static Company__c comp;
    static Account acc;
    static Account mdgAcc;
    static Master_Service__c svc;
    static Master_Service__c svc1;  //Added by Anish - v 1.1
    static Master_Solution__c sol;
    static CostCenter__c cc;
    static Opportunity opp;
    static Opportunity opp1;
    static Service__c opp_svc;
    static Solution__c opp_sol;
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
            ValidityStartDate__c = Date.today().AddDays(-11), //Added by Anish - v 1.1
            ValidityEndDate__c = Date.today().AddDays(11) //Added by Anish - v 1.1
        );
        insert sol;

        cc = new CostCenter__c(
            Name = 'Test Cost Center', 
            Company__c = comp.Id,
            CompanyCode__c = 'T100', 
            Text2__c = '테스트'
        );
        insert cc;

        rcdType = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'Opportunity' AND Name = 'HQ'];

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
            CloseDate = Date.today()
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
            CloseDate = Date.today()
        );
        insert opp1;

        opp_svc = new Service__c(
            Service__c = svc.Id, 
            Opportunity__c = opp.Id,
            DeletionFlag__c = false,  //Added by Anish - v 1.1
            TechAttribute__c = true, //Added by Anish - v 1.1
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

        OpportunitySearchControllerAdmin.customObject custom_comp = new OpportunitySearchControllerAdmin.customObject();
        custom_comp.Id = comp.Id;
        custom_comp.Name = comp.Name;

        OpportunitySearchControllerAdmin.customObject custom_acc = new OpportunitySearchControllerAdmin.customObject();
        custom_acc.Id = mdgAcc.Id;
        custom_acc.Name = mdgAcc.Name;

        OpportunitySearchControllerAdmin.customObject custom_originAcc = new OpportunitySearchControllerAdmin.customObject();
        custom_originAcc.Id = mdgAcc.Id;
        custom_originAcc.Name = mdgAcc.Name;
        
        OpportunitySearchControllerAdmin.customObject custom_owner = new OpportunitySearchControllerAdmin.customObject();
        custom_owner.Id = u.Id;
        custom_owner.Name = u.Name;
        
        OpportunitySearchControllerAdmin.customObject custom_sDept = new OpportunitySearchControllerAdmin.customObject();
        custom_sDept.Id = cc.Id;
        custom_sDept.Name = cc.Name;
        
        OpportunitySearchControllerAdmin.customObject custom_dDept = new OpportunitySearchControllerAdmin.customObject();
        custom_dDept.Id = cc.Id;
        custom_dDept.Name = cc.Name;

        OpportunitySearchControllerAdmin.selectedValue sv = new OpportunitySearchControllerAdmin.selectedValue();
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
        
        //Added by Anish - v 1.1
        OpportunitySearchControllerAdmin.selectedValue sv1 = new OpportunitySearchControllerAdmin.selectedValue();
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
        
        OpportunitySearchControllerAdmin.defaultSetting();
        OpportunitySearchControllerAdmin.getSolutionList(svc.Id, false);
        OpportunitySearchControllerAdmin.getSolutionList(svc.Id, true);
        OpportunitySearchControllerAdmin.getOpptyList('20', '', 'Next', JSON.serialize(sv), true, true, true, true, true, true);  //Added by Anish - v 1.1
        OpportunitySearchControllerAdmin.getOpptyList('20', '', 'Prev', JSON.serialize(sv1), true, true, true, true, true, true);  //Added by Anish - v 1.1
        OpportunitySearchControllerAdmin.getOpptyList('20', '', 'Next', JSON.serialize(sv), true, true, false, false, false, false);  //Added by Anish - v 1.1
        OpportunitySearchControllerAdmin.getOpptyList('20', '', 'Prev', JSON.serialize(sv1), true, false, true, false, false, false);  //Added by Anish - v 1.1
        OpportunitySearchControllerAdmin.getOpptyList('20', '', 'Next', JSON.serialize(sv), true, false, false, true, false, false);  //Added by Anish - v 1.1
        OpportunitySearchControllerAdmin.getOpptyList('20', '', 'Prev', JSON.serialize(sv1), true, false, false, false, true, false);  //Added by Anish - v 1.1
        OpportunitySearchControllerAdmin.getOpptyList('20', '', 'Next', JSON.serialize(sv), true, false, false, false, false, true);  //Added by Anish - v 1.1
        //OpportunitySearchControllerAdmin.getOpptyList('20', '', 'Next', JSON.serialize(sv), true, true, true, false, false, false);  //Added by Anish - v 1.1
        OpportunitySearchControllerAdmin.generateHTML(JSON.serialize(sv));
        OpportunitySearchControllerAdmin.getIBOpptyIdSet('true','true','true','true','true','true');
        OpportunitySearchControllerAdmin.getIBOpptyIdSet('true','true','true','true','true','false');
        OpportunitySearchControllerAdmin.getIBOpptyIdSet('false','false','false','false','false','false');
        OpportunitySearchControllerAdmin.getIBOpptyIdSet('false','false','false','false','false','true');
        OpportunitySearchControllerAdmin.getIBOpptyIdSet('true','false','false','false','false','true');
        OpportunitySearchControllerAdmin.getIBOpptyIdSet('true','true','false','false','false','true');
        OpportunitySearchControllerAdmin.getIBOpptyIdSet('false','true','false','false','false','true');
        OpportunitySearchControllerAdmin.getIBOpptyIdSet('true','false','true','false','false','true');
        OpportunitySearchControllerAdmin.getIBOpptyIdSet('true','true','true','false','false','true');
        OpportunitySearchControllerAdmin.getIBOpptyIdSet('false','true','false','false','false','true');
        OpportunitySearchControllerAdmin.getIBOpptyIdSet('false','false','true','false','false','true');
        OpportunitySearchControllerAdmin.getIBOpptyIdSet('true','false','false','true','false','true');
        OpportunitySearchControllerAdmin.getIBOpptyIdSet('true','true','false','true','false','true');
        OpportunitySearchControllerAdmin.getIBOpptyIdSet('false','true','false','true','false','true');
        OpportunitySearchControllerAdmin.getIBOpptyIdSet('false','false','true','true','false','true');
        OpportunitySearchControllerAdmin.getIBOpptyIdSet('true','false','true','true','false','true');
        OpportunitySearchControllerAdmin.getIBOpptyIdSet('false','true','true','true','false','true');
        OpportunitySearchControllerAdmin.getIBOpptyIdSet('true','true','true','true','false','true');
       // OpportunitySearchControllerAdmin.getIBOpptyIdSet('false','false','true','true','false','true');
       // OpportunitySearchControllerAdmin.getIBOpptyIdSet('false','false','false','false','true','true');
       // OpportunitySearchController.getConfirmMSG(oppty.Id,null); //Added by Anish - v 1.1
       // OpportunitySearchController.bulkExcelDown(JSON.serialize(sv)); //Added by Anish - v 1.1
            
        PageReference opptyExcelPage = Page.OpportunityExcel;
        Test.setCurrentPage(opptyExcelPage);

        // Put Id into the current page Parameters
        ApexPages.currentPage().getParameters().put('searchKeywords', JSON.serialize(sv));

        OpportunitySearchControllerAdmin osc = new OpportunitySearchControllerAdmin();
        osc.getOpptyListAll();

        Test.stopTest();
    }
}