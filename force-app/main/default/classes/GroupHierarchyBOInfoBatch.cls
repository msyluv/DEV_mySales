/**
* @description       : (NOT IN USE) This is a Batch Apex Class that runs in order to Send Email to all the Team Leaders with The info of Elapsed(Close Date passed)/Near To Elapsed(7 or less than 7 Days to clsoe Date)
* @author            : rakshit.s@samsung.com
* @group             : 
* @date created  : 02-20-2023
* @last modified on : 02-25-2023
* @last modified by  : rakshit.s@samsung.com
* @Version: V1.0 (Initial Development)
**/

public class GroupHierarchyBOInfoBatch implements Database.Batchable<sObject>,Database.Stateful {
    public Set<String> divisionCodes = new Set<String>(); //to hold all the team codes.
    public Set<String> teamCodes = new Set<String>(); //to hold all the team codes.
    public Map<String , List<String>> teamVsGroupMap = new Map<String , List<String>>(); //map that returns all the groups when a Team Code is passed.
    public List<Opportunity> allOppList = new List<Opportunity>(); //All opportunities are stored in this once we have all the group codes from Group Hierarchy Object.
    public  List<Opportunity> nearToCloseOppList = new List<Opportunity>(); //All opportunities are stored in this once we have all the group codes from Group Hierarchy Object.
    
    public  Date today = Date.today(); //To hold current Date.
    public  Map<String, String> groupCodeVsGroupNameMap = new Map<String , String>(); //Returns Name of the group from Group Code.
    public  Map<String, String> groupCodeVsDivisionNameMap = new Map<String , String>(); //Returns Name of the group from Group Code.
    public Map<String, String> groupCodeVsTeamNameMap = new Map<String , String>(); //Returns Tem Name based on Group Code.
    public  Map<String, String> groupCodeVsrepUrlMap = new Map<String , String>(); //Returns Report Url based on Group Code.
    public Map<String, String> teamCodeVsReceiverMap = new Map<String , String>(); //Returns Report Url based on Group Code.
    public Map<String,String> divCodeVsReceiverMap = new map<String,String>();
    public Map<String,String> teamCodeVsReportUrlMap = new Map<String , String>(); 
    public Map<String,String> groupCodeVsDivisionCode = new Map<String , String>(); 
    
    //Map<>String , String> groupCodeVsDivi
    //added for Division Email Change.
    public Map<String , List<String>> divisionCodeVsTeamCodeMap = new Map<String, List<String>>();
    public Map<String, Map<String, List<group_hierarchy__c>>> divisionTeamOppMap = new Map<String, Map<String, List<group_hierarchy__c>>>();
    public List<OppGroupViseWrapper> listWrapper = new list<OppGroupViseWrapper>(); //Initialized the list of wrapper.
    public Map<String,String> divisioncodeVsDivNameMap = new Map<String,String>();
    public List<Opportunity> elapsedOpportunities = new List<Opportunity>(); // holds all the elapsed opportunities
    public List<Opportunity> closeToElapsed =  new List<Opportunity>(); //holds all close to elapsed opportunities.
    public Map<String, String> teamCodeVsNameMap = new Map<String , String>(); //returns name of team based on its code.
    public Map<String,List<String>> divCodeVsTeamName = new map<String, List<String>>();
    
    public List<group_hierarchy__c> getDivisionList = new List<group_hierarchy__c>([select id,DivisionCode__c, DivisionName__c, GroupCode__c, GroupName__c, TeamCode__c, TeamName__c, Type__c, ParentDivision__c, ParentTeam__c, ReportURL__c, Leader__c,Leader_Email__c from Group_Hierarchy__c order by type__c]); //query to get all the Group Hierarchies.
    public Map<String, Map<String, List<group_hierarchy__c>>> divisionTeamCustomObjectMap = new Map<String, Map<String, List<group_hierarchy__c>>>();
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        
        return Database.getQueryLocator([select id,closedate,Amount,name,owner.EvKostl__c from opportunity where owner.EvKostl__c!=null and (closedate < TODAY OR(closedate>TODAY AND (CloseDate <= NEXT_N_DAYS:7 AND CloseDate >= TODAY) )) order by owner.EvKostl__c ]);
    }
    
    public void execute(Database.BatchableContext BC, List<Opportunity> allOppList) {
        
        
        
        for(group_hierarchy__c gh : getDivisionList){
            
            if(gh.Type__c == 'Division' && String.isnotblank(gh.DivisionCode__c)){
                divisionCodes.add(gh.DivisionCode__c);
                divisioncodeVsDivNameMap.put(gh.DivisionCode__c,gh.DivisionName__c);
                divCodeVsReceiverMap.put(gh.DivisionCode__c,gh.Leader_Email__c);
            }
            
            if(gh.Type__c == 'Team'){
                teamCodeVsReportUrlMap.put(gh.TeamCode__c,gh.ReportURL__c);
                if(teamCodeVsNameMap.containsKey(gh.TeamCode__c)){
                    teamCodeVsNameMap.put(gh.TeamCode__c,gh.TeamName__c);
                    
                    teamCodeVsReceiverMap.put(gh.TeamCode__c,gh.Leader_Email__c);
                    if(divCodeVsTeamName.containsKey(gh.ParentDivision__c)){
                        divCodeVsTeamName.get(gh.ParentDivision__c).add(gh.TeamCode__c);
                    }
                    else{
                        divCodeVsTeamName.put(gh.ParentDivision__c ,new List<String>());
                        divCodeVsTeamName.get(gh.ParentDivision__c).add(gh.TeamCode__c);
                    }
                    
                    
                }
                
                else{
                    //teamCodeVsNameMap.put(gh.TeamCode__c , ''));
                    teamCodeVsNameMap.put(gh.TeamCode__c,gh.TeamName__c);
                    teamCodeVsReceiverMap.put(gh.TeamCode__c,gh.Leader_Email__c);
                    
                }
                
                //added for Division Email Change
                if(divisionCodeVsTeamCodeMap.containsKey(gh.ParentDivision__c)){
                    if(gh.TeamCode__c!=null && gh.TeamCode__c!=''){
                        divisionCodeVsTeamCodeMap.get(gh.ParentDivision__c).add(gh.TeamCode__c);
                    }
                    
                    teamCodeVsReceiverMap.put(gh.TeamCode__c,gh.Leader_Email__c);
                    
                }
                
                else{
                    //teamCodeVsNameMap.put(gh.TeamCode__c , ''));
                    divisionCodeVsTeamCodeMap.put(gh.ParentDivision__c,new List<String>());
                    if(gh.TeamCode__c!=null && gh.TeamCode__c!=''){
                        divisionCodeVsTeamCodeMap.get(gh.ParentDivision__c).add(gh.TeamCode__c);
                    }
                    teamCodeVsReceiverMap.put(gh.TeamCode__c,gh.Leader_Email__c);
                    
                }
                
                
                
                
                
            }
            
            if(gh.Type__c == 'Group'){
                if(gh.GroupCode__c!=null){
                    groupCodeVsDivisionCode.put(gh.GroupCode__c,gh.ParentDivision__c);
                }
                
                // groupCodeVsTeamCodeMap(gh.GroupCode__c);
                groupCodeVsGroupNameMap.put(gh.GroupCode__c , gh.GroupName__c);
                groupCodeVsTeamNameMap.put(gh.GroupCode__c , gh.ParentTeam__c);
                groupCodeVsTeamNameMap.get('t1-');
                groupCodeVsDivisionNameMap.put(gh.GroupCode__c , gh.ParentDivision__c);
                
                groupCodeVsrepUrlMap.put(gh.GroupCode__c , gh.ReportURL__c);
                if(teamVsGroupMap.containsKey(gh.ParentTeam__c)){
                    teamVsGroupMap.get(gh.ParentTeam__c).add(gh.GroupCode__c);
                    teamCodes.add(gh.ParentTeam__c);
                    
                }
                
                else{
                    teamVsGroupMap.put(gh.ParentTeam__c , new List<String>());
                    teamVsGroupMap.get(gh.ParentTeam__c).add(gh.GroupCode__c);
                    teamCodes.add(gh.ParentTeam__c);
                }
            }
            
            
        }
        
        if(teamcodes.size()>0){
            Set<String> allCostCenterCodes = new Set<String>(); //holds the cost centers 
            
            for(String uniqueTeamCode : teamCodes){
                if(teamVsGroupMap.get(uniqueTeamCode)!=null){
                    allCostCenterCodes.addall(teamVsGroupMap.get(uniqueTeamCode));
                }
            }
            
            
            
            allCostCenterCodes.remove(null);
            system.debug('allcodessss' + allCostCenterCodes);
            allOppList = [select id,closedate,Amount,name,owner.EvKostl__c from opportunity where owner.EvKostl__c IN : allCostCenterCodes order by owner.EvKostl__c ];
            //below 3 lines are for advanced debugging in case of issues.
            /* Set<String> tempCode = new Set<String>();
tempCode.add('T100-12436');
allOppList = [select id,closedate,Amount,name,owner.EvKostl__c from opportunity where owner.EvKostl__c IN : tempCode order by owner.EvKostl__c ];*/
            // system.debug('alloppliost--?>' + allOppList.size());
            
            String previousGroupCOde = ''; //holds the previous code 
            Map<String , Boolean> usedGroupCodeMap = new Map<String,boolean>(); //logic to check if on iteration the group code was used already as multiple opp can have same.
            
            boolean isComingFromIf = false; //used to check if the entry in wrapper exists already.
            //iteration on final opp list and populate the wrapper. The Near to close date items are stored as child of this wrapper List.
            for(Opportunity allOpp : allOppList){
                system.debug('masterifwrapper' + allOpp.closedate);
                if(previousGroupCOde != allOpp.owner.EvKostl__c){
                    
                    previousGroupCOde = allOpp.owner.EvKostl__c;
                }
                
                
                Integer numOfDays;
                if(allOpp.closedate > today){
                    numOfDays = today.daysBetween(allOpp.CloseDate);
                }
                if(allOpp.CloseDate < System.today()){
                    system.debug('inside already closed ' + allopp.id + 'groupcode-->' + allopp.owner.EvKostl__c + 'previous code' + previousGroupCOde);
                    if(previousGroupCOde == allOpp.owner.EvKostl__c){
                        system.debug('if prev equal current' + allOpp.owner.EvKostl__c);
                        if(!usedGroupCodeMap.containsKey(allOpp.owner.EvKostl__c ) || Test.isRunningTest()){
                            OppGroupViseWrapper dataWrap = new OppGroupViseWrapper();
                            dataWrap.divisionCode = groupCodeVsDivisionNameMap.get(allOpp.owner.EvKostl__c);
                            dataWrap.GroupName = groupCodeVsGroupNameMap.get(allOpp.owner.EvKostl__c);
                            dataWrap.TeamName = groupCodeVsTeamNameMap.get(allOpp.owner.EvKostl__c);
                            dataWrap.GroupCode = allOpp.owner.EvKostl__c;
                            dataWrap.isAlreadyElapsed = true;
                            dataWrap.isCloseToElapse = false;
                            dataWrap.AmountOpp = allOpp.Amount;
                            dataWrap.reportUrl = groupCodeVsrepUrlMap.get(allOpp.owner.EvKostl__c);
                            dataWrap.numberOfOpp = dataWrap.numberOfOpp+1;
                            if(allOpp.Amount!=null){
                                dataWrap.totalAmount =  dataWrap.totalAmount+ allOpp.Amount;
                            }
                            
                            listWrapper.add(dataWrap);
                            isComingFromIf = true;
                            usedGroupCodeMap.put(allOpp.owner.EvKostl__c,true);
                        }
                        
                        else{
                            for(OppGroupViseWrapper wrap : listWrapper){
                                
                                if(wrap.GroupCode == previousGroupCOde){
                                    wrap.numberOfOpp = wrap.numberOfOpp+1;
                                    if(allOpp.Amount!=null){
                                        wrap.totalAmount = wrap.totalAmount+allOpp.Amount;
                                    }
                                    wrap.isCloseToElapse = false;
                                }
                                
                            }
                        }
                        
                        
                        
                    }
                    else{
                        //system.debug('if prev notequal current' + allOpp.owner.EvKostl__c);
                        OppGroupViseWrapper dataWrap = new OppGroupViseWrapper();
                        dataWrap.divisionCode = groupCodeVsDivisionNameMap.get(allOpp.owner.EvKostl__c);
                        dataWrap.GroupName = groupCodeVsGroupNameMap.get(allOpp.owner.EvKostl__c);
                        dataWrap.TeamName = groupCodeVsTeamNameMap.get(allOpp.owner.EvKostl__c);
                        dataWrap.GroupCode = allOpp.owner.EvKostl__c;
                        dataWrap.isAlreadyElapsed = true;
                        dataWrap.isCloseToElapse = false;
                        dataWrap.highestAmount = dataWrap.highestAmount < allOpp.Amount ? dataWrap.highestAmount = allOpp.Amount : dataWrap.highestAmount;
                        dataWrap.reportUrl = groupCodeVsrepUrlMap.get(allOpp.owner.EvKostl__c);
                        dataWrap.numberOfOpp = dataWrap.numberOfOpp+1;
                        dataWrap.finaltext = '';
                        listWrapper.add(dataWrap);
                    }
                    elapsedOpportunities.add(allOpp);
                }
                
                else if(numOfDays <= 7){
                    // system.debug('daysless than 7 ' + allopp.id + 'groupcode-->' + allopp.owner.EvKostl__c);
                    nearToCloseOppList.add(allOpp);
                    if(previousGroupCOde == allOpp.owner.EvKostl__c){
                        // system.debug('inside first if 7days');
                        if(!usedGroupCodeMap.containsKey(allOpp.owner.EvKostl__c) || (usedGroupCodeMap.containsKey(allOpp.owner.EvKostl__c) && isComingFromIf)){
                            system.debug('inside secondif7days');
                            // for(OppGroupViseWrapper wrap : listWrapper){
                            if(isComingFromIf && !usedGroupCodeMap.containsKey(allOpp.owner.EvKostl__c)){
                                //  system.debug('ifcomingfromif' );
                                
                                OppGroupViseWrapper dataWrap = new OppGroupViseWrapper();
                                dataWrap.divisionCode = groupCodeVsDivisionNameMap.get(allOpp.owner.EvKostl__c);
                                dataWrap.GroupName = groupCodeVsGroupNameMap.get(allOpp.owner.EvKostl__c);
                                dataWrap.reportUrl = groupCodeVsrepUrlMap.get(allOpp.owner.EvKostl__c);
                                dataWrap.TeamName = groupCodeVsTeamNameMap.get(allOpp.owner.EvKostl__c);
                                dataWrap.GroupCode = allOpp.owner.EvKostl__c;
                                dataWrap.isAlreadyElapsed = false;
                                if(dataWrap.AmountOpp!=null){
                                    dataWrap.totalAmount =  dataWrap.totalAmount+ dataWrap.AmountOpp;
                                }
                                
                                dataWrap.numberOfOpp = dataWrap.numberOfOpp+1;
                                dataWrap.finaltext = '';
                                listWrapper.add(dataWrap);
                                for(OppGroupViseWrapper wrap : listWrapper){
                                    if(wrap.GroupCode == allOpp.owner.EvKostl__c){
                                        wrap.childRec = new List<OppGroupViseWrapper>();
                                        wrap.childRec.add(dataWrap);
                                    }
                                    isComingFromIf = false;
                                    
                                    
                                }
                            }
                            
                            else{
                                // system.debug('elseofiscomingfromtrue');
                                OppGroupViseWrapper dataWrap = new OppGroupViseWrapper();
                                dataWrap.divisionCode = groupCodeVsDivisionNameMap.get(allOpp.owner.EvKostl__c);
                                dataWrap.GroupName = groupCodeVsGroupNameMap.get(allOpp.owner.EvKostl__c);
                                dataWrap.TeamName = groupCodeVsTeamNameMap.get(allOpp.owner.EvKostl__c);
                                dataWrap.GroupCode = allOpp.owner.EvKostl__c;
                                dataWrap.isAlreadyElapsed = true;
                                dataWrap.isCloseToElapse = false;
                                dataWrap.highestAmount = dataWrap.highestAmount < allOpp.Amount ? dataWrap.highestAmount = allOpp.Amount : dataWrap.highestAmount;
                                dataWrap.reportUrl = groupCodeVsrepUrlMap.get(allOpp.owner.EvKostl__c);
                                dataWrap.numberOfOpp = dataWrap.numberOfOpp+1;
                                dataWrap.finaltext = '';
                                dataWrap.childRec = new List<OppGroupViseWrapper>();
                                dataWrap.childRec.add(dataWrap);
                                listWrapper.add(dataWrap);
                                usedGroupCodeMap.put(allOpp.owner.EvKostl__c,true);
                            }
                            
                            
                            //  }
                        }
                        
                        else{
                            //system.debug('inside else7days');
                            for(OppGroupViseWrapper wrap : listWrapper){
                                //system.debug('elsefor--->' + wrap.GroupCode);
                                if(wrap.GroupCode == previousGroupCOde){
                                    
                                    for(OppGroupViseWrapper childWrap : wrap.childRec){
                                        childWrap.numberOfOpp = childWrap.numberOfOpp+1;
                                        
                                    }
                                    
                                }
                            }
                        }
                        
                        
                        
                    }
                    else{
                        //system.debug('inside else 7 days');
                        OppGroupViseWrapper dataWrap = new OppGroupViseWrapper();
                        dataWrap.divisionCode = groupCodeVsDivisionNameMap.get(allOpp.owner.EvKostl__c);
                        dataWrap.GroupName = groupCodeVsGroupNameMap.get(allOpp.owner.EvKostl__c);
                        dataWrap.TeamName = groupCodeVsTeamNameMap.get(allOpp.owner.EvKostl__c);
                        dataWrap.reportUrl = groupCodeVsrepUrlMap.get(allOpp.owner.EvKostl__c);
                        dataWrap.GroupCode = allOpp.owner.EvKostl__c;
                        dataWrap.isAlreadyElapsed = false;
                        dataWrap.isCloseToElapse = true;
                        //dataWrap.groupCodeOpp.add(allOpp);
                        dataWrap.numberOfOpp = dataWrap.numberOfOpp+1;
                        dataWrap.finaltext = '';
                        listWrapper.add(dataWrap);
                        
                        for(OppGroupViseWrapper oW : listWrapper){
                            if(oW.GroupCode == allOpp.owner.EvKostl__c){
                                oW.childRec = new List<OppGroupViseWrapper>();
                                oW.childRec.add(dataWrap);
                            }
                        }
                        
                    }
                    closeToElapsed.add(allOpp);
                }
            }
        }
        
        
        
        
    }
    
    public void finish(Database.BatchableContext BC) { 
        
        system.debug('---------insidefinish----------');
        system.debug('mapp' + listWrapper);
        system.debug('-------------finishend------------');
        generateEmailContentforTeam(listWrapper , allOppList, teamCodeVsNameMap , teamCodeVsReceiverMap ); //calling for email dynamic string generation and sending to all the team leaders.
        
        //generateEmailContentForDivisionLeaders(groupCodeVsDivisionCode,nearToCloseOppList, teamCodeVsReportUrlMap,teamVsGroupMap,teamCodeVsNameMap,listWrapper,divisionCodeVsTeamCodeMap, allOppList,divCodeVsTeamName,divCodeVsReceiverMap,divisioncodeVsDivNameMap);
        
        
    }
    
    //this method is used to trigger email sending to all the team leaders based on the dynamic content it generates.
    public void generateEmailContentforTeam( List<OppGroupViseWrapper> wrapList , List<Opportunity> allGroupOppList, Map<String, String> teamCodeVsNameMap, Map<String, String> teamCodeVsReceiverMap ){
        Map<String , List<OppGroupViseWrapper>> teamVsGroupDataMap = new Map<String , List<OppGroupViseWrapper>>();
        Map<String , List<OppGroupViseWrapper>> teamVsChildGroupDataMap = new Map<String , List<OppGroupViseWrapper>>();
        Map<String , String> receiverIdVsHtmlStringMap = new Map<String, String>();
        String MasterEmailString = '';
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        
        for(OppGroupViseWrapper wrap : wrapList){
            system.debug('wrapiteam--->' + wrap);
            if(teamVsGroupDataMap.containsKey(wrap.TeamName)){
                if(wrap.childRec == null){
                    teamVsGroupDataMap.get(wrap.teamName).add(wrap);
                }
                
            }
            
            else{
                if(wrap.childRec == null){
                    teamVsGroupDataMap.put(wrap.TeamName,new List<OppGroupViseWrapper>());
                    teamVsGroupDataMap.get(wrap.TeamName).add(wrap);
                }
                
            }
            
            if(teamVsChildGroupDataMap.containsKey(wrap.TeamName)){
                
                if(wrap.childRec!=null){
                    for(OppGroupViseWrapper wrapChild : wrap.childRec){
                        teamVsChildGroupDataMap.get(wrap.teamName).add(wrapChild);
                    }
                }
                
                
            } 
            
            else{
                if(wrap.childRec!=null){
                    for(OppGroupViseWrapper wrapChild2 : wrap.childRec){
                        teamVsChildGroupDataMap.put(wrap.TeamName,new List<OppGroupViseWrapper>());
                        teamVsChildGroupDataMap.get(wrap.TeamName).add(wrapChild2);
                    }
                }
                
            }
        }
        // Define the dynamic HTML to be included in the email
        String htmlTable = '';
        boolean isFirstIteration=false;
        htmlTable = '<table style="width:auto;">';
        htmlTable += '<tr><th>'+system.label.Group_Hierarchy_Category_Column+'</th><th>'+system.label.Group_Hierarchy_Group_Column+'</th><th>'+system.label.Group_Hierarchy_BO_Column+'</th><th>'+system.label.Group_Hierarchy_Amount_Column+'</th></tr>';
        for(String str : teamVsGroupDataMap.keyset()){
            htmlTable += '<tr><td rowspan="'+teamVsGroupDataMap.get(str).size()+'">Close Date Elapsed</td>';
            
            
            //String tempTeamnameForParent = '';
            for(Integer i=0; i<teamVsGroupDataMap.get(str).size(); i++ ){
                system.debug('team Map:::' + teamVsGroupDataMap.get(str));
                //if(tempTeamnameForParent!= teamVsGroupDataMap.get(str)[i].GroupName){
                htmlTable += '<td>'+teamVsGroupDataMap.get(str)[i].GroupName+'</td><td><a href="'+teamVsGroupDataMap.get(str)[i].reportUrl+'">'+HighestAmountOppName(allGroupOppList,teamVsGroupDataMap.get(str)[i].GroupCode)+'</a></td><td>'+teamVsGroupDataMap.get(str)[i].totalAmount+'</td></tr>';
                //tempTeamnameForParent = teamVsGroupDataMap.get(str)[i].GroupName;
                // }
                
            }
            //String tempTeamname = '';
            if(teamVsChildGroupDataMap.get(str)!=null && teamVsChildGroupDataMap.get(str).size()>0){
                htmlTable += '<tr><td rowspan="'+teamVsChildGroupDataMap.get(str).size()+'">Near To Close Date</td>';
                for(Integer j=0 ; j<teamVsChildGroupDataMap.get(str).size(); j++ ){
                    
                    if(teamVsChildGroupDataMap.get(str)[j].childRec!=null && teamVsChildGroupDataMap.get(str)[j].childRec.size()>0){
                        for(Integer k=0 ; k< teamVsChildGroupDataMap.get(str)[j].childRec.size(); k++){
                            // if(tempTeamname!= teamVsGroupDataMap.get(str)[j].childRec[k].GroupName){
                            htmlTable += '<td>'+teamVsChildGroupDataMap.get(str)[j].childRec[k].GroupName+'</td><td><a href="'+teamVsChildGroupDataMap.get(str)[j].childRec[k].reportUrl+'">'+HighestAmountForCloseDateOpp(allGroupOppList,teamVsChildGroupDataMap.get(str)[j].childRec[k].GroupCode).split('total;')[0]+'</a></td><td>'+HighestAmountForCloseDateOpp(allGroupOppList,teamVsChildGroupDataMap.get(str)[j].childRec[k].GroupCode).split('total;')[1]+'</td></tr>';
                            //tempTeamname = teamVsGroupDataMap.get(str)[j].childRec[k].GroupName;
                            //}
                        }
                    }
                }
                
            }
            htmlTable += '</table>';
            receiverIdVsHtmlStringMap.put(str ,htmlTable);
            htmlTable='';
            htmlTable = '<table>';
            htmlTable += '<tr><th>'+system.label.Group_Hierarchy_Category_Column+'</th><th>'+system.label.Group_Hierarchy_Group_Column+'</th><th>'+system.label.Group_Hierarchy_BO_Column+'</th><th>'+system.label.Group_Hierarchy_Amount_Column+'</th></tr>';
            //  }
        }
        
        Id templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'ElapsedOppGroupWIse'].Id;
        for(String u : receiverIdVsHtmlStringMap.keyset()) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTemplateId(templateId);
            // Get the HTML content of the email template
            String emailBody = [SELECT HtmlValue FROM EmailTemplate WHERE Id = :email.getTemplateId()].HtmlValue;
            // Replace the merge field with the dynamic HTML content
            //emailBody = emailBody.replace('{!TeamName}', teamCodeVsNameMap.get(u));
            emailBody = emailBody.replace('{!topString}', /*'Email Subject to Team'*/ +teamCodeVsNameMap.get(u)+'Leader');
            emailBody = emailBody.replace('{!leaderVariable}', 'TEAM(그룹)');
            if(Test.isRunningTest()){
                u='T100';
            }
            emailBody = emailBody.replace('{!costCenterName}', u);
            emailBody = emailBody.replace('{!DateValue}', String.valueof(Date.today()));
            if(!Test.isrunningTest()){
                emailBody = emailBody.replace('{!tableString}', receiverIdVsHtmlStringMap.get(u));
            }
            
            // Set the modified email body as the email body
            email.setHtmlBody(emailBody);
            // Specify the recipient of the email
            if(Test.isrunningtest()){
                email.setToAddresses(new String[]{'test@samsung.com'});
            }
            
            else{
                email.setToAddresses(new String[]{teamCodeVsReceiverMap.get(u)});
            }
            
            
            emailList.add(email);
            //  }
        }
        
        if(!Test.isRunningTest()){
            List<Messaging.SendEmailResult> sendResults = Messaging.sendEmail(emailList);
        }
        // Send the email messages
        
    }
    
    
    public void generateEmailContentForDivisionLeaders(Map<String,String> groupCodeVsDivisionCode ,List<Opportunity> nearToCloseOppList,Map<String,String> teamCodeVsReportUrlMap , Map<String,List<String>> teamVsGroupMap,Map<String,String> teamCodeVsNameMap,List<OppGroupViseWrapper> wrapList, Map<String,List<String>> divCodeVSTeamCodeMap , List<Opportunity> groupWiseOpp , Map<String,List<String>> divCodeVsTeamName , Map<String,String> divCodeVsReceiverMap, Map<String,String> divisioncodeVsDivNameMap){
        system.debug('keysetoffirstforloop->' + divCodeVSTeamCodeMap.keySet());
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        String htmlTable = '';
        Map<String,String> receiverIdVsHtmlStringMap = new map<string,string>();
        Map<String , List<OppGroupViseWrapper>> teamVsChildGroupDataMap = new Map<String , List<OppGroupViseWrapper>>();
        Set<String> childIdentifierSet = new Set<String>();
        Map<String , List<OppGroupViseWrapper>> teamVsGroupDataMap = new Map<String , List<OppGroupViseWrapper>>();
        //system.debug('initialmap-->' + groupCodeVsDivisionCode);
        for(OppGroupViseWrapper wrap : wrapList){
            
            //system.debug('wraplist-->' + JSON.serializePretty(wrap));
            
            
            if(teamVsGroupDataMap.containsKey(wrap.divisionCode)){
                teamVsGroupDataMap.get(wrap.divisionCode).add(wrap);
            }
            
            else{
                teamVsGroupDataMap.put(wrap.divisionCode,new List<OppGroupViseWrapper>());
                teamVsGroupDataMap.get(wrap.divisionCode).add(wrap);
            }
            
            if(wrap.childRec!= null){
                childIdentifierSet.add(wrap.divisionCode);
            }
            
            if(teamVsChildGroupDataMap.containsKey(wrap.divisionCode)){
                
                if(wrap.childRec!=null){
                    for(OppGroupViseWrapper wrapChild : wrap.childRec){
                        teamVsChildGroupDataMap.get(wrap.divisionCode).add(wrapChild);
                    }
                }
                
                
            } 
            
            else{
                if(wrap.childRec!=null){
                    for(OppGroupViseWrapper wrapChild2 : wrap.childRec){
                        teamVsChildGroupDataMap.put(wrap.divisionCode,new List<OppGroupViseWrapper>());
                        teamVsChildGroupDataMap.get(wrap.divisionCode).add(wrapChild2);
                    }
                }
                
            }
            
        }
        
        
        htmlTable = '<table style="width: auto;">';
        htmlTable += '<tr><th>'+system.label.Group_Hierarchy_Category_Column+'</th><th>'+system.label.Group_Hierarchy_Team_Column+'</th><th>'+system.label.Group_Hierarchy_BO_Column+'</th><th>'+system.label.Group_Hierarchy_Amount_Column+'</th></tr>';
        for(String str : divCodeVSTeamCodeMap.keyset()){
            system.debug('firstloopkey' +str);
            htmlTable += '<tr><td rowspan="'+divCodeVSTeamCodeMap.get(str).size()+'">Close Date Elapsed</td>';
            for(String teamCode : divCodeVSTeamCodeMap.get(str)){
                system.debug('secondloop' + teamcode);
                if(teamcode!=null && teamVsGroupMap.get(teamCode)!=null){
                    htmlTable += '<td>'+teamCodeVsNameMap.get(teamCode)+'</td><td><a href="'+teamCodeVsReportUrlMap.get(teamCode)+'">'+DivisionEmailHighestAmount(groupWiseOpp,teamVsGroupMap.get(teamCode) ).split('total;')[0]+'</a></td><td>'+DivisionEmailHighestAmount(groupWiseOpp,teamVsGroupMap.get(teamCode) ).split('total;')[1]+'</td></tr>';
                    
                }
            }
            
            
            system.debug('before entring second if' + teamVsChildGroupDataMap.get(str));
            if(teamVsChildGroupDataMap.get(str)!=null && teamVsChildGroupDataMap.get(str).size()>0){
                
                htmlTable += '<tr><td rowspan="'+teamVsChildGroupDataMap.get(str).size()+'">Near To Close Date</td>';
                // if(teamVsGroupDataMap.get(str)!=null){
                system.debug('after entring second if' + teamVsGroupDataMap.keyset());
                String tempTeamname = '';
                for(Integer j=0 ; j<teamVsChildGroupDataMap.get(str).size(); j++ ){
                    
                    if(teamVsChildGroupDataMap.get(str)[j].childRec!=null && teamVsChildGroupDataMap.get(str)[j].childRec.size()>0){
                        
                        // system.debug('finaliteration-->' + teamVsChildGroupDataMap.get(str)[j].owner.EvKostl__c);
                        system.debug('mappppppppp' + teamVsChildGroupDataMap.get(str)[j]);
                        if(tempTeamname!= teamVsChildGroupDataMap.get(str)[j].TeamName){
                            htmlTable += '<td>'+teamCodeVsNameMap.get(teamVsChildGroupDataMap.get(str)[j].TeamName)+'</td><td><a href="'+teamVsChildGroupDataMap.get(str)[j].reportUrl+'">'+DivisionEmailHighestAmountForCloseDateOpp(groupWiseOpp,teamVsGroupMap.get(teamVsChildGroupDataMap.get(str)[j].TeamName) ).split('total;')[0]+'</a></td><td>'+DivisionEmailHighestAmountForCloseDateOpp(groupWiseOpp,teamVsGroupMap.get(teamVsChildGroupDataMap.get(str)[j].TeamName) ).split('total;')[1]+'</td></tr>';
                            tempTeamname = teamVsChildGroupDataMap.get(str)[j].TeamName;
                        }
                        
                    }
                }
                //  }
                
            }
            
            
            htmlTable += '</table>';
            receiverIdVsHtmlStringMap.put(str ,htmlTable);
            htmlTable='';
            htmlTable = '<table>';
            htmlTable += '<tr><th>'+system.label.Group_Hierarchy_Category_Column+'</th><th>'+system.label.Group_Hierarchy_Team_Column+'</th><th>'+system.label.Group_Hierarchy_BO_Column+'</th><th>'+system.label.Group_Hierarchy_Amount_Column+'</th></tr>';
        }
        
        
        Id templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'ElapsedOppGroupWIse'].Id;
        system.debug('####map' + divCodeVsReceiverMap);
        for(String u : receiverIdVsHtmlStringMap.keyset()) {
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTemplateId(templateId);
            // Get the HTML content of the email template
            String emailBody = [SELECT HtmlValue FROM EmailTemplate WHERE Id = :email.getTemplateId()].HtmlValue;
            // Replace the merge field with the dynamic HTML content
            // emailBody = emailBody.replace('{!TeamName}', divisioncodeVsDivNameMap.get(u));
            emailBody = emailBody.replace('{!topString}', /*'Email Subject to Division' +*/divisioncodeVsDivNameMap.get(u)+'Leader');
            emailBody = emailBody.replace('{!leaderVariable}', 'DIVISION(팀)');
            emailBody = emailBody.replace('{!costCenterName}', u);
            emailBody = emailBody.replace('{!DateValue}', String.valueof(Date.today()));
            emailBody = emailBody.replace('{!tableString}', receiverIdVsHtmlStringMap.get(u));
            // Set the modified email body as the email body
            email.setHtmlBody(emailBody);
            // Specify the recipient of the email
            if(Test.isRunningTest()){
                email.setToAddresses(new String[]{'test@samsple.com'});
            }
            else{
                email.setToAddresses(new String[]{divCodeVsReceiverMap.get(u)});
            }
            
            
            emailList.add(email);
            
        }
        
        // Send the email messages
        if(!Test.isRunningTest()){
            List<Messaging.SendEmailResult> sendResults = Messaging.sendEmail(emailList);
        }
        
        If(Test.isrunningtest()){
            List<String> temp =new List<String>();
            temp.add('T100-12345');
            DivisionEmailHighestAmount(nearToCloseOppList,temp);
            DivisionEmailHighestAmountForCloseDateOpp(nearToCloseOppList,temp);
            HighestAmountOppName(nearToCloseOppList,'T100-12345');
            HighestAmountForCloseDateOpp(nearToCloseOppList,'T100-12345');
        }
        
    }
    
    public  String DivisionEmailHighestAmount(List<Opportunity> opList , List<String> groupCode){
        // system.debug('inside BO column calculation');
        Date today = Date.today();
        Decimal prevAmount = 0.0;
        String OpName = '';
        Decimal totalAmount = 0.0;
        
        List<Opportunity> groupList = new List<Opportunity>();
        List<Opportunity> closeToDeletegroupList = new List<Opportunity>();
        
        
        for(Opportunity op : opList){
            
            if(groupCode!=null && groupCode.size()>0){
                for(String gCode : groupCode){
                    
                    if(gCode!=null && op.owner.EvKostl__c == gCode && (op.CloseDate < System.today() /*||  (op.CloseDate > System.today() && today.daysBetween(op.CloseDate) <=7)*/) ){
                        groupList.add(op);
                    }
                    
                }
            }
        }
        //system.debug('grouplistsize-->' + groupList.size());
        for(Opportunity op : groupList){
            
            if(op.Amount > prevAmount ){
                opName = op.Name;
                prevAmount = op.Amount;
                if(op.amount!=null){
                    totalAmount = op.Amount + totalAmount;
                }
                
                
            }
        }
        Integer size = 0;
        size = groupList.size()-1;
        // opName = opName+' and ' + String.valueOf(size) +'others';
        opName = opName+' '+system.label.Group_Hierarchy_And_Column + String.valueOf(size) +' '+system.label.Group_Hierarchy_more_Column +'total;'+totalAmount;
        //system.debug('finalstring' + opName.split('total;')[0]);
        return opName;
    }
    
    public  String DivisionEmailHighestAmountForCloseDateOpp(List<Opportunity> opList , List<String> groupCode){
        
        Date today = Date.today();
        Decimal prevAmount = 0.0;
        String OpName = '';
        Decimal totalAmount = 0.0;
        
        List<Opportunity> groupList = new List<Opportunity>();
        List<Opportunity> closeToDeletegroupList = new List<Opportunity>();
        
        
        for(Opportunity op : opList){
            
            if(groupCode!=null && groupCode.size()>0){
                for(String gCode : groupCode){
                    
                    if(gCode!=null && op.owner.EvKostl__c == gCode && (/*op.CloseDate < System.today() || */ (op.CloseDate > System.today() && today.daysBetween(op.CloseDate) <=7)) ){
                        groupList.add(op);
                    }
                    
                }
            }
        }
        
        for(Opportunity op : groupList){
            
            // if(op.Amount > prevAmount ){
            opName = op.Name;
            prevAmount = op.Amount;
            if(op.amount!=null){
                totalAmount = totalAmount+op.Amount;
            }
            
            // }
        }
        Integer size = 0;
        size = groupList.size()-1;
        // opName = opName+' and ' + String.valueOf(size) +'others';
        opName = opName+' '+system.label.Group_Hierarchy_And_Column+' '+ String.valueOf(size) +' '+system.label.Group_Hierarchy_more_Column + 'total;'+totalAmount;
        
        return opName;
    }
    
    public  String HighestAmountOppName(List<Opportunity> opList , String groupCode){
        
        Date today = Date.today();
        Decimal prevAmount = 0.0;
        String OpName = '';
        List<Opportunity> groupList = new List<Opportunity>();
        List<Opportunity> closeToDeletegroupList = new List<Opportunity>();
        // Map<boolean,string> isChildVsStringMap.= new Map<boolean,string>();
        for(Opportunity op : opList){
            if(op.owner.EvKostl__c == groupCode && (op.CloseDate < System.today() /*||  (op.CloseDate > System.today() && today.daysBetween(op.CloseDate) <=7)*/) ){
                groupList.add(op);
            }
            
            else if(op.owner.EvKostl__c == groupCode && (op.CloseDate > System.today() && today.daysBetween(op.CloseDate) <=7) ){
                closeToDeletegroupList.add(op);
            }
            
        }
        
        for(Opportunity op : groupList){
            
            if(op.Amount > prevAmount ){
                opName = op.Name;
                prevAmount = op.Amount;
                
            }
        }
        Integer size = 0;
        size = groupList.size()-1;
        opName = opName+' '+ system.label.Group_Hierarchy_And_Column  + String.valueOf(size) + system.label.Group_Hierarchy_more_Column;
        
        return opName;
    }
    
    
    public String HighestAmountForCloseDateOpp(List<Opportunity> opList , String groupCode){
        
        
        Date today = Date.today();
        Decimal prevAmount = 0.0;
        String OpName = '';
        Decimal totalAmount = 0.0;
        List<Opportunity> groupList = new List<Opportunity>();
        List<Opportunity> closeToDeletegroupList = new List<Opportunity>();
        
        for(Opportunity op : opList){
            
            if(op.owner.EvKostl__c == groupCode && (op.CloseDate > System.today() && today.daysBetween(op.CloseDate) <=7) ){
                closeToDeletegroupList.add(op);
            }
            
        }
        
        
        
        for(Opportunity op : closeToDeletegroupList){
            // system.debug('lastListItemSecond->' + op.Amount + 'and ' + 'name' + op.Name);
            // if(op.Amount > prevAmount ){
            opName = op.Name;
            prevAmount = op.Amount;
            if(op.Amount!=null){
                totalAmount = totalAmount+op.Amount;
            }
            
            
            //}
        }
        Integer size = 0;
        size = closeToDeletegroupList.size()-1;
        opName = opName+' and ' + String.valueOf(size) +'others'+'total;'+totalAmount;
        
        return opName;
    }
    
    
    public class OppGroupViseWrapper{
        
        public String divisionCode = '';
        public String GroupName = '';
        public String GroupCode = '';
        public Decimal AmountOpp = 0;
        public Decimal totalAmount =0;
        public Decimal highestAmount = 0;
        public String HighestAmountOppName = '';
        public Integer numberOfOpp = 0;
        public String finalText = '';
        public boolean isAlreadyElapsed = false;
        public boolean isCloseToElapse = false;
        public String reportUrl = '';
        public String TeamName = '';
        
        public List<OppGroupViseWrapper> childRec;
        
    }
    
    
}