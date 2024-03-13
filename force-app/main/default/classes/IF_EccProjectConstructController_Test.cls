/**
 * @description       : 
 * @author            : raeganja@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-01-25
 * @last modified by  : ghkil@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   2020-12-29   raeganja@partner.samsung.com   Initial Version
**/
@isTest
public class IF_EccProjectConstructController_Test {

    // IF_EccProjectConstructController 테스트 클래스
    // INTERFACE_ID = 'IF-067';
    // APEX_CLASS   = 'IF_EccProjectConstructController';
    // METHOD_NAME  = 'calloutProjectConstruct';

    public IF_EccProjectConstructController_Test() { }

    static final String REQUEST_DATA = 	'{' +
                                        '   "IV_PSPID": "SIC-20054481-A0" ' +
                                        '}';

    @TestSetup
    static void makeData(){

        IF_Callout_TestDataSetup.dataSetup();
    }

    @isTest
    static void testCallout() {
        Test.startTest();
                    
        List<Project__c> selectList = [
            Select  Id
                    , ProjectCode__c
            From    Project__c
        ];

        String requestData =    '{' +
                                // '   "IV_PSPID": "SIC-20054481-A0" ' +
                                '   "IV_PSPID": "' + selectList[0].ProjectCode__c + '" ' +                                
                                '}';

        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));

        Map<String, Object> result = IF_EccProjectConstructController.calloutProjectConstruct(requestData);
        System.assertEquals(result.get('StatusCode'), 200);

        HttpResponse resp = (HttpResponse)result.get('HttpResponse');
        Map<String,Object> returnMap = (Map<String,Object>) JSON.deserializeUntyped(resp.getBody());
        
        System.assertEquals(String.valueOf(returnMap.get('EV_RETURN')), 'N');

        Test.stopTest();
    }

    @isTest
    static void testCallout400() {
        Test.startTest();
                    
        List<Project__c> selectList = [
            Select  Id
                    , ProjectCode__c
            From    Project__c
        ];

        String requestData =    '{' +
                                // '   "IV_PSPID": "SIC-20054481-A0" ' +
                                '   "IV_PSPID": "' + selectList[0].ProjectCode__c + '" ' +                                
                                '}';
                                        
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(400));

        Map<String, Object> result = IF_EccProjectConstructController.calloutProjectConstruct(requestData);
        System.assertEquals(result.get('StatusCode'), 400);

        Test.stopTest();        
    }

    // @isTest
    // static void testCalloutError() {
    //     Test.startTest();

    //     Map<String, Object> result = IF_EccProjectConstructController.calloutProjectConstruct('Error');

    //     Test.stopTest();
    // }    
}