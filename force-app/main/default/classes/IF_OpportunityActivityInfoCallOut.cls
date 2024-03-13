/**
* @description       : Rest API Callout to Interact 
* @author            : kajal.c@samsung.com
* @group             : 

* @last modified on  : 11-05-2023
* @last modified by  : anish.jain@partner.samsung.com
* Modifications Log 
* Ver   Date         Author                    Modification
* 1.0   2023-02-28   kajal.c@samsung.com    Initial Version
* 1.1   11-05-2023   anish.jain@partner.samsung.com   MySales - 216
**/

public class IF_OpportunityActivityInfoCallOut implements Database.AllowsCallouts {
    public static OutputHeader doCalloutSendingOpportunityActivityInfo(Set<Id> oppIDList){
        System.debug('Entry 1**');
        String APEX_CLASS   = 'IF_OpportunityActivityInfoCallOut';
        String METHOD_NAME_180  = 'doCalloutSendingOpportunityActivityInfo';
        String INTERFACE_ID_180 = 'IF-180';
        Map<String,Object> resMap = new Map<String,Object>();
        IF_Log log = new IF_Log();
        String guId = '';
        guId = IF_KnoxChatSendController.generateUid();
        try{
            List<Opportunity> opList = [Select id,OpportunityCode__c,CompanyCode__c,Opportunity_Review_VRB_Type__c,
                                        (select id,EndDate__c,Status__c,TransactionName__c from BO_Activity__r) 
                                        from opportunity where id IN :oppIDList]; //Added by Anish- v 1.1
            System.debug('KajalOppList size is' +opList.size());
            Map<Id,List<Opportunity_Activity__c>> oppactmap= new Map<Id,List<Opportunity_Activity__c>>();
            Map<Id,String> oppMap= new Map<Id,String>();  //Added by Anish- v 1.1
            for(Opportunity opp : opList){
                oppactmap.put(opp.Id,opp.BO_Activity__r);
                oppMap.put(opp.Id,opp.Opportunity_Review_VRB_Type__c); //Added by Anish- v 1.1
                System.debug('Act Coming' +opp.BO_Activity__r);
                System.debug('Map Size is' +oppactmap.size());
                System.debug('Map value is' +oppactmap);
            }
            List<InputClass_180> input180List = new  List<InputClass_180>();
            for(Opportunity opp1: opList){
                InputClass_180 input180 = new InputClass_180();
                input180.OPPORTUNITY_ID = opp1.Id;
                input180.OPPORTUNITY_CODE = opp1.OpportunityCode__c;
                input180.COMPANY_CODE = opp1.CompanyCode__c;
                List<Opportunity_Activity__c> oppact1 = oppactmap.get(opp1.Id);
                for(Opportunity_Activity__c oppAct : oppact1){
                    System.debug('KajalTestoppact1 size is' +oppAct);
                    if(oppAct.transactionName__c == 'XP99') {
                        if(oppAct.Status__c == 'Completed'){
                            input180.SCP_PRICE_SIMULATION_STATUS = oppAct.Status__c;
                        }
                        String XP99EndDate = String.valueof(oppAct.EndDate__c);
                        if(XP99EndDate != null && XP99EndDate !='') {
                            input180.SCP_PRICE_SIMULATION_ENDDATE = XP99EndDate.replaceAll('-', '');
                        }
                    }
                    if(oppAct.transactionName__c == 'ZP21') {
                      //Added by Anish- v 1.1
                        if(oppAct.Status__c == 'In Progress' && oppMap.get(opp1.Id) == '30'){
                           input180.REVIEW_OPPORTUNITY_STATUS = null; 
                           input180.REVIEW_OPPORTUNITY_ENDDATE = null;
                        }
                        else{
                        if(oppAct.Status__c == 'Completed'){
                            input180.REVIEW_OPPORTUNITY_STATUS = oppAct.Status__c;
                        }
                        String ZP21EndDate = String.valueof(oppAct.EndDate__c);
                        if(ZP21EndDate != null && ZP21EndDate !='') {
                            input180.REVIEW_OPPORTUNITY_ENDDATE = ZP21EndDate.replaceAll('-', '');
                        }
                        }
                    }
                    if(oppAct.transactionName__c == 'XP61') {
                        if(oppAct.Status__c == 'Completed'){
                            input180.ST_COMMITTEE_BIZ_REQUEST_STATUS = oppAct.Status__c;
                        }
                        String XP61EndDate = String.valueof(oppAct.EndDate__c);
                        if(XP61EndDate != null && XP61EndDate !='') {
                            input180.ST_COMMITTEE_BIZ_REQUEST_ENDDATE = XP61EndDate.replaceAll('-', '');
                        }
                    }
                    if(oppAct.transactionName__c == 'XP62') {
                        if(oppAct.Status__c == 'Completed'){
                            input180.ST_COMMITTEE_BIZ_PRICING_STATUS = oppAct.Status__c;
                        }
                        String XP62EndDate = String.valueof(oppAct.EndDate__c);
                        if(XP62EndDate != null && XP62EndDate !='') {
                            input180.ST_COMMITTEE_BIZ_PRICING_ENDDATE = XP62EndDate.replaceAll('-', '');
                        }
                    }
                    if(oppAct.transactionName__c == 'XP63') {
                        if(oppAct.Status__c == 'Completed'){
                            input180.ST_COMMITTEE_BIZ_APPROVAL_STATUS = oppAct.Status__c;
                        }
                        String XP63EndDate = String.valueof(oppAct.EndDate__c);
                        if(XP63EndDate != null && XP63EndDate !='') {
                            input180.ST_COMMITTEE_BIZ_APPROVAL_ENDDATE = XP63EndDate.replaceAll('-', '');
                        }
                    }
                    if(oppAct.transactionName__c == 'XP71') {
                        if(oppAct.Status__c == 'Completed'){
                            input180.ST_COMMITTEE_BIDDING_REQUEST_STATUS = oppAct.Status__c;
                        }
                        String XP71EndDate = String.valueof(oppAct.EndDate__c);
                        if(XP71EndDate != null && XP71EndDate !='') {
                            input180.ST_COMMITTEE_BIDDING_REQUEST_ENDDATE = XP71EndDate.replaceAll('-', '');
                        }
                    }
                    if(oppAct.transactionName__c == 'XP72') {
                        if(oppAct.Status__c == 'Completed'){
                            input180.ST_COMMITTEE_BIDDING_PRICING_STATUS = oppAct.Status__c;
                        }
                        String XP72EndDate = String.valueof(oppAct.EndDate__c);
                        if(XP72EndDate != null && XP72EndDate !='') {
                            input180.ST_COMMITTEE_BIDDING_PRICING_ENDDATE = XP72EndDate.replaceAll('-', '');
                        }
                    }
                    if(oppAct.transactionName__c == 'XP73') {
                        if(oppAct.Status__c == 'Completed'){
                            input180.ST_COMMITTEE_BIDDING_APPROVAL_STATUS = oppAct.Status__c;
                        }
                        String XP73EndDate = String.valueof(oppAct.EndDate__c);
                        if(XP73EndDate != null && XP73EndDate !='') {
                            input180.ST_COMMITTEE_BIDDING_APPROVAL_ENDDATE = XP73EndDate.replaceAll('-', '');
                        }
                    }
                    if(oppAct.transactionName__c == 'ZP32') {
                        if(oppAct.Status__c == 'Completed'){
                            input180.REQUEST_PRESALES_RESOURCES_STATUS = oppAct.Status__c;
                        }
                        String ZP32EndDate = String.valueof(oppAct.EndDate__c);
                        if(ZP32EndDate != null && ZP32EndDate !='') {
                            input180.REQUEST_PRESALES_RESOURCES_ENDDATE = ZP32EndDate.replaceAll('-', '');
                        }
                    }
                    if(oppAct.transactionName__c == 'XP31') {
                        if(oppAct.Status__c == 'Completed'){
                            input180.RECEIVE_RFP_STATUS = oppAct.Status__c;
                        }
                        String XP31EndDate = String.valueof(oppAct.EndDate__c);
                        if(XP31EndDate != null && XP31EndDate !='') {
                            input180.RECEIVE_RFP_ENDDATE = XP31EndDate.replaceAll('-', '');
                        }
                    }
                    if(oppAct.transactionName__c == 'ZP61') {
                        if(oppAct.Status__c == 'Completed'){
                            input180.SUBMIT_PROPOSAL_STATUS = oppAct.Status__c;
                        }
                        String ZP61EndDate = String.valueof(oppAct.EndDate__c);
                        if(ZP61EndDate != null && ZP61EndDate !='') {
                            input180.SUBMIT_PROPOSAL_ENDDATE =  ZP61EndDate.replaceAll('-', '');
                        }
                    }
                    if(oppAct.transactionName__c == 'XP41') {
                        if(oppAct.Status__c == 'Completed'){
                            input180.PRESENTATION_STATUS = oppAct.Status__c;
                        }
                        String XP41EndDate = String.valueof(oppAct.EndDate__c);
                        if(XP41EndDate != null && XP41EndDate !='') {
                            input180.PRESENTATION_ENDDATE = XP41EndDate.replaceAll('-', '');
                        }
                    }
                    if(oppAct.transactionName__c == 'XP42') {
                        if(oppAct.Status__c == 'Completed'){
                            input180.PREFERRED_BIDDER_STATUS = oppAct.Status__c;
                        }
                        String XP42EndDate = String.valueof(oppAct.EndDate__c);
                        if(XP42EndDate != null && XP42EndDate !='') {
                            input180.PREFERRED_BIDDER_ENDDATE = XP42EndDate.replaceAll('-', '');
                        }
                    }
                    if(oppAct.transactionName__c == 'XP43') {
                        if(oppAct.Status__c == 'Completed'){
                            input180.CUSTOMER_APPROVAL_STATUS = oppAct.Status__c;
                        }
                        String XP43EndDate = String.valueof(oppAct.EndDate__c);
                        if(XP43EndDate != null && XP43EndDate !='') {
                            input180.CUSTOMER_APPROVAL_ENDDATE = XP43EndDate.replaceAll('-', '');
                        }
                    }
                    if(oppAct.transactionName__c == 'XP44') {
                        if(oppAct.Status__c == 'Completed'){
                            input180.NEGOTIATION_STATUS = oppAct.Status__c;
                        }
                        String XP44EndDate = String.valueof(oppAct.EndDate__c);
                        if(XP44EndDate != null && XP44EndDate !='') {
                            input180.NEGOTIATION_ENDDATE = XP44EndDate.replaceAll('-', '');
                        }
                    }
                    if(oppAct.transactionName__c == 'XP51') {
                        if(oppAct.Status__c == 'Completed'){
                            input180.CONFIRM_COST_STATUS = oppAct.Status__c;
                        }
                        
                        String XP51EndDate = String.valueof(oppAct.EndDate__c);
                        if(XP51EndDate != null && XP51EndDate !='') {
                            input180.CONFIRM_COST_ENDDATE = XP51EndDate.replaceAll('-', '');
                        }
                    }
                    if(oppAct.transactionName__c == 'XP52') {
                        if(oppAct.Status__c == 'Completed'){
                            input180.LEGAL_REVIEW_STATUS = oppAct.Status__c;
                        }
                        String XP52EndDate = String.valueof(oppAct.EndDate__c);
                        if(XP52EndDate != null && XP52EndDate !='') {
                            input180.LEGAL_REVIEW_ENDDATE = XP52EndDate.replaceAll('-', '');
                        }
                    }
                    if(oppAct.transactionName__c == 'ZP82') {
                        if(oppAct.Status__c == 'Completed'){
                            input180.CONTRACT_APPROVAL_STATUS = oppAct.Status__c;
                        }
                        String ZP82EndDate = String.valueof(oppAct.EndDate__c);
                        if(ZP82EndDate != null && ZP82EndDate !='') {
                            input180.CONTRACT_APPROVAL_ENDDATE = ZP82EndDate.replaceAll('-', '');
                        }
                    }
                    if(oppAct.transactionName__c == 'XP57') {
                        if(oppAct.Status__c == 'Completed'){
                            input180.ARCHIVE_CONTRACT_STATUS = oppAct.Status__c;
                        }
                        String ARCEndDate = String.valueof(oppAct.EndDate__c);
                        if(ARCEndDate != null && ARCEndDate !='') {
                            input180.ARCHIVE_CONTRACT_ENDDATE = ARCEndDate.replaceAll('-', '');
                        }
                    }
                    if(oppAct.transactionName__c == 'ZPZ3') {
                        if(oppAct.Status__c == 'Completed'){
                            input180.AGENCY_CONTRACT_EXCEPTION_STATUS = oppAct.Status__c;
                        }
                        String AGEEndDate = String.valueof(oppAct.EndDate__c);
                        if(AGEEndDate != null && AGEEndDate !='') {
                            input180.AGENCY_CONTRACT_EXCEPTION_ENDDATE = AGEEndDate.replaceAll('-', '');
                        }
                    }
                }
                input180List.add(input180);
            }
            OutputHeader outHeader = new OutputHeader();
            outHeader.Opportunity_Activity  = input180List;
            System.debug('After input180List'+input180List);   
            return outHeader;
        } catch(Exception e){
            system.debug('Exception e occur' + e.getMessage());
            IF_Log.InterfaceLog ifLog;
            ifLog = new IF_Log.InterfaceLog(INTERFACE_ID_180, guId, APEX_CLASS, METHOD_NAME_180, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')),e);
            ID iFLogId = log.createLog2(ifLog);
            system.debug('iFLogId **' + iFLogId);
            return null;
        } 
    }
    public class InputClass_180{
        public String OPPORTUNITY_ID;
        public String OPPORTUNITY_CODE;
        public String COMPANY_CODE;
        public String SCP_PRICE_SIMULATION_STATUS;
        public String SCP_PRICE_SIMULATION_ENDDATE;
        public String REVIEW_OPPORTUNITY_STATUS;
        public String REVIEW_OPPORTUNITY_ENDDATE;
        public String ST_COMMITTEE_BIZ_REQUEST_STATUS;
        public String ST_COMMITTEE_BIZ_REQUEST_ENDDATE;
        public String ST_COMMITTEE_BIZ_PRICING_STATUS;
        public String ST_COMMITTEE_BIZ_PRICING_ENDDATE;
        public String ST_COMMITTEE_BIZ_APPROVAL_STATUS;
        public String ST_COMMITTEE_BIZ_APPROVAL_ENDDATE;
        public String ST_COMMITTEE_BIDDING_REQUEST_STATUS;
        public String ST_COMMITTEE_BIDDING_REQUEST_ENDDATE;
        public String ST_COMMITTEE_BIDDING_PRICING_STATUS;
        public String ST_COMMITTEE_BIDDING_PRICING_ENDDATE;
        public String ST_COMMITTEE_BIDDING_APPROVAL_STATUS;
        public String ST_COMMITTEE_BIDDING_APPROVAL_ENDDATE;
        public String REQUEST_PRESALES_RESOURCES_STATUS;
        public String REQUEST_PRESALES_RESOURCES_ENDDATE;
        public String RECEIVE_RFP_STATUS;
        public String RECEIVE_RFP_ENDDATE;
        public String SUBMIT_PROPOSAL_STATUS;
        public String SUBMIT_PROPOSAL_ENDDATE;
        public String PRESENTATION_STATUS;
        public String PRESENTATION_ENDDATE;
        public String PREFERRED_BIDDER_STATUS;
        public String PREFERRED_BIDDER_ENDDATE;
        public String CUSTOMER_APPROVAL_STATUS;
        public String CUSTOMER_APPROVAL_ENDDATE;
        public String NEGOTIATION_STATUS;
        public String NEGOTIATION_ENDDATE;
        public String CONFIRM_COST_STATUS;
        public String CONFIRM_COST_ENDDATE;
        public String LEGAL_REVIEW_STATUS;
        public String LEGAL_REVIEW_ENDDATE;
        public String CONTRACT_APPROVAL_STATUS;
        public String CONTRACT_APPROVAL_ENDDATE;
        public String ARCHIVE_CONTRACT_STATUS;
        public String ARCHIVE_CONTRACT_ENDDATE;
        public String AGENCY_CONTRACT_EXCEPTION_STATUS;
        public String AGENCY_CONTRACT_EXCEPTION_ENDDATE;
    }
    
    public class OutputHeader{
        public List<InputClass_180> Opportunity_Activity;
    }
}