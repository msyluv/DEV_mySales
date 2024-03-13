/**
 * @description       : 
 * @author            : dongyoung.kim@dkbmc.com
 * @group             : 
 * @last modified on  : 2020-11-17
 * @last modified by  : dongyoung.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2020-11-17   dongyoung.kim@dkbmc.com   Initial Version
**/
global class Schedule_UserActiveChangeController implements Schedulable{

    /*
        Schedule_UserActiveChangeController schedule = new Schedule_UserActiveChangeController();
        String sch = '0 0 9 * * ?';
        system.schedule('User Inactive Batch', sch, schedule);
    */

	global void execute(SchedulableContext SC) {        
		Batch_UserActiveChangeController batch = new Batch_UserActiveChangeController();
		database.executebatch(batch, 200);
    }
}