@isTest
public class Schedule_EccOpptyHQErrSend_Test {
	@isTest
    public static void Test_Schedule_EccOpptyHQErrSend(){
        Test.startTest();
        Schedule_EccOpptyHQErrSendController SES = new Schedule_EccOpptyHQErrSendController();
        System.Schedule('Schedule_EccOpptyHQErrSendController', '0 0 0,3,6,9,12,15,18,21 * * ? *', SES);
        Test.stopTest();
    }
}