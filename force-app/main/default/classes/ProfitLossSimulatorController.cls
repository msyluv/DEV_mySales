/**
 * @description	   : 
 * @author			: woomg@dkbmc.com
 * @group			 : 
 * @last modified on  : 2021-10-22
 * @last modified by  : seonju.jin@dkbmc.com
 * Modifications Log 
 * Ver   Date		 Author			Modification
 * 1.0   01-21-2021   woomg@dkbmc.com   Initial Version
 * 1.1   10-22-2021   seonju.jin@dkbmc.com   Employee 조회 공통처리
**/
public with sharing class ProfitLossSimulatorController {

	@AuraEnabled
	public static CostCenter__c getEmployeeInfo(){
		try {

			String epId = [SELECT FederationIdentifier FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].FederationIdentifier;
			Employee__c emp = Utils.getEmployeeData(epId, new Set<String>{'EvKostl__c','EvDept__c'} , null);
			// String epId = [SELECT FederationIdentifier FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].FederationIdentifier;
			// Employee__c emp = 
			// 	[SELECT Id, EvKostl__c, EvDept__c
			// 	 FROM Employee__c
			// 	 WHERE EvUniqID__c = :epId
			// 		AND EvStatus__c = '1'
			// 		// AND EvFlag__c = '4'  // 정규직 = 4?, 협력사원 = 6?
			// 	 LIMIT 1];

			CostCenter__c cc = [SELECT Id, CompanyCode__c, CostCenter__c, 
									Node1__c, Node2__c, Node3__c, Node4__c, Node5__c,
									Text1__c, Text2__c, Text3__c, Text4__c, Text5__c
								FROM CostCenter__c
								WHERE CostCenter__c = :emp.EvKostl__c
								LIMIT 1];
			return cc;
		} catch (Exception e) {
			throw new AuraHandledException('No EPId or No Employee__c Information!!');
		}
	}

	@AuraEnabled
	public static list<Object> getCompany(){
		list<Object> loption = new list<Object>();
		// try {
			list<AggregateResult> lar = new list<AggregateResult>();
			lar = [SELECT MAX(Id), MAX(Text1__c) LABEL, Node1__c VALUE
				   FROM CostCenter__c
				   GROUP BY Node1__c];

			if(!lar.isEmpty()){
				for(AggregateResult ar : lar){
					String value = (String)ar.get('VALUE');
					if(value != null && value != '') {
						map<String, String> option = new map<String, String>();
						option.put('value', value);
						option.put('label', (String)ar.get('LABEL'));
						loption.add(option);
					}
				}
			}
			return loption;
		// } catch (Exception e) {
		// 	throw new AuraHandledException(e.getMessage());
		// }
	}

	@AuraEnabled
	public static list<Object> getDepartment2(String companyCode){
		list<Object> loption = new list<Object>();
		// try {
			list<AggregateResult> lar = new list<AggregateResult>();
			lar = [SELECT MAX(Id), MAX(Text2__c) LABEL, Node2__c VALUE
				   FROM CostCenter__c
				   WHERE Node1__c = :companyCode
				   GROUP BY Node2__c];

			if(!lar.isEmpty()){
				for(AggregateResult ar : lar){
					String value = (String)ar.get('VALUE');
					if(value != null && value != '' && value.length() == 6) {
						map<String, String> option = new map<String, String>();
						option.put('value', value);
						option.put('label', (String)ar.get('LABEL'));
						loption.add(option);
					}
				}
			}
			return loption;
		// } catch (Exception e) {
		// 	throw new AuraHandledException(e.getMessage());
		// }
	}

	@AuraEnabled
	public static list<Object> getDepartment3(String companyCode, String dept2Code){
		list<Object> loption = new list<Object>();
		// try {
			list<AggregateResult> lar = new list<AggregateResult>();
			lar = [SELECT MAX(Id), MAX(Text4__c) LABEL, Node4__c VALUE
				   FROM CostCenter__c
				   WHERE Node1__c = :companyCode
					AND Node2__c = :dept2Code
				   GROUP BY Node4__c];

			if(!lar.isEmpty()){
				for(AggregateResult ar : lar){
					String value = (String)ar.get('VALUE');
					if(value != null && value != '' && value.length() == 8) {
						map<String, String> option = new map<String, String>();
						option.put('value', value);
						option.put('label', (String)ar.get('LABEL'));
						loption.add(option);
					}
				}
			}
			return loption;
		// } catch (Exception e) {
		// 	throw new AuraHandledException(e.getMessage());
		// }
	}

	@AuraEnabled
	public static list<Object> getDepartment4(String companyCode, String dept2Code, String dept3Code){
		list<Object> loption = new list<Object>();
		loption.add(new map<String, String>{'value'=> 'all', 'label'=>'All'});
		// try {
			list<AggregateResult> lar = new list<AggregateResult>();
			lar = [SELECT MAX(Id), MAX(CostCenterName__c) LABEL, CostCenter__c VALUE
				   FROM CostCenter__c
				   WHERE Node1__c = :companyCode
					AND Node2__c = :dept2Code
					AND Node4__c = :dept3Code
				   GROUP BY CostCenter__c];

			if(!lar.isEmpty()){
				for(AggregateResult ar : lar){
					String value = (String)ar.get('VALUE');
					if(value != null && value != '' && value.length() == 10) {
						map<String, String> option = new map<String, String>();
						option.put('value', value);
						option.put('label', (String)ar.get('LABEL'));
						loption.add(option);
					}
				}
			}
			return loption;
		// } catch (Exception e) {
		// 	throw new AuraHandledException(e.getMessage());
		// }
	}

	@AuraEnabled
	public static list<Object> getSimulations(String bizYear, String companyCode, String dept2Code, String dept3Code){
		list<Object> loption = new list<Object>();
		// try {
			list<ProfitLossSimulation__c> lps = new list<ProfitLossSimulation__c>();
			lps = [SELECT Id, SIMUL_VERSION__c
				   FROM ProfitLossSimulation__c
				   WHERE BUSI_YEAR__c = :bizYear
					AND COMPANY_CODE__c = :companyCode
					AND SALES_DEPT2__c = :dept2Code
					AND SALES_DEPT3__c = :dept3Code
				   ORDER BY SIMUL_VERSION__c DESC];

			if(!lps.isEmpty()){
				for(ProfitLossSimulation__c ps : lps){
					if(ps.SIMUL_VERSION__c != null && ps.SIMUL_VERSION__c != '') {
						map<String, String> option = new map<String, String>();
						option.put('value', ps.Id);
						option.put('label', ps.SIMUL_VERSION__c);
						loption.add(option);
					}
				}
			}
			return loption;
		// } catch (Exception e) {
		// 	throw new AuraHandledException(e.getMessage());
		// }
	}

	@AuraEnabled
	public static SetProfiltLoss getProfitLossSimulations(String headerId, String dept4Code, String bizType, Integer pageSize, Integer pageNum){
		SetProfiltLoss profitLossSet = new SetProfiltLoss();
		try {
			String query = '';
			query += 'SELECT Id, Name, SIMUL_VERSION__c, ';
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
			query += 'OPROFIT_07__c, OPROFIT_08__c, OPROFIT_09__c, OPROFIT_10__c, OPROFIT_11__c, OPROFIT_12__c, ';
			query += 'SUM_CONTRACT__c, SUM_REVENUE__c, SUM_PROFIT__c ';
			query += 'FROM ProfitLossSimulation__c ';
			query += 'WHERE PARENT__c = :headerId ';
			if(dept4Code != null && dept4Code != '')
				query += 'AND SALES_DEPT4__c = :dept4Code ';
			if(bizType != null && bizType != '')
				query += 'AND BUSI_TYPE1__c = :bizType ';
			query += 'ORDER BY SALES_DEPTNAME4__c ASC, ORIGIN_CUSTNAME__c ASC ';

			ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(Database.getQueryLocator(query));
			if(!Test.isRunningTest()){
				setCon.setPageSize(pageSize);
				setCon.setPageNumber(pageNum);
				profitLossSet.totalSize = setCon.getResultSize();				
			}
						
            profitLossSet.profitLoss = setCon.getRecords();
            profitLossSet.pageSize = pageSize;
            profitLossSet.currentPage = pageNum;
            
            return profitLossSet;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	public class SetProfiltLoss {
        @AuraEnabled
        public list<ProfitLossSimulation__c>	profitLoss   { get; set; }
        @AuraEnabled
        public Integer							totalSize    { get; set; }
        @AuraEnabled
        public Integer             				pageSize     { get; set; }
        @AuraEnabled
        public Integer             				currentPage  { get; set; }
    }

	@AuraEnabled
	public static AggregateResult getSimulationSum(String headerId, String dept4Code, String bizType){
		list<AggregateResult> revenueSum = new list<AggregateResult>();
		try {
			String query = 'SELECT ';
			query += 'SUM(CONTRACT_01__c) sumcon01, SUM(CONTRACT_02__c) sumcon02, SUM(CONTRACT_03__c) sumcon03, ';
			query += 'SUM(CONTRACT_04__c) sumcon04, SUM(CONTRACT_05__c) sumcon05, SUM(CONTRACT_06__c) sumcon06, ';
			query += 'SUM(CONTRACT_07__c) sumcon07, SUM(CONTRACT_08__c) sumcon08, SUM(CONTRACT_09__c) sumcon09, ';
			query += 'SUM(CONTRACT_10__c) sumcon10, SUM(CONTRACT_11__c) sumcon11, SUM(CONTRACT_12__c) sumcon12, ';
			query += 'SUM(OPROFIT_01__c) sumpro01, SUM(OPROFIT_02__c) sumpro02, SUM(OPROFIT_03__c) sumpro03, ';
			query += 'SUM(OPROFIT_04__c) sumpro04, SUM(OPROFIT_05__c) sumpro05, SUM(OPROFIT_06__c) sumpro06, ';
			query += 'SUM(OPROFIT_07__c) sumpro07, SUM(OPROFIT_08__c) sumpro08, SUM(OPROFIT_09__c) sumpro09, ';
			query += 'SUM(OPROFIT_10__c) sumpro10, SUM(OPROFIT_11__c) sumpro11, SUM(OPROFIT_12__c) sumpro12, ';
			query += 'SUM(REVENUE_01__c) sumrev01, SUM(REVENUE_02__c) sumrev02, SUM(REVENUE_03__c) sumrev03, ';
			query += 'SUM(REVENUE_04__c) sumrev04, SUM(REVENUE_05__c) sumrev05, SUM(REVENUE_06__c) sumrev06, ';
			query += 'SUM(REVENUE_07__c) sumrev07, SUM(REVENUE_08__c) sumrev08, SUM(REVENUE_09__c) sumrev09, ';
			query += 'SUM(REVENUE_10__c) sumrev10, SUM(REVENUE_11__c) sumrev11, SUM(REVENUE_12__c) sumrev12 ';
			query += 'FROM ProfitLossSimulation__c ';
			query += 'WHERE PARENT__c = :headerId ';
			if(dept4Code != null && dept4Code != '')
				query += 'AND SALES_DEPT4__c = :dept4Code ';
			if(bizType != null && bizType != '')
				query += 'AND BUSI_TYPE1__c = :bizType ';
			
			revenueSum = Database.query(query);
			
			return revenueSum[0];
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static list<Object> getBizType(String simulationId){
		list<Object> loption = new list<Object>();
		loption.add(new map<String, String>{'value'=> 'all', 'label'=>'All'});
		try {
			list<AggregateResult> lar = new list<AggregateResult>();
			lar = [SELECT MAX(Id), BUSI_TYPE1__c BIZTYPE
				   FROM ProfitLossSimulation__c
				   WHERE PARENT__c = :simulationId
				   GROUP BY BUSI_TYPE1__c 
				   ORDER BY BUSI_TYPE1__c];

			if(!lar.isEmpty()){
				for(AggregateResult ar : lar){
					String value = (String)ar.get('BIZTYPE');
					if(value != null && value != '') {
						map<String, String> option = new map<String, String>();
						option.put('value', value);
						option.put('label', value);
						loption.add(option);
					}
				}
			}
			return loption;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static list<Object> getVersion(String bizYear, String companyCode, String dept2Code, String dept3Code){
		list<Object> loption = new list<Object>();
		try {
			list<AggregateResult> lar = new list<AggregateResult>();
			lar = [SELECT MAX(Id), VERSION__c VERSION
				   FROM ProfitLossSummary__c
				   WHERE BUSI_YEAR__c = :bizYear
					AND COMPANY_CODE__c = :companyCode
					AND SALES_DEPT2__c = :dept2Code
					AND SALES_DEPT3__c = :dept3Code
				   GROUP BY VERSION__c 
				   ORDER BY VERSION__c];

			if(!lar.isEmpty()){
				for(AggregateResult ar : lar){
					String value = (String)ar.get('VERSION');
					if(value != null && value != '') {
						map<String, String> option = new map<String, String>();
						option.put('value', value);
						option.put('label', value);
						loption.add(option);
					}
				}
			}
			return loption;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}
	
	@AuraEnabled
	public static ProfitLossSimulationHeader__c createNewSimulation(
		String bizYear, String companyCode, String dept2Code, String dept3Code, 
		String nameCompany, String nameDept, String nameTeam,
		String version, String closeDate, String simulationVersion){
		try {
			list<String> dates = closeDate.split('-');
			Date fromDate = Date.newInstance(Integer.valueOf(dates[0]), Integer.valueOf(dates[1]), Integer.valueOf(dates[2]));
			list<ProfitLossSummary__c> lpls = new list<ProfitLossSummary__c>();
			String query = 'SELECT Id, Name, OwnerId, ';
			query += 'BUSI_YEAR__c, VERSION__c, REAL_FLAG2__c, COMPANY_CODE__c, COMPANY_NAME__c, BUSI_AREA__c, ';
			query += 'BUSI_AREANAME__c, OPPORTUNITY__c, OPPORTUNITY_NAME__c, REGION__c, REGION_NAME__c, ';
			query += 'SALES_DEPT1__c, SALES_DEPTNAME1__c, SALES_DEPT2__c, SALES_DEPTNAME2__c, SALES_DEPT3__c, ';
			query += 'SALES_DEPTNAME3__c, SALES_DEPT4__c, SALES_DEPTNAME4__c, SALES_DEPT5__c, SALES_DEPTNAME5__c, ';
			query += 'DEV_DEPT1__c, DEV_DEPT2__c, DEV_DEPT3__c, DEV_DEPT4__c, DEV_DEPT5__c, DEV_DEPTNAME__c, ';
			query += 'BUSI_TYPE1__c, BUSI_TYPE2__c, SOLUTION_NAME__c, ORIGIN_CUST__c, ORIGIN_CUSTNAME__c, ';
			query += 'STANDARD_CUST__c, STANDARD_CUSTNAME__c, GROUPIN_FLAG__c, DOMESTIC_FLAG__c, CURRENCY__c ';
			query += 'FROM ProfitLossSummary__c ';
			query += 'WHERE BUSI_YEAR__c = :bizYear ';
			query += 'AND COMPANY_CODE__c = :companyCode ';
			query += 'AND SALES_DEPT2__c = :dept2Code ';
			query += 'AND SALES_DEPT3__c = :dept3Code ';
			if(version != '')
				query += 'AND VERSION__c = :version ';
			query += 'LIMIT 1';
			lpls = Database.query(query);
			if(lpls.isEmpty()) throw new CustomException('no record returned');
			ProfitLossSummary__c pls = lpls[0];
			ProfitLossSimulationHeader__c plsh = new ProfitLossSimulationHeader__c(
				Name = bizYear+'-'+companyCode+'-'+dept2Code+'-'+dept3Code,
				VERSION__c = version, 
				SIMUL_VERSION__c = simulationVersion,
				CURRENCY__c = pls.CURRENCY__c != null ? pls.CURRENCY__c : '',
				BUSI_YEAR__c = pls.BUSI_YEAR__c != null ? pls.BUSI_YEAR__c : '', 
				REAL_FLAG2__c = pls.REAL_FLAG2__c != null ? pls.REAL_FLAG2__c : '', 
				COMPANY_CODE__c = pls.COMPANY_CODE__c != null ? pls.COMPANY_CODE__c : '', 
				COMPANY_NAME__c = pls.COMPANY_NAME__c != null ? pls.COMPANY_NAME__c : '', 
				BUSI_AREA__c = pls.BUSI_AREA__c != null ? pls.BUSI_AREA__c : '',
				BUSI_AREANAME__c = pls.BUSI_AREANAME__c != null ? pls.BUSI_AREANAME__c : '', 
				OPPORTUNITY__c = pls.OPPORTUNITY__c != null ? pls.OPPORTUNITY__c : '', 
				OPPORTUNITY_NAME__c = pls.OPPORTUNITY_NAME__c != null ? pls.OPPORTUNITY_NAME__c : '', 
				REGION__c = pls.REGION__c != null ? pls.REGION__c : '', 
				REGION_NAME__c = pls.REGION_NAME__c != null ? pls.REGION_NAME__c : '',
				SALES_DEPT1__c = pls.SALES_DEPT1__c != null ? pls.SALES_DEPT1__c : '', 
				SALES_DEPTNAME1__c = pls.SALES_DEPTNAME1__c != null ? pls.SALES_DEPTNAME1__c : '', 
				SALES_DEPT2__c = pls.SALES_DEPT2__c != null ? pls.SALES_DEPT2__c : '', 
				SALES_DEPTNAME2__c = pls.SALES_DEPTNAME2__c != null ? pls.SALES_DEPTNAME2__c : '', 
				SALES_DEPT3__c = pls.SALES_DEPT3__c != null ? pls.SALES_DEPT3__c : '',
				SALES_DEPTNAME3__c = pls.SALES_DEPTNAME3__c != null ? pls.SALES_DEPTNAME3__c : '', 
				SALES_DEPT4__c = pls.SALES_DEPT4__c != null ? pls.SALES_DEPT4__c : '', 
				SALES_DEPTNAME4__c = pls.SALES_DEPTNAME4__c != null ? pls.SALES_DEPTNAME4__c : '', 
				SALES_DEPT5__c = pls.SALES_DEPT5__c != null ? pls.SALES_DEPT5__c : '', 
				SALES_DEPTNAME5__c = pls.SALES_DEPTNAME5__c != null ? pls.SALES_DEPTNAME5__c : '',
				DEV_DEPT1__c = pls.DEV_DEPT1__c != null ? pls.DEV_DEPT1__c : '', 
				DEV_DEPT2__c = pls.DEV_DEPT2__c != null ? pls.DEV_DEPT2__c : '', 
				DEV_DEPT3__c = pls.DEV_DEPT3__c != null ? pls.DEV_DEPT3__c : '', 
				DEV_DEPT4__c = pls.DEV_DEPT4__c != null ? pls.DEV_DEPT4__c : '', 
				DEV_DEPT5__c = pls.DEV_DEPT5__c != null ? pls.DEV_DEPT5__c : '', 
				DEV_DEPTNAME__c = pls.DEV_DEPTNAME__c != null ? pls.DEV_DEPTNAME__c : ''
			);
			plsh.FROM_DATE__c = fromDate;
			plsh.BUSI_TYPE1__c = pls.BUSI_TYPE1__c != null ? pls.BUSI_TYPE1__c : '';
			plsh.BUSI_TYPE2__c = pls.BUSI_TYPE2__c != null ? pls.BUSI_TYPE2__c : '' ;
			plsh.SOLUTION_NAME__c = pls.SOLUTION_NAME__c != null ? pls.SOLUTION_NAME__c : ''; 
			plsh.ORIGIN_CUST__c = pls.ORIGIN_CUST__c != null ? pls.ORIGIN_CUST__c : ''; 
			plsh.ORIGIN_CUSTNAME__c = pls.ORIGIN_CUSTNAME__c != null ? pls.ORIGIN_CUSTNAME__c : '';
			plsh.STANDARD_CUST__c = pls.STANDARD_CUST__c != null ? pls.STANDARD_CUST__c : ''; 
			plsh.STANDARD_CUSTNAME__c = pls.STANDARD_CUSTNAME__c != null ? pls.STANDARD_CUSTNAME__c : ''; 
			plsh.GROUPIN_FLAG__c = pls.GROUPIN_FLAG__c != null ? pls.GROUPIN_FLAG__c : ''; 
			plsh.DOMESTIC_FLAG__c = pls.DOMESTIC_FLAG__c != null ? pls.DOMESTIC_FLAG__c : ''; 
			if(pls.CURRENCY__c != null) plsh.CurrencyIsoCode = pls.CURRENCY__c;

			insert plsh;
			return plsh;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	public static ProfitLossSimulationHeader__c getProfitLossSimulationHeader(String headerId){
		try {
			ProfitLossSimulationHeader__c plsh =
				[SELECT Id, Name, SIMUL_VERSION__c, FROM_DATE__c,
					BUSI_YEAR__c, VERSION__c, REAL_FLAG2__c, COMPANY_CODE__c, COMPANY_NAME__c, BUSI_AREA__c,
					BUSI_AREANAME__c, OPPORTUNITY__c, OPPORTUNITY_NAME__c, REGION__c, REGION_NAME__c,
					SALES_DEPT1__c, SALES_DEPTNAME1__c, SALES_DEPT2__c, SALES_DEPTNAME2__c, SALES_DEPT3__c,
					SALES_DEPTNAME3__c, SALES_DEPT4__c, SALES_DEPTNAME4__c, SALES_DEPT5__c, SALES_DEPTNAME5__c,
					DEV_DEPT1__c, DEV_DEPT2__c, DEV_DEPT3__c, DEV_DEPT4__c, DEV_DEPT5__c, DEV_DEPTNAME__c,
					BUSI_TYPE1__c, BUSI_TYPE2__c, SOLUTION_NAME__c, ORIGIN_CUST__c, ORIGIN_CUSTNAME__c,
					STANDARD_CUST__c, STANDARD_CUSTNAME__c, GROUPIN_FLAG__c, DOMESTIC_FLAG__c, CURRENCY__c 
				 FROM ProfitLossSimulationHeader__c
				 WHERE Id = :headerId
				 LIMIT 1];
			
			return plsh;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static Boolean hasOrderSummaryInSimulation(String simulationId){
		try {
			list<ProfitLossSimulation__c> lpls =
				[SELECT Id FROM ProfitLossSimulation__c
				 WHERE PARENT__c = :simulationId
				 	AND OPPORTUNITY_ID__c = null LIMIT 1000];
			if(lpls.isEmpty())
				return false;
			else
				return true;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static Boolean hasOrderOpptyInSimulation(String simulationId){
		try {
			list<ProfitLossSimulation__c> lpls =
				[SELECT Id FROM ProfitLossSimulation__c
				 WHERE PARENT__c = :simulationId
				 	AND OPPORTUNITY_ID__c != null LIMIT 1000];
			if(lpls.isEmpty())
				return false;
			else
				return true;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static Boolean importOrderSummaries(String simulationId){
		/////////////////////////////////////////////////////
		// inline code block start
		try {
			ProfitLossSimulationHeader__c plsh = getProfitLossSimulationHeader(simulationId);
			
			list<ProfitLossSummary__c> lsummary = retrieveOrderSummary(
				plsh.BUSI_YEAR__c, plsh.COMPANY_CODE__c, plsh.SALES_DEPT2__c, plsh.SALES_DEPT3__c, plsh.VERSION__c, plsh.FROM_DATE__c);
			if(!lsummary.isEmpty()){
				list<ProfitLossSimulation__c> lpls = new list<ProfitLossSimulation__c>();
				for(ProfitLossSummary__c summary : lsummary){
					lpls.add(importOrderSummary(plsh, summary));
				}
				insert lpls;
				return true;
			}
			return false;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
		// inline code block start
		/////////////////////////////////////////////////////
		// using Batch call for large set of data
		// Batch_ProfitLossImportOrderSummary batch = new Batch_ProfitLossImportOrderSummary();
		// batch.headerId = headerId;
		// DataBase.executeBatch(batch, 1000);
	}

	public static list<ProfitLossSummary__c> retrieveOrderSummary(
		String bizYear, String companyCode, String dept2Code, 
		String dept3Code, String version, Date fromDate){
		try {
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
			query += 'AND SALES_DEPT2__c = :dept2Code ';
			query += 'AND SALES_DEPT3__c = :dept3Code ';
			if(version != null && version != '')
				query += 'AND VERSION__c = :version ';

			return Database.query(query);
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	public static ProfitLossSimulation__c importOrderSummary(ProfitLossSimulationHeader__c header, ProfitLossSummary__c order){
		ProfitLossSimulation__c pl = new ProfitLossSimulation__c();
		try {
			pl.PARENT__c = header.Id;
			pl.SIMUL_VERSION__c = header.SIMUL_VERSION__c;
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

			return pl;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static Boolean importOpportunities(String simulationId){
		/////////////////////////////////////////////////////
		// inline code block start
		try {
			ProfitLossSimulationHeader__c plsh = getProfitLossSimulationHeader(simulationId);
			
			list<Opportunity> loppty = retrieveOpportunity(
				plsh.COMPANY_CODE__c, plsh.SALES_DEPT2__c, plsh.SALES_DEPT3__c, plsh.FROM_DATE__c);

			if(!loppty.isEmpty()){
				list<ProfitLossSimulation__c> lpls = new list<ProfitLossSimulation__c>();
				for(Opportunity oppty : loppty){
					lpls.add(importOpportunity(plsh, oppty));
				}
				insert lpls;
				return true;
			}
			return false;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
		// inline code block start
		/////////////////////////////////////////////////////
		// using Batch call for large set of data
		// Batch_ProfitLossImportOpportunity batch = new Batch_ProfitLossImportOpportunity();
		// batch.headerId = headerId;
		// batch.closeDate = closeDate;
		// DataBase.executeBatch(batch, 1000);
	}

	public static list<Opportunity> retrieveOpportunity(
		String companyCode, String dept2Code, String dept3Code, Date fromDate){
		try {
			list<Opportunity> loppty = 
			[SELECT Id, Name, AccountId, Amount, CurrencyIsoCode, Type, ExpectedRevenue, 
				BusinessLevel__c, BusinessType2__c, BusinessType__c, CompanyCode__c,
				CustDivision__c, CustDivision__r.Name, cOriginAcc__c, cOriginAcc__r.Name, 
				cPrimaryDeliveryDivision__c, cPrimaryDeliveryTeam__c, 
				cPrimarySalesDepartment__c, cPrimarySalesDepartment__r.Name, 
				GroupInternal__c, KoreaDomestic__c, 
				DeliveryOrganization__c, DeliveryOrganization__r.Name, DeliveryRegion__c,
				EPCompanyCode__c, OpportunityCode__c, SalesDepartment__c, 
				SalesDepartment__r.Name, SalesDepartment__r.Company__r.Name, 
				SalesDepartment__r.Node2__c, SalesDepartment__r.Text2__c, 
				SalesDepartment__r.Node4__c, SalesDepartment__r.Text4__c, 
				SalesDepartment__r.Node5__c, SalesDepartment__r.Text5__c, 
				SalesDivision__c, SalesOrganization__r.Name, SalesOrganization__r.Company__r.Name, 
				SalesRegion__c, SalesTeam__c, RecordType.Name, CloseDate, 
				(SELECT Id, Parent__c, Revenue__c, ScheduleDate__c FROM OpportunityRevenueSchedules__r)
			FROM Opportunity
			WHERE (CALENDAR_YEAR(CloseDate) = :fromDate.year()
			 		OR CALENDAR_YEAR(cRevenueStartDate__c) = :fromDate.year()
			 		OR CALENDAR_YEAR(cRevenueEndDate__c) = :fromDate.year())
			 	AND CompanyCode__c = :companyCode
				AND SalesDepartment__r.Node2__c = :dept2Code
				AND SalesDepartment__r.Node4__c = :dept3Code
				AND CloseDate >= :fromDate
				AND StageName != 'Z05'
				AND StageName != 'Z06'
				AND StageName != 'Z07'];
			return loppty;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	public static ProfitLossSimulation__c importOpportunity(ProfitLossSimulationHeader__c header, Opportunity oppty){
		ProfitLossSimulation__c pl = new ProfitLossSimulation__c();
		try {
			Integer month = Integer.valueOf(header.BUSI_YEAR__c) == oppty.CloseDate.year() ? oppty.CloseDate.month() : 0;
			String companyName = '';
			if(oppty.RecordType.Name == 'HQ'){
				companyName = oppty.SalesDepartment__c != null ? oppty.SalesDepartment__r.Company__r.Name : '';
			} else {
				companyName = oppty.SalesOrganization__c != null ? oppty.SalesOrganization__r.Company__r.Name : '';
			}
			pl.PARENT__c = header.Id;
			pl.SIMUL_VERSION__c = header.SIMUL_VERSION__c;
			pl.BUSI_YEAR__c = header.BUSI_YEAR__c;
			pl.VERSION__c = '';
			pl.REAL_FLAG2__c = '';
			pl.COMPANY_CODE__c = (oppty.CompanyCode__c != null ? oppty.CompanyCode__c : '');
			pl.COMPANY_NAME__c = companyName;
			pl.BUSI_AREA__c = '';
			pl.BUSI_AREANAME__c = '';
			pl.OPPORTUNITY__c = oppty.OpportunityCode__c;
			pl.OPPORTUNITY_ID__c = oppty.Id;
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
			if(month > 0) pl.put('CONTRACT_' + String.valueOf(month).leftPad(2, '0') + '__c', oppty.Amount);
			if(!oppty.OpportunityRevenueSchedules__r.isEmpty()){
				for(RevenueScheduleOpportunity__c rs : oppty.OpportunityRevenueSchedules__r){
					if(String.valueOf(rs.ScheduleDate__c.year()) == header.BUSI_YEAR__c){
						if(rs.ScheduleDate__c.month() == 1){
							pl.REVENUE_01__c = rs.Revenue__c != null ?  rs.Revenue__c : 0.0;
						} else if(rs.ScheduleDate__c.month() == 2){
							pl.REVENUE_02__c = rs.Revenue__c != null ?  rs.Revenue__c : 0.0;
						} else if(rs.ScheduleDate__c.month() == 3){
							pl.REVENUE_03__c = rs.Revenue__c != null ?  rs.Revenue__c : 0.0;
						} else if(rs.ScheduleDate__c.month() == 4){
							pl.REVENUE_04__c = rs.Revenue__c != null ?  rs.Revenue__c : 0.0;
						} else if(rs.ScheduleDate__c.month() == 5){
							pl.REVENUE_05__c = rs.Revenue__c != null ?  rs.Revenue__c : 0.0;
						} else if(rs.ScheduleDate__c.month() == 6){
							pl.REVENUE_06__c = rs.Revenue__c != null ?  rs.Revenue__c : 0.0;
						} else if(rs.ScheduleDate__c.month() == 7){
							pl.REVENUE_07__c = rs.Revenue__c != null ?  rs.Revenue__c : 0.0;
						} else if(rs.ScheduleDate__c.month() == 8){
							pl.REVENUE_08__c = rs.Revenue__c != null ?  rs.Revenue__c : 0.0;
						} else if(rs.ScheduleDate__c.month() == 9){
							pl.REVENUE_09__c = rs.Revenue__c != null ?  rs.Revenue__c : 0.0;
						} else if(rs.ScheduleDate__c.month() == 10){
							pl.REVENUE_10__c = rs.Revenue__c != null ?  rs.Revenue__c : 0.0;
						} else if(rs.ScheduleDate__c.month() == 11){
							pl.REVENUE_11__c = rs.Revenue__c != null ?  rs.Revenue__c : 0.0;
						} else if(rs.ScheduleDate__c.month() == 12){
							pl.REVENUE_12__c = rs.Revenue__c != null ?  rs.Revenue__c : 0.0;
						}
					}
				}
			}

			return pl;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static Boolean resetSimulation(String simulationId){
		// try {
			list<ProfitLossSimulation__c> lpls =
				[SELECT Id FROM ProfitLossSimulation__c
				 WHERE PARENT__c = :simulationId];
			if(!lpls.isEmpty()){
				delete lpls;
			}
			return false;
		// } catch (Exception e) {
		// 	throw new AuraHandledException(e.getMessage());
		// }
	}

	@AuraEnabled
	public static Boolean deleteSimulations(list<String> simulIds){
		try {
			list<ProfitLossSimulation__c> lpls =
				[SELECT Id FROM ProfitLossSimulation__c
				 WHERE Id IN :simulIds];
			if(!lpls.isEmpty()){
				delete lpls;
			}
			return false;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static Boolean calcurateProfit(list<String> simulIds, Decimal marginRate){
		/////////////////////////////////////////////////////
		// inline code block start
		try {
			list<ProfitLossSimulation__c> lpls = new list<ProfitLossSimulation__c>();
			lpls = [SELECT Id,
						REVENUE_01__c, REVENUE_02__c, REVENUE_03__c, REVENUE_04__c, REVENUE_05__c, REVENUE_06__c, 
						REVENUE_07__c, REVENUE_08__c, REVENUE_09__c, REVENUE_10__c, REVENUE_11__c, REVENUE_12__c, 
						OPROFIT_01__c, OPROFIT_02__c, OPROFIT_03__c, OPROFIT_04__c, OPROFIT_05__c, OPROFIT_06__c, 
						OPROFIT_07__c, OPROFIT_08__c, OPROFIT_09__c, OPROFIT_10__c, OPROFIT_11__c, OPROFIT_12__c 
					FROM ProfitLossSimulation__c
					WHERE Id IN :simulIds];
			if(!lpls.isEmpty()){
				for(ProfitLossSimulation__c pls : lpls){
					if(pls.REVENUE_01__c != null) pls.OPROFIT_01__c = pls.REVENUE_01__c * marginRate;
					if(pls.REVENUE_02__c != null) pls.OPROFIT_02__c = pls.REVENUE_02__c * marginRate;
					if(pls.REVENUE_03__c != null) pls.OPROFIT_03__c = pls.REVENUE_03__c * marginRate;
					if(pls.REVENUE_04__c != null) pls.OPROFIT_04__c = pls.REVENUE_04__c * marginRate;
					if(pls.REVENUE_05__c != null) pls.OPROFIT_05__c = pls.REVENUE_05__c * marginRate;
					if(pls.REVENUE_06__c != null) pls.OPROFIT_06__c = pls.REVENUE_06__c * marginRate;
					if(pls.REVENUE_07__c != null) pls.OPROFIT_07__c = pls.REVENUE_07__c * marginRate;
					if(pls.REVENUE_08__c != null) pls.OPROFIT_08__c = pls.REVENUE_08__c * marginRate;
					if(pls.REVENUE_09__c != null) pls.OPROFIT_09__c = pls.REVENUE_09__c * marginRate;
					if(pls.REVENUE_10__c != null) pls.OPROFIT_10__c = pls.REVENUE_10__c * marginRate;
					if(pls.REVENUE_11__c != null) pls.OPROFIT_11__c = pls.REVENUE_11__c * marginRate;
					if(pls.REVENUE_12__c != null) pls.OPROFIT_12__c = pls.REVENUE_12__c * marginRate;
				}
				update lpls;
			}

			return true;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static Boolean calcurateProfit(String similationId, String dept4Code, String bizType, Decimal marginRate){
		/////////////////////////////////////////////////////
		// inline code block start
		list<ProfitLossSimulation__c> lpls = new list<ProfitLossSimulation__c>();
		lpls = [SELECT Id,
					REVENUE_01__c, REVENUE_02__c, REVENUE_03__c, REVENUE_04__c, REVENUE_05__c, REVENUE_06__c, 
					REVENUE_07__c, REVENUE_08__c, REVENUE_09__c, REVENUE_10__c, REVENUE_11__c, REVENUE_12__c, 
					OPROFIT_01__c, OPROFIT_02__c, OPROFIT_03__c, OPROFIT_04__c, OPROFIT_05__c, OPROFIT_06__c, 
					OPROFIT_07__c, OPROFIT_08__c, OPROFIT_09__c, OPROFIT_10__c, OPROFIT_11__c, OPROFIT_12__c 
				FROM ProfitLossSimulation__c
				WHERE PARENT__c = :similationId
					AND SALES_DEPT4__c = :dept4Code
					AND BUSI_TYPE1__c = :bizType];
		if(!lpls.isEmpty()){
			for(ProfitLossSimulation__c pls : lpls){
				if(pls.REVENUE_01__c != null) pls.OPROFIT_01__c = pls.REVENUE_01__c * marginRate;
				if(pls.REVENUE_02__c != null) pls.OPROFIT_02__c = pls.REVENUE_02__c * marginRate;
				if(pls.REVENUE_03__c != null) pls.OPROFIT_03__c = pls.REVENUE_03__c * marginRate;
				if(pls.REVENUE_04__c != null) pls.OPROFIT_04__c = pls.REVENUE_04__c * marginRate;
				if(pls.REVENUE_05__c != null) pls.OPROFIT_05__c = pls.REVENUE_05__c * marginRate;
				if(pls.REVENUE_06__c != null) pls.OPROFIT_06__c = pls.REVENUE_06__c * marginRate;
				if(pls.REVENUE_07__c != null) pls.OPROFIT_07__c = pls.REVENUE_07__c * marginRate;
				if(pls.REVENUE_08__c != null) pls.OPROFIT_08__c = pls.REVENUE_08__c * marginRate;
				if(pls.REVENUE_09__c != null) pls.OPROFIT_09__c = pls.REVENUE_09__c * marginRate;
				if(pls.REVENUE_10__c != null) pls.OPROFIT_10__c = pls.REVENUE_10__c * marginRate;
				if(pls.REVENUE_11__c != null) pls.OPROFIT_11__c = pls.REVENUE_11__c * marginRate;
				if(pls.REVENUE_12__c != null) pls.OPROFIT_12__c = pls.REVENUE_12__c * marginRate;
			}
			update lpls;
		}

		return true;
	}

	@AuraEnabled
	public static Opportunity getOpportunity(String companyCode, String opptyCode){
		try {
			Opportunity oppty = [SELECT Id FROM Opportunity
								 WHERE CompanyCode__c = :companyCode
									AND OpportunityCode__c = :opptyCode
								 LIMIT 1];

			return oppty;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static Boolean updateRevenuePlan(ProfitLossSimulation__c pl){
		try {
			ProfitLossSimulation__c upd = new ProfitLossSimulation__c();
			upd.Id = pl.Id;
			if(pl.REVENUE_01__c != null) upd.REVENUE_01__c = pl.REVENUE_01__c;
			if(pl.REVENUE_02__c != null) upd.REVENUE_02__c = pl.REVENUE_02__c;
			if(pl.REVENUE_03__c != null) upd.REVENUE_03__c = pl.REVENUE_03__c;
			if(pl.REVENUE_04__c != null) upd.REVENUE_04__c = pl.REVENUE_04__c;
			if(pl.REVENUE_05__c != null) upd.REVENUE_05__c = pl.REVENUE_05__c;
			if(pl.REVENUE_06__c != null) upd.REVENUE_06__c = pl.REVENUE_06__c;
			if(pl.REVENUE_07__c != null) upd.REVENUE_07__c = pl.REVENUE_07__c;
			if(pl.REVENUE_08__c != null) upd.REVENUE_08__c = pl.REVENUE_08__c;
			if(pl.REVENUE_09__c != null) upd.REVENUE_09__c = pl.REVENUE_09__c;
			if(pl.REVENUE_10__c != null) upd.REVENUE_10__c = pl.REVENUE_10__c;
			if(pl.REVENUE_11__c != null) upd.REVENUE_11__c = pl.REVENUE_11__c;
			if(pl.REVENUE_12__c != null) upd.REVENUE_12__c = pl.REVENUE_12__c;
			update upd;

			return true;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	public class CustomException extends Exception{}
}