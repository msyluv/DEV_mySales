/**
 * @description       : 
 * @author            : kilhwan.an@partner.samsung.com
 * @group             : 
 * @last modified on  : 2020-12-23
 * @last modified by  : ghkil@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                           Modification
 * 1.0   2020-11-13   kilhwan.an@partner.samsung.com   Initial Version
 * 1.1   2020-11-25   ghkil@partner.samsung.com        bypass 형태로 수정
 * 1.2   2020-12-23   ghkil@partner.samsung.com        return Type Class에서 Map으로 변경
**/
public class IF_ILogMakeApprLineController {
    public IF_ILogMakeApprLineController() { }

    private static final String INTERFACE_ID = 'IF-011';
    private static final String APEX_CLASS   = 'IF_ILogMakeApprLineController';
    private static final String METHOD_NAME  = 'calloutSearchApprList';

    private static final Boolean DEBUG_FLAG = IF_Util.DEBUG_FLAG;

    @AuraEnabled
    public static Map<String, Object> calloutSearchApprList(String inputJsonData){       

        String guId = IF_Util.generateGuid();

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

            // Client에서 전달받은 데이터를 callout 규격에 맞게 변환하여 requestbody 만들기
            OutputHeader outHeader = (OutputHeader) JSON.deserialize(inputJsonData, OutputHeader.class);
            if (DEBUG_FLAG) ifLog.addLog('Client에서 전달받은 데이터를 callout 규격에 맞게 변환하여 requestbody 생성');

            result = ifCallout.httpCallout(JSON.serialize(outHeader), '');
            ifLog.addLog('result : '  + result);

            reqMsg = String.valueOf(result.get('Request'));
            resMsg = String.valueOf(result.get('Response'));

            if (DEBUG_FLAG) ifLog.addLog('StatusCode : '  + String.valueOf(result.get('StatusCode')));
            if (DEBUG_FLAG) ifLog.addLog('HttpResponse : '+ String.valueOf(result.get('HttpResponse')));
            if (DEBUG_FLAG) ifLog.addLog('Log : '         + String.valueOf(result.get('Log')));
            if (DEBUG_FLAG) ifLog.addLog('Message : '     + String.valueOf(result.get('Message')));

            Integer resStatusCode = (Integer)result.get('StatusCode');

            if (resStatusCode != null && resStatusCode == 200) {
                HttpResponse hRes = (HttpResponse)result.get('HttpResponse');

                ifLog.addLog('Response Body : ' + hRes.getBody());

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
        public String objectKey;        //모듈내 결재건 KEY값
        @AuraEnabled
        public String corporationId;    //SAP회사코드T604,T100등
        @AuraEnabled
        public String module;           // 모듈명 CR/SD/LD 등
        @AuraEnabled
        public String approvalProcessId;// 업무코드
        @AuraEnabled
        public String draftId;          // KNOX ID 
        @AuraEnabled
        public String draftCompany;     // 상신자 HR회사코드 C6C,C60 등
        @AuraEnabled
        public String draftEmpNo;       // 상신자 사번 (6272800 등)
        @AuraEnabled
        public String draftDept;        // 상신자 부서코드 (C6C1C430등)
        @AuraEnabled
        public List<OUTPUT_T_CONTAINER> T_CONTAINER;
    }
    public class OUTPUT_T_CONTAINER {

        @AuraEnabled
        public String name; // Factor Code
        @AuraEnabled
        public String value; // Factor Value        
    }

    // // 받은 값 : Jitterbit 입력정보 (Request에 대한 Response)
    // public class InputHeader{
        
    //     @AuraEnabled
    //     public String message; // Message Text
    //     @AuraEnabled
    //     public List<INPUT_T_PATHLIST> T_PATHLIST;
    // }
    // public class INPUT_T_PATHLIST{

    //     @AuraEnabled
    //     public String objectKey; // 모듈내 결재건 KEY값
    //     @AuraEnabled
    //     public String draftId; // KNOX ID
    //     @AuraEnabled
    //     public String draftCompany; // 상신자 HR회사코드 C6C,C60 등
    //     @AuraEnabled
    //     public String draftDept; // 상신자 부서코드 (C6C1C430등)
    //     @AuraEnabled
    //     public String approvalLine;
    //     @AuraEnabled
    //     public List<INPUT_T_USERS> T_USERS;        
    // }
    // public class INPUT_T_USERS{

    //     @AuraEnabled
    //     public String userID; // KNOX ID
    //     @AuraEnabled
    //     public String userUID; // UNIQ ID
    //     @AuraEnabled
    //     public String userName; // 이름
    //     @AuraEnabled
    //     public String userOtherName; // 영문이름
    //     @AuraEnabled
    //     public String employeeNumber; // 회사코드+사번
    //     @AuraEnabled
    //     public String deptName; // 부서코드
    //     @AuraEnabled
    //     public String gradeName; // 직급코드
    //     @AuraEnabled
    //     public String stageName; // 역할명
    //     @AuraEnabled
    //     public String stageTypeName; // 결재구분
    // }
}