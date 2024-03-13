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
public class Batch_ProfitLossImportOrderSummary implements Database.Stateful, Database.Batchable<sObject> {
    public String headerId = '';
    public ProfitLossSimulationHeader__c plsh;

    public Database.QueryLocator start(Database.BatchableContext bc) {
        plsh = [SELECT Id, Name, SIMUL_VERSION__c, 
					BUSI_YEAR__c, VERSION__c, REAL_FLAG2__c, COMPANY_CODE__c, COMPANY_NAME__c, BUSI_AREA__c,
					BUSI_AREANAME__c, OPPORTUNITY__c, OPPORTUNITY_NAME__c, REGION__c, REGION_NAME__c,
					SALES_DEPT1__c, SALES_DEPTNAME1__c, SALES_DEPT2__c, SALES_DEPTNAME2__c, SALES_DEPT3__c,
					SALES_DEPTNAME3__c, SALES_DEPT4__c, SALES_DEPTNAME4__c, SALES_DEPT5__c, SALES_DEPTNAME5__c,
					DEV_DEPT1__c, DEV_DEPT2__c, DEV_DEPT3__c, DEV_DEPT4__c, DEV_DEPT5__c, DEV_DEPTNAME__c,
					BUSI_TYPE1__c, BUSI_TYPE2__c, SOLUTION_NAME__c, ORIGIN_CUST__c, ORIGIN_CUSTNAME__c,
					STANDARD_CUST__c, STANDARD_CUSTNAME__c, GROUPIN_FLAG__c, DOMESTIC_FLAG__c, CURRENCY__c 
				FROM ProfitLossSimulationHeader__c
				WHERE Id = :headerId LIMIT 1];

        String bizYear = plsh.BUSI_YEAR__c;
        String companyCode = plsh.COMPANY_CODE__c;
        String deptCode = plsh.SALES_DEPT2__c;
        String teamCode = plsh.SALES_DEPT3__c;
        String version = plsh.VERSION__c != null ? plsh.VERSION__c : '';
        String query = 'SELECT Id, Name, OwnerId, ';
        query += 'BUSI_YEAR__c, VERSION__c, REAL_FLAG2__c, COMPANY_CODE__c, COMPANY_NAME__c, BUSI_AREA__c, ';
        query += 'BUSI_AREANAME__c, OPPORTUNITY__c, OPPORTUNITY_NAME__c, REGION__c, REGION_NAME__c, ';
        query += 'SALES_DEPT1__c, SALES_DEPTNAME1__c, SALES_DEPT2__c, SALES_DEPTNAME2__c, SALES_DEPT3__c, ';
        query += 'SALES_DEPTNAME3__c, SALES_DEPT4__c, SALES_DEPTNAME4__c, SALES_DEPT5__c, SALES_DEPTNAME5__c, ';
        query += 'DEV_DEPT1__c, DEV_DEPT2__c, DEV_DEPT3__c, DEV_DEPT4__c, DEV_DEPT5__c, DEV_DEPTNAME__c, ';
        query += 'BUSI_TYPE1__c, BUSI_TYPE2__c, SOLUTION_NAME__c, ORIGIN_CUST__c, ORIGIN_CUSTNAME__c, ';
        query += 'STANDARD_CUST__c, STANDARD_CUSTNAME__c, GROUPIN_FLAG__c, DOMESTIC_FLAG__c, CURRENCY__c, ';
        query += 'CONTRACT_01__c, CONTRACT_02__c, CONTRACT_03__c, CONTRACT_04__c, CONTRACT_05__c, CONTRACT_06__c, ';
        query += 'CONTRACT_07__c, CONTRACT_08__c, CONTRACT_09__c, CONTRACT_10__c, CONTRACT_11__c, CONTRACT_12__c, ';
        query += 'REVENUE_01__c, REVENUE_02__c, REVENUE_03__c, REVENUE_04__c, REVENUE_05__c, REVENUE_06__c, ';
        query += 'REVENUE_07__c, REVENUE_08__c, REVENUE_09__c, REVENUE_10__c, REVENUE_11__c, REVENUE_12__c, ';
        query += 'OPROFIT_01__c, OPROFIT_02__c, OPROFIT_03__c, OPROFIT_04__c, OPROFIT_05__c, OPROFIT_06__c, ';
        query += 'OPROFIT_07__c, OPROFIT_08__c, OPROFIT_09__c, OPROFIT_10__c, OPROFIT_11__c, OPROFIT_12__c ';
        query += 'FROM ProfitLossSummary__c ';
        query += 'WHERE BUSI_YEAR__c = :bizYear ';
        query += 'AND COMPANY_CODE__c = :companyCode ';
        query += 'AND SALES_DEPT2__c = :deptCode ';
        query += 'AND SALES_DEPT3__c = :teamCode ';
        if(plsh.VERSION__c != null && plsh.VERSION__c != '')
            query += 'AND VERSION__c = :version ';
            
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, list<sObject> objList) {
        try {
            list<ProfitLossSimulation__c> lpls = new list<ProfitLossSimulation__c>();
            for(sObject obj : objList){
                ProfitLossSummary__c order = (ProfitLossSummary__c) obj;
                ProfitLossSimulation__c pl = new ProfitLossSimulation__c();
                
                pl.PARENT__c = plsh.Id;
                pl.SIMUL_VERSION__c = plsh.SIMUL_VERSION__c;
                pl.BUSI_YEAR__c = (order.BUSI_YEAR__c != null ? order.BUSI_YEAR__c : '');
                pl.VERSION__c = (order.VERSION__c != null ? order.VERSION__c : '');
                pl.REAL_FLAG2__c = (order.REAL_FLAG2__c != null ? order.REAL_FLAG2__c : '');
                pl.COMPANY_CODE__c = (order.COMPANY_CODE__c != null ? order.COMPANY_CODE__c : '');
                pl.COMPANY_NAME__c = (order.COMPANY_NAME__c != null ? order.COMPANY_NAME__c : '');
                pl.BUSI_AREA__c = (order.BUSI_AREA__c != null ? order.BUSI_AREA__c : '');
                pl.BUSI_AREANAME__c = (order.BUSI_AREANAME__c != null ? order.BUSI_AREANAME__c : '');
                pl.OPPORTUNITY__c = (order.OPPORTUNITY__c != null ? order.OPPORTUNITY__c : '');
                pl.OPPORTUNITY_NAME__c = (order.OPPORTUNITY_NAME__c != null ? order.OPPORTUNITY_NAME__c : '');
                pl.SALES_DEPT1__c = (order.SALES_DEPT1__c != null ? order.SALES_DEPT1__c : '');
                pl.SALES_DEPTNAME1__c = (order.SALES_DEPTNAME1__c != null ? order.SALES_DEPTNAME1__c : '');
                pl.SALES_DEPT2__c = (order.SALES_DEPT2__c != null ? order.SALES_DEPT2__c : '');
                pl.SALES_DEPTNAME2__c = (order.SALES_DEPTNAME2__c != null ? order.SALES_DEPTNAME2__c : '');
                pl.SALES_DEPT3__c = (order.SALES_DEPT3__c != null ? order.SALES_DEPT3__c : '');
                pl.SALES_DEPTNAME3__c = (order.SALES_DEPTNAME3__c != null ? order.SALES_DEPTNAME3__c : '');
                pl.SALES_DEPT4__c = (order.SALES_DEPT4__c != null ? order.SALES_DEPT4__c : '');
                pl.SALES_DEPTNAME4__c = (order.SALES_DEPTNAME4__c != null ? order.SALES_DEPTNAME4__c : '');
                pl.SALES_DEPT5__c = (order.SALES_DEPT5__c != null ? order.SALES_DEPT5__c : '');
                pl.SALES_DEPTNAME5__c = (order.SALES_DEPTNAME5__c != null ? order.SALES_DEPTNAME5__c : '');
                pl.DEV_DEPT1__c = (order.DEV_DEPT1__c != null ? order.DEV_DEPT1__c : '');
                pl.DEV_DEPT2__c = (order.DEV_DEPT2__c != null ? order.DEV_DEPT2__c : '');
                pl.DEV_DEPT3__c = (order.DEV_DEPT3__c != null ? order.DEV_DEPT3__c : '');
                pl.DEV_DEPT4__c = (order.DEV_DEPT4__c != null ? order.DEV_DEPT4__c : '');
                pl.DEV_DEPT5__c = (order.DEV_DEPT5__c != null ? order.DEV_DEPT5__c : '');
                pl.DEV_DEPTNAME__c = (order.DEV_DEPTNAME__c != null ? order.DEV_DEPTNAME__c : '');
                pl.BUSI_TYPE1__c = (order.BUSI_TYPE1__c != null ? order.BUSI_TYPE1__c : '');
                pl.BUSI_TYPE2__c = (order.BUSI_TYPE2__c != null ? order.BUSI_TYPE2__c : '');
                pl.ORIGIN_CUST__c = (order.ORIGIN_CUST__c != null ? order.ORIGIN_CUST__c : '');
                pl.ORIGIN_CUSTNAME__c = (order.ORIGIN_CUSTNAME__c != null ? order.ORIGIN_CUSTNAME__c : '');
                pl.STANDARD_CUST__c = (order.STANDARD_CUST__c != null ? order.STANDARD_CUST__c : '');
                pl.STANDARD_CUSTNAME__c = (order.STANDARD_CUSTNAME__c != null ? order.STANDARD_CUSTNAME__c : '');
                pl.GROUPIN_FLAG__c = (order.GROUPIN_FLAG__c != null ? order.GROUPIN_FLAG__c : '');
                pl.DOMESTIC_FLAG__c = (order.DOMESTIC_FLAG__c != null ? order.DOMESTIC_FLAG__c : '');
                pl.CURRENCY__c = (order.CURRENCY__c != null ? order.CURRENCY__c : '');
                pl.CurrencyIsoCode = (order.CURRENCY__c != null ? order.CURRENCY__c : '');
                pl.CONTRACT_01__c = (order.CONTRACT_01__c != null ? order.CONTRACT_01__c : 0.0);
                pl.CONTRACT_02__c = (order.CONTRACT_02__c != null ? order.CONTRACT_02__c : 0.0);
                pl.CONTRACT_03__c = (order.CONTRACT_03__c != null ? order.CONTRACT_03__c : 0.0);
                pl.CONTRACT_04__c = (order.CONTRACT_04__c != null ? order.CONTRACT_04__c : 0.0);
                pl.CONTRACT_05__c = (order.CONTRACT_05__c != null ? order.CONTRACT_05__c : 0.0);
                pl.CONTRACT_06__c = (order.CONTRACT_06__c != null ? order.CONTRACT_06__c : 0.0);
                pl.CONTRACT_07__c = (order.CONTRACT_07__c != null ? order.CONTRACT_07__c : 0.0);
                pl.CONTRACT_08__c = (order.CONTRACT_08__c != null ? order.CONTRACT_08__c : 0.0);
                pl.CONTRACT_09__c = (order.CONTRACT_09__c != null ? order.CONTRACT_09__c : 0.0);
                pl.CONTRACT_10__c = (order.CONTRACT_10__c != null ? order.CONTRACT_10__c : 0.0);
                pl.CONTRACT_11__c = (order.CONTRACT_11__c != null ? order.CONTRACT_11__c : 0.0);
                pl.CONTRACT_12__c = (order.CONTRACT_12__c != null ? order.CONTRACT_12__c : 0.0);
                pl.REVENUE_01__c = (order.REVENUE_01__c != null ? order.REVENUE_01__c : 0.0);
                pl.REVENUE_02__c = (order.REVENUE_02__c != null ? order.REVENUE_02__c : 0.0);
                pl.REVENUE_03__c = (order.REVENUE_03__c != null ? order.REVENUE_03__c : 0.0);
                pl.REVENUE_04__c = (order.REVENUE_04__c != null ? order.REVENUE_04__c : 0.0);
                pl.REVENUE_05__c = (order.REVENUE_05__c != null ? order.REVENUE_05__c : 0.0);
                pl.REVENUE_06__c = (order.REVENUE_06__c != null ? order.REVENUE_06__c : 0.0);
                pl.REVENUE_07__c = (order.REVENUE_07__c != null ? order.REVENUE_07__c : 0.0);
                pl.REVENUE_08__c = (order.REVENUE_08__c != null ? order.REVENUE_08__c : 0.0);
                pl.REVENUE_09__c = (order.REVENUE_09__c != null ? order.REVENUE_09__c : 0.0);
                pl.REVENUE_10__c = (order.REVENUE_10__c != null ? order.REVENUE_10__c : 0.0);
                pl.REVENUE_11__c = (order.REVENUE_11__c != null ? order.REVENUE_11__c : 0.0);
                pl.REVENUE_12__c = (order.REVENUE_12__c != null ? order.REVENUE_12__c : 0.0);
                pl.OPROFIT_01__c = (order.OPROFIT_01__c != null ? order.OPROFIT_01__c : 0.0);
                pl.OPROFIT_02__c = (order.OPROFIT_02__c != null ? order.OPROFIT_02__c : 0.0);
                pl.OPROFIT_03__c = (order.OPROFIT_03__c != null ? order.OPROFIT_03__c : 0.0);
                pl.OPROFIT_04__c = (order.OPROFIT_04__c != null ? order.OPROFIT_04__c : 0.0);
                pl.OPROFIT_05__c = (order.OPROFIT_05__c != null ? order.OPROFIT_05__c : 0.0);
                pl.OPROFIT_06__c = (order.OPROFIT_06__c != null ? order.OPROFIT_06__c : 0.0);
                pl.OPROFIT_07__c = (order.OPROFIT_07__c != null ? order.OPROFIT_07__c : 0.0);
                pl.OPROFIT_08__c = (order.OPROFIT_08__c != null ? order.OPROFIT_08__c : 0.0);
                pl.OPROFIT_09__c = (order.OPROFIT_09__c != null ? order.OPROFIT_09__c : 0.0);
                pl.OPROFIT_10__c = (order.OPROFIT_10__c != null ? order.OPROFIT_10__c : 0.0);
                pl.OPROFIT_11__c = (order.OPROFIT_11__c != null ? order.OPROFIT_11__c : 0.0);
                pl.OPROFIT_12__c = (order.OPROFIT_12__c != null ? order.OPROFIT_12__c : 0.0);
    
                lpls.add(pl);
            }

            if(!lpls.isEmpty()) insert lpls;
        } catch(Exception e){
            //
        }
    }

    public void finish(Database.BatchableContext bc) {
        //
    }
}