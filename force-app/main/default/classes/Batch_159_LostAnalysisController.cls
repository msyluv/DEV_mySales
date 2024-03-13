/**
* @description       : Batch run to send IF-159
* @author            : anish.jain@partner.samsung.com
* @group             : 
* @last modified on  : 2024-02-29
* @last modified by  : anish.jain@partner.samsung.com 
* Modifications Log 
* Ver   Date         Author                      Modification
* 1.0   2023-12-10   anish.jain@partner.samsung.com   Initial Version (MS-373) Part of Epic MS-216
* 1.1   2024-01-29   sarthak.j1@samsung.com		Add field to IF-159 (Send Drop/Lost information to legacy) & Stop calling IF-155 (MYSALES-415)
* 1.1   2024-02-29   anish.jain@partner.samsung.com	  MS-460
**/

global class Batch_159_LostAnalysisController implements DataBase.Stateful, Database.Batchable<sObject>, Database.AllowsCallouts ,schedulable { // , schedulable

    private static final String INTERFACE_ID = 'IF-159';
    private static final String APEX_CLASS   = 'Batch_159_LostAnalysisController';
    private static IF_Log ifLog = new IF_Log();
    private static IF_Log.BatchLog batchLog = null;
    private static Datetime deadline = Datetime.now().addMinutes(-30);
    private static String guId = IF_Util.generateGuid();
    public Batch_159_LostAnalysisController(){
     }
        global Database.QueryLocator start(Database.BatchableContext bc)
        {
        Set<String> statusTarget = new Set<String> { 'ZPZ1' , 'ZPZ2' };
        IF_Log ifStartLog = new IF_Log();
        IF_Log.BatchLog batchStartLog;
        batchStartLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Start', '', 0);
        ifStartLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' +  '(Start:' + BC.getJobId() + ') 시작' + ' ####################');
        String queryString;
        Database.QueryLocator returnScope;
        queryString = 'Select Id,Status__c,OpportunityActivity__c,Opportunity_Code__c,Opportunity__c,Opportunity__r.Amount,OpportunityActivity__r.TransactionName__c from KnoxApproval__c'; //Added by Anish-New
        System.debug('Anish Test 0 :'+queryString);
        if(Test.isRunningTest()){
        queryString +=' where ((OpportunityActivity__r.TransactionName__c in : statusTarget) or (OpportunityActivity__r.TransactionName__c = \'ZP82\' and Opportunity__r.Amount = 0) ) and Status__c = \'2\' ';   
        }
        else{
            
        queryString +=' where ((OpportunityActivity__r.TransactionName__c in : statusTarget) or (OpportunityActivity__r.TransactionName__c = \'ZP82\' and Opportunity__r.Amount = 0) ) and ( LastModifiedDate >= :deadline) and Status__c = \'2\' ';
        }
        System.debug('Anish Test 1 :'+queryString);
        returnScope = DataBase.getQueryLocator( queryString);
        System.debug('Anish Test 2 :'+returnScope);
        ifStartLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | '  + '(Start:' + BC.getJobId() + ') 종료' + ' ####################');
        ifStartLog.createLog(batchStartLog);
        System.debug('###################################' + returnScope);
        
        return returnScope;
    }
    
    global void execute(Database.BatchableContext BC, List<KnoxApproval__c> scopeList){
        
        List<Id> knoxId = new List<Id>();
        for(KnoxApproval__c knx : scopeList){
            //knoxId.add(Id);
        }
        
        //List<KnoxApproval__c> lstKnox = [Select Id,OpportunityActivity__r.TransactionName__c,Opportunity__r.Amount,Opportunity__c,OpportunityActivity__c From KnoxApproval__c where Id IN : knoxId];
        Map<String,Object> resMap = new Map<String,Object>();
        IF_Log log = new IF_Log();
        String guId = '';
        String jsonBody = '';
        IF_Callout call;
        HttpResponse res;
        call = new IF_Callout(INTERFACE_ID);
        guId = IF_KnoxChatSendController.generateUid();
        List<Id> oppId = new List<Id>();
        List<Id> oppAcc = new List<Id>();
        String oppidlog;
        try{
            
        for(KnoxApproval__c knoxApp : scopeList){
            oppId.add(knoxApp.Opportunity__c);
            oppAcc.add(knoxApp.OpportunityActivity__c);
            if(knoxApp.Opportunity__c != null )
            oppidlog+= knoxApp.Opportunity_Code__c + ', '; 
        }
        
        List<Opportunity_Activity__c> lstAcc = [Select Id,WhatId__r.OpportunityCode__c,EndDate__c,WhatId__r.CompanyCode__c,WhatId__c,LostType__c From Opportunity_Activity__c where (TransactionName__c = 'ZPZ1' or TransactionName__c = 'ZPZ2') and  WhatId__c IN : oppId];
        
        //LOST RESULT 
                List<LostResult__c> lostResultList = [select Id,Opportunity__c,LostActivity__r.LostType__c,Rate__c,
                                                      LOST_DETAIL__c, LostTypeCode__c  
                                                      from LostResult__c where Opportunity__c IN: oppId]; 
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
                                                       from Lost_Countermeasure__c where Opportunity__c IN : oppId]; // needs to add countermesare, actions fields
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
                for(Opportunity_Activity__c opActivity : lstAcc){
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
                    input_159.BO_ID = opActivity.WhatId__c; //Added by SJOSHI - v 1.1
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
        		//Start v 1.1
        		system.debug('GetRespStatus>>' + res.getStatusCode());
       
        		String jsonResponse = res.getBody(); 
				Map<String,Object> jsonMap = (Map<String,Object>)JSON.deserializeUntyped(jsonResponse); 
        		String result = String.valueOf(jsonMap.get('RESULT')); 
        
                if(result == 'S'){
                    system.debug('Demand Response : '+ res);
                    IF_Log.InterfaceLog ifLog;
                    ifLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, 'execute', String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')));           
                    ID iFLogId = log.createLog2(ifLog);
                    system.debug('iFLogId **' + iFLogId);   
                   }
        		// End v 1.1
        		else { // Added code in Else condition v 1.1     
                    system.debug('F');
                    List<String>  errlist = new List<String>();
                    IF_Log.InterfaceLog ifLog;
                   	ifLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, 'execute', String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')), errlist);
                    ID iFLogId = log.createLog2(ifLog);
        		}
        }
        catch(Exception e){
        IF_Log__c logRec = new IF_Log__c();
        logRec.InterfaceId__c = 'IF-159';
        logRec.InterfaceGuid__c = guid;
        logRec.ApexMethod__c = 'Execute';
        logRec.ApexName__c = 'Batch_159_LostAnalysisController';
        logRec.RequestMessage__c = String.valueOf(resMap.get('Request'));
        logRec.StatusCode__c = 'E';
        logRec.LogType__c = 'Batch';
        logRec.LogText__c = oppidlog;
        logRec.EndDatetime__c  = System.now();
        logRec.StartDatetime__c = System.now();
        logRec.ExceptionType__c = e.getTypeName();
        logRec.ErrorMessage__c = e.getMessage();
        logRec.StackTrace__c = e.getStackTraceString();
        
        insert logRec;    
        }
                 		
    }
    
    global void finish(Database.BatchableContext BC){
        IF_Log ifFinishLog = new IF_Log();
        IF_Log.BatchLog batchFinishLog;
        batchFinishLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Finish', '', 0);
        ifFinishLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + 'Finish' + ' 종료' + ' ####################');
        ifFinishLog.createLog(batchFinishLog);
    }
    
     
    public void execute(SchedulableContext sc) {
        database.executebatch(new Batch_159_LostAnalysisController() , 5);
    }
    
    public class InputClass_159{
        public String BO_CODE;
        public String CLOSE_STAGE;
        public String CLOSE_DATE;
        public String SAP_COMPANY; 
        public String BO_ID; //Added by SJOSHI - v 1.1
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