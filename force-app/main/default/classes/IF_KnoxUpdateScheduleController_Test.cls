/**
 * @description       : 
 * @author            : soohong0.kim@partner.samsung.com
 * @group             : 
 * @last modified on  : 01-08-2021
 * @last modified by  : soohong0.kim@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   12-29-2020   soohong0.kim@partner.samsung.com   Initial Version
**/
@isTest
private class IF_KnoxUpdateScheduleController_Test {
    //IF-071
    private static testMethod void IF_KnoxUpdateScheduleControllerTest() {

        Test.startTest();
        Test.setMock( HttpCalloutMock.class, new IF_Callout_TestMock());

        IF_KnoxUpdateScheduleController.InputClass input = new IF_KnoxUpdateScheduleController.InputClass();
        input.System_ID         = '00U1s000003NEp2EAG';
        input.calendarId        = 'CALM201014060123C60971';
        input.scheduleId        = 'SCH202012151132151425558352';
        input.recurrenceModType = 'ONE';
        input.userId            = 'hyojinn.lee';
        
        IF_KnoxUpdateScheduleController.ScheduleInfo scInfo = new IF_KnoxUpdateScheduleController.ScheduleInfo();
        scInfo.invitedYn         = '';
        scInfo.subject           = 'Test subject';
        scInfo.originalStartTime = '';
        scInfo.originalScheduleId= '';
        scInfo.priority          = '5';
        scInfo.userId            = 'hyojinn.lee';
        scInfo.sendMailYn        = '';
        scInfo.recurrence        = '';
        scInfo.calendarId        = 'CALM201014060123C60971';
        scInfo.contentsType      = 'Text';
        scInfo.contents          = 'test contents';
        scInfo.authority         = '';
        scInfo.contentsCharset   = 'UTF-8';
        scInfo.allDayYn          = 'N';
        scInfo.place             = '';
        scInfo.class_SFDC        = '';
        scInfo.placeCode         = '';
        

        IF_KnoxUpdateScheduleController.Attendees att = new IF_KnoxUpdateScheduleController.Attendees();
        List<IF_KnoxUpdateScheduleController.Attendees> attList = new List<IF_KnoxUpdateScheduleController.Attendees>();
        att.sourceType  = 'EMPLOYEE';
        att.replyStatus = 'ACCEPTED';
        att.type        = 'CHAIR';
        att.userId      = 'M201014060123C60971';
        att.seq         = '0';
        attList.add(att);
        
        scInfo.attendees = attList;
        
        IF_KnoxUpdateScheduleController.TimeTable timeTable = new IF_KnoxUpdateScheduleController.TimeTable();
        IF_KnoxUpdateScheduleController.TimeTable timeTable2 = new IF_KnoxUpdateScheduleController.TimeTable();
        
        timeTable.dateTime_SFDC = '2020-12-15T05:00:00+09:00';
        timeTable.date_SFDC     = '';
        timeTable.timeZone      = 'Asia/Seoul';
        scInfo.startTime        = timeTable;
        
        timeTable2.date_SFDC    = '';
        timeTable2.dateTime_SFDC= '2021-01-30T06:00:00+09:00';
        timeTable2.timeZone     = 'Asia/Seoul';
        
        scInfo.endTime          = timeTable2;
        scInfo.startTime        = timeTable;
        scInfo.endTime          = timeTable2;
        
        input.ScheduleInfo      = scInfo;
        
        Map<String, Object> returnMap = IF_KnoxUpdateScheduleController.updateSchedule( input);
        Integer statusCode = Util_String.nvlInt( returnMap.get( 'StatusCode'));
        System.assertEquals( statusCode, 200);


        Test.stopTest();
    }
}