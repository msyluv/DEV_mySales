/**
* @description       : [C21070005913]사업리드 고객컨택 알람기능 
* @author            : yeongju.baek@dkbmc.com
* @group             : 
* @last modified on  : 2022-12-22
* @last modified by  : anish.jain@partner.samsung.com 
* Modifications Log 
* Ver   Date         Author                   Modification
* 1.0   07-21-2021   yeongju.baek@dkbmc.com   Initial Version
* 1.1   2021-07-30   seonju.jin@dkbmc.com     사업리드 개요 LeadDescription__c -> Description__c 으로 수정, Name 링크 추가
* 1.2   2022-11-30   anish.jain@partner.samsung.com  Delayed notification to Department Head of sales lead
* 1.3   2022-12-22   anish.jain@partner.samsung.com  Special character removal from Sales Lead Description
**/
global class Batch_SalesLeadEmail implements Database.StateFul, Database.Batchable<sobject>, Database.AllowsCallouts, schedulable{
    
    private static final String INTERFACE_ID = 'IF-075';
    private static final String APEX_CLASS   = 'Batch_SalesLeadEmail'; 
    private static final String METHOD_NAME  = 'Batch';
    private static String LINK_URL = 'https://' + getDomain() + '.lightning.force.com/lightning/r/Sales_Lead__c/';
    
    //이메일 템플릿
    private final String EMAIL_TEMP = 'SalesLead_Late_Email';
    private final String SENDER_EMAIL = 'mysales@samsung.com';
    public static Datetime deadline = Datetime.now().addDays(-2);
    private static String guId = IF_Util.generateGuid();
    private static List<KnoxEmail__c> knoxemailList = new List<KnoxEmail__c>();
    private static Boolean isSandbox = Utils.getIsSandbox();
    public static String sendStatus = 'No Data';
    
    //테스트를 위한 변수
    public Set<Id> testIdSet;
    public static String testEmail = 'chae_ho.yang@stage.samsung.com'; //yeongju.baek@stage.partner.samsung.com
    
    public Batch_SalesLeadEmail(){}
    
    //Test를 위한 생성자
    public Batch_SalesLeadEmail(Set<Id> testIdSet){ this.testIdSet = testIdSet;}
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        IF_Log ifStartLog = new IF_Log();
        IF_Log.BatchLog batchStartLog;
        batchStartLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Start', '', 0);
        ifStartLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Start:' + BC.getJobId() + ') 시작' + ' ####################');
        ifStartLog.createLog(batchStartLog);
        String queryString;
        Database.QueryLocator returnScope;
        //SalesLead 정보 조회
        queryString = 'select Id, Name,OwnerId, Owner.Name, Description__c, deptHeadNotiYN__c, LeadDescription__c, CreatedDate, CustomerContactDate__c, Sales_Alert_Date__c from Sales_Lead__c'; //Modified by Anish - v 1.2
        //Start-Added by Anish - v 1.2
        if(Test.isRunningTest()){ 
            queryString += ' where LeadStatus__c != \'Close\' and CustomerContactDate__c = null and Lead__c != null';
        }
        else{
            queryString += ' where LeadStatus__c != \'Close\' and CustomerContactDate__c = null and Lead__c != null AND CreatedDate <= :deadline';
        }    
        //End-Added by Anish - v 1.2
        if(testIdSet != null && testIdSet.size() > 0) queryString += ' AND Id IN :testIdSet';
        
        
        returnScope = DataBase.getQueryLocator( queryString);
        System.debug('Test returnScope'+returnScope);
        //queryString += ' where CustomerContactDate__c = null and Sales_Alert_Date__c = null and Lead__c != null AND CreatedDate <= :deadline limit 10';// testquery : 출력 1개
        ifStartLog.addLog(' selectedSalesLead : '+ returnScope);
        ifStartLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Start:' + BC.getJobId() + ') 종료' + ' ####################');
        return returnScope;
    }
    
    global void execute(Database.BatchableContext BC, List<Sales_Lead__c> scopeList){
        
        IF_Log ifExcuteLog = new IF_Log();
        IF_Log.BatchLog batchExcuteLog;
        
        String reqMsg = '';
        String resMsg = '';
        
        //EmailTemplete 조회
        EmailTemplate temp = [SELECT Id, Name, DeveloperName, Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = :EMAIL_TEMP LIMIT 1];
        
        //1. 템플릿의 메일 제목 가져오기
        //ifExcuteLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Excute:' + BC.getJobId() + ') 시작' + ' ####################');
        Employee__c senderEmployee;
        
        if(isSandbox){
            senderEmployee = Utils.getLoginEmployeeData(UserInfo.getUserId());
            senderEmployee.EvMailAddr__c = testEmail;
        }else{
            List<User> userList = [SELECT Id, Name From User WHERE Username = :SENDER_EMAIL];
            if(userList.size() > 0) senderEmployee = Utils.getLoginEmployeeData(userList.get(0).Id);
        }
        
        Map<String,Object> toEmailMap = new Map<String,Object>();
        
        //scopelist for문 owner정보 가져오기 id, federation
        //1. owner id 가져오기
        Set<String> OwnerSet = new set<String>();
        for( Sales_Lead__c sl : scopeList){
            OwnerSet.add(sl.ownerId);
        }
        
        //2. owner id의 federationIdentifier가져오기
        List<User> userinfo = [
            SELECT 
            Id, FederationIdentifier 
            FROM User 
            WHERE Id IN :OwnerSet
        ];
        Map<String,String> userFed = new Map<String,String>(); //Added by Anish - v 1.2
        
        //3. federation 의 email가져오기
        Set<String> FederSet = new set<String>();
        for(User user : userinfo){
            FederSet.add(user.FederationIdentifier);
            //Start - Added by Anish - v 1.2
            if(user.FederationIdentifier!=null || user.FederationIdentifier!=''){ 
                userFed.put(user.FederationIdentifier,user.Id) ;     
            } 
            //End - Added by Anish - v 1.2
        }
        
        System.debug(' Test userFed'+userFed);
        List<Employee__c> empList = [
            SELECT 
            Id, EvUniqID__c, EvMailAddr__c, EvKostl__c
            FROM Employee__c 
            WHERE EvUniqID__c IN :FederSet
        ];
        
        //Start-Added by Anish - v 1.2
        List<Employee__c> empList1 = new List<Employee__c>(); 
        List<String> listCC = new List<String>();
        for(Employee__c emp : empList){
            if(emp.EvUniqID__c!=null || emp.EvUniqID__c!=''){
                empList1.add(emp);
                listCC.add(String.valueOf(emp.EvKostl__c));
            }
        }
        System.debug('Anish Test empList1'+empList1);
        System.debug('Anish Test listCC'+listCC);
        //End-Added by Anish - v 1.2
        
        Map<String,String> deptHeadMap = new Map<String,String>(); //Added by Anish - v 1.2
        
        
        //4. toEmailMap에 담아주기
        for(User owner : userinfo){
            for(Employee__c email : empList){
                if(owner.FederationIdentifier == email.EvUniqID__c){
                    // System.debug('ownerId = '+owner.Id);
                    // System.debug('ownerEmail = '+email.EvMailAddr__c);
                    String OwnerId = String.valueOf(owner.Id);
                    toEmailMap.put(OwnerId, String.valueOf(email.EvMailAddr__c)); 
                    //toEmailMap.put(OwnerId, 'yeongju.baek@stage.partner.samsung.com'); 
                }
            }
        }
        
        // 5. 부서장 추가 (chae_ho.yang 22.11.25)
        String deptManagerEmail = '';
        //Start-Added by Anish - v 1.2
        Map<String,String> deptEmailMap = new Map<String,String>();
        List<CostCenter__c> ownerCostCenter = [SELECT Id, Name, DeptManager__c, DeptManager__r.EvMailAddr__c,CostCenter__c from CostCenter__c where CostCenter__c IN : listCC]; 
        System.debug('Anish Test ownerCostCenter'+ownerCostCenter);
        for(CostCenter__c cCenter : ownerCostCenter){
            deptEmailMap.put(cCenter.CostCenter__c,cCenter.DeptManager__r.EvMailAddr__c);
        }
        System.debug('Anish Test deptEmailMap'+deptEmailMap);
        for(Employee__c emp : empList1){
            deptHeadMap.put(userFed.get(emp.EvUniqID__c),deptEmailMap.get(String.valueOf(emp.EvKostl__c))); 
        }
        System.debug('Anish Test deptHeadMap'+deptHeadMap);
        //End- Added by Anish - v 1.2
        
        System.debug('toEmailMap = '+ toEmailMap );
        String name = '';
        String owner = '';
        
        List<IF_Log.InterfaceLog> totalIfLogList = new List<IF_Log.InterfaceLog>();
        List<Sales_Lead__c> leadList = new List<Sales_Lead__c>(); //Added by Anish - v 1.2
        try{            
            System.debug(' Test scopeList'+scopeList);
            for( Sales_Lead__c sale : scopeList){
                
                //2  본문 가져오기
                String subject      = String.valueOf(temp.Subject);                                 // Email Subject
                String body         = String.valueOf(temp.HtmlValue).replace('\r\n', '');           // Email Content 
                name                = Util_String.nvlStr(sale.Name);                                // 사업리드 명
                String nameLink     = '<a href ="' + LINK_URL + sale.Id +'/view">'+ name + '</a>';  // 2021.08.02 사업리드명 링크 추가
                owner               = Util_String.nvlStr(sale.Owner.Name);                          // 사업리드 소유자명
                String descript     = sale.Description__c;  // 사업리드 개요
                //Start - Added by Anish - v 1.3
                if(!Test.isRunningTest()){
                descript = descript.replace('\\\\',''); 
                descript = descript.replace('\\','');    
                }
                //End - Added by Anish - v 1.3
                Datetime createDate = sale.createdDate;                                             // 접수일자(생성일자)
                String createLine   = createDate.format('yyyy-MM-dd a HH:mm:ss');
                String deadLine     = createDate.addDays(+2).format('yyyy-MM-dd a HH:mm:ss');       // 회신기한
                
                //사업개요
                if(String.isNotBlank(descript)){
                    if(descript.contains('\n')){
                        descript = + '<p>' +  (sale.Description__c).replace('\n','<br>') + '</p>';
                    }
                } else{
                    descript= '';
                }
                
                //String senderId = 'a091s0000035Ax2AAE';//a0M1s000000W4dhEAC
                System.debug('Name : ' + name);
                System.debug('NameLink:' + nameLink);
                System.debug('Owner : ' + owner);
                System.debug('Descript : ' + descript);
                System.debug('CreateDate : ' + createDate);
                System.debug('DeadLine : ' + deadLine);
                
                body = body.replace('{!Name}'           , nameLink );
                body = body.replace('{!OwnerName}'      , owner);
                body = body.replace('{!LeadDescription}', descript);
                body = body.replace('{!CreateDate}'     , createLine);
                body = body.replace('{!DeadLine}'       , deadLine);
                System.debug('bodyReplace : '+ body);
                
                List<String> toList = new List<String>();
                String toOwner = String.valueOf(sale.ownerId);
                toList.add(String.valueOf(toEmailMap.get(toOwner)));
                System.debug(toList);
                
                //개발,품질 테스트
                 if(isSandbox){toList.add(testEmail);}
                
                List<IF_KnoxEmailSendController.Recipients> recipientsList = new List<IF_KnoxEmailSendController.Recipients>();
                for(String t : toList){
                    IF_KnoxEmailSendController.Recipients r = new IF_KnoxEmailSendController.Recipients(t, 'TO');
                    System.debug('TO : ' + r);
                    recipientsList.add(r);
                }
                
                /*
// 부서장 추가 DeptManager in CC
IF_KnoxEmailSendController.Recipients c = new IF_KnoxEmailSendController.Recipients(String.valueOf(deptHeadMap.get(sale.OwnerId)), 'CC');
system.debug('deptManagerEmail : ' + deptManagerEmail);
recipientsList.add(c);


                system.debug('recipientList : ' + recipientsList);
                */
                //senderEmployee.EvMailAddr__c.split('@')[0], senderEmployee.EvMailAddr__c
                // IF_KnoxEmailSendController.Sender sender = new IF_KnoxEmailSendController.Sender(senderEmployee.EvMailAddr__c.split('@')[0], senderEmployee.EvMailAddr__c);
                if(String.isBlank(senderEmployee.EvMailAddr__c)) senderEmployee.EvMailAddr__c = SENDER_EMAIL;
                IF_KnoxEmailSendController.Sender sender = new IF_KnoxEmailSendController.Sender(senderEmployee.EvMailAddr__c.split('@')[0], senderEmployee.EvMailAddr__c);
                IF_KnoxEmailSendController.InputClass bodyMap = new IF_KnoxEmailSendController.InputClass();
                bodyMap.subject = subject;
                bodyMap.contents = body;
                bodyMap.contentType = 'HTML';
                bodyMap.docSecuType = 'PERSONAL';
                bodyMap.sfdcId = sale.Id;
                bodyMap.recipients = recipientsList;
                bodyMap.sender = sender;
                bodyMap.isMulti = true;
                
                Map<String,Object> resMap = new Map<String,Object>();
                Map<String,Object> response = new Map<String, Object>();
                
                response = IF_KnoxEmailSendController.send(bodyMap);
                System.debug('------------------>'+String.valueOf(response));
                if(Integer.valueof(response.get('StatusCode'))>=300){   // 이메일 발송 실패
                    String errMsg = '';
                    
                    Map<String,Object> errDetailMap =(response.get('errorDetail') == null ) ? new Map<String,Object>() : (Map<String,Object>)response.get('errorDetail');
                    if(errDetailMap != null){
                        errMsg = (errDetailMap.get('errorCode') == null) ? '' : String.valueOf(errDetailMap.get('errorCode'));
                        errMsg += (errDetailMap.get('errorMessage') == null) ? '' :  ',' + String.valueOf(errDetailMap.get('errorMessage'));
                    }
                    //ifExcuteLog.addLog('salesLead Name : '+ Name + ', owner : ' + Owner + ', result : '+ String.valueOf(response.get('result')) + ', errMsg:' + errMsg);
                }else{  //이메일 발송 성공
                    String ResponseMsg = String.valueOf(response.get('result'));
                    String knoxEmailId = Util_String.nvlStr(response.get('mailId'));
                    
                    KnoxEmail__c knoxemail = new KnoxEmail__c(
                        RecordId__c = sale.Id
                        , ToAddress__c = String.join(toList, ',')
                        , Name = subject
                        , HtmlBody__c = body
                        , MailId__c = knoxEmailId
                        , Status__c = 'Send'
                    );
                    if(senderEmployee != null) knoxemail.Sender__c = senderEmployee.Id;
                    knoxemailList.add(knoxemail);
                    sale.Sales_Alert_Date__c = Datetime.now();
                    
                    system.debug('DEPTHEADEMAIL : ' + deptManagerEmail);
                    
                    //--------------------------------------------------------------------
                    //사업리드 48시간 후에 고객컨택 일시 미등록시 알람
                    try{
                        String ownerId = sale.ownerId;
                        String deptHeadId = '';
                        String salesLeadName = sale.Name;
                        String salesLeadOwner = '';
                        String salesLeadDescription = sale.Description__c;
                        system.debug('CHLOG : CHECK');
                        //Start - Added by Anish - v 1.3
                        if(!Test.isRunningTest()){
                        salesLeadDescription = salesLeadDescription.replace('\r',' '); 
                        salesLeadDescription = salesLeadDescription.replace('\n',' '); 
                        salesLeadDescription = salesLeadDescription.replaceAll('\\\\','');
                        }
                        //End - Added by Anish - v 1.3
                        System.debug('Test Description 1@ :'+salesLeadDescription);
                        String ownerEmail = '';
                        String salesLeadCreateDate = createLine;
                        String replyDeadline = deadLine;
                        String linkAddress = '';                
                        Boolean isSandbox = Utils.getIsSandbox();
                        
                        User salesUser = [SELECT Id, LastName, FirstName, Email, FederationIdentifier
                                          FROM User
                                          WHERE id = :ownerId];
                        Employee__c salesEmployee = salesUser.FederationIdentifier != '' ? Utils.getEmployeeData(salesUser.FederationIdentifier) : null;
                        
                        salesLeadOwner = salesUser.LastName + salesUser.FirstName;
                        if(salesEmployee != null) ownerEmail = salesEmployee.EvMailAddr__c;
                        
                        if(String.isNotBlank(ownerEmail)){
                            ownerId = ownerEmail.left(ownerEmail.indexOf('@'));
                        }
                        
                       
                        //QA
                        if(isSandbox){
                            linkAddress = 'https://sdssfa--qa.lightning.force.com/lightning/r/Sales_Lead__c/'+sale.Id+'/view';
                        }
                        //REAL
                        else{
                            linkAddress = 'https://sdssfa.lightning.force.com/lightning/r/Sales_Lead__c/'+sale.Id+'/view';
                        }
                        /* ------------------------------------------------------------------------- */
                        /* Jitterbit 통해 Knox Rest API 호출 시작 */
                        Map<String, String> inputMap = new Map<String, String>();
                        inputMap.put('ownerId', ownerId);
                        inputMap.put('salesLeadName', salesLeadName);
                        inputMap.put('salesLeadOwner', salesLeadOwner);
                        inputMap.put('ownerEmail', ownerEmail);
                        inputMap.put('salesLeadDescription', salesLeadDescription);
                        inputMap.put('salesLeadCreateDate', salesLeadCreateDate);
                        inputMap.put('replyDeadline', replyDeadline);
                        inputMap.put('linkAddress', linkAddress);
                        
                        String oldSingleId = inputMap.get('ownerId');
                        String newSingleId = inputMap.get('ownerId');
                        //TID-000005 : 사업리드 48시간 후에 고객컨택 일시 미등록시 알람
                        String appcardContentStr =  IF_KnoxChatSendController.getKnoxAppcardMessageContents('TID-000005', inputMap);
                        System.debug('Anish Knox Test1 :'+appcardContentStr);
                        System.debug('Test headEmailId1 :'+newSingleId);
                        totalIfLogList.addAll(doChat(oldSingleId, newSingleId, appcardContentStr));
                        
                        //Start-Added by Anish - v 1.2
                        if(sale.deptHeadNotiYN__c == False && deptHeadMap.get(sale.OwnerId) !=null){ 
                            String headEmailId = deptHeadMap.get(sale.OwnerId);
                            System.debug('Test headEmailId :'+headEmailId);
                            List<String> trimDeptId = headEmailId.split('@');
                            totalIfLogList.addAll(doChat(trimDeptId[0], trimDeptId[0], appcardContentStr));
                            sale.deptHeadNotiYN__c = True;
                            leadList.add(sale);
                        } 
                        //End-Added by Anish - v 1.2
                        
                        /* Jitterbit 통해 Knox Rest API 호출 종료*/
                        /* ------------------------------------------------------------------------- */   
                    }
                    catch(Exception e){
                        System.debug('Batch_SalesLeadEmail.cls -> KnoxChat e.getMessage : ' + e.getMessage());
                    }
                    //--------------------------------------------------------------------
                    //ifExcuteLog.addLog( 'salesLead Name : '+ Name + ', owner : ' + Owner + ', result : '+ ResponseMsg + ', mailId: ' + knoxEmailId);
                    
                }
            }
            //Start - Added by Anish - v 1.2
            if(leadList.size()>0){
                System.debug('Anish Test leadList'+leadList);
                update leadList;
            }
            //End - Added by Anish - v 1.2
            sendStatus = 'Success';
        }catch(Exception e){
            ifExcuteLog.addLog( 'salesLead Name : '+ Name +', owner : ' + Owner+ ', Exception: '+ e.getStackTraceString());
            sendStatus = 'Error';
        }finally{
            //saleslead email date
            //update scopeList;       //update Sales_Alert_Date__c
            insert knoxemailList;
            ifExcuteLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Excute:' + BC.getJobId() + ') 종료' + ' ####################');
            
            //create Interface Log
            batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Excute', '', 0);
            ifExcutelog.createLog(batchExcuteLog);
            
            if (totalIfLogList!=null){
                IF_Log log;
                for(IF_Log.InterfaceLog ifResultLog : totalIfLogList){
                    log = new IF_Log();
                    log.createLog(ifResultLog);
                }
            }
        }
        
        
        
        
    }
    
    global void finish(Database.BatchableContext BC){
        IF_Log ifFinishLog = new IF_Log();
        IF_Log.BatchLog batchFinishLog;
        batchFinishLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Finish', '', 0);
        ifFinishLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME +'(SendStatus : '+ sendStatus +') 종료' + ' ####################');
        
        ifFinishLog.createLog(batchFinishLog);
    }
    
    public void execute(SchedulableContext sc) {
        //Callout Exceed Limit으로 5개씩 실행
        DataBase.executeBatch( new Batch_SalesLeadEmail(), 5);
    }
    
    //get Domain
    public static string getDomain(){
        String domain = '';
        try {
            String urlInstance=String.valueof(System.URL.getSalesforceBaseURL().gethost());
            domain = urlInstance.removeEndIgnoreCase('.my.salesforce.com');
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        // system.debug('domain:' + domain);
        return domain;
    }
    
    /* class Schedule_SalesLeadEmail implements schedulable{
//한시간에 한번 salesleadEmail 실행
execute(SchedulableContext cx){
System.Schedule('Batch_SalesLeadEmail', '0 0 * * * ?', new Batch_SalesLeadEmail());
}

}  */
    
    public static List<IF_Log.InterfaceLog> doChat(String receiveSingleId1, String receiveSingleId2, String appcardContent){
        String APEX_CLASS   = 'OpportunityTrigger';
        String METHOD_NAME_145  = 'createKnoxChatRoomRequest';
        String INTERFACE_ID_145 = 'IF-145';
        String METHOD_NAME_146  = 'doKnoxChatRequest';
        String INTERFACE_ID_146 = 'IF-146';
        String METHOD_NAME_147  = 'getKnoxRegKeyValue';
        String INTERFACE_ID_147 = 'IF-147';
        String METHOD_NAME_148  = 'getChatSenderInfo';
        String INTERFACE_ID_148 = 'IF-148';
        String METHOD_NAME_149  = 'getChatReceiverInfo';
        String INTERFACE_ID_149 = 'IF-149';
        String METHOD_NAME_150  = 'getAES256Key';
        String INTERFACE_ID_150 = 'IF-150';
        
        Map<String,Object> ifResultMap = new Map<String, Object>();
        Map<String,Object> resMap = new Map<String,Object>();
        
        List<IF_Log.InterfaceLog> ifLogList = new List<IF_Log.InterfaceLog>();
        IF_Log.InterfaceLog ifLog;
        String guId = '';
        String jsonBody = '';
        IF_Callout call;
        HttpResponse res;
        
        String appcardContent1 = appcardContent;
        String appcardContent2 = appcardContent;
        
        Boolean isSandbox = Utils.getIsSandbox();
        
        
        try{
            //-------------------------------------------------------------------
            //[1]IF-147 reg
            call = new IF_Callout(INTERFACE_ID_147);
            guId = IF_KnoxChatSendController.generateUid();
            
            IF_KnoxChatSendController.InputClass_147 input_147 = new IF_KnoxChatSendController.InputClass_147();
            
            jsonBody = JSON.serialize(input_147);
            Integer deviceServerID = 0;
            
            ifResultMap = new Map<String, Object>();
            if(!Test.isRunningTest()){
                resMap = call.httpCallout(jsonBody, '');
                res = (HttpResponse)resMap.get('HttpResponse');
                ifResultMap.putAll((Map<String,Object>) JSON.deserializeUntyped(res.getBody()));
                deviceServerID = Integer.valueOf(ifResultMap.get('deviceServerID'));
            }
            else{
                deviceServerID = 0;
                resMap = new Map<String,Object>();
                ifResultMap = new Map<String, Object>();
            }
            
            
            
            //-------------------------------------------------------------------
            //[1]IF-149 loginId
            call = new IF_Callout(INTERFACE_ID_149);
            guId = IF_KnoxChatSendController.generateUid();
            
            //변경전 사용자에겐 안보내고, 변경후 사용자에게만 보내도록 함(2021.10.25)
            IF_KnoxChatSendController.InputClass_149_singleIdList receiver2 = new IF_KnoxChatSendController.InputClass_149_singleIdList();
            receiver2.singleID = receiveSingleId2;
            IF_KnoxChatSendController.InputClass_149 input_149 = new IF_KnoxChatSendController.InputClass_149();
            input_149.singleIdList = new List<IF_KnoxChatSendController.InputClass_149_singleIdList>();
            // input_149.singleIdList.add(receiver1);
            input_149.singleIdList.add(receiver2);
            input_149.deviceServerID = deviceServerID;//1000259729;
            
            jsonBody = JSON.serialize(input_149);
            ifResultMap = new Map<String, Object>();
            if(!Test.isRunningTest()){
                resMap = call.httpCallout(jsonBody, '');
                res = (HttpResponse)resMap.get('HttpResponse');
                ifResultMap.putAll((Map<String,Object>) JSON.deserializeUntyped(res.getBody()));
            }
            else{
                resMap = new Map<String,Object>();
                ifResultMap = new Map<String, Object>();
            }
            
            Map<String, Object> userSearchResult = new Map<String, Object>();
            List<Object> searchResultList = new List<Object>();
            // String IF_149_Result_receiverUserId1 = '';
            String IF_149_Result_receiverUserId2 = '';
            
            if(Test.isRunningTest()){
                IF_149_Result_receiverUserId2 = '851034545723543553';//wonjun98.lee
                userSearchResult = new Map<String,Object>();
                searchResultList = new List<Object>();
            }
            else{
                userSearchResult.putAll((Map<String, Object>)ifResultMap.get('userSearchResult'));            
                searchResultList = ((List<Object>)userSearchResult.get('searchResultList'));
                IF_149_Result_receiverUserId2 = String.valueOf(((Map<String, Object>)searchResultList.get(0)).get('userID'));                
            }
            
            
            //-------------------------------------------------------------------
            //[1]IF-150 getKeys
            call = new IF_Callout(INTERFACE_ID_150);
            guId = IF_KnoxChatSendController.generateUid();
            
            IF_KnoxChatSendController.InputClass_150 input_150 = new IF_KnoxChatSendController.InputClass_150();
            input_150.deviceServerID = deviceServerID;
            
            jsonBody = JSON.serialize(input_150);
            
            if(!Test.isRunningTest()){
                resMap = call.httpCallout(jsonBody, '');
            }
            
            String AES256Key = '';
            ifResultMap = new Map<String, Object>();
            if(Test.isRunningTest()){
                AES256Key = System.Label.COMM_LAB_AES256KEY;
                ifResultMap = new Map<String, Object>();
            }
            else{
                res = (HttpResponse)resMap.get('HttpResponse');
                ifResultMap.putAll((Map<String,Object>) JSON.deserializeUntyped(res.getBody()));
                AES256Key = String.valueOf(ifResultMap.get('key'));                
            }
            System.debug('CHLOG :: ' + AES256Key);
            
            
            
            //-------------------------------------------------------------------
            //[1]IF-145 creatChatRoom
            //chatType 5 : 1:1공지방
            call = new IF_Callout(INTERFACE_ID_145);
            String chatType = '5';
            String origin1 = '';
            String origin2 = '';
            String chatRoomId1 = '';
            String chatRoomId2 = '';
            String encoded1 = '';
            String encoded2 = '';
            
            guId = IF_KnoxChatSendController.generateUid();
            origin2 = '{'
                + '\'requestId\':\'' + guId +'\'' + ','
                + '\'chatType\':\'' + chatType +'\'' + ','
                + '\'receivers\':[' + String.valueOf(IF_149_Result_receiverUserId2) +']'
                + '}';            
            System.debug('CHLOG :: ORIGIN2 : ' + origin2);
            
            String jitterbitMessage = '';
            String decrpytedStr = '';
            Map<String,Object> resultMap145 = new Map<String,Object>();
            
            //두번째 수신자 용 1:1공지방 생성
            call = new IF_Callout(INTERFACE_ID_145);
            Blob encrypted2 = IF_KnoxChatSendController.doEncryptAndEncode(AES256Key, origin2);
            System.debug('CHLOG :: encrypted2 : ' + encrypted2);
            encoded2 = EncodingUtil.base64Encode(encrypted2);
            System.debug('CHLOG :: encoded2 : ' + encoded2);
            jsonBody = '("'+encoded2+'")';
            System.debug('CHLOG :: jsonBody : ' + jsonBody);

            if(!Test.isRunningTest()){
               // resMap = call.httpCallout(jsonBody, '');
                resMap = call.httpKnoxCallout(jsonBody, ''); // Divyam 28nov

                res = (HttpResponse)resMap.get('HttpResponse');
                jitterbitMessage = String.valueOf(resMap.get('Response'));
                decrpytedStr = IF_KnoxChatSendController.doDecryptAndDecode(AES256Key, EncodingUtil.base64Decode(jitterbitMessage));
                resultMap145 = (Map<String,Object>) JSON.deserializeUntyped(decrpytedStr);
                chatRoomId2 = String.valueOf(resultMap145.get('chatroomId'));
                appcardContent2 = appcardContent2.replace('XYZCHATROOMIDXYZ', chatRoomId2);
            }
            else{
                jitterbitMessage = 'abc';
                decrpytedStr = 'abc';
                chatRoomId2 = 'abc';
                appcardContent2 = '123';
                ifResultMap = new Map<String, Object>();
            }
            
            
            
            //-------------------------------------------------------------------
            //[1]IF-146 chatRequest
            
            //두번째 수신자 채팅 전송
            call = new IF_Callout(INTERFACE_ID_146);
            guId = IF_KnoxChatSendController.generateUid();
            
            encrypted2 = IF_KnoxChatSendController.doEncryptAndEncode(AES256Key, appcardContent2);
            encoded2 = EncodingUtil.base64Encode(encrypted2);
            jsonBody = '("'+encoded2+'")';
            
            if(!(Test.isRunningTest())){
                resMap = call.httpCallout(jsonBody, '');
                res = (HttpResponse)resMap.get('HttpResponse');                
            }
            else{
                resMap = new Map<String, Object>();
            }
            ifLog = new IF_Log.InterfaceLog(INTERFACE_ID_146, guId, APEX_CLASS, METHOD_NAME_146, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')));
            ifLogList.add(ifLog);
            
        } catch(Exception e) {
            System.debug('KnoxChat ex.getMessage : ' + e.getMessage());
        }
        
        return ifLogList;
    }
}