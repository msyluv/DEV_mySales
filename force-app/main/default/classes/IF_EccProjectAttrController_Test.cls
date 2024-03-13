/**
 * @description       : 
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 2022-01-06
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                      Modification
 * 1.0   2020-12-01   ghkil@partner.samsung.com   Initial Version
**/
@isTest
public class IF_EccProjectAttrController_Test {

    // IF_EccProjectAttrController 테스트 클래스
    // INTERFACE_ID = 'IF-009';
    // APEX_CLASS   = 'IF_EccProjectAttrController';
    // METHOD_NAME  = 'calloutSendProjectAttrInfo';

    public IF_EccProjectAttrController_Test() { }

    static final String REQUEST_DATA = 	'{' +
                                        '  "IT_DATA": [ ' +
                                        '	{ ' +
                                        '	  "CLASS_SFDC": 30000076, ' +
                                        '	  "ZZORDER_TYPE": "S144", ' +
                                        '	  "ZOPPT_TYPE": "TI", ' +
                                        '	  "ZZWBS_CLASS": "SI", ' +
                                        '	  "ZZUSEYN": "Y", ' +
                                        '	  "ZZPS_TYPE": "SI3" ' +
                                        '	}, ' +                                        
                                        '	{ ' +
                                        '	  "CLASS_SFDC": 30000076, ' +
                                        '	  "ZZORDER_TYPE": "S144", ' +
                                        '	  "ZOPPT_TYPE": "TI", ' +
                                        '	  "ZZWBS_CLASS": "SI", ' +
                                        '	  "ZZUSEYN": "Y", ' +
                                        '	  "ZZPS_TYPE": "" ' +                                        
                                        '	}, ' +
                                        '	{ ' +
                                        '	  "CLASS_SFDC": 30000076, ' +
                                        '	  "ZZORDER_TYPE": "S109", ' +
                                        '	  "ZOPPT_TYPE": "TI", ' +
                                        '	  "ZZWBS_CLASS": "SI", ' +
                                        '	  "ZZUSEYN": "Y", ' +
                                        '	  "ZZPS_TYPE": "" ' +                                        
                                        '	}, ' +
                                        '	{ ' +
                                        '	  "CLASS_SFDC": 30000076, ' +
                                        '	  "ZZORDER_TYPE": "S109", ' +
                                        '	  "ZOPPT_TYPE": "TI", ' +
                                        '	  "ZZWBS_CLASS": "SM", ' +
                                        '	  "ZZUSEYN": "Y", ' +
                                        '	  "ZZPS_TYPE": "" ' +                                        
                                        '	}, ' +
                                        '	{ ' +
                                        '	  "CLASS_SFDC": 30000076, ' +
                                        '	  "ZZORDER_TYPE": "S109", ' +
                                        '	  "ZOPPT_TYPE": "TI", ' +
                                        '	  "ZZWBS_CLASS": "SC", ' +
                                        '	  "ZZUSEYN": "Y", ' +
                                        '	  "ZZPS_TYPE": "" ' +                                        
                                        '	}, ' +
                                        '	{ ' +
                                        '	  "CLASS_SFDC": 30000027, ' +
                                        '	  "ZZORDER_TYPE": "S109", ' +
                                        '	  "ZOPPT_TYPE": "TI", ' +
                                        '	  "ZZWBS_CLASS": "SI", ' +
                                        '	  "ZZUSEYN": "Y", ' +
                                        '	  "ZZPS_TYPE": "" ' +                                        
                                        '	}, ' +
                                        '	{ ' +
                                        '	  "CLASS_SFDC": 30000027, ' +
                                        '	  "ZZORDER_TYPE": "S149", ' +
                                        '	  "ZOPPT_TYPE": "TI", ' +
                                        '	  "ZZWBS_CLASS": "SM", ' +
                                        '	  "ZZUSEYN": "Y", ' +
                                        '	  "ZZPS_TYPE": "" ' +
                                        '	}, ' +
                                        '	{ ' +
                                        '	  "CLASS_SFDC": 30000027, ' +
                                        '	  "ZZORDER_TYPE": "S999", ' +
                                        '	  "ZOPPT_TYPE": "TI", ' +
                                        '	  "ZZWBS_CLASS": "SM", ' +
                                        '	  "ZZUSEYN": "Y", ' +
                                        '	  "ZZPS_TYPE": "" ' +
                                        '	}, ' +
                                        '	{ ' +
                                        '	  "CLASS_SFDC": 30000027, ' +
                                        '	  "ZZORDER_TYPE": "S122", ' +
                                        '	  "ZOPPT_TYPE": "TI", ' +
                                        '	  "ZZWBS_CLASS": "SC", ' +
                                        '	  "ZZUSEYN": "Y", ' +
                                        '	  "ZZPS_TYPE": "" ' +
                                        '	}, ' +
                                        '	{ ' +                                        
                                        '	  "CLASS_SFDC": 30000027, ' +
                                        '	  "ZZORDER_TYPE": "S124", ' +
                                        '	  "ZOPPT_TYPE": "TI", ' +
                                        '	  "ZZWBS_CLASS": "SC", ' +
                                        '	  "ZZUSEYN": "Y", ' +
                                        '	  "ZZPS_TYPE": "" ' +
                                        '	}, ' +                                       
                                        '	{ ' +                                        
                                        '	  "CLASS_SFDC": 30000027, ' +
                                        '	  "ZZORDER_TYPE": "S131", ' +
                                        '	  "ZOPPT_TYPE": "TI", ' +
                                        '	  "ZZWBS_CLASS": "SC", ' +
                                        '	  "ZZUSEYN": "Y", ' +
                                        '	  "ZZPS_TYPE": "" ' +
                                        '	}, ' +                                                                                
                                        '	{ ' +                                        
                                        '	  "CLASS_SFDC": 30000999, ' +
                                        '	  "ZZORDER_TYPE": "S156", ' +
                                        '	  "ZOPPT_TYPE": "TI", ' +
                                        '	  "ZZWBS_CLASS": "SI", ' +
                                        '	  "ZZUSEYN": "Y", ' +
                                        '	  "ZZPS_TYPE": "" ' +
                                        '	}, ' +                                                                                
                                        '	{ ' +                                        
                                        '	  "CLASS_SFDC": 30000999, ' +
                                        '	  "ZZORDER_TYPE": "S149", ' +
                                        '	  "ZOPPT_TYPE": "TI", ' +
                                        '	  "ZZWBS_CLASS": "SM", ' +
                                        '	  "ZZUSEYN": "Y", ' +
                                        '	  "ZZPS_TYPE": "" ' +
                                        '	}, ' +                       
                                        '	{ ' +                                        
                                        '	  "CLASS_SFDC": 30000999, ' +
                                        '	  "ZZORDER_TYPE": "S999", ' +
                                        '	  "ZOPPT_TYPE": "TI", ' +
                                        '	  "ZZWBS_CLASS": "SM", ' +
                                        '	  "ZZUSEYN": "Y", ' +
                                        '	  "ZZPS_TYPE": "" ' +
                                        '	}, ' +    
                                        '	{ ' +                                        
                                        '	  "CLASS_SFDC": 30000999, ' +
                                        '	  "ZZORDER_TYPE": "S122", ' +
                                        '	  "ZOPPT_TYPE": "TI", ' +
                                        '	  "ZZWBS_CLASS": "SC", ' +
                                        '	  "ZZUSEYN": "Y", ' +
                                        '	  "ZZPS_TYPE": "" ' +
                                        '	}, ' +                                                                                                                       
                                        '	{ ' +                                        
                                        '	  "CLASS_SFDC": 30000999, ' +
                                        '	  "ZZORDER_TYPE": "S124", ' +
                                        '	  "ZOPPT_TYPE": "TI", ' +
                                        '	  "ZZWBS_CLASS": "SC", ' +
                                        '	  "ZZUSEYN": "Y", ' +
                                        '	  "ZZPS_TYPE": "" ' +
                                        '	}, ' +
                                        '	{ ' +                                        
                                        '	  "CLASS_SFDC": 30000999, ' +
                                        '	  "ZZORDER_TYPE": "S131", ' +
                                        '	  "ZOPPT_TYPE": "TI", ' +
                                        '	  "ZZWBS_CLASS": "SC", ' +
                                        '	  "ZZUSEYN": "Y", ' +
                                        '	  "ZZPS_TYPE": "" ' +
                                        '	}, ' +
                                        '	{ ' +                                        
                                        '	  "CLASS_SFDC": 30000999, ' +
                                        '	  "ZZORDER_TYPE": "S156", ' +
                                        '	  "ZOPPT_TYPE": "TI", ' +
                                        '	  "ZZWBS_CLASS": "SC", ' +
                                        '	  "ZZUSEYN": "Y", ' +
                                        '	  "ZZPS_TYPE": "" ' +
                                        '	} ' +                                                                                                                                                                                                                                             
                                        '  ], ' +
                                        '  "IT_ORDER_TYPE": [ ' +
                                        '	{ ' +
                                        '	  "SPRAS": "EN", ' +
                                        '	  "ZZORDER_TYPE": "S109", ' +
                                        '	  "ZZORDER_TYPE_T": "SI/NI Implementation", ' +
                                        '	  "ZZUSERYN": "Y", ' +
                                        '	  "ZZPS_TYPE": "SI1" ' +				                                        
                                        '	} ' +
                                        '  ] ' +
                                        '}';
                                        
    @TestSetup
    static void makeData(){    }

    @isTest
    static void testCallout() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));

        Map<String, Object> result = IF_EccProjectAttrController.calloutSendProjectAttrInfo(REQUEST_DATA);
        System.assertEquals(result.get('StatusCode'), 200);

        HttpResponse resp = (HttpResponse)result.get('HttpResponse');
        Map<String,Object> returnMap = (Map<String,Object>) JSON.deserializeUntyped(resp.getBody());
        List<Object> dataList = (List<Object>)returnMap.get('ES_RTMSG');

        Map<String, Object> dataMap = (Map<String, Object>)dataList[0];
        System.assertEquals(String.valueOf(dataMap.get('TYPE')), 'S');

        Test.stopTest();
    }

    @isTest
    static void testCallout400() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(400));

        Map<String, Object> result = IF_EccProjectAttrController.calloutSendProjectAttrInfo(REQUEST_DATA);
        System.assertEquals(result.get('StatusCode'), 400);

        Test.stopTest();
    }

    @isTest
    static void testCalloutError() {
        Test.startTest();

        IF_EccProjectAttrController.calloutSendProjectAttrInfo('Error');

        Test.stopTest();
    }    
}