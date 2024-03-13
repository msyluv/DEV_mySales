/**
 * @description       : 
 * @author            : raeganja@partner.samsung.com
 * @group             : 
 * @last modified on  : 2020-12-29
 * @last modified by  : ghkil@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   2020-12-11   raeganja@partner.samsung.com   Initial Version
 * 1.1   2020-12-22   kilhwan.an@partner.samsung.com   Opportunity Activity 만큼 데이터 생성
**/
@RestResource( urlMapping= '/IF003/*')
global class IF_EccProjectStrategySessionController {
    private static final String INTERFACE_ID = 'IF-003';
    private static final String APEX_CLASS   = 'IF_EccProjectStrategySessionController';
    private static final String METHOD_NAME  = 'getProjectStrategySession';

    private static final Boolean DEBUG_FLAG = true;
/*
{
  "DATA": [
    {
      "IV_BUKRS": "T100",
      "IV_ZZORDER_ID": "SDS-20054670",
      "I_PROCESSTYPE": "ZP61"
    }
  ]
}
 */
    
    @HttpPost
    global static void getProjectStrategySession() {
        String guId = IF_Util.generateGuid();

        OutputHeader outHeader   = new OutputHeader();
        outHeader.DATA           = new List<OutputClass>();
        OutputClass outClass     = new OutputClass();
        outHeader.TOTAL_COUNT    = 0;
        outHeader.EV_RESULT      = 'S';
        outHeader.EV_MESG        = '';

        IF_Log ifLog;
        IF_Log.InterfaceLog interfaceLog;
        List<String> errorMsgList = new List<String>();

        ifLog = new IF_Log();
        ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 시작' + ' ####################');

        // RequestBody 데이터 확인
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestRequest req = RestContext.request;
        Blob    reqBody = req.requestBody;

        if( reqBody == null) {
            RestContext.response.responseBody = Blob.valueOf( JSON.serialize(outHeader));
            return; 
        }
        if (DEBUG_FLAG) ifLog.addLog('데이터 수신');

        // 데이터 파싱
        String inputJsonData = reqBody.toString(); //.escapeJava();
        ifLog.addLog('HttpRequest : ' + inputJsonData);
        system.debug('HttpRequest : ' + inputJsonData);        
        InputHeader     inputHeader = (InputHeader) JSON.deserialize( inputJsonData, InputHeader.class);
        List<InputClass> dataList   = inputHeader.DATA;
        if( dataList == null || dataList.size() == 0){
            RestContext.response.responseBody = Blob.valueOf( JSON.serialize( outHeader));   
            return; 
        } 
        if (DEBUG_FLAG) ifLog.addLog('데이터 파싱');

        // 1) 해당정보 반영
        Savepoint sp = Database.setSavepoint();        
        String sendData;

        try {
            // 검색조건값
            InputClass inClass      = dataList.get( 0);
            String companyCode      = inClass.IV_BUKRS;
            String opportunityCode  = inClass.IV_ZZORDER_ID;
            String activityStatus   = inClass.I_PROCESSTYPE;

            // 1) Opportunity 검색
            String query = 'SELECT Id, OpportunityCode__c, CompanyCode__c, BusinessType__c, BiddingMethod__c, ActivityStatus__c, Collaboration__c, ';
            query += '(Select Id,  TransactionName__c, StartDate__c, EndDate__c from BO_Activity__r) ';
            query += 'FROM Opportunity WHERE Id != null ';
            if(String.isNotBlank(companyCode)){
                query += ' AND CompanyCode__c = \''+companyCode+'\'';
            }
            if(String.isNotBlank(opportunityCode)){
                query += ' AND OpportunityCode__c = \''+opportunityCode+'\'';
            }
            if(String.isNotBlank(activityStatus)){
                query += ' AND ActivityStatus__c = \''+activityStatus+'\'';
            }

            List<Opportunity> oppList = Database.query(query);

            // 2) 데이터 적재
            for(Opportunity opp : oppList){

                OutputClass oupputClass  = new OutputClass();
                oupputClass.ZZORDER_ID   = opp.OpportunityCode__c;                                      // 사업코드(프로젝트)
                oupputClass.EV_TECH_PROP = '';                                                          // Technical Proposal(확인중)
                oupputClass.EV_BIZ_TYPE  = opp.BusinessType__c;                                         // 사업유형
                oupputClass.EV_BID_TYPE  = opp.BiddingMethod__c;                                        // 입찰방식

                // Activity 개수 만큼 list 생성
                List<Opportunity_Activity__c> actvOppList = opp.BO_Activity__r;
                for( Opportunity_Activity__c  oppAct : actvOppList){
                    if(oppAct.TransactionName__c == 'ZP61'){
                        oupputClass.ZZSALESSTR   = 'X';                                                 // Strategy Session 
                        oupputClass.DATE_FROM    = Util_String.convertDateString(oppAct.StartDate__c);  // Start Date
                        oupputClass.DATE_TO      = Util_String.convertDateString(oppAct.EndDate__c);    // End Date
                    } else {
                        oupputClass.ZZSALESSTR   = '';                                                  // Strategy Session
                        oupputClass.DATE_FROM    = '';                                                  // Start Date
                        oupputClass.DATE_TO      = '';                                                  // End Date 
                    }
                    outHeader.DATA.add(oupputClass.clone());
                }
                // Activity 값이 없는 경우
                // if( actvOppList.size() == 0){

                //     outHeader.DATA.add(oupputClass.clone());
                // }


                // outHeader.DATA.add(oupputClass);
            }

            // 성공 로그 데이터
            outHeader.TOTAL_COUNT    = outHeader.DATA.size();
            outHeader.EV_RESULT      = IF_Util.RESULT_STATUS_SUCCESS;
            outHeader.EV_MESG        = IF_Util.RESULT_MESSAGE_SUCCESS;
            sendData                 = JSON.serialize(outHeader);

            ifLog.addLog('Response : ' + sendData);

            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, inputJsonData, sendData);  

            if (DEBUG_FLAG) ifLog.addLog('데이터 반영');
        } catch (Exception e) {
            Database.rollback(sp);

            // 에러 로그 데이터
            outHeader.TOTAL_COUNT    = 0;
            outHeader.EV_RESULT      = IF_Util.RESULT_STATUS_ERROR;
            outHeader.EV_MESG        = IF_Util.RESULT_MESSAGE_ERROR + ' |' + e.getMessage();
            sendData          = JSON.serialize(outHeader);

            ifLog.addLog('Response : ' + sendData);            
            ifLog.addLog('Webservice call exception : ' + e.getMessage());
            errorMsgList.add('Webservice call exception : ' + e.getMessage());
            
            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, inputJsonData, sendData, e);
        }

        ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 종료' + ' ####################');

        ifLog.createLog(interfaceLog);

        RestContext.response.responseBody = Blob.valueOf( JSON.serialize( outHeader));
    }

    // 받은 값 : 검색 조건
    public class InputHeader{

        @AuraEnabled
        public List<InputClass> DATA;
        
    }
    public class InputClass{

        @AuraEnabled
        public String IV_BUKRS;  // Company Code
        @AuraEnabled
        public String  IV_ZZORDER_ID;    // 사업코드(프로젝트)
        @AuraEnabled
        public String  I_PROCESSTYPE;    // Business Transaction Type
    }

    // 전달 값: JitterBit
    public class OutputHeader{

        @AuraEnabled
        public Integer TOTAL_COUNT = 0; // 전체 데이터 건수
        @AuraEnabled
        public String EV_RESULT = ''; // 처리 결과
        @AuraEnabled
        public String EV_MESG = ''; // 처리 메세지
        @AuraEnabled
        public List<OutputClass> DATA; // 데이터 포멧        
    }
    public class OutputClass{

        @AuraEnabled
        public String ZZORDER_ID; // 사업코드(프로젝트)
        @AuraEnabled
        public String ZZSALESSTR; // Strategy Session
        @AuraEnabled
        public String DATE_FROM; // Start Date
        @AuraEnabled
        public String DATE_TO; // End Date
        @AuraEnabled
        public String EV_TECH_PROP; // Technical Proposal
        @AuraEnabled
        public String EV_BIZ_TYPE; // 사업유형
        @AuraEnabled
        public String EV_BID_TYPE; // 입찰방식
    }
}