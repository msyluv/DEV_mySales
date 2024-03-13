/**
 * @description       : 
 * @author            : hj.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 2022-05-18
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author             Modification
 * 1.0   2020-11-18   hj.lee@dkbmc.com   Initial Version
**/
@isTest
public class KnoxApprovalNewController_Test {

    static Account acc;
	static Opportunity opp;
    static Employee__c emp1;
    static Employee__c emp2;
    static Employee__c emp3;
    static Employee__c emp4;
    static Employee__c emp5;
    static Profile pf = [select Id from Profile where Name = 'System Administrator' limit 1];
    static TempKnoxApproval__c app;
    static TempKnoxApprover__c apper1;
    static TempKnoxApprover__c apper2;
    static TempKnoxApprover__c apper3;
    static Biz_Review__c biz;
    
    static Lead le = new Lead();
    
    static User user1;
    static User user2;
    static User user3;
    
    static Map<String, Object> ApprovalData;
    static List<Map<String, Object>> fileList;
    

    static{
        le.LastName = 'leadtest';
        le.Company = 'lastCom';
        insert le;

        RecordType acc_RcdType_MDG = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'MDG'];
        acc = new Account(
            Name = 'TestAccount',
            RecordTypeId = acc_RcdType_MDG.Id,
            MDGCheck__c = true
        );        
        insert acc;
		opp = Utils_TestDataFactory.createOpportunity('TestOpportunity', acc.Id);

        user3 = new User(
            Alias = 'testUser',
            Email='SysAdminTestuser@dkbmc.com',
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            EmployeeNumber='AC100000',
            TimeZoneSidKey='Asia/Seoul',
            UserName='SysAdminTestuser@samsung.com',
            ProfileId = pf.Id,
            FederationIdentifier = 'k123456789'
        );
        insert user3;

        emp1 = Utils_TestDataFactory.createEmployee('TestEmp1', 'EPID1');
        emp2 = Utils_TestDataFactory.createEmployee('TestEmp2', 'EPID2');
        emp3 = Utils_TestDataFactory.createEmployee('TestEmp3', 'EPID3');
        emp4 = Utils_TestDataFactory.createEmployee('TestEmp4', 'EPID4');
        emp5 = new Employee__c(
            Name = 'testUser',
            EvMailAddr__c = user3.Email,
            EvUniqID__c = 'k123456789',
            Knox_Id__c = 'knoxId5'  
        );
        insert emp5;
        biz = new Biz_Review__c(
            Opportunity__c = opp.id
        );

        user1 = Utils_TestDataFactory.createUserFull(Utils_TestDataFactory.getProfile('System Administrator'), emp4.EvMailAddr__c, emp4.EvUniqID__c);
        user2 = Utils_TestDataFactory.createUserFull(Utils_TestDataFactory.getProfile('System Administrator'), emp3.EvMailAddr__c, emp3.EvUniqID__c);
        
        ApprovalData = new Map<String,Object>();

        Map<String,Object> appData = new Map<String,Object>();
        Map<String,Object> recordInfo = new Map<String,Object>();

        appData.put('ApprovedId__c', opp.Id);
        appData.put('Opportunity__c', opp.Id);
       // appData.put('Description__c', 'Test Description');
        appData.put('TemplateName__c', '-');
        recordInfo.put('recordId',opp.Id);
        ApprovalData.put('RecordInfo', recordInfo);
        ApprovalData.put('KnoxApproval', appData);

        List<Map<String,Object>> apperList = new List<Map<String,Object>>();
        Map<String,Object> apperData = new Map<String,Object>();
       // apperData.put('TempKnoxApproval__c', app.Id);
        apperData.put('Index__c', 0);
        apperData.put('Name', 'test1');
        apperData.put('ApproverType__c', '7');
        apperData.put('EvSdeptNM__c', '개발');
        apperData.put('EvMailAddr__c', 'test1@samsung.com');
        apperData.put('Email__c', emp1.EvMailAddr__c);
        apperData.put('Employee__c', emp1.Id);
        apperData.put('EvUniqID__c', emp1.EvUniqID__c);
        apperData.put('IsChangeLine__c', true);
        apperData.put('IsEditText__c', true);
        apperData.put('IsArbitraryDecision__c', true);
        apperList.add(apperData);

        apperData = new Map<String,Object>();
       // apperData.put('TempKnoxApproval__c', app.Id);
        apperData.put('Index__c', 0);
        apperData.put('Name', 'test2');
        apperData.put('ApproverType__c', '7');
        apperData.put('EvSdeptNM__c', '개발');
        apperData.put('EvMailAddr__c', 'test2@samsung.com');
        apperData.put('Email__c', emp2.EvMailAddr__c);
        apperData.put('Employee__c', emp2.Id);
        apperData.put('EvUniqID__c', emp2.EvUniqID__c);
        apperData.put('IsChangeLine__c', true);
        apperData.put('IsEditText__c', true);
        apperData.put('IsArbitraryDecision__c', false);
        apperList.add(apperData);

        apperData = new Map<String,Object>();
       // apperData.put('TempKnoxApproval__c', app.Id);
        apperData.put('Index__c', 1);
        apperData.put('Name', 'test3');
        apperData.put('ApproverType__c', '1');
        apperData.put('EvSdeptNM__c', '개발');
        apperData.put('EvMailAddr__c', 'test3@samsung.com');
        apperData.put('Email__c', emp3.EvMailAddr__c);
        apperData.put('Employee__c', emp3.Id);
        apperData.put('EvUniqID__c', emp3.EvUniqID__c);
        apperData.put('IsChangeLine__c', true);
        apperData.put('IsEditText__c', true);
        apperData.put('IsArbitraryDecision__c', false);
        apperList.add(apperData);

        ApprovalData.put('ApproverList', apperList);
        fileList = new List<Map<String, Object>>();
        Map<String,Object> fileData = new Map<String,Object>();
        fileData.put('name', 'testFile');
        fileData.put('fileContents', '123rgvfb34/t');
        fileData.put('iconName', 'image/jpg');
        fileData.put('fileSize', 555);
        fileList.add(fileData);
    }

    @isTest
    static void testApprovalTempData() {
        KnoxApprovalNewController.tempSaveApproval(opp.Id , (String)JSON.serialize(ApprovalData), fileList);

        List<TempKnoxApproval__c> temp = [select id from TempKnoxApproval__c where RecordId__c = :opp.Id and OwnerId = :UserInfo.getUserId()];
        List<TempKnoxApprover__c> tempapper = [SELECT Index__c, Name, ApproverType__c, EvSdeptNM__c, EvMailAddr__c, Employee__c, EvUniqID__c, IsChangeLine__c, IsEditText__c, IsArbitraryDecision__c, Email__c 
             FROM TempKnoxApprover__c WHERE TempKnoxApproval__c = :temp[0].id 
                                                    ORDER BY Index__c ASC, Name];

        List<Attachment> attList = [select id from Attachment where ParentId = :temp[0].Id];
        System.assertEquals(1, temp.size());
        System.assertEquals(3, tempapper.size());
        System.assertEquals(1, attList.size());

        Map<String,Object> tempApp = KnoxApprovalNewController.initComponent(opp.Id, '-',true);
        KnoxApproval__c appmap = (KnoxApproval__c)tempApp.get('knoxApproval');
        List<KnoxApprover__c> aplist = (List<KnoxApprover__c>)tempApp.get('knoxApprover');        
        System.debug('approver : ' +aplist );
        KnoxApprover__c aper = (KnoxApprover__c) aplist[0];       
                
       // System.assertEquals('Test Description', appmap.Description__c);

        System.assertEquals(3, aplist.size());
        System.assertEquals('test1', aper.Name);
        System.assertEquals('EPID1', aper.EvUniqID__c);
        System.assertEquals('7', aper.ApproverType__c);
    }

    @isTest
    static void testApprovalSubmit() {    
        Test.startTest();
       // System.assertEquals(false, System.Approval.isLocked(opp.id));
        KnoxApprovalNewController.initComponent(opp.Id, '-',true);

        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock());
        Map<String,Object> result = KnoxApprovalNewController.requestApproval((String)JSON.serialize(ApprovalData), fileList, '-');

        KnoxApproval__c approval = (KnoxApproval__c) result.get('knoxApproval');
        List<KnoxApprover__c> approverList = (List<KnoxApprover__c>) result.get('knoxApprover');

        //System.assertEquals('Test Description', approval.Description__c);
        //System.assertEquals('Opportunity', approval.objAPIName__c);        
        //System.assertEquals(3, approverList.size());

        //for(Integer i=0; i<approverList.size(); i++ ){
        //    KnoxApprover__c approver = approverList[i];
        //    System.assertEquals('test'+(i+1), approver.Name);
		//
        //}
        //List<OpportunityTeamMember> otmList = new List<OpportunityTeamMember>();
        //OpportunityTeamMember otm = new OpportunityTeamMember(OpportunityId=opp.Id
        //                                                          , UserId= user2.Id
        //                                                          , TeamMemberRole='Account Sales'
        //                                                          , OpportunityAccessLevel='Edit');
        //                                                          
        //otmList.add(otm);
        //INSERT otmList;
        List<String> empList = new List<String>();
        
        

        System.runAs(user3){                        
            //System.assertEquals(true, System.Approval.isLocked(opp.id));
            KnoxApprovalNewController.requestApproval((String)JSON.serialize(ApprovalData), fileList, '-');
            //KnoxApprovalNewController.saveApproval(opp.Id, approval, approverList);
            KnoxApprovalNewController.insertApproval(result);
            
        }

        Test.stopTest();

    }
    @isTest
    static void getStrategyInfo(){
        Test.startTest();
        System.runAs(user1){
            KnoxApprovalNewController.getStrategyInfo(biz.id);
        }
        Test.stopTest();
    }

}