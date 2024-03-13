/**
 * @description       : 
 * @author            : raeganja@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-01-18
 * @last modified by  : raeganja@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   2021-01-15   raeganja@partner.samsung.com   Initial Version
**/
@isTest
public class IF_LegGetProfitLossController_Test {
    final static String REQUEST_URL = '/services/apexrest/WebService/IF031';

    public IF_LegGetProfitLossController_Test() {

    }    

    @TestSetup
    static void makeData(){

    }

    @isTest
    static void testCallout() {
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));

        IF_LegGetProfitLossController controller = new IF_LegGetProfitLossController();
        String sch = '0 0 23 * * ?';
        system.schedule('IF_LegGetProfitLossController', sch, controller);

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
                                '           "BizYear":"2020", '+
                                '           "Version":"001", '+
                                '           "REAL_FLAG2":"R", '+
                                '           "CompanyCode":"", '+
                                '           "CompanyName":"", '+
                                '           "BACode":"", '+
                                '           "BAName":"", '+
                                '           "BALANCE_FLAG":"", '+
                                '           "Opportunity":"", '+
                                '           "OpportunityName":"", '+
                                '           "Project":"", '+
                                '           "ProjectName":"", '+
                                '           "RegionCode":"", '+
                                '           "RegionName":"", '+
                                '           "SalesDeptL1":"", '+
                                '           "SalesDeptNameL1":"", '+
                                '           "SalesDeptL2":"", '+
                                '           "SalesDeptNameL2":"", '+
                                '           "SalesDeptL3":"", '+
                                '           "SalesDeptNameL3":"", '+
                                '           "SalesDeptL4":"", '+
                                '           "SalesDeptNameL4":"", '+
                                '           "SalesDeptL5":"", '+
                                '           "SalesDeptNameL5":"", '+
                                '           "DeliveryDeptL1":"", '+
                                '           "DeliveryDeptL2":"", '+
                                '           "DeliveryDeptL3":"", '+
                                '           "DeliveryDeptL4":"", '+
                                '           "DeliveryDeptL5":"", '+
                                '           "DeliveryDeptName":"", '+
                                '           "BizType1":"", '+
                                '           "BizType2":"", '+
                                '           "ServiceCode":"", '+
                                '           "ServiceName":"", '+
                                '           "SolutionCode":"", '+
                                '           "SolutionName":"", '+
                                '           "OriginAccount":"", '+
                                '           "AccountName":"", '+
                                '           "StndCustCode":"", '+
                                '           "StndCustName":"", '+
                                '           "GroupInOut":"", '+
                                '           "LocalInternational":"", '+
                                '           "CurrencyIsoCode":"", '+
                                '           "Contract01":"", '+
                                '           "Contract02":"", '+
                                '           "Contract03":"", '+
                                '           "Contract04":"", '+
                                '           "Contract05":"", '+
                                '           "Contract06":"", '+
                                '           "Contract07":"", '+
                                '           "Contract08":"", '+
                                '           "Contract09":"", '+
                                '           "Contract10":"", '+
                                '           "Contract11":"", '+
                                '           "Contract12":"", '+
                                '           "Revenue01":"", '+
                                '           "Revenue02":"", '+
                                '           "Revenue03":"", '+
                                '           "Revenue04":"", '+
                                '           "Revenue05":"", '+
                                '           "Revenue06":"", '+
                                '           "Revenue07":"", '+
                                '           "Revenue08":"", '+
                                '           "Revenue09":"", '+
                                '           "Revenue10":"", '+
                                '           "Revenue11":"", '+
                                '           "Revenue12":"", '+
                                '           "Profit01":"", '+
                                '           "Profit02":"", '+
                                '           "Profit03":"", '+
                                '           "Profit04":"", '+
                                '           "Profit05":"", '+
                                '           "Profit06":"", '+
                                '           "Profit07":"", '+
                                '           "Profit08":"", '+
                                '           "Profit09":"", '+
                                '           "Profit10":"", '+
                                '           "Profit11":"", '+
                                '           "Profit12":"" '+
                                '       } ' +
                                '   ] ' +
                                '}';

        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {            
            IF_LegGetProfitLossController.receiveProfitLoss();
        } catch (Exception e) {
            system.debug(e);
        }        

        Test.stopTest();
    }
}