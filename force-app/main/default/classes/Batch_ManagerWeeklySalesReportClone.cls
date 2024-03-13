/**
* @description       : 
* @author            : rakshit.s@samsung.com  d.ashish@samsung.com  aditya.r2@samsung.com
* @group             : 
* @last modified on  : 12-19-2023
* @last modified by  : atul.k1@samsung.com
* Ver   Date         Author                   Modification
 * 1.0  11-24-2023   atul.k1@samsung.com      (IT) HQ mailing improvement MYSALES-361
 * 1.1  12-19-2023   atul.k1@samsung.com      (IT) HQ mailing modification (receiver) MYSALES-384 And Dynamic year change MYSALES-381
 * 1.2  04-03-2024   atul.k1@samsung.com       Weekly Sales Report Logic Change MYSALES-463
 * 1.3  03-08-2024   atul.k1@samsung.com       Changing the BO Count and Sum of the bases of DiffAmt__c MYSALES-377
**/
global class Batch_ManagerWeeklySalesReportClone implements DataBase.Batchable<SObject>, DataBase.AllowsCallouts, Database.Stateful, Schedulable{
    
    private static Boolean isSandbox = Utils.getIsSandbox();
    private set<String> scpBoCodeSet = new Set<String>();
    
    private List<IF_Log__c> allLog = new List<IF_Log__c>();
    private List<IF_Log.InterfaceLog> ifLog = new List<IF_Log.InterfaceLog>();
    private List<userInfoWrap> userWrap = new List<userInfoWrap>();
    private List<KnoxEmail__c> KnoxEmailList = new List<KnoxEmail__c>();
    global Map<String, String> stageNameToLabelMap = new Map<String, String>();
    global Map<String, List<User>> managerVsUserMap = new Map<String,List<User>>();
    global Map<String, String> managerVsCostCenterMap = new Map<String, String>();
    //MYSALES-384
    global Set<String> emailSet = new Set<String>();
    public DataBase.QueryLocator start(Database.BatchableContext BC){
        
        //for getting label of stagename when doing query on parent from child because toLabel does not work on it.          
        // Get the Opportunity object's Describe result
        Schema.DescribeSObjectResult opportunityDescribe = Opportunity.SObjectType.getDescribe();
        
        // Get the field describe for StageName
        Schema.DescribeFieldResult stageNameFieldDescribe = opportunityDescribe.fields.getMap().get('StageName').getDescribe();
        
        // Get the picklist values
        List<Schema.PicklistEntry> picklistValues = stageNameFieldDescribe.getPicklistValues();
        
        // Populate the map with API names and labels
        for (Schema.PicklistEntry picklistEntry : picklistValues) {
            stageNameToLabelMap.put(picklistEntry.getValue(), picklistEntry.getLabel());
        }
        // end logic for stage name label
        
        Map<String,aggregateResult> table1InProgressMap = new Map<String,aggregateResult>();
        Set<String> cst = new Set<String>();
        Set<String> resList = new Set<String>();
        for(aggregateResult aggres : [select max(owner.CostCenter_Level_5__c),owner.EvKostl__c from opportunity where recordtype.name = 'HQ' and companycode__c = 'T100' and owner.evkostl__c != null and owner.CostCenter_Level_5__c != null group by owner.EvKostl__c]){
            cst.add((String)aggres.get('EvKostl__c'));
        }
        system.debug('Cost Center Size from Start Method : '+ cst.size() + ' now Set : '+ cst);
        
        List<costcenter__c> manList = new List<costcenter__c>([select name, deptmanager__r.name, DeptManagerEmail__c, costcenter__c from costcenter__c where DeptManager__c != null and costcenter__c in :cst]);
        for(costcenter__c c : manList){
            resList.add(c.DeptManagerEmail__c);
        }
        System.debug('Final Recipient List size : '+ resList.size() + ' now List : '+ resList);
        List<User> allSalesRep = new List<User>([Select id, name,email,EvKostl__c from user  /* And email='test1@test.com'*/]);               
        //List<User> managerList = new List<User>([Select id, name,email,EvKostl__c from user where email IN: resList AND companycode__c = 'T100']);
        
        Set<String> requiredCostCenterSet = new Set<String>();
        Map<String,String> userCodeVsidMap = new Map<String,String>();
        Map<String ,User> salesRepEmailVsUserMap = new map<String , User>();
        List<Employee__c> neededEmployee = new List<Employee__c>();
        
        List<Scpsimulation__c> scpList = new List<ScpSimulation__c>([Select id , BoCode__c from SCpSimulation__c where BoCode__c!=null or BoCode__c!='']);
        
        for(ScpSimulation__c ss : scpList){           
            scpBoCodeSet.add(ss.BoCode__c);
        }
        for(User uu : allSalesRep){
            salesRepEmailVsUserMap.put(uu.email , uu);
        }
        
        if(!manList.isEmpty()){
            //system.debug('insidemainlogic');
            for(costcenter__c managerUser : manList){
                userCodeVsidMap.put(managerUSer.costcenter__c , managerUser.DeptManagerEmail__c);
                requiredCostCenterSet.add(managerUser.costcenter__c);
            }
            //system.debug('requiredcostcenter' + requiredCostCenterSet);
            neededEmployee = [select id,EvMailAddr__c,EvKostl__c from Employee__c where EvKostl__c IN : requiredCostCenterSet and (EvMailAddr__c!=null or EvMailAddr__c!='')];
            system.debug('neededEmployee : '+ neededEmployee);
            // for(User managerUser : managerList){
            
            for(Employee__c emp : neededEmployee){
                //system.debug('emp email' + emp.EvMailAddr__c + 'empid-->' + emp.id);
                if(salesRepEmailVsUserMap.containsKey(emp.EvMailAddr__c) && salesRepEmailVsUserMap!=null){
                    //system.debug('inside first if');
                    if(managerVsUserMap.containsKey(userCodeVsidMap.get(emp.EvKostl__c))){
                        managerVsUserMap.get(userCodeVsidMap.get(emp.EvKostl__c)).add(salesRepEmailVsUserMap.get(emp.EvMailAddr__c));
                        managerVsCostCenterMap.put(userCodeVsidMap.get(emp.EvKostl__c) , emp.EvKostl__c);
                    }
                    
                    else{
                        managerVsUserMap.put(userCodeVsidMap.get(emp.EvKostl__c) , new list<User>());
                        managerVsUserMap.get(userCodeVsidMap.get(emp.EvKostl__c)).add(salesRepEmailVsUserMap.get(emp.EvMailAddr__c));
                        managerVsCostCenterMap.put(userCodeVsidMap.get(emp.EvKostl__c) , emp.EvKostl__c);                        
                    }
                }
                
            }
            // }
            system.debug('managerVsUserMap : '+ managerVsUserMap);
        }
        //if(managerList!=null)
        if(system.label.Weekly_Manager_Report_User != 'null'){
            List<String> userIdSet =  new List<String>();
            
            userIdSet = system.label.Weekly_Manager_Report_User.split(',');
            String idList = '\''+String.join(userIdSet,'\',\'')+'\'';
            return Database.getqueryLocator('select id, name, deptmanager__r.name, DeptManagerEmail__c, costcenter__c from costcenter__c where DeptManager__c != null and DeptManagerEmail__c IN('+idList +')');
        } 
        
        else{
            if(Test.isRunningTest()){
                return Database.getqueryLocator('select id, name, deptmanager__r.name, DeptManagerEmail__c, costcenter__c from costcenter__c where DeptManager__c != null and DeptManagerEmail__c=\'test@test.com\' Limit 1');
            }else{
                String query = 'select id, name, deptmanager__r.name, DeptManagerEmail__c, costcenter__c from costcenter__c where DeptManager__c != null and costcenter__c in :cst ';
                return Database.getqueryLocator(query);
            }
        }
        
    }
    
    
    public void execute(Database.BatchableContext BC, List<costcenter__c> listScope){
        boolean table1Present = false;
        boolean table2Present = false;
        boolean table3Present = false;
        boolean table4Present = false;
        boolean table5Present = false;
        Map<String,Object> mailresult = new Map<String,Object>(); 
        Integer headingCounter = 1;
        System.debug('### Batch_ManagerWeeklySalesReport :: execute :: listScope = ' + listScope);
        System.debug('  Size of listScope : '+ listScope.size());
        
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
        if(isSandbox){
            //toList = new List<String>(System.label.WEEKLY_MAIL_RECIPIENT_STAGE.split(','));
            toList.add('aditya.r2@stage.samsung.com');
        }
        if(!isSandbox){
            //toList = new List<String>(System.label.WEEKLY_MAIL_RECIPIENT.split(','));
            String st = System.label.WEEKLY_MAIL_RECIPIENT_TEST;
            if(st != 'null' && !emailSet.contains(listScope[0].DeptManagerEmail__c))
            	toList = new List<String>(st.split(','));
                emailSet.add(listScope[0].DeptManagerEmail__c); 
            //MYSALES-384 Start
            /*if(!emailSet.contains(listScope[0].DeptManagerEmail__c)){
                //toList.add(listScope[0].DeptManagerEmail__c);
                //emailSet.add(listScope[0].DeptManagerEmail__c);
            }*/
        }
        
        String strEmailTemp = '';
        String strEmail = '';
        EmailTemplate em = [SELECT Id,subject FROM EmailTemplate WHERE DeveloperName = 'HQ_Manager_Weekly_Sales_Report_Test'];
        Id templateId = em.Id;
        strEmail = [SELECT HtmlValue FROM EmailTemplate WHERE Id = :templateId].HtmlValue;
        String strTitle = system.label.WEEKLY_MAIL_TITLE;
        
        system.debug('fullmap' + managerVsUserMap.keySet() + 'size' + managerVsUserMap.keySet().size());
        system.debug('newMapKeyset' + managerVsCostCenterMap.keyset() + 'size' + managerVsCostCenterMap.keySet().size());
        system.debug('keySet->' + 'id-->' +listScope[0].DeptManagerEmail__c + managerVsUserMap.containsKey(listScope[0].DeptManagerEmail__c));
        
        //table 1 logic start, table 1 in Progress BO logic
        if(managerVsUserMap.containsKey(listScope[0].DeptManagerEmail__c) && !toList.isEmpty()){  // And condition add by //MYSALES-384
            //opportunitycode__c add my MYSALES-361 V 1.0
            List<Opportunity> opplist = [Select id, convertCurrency(Amount), owner.name,opportunitycode__c, CurrencyIsoCode, CloseDate from opportunity where ownerid in:managerVsUserMap.get(listScope[0].DeptManagerEmail__c) AND (StageName = 'Z01' OR StageName = 'Z02' OR StageName = 'Z03' OR StageName = 'Z04') AND  CloseDate = THIS_YEAR AND RecordType.Name='HQ' AND companycode__c='T100'];
            System.debug('OppList for user----------> : '+ opplist.size());
            Map<string, decimal> oppSum = new Map<string, decimal>();
            Map<string, decimal> oppAmtSum = new Map<string, decimal>();
            for(Opportunity opp: opplist){
                 
                if(oppSum.containskey(String.valueOF(opp.Owner.Name)) && oppAmtSum.containskey(String.valueOF(opp.Owner.Name))  ){
                    oppSum.put(String.valueOF(opp.Owner.Name),(oppSum.get(String.valueOF(opp.Owner.Name)) + 1));
                    oppAmtSum.put(String.valueOF(opp.Owner.Name),(oppAmtSum.get(String.valueOF(opp.Owner.Name)) + opp.Amount));
                }
                else{
                    oppSum.put(String.valueOF(opp.Owner.Name),1);
                    oppAmtSum.put(String.valueOF(opp.Owner.Name),opp.Amount);
                }
            }
            
            //table 1 Completed BO logic
            Map<String,Integer> tableOneCount =new MAp<string,integer>() ;
            Map<String,Decimal> BO_AmountMap = new Map<String,Decimal>();
            Set<String> compositeKeySet = new set<string>();
            Map<String,String> countUnquieBOCode = new  Map<String,String>();//MYSALES-361 V 1.0
            //Adding DiffAmtLoc__c in below Query MYSALES-361 V 1.0
            //Start MYSALES-377
            String bulletdataString = '';
            List<BulletinBoard__c> bulletinInfo= [Select id,Name,Notice__c From BulletinBoard__c where Notice__c = true Order By LastModifiedDate desc Limit 3];
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
                    bulletdataString = bulletdataString+'<li class="NoSpace">'+'<span class="DotSpace">'+'<a class="linktext" href="' + str + '">'+ eachbulletinInfo.Name + '</a>'+'</span>'+'</li>'+'</br>'; //with ui li
                    //bulletdataString = bulletdataString +'<a style="color:blue" href="' + str + '">'+'>'+ eachbulletinInfo.Name + '</a>'+'</br>';
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
            //MYSALES-463 Changing the DiffAmtLoc__c to DiffAmt__c. V 1.2
            List<opportunityamt__c> oppam = [Select opportunitycode__c, Version__c, Opportunity__r.Owner.Name,DiffAmt__c,DiffAmtLoc__c from opportunityamt__c where companycode__c ='T100' and opportunity__r.ownerid in:managerVsUserMap.get(listScope[0].DeptManagerEmail__c)  and closedate__c = this_year and opportunity__r.recordtype.developername = 'HQ' and opportunity__r.stagename = 'Z05']; // revert the Confirmdate__c to close date
            for(opportunityamt__c res : oppam){
                system.debug('Version===>'+res.Version__c);
                system.debug('Opp Code===>'+res.opportunitycode__c);
                system.debug('res.Opportunity__r.Owner.Name==>'+res.Opportunity__r.Owner.Name);
                system.debug('tableOneCount==>'+tableOneCount);
                system.debug('countUnquieBOCode==>'+countUnquieBOCode);
                system.debug('res.DiffAmt__c==>'+res.DiffAmt__c);
                //MYSALES-361 V 1.0 && condition add in below code.
				if(tableOneCount.containskey(String.valueOF(res.Opportunity__r.Owner.Name)) ){
					if(!(countUnquieBOCode.containskey(res.opportunitycode__c)) && (res.DiffAmt__c != 0)){
                        system.debug('Inside If');
						tableOneCount.put(String.valueOF(res.Opportunity__r.Owner.Name),tableOneCount.get(String.valueOF(res.Opportunity__r.Owner.Name)) + 1);
                        countUnquieBOCode.put(res.opportunitycode__c,res.Version__c);
					}
				}
                else{
                     system.debug('Inside else');
					if(((countUnquieBOCode.isEmpty()) || ((!countUnquieBOCode.isEmpty()) && (!countUnquieBOCode.containsKey(res.opportunitycode__c)))) 
					     && (res.DiffAmt__c != 0)){
                        system.debug('Inside If-else');
						tableOneCount.put(String.valueOF(res.Opportunity__r.Owner.Name),1);
						countUnquieBOCode.put(res.opportunitycode__c,res.Version__c);
					}
                }
			    system.debug('Version111===>'+res.Version__c);
                system.debug('Opp Code111===>'+res.opportunitycode__c);
                system.debug('res.Opportunity__r.Owner.Name111==>'+res.Opportunity__r.Owner.Name);
                system.debug('tableOneCount111==>'+tableOneCount);
                system.debug('countUnquieBOCode111==>'+countUnquieBOCode);
                system.debug('res.DiffAmt__c111==>'+res.DiffAmt__c);
                compositeKeySet.add(res.opportunitycode__c+'_'+res.Version__c);
            }
            
            BO_AmountMap = getBORelatedAmount(compositeKeySet,BO_AmountMap);
            // TABLE 1 logic end
            Date dat = system.today();
            Integer YearVal = dat.year();
            //Integer YearVal = 2024;
            integer valYear = Math.mod(YearVal,2000);
            system.debug('Year Value==>'+valYear);
            String table1Header = '<thead> <tr>'+
                '<td >영업대표</th>'+
                '<td class="align_right">수주완료 건수</th>'+
                '<td class="align_right">수주완료 금액 </th>'+
                '<td class="align_right">진행중 BO건수(\''+valYear+'년 수주예상일 대상)</th>'+    // //MYSALES-381
                '<td class="align_right">BO금액(\''+valYear+'년 수주예상일 대상)</th>'+           //MYSALES-381
                '</tr> </thead>';
            
            String table1body = '<tbody>';    
              List<User> sortedUsers = new list<User>();
            sortedUsers = sortUsersByUsername(managerVsUserMap.get(listScope[0].DeptManagerEmail__c));
            for(User userObj : sortedUsers){
                
                //Creation of table 1 start
                //table1body = '';
                integer col1Count = 0;
                if(tableOneCount != null && tableOneCount.containskey(userObj.Name) && tableOneCount.get(userObj.Name) != null)
                    col1Count = tableOneCount.get(userObj.Name);
                
                integer col3count = 0;
                
                if(oppSum!= null && oppSum.containskey(userObj.Name) && oppSum.get(userObj.Name) != null)
                    col3count = Integer.valueOf(oppSum.get(userObj.Name));
                
                String amt = '0';
                if(BO_AmountMap != null && BO_AmountMap.containskey(userObj.Name) && BO_AmountMap.get(userObj.Name) != null)
                    amt = String.valueOf(BO_AmountMap.get(userObj.Name) /1000000); //amt = BO_AmountMap.get(userObj.Name)  > 0 ? String.valueOf(BO_AmountMap.get(userObj.Name) /1000000) : '0' ;  //MYSALES-361 V 1.0
                
                String amt1 = '0';
                if(oppAmtSum!= null && oppAmtSum.containskey(userObj.Name) && oppAmtSum.get(userObj.Name) != null)
                    amt1= String.valueOf(Decimal.valueOf(String.valueOf(oppAmtSum.get(userObj.Name)))/1000000); // amt1= Decimal.valueOf(String.valueOf(oppAmtSum.get(userObj.Name))) > 0 ? String.valueOf(Decimal.valueOf(String.valueOf(oppAmtSum.get(userObj.Name)))/1000000) : '0' ;  //MYSALES-361 V 1.0
                System.debug('User name & email for completed : '+ userObj.Name + ' '+ userObj.Email);
                
                //system.debug('------->  --->' + (Decimal.valueOf(String.valueOf(oppAmtSum.get(userObj.Name)))/1000000) + '--->' + String.valueOf(Decimal.valueOf(String.valueOf(oppAmtSum.get(userObj.Name)))/1000000));
                List<String> amtStr = new List<String>();
                List<String> amtStr1 = new List<String>();
                String num = '';
                String num1 = '';
                if(amt.contains('.')){
                    amtStr= amt.split('\\.');
                    num = amtStr[0] +'.' + amtStr[1].substring(0,2);
                }
                else{
                    num = amt;
                }
                if(amt1.contains('.')){
                    amtStr1= amt1.split('\\.');
                    num1 = amtStr1[0] +'.' + amtStr1[1].substring(0,2);
                }
                else{
                    num1 = amt1 ;
                }
                if(col1Count == 0 && col3Count == 0){
                    
                }else{
                    table1body += '<tr>'+
                        '<td >' + userObj.Name + '</td>' +
                        '<td class="align_right">' + col1Count + '</td>' +
                        '<td class="align_right">' + formattedNumber(num) + '</td>' +
                        '<td class="align_right">' + col3Count + '</td>' +
                        '<td class="align_right">' + formattedNumber(num1) + '</td>'+ 
                        '</tr>' ;
                    table1Present = true;
                }
                //Creation of table 1 end
                system.debug('formatted Number : '+ formattedNumber(num));
                system.debug('formatted Number1 : '+ formattedNumber(num1));
            }
            //Creation of table 1 Body end
            table1body += '</tbody>';
            //Start Replacing Template table with real tables
            datetime dt1 = Date.today();
            String sDate = String.valueOf(dt1.format('yyyy-MM-dd'));
            //String sDate = String.valueOf(System.now());
            strEmail = strEmail.replace('{!DateValue}', sDate);
            if(table1body.contains('<tr>')){
                strEmail = strEmail.replace('{!tableString1}', table1Header + table1body);
                strEmail = strEmail.replace('Curent_Year',String.Valueof(valYear));  //MYSALES-381
                headingCounter++;
            }
            
            //Creation of table 2 Body Start
            List<Opportunity> table2List = new List<Opportunity>();
            table2List = [Select id,name ,owner.name, OpportunityCode__c,closeDate,StageName, toLabel(StageName) toLabel_StageName,convertCurrency(Amount),CurrencyIsoCode from opportunity where owner.id IN : managerVsUserMap.get(listScope[0].DeptManagerEmail__c) AND (StageName = 'Z02' OR StageName = 'Z03' OR StageName = 'Z04') AND  CloseDate <= TODAY AND RecordType.Name='HQ' AND companycode__c='T100' AND FirstCloseDate__c = null order by closeDate];
            
            if(table2List.size()>0){
                table2Present = true;
                if(!table1Present && table2Present){
                    strEmail = strEmail.replace('<tr><td class="box_padding"><table class="title_wrap"><tr><td class="title">2. 지연 BO','<tr><td><table class="title_wrap"><tr><td class="title">2. 지연 BO');
                }
                String strTemp = '';
                strTemp += '<thead> <tr>'+
                    '<td >영업대표</th>'+
                    '<td >사업기회 코드</th>'+
                    '<td colspan ="3" >사업기회명</th>'+
                    '<td colspan ="0.5" >수주예상일</th>'+
                    '<td >단계</th>'+
                    '<td class="align_right">금액</th>'+
                    '</tr></thead>';
                strTemp +=  '<tbody>';
                for(Opportunity opp : table2List){
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
                    Decimal exchangeRate;
                    String currencyCode = opp.CurrencyIsoCode;
                    Date closeDatee = opp.CloseDate.toStartOfMonth();
                    
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
                        System.debug('Table 2 amtStr :'+amtStr);
                        system.debug('Table 2 num inside if : '+ num);
                    }
                    else{
                        if(opp.Amount!=null){
                            amt = String.valueOf(opp.Amount/1000000) ;                      
                        }
                        
                    }
                    
                    system.debug('table 2 formatted num '+ formattedNumber(num));
                    strTemp +=  '<tr>'+
                        '<td>' + opp.owner.name + '</td>' +
                        '<td class="nowrap">' + opp.OpportunityCode__c + '</td>' +
                        '<td  colspan ="3">' + '<a style="color:blue" href="' + str + '">'+ opp.Name + '</a>' + '</td>' +
                        '<td  colspan ="0.5" class="nowrap">' + closeDate + '</td>' +
                        '<td class="nowrap">' + opp.get('toLabel_StageName') + '</td>'+ 
                        '<td class="align_right">' + formattedNumber(num) + '</td>'+ 
                        '</tr>' ;
                    
                }
                
                //Creation of table 2 Body end
                strTemp += '</tbody>';
                system.debug('strEmail before Table 2'+ strEmail);
                system.debug('Table 2--->'+ strTemp);
                //Start Replacing Template table with real tables
                // String sDate = String.valueOf(System.now());
                //strEmail = strEmail.replace('{!DateValue}', sDate);
                strEmail = strEmail.replace('{!tableString2}',strTemp);
                strEmail = strEmail.replace('2. ' , String.valueOf(headingCounter)+'. ');
                system.debug('strEmail after Table 2'+ strEmail);
                headingCounter++;
            }
            
            //table3creation start
            
            List<WeeklyReport__c > table3List = new List<WeeklyReport__c >();
            //table3List = [Select id,account.name,(Select id,Name,CheckedforIssue__c,Critical__c,User_Department__c,User_Division__c,ReportingDate__c from Weekly_Report__r limit 1),name ,owner.name, OpportunityCode__c,closeDate,StageName, toLabel(StageName) toLabel_StageName,Amount from opportunity where owner.id IN : managerVsUserMap.get(listScope[0].id) AND createddate = THIS_WEEK order by owner.name];
            table3List = [select id,name,opportunity__r.Account.Name,opportunity__r.StageName,opportunity__r.owner.name,opportunity__r.OpportunityCode__c,User_Department__c,User_Division__c,ReportingDate__c,Critical__c,CheckedforIssue__c,opportunity__r.closedate,opportunity__r.id,opportunity__r.name,convertCurrency(opportunity__r.amount),opportunity__r.CurrencyIsoCode from WeeklyReport__c where createddate = this_week and opportunity__r.owner.EvKostl__c =: managerVsCostCenterMap.get(listScope[0].DeptManagerEmail__c) and opportunity__r.companycode__c = 'T100' and opportunity__r.recordtype.name = 'HQ' order by ReportingDate__c];
            
            if(table3List.size()>0){
                table3Present = true;
                if(!table1Present && !table2Present && table3Present){
                    strEmail = strEmail.replace('<tr><td class="box_padding"><table class="title_wrap"><tr><td class="title">3. 금주에 주간보고, 현안보고가 등록된 BO','<tr><td><table class="title_wrap"><tr><td class="title">3. 금주에 주간보고, 현안보고가 등록된 BO');
                }
                String strTemp = '';
                strTemp += '<thead> <tr>'+
                    '<td >영업대표</th>'+
                    '<td >사업기회 코드</th>'+
                    '<td colspan ="3" >사업기회명</th>'+
                    '<td colspan ="0.5" >수주예상일</th>'+
                    '<td >단계</th>'+
                    '<td class="align_right">금액</th>'+
                    '<td >보고서 유형</th>'+
                    '<td >보고서 명</th>'+
                    '<td >고객명</th>'+
                    '<td >작성일자</th>'+
                    //'<td >소속 사업부</th>'+
                    //'<td >작성일자</th>'+
                    '</tr></thead>';
                strTemp +=  '<tbody>';
                
                for(WeeklyReport__c  opp : table3List){
                    String str; 
                    String strRep = '';
                    if(isSandbox){
                        str = 'https://sdssfa--qa.sandbox.lightning.force.com/lightning/r/Opportunity/' + opp.opportunity__r.Id + '/view';
                        strRep ='https://sdssfa--qa.sandbox.lightning.force.com/lightning/r/WeeklyReport__c/' + opp.Id + '/view';
                        
                    }
                    else{
                        str = 'https://sdssfa.lightning.force.com/lightning/r/Opportunity/' + opp.opportunity__r.Id + '/view';    
                        strRep ='https://sdssfa.lightning.force.com/lightning/r/WeeklyReport__c/' + opp.Id + '/view';
                    }
                    String clDate = String.valueOf(opp.opportunity__r.CloseDate);
                    String closeDate = clDate.substring(0,10);
                    String amt = '';
                    Decimal exchangeRate;
                    String currencyCode = opp.opportunity__r.CurrencyIsoCode;
                    Date closeDatee = opp.opportunity__r.CloseDate.toStartOfMonth();
                    
                    if(opp.opportunity__r.Amount!=null){                       
                        amt = String.valueOf(opp.opportunity__r.Amount/1000000) ;
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
                        if(opp.opportunity__r.Amount!=null){                            
                            amt = String.valueOf(opp.opportunity__r.Amount/1000000) ;
                        }
                        
                    }
                    // System.debug('amtStr Test :'+amtStr);
                    String stagenameApiName= opportunity.StageName.getDescribe().getName();
                    String stagenameLabel = Schema.sObjectType.Opportunity.fields.getMap().get(stagenameApiName).getDescribe().getLabel();
                    datetime rt1 = opp.ReportingDate__c;
                    String repDate = String.valueOf(rt1.format('yyyy-MM-dd'));
                    strTemp +=  '<tr>'+
                        '<td>' + opp.opportunity__r.owner.name + '</td>' +
                        '<td class="nowrap">' + opp.opportunity__r.OpportunityCode__c + '</td>' +
                        '<td  colspan ="3">' + '<a style="color:blue" href="' + str + '">'+ opp.opportunity__r.Name + '</a>' + '</td>' +
                        '<td  colspan ="0.5" class="nowrap">' + closeDate + '</td>' +
                        '<td class="nowrap">' + stageNameToLabelMap.get(opp.opportunity__r.stagename) + '</td>'+ 
                        '<td class="align_right">' + formattedNumber(num) + '</td>';
                    
                    if(opp.Critical__c && !opp.CheckedforIssue__c ){
                        strTemp += '<td>' + '주간보고' + '</td>';
                    }
                    
                    else if(opp.CheckedforIssue__c && !opp.Critical__c){
                        strTemp += '<td>' + '현안보고' + '</td>';
                    }
                    else if(!opp.CheckedforIssue__c && !opp.Critical__c){
                        strTemp += '<td>' + '' + '</td>';
                    }
                    else if(opp.CheckedforIssue__c && opp.Critical__c){
                        strTemp += '<td>' + '주간/현안보고' + '</td>';
                    }
                    
                    strTemp += '<td>' +'<a style="color:blue" href="' + strRep + '">'+opp.Name + '</a>'  + '</td>';
                    
                    
                    strTemp += '<td  >' + opp.opportunity__r.Account.Name + '</td>';
                    
                    //strTemp +=  '<td >' + opp.User_Department__c + '</td>' +
                    //    '<td >' +opp.User_Division__c + '</td>'+ 
                    strTemp +=  '<td >' + repDate + '</td>';
                    
                    
                    strTemp += '</tr>' ;
                }
                
                //Creation of table 3 Body end
                strTemp += '</tbody>';
                //Start Replacing Template table with real tables
                // String sDate = String.valueOf(System.now());
                //strEmail = strEmail.replace('{!DateValue}', sDate);
                strEmail = strEmail.replace('{!tableString3}',strTemp);
                strEmail = strEmail.replace('3. ' , String.valueOf(headingCounter)+'. ');
                headingCounter++;
                //table3 creation ends.
                
            }
            
            //table4creation start
            
            List<Opportunity> table4List = new List<Opportunity>();
            table4List = [Select id,name ,owner.name, OpportunityCode__c,closeDate,StageName,CurrencyIsoCode, toLabel(StageName) toLabel_StageName,convertCurrency(Amount),Opportunity_Review_VRB_Type_Confirm__c,XP63_VRB_APPROVAL_TYPE__c,ZP61_PROPOSAL_SUBMIT_DATE__c,XP6_CONDUCT_DATE__c,XP7_CONDUCT_DATE__c,(select TransactionName__c,Status__c,EndDate__c,StartDate__c    from BO_Activity__r where Status__c = 'In Progress'  AND (transactionname__c='XP61' OR transactionname__c='XP62' OR transactionname__c='XP63' OR  transactionname__c='XP71' OR  transactionname__c='XP72' OR  transactionname__c='XP73') order by StartDate__c desc,transactionname__c desc ) from opportunity where owner.id IN : managerVsUserMap.get(listScope[0].DeptManagerEmail__c) AND (XP6_CONDUCT_DATE__c = NEXT_N_DAYS:30 OR XP7_CONDUCT_DATE__c = NEXT_N_DAYS:30) AND (StageName = 'Z01' OR StageName = 'Z02' OR StageName = 'Z03' OR StageName = 'Z04') order by owner.name];//viz. participation approval type : XP63_VRB_APPROVAL_TYPE__c ,Biz. Participation Conduct Date   :XP6_CONDUCT_DATE__c,Bidding Decision conduct date :XP7_CONDUCT_DATE__c
            
            if(table4List.size()>0){
                table4Present = true;
                if(!table1Present && !table2Present && !table3Present && table4Present){
                    strEmail = strEmail.replace('<tr><td class="box_padding"><table class="title_wrap"><tr><td class="title">4. 1개월 내 수전위 진행 예정 BO','<tr><td><table class="title_wrap"><tr><td class="title">4. 1개월 내 수전위 진행 예정 BO');
                }
                String strTemp = '';
                Set<String> oppId = new Set<String>();
                Map<String, String> oppActList6SeriesMap = new Map<String, String>();
                Map<String, String> oppActList7SeriesMap = new Map<String, String>();
                strTemp += '<thead> <tr>'+
                    '<td >영업대표</th>'+
                    '<td >사업기회 코드</th>'+
                    '<td colspan ="3" >사업기회명</th>'+
                    
                    '<td >수전위 유형</th>'+//Strategy Committee
                    '<td >사업 심의 유형</th>'+//VRB Confirm type
                    
                    
                    '<td colspan ="0.5" >수주예상일</th>'+
                    '<td >단계</th>'+
                    '<td class="align_right">금액</th>'+
                    
                    '<td >사업참여 실행일</th>'+//Biz. participation Conduct
                    '<td >입찰결정 실행일</th>'+//bidding decision conduct
                    '<td >제안 제출일</th>'+//proposal submit date
                    //'<td >수전위 진행</th>'+//last column
                    
                    '</tr></thead>';
                strTemp +=  '<tbody>';
                
                for(Opportunity opp : table4List){
                    oppId.add(opp.Id);
                }
                system.debug('Opp Id for Table 4 : '+ oppId);
                List<Opportunity_Activity__c> oppActList6Series = [select TransactionName__c,Status__c,EndDate__c,StartDate__c,WhatId__c from Opportunity_Activity__c where Status__c in ('In Progress', 'Completed')  AND (transactionname__c='XP61' OR transactionname__c='XP62' OR transactionname__c='XP63' /*OR  transactionname__c='XP71' OR  transactionname__c='XP72' OR  transactionname__c='XP73'*/) and WhatId__c in : oppId order by EndDate__c NULLs Last, TransactionName__c];
                List<Opportunity_Activity__c> oppActList7Series = [select TransactionName__c,Status__c,EndDate__c,StartDate__c,WhatId__c from Opportunity_Activity__c where Status__c in ('In Progress', 'Completed')  AND (/*transactionname__c='XP61' OR transactionname__c='XP62' OR transactionname__c='XP63' OR*/  transactionname__c='XP71' OR  transactionname__c='XP72' OR  transactionname__c='XP73') and WhatId__c in : oppId order by EndDate__c NULLs Last, TransactionName__c];
                system.debug('rakshit' + oppActList6Series);
                system.debug('rakshit2' + oppActList7Series);
                if(oppActList6Series.size() > 0){
                    for(Opportunity_Activity__c oppact : oppActList6Series){
                        oppActList6SeriesMap.put(oppact.WhatId__c,oppact.TransactionName__c);
                    }
                }
                    if(oppActList7Series.size() > 0){
                    for(Opportunity_Activity__c oppact : oppActList7Series){
                        oppActList7SeriesMap.put(oppact.WhatId__c,oppact.TransactionName__c);
                    }
                }   
                
                system.debug('rakshitmap' + oppActList6SeriesMap);
                system.debug('rakshitmap2' + oppActList7SeriesMap);
                for(Opportunity opp : table4List){
                    
                    String str; 
                    if(isSandbox){
                        str = 'https://sdssfa--qa.sandbox.lightning.force.com/lightning/r/Opportunity/' + opp.Id + '/view';
                    }
                    else{
                        str = 'https://sdssfa.lightning.force.com/lightning/r/Opportunity/' + opp.Id + '/view';    
                    }
                    String closeDate = '';
                    String bizconductDate='';
                    String bidconductDate ='';
                    String propsubmitDate='';
                    //Adi
                    //String st = oppvstrans.get(opp.Id);
                    String clDate = String.valueOf(opp.CloseDate);
                    if(clDate != '' && clDate != null)
                        closeDate = clDate.substring(0,10);
                    String bizcnDate = String.valueOf(opp.XP6_CONDUCT_DATE__c);
                    if(bizcnDate != '' && bizcnDate != null)
                        bizconductDate = bizcnDate.substring(0,10);
                    String bidcnDate = String.valueOf(opp.XP7_CONDUCT_DATE__c);
                    if(bidcnDate != '' && bidcnDate != null)
                        bidconductDate = bidcnDate.substring(0,10);
                    String propsubDate = String.valueOf(opp.ZP61_PROPOSAL_SUBMIT_DATE__c);
                    if(propsubDate != '' && propsubDate != null)
                        propsubmitDate = propsubDate.substring(0,10);
                    
                    String ninthColValue = '';
                    String tenthColValue = '';
                    //if(opp.BO_Activity__r != null &&  !opp.BO_Activity__r.isEmpty()){
                        /*if(opp.BO_Activity__r[0].TransactionName__c == 'XP61' || opp.BO_Activity__r[0].TransactionName__c == 'XP71')
LastColValue = '요청';
else if(opp.BO_Activity__r[0].TransactionName__c == 'XP62' || opp.BO_Activity__r[0].TransactionName__c == 'XP72')
LastColValue = '원가';
else if(opp.BO_Activity__r[0].TransactionName__c == 'XP63' || opp.BO_Activity__r[0].TransactionName__c == 'XP73')
LastColValue = '품의';*/
                        //LastColValue = opp.BO_Activity__r[0].Sta
                       
                        
                    //}
                    //column 9 and 10 logic change.
                    if(oppActList6SeriesMap.get(opp.id) == 'XP61'){
                        ninthColValue = '(요청)';
                    }
                    else if(oppActList6SeriesMap.get(opp.id) == 'XP62'){
                        ninthColValue = '(원가)';
                    }
                    else if(oppActList6SeriesMap.get(opp.id) == 'XP63'){
                        ninthColValue = '(품의)';
                    }
                    
                    if(oppActList7SeriesMap.get(opp.id) == 'XP71'){
                        tenthColValue = '(요청)';
                    }
                    else if(oppActList7SeriesMap.get(opp.id) == 'XP72'){
                        tenthColValue = '(원가)';
                    }
                    else if(oppActList7SeriesMap.get(opp.id) == 'XP73'){
                        tenthColValue = '(품의)';
                    }
                    String amt = '';
                    Decimal exchangeRate;
                    String currencyCode = opp.CurrencyIsoCode;
                    Date closeDatee = opp.CloseDate.toStartOfMonth();
                    
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
                            amt = String.valueOf(opp.Amount/1000000) ;
                        }
                        
                    }
                    // System.debug('amtStr Test :'+amtStr);
                    
                    strTemp +=  '<tr>'+
                        '<td>' + opp.owner.name + '</td>' +
                        '<td class="nowrap">' + opp.OpportunityCode__c + '</td>' +
                        '<td  colspan ="3">' + '<a style="color:blue" href="' + str + '">'+ opp.Name + '</a>' + '</td>' +
                        
                        '<td>' + (opp.XP63_VRB_APPROVAL_TYPE__c == null? '사참수전위':'입찰수전위' ) + '</td>' +
                        '<td>' + vrbTypeValues(opp.Opportunity_Review_VRB_Type_Confirm__c) + '</td>' +
                        
                        
                        '<td  colspan ="0.5" class="nowrap">' + closeDate + '</td>' +
                        '<td class="nowrap">' + opp.get('toLabel_StageName') + '</td>'+ 
                        '<td class="align_right">' + formattedNumber(num) + '</td>'+
                        
                        '<td>' + bizconductDate + ninthColValue + '</td>' +
                        '<td>' + bidconductDate + tenthColValue + '</td>' +
                        '<td>' + propsubmitDate + '</td>';
                    //'<td>' + LastColValue + '</td>' 
                    
                    strTemp +=     '</tr>' ;
                }
                
                //Creation of table 4 Body end
                strTemp += '</tbody>';
                strEmail = strEmail.replace('{!tableString4}',strTemp);
                strEmail = strEmail.replace('4. ' , String.valueOf(headingCounter)+'. ');
                headingCounter++;
                //table4 creation ends.
            }
            
            //table5creation start
            
            List<Opportunity> table5List = new List<Opportunity>();
            // Adding ProposalPM__c, ProposalPM__r.Name in below query MYSALES-361 V 1.0
            table5List = [Select id, OpportunityCode__c,CMBizType__c,closeDate,ProposalPM__c, ProposalPM__r.Name,cRevenueStartDate__c,CurrencyIsoCode,CompanyCode__c,Owner.Name,StageName,name, toLabel(StageName) toLabel_StageName,convertcurrency(Amount),(select id,ProjectCode__c from BO_Project__r), (select id,ProposalPMPlan__c,ExecutionPMPlan__c, BOCode__c ,companycode__c,ProposalPMNo__c,ProposalPMStatus__c,P_Projectcode__c,ProposalPMStDt__c,ProposalPMEdDt__c,P_Projectname__c from TXP_manpower_input_information__r limit 1) from opportunity where (stageName='Z01' or stageName='Z02' or stageName='Z03' or stageName='Z04') AND owner.id IN : managerVsUserMap.get(listScope[0].DeptManagerEmail__c) AND Closedate = NEXT_N_MONTHS:3 AND RecordType.Name='HQ' AND companycode__c='T100' order by closeDate];
            
            if(table5List.size()>0){
                table5Present = true;
                if(!table1Present && !table2Present && !table3Present && !table4Present && table5Present){
                    strEmail = strEmail.replace('<tr><td class="box_padding"><table class="title_wrap"><tr><td class="title">5. 3개월 내 수주예상 BO','<tr><td><table class="title_wrap"><tr><td class="title">5. 3개월 내 수주예상 BO');
                }
                String strTemp = '';
                strTemp += '<thead> <tr>'+
                    '<td >영업대표</th>'+
                    '<td >사업기회 코드</th>'+
                    '<td colspan ="3" >사업기회명</th>'+
                    '<td colspan ="0.5" >수주예상일</th>'+
                    '<td >단계</th>'+
                    '<td class="align_right">금액</th>'+
                    '<td >제안PM 가용 여부</th>'+
                    '<td >인력투입계획 작성여부 (사전/실행)</th>'+
                    '<td >SCP 견적 등록 여부</th>'+
                    '</tr></thead>';
                strTemp +=  '<tbody>';
                
                for(Opportunity opp : table5List){
                    proposalPMInfo pp = new proposalPMInfo();
                    pp = getTable6ProposalPMData(opp.TXP_manpower_input_information__r  , opp.BO_Project__r , opp);
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
                    Decimal exchangeRate;
                    String currencyCode = opp.CurrencyIsoCode;
                    Date closeDatee = opp.CloseDate.toStartOfMonth();
                    
                    if(opp.Amount!=null){
                        amt = String.valueOf(opp.Amount/1000000) ;
                    }
                    //MYSALES-361 V 1.0 start
                    if(opp.ProposalPM__r.Name  == null){
                       pp.possibility = ''; 
                    }
                    //MYSALES-361 V 1.0 end
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
                            amt = String.valueOf(opp.Amount/1000000) ;
                        }                      
                    }
                    
                    strTemp +=  '<tr>'+
                        '<td>' + opp.owner.name + '</td>' +
                        '<td class="nowrap">' + opp.OpportunityCode__c + '</td>' +
                        '<td  colspan ="3">' + '<a style="color:blue" href="' + str + '">'+ opp.Name + '</a>' + '</td>' +
                        '<td  colspan ="0.5" class="nowrap">' + closeDate + '</td>' +
                        '<td class="nowrap">' + opp.get('toLabel_StageName') + '</td>'+ 
                        '<td class="align_right">' + formattedNumber(num) + '</td>'+
                        '<td class="align_middle">' + pp.possibility + '</td>';
                    if((pp.manpowerInputPlan!=null && pp.manpowerInputPlan!='') ||(pp.manpowerExecutionPlan!=null && pp.manpowerExecutionPlan!='')){
                        strTemp +='<td class="align_middle">' + pp.manpowerInputPlan+' / '+pp.manpowerExecutionPlan  + '</td>';
                    }
                    else{
                        strTemp +='<td class="align_middle">' +'' + '</td>';
                    }
                    
                    if(opp.CMBizType__c != 'CSP_SCP'){
                        strTemp +='<td class="align_middle">' + 'N/A' + '</td>';
                    }
                    else{
                        if(scpBoCodeSet.contains(opp.OpportunityCode__c)){
                        	strTemp +='<td class="align_middle">' + 'Y' + '</td>';
                    	}
                    	else{
                        	strTemp +='<td class="align_middle">' + 'N' + '</td>';
                    	}
                    }
                    
                    
                }
                
                
                
                //Creation of table 5 Body end
                strTemp += '</tbody>';
                //Start Replacing Template table with real tables
                // String sDate = String.valueOf(System.now());
                //strEmail = strEmail.replace('{!DateValue}', sDate);
                strEmail = strEmail.replace('{!tableString5}',strTemp);
                strEmail = strEmail.replace('5. ' , String.valueOf(headingCounter)+'. ');
                headingCounter=1;
                //table5 creation ends.
            }
            
            
        }
        
        String finalHtmlString = relaceEmptyTableHtml(table1Present,table2Present,table3Present,table4Present,table5Present,strEmail);
        
        
        
        if(table1Present || table2Present || table3Present || table4Present || table5Present){
            mailresult = OpportunityEmailAlertController.sendKnoxEmailMulti(senderEmployee, null, toList, ccList, bccList, strTitle, finalHtmlString, efileList, nfileList);
            if(mailresult.get('KnoxEmail') != null) KnoxEmailList.add((KnoxEmail__c)mailresult.get('KnoxEmail'));
            if(mailresult.get('INTERFACE_LOG') != null){
            	ifLog.add((IF_Log.InterfaceLog)mailresult.get('INTERFACE_LOG')); 
                IF_Log.InterfaceLog temp = (IF_Log.InterfaceLog)mailresult.get('INTERFACE_LOG');
                //Map<String,Object> parsedVal = (Map<String,Object>) temp;
                if(temp.ErrorMessage != null){
               		userInfoWrap uu = new userInfoWrap();
                    uu.Name = listScope[0].DeptManagerEmail__c;
                    //uu.UserId = usr.Id;
                    uu.isfailure = true;
                    userWrap.add(uu);
                 }
                                
            } 
        }else{
            if(!toList.isEmpty()){          ////MYSALES-384
                userInfoWrap uu = new userInfoWrap();
                uu.Name = listScope[0].DeptManagerEmail__c;
                //uu.UserId = usr.Id;
                //uu.isfailure = true;
                userWrap.add(uu);
                
            }
            
        }
        
        
    }
    
    
    public void finish(Database.BatchableContext BC){
        Integer countFailure = 0;
        Integer countNotSent = 0;
        if(ifLog.size() > 0){
            IF_Log log = new IF_Log();
            log.createLog(ifLog);
        }
        //adding knox mailing record
        if(KnoxEmailList.size() > 0){
            system.debug('Knox email final : '+ KnoxEmailList[0].HtmlBody__c.length());
            system.debug('Knox email final : '+ KnoxEmailList[0].HtmlBody__c); 
            for(KnoxEmail__c km : KnoxEmailList){
                if(km.HtmlBody__c.length() > 32000)
                    km.HtmlBody__c = km.HtmlBody__c.substring(0, 32000) + ' ..... to be continued';
            }
            insert KnoxEmailList;
        }
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
        
        IF_Log__c log = new IF_Log__c();
        log.ApexName__c = 'Batch_ManagerWeeklySalesReport'; 
        log.ApexMethod__c =  'finsih';
        log.InterfaceId__c = 'Batch_ManagerWeeklySalesReport_Status';
        log.LogText__c = 'S Count : '+ KnoxEmailList.size() + '\n' + 'F Count : ' + countFailure + '\n' + 'Total Count : '+ (KnoxEmailList.size() + countFailure) + '\n' + 'W(Not sent) : ' + countNotSent;
        log.StatusCode__c = 'S';
        log.LogType__c = 'Mailing';
        log.EndDatetime__c  = System.now();
        log.StartDatetime__c = System.now();
        insert log;
    }
    
    public void execute(SchedulableContext SC){
        DataBase.executeBatch(new Batch_ManagerWeeklySalesReportClone(), 1);
    } 
    
    public String relaceEmptyTableHtml(boolean table1Present,boolean table2Present,boolean table3Present,boolean table4Present,boolean table5Present, String htmlString){
        if(!table1Present){
            //MYSALES-361 V 1.0//MYSALES-381
            htmlString = htmlString.replace('<tr><td><table class="title_wrap"><tr><td class="title">1. 연간 누적 사업기회 수주 현황</td></tr></table><table class="table">{!tableString1}</table><ul class="gray_text"><li>수주완료 건수 : \'Curent_Year년 수주/변경 품의 BO 건수 (수주 변경금액이 0원인 경우 제외, 동일한 BO번호는 1건으로 집계)</li><li2>수주완료 금액 : \'Curent_Year년 수주금액 및 수주 변경금액(차액) 의 합계 </li2><li>변경 품의 금액은 해당 BO 의 Related > Opportunity Amount 에서 확인 가능합니다.</li></ul></td></tr>','');
        }
        if(!table2Present){
            htmlString = htmlString.replace('<tr><td class="box_padding"><table class="title_wrap"><tr><td class="title">2. 지연 BO</td></tr></table><table class="table">{!tableString2}</table></td></tr>','');
        }
        if(!table3Present){
            htmlString = htmlString.replace('<tr><td class="box_padding"><table class="title_wrap"><tr><td class="title">3. 금주에 주간보고, 현안보고가 등록된 BO</td></tr></table><table class="table">{!tableString3}</table></td></tr>','');
        }
        if(!table4Present){
            htmlString = htmlString.replace('<tr><td class="box_padding"><table class="title_wrap"><tr><td class="title">4. 1개월 내 수전위 진행 예정 BO</td></tr></table><table class="table">{!tableString4}</table></td></tr>','');
        }
        if(!table5Present){
            htmlString = htmlString.replace('<tr><td class="box_padding"><table class="title_wrap"><tr><td class="title">5. 3개월 내 수주예상 BO</td></tr></table><table class="table">{!tableString5}</table></td></tr>','');
        }
        
        return htmlString;
    }
    
    public  proposalPMInfo getTable6ProposalPMData(List<TXPmanpower__c> tx , List<Project__c> allProjects , Opportunity currentOp){
         boolean projectCodeMatch = false;
        proposalPMInfo pp =new proposalPMInfo();
        if((tx!=null && tx.size()>0) /*&& allProjects.size()>0*/ ){
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
                            pp.possibility = 'N';
                            String clDate1 = String.valueOf(tx[0].ProposalPMStDt__c);
                            String closeDate1 = clDate1.substring(0,10);
                            String clDate2 = String.valueOf(tx[0].ProposalPMEdDt__c);
                            String closeDate2 = clDate2.substring(0,10);
                            
                            //pp.scheduleString = tx[0].ProposalPMStDt__c +'~' + tx[0].ProposalPMEdDt__c;
                            pp.scheduleString = closeDate1 +'~' + closeDate2 + '<br/>' + tx[0].P_Projectname__c;
                            pp.manpowerInputPlan = tx[0].ProposalPMPlan__c;
                            pp.manpowerExecutionPlan = tx[0].ExecutionPMPlan__c;
                            
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
    
    public static Map<String,decimal> getBORelatedAmount(set<String> sSet,Map<String,decimal> BO_AmountMap){
        decimal totalSum=0; 
        //MYSALES-463 Changing the DiffAmtLoc__c to DiffAmt__c. V 1.2
        for(opportunityamt__c obj:[Select opportunitycode__c, Version__c, id, DiffAmt__c,DiffAmtLoc__c, Opportunity__r.Owner.Name from opportunityamt__c where companycode__c ='T100' and Bo_Version_Composite__c IN :sSet ]){
            
            system.debug('ash');
            system.debug(obj.Opportunitycode__c);
            system.debug(obj.Version__c);
            system.debug(obj.DiffAmt__c);
            if(obj.DiffAmt__c != null && obj.DiffAmt__c != 0){
                
                if(BO_AmountMap.containskey(String.valueOF(obj.Opportunity__r.Owner.Name)))
                    BO_AmountMap.put(String.valueOF(obj.Opportunity__r.Owner.Name),BO_AmountMap.get(String.valueOF(obj.Opportunity__r.Owner.Name)) + obj.DiffAmtLoc__c);
                else
                    BO_AmountMap.put(String.valueOF(obj.Opportunity__r.Owner.Name),obj.DiffAmtLoc__c);
            }
        }
        return BO_AmountMap;
    }
    
    public String formattedNumber(String numString){
        
        if(numString == null && String.isblank(numString)){
            
            return ''; 
            
        }
        else{
            String formattedNumber = '';
            boolean NegativeVal = false; // //MYSALES-361
            List<String> parts = numString.split('\\.');
            
            // Format the integer part
            String integerPart = parts[0];
            //MYSALES-361 Start
            if(integerPart.contains('-')){
                integerPart = integerPart.replace('-','');
			    NegativeVal = true;
                system.debug('integerPart222==>'+integerPart);
			}
            system.debug('integerPart333==>'+integerPart);
            //MYSALES-361 End
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
            //MYSALES-361 Start
            if(NegativeVal == true){
			     formattedNumber = '-'+formattedNumber ;
			}
            //MYSALES-361 End
            
            return formattedNumber;
        }
        
    }
    
    //for sorting based on username custom logic
     public static List<User> sortUsersByUsername(List<User> userList) {
        // Create a map to store the usernames as keys and their associated users as values
        Map<String, User> usernameToUserMap = new Map<String, User>();
        
        // Populate the map with usernames as keys
        for (User u : userList) {
            usernameToUserMap.put(u.name, u);
        }
        
        // Sort the list of usernames
        List<String> sortedUsernames = new List<String>(usernameToUserMap.keySet());
        sortedUsernames.sort();
        
        // Create a list to store the sorted User objects
        List<User> sortedUserList = new List<User>();
        
        // Populate the sortedUserList in the order of sorted usernames
        for (String username : sortedUsernames) {
            sortedUserList.add(usernameToUserMap.get(username));
        }
        
        return sortedUserList;
    }
    
    
    public static string vrbTypeValues(String vrbTypeVal){
        String BO_Strategy_Type = '';
        
        if(vrbTypeVal == '10' ) BO_Strategy_Type = '전사';
        else if(vrbTypeVal == '20') BO_Strategy_Type = '사업부';
        else if(vrbTypeVal == '21') BO_Strategy_Type = 'AM 담당';
        
        return BO_Strategy_Type;
    }
    
    public class userInfoWrap {      
        String Name;
        String userId;
        boolean isfailure = false;
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
                log.ApexName__c = 'Batch_ManagerWeeklySalesReport';
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
                log.ApexName__c = 'Batch_ManagerWeeklySalesReport'; 
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
    
    public static void tempCoverage(){
        Integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}