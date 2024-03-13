/**
* @description       : 
* @author            : rakshit.s@samsung.com  d.ashish@samsung.com  aditya.r2@samsung.com
* @group             : 
* @last modified on  : 12-21-2023
* @last modified by  : atul.k1@samsung.com
* Ver   Date         Author                   Modification
 * 1.0  11-24-2022   atul.k1@samsung.com      (IT) HQ mailing improvement MYSALES-361
 * 1.1  12-19-2023   atul.k1@samsung.com       Dynamic year change MYSALES-381
 * 1.2  04-03-2024   atul.k1@samsung.com       Weekly Sales Report Logic Change MYSALES-463
**/
global class Batch_WeeklySalesReport_Ashish implements DataBase.Batchable<SObject>, Database.Stateful ,DataBase.AllowsCallouts, Schedulable {
    private static Boolean isSandbox = Utils.getIsSandbox();
    private List<IF_Log.InterfaceLog> ifLog = new List<IF_Log.InterfaceLog>();
    private List<userInfoWrap> userWrap = new List<userInfoWrap>();
    private List<IF_Log__c> allLog = new List<IF_Log__c>();
    private List<KnoxEmail__c> KnoxEmailList = new List<KnoxEmail__c>(); //Added by Anish - New
    //private List<Id> listOpptyId = new List<Id>();
    // private static List<IF_Log__c> listOpptyId1 = new List<IF_Log__c>(); 
    private Set<String> adminUserIds = new Set<String>();
    //System.debug('ani finale');
    boolean masterTable = false;
    Boolean table1 = false;
    Boolean table2 = false;
    Boolean table3 = false;
    Boolean table4 = false;
    Boolean table5 =false;
    Boolean table6 =false;
    Boolean table7 =false;
    Boolean table8 =false;
    boolean masterTable4 = false;
    
    private static Boolean bTest = false;  //운영 테스트를 위한 Flag 값;
    
    //T110,T120,T140,T640,T641,L1B0,L1E0,ZB01,ZB10
    private static Set<String> setSubsidiary = new Set<String>(System.Label.OPPTYACT_BO_SUBSIDIARY_LIST.split(','));  //자회사는 대상에서 제외
    
    //발송 제한된 이메일
    private static List<String> listRestrictedEmail = new List<String>{'mysales@samsung.com'};
        
        
        public DataBase.QueryLocator start(Database.BatchableContext BC){
            
            System.debug('### Batch_WeeklySalesReport :: start');
            List<String> queryString = new List<String>(); 
            //String queryString= '';
            Database.QueryLocator returnScope;
            //listOpptyId1 = [select Id from IF_Log__c];
            list<user> adminUserList = new List<user>([select id from user where profile.id='00e2w000002RvtEAAS']);
            
            for(User uu : adminUserList){
                adminUserIds.add(uu.id);
            }
            adminUserIds.add('0052w000008A9cDAAS');
            if(isSandbox){
                //@added by: @rakshit.s@samsung.com
                //@desc: if you want to test the batch for individual users add the user id in comma seperation in the below label named "Weekly_Report_Users" if you want it to run for all enter null in the label value.
                //changes for dynamic user in produciton start
                if(system.label.Weekly_Report_Users != 'null'){
                    List<String> userIdSet =  new List<String>();
                    
                    userIdSet = system.label.Weekly_Report_Users.split(',');
                    String idList = '\''+String.join(userIdSet,'\',\'')+'\'';
                    queryString.add('Select Id , name, Profile.Name,Email from User');
                    queryString.add(' WHERE Id IN('+idList +')');                    
                }
                
                else{
                    queryString.add(' select Id,Email,Name from User');
                    queryString.add(' where  Profile.Name = \'Sales Rep.(HQ)\'  AND IsActive = true ');
                }
            }
            else{
                
                //@added by: @rakshit.s@samsung.com
                //@desc: if you want to test the batch for individual users add the user id in comma seperation in the below label named "Weekly_Report_Users" if you want it to run for all enter null in the label value.
                //changes for dynamic user in produciton start
                
                if(system.label.Weekly_Report_Users != 'null'){
                    List<String> userIdSet =  new List<String>();
                    
                    userIdSet = system.label.Weekly_Report_Users.split(',');
                    String idList = '\''+String.join(userIdSet,'\',\'')+'\'';
                    queryString.add('Select Id , name, Profile.Name,Email from User');
                    queryString.add(' WHERE Id IN('+idList +')');
                }                
                else{                  
                    if(Test.isRunningTest()){
                        queryString.add('Select Id , name, Profile.Name,Email from User where Name = \'박 재만\' AND IsActive = true ');
                    }
                    else{
                        queryString.add('Select Id , name, Profile.Name,Email from User');
                        queryString.add(' where  Profile.Name = \'Sales Rep.(HQ)\'  AND IsActive = true ');
                    }                   
                }               
            }
            returnScope = DataBase.getQueryLocator(String.join(queryString,''));            
            return returnScope;            
        }
    
    public void execute(Database.BatchableContext BC, List<User> listScope){
        Map<String,Object> mailresult = new Map<String,Object>(); 
        //System.debug('### Batch_OpptyEmailController :: execute :: listScope = ' + listScope);
        
        Employee__c senderEmployee = Utils.getLoginEmployeeData(UserInfo.getUserId());
        senderEmployee.EvMailAddr__c = 'chae_ho.yang@stage.samsung.com';
        if(!isSandbox){
            senderEmployee.EvMailAddr__c =   'mysales@samsung.com';
        }
        
        List<String> ccList = new List<String>();
        List<String> bccList = new List<String>();
        List<Map<String, Object>> efileList = new List<Map<String, Object>>();
        List<Map<String, String>> nfileList = new List<Map<String, String>>();
        Map<id, set<id>> OpptyMatchingMap = new Map<id, set<id>>();
        Map<Id,Opportunity> matchedoppLst = new Map<Id,Opportunity>();
        Map<String,decimal> BO_AmountMap= new Map<String,decimal>();
        set<String> BO_AmountMapsSet = new set<String>();
        
        
        List<String> toList = new List<String>(); 
        if(isSandbox){
            //toList = new List<String>(System.label.WEEKLY_MAIL_RECIPIENT_STAGE.split(','));
            toList.add('aditya.r2@stage.samsung.com');
        }
        if(!isSandbox){
            String st = System.label.WEEKLY_MAIL_RECIPIENT_TEST;
            if(st != 'null')
            	toList = new List<String>(st.split(','));
            //toList = new List<String>(System.label.WEEKLY_MAIL_RECIPIENT.split(','));
            //toList.add(listScope[0].Email);
        }
        
        
        String strEmailTemp = '';
        String strEmail = '';
        EmailTemplate em = [SELECT Id,subject FROM EmailTemplate WHERE DeveloperName = 'HQ_Weekly_Sales_Report_Sales_Rep_Test'];
        Id templateId = em.Id;
        strEmail = [SELECT HtmlValue FROM EmailTemplate WHERE Id = :templateId].HtmlValue;
        String strTitle = system.label.WEEKLY_MAIL_TITLE;
        
        List<Opportunity> lstOpp = new List<Opportunity>();
        //List<Opportunity> lstOpp1 = new List<Opportunity>();
        List<Opportunity> lstOpp2 = new List<Opportunity>();
        List<Opportunity> lstOpp3 = new List<Opportunity>();
        List<Opportunity> lstOpp4 = new List<Opportunity>();
        List<Opportunity> lstOpp5 = new List<Opportunity>();
        List<Opportunity> lstOpp6 = new List<Opportunity>();
        List<Opportunity> lstOpp7 = new List<Opportunity>();
        List<Opportunity> lstOpp8 = new List<Opportunity>();
        List<Opportunity> lstOpp9 = new List<Opportunity>();

        //Added By Ashish 
        List<Opportunity> lstOppTable4  = new List<Opportunity>();
        DateTime dt = DateTime.now().addDays(-8);
        //Opportunity lstOpp = new Opportunity();
        //lstOpp = [select Id, Amount,Name,OpportunityCode__c,ZP61_PROPOSAL_SUBMIT_DATE__c,ProposalPM__c,ProposalPM__r.Name, cOriginAcc__c, cOriginAcc__r.Owner.Name,cOriginAcc__r.Name, Opportunity_Review_VRB_Type_Confirm__c,toLabel(Opportunity_Review_VRB_Type_Confirm__c) toLabel_Opportunity_Review_VRB_Type_Confirm__c,Opportunity_Review_VRB_Type__c,toLabel(Opportunity_Review_VRB_Type__c) toLabel_Opportunity_Review_VRB_Type__c, StageName,toLabel(StageName) toLabel_StageName,BO1stRegistrationDate__c,CloseDate,XP7_CONDUCT_DATE__c,XP6_CONDUCT_DATE__c, Account.mDomesticForeign__c, CMBizType__c, AccountId,Account.Owner.Name,Account.Name,OriginAcc_BizTypeL1__c,BusinessLevel__c, RecordType.Name,Type from opportunity where  OwnerId = : listScope[0].Id];
        //addedby: rakshit.s@samsung.com
        //desc: ->  new optimized query in order to avoid unnecessary for loop on line 478. 
        lstOpp = [
            SELECT Id,cRevenueStartDate__c,account.lastmodifieddate,cOriginAcc__r.lastmodifieddate,(select id,ProposalPMPlan__c,ExecutionPMPlan__c, BOCode__c ,companycode__c,ProposalPMNo__c,ProposalPMStatus__c,P_Projectcode__c,ProposalPMStDt__c,ProposalPMEdDt__c,P_Projectname__c from TXP_manpower_input_information__r limit 1),(select id,ProjectCode__c from BO_Project__r), cOriginAcc__r.LastModifiedById,convertCurrency(Amount), Name, account.lastmodifiedbyId, OpportunityCode__c, ZP61_PROPOSAL_SUBMIT_DATE__c, ProposalPM__c, ProposalPM__r.Name, cOriginAcc__c, cOriginAcc__r.Owner.Name, cOriginAcc__r.Name, Opportunity_Review_VRB_Type_Confirm__c, toLabel(Opportunity_Review_VRB_Type_Confirm__c) toLabel_Opportunity_Review_VRB_Type_Confirm__c, FirstCloseDate__c, Opportunity_Review_VRB_Type__c, toLabel(Opportunity_Review_VRB_Type__c) toLabel_Opportunity_Review_VRB_Type__c, StageName, toLabel(StageName) toLabel_StageName, BO1stRegistrationDate__c, CloseDate, XP7_CONDUCT_DATE__c, XP6_CONDUCT_DATE__c, Account.mDomesticForeign__c, CMBizType__c, AccountId, Account.Owner.Name, Account.Name, OriginAcc_BizTypeL1__c, BusinessLevel__c, RecordType.Name, Type,XP7_REQ_DATE__c,XP6_REQ_DATE__c,Opportunity_Review_Confirm__c  
            ,OpportunityStatus__c,XP63_EndDate__c,LastModifiedDate,LastModifiedById,OriginAcc_BizTypeL2__c,CompanyCode__c FROM Opportunity 
            WHERE ((
                OpportunityStatus__c = 'E0002' AND CMBizType__c = 'CSP_SCP' AND CloseDate >= TODAY AND CloseDate <= NEXT_N_MONTHS:3
            ) OR 
                   (
                       (StageName = 'Z02' OR StageName = 'Z03' OR StageName = 'Z04') AND CloseDate >= TODAY AND CloseDate <= NEXT_N_MONTHS:3
                   ) OR 
                   (
                       XP7_REQ_DATE__c = null AND (Opportunity_Review_VRB_Type_Confirm__c= '21' or Opportunity_Review_VRB_Type_Confirm__c= '20' or Opportunity_Review_VRB_Type_Confirm__c= '10') AND Opportunity_Review_Confirm__c = true AND XP63_EndDate__c!=null AND OpportunityStatus__c = 'E0002' AND CloseDate <= Next_N_WEEKS:2
                   ) OR 
                   (
                       XP6_REQ_DATE__c = null AND (Opportunity_Review_VRB_Type_Confirm__c= '21' or Opportunity_Review_VRB_Type_Confirm__c= '20' or Opportunity_Review_VRB_Type_Confirm__c= '10') AND Opportunity_Review_Confirm__c = true AND  OpportunityStatus__c = 'E0002' AND CloseDate <= Next_N_MONTHS:2
                   ) OR 
                   (
                       (StageName = 'Z01' OR StageName = 'Z02' OR StageName = 'Z03' OR StageName = 'Z04') AND CloseDate > TODAY AND CloseDate < NEXT_N_DAYS:14
                   ) OR 
                   (
                       (StageName = 'Z01' OR StageName = 'Z02' OR StageName = 'Z03' OR StageName = 'Z04') AND  CloseDate < TODAY and FirstCloseDate__c = null
                   ) OR 
                   (
                       (StageName = 'Z01' OR StageName = 'Z02' OR StageName = 'Z03' OR StageName = 'Z04' or StageName = 'Z05') AND 
                       
                       CloseDate = THIS_YEAR
                       
                   )  OR 
                   (
                       (StageName = 'Z02' OR StageName = 'Z03' OR StageName = 'Z04') AND 
                       
                       CloseDate <= NEXT_N_MONTHS:3
                   )
                  ) AND OwnerId = : listScope[0].Id
            AND RecordType.Name='HQ' AND companycode__c='T100' order by closeDate Asc, Amount Desc           
        ];
        
        Set<String> scpCodes = new Set<String>();

        for(SCPSimulation__c scp : [select bocode__c  from SCPSimulation__c where companycode__c = 'T100' Limit 500]){//and ownerId = : listScope[0].Id SCP fix by Ashish
            scpCodes.add(scp.bocode__c);
        }
        
        //system.debug('ashish opptySize::'+ lstOpp.size());  
        // system.debug('Users name for opportunity : ' +  listScope[0].Name);
        Decimal dec= 0;
        Decimal dec1= 0;
        Integer count = 1;  //Adi
        Integer subHeadingCount = 1;  //Adi
        
        //sequence change fro table 9 and 1 start
        lstOppTable4 = new list<opportunity>([SELECT Id, cOriginAcc__r.LastModifiedById,convertCurrency(Amount), Name, account.lastmodifiedbyId, OpportunityCode__c, ZP61_PROPOSAL_SUBMIT_DATE__c, ProposalPM__c, ProposalPM__r.Name, cOriginAcc__c, cOriginAcc__r.Owner.Name, cOriginAcc__r.Name, Opportunity_Review_VRB_Type_Confirm__c, toLabel(Opportunity_Review_VRB_Type_Confirm__c) toLabel_Opportunity_Review_VRB_Type_Confirm__c, FirstCloseDate__c, Opportunity_Review_VRB_Type__c, toLabel(Opportunity_Review_VRB_Type__c) toLabel_Opportunity_Review_VRB_Type__c, StageName, toLabel(StageName) toLabel_StageName, BO1stRegistrationDate__c, CloseDate, XP7_CONDUCT_DATE__c, XP6_CONDUCT_DATE__c, Account.mDomesticForeign__c, CMBizType__c, AccountId, Account.Owner.Name, Account.Name, OriginAcc_BizTypeL1__c, BusinessLevel__c, RecordType.Name, Type,XP7_REQ_DATE__c,XP6_REQ_DATE__c,Opportunity_Review_Confirm__c  
                                              ,OpportunityStatus__c,XP63_EndDate__c,LastModifiedDate,LastModifiedById,OriginAcc_BizTypeL2__c,CompanyCode__c,OwnerId FROM Opportunity 
                                              WHERE      BO1stRegistrationDate__c !=null 
                                              AND BO1stRegistrationDate__c = LAST_N_DAYS:8
                                              AND OwnerId = : listScope[0].Id
                                              AND RecordType.Name='HQ' AND companycode__c='T100'
                                             ]);
        matchedoppLst = setupTable9(lstOppTable4,matchedoppLst,OpptyMatchingMap);
        //MYSALES-377 Start
        String bulletdataString = '';
        List<BulletinBoard__c> bulletinInfo= [Select id,Name From BulletinBoard__c where Notice__c = true Order By LastModifiedDate desc Limit 3];
        //mySales 활용 TIP
        if(!bulletinInfo.isEmpty()){
        for(BulletinBoard__c eachbulletinInfo : bulletinInfo){
            //Making it as link
                String str; 
                    if(isSandbox){
                        str = 'https://sdssfa--qa.sandbox.lightning.force.com/lightning/r/BulletinBoard__c/' + eachbulletinInfo.Id + '/view';
                    }
                    else{
                        str = 'https://sdssfa.lightning.force.com/lightning/r/BulletinBoard__c/' + eachbulletinInfo.Id + '/view';    
                    }
            if(eachbulletinInfo.Name != null && eachbulletinInfo.Name != ''){
                //bulletdataString = bulletdataString + eachbulletinInfo.Name + '</br>';
                bulletdataString = bulletdataString +'<li class="NoSpace">'+'<span class="DotSpace">'+'<a class="linktext" href="' + str + '">'+ eachbulletinInfo.Name + '</a>'+'</span>'+'</li>'+'</br>';
            }
            
        }
        }
        if(bulletdataString != null && bulletdataString != ''){
          strEmail = strEmail.replace('Check bulletin board', bulletdataString);  
        }
        else{
            strEmail = strEmail.replace('Check bulletin board', ''); 
        }
        //MYSALES-377 End
        //BO_AmountMap = getBORelatedAmount(BO_AmountMapsSet,BO_AmountMap);
        Integer tableOneCount = 0 ;
        Set<String> compositeKeySet = new set<string>();
        //MYSALES-361 V 1.0
        Map<String,String> countUnquieBOCode = new  Map<String,String>();
        //MYSALES-361 Adding DiffAmtLoc__c in query below. V 1.0 
        //MYSALES-463 Changing the DiffAmtLoc__c to DiffAmt__c. V 1.2
        for(opportunityamt__c res:[Select opportunitycode__c, Version__c,DiffAmt__c,DiffAmtLoc__c from opportunityamt__c where 
                                 companycode__c ='T100'
                                 and closedate__c = this_year
                                 and opportunity__r.recordtype.developername = 'HQ' 
                                 and opportunity__r.owner.id =:   listScope[0].Id      
                                 and opportunity__r.stagename = 'Z05'])    {
                                     system.debug(res.get('Version__c'));
                                     system.debug(res.get('opportunitycode__c'));
                                     //MYSALES-361 Start V 1.0
                                     if(!countUnquieBOCode.isEmpty()){
                                         if(countUnquieBOCode.containsKey(res.opportunitycode__c)){
                                             
                                         }
                                         else{
                                             if(res.DiffAmt__c != 0){
                                             countUnquieBOCode.put(res.opportunitycode__c,res.Version__c);
                                             tableOneCount++;
                                             }
                                             
                                         }
                                         
                                     }
                                     else{
                                         if(res.DiffAmt__c != 0){
                                             countUnquieBOCode.put(res.opportunitycode__c,res.Version__c);
                                             tableOneCount = 1;
                                         }
                                         
                                     }
                                     //MYSALES-361 End V 1.0
                                     compositeKeySet.add(res.get('opportunitycode__c')+'_'+res.get('Version__c'));
                                 }
        
        Decimal tableOneAmountSum = getBORelatedAmount(compositeKeySet,BO_AmountMap,listScope[0]);
        //sequence change fro table 9 amd 1 end
        if(lstOpp.Size()>0 || lstOppTable4.size()>0 || tableOneCount >0){
            masterTable = true;
            for(Opportunity Opp : lstOpp){
                String str = '';
                str = String.valueOf(Opp.BO1stRegistrationDate__c);
                // System.debug('Ani str :'+ str);
                String cntYear = String.valueOf(System.today().year());
                String cntWeek = String.valueOf(System.today().addDays(-7));
                //System.debug('Ani stryear :'+ cntYear);
                
                Date firstDayOfMonth = Date.today().toStartOfMonth().adddays(-1);
                //System.debug('Ani lstOpp999 :'+ lstOpp999.Size());
                if((opp.StageName == 'Z01' || opp.StageName == 'Z02' || opp.StageName == 'Z03' || opp.StageName == 'Z04') && Opp.BO1stRegistrationDate__c != null && (System.today().year() == opp.closedate.year()) ){
                    lstOpp2.add(opp);
                    if(opp.Amount !=null){
                        dec1 = dec1 + opp.Amount;
                    }                    
                }
                //table 2
                if((opp.StageName == 'Z02' || opp.StageName == 'Z03' || opp.StageName == 'Z04') && opp.CloseDate<= System.today() && opp.FirstCloseDate__c == null){
                    lstOpp3.add(opp);
                }
                //table 3
                Date thisWeekStart = date.today().toStartOfWeek();
                if((opp.StageName == 'Z01' || opp.StageName == 'Z02' || opp.StageName == 'Z03' || opp.StageName == 'Z04') &&  (opp.CloseDate > system.today() && opp.CloseDate< date.today().adddays(14) )){
                    lstOpp4.add(opp);
                }
                //table 4
                if(opp.XP6_REQ_DATE__c == null && (opp.Opportunity_Review_VRB_Type_Confirm__c== '21' || opp.Opportunity_Review_VRB_Type_Confirm__c== '20' || opp.Opportunity_Review_VRB_Type_Confirm__c== '10') && opp.Opportunity_Review_Confirm__c && opp.OpportunityStatus__c == 'E0002' && opp.CloseDate<= Date.today().toStartOfMonth().addmonths(+3).adddays(-1)){//System.now().addmonths(+2)  firstDayOfMonth.addmonths(+3)
                    // system.debug('4t table opp-->' + opp.id);
                    lstOpp5.add(opp);
                }
                //table 5
                if(opp.XP7_REQ_DATE__c == null && (opp.Opportunity_Review_VRB_Type_Confirm__c== '21' || opp.Opportunity_Review_VRB_Type_Confirm__c== '20' || opp.Opportunity_Review_VRB_Type_Confirm__c== '10') && opp.Opportunity_Review_Confirm__c && opp.XP63_EndDate__c!=null && opp.OpportunityStatus__c == 'E0002' && opp.CloseDate<= thisWeekStart.adddays(20)){//System.now().addDays(+14)
                    lstOpp6.add(opp);
                }
                //table 6
                if(( opp.StageName == 'Z02' || opp.StageName == 'Z03' || opp.StageName == 'Z04')){
                    //if(opp.CloseDate <= Date.today().toStartOfMonth().addmonths(+4).adddays(-1))//System.now().addMonths(+3))
                    if(opp.CloseDate > system.today() && opp.CloseDate <= Date.today().addmonths(3))
                    {
                        lstOpp7.add(opp);
                    }
                }
                //table 7
                System.debug('Test111==>'+opp.CloseDate);
                System.debug('Test112==>'+opp.CloseDate);
                System.debug('Test113==>'+opp.OpportunityStatus__c );
                 System.debug('Test114==>'+opp.Account.mDomesticForeign__c );
                 System.debug('Test115==>'+opp.account.lastmodifieddate  );
                if((opp.CloseDate > system.today() && opp.CloseDate <= firstDayOfMonth.addmonths(+4) && opp.OpportunityStatus__c == 'E0002' && opp.Account.mDomesticForeign__c == '20' && ((opp.account.lastmodifieddate < Date.today().toStartOfMonth().addmonths(-3) && !adminUserIds.contains(opp.account.LastModifiedById) ) || (opp.cOriginAcc__r.lastmodifieddate < Date.today().toStartOfMonth().addmonths(-3) && !adminUserIds.contains(opp.cOriginAcc__r.LastModifiedById) ))))
                {
                    
                    lstOpp8.add(opp);
                    
                }
                //table 8
                if(((opp.StageName == 'Z01' || opp.StageName == 'Z02' || opp.StageName == 'Z03' || opp.StageName == 'Z04') && opp.CMBizType__c == 'CSP_SCP' && opp.CloseDate > system.today() && opp.CloseDate <= firstDayOfMonth.addmonths(+4)/*System.now().addMonths(+3)*/) && !scpCodes.contains(opp.OpportunityCode__c)){
                    //if((System.now() < opp.CloseDate <= System.now().addMonths(+3)))
                    //{
                    lstOpp9.add(opp);
                    //}
                }
            }
            
            
            //system.debug('Ashish getting matchedoppLst from method'+matchedoppLst);
            //system.debug('Ashish getting OpptyMatchingMap from method'+OpptyMatchingMap);
            lstOpp = null;
            system.debug('---list sizes----' + tableOneCount + '2nd----->' + lstOpp2.size() + '3rd---->' + lstOpp3.size() + '4th--->' + lstOpp4.size() + '5th--->' + lstOpp5.size() + '6th---->' + lstOpp6.size() + '7th---->' + lstOpp7.size() + '8th---->' + lstOpp8.size() + '9th---->' + lstOpp9.size() +  'last table---' + lstOppTable4.size());
            
            if(lstOpp4.Size() == 0){
                if(lstOpp3.Size() > 0){
                    system.debug('Inside Main Table 2: '+ strEmail);
                    
                    strEmail = strEmail.replace('<table class="table box_margin">{!tableString2}</table>', '<table class="table">{!tableString2}</table>');
                    system.debug('Inside Main Table 2 After: '+ strEmail);
                }
            }
            
            if(lstOpp9.Size() == 0){
                if(lstOpp8.Size() > 0){
                    strEmail = strEmail.replace('<table class="table box_margin">{!tableString7}</table>', '<table class="table">{!tableString7}</table>'); 
                }else{
                    if(lstOpp7.Size() > 0){
                        strEmail = strEmail.replace('<table class="table box_margin">{!tableString6}</table>', '<table class="table">{!tableString6}</table>');
                    }else{
                        if(lstOpp5.Size() > 0 || lstOpp6.Size() > 0){
                            strEmail = strEmail.replace('<table class="table box_margin">{!tableString5}</table>', '<table class="table">{!tableString5}</table>');
                        }
                    }		
                }
            }
            
            if(tableOneCount > 0 || lstOpp2.Size()>0){
                // table1 = true;
                String strTemp = '';
                //String amt = dec > 0 ? String.valueOf(dec/1000000) : '0' ;
                String amt = String.valueOf(tableOneAmountSum /1000000); // String amt = tableOneAmountSum  > 0 ? String.valueOf(tableOneAmountSum /1000000) : '0'; //MYSALES-361 V 1.0
                String amt1 =String.valueOf(dec1/1000000) ; //String amt1 =dec1 > 0 ? String.valueOf(dec1/1000000) : '0' ; //MYSALES-361 V 1.0
                //System.debug('amt Test@ :' + amt);
                List<String> amtStr = new List<String>();
                List<String> amtStr1 = new List<String>();
                String num = '';
                String num1 = '';
                if(amt.contains('.')){
                    amtStr= amt.split('\\.');
                    // System.debug('amtStr Test@ :'+amtStr);
                    num = amtStr[0] +'.' + amtStr[1].substring(0,2);
                    
                }
                else{
                    //    num = dec > 0 ? String.valueOf(dec/1000000) : '0' ;
                    num = String.valueOf(tableOneAmountSum/1000000); //  num =tableOneAmountSum > 0 ? String.valueOf(tableOneAmountSum/1000000) : '0' ; //MYSALES-361 V 1.0
                    
                }
                if(amt1.contains('.')){
                    amtStr1= amt1.split('\\.');
                    ///   System.debug('amtStr Test@ :'+amtStr1);
                    num1 = amtStr1[0] +'.' + amtStr1[1].substring(0,2);
                }
                else{
                    num1 =  String.valueOf(dec1/1000000); //num1 = dec1 > 0 ? String.valueOf(dec1/1000000) : '0' ; //MYSALES-361 V 1.0
                }
                //MYSALES-381 Start
                Date dat = system.today();
                Integer YearVal = dat.year();
                //Integer YearVal = 2024;
                integer valYear = Math.mod(YearVal,2000);
                system.debug('Year Value==>'+valYear);
                //MYSALES-381 End
                strTemp += '<thead> <tr>'+
                    '<td class="align_right">수주완료 건수</th>'+
                    '<td class="align_right">수주완료 금액 </th>'+
                    '<td class="align_right">진행중 BO건수(\''+valYear+'년 수주예상일 대상)</th>'+ //MYSALES-381
                    '<td class="align_right">BO금액(\''+valYear+'년 수주예상일 대상)</th>'+ //MYSALES-381
                    '</tr> </thead>'+
                    '<tbody><tr>'+
                    '<td class="align_right">' + tableOneCount + '</td>' +
                    '<td class="align_right">' + formattedNumber(num) + '</td>' +
                    '<td class="align_right">' + lstOpp2.Size() + '</td>' +
                    '<td class="align_right">' + formattedNumber(num1) + '</td>'+ 
                    '</tr><tbody>' ;
                datetime dt1 = Date.today();
				String sDate = String.valueOf(dt1.format('yyyy-MM-dd'));
                String sTemp = '<td class="title">'+ count +'. 연간 누적 사업기회 수주 현황<a class="add_btn" href="https://sdssfa.lightning.force.com/lightning/r/Report/00O2w00000E3Zv5EAF/view?queryScope=userFolders">수주완료 상세보기</a></td>';    //Adi //MYSALES-361 V 1.0
                system.debug('Count inside Main table 1 : '+ count);
                strEmail = strEmail.replace('<td class="title">1. 연간 누적 사업기회 수주 현황<a class="add_btn" href="https://sdssfa.lightning.force.com/lightning/r/Report/00O2w00000E3Zv5EAF/view?queryScope=userFolders">수주완료 상세보기</a></td>', sTemp);    //Adi //MYSALES-361 V 1.0
                strEmail = strEmail.replace('{!DateValue}', sDate);
                strEmail = strEmail.replace('{!tableString1}', strTemp);
                strEmail = strEmail.replace('Curent_Year',String.Valueof(valYear)); //MYSALES-381
                table1 = true;
                count = count +1;  //Adi
                if(Test.isRunningtest()){
                    List<Batch_WeeklySalesReport_Ashish.userInfoWrap> uuList = new List<Batch_WeeklySalesReport_Ashish.userInfoWrap>();
                    Batch_WeeklySalesReport_Ashish.userInfoWrap uu = new Batch_WeeklySalesReport_Ashish.userInfoWrap();
                    uu.Name = 'Sample';
                    uu.UserId = 'sample';
                    Batch_WeeklySalesReport_Ashish.userInfoWrap uu2 = new Batch_WeeklySalesReport_Ashish.userInfoWrap();
                    uu2.Name = 'Sample';
                    uu2.UserId = 'sample';
                    uu2.isfailure = true;        
                    uuList.add(uu2);
                    createInterfaceLog(uuList);
                    
                }
            }
            Boolean a = false;
            if(tableOneCount==0 && lstOpp2.Size()==0){
                a= true;
                strEmail = strEmail.replace('<tr><td><table class="title_wrap"><tr><td class="title">1. 연간 누적 사업기회 수주 현황<a class="add_btn" href="https://sdssfa.lightning.force.com/lightning/r/Report/00O2w00000E3Zv5EAF/view?queryScope=userFolders">수주완료 상세보기</a></td></tr></table><table class="table">{!tableString1}</table> <ul class="gray_text"><li>수주완료 건수 : \'Curent_Year년 수주/변경 품의 BO 건수 (수주 변경금액이 0원인 경우 제외, 동일한 BO번호는 1건으로 집계)</li><li2>수주완료 금액 : \'Curent_Year년 수주금액 및 수주 변경금액(차액) 의 합계 </li2><li>변경 품의 금액은 해당 BO 의 Related > Opportunity Amount 에서 확인 가능합니다.</li></ul></td></tr>',''); //MYSALES-361 V 1.0 Add css  //MYSALES-381
            }
            //lstOpp1 = null;
            lstOpp2 = null;
            if(lstOpp3.Size()>0){
                // table2 = true;
                String strTemp = '';
                strTemp += '<thead> <tr>'+
                    
                    '<td >사업기회 코드</th>'+
                    '<td colspan ="3" >사업기회명</th>'+
                    '<td colspan ="0.5" >수주예상일</th>'+
                    '<td >단계</th>'+
                    '<td class="align_right">금액</th>'+
                    '</tr></thead>';
                strTemp +=  '<tbody>';
                for(Opportunity opp : lstOpp3){
                    String str; 
                    if(isSandbox){
                        str = 'https://sdssfa--qa.sandbox.lightning.force.com/lightning/r/Opportunity/' + opp.Id + '/view';
                    }
                    else{
                        str = 'https://sdssfa.lightning.force.com/lightning/r/Opportunity/' + opp.Id + '/view';    
                    }
                    String clDate = String.valueOf(opp.CloseDate);
                    String closeDate = clDate.substring(0,10);
                    String amt = '';
                    if(opp.Amount!=null){
                        amt = String.valueOf(opp.Amount/1000000) ;
                    }
                    
                    //  System.debug('amt Test@ :' + amt);
                    List<String> amtStr = new List<String>();
                    String num = '';
                    if(amt.contains('.')){
                        amtStr= amt.split('\\.');
                        // System.debug('amtStr Test@ :'+amtStr);
                        num = amtStr[0] +'.' + amtStr[1].substring(0,2);
                    }
                    else{
                        if(opp.Amount!=null){
                            num = String.valueOf(opp.Amount/1000000);
                        }
                        
                    }
                    // System.debug('amtStr Test :'+amtStr);
                    
                    strTemp +=  '<tr>'+
                        
                        '<td class="nowrap">' + opp.OpportunityCode__c + '</td>' +
                        '<td  colspan ="3">' + '<a style="color:blue" href="' + str + '">'+ opp.Name + '</a>' + '</td>' +
                        '<td  colspan ="0.5" class="nowrap">' + closeDate + '</td>' +
                        '<td class="nowrap">' + opp.get('toLabel_StageName') + '</td>'+ 
                        '<td class="align_right">' + formattedNumber(num) + '</td>'+ 
                        '</tr>' ;
                }
                strTemp +=  '</tbody>'; 
                datetime dt1 = Date.today();
				String sDate = String.valueOf(dt1.format('yyyy-MM-dd'));
                String sTemp = IntRoman(subHeadingCount) +'지연 BO';    //Adi
                strEmail = strEmail.replace('i. 지연 BO', sTemp);    //Adi
                subHeadingCount++;
                strEmail = strEmail.replace('{!DateValue}', sDate);
                strEmail = strEmail.replace('{!tableString2}', strTemp);
                table2 = true;
            }
            
            if(lstOpp4.Size()>0){
                //table3 = true;
                String strTemp = '';
                strTemp += ' <thead><tr>'+
                    
                    '<td >사업기회 코드</th>'+
                    '<td colspan ="3" ">사업기회명</th>'+
                    '<td colspan ="0.5" >수주예상일</th>'+
                    '<td >단계</th>'+
                    '<td class="align_right">금액</th>'+
                    '</tr></thead>';
                strTemp +=  '<tbody>';
                for(Opportunity opp : lstOpp4){
                    String str; 
                    if(isSandbox){
                        str = 'https://sdssfa--qa.sandbox.lightning.force.com/lightning/r/Opportunity/' + opp.Id + '/view';
                    }
                    else{
                        str = 'https://sdssfa.lightning.force.com/lightning/r/Opportunity/' + opp.Id + '/view';    
                    }
                    String clDate = String.valueOf(opp.CloseDate);
                    String closeDate = clDate.substring(0,10);
                    String amt = '';
                    if(opp.Amount!=null){
                        amt = String.valueOf(opp.Amount/1000000) ;
                    }
                    // System.debug('amt Test@ :' + amt);
                    List<String> amtStr = new List<String>();
                    String num = '';
                    if(amt.contains('.')){
                        amtStr= amt.split('\\.');
                        //   System.debug('amtStr Test@ :'+amtStr);
                        num = amtStr[0] +'.' +  amtStr[1].substring(0,2);
                    }
                    else{
                        if(opp.Amount!=null){
                            num = String.valueOf(opp.Amount/1000000);
                        }
                        
                        
                    }
                    //   System.debug('amtStr Test :'+amtStr);  
                    strTemp +=  '<tr>'+
                        
                        '<td class="nowrap">' + opp.OpportunityCode__c + '</td>' +
                        '<td " colspan ="3" >' + '<a style="color:blue" href="' + str + '">'+ opp.Name + '</a>' + '</td>' + 
                        '<td " colspan ="0.5" class="nowrap">' + closeDate + '</td>' +
                        '<td class="nowrap">' + opp.get('toLabel_StageName') + '</td>'+ 
                        '<td class="align_right">' + formattedNumber(num) + '</td>'+ 
                        '</tr>' ;
                }
                strTemp +=  '<tbody>';
                String sTemp = IntRoman(subHeadingCount) +'수주예상일 도래 BO (D-13)';    //Adi
                strEmail = strEmail.replace('ii. 수주예상일 도래 BO (D-13)', sTemp);    //Adi
                strEmail = strEmail.replace('{!tableString3}', strTemp);
                datetime dt1 = Date.today();
				String sDate = String.valueOf(dt1.format('yyyy-MM-dd'));
                strEmail = strEmail.replace('{!DateValue}', sDate);
                table3 = true;
            }
            
            if(lstOpp4.Size()==0 && lstOpp3.Size()==0){
                strEmail = strEmail.replace('<tr><td class="box_padding"><p class="title">2. 지연 BO 및 수주 예상일 도래 BO</p><div class="sub_table_wrap">', '');
                strEmail = strEmail.replace('<table class="title_wrap"><tr><td class="sub_title">i. 지연 BO</td></tr></table><table class="table box_margin">{!tableString2}</table>', '');
                strEmail = strEmail.replace('<table class="title_wrap"><tr><td class="sub_title">ii. 수주예상일 도래 BO (D-13)</td></tr></table><table class="table">{!tableString3}</table>', '');
            }else{  //Adi complete else part
                String sTemp = '<p class="title">' + count + '. 지연 BO 및 수주 예상일 도래 BO</p>';
                system.debug('Count inside Main table 2 : '+ count);
                strEmail = strEmail.replace('<p class="title">2. 지연 BO 및 수주 예상일 도래 BO</p>', sTemp);
                count = count +1;
            }
            
            Boolean b = false;
            if(lstOpp3.Size()==0){
                strEmail = strEmail.replace('<table class="title_wrap"><tr><td class="sub_title">i. 지연 BO</td></tr></table><table class="table box_margin">{!tableString2}</table>', '');
                b= true;  
            }
            
            Boolean c = false;
            if(lstOpp4.Size()==0){
                strEmail = strEmail.replace('<table class="title_wrap"><tr><td class="sub_title">ii. 수주예상일 도래 BO (D-13)</td></tr></table><table class="table">{!tableString3}</table>', '');
                c= true;   
            }
            
            lstOpp3 = null;   
            lstOpp4 = null;
            subHeadingCount = 1;  //Adi
            
            if(lstOpp5.Size()>0){
                // table4 = true;
                String strTemp = '';
                strTemp +=  '<thead><td >사업기회코드</td>'+
                    '<td >사업기회명 </td>'+
                    '<td >수전위 유형</td>'+
                    '<td >사업 심의 유형</td>'+
                    '<td >수주예상일</td>'+
                    '<td >단계</td>'+
                    '<td class="align_right" >금액</td>'+
                    '<td >제안 제출일</td>'+
                    '</tr></thead>';
                strTemp +=  '<tbody>';
                for(Opportunity opp : lstOpp5){
                    // system.debug('4th table data-->' + opp.id);
                    String str; 
                    String clDate = String.valueOf(opp.CloseDate);
                    String closeDate = clDate.substring(0,10);
                    if(isSandbox){
                        str = 'https://sdssfa--qa.sandbox.lightning.force.com/lightning/r/Opportunity/' + opp.Id + '/view';
                    }
                    else{
                        str = 'https://sdssfa.lightning.force.com/lightning/r/Opportunity/' + opp.Id + '/view';    
                    } 
                    String cnDate = ''/*String.valueOf(opp.XP7_CONDUCT_DATE__c)*/;
                    String conductDate = '' /*cnDate!=null ? cnDate.substring(0,10):''*/;
                    String propDate = String.valueOf(opp.ZP61_PROPOSAL_SUBMIT_DATE__c);
                    String proposalDate;
                    String tempDate = '';
                    if(propDate != null /*|| propDate != ''*/){
                        if(!Test.isRunningTest())
                        {
                            proposalDate = propDate.substring(0,10);
                        }
                    }
                    String amt = '';
                    if(opp.Amount!=null){
                        amt = String.valueOf(opp.Amount/1000000) ;
                    }
                    //   System.debug('amt Test@ :' + amt);
                    List<String> amtStr = new List<String>();
                    String num = '';
                    if(amt.contains('.')){
                        amtStr= amt.split('\\.');
                        //   System.debug('amtStr Test@ :'+amtStr);
                        num = amtStr[0] + '.' + amtStr[1].substring(0,2);
                    }
                    else{
                        if(opp.Amount!=null){
                            num = String.valueOf(opp.Amount/1000000);
                        }
                        
                        
                    }
                    
                    if(opp.ZP61_PROPOSAL_SUBMIT_DATE__c != null){
                        tempDate = String.valueof(opp.ZP61_PROPOSAL_SUBMIT_DATE__c);
                    }
                    
                    //  System.debug('amtStr Test :'+amtStr);
                    strTemp += '<td class="nowrap">' + opp.Opportunitycode__c  + '</td>' +
                        '<td >'+ '<a style="color:blue" href="' + 'https://sdssfa.lightning.force.com/lightning/r/Opportunity/'+opp.Id+'/view' + '">'+ opp.Name + '</a>' +'</td>' +
                        '<td >' + /*vrbTypeValues(opp.Opportunity_Review_VRB_Type_Confirm__c)*/ '사참수전위' + '</td>' + 
                        '<td >' + vrbTypeValues(opp.Opportunity_Review_VRB_Type_Confirm__c) + '</td>' +
                        '<td class="nowrap">' + closeDate + '</td>'+ 
                        '<td class="nowrap">' + opp.get('toLabel_StageName') + '</td>'+ 
                        '<td class="align_right">' + formattedNumber(num) + '</td>'+ 
                        
                        '<td >' + tempDate + '</td>'+
                        '</tr>' ;
                }
                strTemp +=  '</tbody>';
                datetime dt1 = Date.today();
				String sDate = String.valueOf(dt1.format('yyyy-MM-dd'));
                /*String sTemp = IntRoman(subHeadingCount) +'. 수전위 사전준비';    //Adi
				strEmail = strEmail.replace('i. 수전위 사전준비', sTemp);    //Adi
				subHeadingCount++;  //Adi*/
                strEmail = strEmail.replace('{!DateValue}', sDate);
                strEmail = strEmail.replace('{!tableString4}', strTemp);
                table4 = true;
            }
            
            if(lstOpp6.Size()>0){
                // table5 = true;
                String strTemp='';
                strTemp += '<thead><tr>'+
                    '<td >사업기회 코드</td>'+
                    '<td >사업기회명 </td>'+
                    '<td  >수전위 유형</td>'+
                    '<td >사업 심의 유형</td>'+
                    '<td >수주예상일</td>'+
                    '<td >단계</td>'+
                    '<td class="align_right">금액</td>'+
                    '<td >제안 제출일</td>'+
                    '</tr></thead>';
                strTemp +=  '<tbody>';
                for(Opportunity opp : lstOpp6){
                    String str; 
                    String clDate = String.valueOf(opp.CloseDate);
                    String closeDate = clDate.substring(0,10);
                    if(isSandbox){
                        str = 'https://sdssfa--qa.sandbox.lightning.force.com/lightning/r/Opportunity/' + opp.Id + '/view';
                    }
                    else{
                        str = 'https://sdssfa.lightning.force.com/lightning/r/Opportunity/' + opp.Id + '/view';    
                    }
                    String cnDate = ''/*String.valueOf(opp.XP6_CONDUCT_DATE__c)*/;
                    String conductDate = ''/*cnDate.substring(0,10)*/;
                    //String propDate = String.valueOf(opp.ZP61_PROPOSAL_SUBMIT_DATE__c);
                    //String proposalDate = propDate.substring(0,10);
                    String proposalDate;
                    
                    String amt = '';
                    if(opp.Amount!=null){
                        amt = String.valueOf(opp.Amount/1000000) ;
                    }
                    // System.debug('amt Test@ :' + amt);
                    List<String> amtStr = new List<String>();
                    String num = '';
                    if(amt.contains('.')){
                        amtStr= amt.split('\\.');
                        // System.debug('amtStr Test@ :'+amtStr);
                        num = amtStr[0] + '.' + amtStr[1].substring(0,2);
                    }
                    else{
                        if(opp.Amount!=null){
                            num = String.valueOf(opp.Amount/1000000);
                        }
                        
                        
                    }
                    //  System.debug('amtStr Test :'+amtStr);
                    strTemp +=  '<td class="nowrap">' + opp.Opportunitycode__c  + '</td>' +
                        '<td>' + '<a style="color:blue" href="' + 'https://sdssfa.lightning.force.com/lightning/r/Opportunity/'+opp.Id+'/view' + '">'+ opp.Name + '</a>' +'</td>' +
                        '<td >' + /*vrbTypeValues(opp.Opportunity_Review_VRB_Type_Confirm__c)*/ '입찰수전위' + '</td>' + 
                        '<td >' + vrbTypeValues(opp.Opportunity_Review_VRB_Type_Confirm__c) + '</td>' +
                        '<td class="nowrap">' + closeDate + '</td>'+ 
                        '<td class="nowrap">' + opp.get('toLabel_StageName') + '</td>'+ 
                        '<td class="align_right">' + formattedNumber(num) + '</td>';
                    if(opp.ZP61_PROPOSAL_SUBMIT_DATE__c!=null){
                        strTemp += '<td >' + String.valueOf(opp.ZP61_PROPOSAL_SUBMIT_DATE__c).substring(0,10) + '</td>';//opp.ZP61_PROPOSAL_SUBMIT_DATE__c
                    }
                    else{
                        strTemp += '<td></td>';
                    }
                    
                    strTemp += '</tr>' ;
                }
                strTemp +=  '</tbody>';
                /*String sTemp = IntRoman(subHeadingCount) +'. 수전위 사전준비';    //Adi
				strEmail = strEmail.replace('i. 수전위 사전준비', sTemp);    //Adi
				subHeadingCount++;  //Adi*/
                strEmail = strEmail.replace('{!tableString5}', strTemp);
                datetime dt1 = Date.today();
				String sDate = String.valueOf(dt1.format('yyyy-MM-dd'));
                strEmail = strEmail.replace('{!DateValue}', sDate);
                table5 = true;
            }
            
            //Adi complete if else part
            if(lstOpp5.Size()==0 && lstOpp6.Size()==0){
                strEmail = strEmail.replace('<p class="sub_title">i. 수전위 사전준비</p><p class="text">사참 수전위는 수주예상일 2개월전, 입찰 수전위는 수주예상일 2주전 완료해 주시기 바랍니다.<br>- PM: 자가점검 체크리스트 수행, 인력투입계획 수립, 수전위 원가판 편성<br>- 영업대표: 수전위 원가판 확정 </p><p class="gray_text">※ 심의부서에 체크리스트 심의의견 작성시 참고 할 수 있는 보고서, RFP, 제안서 등을 공유하여 주시기 바랍니다. </p><table class="table box_margin">{!tableString4}</table><table class="table box_margin">{!tableString5}</table>', '');
            }else{  
                String sTemp = IntRoman(subHeadingCount) +'수전위 사전준비';    //Adi
                strEmail = strEmail.replace('i. 수전위 사전준비', sTemp);    //Adi
                subHeadingCount++;  //Adi
            }     
            
            if(lstOpp7.Size()>0){
                // table6 = true;
                //  system.debug('table6 creation');
                /*Set<String> txp_ProjectCode = new Set<String>();
                Set<String> oppId = new Set<String>();
                Map<String,String> txp_ProjectCodeVsProject = new Map<String,String>();
                Map<String,String> oppIdVstxp_ProjectCode = new Map<String,String>();
                for(Opportunity opp : lstOpp7){
                    oppId.add(opp.Id);
                }
                List<TXPmanpower__c> txpman = [select id, P_Projectcode__c,Opportunity__c from TXPmanpower__c where Opportunity__c in : oppId and P_Projectcode__c != null];
                system.debug('txpman : ' + txpman);
                if(txpman.size() > 0){
                	for(TXPmanpower__c tx : txpman){
                    	txp_ProjectCode.add(tx.P_Projectcode__c);
                        oppIdVstxp_ProjectCode.put(tx.Opportunity__c, tx.P_Projectcode__c);
                	}
                    system.debug('oppIdVstxp_ProjectCode : '+ oppIdVstxp_ProjectCode);
                    List<Project__c> projectData = [select id,name,ProjectCode__c,Opportunity__c from Project__c where ProjectCode__c in : txp_ProjectCode];
                    if(projectData.size() > 0){
                        for(Project__c p : projectData){
                            txp_ProjectCodeVsProject.put(p.ProjectCode__c, p.Name);
                        }
                        system.debug('txp_ProjectCodeVsProject : '+ txp_ProjectCodeVsProject);
                    }
                }*/
                
                
                String strTemp = '';
                strTemp += '<thead> <tr>'+
                    '<td >사업기회 코드</th>'+
                    '<td colspan ="2" >사업기회명</th>'+
                    '<td >수주예상일 </th>'+
                    '<td > 단계</th>'+
                    '<td class="align_right" >금액</th>'+
                    '<td >제안PM</th>'+
                    '<td >제안PM 가용 여부 </th>'+
                    '<td >제안 PM 투입 일정</th>'+
                    //'<td >제안 PM 투입과제</th>'+
                    '<td >인력투입계획 작성여부 (사전/실행)</th>'+
                   /* '<td >사전영업 계획</th>'+
                    '<td >실행 계획</th>'+*/
                    '</tr></thead>';
                strTemp +=  '<tbody>';
                for(Opportunity opp : lstOpp7){
                    proposalPMInfo pp = new proposalPMInfo();
                    pp = getTable6ProposalPMData(opp.TXP_manpower_input_information__r  , opp.BO_Project__r , opp);
                    String str; 
                    if(isSandbox){
                        str = 'https://sdssfa--qa.sandbox.lightning.force.com/lightning/r/Opportunity/' + opp.Id + '/view';
                    }
                    else{
                        str = 'https://sdssfa.lightning.force.com/lightning/r/Opportunity/' + opp.Id + '/view';    
                    }
                    String prop;
                    if(opp.ProposalPM__r.Name  == null){
                        prop = '';
                        pp.possibility = ''; // MySales-361
                    }
                    else{prop = opp.ProposalPM__r.Name ;}
                    String clDate = String.valueOf(opp.CloseDate);
                    String closeDate = clDate.substring(0,10);
                    String amt = '';
                    if(opp.Amount!=null){
                        amt = String.valueOf(opp.Amount/1000000) ;
                    }
                    //  System.debug('amt Test@ :' + amt);
                    List<String> amtStr = new List<String>();
                    String num = '';
                    if(amt.contains('.')){
                        amtStr= amt.split('\\.');
                        // System.debug('amtStr Test@ :'+amtStr);
                        num = amtStr[0] + '.' + amtStr[1].substring(0,2);
                    }
                    else{
                        if(opp.Amount!=null){
                            num = String.valueOf(opp.Amount/1000000);
                        }
                        
                        
                    }
                    String Procode = '';
                    String manInputExecution = '';
                    
                    /*if(txp_ProjectCodeVsProject.get(oppIdVstxp_ProjectCode.get(opp.Id)) != null)
                        Procode = txp_ProjectCodeVsProject.get(oppIdVstxp_ProjectCode.get(opp.Id));*/
                    System.debug('pp ManPower : '+ pp.manpowerInputPlan + '  pp Execution Plan : '+ pp.manpowerExecutionPlan);
                    if((pp.manpowerInputPlan != null && pp.manpowerInputPlan != '') || (pp.manpowerExecutionPlan != null && pp.manpowerExecutionPlan != '')){
                        manInputExecution = pp.manpowerInputPlan+' / '+pp.manpowerExecutionPlan;
                    }
                       
                    //  System.debug('amtStr Test :'+amtStr);
                    strTemp +=  '<tr>'+
                        '<td class="nowrap">' + opp.OpportunityCode__c  + '</td>' +
                        '<td colspan ="2" >' + '<a style="color:blue" href="' + str + '">'+ opp.Name + '</a>' + '</td>' + 
                        '<td class="nowrap">' + closeDate + '</td>' +
                        '<td class="nowrap">' + opp.get('toLabel_StageName')+ '</td>'+ 
                        '<td class="align_right">' + formattedNumber(num) + '</td>' +
                        '<td >' + prop + '</td>'+
                        '<td class="align_middle">' + pp.possibility + '</td>'+
                        '<td >' + pp.scheduleString  + '</td>'+
                        /*'<td >' + Procode  + '</td>'+*/
                        '<td class="align_middle">' + manInputExecution  + '</td>'+
                        /*'<td >' + pp.manpowerExecutionPlan   + '</td>'+*/
                        '</tr>' ;
                }
                strTemp +=  '</tbody>';
                String sTemp = '<td class="sub_title">' + IntRoman(subHeadingCount) +'인력투입 계획 수립</td>';    //Adi
                strEmail = strEmail.replace('<td class="sub_title">ii. 인력투입 계획 수립</td>', sTemp);    //Adi
                subHeadingCount++;  //Adi
                strEmail = strEmail.replace('{!tableString6}', strTemp);
                datetime dt1 = Date.today();
				String sDate = String.valueOf(dt1.format('yyyy-MM-dd'));
                strEmail = strEmail.replace('{!DateValue}', sDate);
                table6 = true;
            }
            
            if(lstOpp8.Size()>0 || test.isRunningTest()){// || !isSandbox
                //table7= true;
                String strTemp = '';
                strTemp += '<thead> <tr>'+
                    '<td >사업기회 코드</th>'+
                    '<td colspan ="2" > 사업기회명 </th>'+
                    '<td colspan ="1" > 수주예상일 </th>'+
                    '<td colspan ="1" > 단계</th>'+
                    '<td class="align_right">금액</th>'+
                    '<td >원청고객 </th>'+
                    '<td >원청고객 owner </th>'+
                    '<td >계약고객 </th>'+
                    '<td >계약고객 owner</th>'+
                    '</tr></thead>';
                strTemp +=  '<tbody>';
                for(Opportunity opp : lstOpp8){
                    String str,str1;
                    if(isSandbox){
                        str = 'https://sdssfa--qa.sandbox.lightning.force.com/lightning/r/Opportunity/' + opp.Id + '/view';
                        str1 = 'https://sdssfa--qa.sandbox.lightning.force.com/lightning/r/Account/' + opp.AccountId + '/view';
                    }
                    else{
                        // String str = 'https://sdssfa.lightning.force.com/lightning/r/Opportunity/' + opp.Id + '/view'; 
                        str = 'https://sdssfa.lightning.force.com/lightning/r/Opportunity/' + opp.Id + '/view';
                        str1 = 'https://sdssfa.lightning.force.com/lightning/r/Account/' + opp.AccountId + '/view';
                    } 
                    
                    String clDate = String.valueOf(opp.CloseDate);
                    String closeDate = clDate.substring(0,10);
                    String amt = '';
                    if(opp.Amount!=null){
                        amt = String.valueOf(opp.Amount/1000000) ;
                    }
                    //  System.debug('amt Test@ :' + amt);
                    List<String> amtStr = new List<String>();
                    String num = '';
                    if(amt.contains('.')){
                        amtStr= amt.split('\\.');
                        //   System.debug('amtStr Test@ :'+amtStr);
                        num = amtStr[0] + '.' + amtStr[1].substring(0,2);
                    }
                    else{
                        if(opp.Amount!=null){
                            num = String.valueOf(opp.Amount/1000000);
                        }
                        
                        
                    }
                    strTemp +=  '<tr>'+
                        '<td class="nowrap">' + opp.OpportunityCode__c  + '</td>' +
                        '<td colspan ="2" >' + '<a style="color:blue" href="' + str + '">'+ opp.Name + '</a>' + '</td>' + 
                        '<td class="nowrap">' + closeDate + '</td>' +
                        '<td class="nowrap">' + opp.get('toLabel_StageName')+ '</td>'+ 
                        '<td class="align_right">' + formattedNumber(num) + '</td>' +
                        '<td  colspan ="1" >' + '<a style="color:blue" href="' + str1 + '">'+ opp.cOriginAcc__r.Name + '</a>' + '</td>' + 
                        '<td >' + opp.cOriginAcc__r.Owner.Name + '</td>' +
                        '<td  colspan ="1" >' + '<a style="color:blue" href="' + str1 + '">'+opp.Account.Name  +'</a>' + '</td>' + 
                        '<td >'+opp.Account.owner.name+' </td>' +
                        '</tr>' ;
                }
                strTemp +=  '</tbody>';
                String sTemp = IntRoman(subHeadingCount) +'고객 정보';    //Adi
                strEmail = strEmail.replace('iii. 고객 정보', sTemp);    //Adi
                subHeadingCount++;
                strEmail = strEmail.replace('{!tableString7}', strTemp);
                datetime dt1 = Date.today();
				String sDate = String.valueOf(dt1.format('yyyy-MM-dd'));
                strEmail = strEmail.replace('{!DateValue}', sDate);
                table7 = true;                             
            }
            
            if(lstOpp9.Size()>0 || test.isRunningTest()){//|| !isSandbox
                // table8 = true;
                String strTemp = '';
                strTemp += ' <thead><tr>'+
                    '<td >사업기회 코드</th>'+
                    '<td colspan ="2" >사업기회명 </th>'+
                    '<td > 수주예상일 </th>'+
                    
                    '<td >단계 </th>'+
                    '<td class="align_right"> 금액 </th>'+
                    
                    '</tr></thead>';
                strTemp +=  '<tbody>';
                for(Opportunity opp : lstOpp9){
                    String str; 
                    if(isSandbox){
                        str = 'https://sdssfa--qa.sandbox.lightning.force.com/lightning/r/Opportunity/' + opp.Id + '/view';
                    }
                    else{
                        str = 'https://sdssfa.lightning.force.com/lightning/r/Opportunity/' + opp.Id + '/view';    
                    }
                    
                    String clDate = String.valueOf(opp.CloseDate);
                    String closeDate = clDate.substring(0,10);
                    String amt = '';
                    if(opp.Amount!=null){
                        amt = String.valueOf(opp.Amount/1000000) ;
                    }
                    // System.debug('amt Test@ :' + amt);
                    List<String> amtStr = new List<String>();
                    String num = '';
                    if(amt.contains('.')){
                        amtStr= amt.split('\\.');
                        //  System.debug('amtStr Test@ :'+amtStr);
                        num = amtStr[0] + '.' + amtStr[1].substring(0,2);
                    }
                    else{
                        if(opp.Amount!=null){
                            num = String.valueOf(opp.Amount/1000000);
                        }
                        
                        
                    }
                    //  System.debug('amtStr Test :'+amtStr);
                    
                    strTemp +=  '<tr>'+
                        '<td class="nowrap">' + opp.OpportunityCode__c + '</td>' +
                        '<td  colspan ="2" >' + '<a style="color:blue" href="' + str + '">'+ opp.Name + '</a>' + '</td>' +
                        '<td class="nowrap">' + closeDate + '</td>' +
                        
                        '<td class="nowrap">' + opp.get('toLabel_StageName') + '</td>'+  
                        '<td class="align_right">' +num + '</td>' +
                        
                        '</tr>' ;
                }
                strTemp +=  '</tbody>';
                String sTemp = IntRoman(subHeadingCount) +'SCP 견적 미등록건';    //Adi
                strEmail = strEmail.replace('iv. SCP 견적 등록', sTemp);    //Adi
                subHeadingCount++;
                strEmail = strEmail.replace('{!tableString8}', strTemp);
                datetime dt1 = Date.today();
				String sDate = String.valueOf(dt1.format('yyyy-MM-dd'));
                strEmail = strEmail.replace('{!DateValue}', sDate);
                table8 = true; 
                
                
            }
            
            //Adi Complete If Else
            if(lstOpp5.Size()==0 && lstOpp6.Size()==0 && lstOpp7.Size()==0 && lstOpp8.Size()==0 && lstOpp9.Size()==0){
                String cs = 'CSP_SCP';
                strEmail = strEmail.replace('<tr><td class="box_padding"><p class="title">3. 사업수행 사전준비</p><div class="sub_table_wrap">', '');
                strEmail = strEmail.replace('<p class="sub_title">i. 수전위 사전준비</p><p class="text">사참 수전위는 수주예상일 2개월전, 입찰 수전위는 수주예상일 2주전 완료해 주시기 바랍니다.<br>- PM: 자가점검 체크리스트 수행, 인력투입계획 수립, 수전위 원가판 편성<br>- 영업대표: 수전위 원가판 확정 </p><p class="gray_text">※ 심의부서에 체크리스트 심의의견 작성시 참고 할 수 있는 보고서, RFP, 제안서 등을 공유하여 주시기 바랍니다. </p><table class="table box_margin">{!tableString4}</table><table class="table box_margin">{!tableString5}</table>', '');
                strEmail = strEmail.replace('<table class="title_wrap"><tr><td class="sub_title">ii. 인력투입 계획 수립</td><td class="title_small">수주예상일 3개월 전 인력투입 계획을 수립해 주시기 바랍니다.</td></tr></table><table class="table box_margin">{!tableString6}</table>', '');
                strEmail = strEmail.replace('<table class="title_wrap"><tr><td class="sub_title">iii. 고객 정보</td><td class="title_small">opendart 정보가 원청고객/계약고객에 대해 현행화 되었으므로 이를 확인하시어 고객 정보를 현행화 하시기 바랍니다</td></tr></table><table class="table box_margin">{!tableString7}</table>', '');
                strEmail = strEmail.replace('<table class="title_wrap"><tr><td class="sub_title">iv. SCP 견적 등록</td><td class="title_small">사업유형(상세)을 '+ '\''+ cs + '\'' +'로 등록한 사업기회는 수주예상일 3개월 전 SCP 견적을 등록해 주시기 바랍니다</td></tr></table><table class="table">{!tableString8}</table>', '');
            }else{  //Adi
                String sTemp = '<p class="title">' + count + '. 사업수행 사전준비</p>';
                system.debug('Count inside Main table 3 : '+ count);
                strEmail = strEmail.replace('<p class="title">3. 사업수행 사전준비</p>', sTemp);
                count = count +1;
            }
            
            Boolean d = false;
            if(lstOpp5.Size()==0){
                strEmail = strEmail.replace('<table class="table box_margin">{!tableString4}</table>', '');
                d= true; 
            }
            
            Boolean e = false;
            if(lstOpp6.Size()==0){
                strEmail = strEmail.replace('<table class="table box_margin">{!tableString5}</table>', '');  
                e= true;  
            } 
            
            Boolean f = false;
            if(lstOpp7.Size()==0){
                f= true; 
                strEmail = strEmail.replace('<table class="title_wrap"><tr><td class="sub_title">ii. 인력투입 계획 수립</td><td class="title_small">수주예상일 3개월 전 인력투입 계획을 수립해 주시기 바랍니다.</td></tr></table><table class="table box_margin">{!tableString6}</table>', '');   
            }
            
            Boolean g = false;
            if(lstOpp8.Size()==0){
                strEmail = strEmail.replace('<table class="title_wrap"><tr><td class="sub_title">iii. 고객 정보</td><td class="title_small">opendart 정보가 원청고객/계약고객에 대해 현행화 되었으므로 이를 확인하시어 고객 정보를 현행화 하시기 바랍니다</td></tr></table><table class="table box_margin">{!tableString7}</table>', '');  
                g= true;  
            }
            
            Boolean h = false;
            if(lstOpp9.Size()==0){
                String cs = 'CSP_SCP';  
                strEmail = strEmail.replace('<table class="title_wrap"><tr><td class="sub_title">iv. SCP 견적 등록</td><td class="title_small">사업유형(상세)을 '+ '\''+ cs + '\'' +'로 등록한 사업기회는 수주예상일 3개월 전 SCP 견적을 등록해 주시기 바랍니다</td></tr></table><table class="table">{!tableString8}</table>', ''); 
                h= true;  
            }
            
            lstOpp5 = null; 
            lstOpp6 = null;
            lstOpp7 = null;
            lstOpp8 = null;
            lstOpp9 = null;
        }else{
            String cs = 'CSP_SCP';
            strEmail = strEmail.replace('<tr><td><table class="title_wrap"><tr><td class="title">1. 연간 누적 사업기회 수주 현황<a class="add_btn" href="https://sdssfa.lightning.force.com/lightning/r/Report/00O2w00000E3Zv5EAF/view?queryScope=userFolders">수주완료 상세보기</a></td></tr></table><table class="table">{!tableString1}</table> <ul class="gray_text"><li>수주완료 건수 : \'Curent_Year년 수주/변경 품의 BO 건수 (수주 변경금액이 0원인 경우 제외, 동일한 BO번호는 1건으로 집계)</li><li2>수주완료 금액 : \'Curent_Year년 수주금액 및 수주 변경금액(차액) 의 합계 </li2><li>변경 품의 금액은 해당 BO 의 Related > Opportunity Amount 에서 확인 가능합니다.</li></ul></td></tr>','');//※ 수주 변경한 BO의 수주금액은 변경분(차액)으로 집계됩니다. // MYSALES-361 V 1.0 css end
            strEmail = strEmail.replace('<tr><td class="box_padding"><p class="title">2. 지연 BO 및 수주 예상일 도래 BO</p><div class="sub_table_wrap">', '');
            strEmail = strEmail.replace('<table class="title_wrap"><tr><td class="sub_title">i. 지연 BO</td></tr></table><table class="table box_margin">{!tableString2}</table>', '');
            strEmail = strEmail.replace('<table class="title_wrap"><tr><td class="sub_title">ii. 수주예상일 도래 BO (D-13)</td></tr></table><table class="table">{!tableString3}</table>', '');
            strEmail = strEmail.replace('<tr><td class="box_padding"><p class="title">3. 사업수행 사전준비</p><div class="sub_table_wrap">', '');
            strEmail = strEmail.replace('<p class="sub_title">i. 수전위 사전준비</p><p class="text">사참 수전위는 수주예상일 2개월전, 입찰 수전위는 수주예상일 2주전 완료해 주시기 바랍니다.<br>- PM: 자가점검 체크리스트 수행, 인력투입계획 수립, 수전위 원가판 편성<br>- 영업대표: 수전위 원가판 확정 </p><p class="gray_text">※ 심의부서에 체크리스트 심의의견 작성시 참고 할 수 있는 보고서, RFP, 제안서 등을 공유하여 주시기 바랍니다. </p><table class="table box_margin">{!tableString4}</table><table class="table box_margin">{!tableString5}</table>', '');
            strEmail = strEmail.replace('<table class="title_wrap"><tr><td class="sub_title">ii. 인력투입 계획 수립</td><td class="title_small">수주예상일 3개월 전 인력투입 계획을 수립해 주시기 바랍니다.</td></tr></table><table class="table box_margin">{!tableString6}</table>', '');
            strEmail = strEmail.replace('<table class="title_wrap"><tr><td class="sub_title">iii. 고객 정보</td><td class="title_small">opendart 정보가 원청고객/계약고객에 대해 현행화 되었으므로 이를 확인하시어 고객 정보를 현행화 하시기 바랍니다</td></tr></table><table class="table box_margin">{!tableString7}</table>', '');
            strEmail = strEmail.replace('<table class="title_wrap"><tr><td class="sub_title">iv. SCP 견적 등록</td><td class="title_small">사업유형(상세)을 '+ '\''+ cs + '\'' +'로 등록한 사업기회는 수주예상일 3개월 전 SCP 견적을 등록해 주시기 바랍니다</td></tr></table><table class="table">{!tableString8}</table>', '');
            
        }
        
        //Only fot Testing - Table 4
        String strTemp4 = '';
        string strTemp42 = '';
        strTemp4 += '<thead> <tr >'+
            // '<td > 사업기회 코드 </th>'+
            
            '<td >사업기회</th>'+ //사업기회명
            // '<td > 유사 사업기회 코드 </th>'+
            
            '<td > 유사 사업기회</th>'+
            '<td >수주예상일 </th>'+ //유사 사업기회 수주예상일
            
            '<td >단계</th>'+// 유사 수주예상액 // 유사 사업기회 수주금액 
            '<td class="align_right">금액</th>'+// 유사 사업기회 상태 // 유사 사업기회 단계 
            
            '<td >사업 심의 유형</th>'+//유사 사업기회 수전위 유형 // 유사 사업기회 사업 심의 유형 
            '<td > 제안서</th>'+
            //'<td >실행</th>'+
            // '<td style="text-align:center; padding: 13px 0px 12px 0"> 위험</th>'+
            '<td >영업대표</th>'+//유사 사업기회 영업대표 
            '<td >제안PM</th>'+ //유사 사업기회 제안PM       
            '</tr></thead>';
        //Added By Ashish
        if(lstOppTable4.size() > 0){
            strEmail = strEmail.replace('{!table9SubHeading}', '신규 등록한 BO의 유사사업기회 정보입니다. 사업 수행시 참고해주세요. (업종, 사업등급, 솔루션 기준)'); 
            
            for(Opportunity opp : lstOppTable4) {
                integer i =0;
                
                //  system.debug('ashish OpptyMatchingMap::'+OpptyMatchingMap);
                if(OpptyMatchingMap != NULL && OpptyMatchingMap.containskey(opp.Id) && OpptyMatchingMap.get(opp.Id) != null){
                    
                    
                    integer matchedOPSize = OpptyMatchingMap.get(opp.Id).size();
                    for(Id matchedOPID :  OpptyMatchingMap.get(opp.Id)){
                        if(matchedoppLst != null){
                            Opportunity matchedopp = matchedoppLst.get(matchedOPID);
                            String clDate = String.valueOf(matchedopp.CloseDate);
                            String closeDate = clDate.substring(0,10);
                            
                            List<Opportunity_Activity__c> oAct = new List<Opportunity_Activity__c>();
                            oAct = matchedopp.BO_Activity__r;
                            String amt = '0';
                            if(matchedopp.Amount != null)
                                amt = String.valueOf(matchedopp.Amount/1000000) ;
                            //  System.debug('amt Test@ :' + amt);
                            List<String> amtStr = new List<String>();
                            String num = '';
                            if(amt.contains('.')){
                                amtStr= amt.split('\\.');
                                //  System.debug('amtStr Test@ :'+amtStr);
                                num = amtStr[0] + '.' + amtStr[1].substring(0,2);
                            }
                            else{
                                if(matchedopp.Amount != null)
                                    num = String.valueOf(matchedopp.Amount/1000000);
                            }
                            
                            
                            strTemp42 +=  '<tr >';
                            // if(i==0) strTemp42 += '<td class="align_right" rowspan="'+matchedOPSize+'" >' + opp.OpportunityCode__c + '</td>' ;
                            if(i==0) strTemp42 += '<td class=" etst " rowspan="'+matchedOPSize+'" >' + '<a style="color:blue" href="' + 'https://sdssfa.lightning.force.com/lightning/r/Opportunity/'+opp.Id+'/view' + '">'+ opp.Name + '</a>' + '</td>' ;
                            i++;
                            
                            // strTemp42 += '<td class="align_right">' + matchedopp.OpportunityCode__c + '</td>' +
                            
                            strTemp42 +=  '<td class="">' + '<a style="color:blue" href="' + 'https://sdssfa.lightning.force.com/lightning/r/Opportunity/'+matchedopp.Id+'/view' + '">'+ matchedopp.Name + '</a>' +  '</td>' +
                                '<td class="nowrap">' + closeDate + '</td>'+
                                
                                '<td class="nowrap">' + matchedopp.get('toLabel_StageName') + '</td>' +
                                '<td class="align_right">' + formattedNumber(num) + '</td>' +
                                '<td class="">' + vrbTypeValues(matchedopp.Opportunity_Review_VRB_Type_Confirm__c) + '</td>' ;
                            
                            //dynamic link logic start rakshit.s@samsung.com
                            
                            if(oAct!=null && oAct.size()>0 && matchedopp.companycode__c == 'T100'){
                                strTemp42 +='<td class="">' + '<a style="color:blue" href="' + 'http://70.225.5.3:2007/ArisamWeb/proposal/viewPage.do?catcode=A042&orderId='+matchedopp.Opportunitycode__c+ '">'+'<p style = "font-size:x-large">•</p>'+'</a>'+'</td>'; //companycode__c
                            } 
                            else{
                                strTemp42 +='<td class="">'+ '</td>';
                            }
                            //dynamic link logic END rakshit.s@samsung.com
                            //strTemp42 += '<td class="align_right"style="text-align: right;padding: 6px 16px 6px 6px; ">' + '<a style="color:blue" href="">'+ '<p style = "font-size:x-large">•</p>' + '</a>' + '</td>';
                            // '<td class="align_right">' + '</td>'; 
                            //if(matchedopp.RepresentativePM__c != null) strTemp42 +=  '<td class="align_right">' + '<a style="color:blue" href="' + 'https://sdssfa.lightning.force.com/lightning/'+matchedopp.RepresentativePM__c+'' + '">'+ matchedopp.RepresentativePM__r.Name + '</a>' +     '</td>';
                            //else strTemp42 +=  '<td class="align_right"></td>';
                            //strTemp42 +=  '<td class="align_right">' + '<a style="color:blue" href="' + 'https://sdssfa.lightning.force.com/lightning/'+matchedopp.Ownerid+'' + '">'+ matchedopp.Owner.Name + '</a>' +     '</td>';
                            //if(matchedopp.ProposalPM__c != null) strTemp42 +=  '<td class="align_right">' +  '<a style="color:blue" href="' + 'https://sdssfa.lightning.force.com/lightning/'+matchedopp.ProposalPM__c+'' + '">'+ matchedopp.ProposalPM__r.Name + '</a>' +  '</td>';
                            
                            strTemp42 +=  '<td class="">' + matchedopp.Owner.Name +    '</td>';
                            if(matchedopp.ProposalPM__c != null) strTemp42 +=  '<td class="">' +   matchedopp.ProposalPM__r.Name  +  '</td>';
                            else strTemp42 +=  '<td class="">  </td>' ;
                            
                            strTemp42 +=  '</tr>' ;
                        }
                    }
                }
            }
            
            //Logic to remove extra Line from every Master BO
			List<String> tt = strTemp42.split(' ');
			List<Integer> indextoremove = new List<Integer>();
			//Integer wordCount = 0;
			Integer lastindex = -1;
			for(Integer i=0 ; i< tt.size() ; i++){
    			if(tt[i] == 'etst'){
        			if(lastindex != -1){
            			indextoremove.add(lastindex);
        			}
        			lastindex = i;
    			}
			}
			for(integer i = indextoremove.size() -1 ; i>=0 ; i--){
    			tt.remove(indextoremove[i]);
			}
		
			strTemp42 = String.join(tt, ' ');
			//System.debug('final table 9 body : ' + strTemp42);
            
            String sTemp = '<td class="title">' + count + '. 유사 사업기회 정보 <a class="add_btn" href="https://sdssfa.lightning.force.com/lightning/n/Opportunity_Search">Opportunity Search</a></td>';
            system.debug('Count inside Main table 4 : '+ count);
            strEmail = strEmail.replace('<td class="title">4. 유사 사업기회 정보 <a class="add_btn" href="https://sdssfa.lightning.force.com/lightning/n/Opportunity_Search">Opportunity Search</a></td>', sTemp);
            count = count +1;
            if(String.isnotblank(strTemp42)){
                masterTable4 = true;
                strTemp4 = strTemp4 +' <tbody>'+ strTemp42+'</tbody>';
                strEmail = strEmail.replace('{!tableString9}', strTemp4);
            }
            else{
                strEmail = strEmail.replace('{!tableString9}', '');
                strEmail = strEmail.replace(sTemp, '');
                strEmail = strEmail.replace('<td class="title_small">신규 등록한 BO의 유사사업기회 정보입니다. 사업 수행시 참고해주세요. (업종, 사업등급, 솔루션 기준)</td></tr></table>', '');
                strEmail = strEmail.replace('<a class="add_btn" href="https://sdssfa.lightning.force.com/lightning/n/Opportunity_Search">Opportunity Search</a>', '');
            }
            
        }
        if(lstOppTable4.size() == 0){
            strEmail = strEmail.replace('<tr><td class="box_padding"><table class="title_wrap"><tr><td class="title">4. 유사 사업기회 정보 <a class="add_btn" href="https://sdssfa.lightning.force.com/lightning/n/Opportunity_Search">Opportunity Search</a></td><td class="title_small">신규 등록한 BO의 유사사업기회 정보입니다. 사업 수행시 참고해주세요. (업종, 사업등급, 솔루션 기준)</td></tr></table><table class="table">{!tableString9}</table>', '');
            //strEmail = strEmail.replace('{!table9SubHeading}', ''); 
            strEmail = strEmail.replace('<a style=" background-color:blue;color:white" href="https://sdssfa.lightning.force.com/lightning/n/Opportunity_Search">Opportunity Search</a>', '');
        }
        
        //Adi Complete If Else Block
        lstOppTable4 = null;
        system.debug('Final StrEmail Length : ' + strEmail.length());
        system.debug('Final StrEmail data : ' + strEmail);
        
        for(User usr : listScope){
            String htmlvalue = '';
            //strEmailTemp = strEmail;
            List<String> emUser = new List<String>();
            emUser.add(usr.Email);
            datetime dt1 = Date.today();
			String sDate = String.valueOf(dt1.format('yyyy-MM-dd'));
            //  System.debug('Ani strEmailTemp : '+strEmail);
            htmlvalue  += '<tr style="background-color: #eeeeee;">' + '<td class="align_right" colspan="2" style="text-align: center;font-weight: bold;">'+usr.Name+'</td>' + '<td class="align_right" style="font-weight: bold;">'+usr.Id+'</td>' + '<td class="align_right" style="text-align: right;font-weight: bold;">'+usr.Id+'</td>' + '</tr>';
            strEmail = strEmail.replace('{!tableString1}', '');
            strEmail = strEmail.replace('{!tableString2}', '');
            strEmail = strEmail.replace('{!tableString3}', '');
            strEmail = strEmail.replace('{!tableString4}', '');
            strEmail = strEmail.replace('{!tableString5}', '');
            //  system.debug('tableString6 1080');
            strEmail = strEmail.replace('{!tableString6}', '');
            strEmail = strEmail.replace('{!tableString7}', '');
            strEmail = strEmail.replace('{!tableString8}', '');
            strEmail = strEmail.replace('{!tableString9}', '');
            strEmail = strEmail.replace('{!DateValue}', sDate);
            //System.debug('Ani strEmail : '+strEmail);
            if(isSandbox){
                system.debug('inside email send logic sandbox');
                if(!Test.isRunningTest()){
                    system.debug( 'allemptycheck' + table1 + table2 + table3+ table4+ table5+ table6+ table7 + table8 + mastertable + mastertable4);
                    
                    if(mastertable){
                        system.debug('mainlistpopulated');
                        if(!table1 && !table2 && !table3 && !table4 && !table5 && !table6 && !table7 && !table8 && !mastertable4){
                            //create if log
                            system.debug('otherlistzero');
                            userInfoWrap uu = new userInfoWrap();
                            uu.Name = usr.Name;
                            uu.UserId = usr.Id;
                            userWrap.add(uu);
                        }
                        else{
                            // sendEmail
                            system.debug('createtable');
                            mailresult = OpportunityEmailAlertController.sendKnoxEmailMulti(senderEmployee, usr.Id, toList, ccList, bccList, strTitle, strEmail, efileList, nfileList);
                            if(mailresult.get('KnoxEmail') != null) KnoxEmailList.add((KnoxEmail__c)mailresult.get('KnoxEmail')); //Added by Anish - New
                        
                        }
                        
                    }
                    
                    else
                    {
                        system.debug('mainlistnull');
                        //create if log
                        userInfoWrap uu = new userInfoWrap();
                        uu.Name = usr.Name;
                        uu.UserId = usr.Id;
                        userWrap.add(uu);
                    }
                    
                    
                    
                    // mailresult = OpportunityEmailAlertController.sendKnoxEmailMulti(senderEmployee, usr.Id, toList, ccList, bccList, strTitle, strEmail, efileList, nfileList);
                    // system.enqueueJob(new Queueable_WeeklySalesReport(senderEmployee, usr.Id, toList, ccList, bccList, strTitle, strEmail, efileList, nfileList));
                } 
                if(mailresult.get('INTERFACE_LOG') != null){
                    ifLog.add((IF_Log.InterfaceLog)mailresult.get('INTERFACE_LOG'));
                } 
            }
            else{
                system.debug('inside email send logic sandbox');
                if(!Test.isRunningTest()){
                    system.debug( 'allemptycheck' + table1 + table2 + table3+ table4+ table5+ table6+ table7 + table8 + mastertable + mastertable4);
                    
                    if(mastertable || mastertable4 || table1){
                        system.debug('mainlistpopulated');
                        if(!table1 && !table2 && !table3 && !table4 && !table5 && !table6 && !table7 && !table8 && !mastertable4){
                            //create if log
                            system.debug('otherlistzero');
                            userInfoWrap uu = new userInfoWrap();
                            uu.Name = usr.Name;
                            uu.UserId = usr.Id;
                            userWrap.add(uu);
                        }
                        else{
                            // sendEmail
                            system.debug('createtable');
                            //mailresult = OpportunityEmailAlertController.sendKnoxEmailMulti(senderEmployee, usr.Id, toList, ccList, bccList, strTitle, strEmail, efileList, nfileList);
                            if(!Test.isRunningTest()) mailresult = OpportunityEmailAlertController.sendKnoxEmailMulti(senderEmployee, usr.Id, toList, ccList, bccList, strTitle, strEmail, efileList, nfileList);
                            if(mailresult.get('KnoxEmail') != null) KnoxEmailList.add((KnoxEmail__c)mailresult.get('KnoxEmail')); //Added by Anish - New
                            //system.debug('Knox Email List : '+ (KnoxEmail__c)mailresult.get('KnoxEmail'));
                            KnoxEmail__c ke = (KnoxEmail__c)mailresult.get('KnoxEmail');
                            //system.debug('Knox Email HTML Body Size' +  ke.HtmlBody__c.length());
                            //system.debug('Knox Email HTML Body : ' + ke.HtmlBody__c);
                            if(mailresult.get('INTERFACE_LOG') != null){
                                ifLog.add((IF_Log.InterfaceLog)mailresult.get('INTERFACE_LOG')); 
                                IF_Log.InterfaceLog temp = (IF_Log.InterfaceLog)mailresult.get('INTERFACE_LOG');
                                //Map<String,Object> parsedVal = (Map<String,Object>) temp;
                                if(temp.ErrorMessage != null){
                                    userInfoWrap uu = new userInfoWrap();
                                    uu.Name = usr.Name;
                                    uu.UserId = usr.Id;
                                    uu.isfailure = true;
                                    userWrap.add(uu);
                                }
                                
                            } 
                        }
                        
                    }
                    
                    else
                    {
                        system.debug('mainlistnull');
                        //create if log
                        userInfoWrap uu = new userInfoWrap();
                        uu.Name = usr.Name;
                        uu.UserId = usr.Id;
                        userWrap.add(uu);
                    }
                    
                    
                    
                    // mailresult = OpportunityEmailAlertController.sendKnoxEmailMulti(senderEmployee, usr.Id, toList, ccList, bccList, strTitle, strEmail, efileList, nfileList);
                    // system.enqueueJob(new Queueable_WeeklySalesReport(senderEmployee, usr.Id, toList, ccList, bccList, strTitle, strEmail, efileList, nfileList));
                } 
                //existing start
                
                //existing end
            }
        }
        table1= false; table2=false;  table3=false; table4=false; table5=false; table6=false; table7=false; table8=false;  mastertable = false; mastertable4=false;
    }
    
    public void finish(Database.BatchableContext BC){
        System.debug('### Batch_OpptyEmailController :: finish--->' + allLog.size());        
        System.debug('### Batch_OpptyEmailController :: finish :: ifLog.size() : ' + ifLog.size());
        Integer countFailure = 0;
        Integer countNotSent = 0;
        if(ifLog.size() > 0){
            IF_Log log = new IF_Log();
            log.createLog(ifLog);
        }
        //Start- Added by Anish - New
        System.debug('KnoxEmailList.size() : ' + KnoxEmailList.size());
        
        if(KnoxEmailList.size() > 0){
           system.debug('Knox email final : '+ KnoxEmailList[0].HtmlBody__c.length());
        	system.debug('Knox email final : '+ KnoxEmailList[0].HtmlBody__c); 
            for(KnoxEmail__c km : KnoxEmailList){
                if(km.HtmlBody__c.length() > 32000)
                	km.HtmlBody__c = km.HtmlBody__c.substring(0, 32000) + ' ..... to be continued';
            }
            insert KnoxEmailList;
        } 
        //End- Added by Anish - New
        if(userWrap.size()>0){
            for (userInfoWrap wrap : userWrap) {
                if(wrap.isfailure){                   
                    countFailure++;
                }else{
                    countNotSent++;
                }               
            }
            createInterfaceLog(userWrap);
        }
        
        if(allLog.size()>0){
            insert allLog;
        }
        
		IF_Log__c log = new IF_Log__c();
        log.ApexName__c = 'Batch_WeeklySalesReport'; 
        log.ApexMethod__c =  'finsih';
        log.InterfaceId__c = 'Batch_WeeklySalesReport_Status';
        log.LogText__c = 'S Count : '+ KnoxEmailList.size() + '\n' + 'F Count : ' + countFailure + '\n' + 'Total Count : '+ (KnoxEmailList.size() + countFailure) + '\n' + 'W(Not sent) : ' + countNotSent;
        log.StatusCode__c = 'S';
        log.LogType__c = 'Mailing';
        log.EndDatetime__c  = System.now();
        log.StartDatetime__c = System.now();
        insert log;
        
    }
    
    public void execute(SchedulableContext SC){
        DataBase.executeBatch(new Batch_WeeklySalesReport_Ashish(), 1);
    }    
    public  proposalPMInfo getTable6ProposalPMData(List<TXPmanpower__c> tx , List<Project__c> allProjects , Opportunity currentOp){
        system.debug('inside getTable6ProposalPMData');
        boolean projectCodeMatch = false;
        proposalPMInfo pp =new proposalPMInfo();
        if((tx!=null && tx.size()>0) /*&& allProjects.size()>0*/){
            system.debug('txn present');
            if(tx[0].ProposalPMStatus__c==null){
                system.debug('txn 1st condition');
                pp.possibility = 'Y';
                pp.scheduleString = '';
                pp.manpowerInputPlan = tx[0].ProposalPMPlan__c;
                pp.manpowerExecutionPlan = tx[0].ExecutionPMPlan__c;
                //return pp;
            }
            
            else{
                system.debug('first else');
                if(allProjects!=null && allProjects.size()>0){
                    system.debug('project present');
                    for(Project__c pro : allProjects){
                        if(pro.ProjectCode__c == tx[0].P_Projectcode__c){
                            projectCodeMatch = true;
                            break;
                        }
                    }
                    
                    if(projectCodeMatch){
                        system.debug('codematch');
                        pp.possibility = 'Y';
                        pp.scheduleString = '';
                        pp.manpowerInputPlan = tx[0].ProposalPMPlan__c;
                        pp.manpowerExecutionPlan = tx[0].ExecutionPMPlan__c;
                        //return pp;
                    }
                    
                    else{
                        system.debug('code no match');
                        if(tx[0].ProposalPMEdDt__c < currentOp.cRevenueStartDate__c){
                            system.debug('date less than start date');
                            pp.possibility = 'Y';
                            String clDate1 = String.valueOf(tx[0].ProposalPMStDt__c);
                            String closeDate1 = clDate1.substring(0,10);
                            String clDate2 = String.valueOf(tx[0].ProposalPMEdDt__c);
                            String closeDate2 = clDate2.substring(0,10);
                            
                            //pp.scheduleString = tx[0].ProposalPMStDt__c +'~' + tx[0].ProposalPMEdDt__c;
                            pp.scheduleString = closeDate1 +'~' + closeDate2 + '<br/>' + tx[0].P_Projectname__c;
                            pp.manpowerInputPlan = tx[0].ProposalPMPlan__c;
                            pp.manpowerExecutionPlan = tx[0].ExecutionPMPlan__c;
                            // return pp;
                        }
                        
                        else{
                            system.debug('first not available');
                            pp.possibility = 'N';
                            String clDate1 = String.valueOf(tx[0].ProposalPMStDt__c);
                            String closeDate1 = clDate1.substring(0,10);
                            String clDate2 = String.valueOf(tx[0].ProposalPMEdDt__c);
                            String closeDate2 = clDate2.substring(0,10);
                            
                            //pp.scheduleString = tx[0].ProposalPMStDt__c +'~' + tx[0].ProposalPMEdDt__c;
                            pp.scheduleString = closeDate1 +'~' + closeDate2 + '<br/>' + tx[0].P_Projectname__c;
                            pp.manpowerInputPlan = tx[0].ProposalPMPlan__c;
                            pp.manpowerExecutionPlan = tx[0].ExecutionPMPlan__c;
                            //return pp;
                        }
                    }
                }
                else{
                    
                    system.debug('no Project Data');
                    if(tx[0].ProposalPMStatus__c!=null){
                        
                        if(tx[0].ProposalPMEdDt__c < currentOp.cRevenueStartDate__c){
                            system.debug('date less than start date');
                            pp.possibility = 'Y';
                            String clDate1 = String.valueOf(tx[0].ProposalPMStDt__c);
                            String closeDate1 = clDate1.substring(0,10);
                            String clDate2 = String.valueOf(tx[0].ProposalPMEdDt__c);
                            String closeDate2 = clDate2.substring(0,10);
                            
                            //pp.scheduleString = tx[0].ProposalPMStDt__c +'~' + tx[0].ProposalPMEdDt__c;
                            pp.scheduleString = closeDate1 +'~' + closeDate2 + '<br/>' + tx[0].P_Projectname__c;
                            pp.manpowerInputPlan = tx[0].ProposalPMPlan__c;
                            pp.manpowerExecutionPlan = tx[0].ExecutionPMPlan__c;
                            // return pp;
                        }
                        
                        else{
                            system.debug('first not available');
                            pp.possibility = 'N';
                            String clDate1 = String.valueOf(tx[0].ProposalPMStDt__c);
                            String closeDate1 = clDate1.substring(0,10);
                            String clDate2 = String.valueOf(tx[0].ProposalPMEdDt__c);
                            String closeDate2 = clDate2.substring(0,10);
                            
                            //pp.scheduleString = tx[0].ProposalPMStDt__c +'~' + tx[0].ProposalPMEdDt__c;
                            pp.scheduleString = closeDate1 +'~' + closeDate2 + '<br/>' + tx[0].P_Projectname__c;
                            pp.manpowerInputPlan = tx[0].ProposalPMPlan__c;
                            pp.manpowerExecutionPlan = tx[0].ExecutionPMPlan__c;
                            //return pp;
                        }
                    }
                    
                    if(tx[0].ProposalPMEdDt__c==null && tx[0].ProposalPMStDt__c==null){
                        pp.possibility = 'Y';
                        pp.scheduleString = '';
                        pp.manpowerInputPlan = '';
                        pp.manpowerExecutionPlan = '';
                    }
                }
            }
        }
        
        else{
            system.debug('txn not present');
            pp.possibility = 'Y';
            pp.scheduleString = '';
            pp.manpowerInputPlan = '';
            pp.manpowerExecutionPlan = '';
            
            //adding error wrapper record
            
            /*  userInfoWrap uu = new userInfoWrap();
uu.Name = usr.Name;
uu.UserId = usr.Id;
userWrap.add(uu);*/
            //return pp;
            //
            IF_Log__c log = new IF_Log__c();
            log.ApexName__c = 'Batch_WeeklySalesReport'; 
            log.ApexMethod__c =  'execute';
            log.InterfaceId__c = 'ERR_MAILING_HQ_REP';
            log.LogText__c = 'TXP :' +  currentOp.CompanyCode__c + 'BO Code:' + currentOp.OpportunityCode__c;
            log.StatusCode__c = 'W';
            log.LogType__c = 'Mailing';
            log.EndDatetime__c  = System.now();
            log.StartDatetime__c = System.now();
            System.debug( 'No TXP Found'+ log);
            //insert log;
            allLog.add(log);
        }
        return pp;
    }
    
    public class proposalPMInfo{
        Public String possibility = '';
        public String scheduleString = '';
        public String manpowerInputPlan = '';
        public String manpowerExecutionPlan = '';
    }
    
    public static string IntRoman(Integer i){
        system.debug('trying to save');
        if(i == 1) return '(1)';
        if(i == 2) return '(2)';
        if(i == 3) return '(3)';  
        if(i == 4) return '(4)';
        if(i == 5) return '(5)';
        return '';
    }
    
    public static string vrbTypeValues(String vrbTypeVal){
        String BO_Strategy_Type = '';
        
        if(vrbTypeVal == '10' ) BO_Strategy_Type = '전사';
        else if(vrbTypeVal == '20') BO_Strategy_Type = '사업부';
        else if(vrbTypeVal == '21') BO_Strategy_Type = 'AM 담당';
        
        return BO_Strategy_Type;
    }
    
    public static Map<id,opportunity> setupTable9(List<opportunity> mySalesTable4,Map<id,opportunity> matchedoppLst, Map<id,set<id>> OpptyMatchingMap){
        Integer counterouterLoop = 0;
        Integer counterInnerLoop = 0;
        Map<id,Opportunity> oppList =new Map<id,Opportunity>();
        String oppOwnerId;
        system.debug('ashish  oppList'+oppList);
        Set<String> opptybiz1IdSet = new Set<String>();
        Set<String> opptybiz2IdSet = new Set<String>();
        Set<String> opptybussLabelIdSet = new Set<String>();
        for(Opportunity opp : mySalesTable4){
            oppList.put(opp.id,opp);
            oppOwnerId = String.valueOf(opp.OwnerId);
            //          oppIds.add(opp.id);
            if(opp.OriginAcc_BizTypeL1__c != null)
                opptybiz1IdSet.add(opp.OriginAcc_BizTypeL1__c);
            if(opp.OriginAcc_BizTypeL2__c != null)
                opptybiz2IdSet.add(opp.OriginAcc_BizTypeL2__c);
            if(opp.BusinessLevel__c != null)
                opptybussLabelIdSet.add(opp.BusinessLevel__c);
        }
        Map<id,Set<String>> opptyServiceMap = new Map<id,Set<String>>();
        Map<id,Set<String>> opptySolMap = new Map<id,Set<String>>();
        Set<String> opptySerIdSet = new Set<String>();
        Set<String> opptySolIdSet = new Set<String>();
        system.debug(' ashish oppList.keyset()'+oppList.keyset());
        system.debug(' ashish oppList'+oppList);
        
        for(Service__c serObj:[SELECT Id , Name ,sService__r.Name, sService__r.TechAttribute__c , Opportunity__c
                               FROM Service__c
                               WHERE Opportunity__c IN : oppList.keyset()  AND sDeletionFlag__c = false  ORDER BY sService__r.Name ASC]){
                                   opptySerIdSet.add(serObj.sService__r.Name);
                                   if(opptyServiceMap.containskey(serObj.Opportunity__c)) {
                                       set<String> servName = opptyServiceMap.get(serObj.Opportunity__c);
                                       servName.add(serObj.sService__r.Name);
                                       opptyServiceMap.put(serObj.Opportunity__c,servName);
                                   }
                                   else{
                                       set<String> servName = new Set<String>();
                                       servName.add(serObj.sService__r.Name);
                                       opptyServiceMap.put(serObj.Opportunity__c,servName);
                                   }
                               } 
        
        for(Solution__c serObj:[ SELECT Id , Name , Service__c , sSolution__r.Name,Opportunity__c
                                FROM Solution__c
                                WHERE Opportunity__c in: oppList.keyset() AND sDeletionFlag__c = false
                                ORDER BY sSolution__r.Name ASC
                               ]){
                                   opptySolIdSet.add(serObj.sSolution__r.Name);
                                   if(opptySolMap.containskey(serObj.Opportunity__c)) {
                                       set<String> servName = opptySolMap.get(serObj.Opportunity__c);
                                       servName.add(serObj.sSolution__r.Name);
                                       opptySolMap.put(serObj.Opportunity__c,servName);
                                   }
                                   else{
                                       set<String> servName = new Set<String>();
                                       servName.add(serObj.sSolution__r.Name);
                                       opptySolMap.put(serObj.Opportunity__c,servName);
                                   }
                               }
        
        //Map<id, set<id>> OpptyMatchingMap = new Map<id, set<id>>() ;
        matchedoppLst = new Map<Id,Opportunity>([Select Id, companycode__c,OpportunityCode__c,Opportunity_Review_VRB_Type_Confirm__c,Opportunity_Review_Confirm__c, (select TransactionName__c,Status__c from BO_Activity__r where transactionname__c='ZP61' and status__c='Completed') , ProposalPM__c,RepresentativePM__c,ProposalPM__r.name,RepresentativePM__r.name,OriginAcc_BizTypeL1__c,OriginAcc_BizTypeL2__c,BusinessLevel__c,name,closedate,convertcurrency(amount),StageName,toLabel(StageName) toLabel_StageName,ownerid, owner.name From Opportunity where  OriginAcc_BizTypeL1__c in:opptybiz1IdSet  AND OriginAcc_BizTypeL2__c in:opptybiz2IdSet  AND BusinessLevel__c in:opptybussLabelIdSet  and RecordType.Name = 'HQ' and id in (SELECT opportunity__c from service__c where sService__r.Name in :opptySerIdSet  AND sDeletionFlag__c = false) and id in (SELECT opportunity__c from solution__c where sSolution__r.Name in :opptySolIdSet  AND sDeletionFlag__c = false) and (closedate = LAST_N_YEARS:4 OR closedate = THIS_YEAR) and CompanyCode__c = 'T100' AND stagename != 'Z08' AND OwnerId != : oppOwnerId order by BO1stRegistrationDate__c desc LIMIT 50000]); //and id in (SELECT opportunity__c from service__c where id in :opptySerIdSet) and id in (SELECT opportunity__c from solution__c where id in :opptySolIdSet) and RecordType.Name = 'HQ' and CompanyCode__c = 'T100' and
        system.debug(' ashish matchedoppLst'+matchedoppLst);
        Map<String,set<String>> servSolMap = new Map<String,set<String>>();
        
        for(Service__c serObj:[SELECT Id , Name ,sService__r.Name, sService__r.TechAttribute__c , Opportunity__c
                               
                               FROM Service__c
                               WHERE Opportunity__c IN : matchedoppLst.keyset()  AND sDeletionFlag__c = false  ORDER BY sService__r.Name ASC]){
                                   //opptySerIdSet.add(serObj.Id);
                                   if(opptyServiceMap.containskey(serObj.Opportunity__c)) {
                                       set<String> servName = opptyServiceMap.get(serObj.Opportunity__c);
                                       servName.add(serObj.sService__r.Name);
                                       opptyServiceMap.put(serObj.Opportunity__c,servName);
                                   }
                                   else{
                                       set<String> servName = new Set<String>();
                                       servName.add(serObj.sService__r.Name);
                                       opptyServiceMap.put(serObj.Opportunity__c,servName);
                                   }
                               }
        //    system.debug('ashish opptyServiceMap'+opptyServiceMap);
        for(Solution__c serObj:[ SELECT Id , Name , Service__c,Service__r.sService__r.Name , sSolution__r.Name,Opportunity__c
                                FROM Solution__c
                                WHERE Opportunity__c in: matchedoppLst.keyset() AND sDeletionFlag__c = false
                                ORDER BY sSolution__r.Name ASC
                               ]){
                                   //opptySolIdSet.add(serObj.id);
                                   if(opptySolMap.containskey(serObj.Opportunity__c)) {
                                       set<String> servName = opptySolMap.get(serObj.Opportunity__c);
                                       servName.add(serObj.sSolution__r.Name);
                                       opptySolMap.put(serObj.Opportunity__c,servName);
                                   }
                                   else{
                                       set<String> servName = new Set<String>();
                                       servName.add(serObj.sSolution__r.Name);
                                       opptySolMap.put(serObj.Opportunity__c,servName);
                                   }
                                   if(servSolMap.containskey(serObj.Opportunity__c+'_'+serObj.Service__r.sService__r.Name)) {
                                       set<String> servName = servSolMap.get(serObj.Opportunity__c+'_'+serObj.Service__r.sService__r.Name);
                                       servName.add(serObj.sSolution__r.Name);
                                       servSolMap.put(serObj.Opportunity__c+'_'+serObj.Service__r.sService__r.Name,servName);
                                   }
                                   else{
                                       set<String> servName = new Set<String>();
                                       servName.add(serObj.sSolution__r.Name);
                                       servSolMap.put(serObj.Opportunity__c+'_'+serObj.Service__r.sService__r.Name,servName);
                                   }
                               }
        
        
        for(id myoppId : oppList.keyset()){
            opportunity oppObj = oppList.get(myoppId);
            set<String> oppservSet = opptyServiceMap.get(myoppId);
            set<String> oppsolSet = opptySolMap.get(myoppId);
            for(id mymatchedoppId : matchedoppLst.keyset()){
                opportunity matchedoppObj = matchedoppLst.get(mymatchedoppId);
                boolean servMatched = false;
                boolean solMatched = false;
                set<String> oppservSet1 = opptyServiceMap.get(mymatchedoppId);
                if(oppservSet1 != null)
                    for(String s : oppservSet1){ 
                        if(oppservSet != NULL && oppservSet.contains(s)){
                            for(String sol:servSolMap.get(mymatchedoppId+'_'+s)) 
                                if(oppsolSet != NULL && oppsolSet.contains(sol)) {
                                    servMatched = true; solMatched = true; break;
                                }
                        }
                        if(servMatched) break;
                    }
                
                if(oppObj.Id != matchedoppObj.Id && oppObj.OriginAcc_BizTypeL1__c == matchedoppObj.OriginAcc_BizTypeL1__c && oppObj.OriginAcc_BizTypeL2__c == matchedoppObj.OriginAcc_BizTypeL2__c && oppObj.BusinessLevel__c == matchedoppObj.BusinessLevel__c && servMatched && solMatched)
                    if(OpptyMatchingMap.containsKey(myoppId)){
                        Set<id> matchOpSet = OpptyMatchingMap.get(myoppId);
                        
                        if(matchOpSet.size() <=9){
                            matchOpSet.add(mymatchedoppId);
                            OpptyMatchingMap.put(myoppId,matchOpSet);
                            
                        }
                        
                        
                    }else{
                        Set<id> matchOpSet = new set<id>();
                        if(matchOpSet.size() <=9){
                            matchOpSet.add(mymatchedoppId);
                            OpptyMatchingMap.put(myoppId,matchOpSet);
                            
                        }
                        
                    }
                
            }
        }
        system.debug('NoOfTargetBo' + OpptyMatchingMap.keyset().size());
        system.debug('ashish OpptyMatchingMap'+OpptyMatchingMap);
        return matchedoppLst;
        
    }
    //map<string,decimal>
    public static decimal getBORelatedAmount(set<String> sSet,Map<String,decimal> BO_AmountMap,User u){
        //    Map<String,decimal> BO_AmountMap= new Map<String,decimal>();
        //set<String> composite = new set<string>();
        //set<String> sSet = new set<String>{'SDS-21409390', 'SDS-16032820'};
        decimal totalSum=0;      
        /*for(aggregateresult res:[Select opportunitycode__c, Max(Version__c) ver from opportunityamt__c where companycode__c ='T100'
and closedate__c = this_year
and opportunity__r.recordtype.developername = 'HQ' 
and opportunity__r.owner.id =:   u.id      and opportunity__r.stagename = 'Z05'

and opportunitycode__c IN :sset group by Opportunitycode__c])    {
system.debug(res.get('ver'));
system.debug(res.get('opportunitycode__c'));
composite.add(res.get('opportunitycode__c')+'_'+res.get('ver'));
}
*/
       
        for(opportunityamt__c obj:[Select opportunitycode__c, Version__c, id, DiffAmt__c,DiffAmtLoc__c from opportunityamt__c where companycode__c ='T100' and Bo_Version_Composite__c IN :sSet]){
            
            system.debug('ash');
            system.debug(obj.Opportunitycode__c);
            system.debug(obj.Version__c);
            system.debug(obj.DiffAmt__c);
            //MYSALES-463 Changing the DiffAmtLoc__c to DiffAmt__c. V 1.2
            if(obj.DiffAmt__c != null && obj.DiffAmt__c != 0)
                totalSum += obj.DiffAmtLoc__c;
            BO_AmountMap.put(obj.Opportunitycode__c,obj.DiffAmtLoc__c);
        }
        return totalSum;
    }
    
    public static void createInterfaceLog(List<userInfoWrap> userWrapList){
        
        try{
            List<String> concatenatedStrings = new List<String>();
            List<String> concatenatedfailureStrings = new List<String>();
            for (userInfoWrap wrap : userWrapList) {
                if(wrap.isfailure){
                    concatenatedfailureStrings.add('Sales Rep:' + wrap.name + ',' + wrap.userId);
                }
                else{
                    concatenatedStrings.add('Sales Rep:' + wrap.name + ',' + wrap.userId);
                }
                
            }
            
            //String abc = 
            if(concatenatedStrings.size()>0  || Test.isRunningTest()){
                System.debug( 'ERROR_KNOXAPPROVAL entry');
                IF_Log__c log = new IF_Log__c();
                log.ApexName__c = 'Batch_WeeklySalesReport';
                log.ApexMethod__c =  'execute';
                log.InterfaceId__c = 'ERR_MAILING_HQ_REP';
                log.LogText__c = String.join(concatenatedStrings, ';');
                log.StatusCode__c = 'W';
                log.LogType__c = 'Mailing';
                log.EndDatetime__c  = System.now();
                log.StartDatetime__c = System.now();
                System.debug( 'ERROR_SENDING_EMAIL'+ log);
                insert log;
                system.debug('iflogid-->' + log.id);
            }
            
            
            if(concatenatedfailureStrings.size()>0 || Test.isRunningTest()){
                IF_Log__c log = new IF_Log__c();
                log.ApexName__c = 'Batch_WeeklySalesReport'; 
                log.ApexMethod__c =  'execute';
                log.InterfaceId__c = 'ERR_MAILING_HQ_REP';
                log.LogText__c = String.join(concatenatedfailureStrings, ';');
                log.StatusCode__c = 'F';
                log.LogType__c = 'Mailing';
                log.EndDatetime__c  = System.now();
                log.StartDatetime__c = System.now();
                System.debug( 'ERROR_SENDING_EMAIL'+ log);
                insert log;
                system.debug('iflogid-->' + log.id);
            }
            
        }catch(Exception e){
            System.debug( 'ERROR_SENDING_EMAIL msg'+ e.getMessage());
        }
    }
    
    public String formattedNumber(String numString){
        
        if(numString == null && String.isblank(numString)){
            
            return ''; 
            
        }
        else{
            String formattedNumber = '';
            boolean NegativeVal = false; //MYSALES-361 V 1.0
            List<String> parts = numString.split('\\.');
            
            // Format the integer part
            String integerPart = parts[0];
            //MYSALES-361 Start V 1.0
            if(integerPart.contains('-')){
                integerPart = integerPart.replace('-','');
			    NegativeVal = true;
                system.debug('integerPart222==>'+integerPart);
			}
            system.debug('integerPart333==>'+integerPart);
            //MYSALES-361 End V 1.0
            List<String> integerDigits = integerPart.split('');
            if (integerDigits.size() > 3) {
                Integer commaCounter = 0;
                for (Integer i = integerDigits.size() - 1; i >= 0; i--) {
                    if (commaCounter == 3 && i < integerDigits.size() - 1) {
                        formattedNumber = ',' + formattedNumber; // Add a comma
                        commaCounter = 0;
                    }
                    formattedNumber = integerDigits[i] + formattedNumber;
                    commaCounter++;
                }
            } else {
                formattedNumber = integerPart; // No need to format if less than 4 digits
            }
            
            // Add the decimal part if it exists
            if (parts.size() > 1) {
                formattedNumber += '.' + parts[1];
            }
            //MYSALES-361 Start V 1.0
            if(NegativeVal == true){
			     formattedNumber = '-'+formattedNumber ;
			}
            //MYSALES-361 End V 1.0
            return formattedNumber;
        }
        
        
    }
    
    
    public class userInfoWrap {
        
        String Name;
        String userId;
        boolean isfailure = false;
    }
}