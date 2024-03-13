/**
 * @description       : 
 * @author            : soohong0.kim@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-07-19
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   04-27-2021   soohong0.kim@partner.samsung.com   Initial Version
**/
@isTest
public class IF_EloquaLeaderInfoController_Test {
    // INTERFACE_ID = 'IF-141';
    // APEX_CLASS   = 'IF_EloquaLeaderInfoController';
    // METHOD_NAME  = 'doPost';    

    final static String REQUEST_URL = '/services/apexrest/WebService/IF141';

    @TestSetup
    static void setData(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' or Name = '시스템 관리자' limit 1];
        User u = Utils_TestDataFactory.createUser(p);
        u.Email = 'mysales@samsung.com';
        update u;
    }

    @isTest
    static void restServiceTest() {
        Test.startTest();
        
        Test.setMock( HttpCalloutMock.class, new IF_Callout_TestMock());
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';
        
        IF_EloquaLeaderInfoController.InputHeader input = new IF_EloquaLeaderInfoController.InputHeader();
        input.IV_COUNT = '4';
        
        Campaign camObj = new Campaign();
        camObj.Name = 'Test';
        insert camObj;

        Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;

        List<IF_EloquaLeaderInfoController.IT_DATA> itDataList = new List<IF_EloquaLeaderInfoController.IT_DATA>();
        IF_EloquaLeaderInfoController.IT_DATA itData = new IF_EloquaLeaderInfoController.IT_DATA();
        itData.FirstName = 'test';
        itData.LastName = 'test';
        itData.Title = 'test';
        itData.Company = 'test';
        itData.Country = 'KR';
        itData.BusinessPhone = 'test';
        itData.MobilePhone = 'test';
        itData.Emailaddress = 'test@test.com';
        itData.Comment = 'test';
        itData.SFDCIndustry = 'test';
        itData.SolutionOfInterest = 'test';
        itData.SFDCLeadowner = 'test';
        itData.SFDCSalesLeadowner = 'test';
        itData.LeadCreatedDate = '20200101010101';
        itData.HQEmailOptInDate = '20200101010101';
        itData.HQEmailOptExpiredDate = '20200101010101';
        itData.ELOQUA_ID = 'test';
        if(isSandbox) itData.CampaignId = ( camObj.Id + '').left( 17) + 'B';
        else itData.CampaignId = camObj.Id;
        itDataList.add(itData);

        input.IT_DATA = itDataList;
        request.requestBody = Blob.valueOf(JSON.serialize(input));
        RestContext.request  = request;
        RestContext.response = response;

        try {
            IF_EloquaLeaderInfoController.doPost();
            
            DateTime fromDate = DateTime.now().addDays(-1).addHours(-13);
        	DateTime toDate = DateTime.now().addHours(-13);
            IF_EloquaLeaderInfoController.callInfo(String.valueOf(fromDate), String.valueOf(toDate));
        } catch (Exception e) {
            system.debug(e);
        }        

        Test.stopTest();
    }    
}