/**
* @description       : 
* @author            : seonju.jin@dkbmc.com
* @group             : 
* @last modified on  : 06-30-2021
* @last modified by  : yeongju.baek@dkbmc.com
* Modifications Log 
* Ver   Date         Author                 Modification
* 1.0   2020-11-09   seonju.jin@dkbmc.com   Initial Version
**/
@isTest
public class SearchRoadAddressControllerTest {
    static String addrJsonStr;
    static User admin;
    static Account acc;
    static String recordId;
    
    static{
        addrJsonStr = '{\"siNm\":\"서울특별시\",'
            + '\"sggNm\":\"강남구\",'
            + '\"emdNm\":\"삼성동\",'
            + '\"roadFullAddr\":\"서울특별시 강남구 봉은사로112길 6,'
            + '1212 (삼성동)\",'
            + '\"roadAddr\":\"봉은사로112길 6\",'
            + '\"addrDetail\":\"1212\",'
            + '\"roadAddrPart2\":\"(삼성동)\",'
            + '\"admCd\":\"1168010500\",'
            + '\"zipNo\":\"06170\"}';
        
        Profile p = [SELECT id FROM Profile WHERE name = 'System Administrator' OR name = '시스템 관리자'];
        
        admin = new User(Alias = 'standt1', Email='user0001@ss-sds.com', 
                         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                         LocaleSidKey='ko_KR', ProfileId = p.Id, TimeZoneSidKey='Asia/Seoul', 
                         UserName='user0001@ss-sds.com', Division = 'TW');
        insert admin;
        
        System.runAs(admin){
            acc = new Account(Name = 'Test1');
            insert acc;
            
            recordId = acc.Id;
        }
    }
    
    @isTest static void test_method_1(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        SearchRoadAddressController.saveAddress(recordId, addrJsonStr);
        SearchRoadAddressController.getUserLocale();
        SearchRoadAddressController.getUserProfile();
        SearchRoadAddressController.getRecordNo(recordId);
        Test.stopTest();
    }

    public class MockHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            String body = '';
            body += '"results":{"common":{"countPerPage":"1","currentPage":"1","errorCode":"0","errorMessage":"정상","totalCount":"1"}';
            body += ', "juso":[{"admCd":"1168010500","bdKdcd":"0","buldMnnm":"6","buldSlno":"0","emdNm":"Samseong-dong","jibunAddr":"162-15, Samseong-don"';
            body += ',"korAddr":"서울특별시 강남구 봉은사로112길 6","liNm":"","lnbrMnnm":"162","lnbrSlno":"15","mtYn":"0","rnMgtSn":"116804166331","siNm":Seoul"}]}';
            
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }
    }
}