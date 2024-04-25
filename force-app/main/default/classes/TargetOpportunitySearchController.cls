public without sharing class TargetOpportunitySearchController {
    @AuraEnabled    
    public static List<Map<String, String>> defaultSetting(){
        
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
     
        return statusPickList;
    }

    
    @AuraEnabled
    public static OpportunityDataTableWrapper getOpportunityData(String SelectedValue,Integer pageNumber, Integer pageSize) {
        System.debug('Inside Apex');
        Integer offset = (pageNumber - 1) * pageSize;
        Integer recordEnd = pageSize * pageNumber;
        
        String str_SELECT = 'SELECT Id, Name, OpportunityCode__c, toLabel(OpportunityStatus__c), toLabel(StageName), CompanyCode__c, Account.Name, Account.AccountNumber,cOriginAcc__r.Name,Amount,CurrencyIsoCode, ';
        str_SELECT += 'cOriginAcc__r.AccountNumber,Owner.Name, SalesDivision__c, SalesDepartment__r.Name, cPrimarySalesDepartment__c, cPrimarySalesDepartment__r.Name, CloseDate FROM Opportunity ';
        
        String str_COUNT = 'SELECT COUNT() FROM Opportunity ';
        String str_Where = WhereCondition(SelectedValue);
        String str_ORDER = ' ORDER BY BO1stRegistrationDate__c desc nulls Last ';
        String str_LIMIT = ' LIMIT '+pageSize+' OFFSET '+offset;
        Integer totalRecords = Database.countQuery(str_COUNT + str_WHERE);
        

        //Instance of Opportunity DataTable Wrapper Class
        OpportunityDataTableWrapper objDT =  new OpportunityDataTableWrapper();  
        objDT.pageSize = pageSize;
        objDT.pageNumber = pageNumber;
        objDT.recordStart = offset + 1;
        objDT.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
        objDT.totalRecords = totalRecords;
        objDT.opportunityList = Database.query(str_SELECT + str_WHERE + str_ORDER + str_LIMIT);
        
        Set<String> resultIdSet = new Set<String>();
        Map<String, Boolean> opptyPermissionMap = new Map<String, Boolean>();
        if(objDT.opportunityList.size() > 0){
            for(Opportunity opp : objDT.opportunityList){
                resultIdSet.add(opp.Id);
            }
            
            List<UserRecordAccess> accessList = [SELECT RecordId, HasReadAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :resultIdSet];
            for(UserRecordAccess access : accessList){
                opptyPermissionMap.put(access.RecordId, access.HasReadAccess);
            }
        }
        objDT.opptyPermissionMap = opptyPermissionMap;
        
        return objDT;
    }
    
    @AuraEnabled
    Public static string WhereCondition(String SelectedValue){
        selectedValue sv = (selectedValue)JSON.deserialize(selectedValue, selectedValue.class);
        String str_WHERE = ' WHERE RecordType.Name = \'HQ\' AND CompanyCode__c = \'T100\' ';
        if(sv.BOName != null){
            str_WHERE += ' AND (Name LIKE \'%' + sv.BOName + '%\')';
        }
        if(sv.OpptyCode != null){
            str_WHERE += ' AND (OpportunityCode__c LIKE \'%' + sv.OpptyCode + '%\')';
        }   
        if(sv.Status != ''){
            str_WHERE += ' AND OpportunityStatus__c = \'' + sv.Status + '\'';
        }
        if((sv.Owner).Id != null){
            str_WHERE += ' AND OwnerId = \'' + (sv.Owner).Id + '\'';
        }
        if((sv.SalesDept).Id != null){
            str_WHERE += ' AND SalesDepartment__c = \'' + (sv.SalesDept).Id + '\'';
        }

        if((sv.PrimarySalesDept).Id != null){
            str_WHERE += ' AND cPrimarySalesDepartment__c = \'' + (sv.PrimarySalesDept).Id + '\'';
        }
        return str_WHERE;
    }
    
    public class OpportunityDataTableWrapper {
        @AuraEnabled
        public Integer pageSize {get;set;}
        @AuraEnabled
        public Integer pageNumber {get;set;}
        @AuraEnabled
        public Integer totalRecords {get;set;}
        @AuraEnabled
        public Integer recordStart {get;set;}
        @AuraEnabled
        public Integer recordEnd {get;set;}
        @AuraEnabled
        public List<Opportunity> opportunityList {get;set;}
        @AuraEnabled
        public Map<String,Boolean> opptyPermissionMap {get;set;}
    }
    public class selectedValue {
        @AuraEnabled
        public String BOName {get; set;}
        @AuraEnabled
        public String Status {get; set;}
        @AuraEnabled
        public customObject Owner {get; set;}
        @AuraEnabled
        public String OpptyCode {get; set;}
        @AuraEnabled
        public customObject SalesDept {get; set;}
        @AuraEnabled
        public customObject PrimarySalesDept {get; set;}
    }

    public class customObject {
        @AuraEnabled
        public String Id {get; set;}
        @AuraEnabled
        public String Name {get; set;}
    }
}