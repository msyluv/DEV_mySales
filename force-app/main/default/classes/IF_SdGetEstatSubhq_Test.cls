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
public class IF_SdGetEstatSubhq_Test {
    //IF-005
    static final String REQUEST_DATA =
    '{' +
    '  "IV_BUKRS": "T100", ' +
    '  "IT_ORDER_ID":[ ' +
    '			{ ' + 
    '			  "IV_ZZORDER_ID": "SDS-20054480" ' +
    '			} ' +
    '	] ' +
    '}';

    public IF_SdGetEstatSubhq_Test() {

    }

    @TestSetup
    static void makeData(){
        
    }

    @isTest
    static void testCallout() {
        Test.startTest();
                        
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));

        IF_SdGetEstatSubhq.InputClass inputHeader  =  (IF_SdGetEstatSubhq.InputClass) JSON.deserialize( REQUEST_DATA, IF_SdGetEstatSubhq.InputClass.class);
        Map<String,Object> result =  IF_SdGetEstatSubhq.getEstatSubhq(inputHeader);
        //System.assertEquals(result.get('StatusCode'), 200);

        //HttpResponse resp = (HttpResponse)result.get('HttpResponse');
        //Map<String,Object> returnMap = (Map<String,Object>) JSON.deserializeUntyped(resp.getBody());        
        List<Object> objList = (List<Object>) result.get('ET_ESTAT');
        Map<String, Object> resultAttributes = (Map<String, Object>)objList[0];

        System.assertEquals(String.valueOf(resultAttributes.get('EV_ZZORDER_ID')), 'SIC20054481A000');

        Test.stopTest();
    }

    @isTest
    static void testCallout400() {
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(400));

        IF_SdGetEstatSubhq.InputClass inputHeader  =  (IF_SdGetEstatSubhq.InputClass) JSON.deserialize( REQUEST_DATA, IF_SdGetEstatSubhq.InputClass.class);
        Map<String,Object> result =  IF_SdGetEstatSubhq.getEstatSubhq(inputHeader);

        //System.assertEquals(result.get('StatusCode'), 400);

        Test.stopTest();
    }

    @isTest
    static void testCalloutError() {
        Test.startTest();

        IF_SdGetEstatSubhq.InputClass inputHeader  =  (IF_SdGetEstatSubhq.InputClass) JSON.deserialize( REQUEST_DATA, IF_SdGetEstatSubhq.InputClass.class);
        Map<String,Object> result =  IF_SdGetEstatSubhq.getEstatSubhq(inputHeader);

        Test.stopTest();
    }
}