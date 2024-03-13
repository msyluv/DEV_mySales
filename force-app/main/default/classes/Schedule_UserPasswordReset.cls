global class Schedule_UserPasswordReset implements Schedulable{

    /*
        Batch_UserPasswordReset schedule = new Batch_UserPasswordReset();
        system.schedule('User Inactive Batch', sch, schedule);
    */

	global void execute(SchedulableContext SC) {        
		Batch_UserActiveChangeController batch = new Batch_UserActiveChangeController();
		database.executebatch(batch, 200);
    }
}