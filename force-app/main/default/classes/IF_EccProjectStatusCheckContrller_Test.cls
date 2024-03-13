/**
 * @description       : 
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-01-25
 * @last modified by  : ghkil@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                      Modification
 * 1.0   2020-12-28   ghkil@partner.samsung.com   Initial Version
**/
@isTest
public class IF_EccProjectStatusCheckContrller_Test {

    // IF_EccProjectStatusCheckContrller 테스트 클래스
    // INTERFACE_ID = 'IF-056';
    // APEX_CLASS   = 'IF_EccProjectStatusCheckContrller';
    // METHOD_NAME  = 'calloutProjectStatusCheck';

    public IF_EccProjectStatusCheckContrller_Test() {    }
    
    @TestSetup
    static void makeData(){

        IF_Callout_TestDataSetup.dataSetup();
    }

    @isTest
    static void testCallout() {
        Test.startTest();
        
        List<Project__c> selectList = [
            Select  Id
                    , Name
                    , ProjectCode__c
                    , ProjectType__c
                    , Opportunity__r.OpportunityCode__c
                    , Opportunity__r.CompanyCode__c
                    , Opportunity__r.ActivityStatus__c
            From    Project__c
        ];

        String requestData = 	'{' +
                                '   "IV_BUKRS":"' + selectList[0].Opportunity__r.CompanyCode__c + '", ' +
                                '   "IV_ZZORDER_ID":"' + selectList[0].Opportunity__r.OpportunityCode__c + '", ' +
                                '	"IV_PS_TYPE":"' + 'ZP82' +'", ' +
                                '	"IV_PSPID":"' + selectList[0].ProjectCode__c + '", ' +
                                '	"IV_PJTCHK":"X" ' +
                                '}';

        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));

        Map<String, Object> result = IF_EccProjectStatusCheckContrller.calloutProjectStatusCheck(requestData);
        System.assertEquals(result.get('StatusCode'), 200);

        HttpResponse resp = (HttpResponse)result.get('HttpResponse');
        Map<String,Object> returnMap = (Map<String,Object>) JSON.deserializeUntyped(resp.getBody());
        List<Object> dataList = (List<Object>)returnMap.get('T_RTN');

        Map<String, Object> dataMap = (Map<String, Object>)dataList[0];
        System.assertEquals(String.valueOf(dataMap.get('TYPE')), 'W');
        Test.stopTest();
    }

    @isTest
    static void testCallout400() {
        Test.startTest();

        List<Project__c> selectList = [
            Select  Id
                    , Name
                    , ProjectCode__c
                    , ProjectType__c
                    , Opportunity__r.OpportunityCode__c
                    , Opportunity__r.CompanyCode__c
                    , Opportunity__r.ActivityStatus__c
            From    Project__c
        ];

        String requestData = 	'{' +
                                '   "IV_BUKRS":"' + selectList[0].Opportunity__r.CompanyCode__c + '", ' +
                                '   "IV_ZZORDER_ID":"' + selectList[0].Opportunity__r.OpportunityCode__c + '", ' +
                                '	"IV_PS_TYPE":"' + 'ZP82' +'", ' +
                                '	"IV_PSPID":"' + selectList[0].ProjectCode__c + '", ' +
                                '	"IV_PJTCHK":"X" ' +
                                '}';

        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(400));

        Map<String, Object> result = IF_EccProjectStatusCheckContrller.calloutProjectStatusCheck(requestData);
        System.assertEquals(result.get('StatusCode'), 400);

        Test.stopTest();
    }

    // @isTest
    // static void testCalloutError() {
    //     Test.startTest();

    //     Map<String, Object> result = IF_EccProjectStatusCheckContrller.calloutProjectStatusCheck('Error');

    //     Test.stopTest();
    // }

}