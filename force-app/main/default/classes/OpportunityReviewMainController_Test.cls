/**
 * @description       : 
 * @author            : ukhyeon.lee@samsung.com
 * @group             : 
 * @last modified on  : 09-03-2021
 * @last modified by  : ukhyeon.lee@samsung.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   07-09-2021   ukhyeon.lee@samsung.com   Initial Version
**/
@isTest
public class OpportunityReviewMainController_Test {
	public static String recordId;
    public static final String[] systemAdmin = new String[]{'System Administrator', 'Custom System Administrator'};
    public static final String[] piAdmin = new String[]{'PI (Biz. Owner)'};  
    public static Opportunity opportunity, opportunity1, hqOpportunity, subsOpportunity; 
    public static Opportunity_Activity__c opportunityActivity; 
    public static Project__c project; 
    public static WBS__c wbs;
    public static String inputData;
    public static String inputData1;
    public static Map<String, String> inputMap;
    static OpportunityNotice__c notice; 
    static String docId;
    static{
        
        notice = new OpportunityNotice__c(
            NoticeKR__c = '가나다라',
            NoticeEN__c = 'abcd'
        );
        insert notice;

        ExternalDataSource eds = [SELECT Id FROM ExternalDataSource WHERE DeveloperName = 'EFSS_Vault' LIMIT 1];
        ContentVersion cv = new ContentVersion(
            ContentLocation = 'E',
            Origin = 'H',
            OwnerId = UserInfo.getUserId(),
            Title = 'filename', 
            PathOnClient = 'filename',
            ExternalDataSourceId = eds.Id,
            ExternalDocumentInfo1 = 'vault://0123456789abcdef',
            ExternalDocumentInfo2 = '0123456789abcdef'
        );
        insert cv;
        docId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1].ContentDocumentId; 
        
        opportunity = new Opportunity(
            Name = 'test',
            CurrencyIsoCode='EUR',
            StageName= 'stage1',
            OpportunityCode__c='SDS-123124',
            CloseDate = System.today(),            
            Opportunity_Review_Checkbox1__c=false,
            Opportunity_Review_Checkbox2__c=false,
            Opportunity_Review_Consortium__c=false,
            Opportunity_Review_Exception__c=false,            
            Opportunity_Review_VRB_Type__c='10',
            BusinessType__c='TI'
        );     
        
        opportunity1 = new Opportunity(
            Name = 'test 1',
            CurrencyIsoCode='EUR',
            StageName= 'stage1',
            OpportunityCode__c='SDS-123125',
            CloseDate = System.today(),            
            Opportunity_Review_Checkbox1__c=false,
            Opportunity_Review_Checkbox2__c=false,
            Opportunity_Review_Consortium__c=false,
            Opportunity_Review_Exception__c=false,            
            Opportunity_Review_VRB_Type__c='10',
            BusinessType__c='TI',
            VRB_Account_Change__c = true
        );
        hqOpportunity = new Opportunity(
            Name = 'test',
            CurrencyIsoCode='EUR',
            OpportunityCode__c='SDS-123123',
            StageName= 'stage1',
            BusinessType__c='TI',
            CloseDate = System.today(),            
            Opportunity_Review_Checkbox1__c=false,
            Opportunity_Review_Checkbox2__c=false,
            Opportunity_Review_Consortium__c=false,
            Opportunity_Review_Exception__c=false,            
            Opportunity_Review_VRB_Type__c='10'
        );
        subsOpportunity = new Opportunity(
            Name = 'test',
            OpportunityCode__c='SDS-123123',
            StageName= 'stage1',
            BusinessType__c='TI',
            CloseDate = System.today(),            
            Opportunity_Review_Checkbox1__c=false,
            Opportunity_Review_Checkbox2__c=false,
            Opportunity_Review_Consortium__c=false,
            Opportunity_Review_Exception__c=false,            
            Opportunity_Review_VRB_Type__c='10'
        );

        insert opportunity;
        insert opportunity1;
        insert hqOpportunity;
        insert subsOpportunity;

        Company__c hqc = new Company__c();
        hqc.CompanyCode__c = 'T100';
        hqc.Name = 'hq';
        insert hqc;

        Company__c subsc = new Company__c();
        subsc.CompanyCode__c = 'T810';
        subsc.Name = 'subsc';
        insert subsc;

        CostCenter__c hqCenter = new CostCenter__c();
        hqCenter.CostCenter__c = 'test12';
        hqCenter.Company__c = hqc.id;
        insert hqCenter;
        
        CostCenter__c subsCenter = new CostCenter__c();
        subsCenter.CostCenter__c = 'test13';
        subsCenter.Company__c = subsc.id;
        insert subsCenter;

        Account acc = new Account(
            Name = 'SUBS ACCOUNT',
            AccountNumber = 'A1234567',
            mBizLoan__c = '320',
            MDGCheck__c = true
        );
        insert acc;
        
        hqOpportunity.CollaborationBOId__c = subsOpportunity.id;
        hqOpportunity.SalesDepartment__c =hqCenter.id;
        hqOpportunity.cOriginAcc__c = acc.id;
        hqOpportunity.AccountId = acc.id;
        
        subsOpportunity.CollaborationBOId__c = hqOpportunity.id;
        subsOpportunity.SalesDepartment__c = subsCenter.id;
        subsOpportunity.cOriginAcc__c = acc.id;
        subsOpportunity.AccountId = acc.id;

        update hqOpportunity;
        update subsOpportunity;

        opportunityActivity = new Opportunity_Activity__c(
            WhatId__c = opportunity.id,
            TransactionName__c = 'ZP21'
        );
        insert opportunityActivity;
        project = new Project__c(
            Opportunity__c =  opportunity.Id,
            Name = 'Test2',
            Description__c = 'Test2',
            ProjectCode__c = 'testProject002'
        );
        insert project;



        inputMap = new Map<String, String>();
        inputMap.put('ORDER_ID'       , opportunity.OpportunityCode__c);//BO코드
        inputMap.put('SAP_COMPANY'    , opportunity.CompanyCode__c);//회사코드
        inputMap.put('BIZ_AMOUNT'     , String.valueOf(opportunity.Opportunity_Review_Biz_Amount__c));//사업규모(VAT제외)
        inputMap.put('CONSORTIUM_YN'  , 'N');//컨소시엄여부
        inputMap.put('COMPLIANCE_1_YN', 'N');//Complicance 1
        inputMap.put('COMPLIANCE_2_YN', 'N');//Complicance 2

        inputData = '[{"Opportunity_Review_Checkbox1__c" : false,"Opportunity_Review_Checkbox2__c" : false,"Opportunity_Review_Result__c" : "test","Opportunity_Review_Consortium__c" : false,"Opportunity_Review_Exception__c" : true,"Opportunity_Review_Exception_Reason__c" : "test","Amount" : 0,"Opportunity_Review_VRB_Type__c": "10","Opportunity_Review_VRB_Type_Confirm__c": "10","Opportunity_Review_Dangerous__c": "Y"}]';
        inputData1 = '[{"Opportunity_Review_Checkbox1__c" : false,"Opportunity_Review_Checkbox2__c" : false,"Opportunity_Review_Result__c" : "test","Opportunity_Review_Consortium__c" : false,"Opportunity_Review_Exception__c" : true,"Opportunity_Review_Exception_Reason__c" : "test","Amount" : 0,"Opportunity_Review_VRB_Type__c": "30","Opportunity_Review_VRB_Type_Confirm__c": "30","Opportunity_Review_Dangerous__c": "Y"}]';
    }
    
    @isTest public static void getProjectCode(){
        OpportunityReviewMainController.getProjectCode(opportunity.id);
    }
    @isTest public static void getOpptyData(){
        OpportunityReviewMainController.getOpptyData(hqOpportunity.id);
        OpportunityReviewMainController.getOpptyData(subsOpportunity.id);
    }
    @isTest public static void boDataSave(){
        OpportunityReviewMainController.boDataSave(opportunity.id,inputData);
    }
    @isTest public static void getBOInfo(){
        OpportunityReviewMainController.getBOInfo(hqOpportunity.id);
    }
    @isTest public static void retrieveBusinessCheckType(){
        OpportunityReviewMainController.retrieveBusinessCheckType(opportunity.id, inputData);
    }
    @isTest public static void confirmBoData(){
        OpportunityReviewMainController.confirmBoData(opportunity.id,inputData);
        OpportunityReviewMainController.confirmBoData(opportunity.id,inputData1);
        OpportunityReviewMainController.confirmBoData(opportunity1.id,inputData1);
    }

    @isTest public static void others(){        
        OpportunityReviewMainController.upsertOpportunityActivity(opportunity.id, 'In Progress', false,true);  
        OpportunityReviewMainController.upsertOpportunityActivity(opportunity.id, 'Completed', false,true);
        OpportunityReviewMainController.getBOVRBCheck(inputMap);
    }
    
     @IsTest
    private static void test_method_1() {
        list<String> fileIds = new list<String>();
        fileIds.add('0123456789abcdef');

        Test.startTest();

        String body = '';
            body += '{';
            body += '"id" : "0123456789abcdef",';
            body += '"domain" : "vault-stg.efss.asmsung.net",';
            body += '"secKey" : "0123456789abcdef"';
            body += '}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(body));
        system.debug(OpportunityReviewMainController.getVaultAuthToken('file-view', fileIds));

        Test.stopTest();
    }
    
	@IsTest
    private static void test_method_2() {
        Test.startTest();
        //OpportunityReviewMainController.getInfo('Notice');
        OpportunityReviewMainController.getVaultFileId(docId);
        OpportunityReviewMainController.getUserIPAddress();
        Test.stopTest();
    }
    
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        String responseBody = '';

        public MockHttpResponseGenerator(String responseBody){
            this.responseBody = responseBody;
        }

        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint
            // and method.
            system.assertEquals('POST', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(responseBody);
            res.setStatusCode(200);
            return res;
        }
    }
}