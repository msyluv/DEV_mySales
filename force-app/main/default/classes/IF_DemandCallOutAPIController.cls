/**
* @description       : Apex class to make callout to Jitterbit for sending Close Lead reason to Demand System (IF-158).
* @author            : akash.g@samsung.com
* @group             : 
* @last modified on  : 08-04-2022
* @last modified by  : akash.g@samsung.com
* Modifications Log 
* Ver   Date         Author                    Modification
* 1.0   08-04-2022   akash.g@samsung.com       Initial Version 
**/
public class IF_DemandCallOutAPIController {
    @future(callout=true)
    public static void doCalloutSendingCloseLeadInfo(Map<String,String> inputVarMap){
        String APEX_CLASS   = 'SalesLeadCountTrigger';
        String METHOD_NAME_158  = 'doCalloutSendingCloseLeadInfo';
        String INTERFACE_ID_158 = 'IF-158';
        Map<String,Object> resMap = new Map<String,Object>();
        IF_Log log = new IF_Log();
        IF_Log.InterfaceLog ifLog;
        String guId = '';
        String jsonBody = '';
        IF_Callout call;
        HttpResponse res;
        try{
            System.debug('[IF-158] START');
            call = new IF_Callout(INTERFACE_ID_158);
            guId = IF_KnoxChatSendController.generateUid();
            InputClass_158 input_158 = new InputClass_158();
            input_158.Close_Reason = inputVarMap.get('closeReason');
            input_158.Lead_ID = inputVarMap.get('leadID');
            jsonBody = JSON.serialize(input_158);
            resMap = call.httpCallout(jsonBody, '');
            res = (HttpResponse)resMap.get('HttpResponse');
            system.debug('Demand Response : '+ res);
            ifLog = new IF_Log.InterfaceLog(INTERFACE_ID_158, guId, APEX_CLASS, METHOD_NAME_158, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')));           
        }catch(Exception e){
            system.debug('Exception e occur' + e.getMessage());
            ifLog = new IF_Log.InterfaceLog(INTERFACE_ID_158, guId, APEX_CLASS, METHOD_NAME_158, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')),e);
        }
        ID iFLogId = log.createLog2(ifLog);
        system.debug('iFLogId **' + iFLogId);
    }
    public class InputClass_158{
        public String Lead_ID;
        public String Close_Reason;
    }
}