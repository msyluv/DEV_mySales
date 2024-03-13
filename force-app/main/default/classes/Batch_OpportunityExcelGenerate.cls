/**
 * @author            : hyunhak.roh@dkbmc.com
 * @description       : 
 * @last modified on  : 2022-10-18
 * @last modified by  : hyunhak.roh@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                   Modification
**/
public class Batch_OpportunityExcelGenerate implements Database.Stateful, Database.Batchable<sObject>, Database.AllowsCallouts {
	
    public String csvColumnHeader;
    public String csvRowValues;
    
    //전역변수
    private Set<Id> setParamOppId = new Set<Id>();
    
    public static Map<String,String> stageMap;
    public static Map<String,String> statusMap;
    public static Map<String,String> bizTypeMap;

    public static String RES_RESULT_SUCCESS = 'success';
    public static String RES_RESULT_ERROR = 'fail';
    
    public static Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    
    public static FunctionSwitch__c funSW = FunctionSwitch__c.getInstance(UserInfo.getUserId()); 
    public static Boolean EmailSend = funSW.KnoxEmailSend__c;
    
    public static List<Company__c> companyList = [SELECT Name, CompanyCode__c FROM Company__c];
    
    public static Map<String,Object> mailResult = new Map<String,Object>();
    private List<KnoxEmail__c> KnoxEmailList = new List<KnoxEmail__c>();
    
    public static Integer chkCnt = 0;
    
    static{
        stageMap = new Map<String,String>();
        
        Schema.DescribeFieldResult stageFieldResult = Opportunity.StageName.getDescribe();
        List<Schema.PicklistEntry> stageList = stageFieldResult.getPicklistValues();
        for (Schema.PicklistEntry stage: stageList) {
            stageMap.put(stage.getValue(), stage.getLabel());
        }

        statusMap = new Map<String,String>();
        
        Schema.DescribeFieldResult statusFieldResult = Opportunity.OpportunityStatus__c.getDescribe();
        List<Schema.PicklistEntry> statusList = statusFieldResult.getPicklistValues();
        for (Schema.PicklistEntry status: statusList) {
            statusMap.put(status.getValue(), status.getLabel());
        }

        bizTypeMap = new Map<String,String>();

        Schema.DescribeFieldResult bizTypeFieldResult = Opportunity.BusinessType__c.getDescribe();
        List<Schema.PicklistEntry> bizTypeList = bizTypeFieldResult.getPicklistValues();
        for (Schema.PicklistEntry bizType: bizTypeList) {
            bizTypeMap.put(bizType.getValue(), bizType.getLabel());
        }
    }
    
    //TODO : 호출시에 단건/복수건 일수 있음.
    //
    //Database.executeBatch(new Batch_SendDropLostInfo(Set<Id> setBOActId), 200);  
    //
    public Batch_OpportunityExcelGenerate(Set<Id> setParamOppId){
        System.debug('========== Batch_OpportunityExcelGenerate ==========');
        this.setParamOppId = setParamOppId;
        System.debug('########## Batch_OpportunityExcelGenerate, setParamOppId ########## ' + this.setParamOppId);
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        System.debug('========== start ==========');
        
        //Datetime deadline = Datetime.now().addHours(-1); 
        String str_SELECT = '';
        str_SELECT += 'SELECT Id, Name, OpportunityCode__c, OpportunityStatus__c, StageName, CompanyCode__c, AccountId, Account.Name, Account.AccountNumber, ';
        str_SELECT += 'cOriginAcc__c, cOriginAcc__r.Name, cOriginAcc__r.AccountNumber, BusinessLevel__c, OwnerId, Owner.Name, SalesDivision__c, ';
        str_SELECT += 'SalesDepartment__c, SalesDepartment__r.Name, cPrimaryDeliveryDivision__c, cPrimarySalesDepartment__c, cPrimarySalesDepartment__r.Name, ';
        str_SELECT += 'Collaboration__c, GroupInternal__c, KoreaDomestic__c, BusinessType__c, DealBreak__c, CloseDate, FirstCloseDate__c, RecordTypeId, RecordType.Name ';
        str_SELECT += 'FROM Opportunity ';
        str_SELECT += 'WHERE Id IN :setParamOppId ';
		//Test
		//str_SELECT += 'LIMIT 1000 ';
        
        System.debug('### Batch_OpportunityExcelGenerate, start() str_SELECT : ' + str_SELECT);
        
        return Database.getQueryLocator(str_SELECT);
    }
    
    public void execute(Database.BatchableContext bc, List<Opportunity> boList) {
        System.debug('========== execute ==========');
        System.debug('### Batch_OpportunityExcelGenerate, execute, Query Result Size : ' + boList.size());
        System.debug('### Batch_OpportunityExcelGenerate, execute, Query Result boList get : ' + boList.get(0));

        Map<String,Object> resMap = new Map<String,Object>();
        
        try{
            String tmpComp = '';
            String rowStr = '';
            for(Opportunity oppty : boList){
                
                rowStr += '"' 	+ Util_String.nvlStr(oppty.CompanyCode__c);
                for(Company__c comp : companyList){
                    if(oppty.CompanyCode__c == comp.CompanyCode__c){
                        tmpComp = comp.Name;
                    }
                }
                rowStr += '","' + tmpComp;
                rowStr += '","' + Util_String.nvlStr(oppty.OpportunityCode__c);
                rowStr += '","' + Util_String.nvlStr(oppty.Name);
                rowStr += '","' + statusMap.get(oppty.OpportunityStatus__c);
                rowStr += '","' + stageMap.get(oppty.StageName);       
                rowStr += '","' + Util_String.nvlStr(oppty.Account.AccountNumber);
                rowStr += '","' + Util_String.nvlStr(oppty.Account.Name);
                rowStr += '","' + Util_String.nvlStr(oppty.cOriginAcc__r.AccountNumber);
                rowStr += '","' + Util_String.nvlStr(oppty.cOriginAcc__r.Name);
                rowStr += '","' + Util_String.nvlStr(oppty.BusinessLevel__c);
                rowStr += '","' + Util_String.nvlStr(oppty.Owner.Name);
                rowStr += '","' + Util_String.nvlStr(oppty.SalesDivision__c);
                rowStr += '","' + Util_String.nvlStr(oppty.SalesDepartment__r.Name);
                rowStr += '","' + Util_String.nvlStr(oppty.cPrimaryDeliveryDivision__c);
                rowStr += '","' + Util_String.nvlStr(oppty.cPrimarySalesDepartment__r.Name);
                if(oppty.Collaboration__c)	rowStr += '","' + 'O';
                else						rowStr += '","' + 'X';
                if(oppty.GroupInternal__c)	rowStr += '","' + 'O';
                else						rowStr += '","' + 'X';
                if(oppty.KoreaDomestic__c)	rowStr += '","' + 'O';
                else						rowStr += '","' + 'X';
                rowStr += '","' + bizTypeMap.get(oppty.BusinessType__c);
                if(oppty.DealBreak__c)		rowStr += '","' + 'O';
                else						rowStr += '","' + 'X';
                String formattedDateStr = DateTime.newInstance(oppty.CloseDate.year(), oppty.CloseDate.month(), oppty.CloseDate.day()).format(Utils.getUserDateFormat());
                rowStr += '","' + formattedDateStr;
                if(oppty.FirstCloseDate__c != null){
                    String formattedDateStr_first = DateTime.newInstance(oppty.FirstCloseDate__c.year(), oppty.FirstCloseDate__c.month(), oppty.FirstCloseDate__c.day()).format(Utils.getUserDateFormat());
                    rowStr += '","' + formattedDateStr_first;
                }else{
                    rowStr += '","' + '';
                }
                rowStr += '"\n';
                
                chkCnt++;
                
                //Test
                //rowStr += rowStr;
            }
            
            csvRowValues += rowStr;

            System.debug('### Batch_OpportunityExcelGenerate, execute, chkCnt : ' + chkCnt);
            System.debug('### Batch_OpportunityExcelGenerate, execute, boList : ' + boList);
            System.debug('### Batch_OpportunityExcelGenerate, execute, rowStr : ' + csvRowValues);
            
        }catch(Exception e){
            System.debug('Error : ' + e.getMessage());
            System.debug('Error StackTrace : ' + e.getStackTraceString());
            System.debug('Error Line : ' + e.getLineNumber());
        }
    }
    
    public void finish(Database.BatchableContext bc) { 
        System.debug('========== finish ==========');
        
        DateTime dtNow = system.now().addHours(9);
        
        List<String> toList = new List<String>();
        List<String> ccList = new List<String>();
        List<String> bccList = new List<String>();
        List<Map<String, Object>> efileList = new List<Map<String, Object>>();
        List<Map<String, String>> nfileList = new List<Map<String, String>>();
        
        // 수신자
        if(!isSandbox) 	toList.add(UserInfo.getUserEmail());
        else 			toList.add('kj78.yu@stage.partner.samsung.com');

        /*
        //Test
        String tmpRow = '"T100","Samsung SDS","SDS-21011920","[TR] SETK-P/Cloud/MES Implementation","Won","Won","T401-00","Samsung SDS Europe LTD","A1061470","Samsung Electronics Turkey (SETK)","B","김 영훈","전략마케팅실","전자MES사업그룹(DS AM)","클라우드서비스사업부","G-MES시스템그룹(DX/부품SRE)","X","O","X","Implementation Business","X","2021. 12. 13.","2021. 12. 13."' + '"\n';
        for(integer idx = 0; idx < 10; idx++){
            tmpRow += tmpRow;
        }
        csvRowValues += csvRowValues;
        csvRowValues += csvRowValues;
        csvRowValues += csvRowValues;
        //csvRowValues += tmpRow;
        */
        
        //첨부 파일
        Blob body = Blob.valueOf('\uFEFF' + generateCSV(csvRowValues));
        Map<String, Object> efile = new Map<String, Object>();
        efile.put('name'			, 'OPPORTUNITY_SEARCH_' + dtNow + '.csv');
        efile.put('fileContents'	, EncodingUtil.base64Encode(body));
        efileList.add(efile);
        
        //if(!Test.isRunningTest()) mailresult = sendKnoxEmail(Id.valueOf(UserInfo.getUserId()), toList, ccList, bccList, String.valueOf(tempMap.get('subject')), String.valueOf(tempMap.get('body')), efileList, nfileList);
        mailResult = sendKnoxEmail(Id.valueOf(UserInfo.getUserId()), toList, ccList, bccList, System.Label.BOSEARCH_LAB_BULK_MAIL_SUBJECT, System.Label.BOSEARCH_LAB_BULK_MAIL_BODY, efileList, nfileList, false);
        
        if(mailresult.get('KnoxEmail') != null) KnoxEmailList.add((KnoxEmail__c)mailResult.get('KnoxEmail'));
        
        System.debug('### Batch_OpportunityExcelGenerate, finish, KnoxEmailList.size() : ' + KnoxEmailList.size());
        System.debug('### Batch_OpportunityExcelGenerate, finish, KnoxEmailList  : ' + KnoxEmailList);
        
        if(KnoxEmailList.size() > 0) insert KnoxEmailList;
    }
    
    public static String generateCSV(String csvRowValues) {
        // ######################## Import Header Start ########################        
		String csvColumnHeader = '';
        csvColumnHeader += '"' 	 + System.Label.BOSEARCH_LAB_COMPANYID;
        csvColumnHeader += '","' + System.Label.BOSEARCH_LAB_COMPANYCODE;
        csvColumnHeader += '","' + System.Label.BOSEARCH_LAB_BOCODE;
        csvColumnHeader += '","' + System.Label.BOSEARCH_LAB_BONAME;
        csvColumnHeader += '","' + System.Label.BOSEARCH_LAB_STATUS;
        csvColumnHeader += '","' + System.Label.BOSEARCH_LAB_STAGE;
        csvColumnHeader += '","' + System.Label.BOSEARCH_LAB_ACCOUNTCODE;
        csvColumnHeader += '","' + System.Label.BOSEARCH_LAB_ACCOUNT;
        csvColumnHeader += '","' + System.Label.BOSEARCH_LAB_ORIGNACCOUNTCODE;
        csvColumnHeader += '","' + System.Label.BOSEARCH_LAB_ORIGNACCOUNT;
        csvColumnHeader += '","' + System.Label.BOSEARCH_LAB_BIZLEVEL;
        csvColumnHeader += '","' + System.Label.BOSEARCH_LAB_OWNER;
        csvColumnHeader += '","' + System.Label.BOSEARCH_LAB_SALESDIVISION;
        csvColumnHeader += '","' + System.Label.BOSEARCH_LAB_SALESDEPT;
        csvColumnHeader += '","' + System.Label.BOSEARCH_LAB_DELIVERYDEVISION;
        csvColumnHeader += '","' + System.Label.BOSEARCH_LAB_DELIVERYDEPT;
        csvColumnHeader += '","' + System.Label.BOSEARCH_LAB_COLLABORATION;
        csvColumnHeader += '","' + System.Label.BOSEARCH_LAB_GROUPINTERNAL;
        csvColumnHeader += '","' + System.Label.BOSEARCH_LAB_DOMESTIC;
        csvColumnHeader += '","' + System.Label.BOSEARCH_LAB_BIZTYPE;
        csvColumnHeader += '","' + System.Label.BOSEARCH_LAB_DEALBREAK;
        csvColumnHeader += '","' + System.Label.BOSEARCH_LAB_CLOSEDATE;
        csvColumnHeader += '","' + System.Label.BOSEARCH_LAB_1STCLOSEDATE;
        csvColumnHeader += '"\n';

        System.debug('### Batch_OpportunityExcelGenerate, finish(), csvColumnHeader : ' + csvColumnHeader);
        System.debug('### Batch_OpportunityExcelGenerate, finish(), csvRowValues : ' + csvRowValues);
        
        return csvColumnHeader + csvRowValues;
    }
    
    /**
	* sendKnoxEmail   Method
    * @description    이메일 발송
    * @Id             대상 SObject 레코드 Id
    * @toList         받는 사람 
    * @ccList         참조자
    * @bccList        숨은 참조자
    * @subject        제목
    * @description    보내는 내용
    * @efileList      파일목록
    * @return         String Knox 이메일 객체 결과 정보
	*
    **/
    public static Map<String,Object> sendKnoxEmail( Id recordId, List<String> toList, List<String> ccList, 
                                            	List<String> bccList ,String subject,  String description, 
                                             	List<Map<String, Object>> efileList, List<Map<String, String>> nfileList, Boolean isMulti){

        Map<String,Object> resMap = new Map<String,Object>();

        Employee__c senderEmployee = Utils.getLoginEmployeeData(UserInfo.getUserId());
        IF_KnoxEmailSendController.InputClass bodyMap = new IF_KnoxEmailSendController.InputClass();

        bodyMap.subject = subject;
        bodyMap.contents = description;
        // contentType : 1) TEXT : 텍스트, 2) MIME : 마임, 3) HTML : HTML
        bodyMap.contentType = 'HTML';
        // doSecuType : 1) PERSONAL : 개인, 2) OFFICIAL : 공문
        bodyMap.docSecuType = 'PERSONAL';
        bodyMap.sfdcId = recordId;

        // 2021-02-05 InputClass isMulti val 추가
        bodyMap.isMulti = isMulti;
        System.debug('### Batch_OpportunityExcelGenerate, sendKnoxEmail, isMulti : ' + isMulti);
        System.debug('### Batch_OpportunityExcelGenerate, sendKnoxEmail, before : ' + senderEmployee.EvMailAddr__c);
        
		// 발신자
        if(!isSandbox) senderEmployee.EvMailAddr__c = 'mysales@samsung.com';
        else senderEmployee.EvMailAddr__c = 'kj78.yu@stage.partner.samsung.com';
                                                    
        System.debug('============sendknoxemail============');
        System.debug('### Batch_OpportunityExcelGenerate, sendKnoxEmail, after : ' + senderEmployee.EvMailAddr__c);
        IF_KnoxEmailSendController.Sender sender = new IF_KnoxEmailSendController.Sender(senderEmployee.EvMailAddr__c.split('@')[0], senderEmployee.EvMailAddr__c);
        bodyMap.sender = sender;

        // recipientType : 1) 수신 : TO, 2) 참조 : CC, 3) 비밀참조 : BCC
        List<IF_KnoxEmailSendController.Recipients> recipientsList = new List<IF_KnoxEmailSendController.Recipients>();
        for(String t : toList){
            IF_KnoxEmailSendController.Recipients r = new IF_KnoxEmailSendController.Recipients(t, 'TO');
            System.debug('### Batch_OpportunityExcelGenerate, sendKnoxEmail, TO : ' + r);
            recipientsList.add(r);
        }

        for(String t : ccList){
            IF_KnoxEmailSendController.Recipients r = new IF_KnoxEmailSendController.Recipients(t, 'CC');
            System.debug('### Batch_OpportunityExcelGenerate, sendKnoxEmail, CC : ' + r);
            recipientsList.add(r);
        }

        for(String t : bccList){
            IF_KnoxEmailSendController.Recipients r = new IF_KnoxEmailSendController.Recipients(t, 'BCC');
            System.debug('### Batch_OpportunityExcelGenerate, sendKnoxEmail, BCC : ' + r);
            recipientsList.add(r);
        }
        bodyMap.recipients = recipientsList;

        List<IF_KnoxEmailSendController.Attachments> attachmentsList = new List<IF_KnoxEmailSendController.Attachments>();
        for(Map<String, Object> file : efileList){
            System.debug('### Batch_OpportunityExcelGenerate, sendKnoxEmail, file : ' + file.get('file'));
            IF_KnoxEmailSendController.Attachments attachments = new IF_KnoxEmailSendController.Attachments('file', String.valueOf(file.get('name')), String.valueOf(file.get('fileContents')));
            System.debug('### Batch_OpportunityExcelGenerate, sendKnoxEmail, attachments : ' + attachments);
            attachmentsList.add(attachments);
        }
        bodyMap.attachments = attachmentsList;
                                                    
        System.debug('### Batch_OpportunityExcelGenerate, sendKnoxEmail, bodyMap : ' + bodyMap);

        Map<String,Object> response = new Map<String, Object>();
        if(!Test.isRunningTest()){
            if(EmailSend){
                response = IF_KnoxEmailSendController.send(bodyMap);

                if(isMulti){
                    // IF_Log.InterfaceLog ifLog = (IF_Log.InterfaceLog) response.get('INTERFACE_LOG');
                    // IF_Log log = new IF_Log();
                    // log.createLog(ifLog);
                    resMap.put('INTERFACE_LOG', response.get('INTERFACE_LOG'));
                }
            }
        } else {
            response.put('result', RES_RESULT_SUCCESS);
            response.put('mailId', 'testMailId');
        }
        System.debug('### Batch_OpportunityExcelGenerate, sendKnoxEmail, response : ' + response);
                                                 
        for(String s : response.keySet()){
            System.debug('### Batch_OpportunityExcelGenerate, keyVal : ' + s);
        }

        String responseResult = String.valueOf(response.get('result') == null ? '' : response.get('result'));
        System.debug('### Batch_OpportunityExcelGenerate, responseResult : ' + responseResult);
        if(responseResult == RES_RESULT_ERROR){
            resMap.put('result', RES_RESULT_ERROR);
            
            Map<String, Object> approvalResponseErrorDetail = (Map<String,Object>)response.get('errorDetail');
            resMap.put('Message', String.valueOf(approvalResponseErrorDetail.get('errorMessage')));

        }else if(responseResult == RES_RESULT_SUCCESS){
            resMap.put('result', RES_RESULT_SUCCESS);

            String knoxEmailId = String.valueOf(response.get('mailId'));
            if(isMulti){
                resMap.put('KnoxEmail', KnoxEmailObj(recordId, senderEmployee.Id, toList, ccList, bccLIst, subject, description, knoxEmailId));
            } else {
                insertKnoxEmailObj(recordId, senderEmployee.Id, toList, ccList, bccLIst, subject, description, knoxEmailId);
            }
        }
        return resMap;
    }

	public static void insertKnoxEmailObj(Id recordId, String senderEmpId, List<String> toList, List<String> ccList, List<String> bccList,
                                    String subject,  String description, String knoxEmailId){
        KnoxEmail__c knoxEmail = new KnoxEmail__c(
            RecordId__c = recordId
            , Sender__c = senderEmpId
            , ToAddress__c = String.join(toList, ',')
            , CcAddress__c = String.join(ccList, ',')
            , BccAddress__c = String.join(bccList, ',')
            , Name = subject
            , HtmlBody__c = description
            , MailId__c = knoxEmailId
            , Status__c = 'Send'
        );

        if(recordId != null) {
            String objApiName =String.valueOf(recordId.getSObjectType()); 
            if(objApiName == 'Opportunity') knoxEmail.Opportunity__c = recordId;
        }

        insert knoxEmail;
    }

    public static KnoxEmail__c KnoxEmailObj(Id recordId, String senderEmpId, List<String> toList, List<String> ccList, List<String> bccList,
                                    String subject,  String description, String knoxEmailId){
        KnoxEmail__c knoxEmail = new KnoxEmail__c(
            RecordId__c = recordId
            , Sender__c = senderEmpId
            , ToAddress__c = String.join(toList, ',')
            , CcAddress__c = String.join(ccList, ',')
            , BccAddress__c = String.join(bccList, ',')
            , Name = subject
            , HtmlBody__c = description
            , MailId__c = knoxEmailId
            , Status__c = 'Send'
        );

        if(recordId != null) {
            String objApiName =String.valueOf(recordId.getSObjectType()); 
            if(objApiName == 'Opportunity') knoxEmail.Opportunity__c = recordId;
        }

        return knoxEmail;
    }
    
    public class InputClass{
        
    }
}