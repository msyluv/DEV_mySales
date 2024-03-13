global class Batch_POC_Mail implements DataBase.Batchable<SObject>, DataBase.AllowsCallouts, Schedulable {
    private static Boolean isSandbox = Utils.getIsSandbox();
    private List<IF_Log.InterfaceLog> ifLog = new List<IF_Log.InterfaceLog>();
    public static Map<String,Object> mailresult = new Map<String,Object>(); 
    private List<KnoxEmail__c> KnoxEmailList = new List<KnoxEmail__c>();
    private List<Id> listOpptyId = new List<Id>();
    
    private static Boolean bTest = false;	//운영 테스트를 위한 Flag 값.
    
    //T110,T120,T140,T640,T641,L1B0,L1E0,ZB01,ZB10
    private static Set<String> setSubsidiary = new Set<String>(System.Label.OPPTYACT_BO_SUBSIDIARY_LIST.split(','));  //자회사는 대상에서 제외
    
    //발송 제한된 이메일
    private static List<String> listRestrictedEmail = new List<String>{'mysales@samsung.com'};
    
    public Batch_POC_Mail(){
        
    }
    
    public Batch_POC_Mail(Boolean isMigData){
        if(isMigData){
            List<MigOppCode__c> migOppCdList = [
                SELECT Id 
                ,Name                 // ID
                ,OpportunityCode__c
                FROM   MigOppCode__c
                WHERE  Systemmodstamp = today
                AND    Send_Check__c  = false
                AND    InterfaceId__c = 'IF-075'
            ];
            
            Set<String> oppCdSet = new Set<String>();
            for( MigOppCode__c migOpp : migOppCdList){            
                listOpptyId.add(migOpp.Name);
            }
        }        
    }
    
    public DataBase.QueryLocator start(Database.BatchableContext BC){
        System.debug('### Batch_OpptyEmailController :: start');
         
        String queryString= '';
        Database.QueryLocator returnScope;
        
        System.debug('### Batch_OpptyEmailController :: start :: setSubsidiary = ' + setSubsidiary);

        List<Opportunity> listOppty = new List<Opportunity>();       
        if(listOpptyId.size() > 0){
            queryString += ' SELECT Id, Owner.FederationIdentifier, Name, OpportunityCode__c, Owner.Name, CloseDate , BusinessLevel__c, toLabel(StageName) Label_StageName FROM Opportunity ';
            queryString += ' WHERE RecordType.DeveloperName = \'HQ\' AND StageName IN (\'Z02\',\'Z03\',\'Z04\') AND CloseDate < TODAY  AND CompanyCode__c != : setSubsidiary and id =: listOpptyId and Owner.Email !=: listRestrictedEmail  and FirstCloseDate__c = null';
        }else{            
            queryString += ' SELECT Id, Owner.FederationIdentifier, Name, OpportunityCode__c, Owner.Name, CloseDate, BusinessLevel__c, toLabel(StageName) Label_StageName FROM Opportunity '; 
            queryString += ' WHERE RecordType.DeveloperName = \'HQ\' AND StageName IN (\'Z02\',\'Z03\',\'Z04\') AND CloseDate < TODAY  AND CompanyCode__c != : setSubsidiary and Owner.Email !=: listRestrictedEmail LIMIT 10';            
        }
 
        System.debug('### Batch_OpptyEmailController :: start :: listOppty size = ' + listOppty.size());
        
        returnScope = DataBase.getQueryLocator(queryString);
        System.debug('### Batch_OpptyEmailController :: start :: listOppty size = ' + returnScope);

        return returnScope;

    }
    
    public void execute(Database.BatchableContext BC, List<Opportunity> listScope){
        
        System.debug('### Batch_OpptyEmailController :: execute :: listScope = ' + listScope);
        
        Employee__c senderEmployee = Utils.getLoginEmployeeData(UserInfo.getUserId());
        senderEmployee.EvMailAddr__c = 'chae_ho.yang@stage.samsung.com';

        List<String> ccList = new List<String>();
        List<String> bccList = new List<String>();
        List<Map<String, Object>> efileList = new List<Map<String, Object>>();
        List<Map<String, String>> nfileList = new List<Map<String, String>>();
        
       
            List<String> toList = new List<String>(); 
        if(isSandbox){
        toList.add('anish.jain@stage.partner.samsung.com');
        toList.add('boram85.jung@stage.samsung.com');
        }
            
            String strEmailTemp = '';
            String strEmail = '';
            EmailTemplate em = [SELECT Id,subject FROM EmailTemplate WHERE DeveloperName = 'Email_POC'];
            Id templateId = em.Id;
            strEmail = [SELECT HtmlValue FROM EmailTemplate WHERE Id = :templateId].HtmlValue;
            String strTitle = 'Delayed POC Email';
            Id str;
            String usrMail = Label.POC_Users ;
            List<String> emUser = usrMail.split(',');
            
                for(Opportunity Opp : listScope){
                    String htmlvalue = '';
                    strEmailTemp = strEmail;
                    System.debug('Ani strEmailTemp : '+strEmailTemp);
                    htmlvalue  += '<tr style="background-color: #eeeeee;">' + '<td colspan="2" style="text-align: center;font-weight: bold;">'+Opp.Name+'</td>' + '<td style="font-weight: bold;">'+Opp.OpportunityCode__c+'</td>' + '<td style="text-align: right;font-weight: bold;">'+Opp.CloseDate+'</td>' + '</tr>';
                    strEmailTemp = strEmailTemp.replace('{!tableString1}', htmlvalue);
                    strEmailTemp = strEmailTemp.replace('{!tableString2}', htmlvalue);
                    strEmailTemp = strEmailTemp.replace('{!tableString3}', htmlvalue);
                    strEmailTemp = strEmailTemp.replace('{!tableString4}', htmlvalue);
                    strEmailTemp = strEmailTemp.replace('{!tableString5}', htmlvalue);
                    strEmailTemp = strEmailTemp.replace('{!tableString6}', htmlvalue);
                    strEmailTemp = strEmailTemp.replace('{!tableString7}', htmlvalue);
                    strEmailTemp = strEmailTemp.replace('{!tableString8}', htmlvalue);
                    System.debug('Ani strEmailTemp : '+strEmailTemp);
                    if(isSandbox){
                if(!Test.isRunningTest()) mailresult = OpportunityEmailAlertController.sendKnoxEmailMulti(senderEmployee, Opp.Id, toList, ccList, bccList, strTitle, strEmailTemp, efileList, nfileList);
                if(mailresult.get('INTERFACE_LOG') != null) ifLog.add((IF_Log.InterfaceLog)mailresult.get('INTERFACE_LOG'));
                if(mailresult.get('KnoxEmail') != null) KnoxEmailList.add((KnoxEmail__c)mailresult.get('KnoxEmail'));
                    }
                    else{
                        for(String usrStr: emUser){
                            if(usrStr == Opp.Owner.Email){
                                List<String> toListProd = new List<String>();
                                toListProd.add(usrStr);
                if(!Test.isRunningTest()) mailresult = OpportunityEmailAlertController.sendKnoxEmailMulti(senderEmployee, Opp.Id, toListProd, ccList, bccList, strTitle, strEmailTemp, efileList, nfileList);
                if(mailresult.get('INTERFACE_LOG') != null) ifLog.add((IF_Log.InterfaceLog)mailresult.get('INTERFACE_LOG'));
                if(mailresult.get('KnoxEmail') != null) KnoxEmailList.add((KnoxEmail__c)mailresult.get('KnoxEmail'));   
                            }
                        }
                    }
        }
    }
    
    public void finish(Database.BatchableContext BC){
        System.debug('### Batch_OpptyEmailController :: finish');        
        System.debug('### Batch_OpptyEmailController :: finish :: ifLog.size() : ' + ifLog.size());
        if(ifLog.size() > 0){
            IF_Log log = new IF_Log();
            log.createLog(ifLog);
        }
   
    }
    
    public void execute(SchedulableContext SC){
        DataBase.executeBatch(new Batch_OpptyEmailController(), 5);
    }    
    
   
}