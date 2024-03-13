@isTest
public class Schedule_EccOpptyLogisErrSend_Test {
	@isTest
    public static void Test_Schedule_EccOpptyLogisErrSend(){
        Test.startTest();
        Schedule_EccOpptyLogisErrSendController SES = new Schedule_EccOpptyLogisErrSendController();
        System.Schedule('Schedule_EccOpptyLogisErrSendController', '0 0 1,4,7,10,13,16,19,22 * * ? *', SES);
        Test.stopTest();
    }
}