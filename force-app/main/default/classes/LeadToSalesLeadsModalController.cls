/**
 * @description       : 
 * @author            : Junghwa.Kim@dkbmc.com
 * @group             : 
 * @last modified on  : 11-11-2021
 * @last modified by  : zenith21c@test.com
 * Modifications Log 
 * Ver   Date         Author                  Modification
 * 1.0   11-03-2020   Junghwa.Kim@dkbmc.com   Initial Version
**/
public without sharing class LeadToSalesLeadsModalController {
    // 변환 가능여부 체크
    @AuraEnabled
    public static Map<String, Boolean> leadCheck(String recordId){
        try{
            Map<String, Boolean> rtnMap = new Map<String, Boolean>();

            List<Lead> lead = [SELECT Id, Name, Status, LeadType__c, SalesLeadID__c FROM Lead WHERE Id = :recordId LIMIT 1];
            Boolean isConverted = false;
            if(lead.size() > 0 && lead[0].SalesLeadID__c != null) isConverted = true;
            rtnMap.put('isConverted', isConverted);

            Boolean isClosed = false;
            if(lead.size() > 0 && lead[0].Status == 'Close') isClosed = true;
            rtnMap.put('isClosed', isClosed);

            rtnMap.put('isAdmin', Utils.isAdmin());

            Boolean isConvertTarget = false;
            if(lead.size() > 0 && (lead[0].LeadType__c == '01' || lead[0].LeadType__c == '02')) isConvertTarget = true;
            rtnMap.put('isConvertTarget', isConvertTarget);

            return rtnMap;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    // 변환에 필요한 필드정보 조회 및 세팅
    @AuraEnabled
    public static Map<String, String> getFieldLabel(String recordId){
        Map<String, String> rtnMap = new Map<String, String>();

        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get('Lead');
        Map<String, Schema.SObjectField> LeadfieldMap = leadSchema.getDescribe().fields.getMap();
    
        Lead lead = [SELECT Id, Name, LastName, FirstName, Title, Company, Country__c, Phone, MobilePhone, Email, Description, CurrencyIsoCode, 
                            InterestSubject1__c, InterestSubject2__c, PersonalInfoAgreementExpireDate__c, PersonalInfoAgreement__c 
                       FROM Lead 
                      WHERE Id =: recordId];
    
        Map<String, customObject> leadMap = new Map<String, customObject>();
        leadMap.put(LeadfieldMap.get('Name').getDescribe().getLabel(),                               new customObject(lead.Name != null ? lead.Name : '', 'text'));
        leadMap.put(LeadfieldMap.get('Title').getDescribe().getLabel(),                              new customObject(lead.Title != null ? lead.Title : '', 'text'));
        leadMap.put(LeadfieldMap.get('Company').getDescribe().getLabel(),                            new customObject(lead.Company != null ? lead.Company : '', 'text'));
        leadMap.put(LeadfieldMap.get('Country__c').getDescribe().getLabel(),                         new customObject(lead.Country__c != null ? lead.Country__c : '', 'text'));
        leadMap.put(LeadfieldMap.get('Phone').getDescribe().getLabel(),                              new customObject(lead.Phone != null ? lead.Phone : '', 'text'));
        leadMap.put(LeadfieldMap.get('MobilePhone').getDescribe().getLabel(),                        new customObject(lead.MobilePhone != null ? lead.MobilePhone : '', 'text'));
        leadMap.put(LeadfieldMap.get('Email').getDescribe().getLabel(),                              new customObject(lead.Email != null ? lead.Email : '', 'text'));
        leadMap.put(LeadfieldMap.get('Description').getDescribe().getLabel(),                        new customObject(lead.Description != null ? lead.Description : '', 'text'));
        leadMap.put(LeadfieldMap.get('CurrencyIsoCode').getDescribe().getLabel(),                    new customObject(lead.CurrencyIsoCode != null ? lead.CurrencyIsoCode : '', 'text'));
        leadMap.put(LeadfieldMap.get('InterestSubject1__c').getDescribe().getLabel(),                new customObject(lead.InterestSubject1__c != null ? lead.InterestSubject1__c : '', 'text'));
        leadMap.put(LeadfieldMap.get('InterestSubject2__c').getDescribe().getLabel(),                new customObject(lead.InterestSubject2__c != null ? lead.InterestSubject2__c : '', 'text'));
        leadMap.put(LeadfieldMap.get('PersonalInfoAgreementExpireDate__c').getDescribe().getLabel(), new customObject(lead.PersonalInfoAgreementExpireDate__c != null ? String.valueOf(lead.PersonalInfoAgreementExpireDate__c) : '', 'datetime'));
        leadMap.put(LeadfieldMap.get('PersonalInfoAgreement__c').getDescribe().getLabel(),           new customObject(lead.PersonalInfoAgreement__c != null ? String.valueOf(lead.PersonalInfoAgreement__c) : '', 'checkbox'));
    
        rtnMap.put('Lead', JSON.serialize(leadMap));
    
        Map<String, customObject> SalesLeadMap = new Map<String, customObject>();
        SalesLeadMap.put(LeadfieldMap.get('Name').getDescribe().getLabel(),                               new customObject(lead.Name != null ? lead.Name : '', 'text'));
        SalesLeadMap.put(LeadfieldMap.get('Title').getDescribe().getLabel(),                              new customObject(lead.Title != null ? lead.Title : '', 'text'));
        SalesLeadMap.put(LeadfieldMap.get('Company').getDescribe().getLabel(),                            new customObject(lead.Company != null ? lead.Company : '', 'text'));
        SalesLeadMap.put(LeadfieldMap.get('Country__c').getDescribe().getLabel(),                         new customObject(lead.Country__c != null ? lead.Country__c : '', 'text'));
        SalesLeadMap.put(LeadfieldMap.get('Phone').getDescribe().getLabel(),                              new customObject(lead.Phone != null ? lead.Phone : '', 'text'));
        SalesLeadMap.put(LeadfieldMap.get('MobilePhone').getDescribe().getLabel(),                        new customObject(lead.MobilePhone != null ? lead.MobilePhone : '', 'text'));
        SalesLeadMap.put(LeadfieldMap.get('Email').getDescribe().getLabel(),                              new customObject(lead.Email != null ? lead.Email : '', 'text'));
        SalesLeadMap.put(LeadfieldMap.get('Description').getDescribe().getLabel(),                        new customObject(lead.Description != null ? lead.Description : '', 'text'));
        SalesLeadMap.put(LeadfieldMap.get('CurrencyIsoCode').getDescribe().getLabel(),                    new customObject(lead.CurrencyIsoCode != null ? lead.CurrencyIsoCode : '', 'text'));
        SalesLeadMap.put(LeadfieldMap.get('InterestSubject1__c').getDescribe().getLabel(),                new customObject(lead.InterestSubject1__c != null ? lead.InterestSubject1__c : '', 'text'));
        SalesLeadMap.put(LeadfieldMap.get('InterestSubject2__c').getDescribe().getLabel(),                new customObject(lead.InterestSubject2__c != null ? lead.InterestSubject2__c : '', 'text'));
        SalesLeadMap.put(LeadfieldMap.get('PersonalInfoAgreementExpireDate__c').getDescribe().getLabel(), new customObject(lead.PersonalInfoAgreementExpireDate__c != null ? String.valueOf(lead.PersonalInfoAgreementExpireDate__c) : '', 'datetime'));
        SalesLeadMap.put(LeadfieldMap.get('PersonalInfoAgreement__c').getDescribe().getLabel(),           new customObject(lead.PersonalInfoAgreement__c != null ? String.valueOf(lead.PersonalInfoAgreement__c) : '', 'checkbox'));
    
        rtnMap.put('SalesLead', JSON.serialize(SalesLeadMap));

        return rtnMap;
    }

    // 마케팅리드를 사업리드로 변환
    @AuraEnabled
    public static string convertLead(String LeadId, String OwnerId){
        // Get lead info
        Lead lead = [SELECT Id, Name, LastName, FirstName, Title, Company, Country__c, Phone, MobilePhone, Email, Description, LeadType__c,
                            CurrencyIsoCode, InterestSubject1__c, InterestSubject2__c, PersonalInfoAgreementExpireDate__c, PersonalInfoAgreement__c, SalesDepartment__c, ownerId
                       FROM Lead 
                      WHERE Id = :LeadId];
        
        // Get record type
        User owner = [SELECT Id, ProfileId, FederationIdentifier, CompanyCode__c FROM User WHERE Id = :OwnerId LIMIT 1];
        List<Employee__c> empList = [SELECT Id, Name, EvKostl__c, EvUniqID__c, EvSapBukrs__c FROM Employee__c WHERE EvUniqID__c =: owner.FederationIdentifier];
        List<CostCenter__c> ccList = new List<CostCenter__c>();
        if(empList.size() > 0){
            if(empList[0].EvKostl__c != null) ccList = [SELECT Id, CompanyCode__c, CostCenter__c, ZZCheck__c, Closed__c FROM CostCenter__c WHERE CostCenter__c =: empList[0].EvKostl__c AND Closed__c = false];
        }
        
        // Get campaign info
        Set<String> cIdList = new Set<String>();
        for(CampaignMember c : [SELECT CampaignId FROM CampaignMember WHERE LeadId = :lead.Id]){
            cIdList.add(c.CampaignId);
        }
        List<Campaign> CList = [SELECT Id, SalesLeadConvertedNumber__c FROM Campaign WHERE Id IN :cIdList ORDER BY CreatedDate DESC LIMIT 1];

        Sales_Lead__c saleslead = new Sales_Lead__c();
        saleslead.RecordTypeId = getRecordType(owner.ProfileId);
        saleslead.OwnerId = OwnerId;
        saleslead.Lead__c = LeadId;
        saleslead.LeadStatus__c = 'In Process';
        saleslead.LeadStage__c = 'Cold';
        if(lead.LeadType__c == '01') saleslead.LeadType__c = '01';
        else if(lead.LeadType__c == '02') saleslead.LeadType__c = '02';
        if(ccList.size() > 0) saleslead.SalesDepartment__c = ccList[0].Id == null ? null : ccList[0].Id;
        saleslead.Name = lead.Name;
        saleslead.LastName__c = lead.LastName;
        saleslead.FirstName__c = lead.FirstName;
        saleslead.Title__c = lead.Title;
        saleslead.Company__c = lead.Company;
        saleslead.Country__c = lead.Country__c;
        saleslead.Phone__c = lead.Phone;
        saleslead.MobilePhone__c = lead.MobilePhone;
        saleslead.Email__c = lead.Email;
        saleslead.Description__c = lead.Description;
        saleslead.CurrencyIsoCode = lead.CurrencyIsoCode;
        saleslead.InterestSubject1__c = lead.InterestSubject1__c;
        saleslead.InterestSubject2__c = lead.InterestSubject2__c;
        saleslead.PersonalInfoAgreementExpireDate__c = lead.PersonalInfoAgreementExpireDate__c;
        saleslead.PersonalInfoAgreement__c = lead.PersonalInfoAgreement__c;
        saleslead.LeadChannel__c = 'Marketing Lead Converted';
        if(CList.size() > 0) saleslead.CampaignId__c = CList[0].Id;

        try{
            insert saleslead;

            lead.SalesLeadID__c = saleslead.Id;
            lead.CloseReason__c = 'Sales Lead Converted';
            lead.Status = 'Close';
            lead.LeadStage__c = 'Converted';
            update lead;

            //--------------------------------------------------------------------
            //마케팅 리드에서 사업리드로 변환 시, Owner에게 Knox채팅 알람 발송
            try{
                String oldOwnerId = lead.ownerId;
                String newOwnerId = saleslead.ownerId;
                String salesLeadName = saleslead.Name;
                String salesLeadBeforeOwner = '';
                String salesLeadAfterOwner = '';
                String salesLeadDescription = saleslead.Description__c;
                Datetime modifyDate = saleslead.LastModifiedDate;
                if (modifyDate==null){
                    modifyDate = Datetime.now();
                }
                String salesLeadChangeDate = modifyDate.format('yyyy-MM-dd a HH:mm:ss');
                String oldOwnerEmail = '';
                String newOwnerEmail = '';
                String linkAddress = '';                
                Boolean isSandbox = Utils.getIsSandbox();

                User oldUser = [SELECT Id, LastName, FirstName, Email, FederationIdentifier
                                    FROM User
                                WHERE id = :oldOwnerId];
                Employee__c oldEmployee = oldUser.FederationIdentifier != '' ? Utils.getEmployeeData(oldUser.FederationIdentifier) : null;
                User newUser = [SELECT Id, LastName, FirstName, Email, FederationIdentifier
                                    FROM User
                                WHERE id = :newOwnerId];
                Employee__c newEmployee = newUser.FederationIdentifier != '' ? Utils.getEmployeeData(newUser.FederationIdentifier) : null;
                Employee__c senderEmployee;
                
                salesLeadBeforeOwner = oldUser.LastName + oldUser.FirstName;
                if(oldEmployee != null) oldOwnerEmail          = oldEmployee.EvMailAddr__c;

                salesLeadAfterOwner  = newUser.LastName + newUser.FirstName;
                if(newEmployee != null) newOwnerEmail          = newEmployee.EvMailAddr__c;
             
                if(String.isNotBlank(oldOwnerEmail)){
                    oldOwnerId = oldOwnerEmail.left(oldOwnerEmail.indexOf('@'));
                }
                if(String.isNotBlank(newOwnerEmail)){
                    newOwnerId = newOwnerEmail.left(newOwnerEmail.indexOf('@'));
                }
                //QA
                if(isSandbox){
                    linkAddress = 'https://sdssfa--qa.lightning.force.com/lightning/r/Sales_Lead__c/'+saleslead.Id+'/view';
                }
                //REAL
                else{
                    linkAddress = 'https://sdssfa.lightning.force.com/lightning/r/Sales_Lead__c/'+saleslead.Id+'/view';
                }
                /* ------------------------------------------------------------------------- */
                /* Jitterbit 통해 Knox Rest API 호출 시작 */
                Map<String, String> inputMap = new Map<String, String>();
                inputMap.put('oldSingleId', oldOwnerId);
                inputMap.put('newSingleId', newOwnerId);
                inputMap.put('salesLeadName', salesLeadName);
                inputMap.put('salesLeadBeforeOwner', salesLeadBeforeOwner);
                inputMap.put('salesLeadAfterOwner', salesLeadAfterOwner);
                inputMap.put('oldOwnerEmail', oldOwnerEmail);
                inputMap.put('newOwnerEmail', newOwnerEmail);
                inputMap.put('salesLeadChangeDate', salesLeadChangeDate);
                inputMap.put('salesLeadDescription', salesLeadDescription);
                inputMap.put('linkAddress', linkAddress);
                IF_KnoxChatSendController.sendMarketingLeadConvertedToSalesLeadChat(inputMap);
                /* Jitterbit 통해 Knox Rest API 호출 종료*/
                /* ------------------------------------------------------------------------- */   
            }
            catch(Exception e){
                System.debug('LeadToSalesLeadsModalController -> KnoxChat e.getMessage : ' + e.getMessage());
            }
            //--------------------------------------------------------------------

            return saleslead.Id;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string getRecordType(String profileId){
        Profile p = [SELECT Id, Name FROM Profile WHERE Id = :profileId];
        String profileName = String.valueOf(p.Name);

        RecordType rt;
        if(profileName.contains('Logi')){
            rt = [SELECT Id,Name, DeveloperName FROM RecordType WHERE DeveloperName = 'Logistics' AND sObjectType = 'Sales_Lead__c' LIMIT 1];
        }else{
            rt = [SELECT Id,Name, DeveloperName FROM RecordType WHERE DeveloperName = 'HQ' AND sObjectType = 'Sales_Lead__c' LIMIT 1];
        }

        return String.valueOf(rt.Id);
    }

    public class ReturnWrapper{
        @AuraEnabled
        public List<Map<String, String>> lflist {get; set;}

        public ReturnWrapper(List<Map<String, String>> returnlist){
            this.lflist = returnlist;
        }
    }

    public class customObject{
        @AuraEnabled
        public String value {get; set;}
        public String type {get; set;}

        public customObject(String value, String type){
            this.value = value;
            this.type = type;
        }
    }
}