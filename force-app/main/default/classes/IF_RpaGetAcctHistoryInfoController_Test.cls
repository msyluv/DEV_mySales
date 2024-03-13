/**
 * @description       : 
 * @author            : raeganja@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-01-13
 * @last modified by  : raeganja@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   2021-01-13   raeganja@partner.samsung.com   Initial Version
**/
@isTest
public class IF_RpaGetAcctHistoryInfoController_Test {
    final static String REQUEST_URL = '/services/apexrest/WebService/IF021';

    public IF_RpaGetAcctHistoryInfoController_Test() {

    }

    @TestSetup
    static void makeData(){
        Account acc = new Account(
             Name = '(주)아이마켓코리아'
            ,CorporateNumber__c = '1048158502'
        );
        
        insert acc;
    }

    @isTest
    static void testCallout() {
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));

        IF_RpaGetAcctHistoryInfoController accInfo = new IF_RpaGetAcctHistoryInfoController();
        String sch = '0 0 23 * * ?';
        Integer ifRand = Math.random().intValue();
        system.schedule('IF_RpaGetAcctHistoryInfoController_'+ifRand, sch, accInfo);

        //System.assertEquals(String.valueOf(result.get('EV_RESULT')), 'S');

        Test.stopTest();
    }

    @isTest
    static void restServiceTest() {
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';

        String reqeustBody =    '{ ' +
                                '   "IT_DATA":[ ' +
                                '       { ' +
                                '            "BizRegNo": "1048158502", ' +
                                '            "InfoSource": "OPENDART", ' +
                                '            "HistoryDate": "20201231", ' +
                                '            "Description": "Description" ' +
                                '       } ' +
                                '   ] ' +
                                '}';

        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {            
            IF_RpaGetAcctHistoryInfoController.receiveAcctHistoryInfo();
        } catch (Exception e) {
            system.debug(e);
        }        

        Test.stopTest();
    }
}