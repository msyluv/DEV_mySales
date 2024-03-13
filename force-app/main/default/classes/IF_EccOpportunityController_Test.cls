/**
 * @description       : 
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-05-05
 * @last modified by  : ghkil@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                      Modification
 * 1.0   2021-01-26   ghkil@partner.samsung.com   Initial Version
**/
@isTest
public class IF_EccOpportunityController_Test {

    // IF_EccOpportunityController 테스트 클래스
    // INTERFACE_ID = 'IF-125';
    // APEX_CLASS   = 'IF_EccOpportunityController';
    // METHOD_NAME  = 'calloutOpportunityInfo';

    public IF_EccOpportunityController_Test() {    }

    @TestSetup
    static void makeData(){

        IF_Callout_TestDataSetup.dataSetup();

        List<Opportunity> oppList = [SELECT id from Opportunity ];
        List<RevenueScheduleOpportunity__c> lrso = RevenueScheduleController.getOpportunitySchedules( oppList.get( 0).Id);
    }

    @isTest
    static void calloutTest(){
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));


        List<Opportunity> selectOpportunityList = [
            Select  Id
            From    Opportunity
        ];
        List<String> selectList = new List<String>();
        for (Opportunity opportunityData : selectOpportunityList) {
            selectList.add(opportunityData.Id);
        }

        IF_EccOpportunityController.calloutOpportunityInfo(selectList);
        
        // System.assertEquals(result.get('StatusCode'), 200);

        // HttpResponse resp = (HttpResponse)result.get('HttpResponse');
        // Map<String,Object> returnMap = (Map<String,Object>) JSON.deserializeUntyped(resp.getBody());
        // List<Object> dataList = (List<Object>)returnMap.get('ES_RTMSG');

        // Map<String, Object> dataMap = (Map<String, Object>)dataList[0];
        // System.assertEquals(String.valueOf(dataMap.get('TYPE')), 'S');

        Test.stopTest();
    }
}