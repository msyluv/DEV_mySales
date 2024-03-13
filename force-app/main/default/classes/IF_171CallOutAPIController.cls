/**
* @author            : anish.jain@partner.samsung.com
* @description       : [IF-171] BO_실주중도종결_정보전송
* 		              : Interface call for 'Save' button on Service/Solution tab of Review Opportunity
* @last modified on  : 07-07-2023
* @last modified by  : chae_ho.yang@samsung.com
* Modifications Log 
* Ver   Date         Author                   Modification
* 1.0   2022-11-08   anish.jain@partner.samsung.com  Initial Version
**/
public class IF_171CallOutAPIController {
    @future(callout=true)
    public static void doCalloutSendingReviewOpportunityInfo(ID oppID){
        String APEX_CLASS   = 'IF_171CallOutAPIController';
        String METHOD_NAME_171  = 'doCalloutSendingReviewOpportunityInfo';
        String INTERFACE_ID_171 = 'IF-171';
        Map<String,Object> resMap = new Map<String,Object>();
        IF_Log log = new IF_Log();
        IF_Log.InterfaceLog ifLog;
        String guId = '';
        String jsonBody = '';
        IF_Callout call;
        HttpResponse res;
        try{
            system.debug('oppty ID  : '+ oppID);
            Opportunity oppRecord = [select Id,Name,Owner.Name,Owner.Email,OpportunityCode__c,Account.Name, cOriginAcc__r.name From Opportunity 
                                     where Id=:oppID];
            List<String> str = new List<String>();
            str = oppRecord.Owner.Email.split('@');
            String knoxId = str[0];
            System.debug('oppRecord 171 '+oppRecord);
            call = new IF_Callout(INTERFACE_ID_171);
            guId = IF_KnoxChatSendController.generateUid();
            InputClass_171 input_171 = new InputClass_171();
            input_171.instanceName = 'mySales_bo_confirm';
            input_171.variableSetName = 'mySales_bo_confirm_info';
            input_171.variableSetValues.bo_code = oppRecord.OpportunityCode__c;
            input_171.variableSetValues.bo_custom_nm = oppRecord.cOriginAcc__r.name;
            input_171.variableSetValues.bo_name = oppRecord.Name;
            input_171.variableSetValues.bo_salesman = oppRecord.Owner.Name.replace(' ','');
            input_171.variableSetValues.bo_mail_info_am = knoxId;
            System.debug('oppRecord input_171 '+ input_171);   
            jsonBody = JSON.serialize(input_171);
            system.debug('Demand Response jsonBody : '+ jsonBody);
            resMap = call.httpCallout(jsonBody, '');
            system.debug('resMap##' + resMap);
            res = (System.HttpResponse)resMap.get('HttpResponse');
            system.debug('Demand Response : '+ res);
            OutputClass_171 out_171 = new OutputClass_171();
            if(res.getStatusCode() == 200){
                Map<String, Object> bodyMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                if(bodyMap.get('RESULT') != null && bodyMap.get('RESULT') == 'S'){
                    out_171 = (OutputClass_171)json.deserialize(res.getbody(),OutputClass_171.class);
                }
            }
            ifLog = new IF_Log.InterfaceLog(INTERFACE_ID_171, guId, APEX_CLASS, METHOD_NAME_171, String.valueOf(resMap.get('Request')), String.valueOf(out_171));  
            System.debug('ifLog Output :'+ifLog);
        }catch(Exception e){
            system.debug('Exception e occur' + e.getMessage());
            ifLog = new IF_Log.InterfaceLog(INTERFACE_ID_171, guId, APEX_CLASS, METHOD_NAME_171, String.valueOf(resMap.get('Request')), String.valueOf(resMap),e);
        }
        ID iFLogId = log.createLog2(ifLog);
        system.debug('iFLogId **' + iFLogId);
        
    }
    
    public class InputClass_171{
        public String instanceName;
        public String variableSetName;
        public InnerInputClass_171 variableSetValues = new InnerInputClass_171();
    }
    public class InnerInputClass_171{
        public String bo_code;
        public String bo_custom_nm;
        public String bo_name;
        public String bo_salesman;
        public String bo_mail_info_am;
    }
    public class OutputClass_171{
        public string instanceId;
        public string definitionId;
        public string instanceName;
        public Boolean ended;
        public Boolean suspended;
    }
    
}