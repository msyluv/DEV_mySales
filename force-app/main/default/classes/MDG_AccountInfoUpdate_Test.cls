/**
 * @description       : 
 * @author            : anish.jain@partner.samsung.com
 * @group             : 
 * @last modified on  : 12-26-2022
 * @last modified by  : anish.jain@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   12-26-2022   anish.jain@partner.samsung.com   Initial Version
**/

@isTest
public class MDG_AccountInfoUpdate_Test {
    
    static MDGAccount__c md1;
    static{
          List<MDGAccount__c> MDGList = new List<MDGAccount__c>();
          md1 = new MDGAccount__c(
            Name= 'TestMDG',
            BP_HEADER__c = 'A2040734',
            CITY1__c = 'CNSZH',
            CITY2__c = 'CNSZP',
            STREET__c = null,
            POST_CODE1__c= null,
            COUNTRY__c = 'Korea' ,
            REGION__c = 'Seoul',
            NAME1__c= 'Marketing Lead Converted',
            NAME2__c= 'CO,LTD',
            TEL_NUMBER__c = '1234567865',
            MDG_INFO__c = FALSE,
            Type__c = 'A'
        );
        MDGList.add(md1);
        insert MDGList;
    }
    
        @isTest
        public static void Test_Batch_MDGInfo(){
        Test.startTest();
        DataBase.executeBatch( new MDG_AccountInfoUpdate(), 10);
        Test.stopTest();
    }
    
        @isTest
        public static void Test_Shcedule(){
        Test.startTest();
        System.schedule('Test','0 0 4 * * ? *', new MDG_AccountInfoUpdate());
        Test.stopTest();
    }

}