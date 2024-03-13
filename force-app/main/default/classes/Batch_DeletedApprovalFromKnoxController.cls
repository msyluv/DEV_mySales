/**
 * @description       : 상신일 기준 31일 되는 시점에 knox 결재 미결인 건에 대해 'canceled'로 상태 업데이트. Knox쪽 결재이력은 30일 시점으로 삭제됨.
 * @author            : kj78.yu@partner.samsung.com
 * @group             : 
 * @last modified on  : 2022-10-24
 * @last modified by  : kj78.yu@partner.samsung.com
 * Execute Script Code : database.executebatch(new Batch_DeletedApprovalFromKnoxController(), 20);
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   2022-10-24   kj78.yu@partner.samsung.com   Initial Version
**/
public class Batch_DeletedApprovalFromKnoxController implements Database.Stateful, Database.Batchable<sObject>, Database.AllowsCallouts, schedulable {
    private static final String INTERFACE_ID = '';
    private static final String APEX_CLASS   = 'Batch_DeletedApprovalFromKnoxController'; 
    private static final String METHOD_NAME  = 'Batch';
    private static String guId = IF_Util.generateGuid();
    
    List<KnoxApproval__c> approvalList;
    
    public Batch_DeletedApprovalFromKnoxController(){
        system.debug('### Batch_DeletedApprovalFromKnoxController :: constructor ');   
        approvalList = new List<KnoxApproval__c>();
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        IF_Log ifStartLog = new IF_Log();
        IF_Log.BatchLog batchStartLog;
        batchStartLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Start', '', 0);
        ifStartLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Start:' + BC.getJobId() + ') 시작' + ' ####################');
        
        Date dDay = Date.today().addDays(-31);	// 현재일 기준 31일전 결재이력.
        
        String query = '';        
        query = ' SELECT Id, Status__c, MISID__c, CreatedDate FROM KnoxApproval__c WHERE Status__c = \'1\' AND CreatedDate < :dDay AND Opportunity__c != null And OpportunityActivity__c != null ';
        
        system.debug('### Batch_DeletedApprovalFromKnoxController :: start :: query = ' + query);
        
        ifStartLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Start:' + BC.getJobId() + ') 종료' + ' ####################');
        ifStartLog.createLog(batchStartLog);

        return DataBase.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<KnoxApproval__c> listKnoxApproval) {        
        system.debug('### Batch_DeletedApprovalFromKnoxController :: execute :: listKnoxApproval = ' + listKnoxApproval);
        IF_Log ifExcuteLog = new IF_Log();
        IF_Log.BatchLog batchExcuteLog;
        
        for(KnoxApproval__c rowKnoxApproval : listKnoxApproval){
            rowKnoxApproval.Status__c = '4';	//상신취소
            approvalList.add(rowKnoxApproval);            
        }
        
        ifExcuteLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Excute:' + BC.getJobId() + ') 종료' + ' ####################');
        batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Excute', '', 0);
        ifExcutelog.createLog(batchExcuteLog);
    }
    
    public void finish(Database.BatchableContext bc) {
        //로그 생성 -> Trigger 에서 Batch 호출로 인해 Chain 처리
        system.debug('### Batch_DeletedApprovalFromKnoxController :: finish :: approvalList = ' + approvalList.size());
        system.debug('### Batch_DeletedApprovalFromKnoxController :: finish :: approvalList = ' + approvalList);
        
        if(approvalList.size()>0) Database.Update(approvalList, false);
        
        IF_Log ifFinishLog = new IF_Log();
        IF_Log.BatchLog batchFinishLog;
        batchFinishLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Finish', '', 0);
        ifFinishLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 종료' + ' ####################');
        
        ifFinishLog.createLog(batchFinishLog);
    }
    
    public void execute(SchedulableContext sc) {
        database.executebatch(new Batch_DeletedApprovalFromKnoxController(), 200);
    }
}