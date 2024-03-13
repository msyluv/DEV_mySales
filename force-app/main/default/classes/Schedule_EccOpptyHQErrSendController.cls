/**
 * @description       : 
 * @author            : yeongju.baek@dkbmc.com
 * @group             : 
 * @last modified on  : 11-03-2021
 * @last modified by  : yeongju.baek@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   11-03-2021   yeongju.baek@dkbmc.com   Initial Version
**/
public class Schedule_EccOpptyHQErrSendController implements schedulable{
    //3시, 6시, 9시, 12시, 15시, 18시, 21시, 24시 매일 실행
    public void execute(SchedulableContext cx){
        System.Schedule('Batch_EccOpportunityHQErrSendController', '0 0 0,3,6,9,12,15,18,21 * * ? *', new Batch_EccOpportunityHQErrSendController());
    }
}