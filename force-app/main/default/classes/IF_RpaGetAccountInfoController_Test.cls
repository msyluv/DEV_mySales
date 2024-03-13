/**
 * @description       : 
 * @author            : raeganja@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-01-14
 * @last modified by  : raeganja@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   2021-01-13   raeganja@partner.samsung.com   Initial Version
**/
@isTest
public class IF_RpaGetAccountInfoController_Test {
    final static String REQUEST_URL = '/services/apexrest/WebService/IF022';

    public IF_RpaGetAccountInfoController_Test() {

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

        IF_RpaGetAccountInfoController accInfo = new IF_RpaGetAccountInfoController();
        String sch = '0 0 23 * * ?';
        Integer ifRand = Math.random().intValue();
        system.schedule('IF_RpaGetAccountInfoController_'+ifRand, sch, accInfo);

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
                                '            "CorporateNumber": "1048158502", ' +
                                '            "eInfoSource": "OPENDART", ' +
                                '            "eAccName": "(주)아이마켓코리아", ' +
                                '            "eAccNameE": "iMarketKorea Inc.", ' +
                                '            "eCEOName": "남인봉", ' +
                                '            "eAddress": "서울특별시 강남구 삼성로 512 삼성동빌딩 16층", ' +
                                '            "ePhoneNum": "02-3708-5678", ' +
                                '            "eFaxNum": "02-3708-5797", ' +
                                '            "eHomepage": "www.imarketkorea.com", ' +
                                '            "eCorporateNum": "1048158502", ' +
                                '            "eEstablishmentDate": "2001-12-08", ' +
                                '            "eIndustryCode": "", ' +
                                '            "eUpdateDateB": "2019-12-30" ' +
                                '       } ' +
                                '   ] ' +
                                '}';

        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {            
            IF_RpaGetAccountInfoController.receiveAccountInfo();
        } catch (Exception e) {
            system.debug(e);
        }        

        Test.stopTest();
    }
}