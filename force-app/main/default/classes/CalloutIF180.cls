public class CalloutIF180 {
 
    @Future(callout = true)
    public static void CallIF180( Set<ID> oppID){
        IF_OpportunityActivityInfoCallOut.doCalloutSendingOpportunityActivityInfo(oppID);
    }
}