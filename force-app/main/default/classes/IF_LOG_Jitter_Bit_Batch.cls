/**
* @description       : Email Notification for jitter bit error 
* @author            : Kajal.c@samsung.com 
* @group             : My Sales (GDCI)
* @last modified on  : 07-24-2023
* @last modified by  : Kajal.c@samsung.com
* Modifications Log 
* Ver   Date         Author            		Modification
* 1.0   07-23-2023   Kajal.c@samsung.com    Error notification email sending function to quickly detect Jitterbit errors (Communication Error/Status code : 500) and send mail to jitterbit. Batch schedule for every 10 minutes interval (MySales-457)
**/

global class IF_LOG_Jitter_Bit_Batch Implements Database.Batchable<sObject>, Database.Stateful ,DataBase.AllowsCallouts, Schedulable  {
    private static final String INTERFACE_ID = 'IF_LOG_Jitter_Bit';
    private static final String APEX_CLASS   = 'IF_LOG_Jitter_Bit_Batch';
    private static IF_Log ifLog = new IF_Log();
    private static IF_Log.BatchLog batchLog = null;
    private static String guId = IF_Util.generateGuid();
    private static Boolean isSandbox = Utils.getIsSandbox();
    private List<KnoxEmail__c> KnoxEmailList = new List<KnoxEmail__c>();
    
    global Database.queryLocator start(Database.BatchableContext bc) {
        IF_Log ifStartLog = new IF_Log();
        IF_Log.BatchLog batchStartLog;
        batchStartLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Start', '', 0);
        ifStartLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' +  '(Start:' + BC.getJobId() + ')' + ' ####################');
        ifStartLog.createLog(batchStartLog);
        Integer lastMinutes = Integer.valueOf( System.Label.JITTERBIT_IFERROR_Last_Minutes);
        Datetime timeNow =  System.now();
        Datetime tenMinBefore = timeNow.addminutes(lastMinutes);
        String SOQL = 'Select id,name,RequestMessage__c,ErrorMessage__c,StatusCode__c,createddate,InterfaceId__c,InterfaceGuid__c from IF_Log__c where (StatusCode__c =\'E\' OR StatusCode__c = \'F\')    AND CreatedDate >=:tenMinBefore AND CreatedDAte <=: timeNow ';//ErrorMessage__c like \'%Communication Error%\' AND ErrorMessage__c like \'%StatusCode : 500%\'  
        return Database.getQueryLocator( SOQL );
        
    }
    
    global void execute( Database.BatchableContext bc, List<IF_Log__c> listRecords ) {       
        Map<String,Object> mailresult = new Map<String,Object>(); 
        System.debug('Entry CE');
        Employee__c senderEmployee = Utils.getLoginEmployeeData(UserInfo.getUserId());
        senderEmployee.EvMailAddr__c = 'chae_ho.yang@stage.samsung.com';
        if(!isSandbox){
            senderEmployee.EvMailAddr__c =   'mysales@samsung.com';
        }
        
        List<String> ccList = new List<String>();
        List<String> bccList = new List<String>();
        List<Map<String, Object>> efileList = new List<Map<String, Object>>();
        List<Map<String, String>> nfileList = new List<Map<String, String>>();
        List<String> toList = new List<String>(); 
        IF_Log log = new IF_Log();
        String logid = '';
        try{
        if(isSandbox){
            String str = System.label.JITTERBIT_IFERROR_MAIL_RECIPIENT_SANDBOX;
            if(str != 'null')
                toList = new List<String>(str.split(','));
        
        }
        if(!isSandbox){
            String st = System.label.JITTERBIT_IFERROR_MAIL_RECIPIENT;
            if(st != 'null')
                toList = new List<String>(st.split(','));
            //toList = new List<String>(System.label.WEEKLY_MAIL_RECIPIENT.split(','));
            //    toList.add(listScope[0].Email);
        }
        
        String strEmailTemp = '';
        String strEmail = '';
        EmailTemplate em = [SELECT Id,subject FROM EmailTemplate WHERE DeveloperName = 'Jitter_Bit_IF_Error'];
        Id templateId = em.Id;
        strEmail = [SELECT HtmlValue FROM EmailTemplate WHERE Id = :templateId].HtmlValue;
        String strTitle = '[mySales-Jitterbit] '; //em.subject;  //V1.1 added by Kajal
        Boolean foundLog = false;
        String  LogInfo = '';
        for(IF_Log__c Obj:listRecords){
            //V1.1 added IF Condition
            if(Obj.ErrorMessage__c != ''){
            if(Obj.ErrorMessage__c.ContainsIgnoreCase('Communication Error') || Obj.ErrorMessage__c.ContainsIgnoreCase('StatusCode : 500')){
            logid += Obj.InterfaceId__c + ', '; 
            LogInfo += 'Interface Id:'+Obj.InterfaceId__c+'<br/><br/>';
            LogInfo += 'Request Message:'+Obj.RequestMessage__c+'<br/><br/>';
            LogInfo += 'Error Message:'+Obj.ErrorMessage__c+'<br/><br/><hr style="border-top: 1px solid #333;"><br/>';
                //V1.1 added IF Condition
                if(foundLog == false){
                   strTitle += Obj.InterfaceId__c + ' ' + Obj.ErrorMessage__c;
                }
                foundLog =true;
            }
        }
        }
        datetime dt1 = Date.today();
        String sDate = String.valueOf(dt1.format('yyyy-MM-dd'));
        
        strEmail = strEmail.replace('{!DateValue}', sDate);
        strEmail = strEmail.replace('{!LogInfo}', LogInfo);
        if(foundLog){
        if(isSandbox){
            System.debug('Entry CE1'+foundLog);
            mailresult = OpportunityEmailAlertController.sendKnoxEmailMulti(senderEmployee, UserInfo.getUserID(), toList, ccList, bccList, strTitle, strEmail, efileList, nfileList);
                      if(mailresult.get('KnoxEmail') != null) KnoxEmailList.add((KnoxEmail__c)mailresult.get('KnoxEmail')); 
                     }
        else{
            if(!Test.isRunningTest()) mailresult = OpportunityEmailAlertController.sendKnoxEmailMulti(senderEmployee, UserInfo.getUserID(), toList, ccList, bccList, strTitle, strEmail, efileList, nfileList);
            if(mailresult.get('KnoxEmail') != null) KnoxEmailList.add((KnoxEmail__c)mailresult.get('KnoxEmail')); 
        }  
        }
        if(KnoxEmailList.size() > 0){
           system.debug('Knox email final : '+ KnoxEmailList[0].HtmlBody__c.length());
        	system.debug('Knox email final : '+ KnoxEmailList[0].HtmlBody__c); 
            for(KnoxEmail__c km : KnoxEmailList){
                if(km.HtmlBody__c.length() > 32000)
                	km.HtmlBody__c = km.HtmlBody__c.substring(0, 32000);
                //V1.1 added below IF Condition
                if(km.Name.length() > 80)
                	km.Name = km.Name.substring(0, 80);
            }
            if(KnoxEmailList.size() > 0){
            insert KnoxEmailList;
            }
            IF_Log.InterfaceLog ifLog;
            ifLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, 'execute', logid, '');           
            ID iFLogId = log.createLog2(ifLog);
            system.debug('iFLogId **' + iFLogId);   
        }
    }
         catch(Exception e){
        IF_Log__c logRec = new IF_Log__c(InterfaceId__c = 'IF_LOG_Jitter_Bit_Batch',InterfaceGuid__c = guid,ApexMethod__c = 'Execute',ApexName__c = 'IF_LOG_Jitter_Bit_Batch',StatusCode__c = 'E',LogType__c = 'Batch',LogText__c = logid,EndDatetime__c  = System.now(),StartDatetime__c = System.now(),ExceptionType__c = e.getTypeName(),ErrorMessage__c = e.getMessage(),StackTrace__c = e.getStackTraceString());
        
        insert logRec;    
        }
        
    }
    
    global void finish( Database.BatchableContext bc ) {
         IF_Log ifFinishLog = new IF_Log();
        IF_Log.BatchLog batchFinishLog;
        batchFinishLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Finish', '', 0);
        ifFinishLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + 'Finish'  + ' ####################');
        ifFinishLog.createLog(batchFinishLog);
    }
    public void execute(SchedulableContext SC){
        DataBase.executeBatch(new IF_LOG_Jitter_Bit_Batch());
    }
}