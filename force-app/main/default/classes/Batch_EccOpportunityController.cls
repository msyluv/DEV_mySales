/**
 * @description       : 
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-05-04
 * @last modified by  : ghkil@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                            Modification
 * 1.0   2020-12-02   ghkil@partner.samsung.com         Initial Version
 * 1.1   2020-12-24   ghkil@partner.samsung.com         Start 쿼리에 Id 조건 추가
 * 1.2   2020-12-28   ghkil@partner.samsung.com         Department__c 조회 시 Key값(CostCenter + 99991231 + CompanyCode)에 맞게 수정
 * 1.3   2020-12-28   ghkil@partner.samsung.com         항목 추가 (2020-12-28 정의서 반영)
 * 1.4   2021-01-12   ghkil@partner.samsung.com         항목 추가 (2021-01-11 정의서 반영, 메인 기준), Opportunity Activity Code 오류 수정, BIG_ACCOUNT_YN 체크 관련 보완(KRW이 아닌 경우 KRW로 환산 처리)
 * 1.5   2021-01-14   ghkil@partner.samsung.com         금액(Decimal Type) 표기 과학적(지수)표기 되지 않도록 처리
 * 1.6   2021-01-21   ghkil@partner.samsung.com         Queueable로 인해 DataBase.Stateful을 사용하지 못하는 Batch 처리에 대한 Log 처리 수정 (Start, Excute, End 각각 나눠 기록)
 * 1.6   2021-01-25   kilhwan.an@partner.samsung.com    epcompany값이 있는 데이터 내역만
 * 1.7   2021-01-26   ghkil@partner.samsung.com         Opportunity/RevenueScheduleOpportunity__c정보 추가(정의서 2021.01.25 IF-094 기준), 개발 후 적용 전(주석 처리)
 * 1.8   2021-01-26   ghkil@partner.samsung.com         협업여부 항목에 대한 값 조건 보완 (Collaboration__c, IsOriginal__c가 모두 true인 경우만 Y처리)
 * 1.9   2021-01-26   ghkil@partner.samsung.com         Queueable 제거하고 Business Ligic을 IF_EccOpportunityController를 호출하여 처리
 * 1.91  2021-02-03   ghkil@partner.samsung.com         생성자를 통해 처리할 List 조건 추가
 * 1.92  2021-02-25   ghkil@partner.samsung.com         Batch Log 생성 시 ApexMethod 추가 (JobId 제거)
**/
global class Batch_EccOpportunityController  implements DataBase.stateful, DataBase.Batchable<SObject>, DataBase.AllowsCallouts, Schedulable {
 
    private static final String INTERFACE_ID = 'IF-125';
    private static final String APEX_CLASS   = 'Batch_EccOpportunityController'; 
    private static final String METHOD_NAME  = 'Batch';

    public Date BATCH_CONDITION = null; // 배치 처리 조건 (최초 3일 전부터 조회)
       
    private static final Boolean DEBUG_FLAG = IF_Util.DEBUG_FLAG;

    private static String guId = IF_Util.generateGuid();

    public List<String> selectIdList = new List<String>();

    public Batch_EccOpportunityController() {    }

    // public Batch_EccOpportunityController(List<String> selectIdList) {    
    //     this.selectIdList = selectIdList;
    // }

    public DataBase.QueryLocator start(DataBase.BatchableContext BC){

        IF_Log ifStartLog = new IF_Log();
        IF_Log.BatchLog batchStartLog;
        List<String> startErrorMsgList = new List<String>();

        ifStartLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Start:' + BC.getJobId() + ') 시작' + ' ####################');

        String queryString;
        Database.QueryLocator returnScope;

        // 기본 쿼리 검색
        try{

            if(BATCH_CONDITION == null) BATCH_CONDITION = Date.today().addDays(-3);

            queryString = IF_EccOpportunityController.QUERY_STRING + ' And   Systemmodstamp   >= :BATCH_CONDITION ';

            System.debug('# selectIdList ' + selectIdList);
            if (selectIdList.size() > 0) {
                queryString = queryString + ' And    Id IN :selectIdList ';
            }

//            Organization org = [ SELECT Id, isSandBox FROM Organization];
//
//            if( org.IsSandbox && org.Id != '00D1s0000008pnsEAA'){       // Dev Id 제외 (00D1s0000008pnsEAA)
//
//                // 10, 50, 100, 200, 300, 400, 500
//                //queryString = queryString + ' AND CreatedById = \'0051s000000zvP1AAI\' ' ;
//                queryString += ' ORDER BY Systemmodstamp DESC LIMIT 10 ';
//            }

            queryString = queryString + 'ALL ROWS ';

            System.debug('# queryString ' + queryString);
            returnScope = DataBase.getQueryLocator(queryString);

            ifStartLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Start:' + BC.getJobId() + ') 종료' + ' ####################');
                          
            batchStartLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Start', '', 0);
            
            ifStartLog.createLog(batchStartLog);
        }catch(Exception e){

            batchStartLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Start', '', 0, 0, e);
            startErrorMsgList.add('Batch exception : ' + e.getMessage());

            ifStartLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Start:' + BC.getJobId() + ') 종료' + ' ####################');

            ifStartLog.createLog(batchStartLog);
        }

        return returnScope;
    }
    
    public void execute(DataBase.BatchableContext BC, List<Opportunity> scopeList){
        IF_Log ifExcuteLog = new IF_Log();
        IF_Log.BatchLog batchExcuteLog;
        List<String> excuteErrorMsgList = new List<String>();

        ifExcuteLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Excute:' + BC.getJobId() + ') 시작' + ' ####################');

        String reqMsg = '';
        String resMsg = '';

        Map<String, Object> result = new Map<String,Object>();

        try {

            if (DEBUG_FLAG) ifExcuteLog.addLog('scopeList.size() : ' + scopeList.size());
            system.debug('처리 대상 : ' + scopeList.size());

            // *************************************
            // Opportunity 상세정보 정보 가져오기
            // *************************************
            IF_EccOpportunityController.OutputHeader outHeader = IF_EccOpportunityController.getOpportunityDetailInfo(scopeList);

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
                HttpResponse hRes = (HttpResponse)result.get('HttpResponse');

                ifExcuteLog.addLog('HttpResponse getBody : ' + hRes.getBody());

                // recHeader = (ReceiveHeader) JSON.deserialize(hRes.getBody(), ReceiveHeader.class); 
                ifExcuteLog.addLog('recHeader : ' + hRes.getBody());

                batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Excute', reqMsg, outHeader.OPPORTUNITY.size());
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

            batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Excute', reqMsg, 0, 0, e);

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
    public void execute( SchedulableContext SC){
        DataBase.executeBatch( new Batch_EccOpportunityController(), 50);
    }
}