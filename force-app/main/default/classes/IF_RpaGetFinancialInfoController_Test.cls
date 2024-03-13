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
public class IF_RpaGetFinancialInfoController_Test {
    final static String REQUEST_URL = '/services/apexrest/WebService/IF019';

    public IF_RpaGetFinancialInfoController_Test() {

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

        IF_RpaGetFinancialInfoController accInfo = new IF_RpaGetFinancialInfoController();
        String sch = '0 0 23 * * ?';
        Integer ifRand = Math.random().intValue();
        system.schedule('IF_RpaGetFinancialInfoController_'+ifRand, sch, accInfo);

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
                                '            "InformationSource": "OPENDART", ' +
                                '            "Name": "Name", ' +
                                '            "TotalAssets": "0.0", ' +
                                '            "TotalLiability": "0.0", ' +
                                '            "TotalCapital": "0.0", ' +
                                '            "Revenue": "0.0", ' +
                                '            "OperatingProfit": "0.0", ' +
                                '            "NetIncome": "0.0" ' +
                                '       } ' +
                                '   ] ' +
                                '}';

        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {            
            IF_RpaGetFinancialInfoController.receiveFinancialInfo();
        } catch (Exception e) {
            system.debug(e);
        }        

        Test.stopTest();
    }
}