@isTest
public class Schedule_SalesLeadEmail_Test {
    @isTest
    public static void Test_Schedule_SalesLeadEmail(){
        Test.startTest();
        Schedule_SalesLeadEmail SSE = new Schedule_SalesLeadEmail();
        System.Schedule('Schedule_SalesLeadEmail', '0 0 4 * * ? *', SSE);
        Test.stopTest();
    }
}