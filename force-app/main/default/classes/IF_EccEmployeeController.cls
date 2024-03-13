/**
 * @description       : 
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-02-19
 * @last modified by  : ghkil@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                      Modification
 * 1.0   2020-11-17   ghkil@partner.samsung.com   Initial Version
 * 1.1   2020-11-25   ghkil@partner.samsung.com   Json Format에 맞춰 bypass 형태로 수정
 * 1.2   2020-12-23   ghkil@partner.samsung.com   return Type Class에서 Map으로 변경
**/
public class IF_EccEmployeeController {

    private static final String INTERFACE_ID = 'IF-090';
    private static final String APEX_CLASS   = 'IF_EccEmployeeController';
    private static final String METHOD_NAME  = 'calloutEmployee';

    private static final Boolean DEBUG_FLAG = IF_Util.DEBUG_FLAG;
    
    @AuraEnabled
    public static Map<String, Object> calloutEmployee(String inputJsonData){        

        String guId = IF_Util.generateGuid();

        Map<String, Object> result;

        String reqMsg = '';
        String resMsg = '';
    
        IF_Log iflog;
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
            // if (DEBUG_FLAG) ifLog.addLog('Log : '         + String.valueOf(result.get('Log')));
            // if (DEBUG_FLAG) ifLog.addLog('Message : '     + String.valueOf(result.get('Message')));

            Integer resStatusCode = (Integer)result.get('StatusCode');

            if (resStatusCode != null && resStatusCode == 200) {
                HttpResponse hRes = (HttpResponse)result.get('HttpResponse');

                ifLog.addLog('Response Body : ' + hRes.getBody());

                interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqMsg, resMsg);
            }else{
                ifLog.addLog('Communication Error : ' + String.valueOf(result.get('Message')) + ' / StatusCode : ' + String.valueOf(resStatusCode));
                errorMsgList.add('Communication Error : ' + String.valueOf(result.get('Message')) + ' / StatusCode : ' + String.valueOf(resStatusCode));

                interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqMsg, resMsg, errorMsgList);
            }            
        } catch(Exception e){
            ifLog.addLog('Exception : ' + String.valueOf(e.getMessage()));
            errorMsgList.add('Exception : ' + String.valueOf(e.getMessage()));

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
        public String IV_GUBUN; // 구분, 구분( 1: 개인, 2: 부서장 )
        @AuraEnabled
        public String IV_SABUN; // PERNR, 법인코드+사번
    }    
}