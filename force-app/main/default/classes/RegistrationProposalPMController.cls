/**
* @author            : younghoon.kim@dkbmc.com
* @group             : 
* @description       : 
* @last modified on  : 2022-09-14
* @last modified by  : divyam.gupta@samsung.com
* Modifications Log 
* Ver   Date         Author                    Modification
* 1.0   2021-05-13   younghoon.kim@dkbmc.com   Initial Version
* 1.1   2022-06-13   akash.g@samsung.com       Add functionality of Registration Representative PM Button.
* 1.2   2022-06-16   akash.g@samsung.com       Add new function to check whether opportunity have project code or not.
* 1.3   2022-09-14   divyam.gupta@samsug.com   Add new functionality to check whether profile is Service Desk Agency or not.
**/
public class RegistrationProposalPMController {
    
    @AuraEnabled
    public static Opportunity init(String opptyId){
        //V1.2 -> Add StageName field in below query.
        Opportunity oppty = [SELECT Id, Name, CompanyCode__c, OpportunityCode__c, ProposalPM_User__c, ProposalPM__c,RepresentativePM__c,StageName FROM Opportunity WHERE Id =: opptyId];
        return oppty;
    }    
    
    @AuraEnabled
    public static Map<String, String> proposalPMSave(String opptyId, String empId){
        Map<String, String> rtnMap = new Map<String, String>();
        
        try{
            Opportunity oppty = [SELECT Id, Name, CompanyCode__c, OpportunityCode__c, ProposalPM_User__c, ProposalPM__c FROM Opportunity WHERE Id =: opptyId];
            oppty.ProposalPM_User__c = null;
            oppty.ProposalPM__c = empId;
            
            update oppty;
            
            rtnMap.put('Result', 'S');
            rtnMap.put('Message', '');
        }catch(Exception e){
            System.debug('Error : ' + e.getMessage());
            rtnMap.put('Result', 'E');
            rtnMap.put('Message', e.getMessage());
        }
        
        return rtnMap;
    }
    
    @AuraEnabled
    public static Map<String, String> representativePMSave(String opptyId, String empId){
        Map<String, String> rtnMap = new Map<String, String>();
        
        try{
            Opportunity oppty = [SELECT Id, Name FROM Opportunity WHERE Id =: opptyId];
            oppty.RepresentativePM__c = empId;
            
            update oppty;
            
            rtnMap.put('Result', 'S');
            rtnMap.put('Message', '');
        }catch(Exception e){
            System.debug('Error : ' + e.getMessage());
            rtnMap.put('Result', 'E');
            rtnMap.put('Message', e.getMessage());
        }
        
        return rtnMap;
    }
    //V1.2 -> Add new function to check whether opportunity have project code or not
    @AuraEnabled
    public static String representativePMCheckProjectCode(String opptyId){
        String projExist;
        //V1.3 -> Add new functionality to check whether profile is Service Desk Agency or not.
        String profileNameUserInfo = [SELECT Name FROM Profile WHERE Id =: UserInfo.getProfileId()].Name;
        String Sdeskprofile = 'Service Desk Agency';
        
        if(profileNameUserInfo == Sdeskprofile){
            projExist = 'Service_desk';
            return projExist;
        }
        //V1.3 --- END
        else{
            List<Project__c> projList = [Select id,DeletionFlag__c from Project__c where Opportunity__c =: opptyId AND DeletionFlag__c = false];
            if(projList.size() == 0){
                projExist = 'false';
            }else{
                projExist = 'true';
            }
            return projExist;
        }  
    }
      //V1.3 -> Add new functionality to check whether profile is Service Desk Agency or not.
    @AuraEnabled
    public static String profilecheck(){
        
        String profileNameUserInfo = [SELECT Name FROM Profile WHERE Id =: UserInfo.getProfileId()].Name;
        String Sdeskprofile = 'Service Desk Agency';
        if(profileNameUserInfo == Sdeskprofile){
            return 'service_desk';
        }
        else {
            return 'other';
        }
    }
}