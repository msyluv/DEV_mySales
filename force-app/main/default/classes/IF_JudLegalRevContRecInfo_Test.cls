/**
 * @description       : 
 * @author            : raeganja@partner.samsung.com
 * @group             : 
 * @last modified on  : 01-14-2021
 * @last modified by  : soohong0.kim@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   2021-01-04   raeganja@partner.samsung.com   Initial Version
**/
@isTest
public class IF_JudLegalRevContRecInfo_Test {
    final static String REQUEST_URL = '/services/apexrest/WebService/IF128';
    static Account acc = Utils_TestDataFactory.createAccount('TestAcc');

    public IF_JudLegalRevContRecInfo_Test() {

    }

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
        );
        Insert hqOppty;

        
    }

    private static void runTest(String status){
        try {
             IF_JudLegalRevContRecInfoController.InputHeader header = new IF_JudLegalRevContRecInfoController.InputHeader();
            IF_JudLegalRevContRecInfoController.InputClass input = new IF_JudLegalRevContRecInfoController.InputClass();
            List<IF_JudLegalRevContRecInfoController.InputClass> inputList = new List<IF_JudLegalRevContRecInfoController.InputClass>();

            input.COMPANY = 'EP1';
            input.CONTRACT_TYPE = 'SI';
            input.ORDER_ID = 'SDS-15016921';
            input.CONTRACT_NO = 'CT2020022901';
            input.CONTRACT_STATUS = status;
            input.CONFIRM_DATE = '';
            inputList.add(input);
            header.DATA = inputList;

            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();
            request.requestURI = REQUEST_URL;        
            request.httpMethod = 'POST';

            request.requestBody = Blob.valueOf(JSON.serialize(header));
            RestContext.request  = request;
            RestContext.response = response;

            IF_JudLegalRevContRecInfoController.saveData();

        } catch (Exception e) {
            system.debug(e);
        }        
    }
    //Activity가 없을때
    @isTest 
    static void restServiceTest01() {
        Test.startTest();
        runTest('00401');
        Test.stopTest();

    }
    @isTest 
    static void restServiceTest02() {
        Test.startTest();
        runTest('00404');
        Test.stopTest();
    }
    @isTest 
    static void restServiceTest03() {
        Test.startTest();
        runTest('00405');
        Test.stopTest();

    }
    @isTest 
    static void restServiceTest04() {
        Test.startTest();
        runTest('00420');
        Test.stopTest();
    }

    //Activity가 있을때
    @isTest 
    static void restServiceTest05() {
        Test.startTest();
        Opportunity oppty = [Select Id From Opportunity where OpportunityCode__c = 'SDS-15016921' limit 1];

        Utils_TestDataFactory.createOpportunityActivity(oppty.id, 'XP52');
        Utils_TestDataFactory.createOpportunityActivity(oppty.id, 'XP57');
        runTest('00401');
        Test.stopTest();
    }
    @isTest 
    static void restServiceTest06() {
        Test.startTest();
        Opportunity oppty = [Select Id From Opportunity where OpportunityCode__c = 'SDS-15016921' limit 1];

        Utils_TestDataFactory.createOpportunityActivity(oppty.id, 'XP52');
        Utils_TestDataFactory.createOpportunityActivity(oppty.id, 'XP57');
        runTest('00404');
        Test.stopTest();
    }

    @isTest 
    static void restServiceTest07() {
        Test.startTest();
        Opportunity oppty = [Select Id From Opportunity where OpportunityCode__c = 'SDS-15016921' limit 1];

        Utils_TestDataFactory.createOpportunityActivity(oppty.id, 'XP52');
        Utils_TestDataFactory.createOpportunityActivity(oppty.id, 'XP57');
        runTest('00405');
        Test.stopTest();
    }
    
    @isTest 
    static void restServiceTest08() {
        Test.startTest();
        Opportunity oppty = [Select Id From Opportunity where OpportunityCode__c = 'SDS-15016921' limit 1];

        Utils_TestDataFactory.createOpportunityActivity(oppty.id, 'XP52');
        Utils_TestDataFactory.createOpportunityActivity(oppty.id, 'XP57');
        runTest('00420');
        Test.stopTest();
    }


    @isTest 
    static void restServiceTest_DATA_NULL() {
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;        
        request.httpMethod = 'POST';
        IF_JudLegalRevContRecInfoController.InputClass input = new IF_JudLegalRevContRecInfoController.InputClass();
        List<IF_JudLegalRevContRecInfoController.InputClass> inputList = new List<IF_JudLegalRevContRecInfoController.InputClass>();
        IF_JudLegalRevContRecInfoController.InputHeader header = new IF_JudLegalRevContRecInfoController.InputHeader();

        input.COMPANY = 'null';
        input.ORDER_ID = 'null';
        inputList.add(input);
        header.DATA = inputList;
        request.requestBody = Blob.valueOf(JSON.serialize(header));
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_JudLegalRevContRecInfoController.saveData();

        } catch (Exception e) {
            system.debug(e);
        }        

        Test.stopTest();
    }

    @isTest 
    static void restServiceTest_Exception() {
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;        
        request.httpMethod = 'POST';

        String reqeustBody =
        '{ ' +
        '    "DATA_Exception": [ ' +
        '      { ' +
        '       "COMPANY" : "C60", ' +
        '       "CONTRACT_TYPE" : "SI", ' +
        '       "ORDER_ID" : "SDS-15016921", ' +
        '       "CONTRACT_NO" : "CT2020022901", ' +
        '       "CONTRACT_STATUS" : "00404", ' +
        '       "CONFIRM_DATE" : "" ' +
        '      } ' +
        '    ] ' +
        '}';


        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_JudLegalRevContRecInfoController.saveData();

        } catch (Exception e) {
            system.debug(e);
        }        

        Test.stopTest();
    }
}