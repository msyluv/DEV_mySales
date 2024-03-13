/**
* @description       : 
* @author            : akash.g@samsung.com
* @group             : 
* @last modified on  : 2023-03-19
* @last modified by  : akash.g@samsung.com
* Modifications Log 
* Ver   Date         Author                         Modification
* 1.0   2023-03-19  akash.g@samsung.com   Initial Version((MySales -147))
**/
global class Batch_IF180callout implements DataBase.stateful, DataBase.Batchable<SObject>, DataBase.AllowsCallouts, Schedulable {
    
    private final String INTERFACE_ID = 'IF-180';
    private final String APEX_CLASS   = 'Batch_IF180callout';
    private final String METHOD_NAME  = 'Batch';
    private static final Boolean DEBUG_FLAG = false;    
    
    private static String guId = IF_Util.generateGuid();
    
    public DataBase.QueryLocator start(DataBase.BatchableContext BC){
        IF_Log ifStartLog = new IF_Log();
        IF_Log.BatchLog batchStartLog;
        List<String> startErrorMsgList = new List<String>();
        
        ifStartLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Start:' + BC.getJobId() + ') 시작' + ' ####################');
        
        String queryString;
        Database.QueryLocator returnScope;
        try{
            List<BO_Activity_Complete__c> migOppCdList = [
                SELECT Id ,Name ,OpportunityCode__c FROM BO_Activity_Complete__c WHERE Send_Check__c  = false
                AND InterfaceId__c = 'IF-180'               
            ];
            Set<String> oppIdSet = new Set<String>();
            for( BO_Activity_Complete__c migOpp : migOppCdList){
                oppIdSet.add( migOpp.Name);
            }
            queryString = 'Select Id ' +		 
                '       , OpportunityCode__c ' +      
                '       , Name ' +                    
                'From   Opportunity ' + 
                'WHERE    Id IN :oppIdSet' ;
            
            returnScope = DataBase.getQueryLocator(queryString);
            
            ifStartLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Start:' + BC.getJobId() + ') 종료' + ' ####################');
            
            batchStartLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Start', '', 0);
            
            ifStartLog.createLog(batchStartLog);
            
        } catch(Exception e){
            
            batchStartLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Start', '', 0, 0, e);
            startErrorMsgList.add('Batch exception : ' + e.getMessage());
            
            ifStartLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Start:' + BC.getJobId() + ') 종료' + ' ####################');
            
            ifStartLog.createLog(batchStartLog);
        }
        return returnScope;
    }
    
    public void execute(DataBase.BatchableContext BC, List<Opportunity> scopeList){
        
        IF_Log ifExcuteLog = new IF_Log();
        IF_Log.BatchLog batchExcuteLog;
        List<String> excuteErrorMsgList = new List<String>();
        
        ifExcuteLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Excute:' + BC.getJobId() + ') 시작' + ' ####################');
        
        String reqMsg = '';
        String resMsg = '';
        
        Map<String, Object> result = new Map<String,Object>();
        Set<Id> scopeSet = new Set<Id>();
        Map<Id,String> oppMap = new Map<Id,String>();
        for(Opportunity opp :scopeList){
            oppMap.put(opp.Id, opp.OpportunityCode__c);
            scopeSet.add(opp.Id);  
        }
        IF_OpportunityActivityInfoCallOut.OutputHeader outHeader = IF_OpportunityActivityInfoCallOut.doCalloutSendingOpportunityActivityInfo(scopeSet);
        
        
        try {
            IF_Callout ifCallout = new IF_Callout(INTERFACE_ID);
            result = ifCallout.httpCallout(JSON.serialize(outHeader), '');
            system.debug('CallOut Result' + ' / ' + result);
            reqMsg = String.valueOf(result.get('Request'));
            resMsg = String.valueOf(result.get('Response'));
            ifExcuteLog.addLog('StatusCode : '  + String.valueOf(result.get('StatusCode')));
            ifExcuteLog.addLog('HttpResponse : '+ String.valueOf(result.get('HttpResponse')));
            Integer resStatusCode = (Integer)result.get('StatusCode');
            if (resStatusCode != null && (resStatusCode == 200 || resStatusCode == 202)) {
                List<BO_Activity_Complete__c> migOppList = [
                    SELECT Id,Name,OpportunityCode__c,Send_Check__c FROM  BO_Activity_Complete__c WHERE 
                    InterfaceId__c = 'IF-180' AND   Name IN :scopeSet
                ];
                
                for( BO_Activity_Complete__c migOpp : migOppList){
                    migOpp.Send_Check__c = true;
                    if(migOpp.OpportunityCode__c == null){
                        migOpp.OpportunityCode__c = oppMap.get(migOpp.name);
                    }
                }
                update migOppList;
                HttpResponse hRes = (HttpResponse)result.get('HttpResponse');
                ifExcuteLog.addLog('HttpResponse getBody : ' + hRes.getBody());
                ifExcuteLog.addLog('마이그 update : ' + migOppList.size() + ' 전송건수:'  + outHeader.Opportunity_Activity.size());
                ifExcuteLog.addLog('recHeader : ' + hRes.getBody());
                batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Excute', reqMsg, outHeader.Opportunity_Activity.size());
            } else {
                ifExcuteLog.addLog('Communication Error : ' + String.valueOf(result.get('Message')) + ' / StatusCode : ' + String.valueOf(resStatusCode));
                excuteErrorMsgList.add('Communication Error : ' + String.valueOf(result.get('Message')) + ' / StatusCode : ' + String.valueOf(resStatusCode));
                batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Excute', reqMsg, 0, 0, excuteErrorMsgList);
            }
            ifExcuteLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Excute:' + BC.getJobId() + ') 종료' + ' ####################');
            ifExcutelog.createLog(batchExcuteLog);
        } catch (Exception e) {
            ifExcuteLog.addLog('Exception : ' + e.getStackTraceString());
            excuteErrorMsgList.add('Exception : ' + e.getMessage());
            batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Excute', '', 0, 0, e);
            ifExcuteLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Excute:' + BC.getJobId() + ') 종료' + ' ####################');            
            ifExcutelog.createLog(batchExcuteLog);
        }
    }
    
    public void finish(DataBase.BatchableContext BC){
        IF_Log ifFinishLog = new IF_Log();
        IF_Log.BatchLog batchFinishLog;
        List<String> finishErrorMsgList = new List<String>();
        ifFinishLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Finish:' + BC.getJobId() + ') 시작' + ' ####################');
        batchFinishLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Finish', '', 0);
        ifFinishLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Finish:' + BC.getJobId() + ') 종료' + ' ####################');
        ifFinishLog.createLog(batchFinishLog);
        
         //IF-180 배치가 수행중이면 강제 종료.
            List<CronTrigger> schJobList = [SELECT Id,  CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = 'Batch_IF180callout'];
            for(CronTrigger obj : schJobList){
                System.abortJob(obj.id);
            }
            
            //IF-180 배치 종료후, 10분후 다시 IF-133 배치 수행.
            Integer iMin = Datetime.now().minute() + 5;
            if(iMin >= 60) iMin -=60;
            String min = String.valueOf(iMin);
            System.schedule('Batch_IF180callout', '0 '+min+' * * * ? *' , new Batch_IF180callout());
    }
    
    // 스케줄 호출
    public void execute(SchedulableContext SC){
        DataBase.executeBatch(new Batch_IF180callout(), 5);
    }
}