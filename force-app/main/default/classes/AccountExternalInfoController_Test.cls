/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2021-01-29
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2021-01-29   younghoon.kim@dkbmc.com   Initial Version
**/
@isTest
private class AccountExternalInfoController_Test {
    static Account acc;
    static String finance;
    static String history;
    static String manager;

    static {
        acc = new Account(
            Name = 'Test Account'
        );
        insert acc;
    }
    @isTest static void test_method_1() {
        Test.startTest();
        AccountExternalInfoController.accountInfoCheck(acc.Id);

        acc.CorporateNumber__c = '1018159273';
        update acc;

        AccountExternalInfoController.accountInfoCheck(acc.Id);
		Test.stopTest();
    }
    
    @isTest static void test_method_2() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock());

        Map<String, String> suc_rtnMap = AccountExternalInfoController.getExternalInformation('1018159272');
        System.debug('suc_rtnMap : ' + suc_rtnMap);
        System.debug('suc_rtnMap FINANCE : ' + suc_rtnMap.get('FINANCE'));
        System.debug('suc_rtnMap HISTORY : ' + suc_rtnMap.get('HISTORY'));
        System.debug('suc_rtnMap MANAGER : ' + suc_rtnMap.get('MANAGER'));
        
        finance = suc_rtnMap.get('FINANCE');
		history = suc_rtnMap.get('HISTORY');
        manager = suc_rtnMap.get('MANAGER');
        
        // Map<String, String> err_rtnMap = AccountExternalInfoController.getExternalInformation('10181'); // Exception
        // System.debug('err_rtnMap : ' + err_rtnMap);
        
        AccountExternalInfoController.it_data exData = new AccountExternalInfoController.it_data();
        exData.InfoSource = 'OPENDART';
        exData.NameKR = '놀라운 회사';
        exData.NameEN = 'Amazing company';
        exData.CeoName = '김깜놀';
        exData.Address = '서울특별시 서초구 서초대로 123 12층';
        exData.Phone = '02-1111-2222';
        exData.Fax = '02-2222-1111';
        exData.Website = 'www.amazingcompany.com';
        
        AccountExternalInfoController.accInfoSave(acc.Id, JSON.serialize(exData), finance, history, manager);
		Test.stopTest();
    }

    @isTest static void test_method_3() {
        
        /*
        Test.startTest();
        AccountExternalInfoController.externalData exData = new AccountExternalInfoController.externalData();
        exData.InfoSource = '흥신소';
        exData.NameKR = '놀라운 회사';
        exData.NameEN = 'Amazing company';
        exData.CeoName = '김깜놀';
        exData.Address = '서울특별시 서초구 서초대로 123 12층';
        exData.Phone = '02-1111-2222';
        exData.Fax = '02-2222-1111';
        exData.Website = 'www.amazingcompany.com';
        
        AccountExternalInfoController.accInfoSave(acc.Id, JSON.serialize(exData));
		Test.stopTest();
        */
    }
}