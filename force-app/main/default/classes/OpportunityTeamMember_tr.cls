/*********************************************************************************
* Description : OpportunityTeamMember TriggerHandler Class
* Author      : kwangjin.yu
* Modification Log
* ===============================================================
* Ver    Date      Author      Modification
* ===============================================================
  1.0   2022.03.21.  kwangjin.yu    Create
* 1.1   2022-03-22   hyunhak.roh@dkbmc.com				TeamMember에서 Owner와 동일 유저 입력시 등록 불가 처리.
***********************************************************************************/
public class OpportunityTeamMember_tr extends TriggerHandler{
    private static List<OpportunityTeamMember> listNew;
    private static Map<Id, OpportunityTeamMember> mapOld;   
            
    public OpportunityTeamMember_tr() {
        listNew = (List<OpportunityTeamMember>)Trigger.new;
        mapOld = (Map<Id, OpportunityTeamMember>)Trigger.oldMap;        
    }
    public override void beforeInsert() {       
        validOpportunityTeamMember(listNew);
    }    
    public override void beforeUpdate() {
        validOpportunityTeamMember(listNew);
    }
    public override void beforeDelete() {
        List<OpportunityTeamMember> rowOpportunityTeamMember = (List<OpportunityTeamMember>)trigger.old;
    }
    public override void afterInsert() {
        
    }    
    public override void afterUpdate() {
        
    }
    public override void afterDelete() {
        
    }

    //TeamMember에서 Owner와 동일 유저 입력시 등록 불가 처리.
    private static void validOpportunityTeamMember(List<OpportunityTeamMember> objList){
       	/*
            1. Opportunity 를 주어진 OpportunityId 로 검색
            2. 1에서 검색한 Opportunity 의 OwnerId 와 OpportunityTeamMember 의 UserId 가 동일한 유저인지 체크
            3. 2에서 체크한 조건인 경우, 메세지 처리 및 불가 처리
        */
        system.debug('### validOpportunityTeamMember Start~~~!!!');
        
        Set<String> opptyIdSet = new Set<String>();
        Map<id, id> chkMap = new Map<id, id>();		// UserId, OpportunityId 
        
        for(OpportunityTeamMember opptyTeamMember : objList){
            //
            if(opptyTeamMember.OpportunityId != null){
                opptyIdSet.add(opptyTeamMember.OpportunityId);
                
                chkMap.put(opptyTeamMember.UserId, opptyTeamMember.OpportunityId);
            }
        }
         
        List<Opportunity> opptyList = [SELECT Id, OwnerId, ProposalPM_User__c  FROM Opportunity WHERE Id = :opptyIdSet];
        Set<Id> setOpptyUser = new Set<Id>();
        for(Opportunity row : opptyList){
            setOpptyUser.add(row.OwnerId);
        }
        
        system.debug('### validOpportunityTeamMember, opptyList size => ' + opptyList.size());
        
        //
        for(Integer idx = 0; idx < objList.size(); idx++) 
        {
            //
            if(setOpptyUser.contains(objList[idx].UserId))
            {
                //
                system.debug('### validOpportunityTeamMember, Error Happend ');
                //
                objList[idx].addError(System.Label.OPPTYTMMB_MSG_001);		//사업기회의 영업대표와 동일한 팀 구성원 추가는 불가합니다.
                //objList[idx].addError('It is not possible to add opportunity team members of the same team as the sales representative of the business opportunity.');
            }
        }
        
        //
        system.debug('### validOpportunityTeamMember End~~~!!!');
    }
}