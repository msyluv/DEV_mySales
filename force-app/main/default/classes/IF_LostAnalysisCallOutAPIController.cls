/**
* @description       : Rest API Callout to Interact with Cello system
* @author            : Kajal.c@samsung.com
* @group             : 
* @last modified on  : 2023-08-09
* @last modified by  : sarthak.j1@samsung.com	
* Modifications Log 
* Ver   Date         Author                    Modification
* 1.0   2023-04-25   Kajal.c@samsung.com   Initial Version
* 1.1   2023-08-09   anish.jain@partner.samsung.com  [Urgent]Change Interface program related to Strategic Committee (My Sales - 275)
* 1.2	2024-01-16   sarthak.j1@samsung.com		Add field to IF-159 (Send Drop/Lost information to legacy) & Stop calling IF-155 (MYSALES-415)
**/

public class IF_LostAnalysisCallOutAPIController implements Queueable, Database.AllowsCallouts{
    public Set<ID> oppIDList;

    public IF_LostAnalysisCallOutAPIController(Set<Id> oppIDList) {
        system.debug('Akash3 Test');
        this.oppIDList = oppIDList;
        system.debug('oppIDList'+oppIDList);
    }
    
     public void execute(QueueableContext context) {
        system.debug('Akash4 Test');
        doCalloutSendingLostOpportunityInfo();
    }
    
    public void doCalloutSendingLostOpportunityInfo(){
        String APEX_CLASS   = '';
        String METHOD_NAME_159  = 'doCalloutSendingLostOpportunityInfo';
        String INTERFACE_ID_159 = 'IF-159';
        Map<String,Object> resMap = new Map<String,Object>();
        IF_Log log = new IF_Log();
        String guId = '';
        String jsonBody = '';
        IF_Callout call;
        HttpResponse res;
        call = new IF_Callout(INTERFACE_ID_159);
        guId = IF_KnoxChatSendController.generateUid();
        try{
            System.debug('[IF-159] START');
              List<Opportunity_Activity__c> opActList = new List<Opportunity_Activity__c>();
           
            opActList = [Select id,EndDate__c,LostType__c,WhatId__r.OpportunityCode__c,WhatId__c,WhatId__r.CompanyCode__c,whatId__r.RecordType.Name from Opportunity_Activity__c
                                                       where WhatId__c IN :oppIDList AND TransactionName__c in ('ZPZ1' , 'ZPZ2') ];

            
            System.debug('opActListSize' +opActList);
            system.debug('compcode'+opActList[0].WhatId__r.RecordType.Name);
            if(opActList != null){
                
                //LOST RESULT 
                List<LostResult__c> lostResultList = [select Id,Opportunity__c,LostActivity__r.LostType__c,Rate__c,
                                                      LOST_DETAIL__c, LostTypeCode__c  
                                                      from LostResult__c where Opportunity__c IN: oppIDList]; 
                Map<ID, List<LostResult__c>> lostResultMap = new Map<ID, List<LostResult__c>>();
                for(LostResult__c lostresult : lostResultList){
                    if (lostResultMap.containsKey(lostresult.Opportunity__c))
                    {
                        List<LostResult__c> lst_terr = lostResultMap.get(lostresult.Opportunity__c);
                        lst_terr.add(lostresult);
                        lostResultMap.put(lostresult.Opportunity__c,lst_terr); 
                    }else{
                        lostResultMap.put(lostresult.Opportunity__c, new List<LostResult__c>{lostresult});
                    }
                }
                //counterMeasure
                List<Lost_Countermeasure__c> cmList = [Select id,Opportunity__c,Master_Lost_Type_Code__c,Countermeasures__c,Action_Item__c,
                                                       	Managing_Department__c,Deadline__c,ManagementDeptCode__c
                                                       from Lost_Countermeasure__c where Opportunity__c IN : oppIDList]; // needs to add countermesare, actions fields
                Map<Id,List<Lost_Countermeasure__c>> cmMap = new Map<Id,List<Lost_Countermeasure__c>>(); 
                
                for(Lost_Countermeasure__c cm :cmList){
                    if (cmMap.containsKey(cm.Opportunity__c))
                    {
                        List<Lost_Countermeasure__c> lst_terr = cmMap.get(cm.Opportunity__c);
                        lst_terr.add(cm);
                        cmMap.put(cm.Opportunity__c,lst_terr); 
                    }else{
                        cmMap.put(cm.Opportunity__c, new List<Lost_Countermeasure__c>{cm});
                    }
                }
                
                //Action Item --> added ACTION_ITEM_COMPLETION_DATE__c --> Remove complete
                System.debug('cmMap value' +cmMap);
                
                List<InputClass_159> input159List = new List<InputClass_159>();
                for(Opportunity_Activity__c opActivity : opActList){
                    InputClass_159 input_159 = new InputClass_159();
                    input_159.BO_CODE = opActivity.WhatId__r.OpportunityCode__c;
                    if(opActivity.LostType__c =='Z06'){
                        input_159.CLOSE_STAGE = 'LOST';
                    }else if(opActivity.LostType__c =='Z07'){
                        input_159.CLOSE_STAGE = 'DROP';
                    }
                    String closedate = String.valueof(opActivity.EndDate__c);
                    if(closedate != null && closedate !=''){
                    input_159.CLOSE_DATE = closedate.replaceAll('-', '');
                    }
                    input_159.SAP_COMPANY = opActivity.WhatId__r.CompanyCode__c;  //Added by Anish - v 1.1
                    input_159.BO_ID = opActivity.WhatId__c; //Added by SJOSHI - v 1.2
                    input159List.add(input_159);
                    System.debug('Opportunity Data '+input159List);
                    if(lostResultMap.size() > 0){
                        List<LostResult__c> lrList = lostResultMap.get(opActivity.WhatId__c);
                        if(lrList != null){
                            for(LostResult__c lostData : lrList){
                                LostResultInputClass newInputLost = new LostResultInputClass();                
                                newInputLost.LOST_TYPE = lostData.LostTypeCode__c;
                                String lostdetail  = lostData.LOST_DETAIL__c;
                                newInputLost.LOST_DETAIL = lostData.LOST_DETAIL__c;
                               // newInputLost.LOST_DETAIL = lostdetail.replace(' ', '&nbsp;');
                                newInputLost.RATE = lostData.Rate__c;
                                input_159.BO_LOST_INFO.add(newInputLost);
                            }
                        }
                    }
                    if(cmMap.size() > 0){
                        List<Lost_Countermeasure__c> counterMeasureList =  cmMap.get(opActivity.WhatId__c);
                        if(counterMeasureList !=  null){
                            for(Lost_Countermeasure__c cm : counterMeasureList){
                                CounterMeasureInputClass newInputCounter = new CounterMeasureInputClass(); 
                                newInputCounter.LOST_TYPE = cm.Master_Lost_Type_Code__c;
                                newInputCounter.LOST_COUNTERMEASURES = cm.Countermeasures__c;
                                newInputCounter.ACTION_ITEM = cm.Action_Item__c;
                                newInputCounter.ACTION_DEPT =cm.ManagementDeptCode__c;
                                String ActionDeadline = String.valueof(cm.Deadline__c );
                                if(ActionDeadline != null && ActionDeadline != ''){
                                newInputCounter.ACTION_DEADLINE = ActionDeadline.replaceAll('-', '') ;
                                }
                                input_159.BO_LOST_MEASURES.add(newInputCounter);
                            }
                        }
                    }
                }
                
                System.debug('After input159List'+input159List); 
                jsonBody = JSON.serialize(input159List);
                system.debug('Demand Response jsonBody : '+ jsonBody);
                resMap = call.httpCallout(jsonBody, '');
                res = (HttpResponse)resMap.get('HttpResponse');
                system.debug('Demand Response : '+ res);
                IF_Log.InterfaceLog ifLog;
                ifLog = new IF_Log.InterfaceLog(INTERFACE_ID_159, guId, APEX_CLASS, METHOD_NAME_159, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')));           
                ID iFLogId = log.createLog2(ifLog);
                system.debug('iFLogId **' + iFLogId);
            }
        } catch(Exception e){
            system.debug('Exception e occur' + e.getMessage());
            IF_Log.InterfaceLog ifLog;
            ifLog = new IF_Log.InterfaceLog(INTERFACE_ID_159, guId, APEX_CLASS, METHOD_NAME_159, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')),e);
            ID iFLogId = log.createLog2(ifLog);
            system.debug('iFLogId **' + iFLogId);
        } 
    } 
    public class InputClass_159{
        public String BO_CODE;
        public String CLOSE_STAGE;
        public String CLOSE_DATE;
        public String SAP_COMPANY; //Added by Anish - v 1.1
        public String BO_ID; //Added by SJOSHI - v 1.2
        public List<LostResultInputClass> BO_LOST_INFO = new List<LostResultInputClass>();
        public List<CounterMeasureInputClass> BO_LOST_MEASURES = new List<CounterMeasureInputClass>();
    }
             
    public class LostResultInputClass{
        public String LOST_TYPE;
        public String LOST_DETAIL;
        public decimal RATE;
    }
    public class CounterMeasureInputClass{
        public String LOST_TYPE;
        public String LOST_COUNTERMEASURES;
        public String ACTION_ITEM;
        public String ACTION_DEPT;
        public string ACTION_DEADLINE;
    }
    
}