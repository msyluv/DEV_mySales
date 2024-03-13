/**
 * @description       : 
 * @author            : raeganja@partner.samsung.com
 * @group             : 
 * @last modified on  : 2020-12-23
 * @last modified by  : raeganja@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   2020-12-11   raeganja@partner.samsung.com   Initial Version
 * 1.0.1 2020-12-23   raeganja@partner.samsung.com   getSafetyInspectTarget Method Return Map Change
**/
public class IF_EccSafetyInspectTargetController {
    private static final String INTERFACE_ID = 'IF-029';
    private static final String APEX_CLASS   = 'IF_EccSafetyInspectTargetController';
    private static final String METHOD_NAME  = 'getSafetyInspectTarget';

    private static final Boolean DEBUG_FLAG = true;

    public IF_EccSafetyInspectTargetController() {

    }

    @AuraEnabled
    public static Map<String,Object> getSafetyInspectTarget(String inputJsonData){
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

            // Client에서 전달받은 데이터를 callout 규격에 맞게 변환하여 requestbody 만들기
            OutputHeader outHeader = (OutputHeader) JSON.deserialize(inputJsonData, OutputHeader.class);
            if (DEBUG_FLAG) ifLog.addLog('Client에서 전달받은 데이터를 callout 규격에 맞게 변환하여 requestbody 생성');

            result = ifCallout.httpCallout(JSON.serialize(outHeader), '');
            if (DEBUG_FLAG) ifLog.addLog('Callout');

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
                //inHeader = (InputHeader) JSON.deserialize(hRes.getBody(), InputHeader.class);

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
            //if (inHeader != null)
            //    ifLog.addLog(inHeader);
                            
            ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 종료' + ' ####################');

            ifLog.createLog(interfaceLog);
        }
        return result;
    }

    // 전달 값: JitterBit (Client에서 받아서 Jitterbit으로 전달)
    public class OutputHeader{

        @AuraEnabled
        public String IV_PSPID; // Project Definition
        @AuraEnabled
        public String IV_ZZCCODE; // B/O Code
        @AuraEnabled
        public String IV_GUBUN; // P: 실행 / S: 수주
    }

    // 받은 값 : Jitterbit 입력정보 (Request에 대한 Response)
    public class InputHeader{
        
        @AuraEnabled
        public String EV_RETURN; // Y: 확인, 대상아님 / N: 취소 (Default: Y)      
    }    
}