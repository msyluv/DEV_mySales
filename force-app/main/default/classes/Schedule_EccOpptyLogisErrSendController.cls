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
public class Schedule_EccOpptyLogisErrSendController implements schedulable{
    //1시, 4시, 7시, 10시, 13시, 16시, 19시, 22시 매일 실행
	public void execute(SchedulableContext cx){
        System.Schedule('Batch_EccOpptyLogisErrSendController', '0 0 1,4,7,10,13,16,19,22 * * ? *', new Batch_EccOpptyLogisErrSendController());
    }
}