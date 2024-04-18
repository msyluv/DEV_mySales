/**
 * @description       : 
 * @author            : vikrant.ks@samsung.com
 * @group             : 
 * @last modified on  : 02-26-2024
 * @last modified by  : vikrant.ks@samsung.com
 * Modifications Log 
 * Ver   Date         Author            			   Modification
 * 1.0   02-26-2024   vikrant.ks@samsung.com           Initial Version (MYSALES-447)
**/
public class DeliveryProbabilityCmpController{
    @AuraEnabled    
    public static String DeliveryProbabilityList(String oppId){
        
        List<Delivery_Probabiliy__c> DP = [Select DeliveryActivity__c from Delivery_Probabiliy__c where Opportunity__c = :oppId Limit 1];
        if(DP.size()>0){
        	return DP[0].DeliveryActivity__c;
        }
        return '';
    }
}