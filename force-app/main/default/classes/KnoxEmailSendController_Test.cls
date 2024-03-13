/**
 * @description       : 
 * @author            : Junghwa.Kim@dkbmc.com
 * @group             : 
 * @last modified on  : 2021-03-30
 * @last modified by  : Junghwa.Kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                  Modification
 * 1.0   12-30-2020   Junghwa.Kim@dkbmc.com   Initial Version
**/
@isTest
public class KnoxEmailSendController_Test {
    
    static User adminUser;
    static Profile adminpf;
    static Account acc;
    static Opportunity opp;
    static EmailTemplate emailTemp;
    static Employee__c emp;
    
    static {
        adminpf =  [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = '시스템 관리자' limit 1];
        
        adminUser = new User(
            Alias = 'testUser'
            , Email = 'adminUser@test.com.test'
            , EmailEncodingKey = 'UTF-8'
            , LastName = 'Testing'
            , LanguageLocaleKey = 'en_US'
            , LocaleSidKey = 'en_US'
            , EmployeeNumber = 'AC100000'
            , TimeZoneSidKey = 'Asia/Seoul'
            , ProfileId = adminpf.Id
            , UserName = 'adminUser@test.com.test'
            , FederationIdentifier = 'epId1'
        );
        insert adminUser;

        emp = new Employee__c(
            Name = 'name',
            EvMailAddr__c = 'name@samsung.com',
            EvUniqID__c = 'epId1'            
        );
        insert emp;
            
        acc = new Account(
            Name = 'a_name'
        );
        insert acc;
        
        opp = new Opportunity(
            Name = 'a_name',
            AccountId = acc.Id,
            StageName = 'Z01',
            CloseDate = Utils.getCurDatetime().date().addDays(1)
        );
        
        insert opp;
        
        emailTemp = [SELECT Id ,Name ,Subject ,Body ,HtmlValue ,CreatedDate ,DeveloperName FROM EmailTemplate LIMIT 1];
    }

    @isTest
    public static void KnoxEmailSendControllerTest() {
        KnoxEmailSendController.getInstance();

        Map<String, Object> initMap = KnoxEmailSendController.doInit(opp.Id);
        List<String> eToList = new List<String>();
        List<String> eCcList = new List<String>();
        List<String> eBccList = new List<String>();
        
        eToList.add(String.valueOf(adminUser.Id));
        eCcList.add(String.valueOf(adminUser.Id));
        eBccList.add(String.valueOf(adminUser.Id));

        List<Map<String, Object>> efileList = new List<Map<String, Object>>();
        List<Map<String, String>> nfileList = new List<Map<String, String>>();

        Map<String, Object> efileMap = new Map<String, Object>();
        Map<String, String> nfileMap = new Map<String, String>();

        efileMap.put('name', 'ename');
        efileMap.put('fileContents', 'efileContents');
        nfileMap.put('name', 'nname');
        nfileMap.put('fileContents', 'nfileContents');

        efileList.add(efileMap);
        nfileList.add(nfileMap);

        List<String> epIdList = new List<String>();
        epIdList.add('epId1');

        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        List<String> fileIdList = new List<sTring>();
        for(ContentDocument d : documents){
            fileIdList.add(String.valueOf(d.Id));
        }

        System.runas(adminUser){
            KnoxEmailSendController.sendKnoxEmail(opp.Id, true, eToList, eCcList, eBccList, 'subject', 'description', efileList, nfileList, 'selEmailId');
            KnoxEmailSendController.convertHtmlFieldValue(opp.Id, emailTemp);
            knoxEmailSendController.isMobile(true);
            //knoxEmailSendController.getTeamMembers(opp.Id, epIdList);
            knoxEmailSendController.getDocFileList(fileIdList);
        }
    }
}