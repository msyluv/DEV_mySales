/**
 * @description       : 
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-08-10
 * @last modified by  : seonju.jin@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                      Modification
 * 1.0   2021-01-27   ghkil@partner.samsung.com   Initial Version
**/
@isTest
public class IF_LsDashboardController_Test {

    // IF_LsDashboardController_Test 테스트 클래스
    // INTERFACE_ID = 'IF-042';
    // APEX_CLASS   = 'IF_LsDashboardController';
    // METHOD_NAME  = 'CalloutDashboardInfo';

    public IF_LsDashboardController_Test() {    }

    @TestSetup
    static void makeData(){

        IF_Callout_TestDataSetup.dataSetup();
    }
    
    @isTest
    static void calloutTest(){
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));

        List<Opportunity> opptyList = [
            Select  Id
            From    Opportunity
        ];
        Set<Id> opptyIdSet = new Set<Id>();
        for (Opportunity oppty : opptyList) {
            opptyIdSet.add(oppty.Id);
        }

        IF_LsDashboardController.calloutDashboardInfo(opptyIdSet);

        Test.stopTest();
    }        
}