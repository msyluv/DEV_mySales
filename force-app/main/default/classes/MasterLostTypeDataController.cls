/**
* @description       : This class is a controller for master lost type data table lwc masterLostTypeDataTable
* @author            : rakshit.s@samsung.com
* @group             : 
* @last modified on  : 03-01-2023
* @last modified by  : rakshit.s@samsung.com
* Modifications Log 
* Ver   Date         Author                  Modification
* 1.0   03-01-2023  rakshit.s@samsung.com   Initial Version
* 1.1   2023-04-20   rakshit.s@samsung.com       logic to check if the scenario of activity is lost or drop.
* 1.2   2023-07-24   divyam.gupta@smsung.com     MySales-255 lost/drop changes 
**/
public with sharing class MasterLostTypeDataController {
    
    
    @AuraEnabled
    public static boolean isLostOrDrop(String activityId,String oppId){
        
        boolean isLost = false;
        List<Opportunity_Activity__c> checkOpptyAct = [
            SELECT  Id ,TransactionName__c,Status__c, StartDate__c, EndDate__c, DueDate__c, OpportunityStage__c, LostReason__c, Description__c FROM Opportunity_Activity__c WHERE WhatId__c =:oppId AND (TransactionName__c = 'ZPZ1' or TransactionName__c = 'ZPZ2')
        ];
        
        if(checkOpptyAct[0].TransactionName__c == 'ZPZ1'){
            isLost = true;
            
        }
        
        return isLost;
    }
    
    @AuraEnabled
    public static List<Master_LostType__c> getMasterLostType(String userLang, boolean isSecondButton, String oppId, String oppActId){
        String queryEngAllData = '';
        String queryKorAllData = '';
        boolean isLost = false;
        boolean isDrop = false;
        //oppId = '006N000000JAUgaIAH';
        List<Opportunity_Activity__c> checkOpptyAct = [
            SELECT  Id ,TransactionName__c,Status__c, StartDate__c, EndDate__c, DueDate__c, OpportunityStage__c, LostReason__c, Description__c FROM Opportunity_Activity__c WHERE WhatId__c =:oppId AND (TransactionName__c = 'ZPZ1' or TransactionName__c = 'ZPZ2')
        ];
        
        if(checkOpptyAct[0].TransactionName__c == 'ZPZ1'){
            isLost = true;
            isDrop = false;
        }
        if(checkOpptyAct[0].TransactionName__c == 'ZPZ2'){
            isDrop = true;
            isLost = false;
        }
        if(!isSecondButton){
            if(isLost){
                queryEngAllData = 'Select Level1_type_eng__c, level2_type_eng__c,Type_Eng__c  from master_losttype__c where lost_drop_type__c=\'Lost\' AND Use__c= True order by Order_Number__c asc';
                queryKorAllData = 'Select Level1_Type_Kor__c,Level2_Type_Kor__c,Type_Kor__c from Master_LostType__c where lost_drop_type__c=\'Lost\' AND Use__c= True order by Order_Number__c asc';
            }
            
            else if(isDrop){
                queryEngAllData = 'Select Level1_type_eng__c, level2_type_eng__c,Type_Eng__c  from master_losttype__c where lost_drop_type__c=\'Drop\' AND Use__c= True order by Order_Number__c asc';
                queryKorAllData = 'Select Level1_Type_Kor__c,Level2_Type_Kor__c,Type_Kor__c from Master_LostType__c where lost_drop_type__c=\'Drop\' AND Use__c= True order by Order_Number__c asc';                
            }
            
        }
        
        else if(isSecondButton){
            //V 1.2
            queryEngAllData = 'select Master_LostType__r.Level1_Type_Eng__c,Master_LostType__r.Level2_Type_Eng__c,Master_LostType__r.Type_Eng__c,Lost_Detail__c,Rate__c from lostresult__c where Opportunity__c=\'' + oppId + '\' AND LostActivity__c =\'' + oppActId + '\' order by createddate asc';
            queryKorAllData = 'select Master_LostType__r.Level1_Type_Kor__c,Master_LostType__r.Level2_Type_Kor__c,Master_LostType__r.Type_Kor__c,Lost_Detail__c,Rate__c from lostresult__c where Opportunity__c=\'' + oppId + '\' AND LostActivity__c =\'' + oppActId + '\' order by createddate asc';
            
            /*queryEngAllData = 'select Master_LostType__r.Level1_Type_Eng__c,Master_LostType__r.Level2_Type_Eng__c,Master_LostType__r.Type_Eng__c,Lost_Detail__c,Results_Bidding__c,Rate__c from lostresult__c where Opportunity__c=\'' + oppId + '\'order by Master_LostType__r.Order_Number__c';
queryKorAllData = 'select Master_LostType__r.Level1_Type_Kor__c,Master_LostType__r.Level2_Type_Kor__c,Master_LostType__r.Type_Kor__c,Results_Bidding__c,Rate__c from lostresult__c where Opportunity__c=\'' + oppId + '\' order by Master_LostType__r.Order_Number__c';
006N000000JAUgaIAH*/
        }
        
        
        
        
        
        
        
        
        
        
        //system.debug('map--->' + columsVsSpanMap);
        
        
        switch on userLang {
            when 'en-US' {
                
                return Database.query(queryEngAllData);
                
                
            }
            when 'ko'{
                return Database.query(queryKorAllData);
            }
            when else {
                return Database.query(queryEngAllData);
            }
        }
        //Select count(id),Level1_Type_Eng__c from Master_LostType__c
    }
    
    
}