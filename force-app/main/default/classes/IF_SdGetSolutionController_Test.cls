/**
 * @description       : 
 * @author            : raeganja@partner.samsung.com
 * @group             : 
 * @last modified on  : 01-08-2021
 * @last modified by  : soohong0.kim@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   2020-12-28   raeganja@partner.samsung.com   Initial Version
**/
@isTest
public class IF_SdGetSolutionController_Test {
    //IF-063
    static final String REQUEST_DATA =
    '{' +
    '  "CT_SOL":[ ' +
    '	{ ' + 
    '	  "GUID": "0", ' +
    '	  "ZZORDER_ID": "SDS-20021960", ' +
    '	  "DESCRIPTION": "[신세계건설(주)] 하남빌리브 344세대 도어록(DP740) 납품설치", ' +
    '	  "NUMBER_INT": "10", ' +
    '	  "ZZSERVICE_CLASS": "20000012", ' +
    '	  "ZZSOLUTION": "30000028", ' +
    '	  "ZZBUKRS_H": "T100", ' +
    '	  "AERDAT": "2020.10.20", ' +
    '	  "ZZSALES_CELL_NAM": "T100-11975", ' +
    '	  "ZZDEVELOP_CELL_N": "T100-11975" ' +
    '	}, ' +
    '	{ ' + 
    '	  "GUID": "0", ' +
    '	  "ZZORDER_ID": "SDS-20021960", ' +
    '	  "DESCRIPTION": "[신세계건설(주)] 하남빌리브 344세대 도어록(DP740) 납품설치", ' +
    '	  "NUMBER_INT": "10", ' +
    '	  "ZZSERVICE_CLASS": "20000012", ' +
    '	  "ZZSOLUTION": "30000032", ' +
    '	  "ZZBUKRS_H": "T100", ' +
    '	  "AERDAT": "2020.10.20", ' +
    '	  "ZZSALES_CELL_NAM": "T100-11975", ' +
    '	  "ZZDEVELOP_CELL_N": "T100-11975" ' +
    '	} ' +
    '	] ' +
    '}';

    public IF_SdGetSolutionController_Test() {

    }

    @TestSetup
    static void makeData(){
        
    }

    @isTest
    static void testCallout() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));

        IF_SdGetSolutionController.InputClass inputClass  =  (IF_SdGetSolutionController.InputClass) JSON.deserialize( REQUEST_DATA, IF_SdGetSolutionController.InputClass.class);
        Map<String,Object> result =  IF_SdGetSolutionController.send(inputClass);
        System.assertEquals(result.get('StatusCode'), 200);

        HttpResponse resp = (HttpResponse)result.get('HttpResponse');
        Map<String,Object> returnMap = (Map<String,Object>) JSON.deserializeUntyped(resp.getBody());
        List<Object> dataList = (List<Object>) returnMap.get('CT_SOL');

        Map<String, Object> dataMap = (Map<String, Object>)dataList[0];
        System.assertEquals(String.valueOf(dataMap.get('ZZORDER_ID')), 'SDS-20021960');        

        Test.stopTest();
    }

    @isTest
    static void testCallout400() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(400));

        IF_SdGetSolutionController.InputClass inputClass  =  (IF_SdGetSolutionController.InputClass) JSON.deserialize( REQUEST_DATA, IF_SdGetSolutionController.InputClass.class);
        Map<String,Object> result =  IF_SdGetSolutionController.send(inputClass);
        System.assertEquals(result.get('StatusCode'), 400);      

        Test.stopTest();
    }

    @isTest
    static void testCalloutError() {
        Test.startTest();

        IF_SdGetSolutionController.InputClass inputClass  =  (IF_SdGetSolutionController.InputClass) JSON.deserialize( REQUEST_DATA, IF_SdGetSolutionController.InputClass.class);
        Map<String,Object> result =  IF_SdGetSolutionController.send(inputClass);     

        Test.stopTest();
    }
}