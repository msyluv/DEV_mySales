/**
 * @description       : 
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-01-11
 * @last modified by  : ghkil@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                      Modification
 * 1.0   2020-01-11   ghkil@partner.samsung.com   Initial Version
 **/
global class Schedule_EccOpportunityController implements Schedulable { // Schedulable

    // 스케줄 호출
    public void execute( SchedulableContext SC){
        DataBase.executeBatch( new Batch_EccOpportunityController(), 50);
    }
}