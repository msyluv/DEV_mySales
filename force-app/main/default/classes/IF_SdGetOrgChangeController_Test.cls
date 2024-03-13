/**
 * @description       : 
 * @author            : raeganja@partner.samsung.com
 * @group             : 
 * @last modified on  : 01-08-2021
 * @last modified by  : soohong0.kim@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   2020-12-10   raeganja@partner.samsung.com   Initial Version
**/
@isTest
public class IF_SdGetOrgChangeController_Test {
    //IF-016
    static final String REQUEST_DATA =
    '{' +
    '  "IV_BUKRS": "T100", ' +
    '  "IV_OTSEQ": 1, ' +
    '  "IT_POSID":[ ' +
    '			{ ' + 
    '			  "WBS_ELEMENT": "SCA07000285A001" ' +
    '			} ' +
    '	] ' +
    '}';

    public IF_SdGetOrgChangeController_Test() {

    }

    @TestSetup
    static void makeData(){
        
    }

    @isTest
    static void testCallout() {
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));

        IF_SdGetOrgChangeController.InputClass inputHeader  =  (IF_SdGetOrgChangeController.InputClass) JSON.deserialize( REQUEST_DATA, IF_SdGetOrgChangeController.InputClass.class);
        Map<String,Object> result =  IF_SdGetOrgChangeController.getOrgChange(inputHeader);
        //System.assertEquals(result.get('StatusCode'), 200);

        //HttpResponse resp = (HttpResponse)result.get('HttpResponse');
        //Map<String,Object> returnMap = (Map<String,Object>) JSON.deserializeUntyped(resp.getBody());

        System.assertEquals(String.valueOf(result.get('EV_ERROR')), 'S');

        Test.stopTest();
    }

    @isTest
    static void testCallout400() {
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(400));

        IF_SdGetOrgChangeController.InputClass inputHeader  =  (IF_SdGetOrgChangeController.InputClass) JSON.deserialize( REQUEST_DATA, IF_SdGetOrgChangeController.InputClass.class);
        Map<String,Object> result =  IF_SdGetOrgChangeController.getOrgChange(inputHeader);

        //System.assertEquals(result.get('StatusCode'), 400);

        Test.stopTest();
    }

    @isTest
    static void testCalloutError() {
        Test.startTest();

        IF_SdGetOrgChangeController.InputClass inputHeader  =  (IF_SdGetOrgChangeController.InputClass) JSON.deserialize( REQUEST_DATA, IF_SdGetOrgChangeController.InputClass.class);        
        Map<String,Object> result =  IF_SdGetOrgChangeController.getOrgChange(inputHeader);

        Test.stopTest();
    }
}