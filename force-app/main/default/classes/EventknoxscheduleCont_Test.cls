@IsTest
public class EventknoxscheduleCont_Test {
    @isTest(SeeAllData=true)
    public static void EventknoxscheduleCont_Test_1(){     
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EventknoxscheduleCont_TestMock(200));
        List<Event> listofEvents =[SELECT Id,Subject,ActivityDate,StartDateTime,EndDateTime,OwnerId,Owner.Email,Knox_Schedule_ID__c,Location,Description,IsAllDayEvent FROM Event LIMIT 1];
        String evId = listofEvents[0].Id;
        String result = EventknoxscheduleCont.getknoxscheduledata(evId);
        Test.stopTest();
    } 
    
    public class EventknoxscheduleCont_TestMock implements HttpCalloutMock {
        Integer returnStatusCode = 200;
        String returnStatus = 'OK';
        private EventknoxscheduleCont_TestMock() {    
            returnStatusCode = 200;
            setReturnStatus(returnStatusCode);
        }

        private EventknoxscheduleCont_TestMock(Integer statusCode) {
            returnStatusCode = statusCode;
            setReturnStatus(returnStatusCode);
        }
        private EventknoxscheduleCont_TestMock(Integer statusCode, String status) {
            returnStatusCode = statusCode;
            returnStatus = status;
        }
        private void setReturnStatus(Integer statusCode) {
            if (statusCode == 200) {
                returnStatus = 'OK';
            } else if (statusCode == 201) {
                returnStatus = 'Created';
            } else if (statusCode == 202) {
                returnStatus = 'Accepted';
            } else if (statusCode == 300) {
                returnStatus = 'Multiple Choice';
            } else if (statusCode == 301) {
                returnStatus = 'Moved Permanently';
            } else if (statusCode == 302) {
                returnStatus = 'Found';
            } else if (statusCode == 400) {
                returnStatus = 'Bad Request';
            } else if (statusCode == 401) {
                returnStatus = 'Unauthorized';
            } else if (statusCode == 402) {
                returnStatus = 'Payment Required';
            }
        } 
        
        public HTTPResponse respond(HTTPRequest request) {
            String url      = request.getEndPoint();
            System.debug('url::::' + url);
            String jsonData = getResponseData( url + '');
            HttpResponse response = new HttpResponse();

            System.debug( 'jsonData::::' + jsonData);

            response.setHeader('Content-Type', 'application/json');
            response.setBody( jsonData);
            response.setStatus(returnStatus);
            response.setStatusCode(returnStatusCode);

            return response;
        }

        public String getResponseData( String val){
            String jsonData = '{"data":{"invitedYn":"","subject":"Email","attendees":[{"sourceType":"EMPLOYEE","replyStatus":"ACCEPTED","type":"CHAIR","userId":"M220809055237C6N6079","seq":0}],"startTime":{"dateTime_SFDC":"2023-11-28T17:00:00+09:00","timeZone":"Asia/Seoul"},"endTime":{"dateTime_SFDC":"2023-11-28T18:00:00+09:00","timeZone":"Asia/Seoul"},"originalScheduleId":"","priority":"5","userId":"M220809055237C6N6079","calendarId":"CAL202311220820157525381580","contents":"abc","authority":"ALL","contentsCharset":"UTF-8","allDayYn":"N","class_SFDC":"PUBLIC","scheduleId":"SCH202311280744480635404428","recurrence":{"condition":"c1","endType":"a","count":"3","freqInterval":"6","freq":"8","until":"a"}},"result":"success","statusCode":200}'; 
        	return jsonData;
        }
    }
}