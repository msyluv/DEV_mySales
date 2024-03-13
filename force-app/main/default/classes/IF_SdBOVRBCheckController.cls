/**
 * @description       :
 * @author            : ukhyeon.lee@samsung.com
 * @group             :
 * @last modified on  : 09-02-2021
 * @last modified by  : ukhyeon.lee@samsung.com
 * Modifications Log
 * Ver   Date         Author                    Modification
 * 1.0   06-24-2021   ukhyeon.lee@samsung.com   Initial Version
 **/
public class IF_SdBOVRBCheckController {
  private static final String INTERFACE_ID = 'IF-143';
  private static final String APEX_CLASS = 'IF_SdBOVRBCheckController';
  private static final String METHOD_NAME = 'getBOVRBCheck';

  private static final Boolean DEBUG_FLAG = true;

  public IF_SdBOVRBCheckController() {
  }

  @AuraEnabled
  public static Map<String, Object> getBOVRBCheck(String inputJsonData) {
    String guId = IF_Util.generateGuid();

    Map<String, Object> result;

    String reqMsg = '';
    String resMsg = '';

    IF_Log ifLog;
    IF_Log.InterfaceLog interfaceLog;
    List<String> errorMsgList = new List<String>();

    ifLog = new IF_Log();
    ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 시작' +' ####################');

    try {
      IF_Callout ifCallout = new IF_Callout(INTERFACE_ID);

      // Client에서 전달받은 데이터를 callout 규격에 맞게 변환하여 requestbody 만들기
      OutputHeader outHeader = (OutputHeader) JSON.deserialize(
        inputJsonData,
        OutputHeader.class
      );
      if (DEBUG_FLAG)
        ifLog.addLog('Client에서 전달받은 데이터를 callout 규격에 맞게 변환하여 requestbody 생성');

      result = ifCallout.httpCallout(JSON.serialize(outHeader), '');
      if (DEBUG_FLAG)
        ifLog.addLog('Callout');

      reqMsg = String.valueOf(result.get('Request'));
      resMsg = String.valueOf(result.get('Response'));

      ifLog.addLog('StatusCode : ' + String.valueOf(result.get('StatusCode')));
      ifLog.addLog('HttpResponse : ' + String.valueOf(result.get('HttpResponse')));
      ifLog.addLog('Log : ' + String.valueOf(result.get('Log')));
      ifLog.addLog('Message : ' + String.valueOf(result.get('Message')));

      Integer resStatusCode = (Integer) result.get('StatusCode');
      if (resStatusCode != null && resStatusCode == 200) {
        HttpResponse hRes = (HttpResponse) result.get('HttpResponse');

        ifLog.addLog('Response Body : ' + hRes.getBody());

        interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqMsg, resMsg);
      } else {
        ifLog.addLog(          'Webservice call exception : ' + String.valueOf(result.get('Message')));
        errorMsgList.add(          'Webservice call exception : ' + String.valueOf(result.get('Message')));

        interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqMsg, resMsg, errorMsgList);
      }
    } catch (Exception e) {
      //ifLog.addLog('Webservice call exception : ' + String.valueOf(e.getMessage()));
      //errorMsgList.add('Webservice call exception : ' + String.valueOf(e.getMessage()));
      ifLog.addLog('StatusCode : E');
      interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqMsg, resMsg, e);
    } finally {
      //if (inHeader != null)
      //    ifLog.addLog(inHeader);
      ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 종료' + ' ####################');

      ifLog.createLog(interfaceLog);
      result.put('INTERFACE_LOG', interfaceLog);
    }
    return result;
  }

  // 전달 값: JitterBit (Client에서 받아서 Jitterbit으로 전달)
  public class OutputHeader {
    @AuraEnabled
    public String ZZORDER_ID; //BO코드
    @AuraEnabled
    public String ZZBUKRS_H; //회사코드
    @AuraEnabled
    public String BIZ_AMOUNT; //사업규모(VAT제외)
    @AuraEnabled
    public String CONSORTIUM_YN; //컨소시엄여부
    @AuraEnabled
    public String COMPLIANCE_1_YN; //Complicance 1
    @AuraEnabled
    public String COMPLIANCE_2_YN; //Complicance 2
  }
}