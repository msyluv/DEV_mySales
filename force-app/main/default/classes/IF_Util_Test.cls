/**
 * @description       : 
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-03-18
 * @last modified by  : ghkil@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                      Modification
 * 1.0   2020-10-28   ghkil@partner.samsung.com   Initial Version
**/
@isTest
public with sharing class IF_Util_Test {

    @isTest
    static void test() {
        system.assertEquals('S', IF_Util.RESULT_STATUS_SUCCESS);
        system.assertEquals('F', IF_Util.RESULT_STATUS_FAILED);
        system.assertEquals('E', IF_Util.RESULT_STATUS_ERROR);

//        IF_Util util = new IF_Util();
        System.assertEquals(datetime.valueOfGMT('2020-10-21 00:00:00'), IF_Util.convertDatetime(Date.valueof('2020-10-21')));
        System.assertEquals(10.0, IF_Util.convertDecimalToLong(10));
        System.assertEquals(Date.valueOf('2020-10-21'), IF_Util.convertStringToDate('20201021'));

        try {
            String objName = 'Account';
            String recordTypeName = 'Construction';
            String rtId = IF_Util.getRecordTypeId(objName, recordTypeName);
            String rtIdValue = Schema.getGlobalDescribe().get(objName).getDescribe().getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
            System.assertEquals(rtId, rtIdValue);
            
        } catch (Exception e) {
            system.debug(e.getMessage());
        }

        try {
            String objName = 'Account';
            
            Map<String, String> rtAcMap = IF_Util.getRecordTypeMap(objName);
            System.assert(!rtAcMap.isEmpty());
        } catch (Exception e) {
            system.debug(e.getMessage());
        }        

        system.assertEquals(Userinfo.getUserId(), IF_Util.getUserRecord().Id);
        system.assert(IF_Util.generateGuid() != '');
        system.assertEquals('IF-008', IF_Util.getInterfaceMdt('IF-008')[0].InterfaceId__c);
        system.assertEquals('Hot', IF_Util.getPicklist('Account', 'Rating')[0].Label);

        IF_Util.makePayLoad('IF-000', IF_Util.generateGuid(), 'ClassName', 'POST', '{ "TOTAL_COUNT":1, "EV_RESULT":"S" }');

        Map<String, DatedConversionRate> rateMap1 = IF_UTIL.getRecentlyDatedConversionRate();
        // Map<String, DatedConversionRate> rateMap2 = IF_UTIL.getDatedConversionRate(system.today().addDays(-10), system.today());
        // List<Date> selectDate = new List<Date>();
        // selectDate.add(system.today().addDays(-10));
        // selectDate.add(system.today());
        // Map<String, DatedConversionRate> rateMap3 = IF_UTIL.getDatedConversionRate(selectDate);
        Map<String, DatedConversionRate> rateMap3 = IF_UTIL.getDatedConversionRate(new List<Date>{system.today().addDays(-10), system.today()});

        // Decimal currencyResult1 = IF_UTIL.calculationCurrency('KRW', 1000.0, 'JPY');
        Decimal currencyResult2 = IF_UTIL.calculationCurrency('KRW', 1000.0, 'JPY', 0.9, 1.1);

        // IF_Callout_TestDataSetup.dataSetup();
        // Set<Id> solutionIdSet = new Set<Id>();
        // Solution__c selectSolution = [Select Id From Solution__c][0];
        // solutionIdSet.add(selectSolution.Id);
        // Map<Id, IF_Util.solutionCalculationClass> result = IF_Util.solutionCalculationCurrency(solutionIdSet);        
    }    
}