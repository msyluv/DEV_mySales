/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 07-24-2023
 * @last modified by  : aditya.r2@samsung.com
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   11-23-2020   woomg@dkbmc.com   Initial Version
 * 1.1   07-24-2023   aditya.r2@samsung.com    Added Period__c field for Opportunity Revenue Schedule object    MySales-262
 * 1.2   03-12-2024   d.ashish@samsung.com    Added 0 Amount Calculation logic for Opportunity Revenue Schedule object    MySales-446

**/
public With sharing class RevenueScheduleController {

    @AuraEnabled
    public static Decimal getSalesLeadAmount(String recordId){
        Decimal amount = 0.0;
        try {
            Sales_Lead__c sl = [SELECT Id, Amount__c FROM Sales_Lead__c WHERE Id = :recordId];
            amount = sl.Amount__c != null ? sl.Amount__c : 0.0;

            return amount;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Decimal getOpportunityAmount(String recordId){
        Decimal amount = 0.0;
        try {
            Opportunity op = [SELECT Id, Amount FROM Opportunity WHERE Id = :recordId];
            amount = op.Amount != null ? op.Amount : 0.0;

            return amount;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static list<RevenueScheduleSalesLead__c> getSalesLeadSchedules(String recordId){
        list<RevenueScheduleSalesLead__c> lrs = new list<RevenueScheduleSalesLead__c>();
        try {
            lrs = queryExistSalesLeadSchedules(recordId);
            if(lrs.isEmpty()){
                lrs = createNewSalesLeadSchedules(recordId);
            }

            return lrs;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static list<RevenueScheduleOpportunity__c> getOpportunitySchedules(String recordId){
        list<RevenueScheduleOpportunity__c> lrs = new list<RevenueScheduleOpportunity__c>();
        try {
            lrs = queryExistOpportunitySchedules(recordId);
            if(lrs.isEmpty()){
                lrs = createNewOpportunitySchedules(recordId);
            }

            return lrs;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static list<RevenueScheduleSalesLead__c> getNewSalesLeadSchedules(String recordId){
        list<RevenueScheduleSalesLead__c> lrs = new list<RevenueScheduleSalesLead__c>();
        try {
            lrs = queryExistSalesLeadSchedules(recordId);
            if(!lrs.isEmpty()){
                delete lrs;
            }
            lrs = createNewSalesLeadSchedules(recordId);

            return lrs;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static list<RevenueScheduleOpportunity__c> getNewOpportunitySchedules(String recordId){
        list<RevenueScheduleOpportunity__c> lrs = new list<RevenueScheduleOpportunity__c>();
        try {
            lrs = queryExistOpportunitySchedules(recordId);
            if(!lrs.isEmpty()){
                delete lrs;
            }
            lrs = createNewOpportunitySchedules(recordId);

            return lrs;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean saveSalesLeadSchedules(String recordId, list<RevenueScheduleSalesLead__c> records){
        try {
            system.debug(records);
            for(RevenueScheduleSalesLead__c rs : records){
                if(rs.Parent__c == null) rs.Parent__c = recordId;
            }
            upsert records;
            return true;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean saveOpportunitySchedules(String recordId, list<RevenueScheduleOpportunity__c> records){
        try {
            system.debug(records);
            for(RevenueScheduleOpportunity__c rs : records){
                if(rs.Parent__c == null) rs.Parent__c = recordId;
            }
            upsert records;
            return true;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static Boolean convertSalesLead2Oppty(String leadId, String opptyId){
        try {
            list<RevenueScheduleSalesLead__c> lrs = 
                [SELECT Id, Parent__c, Revenue__c, ScheduleDate__c, Description__c
                 FROM RevenueScheduleSalesLead__c
                 WHERE Parent__c = :leadId
                 ORDER BY ScheduleDate__c ASC];
            if(!lrs.isEmpty()){
                list<RevenueScheduleOpportunity__c> newset = new list<RevenueScheduleOpportunity__c>();
                for(RevenueScheduleSalesLead__c rs : lrs){
                    RevenueScheduleOpportunity__c nrs = new RevenueScheduleOpportunity__c();
                    nrs.Parent__c = opptyId;
                    nrs.Revenue__c = rs.Revenue__c;
                    nrs.ScheduleDate__c = rs.ScheduleDate__c;
                    if(rs.Description__c != null) nrs.Description__c = rs.Description__c;
                    
                    newset.add(nrs);
                }

                insert newset;
                return true;
            }
        } catch (Exception e){
            throw new CustomException(Label.REVENUE_SCHEDULE_CON_ERROR_CONVERT);
        }
        return true;
    }

    public static list<RevenueScheduleSalesLead__c> queryExistSalesLeadSchedules(String recordId){
        String query = '';
        query += 'SELECT Id, Parent__c, Revenue__c, ScheduleDate__c, Description__c ';
        query += 'FROM RevenueScheduleSalesLead__c ';
        query += 'WHERE Parent__c = \'' + recordId + '\' ';
        query += 'ORDER BY ScheduleDate__c ASC';

        return Database.query(query);
    }

    public static list<RevenueScheduleOpportunity__c> queryExistOpportunitySchedules(String recordId){
        String query = '';
        query += 'SELECT Id, Parent__c, Revenue__c, ScheduleDate__c, Description__c ';
        query += 'FROM RevenueScheduleOpportunity__c ';
        query += 'WHERE Parent__c = \'' + recordId + '\' ';
        query += 'ORDER BY ScheduleDate__c ASC';

        return Database.query(query);
    }

    public static list<RevenueScheduleSalesLead__c> createNewSalesLeadSchedules(String recordId){
        list<RevenueScheduleSalesLead__c> lrs = new list<RevenueScheduleSalesLead__c>();
        map<String, Object> baseObj = getSalesLead(recordId);

        String curr = (String) baseObj.get('currency');

        Date startDate = (Date) baseObj.get('start');
        Date endDate = (Date) baseObj.get('end');
        Date scheduleDate = startDate;
        Integer duration = startdate.monthsBetween(endDate);
        Integer numOfSchedule = duration + 1;

        Decimal amount = (Decimal) baseObj.get('amount');
        Decimal splitRev = Math.floor(amount / numOfSchedule);
        Decimal splitSum = splitRev * numOfSchedule;
        Decimal splitGap = amount - splitSum;

        for(Integer count = 0; count <= duration; count++){
            RevenueScheduleSalesLead__c rs = new RevenueScheduleSalesLead__c();
            rs.CurrencyIsoCode = curr;
            if(count < duration){
                rs.ScheduleDate__c = scheduleDate;
                rs.Revenue__c = splitRev;
                rs.Parent__c = recordId;
            } else {
                rs.ScheduleDate__c = endDate;
                rs.Revenue__c = splitRev + splitGap;
                rs.Parent__c = recordId;
            }
            lrs.add(rs);
            scheduleDate = scheduleDate.addMonths(1);
        }
        return lrs;
    }

    public static list<RevenueScheduleOpportunity__c> createNewOpportunitySchedules(String recordId){
        list<RevenueScheduleOpportunity__c> lrs = new list<RevenueScheduleOpportunity__c>();
        map<String, Object> baseObj = getOpportunity(recordId);

        String curr = (String) baseObj.get('currency');

        Date startDate = (Date) baseObj.get('start');
        Date endDate = (Date) baseObj.get('end');
        Date scheduleDate = startDate;
        Integer duration = startdate.monthsBetween(endDate);
        Integer numOfSchedule = duration + 1;

        Decimal amount = (Decimal) baseObj.get('amount');
        //Decimal splitRev = Math.floor(amount / numOfSchedule);    V1.1 - MySales-262
        Decimal splitRev = 0;
        Decimal splitSum = 0;
        Decimal splitGap = 0;
        if(amount > 0){//START--V1.2 MS-446 0 Amount Calculation logic
         splitRev = (amount / numOfSchedule).setscale(2);
         splitSum = splitRev * numOfSchedule;
         splitGap = amount - splitSum;
        }
        //--V1.2 END
        for(Integer count = 0; count <= duration; count++){
            RevenueScheduleOpportunity__c rs = new RevenueScheduleOpportunity__c();
        
            rs.CurrencyIsoCode = curr;
            if(count < duration){
                rs.ScheduleDate__c = scheduleDate;
                rs.Revenue__c = splitRev;
                rs.Parent__c = recordId;
                rs.Period__c = String.valueOf(numOfSchedule);    // V1.1 MySales-262
            } else {
                rs.ScheduleDate__c = endDate;
                rs.Revenue__c = splitRev + splitGap;
                rs.Parent__c = recordId;
                rs.Period__c = String.valueOf(numOfSchedule);    //V1.1 MySales-262
            
            }
            lrs.add(rs);
            
            scheduleDate = scheduleDate.addMonths(1);
        }
        return lrs;
    }
	public static map<String, Object> getSalesLead(String recordId){
        map<String, Object> baseObj = new map<String, Object>();
        Sales_Lead__c sl = [SELECT Id, CurrencyIsoCode, RevenueStartDate__c, RevenueEndDate__c, Amount__c 
                            FROM Sales_Lead__c WHERE Id = :recordId];

        if(sl.RevenueStartDate__c != null || sl.RevenueEndDate__c != null && sl.Amount__c != null){
            baseObj.put('start', sl.RevenueStartDate__c);
            baseObj.put('end', sl.RevenueEndDate__c);
            baseObj.put('amount', sl.Amount__c);
            baseObj.put('currency', sl.CurrencyIsoCode);
        } else {
            throw new CustomException(Label.REVENUE_SCHEDULE_CON_ERROR_INVALID);
        }

        return baseObj;
    }

    public static map<String, Object> getOpportunity(String recordId){
        map<String, Object> baseObj = new map<String, Object>();
        Opportunity op = [SELECT Id, CurrencyIsoCode, cRevenueStartDate__c, cRevenueEndDate__c, Amount 
                          FROM Opportunity WHERE Id = :recordId];
        system.debug('getOpportunity ->') ;
        system.debug(op);

        if(op.cRevenueStartDate__c != null || op.cRevenueEndDate__c != null && op.Amount != null){
            baseObj.put('start', op.cRevenueStartDate__c);
            baseObj.put('end', op.cRevenueEndDate__c);
            baseObj.put('amount', op.Amount);
            baseObj.put('currency', op.CurrencyIsoCode);
        } else {
            throw new CustomException(Label.REVENUE_SCHEDULE_CON_ERROR_INVALID);
        }

        return baseObj;
    }

    public class CustomException extends Exception {}
}