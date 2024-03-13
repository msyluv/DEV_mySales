/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 03-11-2021
 * @last modified by  : woomg@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   01-07-2021   woomg@dkbmc.com   Initial Version
 * 1.1	 07-28-2023	  aditya.r2@samsung.com   MySales-262	Fixed FIELD_CUSTOM_VALIDATION_EXCEPTION error  
**/
@isTest
private class RevenueScheduleController_Test {
    /*static Opportunity oppty;
    static Sales_Lead__c sl;
    static {
        // [Trigger Switch Setting ]
        TriggerSwitch__c profileSwitch = new TriggerSwitch__c(
            All__c = true,
            Opportunity__c = true,
            SetupOwnerId = UserInfo.getProfileId()
        );
        insert profileSwitch;

        RecordType recordId = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND Name = 'HQ' Limit 1];
        
        Account accAct = new Account(Name = 'accTest');

        insert accAct;
        
        CostCenter__c costCenterHQ = new CostCenter__c(
            Name                = '기술전략팀(T100-11331)'
            , CurrencyIsoCode   = 'KRW'
            , CompanyCode__c    = 'T100'
            , CostCenterName__c = '기술전략팀'
            , CostCenter__c     = 'T100-11331'
            , Node1__c          = 'T100'
            , Node2__c          = 'T100SB'
            , Node3__c          = 'T100SB1'
            , Node4__c          = 'T100SB13'
            , Node5__c          = 'T100SB131'            
            , ZZCheck__c        = true
            , Text2__c      = '클라우드서비스사업부'
        );
        insert costCenterHQ;

        oppty = new Opportunity(Name ='Test', RecordTypeId = recordId.Id, AccountId =accAct.Id, CurrencyIsoCode = 'KRW', Amount = 100000,
                                cRevenueStartDate__c = system.today(), cRevenueEndDate__c = System.today().addMonths(10), 
                                CloseDate = System.today().addMonths(10), StageName = 'Z01', cPrimarySalesDepartment__c = costCenterHQ.Id,
            					SalesDepartment__c = costCenterHQ.Id, cOriginAcc__c = accAct.Id, CspMspType__c = 'CSP', 
            					OtherCSP__c = 'CSP1', MSP_Amount__c = 200, cLeadID__c = NULL);
        insert oppty;

        sl = new Sales_Lead__c(Name = 'Test', AccountId__c = accAct.Id, Amount__c = 100000,
                               RevenueStartDate__c = system.today(), RevenueEndDate__c = System.today().addMonths(10),
                               CloseDate__c = System.today().addMonths(10), LeadStage__c = 'Warm');
        insert sl;
    }*/
    
    @testSetup static void setup(){
        TriggerSwitch__c profileSwitch = new TriggerSwitch__c(
            All__c = true,
            Opportunity__c = true,
            SetupOwnerId = UserInfo.getProfileId()
        );
        insert profileSwitch;

        RecordType recordId = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND Name = 'HQ' Limit 1];
        
        Account accAct = new Account(Name = 'accTest', MDGCheck__c = true);

        insert accAct;
        system.debug('Inserted Account : '+ accAct);
        
        CostCenter__c costCenterHQ = new CostCenter__c(
            Name                = '기술전략팀(T100-11331)'
            , CurrencyIsoCode   = 'KRW'
            , CompanyCode__c    = 'T100'
            , CostCenterName__c = '기술전략팀'
            , CostCenter__c     = 'T100-11331'
            , Node1__c          = 'T100'
            , Node2__c          = 'T100SB'
            , Node3__c          = 'T100SB1'
            , Node4__c          = 'T100SB13'
            , Node5__c          = 'T100SB131'            
            , ZZCheck__c        = true
            , Text2__c      = '클라우드서비스사업부'
        );
        insert costCenterHQ;
        System.debug('Inserted CC : '+ costCenterHQ);

        Opportunity oppty = new Opportunity(Name ='Test', RecordTypeId = recordId.Id, AccountId =accAct.Id, CurrencyIsoCode = 'KRW', Amount = 100000,
                                cRevenueStartDate__c = system.today(), cRevenueEndDate__c = System.today().addMonths(13), 
                                CloseDate = System.today().addMonths(13), StageName = 'Z01', cPrimarySalesDepartment__c = costCenterHQ.Id,
            					SalesDepartment__c = costCenterHQ.Id, cOriginAcc__c = accAct.Id, CspMspType__c = 'CSP', 
            					OtherCSP__c = 'CSP1', MSP_Amount__c = 200, cLeadID__c = NULL);
        insert oppty;
        System.debug('Inserted Oppty : '+ oppty);

        Sales_Lead__c sl = new Sales_Lead__c(Name = 'Test', AccountId__c = accAct.Id, Amount__c = 100000,
                               RevenueStartDate__c = system.today(), RevenueEndDate__c = System.today().addMonths(10),
                               CloseDate__c = System.today().addMonths(10), LeadStage__c = 'Warm', Internal_External__c = 'Internal', SalesDepartment__c =costCenterHQ.id);
        insert sl;
        System.debug('Inserted Lead : '+ sl);
    }

    @isTest static void testMethodOne() {
        Test.startTest();
        Opportunity oppty = [Select Id,name from Opportunity Limit 1];
        Sales_Lead__c sl = [Select Id,name from Sales_Lead__c Limit 1];
        list<RevenueScheduleOpportunity__c> lrso = RevenueScheduleController.getOpportunitySchedules(oppty.Id);
        System.debug('testMethodOne lrso : '+ lrso);
        list<RevenueScheduleSalesLead__c> lrss = RevenueScheduleController.getSalesLeadSchedules(sl.Id);
        system.debug(RevenueScheduleController.getOpportunityAmount(oppty.Id));
        system.debug(RevenueScheduleController.getSalesLeadAmount(sl.Id));
        system.debug(RevenueScheduleController.getNewOpportunitySchedules(oppty.Id));
        system.debug(RevenueScheduleController.getNewSalesLeadSchedules(sl.Id));
        system.debug(RevenueScheduleController.saveOpportunitySchedules(oppty.Id, lrso));
        system.debug(RevenueScheduleController.saveSalesLeadSchedules(sl.Id, lrss));
        system.debug(RevenueScheduleController.getOpportunitySchedules(oppty.Id));
        system.debug(RevenueScheduleController.getSalesLeadSchedules(sl.Id));
        system.debug(RevenueScheduleController.convertSalesLead2Oppty(sl.Id, oppty.Id));
		Test.stopTest();
    }

    @isTest static void testMethodTwo() {
        
		Test.startTest();
        Sales_Lead__c sl = [Select Id,name from Sales_Lead__c Limit 1];
        try {
            system.debug(RevenueScheduleController.getOpportunityAmount('@@@@'));
        } catch (Exception e) {
            //
        }
        try {
            system.debug(RevenueScheduleController.getSalesLeadAmount('@@@@'));
        } catch (Exception e) {
            //
        }
        try {
            system.debug(RevenueScheduleController.getSalesLeadSchedules('@@@@'));
        } catch (Exception e) {
            //
        }
        try {
            system.debug(RevenueScheduleController.getOpportunitySchedules('@@@@'));
        } catch (Exception e) {
            //
        }
        try {
            system.debug(RevenueScheduleController.getNewSalesLeadSchedules('@@@@'));
        } catch (Exception e) {
            //
        }
        try {
            system.debug(RevenueScheduleController.getNewOpportunitySchedules('@@@@'));
        } catch (Exception e) {
            //
        }
        try {
            system.debug(RevenueScheduleController.saveSalesLeadSchedules('@@@@', null));
        } catch (Exception e) {
            //
        }
        try {
            system.debug(RevenueScheduleController.saveOpportunitySchedules('@@@@', null));
        } catch (Exception e) {
            //
        }
        try {
            system.debug(RevenueScheduleController.convertSalesLead2Oppty(sl.Id, '@@@@'));
        } catch (Exception e) {
            //
        }
        try {
            system.debug(RevenueScheduleController.getOpportunity('@@@@'));
        } catch (Exception e) {
            //
        }
        try {
            system.debug(RevenueScheduleController.getSalesLead('@@@@'));
        } catch (Exception e) {
            //
        }


		Test.stopTest();
    }

    @isTest static void testMethodThree() {

        Test.startTest();
        Opportunity oppty = [Select Id,name from Opportunity Limit 1];
        Sales_Lead__c sl1 = [Select Id,name from Sales_Lead__c Limit 1];
        list<String> lopptyId = new list<string>();
        list<String> lslId = new list<string>();
        lopptyId.add(oppty.Id);
        lslId.add(sl1.Id);
        system.debug(Flow_RevenueSplitOpportunity.createRevenues(lopptyId));
        system.debug(Flow_RevenueSplitSalesLead.createRevenues(lslId));
		Test.stopTest();
	}

}