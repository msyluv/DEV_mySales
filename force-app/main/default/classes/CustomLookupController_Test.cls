/**
 * @File Name          : CustomLookupController_Test.cls
 * @Description        : 
 * @Author             : MinGyoon Woo (woomg@dkbmc.com)
 * @Group              : 
 * @Last Modified By   : woomg@dkbmc.com
 * @Last Modified On   : 01-20-2021
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    7/10/2019, 12:00:00 PM   MinGyoon Woo (woomg@dkbmc.com)     Initial Version
**/
@IsTest
public with sharing class CustomLookupController_Test {
    static {

        Account ac = new Account(
            Name='Test Account'
        );
        insert ac;
    }

    @IsTest
	private static void testMethodOne() {
        Test.startTest();
        system.debug(CustomLookupController.initComponent('Account'));
        system.debug(CustomLookupController.queryRecords('Test', 'Account', '', '', '', '', '', '', '', '', false, '', '5', false));
        try {
            system.debug(CustomLookupController.queryRecords('Test', 'Account', 'Email', '', '', '', '', '', '', '', false, '', '5', false));
        } catch(Exception e){}
        system.debug(CustomLookupController.getCreatedRecord('Account'));
        system.debug(CustomLookupController.makeQueryString('Email, Phone'));
        system.debug(CustomLookupController.makeSearchString('Email, Phone', 'Test'));
        system.debug(CustomLookupController.makeFilterString('User', 'Email, Phone','empty, 0000','eq,eq',''));
        system.debug(CustomLookupController.makeRecordTypeFilter('Email, Phone'));
        system.debug(CustomLookupController.makeOrderBy('Email, Phone'));
        system.debug(CustomLookupController.convertOperator('eq'));
        system.debug(CustomLookupController.convertOperator('ne'));
        system.debug(CustomLookupController.convertOperator('gt'));
        system.debug(CustomLookupController.convertOperator('lt'));
        system.debug(CustomLookupController.convertOperator('gte'));
        system.debug(CustomLookupController.convertOperator('lte'));

    }

    /*
    @isTest static void fetchLookUpValues() {
        Test.startTest();
        String searchKeyWord = '';
        String ObjectName = '';
        String FilterField = '';
        String filterValue = ''; 
        String filterCondition = ''; 
        String searchType = ''; 
        String myRecord = '';

        searchKeyWord = 'Test';
        ObjectName = 'Employee__c';
        FilterField = '';
        filterValue = ''; 
        filterCondition = ''; 
        searchType = 'Base'; 
        myRecord = 'Y';
        customLookUpController.fetchLookUpValues(searchKeyWord,ObjectName,FilterField,filterValue,filterCondition,searchType,myRecord);
        Test.stopTest();
    }
    */
}