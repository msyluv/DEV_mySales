/**
 * @description       : 
 * @author            : raeganja@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-04-21
 * @last modified by  : raeganja@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   2021-01-13   raeganja@partner.samsung.com   Initial Version
 * 1.1   2021-04-21   raeganja@partner.samsung.com   acct.AccountNumber -> acct.Id 로 변경
**/
@RestResource( UrlMapping='/IF021/*')
global class IF_RpaGetAcctHistoryInfoController implements Schedulable{
    private static final String INTERFACE_ID = 'IF-021';
    private static final String APEX_CLASS   = 'IF_RpaGetAcctHistoryInfoController';
    private static final String METHOD_NAME  = 'getAcctHistoryInfo';

    @HttpPost
    global static OutputHeader receiveAcctHistoryInfo(){
        // 로그 정보
        String              guId      = IF_Util.generateGuid();
        OutputHeader        outHeader = new OutputHeader();
        IF_Log              log       = new IF_Log();
        IF_Log.InterfaceLog infLog    = null;

        // RequestBody 데이터 확인
        RestRequest req = RestContext.request;
        Blob    reqBody = req.requestBody;
        RestResponse rep= RestContext.response;
        rep.addHeader('Content-Type', 'application/json');

        try{
            outHeader.EV_RESULT      = IF_Util.RESULT_STATUS_SUCCESS;
            outHeader.EV_MESG        = IF_Util.RESULT_MESSAGE_SUCCESS;

            // 데이터 존재 하는지 여부 확인
            Map<String,Object> bodyMap =( Map<String, Object>) JSON.deserializeUntyped( reqBody.toString());
            if( bodyMap == null){

                outHeader.EV_RESULT = IF_Util.RESULT_MESSAGE_ERROR;
                outHeader.EV_MESG   = 'No Data';

                infLog = new IF_Log.InterfaceLog( INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqBody.toString(), JSON.serialize(outHeader));
                log.createLog( infLog);
                return outHeader;
            }

            // 사업자 번호 기준으로 Account 정보를 읽어옴
            // Map<String,Id> accMap  = new Map<String,Id>();
            String              ifKey         = Util_String.nvlStr(bodyMap.get('IF_KEY'));
            String              endData       = Util_String.nvlStr(bodyMap.get('END_DATA'));
            List<Object>        dataList      = (List<Object>)bodyMap.get('IT_DATA');
            Set<String>         accCorpNumSet = new Set<String>();
            Map<String, List<Map<String, Object>>> accHistoryMap    = new Map<String, List<Map<String, Object>>>();
            for(Object obj : dataList) {

                Map<String,Object> objMap = (Map<String,Object>) obj;
                String custRegNo = objMap.get('BizRegNo') + '';
                accCorpNumSet.add( custRegNo);

                List<Map<String, Object>> objListMap = accHistoryMap.get(custRegNo);
                if(objListMap == null){
                    objListMap = new List<Map<String, Object>>();
                } 
                
                objListMap.add(objMap);
                
                accHistoryMap.put( custRegNo, objListMap);
            }

            // 데이터 등록 처리
            List<Account> accList = [SELECT id, CorporateNumber__c, AccountNumber From Account where CorporateNumber__c in :accCorpNumSet];
            List<AccountHistory__c> acctHistoryList = new List<AccountHistory__c>();
            for(Account acct : accList){               

                //Map<String, Object> objMap = (Map<String, Object>)accHistoryMap.get( acct.CorporateNumber__c);
                List<Map<String, Object>> objListMap = (List<Map<String, Object>>)accHistoryMap.get( acct.CorporateNumber__c);

                for(Map<String, Object> objMap : objListMap){
                    AccountHistory__c acctHistory = new AccountHistory__c();

                    String bizRegNo                     = Util_String.nvlStr(objMap.get('BizRegNo'));
                    String infoSource                   = Util_String.nvlStr(objMap.get('InfoSource'));                    
                    String historyDate                  = Util_String.nvlStr(objMap.get('HistoryDate'));
                    String description                  = Util_String.nvlStr(objMap.get('Description'));

                    acctHistory.Account__c              = acct.Id;
                    acctHistory.BizRegNo__c             = bizRegNo;
                    acctHistory.InformationSource__c    = infoSource;
                    acctHistory.HistoryDate__c          = historyDate;
                    acctHistory.Description__c          = description;           

                    //삭제를 위한 Key값
                    //acctHistory.ifKey__c                = ifKey;
                    //acctHistory.DeleteExtId__c          = acct.AccountNumber + '_' + bizRegNo +'_'+ infoSource;
                    //acctHistory.ExternalId__c           = acct.AccountNumber + '_' + bizRegNo +'_'+ infoSource +'_'+ historyDate;
                    acctHistory.DeleteExtId__c          = acct.Id + '_' + bizRegNo +'_'+ infoSource;
                    acctHistory.ExternalId__c           = acct.Id + '_' + bizRegNo +'_'+ infoSource +'_'+ historyDate;
                    acctHistoryList.add(acctHistory);
                }
            }

            upsert acctHistoryList ExternalId__c;
            outHeader.TOTAL_COUNT = acctHistoryList.size();
            outHeader.EV_RESULT      = IF_Util.RESULT_STATUS_SUCCESS;
            outHeader.EV_MESG        = IF_Util.RESULT_MESSAGE_SUCCESS;

            // 로그 객체 생성
            infLog = new IF_Log.InterfaceLog( INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqBody.toString(), JSON.serialize(outHeader));

            if(String.isNotBlank(endData) && endData.equals('Y')){
                Batch_AcctHistoryInfoDeleteController controller = new Batch_AcctHistoryInfoDeleteController();
                //controller.ifKey = ifKey;
                DataBase.executeBatch( controller, 100);
            }
        } catch(Exception e){

            outHeader.EV_RESULT      = IF_Util.RESULT_STATUS_ERROR;
            outHeader.EV_MESG        = IF_Util.RESULT_MESSAGE_ERROR + ' |' + e.getMessage();
            infLog = new IF_Log.InterfaceLog( INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqBody.toString(), JSON.serialize(outHeader),e);
        }
        log.createLog( infLog);
        return outHeader;
    }

    // Callout 처리
    @Future( Callout=true)
    global static void getAcctHistoryInfo( String reqDate){
        // 로그 변수
        String      guId = IF_Util.generateGuid();
        IF_Callout  call = new IF_Callout( INTERFACE_ID);
        IF_Log      log  = new IF_Log();
        IF_Log.InterfaceLog ifLog;

        // 검색할 년월일, json 변환
        Map<String,String> reqMap = new Map<String,String>();
        reqMap.put('Search_Date' , reqDate);
        String jsonBody = JSON.serialize(reqMap);

        try{

            // callout
            Map<String, Object> rtnMap = call.httpCallout(jsonBody, '');
            String statusCode = rtnMap.get( 'StatusCode') + '';
            ifLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, jsonBody, 'Async(' + statusCode + ')');
        }catch( Exception e){

            ifLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, jsonBody, 'Async',e);
        }
        log.createLog( ifLog);
    }

    global void execute( SchedulableContext SC){

        Date   toDt     = Date.today().addDays( -1);
        String regDate  = Util_String.convertDateString( toDt);
        getAcctHistoryInfo ( regDate);
    }

    // 전달 값: JitterBit
    global class OutputHeader{

        @AuraEnabled
        public Integer TOTAL_COUNT = 0; // 전체 데이터 건수
        @AuraEnabled
        public String EV_RESULT = ''; // 처리 결과
        @AuraEnabled
        public String EV_MESG = ''; // 처리 메세지
        @AuraEnabled
        public List<OutputClass> DATA; // 데이터 포멧
    }

    public class OutputClass{ }
}