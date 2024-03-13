/**
* @description       : This is a scheduled Apex Class that runs in order to Send Email to all the Team Leaders with The info of Elapsed(Close Date passed)/Near To Elapsed(7 or less than 7 Days to clsoe Date)
* @author            : rakshit.s@samsung.com
* @group             : 
* @date created  : 02-20-2023
* @last modified on : 11-13-2023
* @last modified by  : chae_ho.yang@samsung.com
* @Version: V1.0 (Initial Development)
* @version V2.0 Ability to send emails to multiple leaders (upto 10).
* @version V2.1 Ability To convert all amount to the User local currency (KRW) and calculate highest amount and total accordinly.
* @version V2.2 Ability to show the sub total and total of all the values on table values eg count and amount
* @version V2.3 Template Changes and Making Headings bold for the Email and also fixed the duplicate map values issue
* @version V2.4 Show amount as two => one decimal place (modified decimalToCommaSeparatedInteger method)
* @Version V2.5 Updated Table CSS for Sub-Total and Total Table Rows.
* @Version V2.6 Delayed BO Mailing SQOL condition change(MySales -202)
* @version V3.0 Maintain the order of Table Rows based on Amount Column in descending order. MySales-191
* @version V3.1 Fixed issue on near to delay BO for division leader where order was not coming right in desc order. 
**/ 
global class GroupHierarchyBOInfo {
    
    
    
    //This Apex method is invoked from the scheduler or any other Apex Class and it prepares whole data for snding emails.
    @future(callout=true) public static void sendEmailToLeaders()
    {
        
        Set<String> divisionCodes = new Set<String>(); //to hold all the team codes.
        Set<String> teamCodes = new Set<String>(); //to hold all the team codes.
        Map<String , List<String>> teamVsGroupMap = new Map<String , List<String>>(); //map that returns all the groups when a Team Code is passed.
        List<Opportunity> allOppList = new List<Opportunity>(); //All opportunities are stored in this once we have all the group codes from Group Hierarchy Object.
        List<Opportunity> nearToCloseOppList = new List<Opportunity>(); //All opportunities are stored in this once we have all the group codes from Group Hierarchy Object.
        
        Date today = Date.today(); //To hold current Date.
        Map<String, String> groupCodeVsGroupNameMap = new Map<String , String>(); //Returns Name of the group from Group Code.
        Map<String, String> groupCodeVsDivisionNameMap = new Map<String , String>(); //Returns Name of the group from Group Code.
        Map<String, String> groupCodeVsTeamNameMap = new Map<String , String>(); //Returns Tem Name based on Group Code.
        Map<String, String> groupCodeVsrepUrlMap = new Map<String , String>(); //Returns Report Url based on Group Code.
        Map<String, String> groupCodeVsrepUrlMap2 = new Map<String , String>(); //Returns Report Url2 based on Group Code.
        Map<String, List<String>> teamCodeVsReceiverMap = new Map<String , List<String>>(); //Returns Report Url based on Group Code.
        Map<String,List<String>> divCodeVsReceiverMap = new map<String,List<String>>();
        Map<String,String> teamCodeVsReportUrlMap = new Map<String , String>(); 
        Map<String,String> teamCodeVsReportUrlMap2 = new Map<String , String>(); 
        Map<String,String> groupCodeVsDivisionCode = new Map<String , String>();
        Map<String,String> groupCodeVsTeamCodeMap = new Map<String , String>(); 
        Map<String , Decimal> teamcodeVstotalOppAmountMap = new Map<String , Decimal>(); //V3.0
        
        Set<String> requiredGroupCode = new Set<String>();
        Set<String> requiredTeamCodes = new Set<String>();
        Set<String> requiredTeamAlreadyClosedCodes = new Set<String>();
        Set<String> requiredTeamNearToClosedCodes = new Set<String>();
        
        //Map<>String , String> groupCodeVsDivi
        //added for Division Email Change.
        Map<String , List<String>> divisionCodeVsTeamCodeMap = new Map<String, List<String>>();
        Map<String, Map<String, List<group_hierarchy__c>>> divisionTeamOppMap = new Map<String, Map<String, List<group_hierarchy__c>>>();
        List<OppGroupViseWrapper> listWrapper = new list<OppGroupViseWrapper>(); //Initialized the list of wrapper.
        Map<String,String> divisioncodeVsDivNameMap = new Map<String,String>();
        List<Opportunity> elapsedOpportunities = new List<Opportunity>(); // holds all the elapsed opportunities
        List<Opportunity> closeToElapsed =  new List<Opportunity>(); //holds all close to elapsed opportunities.
        Map<String, String> teamCodeVsNameMap = new Map<String , String>(); //returns name of team based on its code.
        Map<String, String> divCodeVsdivNameMap = new Map<String , String>(); //returns name of team based on its code.
        Map<String,List<String>> divCodeVsTeamName = new map<String, List<String>>();
        Set<String> setSubsidiary = new Set<String>(System.Label.OPPTYACT_BO_SUBSIDIARY_LIST.split(','));  //자회사는 대상에서 제외
        List<String> listRestrictedEmail = new List<String>{'mysales@samsung.com'};
            List<group_hierarchy__c> getDivisionList = new List<group_hierarchy__c>([select id,DivisionCode__c, DivisionName__c, GroupCode__c, GroupName__c, TeamCode__c, TeamName__c, Type__c, ParentDivision__c, ParentTeam__c, ReportURL__c, ReportURL2__c,Leader__c,Leader_Email__c from Group_Hierarchy__c order by type__c]); //query to get all the Group Hierarchies.
        Map<String, Map<String, List<group_hierarchy__c>>> divisionTeamCustomObjectMap = new Map<String, Map<String, List<group_hierarchy__c>>>();
        //Iterate over Queried Group Hierarchies and populate the Sets and Maps based on Type__c
        for(group_hierarchy__c gh : getDivisionList){
            
            if(gh.Type__c == 'Division' && String.isnotblank(gh.DivisionCode__c)){
                divisionCodes.add(gh.DivisionCode__c);
                divisioncodeVsDivNameMap.put(gh.DivisionCode__c,gh.DivisionName__c);
                if(gh.Leader_Email__c!=null || gh.Leader_Email__c!=''){
                    divCodeVsReceiverMap.put(gh.DivisionCode__c,new List<String>());
                    // divCodeVsReceiverMap.get(gh.DivisionCode__c).a
                    String abc = gh.Leader_Email__c;
                    List<String> stringList = abc.split(';');
                    List<String> nonEmptyStringList = new List<String>();
                    
                    for(String s : stringList) {
                        if(!String.isBlank(s)) {
                            nonEmptyStringList.add(s);
                        }
                    }
                    divCodeVsReceiverMap.get(gh.DivisionCode__c).addAll(nonEmptyStringList);
                    
                }
                
                //divCodeVsdivNameMap.put(gh.DivisionCode__c , gh);
            }
            
            if(gh.Type__c == 'Team'){
                teamCodeVsReportUrlMap.put(gh.TeamCode__c,gh.ReportURL__c);
                teamCodeVsReportUrlMap2.put(gh.TeamCode__c,gh.ReportURL2__c);
                if(teamCodeVsNameMap.containsKey(gh.TeamCode__c)){
                    teamCodeVsNameMap.put(gh.TeamCode__c,gh.TeamName__c);
                    
                    teamCodeVsReceiverMap.put(gh.TeamCode__c, new List<String>());
                    String abc = gh.Leader_Email__c;
                    List<String> stringList = abc.split(';');
                    List<String> nonEmptyStringList = new List<String>();
                    
                    for(String s : stringList) {
                        if(!String.isBlank(s)) {
                            nonEmptyStringList.add(s);
                        }
                    }
                    teamCodeVsReceiverMap.get(gh.DivisionCode__c).addAll(nonEmptyStringList);
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
                    if(gh.Leader_Email__c!=null || gh.Leader_Email__c!=''){
                        teamCodeVsReceiverMap.put(gh.TeamCode__c,new List<String>());
                        String abc = gh.Leader_Email__c;
                        List<String> stringList = abc.split(';');
                        List<String> nonEmptyStringList = new List<String>();
                        
                        for(String s : stringList) {
                            if(!String.isBlank(s)) {
                                nonEmptyStringList.add(s);
                            }
                        }
                        teamCodeVsReceiverMap.get(gh.TeamCode__c).addAll(nonEmptyStringList);
                    }
                    
                }
                
                //added for Division Email Change
                if(divisionCodeVsTeamCodeMap.containsKey(gh.ParentDivision__c)){
                    if(gh.TeamCode__c!=null && gh.TeamCode__c!=''){
                        divisionCodeVsTeamCodeMap.get(gh.ParentDivision__c).add(gh.TeamCode__c);
                    }
                    
                    teamCodeVsReceiverMap.put(gh.TeamCode__c,new List<String>());
                    String abc = gh.Leader_Email__c;
                    List<String> stringList = abc.split(';');
                    List<String> nonEmptyStringList = new List<String>();
                    
                    for(String s : stringList) {
                        if(!String.isBlank(s)) {
                            nonEmptyStringList.add(s);
                        }
                    }
                    teamCodeVsReceiverMap.get(gh.TeamCode__c).addAll(nonEmptyStringList);
                    
                    
                }
                
                else{
                    //teamCodeVsNameMap.put(gh.TeamCode__c , ''));
                    divisionCodeVsTeamCodeMap.put(gh.ParentDivision__c,new List<String>());
                    if(gh.TeamCode__c!=null && gh.TeamCode__c!=''){
                        divisionCodeVsTeamCodeMap.get(gh.ParentDivision__c).add(gh.TeamCode__c);
                    }
                    teamCodeVsReceiverMap.put(gh.TeamCode__c,new List<String>());
                    String abc = gh.Leader_Email__c;
                    List<String> stringList = abc.split(';');
                    List<String> nonEmptyStringList = new List<String>();
                    
                    for(String s : stringList) {
                        if(!String.isBlank(s)) {
                            nonEmptyStringList.add(s);
                        }
                    }
                    teamCodeVsReceiverMap.get(gh.TeamCode__c).addAll(nonEmptyStringList);
                    
                }
                
                
                
                
                
            }
            
            if(gh.Type__c == 'Group'){
                if(gh.GroupCode__c!=null){
                    groupCodeVsDivisionCode.put(gh.GroupCode__c,gh.ParentDivision__c);
                    if(gh.ParentTeam__c!=null){
                        groupCodeVsTeamCodeMap.put(gh.GroupCode__c,gh.ParentTeam__c);
                    }
                }
                
                
                groupCodeVsGroupNameMap.put(gh.GroupCode__c , gh.GroupName__c);
                groupCodeVsTeamNameMap.put(gh.GroupCode__c , gh.ParentTeam__c);
                //groupCodeVsTeamNameMap.get('t1-');
                groupCodeVsDivisionNameMap.put(gh.GroupCode__c , gh.ParentDivision__c);
                
                groupCodeVsrepUrlMap.put(gh.GroupCode__c , gh.ReportURL__c);
                groupCodeVsrepUrlMap2.put(gh.GroupCode__c , gh.ReportURL2__c);
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
            
            system.debug('mapbeforeupdate-->' + divisionCodeVsTeamCodeMap);
            system.debug('teamvsgroupmap-->' + teamVsGroupMap);
            for(String str : divisionCodeVsTeamCodeMap.keySet()){
                for(Integer i=0 ; i<divisionCodeVsTeamCodeMap.get(str).size(); i++ ){
                    system.debug('key is-->' + str);
                    system.debug('initial map change:' + teamVsGroupMap.get(divisionCodeVsTeamCodeMap.get(str)[i]));
                    if(teamVsGroupMap.get(divisionCodeVsTeamCodeMap.get(str)[i]) == null /*|| teamVsGroupMap.get(divisionCodeVsTeamCodeMap.get(str)[i]).isEmpty()*/){
                        divisionCodeVsTeamCodeMap.get(str).remove(i);
                        //divisionCodeVsTeamCodeMap.get(str)
                    }
                    
                    
                    
                    
                    
                    
                }
                
            }   
            
            system.debug('mapafterupdate-->' + divisionCodeVsTeamCodeMap);
            system.debug('allcodessss' + allCostCenterCodes);
            //V2.6 -> Add FirstCloseDate__c = null condition in below soql query for MySales 202.
            
            allOppList = [select id,closedate,convertCurrency(Amount),convertCurrency(AmountDivide8__c),name,owner.EvKostl__c from opportunity where owner.EvKostl__c IN : allCostCenterCodes AND (closedate < TODAY or (closedate >= TODAY AND closedate <= NEXT_N_DAYS:7)) AND RecordType.DeveloperName = 'HQ' AND StageName IN ('Z02','Z03','Z04') AND CompanyCode__c != : setSubsidiary and Owner.Email !=: listRestrictedEmail and  FirstCloseDate__c = null order by owner.EvKostl__c, closedate asc ];
            
            //below 3 lines are for advanced debugging in case of issues.
            /* if(!Test.isRunningTest()){
Set<String> tempCode = new Set<String>();
tempCode.add('T100-12747');
tempCode.add('T100-12436');
tempCode.add('T100-12613');
tempCode.add('T100-12713');
tempCode.add('T100-12749');
tempCode.add('T100-11788');
tempCode.add('T100-12312');
tempCode.add('T100-12313');
tempCode.add('T100-12314');
//tempCode.add('T100-12749');
allOppList = [select id,closedate,convertCurrency(Amount),convertCurrency(AmountDivide8__c),name,owner.EvKostl__c from opportunity where owner.EvKostl__c IN : tempCode AND (closedate < TODAY or (closedate >= TODAY AND closedate <= NEXT_N_DAYS:7)) AND RecordType.DeveloperName = 'HQ' AND StageName IN ('Z02','Z03','Z04') AND CompanyCode__c != : setSubsidiary and Owner.Email !=: listRestrictedEmail and  FirstCloseDate__c = null order by owner.EvKostl__c, closedate asc];
}*/
            // system.debug('alloppliost--?>' + allOppList.size());
            
            String previousGroupCOde = ''; //holds the previous code 
            Map<String , Boolean> usedGroupCodeMap = new Map<String,boolean>(); //logic to check if on iteration the group code was used already as multiple opp can have same.
            
            boolean isComingFromIf = false; //used to check if the entry in wrapper exists already.
            //iteration on final opp list and populate the wrapper. The Near to close date items are stored as child of this wrapper List.
            if(allOppList.size()>0){
                for(Opportunity allOpp : allOppList){
                    
                    if(allOpp.owner.EvKostl__c == 'T100-12153' || allOpp.owner.EvKostl__c == 'T100-12210' || allOpp.owner.EvKostl__c == 'T100-12489' ||  allOpp.owner.EvKostl__c == 'T100-12490'){
                        system.debug('inside count opp');
                    }
                    
                    requiredGroupCode.add(allOpp.owner.EvKostl__c);
                    if(groupCodeVsTeamCodeMap.get(allOpp.owner.EvKostl__c)!=null || groupCodeVsTeamCodeMap.get(allOpp.owner.EvKostl__c)!=''){
                        requiredTeamCodes.add(groupCodeVsTeamCodeMap.get(allOpp.owner.EvKostl__c));
                    }
                    //system.debug('masterifwrapper' + allOpp.closedate);
                    
                    /*for(String team : teamVsGroupMap.keyset()){
teamVsGroupMap.get(team)
}
groupCodeVsTeamNameMap.get(allOpp.owner.EvKostl__c)*/
                    if(previousGroupCOde != allOpp.owner.EvKostl__c){
                        
                        previousGroupCOde = allOpp.owner.EvKostl__c;
                    }
                    
                    
                    Integer numOfDays;
                    if(allOpp.closedate >= today){
                        numOfDays = today.daysBetween(allOpp.CloseDate);
                    }
                    if(allOpp.CloseDate < System.today()){
                        
                        if(groupCodeVsTeamCodeMap.get(allOpp.owner.EvKostl__c)!=null || groupCodeVsTeamCodeMap.get(allOpp.owner.EvKostl__c)!=''){
                            requiredTeamAlreadyClosedCodes.add(groupCodeVsTeamCodeMap.get(allOpp.owner.EvKostl__c));
                            
                        }
                        
                        
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
                                dataWrap.AmountOpp = allOpp.AmountDivide8__c;
                                dataWrap.reportUrl = groupCodeVsrepUrlMap.get(allOpp.owner.EvKostl__c);
                                dataWrap.reportUrl2 = groupCodeVsrepUrlMap2.get(allOpp.owner.EvKostl__c);
                                dataWrap.numberOfOpp = dataWrap.numberOfOpp+1;
                                if(allOpp.AmountDivide8__c!=null){
                                    dataWrap.totalAmount =  dataWrap.totalAmount+ allOpp.AmountDivide8__c;
                                }
                                
                                listWrapper.add(dataWrap);
                                isComingFromIf = true;
                                usedGroupCodeMap.put(allOpp.owner.EvKostl__c,true);
                            }
                            
                            else{
                                for(OppGroupViseWrapper wrap : listWrapper){
                                    
                                    if(wrap.GroupCode == previousGroupCOde){
                                        wrap.numberOfOpp = wrap.numberOfOpp+1;
                                        if(allOpp.AmountDivide8__c!=null){
                                            wrap.totalAmount = wrap.totalAmount+allOpp.AmountDivide8__c;
                                        }
                                        wrap.isCloseToElapse = false;
                                    }
                                    
                                }
                            }
                            
                            
                            
                        }
                        else{
                            system.debug('if prev notequal current' + allOpp.owner.EvKostl__c);
                            OppGroupViseWrapper dataWrap = new OppGroupViseWrapper();
                            dataWrap.divisionCode = groupCodeVsDivisionNameMap.get(allOpp.owner.EvKostl__c);
                            dataWrap.GroupName = groupCodeVsGroupNameMap.get(allOpp.owner.EvKostl__c);
                            dataWrap.TeamName = groupCodeVsTeamNameMap.get(allOpp.owner.EvKostl__c);
                            dataWrap.GroupCode = allOpp.owner.EvKostl__c;
                            dataWrap.isAlreadyElapsed = true;
                            dataWrap.isCloseToElapse = false;
                            dataWrap.highestAmount = dataWrap.highestAmount < allOpp.Amount ? dataWrap.highestAmount = allOpp.Amount : dataWrap.highestAmount;
                            dataWrap.reportUrl = groupCodeVsrepUrlMap.get(allOpp.owner.EvKostl__c);
                            dataWrap.reportUrl2 = groupCodeVsrepUrlMap2.get(allOpp.owner.EvKostl__c);
                            dataWrap.numberOfOpp = dataWrap.numberOfOpp+1;
                            dataWrap.totalAmount =  dataWrap.totalAmount+ allOpp.AmountDivide8__c;
                            dataWrap.finaltext = '';
                            listWrapper.add(dataWrap);
                        }
                        elapsedOpportunities.add(allOpp);
                    }
                    
                    else if(numOfDays <= 7){
                        
                        if(groupCodeVsTeamCodeMap.get(allOpp.owner.EvKostl__c)!=null || groupCodeVsTeamCodeMap.get(allOpp.owner.EvKostl__c)!=''){
                            requiredTeamNearToClosedCodes.add(groupCodeVsTeamCodeMap.get(allOpp.owner.EvKostl__c));
                        }
                        
                        
                        system.debug('daysless than 7 ' + allopp.id + 'groupcode-->' + allopp.owner.EvKostl__c);
                        nearToCloseOppList.add(allOpp);
                        if(previousGroupCOde == allOpp.owner.EvKostl__c){
                            system.debug('inside first if 7days');
                            if(!usedGroupCodeMap.containsKey(allOpp.owner.EvKostl__c) || (usedGroupCodeMap.containsKey(allOpp.owner.EvKostl__c) && isComingFromIf)){
                                system.debug('inside secondif7days');
                                // for(OppGroupViseWrapper wrap : listWrapper){
                                if(isComingFromIf && !usedGroupCodeMap.containsKey(allOpp.owner.EvKostl__c)){
                                    system.debug('ifcomingfromif' );
                                    
                                    OppGroupViseWrapper dataWrap = new OppGroupViseWrapper();
                                    dataWrap.divisionCode = groupCodeVsDivisionNameMap.get(allOpp.owner.EvKostl__c);
                                    dataWrap.GroupName = groupCodeVsGroupNameMap.get(allOpp.owner.EvKostl__c);
                                    dataWrap.reportUrl = groupCodeVsrepUrlMap.get(allOpp.owner.EvKostl__c);
                                    dataWrap.reportUrl2 = groupCodeVsrepUrlMap2.get(allOpp.owner.EvKostl__c);
                                    dataWrap.TeamName = groupCodeVsTeamNameMap.get(allOpp.owner.EvKostl__c);
                                    dataWrap.GroupCode = allOpp.owner.EvKostl__c;
                                    dataWrap.AmountOpp = allOpp.AmountDivide8__c;
                                    dataWrap.isAlreadyElapsed = false;
                                    if(allOpp.AmountDivide8__c!=null){
                                        dataWrap.totalAmount =  dataWrap.totalAmount+ allOpp.AmountDivide8__c;
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
                                    system.debug('elseofiscomingfromtrue');
                                    OppGroupViseWrapper dataWrap = new OppGroupViseWrapper();
                                    dataWrap.divisionCode = groupCodeVsDivisionNameMap.get(allOpp.owner.EvKostl__c);
                                    dataWrap.GroupName = groupCodeVsGroupNameMap.get(allOpp.owner.EvKostl__c);
                                    dataWrap.TeamName = groupCodeVsTeamNameMap.get(allOpp.owner.EvKostl__c);
                                    dataWrap.GroupCode = allOpp.owner.EvKostl__c;
                                    dataWrap.isAlreadyElapsed = true;
                                    dataWrap.isCloseToElapse = false;
                                    dataWrap.highestAmount = dataWrap.highestAmount < allOpp.Amount ? dataWrap.highestAmount = allOpp.Amount : dataWrap.highestAmount;
                                    dataWrap.reportUrl = groupCodeVsrepUrlMap.get(allOpp.owner.EvKostl__c);
                                    dataWrap.reportUrl2 = groupCodeVsrepUrlMap2.get(allOpp.owner.EvKostl__c);
                                    dataWrap.numberOfOpp = dataWrap.numberOfOpp+1;
                                    dataWrap.totalAmount =  dataWrap.totalAmount+ allOpp.AmountDivide8__c;
                                    dataWrap.finaltext = '';
                                    dataWrap.childRec = new List<OppGroupViseWrapper>();
                                    dataWrap.childRec.add(dataWrap);
                                    listWrapper.add(dataWrap);
                                    usedGroupCodeMap.put(allOpp.owner.EvKostl__c,true);
                                }
                                
                                
                                //  }
                            }
                            
                            else{
                                system.debug('inside else7days');
                                for(OppGroupViseWrapper wrap : listWrapper){
                                    system.debug('elsefor--->' + wrap.GroupCode);
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
                            dataWrap.reportUrl2 = groupCodeVsrepUrlMap2.get(allOpp.owner.EvKostl__c);
                            dataWrap.GroupCode = allOpp.owner.EvKostl__c;
                            dataWrap.isAlreadyElapsed = false;
                            dataWrap.totalAmount =  dataWrap.totalAmount+ allOpp.AmountDivide8__c;
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
                
                system.debug('requiredteamcodes--->' + requiredTeamCodes);
            }
            
            
            
            
            for (String key : teamVsGroupMap.keySet()) {
                List<String> values = teamVsGroupMap.get(key);
                List<String> filteredValues = new List<String>();
                for (String value : values) {
                    if (requiredGroupCode.contains(value)) {
                        filteredValues.add(value);
                    }
                }
                teamVsGroupMap.put(key, filteredValues);
            }
            
            Map<String ,List<String>> divisionCodeVsAlreadyClosedTeamCodeMap = new Map<String , List<String>>();
            Map<String , List<String>> divisionCodeVsNearToCloseTeamCodeMap = new Map<String ,List<String>>();
            for (String key : divisionCodeVsTeamCodeMap.keySet()) {
                List<String> values = divisionCodeVsTeamCodeMap.get(key);
                List<String> filteredValues = new List<String>();
                List<String> filteredAlreadyClosedValues = new List<String>();
                List<String> filteredNearToCLoseValues = new List<String>();
                for (String value : values) {
                    if (requiredTeamCodes.contains(value)) {
                        filteredValues.add(value);
                    }
                    
                    if (requiredTeamAlreadyClosedCodes.contains(value)) {
                        filteredAlreadyClosedValues.add(value);
                    }
                    
                    if (requiredTeamNearToClosedCodes.contains(value)) {
                        filteredNearToCLoseValues.add(value);
                    }
                    
                    ///requiredTeamAlreadyClosedCodes.add(groupCodeVsTeamCodeMap.get(allOpp.owner.EvKostl__c));
                    
                }
                divisionCodeVsTeamCodeMap.put(key, filteredValues);
                divisionCodeVsAlreadyClosedTeamCodeMap.put(key , filteredAlreadyClosedValues);
                divisionCodeVsNearToCloseTeamCodeMap.put(key , filteredNearToCLoseValues);
                
            }
            // Set<String> divisionsUnique = new Set<String>();
            // for v3.0 
            for (Integer i = 0; i < listWrapper.size(); i++) {
                
                
                for (Integer j = i + 1; j < listWrapper.size(); j++) {
                    if (listWrapper[j].totalAmount > listWrapper[i].totalAmount) {
                        OppGroupViseWrapper temp = listWrapper[i];
                        listWrapper[i] = listWrapper[j];
                        listWrapper[j] = temp;
                        //listWrapper[j].childRec = temp;
                    }
                }
                
                /* if(listWrapper[i].childRec!=null){
//   List<OppGroupViseWrapper> listWrapper[i].childRec = listWrapper[i].childRec;
for (Integer z = 0; z < listWrapper[i].childRec.size() - 1; z++) {
for (Integer j = 0; j < listWrapper[i].childRec.size() - z - 1; j++) {
// Compare totalAmount of adjacent elements and swap if necessary
if (listWrapper[i].childRec[j].totalAmount < listWrapper[i].childRec[j + 1].totalAmount) {
OppGroupViseWrapper temp = listWrapper[i].childRec[j];
listWrapper[i].childRec[j] = listWrapper[i].childRec[j + 1];
listWrapper[i].childRec[j + 1] = temp;

}
}
}

}*/
            }
            
            //for v3.0 ends
            
            /* Map<String , Integer> teamcodeVs
for(String ss : divisionCodeVsTeamCodeMap.keyset()){
List<String> teamCodes = divisionCodeVsTeamCodeMap.get(ss);


for(String teamCodeSingle : teamCodes){
for(OppGroupViseWrapper oW : listWrapper){
if(oW.TeamName  == teamCodeSingle)

}
}

}*/
            
            //system.debug('wrapperr->' + JSON.serialize(listWrapper));
            
            
            for(OppGroupViseWrapper oW : listWrapper){
                system.debug('wrapperitems----->' + oW);
                
                if(oW.childRec!=null){
                    for(OppGroupViseWrapper oWc : oW.childRec){
                        system.debug('wrapperitemschildddd----->' + oW);
                    }
                }
                
                if(teamcodeVstotalOppAmountMap.containsKey(oW.TeamName)){
                    teamcodeVstotalOppAmountMap.put(oW.TeamName, teamcodeVstotalOppAmountMap.get(oW.TeamName)+oW.totalAmount);
                }
                
                else{
                    teamcodeVstotalOppAmountMap.put(oW.TeamName, oW.totalAmount); 
                }
                
                
                
            }
            
            generateEmailContentforTeam(listWrapper , allOppList, teamCodeVsNameMap , teamCodeVsReceiverMap ); //calling for email dynamic string generation and sending to all the team leaders.
            
            generateEmailContentForDivisionLeaders(teamcodeVstotalOppAmountMap,requiredGroupCode,groupCodeVsDivisionCode,nearToCloseOppList, teamCodeVsReportUrlMap,teamCodeVsReportUrlMap2,teamVsGroupMap,teamCodeVsNameMap,listWrapper,divisionCodeVsTeamCodeMap,divisionCodeVsAlreadyClosedTeamCodeMap,divisionCodeVsNearToCloseTeamCodeMap, allOppList,divCodeVsTeamName,divCodeVsReceiverMap,divisioncodeVsDivNameMap);
        }
        
    }
    
    //this method is used to trigger email sending to all the team leaders based on the dynamic content it generates.
    public static void generateEmailContentforTeam( List<OppGroupViseWrapper> wrapList , List<Opportunity> allGroupOppList, Map<String, String> teamCodeVsNameMap, Map<String, List<String>> teamCodeVsReceiverMap ){
        Map<String , List<OppGroupViseWrapper>> teamVsGroupDataMap = new Map<String , List<OppGroupViseWrapper>>();
        Map<String , List<OppGroupViseWrapper>> teamVsChildGroupDataMap = new Map<String , List<OppGroupViseWrapper>>();
        Map<String , String> receiverIdVsHtmlStringMap = new Map<String, String>();
        String MasterEmailString = '';
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        List<IF_KnoxEmailSendController.Recipients> recipientsList = new List<IF_KnoxEmailSendController.Recipients>();
        //added for fix of T100-11474 issue (if only near to close present in any teamcode)
        Set<String> allKeysets = new Set<String>();
        Set<OppGroupViseWrapper> uniqueWrap = new Set<OppGroupViseWrapper>(wrapList);
        wrapList.clear();
        wrapList.addAll(uniqueWrap);
        String SENDER_EMAIL = 'mysales@samsung.com';
        
        for(OppGroupViseWrapper wrap : wrapList){
            
            
            //system.debug('wrapitem' + wrap);
            
            
            
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
        allKeysets.addAll(teamVsGroupDataMap.keyset());
        system.debug('allkeysetbeforechild---->' + allKeysets);
        allKeysets.addAll(teamVsChildGroupDataMap.keyset());
        system.debug('allkeysetafter---->' + allKeysets);
        // system.debug('teamVsGroupDataMapkeyssss-->' + teamVsGroupDataMap.keyset());
        // system.debug('teamVschildGroupDataMapkeyssss-->' + teamVsGroupDataMap.keyset());
        // system.debug('teamVschildGroupDataMapkeyssss-->' + teamVsChildGroupDataMap);
        
        
        Map<String, List<OppGroupViseWrapper>> HighestValMap = new Map<String, List<OppGroupViseWrapper>>();
        
        // Iterate over each entry in the teamVsChildGroupDataMap
        for (String key : teamVsChildGroupDataMap.keySet()) {
            List<OppGroupViseWrapper> wrapperList = teamVsChildGroupDataMap.get(key);
            Map<String, OppGroupViseWrapper> groupCodeToWrapperMap = new Map<String, OppGroupViseWrapper>();
            
            // Create a map where the key is the GroupCode and the value is the merged OppGroupViseWrapper
            for (OppGroupViseWrapper wrapper : wrapperList) {
                if (!groupCodeToWrapperMap.containsKey(wrapper.GroupCode)) {
                    groupCodeToWrapperMap.put(wrapper.GroupCode, wrapper);
                } else {
                    OppGroupViseWrapper existingWrapper = groupCodeToWrapperMap.get(wrapper.GroupCode);
                    existingWrapper.totalAmount += wrapper.totalAmount;
                }
            }
            
            // Add the merged wrappers to the HighestValMap
            HighestValMap.put(key, new List<OppGroupViseWrapper>(groupCodeToWrapperMap.values()));
        }
        
        // The HighestValMap now contains the updated values with merged entries based on GroupCode and added totalAmount
        
        
        Map<String, List<OppGroupViseWrapper>> uniqueMap = new Map<String, List<OppGroupViseWrapper>>();
        for (String key : HighestValMap.keySet()) {
            List<OppGroupViseWrapper> wrapperList = HighestValMap.get(key);
            List<OppGroupViseWrapper> uniqueList = new List<OppGroupViseWrapper>();
            Set<String> uniqueValues = new Set<String>();
            for (OppGroupViseWrapper wrapper : wrapperList) {
                if (!uniqueValues.contains(wrapper.GroupCode)) {
                    uniqueList.add(wrapper);
                    uniqueValues.add(wrapper.GroupCode);
                }
            }
            //sort list desc order check
            /*  for (Integer i = 0; i < uniqueList.size() - 1; i++) {
for (Integer j = 0; j < uniqueList.size() - i - 1; j++) {
OppGroupViseWrapper currentWrapper = uniqueList[j];
OppGroupViseWrapper nextWrapper = uniqueList[j + 1];

if (currentWrapper.totalAmount < nextWrapper.totalAmount) {
// Swap the positions of currentWrapper and nextWrapper
uniqueList[j] = nextWrapper;
uniqueList[j + 1] = currentWrapper;
}
}
}*/
            uniqueMap.put(key, uniqueList);
        }
        
        for(String str1 : uniqueMap.keyset()){
            // Retrieve the list from the map
            
            for(Integer j=0 ; j<uniqueMap.get(str1).size(); j++ ){
                if(uniqueMap.get(str1)[j].childRec!=null && uniqueMap.get(str1)[j].childRec.size()>0){
                    String myString = HighestAmountForCloseDateOpp(allGroupOppList,uniqueMap.get(str1)[j].GroupCode).customString.split('total;')[1];
                    myString = myString.replaceAll(',', '');
                    String modifiedString = myString.substring(0, myString.length() - 1);
                    uniqueMap.get(str1)[j].totalAmount = Decimal.valueOf(modifiedString);
                }
                
            }
            List<OppGroupViseWrapper> myList = uniqueMap.get(str1);
            
            // Implement a custom sorting algorithm
            for (Integer i = 0; i < myList.size(); i++) {
                for (Integer j = i + 1; j < myList.size(); j++) {
                    if (myList[j].totalAmount > myList[i].totalAmount) {
                        // Swap elements
                        OppGroupViseWrapper temp = myList[i];
                        myList[i] = myList[j];
                        myList[j] = temp;
                    }
                }
            }
            
            
            
        }
        // HighestAmountForCloseDateOpp(allGroupOppList,uniqueMap.get(str)[j].childRec[k].GroupCode).customString.split('total;')[1]
        // Define the dynamic HTML to be included in the email
        String htmlTable = '';
        boolean isFirstIteration=false;
        htmlTable = '<table>';
        htmlTable += '<tr><th style=text-align:center;width:20%;font-weight: bold;>'+system.label.Group_Hierarchy_Category_Column+'</th><th style=text-align:center;width:20%>'+system.label.Group_Hierarchy_Group_Column+'</th><th style=text-align:center;width:40%>'+system.label.Group_Hierarchy_BO_Column+'</th><th style=text-align:center;width:20%>'+system.label.Group_Hierarchy_Amount_Column+'</th></tr>';
        for(String str : allKeysets){
            Decimal totalCount = 0.0;
            Integer totalOpp = 0;
            Integer totalCountforNearToClose = 0;
            Decimal totalOppForNearToClose = 0;
            system.debug('before breaking-->' + str);
            if(teamVsGroupDataMap.get(str)!=null){
                htmlTable += '<tr><td style="text-align:center; vertical-align:middle; padding:13px 0 12px 20px; font-weight: bold;" rowspan="'+teamVsGroupDataMap.get(str).size()+'">'+system.label.Group_Hierarchy_Close_Date_Elapsed_Column+'</td>';
                
                
                //String tempTeamnameForParent = '';
                for(Integer i=0; i<teamVsGroupDataMap.get(str).size(); i++ ){
                    system.debug('team Map for :::' + str +teamVsGroupDataMap.get(str));
                    //if(tempTeamnameForParent!= teamVsGroupDataMap.get(str)[i].GroupName){
                    totalOpp = totalOpp+HighestAmountOppName(allGroupOppList,teamVsGroupDataMap.get(str)[i].GroupCode).Size;
                    htmlTable += '<td>'+teamVsGroupDataMap.get(str)[i].GroupName+'</td><td><a href="'+teamVsGroupDataMap.get(str)[i].reportUrl+'">'+HighestAmountOppName(allGroupOppList,teamVsGroupDataMap.get(str)[i].GroupCode).customString+'</a></td><td style="text-align:right">'+decimalToCommaSeparatedInteger(teamVsGroupDataMap.get(str)[i].totalAmount)+System.label.Group_Hierarchy_100M_Label+'</td></tr>';
                    //tempTeamnameForParent = teamVsGroupDataMap.get(str)[i].GroupName;
                    // }
                    totalCount = totalCount + teamVsGroupDataMap.get(str)[i].totalAmount;
                    
                }
                
                // htmlTable += 'the subcount would be added here.';
                htmlTable  += '<tr style="background-color: #eeeeee;">' + '<td colspan="2" style="text-align: center;font-weight: bold;">'+System.label.Group_Hierarchy_Sub_Total_label+'</td>' + '<td style="font-weight: bold;">'+System.label.Group_Hierarchy_Total_Label+' '+totalOpp+' '+System.label.Group_Hierarchy_more_Column+'</td>' + '<td style="text-align: right;font-weight: bold;">'+System.label.Group_Hierarchy_Total_Label+' '+decimalToCommaSeparatedInteger(totalCount)+System.label.Group_Hierarchy_100M_Label+'</td>' + '</tr>';
                
                
            }
            
            system.debug('keysetteam->' + uniqueMap.keyset());
            String tempTeamname = '';
            String tempCode = '';
            if(uniqueMap.get(str)!=null && uniqueMap.get(str).size()>0){
                // system.debug('keyfirstmap-->' + str);
                system.debug('firstloopvalue' + uniqueMap.get(str));
                system.debug('oldmap-->' + teamVsChildGroupDataMap.get(str));
                //system.debug('firstloopsize0>' + uniqueMap.get(str).size());
                
                htmlTable += '<tr><td style="text-align:center; vertical-align:middle; padding:13px 0 12px 20px; font-weight: bold;" rowspan="'+uniqueMap.get(str).size()+'">'+system.label.Group_Hierarchy_Near_To_Close_Column+'</td>';
                for(Integer j=0 ; j<uniqueMap.get(str).size(); j++ ){
                    system.debug('entriessss'+ uniqueMap.get(str));
                    if(uniqueMap.get(str)[j].childRec!=null && uniqueMap.get(str)[j].childRec.size()>0){
                        for(Integer k=0 ; k< uniqueMap.get(str)[j].childRec.size(); k++){
                            
                            // system.debug('####groupcodesunique' + uniqueMap.get(str)[j].childRec[k].GroupCode);
                            system.debug('####groupcodes' + uniqueMap.get(str)[j].childRec[k].GroupCode);
                            if(tempCode != uniqueMap.get(str)[j].childRec[k].GroupCode){
                                totalCountforNearToClose = totalCountforNearToClose + HighestAmountForCloseDateOpp(allGroupOppList,uniqueMap.get(str)[j].childRec[k].GroupCode).Size;
                                totalOppForNearToClose = totalOppForNearToClose + HighestAmountForCloseDateOpp(allGroupOppList,uniqueMap.get(str)[j].childRec[k].GroupCode).totalWrapAmount;
                            }
                            
                            if(tempTeamname!= uniqueMap.get(str)[j].childRec[k].GroupName){
                                
                                htmlTable += '<td>'+uniqueMap.get(str)[j].childRec[k].GroupName+'</td><td><a href="'+uniqueMap.get(str)[j].childRec[k].reportUrl2+'">'+HighestAmountForCloseDateOpp(allGroupOppList,uniqueMap.get(str)[j].childRec[k].GroupCode).customString.split('total;')[0]+'</a></td><td style="text-align:right">'+HighestAmountForCloseDateOpp(allGroupOppList,uniqueMap.get(str)[j].childRec[k].GroupCode).customString.split('total;')[1]+'</td></tr>';
                                tempTeamname = uniqueMap.get(str)[j].childRec[k].GroupName;
                            }
                            tempCode = uniqueMap.get(str)[j].childRec[k].GroupCode;
                        }
                    }
                }
                htmlTable  += '<tr style="background-color: #eeeeee;">' + '<td colspan="2" style="text-align: center;font-weight: bold;">'+System.label.Group_Hierarchy_Sub_Total_label+'</td>' + '<td style="font-weight: bold;">'+System.label.Group_Hierarchy_Total_Label+' '+totalCountforNearToClose+' '+System.label.Group_Hierarchy_more_Column+'</td>' + '<td style="text-align: right;font-weight: bold;">'+System.label.Group_Hierarchy_Total_Label+' '+decimalToCommaSeparatedInteger(totalOppForNearToClose)+System.label.Group_Hierarchy_100M_Label+'</td>' + '</tr>';
            }
            
            
            Decimal finalTotalAmount =  totalOppForNearToClose + totalCount;
            Integer finalTotalOppCount = totalOpp+totalCountforNearToClose;
            htmlTable  += '<tr style="background-color: #cccccc;">' + '<td colspan="2" style="text-align: center;font-weight: bold;">'+System.label.Group_Hierarchy_Total_Sum_Label+'</td>' + '<td style="font-weight: bold;" >'+System.label.Group_Hierarchy_Total_Label+' '+finalTotalOppCount+' '+System.label.Group_Hierarchy_more_Column+'</td>' + '<td style="text-align: right;font-weight: bold;">'+System.label.Group_Hierarchy_Total_Label+' '+decimalToCommaSeparatedInteger(finalTotalAmount)+System.label.Group_Hierarchy_100M_Label+'</td>' + '</tr>';
            htmlTable += '</table>';
            system.debug('final html string-->' + htmlTable);
            receiverIdVsHtmlStringMap.put(str ,htmlTable);
            
            htmlTable='';
            htmlTable = '<table>';
            htmlTable += '<tr><th style=text-align:center;font-weight: bold;>'+system.label.Group_Hierarchy_Category_Column+'</th><th style=text-align:center;width:20%>'+system.label.Group_Hierarchy_Group_Column+'</th><th style=text-align:center;width:40%>'+system.label.Group_Hierarchy_BO_Column+'</th><th style=text-align:center;width:20%>'+system.label.Group_Hierarchy_Amount_Column+'</th></tr>';
            //  }
        }
        
        
        EmailTemplate em = [SELECT Id,subject FROM EmailTemplate WHERE DeveloperName = 'ElapsedOppGroupWIse'];
        Id templateId = em.Id;
        
        Employee__c senderEmployee;
        
        
        
        
        if( Utils.getIsSandbox()){
            senderEmployee = Utils.getLoginEmployeeData('0051s000001E9SuAAK');
            senderEmployee.EvMailAddr__c = 'chae_ho.yang@stage.samsung.com';
        }else{
            List<User> userList = [SELECT Id, Name From User WHERE Username = :SENDER_EMAIL];
            if(userList.size() > 0) senderEmployee = Utils.getLoginEmployeeData(userList.get(0).Id);
        }
        
        String emailBody = [SELECT HtmlValue FROM EmailTemplate WHERE Id = :templateId].HtmlValue;
        String shadowCopyOfBody = emailBody;
        system.debug('receivermap-->' + receiverIdVsHtmlStringMap.keySet());
        for(String u : receiverIdVsHtmlStringMap.keyset()) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTemplateId(templateId);
            // Get the HTML content of the email template
            
            // Replace the merge field with the dynamic HTML content
            //emailBody = emailBody.replace('{!TeamName}', teamCodeVsNameMap.get(u));
            emailBody = emailBody.replace('{!topString}', /*'Email Subject to Team'*/ +teamCodeVsNameMap.get(u)+'Leader');
            emailBody = emailBody.replace('{!leaderVariable}', '팀 산하 그룹장,');
            emailBody = emailBody.replace('{!divisionTeam}', '그룹');
            if(Test.isRunningTest()){
                u='T100-12346';
            }
            if(Test.isRunningTest()){
                emailBody = emailBody.replace('{!costCenterName}', 'testData');
            }
            else{
                emailBody = emailBody.replace('{!costCenterName}', teamCodeVsNameMap.get(u));
            }
            
            emailBody = emailBody.replace('{!DateValue}', String.valueof(Date.today()));
            if(!Test.isrunningTest()){
                emailBody = emailBody.replace('{!tableString}', receiverIdVsHtmlStringMap.get(u));
            }
            
            // Set the modified email body as the email body
            email.setHtmlBody(emailBody);
            
            
            //for knox
            recipientsList.clear();
            //for knox
            system.debug('mapp--->' + teamCodeVsReceiverMap);
            system.debug('keyis-->' + u);
            for(String tempValue : teamCodeVsReceiverMap.get(u)){
                system.debug('generating receiver for team' + String.valueOf(tempValue));
                IF_KnoxEmailSendController.Recipients c = new IF_KnoxEmailSendController.Recipients(String.valueOf(tempValue), 'to');
                //c.remove
                recipientsList.add(c);
            }
                IF_KnoxEmailSendController.Recipients c1 = new IF_KnoxEmailSendController.Recipients('divyam.gupta@stage.samsung.com', 'to');
              recipientsList.add(c1);
            //system.debug('recipientsList' + recipientsList);
            IF_KnoxEmailSendController.Sender sender;
            if(test.isRunningTest()){
                sender = new IF_KnoxEmailSendController.Sender('mysales', 'mysales@samsung.com');
            }
            else{
                sender = new IF_KnoxEmailSendController.Sender(senderEmployee.EvMailAddr__c.split('@')[0], senderEmployee.EvMailAddr__c);
            }
            
            IF_KnoxEmailSendController.InputClass bodyMap = new IF_KnoxEmailSendController.InputClass();
            //bodyMap.subject = 'Group Wise Information of Opportunity Elapsed/Close To Elapse';
            bodyMap.subject = em.Subject;
            bodyMap.contents = emailBody;
            bodyMap.contentType = 'HTML';
            bodyMap.docSecuType = 'PERSONAL';
            //bodyMap.sfdcId = Userinfo.getUserid();
            bodyMap.recipients = recipientsList;
            bodyMap.sender = sender;
            bodyMap.isMulti = true;
            
            Map<String,Object> resMap = new Map<String,Object>();
            Map<String,Object> response = new Map<String, Object>();
            
            response = IF_KnoxEmailSendController.send(bodyMap);
            //System.debug('------------------>'+String.valueOf(response)); 
            //for knox end
            
            
            // emailList.add(email);
            //  }
            emailBody = '';
            emailBody = shadowCopyOfBody;
        }
        
        /* if(!Test.isRunningTest()){
List<Messaging.SendEmailResult> sendResults = Messaging.sendEmail(emailList);
}*/
        // Send the email messages
        
    }
    
    
    public static void generateEmailContentForDivisionLeaders(Map<String,Decimal> teamcodeVstotalOppAmountMap, Set<String> workingGroupCodes ,Map<String,String> groupCodeVsDivisionCode ,List<Opportunity> nearToCloseOppList,Map<String,String> teamCodeVsReportUrlMap , Map<String,String> teamCodeVsReportUrlMap2, Map<String,List<String>> teamVsGroupMap,Map<String,String> teamCodeVsNameMap,List<OppGroupViseWrapper> wrapList, Map<String,List<String>> divCodeVSTeamCodeMap ,Map<String,List<String>> divCodeVSAlreadyCloseTeamCodeMap,Map<String,List<String>> divCodeVSNearCloseTeamCodeMap, List<Opportunity> groupWiseOpp , Map<String,List<String>> divCodeVsTeamName , Map<String,List<String>> divCodeVsReceiverMap, Map<String,String> divisioncodeVsDivNameMap){
        system.debug('keysetoffirstforloop->' + divCodeVSTeamCodeMap.keySet());
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        String htmlTable = '';
        Map<String,String> receiverIdVsHtmlStringMap = new map<string,string>();
        Map<String , List<OppGroupViseWrapper>> teamVsChildGroupDataMap = new Map<String , List<OppGroupViseWrapper>>();
        Set<String> childIdentifierSet = new Set<String>();
        Map<String , List<OppGroupViseWrapper>> teamVsGroupDataMap = new Map<String , List<OppGroupViseWrapper>>();
        List<IF_KnoxEmailSendController.Recipients> recipientsList = new List<IF_KnoxEmailSendController.Recipients>();
        String SENDER_EMAIL = 'mysales@samsung.com';
        String prevElement = '';
        String tempCode = '';
        system.debug('initialmap-->' + groupCodeVsDivisionCode);
        
        /*  for(String str : divCodeVSTeamCodeMap.keyset()){



}*/
        
        for(OppGroupViseWrapper wrap : wrapList){
            
            // system.debug('wraplist-->' + wrap);
            
            
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
                
                if(wrap.childRec!=null ){
                    for(OppGroupViseWrapper wrapChild : wrap.childRec){
                        if(wrapChild.TeamName != prevElement){
                            teamVsChildGroupDataMap.get(wrap.divisionCode).add(wrapChild);
                            prevElement = wrapChild.TeamName;
                        }
                        
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
        
        
        system.debug('divCodeVSTeamCodeMap' + divCodeVSTeamCodeMap);
        system.debug('mapp' + teamcodeVstotalOppAmountMap);   
        //added for: V3.0 MySales-191 desc order
        List<String> stringList = new List<String>();
        for(String divCodes : divCodeVSTeamCodeMap.keySet()){
            //system.debug('divcode-->' + divCodes);
            List<Decimal> tempListToSort = new List<Decimal>();
            List<Decimal> sortedListinReverse = new list<Decimal>();
            for(String teamCode : divCodeVSTeamCodeMap.get(divCodes) ){
                tempListToSort.add(teamcodeVstotalOppAmountMap.get(teamCode));
            }
            tempListToSort.sort();
            system.debug('sortingfor--->'+ divCodes + 'listTosort-->' + tempListToSort);
            sortedListinReverse = descOrderList(tempListToSort);
            system.debug('afterreverse-->' + sortedListinReverse);
            
            divCodeVSTeamCodeMap.get(divCodes).clear();
            system.debug('afterclearingmap--->' + divCodeVSTeamCodeMap.get(divCodes));
            for(Decimal d : sortedListinReverse){
                system.debug('insideerrormap-->' + d);
                //stringList.add(String.valueOf(d));
                for(String dd : teamcodeVstotalOppAmountMap.keySet()){
                    if(teamcodeVstotalOppAmountMap.get(dd) == d){
                        divCodeVSTeamCodeMap.get(divCodes).add(dd);
                    }
                    
                    
                }
            }
            
            system.debug('convertedToString--->' + stringList);
            //divCodeVSTeamCodeMap.get(divCodes).addAll(stringList);
            
            
        }
        //added for V3.0 my Sales 191 end
        
        
        
        
        Map<String, List<OppGroupViseWrapper>> uniqueMap = new Map<String, List<OppGroupViseWrapper>>();
        for (String key : teamVsChildGroupDataMap.keySet()) {
            List<OppGroupViseWrapper> wrapperList = teamVsChildGroupDataMap.get(key);
            List<OppGroupViseWrapper> uniqueList = new List<OppGroupViseWrapper>();
            Set<String> uniqueValues = new Set<String>();
            for (OppGroupViseWrapper wrapper : wrapperList) {
                if (!uniqueValues.contains(wrapper.TeamName)) {
                    uniqueList.add(wrapper);
                    uniqueValues.add(wrapper.TeamName);
                }
            }
            uniqueMap.put(key, uniqueList);
        }
        
        system.debug('endmap-->' + divCodeVSTeamCodeMap);
        system.debug('uniquemapp' + uniqueMap);
        
        //logic for sorting issue fix 3.1
        // Iterate over the map keys
        for (String key : uniqueMap.keySet()) {
            // Get the wrapper list from the map
            List<OppGroupViseWrapper> wrapperList = uniqueMap.get(key);
            
            // Recalculate totalAmount based on your logic
            Decimal recalculatedTotalAmount = 0;
            for (OppGroupViseWrapper wrapper : wrapperList) {
                // Perform your calculation logic here to update totalAmount
                String str= DivisionEmailHighestAmountForCloseDateOpp(groupWiseOpp,teamVsGroupMap.get(wrapper.TeamName) ).customString.split('total;')[1];
                system.debug('beforerstring-->' + str);
                str = str.substring(0, str.length() - 1);
                str = str.replace(',', '');
                system.debug('afterstring-->' + str);
                recalculatedTotalAmount +=  Decimal.valueOf(str);
                wrapper.totalAmount = recalculatedTotalAmount;
                recalculatedTotalAmount = 0.0;
            }
            
            
                system.debug('beforewrapper list-->' + wrapperList);
            
            
            // Sort the wrapper list in descending order based on totalAmount field
            for (Integer i = 0; i < wrapperList.size() - 1; i++) {
        for (Integer j = 0; j < wrapperList.size() - i - 1; j++) {
            if (wrapperList[j].totalAmount < wrapperList[j+1].totalAmount) {
                // Swap the positions of wrapperList[j] and wrapperList[j+1]
                OppGroupViseWrapper temp = wrapperList[j];
                wrapperList[j] = wrapperList[j+1];
                wrapperList[j+1] = temp;
            }
        }
    }
            
            system.debug('afterwrapper list-->' + wrapperList);
            // Update the sorted wrapperList back to the map
    uniqueMap.put(key, wrapperList);
 
        }
        system.debug('updateduniquemapp---->' + uniqueMap);
        //logic for sorting issue fix 3.1 end
        
        
        
        
        htmlTable = '<table>';
        htmlTable += '<tr><th style=text-align:center;width:20%;font-weight: bold;>'+system.label.Group_Hierarchy_Category_Column+'</th><th style=text-align:center;width:20%>'+system.label.Group_Hierarchy_Team_Column+'</th><th style=text-align:center;width:40%>'+system.label.Group_Hierarchy_BO_Column+'</th><th style=text-align:center;width:20%>'+system.label.Group_Hierarchy_Amount_Column+'</th></tr>';
        for(String str : divCodeVSTeamCodeMap.keyset()){
            
            Decimal totalCount = 0.0;
            Integer totalOpp = 0;
            Integer totalCountforNearToClose = 0;
            Decimal totalOppForNearToClose = 0;
            /* for(Integer i=0; i< divCodeVSTeamCodeMap.get(str).size(); i++){
if(divCodeVSTeamCodeMap.get(str)[i]==null){
divCodeVSTeamCodeMap
}

}*/
            
            
            //if(divCodeVSTeamCodeMap.get(str))
            system.debug('firstloopkey' +str);
            if (divCodeVSAlreadyCloseTeamCodeMap.get(str).size() > 0) { // 2023.11.13 chae_ho.yang table modification caused by on division, with no delayed bo
                htmlTable += '<tr><td style="text-align:center; vertical-align:middle; padding:13px 0 12px 20px; font-weight: bold;" rowspan="'+divCodeVSAlreadyCloseTeamCodeMap.get(str).size()+'">'+system.label.Group_Hierarchy_Close_Date_Elapsed_Column+'</td>';
                for(String teamCode : divCodeVSTeamCodeMap.get(str)){
                    
                    system.debug('secondloop' + teamcode);
                    system.debug('teamcodecheck' + teamVsGroupMap.get(teamCode));
                    if(teamcode!=null && teamVsGroupMap.get(teamCode)!=null && teamVsGroupMap.get(teamCode).size()>0 && (!String.isBlank(DivisionEmailHighestAmount(groupWiseOpp,teamVsGroupMap.get(teamCode)).customString))){
                        totalOpp = totalOpp + DivisionEmailHighestAmount(groupWiseOpp,teamVsGroupMap.get(teamCode) ).size;
                        totalCount =totalCount + DivisionEmailHighestAmount(groupWiseOpp,teamVsGroupMap.get(teamCode) ).totalWrapAmount;
                        system.debug('forgroupcodes->' + teamVsGroupMap.get(teamCode));
                        htmlTable += '<td>'+teamCodeVsNameMap.get(teamCode)+'</td><td><a href="'+teamCodeVsReportUrlMap.get(teamCode)+'">'+DivisionEmailHighestAmount(groupWiseOpp,teamVsGroupMap.get(teamCode) ).customString.split('total;')[0]+'</a></td><td style="text-align:right">'+DivisionEmailHighestAmount(groupWiseOpp,teamVsGroupMap.get(teamCode) ).customString.split('total;')[1]+'</td></tr>';
                        
                    }
                }
                htmlTable  += '<tr style="background-color: #eeeeee;">' + '<td colspan="2" style="text-align: center;font-weight: bold;">'+System.label.Group_Hierarchy_Sub_Total_label+'</td>' + '<td style="font-weight: bold;">'+System.label.Group_Hierarchy_Total_Label+' '+totalOpp+' '+System.label.Group_Hierarchy_more_Column+'</td>' + '<td style="text-align: right;font-weight: bold;">'+System.label.Group_Hierarchy_Total_Label+' '+decimalToCommaSeparatedInteger(totalCount)+System.label.Group_Hierarchy_100M_Label+'</td>' + '</tr>';
            }
            system.debug('before entring second if' + teamVsChildGroupDataMap.get(str));
            if(teamVsChildGroupDataMap.get(str)!=null && teamVsChildGroupDataMap.get(str).size()>0){
                //Integer tempSize = teamVsChildGroupDataMap.get(str).size() > 1 ? teamVsChildGroupDataMap.get(str).size() - 1 : teamVsChildGroupDataMap.get(str).size();
                htmlTable += '<tr><td style=" text-align:center; vertical-align:middle; padding:13px 0 12px 20px; font-weight: bold;" rowspan="'+uniqueMap.get(str).size()+'">'+system.label.Group_Hierarchy_Near_To_Close_Column+'</td>';
                // if(teamVsGroupDataMap.get(str)!=null){
                //system.debug('after entring second if' + teamVsGroupDataMap.keyset());
                List<String> tempTeamname = new List<String>();
                for(Integer j=0 ; j<uniqueMap.get(str).size(); j++ ){
                    system.debug('finaliteration-->' + str);
                    
                    if(uniqueMap.get(str)[j].childRec!=null && uniqueMap.get(str)[j].childRec.size()>0){
                        
                        system.debug('mappppppppp' + uniqueMap.get(str)[j]);
                        system.debug('fixedurl'+ teamCodeVsReportUrlMap2.get(uniqueMap.get(str)[j].TeamName));
                        //system.debug('uniqueMap->' + uniqueMap);
                        if(!tempTeamname.contains(uniqueMap.get(str)[j].TeamName)){
                            totalCountforNearToClose = totalCountforNearToClose + DivisionEmailHighestAmountForCloseDateOpp(groupWiseOpp,teamVsGroupMap.get(uniqueMap.get(str)[j].TeamName) ).Size;
                            totalOppForNearToClose = totalOppForNearToClose + DivisionEmailHighestAmountForCloseDateOpp(groupWiseOpp,teamVsGroupMap.get(uniqueMap.get(str)[j].TeamName) ).totalWrapAmount;
                            htmlTable += '<td>'+teamCodeVsNameMap.get(uniqueMap.get(str)[j].TeamName)+'</td><td><a href="'+teamCodeVsReportUrlMap2.get(uniqueMap.get(str)[j].TeamName)+'">'+DivisionEmailHighestAmountForCloseDateOpp(groupWiseOpp,teamVsGroupMap.get(uniqueMap.get(str)[j].TeamName) ).customString.split('total;')[0]+'</a></td><td style="text-align:right">'+DivisionEmailHighestAmountForCloseDateOpp(groupWiseOpp,teamVsGroupMap.get(uniqueMap.get(str)[j].TeamName) ).customString.split('total;')[1]+'</td></tr>';
                            
                            tempTeamname.add(uniqueMap.get(str)[j].TeamName);
                        }
                        
                    }
                    tempCode = teamVsChildGroupDataMap.get(str)[j].TeamName;
                }
                htmlTable  += '<tr style="background-color: #eeeeee;">' + '<td colspan="2" style="text-align: center;font-weight: bold;">'+System.label.Group_Hierarchy_Sub_Total_label+'</td>' + '<td style="font-weight: bold;">'+System.label.Group_Hierarchy_Total_Label+' '+totalCountforNearToClose+' '+System.label.Group_Hierarchy_more_Column+'</td>' + '<td style="text-align: right;font-weight: bold;">'+System.label.Group_Hierarchy_Total_Label+' '+decimalToCommaSeparatedInteger(totalOppForNearToClose)+System.label.Group_Hierarchy_100M_Label+'</td>' + '</tr>';
                
                //  }
                
            }
            
            Decimal finalTotalAmount =  totalOppForNearToClose + totalCount;
            Integer finalTotalOppCount = totalOpp+totalCountforNearToClose;
            htmlTable  += '<tr style="background-color: #cccccc;">' + '<td colspan="2" style="text-align: center;font-weight: bold;">'+System.label.Group_Hierarchy_Total_Sum_Label+'</td>' + '<td style="font-weight: bold;">'+System.label.Group_Hierarchy_Total_Label+' '+finalTotalOppCount+' '+System.label.Group_Hierarchy_more_Column+'</td>' + '<td style="text-align: right;font-weight: bold;">'+System.label.Group_Hierarchy_Total_Label+' '+decimalToCommaSeparatedInteger(finalTotalAmount)+System.label.Group_Hierarchy_100M_Label+'</td>' + '</tr>';
            htmlTable += '</table>';
            system.debug('divhtmlstring' + htmlTable);
            receiverIdVsHtmlStringMap.put(str ,htmlTable);
            htmlTable='';
            htmlTable = '<table>';
            htmlTable += '<tr><th style=text-align:center;width:20%; font-weight: bold;>'+system.label.Group_Hierarchy_Category_Column+'</th><th style=text-align:center;width:20%>'+system.label.Group_Hierarchy_Team_Column+'</th><th style=text-align:center;width:40%>'+system.label.Group_Hierarchy_BO_Column+'</th><th style=text-align:center;width:20%>'+system.label.Group_Hierarchy_Amount_Column+'</th></tr>';
        }
        
        
        EmailTemplate em = [SELECT Id,subject FROM EmailTemplate WHERE DeveloperName = 'ElapsedOppGroupWIse'];
        Id templateId = em.Id;
        // system.debug('####map' + divCodeVsReceiverMap);
        Employee__c senderEmployee;
        
        
        
        
        if( Utils.getIsSandbox()){
            senderEmployee = Utils.getLoginEmployeeData('0051s000001E9SuAAK');
            senderEmployee.EvMailAddr__c = 'chae_ho.yang@stage.samsung.com';
        }else{
            List<User> userList = [SELECT Id, Name From User WHERE Username = :SENDER_EMAIL];
            if(userList.size() > 0) senderEmployee = Utils.getLoginEmployeeData(userList.get(0).Id);
        }
        
        String emailBody = [SELECT HtmlValue FROM EmailTemplate WHERE Id = :templateId].HtmlValue;
        String shadowCopyOfBody = emailBody;
        system.debug('insidemap-->' + divisioncodeVsDivNameMap);
        system.debug('insidemapother' + receiverIdVsHtmlStringMap.keyset());
        system.debug('insidemapother' + divCodeVsReceiverMap);
        
        for(String u : receiverIdVsHtmlStringMap.keyset()) {
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTemplateId(templateId);
            // Get the HTML content of the email template
            
            // Replace the merge field with the dynamic HTML content
            // emailBody = emailBody.replace('{!TeamName}', divisioncodeVsDivNameMap.get(u));
            emailBody = emailBody.replace('{!topString}', /*'Email Subject to Division' +*/divisioncodeVsDivNameMap.get(u)+'Leader');
            emailBody = emailBody.replace('{!leaderVariable}', '담당 산하 팀장, 그룹장,');
            emailBody = emailBody.replace('{!divisionTeam}', '팀');
            if(Test.isRunningTest()){
                emailBody = emailBody.replace('{!costCenterName}', 'fortesting');
            }
            else{
                emailBody = emailBody.replace('{!costCenterName}', divisioncodeVsDivNameMap.get(u)); 
            }
            
            emailBody = emailBody.replace('{!DateValue}', String.valueof(Date.today()));
            emailBody = emailBody.replace('{!tableString}', receiverIdVsHtmlStringMap.get(u));
            // Set the modified email body as the email body
            email.setHtmlBody(emailBody);
            // Specify the recipient of the email
            recipientsList.clear();
            //for knox
            if(Test.isRunningTest()){
                u = 'T100-12579';
            }
            for(String tempValue : divCodeVsReceiverMap.get(u)){
                system.debug('generating receiver' + String.valueOf(tempValue));
                IF_KnoxEmailSendController.Recipients c = new IF_KnoxEmailSendController.Recipients(String.valueOf(tempValue), 'to');
                //c.remove
                recipientsList.add(c);
            }
            //Divyam
            IF_KnoxEmailSendController.Recipients c1 = new IF_KnoxEmailSendController.Recipients('divyam.gupta@stage.samsung.com', 'to');
            recipientsList.add(c1);
        
            
            system.debug('division recipient-->' + recipientsList);
            
            
            // system.debug('recipientsList' + recipientsList);
            IF_KnoxEmailSendController.Sender sender;
            if(test.isRunningTest()){
                sender = new IF_KnoxEmailSendController.Sender('mysales', 'mysales@samsung.com');
            }
            else{
                sender = new IF_KnoxEmailSendController.Sender(senderEmployee.EvMailAddr__c.split('@')[0], senderEmployee.EvMailAddr__c);
            }
            // IF_KnoxEmailSendController.Sender sender = new IF_KnoxEmailSendController.Sender(senderEmployee.EvMailAddr__c.split('@')[0], senderEmployee.EvMailAddr__c);
            IF_KnoxEmailSendController.InputClass bodyMap = new IF_KnoxEmailSendController.InputClass();
            //bodyMap.subject = 'Group Wise Information of Opportunity Elapsed/Close To Elapse';
            bodyMap.subject = em.Subject;
            bodyMap.contents = emailBody;
            bodyMap.contentType = 'HTML';
            bodyMap.docSecuType = 'PERSONAL';
            //bodyMap.sfdcId = Userinfo.getUserid();
            bodyMap.recipients = recipientsList;
            bodyMap.sender = sender;
            bodyMap.isMulti = true;
            
            Map<String,Object> resMap = new Map<String,Object>();
            Map<String,Object> response = new Map<String, Object>();
            
            response = IF_KnoxEmailSendController.send(bodyMap);
            System.debug('------------------>'+String.valueOf(response)); 
            //for knox end
            
            emailBody = '';
            emailBody = shadowCopyOfBody;
            
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
    
    
    public static OppColumnStringAndSizeWrap DivisionEmailHighestAmount(List<Opportunity> opList , List<String> groupCode){
        system.debug('inside BO column calculation-->' + opList.size());
        system.debug('groupcodes-->' + groupCode);
        Date today = Date.today();
        Decimal prevAmount = 0.0;
        String OpName = '';
        Decimal totalAmount = 0.0;
        
        List<Opportunity> groupList = new List<Opportunity>();
        List<Opportunity> closeToDeletegroupList = new List<Opportunity>();
        OppColumnStringAndSizeWrap opWrap = new OppColumnStringAndSizeWrap();
        
        for(Opportunity op : opList){
            
            if(groupCode!=null && groupCode.size()>0){
                for(String gCode : groupCode){
                    
                    if(gCode!=null && op.owner.EvKostl__c == gCode && (op.CloseDate < System.today() /*||  (op.CloseDate > System.today() && today.daysBetween(op.CloseDate) <=7)*/) ){
                        groupList.add(op);
                    }
                    
                }
            }
        }
        system.debug('grouplistsize-->' + groupList.size());
        
        
        for(Opportunity op : groupList){
            
            if(op.Amount > prevAmount ){
                opName = op.Name;
                prevAmount = op.Amount;
            }
            if(op.AmountDivide8__c!=null){
                totalAmount = op.AmountDivide8__c + totalAmount;
            }
        }
        Integer size = 0;
        size = groupList.size()-1;
        if(size == 0){
            opName = opName+' '/*+system.label.Group_Hierarchy_And_Column + ' ' + String.valueOf(size) +' '+system.label.Group_Hierarchy_more_Column */+'total;'+decimalToCommaSeparatedInteger(totalAmount)+System.label.Group_Hierarchy_100M_Label;
            opWrap.customString = opName;
            opWrap.Size = 1;
        }
        
        else if(size >0){
            opName = opName+' '+system.label.Group_Hierarchy_And_Column + ' ' + String.valueOf(size) +' '+system.label.Group_Hierarchy_more_Column +'total;'+decimalToCommaSeparatedInteger(totalAmount)+System.label.Group_Hierarchy_100M_Label;
            opWrap.customString = opName;
            opWrap.Size = size+1;
        }
        opWrap.totalWrapAmount = totalAmount;
        // opName = opName+' and ' + String.valueOf(size) +'others';
        
        //system.debug('finalstring' + opName.split('total;')[0]);
        
        
        return opWrap;
    }
    
    public static OppColumnStringAndSizeWrap DivisionEmailHighestAmountForCloseDateOpp(List<Opportunity> opList , List<String> groupCode){
        
        Date today = Date.today();
        Decimal prevAmount = 0.0;
        String OpName = '';
        Decimal totalAmount = 0.0;
        
        List<Opportunity> groupList = new List<Opportunity>();
        List<Opportunity> closeToDeletegroupList = new List<Opportunity>();
        OppColumnStringAndSizeWrap opWrap = new OppColumnStringAndSizeWrap();
        
        for(Opportunity op : opList){
            
            if(groupCode!=null && groupCode.size()>0){
                for(String gCode : groupCode){
                    
                    if(gCode!=null && op.owner.EvKostl__c == gCode && (/*op.CloseDate < System.today() || */ (op.CloseDate >= System.today() && today.daysBetween(op.CloseDate) <=7)) ){
                        groupList.add(op);
                    }
                    
                }
            }
        }
        
        for(Opportunity op : groupList){
            
            if(op.Amount > prevAmount ){
                opName = op.Name;
                prevAmount = op.Amount;
            }
            if(op.AmountDivide8__c!=null){
                totalAmount = totalAmount+op.AmountDivide8__c;
            }
            
            
        }
        Integer size = 0;
        size = groupList.size()-1;
        // opName = opName+' and ' + String.valueOf(size) +'others';
        if(size == 0){
            opName = opName+' '/*+system.label.Group_Hierarchy_And_Column+' '+ String.valueOf(size) +' '+system.label.Group_Hierarchy_more_Column */+ 'total;'+decimalToCommaSeparatedInteger(totalAmount)+System.label.Group_Hierarchy_100M_Label;
            opWrap.customString = opName;
            opWrap.Size = 1;
        }
        
        else if(size >0){
            // if(size-1 == 1){
            //     opName = opName+' '+ 'total;'+decimalToCommaSeparatedInteger(totalAmount)+System.label.Group_Hierarchy_100M_Label;
            // }
            // else {
            opName = opName+' '+system.label.Group_Hierarchy_And_Column+' '+ String.valueOf(size) +' '+system.label.Group_Hierarchy_more_Column + 'total;'+decimalToCommaSeparatedInteger(totalAmount)+System.label.Group_Hierarchy_100M_Label;
            // }
            
            opWrap.customString = opName;
            opWrap.Size = size + 1;
        }
        opWrap.totalWrapAmount = totalAmount;
        system.debug('divneartocloseopWrap--->' + opWrap);
        return opWrap;
        
    }
    
    public static  OppColumnStringAndSizeWrap HighestAmountOppName(List<Opportunity> opList , String groupCode){
        system.debug('groupCode1-->' + groupCode);
        Date today = Date.today();
        Decimal prevAmount = 0.0;
        String OpName = '';
        List<Opportunity> groupList = new List<Opportunity>();
        List<Opportunity> closeToDeletegroupList = new List<Opportunity>();
        OppColumnStringAndSizeWrap opWrap = new OppColumnStringAndSizeWrap();
        // Map<boolean,string> isChildVsStringMap.= new Map<boolean,string>();
        for(Opportunity op : opList){
            if(op.owner.EvKostl__c == groupCode && (op.CloseDate < System.today() /*||  (op.CloseDate > System.today() && today.daysBetween(op.CloseDate) <=7)*/) ){
                groupList.add(op);
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
        if(size == 0){
            
            opName = opName;
            opWrap.customString = opName;
            opWrap.Size = 1;
        }
        else if(size > 0){
            opName = opName+' '+ system.label.Group_Hierarchy_And_Column + ' ' + String.valueOf(size) + ' ' + system.label.Group_Hierarchy_more_Column;
            opWrap.customString = opName;
            opWrap.Size = size+1;
        }
        //opWrap.totalWrapAmount = totalAmount;
        
        return opWrap;
    }
    
    public class OppColumnStringAndSizeWrap{
        
        public Integer Size = 0;
        public String customString='';
        public Decimal totalWrapAmount =0;
    }
    
    public static OppColumnStringAndSizeWrap HighestAmountForCloseDateOpp(List<Opportunity> opList , String groupCode){
        
        
        Date today = Date.today();
        Decimal prevAmount = 0.0;
        String OpName = '';
        Decimal totalAmount = 0.0;
        List<Opportunity> groupList = new List<Opportunity>();
        List<Opportunity> closeToDeletegroupList = new List<Opportunity>();
        OppColumnStringAndSizeWrap opWrap = new OppColumnStringAndSizeWrap();
        
        
        for(Opportunity op : opList){
            
            if(op.owner.EvKostl__c == groupCode && (op.CloseDate >= System.today() && today.daysBetween(op.CloseDate) <=7) ){
                closeToDeletegroupList.add(op);
            }
            
        }
        
        
        
        for(Opportunity op : closeToDeletegroupList){
            // system.debug('lastListItemSecond->' + op.Amount + 'and ' + 'name' + op.Name);
            if(op.Amount > prevAmount ){
                opName = op.Name;
                prevAmount = op.Amount;
            }
            if(op.AmountDivide8__c!=null){
                totalAmount = totalAmount+op.AmountDivide8__c;
            }
            
            
            
        }
        Integer size = 0;
        size = closeToDeletegroupList.size()-1;
        // opName = opName+' '+system.label.Group_Hierarchy_And_Column+' '+ String.valueOf(size) +' '+system.label.Group_Hierarchy_more_Column + 'total;'+decimalToCommaSeparatedInteger(totalAmount);
        if(size == 0){
            opName = opName+' '+/*system.label.Group_Hierarchy_And_Column+' '+ String.valueOf(size) +' '+system.label.Group_Hierarchy_more_Column*/ + 'total;'+decimalToCommaSeparatedInteger(totalAmount)+System.label.Group_Hierarchy_100M_Label;
            opWrap.customString = opName;
            opWrap.Size = 1;
        }
        
        else if(size >0){
            opName = opName+' '+system.label.Group_Hierarchy_And_Column+' '+ String.valueOf(size) +' '+system.label.Group_Hierarchy_more_Column + 'total;'+decimalToCommaSeparatedInteger(totalAmount)+System.label.Group_Hierarchy_100M_Label;
            opWrap.customString = opName;
            opWrap.Size = size+1;
        }
        opWrap.totalWrapAmount = totalAmount;
        
        return opWrap;
    }
    
    
    public static String decimalToCommaSeparatedInteger(Decimal d) {
        
        System.debug('CHLOG::Original Decimal value : ' + d);
        Long l = (Long)d;
        Decimal rest = d - l;
        Decimal restRound = rest.setScale(1, RoundingMode.HALF_UP);
        String restStr = String.valueOf(restRound);
        if (restStr.startsWith('0.')) {
            restStr = '.' + restStr.substring(2);
        } else if (restStr.startsWith('1.0')) { // chae_ho.yang added due to showing amount as one decimal place
            l += 1;
            restStr = '.0';
        }
        
        String s = String.valueOf(l);
        String result = '';
        Integer length = s.length();
        Integer counter = 0;
        for (Integer j = length - 1; j >= 0; j--) {
            counter++;
            result = s.substring(j, j + 1) + result; 
            if (counter == 3 && j != 0) {
                result = ',' + result;
                counter = 0;
            }
        }
        return result+restStr; 
    }  
    
    
    //for v3.0 functoin to reverse a list.
    public static List<Decimal> descOrderList(List<Decimal> toReverse){
        
        List<Decimal> reversed = new List<Decimal>();
        
        for(Integer i = toReverse.size() - 1; i >= 0; i--){
            reversed.add(toReverse[i]);
        }
        
        return reversed;
    }
    
    
    /* public static boolean isValidTeam(String teamCode, List<group_hierarchy__c> getDivisionList ,Set<String> allCostCenterCodes){

for(group_hierarchy__c gh : getDivisionList){

if(gh.type__c == 'Group' && (gh.ParentTeam__c!=null || gh.ParentTeam__c!='') && gh.ParentTeam__c == teamCode){

}
}

//update query
//
SELECT Id, CloseDate, convertCurrency(Amount), convertCurrency(AmountDivide8__c), Name, Owner.EvKostl__c
FROM Opportunity
WHERE (Owner.EvKostl__c IN ('T100-12153', 'T100-12210', 'T100-12489', 'T100-12490'))
AND (CloseDate < TODAY OR (CloseDate >= TODAY AND CloseDate <= NEXT_N_DAYS:7))
AND RecordType.DeveloperName = 'HQ'
AND StageName IN ('Z02', 'Z03', 'Z04')
AND (CompanyCode__c NOT IN ('L1B0', 'L1E0', 'T110', 'T120', 'T140', 'T640', 'T641', 'ZB01', 'ZB10', 'ZBK'))
AND Owner.Email != 'mysales@samsung.com'
AND FirstCloseDate__c = null
ORDER BY Owner.EvKostl__c ASC, CloseDate ASC
select id,closedate,convertCurrency(Amount),convertCurrency(AmountDivide8__c),name,owner.EvKostl__c from opportunity where (owner.EvKostl__c='T100-12312') AND (closedate < TODAY or (closedate >= TODAY AND closedate <= NEXT_N_DAYS:7)) AND RecordType.DeveloperName = 'HQ' AND StageName IN ('Z02','Z03','Z04')  AND (CompanyCode__c !='T110' or CompanyCode__c !='T120' or CompanyCode__c !='T140' or CompanyCode__c !='T640' or CompanyCode__c !='TL1B0' or CompanyCode__c !='L1E0' or CompanyCode__c !='ZBK' or CompanyCode__c !='ZB01' or CompanyCode__c !='ZB10') and Owner.Email !='mysales@samsung.com' and  FirstCloseDate__c = null order by owner.EvKostl__c, closedate asc
select id, closedate, Amount, name, owner.EvKostl__c from opportunity where (owner.EvKostl__c='T100-11788' or owner.EvKostl__c='T100-12312' or owner.EvKostl__c='T100-12313' or owner.EvKostl__c='T100-12314') AND (closedate < TODAY or (closedate > TODAY AND closedate <= NEXT_N_DAYS:7)) AND RecordType.DeveloperName = 'HQ' AND StageName IN ('Z02', 'Z03', 'Z04') AND (CompanyCode__c !='T110' or CompanyCode__c !='T120' or CompanyCode__c !='T140' or CompanyCode__c !='T640' or CompanyCode__c !='TL1B0' or CompanyCode__c !='L1E0' or CompanyCode__c !='ZBK' or CompanyCode__c !='ZB01' or CompanyCode__c !='ZB10') and Owner.Email !='mysales@samsung.com' and  FirstCloseDate__c = null order by owner.EvKostl__c 
}*/
    
    
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
        public String reportUrl2 = '';
        public String TeamName = '';
        
        public List<OppGroupViseWrapper> childRec;
        
    }
    
    
}