/**
 * @description       : 
 * @author            : hj.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 2023-08-24
 * @last modified by  : anish.jain@partner.salesforce.com
 * Modifications Log 
 * Ver   Date         Author             Modification	
 * 1.0   2020-11-18   hj.lee@dkbmc.com   Initial Version
 * 1.1   2023-05-20   anish.jain@partner.salesforce.com   Coverage for MS-198
 * 1.2   2023-08-24   anish.jain@partner.salesforce.com   Coverage for MS-283
**/
@isTest
public class KnoxApprovalSubmitController_Test {

    static Account acc;
	static Opportunity opp,opp_collabo;
    static Employee__c emp1;
    static Employee__c emp2;
    static Employee__c emp3;
    static Employee__c emp4;
    static Employee__c emp5;
    static Profile pf = [SELECT Id FROM Profile WHERE Name Like '%System Admin%' or Name Like '시스템 관리자' limit 1];

    static TempKnoxApproval__c app;

    static TempKnoxApprover__c tempApprover1;
    static TempKnoxApprover__c tempApprover2;
    static TempKnoxApprover__c tempApprover3;

    static KnoxApprover__c approver1;
    static KnoxApprover__c approver2;
    static KnoxApprover__c approver3;
    
    static User user1;
    static User user2;
    static User user3;

    static Map<String, Object> ApprovalData;
    static List<Map<String, Object>> fileList;
    static String opptyActId;
    
    static{
        // [User]
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

        user1 = Utils_TestDataFactory.createUserFull(Utils_TestDataFactory.getProfile('System Administrator'), emp1.EvMailAddr__c, emp1.EvUniqID__c);
        user2 = Utils_TestDataFactory.createUserFull(Utils_TestDataFactory.getProfile('System Administrator'), emp3.EvMailAddr__c, emp3.EvUniqID__c);

        // [Account]
        acc = Utils_TestDataFactory.createAccount('TestAccount');
        acc.MDGCheck__c = true;
        update acc;

        // [Opportunity]
		opp = Utils_TestDataFactory.createOpportunity('TestOpportunity', acc.Id);
        opp.ownerId = user1.id;

        opp_collabo = Utils_TestDataFactory.createOpportunity('TestOpportunity Collabo', acc.Id);
        opp.CollaborationBOId__c = opp_collabo.Id;
        opp.CollaborationInOut__c = 'Out';
        update opp;

        Opportunity_Activity__c opptyAct = new Opportunity_Activity__c( 
            Status__c            = OpportunityActivityNewController.OPPTYACT_STATUS_COMPLETED
            , DueDate__c         = System.today()
            , TransactionName__c = OpportunityActivityHelper.ACT_CODE_CONTRACT_APPROVAL
            , WhatId__c          = opp.Id 
        );
        opptyAct.ExtId__c = OpportunityActivityHelper.generateOpportunityActivityExtKey(opptyAct);
        insert  opptyAct;

        opptyActId = opptyAct.Id;

        // [Approval Data]
        ApprovalData = new Map<String,Object>();

        Map<String,Object> appData = new Map<String,Object>();
        Map<String,Object> recordInfo = new Map<String,Object>();

        appData.put('ApprovedId__c', opp.Id);
        appData.put('Opportunity__c', opp.Id);
        appData.put('Opinion__c', '1');
       // appData.put('Description__c', 'Test Description');
        appData.put('TemplateName__c', '-');
        recordInfo.put('recordId',opp.Id);
        ApprovalData.put('RecordInfo', recordInfo);
        ApprovalData.put('KnoxApproval', appData);
            
        List<Map<String,Object>> tempApproverList = new List<Map<String,Object>>();
        TempKnoxApprover__c tempKnoxApprover = new TempKnoxApprover__c();
        Map<String, Object> tempKnoxApproverMap = new Map<String, Object>();

        tempKnoxApprover = new TempKnoxApprover__c(
            Index__c = 1,
            Name = 'test2',
            ApproverType__c = '7',
            EvSdeptNM__c = '개발',
            EvMailAddr__c = emp2.EvMailAddr__c,
            Employee__c = emp2.Id,
            EvUniqID__c = emp2.EvUniqID__c,
            IsChangeLine__c = true,
            IsEditText__c = true,
            IsArbitraryDecision__c = true
        );
        tempKnoxApproverMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(tempKnoxApprover));
        tempApproverList.add(tempKnoxApproverMap);

        tempKnoxApprover = new TempKnoxApprover__c(
            Index__c = 2,
            Name = 'test3',
            ApproverType__c = '7',
            EvSdeptNM__c = '개발',
            EvMailAddr__c = emp3.EvMailAddr__c,
            Employee__c = emp3.Id,
            EvUniqID__c = emp3.EvUniqID__c,
            IsChangeLine__c = true,
            IsEditText__c = true,
            IsArbitraryDecision__c = true
        );
        tempKnoxApproverMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(tempKnoxApprover));
        tempApproverList.add(tempKnoxApproverMap);

        tempKnoxApprover = new TempKnoxApprover__c(
            Index__c = 3,
            Name = 'test4',
            ApproverType__c = '7',
            EvSdeptNM__c = '개발',
            EvMailAddr__c = emp4.EvMailAddr__c,
            Employee__c = emp4.Id,
            EvUniqID__c = emp4.EvUniqID__c,
            IsChangeLine__c = true,
            IsEditText__c = true,
            IsArbitraryDecision__c = true
        );
        tempKnoxApproverMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(tempKnoxApprover));
        tempApproverList.add(tempKnoxApproverMap);

        tempKnoxApprover = new TempKnoxApprover__c(
            Index__c = 4,
            Name = 'test5',
            ApproverType__c = '7',
            EvSdeptNM__c = '개발',
            EvMailAddr__c = emp5.EvMailAddr__c,
            Employee__c = emp5.Id,
            EvUniqID__c = emp5.EvUniqID__c,
            IsChangeLine__c = true,
            IsEditText__c = true,
            IsArbitraryDecision__c = true
        );
        tempKnoxApproverMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(tempKnoxApprover));
        tempApproverList.add(tempKnoxApproverMap);

        ApprovalData.put('ApproverList', tempApproverList);

        fileList = new List<Map<String, Object>>();
        Map<String,Object> fileData = new Map<String,Object>();
        fileData.put('name', 'testFile');
        fileData.put('fileContents', '123rgvfb34/t');
        fileData.put('iconName', 'image/jpg');
        fileData.put('fileSize', 555);
        fileList.add(fileData);

        KnoxApproval__c knoxApprovalObj = new KnoxApproval__c();
        knoxApprovalObj.Name = 'Knox Approval Name';
        knoxApprovalObj.OwnerId = user1.Id;
        knoxApprovalObj.WFOBJECT__c = 'ZCRM000310';
        knoxApprovalObj.Opportunity__c = opp.Id;
        knoxApprovalObj.OpportunityActivity__c = opptyActId;
        knoxApprovalObj.ApprovedId__c = opp.Id;
        knoxApprovalObj.Opinion__c = 'Approval Opinion';
        insert knoxApprovalObj;

       
    }

    @isTest
    static void testApprovalTempData() {
      list<EmailTemplate> listofEmailTemp = [SELECT id, Subject, HtmlValue FROM EmailTemplate WHERE DeveloperName = :'HQ' LIMIT 1];
        KnoxApprovalSubmitController.tempSaveApproval(opp.Id , (String)JSON.serialize(ApprovalData), fileList, opptyActId);

        List<TempKnoxApproval__c> temp = [select id from TempKnoxApproval__c where RecordId__c = :opp.Id and OwnerId = :UserInfo.getUserId() AND ActivityId__c = :opptyActId];
        List<TempKnoxApprover__c> temptempApprover = [SELECT Index__c, Name, ApproverType__c, EvSdeptNM__c, EvMailAddr__c, Employee__c, EvUniqID__c, IsChangeLine__c, IsEditText__c, IsArbitraryDecision__c
                                                        FROM TempKnoxApprover__c 
                                                        WHERE TempKnoxApproval__c = :temp[0].id 
                                                        ORDER BY Index__c ASC, Name];
         KnoxApproval__c knoxApprovalObj2 = [
                SELECT  Name,
                        OwnerId,
                        WFOBJECT__c,
                        Opportunity__c,
                        OpportunityActivity__c,
                        ApprovedId__c,
                        Opinion__c,
                        Description__c,
                        HTML__c,
             			MISID__c
                FROM KnoxApproval__c
                LIMIT 1];
		Opportunity_Activity__c opptyActId1 = [Select Id from Opportunity_Activity__c where Id =:opptyActId];
        List<Attachment> attList = [select id from Attachment where ParentId = :temp[0].Id];
        System.assertEquals(1, temp.size());
        //System.assertEquals(3, temptempApprover.size());
        System.assertEquals(1, attList.size());

        Map<String,Object> tempApp = KnoxApprovalSubmitController.initComponent(opp.Id, '-',true, opptyActId,knoxApprovalObj2.MISID__c);
        KnoxApproval__c appmap = (KnoxApproval__c)tempApp.get('knoxApproval');
        List<KnoxApprover__c> aplist = (List<KnoxApprover__c>)tempApp.get('knoxApprover');        
        System.debug('approver : ' +aplist );
        String sObjectName = opp.Id.getSObjectType().getDescribe().getName();
         sObjectName = 'Biz_Review__c';
        KnoxApprover__c aper = (KnoxApprover__c) aplist[0]; 
         try
      {
        KnoxApprovalSubmitController.saveApproval(opp.Id,knoxApprovalObj2,aplist,true,'');  
           }
        catch(exception e){
        }
        KnoxApprovalSubmitController.getChangeData('HQ',opp.Id,opptyActId1.Id);
       // System.assertEquals('Test Description', appmap.Description__c);

        //System.assertEquals(3, aplist.size());
        // System.assertEquals('test1', aper.Name);
        // System.assertEquals('EPID1', aper.EvUniqID__c);
        // System.assertEquals('7', aper.ApproverType__c);
    }

    @isTest
    static void testApprovalSubmit() {
        List<KnoxApproval__c>  aproverList = new List<KnoxApproval__c>();
        KnoxApproval__c knoxApprovalObj = [
                SELECT  Name,
                        OwnerId,
                        WFOBJECT__c,
                        Opportunity__c,
                        OpportunityActivity__c,
                        ApprovedId__c,
                        Opinion__c,
                        Description__c,
                        HTML__c,
            			MISID__c
                FROM KnoxApproval__c
                LIMIT 1];
        aproverList.add(knoxApprovalObj);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock());

        System.runAs(user1){                        
           Map<String,Object> resMap = KnoxApprovalSubmitController.initComponent(opp.Id, '-',true, opptyActId,knoxApprovalObj.MISID__c);
            /**
             * Knox Approval (Knox 결재)
             */
           
            Map<String, Object> knoxApprovalMap = (Map<String, Object>)JSON.deserializeUntyped( JSON.serialize(knoxApprovalObj) ) ;
            ApprovalData.put('KnoxApproval', knoxApprovalMap);
            
            Map<String,Object> result = KnoxApprovalSubmitController.requestApproval((String)JSON.serialize(ApprovalData), fileList, '-', '<p></p>', true, 'ZCRM000310' , opptyActId); //Added by Anish - v 1.1
            
            KnoxApproval__c approval = (KnoxApproval__c) result.get('knoxApproval');
            List<KnoxApprover__c> approverList = (List<KnoxApprover__c>) result.get('knoxApprover');

            KnoxApprovalSubmitController.copyCollaboContractApproval(opp_collabo.Id, 'ZCM9000001', knoxApprovalObj);
            KnoxApprovalSubmitController.callout_if135(knoxApprovalObj.Id);
            
            KnoxApprovalSubmitController.getCollaboOpptyActId(opp.Id , opp.CompanyCode__c , opp.OpportunityCode__c); //Added by Anish - New
        }
        Test.stopTest();

    }

    @isTest
    static void insertApprovalTest(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock(200));
        KnoxApproval__c approval = KnoxApprovalSubmitController.insertApproval(ApprovalData, opptyActId); //Added by Anish - v 1.1
        KnoxApprovalSubmitController.deleteApproval(approval.Id, 'IF079_ERROR');
        KnoxApprovalSubmitController.createInterfaceLog('deleteApproval','deleted','S',opptyActId); //Added by Anish- v 1.2
        KnoxApprovalSubmitController.getUserIPAddress();
        KnoxApprovalSubmitController.saveVaultId2Content(null,null,'Testing');
        KnoxApprovalSubmitController.getRelatedFiles(opptyActId);
        try{
            KnoxApprovalSubmitController.getVaultAuthToken('file-upload',null,'web');
        }catch(Exception e){
            System.debug(e);
        }
        Test.stopTest();
    }

}