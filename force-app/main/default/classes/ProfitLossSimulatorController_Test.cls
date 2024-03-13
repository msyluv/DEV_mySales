/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 05-13-2021
 * @last modified by  : woomg@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   04-26-2021   woomg@dkbmc.com   Initial Version
**/
@isTest
public class ProfitLossSimulatorController_Test {
    static RecordType RT_OPPTY_HQ;
    static User usr1;
    static User usr2;
    static Employee__c emp1;
    static Employee__c emp2;
    static Opportunity oppty;
    static ProfitLossSimulationHeader__c plsh;

    static {        
        RT_OPPTY_HQ = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'HQ' Limit 1];
        
        // 임직원 및 User Setting
        emp1 = new Employee__c(
            Name = 'TestEmp1',
            EvMailAddr__c = 'TestEmp1' + '@samsung.com',
            EvUniqID__c = 'EPID1',
            EvKostl__c = 'TESTCC0001',
            EvStatus__c = '1',
            EvFlag__c = '4'      
        );
        insert emp1;

        usr1 = Utils_TestDataFactory.createUserFull(
                Utils_TestDataFactory.getProfile('Sales Rep.(HQ)'),
                emp1.EvMailAddr__c,
                emp1.EvUniqID__c);

        // 임직원 및 User Setting
        emp2 = new Employee__c(
            Name = 'TestEmp2',
            EvMailAddr__c = 'TestEmp2' + '@samsung.com',
            EvUniqID__c = 'EPID2',
            EvKostl__c = 'TESTCC0002'
        );
        insert emp2;

        usr2 = Utils_TestDataFactory.createUserFull(
                Utils_TestDataFactory.getProfile('Sales Rep.(HQ)'),
                emp2.EvMailAddr__c,
                emp2.EvUniqID__c);

        Company__c co = new Company__c(
            Name = 'T100',
            CompanyCode__c = 'T100',
            CompanyFullName__c = 'T100'
        );
        insert co;

        CostCenter__c cc = new CostCenter__c(
            CostCenter__c='TESTCC0001', 
            Company__c = co.Id,
            Node1__c='T100', 
            Node2__c='T100S1', 
            Node3__c='T100S11', 
            Node4__c='T100S111', 
            Node5__c='T100S10101',
            Text1__c='Company', 
            Text2__c='Dept', 
            Text3__c='Team', 
            Text4__c='Group', 
            Text5__c='Cell'
        );
        insert cc;

        Account acc = new Account(Name = 'accTest', MDGCheck__c=true, mDomesticForeign__c='10', mCountry__c='KR');
        insert acc;

        MasterActivity__c mastrtAct1_ZP62 = new MasterActivity__c(
                                transactionName__c=OpportunityActivityHelper.ACT_CODE_REQUEST_COMMITTEE_APPROVAL,
                                Stage__c='Z01',Order__c=1,
                                IsRequiredKnoxApproval__c=false,
                                Position__c='1',IsImportant__c=true,IsRequired__c=true,
                                ObjectApiName__c='Opportunity',IsActive__c=true,Type__c='HQ');

        insert mastrtAct1_ZP62;
        
        Date testDate = Date.newInstance(system.today().year(), 1, 10);
        oppty = new Opportunity(
            Name='Test', 
            OwnerId=usr1.Id, 
            Amount=10000000, 
            RecordTypeId=RT_OPPTY_HQ.Id, 
            AccountId=acc.Id, 
            CloseDate=testDate,
            cRevenueStartDate__c=testDate.addDays(10),
            cRevenueEndDate__c=testDate.addMonths(12),
            SalesDepartment__c = cc.Id,
            cPrimarySalesDepartment__c = cc.Id,
            cOriginAcc__c = acc.Id,
            StageName = 'Z01');
        insert oppty;

        List<RevenueScheduleOpportunity__c> lrso = RevenueScheduleController.getOpportunitySchedules( oppty.Id);
        insert lrso;

        String year = String.valueOf(system.today().year());
        ProfitLossSummary__c pls = new ProfitLossSummary__c();
        pls.BUSI_YEAR__c = year;
        pls.VERSION__c = '401';
        pls.REAL_FLAG2__c = 'R';
        pls.COMPANY_CODE__c = 'T100';
        pls.COMPANY_NAME__c = 'COMPANY';
        pls.BUSI_AREA__c = 'T100';
        pls.BUSI_AREANAME__c = 'T100 OWNED';
        pls.OPPORTUNITY__c = 'SDS-210000010';
        pls.OPPORTUNITY_NAME__c = 'SDS-210000010 OPPTY';
        pls.SALES_DEPT1__c = 'T100';
        pls.SALES_DEPTNAME1__c = 'COMPANY';
        pls.SALES_DEPT2__c = 'T100S1';
        pls.SALES_DEPTNAME2__c = 'DEPT';
        pls.SALES_DEPT3__c = 'T100S111';
        pls.SALES_DEPTNAME3__c = 'TEAM';
        pls.SALES_DEPT4__c = 'T100S11101';
        pls.SALES_DEPTNAME4__c = 'GROUP';
        pls.SALES_DEPT5__c = 'T100S1110101';
        pls.SALES_DEPTNAME5__c = 'CELL';
        pls.DEV_DEPT1__c = 'DEV_DEPT1';
        pls.DEV_DEPT2__c = 'DEV_DEPT2';
        pls.DEV_DEPT3__c = 'DEV_DEPT3';
        pls.DEV_DEPT4__c = 'DEV_DEPT4';
        pls.DEV_DEPT5__c = 'DEV_DEPT5';
        pls.DEV_DEPTNAME__c = 'DEV_DEPTNAME';
        pls.BUSI_TYPE1__c = 'BUSI_TYPE1';
        pls.BUSI_TYPE2__c = 'BUSI_TYPE2';
        pls.ORIGIN_CUST__c = 'ORIGIN_CUST';
        pls.ORIGIN_CUSTNAME__c = 'ORIGIN_CUSTNAME';
        pls.STANDARD_CUST__c = 'STANDARD_CUST';
        pls.STANDARD_CUSTNAME__c = 'STANDARD_CUSTNAME';
        pls.CURRENCY__c =  'KRW';
        pls.CurrencyIsoCode = 'KRW';
        pls.CONTRACT_01__c = 10000;
        pls.CONTRACT_02__c = 10000;
        pls.CONTRACT_03__c = 10000;
        pls.CONTRACT_04__c = 10000;
        pls.CONTRACT_05__c = 10000;
        pls.CONTRACT_06__c = 10000;
        pls.CONTRACT_07__c = 10000;
        pls.CONTRACT_08__c = 10000;
        pls.CONTRACT_09__c = 10000;
        pls.CONTRACT_10__c = 10000;
        pls.CONTRACT_11__c = 10000;
        pls.CONTRACT_12__c = 10000;
        pls.REVENUE_01__c = 10000;
        pls.REVENUE_02__c = 10000;
        pls.REVENUE_03__c = 10000;
        pls.REVENUE_04__c = 10000;
        pls.REVENUE_05__c = 10000;
        pls.REVENUE_06__c = 10000;
        pls.REVENUE_07__c = 10000;
        pls.REVENUE_08__c = 10000;
        pls.REVENUE_09__c = 10000;
        pls.REVENUE_10__c = 10000;
        pls.REVENUE_11__c = 10000;
        pls.REVENUE_12__c = 10000;
        pls.OPROFIT_01__c = 100;
        pls.OPROFIT_02__c = 100;
        pls.OPROFIT_03__c = 100;
        pls.OPROFIT_04__c = 100;
        pls.OPROFIT_05__c = 100;
        pls.OPROFIT_06__c = 100;
        pls.OPROFIT_07__c = 100;
        pls.OPROFIT_08__c = 100;
        pls.OPROFIT_09__c = 100;
        pls.OPROFIT_10__c = 100;
        pls.OPROFIT_11__c = 100;
        pls.OPROFIT_12__c = 100;

        insert pls;
    }

    @isTest
    public static void testMethodOne() {
        Test.startTest();
        System.runAs(usr1) {
            String year = String.valueOf(system.today().year());
            system.debug(ProfitLossSimulatorController.getEmployeeInfo());
            system.debug(ProfitLossSimulatorController.getCompany());
            system.debug(ProfitLossSimulatorController.getDepartment2('T100'));
            system.debug(ProfitLossSimulatorController.getDepartment3('T100', 'T100S1'));
            system.debug(ProfitLossSimulatorController.getDepartment4('T100', 'T100S1', 'T100S111'));

            system.debug(ProfitLossSimulatorController.getVersion(year, 'T100', 'T100S1', 'T100S111'));

            plsh = ProfitLossSimulatorController.createNewSimulation(
                year, 'T100', 'T100S1', 'T100S111', 'COMPANY', 'DEPT', 'TEAM', '401', year +'-01-01', '210401'
            );
            system.debug(ProfitLossSimulatorController.getProfitLossSimulationHeader(plsh.Id));
            system.debug(ProfitLossSimulatorController.hasOrderSummaryInSimulation(plsh.Id));
            system.debug(ProfitLossSimulatorController.hasOrderOpptyInSimulation(plsh.Id));
            system.debug(ProfitLossSimulatorController.importOrderSummaries(plsh.Id));
            system.debug(ProfitLossSimulatorController.importOpportunities(plsh.Id));
            system.debug(ProfitLossSimulatorController.hasOrderSummaryInSimulation(plsh.Id));
            system.debug(ProfitLossSimulatorController.hasOrderOpptyInSimulation(plsh.Id));
            system.debug(ProfitLossSimulatorController.getSimulations(year, 'T100', 'T100S1', 'T100S111'));
            Test.setCurrentPage(Page.JusoChild);
            system.debug(ProfitLossSimulatorController.getProfitLossSimulations(plsh.Id, 'T100S11101', 'BUSI_TYPE1', 50, 1));
            system.debug(ProfitLossSimulatorController.getSimulationSum(plsh.Id, 'T100S11101', 'BUSI_TYPE1'));
            system.debug(ProfitLossSimulatorController.getBizType(plsh.Id));
            system.debug(ProfitLossSimulatorController.resetSimulation(plsh.Id));
        }
        Test.stopTest();
    }

    @isTest
    public static void testMethodTwo() {
        Test.startTest();
        System.runAs(usr1) {
            String year = String.valueOf(system.today().year());
            plsh = ProfitLossSimulatorController.createNewSimulation(
                year, 'T100', 'T100S1', 'T100S111', 'COMPANY', 'DEPT', 'TEAM', '401', year +'-01-01', '210401'
            );
            system.debug(ProfitLossSimulatorController.getProfitLossSimulationHeader(plsh.Id));
            system.debug(ProfitLossSimulatorController.hasOrderSummaryInSimulation(plsh.Id));
            system.debug(ProfitLossSimulatorController.hasOrderOpptyInSimulation(plsh.Id));
            system.debug(ProfitLossSimulatorController.importOrderSummaries(plsh.Id));
            system.debug(ProfitLossSimulatorController.importOpportunities(plsh.Id));
            list<ProfitLossSimulation__c> lpls = 
                [SELECT Id, REVENUE_01__c,  REVENUE_02__c, REVENUE_03__c, REVENUE_04__c, REVENUE_05__c, REVENUE_06__c,
                    REVENUE_07__c, REVENUE_08__c, REVENUE_09__c, REVENUE_10__c, REVENUE_11__c, REVENUE_12__c
                 FROM ProfitLossSimulation__c
                 WHERE OPPORTUNITY_ID__c != null];
            list<String> ids = new list<String>();
            for(ProfitLossSimulation__c pls : lpls){
                ids.add(pls.Id);
            }
            system.debug(ProfitLossSimulatorController.calcurateProfit(ids, 0.01));
            system.debug(ProfitLossSimulatorController.calcurateProfit(plsh.Id, 'T100S11101', 'BUSI_TYPE1', 0.01));
            system.debug(ProfitLossSimulatorController.updateRevenuePlan(lpls[0]));
            
            String opptyCode = [SELECT OpportunityCode__c FROM Opportunity LIMIT 1].OpportunityCode__c;
            system.debug(ProfitLossSimulatorController.getOpportunity('T100', opptyCode));

            system.debug(ProfitLossSimulatorController.deleteSimulations(ids));

        }
        Test.stopTest();
    }

    @isTest
    public static void testMethodThree() {
        Test.startTest();
        System.runAs(usr2) {
            try{
                system.debug(ProfitLossSimulatorController.getEmployeeInfo());
            } catch (Exception ex){}


            try{
                system.debug(ProfitLossSimulatorController.deleteSimulations(null));
            } catch (Exception ex){}
            try{
                system.debug(ProfitLossSimulatorController.calcurateProfit(null, null));
            } catch (Exception ex){}
            try{
                system.debug(ProfitLossSimulatorController.getOpportunity(null, null));
            } catch (Exception ex){}
            try{
                system.debug(ProfitLossSimulatorController.updateRevenuePlan(null));
            } catch (Exception ex){}
        }
        Test.stopTest();
    }

    @isTest
    public static void testBatchMethod() {
        Test.startTest();
        System.runAs(usr2) {
            String year = String.valueOf(system.today().year());
            plsh = ProfitLossSimulatorController.createNewSimulation(
                year, 'T100', 'T100S1', 'T100S111', 'COMPANY', 'DEPT', 'TEAM', '401', year +'-01-01', '210401'
            );
            Batch_ProfitLossImportOpportunity b1 = new Batch_ProfitLossImportOpportunity();
            b1.headerId = plsh.Id;
            b1.closeDate = year + '-01-01';
            DataBase.executeBatch( b1, 100 );    

            Batch_ProfitLossImportOrderSummary b2 = new Batch_ProfitLossImportOrderSummary();
            b2.headerId = plsh.Id;
            DataBase.executeBatch( b2, 100 );    
        }
        Test.stopTest();
    }

}