/**
 * @description       : 
 * @author            : Junghwa.Kim@dkbmc.com
 * @group             : 
 * @last modified on  : 2021-10-27
 * @last modified by  : seonju.jin@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                  Modification
 * 1.0   2021-02-19   Junghwa.Kim@dkbmc.com   Initial Version
**/
global class Schedule_OpptyEmailAlertController implements Schedulable {
    public Boolean stageChangeFlag = true;
    global void execute( SchedulableContext SC){
        Batch_OpptyEmailAlertController ps = new Batch_OpptyEmailAlertController();
        ps.EMAIL_TEMP = ps.STAGE_CHANGE;
        ps.stageChangeFlag = stageChangeFlag;
        Database.executeBatch(ps,50);
    }
}