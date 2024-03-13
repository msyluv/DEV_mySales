/**
 * @description       : 
 * @author            : ukhyeon.lee@samsung.com
 * @group             : 
 * @last modified on  : 05-24-2022
 * @last modified by  : ukhyeon.lee@samsung.com
**/
global without sharing class OpportunitySearchExcel {
    public List<List<returnObject>> objList {get;set;}
	public String xmlheader {get;set;}
    public String endfile{get;set;}
    private ApexPages.StandardController controller;


    public static Map<String,String> stageMap;
    public static Map<String,String> statusMap;
    public static Map<String,String> bizTypeMap;

    static{
        stageMap = new Map<String,String>();
        
        Schema.DescribeFieldResult stageFieldResult = Opportunity.StageName.getDescribe();
        List<Schema.PicklistEntry> stageList = stageFieldResult.getPicklistValues();
        for (Schema.PicklistEntry stage: stageList) {
            stageMap.put(stage.getValue(), stage.getLabel());
        }

        statusMap = new Map<String,String>();
        
        Schema.DescribeFieldResult statusFieldResult = Opportunity.OpportunityStatus__c.getDescribe();
        List<Schema.PicklistEntry> statusList = statusFieldResult.getPicklistValues();
        for (Schema.PicklistEntry status: statusList) {
            statusMap.put(status.getValue(), status.getLabel());
        }

        bizTypeMap = new Map<String,String>();

        Schema.DescribeFieldResult bizTypeFieldResult = Opportunity.BusinessType__c.getDescribe();
        List<Schema.PicklistEntry> bizTypeList = bizTypeFieldResult.getPicklistValues();
        for (Schema.PicklistEntry bizType: bizTypeList) {
            bizTypeMap.put(bizType.getValue(), bizType.getLabel());
        }
    }


    public OpportunitySearchExcel(ApexPages.StandardController controller){
        this.controller = controller;
		xmlheader ='<?xml version="1.0"?><?mso-application progid="Excel.Sheet"?>';
        endfile = '</Workbook>';

       
        //selectedValue sv = (selectedValue)JSON.deserialize(ApexPages.currentPage().getParameters().get('searchKeywords'), selectedValue.class);
        selectedValue sv = new selectedValue();
        
        String str_SELECT = '';
        str_SELECT += 'SELECT Id, Name, OpportunityCode__c, OpportunityStatus__c, StageName, CompanyCode__c, AccountId, Account.Name, Account.AccountNumber, ';
        str_SELECT += 'cOriginAcc__c, cOriginAcc__r.Name, cOriginAcc__r.AccountNumber, BusinessLevel__c, OwnerId, Owner.Name, SalesDivision__c, ';
        str_SELECT += 'SalesDepartment__c, SalesDepartment__r.Name, cPrimaryDeliveryDivision__c, cPrimarySalesDepartment__c, cPrimarySalesDepartment__r.Name, ';
        str_SELECT += 'Collaboration__c, GroupInternal__c, KoreaDomestic__c, BusinessType__c, DealBreak__c, CloseDate, FirstCloseDate__c, RecordTypeId, RecordType.Name ';
        str_SELECT += 'FROM Opportunity';
        /*
        Set<String> opptyIdSet = getOpptyIdSet(sv.Service, sv.Solution);
        
        String str_WHERE = formatWhereClause(sv);
        if(opptyIdSet.size() > 0){
            str_WHERE += ' AND Id IN: opptyIdSet';
        }
        */
        objList = new List<List<returnObject>>();

        Integer opptyCount = database.countQuery('select count() from Opportunity');
        List<Opportunity> opptyList = Database.query(str_SELECT);
        //Integer opptyCount = database.countQuery('select count() from Opportunity' + str_WHERE);
        //List<Opportunity> opptyList = Database.query(str_SELECT + str_WHERE);

        List<Company__c> companyList = [SELECT Name, CompanyCode__c FROM Company__c];
        List<returnObject> rtnObjList = new List<returnObject>();
        for(Opportunity opp : opptyList){
            returnObject rtnObj = new returnObject();
            rtnObj.OpptyCode = opp.OpportunityCode__c;
            rtnObj.Id = opp.Id;
            rtnObj.Name = opp.Name;
            rtnObj.Status = statusMap.get(opp.OpportunityStatus__c);
            rtnObj.Stage = stageMap.get(opp.StageName);
            rtnObj.CompCode = opp.CompanyCode__c;
            for(Company__c comp : companyList){
                if(opp.CompanyCode__c == comp.CompanyCode__c){
                    rtnObj.CompName = comp.Name;
                }
            }
            rtnObj.AccNumber = opp.Account.AccountNumber;
            rtnObj.AccName = opp.Account.Name;
            rtnObj.OriginAccNum = opp.cOriginAcc__r.AccountNumber;
            rtnObj.OriginAcctName = opp.cOriginAcc__r.Name;
            rtnObj.BizLevel = opp.BusinessLevel__c;
            rtnObj.OwnerName = opp.Owner.Name;
            rtnObj.SalesDiv = opp.SalesDivision__c;
            rtnObj.SalesDept = opp.SalesDepartment__r.Name;
            rtnObj.DeliveryDiv = opp.cPrimaryDeliveryDivision__c;
            rtnObj.DeliveryDept = opp.cPrimarySalesDepartment__r.Name;
            rtnObj.Collaboration = opp.Collaboration__c;
            rtnObj.GroupInternal = opp.GroupInternal__c;
            rtnObj.KoreaDomestic = opp.KoreaDomestic__c;
            rtnObj.BizType = bizTypeMap.get(opp.BusinessType__c);
            rtnObj.DealBreak = opp.DealBreak__c;
            String formattedDateStr = DateTime.newInstance(opp.CloseDate.year(), opp.CloseDate.month(), opp.CloseDate.day()).format(Utils.getUserDateFormat());
            rtnObj.CloseDate = formattedDateStr;
            if(opp.FirstCloseDate__c != null){
                String formattedDateStr_first = DateTime.newInstance(opp.FirstCloseDate__c.year(), opp.FirstCloseDate__c.month(), opp.FirstCloseDate__c.day()).format(Utils.getUserDateFormat());
                rtnObj.FirstCloseDate = formattedDateStr_first;
            }else{
                rtnObj.FirstCloseDate = '';
            }
            rtnObjList.add(rtnObj);
        } 
        objList.add(rtnObjList);
    }

    private static Set<String> getOpptyIdSet(String serviceId, String solutionId){
        Set<String> OpptyIdSet = new Set<String>();
        if(serviceId != ''){
            List<Service__c> svcList = [SELECT Id, Name, Service__c, Opportunity__c FROM Service__c WHERE Service__c =: serviceId AND DeletionFlag__c = false];
            if(svcList.size() > 0){
                for(Service__c svc : svcList){
                    OpptyIdSet.add(svc.Opportunity__c);
                }
            }

            if(solutionId != ''){
                List<Solution__c> solList = [SELECT Id, Name, Solution__c, Opportunity__c FROM Solution__c WHERE Opportunity__c =: OpptyIdSet AND Solution__c =: solutionId AND DeletionFlag__c = false];
                if(solList.size() > 0){
                    OpptyIdSet = new Set<String>();
                    for(Solution__c sol : solList){
                        OpptyIdSet.add(sol.Opportunity__c);
                    }
                }
            }
        }

        return OpptyIdSet;
    }

    private static String formatWhereClause(selectedValue sv){
        String str_WHERE = ' WHERE (Name LIKE \'%' + sv.BOName + '%\')';
        str_WHERE += ' AND (OpportunityCode__c LIKE \'%' + sv.OpptyCode + '%\')';

        if(sv.StartDate != null && sv.EndDate != null){
            String srt_StartYear = String.valueOf((sv.StartDate).year());
            String srt_StartMonth = ((sv.StartDate).month()) < 10 ? '0' + String.valueOf((sv.StartDate).month()) : String.valueOf((sv.StartDate).month());
            String srt_StartDay = ((sv.StartDate).day()) < 10 ? '0' + String.valueOf((sv.StartDate).day()) : String.valueOf((sv.StartDate).day());
            String str_StartDate = srt_StartYear + '-' + srt_StartMonth + '-' + srt_StartDay;

            String srt_EndYear = String.valueOf((sv.EndDate).year());
            String srt_EndMonth = ((sv.EndDate).month()) < 10 ? '0' + String.valueOf((sv.EndDate).month()) : String.valueOf((sv.EndDate).month());
            String srt_EndDay = ((sv.EndDate).day()) < 10 ? '0' + String.valueOf((sv.EndDate).day()) : String.valueOf((sv.EndDate).day());
            String str_EndDate = srt_EndYear + '-' + srt_EndMonth + '-' + srt_EndDay;

            str_WHERE += ' AND CloseDate >= ' + str_StartDate;
            str_WHERE += ' AND CloseDate <= ' + str_EndDate;
        }

        if(sv.FirstStartDate != null && sv.FirstEndDate != null){
            String srt_FirstStartYear = String.valueOf((sv.FirstStartDate).year());
            String srt_FirstStartMonth = ((sv.FirstStartDate).month()) < 10 ? '0' + String.valueOf((sv.FirstStartDate).month()) : String.valueOf((sv.FirstStartDate).month());
            String srt_FirstStartDay = ((sv.FirstStartDate).day()) < 10 ? '0' + String.valueOf((sv.FirstStartDate).day()) : String.valueOf((sv.FirstStartDate).day());
            String str_FirstStartDate = srt_FirstStartYear + '-' + srt_FirstStartMonth + '-' + srt_FirstStartDay;

            String srt_FirstEndYear = String.valueOf((sv.FirstEndDate).year());
            String srt_FirstEndMonth = ((sv.FirstEndDate).month()) < 10 ? '0' + String.valueOf((sv.FirstEndDate).month()) : String.valueOf((sv.FirstEndDate).month());
            String srt_FirstEndDay = ((sv.FirstEndDate).day()) < 10 ? '0' + String.valueOf((sv.FirstEndDate).day()) : String.valueOf((sv.FirstEndDate).day());
            String str_FirstEndDate = srt_FirstEndYear + '-' + srt_FirstEndMonth + '-' + srt_FirstEndDay;

            str_WHERE += ' AND FirstCloseDate__c >= ' + str_FirstStartDate;
            str_WHERE += ' AND FirstCloseDate__c <= ' + str_FirstEndDate;
        }

        if(sv.Collaboration == 'true') str_WHERE += ' AND Collaboration__c = true';
        else if(sv.Collaboration == 'false') str_WHERE += ' AND Collaboration__c = false';
        if(sv.GroupInternal == 'true') str_WHERE += ' AND GroupInternal__c = true';
        else if(sv.GroupInternal == 'false') str_WHERE += ' AND GroupInternal__c = false';
        if(sv.Status != '') str_WHERE += ' AND OpportunityStatus__c = \'' + sv.Status + '\'';
        if(sv.RecordType != '') str_WHERE += ' AND RecordTypeId = \'' + sv.RecordType + '\'';

        if((sv.Company).Id != null){
            String companyCode = [SELECT Id, Name, CompanyCode__c FROM Company__c WHERE Id =: (sv.Company).Id].CompanyCode__c;
            str_WHERE += ' AND CompanyCode__c = \'' + companyCode + '\'';
        }
        if((sv.Account).Id != null) str_WHERE += ' AND AccountId = \'' + (sv.Account).Id + '\'';
        if((sv.OriginAccount).Id != null) str_WHERE += ' AND cOriginAcc__c = \'' + (sv.OriginAccount).Id + '\'';
        if((sv.Owner).Id != null) str_WHERE += ' AND OwnerId = \'' + (sv.Owner).Id + '\'';
        if((sv.SalesDept).Id != null) str_WHERE += ' AND SalesDepartment__c = \'' + (sv.SalesDept).Id + '\'';
        if((sv.PrimarySalesDept).Id != null) str_WHERE += ' AND cPrimarySalesDepartment__c = \'' + (sv.PrimarySalesDept).Id + '\'';

        if(sv.Service != ''){
            Set<String> OpptyIdSet = new Set<String>();
            List<Service__c> svcList = [SELECT Id, Name, Service__c, Opportunity__c FROM Service__c WHERE Service__c =: sv.Service AND DeletionFlag__c = false];
            if(svcList.size() > 0){
                for(Service__c svc : svcList){
                    OpptyIdSet.add(svc.Opportunity__c);
                }
            }

            if(sv.Solution != ''){
                List<Solution__c> solList = [SELECT Id, Name, Solution__c, Opportunity__c FROM Solution__c WHERE Opportunity__c =: OpptyIdSet AND Solution__c =: sv.Solution AND DeletionFlag__c = false];
                if(solList.size() > 0){
                    OpptyIdSet = new Set<String>();
                    for(Solution__c sol : solList){
                        OpptyIdSet.add(sol.Opportunity__c);
                    }
                }
            }
            // if(OpptyIdSet.size() > 0){
                //str_WHERE += ' AND Id IN: OpptyIdSet';
            // }
        }
        return str_WHERE;
    }

    global class selectedValue {
        @AuraEnabled
        global customObject Company {get; set;}
        @AuraEnabled
        global customObject Account {get; set;}
        @AuraEnabled
        global customObject OriginAccount {get; set;}
        @AuraEnabled
        global String BOName {get; set;}
        @AuraEnabled
        global String Collaboration {get; set;}
        @AuraEnabled
        global String GroupInternal {get; set;}
        @AuraEnabled
        global String Service {get; set;}
        @AuraEnabled
        global String Solution {get; set;}
        @AuraEnabled
        global String Status {get; set;}
        @AuraEnabled
        global Date StartDate {get; set;}
        @AuraEnabled
        global Date EndDate {get; set;}
        @AuraEnabled
        global customObject Owner {get; set;}
        @AuraEnabled
        global String OpptyCode {get; set;}
        @AuraEnabled
        global customObject SalesDept {get; set;}
        @AuraEnabled
        global customObject PrimarySalesDept {get; set;}
        @AuraEnabled
        global String RecordType {get; set;}
        @AuraEnabled
        global Date FirstStartDate {get; set;}
        @AuraEnabled
        global Date FirstEndDate {get; set;}
    }

    global class customObject {
        @AuraEnabled
        global String Id {get; set;}
        @AuraEnabled
        global String Name {get; set;}
    }

    global class returnObject {
        @AuraEnabled
        global String OpptyCode {get; set;}
        @AuraEnabled
        global String Id {get; set;}
        @AuraEnabled
        global String Name {get; set;}
        @AuraEnabled
        global String Status {get; set;}
        @AuraEnabled
        global String Stage {get; set;}
        @AuraEnabled
        global String CompCode {get; set;}
        @AuraEnabled 
        global String CompName {get; set;}
        @AuraEnabled
        global String AccNumber {get; set;}
        @AuraEnabled
        global String AccName {get; set;}
        @AuraEnabled
        global String OriginAccNum {get; set;}
        @AuraEnabled
        global String OriginAcctName {get; set;}
        @AuraEnabled
        global String BizLevel {get; set;}
        @AuraEnabled
        global String OwnerName {get; set;}
        @AuraEnabled
        global String SalesDiv {get; set;}
        @AuraEnabled
        global String SalesDept {get; set;}
        @AuraEnabled
        global String DeliveryDiv {get; set;}
        @AuraEnabled
        global String DeliveryDept {get; set;}
        @AuraEnabled
        global Boolean Collaboration {get; set;}
        @AuraEnabled
        global Boolean GroupInternal {get; set;}
        @AuraEnabled
        global Boolean KoreaDomestic {get; set;}
        @AuraEnabled
        global String BizType {get; set;}
        @AuraEnabled
        global Boolean DealBreak {get; set;}
        @AuraEnabled
        global String CloseDate {get; set;}
        @AuraEnabled
        global String FirstCloseDate {get; set;}
        @AuraEnabled
        global Boolean Permission {get; set;}
    }
}