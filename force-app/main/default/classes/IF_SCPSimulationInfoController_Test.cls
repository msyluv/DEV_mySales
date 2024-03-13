/**
* @description       : Test Class of IF_SCPSimulationInfoController(IF-183)
* @author            : vikrant.ks@samsung.com
* @group             : 
* @last modified on  : 2023-07-25 
* @last modified by  : vikrant.ks@samsung.com 
* Modifications Log 
* Ver   Date         Author                   Modification
* 1.0   2023-07-25    vikrant.ks@samsung.com   Initial Version(MySales 265)
**/
@isTest
public class IF_SCPSimulationInfoController_Test {
    
    final static String REQUEST_URL = '/services/apexrest/WebService/IF183';
    
    @TestSetup
    static void setData(){
        Company__c insertCompany = new Company__c (
            Name                = 'T100 - Name'
            , CompanyCode__c    = 'T100'
            , EPCompanyCode__c  = 'EP1'
            , CurrencyIsoCode   = 'KRW'
            , Country__c        = 'Korea, Republic of'
        );
        insert insertCompany;
		System.debug('Company: '+insertCompany);
        
        CostCenter__c insertCostCenter = new CostCenter__c(
                    Name                = '기술전략팀(T100-11331)'
                    , CurrencyIsoCode   = 'KRW'
                    , CompanyCode__c    = 'T100'
                    , CostCenterName__c = '기술전략팀'
                    , CostCenter__c     = 'T100-11331'
                    , Node1__c          = 'T100'
                    , Node2__c          = 'T100SB'
                    , Node3__c          = 'T100SB1'
                    , Node4__c          = 'T100SB13'
                    , Node5__c          = 'T100SB131'
                    , Company__c        = insertCompany.Id
                );
        insert insertCostCenter;     
        System.debug('CostCenter: '+insertCostCenter);
        Opportunity hqOppty = new Opportunity(
            Name                    = 'testOpp1'
            , CloseDate             = System.today().addDays(5)
            , StageName             = 'Z03'
            , SalesDepartment__c    = insertCostCenter.Id
            , Amount                = 1000000
            , CurrencyIsoCode       = 'KRW'
            , OpportunityCode__c    = 'SDS-20000200'
            , cRevenueStartDate__c  = System.today()
            , cRevenueEndDate__c    = System.today().addDays(90)
        );
        
        insert hqOppty;
        
        
        SCPSimulation__c temp = new SCPSimulation__c();
        temp.BOCode__c = 'SDS-20000200';
        temp.companyCode__c = 'T100';
        temp.quotNm__c = 'Test';
        temp.quotId__c = '1';
        temp.orderRate__c = Decimal.valueOf('1234');
        temp.az__c = '';
        temp.totAmt__c = Decimal.valueOf('43');
        temp.crncyCd__c = '12';
        temp.serviceDt__c = '';
        temp.quotStat__c = '';
        temp.regDate__c = Date.valueOf('2023-07-25');
        temp.chgDate__c = Date.valueOf('2023-07-25');
        temp.Opportunity__c = hqOppty.Id;
        upsert temp;

    }
    
    @isTest
    public static void TestMethod1(){
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;   
        request.httpMethod = 'POST';
		
        String reqeustBody ='{"boCode":"SDS-20000200","companyCode":"T100","quotNm":"Testing","quotId":"1","orderRate":"123","aZ":"","totAmt":"4321","crncyCd":"12","serviceDt":"","quotStat":"","regDate":"2023-07-25","chgDate":"2023-07-25"}';
		request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_SCPSimulationInfoController.ReceiveDatafromSCP();

        } catch (Exception e) {
            system.debug(e);
        }        
        Test.stopTest();
    }
    @isTest
    public static void TestMethod2(){
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;   
        request.httpMethod = 'POST';
		
        String reqeustBody ='{"boCode":"SDS-987645","companyCode":"T111","quotNm":"Test","quotId":"1","orderRate":"123487.235","aZ":"","totAmt":"4321","crncyCd":"12","serviceDt":"","quotStat":"","regDate":"2023-07-25","chgDate":"2023-07-25"}';
		request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_SCPSimulationInfoController.ReceiveDatafromSCP();

        } catch (Exception e) {
            system.debug(e);
        }        
        Test.stopTest();
    }
}