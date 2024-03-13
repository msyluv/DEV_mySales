/**
 * @description       : 
 * @author            : raeganja@partner.samsung.com
 * @group             : 
 * @last modified on  : 2020-12-23
 * @last modified by  : raeganja@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                          Modification
 * 1.0   2020-12-17   raeganja@partner.samsung.com   Initial Version
 * 1.0.1 2020-12-23   raeganja@partner.samsung.com   accRegSvcRqst Method Return Map Change
**/
public class IF_ItsmAccRegSvcRqstController {
    private static final String INTERFACE_ID = 'IF-130';
    private static final String APEX_CLASS   = 'IF_ItsmAccRegSvcRqstController';
    private static final String METHOD_NAME  = 'accRegSvcRqst';

    private static final Boolean DEBUG_FLAG = true;

    public IF_ItsmAccRegSvcRqstController() {

    }

    @AuraEnabled
    public static Map<String,Object> accRegSvcRqst(String inputJsonData){

        String guId = IF_Util.generateGuid();

        InputHeader inHeader;
        Map<String, Object> result;

        String reqMsg = '';
        String resMsg = '';
    
        IF_Log ifLog;
        IF_Log.InterfaceLog interfaceLog;
        List<String> errorMsgList = new List<String>();        

		ifLog = new IF_Log();
        ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 시작' + ' ####################');

        try {
            IF_Callout ifCallout = new IF_Callout(INTERFACE_ID);
            
            System.debug( '### IF_ItsmAccRegSvcRqstController :: accRegSvcRqst :: inputJsonData = ' + inputJsonData);

            // Client에서 전달받은 데이터를 callout 규격에 맞게 변환하여 requestbody 만들기
            OutputHeader outHeader = (OutputHeader) JSON.deserialize(inputJsonData, OutputHeader.class);
            if (DEBUG_FLAG) ifLog.addLog('Client에서 전달받은 데이터를 callout 규격에 맞게 변환하여 requestbody 생성');
            
            System.debug( '### IF_ItsmAccRegSvcRqstController :: accRegSvcRqst :: outHeader = ' + JSON.serialize(outHeader));

            result = ifCallout.httpCallout(JSON.serialize(outHeader), '');

            System.debug( '### IF_ItsmAccRegSvcRqstController :: accRegSvcRqst :: result = ' + result);

            reqMsg = String.valueOf(result.get('Request'));
            resMsg = String.valueOf(result.get('Response'));

            ifLog.addLog('StatusCode : '  + String.valueOf(result.get('StatusCode')));
            ifLog.addLog('HttpResponse : '+ String.valueOf(result.get('HttpResponse')));
            ifLog.addLog('Log : '         + String.valueOf(result.get('Log')));
            ifLog.addLog('Message : '     + String.valueOf(result.get('Message')));

            Integer resStatusCode = (Integer)result.get('StatusCode');

            if (resStatusCode != null && resStatusCode == 200) {
                HttpResponse hRes = (HttpResponse)result.get('HttpResponse');

                ifLog.addLog('Response Body : ' + hRes.getBody());
                system.debug('Response Body : ' + hRes.getBody());
                //inHeader = (InputHeader) JSON.deserialize(hRes.getBody(), InputHeader.class);
                //ifLog.addLog('inHeader : ' + inHeader);

                interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqMsg, resMsg);
            }else{
                ifLog.addLog('Webservice call exception : ' + String.valueOf(result.get('Message')));
                errorMsgList.add('Webservice call exception : ' + String.valueOf(result.get('Message')));

                interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqMsg, resMsg, errorMsgList);
            }            
        } catch(Exception e){
            ifLog.addLog('Webservice call exception : ' + String.valueOf(e.getMessage()));
            errorMsgList.add('Webservice call exception : ' + String.valueOf(e.getMessage()));

            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqMsg, resMsg, e);
        } finally {
            ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 종료' + ' ####################');

            ifLog.createLog(interfaceLog);
        }
        return result;        
    }

    // 전달 값: JitterBit (Client에서 받아서 Jitterbit으로 전달)
    public class OutputHeader{

        @AuraEnabled
        public String srcertid; // 대외시스템ID
        @AuraEnabled
        public List<OutputClass> CallDataWithWorkVOV2;
    }

    public class OutputClass{        

        @AuraEnabled
        public String EXTNL_SYS_ID;//대외시스템ID
        @AuraEnabled
        public String SERV_CALL_RLSE_NO;//서비스 콜 이관번호
        @AuraEnabled
        public String TITLE;//제목
        @AuraEnabled
        public String REQ_CTNT;//요청내용
        @AuraEnabled
        public String REQ_CTNT_TP_CD;//요청내용 입력구분
        @AuraEnabled
        public String REQ_DTM;//요청일시
        @AuraEnabled
        public String END_REQ_DTM;//완료요청일시
        @AuraEnabled
        public String START_SCHED_DTM;//착수예정일시
        @AuraEnabled
        public String APPLYR_ID;//신청자 Uniq_id(암호화됨)
        @AuraEnabled
        public String APPLYR_EMP_NO;//신청자 사번
        @AuraEnabled
        public String IS_APPLYR_EMP_NO;//신청자사번전송여부
        @AuraEnabled
        public String APPLYR_NM;//신청자명
        @AuraEnabled
        public String REGR_ID;//등록자 UNIQ_ID
        @AuraEnabled
        public String REGR_NM;//등록자명
        @AuraEnabled
        public String ATCH_FILE_YN;//첨부파일여부
        @AuraEnabled
        public String END_SCHED_DTM;//완료예정일시
        @AuraEnabled
        public String MAILING_YN;//메일수신여부
        @AuraEnabled
        public String URG_YN;//긴급여부
        @AuraEnabled
        public String SRVC_KEY;//서비스코드
        @AuraEnabled
        public String CUST_COMP_CD;//고객사 회사 코드
        @AuraEnabled
        public String CUST_ORG_CD;//고객사 조직 코드
        @AuraEnabled
        public String CUST_COMP_KEY;//고객사 KEY
        @AuraEnabled
        public String REG_IP_ADDR;//등록 IP 주소
        @AuraEnabled
        public String IRP_CODE;//IRP 코드
        @AuraEnabled
        public String IRP_NAME;//IRP 코드
    }

    // 받은 값 : Jitterbit 입력정보 (Request에 대한 Response)
    public class InputHeader{

        @AuraEnabled
        public String EXTNL_SYS_ID;//대외시스템ID
        @AuraEnabled
        public String SERV_CALL_RLSE_NO;//서비스 콜 이관번호
        @AuraEnabled
        public String RET_SUCCS_CD;//반환성공코드
        @AuraEnabled
        public String CHECK_CD;//체크코드
        @AuraEnabled
        public String RET_MSG;//반환메시지
    }

    public class InputClass{    

    }
}