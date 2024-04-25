/**
 * @description       : 
 * @author            : hj.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 2022-05-09
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                 Modification
 * 1.0   2020-11-23   hj.lee@dkbmc.com       Initial Version
 * 1.1   2021-03-30   Junghwa.Kim@dkbmc.com  FunctionSwitch 기능추가  
**/
public with sharing class KnoxEmailSendController {
    public static String RES_RESULT_SUCCESS = 'success';
    public static String RES_RESULT_ERROR = 'fail';
    
    private static KnoxEmailSendController instance;

    // FunctionSwitch__c 추가 2021-03-30
    public static FunctionSwitch__c funSW = FunctionSwitch__c.getInstance(UserInfo.getUserId()); 
    public static Boolean EmailSend = funSW.KnoxEmailSend__c;
    
    @AuraEnabled
    public static KnoxEmailSendController getInstance(){

        return instance == null? new KnoxEmailSendController() : instance;
    }

    /**
	* doInit        Method
    * @description  이메일 발송을 위한 기초 정보 
    * @Id           상세 보기 페이지에 대한 Record Id
    * @return       Map<String, Object> mapReturn
    *               resMap.recordInfo   객체 Id
    * 				resMap.userInfo 	로그인 사용자 정보
	**/
    @AuraEnabled
    public static Map<String, Object> doInit( Id recordId){
        
        System.debug( ':::::::::::KnoxEmailSendController( doInit):::::::::::::::');

        instance = KnoxEmailSendController.getInstance();
        
        Map<String, Object> mapReturn   = new Map<String, Object>();
        Map<String, String> mapUserInfo = new Map<String, String>();
        mapUserInfo.put( 'Id'       , UserInfo.getUserId());
        mapUserInfo.put( 'Name'     , UserInfo.getName());
        mapUserInfo.put( 'Email'    , UserInfo.getUserEmail());
        SObject parentSObj = instance.getParentInfo( recordId);        
        
        Boolean isEmailObj = String.valueof( recordId.getSObjectType()) == 'SendEmailReport__c';
        mapReturn.put( 'recordInfo', parentSObj);
        mapReturn.put( 'userInfo'  , mapUserInfo);
        mapReturn.put( 'isEmailObj', isEmailObj);
       

        /*
        2020-12-31 주석처리 
        if( isEmailObj){

            // 수신자 이메일 주소
            String[] emailCap     = new String[]{ 'TO', 'CC', 'BCC'};
            String[] emails       = new String[]{ };
            String[] strEmails    = String.join( emails, ',').replaceAll( ';', ',').split( ',');
            Set<String> setEmails = new Set<String>( strEmails);

            mapReturn.put( 'teamMemberList', instance.setEmailCC( emailCap, emails, setEmails));
        }       
        */
     

        String objName = String.valueof( recordId.getSObjectType());
        if( objName == 'Opportunity'){
            
            // 1) Stagename 기준
            String ifTemplate = '%Closure_Report_Lose_%';
            Opportunity   opp = ( Opportunity)parentSObj;
            if(  opp.StageName == 'Closed Lost') ifTemplate = '%Closure_Report_Not_Lose_%';
            // opp.StageName == 'Cancel' 


            // 2) 이메일 템플릿
            Map<Id, EmailTemplate> mapEmailTemp = instance.getEmailTemplate( ifTemplate);

            // 3) 이메일 템플릿 카테고리 생성
            List<Object>  listEmail    = new List<Object>();
            String        emailTemForm = '"label" : "{0}", "value" : "{1}" ';
            listEmail.add( JSON.deserializeUntyped( '{' + String.format( emailTemForm, new String[]{ '--None--', ''}) + '}') );

            for( EmailTemplate template : mapEmailTemp.values()){

                String[] emailParam = new String[]{ template.Subject, template.Id};
                listEmail.add( JSON.deserializeUntyped( '{' + String.format( emailTemForm, emailParam) + '}'));
            }
            
            mapReturn.put( 'emailList'    , listEmail);
            mapReturn.put( 'emailTemplate', mapEmailTemp);
        }

        return mapReturn;
    }


    @AuraEnabled
    public static Map<Integer, String>  convertHtmlFieldValue( Id recordId, EmailTemplate emailTemplate){
        
        System.debug( ':::::::::::KnoxEmailSendController( convertHtmlFieldValue):::::::::::::::');
        if( emailTemplate == null) return null;
        
        String description = null;
        if( emailTemplate.HtmlValue  != null) description = emailTemplate.HtmlValue;
        else if( emailTemplate.Body  != null) description = emailTemplate.Body;
        
        List<String> listTemplate = new List<String>{ emailTemplate.Subject, description};

        instance = KnoxEmailSendController.getInstance();
        return instance.convertHtmlFieldValue( recordId, listTemplate);
    }

    /**
	* sendEmail     Method
    * @description  이메일 발송을 위한 기초 정보 
    * @eFrom        보내는 사람 객체 정보
    * @eToList      받는 사람 
    * @eCcList      참조자
    * @eBccList     숨은 참조자
    * @eSubject     제목
    * @eDescription 보내는 내용
    * @efileList    파일목록
    * @return       Map<String, Object> mapReturn
    *               resMap.recordInfo   객체 Id
    * 				resMap.userInfo 	로그인 사용자 정보
    **/
    /*
    2020-12-31 주석처리 
    sendKnoxEmail()로 변경
    @AuraEnabled
    public static Map<String, List<String>> sendEmail( Id recordId, Boolean isEmailObj, List<String> eToList
                                                    , List<String> eCcList, List<String> eBccList, String subject
                                                    , String description, List<Map<String, Object>> efileList
                                                    , List<Map<String, String>> nfileList, String selEmailId){
        
        System.debug( ':::::::::::KnoxEmailSendController( sendEmail):::::::::::::::');
        instance = KnoxEmailSendController.getInstance();

        // 데이터 등록
        String             objName   = String.valueOf( recordId.getSObjectType());
       
        eBccList.add( UserInfo.getuserEmail());
        List<String>                    listTemplate = new List<String> { subject, description};
        Map<Integer, String>            mapResParse  = instance.convertHtmlFieldValue( recordId, listTemplate);
        List<Messaging.SendEmailResult> resultList   = instance.sendEmail( recordId, eToList, eCcList, eBccList
                                                                          ,mapResParse.get( 0), mapResParse.get( 1), efileList, nfileList);

        // 메일 전송 성공 여부
        Map<String, List<String>>    mapEmailResult = new Map<String, List<String>>();
        List<String>                 failListResult = new List<String>();
        for( Messaging.SendEmailResult result: resultList){

            if( !result.isSuccess()){

                for( Messaging.SendEmailError err : result.getErrors()){

                   failListResult.add( err.getMessage());
                }
            }
        }
        
        // 처리 결과
        if( failListResult.size() > 0) mapEmailResult.put( 'fail'   , failListResult);        

        return mapEmailResult;
    }
    */

    /**
	* getTeamMembers Method
    * @description  Record Id를 이용해 TeamMember의 이메일 객체
    * @recordId     부모 ParentId
    * @epIdList     사용자 epid 목록
    * @return       Map<String, List<Object>> Team Member의 이메일 객체
	**/
    /*
    @AuraEnabled
    public static List<Object> getTeamMembers( Id recordId, List<String> epIdList){
        
        System.debug( ':::::::::::KnoxEmailSendController( getTeamMembers):::::::::::::::');

        String       sObjName       = String.valueOf( recordId.getSObjectType());
        
        return KnoxApprovalNewController.getTeamMembers( recordId, epIdList);   
    }
    */
    /**
	* isMobile      Method
    * @description  모바일일 경우 강제로 Callback 호출을 시키기 위한 더미 함수 
    * @isMobile     모바일 여부 true/false
    * @return       모바일 여부 true/false
	**/
    @AuraEnabled
    public static Boolean isMobile( Boolean isMobile){
        
        return isMobile;
    }    

    /**
	* getParentInfo Method
    * @description  Record Id를 이용해 객체 정보를 구해온다. 
    * @Id           상세  페이지 Record Id
    * @return       SObject  셍세 페이지 정보
	**/
    public SObject getParentInfo( Id recordId){

        System.debug( ':::::::::::KnoxEmailSendController( getParentInfo):::::::::::::::');
            
        String                    sObjName  = String.valueof( recordId.getSObjectType());
        Map<String, SObjectField> mapFields = Schema.getGlobalDescribe().get( sObjName).getDescribe().fields.getMap();
        String[]                  objFields = new List<String>( mapFields.KeySet());
        String                    strFields = String.join( objFields, ',');
        String                    query     = 'SELECT {0} FROM {1} WHERE Id = :recordId ';

        query  = String.escapeSingleQuotes( String.format( query, new String[]{ strFields, sObjName}));

        return DataBase.query( query);
    }

    /**
	* getEmailFileAttachList      Method
    * @description                Email의 첨부파일 객체를 생성
    * @List<Map<String, Object>>  efileList  파일객체 목록
    * @return   listAttach        Email 파일 객체
	**/
    private List<Messaging.EmailFileAttachment> getEmailFileAttachList( List<Map<String, Object>> efileList){

        System.debug( ':::::::::::KnoxEmailSendController( getEmailFileAttachList):::::::::::::::');
        List<Messaging.EmailFileAttachment> listAttach = new List<Messaging.EmailFileAttachment>();
        for( Map<String, Object> mapObj : efileList){

            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName( mapObj.get( 'name') + '');
            efa.setBody    ( (Blob) EncodingUtil.base64Decode( mapObj.get( 'fileContents') + ''));

            listAttach.add( efa);
        }

        return listAttach;
    }

    /**
	* convertHtmlFieldValue       Method
    * @description                HTML의 SObject 필드값 매칭
    * recordId                    관련 목록 MASTER Id
    * listTemplate                HTML 서식에서 변환될 SObject의 필드값(HTML 서식)
    * @return                     Map<Integer, String>  변환될 결과 RETURN
	**/
    public Map<Integer, String> convertHtmlFieldValue( Id recordId, List<String> listTemplate){

        System.debug( ':::::::::::KnoxEmailSendController( convertHtmlFieldValue):::::::::::::::');
        List<Messaging.RenderEmailTemplateBodyResult> parseList = Messaging.RenderEmailTemplate( null, recordId, listTemplate);
        
        Map<Integer, String> mapParse    = new Map<Integer, String>();
        Integer              parseRowCnt = parseList.size();
        for( Integer i = 0; i < parseRowCnt; i ++){

            Messaging.RenderEmailTemplateBodyResult result = parseList.get( i);
            if( result.getSuccess())  mapParse.put( i, result.getMergedBody());
            else mapParse.put( i, listTemplate[i]);
        }
        
        return mapParse;
    }


    /**
	* sendEmail     Method
    * @description  이메일 발송
    * @Id           대상 SObject 레코드 Id
    * @toList       받는 사람 
    * @ccList       참조자
    * @bccList      숨은 참조자
    * @subject      제목
    * @description  보내는 내용
    * @efileList    파일목록
    * @return       List<Messaging.SendEmailResult> 이메일 객체 결과 정보
	*
    **/
    /*
    2020-12-31 주석처리 
    sendKnoxEmail()로 변경
    public List<Messaging.SendEmailResult> sendEmail( Id recordId, List<String> toList, List<String> ccList, List<String> bccList
                                                    ,String subject,  String description, List<Map<String, Object>> efileList, List<Map<String, String>> nfileList){

        System.debug( ':::::::::::KnoxEmailSendController( sendEmail):::::::::::::::');
        List<Messaging.EmailFileAttachment> listAttach =  getEmailFileAttachList( efileList);
        
        Messaging.SingleEmailMessage sEmail  = new Messaging.SingleEmailMessage();

        String desc1 = description.replaceAll( '\\n', '---n');
        desc1 = desc1.stripHtmlTags().replaceAll( '--n', '\\n');

        if( nfileList.size() > 0) description = description + saveTheCvFileLink( nfileList);

        sEmail.setToAddresses ( toList);
        sEmail.setCcAddresses ( ccList);
        sEmail.setBccAddresses( bccList);
        sEmail.setSubject     ( subject);
        sEmail.setHtmlBody    ( description);
        sEmail.setPlainTextBody(desc1);
        sEmail.setWhatId      ( recordId);
        sEmail.setFileAttachments( listAttach);
        sEmail.setSaveAsActivity( true);



        //String sObjName = recordId.getSobjectType().getDescribe().getName().toLowerCase();
        String sObjName    = String.valueof( recordId.getSObjectType()).toLowerCase();
        if( 'user,contact,lead'.indexOf( sObjName) >-1) sEmail.setTargetObjectId( recordId);
        Messaging.Email[] emails  = new Messaging.Email[]{ sEmail};
        return Messaging.sendEmail( emails);        
    }

*/
    /**
	* sendKnoxEmail     Method
    * @description  이메일 발송을 위한 기초 정보 
    * @eFrom        보내는 사람 객체 정보
    * @eToList      받는 사람 
    * @eCcList      참조자
    * @eBccList     숨은 참조자
    * @eSubject     제목
    * @eDescription 보내는 내용
    * @efileList    파일목록
    * @return       Map<String, Object> mapReturn
    *               resMap.recordInfo   객체 Id
    * 				resMap.userInfo 	로그인 사용자 정보
	**/
    @AuraEnabled
    public static Map<String, List<String>> sendKnoxEmail( Id recordId, Boolean isEmailObj, List<String> eToList
                                                    , List<String> eCcList, List<String> eBccList, String subject
                                                    , String description, List<Map<String, Object>> efileList
                                                    , List<Map<String, String>> nfileList, String selEmailId){
        
        System.debug( ':::::::::::KnoxEmailSendController( sendKnoxEmail):::::::::::::::');
        instance = KnoxEmailSendController.getInstance();

        // 데이터 등록
        
        String             objName   = String.valueOf( recordId.getSObjectType());
        Employee__c senderEmployee = Utils.getLoginEmployeeData(UserInfo.getUserId());
       
        eBccList.add( senderEmployee.EvMailAddr__c);
        List<String>                    listTemplate = new List<String> { subject, description};
        Map<Integer, String>            mapResParse  = instance.convertHtmlFieldValue( recordId, listTemplate);
        Map<String,Object>              resultMap = instance.sendKnoxEmail( recordId, eToList, eCcList, eBccList, mapResParse.get( 0), mapResParse.get( 1), efileList, nfileList);
        
        // 메일 전송 성공 여부
        Map<String, List<String>>    mapEmailResult = new Map<String, List<String>>();
        
        List<String>                 failListResult = new List<String>();

        System.debug('result Map : ' + resultMap);
        System.debug('result : ' + resultMap.get('result'));
        System.debug('errorDetail : ' + resultMap.get('errorDetail'));

        // 2020-12-30 StatusCode 체크 추가
        if(resultMap.get('StatusCode') != 200){
            failListResult.add(String.valueOf('IF_MSG'));
            mapEmailResult.put('fail', failListResult);

            return mapEmailResult;
        }
        if(resultMap.get('result') == 'fail'){
            
            failListResult.add(String.valueOf(resultMap.get('errorDetail')));
        }
        // 처리 결과
        if( failListResult.size() > 0) mapEmailResult.put( 'fail'   , failListResult);        
        
        return mapEmailResult;
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

    public Map<String,Object> sendKnoxEmail( Id recordId, List<String> toList, List<String> ccList, 
                                            List<String> bccList ,String subject,  String description, 
                                             List<Map<String, Object>> efileList, List<Map<String, String>> nfileList){

        Map<String,Object> resMap = new Map<String,Object>();

        Employee__c senderEmployee = Utils.getLoginEmployeeData(UserInfo.getUserId());
        system.debug('Sender Employee : '+ senderEmployee);                                      
        IF_KnoxEmailSendController.InputClass bodyMap = new IF_KnoxEmailSendController.InputClass();

        bodyMap.subject = subject;
        bodyMap.contents = description;
        // contentType : 1) TEXT : 텍스트, 2) MIME : 마임, 3) HTML : HTML
        bodyMap.contentType = 'HTML';
        // doSecuType : 1) PERSONAL : 개인, 2) OFFICIAL : 공문
        bodyMap.docSecuType = 'PERSONAL';
        bodyMap.sfdcId = recordId;

        // 2021-02-05 InputClass isMulti val 추가
        /*
        bodyMap.isMulti = false;
        String ObjName = recordId.getSobjectType().getDescribe().getName();
        if(ObjName == 'VRBRequest__c' || ObjName == 'Biz_Review__c'){
            bodyMap.isMulti = true;
        }
        */
        IF_KnoxEmailSendController.Sender sender = new IF_KnoxEmailSendController.Sender(senderEmployee.EvMailAddr__c.split('@')[0], senderEmployee.EvMailAddr__c);
        bodyMap.sender = sender;

        // recipientType : 1) 수신 : TO, 2) 참조 : CC, 3) 비밀참조 : BCC
        List<IF_KnoxEmailSendController.Recipients> recipientsList = new List<IF_KnoxEmailSendController.Recipients>();
        for(String t : toList){
            IF_KnoxEmailSendController.Recipients r = new IF_KnoxEmailSendController.Recipients(t, 'TO');
            System.debug('TO : ' + r);
            recipientsList.add(r);
        }

        for(String t : ccList){
            IF_KnoxEmailSendController.Recipients r = new IF_KnoxEmailSendController.Recipients(t, 'CC');
            System.debug('CC : ' + r);
            recipientsList.add(r);
        }

        for(String t : bccList){
            IF_KnoxEmailSendController.Recipients r = new IF_KnoxEmailSendController.Recipients(t, 'BCC');
            System.debug('BCC : ' + r);
            recipientsList.add(r);
        }
        bodyMap.recipients = recipientsList;

        List<IF_KnoxEmailSendController.Attachments> attachmentsList = new List<IF_KnoxEmailSendController.Attachments>();
        for(Map<String, Object> file : efileList){
            System.debug(file.get('file'));
            IF_KnoxEmailSendController.Attachments attachments = new IF_KnoxEmailSendController.Attachments('file', String.valueOf(file.get('name')), String.valueOf(file.get('fileContents')));
            System.debug('attachments : ' + attachments);
            attachmentsList.add(attachments);
        }
        bodyMap.attachments = attachmentsList;

        System.debug('bodyMap : ' + bodyMap);

        Map<String,Object> response = new Map<String, Object>();
        if(!Test.isRunningTest()){
            // FunctionSwitch__c 추가 2021-03-30
            if(EmailSend) response = IF_KnoxEmailSendController.send(bodyMap);
        } else {
            response.put('result', RES_RESULT_SUCCESS);
            response.put('mailId', 'testMailId');
        }
        System.debug(response);

        String responseResult = String.valueOf(response.get('result') == null ? '' : response.get('result'));
        if(responseResult == RES_RESULT_ERROR){
            System.debug('1111');
            resMap.put('result', RES_RESULT_ERROR);
            
            Map<String, Object> approvalResponseErrorDetail = (Map<String,Object>)response.get('errorDetail');
            resMap.put('Message', String.valueOf(approvalResponseErrorDetail.get('errorMessage')));

        }else if(responseResult == RES_RESULT_SUCCESS){
            System.debug('2222');
            resMap.put('result', RES_RESULT_SUCCESS);

            String knoxEmailId = String.valueOf(response.get('mailId'));
            insertKnoxEmailObj(recordId, senderEmployee.Id, toList, ccList, bccLIst, subject, description, knoxEmailId);
        }
        return resMap;
    }


    public void insertKnoxEmailObj(Id recordId, String senderEmpId, List<String> toList, List<String> ccList, List<String> bccList,
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

    /**                                                                          
	* getEmailTemplate     Method
    * @description        이메일 템플릿 목록
    * @ifTemplate         검색 조건
    * @return       Map<Id, EmailTemplate> 이메일 템플릿 정보
	*
    **/
    public Map<Id, EmailTemplate>  getEmailTemplate( String ifTemplate){

        // 이메일 템플릿 목록
       return new Map<Id, EmailTemplate>([
            
            SELECT Id ,Name ,Subject ,Body 
                  ,HtmlValue ,CreatedDate ,DeveloperName
            FROM   EmailTemplate
            WHERE  FolderId in (

                SELECT Id from Folder
                WHERE DeveloperName = 'Report_Template'
            )
            AND    ( NOT DeveloperName LIKE :ifTemplate)
            AND    isActive = true
            ORDER BY Name ASC
        ]);

    }


    /**
	* setEmailCC     Method
    * @description  이메일 수신자 정보 설정
    * @emailCap     발송 이메일 Header( toAddress, ccAddress, bccAddress) 
    * @emails       벌송 이메일 
    * @strEmails    벌송 이메일 검색 조건 
    * @return       Map<Id, EmailTemplate> 이메일 템플릿 정보
	*
    **/
    /*
    2020-12-31 주석처리 

    public List<Object> setEmailCC( String[] emailCap, String[] emails, Set<String> setEmails){

        Integer emailRowCnt = emailCap.size();
        

        // 이메일 주소에 맞는 사용자 검색
        Map<String, Employee__c> mapEmpEmail = new Map<String, Employee__c>();
        for( Employee__c emp : [ SELECT Id, Name, EvMailAddr__c, EvSdeptNM__c, EvUniqID__c FROM Employee__c WHERE EvMailAddr__c IN :setEmails]){

            mapEmpEmail.put( emp.EvMailAddr__c, emp);
        }
        

        // TeamMemberList 읽어온다.
        List<Object> empList = new List<Object>();
        String   tMemberForm = '"Id" : "{0}", "Name" : "{1}", "EvMailAddr__c" : "{2}", "EvSdeptNM__c" : "{3}", "EvUniqID__c" : "{4}", "RecpSt": "{5}"';
        for( Integer i = 0; i < emailRowCnt; i ++){

            if( String.isempty( emails[i])) continue;
                
            // Recipients
            String[] tEmails     = emails[i].split( ';');
            for( String tEmail : tEmails){
                
                Employee__c emp    = ( Employee__c)mapEmpEmail.get( tEmail);
                if( emp == null) continue;
                
                String memberForm  = String.format( tMemberForm, new String[] { emp.Id, emp.Name, emp.EvMailAddr__c
                                                                              , emp.EvSdeptNM__c, emp.EvUniqID__c, emailCap[i]});
                empList.add( JSON.deserializeUntyped( '{' + memberForm + '}'));
            }
        }

        return empList;
    }
    */
    /**
	* saveTheCvFiles  Method
    * @description    발송된 이메일의 첨부파일 저장
    * @fileList       파일 목록( 파일 내역 정보)
    * @return         저장된 Salesforce File
	*
    **/
    /*
    2020-12-31 주석처리 
    public List<ContentVersion> saveTheCvFiles( List<Map<String, Object>> fileList){

        List<ContentVersion> cvList = new List<ContentVersion>();
        for( Map<String, Object> file : fileList){

            String fileName      = String.valueof( file.get( 'name'));
            ContentVersion cv    = new ContentVersion(
                 ContentLocation = 'S'
                ,PathOnClient    = fileName
                ,Origin          = 'C'
                ,Title           = fileName
                ,VersionData     = ( Blob)EncodingUtil.base64Decode( file.get( 'fileContents') + '') 
            );
            cvList.add( cv);
        }
        insert cvList;

        return cvList;
    }
    */

    /**
	* saveTheCvFiles Method
    * @description   관련 목록
    * @parentId      상위 파일 목록 아이디
    * @fileList      파일 목록( 파일 내역 정보)
    * @return        관련 목록 객체 정보
	*
    **/
    /*
    2020-12-31 주석처리 
    public List<ContentDocumentLink> saveTheCvFiles( Id parentId, List<Map<String, Object>> fileList){
    
        List<ContentVersion> cvList    = saveTheCvFiles( fileList);
        List<ContentVersion> contVList = [ SELECT ContentDocumentId FROM ContentVersion WHERE  Id IN :cvList];

        List<ContentDocumentLink> linkList = new List<ContentDocumentLink>();
        for( ContentVersion cv : contVList){

            ContentDocumentLink link= new ContentDocumentLink(
                 LinkedEntityId     = parentId
                ,ContentDocumentId  = cv.ContentDocumentid
                ,ShareType          = 'V'
            );
            linkList.add( link);
        }
        insert linkList;

        return linkList;
    }
    */
    /**
	* saveTheCvFileLink Method
    * @description    첨부파일 링크
    * @fileList      파일 목록( 파일 내역 정보)
    * @return        다운로드 HTML 서식정보
	*
    **/
    /*
    2020-12-31 주석처리 
    public String saveTheCvFileLink( List<Map<String, String>> fileList){


        List<ContentDistribution> cdList    = new List<ContentDistribution>();
        for( Map<String, String> fileMap : fileList){

            ContentDistribution cd  = new ContentDistribution();
            cd.Name                             = fileMap.get( 'name');
            cd.ContentVersionId                 = fileMap.get( 'cvId');
            cd.PreferencesAllowViewInBrowser    = true;
            cd.PreferencesLinkLatestVersion     = true;
            cd.PreferencesNotifyOnVisit         = false;
            cd.PreferencespasswordRequired      = false;
            cd.PreferencesAllowOriginalDownload = true;
            cdList.add( cd);
        }
        insert cdList;


        List<ContentDistribution> cdbList = [ 

            SELECT Id
                  ,Name
                  ,DistributionPublicUrl
            FROM   ContentDistribution 
            WHERE  Id IN :cdList
        ];

        String htmlBody = '<br/><br/><br/><h5> File DownLoad</h5>';
        htmlBody += '<table border="0" style="border-collapse: collapse;border-top: 3px solid #168;width:100%">';
        htmlBody += '<thead>';
        //htmlBody += '<caption>File DownLoad</caption>';
        htmlBody += '<tr style="text-align: center;">';
        htmlBody += '<th style="color:#168;text-align:center;padding:10px;border: 1px solid #ddd;border-left: 0;">File Name</th>';
        htmlBody += '<th style="color:#168;text-align:center;padding:10px;border: 1px solid #ddd;border-right: 0;">DownLoad</th>';
        htmlBody += '</tr></thead>';
        htmlBody += '<tbody>';
        for( ContentDistribution cd : cdbList){

            htmlBody += '<tr style="text-align: center;">';
            htmlBody += '<td style="padding: 10px;border: 1px solid #ddd;border-left: 0;">'+ cd.Name +'</td>';
            htmlBody += '<td style="padding: 10px;border: 1px solid #ddd;border-right: 0;">';
            htmlBody += '<a href=' + cd.DistributionPublicUrl + ' download style="color:#0e89d6">' + cd.Name+ '</a><br/></td>';
            htmlBody += '</tr>';
        }
        htmlBody += '</tbody></table>';

        return htmlBody;
    }
    */
    @AuraEnabled
    public static List<Map<String,String>> getDocFileList( List<String> fileIdList){

        List<ContentDocument> docList = [

            SELECT Id
                  ,LatestPublishedVersionId
                  ,Title
                  ,FileType
                  ,FileExtension
            FROM   ContentDocument
            WHERE  Id  IN :fileIdList
        ];

        List<Map<String, String>> fileList = new List<Map<String, String>>();
        Map<String, String>       docMap   = new Map<String, String>();
        for( ContentDocument doc : docList){

            String fileName   = doc.Title;
            if( !String.isEmpty( doc.FileExtension)) fileName += '.' + doc.FileExtension;
            String fileType = doc.FileType.toLowerCase();

            docMap.put( 'cvId', doc.LatestPublishedVersionId);
            docMap.put( 'name', fileName);
            fileList.add( docMap);
        }

        return fileList;
    }
}