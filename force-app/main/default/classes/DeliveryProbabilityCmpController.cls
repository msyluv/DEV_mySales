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