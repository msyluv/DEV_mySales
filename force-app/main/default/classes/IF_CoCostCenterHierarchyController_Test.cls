/**
 * @description       : 
 * @author            : soohong0.kim@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-03-02
 * @last modified by  : raeganja@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   01-07-2021   soohong0.kim@partner.samsung.com   Initial Version
**/

@isTest
public class IF_CoCostCenterHierarchyController_Test {
    final static String REQUEST_URL = '/services/apexrest/WebService/IF124';
    
    private static testMethod void restServiceTest() {
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;        
        request.httpMethod = 'POST';
        IF_CoCostCenterHierarchyController.IT_TABLE table = new IF_CoCostCenterHierarchyController.IT_TABLE();
        List<IF_CoCostCenterHierarchyController.IT_TABLE> tableList = new List<IF_CoCostCenterHierarchyController.IT_TABLE>();
        IF_CoCostCenterHierarchyController.InputClass input = new IF_CoCostCenterHierarchyController.InputClass();
        table.BUKRS = 'T100';
        table.KOSTL = 'T100-10851';
        table.NODE1 = 'T100';
        table.NODE2 = 'T100S2';
        table.NODE3 = 'T100S21';
        table.NODE4 = 'T100S213';
        table.NODE5 = 'T100S2131';
        table.TEXT1 = 'SDS HQ';
        table.TEXT2 = 'IT혁신사업부';
        table.TEXT3 = 'IT혁신사업부';
        table.TEXT4 = '지원팀(IT혁신)';
        table.TEXT5 = '지원팀(IT혁신)';
        table.KOSTL_KTEXT = '지원팀(IT혁신)';
        table.ZEXPIRED  = '20201020';
        // table.BKZER     = 'X';
        // table.BKZKP     = 'X';
        // table.BKZKS     = 'X';
        // table.BKZOB     = 'X';
        // table.PKZER     = 'X';
        // table.PKZKP     = 'X';
        // table.PKZKS     = 'X';
        
        tableList.add(table);
        
        input.IT_TABLE = tableList;

        request.requestBody = Blob.valueOf(JSON.serialize(input));
        RestContext.request  = request;
        RestContext.response = response;

        try {
            Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));
            IF_CoCostCenterHierarchyController.saveCostCenter();

        } catch (Exception e) {
            system.debug(e);
        }        

        Test.stopTest();
    }

}