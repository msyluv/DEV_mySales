public class test11 {
    //Akash test
  
    public class OtherException extends Exception {}
    
    public static void testExtendedException() {
        
        
        
        
        try{
            String leadName = 'Testing 3 create';
            String leadType = '31';
            String account = '';
            String owner = 'seonju.jin';
            String description = 'Test Desc';
            String reqName = 'sm2528 hong';
            String reqId = 'sm2528.hong';
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
                Account acc = [select id from account where AccountNumber =: account Limit 1];
                system.debug('acc @@' + acc);
                if(acc != null){
                    accID = acc.ID;
                    system.debug('accID@@' + accID);
                    slLead.AccountId__c = accID;
                }
            }
            
            if(owner != null && owner != ''){
                String ownerKnoxID = owner + '@%';
                ID uID;
                String EvUniqueID;
                String costCentreCode;
                List<User> userList = [Select id,FederationIdentifier,DefaultCurrencyIsoCode from user where IsActive = true And email Like : ownerKnoxID Limit 1];
                system.debug('userList Size @@' + userList.size());
                if(userList.size()== 1){
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
	    system.debug('slLead ID=' + slLead.ID);
                   
        }catch(Exception e){
            
            system.debug('Exeption detail=' + e.getCause()+e.getMessage()+e.getTypeName()+e.getLineNumber());
         
        }
        
       
    }
    
}