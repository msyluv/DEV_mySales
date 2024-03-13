/**
 * @author            : aditya.r2@partner.samsung.com
 * @group             : 
 * @description       : 
 * @last modified on  : 
 * @last modified by  : 
 * Modifications Log 
 * Ver   Date         Author                    	Modification
 * 1.0   2023-08-28	 aditya.r2@partner.samsung.com	Initial Version
**/
global without sharing class TestApexAdi {
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

    @AuraEnabled    
    global static Map<String, List<Map<String, String>>> defaultSetting(){
        Map<String, List<Map<String, String>>> rtnMap = new Map<String, List<Map<String, String>>>();
        
        // Default Map Setting
        Map<String, String> defaultMap = new Map<String, String>();
        defaultMap.put('label', System.Label.BOSEARCH_LAB_ALL);
        defaultMap.put('value', '');

        // Status Picklist Setting
        List<Map<String, String>> statusPickList = new List<Map<String, String>>();
        statusPickList.add(defaultMap);

        List<Map<String, String>> opptyStatusList = Utils.getPicklistOptionType('Opportunity', 'OpportunityStatus__c');
        for(Integer i = 0; i < opptyStatusList.size(); i++){
            statusPickList.add(opptyStatusList[i]);
        }
        rtnMap.put('Status', statusPickList);
        
        // Record Type Picklist Setting
        List<Map<String,String>> rcdMapList = new List<Map<String,String>>();
        rcdMapList.add(defaultMap);
        List<RecordType> rcdList = [SELECT Id, toLabel(Name), DeveloperName, SobjectType, IsActive FROM RecordType WHERE SobjectType = 'Opportunity' AND IsActive = TRUE];
        for (RecordType rcd : rcdList) {
            Map<String,String> rcdMap = new Map<String,String>();
            rcdMap.put('label', rcd.Name);
            rcdMap.put('value', rcd.Id);
            rcdMapList.add(rcdMap);
        }
        rtnMap.put('RecordType', rcdMapList);

        // Service Picklist Setting
        List<Map<String,String>> svcMapList = new List<Map<String,String>>();
        svcMapList.add(defaultMap);
        //TA Service 는 조회 되지 않도록 수정.
        List<Master_Service__c> masterSvcList = [SELECT Id, Name 
                                                   FROM Master_Service__c 
                                                  WHERE Use__c = true 
                                                    AND (ValidityStartDate__c < :System.today() AND ValidityEndDate__c > :System.today()) 
                                                 	AND TechAttribute__c = false
                                                  ORDER BY Name];
        for(Master_Service__c masterSvc : masterSvcList){
            Map<String,String> masterSvcMap = new Map<String,String>();
            masterSvcMap.put('label', masterSvc.Name);
            masterSvcMap.put('value', masterSvc.Id);
            svcMapList.add(masterSvcMap);
        }
        rtnMap.put('Service', svcMapList);

        // Solution Picklist Setting
        List<Map<String,String>> solMapList = new List<Map<String,String>>();
        solMapList.add(defaultMap);
        rtnMap.put('Solution', solMapList);

        // Collaboration Picklist Setting
        List<Map<String,String>> collaboMapList = new List<Map<String,String>>();
        collaboMapList.add(defaultMap);

        Map<String,String> collabo_OMap = new Map<String,String>();
        collabo_OMap.put('label', System.Label.BOSEARCH_LAB_COLLABO_O);
        collabo_OMap.put('value', 'true');
        collaboMapList.add(collabo_OMap);

        Map<String,String> collabo_XMap = new Map<String,String>();
        collabo_XMap.put('label', System.Label.BOSEARCH_LAB_COLLABO_X);
        collabo_XMap.put('value', 'false');
        collaboMapList.add(collabo_XMap);

        rtnMap.put('Collaboration', collaboMapList);

        // Internal Biz Picklist Setting
        List<Map<String,String>> internalBizMapList = new List<Map<String,String>>();
        internalBizMapList.add(defaultMap);

        Map<String,String> internalBizMap = new Map<String,String>();
        internalBizMap.put('label', System.Label.BOSEARCH_LAB_INTERNALBIZ);
        internalBizMap.put('value', 'true');
        internalBizMapList.add(internalBizMap);

        Map<String,String> externalBizMap = new Map<String,String>();
        externalBizMap.put('label', System.Label.BOSEARCH_LAB_EXTERNALBIZ);
        externalBizMap.put('value', 'false');
        internalBizMapList.add(externalBizMap);

        rtnMap.put('InternalBiz', internalBizMapList);
     
        return rtnMap;
    }

    @AuraEnabled
    global static Map<String, String> getOpptyList(String pageSize, String rcdId, String searchType, String selectedValue){
        selectedValue sv = (selectedValue)JSON.deserialize(selectedValue, selectedValue.class);
        System.debug('sv Company : ' + (sv.Company).Id);
        System.debug('sv Account : ' + (sv.Account).Id);
        System.debug('sv OriginAccount : ' + (sv.OriginAccount).Id);
        System.debug('sv BOName : ' + sv.BOName);
        System.debug('sv Collaboration : ' + sv.Collaboration);
        System.debug('sv GroupInternal : ' + sv.GroupInternal);
        System.debug('sv Service : ' + sv.Service);
        System.debug('sv Solution : ' + sv.Solution);
        System.debug('sv Status : ' + sv.Status);
        System.debug('sv StartDate : ' + sv.StartDate);
        System.debug('sv EndDate : ' + sv.EndDate);
        System.debug('sv Owner : ' + (sv.Owner).Id);
        System.debug('sv OpptyCode : ' + sv.OpptyCode);
        System.debug('sv SalesDept : ' + (sv.SalesDept).Id);
        System.debug('sv PrimarySalesDept : ' + (sv.PrimarySalesDept).Id);
        System.debug('sv RecordType : ' + sv.RecordType);
        System.debug('sv FirstStartDate : ' + sv.FirstStartDate);
        System.debug('sv FirstEndDate : ' + sv.FirstEndDate);
        System.debug('sv Strategic Account : ' + sv.StrategicAccount);
        
        Map<String, String> rtnMap = new Map<String, String>();

        String str_COUNT = 'SELECT COUNT() FROM Opportunity';
        String str_SELECT = '';
        str_SELECT += 'SELECT Id, Name, OpportunityCode__c, OpportunityStatus__c, StageName, CompanyCode__c, AccountId, Account.Name, Account.AccountNumber, ';
        str_SELECT += 'cOriginAcc__c, cOriginAcc__r.Name, cOriginAcc__r.AccountNumber, BusinessLevel__c, OwnerId, Owner.Name, SalesDivision__c, ';
        str_SELECT += 'SalesDepartment__c, SalesDepartment__r.Name, cPrimaryDeliveryDivision__c, cPrimarySalesDepartment__c, cPrimarySalesDepartment__r.Name, ';
        str_SELECT += 'Collaboration__c, GroupInternal__c, KoreaDomestic__c, BusinessType__c, DealBreak__c, CloseDate, FirstCloseDate__c, RecordTypeId, RecordType.Name ';
        str_SELECT += 'FROM Opportunity';
        String str_WHERE = ' WHERE (Name LIKE \'%' + sv.BOName + '%\')';
        str_WHERE += ' AND (OpportunityCode__c LIKE \'%' + sv.OpptyCode + '%\')';
        String str_ORDER = ' ORDER BY Id';
        String str_LIMIT = ' LIMIT ' + pageSize;
                        
        if(String.isNotEmpty(searchType)){
            String sign = '';
            if(searchType.equals('Next')){
                sign = '>';
                str_ORDER += ' ASC';
            }else if(searchType.equals('Prev')){
                sign = '<';
                str_ORDER += ' DESC';
            }

            if(String.isNotEmpty(rcdId)) str_WHERE += ' AND Id' + sign + '\'' + rcdId + '\'';
        }

        System.debug('str_COUNT : ' + str_COUNT);
        System.debug('str_SELECT : ' + str_SELECT);
        System.debug('str_WHERE : ' + str_WHERE);
        System.debug('str_ORDER : ' + str_ORDER);
        System.debug('str_LIMIT : ' + str_LIMIT);
        System.debug('result String : ' + str_SELECT + str_WHERE + str_ORDER + str_LIMIT);

        String resultMSG = '';
        Decimal totalPage = 0;
        Decimal totalCount = 0;
        String str_totalCount = '';
        List<Opportunity> resultOpptyList = new List<Opportunity>();
        List<returnObject> returnList = new List<returnObject>();
        try{
            resultMSG = 'SUCCESS';

            totalPage = Database.countQuery(str_COUNT + str_WHERE);
            totalCount = totalPage;
            //if(totalCount > 1000) str_totalCount = '1000+';
            //else str_totalCount = String.valueOf(totalCount);
            str_totalCount = String.valueOf(totalCount);
            totalPage = Math.ceil(totalPage/20);
            totalPage = (totalPage == 0) ? 1 : totalPage;
            //OpptyIdSet1.addAll(OpptyMSPIdSet); //Anish Testing
            //str_WHERE += ' AND Id IN: OpptyIdSet1'; //Anish Testing
            //System.debug('Ani Size :' + OpptyIdSet1.Size() + '-' + OpptyMSPIdSet.Size());
            System.debug('Ani Query String : '+ str_SELECT + str_WHERE + str_ORDER + str_LIMIT);
            resultOpptyList = Database.query(str_SELECT + str_WHERE + str_ORDER + str_LIMIT);

            Set<String> resultIdSet = new Set<String>();
            Map<String, Boolean> opptyPermissionMap = new Map<String, Boolean>();
            if(resultOpptyList.size() > 0){
                for(Opportunity opp : resultOpptyList){
                    resultIdSet.add(opp.Id);
                }

                List<UserRecordAccess> accessList = [SELECT RecordId, HasReadAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :resultIdSet];
                for(UserRecordAccess access : accessList){
                    opptyPermissionMap.put(access.RecordId, access.HasReadAccess);
                }
                List<Company__c> companyList = [SELECT Name, CompanyCode__c FROM Company__c];
                for(Opportunity opp : resultOpptyList){
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
                    rtnObj.Permission = opptyPermissionMap.get(opp.Id);

                    returnList.add(rtnObj);
                }                
            }
        }catch(Exception e){
            System.debug('ERROR : ' + e.getMessage());
            resultMSG = 'ERROR : ' + e.getMessage();
        }

        rtnMap.put('MESSAGE', resultMSG);
        rtnMap.put('COUNT', String.valueOf(totalPage));
        rtnMap.put('LIST', JSON.serialize(returnList));
        // rtnMap.put('TOTALCOUNT', String.valueOf(totalCount));
        rtnMap.put('TOTALCOUNT', str_totalCount);

        return rtnMap;
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
        global String ProjectCode {get; set;}
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
        //Start-Added by Anish - v 1.6
        @AuraEnabled
        global String CSP {get; set;}
        @AuraEnabled
        global String MSP {get; set;}
        @AuraEnabled
        global String SCP {get; set;}
        @AuraEnabled
        global String ERP {get; set;}
        @AuraEnabled
        global String MES {get; set;}
        @AuraEnabled
        global String TechAttribute {get; set;}
        //End-Added by Anish - v 1.6
        @AuraEnabled
        global String StrategicAccount {get; set;} //Added by Anish - v 1.7
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