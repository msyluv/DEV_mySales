/**
* @description       : class for generating BO Emails BOReportCtrl 
* @author            : d.ashish@samsung.com
* @group             : 
* @last modified on  : 2023-06-21
* @last modified by  : d.ashish@samsung.com
* Modifications Log 
* Ver   Date         Author                   Modification
* 1.0   2023-06-21   d.ashish@samsung.com   Initial Version
**/
public class BOReportCtrl 
{
    public string orgName;
    public string getorgName() {
        return orgName;
    }
    public void SetorgName(String name) {
        this.orgName=name;
        runCode();
        system.debug('this.orgName'+this.orgName);
    }      
    public static String datetimeString{get;set;}
    public static string reportURL1{get;set;}
    public static string reportURL3{get;set;}
    public static Map<String, sobject> countMapReport1{get;set;}
    public static Map<String, sobject> countMapReport2{get;set;}
    public static map<string,sobject> eventCount{get;set;}
    public static List<reportA> reportAList{get;set;}
    public static List<reportB> reportBList{get;set;}
    public static List<reportC> reportCList{get;set;}
    public static integer totalBOcountThisMonth{get;set;}
    public static integer totalBOcountNextMonth{get;set;}
    public static integer totalBOcountNext1Month{get;set;}
    public static integer totalBOcountTotal{get;set;}
    public static decimal totalBOamtThisMonth{get;set;}
    public static decimal totalBOamtNextMonth{get;set;}
    public static decimal totalBOamtNext1Month{get;set;}
    public static decimal totalBOamtTotal{get;set;}
    public static Integer totalBOCountLastWeekThisMonth{get;set;}
    public static Integer totalBOCountThisWeekThisMonth{get;set;}
    public static Integer totalBOCountDiffThisMonth{get;set;}
    public static Integer totalBOCountLastWeekNextMonth{get;set;}
    public static Integer totalBOCountThisWeekNextMonth{get;set;}
    public static Integer totalBOCountDiffNextMonth{get;set;}
    public static Integer totalBOCountLastWeekNext1Month{get;set;}
    public static Integer totalBOCountThisWeekNext1Month{get;set;}
    public static Integer totalBOCountDiffNext1Month{get;set;}
    public static String thisMonthString{get;set;}
    public static    String nextMonthString{get;set;}
    public static   String next1MonthString{get;set;}
    
    public static  integer thisMonthyear {get;set;} 
    public static  integer nextMonthyear  {get;set;}
    public static  integer next1Monthyear {get;set;}
    public static CurrencyType currencyTypeList ;
    public void runCode(){
         currencyTypeList = new CurrencyType();
        currencyTypeList = [select id,IsoCode,ConversionRate from CurrencyType where isActive = true and IsoCode='KRW' Limit 1];
        system.debug('orgName::'+orgName);
        if(orgName == 'SDSAE'){
            reportURL1= System.Label.BO_Report_table_A_Url;
            reportURL3= system.Label.BO_Report_table_C_Url;
        }
        else if(orgName == 'SDSEG'){
            reportURL1= System.Label.BO_Report_table_A_UrlSDSEG;
            reportURL3= system.Label.BO_Report_table_C_UrlSDSEG;
        }
        else if(orgName == 'SDSI-CNL'){
            reportURL1= System.Label.BO_Report_table_A_UrlSDSI_CNL;
            reportURL3= system.Label.BO_Report_table_C_UrlSDSI_CNL;
        }
        else if(orgName == 'SDSI-NDL'){
            reportURL1= System.Label.BO_Report_table_A_UrlSDSI_NDL;
            reportURL3= system.Label.BO_Report_table_C_UrlSDSI_NDL;
        }
        else if(orgName == 'SDSTR'){
            reportURL1= System.Label.BO_Report_table_A_UrlSDSTR;
            reportURL3= system.Label.BO_Report_table_C_UrlSDSTR;
        }
        else if(orgName == 'SDSZA'){
            reportURL1= System.Label.BO_Report_table_A_UrlSDSZA;
            reportURL3= system.Label.BO_Report_table_C_UrlSDSZA;
        }
        totalBOcountThisMonth = 0;
        totalBOcountNextMonth = 0;
        totalBOcountNext1Month = 0;
        totalBOcountTotal = 0;
        totalBOamtThisMonth = 0;
        totalBOamtNextMonth = 0;
        totalBOamtNext1Month = 0;
        totalBOamtTotal = 0;
        totalBOCountLastWeekThisMonth  = 0;
        totalBOCountThisWeekThisMonth  = 0;
        totalBOCountDiffThisMonth  = 0;
        totalBOCountLastWeekNextMonth  = 0;
        totalBOCountThisWeekNextMonth  = 0;
        totalBOCountDiffNextMonth  = 0;
        totalBOCountLastWeekNext1Month  = 0;
        totalBOCountThisWeekNext1Month  = 0;
        totalBOCountDiffNext1Month  = 0;
        
        Boolean isConversion = true;
        
        //orgName = '로컬사업그룹(Cello Square사업)';
        Map<integer, String> monthMap = new map<integer,string>{1=>'Jan', 2=>'Feb', 3=>'Mar',4=>'Apr', 5=>'May',6=>'Jun',7=>'Jul',8=>'Aug',9=>'Sep',10=>'Oct',11=>'Nov',12=>'Dec'};
            Date todayDate = Date.Today();
        Datetime nowDateTime = system.now();
		datetimeString = nowDateTime.format('yyyy MMM dd EEE hh:mm a');

        Date weekstartdate = todayDate.toStartofWeek();
        for(integer i = 0;i<=6 ;i++){
            Datetime dt = (DateTime)weekstartdate;
            
            String dayOfWeek = dt.format('EEEE');
            
            if(dayOfWeek=='Thursday')
                break;
            else
                weekstartdate =weekstartdate.addDays(1);
        }
        integer thisMonth = weekstartdate.Month(); 
        integer nextMonth =  weekstartdate.addMonths(1).Month();
        integer next1Month =  weekstartdate.addMonths(2).Month();
        thisMonthString = monthMap.get(thisMonth);
        nextMonthString =  monthMap.get(nextMonth);
        next1MonthString =  monthMap.get(next1Month);
        
        thisMonthyear = weekstartdate.Year(); 
        nextMonthyear =  weekstartdate.addMonths(1).Year();
        next1Monthyear =  weekstartdate.addMonths(2).Year();
        String dynamicQuerytab1 = 'select count(id) cnt, sum(amount) amt, SalesOrganization__r.name ogName, Owner.id owId, calendar_month(closedate) cmonth, owner.lastname olName, owner.firstname oFname from opportunity where (closedate =THIS_MONTH Or closedate = NEXT_N_MONTHS:2)  and SalesOrganization__c != null and SalesOrganization__r.name =:orgName group by SalesOrganization__r.name, Owner.id, calendar_month(closedate), owner.lastname, owner.firstname';
        String dynamicQuerytab2 = 'select count(id) cnt,sum(amount) amt,SalesOrganization__r.name ogName,Owner.id owid,calendar_month(closedate) cmonth,owner.lastname olName,owner.firstname oFname from opportunity where  (closedate =THIS_MONTH Or closedate = NEXT_N_MONTHS:2) and  SalesOrganization__c != null and SalesOrganization__r.name =:orgName and (createdDate = THIS_WEEK) group by SalesOrganization__r.name, Owner.id,calendar_month(closedate),owner.lastname,owner.firstname';
        
        if(thisMonth < Date.today().Month()){
            dynamicQuerytab1 = 'select count(id) cnt, sum(amount) amt, SalesOrganization__r.name ogName, Owner.id owId, calendar_month(closedate) cmonth, owner.lastname olName, owner.firstname oFname from opportunity where (closedate =LAST_MONTH or  closedate =THIS_MONTH Or closedate = NEXT_N_MONTHS:1)  and SalesOrganization__c != null and SalesOrganization__r.name =:orgName group by SalesOrganization__r.name, Owner.id, calendar_month(closedate), owner.lastname, owner.firstname';
            dynamicQuerytab2 = 'select count(id) cnt,sum(amount) amt,SalesOrganization__r.name ogName,Owner.id owid,calendar_month(closedate) cmonth,owner.lastname olName,owner.firstname oFname from opportunity where  (closedate =LAST_MONTH or  closedate =THIS_MONTH Or closedate = NEXT_N_MONTHS:1) and  SalesOrganization__c != null and SalesOrganization__r.name =:orgName and (createdDate = THIS_WEEK) group by SalesOrganization__r.name, Owner.id,calendar_month(closedate),owner.lastname,owner.firstname';
        }
        else if(thisMonth > Date.today().Month()){
            dynamicQuerytab1 = 'select count(id) cnt, sum(amount) amt, SalesOrganization__r.name ogName, Owner.id owId, calendar_month(closedate) cmonth, owner.lastname olName, owner.firstname oFname from opportunity where (closedate = NEXT_N_MONTHS:3)  and SalesOrganization__c != null and SalesOrganization__r.name =:orgName group by SalesOrganization__r.name, Owner.id, calendar_month(closedate), owner.lastname, owner.firstname';
            dynamicQuerytab2 = 'select count(id) cnt,sum(amount) amt,SalesOrganization__r.name ogName,Owner.id owid,calendar_month(closedate) cmonth,owner.lastname olName,owner.firstname oFname from opportunity where  (closedate = NEXT_N_MONTHS:3) and  SalesOrganization__c != null and SalesOrganization__r.name =:orgName and (createdDate = THIS_WEEK) group by SalesOrganization__r.name, Owner.id,calendar_month(closedate),owner.lastname,owner.firstname';
        }
        
        system.debug('next1Monthyear'+next1Monthyear);
        List<Sobject> sobjectList = database.query(dynamicQuerytab1);//[select count(id) cnt, sum(amount) amt, SalesOrganization__r.name ogName, Owner.id owId, calendar_month(closedate) cmonth, owner.lastname olName, owner.firstname oFname from opportunity where (closedate =THIS_MONTH Or closedate = NEXT_N_MONTHS:2)  and SalesOrganization__c != null and SalesOrganization__r.name =:orgName group by SalesOrganization__r.name, Owner.id, calendar_month(closedate), owner.lastname, owner.firstname];
        countMapReport1 = new Map<String, sobject>();
        countMapReport2 = new Map<String, sobject>();
        for(Sobject obj: sobjectList){
            countMapReport1.put(obj.get('ogName')+'-'+obj.get('owid')+'-'+obj.get('cMonth'),obj);
        }
        for(Sobject obj: database.query(dynamicQuerytab2)){//[select count(id) cnt,sum(amount) amt,SalesOrganization__r.name ogName,Owner.id owid,calendar_month(closedate) cmonth,owner.lastname olName,owner.firstname oFname from opportunity where  (closedate =THIS_MONTH Or closedate = NEXT_N_MONTHS:2) and  SalesOrganization__c != null and SalesOrganization__r.name =:orgName and (createdDate = THIS_WEEK) group by SalesOrganization__r.name, Owner.id,calendar_month(closedate),owner.lastname,owner.firstname]){
            countMapReport2.put(obj.get('ogName')+'-'+obj.get('owid')+'-'+obj.get('cMonth'),obj);
        }
        eventCount = new map<string,sobject>();
        set<STring> cIds = new set<String>();
        //for(Sobject obj: [select count(id) cnt,ownerid   from event where what.Type = 'Opportunity' and (createddate = THIS_WEEK) group by ownerid]){
        for(Sobject obj: [select count(id) cnt, ownerid, owner.Name owname from event where what.Type = 'Opportunity' AND (createddate = THIS_WEEK)
                          AND  WhatId in (
                              select Id
                              from Opportunity
                              where SalesOrganization__c != null and SalesOrganization__r.name =:  orgName
                          )
                          group by ownerid,owner.Name]){
                              eventCount.put(obj.get('ownerid')+'-THISWEEK',obj);   
                              cIds.add((String)obj.get('ownerid'));
                          }
        //for(Sobject obj: [select count(id) cnt,ownerid  from event where what.Type = 'Opportunity' AND (createddate = LAST_WEEK) group by ownerid]){
        for(Sobject obj: [select count(id) cnt, ownerid, owner.Name owname from event where what.Type = 'Opportunity' AND (createddate = LAST_WEEK)
                          AND  WhatId in (
                              select Id
                              from Opportunity
                              where SalesOrganization__c != null and SalesOrganization__r.name =:  orgName
                          )
                          group by ownerid,owner.Name]){
                              eventCount.put(obj.get('ownerid')+'-LASTWEEK',obj);                      
                              cIds.add((String)obj.get('ownerid'));
                          }
        
        reportAList = new List<reportA>();
        reportBList = new List<reportB>();
        reportCList = new List<reportC>();
        system.debug('countMapReport1'+countMapReport1);
        set<String> avoidRecordRepitition = new set<String>();
        for(Sobject obj: sobjectList){
            if(!avoidRecordRepitition.contains(String.valueOf(obj.get('Owid')))){
                //Report A Setup
                reportA aObj = new reportA();
                aObj.branchName = String.valueOf(obj.get('ogName'));
                String repNamea = '';
                if(obj.get('oFName') != null) repNamea = String.valueOf(obj.get('oFName'));
                if(obj.get('oLName') != null) repNamea +=' '+ String.valueOf(obj.get('oLName'));
                
                aObj.repName = repNamea;
                
                if(countMapReport1.get(obj.get('ogName')+'-'+obj.get('Owid')+'-'+thisMonth) != null)
                    aObj.BOCountThisMonth = Integer.valueOf( countMapReport1.get(obj.get('ogName')+'-'+obj.get('Owid')+'-'+thisMonth).get('cnt'));
                else
                    aObj.BOCountThisMonth = 0;
                if(countMapReport1.get(obj.get('ogName')+'-'+obj.get('Owid')+'-'+thisMonth) != null){
                    decimal d =  (Decimal)( countMapReport1.get(obj.get('ogName')+'-'+obj.get('Owid')+'-'+thisMonth).get('amt'));
                    aObj.BOAmountThisMonth = (isConversion ? convertKRW(d)/ 100000000: d);
                }
                else aObj.BOAmountThisMonth = 0;
                if(countMapReport1.get(obj.get('ogName')+'-'+obj.get('Owid')+'-'+nextMonth) != null)
                    aObj.BOCountNextMonth = Integer.valueOf( countMapReport1.get(obj.get('ogName')+'-'+obj.get('Owid')+'-'+nextMonth).get('cnt'));
                else
                    aObj.BOCountNextMonth = 0;
                
                if(countMapReport1.get(obj.get('ogName')+'-'+obj.get('Owid')+'-'+nextMonth) != null){
                    decimal d =  (Decimal) ( countMapReport1.get(obj.get('ogName')+'-'+obj.get('Owid')+'-'+nextMonth).get('amt'));
                    
                    aObj.BOAmountNextMonth = (isConversion ? convertKRW(d)/ 100000000: d);
                    
                }
                else aObj.BOAmountNextMonth = 0;
                
                if(countMapReport1.get(obj.get('ogName')+'-'+obj.get('Owid')+'-'+next1Month) != null)
                    aObj.BOCountNext1Month = Integer.valueOf( countMapReport1.get(obj.get('ogName')+'-'+obj.get('Owid')+'-'+next1Month).get('cnt'));
                else aObj.BOCountNext1Month =0;
                if(countMapReport1.get(obj.get('ogName')+'-'+obj.get('Owid')+'-'+next1Month) != null){
                    decimal d = (Decimal) ( countMapReport1.get(obj.get('ogName')+'-'+obj.get('Owid')+'-'+next1Month).get('amt'));
                    
                    aObj.BOAmountNext1Month = (isConversion ? convertKRW(d)/ 100000000: d);
                }
                else aObj.BOAmountNext1Month = 0;
                aObj.BOCountTotal = aObj.BOCountThisMonth + aObj.BOCountNextMonth + aObj.BOCountNext1Month;
                aObj.BOAmountTotal = aObj.BOAmountThisMonth + aObj.BOAmountNextMonth + aObj.BOAmountNext1Month;
                reportAList.add(aObj);
                totalBOcountThisMonth += aObj.BOCountThisMonth;
                totalBOcountNextMonth += aObj.BOCountNextMonth;
                totalBOcountNext1Month += aObj.BOCountNext1Month;
                totalBOcountTotal += aObj.BOCountTotal;
                totalBOamtThisMonth += aObj.BOAmountThisMonth;
                totalBOamtNextMonth += aObj.BOAmountNextMonth;
                totalBOamtNext1Month += aObj.BOAmountNext1Month;
                totalBOamtTotal += aObj.BOAmountTotal;
                
                
                //ReportB Setup
                reportB bObj = new reportB();
                bObj.branchName = String.valueOf(obj.get('ogName'));
                String repName = '';
                if(obj.get('oFName') != null) repName = string.valueOf(obj.get('oFName'));
                if(obj.get('oLName') != null) repName +=' '+ String.valueOf(obj.get('oLName'));
                
                bObj.repName = repName;
                system.debug('test::'+(obj.get('ogName')+'-'+obj.get('Owid')+'-'+thisMonth));
                if(countMapReport1.get(obj.get('ogName')+'-'+obj.get('Owid')+'-'+thisMonth) != null)
                    bObj.BOCountThisWeekThisMonth = Integer.valueOf( countMapReport1.get(obj.get('ogName')+'-'+obj.get('Owid')+'-'+thisMonth).get('cnt'));
                else
                    bObj.BOCountThisWeekThisMonth = 0;
                
                if(countMapReport2.get(obj.get('ogName')+'-'+obj.get('Owid')+'-'+thisMonth) != null)
                    bObj.BOCountDiffThisMonth = Integer.valueOf( countMapReport2.get(obj.get('ogName')+'-'+obj.get('Owid')+'-'+thisMonth).get('cnt'));
                else
                    bObj.BOCountDiffThisMonth = 0;
                
                bObj.BOCountLastWeekThisMonth = Math.abs(bObj.BOCountThisWeekThisMonth - bObj.BOCountDiffThisMonth);
                
                if(countMapReport1.get(obj.get('ogName')+'-'+obj.get('Owid')+'-'+NextMonth) != null)
                    bObj.BOCountThisWeekNextMonth = Integer.valueOf( countMapReport1.get(obj.get('ogName')+'-'+obj.get('Owid')+'-'+NextMonth).get('cnt'));
                else
                    bObj.BOCountThisWeekNextMonth = 0;
                
                if(countMapReport2.get(obj.get('ogName')+'-'+obj.get('Owid')+'-'+NextMonth) != null)
                    bObj.BOCountDiffNextMonth = Integer.valueOf( countMapReport2.get(obj.get('ogName')+'-'+obj.get('Owid')+'-'+NextMonth).get('cnt'));
                else
                    bObj.BOCountDiffNextMonth = 0;
                
                bObj.BOCountLastWeekNextMonth = Math.abs(bObj.BOCountThisWeekNextMonth - bObj.BOCountDiffNextMonth);
                
                if(countMapReport1.get(obj.get('ogName')+'-'+obj.get('Owid')+'-'+Next1Month) != null)
                    bObj.BOCountThisWeekNext1Month = Integer.valueOf( countMapReport1.get(obj.get('ogName')+'-'+obj.get('Owid')+'-'+Next1Month).get('cnt'));
                else
                    bObj.BOCountThisWeekNext1Month = 0;
                
                if(countMapReport2.get(obj.get('ogName')+'-'+obj.get('Owid')+'-'+Next1Month) != null)
                    bObj.BOCountDiffNext1Month = Integer.valueOf( countMapReport2.get(obj.get('ogName')+'-'+obj.get('Owid')+'-'+Next1Month).get('cnt'));
                else
                    bObj.BOCountDiffNext1Month = 0;
                
                bObj.BOCountLastWeekNext1Month = Math.abs(bObj.BOCountThisWeekNext1Month - bObj.BOCountDiffNext1Month);
                totalBOCountLastWeekThisMonth  += bObj.BOCountLastWeekThisMonth;
                totalBOCountThisWeekThisMonth  += bObj.BOCountThisWeekThisMonth;
                totalBOCountDiffThisMonth  += bObj.BOCountDiffThisMonth;
                totalBOCountLastWeekNextMonth  += bObj.BOCountLastWeekNextMonth ;
                totalBOCountThisWeekNextMonth  += bObj.BOCountThisWeekNextMonth;
                totalBOCountDiffNextMonth  += bObj.BOCountDiffNextMonth;
                totalBOCountLastWeekNext1Month  += bObj.BOCountLastWeekNext1Month;
                totalBOCountThisWeekNext1Month  += bObj.BOCountThisWeekNext1Month;
                totalBOCountDiffNext1Month  += bObj.BOCountDiffNext1Month;
                
                
                reportBList.add(bObj);
                avoidRecordRepitition.add(String.valueOf(obj.get('Owid')));
            }
        }
        
        for(String sOwnerId: cIds){
            //Setup Report C
            reportC cobj = new reportC();
            if(eventCount.get(sOwnerId+'-LASTWEEK') != null){
                cobj.eventCountLastWeek = Integer.valueOf( eventCount.get(sOwnerId+'-LASTWEEK').get('cnt'));
                cobj.repName = String.valueOf(eventCount.get(sOwnerId+'-LASTWEEK').get('owname'));
            }
            else cobj.eventCountLastWeek = 0;
            if(eventCount.get(sOwnerId+'-THISWEEK') != null){
                cobj.eventCountThisWeek = Integer.valueOf(eventCount.get(sOwnerId+'-THISWEEK').get('cnt'));
                cobj.repName = String.valueOf(eventCount.get(sOwnerId+'-THISWEEK').get('owname'));
            }
            else cobj.eventCountThisWeek = 0;
            reportCList.add(cObj);
            
        }
        
    }
    public BOReportCtrl(){
        //  runCode();
    }
    public class reportA{
        public String branchName{get;set;}
        public String repName{get;set;}
        public Integer BOCountThisMonth{get;set;}
        public Decimal BOAmountThisMonth{get;set;}
        public Integer BOCountNextMonth{get;set;}
        public Decimal BOAmountNextMonth{get;set;}
        public Integer BOCountNext1Month{get;set;}
        public Decimal BOAmountNext1Month{get;set;}
        public Integer BOCountTotal{get;set;}
        public Decimal BOAmountTotal{get;set;}
        
        
    }
    public class reportB{
        public String branchName{get;set;}
        public String repName{get;set;}
        public Integer BOCountLastWeekThisMonth{get;set;}
        public Integer BOCountThisWeekThisMonth{get;set;}
        public Integer BOCountDiffThisMonth{get;set;}
        public Integer BOCountLastWeekNextMonth{get;set;}
        public Integer BOCountThisWeekNextMonth{get;set;}
        public Integer BOCountDiffNextMonth{get;set;}
        public Integer BOCountLastWeekNext1Month{get;set;}
        public Integer BOCountThisWeekNext1Month{get;set;}
        public Integer BOCountDiffNext1Month{get;set;}
        
    }
    public class reportC{
        public String branchName{get;set;}
        public String repName{get;set;}
        public Integer eventCountLastWeek{get;set;}
        public Integer eventCountThisWeek{get;set;}
        
    }
    public static Decimal convertKRW(decimal d){
        //List<CurrencyType> currencyTypeList = [select id,IsoCode,ConversionRate from CurrencyType where isActive = true and IsoCode='KRW' Limit 1] ;
        decimal Amount_Converted_bro = d * currencyTypeList.ConversionRate;//1306.10;
        system.debug('ashish currencyTypeList'+currencyTypeList);
        return Amount_Converted_bro;
    }
}