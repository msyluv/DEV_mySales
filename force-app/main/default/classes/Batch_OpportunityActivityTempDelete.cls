/**
 * @description       : 임시로 생성된 Opportunity Activity Record 삭제
 * @author            : hj.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 2021-04-26
 * @last modified by  : hj.lee@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author             Modification
 * 1.0   2021-04-13   hj.lee@dkbmc.com   Initial Version
**/
public class Batch_OpportunityActivityTempDelete implements DataBase.Batchable<SObject>, DataBase.Stateful, DataBase.AllowsCallouts, Schedulable {
    /*
     	↓실행 코드 [실행 일시 : 매일 오전 3시]
		System.schedule('Opportunity Activity Temp Delete ', '0 0 3 * * ? *', new Batch_OpportunityActivityTempDelete());
	*/
    
    public String query = 'SELECT Id FROM Opportunity_Activity__c WHERE Status__c = null';
    public Date deleteBeforeTargetDate = system.today().addDays(-2);

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return DataBase.getQueryLocator(query + ' AND CreatedDate <= :deleteBeforeTargetDate');
    }

    public void execute(DataBase.BatchableContext BC, List<sObject> scope){
        delete scope;
    }

    public void finish(DataBase.BatchableContext BC){   
    }

    // 스케줄 호출
    public void execute(SchedulableContext SC){
        Batch_OpportunityActivityTempDelete controller = new Batch_OpportunityActivityTempDelete();
        DataBase.executeBatch(controller, 200);
    }
}