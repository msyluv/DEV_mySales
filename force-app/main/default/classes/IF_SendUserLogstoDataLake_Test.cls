/**
 * @description       : Test class for Program that sends user access logs for mySales to DataLake when requested (IF-181)
 * @author            : vikrant.ks@samsung.com
 * @group             : 
 * @last modified on  : 2023-05-23
 * @last modified by  : vikrant.ks@samsung.com 
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   2023-05-23   vikrant.ks@samsung.com   Initial Version(MySales 208)
**/
@isTest(SeeAllData=true)
public class IF_SendUserLogstoDataLake_Test{ 
    final static String REQUEST_URL = '/services/apexrest/WebService/IF181';
    @isTest
    public static void TestMethod1(){
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;    
        request.httpMethod = 'POST';

        String reqeustBody = '{"FROM_DATE":"20230519000000"}';

        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_SendUserLogstoDataLake.sendLoginHistorytoDataLake();

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

        String reqeustBody = '{"FROM_DATE":""}';//FROM DATE variable is Null or Empty.

        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_SendUserLogstoDataLake.sendLoginHistorytoDataLake();

        } catch (Exception e) {
            system.debug(e);
        }        
        Test.stopTest();
    }
    @isTest
    public static void TestMethod3(){
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;    
        request.httpMethod = 'POST';

        String reqeustBody = '{}';//Request body Is Null or Empty.

        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_SendUserLogstoDataLake.sendLoginHistorytoDataLake();

        } catch (Exception e) {
            system.debug(e);
        }        
        Test.stopTest();
    }
    @isTest
    public static void TestMethod4(){
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;     
        request.httpMethod = 'POST';

        String reqeustBody = '{"FROM_DATE":"20220501000000"}';//Total count is more than 50,000 records.//Only works for Production.

        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_SendUserLogstoDataLake.sendLoginHistorytoDataLake();

        } catch (Exception e) {
            system.debug(e);
        }        
        Test.stopTest();
    }
    @isTest
    public static void TestMethod5(){
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;    
        request.httpMethod = 'POST';

        String reqeustBody =    '{"FROM_DATE":"20230231000000"}';//Wrong data

        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_SendUserLogstoDataLake.sendLoginHistorytoDataLake();

        } catch (Exception e) {
            system.debug(e);
        }        
        Test.stopTest();
    }
}