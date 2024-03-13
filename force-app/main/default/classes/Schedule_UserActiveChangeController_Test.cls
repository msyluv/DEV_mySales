@isTest
private class Schedule_UserActiveChangeController_Test {
    @isTest static void test_method_1() {
        Schedule_UserActiveChangeController schedule = new Schedule_UserActiveChangeController();
        String sch = '0 0 9 * * ?';
        system.schedule('User Inactive Batch', sch, schedule);    
    }    
}