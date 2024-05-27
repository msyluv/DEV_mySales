/**
 * @description       : 
 * @author            : chae_ho.yang@samsung.com
 * @group             : 
 * @last modified on  : 09-19-2023
 * @last modified by  : chae_ho.yang@samsung.com
 * * Modifications Log 
* Ver   Date         Author                   Modification
* 1.0   2024-05-01   vipul.k1@samsung.com    Initial Version (Added Error Handling in execute method.)
**/
global class Batch_OpptyLogiEmailController implements DataBase.Batchable<String>, DataBase.AllowsCallouts, Schedulable {
    private static Boolean isSandbox = Utils.getIsSandbox();
    private List<IF_Log.InterfaceLog> ifLog = new List<IF_Log.InterfaceLog>();
    public static Map<String,Object> mailresult = new Map<String,Object>(); 
    private List<KnoxEmail__c> KnoxEmailList = new List<KnoxEmail__c>();
    private List<Id> listOpptyId = new List<Id>();
    
    private static Boolean bTest = false;	//운영 테스트를 위한 Flag 값.
    private static Boolean cTest = false;    //chae_ho.yang test
    
    //T110,T120,T140,T640,T641,L1B0,L1E0,ZB01,ZB10
    private static Set<String> setSubsidiary = new Set<String>(System.Label.OPPTYACT_BO_SUBSIDIARY_LIST.split(','));  //자회사는 대상에서 제외
    
    //발송 제한된 이메일
    private static List<String> listRestrictedEmail = new List<String>{'mysales@samsung.com'};
    
    public Batch_OpptyLogiEmailController(){
        
    }
    
    public Batch_OpptyLogiEmailController(Boolean isMigData){
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
    
    //배치 대상의 모수는 BO가 아닌 CostCenter가 되야함.
    //그래야 부서장에 여러건의 메일 발송을 방지할수 있음.
    public List<String> start(Database.BatchableContext BC){
        System.debug('### Batch_OpptyLogiEmailController :: start');
        
        //SELECT Id, Name, OpportunityCode__c, Owner.Name, CloseDate, toLabel(StageName) FROM Opportunity WHERE RecordType.DeveloperName = 'HQ' AND StageName IN ('Z02','Z03','Z04') and CloseDate < TODAY  LIMIT 10
        String query = '';
        /*
        query += ' SELECT Id, Owner.FederationIdentifier, Name, OpportunityCode__c, Owner.Name, CloseDate, BusinessLevel__c, toLabel(StageName) Label_StageName FROM Opportunity ';
        query += ' WHERE RecordType.DeveloperName = \'HQ\' AND StageName IN (\'Z02\',\'Z03\',\'Z04\') AND CloseDate < TODAY AND CompanyCode__c = \'T100\' ';
        
        //TEST Code
        if(isSandbox) query += ' AND CreatedDate >= 2022-05-03T00:00:00.000+0000 ';
        //query = ' SELECT Id, Owner.FederationIdentifier, Name, OpportunityCode__c, Owner.Name, CloseDate, BusinessLevel__c, toLabel(StageName) Label_StageName FROM Opportunity LIMIT 1 ';
        
        System.debug('### Batch_OpptyLogiEmailController :: start :: query = ' + query);
		*/
        Set<String> setFederIds = new Set<String>();	//BO의 Owner Set
        Set<String> setCostCenter = new Set<String>();	//BO의 CostCenter Set        
        
        System.debug('### Batch_OpptyLogiEmailController :: start :: setSubsidiary = ' + setSubsidiary);
        //자회사 제외 : 'T110','T120','T140','T640','T641','L1B0','L1E0','ZB01','ZB10' 
        List<Opportunity> listOppty = new List<Opportunity>();       
        //V1.1 -> Add FirstCloseDate__c = null condition in below SOQL queries.(MySales 202)
        if(listOpptyId.size() > 0){
            listOppty = [SELECT Id, Owner.FederationIdentifier, Name, OpportunityCode__c, Owner.Name, CloseDate
                         , BusinessLevel__c, toLabel(StageName) Label_StageName
                         FROM Opportunity 
                         WHERE RecordType.DeveloperName in ('Logistics') AND StageName IN ('Z02','Z03','Z04') AND CloseDate < TODAY 
                         AND CompanyCode__c != : setSubsidiary and id =: listOpptyId and Owner.Email !=: listRestrictedEmail  and FirstCloseDate__c = null];
        }else{            
            listOppty = [SELECT Id, Owner.FederationIdentifier, Name, OpportunityCode__c, Owner.Name, CloseDate
                         , BusinessLevel__c, toLabel(StageName) Label_StageName
                         FROM Opportunity 
                         WHERE RecordType.DeveloperName in ('Logistics') AND StageName IN ('Z02','Z03','Z04') AND CloseDate < TODAY 
                         AND CompanyCode__c != : setSubsidiary and Owner.Email !=: listRestrictedEmail  AND FirstCloseDate__c = null];            
        }
            
            
        
        System.debug('### Batch_OpptyLogiEmailController :: start :: listOppty size = ' + listOppty.size());
        
        for(Opportunity rowOppty : listOppty){
            setFederIds.add(rowOppty.Owner.FederationIdentifier);
        }
        
        System.debug('### Batch_OpptyLogiEmailController :: start :: setFederIds size = ' + setFederIds.size());
        
        List<Employee__c> listEmployee= [SELECT Id, Name, EvEName__c, EvSdeptNM__c, EvKostl__c, EvMailAddr__c, EvUniqID__c, Status__c, EvMailReLanguage__c
                                         FROM Employee__c WHERE EvUniqID__c =:setFederIds];
        
        System.debug('### Batch_OpptyLogiEmailController :: start :: listEmployee size = ' + listEmployee.size());
        
        for(Employee__c rowEmp : listEmployee){
            setCostCenter.add(rowEmp.EvKostl__c);
        }
        
        System.debug('### Batch_OpptyLogiEmailController :: start :: setCostCenter size = ' + setCostCenter.size());
        
        return new List<String>(setCostCenter);
    }
    //Batch_SalesLeadEmail
    public void execute(Database.BatchableContext BC, List<String> listScope){
        try{
        System.debug('### Batch_OpptyLogiEmailController :: execute :: listScope = ' + listScope);
        
        Set<String> setFederIds = new Set<String>();	//BO의 Owner Set
        Set<String> setCostCenter = new Set<String>();	//BO의 CostCenter Set        
        
        List<Opportunity> listTargetOppty = new List<Opportunity>();
        
        if(listOpptyId.size() > 0){
            listTargetOppty = [SELECT Id, Owner.FederationIdentifier, Name, OpportunityCode__c, Owner.Name, CloseDate
                                        , BusinessLevel__c, toLabel(StageName) Label_StageName
                                        FROM Opportunity 
                                        WHERE RecordType.DeveloperName in ('Logistics') AND StageName IN ('Z02','Z03','Z04') AND CloseDate < TODAY 
                                        AND CompanyCode__c != : setSubsidiary AND Owner.EvKostl__c =:listScope and id =: listOpptyId and Owner.Email !=: listRestrictedEmail AND FirstCloseDate__c = null];
        }else{            
            listTargetOppty = [SELECT Id, Owner.FederationIdentifier, Name, OpportunityCode__c, Owner.Name, CloseDate
                                        , BusinessLevel__c, toLabel(StageName) Label_StageName
                                        FROM Opportunity 
                                        WHERE RecordType.DeveloperName in ('Logistics') AND StageName IN ('Z02','Z03','Z04') AND CloseDate < TODAY 
                                        AND CompanyCode__c != : setSubsidiary AND Owner.EvKostl__c =:listScope and Owner.Email !=: listRestrictedEmail AND FirstCloseDate__c = null];         
        }

        
        
        
        //EP Id.
        for(Opportunity rowOppty : listTargetOppty){
            setFederIds.add(rowOppty.Owner.FederationIdentifier);
        }        
        
        System.debug('### Batch_OpptyLogiEmailController :: execute :: setFederIds = ' + setFederIds);
        
        List<Employee__c> listEmployee= [SELECT Id, Name, EvEName__c, EvSdeptNM__c, EvKostl__c, EvMailAddr__c, EvUniqID__c, Status__c, EvMailReLanguage__c
                                         FROM Employee__c WHERE EvUniqID__c =:setFederIds];
        
        System.debug('### Batch_OpptyLogiEmailController :: execute :: listEmployee = ' + listEmployee);
        
        //EpId별 Employee 데이터 셋.
        Map<String, Employee__c> mapSalesRepEmployee = new Map<String, Employee__c>();	//영업대표용 Emp 정보
        Map<String, Employee__c> mapManagerEmployee = new Map<String, Employee__c>();	//부서장용 Emp 정보
        
        for(Employee__c rowEmp : listEmployee){
            if(String.isNotBlank(rowEmp.EvKostl__c)) setCostCenter.add(rowEmp.EvKostl__c);
            if(rowEmp.Status__c != 'R') mapSalesRepEmployee.put(rowEmp.EvUniqID__c, rowEmp);	//영업대표용
            mapManagerEmployee.put(rowEmp.EvUniqID__c, rowEmp);	//부서장용
        }
        
        System.debug('### Batch_OpptyLogiEmailController :: execute :: mapSalesRepEmployee = ' + mapSalesRepEmployee);
        
        List<CostCenter__c> listCostCenter = [SELECT Id, Name, DeptManager__c, DeptManager__r.EvMailReLanguage__c, DeptManager__r.EvMailAddr__c, DeptManagerEmail__c, CostCenter__c FROM CostCenter__c WHERE CostCenter__c =:setCostCenter];
        //CostCenter별 부서장 Email 데이터 셋.
        Map<String, ManagerInfo> mapCostCenter = new Map<String, ManagerInfo>();
        for(CostCenter__c rowCost : listCostCenter){
            if(String.isNotBlank(rowCost.DeptManagerEmail__c)){
                ManagerInfo rowManagerInfo = new ManagerInfo(); 
                rowManagerInfo.eMail = rowCost.DeptManager__r.EvMailAddr__c;
                rowManagerInfo.langCd = rowCost.DeptManager__r.EvMailReLanguage__c;
                mapCostCenter.put(rowCost.CostCenter__c, rowManagerInfo);
            }
        }        
        
        System.debug('### Batch_OpptyLogiEmailController :: execute :: mapCostCenter = ' + mapCostCenter);
        
        //TODO
        //1) EpId별 수주 예상일이 지난 BO를 Grouping. EvMailAddr__c.
        //2) CostCenter별 BO를 Grouping. EvKostl__c.
        Map<String, List<Opportunity>> mapEpidOppty = new Map<String, List<Opportunity>>();	//EpId별 BO Group.
        Map<String, List<Opportunity>> mapCostOppty = new Map<String, List<Opportunity>>();	//CostCenter별 BO Group.
        for(Opportunity rowOppty : listTargetOppty){
            Employee__c empSalesRep = mapSalesRepEmployee.get(rowOppty.Owner.FederationIdentifier);
            
            //임원정보가 존재하지 않으면 발송 대상에서 제외
            if(empSalesRep != null){
                //1) EpId별 BO Group. 영업대표는 Emp Status__c != 'R' 대상만 메일 발송.                               
                if(mapEpidOppty.get(rowOppty.Owner.FederationIdentifier) == null){
                    mapEpidOppty.put(rowOppty.Owner.FederationIdentifier, new List<Opportunity>{rowOppty});
                }else{        
                    List<Opportunity> listEpidOppty = mapEpidOppty.get(rowOppty.Owner.FederationIdentifier);
                    listEpidOppty.add(rowOppty);
                    mapEpidOppty.put(rowOppty.Owner.FederationIdentifier, listEpidOppty);
                } 
            } 
            
            Employee__c empManager = mapManagerEmployee.get(rowOppty.Owner.FederationIdentifier);
            
            System.debug('### Batch_OpptyLogiEmailController :: execute :: BO Id = ' + rowOppty.Id);
            System.debug('### Batch_OpptyLogiEmailController :: execute :: emp.EvKostl__c = ' + empManager.EvKostl__c); 
            
            //2) CostCenter별 BO Group. 부서장은 Emp Status__c != 'R' 상관 없이 메일 발송.
            if(mapCostOppty.get(empManager.EvKostl__c) == null){
                mapCostOppty.put(empManager.EvKostl__c, new List<Opportunity>{rowOppty});
            }else{
                List<Opportunity> listCostOppty = mapCostOppty.get(empManager.EvKostl__c);
                listCostOppty.add(rowOppty);
                mapCostOppty.put(empManager.EvKostl__c, listCostOppty);
            }          
        }
        
        System.debug('### Batch_OpptyLogiEmailController :: execute :: mapEpidOppty = ' + mapEpidOppty);
        System.debug('### Batch_OpptyLogiEmailController :: execute :: mapCostOppty = ' + mapCostOppty);
         
        //메일 발신자
        Employee__c senderEmployee = Utils.getLoginEmployeeData(UserInfo.getUserId());
        if(!isSandbox) senderEmployee.EvMailAddr__c = 'mysales@samsung.com';
        else senderEmployee.EvMailAddr__c = 'chae_ho.yang@stage.samsung.com';
        //else senderEmployee.EvMailAddr__c = 'oldman.sea@stage.samsung.com';
        
        //Dummy Data
        List<String> ccList = new List<String>();
        List<String> bccList = new List<String>();
        List<Map<String, Object>> efileList = new List<Map<String, Object>>();
        List<Map<String, String>> nfileList = new List<Map<String, String>>();
        
        //1) EpId별 BO Group에 메일 보내기.
        for(String strRow : mapEpidOppty.keySet()){
            
            List<String> toList = new List<String>();
            
            //toList.add('kj78.yu@stage.partner.samsung.com'); 	//테스트 메일 주소            
            
            //toList.add(mapSalesRepEmployee.get(strRow).EvMailAddr__c); 	//메일 주소
            // test 
            if (isSandbox) {
                toList.add('chae_ho.yang@stage.samsung.com');
            } else {
                toList.add('chae_ho.yang@samsung.com');
            }
            
            String langCd = (mapSalesRepEmployee.get(strRow).EvMailReLanguage__c == 'ko' ? 'ko':'en'); //사용자 언어. en. ko.
            
            //Email Template
            String strEmailTemp = expiredCloseDateTemplate(mapEpidOppty.get(strRow), langCd);
            String strTitle = '';
            if('ko'.equals(langCd)){
                strTitle = '수주 예상일 업데이트를 요청드립니다.';
            }else{
                strTitle = 'Request for Synchronizing Expected Close Date';
            }
            
            if(bTest){
                List<Opportunity> listOppty = mapEpidOppty.get(strRow);
                String strBody = String.valueOf(listOppty.size());
                
                KnoxEmail__c rowKnoxEmail = new KnoxEmail__c();
                rowKnoxEmail.Name = strTitle;
                rowKnoxEmail.HtmlBody__c = strBody;
                rowKnoxEmail.MailId__c = 'CLOSE_DATE_Logi_MAIL_SalesRep';
                rowKnoxEmail.Sender__c = senderEmployee.Id;
                rowKnoxEmail.Status__c = 'Send';
                String strToAddr = '';
                for(Integer i=0 ; i < toList.size() ; i++){
                    strToAddr += toList[i];
                    if(i < (toList.size()-1)) strToAddr += ',';
                }
                
                rowKnoxEmail.ToAddress__c = strToAddr;
                KnoxEmailList.add(rowKnoxEmail);
            }else{
                if(!Test.isRunningTest()) mailresult = OpportunityEmailAlertController.sendKnoxEmailMulti(senderEmployee, mapEpidOppty.get(strRow)[0].Id, toList, ccList, bccList, strTitle, strEmailTemp, efileList, nfileList);
                if(mailresult.get('INTERFACE_LOG') != null) ifLog.add((IF_Log.InterfaceLog)mailresult.get('INTERFACE_LOG'));
                if(mailresult.get('KnoxEmail') != null) KnoxEmailList.add((KnoxEmail__c)mailresult.get('KnoxEmail'));
            }
        } 
        
        //2) CostCenter별 BO Group 메일 보내기.
        for(String strRow : mapCostOppty.keySet()){
            
            if(mapCostCenter.get(strRow) != null){	//부서장 정보가 존재하면 메일 발송.
                List<String> toList = new List<String>();          
            
                
                //toList.add('kj78.yu@stage.partner.samsung.com'); 	//테스트 메일 주소                
                //toList.add(mapCostCenter.get(strRow).eMail); 	//메일 주소   
                //chae_ho.yang test
                if (isSandbox) {
                    toList.add('chae_ho.yang@stage.samsung.com');
                } else {
                    toList.add('chae_ho.yang@samsung.com');
                }                 
                
                System.debug('### Batch_OpptyLogiEmailController :: execute :: strRow = ' + strRow);
                System.debug('### Batch_OpptyLogiEmailController :: execute :: langCd = ' + mapCostCenter.get(strRow));
                
                String langCd = (mapCostCenter.get(strRow).langCd == 'ko' ? 'ko':'en'); //사용자 언어. en. ko.
                
                //TODO : land CD 설정하기.
                String strEmailTemp = expiredCloseDateTemplate(mapCostOppty.get(strRow), langCd);
                String strTitle = '';
                if('ko'.equals(langCd)){
                    strTitle = '수주 예상일 업데이트를 요청드립니다.';
                }else{
                    strTitle = 'Request for Synchronizing Expected Close Date';
                }
                
                if(bTest){
                    List<Opportunity> listOppty = mapCostOppty.get(strRow);
                    String strBody = String.valueOf(listOppty.size());
                        
                    KnoxEmail__c rowKnoxEmail = new KnoxEmail__c();
                    rowKnoxEmail.Name = strTitle;
                    rowKnoxEmail.HtmlBody__c = strBody;
                    rowKnoxEmail.MailId__c = 'CLOSE_DATE_Logi_MAIL_Manager';
                    rowKnoxEmail.Sender__c = senderEmployee.Id;
                    rowKnoxEmail.Status__c = 'Send';
                    String strToAddr = '';
                    for(Integer i=0 ; i < toList.size() ; i++){
                        strToAddr += toList[i];
                        if(i < (toList.size()-1)) strToAddr += ',';
                    }
                    rowKnoxEmail.ToAddress__c = strToAddr;
                    KnoxEmailList.add(rowKnoxEmail);
                }else{                
                    if(!Test.isRunningTest()) mailresult = OpportunityEmailAlertController.sendKnoxEmailMulti(senderEmployee, mapCostOppty.get(strRow)[0].Id, toList, ccList, bccList, strTitle, strEmailTemp, efileList, nfileList);
                    if(mailresult.get('INTERFACE_LOG') != null) ifLog.add((IF_Log.InterfaceLog)mailresult.get('INTERFACE_LOG'));
                    if(mailresult.get('KnoxEmail') != null) KnoxEmailList.add((KnoxEmail__c)mailresult.get('KnoxEmail')); 
                }
            }            
        } 
        
        System.debug('### Batch_OpptyLogiEmailController :: execute :: ifLog.size() : ' + ifLog.size());
        System.debug('### Batch_OpptyLogiEmailController :: execute :: KnoxEmailList.size() : ' + KnoxEmailList.size());
        }
        catch(Exception e){ // Added By Vipul Start v-1.0
             List<IF_Log.InterfaceLog> ifLogList = new  List<IF_Log.InterfaceLog>();
             ifLogList.add(new IF_Log.InterfaceLog('Batch_OpptyLogiEmailController', IF_Util.generateGuid(), 'Batch_OpptyLogiEmailController', 'Execute', '', '',e));
             new IF_Log().createLog(ifLogList); // Added By Vipul End v-1.0
        }
    }
    
    public void finish(Database.BatchableContext BC){
        System.debug('### Batch_OpptyLogiEmailController :: finish');        
        System.debug('### Batch_OpptyLogiEmailController :: finish :: ifLog.size() : ' + ifLog.size());
        if(ifLog.size() > 0){
            IF_Log log = new IF_Log();
            log.createLog(ifLog);
        }
        
        System.debug('### Batch_OpptyLogiEmailController :: finish :: KnoxEmailList.size() : ' + KnoxEmailList.size());
        if(KnoxEmailList.size() > 0) insert KnoxEmailList;
    }
    
    // 스케줄 호출
    public void execute(SchedulableContext SC){
        DataBase.executeBatch(new Batch_OpptyLogiEmailController(), 5);
    }    
    
    //langCD : en. ko.
    private String expiredCloseDateTemplate(List<Opportunity> listOppty, String langCd){
        
        DateTime dToday = Datetime.now();
        String dateOutput = dToday.format('yyyy.MM.dd');
              
        String htmlTemp = '';
        
        htmlTemp += '<head>';
        htmlTemp += '<meta charset="UTF-8">';
        htmlTemp += '<title>Samsung SDS</title>';
        htmlTemp += '<meta http-equiv="X-UA-Compatible" content="IE=edge">';
        htmlTemp += '<style type="text/css">';
        htmlTemp += '@charset "utf-8";';
        htmlTemp += '';
        htmlTemp += '.mailing_wrap{width:980px; border:solid 1px #a3a9b1;}';
        htmlTemp += '.mailing_wrap .tit_wrap{height:55px;';
        htmlTemp += 'line-height:55px; background-color: #1c2637;';
        htmlTemp += 'background-image: -webkit-linear-gradient(left, #112860, #145675);';
        htmlTemp += 'background-image: -moz-linear-gradient(left, #112860, #145675);';
        htmlTemp += 'background-image: -o-linear-gradient(left, #112860, #145675);';
        htmlTemp += 'background-image: -ms-linear-gradient(left, #112860, #145675);';
        htmlTemp += 'background-image: linear-gradient(to right, #112860, #145675);}';
        htmlTemp += '.mailing_wrap .tit_wrap h1{float:left; margin:0 10px 0 40px; font-size:20px; color:#fff;}';
        htmlTemp += '.mailing_wrap .tit_wrap h2{float:left; font-size:20px; color:#fff;}';
        htmlTemp += '.mailing_wrap .tit_wrap span{float:right; margin:0 40px 0 0; color:#fff;}';
        htmlTemp += '.mailing_wrap .cont_wrap{padding:35px 40px;}';
        htmlTemp += '.mailing_wrap .cont_wrap h3{font-size:24px; text-align:center; margin:0 0 35px 0;}';
        htmlTemp += '.mailing_wrap .desc{line-height:1.5;}';
        htmlTemp += '.mailing_wrap .desc_s{font-size:11px; line-height:1.4; color:#666;}';
        htmlTemp += '.mailing_wrap .desc_s_blue{font-size:11px; line-height:1.4; color:#597385; text-align:right;}';
        htmlTemp += '.mailing_wrap .box_info{background-color:#f2f5f9; padding:20px; color:#666; line-height:1.5; }';
        htmlTemp += '.mailing_wrap';
        htmlTemp += '.box_info strong.tit{display:block; margin:0 0 10px 0; font-size:15px; color:#325179; }';
        htmlTemp += '.mailing_wrap .box_info span.c_orange{font-weight:bold; color:#ff575a;}';
        htmlTemp += '.mailing_wrap .list_type_dot li{padding:1px 0 2px 5px;}';
        htmlTemp += '.mailing_wrap .list_type_dot li a:hover{text-decoration:underline;}';
        htmlTemp += '.mailing_wrap .link_line{text-decoration:underline; color:#4d6da7;}';
        htmlTemp += '.mailing_wrap .link_line:hover{text-decoration:underline;}';
        htmlTemp += '';
        htmlTemp += '.mailing_wrap .tbl_tit{margin:35px 0 10px; font-weight:bold; font-size:16px; color:#333;}';
        htmlTemp += '.mailing_wrap table th, table td{vertical-align:top; font-size:12px;}';
        htmlTemp += '.mailing_wrap table td{position:relative;}';
        htmlTemp += '.mailing_wrap table td a:hover{text-decoration:underline;}';
        htmlTemp += '.mailing_wrap table td.tit a{display:block; overflow:hidden; white-space:nowrap;';
        htmlTemp += 'text-overflow:ellipsis; -o-text-overflow:ellipsis;}';
        htmlTemp += '.mailing_wrap table td.a_l{text-align:left; padding:0 0 0 10px;}';
        htmlTemp += '.mailing_wrap table td.a_c{text-align:center; padding:0;}';
        htmlTemp += '.mailing_wrap table td.a_r{text-align:right; padding:0 10px 0 0;}';
        htmlTemp += '.mailing_wrap table td.a_m{vertical-align:middle;}';
        htmlTemp += '.mailing_wrap table td.date{text-align:right; color:#93a2b2;}';
        htmlTemp += '.mailing_wrap table td.c_gray{color:#838383;}';
        htmlTemp += '.mailing_wrap table td.c_blue{color:#597385;}';
        htmlTemp += '.mailing_wrap table td.c_sky{color:#7eaad4;}';
        htmlTemp += '.mailing_wrap table th.f_normal{font-weight:normal;}';
        htmlTemp += '.mailing_wrap table textarea{width:100%; resize:none; line-height:1.5;}';
        htmlTemp += '.mailing_wrap table button{display:inline-block; height:20px; line-height:18px; padding:0 5px;';
        htmlTemp += 'border-radius:4px; background-color:#eef1f5;';
        htmlTemp += 'border:solid 1px #cbd0d7; color:#606772; text-decoration:none;}';
        htmlTemp += '.mailing_wrap table button:hover{background-color:#eef1f5;';
        htmlTemp += 'border:solid 1px #94b9de; color:#1584ef;}';
        htmlTemp += '.mailing_wrap table button:active{background-color:#81baf2;';
        htmlTemp += 'border:solid 1px #1584ef; color:#fff;}';
        htmlTemp += '.mailing_wrap table button:disabled{background-color:#f9fafb;';
        htmlTemp += 'border:solid 1px #eff0f2; color:#cdcdce ;}';
        htmlTemp += '.mailing_wrap .tbl_type01 table{border:solid 1px #a3a9b1;}';
        htmlTemp += '.mailing_wrap';
        htmlTemp += '.tbl_type01 table tr th,';
        htmlTemp += '.mailing_wrap .tbl_type01 table tr td{border-top:dashed 1px #cfd3d7;}';
        htmlTemp += '.mailing_wrap .tbl_type01 table tr.noline th,';
        htmlTemp += '.mailing_wrap .tbl_type01 table tr.noline td{border-top:0 none;}';
        htmlTemp += '.mailing_wrap .tbl_type01 table th{width:300px;';
        htmlTemp += 'vertical-align:top; padding:13px 0 12px 20px;';
        htmlTemp += 'text-align:left; color:#4d6da7;}';
        htmlTemp += '.mailing_wrap .tbl_type01 table td{padding:12px 20px 10px 0;';
        htmlTemp += 'line-height:1.4;}';
        htmlTemp += '.mailing_wrap .tbl_type02 table{border-spacing:0;';
        htmlTemp += 'border:solid 1px #a3a9b1; border-right:0;}';
        htmlTemp += '.mailing_wrap .tbl_type02 table th{padding:6px 10px;';
        htmlTemp += 'vertical-align:middle;';
        htmlTemp += 'background-color:#fafafa; border-bottom:solid 1px #a3a9b1;';
        htmlTemp += 'border-right:solid 1px #cfd3d7; color:#597385;}';
        htmlTemp += '.mailing_wrap .tbl_type02 table td{padding:8px 10px 6px;';
        htmlTemp += 'border-top:solid 1px #cfd3d7; border-right:solid 1px #cfd3d7; vertical-align:middle;}';
        htmlTemp += '.mailing_wrap .tbl_type02 table td span{color:#8c8c8c;}';
        htmlTemp += '.mailing_wrap .tbl_type02 table tr.select td{background-color:#dcedfd;}';
        htmlTemp += '.mailing_wrap .tbl_type02 .scroll{border-bottom:solid 1px #a3a9b1;}';
        htmlTemp += '.mailing_wrap .tbl_type02 .scroll table{border-top:0;}';
        htmlTemp += '.mailing_wrap .tbl_type02 table tr td input[type="checkbox"]{margin:0;}';
        htmlTemp += '.mailing_wrap .tbl_type02 table tr.total_sub td{border-top:solid 1px #a3a9b1;';
        htmlTemp += 'background-color:#f2f5f9; font-weight:bold; color:#4d6da7;}';
        htmlTemp += '.mailing_wrap .tbl_type02 table tr.total td{background-color:#e6ebf3;';
        htmlTemp += 'font-weight:bold; color:#325179;}';
        htmlTemp += '.mailing_wrap .tbl_type02 table tr.tr_line td{border-bottom:solid 1px #a3a9b1;}';
        htmlTemp += '.mailing_wrap';
        htmlTemp += '.tbl_type02 table .noline td, .mailing_wrap .tbl_type02 table .noline th{border-top:0 none;}';
        htmlTemp += '.mailing_wrap .tbl_type02 table .noline{border-bottom:0 none;}';
        htmlTemp += '.mailing_wrap .tbl_type02 table .total_sub.noline td{border-top:0 none;}';
        htmlTemp += '.mailing_wrap .link_wrap{padding:15px 20px; background-color:#f8f9fa;}';
        htmlTemp += '.mailing_wrap .link_wrap strong{display:inline-block; padding:5px 0 0 0; color:#325179;}';
        htmlTemp += '.mailing_wrap .link_wrap .link_go{float:right; display:inline-block; height:22px;';
        htmlTemp += 'line-height:22px; padding:0 12px 0 8px; border-radius:4px;';
        htmlTemp += 'text-decoration:none; border:solid 1px #cbd0d7; color:#606772;}';
        htmlTemp += '.mailing_wrap .link_wrap .link_go:hover{background-color:#eef1f5;';
        htmlTemp += 'border:solid 1px #94b9de; color:#1584ef;}';
        htmlTemp += '.mailing_wrap .link_wrap .link_go:active{background-color:#81baf2;';
        htmlTemp += 'border:solid 1px #1584ef; color:#fff;}';
        htmlTemp += '.mailing_wrap .link_wrap .link_go:disabled{background-color:#f9fafb;';
        htmlTemp += 'border:solid 1px #eff0f2; color:#cdcdce ;}';
        htmlTemp += '.mailing_wrap .link_multi_wrap table{border-collapse:collapse;}';
        htmlTemp += '.mailing_wrap .link_multi_wrap table th{width:140px; vertical-align:middle;';
        htmlTemp += 'text-align:center; color:#325179; background-color:#e6ebf3;}';
        htmlTemp += '.mailing_wrap .link_multi_wrap table td{padding:15px 20px 10px;';
        htmlTemp += 'background-color:#f2f5f9;}';
        htmlTemp += '.mailing_wrap .link_multi_wrap table td a{display:inline-block;';
        htmlTemp += 'margin:0 20px 5px 0; text-decoration:underline; color:#4d6da7;}';
        htmlTemp += '.mailing_wrap .footer_wrap{padding:10px 0; text-align:center;';
        htmlTemp += 'background-color:#eef1f5;}';
        htmlTemp += '';
        htmlTemp += '/* RESET */';
        htmlTemp += 'html,body {width:100%; height:100%; }';
        htmlTemp += 'html {overflow-y:scroll;}';
        htmlTemp += 'body{background-color:#fff;}';
        htmlTemp += 'body,div,dl,dt,dd,ul,ol,li,h1,h2,h3,h4,h5,form,fieldset,p,button';
        htmlTemp += '{margin:0; padding:0;}';
        htmlTemp += 'body,h1,h2,h3,h4,input,button {font-family:arial,\'##\',Dotum,';
        htmlTemp += 'Helvetica, Sans-serif; font-size:12px; color:#000;}';
        htmlTemp += 'img,fieldset,iframe {border:0 none;}';
        htmlTemp += 'li {list-style:none;}';
        htmlTemp += 'input,select,button {vertical-align:middle;}';
        htmlTemp += 'img {vertical-align:top;}';
        htmlTemp += 'i,em,address {font-style:normal;}';
        htmlTemp += 'label,button {cursor:pointer;}';
        htmlTemp += 'button {margin:0; padding:0;}';
        htmlTemp += 'label input{margin:-3px 0 0 0;}';
        htmlTemp += 'a {color:#000; text-decoration:none;}';
        htmlTemp += 'a:hover {text-decoration:none;}';
        htmlTemp += 'hr {display:none;}';
        htmlTemp += 'table {width:100%; table-layout:fixed; border-spacing:0;}';
        htmlTemp += '';
        htmlTemp += 'legend,.blind,caption {display:block; overflow:hidden; position:absolute; top:-1000em; left:0;}';
        htmlTemp += '.ellipsis {overflow:hidden; white-space:nowrap;';
        htmlTemp += 'text-overflow:ellipsis; -o-text-overflow:ellipsis;}';
        htmlTemp += '';
        htmlTemp += 'input[type=text], input[type=password]{height:18px; line-height:18px; padding:2px 0 2px 4px;';
        htmlTemp += 'font-size:12px; border:1px solid #bababa; border-radius:3px;';
        htmlTemp += 'font-family:\'##\',Dotum, arial,Helvetica, Sans-serif;}';
        htmlTemp += 'input[type="radio"], input[type="checkbox"]{margin:0; padding:0;}';
        htmlTemp += 'select{height:22px; border:1px solid #bababa; border-radius:3px;}';
        htmlTemp += '';
        htmlTemp += '/* */';
        htmlTemp += '.fL { float:left;}';
        htmlTemp += '.fR { float:right;}';
        htmlTemp += '.a_left{ text-align:left;}';
        htmlTemp += '.a_center{ text-align:center;}';
        htmlTemp += '.a_right{ text-align:right;}';
        htmlTemp += '';
        htmlTemp += '.clear {clear:both;}';
        htmlTemp += '.fix { zoom:1;}';
        htmlTemp += '.fix:after { content:"."; display:block; font-size:0; height:0px; line-height:0; clear:both;}';
        htmlTemp += '';
        htmlTemp += '.frm_small{width:65px;}';
        htmlTemp += '.frm_basic{width:135px;}';
        htmlTemp += '.frm_double{width:170px;}';
        htmlTemp += '.frm_wide {width:200px;}';
        htmlTemp += '.frm_widest{width:310px;}';
        htmlTemp += '.frm_max{width:95%;}';
        htmlTemp += '';
        htmlTemp += '.space_mt0{margin-top:0px;}';
        htmlTemp += '.space_mt5{margin-top:5px;}';
        htmlTemp += '.space_mt10{margin-top:10px;}';
        htmlTemp += '.space_mt15{margin-top:15px;}';
        htmlTemp += '.space_mt20{margin-top:20px;}';
        htmlTemp += '.space_mt25{margin-top:25px;}';
        htmlTemp += '.space_mt30{margin-top:30px;}';
        htmlTemp += '.space_mt35{margin-top:35px;}';
        htmlTemp += '.space_mt40{margin-top:40px;}';
        htmlTemp += '.space_mt45{margin-top:45px;}';
        htmlTemp += '.space_mt50{margin-top:50px;}';
        htmlTemp += '';
        htmlTemp += 'select{padding:2px 0 2px 5px;}';
        htmlTemp += '';
        htmlTemp += '.scroll{overflow-y:auto;}';
        htmlTemp += '';
        htmlTemp += '/* layout */';
        htmlTemp += '.body_wrap{width:900px;}';
        htmlTemp += '.body_wrap .tit_wrap{padding:35px 0;}';
        htmlTemp += '.body_wrap .tit_wrap h1{text-align:center; font-size:24px; color:#000;}';
        htmlTemp += '.body_wrap .cont_wrap{padding:35px 40px;}';
        htmlTemp += '.body_wrap .cont_wrap h3{font-size:24px; text-align:center; margin:0 0 35px 0;}';
        htmlTemp += '';
        htmlTemp += '/* module */';
        htmlTemp += '.body_wrap .tit_con{margin:35px 0 10px; font-size:16px; color:#333;}';
        htmlTemp += '.body_wrap .desc{line-height:1.5;}';
        htmlTemp += '.body_wrap .desc_s{font-size:11px; line-height:1.4; color:#666;}';
        htmlTemp += '.body_wrap .desc_s_blue{font-size:11px; line-height:1.4; color:#597385; text-align:right;}';
        htmlTemp += '';
        htmlTemp += '.body_wrap .box_info{background-color:#f2f5f9; padding:20px; color:#666; line-height:1.5; }';
        htmlTemp += '.body_wrap .box_info strong.tit{display:block; margin:0 0 10px 0; padding:0 0 0 18px;';
        htmlTemp += 'font-size:15px; color:#325179;';
        htmlTemp += 'background:url(\'http://iedh1201.sds.samsung.net:50000/crm/images/icon_approval.png\') no-repeat 0 5px; }';
        htmlTemp += '.body_wrap .box_info strong.info{display:block; margin:0 0 10px 0; padding:0 0 0 18px;';
        htmlTemp += 'font-size:15px; color:#325179;';
        htmlTemp += 'background:url(\'http://iedh1201.sds.samsung.net:50000/crm/images/icon_approval_info.png\') no-repeat 0 3px; }';
        htmlTemp += '.body_wrap .box_info span.c_orange{font-weight:bold; color:#ff575a;}';
        htmlTemp += '.body_wrap .list_type_dot li{ padding:1px 10px 2px;';
        htmlTemp += 'background:url(\'http://iedh1201.sds.samsung.net:50000/crm/images/icon_dot.png\') no-repeat 0 9px;}';
        htmlTemp += '.body_wrap .list_type_dot li a:hover{text-decoration:underline;}';
        htmlTemp += '';
        htmlTemp += '.body_wrap .link_line{text-decoration:underline; color:#4d6da7;}';
        htmlTemp += '.body_wrap .link_line:hover{text-decoration:underline;}';
        htmlTemp += '';
        htmlTemp += '/*table*/';
        htmlTemp += '.body_wrap table th, table td{vertical-align:top;}';
        htmlTemp += '.body_wrap table td{position:relative;}';
        htmlTemp += '.body_wrap table td > a:hover{text-decoration:underline;}';
        htmlTemp += '.body_wrap table td.tit a{display:block; overflow:hidden; white-space:nowrap;';
        htmlTemp += 'text-overflow:ellipsis; -o-text-overflow:ellipsis;}';
        htmlTemp += '.body_wrap table td.a_l{text-align:left; padding:0 0 0 10px;}';
        htmlTemp += '.body_wrap table td.a_c{text-align:center; padding:0;}';
        htmlTemp += '.body_wrap table td.a_r{text-align:right; padding:0 10px 0 0;}';
        htmlTemp += '.body_wrap table td.a_t{vertical-align:top;}';
        htmlTemp += '.body_wrap table td.date{text-align:right; color:#93a2b2;}';
        htmlTemp += '.body_wrap table td.c_gray{color:#838383;}';
        htmlTemp += '.body_wrap table td.c_blue{color:#597385;}';
        htmlTemp += '.body_wrap table td.c_sky{color:#7eaad4;}';
        htmlTemp += '.body_wrap table th.f_normal{font-weight:normal;}';
        htmlTemp += '';
        htmlTemp += '.body_wrap';
        htmlTemp += '.tbl_type01 > table{border-top:solid 1px #a3a9b1;';
        htmlTemp += 'border-left:solid 1px #a3a9b1; border-right:solid 1px #a3a9b1;}';
        htmlTemp += '.body_wrap';
        htmlTemp += '.tbl_type01 table tr';
        htmlTemp += '{background:url(\'http://iedh1201.sds.samsung.net:50000/crm/images/bg_tbl_dash.png\') repeat-x bottom;}';
        htmlTemp += '.body_wrap .tbl_type01 table tr:last-child{background:none;}';
        htmlTemp += '.body_wrap .tbl_type01 table tr:last-child th, .body_wrap .tbl_type01 table tr:last-child td';
        htmlTemp += '{border-bottom:solid 1px #a3a9b1;}';
        htmlTemp += '.body_wrap .tbl_type01 table th';
        htmlTemp += '{width:140px; vertical-align:top; padding:13px 0 12px 20px; text-align:left; color:#4d6da7;}';
        htmlTemp += '.body_wrap .tbl_type01 table td{padding:12px 20px 10px 0; line-height:1.4;}';
        htmlTemp += '';
        htmlTemp += '.body_wrap .tbl_type02 > table{border-top:solid 1px #a3a9b1; border-bottom:solid 1px #a3a9b1;';
        htmlTemp += 'border-left:solid 1px #cfd3d7; border-right:solid 1px #cfd3d7;}';
        htmlTemp += '.body_wrap .tbl_type02 table th{padding:6px 10px; vertical-align:middle;';
        htmlTemp += 'background-color:#fafafa; border-bottom:solid 1px #a3a9b1;';
        htmlTemp += 'border-right:solid 1px #cfd3d7; color:#597385;}';
        htmlTemp += '.body_wrap .tbl_type02 table td{padding:8px 10px 6px;';
        htmlTemp += 'border-right:solid 1px #cfd3d7; border-bottom:solid 1px #cfd3d7;}';
        htmlTemp += '.body_wrap .tbl_type02 table td span{color:#8c8c8c;}';
        htmlTemp += '.body_wrap .tbl_type02 table tr th:last-child{border-right:0;}';
        htmlTemp += '.body_wrap .tbl_type02 table tr td:last-child{border-right:0;}';
        htmlTemp += '.body_wrap .tbl_type02 table tr:last-child td{border-bottom:0;}';
        htmlTemp += '.body_wrap .tbl_type02 table tr.select td{background-color:#dcedfd;}';
        htmlTemp += '.body_wrap .tbl_type02 .scroll{border-bottom:solid 1px #a3a9b1;}';
        htmlTemp += '.body_wrap .tbl_type02 .scroll table{border-top:0;}';
        htmlTemp += '.body_wrap .tbl_type02 table tr td input[type="checkbox"]{margin:0;}';
        htmlTemp += '.body_wrap .tbl_type02 table tr.total_sub td{border-bottom:solid 1px #a3a9b1;';
        htmlTemp += 'background-color:#f2f5f9; font-weight:bold; color:#4d6da7;}';
        htmlTemp += '.body_wrap .tbl_type02 table tr.total td{background-color:#e6ebf3; font-weight:bold; color:#325179;}';
        htmlTemp += '.body_wrap .tbl_type02 table tr.tr_line td{border-bottom:solid 1px #a3a9b1;}';
        htmlTemp += '.body_wrap .tbl_type02 table .noline{border-bottom:0 none;}';
        htmlTemp += '.body_wrap .tbl_type02 table .total_sub.noline td{border-bottom:0 none;}';
        htmlTemp += '';
        htmlTemp += '.body_wrap .link_wrap{padding:15px 20px; background-color:#f8f9fa;}';
        htmlTemp += '.body_wrap .link_wrap strong{display:inline-block; padding:5px 0 0 0; color:#325179;}';
        htmlTemp += '.body_wrap .link_wrap .link_go{float:right; display:inline-block; height:22px; line-height:22px;';
        htmlTemp += 'padding:0 12px 0 8px; border-radius:4px; text-decoration:none;';
        htmlTemp += 'background:#eef1f5 url(\'http://iedh1201.sds.samsung.net:50000/crm/images/icon_link_arrow.png\') no-repeat right;';
        htmlTemp += 'border:solid 1px #cbd0d7; color:#606772;}';
        htmlTemp += '.body_wrap .link_wrap .link_go:hover{background-color:#eef1f5;';
        htmlTemp += 'border:solid 1px #94b9de; color:#1584ef;}';
        htmlTemp += '.body_wrap .link_wrap .link_go:active{background-color:#81baf2;';
        htmlTemp += 'border:solid 1px #1584ef; color:#fff;}';
        htmlTemp += '.body_wrap .link_wrap .link_go:disabled{background-color:#f9fafb;';
        htmlTemp += 'border:solid 1px #eff0f2; color:#cdcdce ;}';
        htmlTemp += '.body_wrap .link_multi_wrap table th{width:140px; vertical-align:middle;';
        htmlTemp += 'text-align:center; color:#325179; background-color:#e6ebf3;}';
        htmlTemp += '.body_wrap .link_multi_wrap table td{padding:15px 20px 10px; background-color:#f2f5f9;}';
        htmlTemp += '.body_wrap .link_multi_wrap table td > a{display:inline-block;';
        htmlTemp += 'margin:0 20px 5px 0; text-decoration:underline; color:#4d6da7;}';
        htmlTemp += '';
        htmlTemp += '.td_txtIndent{padding-left:17px; text-indent: -17px; color: #000 !important; display: block; margin: 5px 0}';
        htmlTemp += '.td_txtIndent:first-letter{font-weight: bold;}';
        htmlTemp += '</style>';

        htmlTemp += '</head>';
        htmlTemp += '<body>';
        htmlTemp += '<div  class="mailing_wrap">';
        htmlTemp += '<div class="tit_wrap">';
        htmlTemp += '<h1>SAMSUNG SDS</h1>';
        htmlTemp += '<h2>mySales</h2>';
        htmlTemp += '</div>';
        htmlTemp += '<p><br></p>';
        htmlTemp += '<p><br></p>';
        htmlTemp += '<div class="cont_wrap">'; 
		
		
        if('ko'.equals(langCd)){
            htmlTemp += '<h3>수주예상일 업데이트를 요청드립니다.</h3>';
            htmlTemp += '<p><br></p><p><br></p>';
        }else{
            htmlTemp += '<h3>Request for Synchronizing Expected Close Date</h3>';
            htmlTemp += '<p><br></p><p><br></p>';
        }        
        htmlTemp += '<h5>E-mail send on&nbsp;'+ dateOutput +'</h5>';
        htmlTemp += '<div class="tbl_type01">';
        htmlTemp += '<table width="918" >';
        htmlTemp += '<tbody>';
        htmlTemp += '<tr>';
        
        if('ko'.equals(langCd)){
            htmlTemp += '<td colspan="6" rowspan="3" style="text-align: left; padding-left: 5px;">수주예상일이 지연되었습니다.<br>영업대표분들 께서는 수주예상일 업데이트 또는 영업중도종결을 진행해주시기 바랍니다.<br>수주부서장님들께서는 영업대표들이 BO 정보를 최신화 하도록 독려 부탁드립니다.</td>';
        }else{
            htmlTemp += '<td colspan="6" rowspan="3" style="text-align: left; padding-left: 5px;">Close date has already passed.<br>Sales Representatives : Please update close date if scheduled has changed.<br>Leaders of the sales department : Please encourage Sales Representatives to update close date.</td>';
        }        
        
        htmlTemp += '</tr>';
        htmlTemp += '</tbody>';
        htmlTemp += '</table>';
        htmlTemp += '</div>';
        htmlTemp += '<br/>';
        if('ko'.equals(langCd)){
            htmlTemp += '<h5>지연 BO 리스트 ('+ listOppty.size() +' BOs)</h5>';
        }else{
            htmlTemp += '<h5>Business Opportunity Overdue List ('+ listOppty.size() +' BOs)</h5>';
        }            
        htmlTemp += '<div class="tbl_type02">';
        htmlTemp += '<table width="918" >';
        
        htmlTemp += '<thead>';
        htmlTemp += '<tr>';
        
        if('ko'.equals(langCd)){
            htmlTemp += '<th width="12%">BO 코드</th>';
            htmlTemp += '<th width="30%">BO 명</th>';
            htmlTemp += '<th width="12%">영업대표</th>';
            htmlTemp += '<th width="12%">등급</th>';
            htmlTemp += '<th width="12%">수주예상일</th>';
            htmlTemp += '<th width="12%">BO 단계</th>';
        }else{
            htmlTemp += '<th width="12%">BO Code</th>';
            htmlTemp += '<th width="30%">BO Name</th>';
            htmlTemp += '<th width="12%">Sales Rep.</th>';
            htmlTemp += '<th width="12%">Grade</th>';
            htmlTemp += '<th width="12%">Close Date</th>';
            htmlTemp += '<th width="12%">BO Stage</th>';
        }        
        htmlTemp += '</tr>';
        htmlTemp += '</thead>';
        
        
        htmlTemp += '<tbody>';
        for(Opportunity rowOppty : listOppty){
            String strBusinessLevel = (String.isBlank(rowOppty.BusinessLevel__c) ? '-' : rowOppty.BusinessLevel__c);
            htmlTemp += '<tr>';
            htmlTemp += '<td>'+ rowOppty.OpportunityCode__c +'</td>';
            String strPath = URL.getSalesforceBaseUrl().toExternalForm() + '/' + rowOppty.Id;
            htmlTemp += '<td style="text-align: left;"><a href="'+ strPath +'" target="_blank">'+ rowOppty.Name +'</a></td>';
            htmlTemp += '<td style="text-align: center;">'+ rowOppty.Owner.Name +'</td>';
            htmlTemp += '<td style="text-align: center;">'+ strBusinessLevel +'</td>';
            htmlTemp += '<td style="text-align: center;">'+ rowOppty.CloseDate.Year() + '.' + rowOppty.CloseDate.Month() + '.' + rowOppty.CloseDate.Day() +'</td>';
            htmlTemp += '<td style="text-align: center;">'+ rowOppty.get('Label_StageName') +'</td>';
            htmlTemp += '</tr>';
        }
        htmlTemp += '</tbody>';
        htmlTemp += '</table>';
        htmlTemp += '</div>';
		htmlTemp += '</div>';
		htmlTemp += '<p><br></p><p><br></p>';
		htmlTemp += '<div class="footer_wrap">';
		htmlTemp += 'Copyright <strong>SAMSUNG SDS.</strong>   All Rights Reserved.';
		htmlTemp += '</div>';
		htmlTemp += '</div>';
		htmlTemp += '</body>';
		htmlTemp += '</html>';
		
        
        return htmlTemp;        
    }
    
    public class ManagerInfo{        
        public String eMail;
        public String langCd;
    }
}