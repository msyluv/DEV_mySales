/**
* @description       : Test Class of IF_CelloOrganizationInfoController.(IF-186)
* @author            : vikrant.ks@samsung.com
* @group             : 
* @last modified on  : 2023-12-22
* @last modified by  : vikrant.ks@samsung.com 
* Modifications Log 
* Ver   Date          Author                   Modification
* 1.0   2023-08-16    vikrant.ks@samsung.com   Initial Version(MySales 279)
* 1.1   2023-12-22    vikrant.ks@samsung.com   Increased Code coverage
**/
@isTest
public class IF_CelloOrganizationInfoController_Test {
	
    final static String REQUEST_URL = '/services/apexrest/WebService/IF186';
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
        
        Company__c insertCompany1 = new Company__c (
            Name                = 'T100 - Name'
            , CompanyCode__c    = 'T302'
            , EPCompanyCode__c  = 'EP1'
            , CurrencyIsoCode   = 'KRW'
            , Country__c        = 'Korea, Republic of'
        );
        insert insertCompany1;
        
        Organization__c insertOrganization1 = new Organization__c(
            Name = 'Logical Organization'
            , Region__c = 'H'
            , Company__c = insertCompany.Id
            ,Code__c = 'test'
        );
        Insert insertOrganization1;

    }
    
    @isTest
    public static void TestMethod1(){
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;   
        request.httpMethod = 'POST';
		
        String reqeustBody ='{"wksIaOrgSndIFvo":[{"ORG_ID":"test","ORG_NM":"SAMSUNG SDS AMERICA, INC","CURR_CD":"USD","AREA_CCD":"A","PRNT_ORG_PATY_ID":"T302","DEL_YN":"N"},{"ORG_ID":"test1","ORG_NM":"SAMSUNG SDS AMERICA, INC","CURR_CD":"USD","AREA_CCD":"H","PRNT_ORG_PATY_ID":"T302","DEL_YN":"N"}]}';
		request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_CelloOrganizationInfoController.ReceiveDatafromCello();

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

            IF_CelloOrganizationInfoController.ReceiveDatafromCello();

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
		
        String reqeustBody ='{"wksIaOrgSndIFvo":[{"ORG_ID":"test","ORG_NM":"SAMSUNG SDS AMERICA, INC","CURR_CD":"USD","AREA_CCD":"A","PRNT_ORG_PATY_ID":"98765","DEL_YN":"N"}]}';
		request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;

        try {

            IF_CelloOrganizationInfoController.ReceiveDatafromCello();

        } catch (Exception e) {
            system.debug(e);
        }        
        Test.stopTest();
    }
}