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
public class IF_PsCreatePjtNoController_Test {
    //IF-040
    static final String REQUEST_DATA =
    '{' +
    '  "IV_BIZ_PLAN": "", ' +
    '  "IS_HEADER": ' +
    '			{ ' + 
    '			  "ZZORDER_ID": "SDS-20061130", ' +
    '			  "DESCRIPTION": "[ID] SEIN-S 2020 NW EQUIP MA AUG20JUL21", ' +
    '			  "BUKRS": "T100", ' +
    '			  "MAIN_FKSTL": "T100-11159", ' +
    '			  "MAIN_AKSTL": "T100-12311", ' +
    '			  "ORIGIN_CUSTOMER": "A1061335", ' +
    '			  "CUSTOMER": "A1061335", ' +
    '			  "SALES_PLFAZ": "2020.07.07", ' +
    '			  "SALES_PLSEZ": "2021.07.31", ' +
    '			  "PLFAZ": "2020.08.01", ' +
    '			  "PLSEZ": "2021.07.31", ' +
    '			  "CONTRACT_EXP_DATE": "2020.07.30", ' +
    '			  "ZZSALEMP_CNO": 36549, ' +
    '			  "ZZPROPOSAL_PM_CNO": 27658, ' +
    '			  "ZZBIZ_LEVEL": "C", ' +
    '			  "ZZSUBS_PJT": "SDS-20061130" ' +
    '			}, ' +
    '  "IT_ITEM":[ ' +
    '			{ ' + 
    '			  "SERVICE": 20000020, ' +
    '			  "SERVICE_NAME": "10 : NETWORK", ' +
    '			  "SOLUTION": "30000067", ' +
    '			  "SOLUTION_NAME": "NETWORK IMPL", ' +
    '			  "SUB_FKSTL": "T100-11159", ' +
    '			  "SUB_AKSTL": "T100-12311", ' +
    '			  "ZZFHD_CD": "", ' +
    '			  "GUBUN": "1", ' +
    '			  "NUMBER_INT": 10, ' +
    '			  "ZZORDER_TYPE_S": "S135", ' +
    '			  "ZZBIZ_TYPE_S": "TI", ' +
    '			  "ZZWBS_CLASS_S": "SM", ' +
    '			  "ZZSERVICE_REP_X": "X" ' +
    '			} ' +
    '	], ' +
    '  "IT_TLINE":[ ' +
    '			{ ' + 
    '			  "TDLINE": "" ' +
    '			} ' +
    '	] ' +
    '}';

    public IF_PsCreatePjtNoController_Test() {

    }

    @TestSetup
    static void makeData(){
        
    }

    @isTest
    static void testCallout() {
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));

        IF_PsCreatePjtNoController.InputClass inputHeader  =  (IF_PsCreatePjtNoController.InputClass) JSON.deserialize( REQUEST_DATA, IF_PsCreatePjtNoController.InputClass.class);
        Map<String,Object> result =  IF_PsCreatePjtNoController.createPjtNo(inputHeader);
        //System.assertEquals(result.get('StatusCode'), 200);

        //HttpResponse resp = (HttpResponse)result.get('HttpResponse');
        //Map<String,Object> returnMap = (Map<String,Object>) JSON.deserializeUntyped(resp.getBody());

        System.assertEquals(String.valueOf(result.get('ET_PJT_CODE_A')), 'SMA-20061131-A0');

        Test.stopTest();
    }

    @isTest
    static void testCallout400() {
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(400));

        IF_PsCreatePjtNoController.InputClass inputHeader  =  (IF_PsCreatePjtNoController.InputClass) JSON.deserialize( REQUEST_DATA, IF_PsCreatePjtNoController.InputClass.class);
        Map<String,Object> result =  IF_PsCreatePjtNoController.createPjtNo(inputHeader);

        //System.assertEquals(result.get('StatusCode'), 400);

        Test.stopTest();
    }

    @isTest
    static void testCalloutError() {
        Test.startTest();

        IF_PsCreatePjtNoController.InputClass inputHeader  =  (IF_PsCreatePjtNoController.InputClass) JSON.deserialize( REQUEST_DATA, IF_PsCreatePjtNoController.InputClass.class);
        Map<String,Object> result =  IF_PsCreatePjtNoController.createPjtNo(inputHeader);

        Test.stopTest();
    }
}