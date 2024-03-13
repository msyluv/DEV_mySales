/**
 * @description       : 
 * @author            : soohong0.kim@partner.samsung.com
 * @group             : 
 * @last modified on  : 01-05-2021
 * @last modified by  : soohong0.kim@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   01-05-2021   soohong0.kim@partner.samsung.com   Initial Version
**/
@isTest
public class IF_KnoxApprovalStatusController_Test {
    private static testMethod void IF_KnoxApprovalStatusControllerTest() {

        Test.startTest();
        Test.setMock( HttpCalloutMock.class, new IF_Callout_TestMock());
        List<IF_KnoxApprovalStatusController.InputClass> inputList = new List<IF_KnoxApprovalStatusController.InputClass>();
        inputList.add(new IF_KnoxApprovalStatusController.InputClass('test'));
        Map<String, Object> returnMap = IF_KnoxApprovalStatusController.approvalStatus(inputList);
        Integer statusCode   = Util_String.nvlInt( returnMap.get( 'StatusCode'));
        System.assertEquals( statusCode, 200);
      
        Test.stopTest();
    }
}