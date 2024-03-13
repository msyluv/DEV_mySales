/**
* @description       : Rest API Callout to Interact with Cello system
* @author            : Kajal.c@samsung.com
* @group             : 
* @last modified on  : 2022-10-19
* @last modified by  : Kajal.c@samsung.com
* Modifications Log 
* Ver   Date         Author                    Modification
* 1.0   2022-10-19   Kajal.c@samsung.com   Initial Version
* 1.1   2023-10-05   divyam.gupta@samsung.com   Mysales-313 (Logistics) CP Review URL error modify.
**/
public class LogisticsCPReviewComp {
    
    @AuraEnabled
    public static List<Master_Logistics_CPReview__c> getLogisticsCPReviewData(){
    List<Master_Logistics_CPReview__c> CPReviewrecords = [Select Class_code__c,Class_Name_English__c,Class_Name_Korean__c,Class_Division_Code__c,Class_Division_Name_English__c,
                                                             Class_Division_Name_Korean__c from Master_Logistics_CPReview__c Order By Class_Division_Code__c];
        
        return CPReviewrecords;
    }
    
    @AuraEnabled
    public static Map<String, String>  getURL(String lbsType,String boId, String billToId){
        system.debug('entry getURL function');
        Map<String, String> returnUrlMap = CelloParameterController.getCelloParameters('WKS_LOGICP_REG',lbsType,'FIN',boId, billToId);
        return returnUrlMap;
    }
    
    @AuraEnabled
    public static void updateOpp(String boId){
        system.debug('UpdateOpp@@');
        Opportunity opp = [Select id,Opportunity_Logistics_CPReviewStatus_FIN__c from opportunity where ID =: boId];
        List<Opportunity_Activity__c> opActList = [Select id,StartDate__c,Status__c from Opportunity_Activity__c 
                                                   where WhatId__c =: boId AND TransactionName__c = '2.4.4'];
        if(opp.Opportunity_Logistics_CPReviewStatus_FIN__c != 'CNFM'){
            opp.Opportunity_Logistics_CPReviewStatus_FIN__c = 'CNFM';
            update opp;
        }
        if(opActList.size() == 1){
            if(opActList[0].StartDate__c == null){
                opActList[0].StartDate__c = System.today();
            }
            if(opActList[0].Status__c == null){
                opActList[0].Status__c = 'In Progress';
            }
            if(opp.Opportunity_Logistics_CPReviewStatus_FIN__c == 'CNFM'){
                opActList[0].Status__c = 'Completed';
                opActList[0].EndDate__c = System.today();
            }
            system.debug('opActList[0]**' + opActList[0]);
           update opActList[0]; 
        } else if(opActList.size() == 0){
            Opportunity_Activity__c newOpAct = new Opportunity_Activity__c();
            newOpAct.WhatId__c = boId;
            newOpAct.StartDate__c = System.today();
            newOpAct.Status__c = 'In Progress';
            if(opp.Opportunity_Logistics_CPReviewStatus_FIN__c == 'CNFM'){
                newOpAct.Status__c = 'Completed';
                newOpAct.EndDate__c = System.today();
            }
            system.debug('newOpAct**' + newOpAct);
            insert newOpAct;
        }
    }
    @AuraEnabled
    public static List<Opportunity> getOppData(String boId){
        // V 1.1 Divyam Changes
    List<Opportunity> opprecord = [Select id,Opportunity_Logistics_CPReviewStatus_FIN__c,OpportunityCode__c from opportunity where ID =: boId];
       
        return opprecord;
    }
    
       @AuraEnabled
    public static String IsConfirmData(String boId , Boolean IsConfirm){
    Logistics_CP_Review_YesorNo__c LogiYesNoComfirm = [select IsConfirm__c from Logistics_CP_Review_YesorNo__c where Opportunity__c =: boId];
       LogiYesNoComfirm.IsConfirm__c = IsConfirm;
        update LogiYesNoComfirm;
        return 'IsConfirm Successfully updated';
            
    }
    
    @AuraEnabled
    public static String updateAndInsertLogisticsYesorNo(String boId , String L1 ,String L2,String L3,String L4) {
        if(boId!=null && boId!=''){
            List<Logistics_CP_Review_YesorNo__c> updatedData = new list<Logistics_CP_Review_YesorNo__c>();
            List<Logistics_CP_Review_YesorNo__c> logiYesNo = [select Level1__c,Level2__c,Level3__c,Level4__c from Logistics_CP_Review_YesorNo__c where Opportunity__c =: boId];
            System.debug('Opp yes no Data' +logiYesNo);
            if(logiYesNo.size() == 1) {
             Logistics_CP_Review_YesorNo__c logis = logiYesNo[0];
                logis.Level1__c = L1;
                logis.Level2__c = L2;
                System.debug('L2 got updated');
                logis.Level3__c = L3;
                logis.Level4__c = L4;
                updatedData.add(logis);
            } 
            else if(logiYesNo.size() == 0){
                Logistics_CP_Review_YesorNo__c logis = new Logistics_CP_Review_YesorNo__c(
                Level1__c = L1,
                Opportunity__c = boId );
                updatedData.add(logis);
            }
            upsert updatedData;
        } 
        return 'Succesully updated/inserted';
    }
    
    @AuraEnabled
    public static List<Logistics_CP_Review_YesorNo__c> getLevelvalue(String boId){
    List<Logistics_CP_Review_YesorNo__c> logidata = [select Level1__c,Level2__c,Level3__c,Level4__c, IsConfirm__c from Logistics_CP_Review_YesorNo__c where Opportunity__c =: boId];   
            return logidata;
        
        }
   
}