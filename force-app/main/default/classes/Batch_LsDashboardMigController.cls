/**
 * @description       : 
 * @author            : raeganja@partner.samsung.com
 * @group             : 
 * @last modified on  : 2023-04-27
 * @last modified by  : saurav.k@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   2021-05-26   raeganja@partner.samsung.com   Initial Version
 * 1.1   2023-04-27   saurav.k@partner.samsung.com   (MySales -171) -IF-042(Send Service/Solution Info to Legacy) modification
**/
global class Batch_LsDashboardMigController implements DataBase.stateful, DataBase.Batchable<SObject>, DataBase.AllowsCallouts, Schedulable {
    
    private final String INTERFACE_ID = 'IF-042';
    private final String APEX_CLASS   = 'Batch_LsDashboardMigController';
    private final String METHOD_NAME  = 'Batch';

    public Date  BATCH_CONDITION = null; // 배치 처리 조건

    private static final Boolean DEBUG_FLAG = false;    

    private static String guId = IF_Util.generateGuid();

    public Batch_LsDashboardMigController() { }

    public DataBase.QueryLocator start(DataBase.BatchableContext BC){

        IF_Log ifStartLog = new IF_Log();
        IF_Log.BatchLog batchStartLog;
        List<String> startErrorMsgList = new List<String>();

        ifStartLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Start:' + BC.getJobId() + ') 시작' + ' ####################');

        String queryString;
        Database.QueryLocator returnScope;

        // 기본 쿼리 검색  
        try{

            List<MigOppCode__c> migOppCdList = [

                SELECT Id 
                      ,Name                 // ID
                      ,OpportunityCode__c
                FROM   MigOppCode__c
                WHERE  Systemmodstamp = today
                AND    Send_Check__c  = false
                AND    InterfaceId__c = 'IF-042'               
            ];

            Set<String> oppIdSet = new Set<String>();
            for( MigOppCode__c migOpp : migOppCdList){

                oppIdSet.add( migOpp.Name);
            }

            if(BATCH_CONDITION == null) BATCH_CONDITION = Date.today().addDays(-3);// 현재일의 기준 3일 전 데이터 처리

            queryString = 'Select Id ' +		 
            '       , Opportunity__r.Id ' +                      // 사업기회ID
            '       , Opportunity__r.OpportunityCode__c ' +      // 사업기회Code
            '       , Opportunity__r.Name ' +                    // 사업기회명
            '       , ItemNumber__c ' +                          // Item Number
			'       , sService__c ' +                           // 마스터 서비스 Id
            '       , sService__r.Name ' +                      // 서비스명
            '       , sService__r.Code__c ' +                   // 서비스코드
            '       , Service__c ' +                             // 마스터 서비스 Id
            '       , Service__r.Name ' +                        // 서비스명
            '       , Service__r.Code__c ' +                     // 서비스코드
            '       , Opportunity__r.CompanyCode__c ' +          // Company Code
            '       , Opportunity__r.EPCompanyCode__c ' +        // EPCompanyCode__c
            '       , Opportunity__r.CloseDate ' +
            '       , SalesDepartment__r.CostCenter__c ' +       // 수주부서 코스트센터
            '       , DeliveryDepartment__r.CostCenter__c ' +    // 개발부서 코스트센터
			'       , sSalesDepartment__r.CostCenter__c ' +
            '       , sDeliveryDepartment__r.CostCenter__c ' +
            '       , LastModifiedDate '+                        // 서비스 최종수정일
            '       , SendSAP__c '+                             // SAP 전송여부
			'       , TechAttribute__c ' +                       // Tech Attribute
            'From   Service__c ' + 
            // 'Where  SendSAP__c = true ' +
            'WHERE    sDeletionFlag__c = false ' +
            'AND    Opportunity__r.Id IN :oppIdSet ' +
              'AND  SendSAP__c = true ';// V1.1 -> MySales -171

            returnScope = DataBase.getQueryLocator(queryString);

            ifStartLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Start:' + BC.getJobId() + ') 종료' + ' ####################');
                          
            batchStartLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Start', '', 0);
            
            ifStartLog.createLog(batchStartLog);

        } catch(Exception e){

            batchStartLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Start', '', 0, 0, e);
            startErrorMsgList.add('Batch exception : ' + e.getMessage());

            ifStartLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Start:' + BC.getJobId() + ') 종료' + ' ####################');

            ifStartLog.createLog(batchStartLog);
        }
        return returnScope;
    }

    public void execute(DataBase.BatchableContext BC, List<Service__c> scopeList){
        
        IF_Log ifExcuteLog = new IF_Log();
        IF_Log.BatchLog batchExcuteLog;
        List<String> excuteErrorMsgList = new List<String>();

        ifExcuteLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Excute:' + BC.getJobId() + ') 시작' + ' ####################');

        IF_LsDashboardController.ReceiveHeader recHeader;

        String reqMsg = '';
        String resMsg = '';

        Map<String, Object> result = new Map<String,Object>();

        // ifExcuteLog.addLog('처리 대상(Service 기준) : ' + scopeList.size());
        // system.debug('처리 대상(Service 기준) : ' + scopeList.size());

        IF_LsDashboardController.OutputHeader outHeader = IF_LsDashboardController.getDashboardDetailInfo(scopeList,null);

        if (DEBUG_FLAG) ifExcuteLog.addLog('Service 처리 건수 : ' + outHeader.BO_SERVICE.size());
        if (DEBUG_FLAG) ifExcuteLog.addLog('Solution 처리 건수 : ' + outHeader.BO_SOLUTION.size());

        try {

            // 관련정보 Callout 처리
            // Callout 처리
            IF_Callout ifCallout = new IF_Callout(INTERFACE_ID);
            result = ifCallout.httpCallout(JSON.serialize(outHeader), '');
            system.debug('CallOut Result' + ' / ' + result);

            reqMsg = String.valueOf(result.get('Request'));
            resMsg = String.valueOf(result.get('Response'));
            
            // Batch는 Request 정보가 길어 주석 처리
            // if (DEBUG_FLAG) ifExcuteLog.addLog('Request : '  + reqMsg);     

            ifExcuteLog.addLog('StatusCode : '  + String.valueOf(result.get('StatusCode')));
            ifExcuteLog.addLog('HttpResponse : '+ String.valueOf(result.get('HttpResponse')));
            // if (DEBUG_FLAG) ifLog.addLog('Log : '         + String.valueOf(result.get('Log')));
            // if (DEBUG_FLAG) ifLog.addLog('Message : '     + String.valueOf(result.get('Message')));
           
            Integer resStatusCode = (Integer)result.get('StatusCode');

            if (resStatusCode != null && (resStatusCode == 200 || resStatusCode == 202)) {
                Set<String> oppCodeSet = new Set<String>();
                for( Service__c serviceData : scopeList){

                    oppCodeSet.add( serviceData.Opportunity__r.Id);
                }

                List<MigOppCode__c> migOppList = [
                    
                    SELECT Id 
                          ,Name                 // ID
                          ,OpportunityCode__c
                          ,Send_Check__c
                    FROM  MigOppCode__c
                    WHERE InterfaceId__c = 'IF-042'
                    AND   Name IN :oppCodeSet
                ];

                for( MigOppCode__c migOpp : migOppList){

                    migOpp.Send_Check__c = true;
                }

                update migOppList;

                HttpResponse hRes = (HttpResponse)result.get('HttpResponse');

                ifExcuteLog.addLog('HttpResponse getBody : ' + hRes.getBody());
                ifExcuteLog.addLog('마이그 update : ' + migOppList.size() + ' 전송건수:'  + outHeader.BO_SERVICE.size());
                ifExcuteLog.addLog('recHeader : ' + hRes.getBody());

                batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Excute', reqMsg, outHeader.BO_SERVICE.size());
            } else {
                ifExcuteLog.addLog('Communication Error : ' + String.valueOf(result.get('Message')) + ' / StatusCode : ' + String.valueOf(resStatusCode));
                excuteErrorMsgList.add('Communication Error : ' + String.valueOf(result.get('Message')) + ' / StatusCode : ' + String.valueOf(resStatusCode));

                batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Excute', reqMsg, 0, 0, excuteErrorMsgList);
            }

            // 로그 남기기
            ifExcuteLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Excute:' + BC.getJobId() + ') 종료' + ' ####################');

            ifExcutelog.createLog(batchExcuteLog);
        } catch (Exception e) {
            ifExcuteLog.addLog('Exception : ' + e.getStackTraceString());
            excuteErrorMsgList.add('Exception : ' + e.getMessage());

            batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Excute', '', 0, 0, e);

            ifExcuteLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Excute:' + BC.getJobId() + ') 종료' + ' ####################');            

            ifExcutelog.createLog(batchExcuteLog);
        }
    }

    public void finish(DataBase.BatchableContext BC){
        IF_Log ifFinishLog = new IF_Log();
        IF_Log.BatchLog batchFinishLog;
        List<String> finishErrorMsgList = new List<String>();

        ifFinishLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Finish:' + BC.getJobId() + ') 시작' + ' ####################');

        batchFinishLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Finish', '', 0);

        ifFinishLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Finish:' + BC.getJobId() + ') 종료' + ' ####################');

        ifFinishLog.createLog(batchFinishLog);
    }

    // 스케줄 호출
    public void execute(SchedulableContext SC){

        DataBase.executeBatch(new Batch_LsDashboardMigController(), 2000);
    }
}