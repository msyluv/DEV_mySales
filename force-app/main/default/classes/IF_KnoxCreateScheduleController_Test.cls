/**
 * @description       : 
 * @author            : soohong0.kim@partner.samsung.com
 * @group             : 
 * @last modified on  : 2020-12-29
 * @last modified by  : hj.lee@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   11-30-2020   soohong0.kim@partner.samsung.com   Initial Version
**/
@isTest
private class IF_KnoxCreateScheduleController_Test {
    private static testMethod void IF_KnoxCreateScheduleControllerTest() {

        Test.startTest();
        Test.setMock( HttpCalloutMock.class, new IF_Callout_TestMock());

        IF_KnoxCreateScheduleController.InputClass input = new IF_KnoxCreateScheduleController.InputClass();
        input.System_ID  = '00U1s000003NEp2EAG';
        input.calendarId = 'CALM201014060123C60971';
        input.userId     = 'hyojinn.lee';

        IF_KnoxCreateScheduleController.ScheduleInfo scInfo = new IF_KnoxCreateScheduleController.ScheduleInfo();
        scInfo.invitedYn = '';
        scInfo.subject   = '1210 / 11:03 TEST';
        scInfo.originalStartTime = '';
        scInfo.originalScheduleId = '';
        scInfo.priority   = '5';
        scInfo.userId     = 'hyojinn.lee';
        scInfo.sendMailYn = '';
        scInfo.recurrence = '';
        scInfo.calendarId = 'CALM201014060123C60971';
        scInfo.contentsType = 'Text';
        scInfo.contents   = null;
        scInfo.authority  = '';
        scInfo.contentsCharset = 'UTF-8';
        scInfo.allDayYn   = 'N';
        scInfo.place      = '';
        scInfo.class_SFDC = '';
        scInfo.placeCode  = '';



        IF_KnoxCreateScheduleController.Attendees att = new IF_KnoxCreateScheduleController.Attendees();
        List<IF_KnoxCreateScheduleController.Attendees> attList = new List<IF_KnoxCreateScheduleController.Attendees>();
        att.sourceType = 'EMPLOYEE';
        att.sourceType = 'replyStatus';
        att.sourceType = 'type';
        att.sourceType = 'userId';
        att.sourceType = 'seq';
        attList.add(att);

        scInfo.attendees = null;

        IF_KnoxCreateScheduleController.TimeTable timeTable = new IF_KnoxCreateScheduleController.TimeTable();
        IF_KnoxCreateScheduleController.TimeTable timeTable2 = new IF_KnoxCreateScheduleController.TimeTable();
        timeTable.date_SFDC = '';
        timeTable.dateTime_SFDC = '2020-12-10T05:00:00+09:00';
        timeTable.timeZone  = 'Asia/Seoul';
        scInfo.startTime    = timeTable;

        timeTable2.date_SFDC = '';
        timeTable2.dateTime_SFDC = '2020-12-10T06:00:00+09:00';
        timeTable2.timeZone  = 'Asia/Seoul';
        scInfo.endTime       = timeTable2;

        input.ScheduleInfo   = scInfo;
        Map<String, Object> returnMap = IF_KnoxCreateScheduleController.createSchedule(input);
        Integer statusCode   = Util_String.nvlInt( returnMap.get( 'StatusCode'));
        System.assertEquals( statusCode, 200);
      
        Test.stopTest();
    }
}