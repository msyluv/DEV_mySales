/**
* @description       : 
* @author            : chae_ho.yang@samsung.com
* @group             : 
* @last modified on  : 07-28-2023
* @last modified by  : chae_ho.yang@samsung.com
**/
global class Batch_WeeklySalesReport_ADi_QA implements DataBase.Batchable<SObject>, Database.Stateful ,DataBase.AllowsCallouts, Schedulable {
    private static Boolean isSandbox = Utils.getIsSandbox();
    private List<IF_Log.InterfaceLog> ifLog = new List<IF_Log.InterfaceLog>();
    private List<userInfoWrap> userWrap = new List<userInfoWrap>();
    //private List<KnoxEmail__c> KnoxEmailList = new List<KnoxEmail__c>();
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
            list<user> adminUserList = new List<user>([select id from user where profile.name='System Administrator']);
            
            for(User uu : adminUserList){
                adminUserIds.add(uu.id);
            }
            if(isSandbox){
                //@added by: @rakshit.s@samsung.com
                //@desc: if you want to test the batch for individual users add the user id in comma seperation in the below label named "Weekly_Report_Users" if you want it to run for all enter null in the label value.
                //changes for dynamic user in produciton start
                if(system.label.Weekly_Report_Users != 'null'){
                    List<String> userIdSet =  new List<String>();
                    
                    userIdSet = system.label.Weekly_Report_Users.split(',');
                    String idList = '\''+String.join(userIdSet,'\',\'')+'\'';
                    // queryString += 'Select Id , name, Profile.Name,Email from User'; //where Id IN \'박 재만\' AND IsActive = true ';
                    queryString.add('Select Id , name, Profile.Name,Email from User');
                    //queryString += ' WHERE Id IN('+idList +')';
                    queryString.add(' WHERE Id IN('+idList +')');
                    
                }
                
                else{
                    //queryString += ' select Id,Email,Name from User';
                    queryString.add(' select Id,Email,Name from User');
                    //queryString += ' where  Profile.Name = \'Sales Rep.(HQ)\'  AND IsActive = true '; //id =\'0051s000003VUcAAAW\'  Profile.Name = \'Sales Rep.(HQ)\';
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
                    //queryString += 'Select Id , name, Profile.Name,Email from User'; //where Id IN \'박 재만\' AND IsActive = true ';
                    queryString.add('Select Id , name, Profile.Name,Email from User');
                    // queryString += ' WHERE Id IN('+idList +')';
                    queryString.add(' WHERE Id IN('+idList +')');
                } 
                
                else{
                    //queryString += 'Select Id , name, Profile.Name,Email from User where Id IN \'박 재만\' AND IsActive = true ';
                    //queryString += 'Select Id , name, Profile.Name,Email from User where Name = \'박 재만\' AND IsActive = true ';
                    //commented -> queryString.add('Select Id , name, Profile.Name,Email from User where Name = \'박 재만\' AND IsActive = true ');
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
            //  System.debug('### Batch_WeeklySalesReport :: start :: listUser size = ' + returnScope);
            
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
        //Map<String,decimal> BO_AmountMap= new Map<String,decimal>();
        //set<String> BO_AmountMapsSet = new set<String>();
        
        
        List<String> toList = new List<String>(); 
        if(isSandbox){
            //toList = new List<String>(System.label.WEEKLY_MAIL_RECIPIENT_STAGE.split(','));
            toList.add('rakshit.s@stage.samsung.com');
            toList.add('d.ashish@stage.samsung.com');
            //toList.add('boram85.jung@stage.samsung.com');
            //toList.add('akash.g@stage.samsung.com');
            toList.add('aditya.r2@stage.samsung.com');
            //toList.add('vikrant.ks@stage.samsung.com');
            //toList.add('saavi.96@stage.partner.samsung.com');
        }
        if(!isSandbox){
            toList = new List<String>(System.label.WEEKLY_MAIL_RECIPIENT.split(','));
        }
        
        
        String strEmailTemp = '';
        String strEmail = '';
        EmailTemplate em = [SELECT Id,subject FROM EmailTemplate WHERE DeveloperName = 'HQ_Weekly_Sales_Report_Sales_Rep'];
        Id templateId = em.Id;
        strEmail = [SELECT HtmlValue FROM EmailTemplate WHERE Id = :templateId].HtmlValue;
        String strTitle = system.label.WEEKLY_MAIL_TITLE;
        //Id str;
        
        List<Opportunity> lstOpp = new List<Opportunity>();
        List<Opportunity> lstOpp1 = new List<Opportunity>();
        List<Opportunity> lstOpp2 = new List<Opportunity>();
        List<Opportunity> lstOpp3 = new List<Opportunity>();
        List<Opportunity> lstOpp4 = new List<Opportunity>();
        List<Opportunity> lstOpp5 = new List<Opportunity>();
        List<Opportunity> lstOpp6 = new List<Opportunity>();
        List<Opportunity> lstOpp7 = new List<Opportunity>();
        List<Opportunity> lstOpp8 = new List<Opportunity>();
        List<Opportunity> lstOpp9 = new List<Opportunity>();
        //List<Opportunity> lstOpp99 = new List<Opportunity>();
        //List<Opportunity> lstOpp999 = new List<Opportunity>();
        //Added By Ashish 
        List<Opportunity> lstOppTable4  = new List<Opportunity>();
        DateTime dt = DateTime.now().addDays(-8);
        //Opportunity lstOpp = new Opportunity();
        //lstOpp = [select Id, Amount,Name,OpportunityCode__c,ZP61_PROPOSAL_SUBMIT_DATE__c,ProposalPM__c,ProposalPM__r.Name, cOriginAcc__c, cOriginAcc__r.Owner.Name,cOriginAcc__r.Name, Opportunity_Review_VRB_Type_Confirm__c,toLabel(Opportunity_Review_VRB_Type_Confirm__c) toLabel_Opportunity_Review_VRB_Type_Confirm__c,Opportunity_Review_VRB_Type__c,toLabel(Opportunity_Review_VRB_Type__c) toLabel_Opportunity_Review_VRB_Type__c, StageName,toLabel(StageName) toLabel_StageName,BO1stRegistrationDate__c,CloseDate,XP7_CONDUCT_DATE__c,XP6_CONDUCT_DATE__c, Account.mDomesticForeign__c, CMBizType__c, AccountId,Account.Owner.Name,Account.Name,OriginAcc_BizTypeL1__c,BusinessLevel__c, RecordType.Name,Type from opportunity where  OwnerId = : listScope[0].Id];
        //addedby: rakshit.s@samsung.com
        //desc: ->  new optimized query in order to avoid unnecessary for loop on line 478. 
        lstOpp = [
            SELECT Id, cOriginAcc__r.LastModifiedById,convertCurrency(Amount), Name, account.lastmodifiedbyId, OpportunityCode__c, ZP61_PROPOSAL_SUBMIT_DATE__c, ProposalPM__c, ProposalPM__r.Name, cOriginAcc__c, cOriginAcc__r.Owner.Name, cOriginAcc__r.Name, Opportunity_Review_VRB_Type_Confirm__c, toLabel(Opportunity_Review_VRB_Type_Confirm__c) toLabel_Opportunity_Review_VRB_Type_Confirm__c, FirstCloseDate__c, Opportunity_Review_VRB_Type__c, toLabel(Opportunity_Review_VRB_Type__c) toLabel_Opportunity_Review_VRB_Type__c, StageName, toLabel(StageName) toLabel_StageName, BO1stRegistrationDate__c, CloseDate, XP7_CONDUCT_DATE__c, XP6_CONDUCT_DATE__c, Account.mDomesticForeign__c, CMBizType__c, AccountId, Account.Owner.Name, Account.Name, OriginAcc_BizTypeL1__c, BusinessLevel__c, RecordType.Name, Type,XP7_REQ_DATE__c,XP6_REQ_DATE__c,Opportunity_Review_Confirm__c  
            ,OpportunityStatus__c,XP63_EndDate__c,LastModifiedDate,LastModifiedById,OriginAcc_BizTypeL2__c,CompanyCode__c FROM Opportunity 
            WHERE ((
                OpportunityStatus__c = 'E0002' AND CMBizType__c = 'CSP_SCP' AND CloseDate >= TODAY AND CloseDate <= NEXT_N_MONTHS:3
            ) OR 
                   (
                       (StageName = 'Z02' OR StageName = 'Z03' OR StageName = 'Z04') AND CloseDate <= NEXT_N_MONTHS:3
                   ) OR 
                   (
                       XP7_REQ_DATE__c = null AND (Opportunity_Review_VRB_Type_Confirm__c= '21' or Opportunity_Review_VRB_Type_Confirm__c= '20' or Opportunity_Review_VRB_Type_Confirm__c= '10') AND Opportunity_Review_Confirm__c = true AND XP63_EndDate__c!=null AND OpportunityStatus__c = 'E0002' AND CloseDate <= Next_N_WEEKS:2
                   ) OR 
                   (
                       XP6_REQ_DATE__c = null AND (Opportunity_Review_VRB_Type_Confirm__c= '21' or Opportunity_Review_VRB_Type_Confirm__c= '20' or Opportunity_Review_VRB_Type_Confirm__c= '10') AND Opportunity_Review_Confirm__c = true AND  OpportunityStatus__c = 'E0002' AND CloseDate <= Next_N_MONTHS:2
                   ) OR 
                   (
                       (StageName = 'Z01' OR StageName = 'Z02' OR StageName = 'Z03' OR StageName = 'Z04') AND CloseDate > TODAY AND CloseDate <= NEXT_N_WEEKS:2
                   ) OR 
                   (
                       (StageName = 'Z01' OR StageName = 'Z02' OR StageName = 'Z03' OR StageName = 'Z04') AND  CloseDate < TODAY and FirstCloseDate__c = null
                   ) OR 
                   (
                       (StageName = 'Z01' OR StageName = 'Z02' OR StageName = 'Z03' OR StageName = 'Z04' or StageName = 'Z05') AND 
                       
                       CloseDate = THIS_YEAR
                       
                   ) OR 
                   (
                       (StageName = 'Z02' OR StageName = 'Z03' OR StageName = 'Z04') AND 
                       
                       CloseDate <= NEXT_N_MONTHS:3
                   )
                   /*OR
(
BO1stRegistrationDate__c !=null AND BO1stRegistrationDate__c >=: dt
)*/
                  ) AND OwnerId = : listScope[0].Id
            AND RecordType.Name='HQ' AND companycode__c='T100'
            
        ];
        
        //List<SCPSimulation__c> scpRec = new List<SCPSimulation__c>();
        Set<String> scpCodes = new Set<String>();
        //scpRec = [select bocode__c  from SCPSimulation__c where companycode__c = 'T100' and ownerId = : listScope[0].Id].bocode__c;
        for(SCPSimulation__c scp : [select bocode__c  from SCPSimulation__c where companycode__c = 'T100' and ownerId = : listScope[0].Id]){
            scpCodes.add(scp.bocode__c);
        }
        //system.debug('ashish opptySize::'+ lstOpp.size());  
        // system.debug('Users name for opportunity : ' +  listScope[0].Name);
        Decimal dec= 0;
        Decimal dec1= 0;
        Integer count = 1;  //Adi
        Integer subHeadingCount = 1;  //Adi
        
        if(lstOpp.Size()>0){
            masterTable = true;
            for(Opportunity Opp : lstOpp){
                String str = '';
                str = String.valueOf(Opp.BO1stRegistrationDate__c);
                // System.debug('Ani str :'+ str);
                String cntYear = String.valueOf(System.today().year());
                String cntWeek = String.valueOf(System.today().addDays(-7));
                //System.debug('Ani stryear :'+ cntYear);
                if(opp.StageName == 'Z05' && Opp.BO1stRegistrationDate__c != null && (System.today().year() == opp.closedate.year())/*str.contains(cntYear)*/){
                    lstOpp1.add(opp);
                    //BO_AmountMapsSet.add(opp.opportunitycode__c);
                    if(opp.Amount!=null){
                        dec = dec + opp.Amount;
                    }
                    
                }
                /*
if(System.today().addDays(-7) <=Opp.BO1stRegistrationDate__c){
lstOpp999.add(opp);
}*/
                //Added By Ashish
                //if(Opp.BO1stRegistrationDate__c != null && isSameWeekDate(Date.valueOf(Opp.BO1stRegistrationDate__c)) /*&& Opp.BO1stRegistrationDate__c >= System.today() && Opp.BO1stRegistrationDate__c <= System.today().addDays(+7)*/){
                
                // isSameWeekDate(Opp.BO1stRegistrationDate__c);
                //for master table 4
                //    lstOppTable4.add(opp);
                //}
                
                /*if(opp.StageName == 'Z01' || opp.StageName == 'Z02' || opp.StageName == 'Z05'){
lstOpp999.add(opp);
}*/
                Date firstDayOfMonth = Date.today().toStartOfMonth().adddays(-1);
                //System.debug('Ani lstOpp999 :'+ lstOpp999.Size());
                if((opp.StageName == 'Z01' || opp.StageName == 'Z02' || opp.StageName == 'Z03' || opp.StageName == 'Z04') && Opp.BO1stRegistrationDate__c != null && (System.today().year() == opp.closedate.year()) ){
                    lstOpp2.add(opp);
                    if(opp.Amount !=null){
                        dec1 = dec1 + opp.Amount;
                    }
                    
                }
                //table 2
                if((opp.StageName == 'Z01' || opp.StageName == 'Z02' || opp.StageName == 'Z03' || opp.StageName == 'Z04') && opp.CloseDate<= System.today() && opp.FirstCloseDate__c == null){
                    lstOpp3.add(opp);
                }
                //table 3
                Date thisWeekStart = date.today().toStartOfWeek();
                if((opp.StageName == 'Z01' || opp.StageName == 'Z02' || opp.StageName == 'Z03' || opp.StageName == 'Z04') &&  (opp.CloseDate > system.today() && opp.CloseDate<= thisWeekStart.adddays(20) )){
                    lstOpp4.add(opp);
                }
                //table 4
                if(opp.XP6_REQ_DATE__c == null && (opp.Opportunity_Review_VRB_Type_Confirm__c== '21' || opp.Opportunity_Review_VRB_Type_Confirm__c== '20' || opp.Opportunity_Review_VRB_Type_Confirm__c== '10') && opp.Opportunity_Review_Confirm__c && opp.OpportunityStatus__c == 'E0002' && opp.CloseDate<= firstDayOfMonth.addmonths(+3)){//System.now().addmonths(+2)
                    // system.debug('4t table opp-->' + opp.id);
                    lstOpp5.add(opp);
                }
                //table 5
                if(opp.XP7_REQ_DATE__c == null && (opp.Opportunity_Review_VRB_Type_Confirm__c== '21' || opp.Opportunity_Review_VRB_Type_Confirm__c== '20' || opp.Opportunity_Review_VRB_Type_Confirm__c== '10') && opp.Opportunity_Review_Confirm__c && opp.XP63_EndDate__c!=null && opp.OpportunityStatus__c == 'E0002' && opp.CloseDate<= thisWeekStart.adddays(20)){//System.now().addDays(+14)
                    lstOpp6.add(opp);
                }
                //table 6
                if(( opp.StageName == 'Z02' || opp.StageName == 'Z03' || opp.StageName == 'Z04')){
                    if(opp.CloseDate <= firstDayOfMonth.addmonths(+4))//System.now().addMonths(+3))
                    {
                        lstOpp7.add(opp);
                    }
                }
                //table 7
                if((opp.CloseDate > system.today() && opp.CloseDate <= firstDayOfMonth.addmonths(+4)/*System.now().addMonths(+3)*/ && opp.OpportunityStatus__c == 'E0002' && opp.Account.mDomesticForeign__c == '20' && opp.lastmodifieddate <= firstDayOfMonth.addmonths(+4)/*System.now().addMonths(+3)*/) && (!adminUserIds.contains(opp.account.LastModifiedById) || !adminUserIds.contains(opp.cOriginAcc__r.LastModifiedById))){
                    
                    lstOpp8.add(opp);
                    
                }
                //table 8
                if(((opp.StageName == 'Z01' || opp.StageName == 'Z02' || opp.StageName == 'Z03' || opp.StageName == 'Z04') && opp.CMBizType__c == 'CSP_SCP' && opp.CloseDate > system.today() && opp.CloseDate <= firstDayOfMonth.addmonths(+4)/*System.now().addMonths(+3)*/) && !scpCodes.contains(opp.CompanyCode__c)){
                    //if((System.now() < opp.CloseDate <= System.now().addMonths(+3)))
                    //{
                    lstOpp9.add(opp);
                    //}
                }
            }
            lstOppTable4 = new list<opportunity>([SELECT Id, cOriginAcc__r.LastModifiedById,convertCurrency(Amount), Name, account.lastmodifiedbyId, OpportunityCode__c, ZP61_PROPOSAL_SUBMIT_DATE__c, ProposalPM__c, ProposalPM__r.Name, cOriginAcc__c, cOriginAcc__r.Owner.Name, cOriginAcc__r.Name, Opportunity_Review_VRB_Type_Confirm__c, toLabel(Opportunity_Review_VRB_Type_Confirm__c) toLabel_Opportunity_Review_VRB_Type_Confirm__c, FirstCloseDate__c, Opportunity_Review_VRB_Type__c, toLabel(Opportunity_Review_VRB_Type__c) toLabel_Opportunity_Review_VRB_Type__c, StageName, toLabel(StageName) toLabel_StageName, BO1stRegistrationDate__c, CloseDate, XP7_CONDUCT_DATE__c, XP6_CONDUCT_DATE__c, Account.mDomesticForeign__c, CMBizType__c, AccountId, Account.Owner.Name, Account.Name, OriginAcc_BizTypeL1__c, BusinessLevel__c, RecordType.Name, Type,XP7_REQ_DATE__c,XP6_REQ_DATE__c,Opportunity_Review_Confirm__c  
                                                  ,OpportunityStatus__c,XP63_EndDate__c,LastModifiedDate,LastModifiedById,OriginAcc_BizTypeL2__c,CompanyCode__c FROM Opportunity 
                                                  WHERE      BO1stRegistrationDate__c !=null 
                                                  AND OwnerId = : listScope[0].Id
                                                  AND RecordType.Name='HQ' AND companycode__c='T100'
                                                 ]);
            matchedoppLst = setupTable9(lstOppTable4,matchedoppLst,OpptyMatchingMap);
            //BO_AmountMap = getBORelatedAmount(BO_AmountMapsSet,BO_AmountMap);
            //system.debug('Ashish getting matchedoppLst from method'+matchedoppLst);
            //system.debug('Ashish getting OpptyMatchingMap from method'+OpptyMatchingMap);
            lstOpp = null;
            system.debug('---list sizes----' + lstOpp1.size() + '2nd----->' + lstOpp2.size() + '3rd---->' + lstOpp3.size() + '4th--->' + lstOpp4.size() + '5th--->' + lstOpp5.size() + '6th---->' + lstOpp6.size() + '7th---->' + lstOpp7.size() + '8th---->' + lstOpp8.size() + '9th---->' + lstOpp9.size() +  'last table---' + lstOppTable4.size());
            
            if(lstOpp4.Size()==0){
				if(lstOpp3.Size()!=0){
        			strEmail = strEmail.replace('<table class="table box_margin">{!tableString2}</table>', '<table class="table">{!tableString2}</table>');
    			}
			}

			if(lstOpp9.Size()==0){
				if(lstOpp8.Size()!=0){
					strEmail = strEmail.replace('<table class="table box_margin">{!tableString7}</table>', '<table class="table">{!tableString7}</table>'); 
				}else{
					if(lstOpp7.Size()!=0){
						strEmail = strEmail.replace('<table class="table box_margin">{!tableString6}</table>', '<table class="table">{!tableString6}</table>');
					}else{
						if(lstOpp5.Size()!=0 || lstOpp6.Size()!=0){
							strEmail = strEmail.replace('<table class="table box_margin">{!tableString5}</table>', '<table class="table">{!tableString5}</table>');
						}
					}		
				}
			}
            
            if(lstOpp1.Size()>0 || lstOpp2.Size()>0){
                // table1 = true;
                String strTemp = '';
                String amt = dec > 0 ? String.valueOf(dec/1000000) : '0' ;
                String amt1 = dec1 > 0 ? String.valueOf(dec1/1000000) : '0' ;
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
                    num = dec > 0 ? String.valueOf(dec/1000000) : '0' ;
                }
                if(amt1.contains('.')){
                    amtStr1= amt1.split('\\.');
                    ///   System.debug('amtStr Test@ :'+amtStr1);
                    num1 = amtStr1[0] +'.' + amtStr1[1].substring(0,2);
                }
                else{
                    num1 = dec1 > 0 ? String.valueOf(dec1/1000000) : '0' ;
                }
                strTemp += '<thead> <tr>'+
                    
                    '<td class="align_right">수주완료 건수</th>'+
                    '<td class="align_right">수주완료 금액 </th>'+
                    '<td class="align_right">올해 수주 예상일로 진행 중인 BO 의 건수</th>'+
                    '<td class="align_right">올해 수주 예상일로 진행 중인 BO 의 금액 </th>'+
                    '</tr> </thead>'+
                    '<tbody><tr>'+
                    
                    '<td class="align_right">' + lstOpp1.Size() + '</td>' +
                    '<td class="align_right">' + num + '</td>' +
                    '<td class="align_right">' + lstOpp2.Size() + '</td>' +
                    '<td class="align_right">' + num1 + '</td>'+ 
                    '</tr><tbody>' ;
                
                String sDate = String.valueOf(System.now());
                String sTemp = '<td class="title">'+ count +'. 연간 누적 사업기회 수주 현황</td>';    //Adi
                system.debug('Count inside Main table 1 : '+ count);
                strEmail = strEmail.replace('<td class="title">1. 연간 누적 사업기회 수주 현황</td>', sTemp);    //Adi
                strEmail = strEmail.replace('{!DateValue}', sDate);
                strEmail = strEmail.replace('{!tableString1}', strTemp);
                table1 = true;
                count = count +1;  //Adi
            }
            Boolean a = false;
            if(lstOpp1.Size()==0 && lstOpp2.Size()==0){
                a= true; 
                strEmail = strEmail.replace('<tr><td><table class="title_wrap"><tr><td class="title">1. 연간 누적 사업기회 수주 현황</td><td class="right_text">금액 : 백만단위 (KRW)</td></tr></table><table class="table">{!tableString1}</table><p class="gray_text">※ 수주 변경한 BO의 수주금액은 변경분(차액)으로 집계됩니다.</p>','');
            }
            lstOpp1 = null;
            lstOpp2 = null;
            if(lstOpp3.Size()>0){
                // table2 = true;
                String strTemp = '';
                strTemp += '<thead> <tr>'+
                    
                    '<td >사업기회 코드</th>'+
                    '<td colspan ="3" >사업기회 명</th>'+
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
                        
                        '<td>' + opp.OpportunityCode__c + '</td>' +
                        '<td  colspan ="3">' + '<a style="color:blue" href="' + str + '">'+ opp.Name + '</a>' + '</td>' +
                        '<td  colspan ="0.5">' + closeDate + '</td>' +
                        '<td >' + opp.get('toLabel_StageName') + '</td>'+ 
                        '<td class="align_right">' + num + '</td>'+ 
                        '</tr>' ;
                }
                strTemp +=  '</tbody>'; 
                String sDate = String.valueOf(System.now());
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
                    '<td colspan ="3" ">사업기회 명</th>'+
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
                        
                        '<td ">' + opp.OpportunityCode__c + '</td>' +
                        '<td " colspan ="3" >' + '<a style="color:blue" href="' + str + '">'+ opp.Name + '</a>' + '</td>' + 
                        '<td " colspan ="0.5" >' + closeDate + '</td>' +
                        '<td >' + opp.get('toLabel_StageName') + '</td>'+ 
                        '<td class="align_right">' + num + '</td>'+ 
                        '</tr>' ;
                }
                strTemp +=  '<tbody>';
                String sTemp = '<td class="title">' + IntRoman(subHeadingCount) +'수주예상일 도래 BO (D-14days)</td>';    //Adi
                strEmail = strEmail.replace('ii. 수주예상일 도래 BO (D-14days)', sTemp);    //Adi
                strEmail = strEmail.replace('{!tableString3}', strTemp);
                String sDate = String.valueOf(System.now());
                strEmail = strEmail.replace('{!DateValue}', sDate);
                table3 = true;
            }
            
            if(lstOpp4.Size()==0 && lstOpp3.Size()==0){
                strEmail = strEmail.replace('<tr><td class="box_padding"><p class="title">2. 지연 BO 및 수주 예상일 도래 BO</p><div class="sub_table_wrap">', '');
                strEmail = strEmail.replace('<table class="title_wrap"><tr><td class="title">i. 지연 BO</td></tr></table><table class="table box_margin">{!tableString2}</table>', '');
                strEmail = strEmail.replace('<table class="title_wrap"><tr><td class="title">ii. 수주예상일 도래 BO (D-14days)</td></tr></table><table class="table">{!tableString3}</table>', '');
            }else{  //Adi complete else part
                String sTemp = '<p class="title">' + count + '. 지연 BO 및 수주 예상일 도래 BO</p>';
                system.debug('Count inside Main table 2 : '+ count);
                strEmail = strEmail.replace('<p class="title">2. 지연 BO 및 수주 예상일 도래 BO</p>', sTemp);
                count = count +1;
            }
            
            Boolean b = false;
            if(lstOpp3.Size()==0){
                strEmail = strEmail.replace('<table class="title_wrap"><tr><td class="title">i. 지연 BO</td></tr></table><table class="table box_margin">{!tableString2}</table>', '');
                b= true;  
            }
            
            Boolean c = false;
            if(lstOpp4.Size()==0){
                strEmail = strEmail.replace('<table class="title_wrap"><tr><td class="title">ii. 수주예상일 도래 BO (D-14days)</td></tr></table><table class="table">{!tableString3}</table>', '');
                c= true;   
            }
            
            
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
                    String propDate = ''/*String.valueOf(opp.ZP61_PROPOSAL_SUBMIT_DATE__c)*/;
                    String proposalDate;
                    String tempDate = '';
                    if(propDate != null || propDate != ''){
                        if(!Test.isRunningTest())
                        {
                            proposalDate = ''/*propDate.substring(0,10)*/;
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
                    strTemp += '<td >' + opp.Opportunitycode__c  + '</td>' +
                        '<td >'+ '<a style="color:blue" href="' + 'https://sdssfa.lightning.force.com/lightning/r/Opportunity/'+opp.Id+'/view' + '">'+ opp.Name + '</a>' +'</td>' +
                        '<td >' + /*vrbTypeValues(opp.Opportunity_Review_VRB_Type_Confirm__c)*/ '사참수전위' + '</td>' + 
                        '<td >' + vrbTypeValues(opp.Opportunity_Review_VRB_Type_Confirm__c) + '</td>' +
                        '<td >' + closeDate + '</td>'+ 
                        '<td >' + opp.get('toLabel_StageName') + '</td>'+ 
                        '<td class="align_right">' + num + '</td>'+ 
                        
                        '<td >' + tempDate + '</td>'+
                        '</tr>' ;
                }
                strTemp +=  '</tbody>';
                String sDate = String.valueOf(System.now());
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
                    String propDate = String.valueOf(opp.ZP61_PROPOSAL_SUBMIT_DATE__c);
                    //String proposalDate = propDate.substring(0,10);
                    String proposalDate;
                    if(propDate != null || propDate != ''){
                        if(!Test.isRunningTest())
                        {
                            proposalDate = propDate.substring(0,10);
                        }
                    }
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
                    strTemp +=  '<td">' + opp.Opportunitycode__c  + '</td>' +
                        '<td>' + '<a style="color:blue" href="' + 'https://sdssfa.lightning.force.com/lightning/r/Opportunity/'+opp.Id+'/view' + '">'+ opp.Name + '</a>' +'</td>' +
                        '<td >' + /*vrbTypeValues(opp.Opportunity_Review_VRB_Type_Confirm__c)*/ '입찰수전위' + '</td>' + 
                        '<td >' + vrbTypeValues(opp.Opportunity_Review_VRB_Type_Confirm__c) + '</td>' +
                        '<td >' + closeDate + '</td>'+ 
                        '<td >' + opp.get('toLabel_StageName') + '</td>'+ 
                        '<td class="align_right">' + num + '</td>'+ 
                        '<td >' + proposalDate + '</td>'+//opp.ZP61_PROPOSAL_SUBMIT_DATE__c
                        '</tr>' ;
                }
                strTemp +=  '</tbody>';
                /*String sTemp = IntRoman(subHeadingCount) +'. 수전위 사전준비';    //Adi
strEmail = strEmail.replace('i. 수전위 사전준비', sTemp);    //Adi
subHeadingCount++;  //Adi*/
                strEmail = strEmail.replace('{!tableString5}', strTemp);
                String sDate = String.valueOf(System.now());
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
                String strTemp = '';
                strTemp += '<thead> <tr>'+
                    '<td >사업기회 코드</th>'+
                    '<td colspan ="2" >사업기회 명</th>'+
                    '<td >수주예상일 </th>'+
                    '<td > 단계</th>'+
                    '<td class="align_right" >금액</th>'+
                    '<td >제안PM</th>'+
                    '<td >제안PM 가용여부 </th>'+
                    '<td >제안 PM 일정</th>'+
                    '<td >제안 PM 사전영업 계획</th>'+
                    '<td >실행 계획 </th>'+
                    '</tr></thead>';
                strTemp +=  '<tbody>';
                for(Opportunity opp : lstOpp7){
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
                    //  System.debug('amtStr Test :'+amtStr);
                    strTemp +=  '<tr>'+
                        '<td >' + opp.OpportunityCode__c  + '</td>' +
                        '<td colspan ="2" >' + '<a style="color:blue" href="' + str + '">'+ opp.Name + '</a>' + '</td>' + 
                        '<td >' + closeDate + '</td>' +
                        '<td >' + opp.get('toLabel_StageName')+ '</td>'+ 
                        '<td class="align_right">' + num + '</td>' +
                        '<td >' + prop + '</td>'+
                        '<td >' + 'Y' + '</td>'+
                        '<td >' + '2023-08-16' + '</td>'+
                        '<td >' + 'Y' + '</td>'+
                        '<td >' + 'N' + '</td>'+
                        '</tr>' ;
                }
                strTemp +=  '</tbody>';
                String sTemp = '<td class="title">' + IntRoman(subHeadingCount) +'인력투입 계획 수립</td>';    //Adi
                strEmail = strEmail.replace('<td class="title">ii. 인력투입 계획 수립</td>', sTemp);    //Adi
                subHeadingCount++;  //Adi
                strEmail = strEmail.replace('{!tableString6}', strTemp);
                String sDate = String.valueOf(System.now());
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
                        str = 'https://sdssfa--qa.sandbox.lightning.force.com/lightning/r/Account/' + opp.cOriginAcc__c + '/view';
                        str1 = 'https://sdssfa--qa.sandbox.lightning.force.com/lightning/r/Account/' + opp.AccountId + '/view';
                    }
                    else{
                        // String str = 'https://sdssfa.lightning.force.com/lightning/r/Opportunity/' + opp.Id + '/view'; 
                        str = 'https://sdssfa.lightning.force.com/lightning/r/Account/' + opp.cOriginAcc__c + '/view';
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
                        '<td >' + opp.OpportunityCode__c  + '</td>' +
                        '<td colspan ="2" >' + '<a style="color:blue" href="' + str + '">'+ opp.Name + '</a>' + '</td>' + 
                        '<td >' + closeDate + '</td>' +
                        '<td >' + opp.get('toLabel_StageName')+ '</td>'+ 
                        '<td class="align_right">' + num + '</td>' +
                        '<td  colspan ="1" >' + '<a style="color:blue" href="' + str1 + '">'+ opp.cOriginAcc__r.Name + '</a>' + '</td>' + 
                        '<td >' + opp.cOriginAcc__r.Owner.Name + '</td>' +
                        '<td  colspan ="1" >' + '<a style="color:blue" href="' + str1 + '">'+opp.Account.Name  +'</a>' + '</td>' + 
                        '<td >'+opp.Account.owner.name+' </td>' +
                        '</tr>' ;
                }
                strTemp +=  '</tbody>';
                String sTemp = '<td class="title">' + IntRoman(subHeadingCount) +'고객 정보 Update'+'</td>';    //Adi
                strEmail = strEmail.replace('iii. 고객 정보 Update', sTemp);    //Adi
                subHeadingCount++;
                strEmail = strEmail.replace('{!tableString7}', strTemp);
                String sDate = String.valueOf(System.now());
                strEmail = strEmail.replace('{!DateValue}', sDate);
                table7 = true;                             
            }
            
            if(lstOpp9.Size()>0 || test.isRunningTest()){//|| !isSandbox
                // table8 = true;
                String strTemp = '';
                strTemp += ' <thead><tr>'+
                    '<td >사업기회 코드</th>'+
                    '<td colspan ="2" >사업기회 명 </th>'+
                    '<td > 수주예상일 </th>'+
                    '<td class="align_right"> 수주금액 </th>'+
                    '<td >단계 </th>'+
                    
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
                        '<td >' + opp.OpportunityCode__c + '</td>' +
                        '<td  colspan ="2" >' + '<a style="color:blue" href="' + str + '">'+ opp.Name + '</a>' + '</td>' +
                        '<td >' + closeDate + '</td>' +
                        '<td class="align_right">' +num + '</td>' +
                        '<td >' + opp.get('toLabel_StageName') + '</td>'+  
                        
                        '</tr>' ;
                }
                strTemp +=  '</tbody>';
                String sTemp = '<td class="title">' + IntRoman(subHeadingCount) +'SCP 견적 등록 </td>';    //Adi
                strEmail = strEmail.replace('iv. SCP 견적 등록', sTemp);    //Adi
                subHeadingCount++;
                strEmail = strEmail.replace('{!tableString8}', strTemp);
                String sDate = String.valueOf(System.now());
                strEmail = strEmail.replace('{!DateValue}', sDate);
                table8 = true; 
                
                
            }
            
            //Adi Complete If Else
            if(lstOpp5.Size()==0 && lstOpp6.Size()==0 && lstOpp7.Size()==0 && lstOpp8.Size()==0 && lstOpp9.Size()==0){
                String cs = 'CSP_SCP';
                strEmail = strEmail.replace('<tr><td class="box_padding"><p class="title">3. 사업수행 사전준비</p><div class="sub_table_wrap">', '');
                strEmail = strEmail.replace('<p class="sub_title">i. 수전위 사전준비</p><p class="text">사참 수전위는 수주예상일 2개월전, 입찰 수전위는 수주예상일 2주전 완료해 주시기 바랍니다.<br>- PM: 자가점검 체크리스트 수행, 인력투입계획 수립, 수전위 원가판 편성<br>- 영업대표: 수전위 원가판 확정 </p><p class="gray_text">※ 심의부서에 체크리스트 심의의견 작성시 참고 할 수 있는 보고서, RFP, 제안서 등을 공유하여 주시기 바랍니다. </p><table class="table box_margin">{!tableString4}</table><table class="table box_margin">{!tableString5}</table>', '');
                strEmail = strEmail.replace('<table class="title_wrap"><tr><td class="title">ii. 인력투입 계획 수립</td><td class="title_small">수주예상일 3개월 전 인력투입 계획을 수립해 주시기 바랍니다.</td></tr></table><table class="table box_margin">{!tableString6}</table>', '');
                strEmail = strEmail.replace('<table class="title_wrap"><tr><td class="title">iii. 고객 정보 Update</td><td class="title_small">opendart 정보가 원청고객/계약고객에 대해 현행화 되었으므로 이를 확인하시어 고객 정보를 현행화 하시기 바랍니다</td></tr></table><table class="table box_margin">{!tableString7}</table>', '');
                strEmail = strEmail.replace('<table class="title_wrap"><tr><td class="title">iv. SCP 견적 등록</td><td class="title_small">사업유형(상세)을 '+ '\''+ cs + '\'' +'로 등록한 사업기회는 수주예상일 3개월 전 SCP 견적을 등록해 주시기 바랍니다</td></tr></table><table class="table">{!tableString8}</table>', '');
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
                strEmail = strEmail.replace('<table class="title_wrap"><tr><td class="title">ii. 인력투입 계획 수립</td><td class="title_small">수주예상일 3개월 전 인력투입 계획을 수립해 주시기 바랍니다.</td></tr></table><table class="table box_margin">{!tableString6}</table>', '');   
            }
            
            Boolean g = false;
            if(lstOpp8.Size()==0){
                strEmail = strEmail.replace('<table class="title_wrap"><tr><td class="title">iii. 고객 정보 Update</td><td class="title_small">opendart 정보가 원청고객/계약고객에 대해 현행화 되었으므로 이를 확인하시어 고객 정보를 현행화 하시기 바랍니다</td></tr></table><table class="table box_margin">{!tableString7}</table>', '');  
                g= true;  
            }
            
            Boolean h = false;
            if(lstOpp9.Size()==0){
                String cs = 'CSP_SCP';  
                strEmail = strEmail.replace('<table class="title_wrap"><tr><td class="title">iv. SCP 견적 등록</td><td class="title_small">사업유형(상세)을 '+ '\''+ cs + '\'' +'로 등록한 사업기회는 수주예상일 3개월 전 SCP 견적을 등록해 주시기 바랍니다</td></tr></table><table class="table">{!tableString8}</table>', ''); 
                h= true;  
            }
                       
            lstOpp3 = null;   
            lstOpp4 = null;
            lstOpp5 = null; 
            lstOpp6 = null;
            lstOpp7 = null;
            lstOpp8 = null;
            lstOpp9 = null;
        }else{
            String cs = 'CSP_SCP';
            strEmail = strEmail.replace('<tr><td><table class="title_wrap"><tr><td class="title">1. 연간 누적 사업기회 수주 현황</td><td class="right_text">금액 : 백만단위 (KRW)</td></tr></table><table class="table">{!tableString1}</table><p class="gray_text">※ 수주 변경한 BO의 수주금액은 변경분(차액)으로 집계됩니다.</p>','');
            strEmail = strEmail.replace('<tr><td class="box_padding"><p class="title">2. 지연 BO 및 수주 예상일 도래 BO</p><div class="sub_table_wrap">', '');
            strEmail = strEmail.replace('<table class="title_wrap"><tr><td class="title">i. 지연 BO</td></tr></table><table class="table box_margin">{!tableString2}</table>', '');
            strEmail = strEmail.replace('<table class="title_wrap"><tr><td class="title">ii. 수주예상일 도래 BO (D-14days)</td></tr></table><table class="table">{!tableString3}</table>', '');
            strEmail = strEmail.replace('<tr><td class="box_padding"><p class="title">3. 사업수행 사전준비</p><div class="sub_table_wrap">', '');
            strEmail = strEmail.replace('<p class="sub_title">i. 수전위 사전준비</p><p class="text">사참 수전위는 수주예상일 2개월전, 입찰 수전위는 수주예상일 2주전 완료해 주시기 바랍니다.<br>- PM: 자가점검 체크리스트 수행, 인력투입계획 수립, 수전위 원가판 편성<br>- 영업대표: 수전위 원가판 확정 </p><p class="gray_text">※ 심의부서에 체크리스트 심의의견 작성시 참고 할 수 있는 보고서, RFP, 제안서 등을 공유하여 주시기 바랍니다. </p><table class="table box_margin">{!tableString4}</table><table class="table box_margin">{!tableString5}</table>', '');
            strEmail = strEmail.replace('<table class="title_wrap"><tr><td class="title">ii. 인력투입 계획 수립</td><td class="title_small">수주예상일 3개월 전 인력투입 계획을 수립해 주시기 바랍니다.</td></tr></table><table class="table box_margin">{!tableString6}</table>', '');
            strEmail = strEmail.replace('<table class="title_wrap"><tr><td class="title">iii. 고객 정보 Update</td><td class="title_small">opendart 정보가 원청고객/계약고객에 대해 현행화 되었으므로 이를 확인하시어 고객 정보를 현행화 하시기 바랍니다</td></tr></table><table class="table box_margin">{!tableString7}</table>', '');
            strEmail = strEmail.replace('<table class="title_wrap"><tr><td class="title">iv. SCP 견적 등록</td><td class="title_small">사업유형(상세)을 '+ '\''+ cs + '\'' +'로 등록한 사업기회는 수주예상일 3개월 전 SCP 견적을 등록해 주시기 바랍니다</td></tr></table><table class="table">{!tableString8}</table>', '');
            
        }
        
        //Only fot Testing - Table 4
        String strTemp4 = '';
        string strTemp42 = '';
        strTemp4 += '<thead> <tr >'+
            // '<td > 사업기회 코드 </th>'+
            
            '<td >사업기회</th>'+ //사업기회 명
            // '<td > 유사 사업기회 코드 </th>'+
            
            '<td > 유사 사업기회</th>'+
            '<td >수주예상일(수주일) </th>'+ //유사 사업기회 수주예상일
            
            '<td >단계</th>'+// 유사 수주예상액 // 유사 사업기회 수주금액 
            '<td >금액</th>'+// 유사 사업기회 상태 // 유사 사업기회 단계 
            
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
            masterTable4 = true;
            //strTemp42 += '<tbody>';
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
                            if(i==0) strTemp42 += '<td class="" rowspan="'+matchedOPSize+'" >' + '<a style="color:blue" href="' + 'https://sdssfa.lightning.force.com/lightning/r/Opportunity/'+opp.Id+'/view' + '">'+ opp.Name + '</a>' + '</td>' ;
                            i++;
                            
                            // strTemp42 += '<td class="align_right">' + matchedopp.OpportunityCode__c + '</td>' +
                            
                            strTemp42 +=  '<td class="">' + '<a style="color:blue" href="' + 'https://sdssfa.lightning.force.com/lightning/r/Opportunity/'+matchedopp.Id+'/view' + '">'+ matchedopp.Name + '</a>' +  '</td>' +
                                '<td class="">' + closeDate + '</td>'+
                                '<td class="align_right">' + num + '</td>' +
                                '<td class="">' + matchedopp.get('toLabel_StageName') + '</td>' +
                                '<td class="">' + vrbTypeValues(matchedopp.Opportunity_Review_VRB_Type_Confirm__c) + '</td>' ;
                            
                            //dynamic link logic start rakshit.s@samsung.com
                            /*if((matchedopp.Opportunity_Review_VRB_Type_Confirm__c == '10' || matchedopp.Opportunity_Review_VRB_Type_Confirm__c == '20' || matchedopp.Opportunity_Review_VRB_Type_Confirm__c == '30') && matchedopp.Opportunity_Review_Confirm__c){
strTemp42 +='<td class="align_right">' + '<a style="color:blue" href="' + 'http://scd.sds.samsung.net/app/scdDetail?sapCompany='+matchedopp.Companycode__C+'&'+'orderId='+matchedopp.Opportunitycode__c+ '">+</td>';
}

else{
strTemp42 +='

>'+ '</td>';
}*/
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
            //strTemp42 += '</tbody>';
            
            String sTemp = '<td class="title">' + count + '. 유사 사업기회 정보 <a class="add_btn" href="https://sdssfa.lightning.force.com/lightning/n/Opportunity_Search">Opportunity Search</a></td>';
            system.debug('Count inside Main table 4 : '+ count);
            strEmail = strEmail.replace('<td class="title">4. 유사 사업기회 정보 <a class="add_btn" href="https://sdssfa.lightning.force.com/lightning/n/Opportunity_Search">Opportunity Search</a></td>', sTemp);
            count = count +1;
            if(String.isnotblank(strTemp42)){
                strTemp4 = strTemp4 +' <tbody>'+ strTemp42+'</tbody>';
                strEmail = strEmail.replace('{!tableString9}', strTemp4);
            }
            else{
                strEmail = strEmail.replace('{!tableString9}', '');
                // if(lstOppTable4.size() == 0 || String.isblank(strTemp42)){
                strEmail = strEmail.replace(sTemp, '');
                strEmail = strEmail.replace('<a class="add_btn" href="https://sdssfa.lightning.force.com/lightning/n/Opportunity_Search">Opportunity Search</a>  <br/>', '');
                // strEmail = strEmail.replace('- 금액 : 백만단위 (KRW)<br/>', ''); 
                //      }
            }
            
        }
        if(lstOppTable4.size() == 0){
            strEmail = strEmail.replace('<tr><td class="box_padding"><table class="title_wrap"><tr><td class="title">4. 유사 사업기회 정보 <a class="add_btn" href="https://sdssfa.lightning.force.com/lightning/n/Opportunity_Search">Opportunity Search</a></td><td class="title_small">신규 등록한 BO의 유사사업기회 정보입니다. 사업 수행시 참고해주세요. (업종, 사업등급, 솔루션 기준)</td></tr></table><table class="table">{!tableString9}</table>', '');
            //strEmail = strEmail.replace('{!table9SubHeading}', ''); 
            strEmail = strEmail.replace('<a style=" background-color:blue;color:white" href="https://sdssfa.lightning.force.com/lightning/n/Opportunity_Search">Opportunity Search</a>  <br/>', '');
        }
        
        //Adi Complete If Else Block
        lstOppTable4 = null;
        
		for(User usr : listScope){
            String htmlvalue = '';
            //strEmailTemp = strEmail;
            List<String> emUser = new List<String>();
            emUser.add(usr.Email);
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
            strEmail = strEmail.replace('{!DateValue}', String.valueof(System.now()));
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
                            //mailresult = OpportunityEmailAlertController.sendKnoxEmailMulti(senderEmployee, usr.Id, toList, ccList, bccList, strTitle, strEmail, efileList, nfileList);
                            if(!Test.isRunningTest()) mailresult = OpportunityEmailAlertController.sendKnoxEmailMulti(senderEmployee, usr.Id, toList, ccList, bccList, strTitle, strEmail, efileList, nfileList);
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
        System.debug('### Batch_OpptyEmailController :: finish');        
        System.debug('### Batch_OpptyEmailController :: finish :: ifLog.size() : ' + ifLog.size());
        if(ifLog.size() > 0){
            IF_Log log = new IF_Log();
            log.createLog(ifLog);
        }
        
        if(userWrap.size()>0){
            createInterfaceLog(userWrap);
        }
        
    }
    
    public void execute(SchedulableContext SC){
        DataBase.executeBatch(new Batch_WeeklySalesReport(), 1);
    }    
    /*
public static boolean isSameWeekDate(datetime dateVal){
//String targetDate = dateVal; // The date you want to check

// Get the current date and time
Datetime currentDatetime = dateVal;
DateTime lastWeek = Datetime.now().addDays(-8);
system.debug('current-->' + currentDateTime);
system.debug('last8days-->' + lastWeek);
if(currentDatetime.date() >= System.now().addDays(-8).date()){
return true;
}

else{
return false;
}


}
*/
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
        system.debug('ashish  oppList'+oppList);
        Set<String> opptybiz1IdSet = new Set<String>();
        Set<String> opptybiz2IdSet = new Set<String>();
        Set<String> opptybussLabelIdSet = new Set<String>();
        for(Opportunity opp : mySalesTable4){
            oppList.put(opp.id,opp);
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
        matchedoppLst = new Map<Id,Opportunity>([Select Id, companycode__c,OpportunityCode__c,Opportunity_Review_VRB_Type_Confirm__c,Opportunity_Review_Confirm__c, (select TransactionName__c,Status__c from BO_Activity__r where transactionname__c='ZP61' and status__c='Completed') , ProposalPM__c,RepresentativePM__c,ProposalPM__r.name,RepresentativePM__r.name,OriginAcc_BizTypeL1__c,OriginAcc_BizTypeL2__c,BusinessLevel__c,name,closedate,convertcurrency(amount),StageName,toLabel(StageName) toLabel_StageName,ownerid, owner.name From Opportunity where  OriginAcc_BizTypeL1__c in:opptybiz1IdSet  AND OriginAcc_BizTypeL2__c in:opptybiz2IdSet  AND BusinessLevel__c in:opptybussLabelIdSet  and RecordType.Name = 'HQ' and id in (SELECT opportunity__c from service__c where sService__r.Name in :opptySerIdSet  AND sDeletionFlag__c = false) and id in (SELECT opportunity__c from solution__c where sSolution__r.Name in :opptySolIdSet  AND sDeletionFlag__c = false) and (closedate = LAST_N_YEARS:4 OR closedate = THIS_YEAR) and CompanyCode__c = 'T100' AND stagename != 'Z08' order by BO1stRegistrationDate__c desc LIMIT 50000]); //and id in (SELECT opportunity__c from service__c where id in :opptySerIdSet) and id in (SELECT opportunity__c from solution__c where id in :opptySolIdSet) and RecordType.Name = 'HQ' and CompanyCode__c = 'T100' and
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
        system.debug('ashish OpptyMatchingMap'+OpptyMatchingMap);
        return matchedoppLst;
        
    }
    /*
    public static map<string,decimal> getBORelatedAmount(set<String> sSet,Map<String,decimal> BO_AmountMap){
        //    Map<String,decimal> BO_AmountMap= new Map<String,decimal>();
        set<String> composite = new set<string>();
        //set<String> sSet = new set<String>{'SDS-21409390', 'SDS-16032820'};
        for(aggregateresult res:[Select opportunitycode__c, Max(Version__c) ver from opportunityamt__c where companycode__c ='T100' and opportunitycode__c IN :sset group by Opportunitycode__c])    {
            system.debug(res.get('ver'));
            system.debug(res.get('opportunitycode__c'));
            composite.add(res.get('opportunitycode__c')+'_'+res.get('ver'));
        }
        for(opportunityamt__c obj:[Select opportunitycode__c, Version__c, id, TotalAmtLoc__c from opportunityamt__c where companycode__c ='T100' and Bo_Version_Composite__c IN :composite]){
            
            system.debug('ash');
            system.debug(obj.Opportunitycode__c);
            system.debug(obj.Version__c);
            system.debug(obj.TotalAmtLoc__c);
            BO_AmountMap.put(obj.Opportunitycode__c,obj.TotalAmtLoc__c);
        }
        return BO_AmountMap;
    }
    */
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
    
    public class userInfoWrap {
        
        String Name;
        String userId;
        boolean isfailure = false;
    }
}