/**
* @description       : This class is a controller for Lost Counter Measure data table lwc LostCounterMeasureTable
* @author            : rakshit.s@samsung.com
* @group             : 
* @last modified on  : 06-02-2023
* @last modified by  : rakshit.s@samsung.com
* Modifications Log 
* Ver   Date         Author                  Modification
* 1.0   06-02-2023  rakshit.s@samsung.com   Initial Version
**/
public class LostCounterMeasureTableController {
    
    
    
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
    
    @AuraEnabled()
    public static String getCounterMeasureData(String userLang,String recId,String oppActid){
        system.debug('actid-->'+oppActid);
        List<Lost_Countermeasure__c> countermeasures = new List<Lost_Countermeasure__c>();
        // Create a Map to group the records by Master_LostType__r.Type_Eng__c
        Map<String, List<Lost_Countermeasure__c>> groupedCountermeasures = new Map<String, List<Lost_Countermeasure__c>>();
        // Execute the SOQL query
        if(userLang == 'en-US'){
            countermeasures = [SELECT Master_LostType__r.Type_Eng__c, Countermeasures__c, Action_Item__c, Managing_Department__c,Managing_Department__r.Name, Deadline__c FROM Lost_Countermeasure__c WHERE Opportunity__c =: recId AND LostActivity__c =:oppActid ORDER BY createddate ASC];
            
            
            
            Set<Id> tempId = new Set<Id>();
            for (Lost_Countermeasure__c countermeasure : countermeasures) {
                
                if (!groupedCountermeasures.containsKey(countermeasure.Master_LostType__r.Type_Eng__c)/* && !tempId.contains(countermeasure.Managing_Department__c)*/) {
                    groupedCountermeasures.put(countermeasure.Master_LostType__r.Type_Eng__c, new List<Lost_Countermeasure__c>());
                }
                
                
                groupedCountermeasures.get(countermeasure.Master_LostType__r.Type_Eng__c).add(countermeasure);
                
                
                // tempId.add(countermeasure.Managing_Department__c);
            }
            
        }
        
        else if(userLang == 'ko'){
            countermeasures = [SELECT Master_LostType__r.Type_Kor__c, Countermeasures__c, Action_Item__c, Managing_Department__c,Managing_Department__r.Name, Deadline__c FROM Lost_Countermeasure__c WHERE Opportunity__c =: recId AND LostActivity__c =:oppactid ORDER BY createddate ASC];
            
            
            
            Set<Id> tempId = new Set<Id>();
            for (Lost_Countermeasure__c countermeasure : countermeasures) {
                
                if (!groupedCountermeasures.containsKey(countermeasure.Master_LostType__r.Type_Kor__c)/* && !tempId.contains(countermeasure.Managing_Department__c)*/) {
                    groupedCountermeasures.put(countermeasure.Master_LostType__r.Type_Kor__c, new List<Lost_Countermeasure__c>());
                }
                
                
                groupedCountermeasures.get(countermeasure.Master_LostType__r.Type_Kor__c).add(countermeasure);
                
                
                // tempId.add(countermeasure.Managing_Department__c);
            }
            
        }
        
        
        // Create a String variable to store the HTML string
        String htmlString = '';
        
        // Loop through the entries in the Map and append the HTML tags
        for (String type : groupedCountermeasures.keySet()) {
            List<Lost_Countermeasure__c> typeCountermeasures = groupedCountermeasures.get(type);
            
            
            
            htmlString += '<tr>';
            htmlString += '<td style=" white-space: pre-wrap; background: #f8f9f9; color: #000; font-family: NanumSquare,Helvatica,Arial,sans-serif;" rowspan="' + String.valueOf(typeCountermeasures.size()) + '">' + type + '</td>';
            for (Integer i = 0; i < typeCountermeasures.size(); i++) {
                system.debug('first--> ' + typeCountermeasures[i].Countermeasures__c + 'second--> ' + typeCountermeasures[i].Action_Item__c + '3rd-> ' + typeCountermeasures[i].Managing_Department__r.Name + 'forth--> ' + String.valueOf(typeCountermeasures[i].Deadline__c) );
                if (i > 0) {
                    htmlString += '<tr>';
                }
                if(typeCountermeasures[i].Countermeasures__c == null){
                    htmlString += '<td style="white-space: pre-wrap; background: #fff; color: #000; font-family: NanumSquare,Helvatica,Arial,sans-serif;">' + ' ' + '</td>';
                }
                else{
                    htmlString += '<td style="white-space: pre-wrap; white-space: pre-wrap;text-align:left; white-space: pre-wrap; background: #fff; color: #000; font-family: NanumSquare,Helvatica,Arial,sans-serif;">' + typeCountermeasures[i].Countermeasures__c + '</td>';
                }
                
                if(typeCountermeasures[i].Action_Item__c == null){
                    htmlString += '<td style="white-space: pre-wrap; background: #fff; color: #000; font-family: NanumSquare,Helvatica,Arial,sans-serif;">' + ' ' + '</td>';
                }
                else{
                    htmlString += '<td style="white-space: pre-wrap; text-align:left; white-space: pre-wrap; background: #fff; color: #000; font-family: NanumSquare,Helvatica,Arial,sans-serif;">' + typeCountermeasures[i].Action_Item__c + '</td>';
                }
                if(typeCountermeasures[i].Managing_Department__r.Name == null){
                    htmlString += '<td style=" vertical-align:middle; white-space: pre-wrap; background: #fff; color: #000; font-family: NanumSquare,Helvatica,Arial,sans-serif;">' + ' ' + '</td>';
                }
                else{
                    htmlString += '<td style=" vertical-align:middle; white-space: pre-wrap; background: #fff; color: #000; font-family: NanumSquare,Helvatica,Arial,sans-serif;">' + typeCountermeasures[i].Managing_Department__r.Name + '</td>';
                }
                if(String.valueOf(typeCountermeasures[i].Deadline__c) == null){
                    htmlString += '<td style=" vertical-align:middle; background: #fff; color: #000; font-family: NanumSquare,Helvatica,Arial,sans-serif;">' + ' ' + '</td>';
                }
                else{
                    htmlString += '<td style=" vertical-align:middle; white-space: pre-wrap; background: #fff; color: #000; font-family: NanumSquare,Helvatica,Arial,sans-serif;">' + String.valueOf(typeCountermeasures[i].Deadline__c) + '</td>';
                }
                htmlString += '</tr>';
            }
        }
        
        htmlString = htmlString.replace('null','');
        htmlString = removeEmptyTableRows(htmlString);
        return htmlString;
        
    }
    
    public static String removeEmptyTableRows(String htmlString){
        
        
        // String htmlString = '<tr><td rowspan="1"></td><td> </td><td> </td><td> </td><td> </td></tr><tr><td rowspan="1">Free/Additional Proposals Inferior</td><td> </td><td> </td><td> </td><td> </td></tr>';
        
        // Split the HTML string into an array of <tr> tags
        List<String> trTags = htmlString.split('<tr');
        
        // Loop through each <tr> tag in reverse order and check if it contains only empty <td> tags
        for (Integer i = trTags.size() - 1; i >= 0; i--) {
            String tr = trTags[i];
            Integer tdCount = tr.countMatches('<td>');
            Integer nonEmptyTdCount = tr.replace('<td></td>', '').countMatches('<td>');
            if (nonEmptyTdCount == 0 && tdCount > 0) {
                trTags.remove(i);
            }
        }
        
        // Join the remaining <tr> tags back into a single string
        htmlString = '<tr' + String.join(trTags, '<tr');
        return htmlString;
        
    }
    
    
}