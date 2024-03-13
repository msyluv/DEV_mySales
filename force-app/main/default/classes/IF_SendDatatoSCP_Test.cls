/**
* @description       : Send BO information for request of SCP/Legal system (IF-182)
* @author            : vikrant.ks@samsung.com
* @group             : 
* @last modified on  : 2023-06-12 
* @last modified by  : vikrant.ks@samsung.com 
* Modifications Log 
* Ver   Date         Author                   Modification
* 1.0   2023-06-12   vikrant.ks@samsung.com   Initial Version(MySales 230)
**/

@isTest
public class IF_SendDatatoSCP_Test{
    
    final static String REQUEST_URL = '/services/apexrest/WebService/IF182';
    static Opportunity oppty;
    public static Opportunity Opportunity1;
    public static Opportunity Opportunity2;
    @TestSetup
    static void setData(){
        Id rdType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('MDG').getRecordTypeId();
        Account acc = new Account (
        Name = 'Test1234',AccountNumber='A2999999',RecordTypeId = rdType, MDGCheck__c = true, mLoevm__c = false);
        insert acc;
        Organization__c org = new Organization__c();
        insert org;
        RecordType RT_OPPTY_HQ   = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'HQ' Limit 1];
        Opportunity1 = new Opportunity(
            Name = 'MySales',
            CurrencyIsoCode='EUR',
            OpportunityCode__c='SDS-22131801',
            StageName= 'Qualified',
            CspMspType__c = 'CSP',
            Amount = 78,
            AccountId = acc.id,
            SalesOrganization__c = org.id,
            DeliveryOrganization__c = org.id,
            CloseDate = System.today(),
            OpportunityStatus__c='E0003',
            CMBizType__c='CSP_SCP',
            RecordTypeId = RT_OPPTY_HQ.Id
            );
        
        	insert Opportunity1;
         
    }
        
    @isTest
    public static void TestMethod1(){
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;   
        request.httpMethod = 'POST';

        String reqeustBody ='{"SYSTEM_ID":"1","ACCOUNT_ID":"A2999999","TYPE":"SCP","BO_CODE":"SDS-22131801","BO_NAME":"Kang Ji","BO_OWNER_EMAIL":"kang.jh@samsung.com"}';
		request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_SendDatatoSCP.SendDatatoSCP();

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

        String reqeustBody ='{}';

        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_SendDatatoSCP.SendDatatoSCP();

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

        String reqeustBody ='{"SYSTEM_ID":"","ACCOUNT_ID":"","TYPE":"SCP","BO_CODE":"SDS-23001000","BO_NAME":"[CSP][Single]Test3 (SDSLA)","BO_OWNER_EMAIL":"kang.jh@samsung.com"}';

        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_SendDatatoSCP.SendDatatoSCP();

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

        String reqeustBody ='{"SYSTEM_ID":"1","ACCOUNT_ID":"A2999999"}';
		request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_SendDatatoSCP.SendDatatoSCP();

        } catch (Exception e) {
            system.debug(e);
        }        
        Test.stopTest();
        List<Opportunity> oppList1 = [Select Id,RecordType.Name,Account.AccountNumber from Opportunity];
        System.debug('Opp1: '+oppList1);
        List<Opportunity> oppList2 = [Select Id,RecordType.Name,Account.AccountNumber from Opportunity where RecordType.Name = 'HQ'and Account.AccountNumber = 'A2999999'];
        System.debug('Opp2: '+oppList2);
    }
}