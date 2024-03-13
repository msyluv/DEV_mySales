/*********************************************************************************
* Description : Account Trigger
* Author      : kwangjin.yu
* Modification Log
* ===============================================================
* Ver    Date      Author      Modification
* ===============================================================
  1.0    2022.03. 21.  kwangjin.yu    Create
  1.1    2023.12. 05.  atul.k1@samsung.com    IF-038 Modification related to billing authority(MYSALES-368)
***********************************************************************************/
trigger OpportunityTeamMember on OpportunityTeamMember (before insert, before update, before delete, after insert, after update, after delete) {
    
    //new OpportunityTeamMember_tr().run();
    
    Integer i = 0;
    // V 1.1 Start (MYSALES-368)
    if(trigger.isInsert && trigger.isBefore){
        //validOpportunityTeamMember(listNew);
        List<OpportunityTeamMember> OppTeamLst = new List<OpportunityTeamMember>();
        for(OpportunityTeamMember eachOppTeam : trigger.new){
            if(eachOppTeam.TeamMemberRole == 'Billing Manager' || eachOppTeam.TeamMemberRole ==  '청구 담당자'){
                OppTeamLst.add(eachOppTeam);
            }
            
        }
        if(!OppTeamLst.isEmpty()){
            ValidCompanyCode(OppTeamLst);
        }
        
        
    }
    if(trigger.isUpdate && trigger.isBefore){
        //validOpportunityTeamMember(listNew);
       List<OpportunityTeamMember> OppTeamLst = new List<OpportunityTeamMember>();
        for(OpportunityTeamMember eachOppTeam : trigger.new){
            if(eachOppTeam.TeamMemberRole == 'Billing Manager' || eachOppTeam.TeamMemberRole =='청구 담당자'){
                OppTeamLst.add(eachOppTeam);
            }
            
        }
        if(!OppTeamLst.isEmpty()){
            ValidCompanyCode(OppTeamLst);
        }
        
    }
    private static void ValidCompanyCode(List<OpportunityTeamMember> objList){
         system.debug('qwerty');
         Set<ID> opptyIdSet = new Set<ID>();
         Set<ID> userIDSet = new Set<ID>();
         Map<id,Opportunity> oppdetailsMap = new  Map<id,Opportunity>();
         Map<id,User> userdetailsMap = new  Map<id,User>(); 
        //Map<id, id> chkMap = new Map<id, id>();		
         if(!objList.isEmpty()){
              for(OpportunityTeamMember opptyTeamMember : objList){
                 if(opptyTeamMember.OpportunityId != null){
                opptyIdSet.add(opptyTeamMember.OpportunityId);
                }
                  if(opptyTeamMember.UserID != null){
                     userIDSet.add(opptyTeamMember.UserID ); 
                  }
                  
             }
              if(userIDSet != null){
                  
            	List<User> userdetails = [SELECT id,name,CompanyCode__c FROM User Where id IN: userIDSet];
                  for(User eachUser : userdetails){
                      userdetailsMap.put(eachUser.id,eachUser);
                  }
              }
             if(opptyIdSet != null){
                  
                 List<Opportunity> oppdeatils = [SELECT Id, OwnerId, ProposalPM_User__c,CompanyCode__c  FROM Opportunity WHERE Id = :opptyIdSet];
                 for(Opportunity eachOpp : oppdeatils){
                      oppdetailsMap.put(eachOpp.id,eachOpp);
                  }
             }
               for(OpportunityTeamMember opptyTeamMember : objList){
                   if(opptyTeamMember.TeamMemberRole == 'Billing Manager' || opptyTeamMember.TeamMemberRole == '청구 담당자'){
                   if(userdetailsMap.containsKey(opptyTeamMember.UserId) && oppdetailsMap.containsKey(opptyTeamMember.OpportunityId)){
                       if(userdetailsMap.get(opptyTeamMember.UserId).CompanyCode__c != oppdetailsMap.get(opptyTeamMember.OpportunityId).CompanyCode__c){
                           opptyTeamMember.addError(System.Label.BO_Team_Mamber_Billing_Manager_Msg);
                       }
                   }
                   }
               }
             
             
         }
     }
     // V 1.1 End (MYSALES-368)
    
}