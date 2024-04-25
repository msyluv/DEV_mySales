/**
* @description       : 
* @author            : vikrant.ks@samsung.com
* @group             : 
* @last modified on  : 2024-02-16
* @last modified by  : vikrant.ks@samsung.com 
* Modifications Log 
* Ver   Date          Author                   Modification
* 1.0   2024-02-16    vikrant.ks@samsung.com   Initial Version(MySales 447)
**/
@isTest
public class IF_DeliveryProbabilityController_Test {
    
    final static String REQUEST_URL = '/services/apexrest/WebService/deliveryprob';
    static User member1;
    static Opportunity opptyHQ;
    static Opportunity opptyHQ1;
    static RecordType RT_OPPTY_HQ = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'HQ' Limit 1];
    
    Static{
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = '시스템 관리자'];
        member1 = new User(Alias = 'member1', Email='member1@samsung.com',
                     EmailEncodingKey='UTF-8', LastName='member1', LanguageLocaleKey='en_US', 
                     LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Seoul', 
                     UserName='member1@samsung.com');
        insert member1;
        
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
            		, ZZCheck__c        = true
            		, Text2__c      = '클라우드서비스사업부'
                    , Company__c        = insertCompany.Id
                );
        insert insertCostCenter;     
        System.debug('CostCenter: '+insertCostCenter);
        
        opptyHQ = new Opportunity(
            Name = 'Test Opportunity',
            OpportunityCode__c = 'SDS-23205170',
            RecordTypeId = RT_OPPTY_HQ.Id,
            StageName = 'Z02',
            CloseDate = Date.today(),
            SalesDepartment__c= insertCostCenter.Id
        );
        insert opptyHQ;
        
        opptyHQ1 = new Opportunity(
            Name = 'Test Opportunity1',
            OpportunityCode__c = 'SDS-23205180',
            RecordTypeId = RT_OPPTY_HQ.Id,
            StageName = 'Z02',
            CloseDate = Date.today(),
            SalesDepartment__c= insertCostCenter.Id
        );
        insert opptyHQ1;
        
        Delivery_Probabiliy__c DeliveryProbabiliy = new Delivery_Probabiliy__c();
        DeliveryProbabiliy.Opportunity__c = opptyHQ1.Id;
        
        insert DeliveryProbabiliy;
    }
    
    @isTest
    public static void TestMethod1(){
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;   
        request.httpMethod = 'POST';
		
        String reqeustBody ='{"BOCode":"SDS-23205170","BOName":"Test Opportunity","Companycode":"T100","Probability":"100","Activity":"Test IF-187","opportunity_id":"'+opptyHQ.Id+'"}';
		request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_DeliveryProbabilityController.ReceiveDatafromDashboard();

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
		
        String reqeustBody ='{"BOCode":"SDS-23205170","BOName":"Test Opportunity","Probability":"100","Activity":"Test IF-187","Modifiedby":"양채호 test"}';
		request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_DeliveryProbabilityController.ReceiveDatafromDashboard();

        } catch (Exception e) {
            system.debug(e);
        }        
        Test.stopTest();
    }
    @isTest
    public static void TestMethod3(){
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;   
        request.httpMethod = 'POST';
		
        String reqeustBody ='{}';
		request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_DeliveryProbabilityController.ReceiveDatafromDashboard();

        } catch (Exception e) {
            system.debug(e);
        }        
        Test.stopTest();
    }
    @isTest
    public static void TestMethod4(){
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;   
        request.httpMethod = 'POST';
		
        String reqeustBody ='{"BOCode":"SDS-23205320","BOName":"Test Opportunity","Companycode":"T100","Probability":"100","Activity":"Test IF-187","Modifiedby":"양채호 test"}';
		request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_DeliveryProbabilityController.ReceiveDatafromDashboard();

        } catch (Exception e) {
            system.debug(e);
        }        
        Test.stopTest();
    }
    @isTest
    public static void TestMethod5(){
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;   
        request.httpMethod = 'POST';
		
        String reqeustBody ='{"BOCode":"SDS-23205170",BOName":"Test Opportunity","Companycode":"T100","Probability":"100","Activity":"Test IF-187","Modifiedby":"양채호 test"}';
		request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_DeliveryProbabilityController.ReceiveDatafromDashboard();

        } catch (Exception e) {
            system.debug(e);
        }        
        Test.stopTest();
    }
    @isTest
    public static void TestMethod6(){
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;   
        request.httpMethod = 'POST';
		
        String reqeustBody ='{"BOCode":"SDS-23205180","BOName":"Test Opportunity1","Companycode":"T100","Probability":"","Activity":"","Modifiedby":""}';
		request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_DeliveryProbabilityController.ReceiveDatafromDashboard();

        } catch (Exception e) {
            system.debug(e);
        }        
        Test.stopTest();
    }
}