/**
 * @description       : 
 * @author            : yeongju.baek@dkbmc.com
 * @group             : 
 * @last modified on  : 2022-11-30
 * @last modified by  : anish.jain@partner.samsung.com 
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   08-03-2021   yeongju.baek@dkbmc.com   Initial Version
 * 1.1   2022-11-30   anish.jain@partner.samsung.com  scheduling as per bacth size '5'
**/
public class Schedule_SalesLeadEmail implements schedulable{
	//↓실행 코드 [실행 일시 : 매일 오전 4시]
    public void execute(SchedulableContext cx){
        //System.Schedule('Batch_SalesLeadEmail', '0 0 4 * * ? *', new Batch_SalesLeadEmail());
        Batch_SalesLeadEmail b = new Batch_SalesLeadEmail();
       	database.executebatch(b,5);
    }

}