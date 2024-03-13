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
public class Batch_ProfitLossImportOpportunity implements Database.Stateful, Database.Batchable<sObject> {
    public String headerId = '';
    public String closeDate = '';
    public ProfitLossSimulationHeader__c plsh;

    public Database.QueryLocator start(Database.BatchableContext bc) {
        list<String> dates = closeDate.split('-');
        Date fromDate = Date.newInstance(Integer.valueOf(dates[0]), Integer.valueOf(dates[1]), Integer.valueOf(dates[2]));
        Integer year = fromDate.year();
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

        String companyCode = plsh.COMPANY_CODE__c;
        String deptCode = plsh.SALES_DEPT2__c;
        String teamCode = plsh.SALES_DEPT3__c;

        String query = 'SELECT Id, Name, AccountId, Amount, CurrencyIsoCode, Type, ExpectedRevenue, ';
		query += 'BusinessLevel__c, BusinessType2__c, BusinessType__c, CompanyCode__c, ';
		query += 'CustDivision__c, CustDivision__r.Name, cOriginAcc__c, cOriginAcc__r.Name, ';
		query += 'cPrimaryDeliveryDivision__c, cPrimaryDeliveryTeam__c, ';
		query += 'cPrimarySalesDepartment__c, cPrimarySalesDepartment__r.Name, ';
		query += 'DeliveryOrganization__c, DeliveryOrganization__r.Name, DeliveryRegion__c, ';
		query += 'EPCompanyCode__c, OpportunityCode__c, SalesDepartment__c, ';
		query += 'SalesDepartment__r.Name, SalesDepartment__r.Company__r.Name, ';
		query += 'SalesDepartment__r.Node2__c, SalesDepartment__r.Text2__c, ';
		query += 'SalesDepartment__r.Node4__c, SalesDepartment__r.Text4__c, ';
		query += 'SalesDepartment__r.Node5__c, SalesDepartment__r.Text5__c, ';
		query += 'SalesDivision__c, SalesOrganization__r.Name, SalesOrganization__r.Company__r.Name, ';
		query += 'SalesRegion__c, SalesTeam__c, RecordType.Name, GroupInternal__c, KoreaDomestic__c, ';
		query += '(SELECT Id, Parent__c, Revenue__c, ScheduleDate__c FROM OpportunityRevenueSchedules__r) ';
		query += 'FROM Opportunity ';
		query += 'WHERE CALENDAR_YEAR(CloseDate) = :this.year ';
		query += 'AND CompanyCode__c = :companyCode ';
		query += 'AND SalesDepartment__r.Node2__c = :deptCode ';
		query += 'AND SalesDepartment__r.Node4__c = :teamCode ';
		query += 'AND CloseDate >= :fromDate ';
		query += 'AND StageName != \'Z05\' ';
		query += 'AND StageName != \'Z06\' ';
		query += 'AND StageName != \'Z07\' ';

        system.debug(query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, list<sObject> objList) {
        try{
            list<ProfitLossSimulation__c> lpls = new list<ProfitLossSimulation__c>();
            for(sObject obj : objList){
                Opportunity oppty = (Opportunity) obj;
                ProfitLossSimulation__c pl = new ProfitLossSimulation__c();
                String companyName = '';
                if(oppty.RecordType.Name == 'HQ'){
                    companyName = oppty.SalesDepartment__c != null ? oppty.SalesDepartment__r.Company__r.Name : '';
                } else {
                    companyName = oppty.SalesOrganization__c != null ? oppty.SalesOrganization__r.Company__r.Name : '';
                }
                pl.PARENT__c = plsh.Id;
                pl.SIMUL_VERSION__c = plsh.SIMUL_VERSION__c;
                pl.BUSI_YEAR__c = plsh.BUSI_YEAR__c;
                pl.VERSION__c = '';
                pl.REAL_FLAG2__c = '';
                pl.COMPANY_CODE__c = (oppty.CompanyCode__c != null ? oppty.CompanyCode__c : '');
                pl.COMPANY_NAME__c = companyName;
                pl.BUSI_AREA__c = '';
                pl.BUSI_AREANAME__c = '';
                pl.OPPORTUNITY__c = oppty.OpportunityCode__c;
                pl.OPPORTUNITY_NAME__c = oppty.Name;
                pl.SALES_DEPT1__c = '';
                pl.SALES_DEPTNAME1__c = '';
                pl.SALES_DEPT2__c = (oppty.SalesDepartment__c != null ? oppty.SalesDepartment__r.Node2__c : '');
                pl.SALES_DEPTNAME2__c = (oppty.SalesDepartment__c != null ? oppty.SalesDepartment__r.Text2__c : '');
                pl.SALES_DEPT3__c = '';
                pl.SALES_DEPTNAME3__c = '';
                pl.SALES_DEPT4__c = (oppty.SalesDepartment__c != null ? oppty.SalesDepartment__r.Node4__c : '');
                pl.SALES_DEPTNAME4__c = (oppty.SalesDepartment__c != null ? oppty.SalesDepartment__r.Text4__c : '');
                pl.SALES_DEPT5__c = (oppty.SalesDepartment__c != null ? oppty.SalesDepartment__r.Node5__c : '');
                pl.SALES_DEPTNAME5__c = (oppty.SalesDepartment__c != null ? oppty.SalesDepartment__r.Text5__c : '');
                pl.DEV_DEPT1__c = '';
                pl.DEV_DEPT2__c = oppty.cPrimaryDeliveryDivision__c;
                pl.DEV_DEPT3__c = '';
                pl.DEV_DEPT4__c = oppty.cPrimaryDeliveryTeam__c;
                pl.DEV_DEPT5__c = (oppty.cPrimarySalesDepartment__c != null ? oppty.cPrimarySalesDepartment__c :'');
                pl.DEV_DEPTNAME__c = (oppty.cPrimarySalesDepartment__c != null ? oppty.cPrimarySalesDepartment__r.Name :'');
                pl.BUSI_TYPE1__c = (oppty.BusinessType__c != null ? oppty.BusinessType__c : '');
                pl.BUSI_TYPE2__c = (oppty.BusinessType2__c != null ? oppty.BusinessType2__c : '');
                pl.ORIGIN_CUST__c = (oppty.cOriginAcc__c != null ? oppty.cOriginAcc__c : '');
                pl.ORIGIN_CUSTNAME__c = (oppty.cOriginAcc__c != null ? oppty.cOriginAcc__r.Name : '');
                pl.STANDARD_CUST__c = (oppty.cOriginAcc__c != null ? oppty.cOriginAcc__c : '');
                pl.STANDARD_CUSTNAME__c = (oppty.cOriginAcc__c != null ? oppty.cOriginAcc__r.Name : '');
                pl.GROUPIN_FLAG__c = (oppty.GroupInternal__c ? 'Y' : 'N');
                pl.DOMESTIC_FLAG__c = (oppty.KoreaDomestic__c ? 'Y' : 'N');
                pl.CURRENCY__c = oppty.CurrencyIsoCode;
                pl.CurrencyIsoCode = oppty.CurrencyIsoCode;
                if(!oppty.OpportunityRevenueSchedules__r.isEmpty()){
                    for(RevenueScheduleOpportunity__c rs : oppty.OpportunityRevenueSchedules__r){
                        if(String.valueOf(rs.ScheduleDate__c.year()) == plsh.BUSI_YEAR__c){
                            if(rs.ScheduleDate__c.month() == 0){
                                pl.CONTRACT_01__c = rs.Revenue__c != null ?  rs.Revenue__c : 0.0;
                                pl.REVENUE_01__c = rs.Revenue__c != null ?  rs.Revenue__c : 0.0;
                            } else if(rs.ScheduleDate__c.month() == 1){
                                pl.CONTRACT_02__c = rs.Revenue__c != null ?  rs.Revenue__c : 0.0;
                                pl.REVENUE_02__c = rs.Revenue__c != null ?  rs.Revenue__c : 0.0;
                            } else if(rs.ScheduleDate__c.month() == 2){
                                pl.CONTRACT_03__c = rs.Revenue__c != null ?  rs.Revenue__c : 0.0;
                                pl.REVENUE_03__c = rs.Revenue__c != null ?  rs.Revenue__c : 0.0;
                            } else if(rs.ScheduleDate__c.month() == 3){
                                pl.CONTRACT_04__c = rs.Revenue__c != null ?  rs.Revenue__c : 0.0;
                                pl.REVENUE_04__c = rs.Revenue__c != null ?  rs.Revenue__c : 0.0;
                            } else if(rs.ScheduleDate__c.month() == 4){
                                pl.CONTRACT_05__c = rs.Revenue__c != null ?  rs.Revenue__c : 0.0;
                                pl.REVENUE_05__c = rs.Revenue__c != null ?  rs.Revenue__c : 0.0;
                            } else if(rs.ScheduleDate__c.month() == 5){
                                pl.CONTRACT_06__c = rs.Revenue__c != null ?  rs.Revenue__c : 0.0;
                                pl.REVENUE_06__c = rs.Revenue__c != null ?  rs.Revenue__c : 0.0;
                            } else if(rs.ScheduleDate__c.month() == 6){
                                pl.CONTRACT_07__c = rs.Revenue__c != null ?  rs.Revenue__c : 0.0;
                                pl.REVENUE_07__c = rs.Revenue__c != null ?  rs.Revenue__c : 0.0;
                            } else if(rs.ScheduleDate__c.month() == 7){
                                pl.CONTRACT_08__c = rs.Revenue__c != null ?  rs.Revenue__c : 0.0;
                                pl.REVENUE_08__c = rs.Revenue__c != null ?  rs.Revenue__c : 0.0;
                            } else if(rs.ScheduleDate__c.month() == 8){
                                pl.CONTRACT_09__c = rs.Revenue__c != null ?  rs.Revenue__c : 0.0;
                                pl.REVENUE_09__c = rs.Revenue__c != null ?  rs.Revenue__c : 0.0;
                            } else if(rs.ScheduleDate__c.month() == 9){
                                pl.CONTRACT_10__c = rs.Revenue__c != null ?  rs.Revenue__c : 0.0;
                                pl.REVENUE_10__c = rs.Revenue__c != null ?  rs.Revenue__c : 0.0;
                            } else if(rs.ScheduleDate__c.month() == 10){
                                pl.CONTRACT_11__c = rs.Revenue__c != null ?  rs.Revenue__c : 0.0;
                                pl.REVENUE_11__c = rs.Revenue__c != null ?  rs.Revenue__c : 0.0;
                            } else if(rs.ScheduleDate__c.month() == 11){
                                pl.CONTRACT_12__c = rs.Revenue__c != null ?  rs.Revenue__c : 0.0;
                                pl.REVENUE_12__c = rs.Revenue__c != null ?  rs.Revenue__c : 0.0;
                            }
                        }
                    }
                }
    
                lpls.add(pl);
            }

            if(!lpls.isEmpty()) insert lpls;
        } catch(Exception e){

        }
    }

    public void finish(Database.BatchableContext bc) {
        //
    }

}