@isTest
public class batch_UpsertKnoxSchedules_Test {
    
    @isTest
    static void testBatch1(){
        
        Event e = new Event();
        e.Subject = 'Meeting01';
        e.StartDateTime = Date.valueOf('2023-12-19T16:30:00+09:00');
        e.EndDateTime = Date.valueOf('2023-12-19T17:00:00+09:00');
        e.Location = 'Korea';
        e.Description ='Test1';
        e.ActivityDateTime = Date.valueof('2023-12-19T17:00:00+09:00');
        e.Type = 'CHAIR';
        e.Knox_Schedule_ID__c = 'SCH202312180702227266826011';
        e.DurationInMinutes = 0;
        e.IsAllDayEvent = false;
        
        Event e1 = new Event();
        e1.Subject = 'Meeting01';
        e1.StartDateTime = Date.valueOf('2023-12-19T10:00:00+09:00'); //SJOSHI: changed '2023-12-20T00' to '2023-12-19T10'
        e1.EndDateTime = Date.valueOf('2023-12-20T00:00:00+09:00'); 
        e1.Location = 'Korea';
        e1.Description ='Test1';
      //  e1.ActivityDateTime = Date.valueof('2023-12-20');
        e1.Type = 'CHAIR';
        e1.Knox_Schedule_ID__c = 'SCH202312180702227266826041';
        e1.IsAllDayEvent = true;
        insert e1;
        Map<String,String> newknoxMapDateStart = new Map<String,String>();
        newknoxMapDateStart.put(e.Knox_Schedule_ID__c,'2023-12-19T16:30:00+09:00');
        newknoxMapDateStart.put('SCH202312180702227266826211','2023-12-20T16:30:00+09:00');

        List<String> listofknox = new List<String>();
        listofknox.add('SCH202312180702227266826011');

        Map<String,String> newknoxMapDateSingle = new  Map<String,String>{'SCH202312180702227266826011' => '2023-12-19',
                                                                              'SCH202312180702227266826211'=> '2023-12-20',
                                                                             'SCH202312180702227266826311'=> '2023-12-21',
                                                                                  'SCH202312180702227266826041' => '2023-12-19'};//SJOSHI: changed '2023-12-20' to '2023-12-19'
        Map<String,String> newknoxMapDate = new Map<String,String>{'SCH202312180702227266826011' => '2023-12-19T16:30:00+09:00',
            													   'SCH202312180702227266826211' => '2023-12-20T16:50:00+09:00'}; // SJOSHI: changed T16:30 to T16:50
            														//'SCH202312180702227266826041' => '2023-12-19T10:00:00+09:00'}; //SJOSHI: added

        Map<String, Object> result = new Map<String, Object>{

            'allDayYn'    => 'N',
            'attachs'  => '[]',
            'attendees'=> '[{"sourceType":"EMPLOYEE","displayName":"Divyam Gupta/Engineer/Global Solution Part/SDSI","replyStatus":"ACCEPTED","type":"CHAIR","userId":"M220809055237C6N6079","email":"divyam.gupta@stage.samsung.com","seq":0}]',
            'authority'=> 'ALL',
            'calendarId'     => 'CAL202312141037198851625229',
            'class_SFDC'  => 'PUBLIC',
            'contents'       => 'test1',
            'contentsType'      => 'MIME',
            'endTime'	=> '{"dateTime_SFDC":"2023-12-19T17:00:00+09:00","timeZone":"Asia/Seoul"}',
            'invitedYn' => 'N',
            'scheduleId' => 'SCH202312180702227266826011'

        };
                 Map<String, Object> result1 = new Map<String, Object>{

            'allDayYn'    => 'N',
            'attachs'  => '[]',
            'attendees'=> '[{"sourceType":"EMPLOYEE","displayName":"Divyam Gupta/Engineer/Global Solution Part/SDSI","replyStatus":"ACCEPTED","type":"CHAIR","userId":"M220809055237C6N6079","email":"divyam.gupta@stage.samsung.com","seq":0}]',
            'authority'=> 'ALL',
            'calendarId'     => 'CAL202312141037198851625229',
            'class_SFDC'  => 'PUBLIC',
            'contents'       => 'test1',
            'contentsType'      => 'MIME',
            'endTime'	=> '{"dateTime_SFDC":"2023-12-20T17:00:00+09:00","timeZone":"Asia/Seoul"}',
            'invitedYn' => 'N',
            'scheduleId' => 'SCH202312180702227266826211'

        };
              Map<String, Object> result2 = new Map<String, Object>{

            'allDayYn'    => 'Y',
            'attachs'  => '[]',
            'attendees'=> '[{"sourceType":"EMPLOYEE","displayName":"Divyam Gupta/Engineer/Global Solution Part/SDSI","replyStatus":"ACCEPTED","type":"CHAIR","userId":"M220809055237C6N6079","email":"divyam.gupta@stage.samsung.com","seq":0}]',
            'authority'=> 'ALL',
            'calendarId'     => 'CAL202312141037198851625229',
            'class_SFDC'  => 'PUBLIC',
            'contents'       => 'test1',
            'contentsType'      => 'MIME',
            'endTime'	=> '{"dateTime_SFDC":"2023-12-20T17:00:00+09:00","timeZone":"Asia/Seoul"}',
            'invitedYn' => 'N',
            'scheduleId' => 'SCH202312180702227266826311'

        };
                Map<String, Object> result3 = new Map<String, Object>{

            'allDayYn'    => 'Y',
            'attachs'  => '[]',
            'attendees'=> '[{"sourceType":"EMPLOYEE","displayName":"Divyam Gupta/Engineer/Global Solution Part/SDSI","replyStatus":"ACCEPTED","type":"CHAIR","userId":"M220809055237C6N6079","email":"divyam.gupta@stage.samsung.com","seq":0}]',
            'authority'=> 'ALL',
            'calendarId'     => 'CAL202312141037198851625229',
            'class_SFDC'  => 'PUBLIC',
            'contents'       => 'test1',
            'contentsType'      => 'MIME',
            'endTime'	=> '{"dateTime_SFDC":"2023-12-20T17:00:00+09:00","timeZone":"Asia/Seoul"}',
            'invitedYn' => 'N',
            'scheduleId' => 'SCH202312180702227266826041'

        };
            
        Map<String,Map<String,Object>> newknoxMap = new Map<String,Map<String,Object>>();
        newknoxMap.put('SCH202312180702227266826011', result);
         newknoxMap.put('SCH202312180702227266826211', result1);
         newknoxMap.put('SCH202312180702227266826311', result2);
         newknoxMap.put('SCH202312180702227266826041', result3);
        

        //Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));
        insert e;
        
         // SJOSHI: Start
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = '시스템 관리자'];
        User u = new User(Alias = 'testUser', Email = 'testUser@abc.com', EmailEncodingKey = 'UTF-8', 
                          LastName = 'testing', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', 
                          ProfileId = p.Id, TimeZoneSidKey = 'America/Los_Angeles', UserName = 'tu@abc.com');
        //User myTestUser = UserFactory.createTestUser();
        // SJOSHI: End
        
        Test.startTest();
        // SJOSHI: Start
        System.runAs(u){
            Id batchJobId = Database.executeBatch(new batch_UpsertKnoxSchedules('SCH202312180702227266826011', 'Meeting01', 'MIME', 'test1', '2023-12-19', '2023-12-19T17:00:00+09:00', newknoxMap, newknoxMapDate, newknoxMapDateSingle, listofknox, newknoxMapDateStart), 201);
        }
        // SJOSHI: End
        Test.stopTest();
    }

}