/**
* @description       : Rest API CallIn to Interact with Demand system(Sales Lead generation through Demand system).
* @author            : akash.g@samsung.com
* @group             : 
* @last modified on  : 07-20-2022
* @last modified by  : akash.g@samsung.com
* Modifications Log 
* Ver   Date         Author                    Modification
* 1.0   07-15-2022   akash.g@samsung.com   Initial Version
**/
@RestResource(urlMapping = '/IF157/*')
global class IF_DemandCallInAPIController {
    public class OtherException extends Exception {}
    private static final String INTERFACE_ID = 'IF-157';
    private static final String APEX_CLASS   = 'IF_DemandCallInAPIController';
    private static final String METHOD_NAME  = 'doPost';
    private static String leadName, leadType,account,owner,description,reqName,reqId;
    
    @HttpPost
    global static OutputHeader doPost() {
        String guId = IF_Util.generateGuid();
        IF_Log.InterfaceLog infLog;
        IF_Log log = new IF_Log();
        RestRequest req = RestContext.request;
        system.debug('Request**=' + req);
        Blob reqBody = req.requestBody;
        system.debug('reqBody**=' + reqBody);
        
        InputHeader input = (InputHeader)JSON.deserializeStrict(reqBody.toString(),InputHeader.class);
        system.debug('Input**=' + input);
        OutputHeader outHeader = new OutputHeader();
        SavePoint sp = DataBase.setSavePoint();
        try{
            leadName = input.Name;
            leadType = input.Lead_Type;
            account = input.Account;
            owner = input.Owner;
            description = input.Description;
            reqName = input.Requester_Name;
            reqId = input.Requester_ID;
            system.debug('leadName**=' + leadName + 'leadType**=' + leadType + 'account**=' + account + 'owner**=' + owner +
                         'description**=' + description + 'reqName**=' + reqName + 'reqId**=' + reqId);
            String leadRecordTypeID = Schema.SObjectType.Sales_Lead__c.getRecordTypeInfosByDeveloperName().get('HQ').getRecordTypeId();
            system.debug('leadRecordTypeID&&' + leadRecordTypeID);
            Sales_Lead__c slLead = new Sales_Lead__c();
            if(leadRecordTypeID != null)
                slLead.RecordTypeId = leadRecordTypeID;
            slLead.Name = leadName;
            slLead.LeadType__c = leadType;
            slLead.Description__c = description;
            slLead.Requester_Name__c = reqName;
            slLead.Requester_ID__c = reqId;
            slLead.LeadChannel__c = 'Demand' ;
            slLead.LeadStage__c = 'Cold';
            slLead.LeadStatus__c = 'In Process';
            if(account != null && account != ''){
                String accID;
                List<Account> accList = [select id from account where AccountNumber =: account Limit 1];
                system.debug('accList Size @@' + accList.size());
                if(accList.size() == 1 ){
                    accID = accList[0].ID;
                    system.debug('accID@@' + accID);
                    slLead.AccountId__c = accID;
                }
            }
            
            if(owner != null && owner != ''){
                String ownerKnoxID = owner + '@%';
                ID uID;
                String EvUniqueID;
                String costCentreCode;
                List<User> userList = [Select id,FederationIdentifier,DefaultCurrencyIsoCode from user where IsActive = true 
                                      And email Like : ownerKnoxID Limit 1];
                system.debug('userList size @@' + userList.size());
                if(userList.size() == 1){
                    uID = userList[0].ID;
                    slLead.Demand_Owner_ID__c = uID;
                    slLead.CurrencyIsoCode = userList[0].DefaultCurrencyIsoCode;
                    EvUniqueID = userList[0].FederationIdentifier;
                    system.debug('uID@@' + uID);
                    system.debug('EvUniqueID@@' + EvUniqueID);
                    List<Employee__c> empList= [select EvKostl__c from Employee__c where EvUniqID__c =: EvUniqueID Limit 1];
                    system.debug('empList size@@' + empList.size());
                    if(empList.size() == 1 && empList[0].EvKostl__c != null){
                        costCentreCode = empList[0].EvKostl__c;
                        system.debug('CostCentreCode@@' + costCentreCode);
                        List<CostCenter__c> ccList = [select id from CostCenter__c where CostCenter__c =: costCentreCode Limit 1];
                        if(ccList.size() == 1 ){
                            slLead.SalesDepartment__c = ccList[0].ID;
                        }
                    }
                }else{
                    throw new OtherException(System.Label.User_Register_Demand_System);
                }
            }
            Insert slLead;
            outHeader.RESULT  = IF_Util.RESULT_STATUS_SUCCESS;
            outHeader.RESULT_MESSAGE = slLead.ID ;
            infLog = new IF_Log.InterfaceLog( INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqBody.toString(), JSON.serialize(outHeader));         
        }catch(Exception e){
            DataBase.rollback( sp);            
            outHeader.RESULT  = 'F';
            outHeader.RESULT_MESSAGE = e.getMessage();
            system.debug('Exception name =' + e);
            system.debug('Exeption detail=' + e.getCause()+e.getMessage()+e.getTypeName()+e.getLineNumber());
            infLog = new IF_Log.InterfaceLog( INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqBody.toString(), JSON.serialize(outHeader),e);
        }
        
        ID iFLogId = log.createLog2( infLog); 
        system.debug('iFLogId **' + iFLogId);
        return outHeader;
    }   
    
    
    global class OutputHeader{
        public String RESULT = '';
        public String RESULT_MESSAGE = '';
    }
    
    global class InputHeader{
        public String Channel;
        public String Name;
        public String Lead_Type;
        public String Account;
        public String Owner;
        public String Description;
        public String Requester_Name;
        public String Requester_ID;
    }
}