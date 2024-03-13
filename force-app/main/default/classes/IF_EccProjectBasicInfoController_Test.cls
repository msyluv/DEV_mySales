/**
 * @description       : 
 * @author            : raeganja@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-02-15
 * @last modified by  : raeganja@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   2021-02-05   raeganja@partner.samsung.com   Initial Version
**/
@isTest
public class IF_EccProjectBasicInfoController_Test {
    public IF_EccProjectBasicInfoController_Test() {

    }

    static Account acc;
    static Opportunity oppty;
    static final String REQUEST_DATA = 	'0061s000005QCXuAAO';

    @TestSetup
    static void makeData(){
        RecordType RT_OPPTY_HQ        = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'HQ' Limit 1];

        Company__c insertCompany = new Company__c (
            Name                = 'C60 - Name'
            , CompanyCode__c    = 'C60'
            , EPCompanyCode__c  = 'EP1'
            , CurrencyIsoCode   = 'KRW'
            , Country__c        = 'KR'
        );
        Insert insertCompany;

        CostCenter__c insertCostCenter = new CostCenter__c(
            Name                = '기술전략팀(T100-11331)'
            , CurrencyIsoCode   = 'KRW'
            , CompanyCode__c    = 'C60'
            , CostCenterName__c = '기술전략팀'
            , CostCenter__c     = 'C60-11331'
            , Node1__c          = 'C60'
            , Node2__c          = 'C60SB'
            , Node3__c          = 'C60SB1'
            , Node4__c          = 'C60SB13'
            , Node5__c          = 'C60SB131'
            , Company__c        = insertCompany.Id
        );
        Insert insertCostCenter;

        Department__c insertDepartment = new Department__c(
            Name                = '기술기획팀'
            , CurrencyIsoCode   = 'KRW'
            , Abtel__c          = 'C60AI562'
            , Bkzer__c          = 'X'
            , Bukrs__c          = 'C60'
            , Datab__c          = System.today()
            , DatabI__c         = Date.valueOf('4000-12-31')
            , EKText__c         = '기술기획팀'
            , Kostl__c          = 'C60-11331'
        );
        Insert insertDepartment;

        Opportunity hqOppty = new Opportunity(
            Name                    = 'testOpp1'
            , RecordTypeId          = RT_OPPTY_HQ.Id
            , CloseDate             = System.today()
            , StageName             = 'Z01'
            , SalesDepartment__c    = insertCostCenter.Id
            , Amount                = 1000000
            , CurrencyIsoCode       = 'KRW'
            , OpportunityCode__c    = 'SDS-15016921'
            , MigData__c            = false
        );
        Insert hqOppty;
    }

    @isTest
    static void testCallout() {
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));

        Opportunity oppty = [Select Id From Opportunity where OpportunityCode__c = 'SDS-15016921' limit 1];
        Map<String, Object> result = IF_EccProjectBasicInfoController.getProjectBasicInfo(oppty.Id);
        System.assertEquals(result.get('StatusCode'), 200);

        HttpResponse resp = (HttpResponse)result.get('HttpResponse');
        Map<String,Object> returnMap = (Map<String,Object>) JSON.deserializeUntyped(resp.getBody());

        System.assertEquals(String.valueOf(returnMap.get('EV_RTNST')), 'S');

        Test.stopTest();
    }

    @isTest
    static void testCallout400() {
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(400));
        Opportunity oppty = [Select Id From Opportunity where OpportunityCode__c = 'SDS-15016921' limit 1];
        Map<String, Object> result = IF_EccProjectBasicInfoController.getProjectBasicInfo(oppty.Id);
        System.assertEquals(result.get('StatusCode'), 400);

        Test.stopTest();
    }

    @isTest
    static void testCalloutError() {
        Test.startTest();

        Map<String, Object> result = IF_EccProjectBasicInfoController.getProjectBasicInfo('Error');

        Test.stopTest();
    }
}