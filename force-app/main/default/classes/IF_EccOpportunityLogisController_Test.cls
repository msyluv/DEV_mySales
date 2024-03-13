/**
 * @description       : 
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-01-27
 * @last modified by  : ghkil@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                      Modification
 * 1.0   2021-01-27   ghkil@partner.samsung.com   Initial Version
**/
@isTest
public class IF_EccOpportunityLogisController_Test {

    // IF_EccOpportunityLogisController 테스트 클래스
    // INTERFACE_ID = 'IF-094';
    // APEX_CLASS   = 'IF_EccOpportunityLogisController';
    // METHOD_NAME  = 'calloutOpportunityLogisInfo';

    public IF_EccOpportunityLogisController_Test() {    }

    @TestSetup
    static void makeData(){

        IF_Callout_TestDataSetup.dataSetup();
    }

    @isTest
    static void calloutTest(){
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));

        List<Opportunity> selectOpportunityList = [
            Select  Id
            From    Opportunity
            Where   RecordType.DeveloperName = 'Logistics'
        ];
        List<String> selectList = new List<String>();
        for (Opportunity opportunityData : selectOpportunityList) {
            selectList.add(opportunityData.Id);
        }

        IF_EccOpportunityLogisController.calloutOpportunityLogisInfo(selectList);
        
        Test.stopTest();
    }
}