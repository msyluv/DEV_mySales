global class Batch_IF040_Automation implements DataBase.stateful, DataBase.Batchable<SObject>, DataBase.AllowsCallouts, Schedulable {
	private final String INTERFACE_ID = 'IF-040-Automation';
	private final String APEX_CLASS = 'Batch_IF040_Automation';
	private final String METHOD_NAME = 'Batch';
	//private static Map<String,String> oppId = new Map<String,String>();
	Map<Opportunity, Opportunity_Activity__c> oppId;
	List<Id> lstId;
	List<String> lstOppCode;
	Map<String, List<Solution__c>> solActiveList;

	public Date BATCH_CONDITION = null; // 배치 처리 조건

	private static final Boolean DEBUG_FLAG = false;

	private static String guId = IF_Util.generateGuid();

	public Batch_IF040_Automation() {
		oppId = new Map<Opportunity, Opportunity_Activity__c>();
		solActiveList = new Map<String, List<Solution__c>>();
		lstId = new List<Id>();
		lstOppCode = new List<String>();
	}

	public DataBase.QueryLocator start(DataBase.BatchableContext BC) {
		IF_Log ifStartLog = new IF_Log();
		IF_Log.BatchLog batchStartLog;
		List<String> startErrorMsgList = new List<String>();

		ifStartLog.addLog('#################### ' + INTERFACE_ID +' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Start:' + BC.getJobId() + ') 시작' + ' ####################');

		String queryString;
		Database.QueryLocator returnScope;

		// 기본 쿼리 검색
		try {
			if (BATCH_CONDITION == null)
				BATCH_CONDITION = Date.today().addDays(-3); // 현재일의 기준 3일 전 데이터 처리

			queryString =
				'SELECT Id' +
				',Name' +
				',OpportunityCode__c ' +
				'FROM   MigOppCode__c ' +
				'WHERE  SystemModstamp  = Today ' +
				'AND    Send_Check__c  = false ' +
				'AND    InterfaceId__c = \'IF-040\' ';

			returnScope = DataBase.getQueryLocator(queryString);
			System.debug('returnScope MigOpp ' + returnScope);

			ifStartLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Start:' + BC.getJobId() + ') 종료' + ' ####################');

			batchStartLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Start', '', 0);

			ifStartLog.createLog(batchStartLog);
		} catch (Exception e) {
			batchStartLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Start', '', 0, 0, e);
			startErrorMsgList.add('Batch exception : ' + e.getMessage());

			ifStartLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Start:' + BC.getJobId() + ') 종료' + ' ####################' );

			ifStartLog.createLog(batchStartLog);
		}
		return returnScope;
	}

	public void execute(DataBase.BatchableContext BC, List<MigOppCode__c> scopeList) {
		IF_Log ifExcuteLog = new IF_Log();
		IF_Log.BatchLog batchExcuteLog;
		List<String> excuteErrorMsgList = new List<String>();
		Opportunity_Activity__c opptyAct = new Opportunity_Activity__c();
		
		Opportunity opp = [
			SELECT
				Id,
				CompanyCode__c,
				BusinessType__c,
				Opportunity_Review_VRB_Type_Confirm__c,
				CollaborationBOId__c,
				CollaborationBOId__r.BusinessType__c,
				Collaboration__c
			FROM Opportunity
			WHERE Id = :scopeList[0].Name
		];

		opptyAct = [
			SELECT
				Id,
				Name,
				Status__c,
				StartDate__c,
				DueDate__c,
				EndDate__c,
				ExtId__c,
				WhatId__c,
				WhatId__r.OpportunityCode__c,
				TransactionName__c,
				WhatId__r.CompanyCode__c,
				WhatId__r.GroupInternal__c
			FROM Opportunity_Activity__c
			WHERE WhatId__c = :scopeList[0].Name AND TransactionName__c = :OpportunityActivityHelper.ACT_CODE_REVIEW_BO
			ORDER BY CreatedDate DESC
			LIMIT 1
		];
												  
		Map<String, Object> resultMap = new Map<String, Object>();
		System.debug('Ani scopeList[0].Name ' + scopeList[0].Name);
		resultMap = IF_040_Automation.Project_WBS(scopeList[0].Name);
		System.debug('returnScope MigOpp result ' + resultMap.get('MSG'));
		String compCode = opp.CompanyCode__c;
		//System.debug('returnScope MigOpp Company Code '+ resultMap.get('Company Code'));

		List<MigOppCode__c> migOppList = new List<MigOppCode__c>();
		try {
			if (resultMap.get('MSG') == 'S' || Test.isRunningTest()) {
				migOppList = [
					SELECT Id, Name, OpportunityCode__c, Send_Check__c
					FROM MigOppCode__c
					WHERE InterfaceId__c = 'IF-040' AND Name = :scopeList[0].Name
				];

				for (MigOppCode__c migOpp : migOppList) {
					migOpp.Send_Check__c = true;
				}
				oppId.put(opp, opptyAct);
				// solActiveList.put(migOppList[0].Name , lSolList);
				lstId.add(migOppList[0].Name);
				lstOppCode.add(migOppList[0].OpportunityCode__c);
				update migOppList;
			}

			batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Execute', '', 0);
			// 로그 남기기
			ifExcuteLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Excute:' + BC.getJobId() + ') 종료' + migOppList[0].OpportunityCode__c + ', Result -' + resultMap.get('MSG'));

			ifExcutelog.createLog(batchExcuteLog);
		} catch (Exception e) {
			ifExcuteLog.addLog('Exception : ' + e.getStackTraceString());
			excuteErrorMsgList.add('Exception : ' + e.getMessage());

			batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Excute', '', 0, 0, e);

			ifExcuteLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Excute:' + BC.getJobId() + ') 종료' + ' ####################');

			ifExcutelog.createLog(batchExcuteLog);
		}
		
	}

	public void finish(DataBase.BatchableContext BC) {
		System.debug('Update 040 oppId' + oppId);
		System.debug('Update 040 solActiveList' + solActiveList);
		System.debug('Update 040 lstId' + lstId);
		List<Solution__c> lSol = new List<Solution__c>();
		List<Solution__c> lSolList = new List<Solution__c>();
		List<Opportunity> lstOpp = new List<Opportunity>();
		Map<Id, List<Solution__c>> mapSol = new Map<Id, List<Solution__c>>();
		lSol = [
			SELECT
				Id,
				Name,
				ItemNumber__c,
				WBSCode__c,
				Service__r.Service__r.Code__c,
				Solution__r.Code__c,
				BizAttribute__r.Code__c,
				WBSClass__c,
				DeletionFlag__c,
				BusinessType__c,
				Service__r.TechAttribute__c,
				Opportunity__c
			FROM Solution__c
			WHERE Opportunity__c IN :lstId AND SendSAP__c = TRUE
		];
		for (Solution__c sol : lSol) {
			if (!mapSol.containsKey(sol.Opportunity__c)) {
				mapSol.put(sol.Opportunity__c, new List<Solution__c>{ sol });
			} else {
				mapSol.get(sol.Opportunity__c).add(sol);
			}
		}
		System.debug('mapSol Ani' + mapSol);

		for (Id oppId : mapSol.keySet()) {
			String bizType = 'TS';
			Opportunity opp = new Opportunity();
			opp.Id = oppId;
			for (Solution__c obj : mapSol.get(oppId)) {
				if (obj.BusinessType__c == 'TI') {
					bizType = 'TI';
					break;
				} else if (obj.BusinessType__c == 'TD') {
					bizType = 'TD';
				}
			}
			opp.BusinessType__c = bizType;
			lstOpp.add(opp);
		}

		System.debug('lstOpp Ani' + lstOpp);

		if (lstOpp.Size() > 0) {
			Database.Update(lstOpp, false);
		}

		IF_040_Automation.upsertOpportunityActivity(oppId, 'Completed');
		
		IF_Log ifFinishLog = new IF_Log();
		IF_Log.BatchLog batchFinishLog;
		List<String> finishErrorMsgList = new List<String>();

		batchFinishLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Finish', '', 0);

		ifFinishLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Finish:' + BC.getJobId() + ') ' + ' Opportunity BO Code List - ' + lstOppCode);

		ifFinishLog.createLog(batchFinishLog);
	}

	// 스케줄 호출
	public void execute(SchedulableContext SC) {
		DataBase.executeBatch(new Batch_IF040_Automation(), 1);
	}
}