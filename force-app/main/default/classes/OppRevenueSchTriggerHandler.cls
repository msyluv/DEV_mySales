/**
* @description       : 
* @author            : d.ashish@samsung.com
* @group             : 
* @last modified on  : 2024-02-22
* @last modified by  : anish.jain@partner.samsung.com
* Modifications Log 
* Ver   Date         Author                    Modification
* 1.0   2024-02-22   d.ashish@samsung.com      Initial Version
* 1.1   2024-03-20   anish.jain@partner.samsung.com    Added the functionality to show Yearly Revenue Schedule Records for only 'Solution' Division 솔루션사업부
**/
public class OppRevenueSchTriggerHandler {
    
    public static void afterUpdate(List<RevenueScheduleOpportunity__c> newlist, Map<id,RevenueScheduleOpportunity__c> newmap ,Map<id,RevenueScheduleOpportunity__c> oldmap){
        String node = System.Label.YearlyRevenueScheduleNote2;
        Set<String> oppYearlyRevSet = new Set<String>();
        Set<String> oppYearlyDelSet = new Set<String>(); //Added by Anish - v 1.1
        Map<String,set<integer>> months = new Map<String,set<integer>>();
        for(RevenueScheduleOpportunity__c Obj: newList){
            if(Obj.BO_Primary_Delivery_Division__c == '솔루션사업부'){ //Added by Anish - v 1.1
            oppYearlyRevSet.add(Obj.Parent__c);
            if(months.containskey(Obj.Parent__c+'-'+ Obj.ScheduleDate__c.year())){
                Set<integer> monthSet = months.get(Obj.Parent__c+'-'+ Obj.ScheduleDate__c.year());
                monthSet.add(Obj.ScheduleDate__c.month());
                months.put(Obj.Parent__c+'-'+ Obj.ScheduleDate__c.year(),monthSet);
            }else{
                Set<integer> monthSet =   new  Set<integer>(); 
                monthSet.add(Obj.ScheduleDate__c.month());
                months.put(Obj.Parent__c+'-'+ Obj.ScheduleDate__c.year(),monthSet);
            }
            }
            else{
            oppYearlyDelSet.add(Obj.Parent__c);  //Added by Anish - v 1.1
            }
        }
        Map<id,Opportunity> oppMap = new Map<id,Opportunity>([Select id, CompanyCode__c,RecordType.Name,cPrimarySalesDepartment__r.Node2__c from opportunity where id in: oppYearlyRevSet]);
        Map<String,Delivery_Probabiliy__c> delList = new Map<String,Delivery_Probabiliy__c>();
        for(Delivery_Probabiliy__c Obj: [Select id, name,Opportunity__c from Delivery_Probabiliy__c where Opportunity__c in: oppYearlyRevSet ]){
            delList.put(Obj.Opportunity__c,Obj);
        }
        //Start - Added by Anish - v 1.1
        List<Yearly_Revenue_Schedule__c> delYrs = new List<Yearly_Revenue_Schedule__c>();
        delYrs= [Select id, Name,ContractYear__c, Delivery_probability__c,ContractYearDate__c,CurrencyIsoCode, OpportunityId__c,M1__c,M2__c,M3__c,M4__c,M5__c,M6__c,M7__c,M8__c,M9__c,M10__c,M11__c,M12__c from Yearly_Revenue_Schedule__c  where OpportunityId__c in: oppYearlyDelSet and OpportunityId__r.RecordType.Name = 'HQ' AND OpportunityId__r.CompanyCode__c = 'T100' ]; // Added by Anish - v 1.1
        if(!delYrs.isEmpty()){
        database.delete(delYrs,false);
        }
        //End - Added by Anish - v 1.1
        
        List<Yearly_Revenue_Schedule__c> needToBeDeleteYRS = new List<Yearly_Revenue_Schedule__c>();
        Map<String,Yearly_Revenue_Schedule__c> oppYearly = new Map<String,Yearly_Revenue_Schedule__c>();
        for(Yearly_Revenue_Schedule__c yrs:[Select id, Name,ContractYear__c, Delivery_probability__c,ContractYearDate__c,CurrencyIsoCode, OpportunityId__c,M1__c,M2__c,M3__c,M4__c,M5__c,M6__c,M7__c,M8__c,M9__c,M10__c,M11__c,M12__c from Yearly_Revenue_Schedule__c  where OpportunityId__c in: oppYearlyRevSet and OpportunityId__r.RecordType.Name = 'HQ' AND OpportunityId__r.CompanyCode__c = 'T100' ]){
            if(months.containskey((yrs.OpportunityId__c+'-'+yrs.ContractYear__c))){
                oppYearly.put(yrs.OpportunityId__c+'-'+yrs.ContractYear__c,yrs);
           		setYearlyRevenueAmountblank(yrs,months.get(yrs.OpportunityId__c+'-'+yrs.ContractYear__c));
            }
            else{
                needToBeDeleteYRS.add(yrs);
            }
            system.debug('26::'+(yrs.OpportunityId__c+'-'+yrs.ContractYear__c));
        }
        if(!needToBeDeleteYRS.isEmpty())
        database.delete(needToBeDeleteYRS,false);
        for(RevenueScheduleOpportunity__c Obj: newList){
               Date firstJanschDate = Date.newInstance(Obj.ScheduleDate__c.year(),1,1);
        	
            if(oppMap != null && !oppMap.isEmpty() && oppMap.containskey(Obj.Parent__c)  && oppMap.get(Obj.Parent__c).RecordType.Name == 'HQ'  && oppMap.get(Obj.Parent__c).CompanyCode__c == 'T100' && oppMap.get(Obj.Parent__c).cPrimarySalesDepartment__r.Node2__c ==node){
                Yearly_Revenue_Schedule__c yr = new Yearly_Revenue_Schedule__c();
                if(oppYearly != null && !oppYearly.isEmpty() && oppYearly.containskey(Obj.Parent__c+'-'+ Obj.ScheduleDate__c.year())){
                    system.debug('39'+(Obj.Parent__c+'-'+ Obj.ScheduleDate__c.year()));
                    yr = oppYearly.get(Obj.Parent__c+'-'+ Obj.ScheduleDate__c.year());
                    yr.CurrencyIsoCode = Obj.CurrencyIsoCode;
                    
                }else{
                    system.debug('39'+(Obj.Parent__c+'-'+ Obj.ScheduleDate__c.year()));
                    yr = new Yearly_Revenue_Schedule__c(name = 'Yearly Revenue for '+ Obj.ScheduleDate__c.year(), ContractYearDate__c = firstJanschDate, OpportunityId__c =Obj.Parent__c);
                    if(delList != null && !delList.isEmpty() && delList.containskey(Obj.Parent__c)) yr.Delivery_probability__c =  delList.get(Obj.Parent__c).id;           	
                    setYearlyRevenueAmount(yr, Obj.ScheduleDate__c, Obj.Revenue__c);				
                    yr.CurrencyIsoCode = Obj.CurrencyIsoCode;
                    oppYearly.put(Obj.Parent__c+'-'+ Obj.ScheduleDate__c.year(),yr);
                    
                }
                setYearlyRevenueAmount(yr, Obj.ScheduleDate__c, Obj.Revenue__c);				
                //oppYearly.put(Obj.Parent__c+'-'+ Obj.ScheduleDate__c.year(),yr);
            }
        }
        system.debug('ashish oppYearly'+oppYearly);
        system.debug('ashish oppYearly'+oppYearly.size());
        if(oppYearly.size() >=3) system.debug('ashish oppYearly 3');
        
        if(!oppYearly.isEmpty()) database.upsert(oppYearly.values(),false);
    }
    
    //MYSALES-450			
    public static void setYearlyRevenueAmount(Yearly_Revenue_Schedule__c yrsObj, Date scheduleDate, decimal valueRevenue){
        Integer monthNo = scheduleDate.Month();
        system.debug('ashish monthNo'+monthNo);
        if(monthNo == 1) yrsObj.M1__c = valueRevenue;
        if(monthNo == 2) yrsObj.M2__c = valueRevenue;
        if(monthNo == 3) yrsObj.M3__c = valueRevenue;
        if(monthNo == 4) yrsObj.M4__c = valueRevenue;
        if(monthNo == 5) yrsObj.M5__c = valueRevenue;
        if(monthNo == 6) yrsObj.M6__c = valueRevenue;
        if(monthNo == 7) yrsObj.M7__c = valueRevenue;
        if(monthNo == 8) yrsObj.M8__c = valueRevenue;
        if(monthNo == 9) yrsObj.M9__c = valueRevenue;
        if(monthNo == 10) yrsObj.M10__c = valueRevenue;
        if(monthNo == 11) yrsObj.M11__c = valueRevenue;
        if(monthNo == 12) yrsObj.M12__c = valueRevenue;
    }
    
    //MYSALES-450			
    public static void setYearlyRevenueAmountblank(Yearly_Revenue_Schedule__c yrsObj, set<integer> months){
        for(integer i=1; i<=12; i++){
            if(i == 1 && !months.contains(i)) yrsObj.M1__c = null;
            if(i == 2 && !months.contains(i)) yrsObj.M2__c = null;
            if(i == 3 && !months.contains(i)) yrsObj.M3__c = null;
            if(i == 4 && !months.contains(i)) yrsObj.M4__c = null;
            if(i == 5 && !months.contains(i)) yrsObj.M5__c = null;
            if(i == 6 && !months.contains(i)) yrsObj.M6__c = null;
            if(i == 7 && !months.contains(i)) yrsObj.M7__c = null;
            if(i == 8 && !months.contains(i)) yrsObj.M8__c = null;
            if(i == 9 && !months.contains(i)) yrsObj.M9__c = null;
            if(i == 10 && !months.contains(i)) yrsObj.M10__c = null;
            if(i == 11 && !months.contains(i)) yrsObj.M11__c = null;
            if(i == 12 && !months.contains(i)) yrsObj.M12__c = null;
        }
    }
    
}