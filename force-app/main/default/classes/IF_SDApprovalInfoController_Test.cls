/**
* @description       : Test Class of IF_SDApprovalInfoController(IF-183)
* @author            : vikrant.ks@samsung.com
* @group             : 
* @last modified on  : 2023-07-25 
* @last modified by  : vikrant.ks@samsung.com 
* Modifications Log 
* Ver   Date         Author                   Modification
* 1.0   2023-07-25    vikrant.ks@samsung.com   Initial Version(MySales 265)
**/
@isTest
public class IF_SDApprovalInfoController_Test {
    
    final static String REQUEST_URL = '/services/apexrest/WebService/IF185';
    
    @isTest
    public static void TestMethod1(){
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;   
        request.httpMethod = 'POST';
		
        String reqeustBody ='{"OpportunityCode":"SDS-22001260","CompanyCode":"T100","Version":"S001","Closedate":"2023.04.15","TotalAmt":"10000","Curr":"USD","DiffAmt":"0","TotalAmt_Loc":"13038000","Currency_Loc":"KRW","DiffAmt_Loc":"0","Rate_yn":"N","Contractno":"N12345","Confirmdate":"2023.04.15"}';
		request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_SDApprovalInfoController.ReceiveDatafromSD();

        } catch (Exception e) {
            system.debug(e);
        }        
        Test.stopTest();
    }
    @isTest
    public static void TestMethod2(){
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;   
        request.httpMethod = 'POST';
		
        String reqeustBody ='{"OpportunityCode":"SDS-22001260","CompanyCode":"T100","Version":"S001","Closedate":"2023/04/15","TotalAmt":"10000","Curr":"USD","DiffAmt":"0","TotalAmt_Loc":"13038000.9864","Currency_Loc":"KRW","DiffAmt_Loc":"0","Rate_yn":"N"}';
		request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_SDApprovalInfoController.ReceiveDatafromSD();

        } catch (Exception e) {
            system.debug(e);
        }        
        Test.stopTest();
    }
}