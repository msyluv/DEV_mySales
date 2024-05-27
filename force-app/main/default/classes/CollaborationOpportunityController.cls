/**
 * @description       : 
 * @author            : jiiiiii.park@partner.samsung.com.sds.dev
 * @group             : 
 * @last modified on  : 2023-15-02
 * @last modified by  : akash.g@samsung.com
 * Modifications Log 
 * Ver   Date         Author                                     Modification
 * 1.0   2020-11-25   jiiiiii.park@partner.samsung.com.sds.dev   Initial Version
 * 1.1   2023-07-02   akash.g@samsung.com                        MySales 112 (The BO created in the CSP type disables the Collaboration button (Cooperative BO cannot be created).)
 * 1.2   2023-15-02   akash.g@samsung.com                        MySales -110 (Collaboration BO Create - Cost Center Check logic Improvement)
**/
public without sharing class CollaborationOpportunityController {
    
    public virtual class CustomException extends Exception {}
    
    @AuraEnabled
    public static Map<String, String> collaborationCheck(String recordId){        

        Map<String, String> returnMap = new Map<String, String>();
        Opportunity oppty = [SELECT Id, Name, IsClosed, CompanyCode__c, Collaboration__c, CollaborationBOId__c, CollaborationInOut__c,CspMspType__c FROM Opportunity WHERE Id =: recordId];
        returnMap.put('OPPTY', JSON.serialize(oppty));

        if(oppty.IsClosed){ // 1. Opportunity가 Close된 경우
            returnMap.put('STATUS', 'ERROR');
            returnMap.put('MESSAGE', System.Label.COLLABO_MSG_0003); // If Opportunity is closed, collaboration is not possible.
            return returnMap;
        }
        
        if(oppty.CompanyCode__c == 'T100'){ // 2. 본사가 협업을 요청하는 경우
            returnMap.put('STATUS', 'ERROR');
            returnMap.put('MESSAGE', System.Label.COLLABO_MSG_0004); // HQ cannot request collaboration.
            return returnMap;
        }

        if(oppty.Collaboration__c){ // 3. 이미 협업을 진행한 경우
            returnMap.put('STATUS', 'ERROR');
            returnMap.put('MESSAGE', System.Label.COLLABO_MSG_0005); // This opportunity is already collaboration.
            return returnMap;
        }
        /**V1.1 -START  MySales 112 - For CSP can not create collaboration.**/
        if(oppty.CspMspType__c == 'CSP'){
            returnMap.put('STATUS', 'ERROR');
            returnMap.put('MESSAGE', System.Label.COLLABO_MSG_0010); // This opportunity is already collaboration.
            return returnMap;
        }
        /**V1.1 -END**/
        if(oppty.CompanyCode__c == null){ // 4. Compamy Code가 입력되어있지 않은 경우
            returnMap.put('STATUS', 'ERROR');
            returnMap.put('MESSAGE', System.Label.COLLABO_MSG_0008); // Company Code is empty. 
            return returnMap;
        }
        
        List<Opportunity_Activity__c> OpptyActList = [SELECT Id, Name, WhatId__c, WhatId__r.Name, TransactionName__c, Status__c 
                                                        FROM Opportunity_Activity__c 
                                                       WHERE WhatId__c =: recordId 
                                                         AND TransactionName__c = 'ZP21' 
                                                         AND (Status__c = 'Completed' OR Status__c = 'N/A')];
        if(OpptyActList.size() > 0){ // 4. 사기검이 이미 완료된 경우
            returnMap.put('STATUS', 'ERROR');
            returnMap.put('MESSAGE', System.Label.COLLABO_MSG_0006); // Collaboration is not possible if the Opportunity Review has already been completed.
            return returnMap;
        }else{
            returnMap.put('STATUS', 'SUCCESS');
            return returnMap;
        }
    }

    @AuraEnabled
    public static String saveCollaboration(String opptyId, String userId){
        String rtnMsg = '';
        System.debug('Ani Collab Entry@');
        
        String fieldString = Utils.retrieveFieldList('Opportunity');
        try{
            User user = [SELECT Id, Name, CurrencyIsoCode, EvKostl__c  FROM User WHERE Id =: userId];
            
            //손익부서 체크. 손익부서가 아닐경우 아래 메시지 출력.
            //해당 사용자는 지정할 수 없습니다. 공식 영업 부서에 소속된 영업대표로 지정하세요.
            CostCenter__c rowCostCenter = [SELECT Id, CostCenter__c, ZZCheck__c  FROM CostCenter__c WHERE CostCenter__c =: user.EvKostl__c];
            
            if(!rowCostCenter.ZZCheck__c){
                throw new CustomException(System.Label.COLLABO_MSG_0009);
            }
            
                
            Opportunity originOppty = Database.query('SELECT ' + fieldString + ' FROM Opportunity WHERE Id=\'' + opptyId + '\'');
            System.debug('originOppty: '+originOppty);
            String keyword = originOppty.CompanyCode__c + '-00';

            Account acc = [SELECT Id, Name, AccountNumber FROM Account WHERE AccountNumber =: keyword];
            Opportunity cloneOppty = originOppty.clone(false,true);
			System.debug('cloneOppty: '+cloneOppty);
            cloneOppty.OwnerId = userId;
            cloneOppty.AccountId = acc.Id;
            cloneOppty.CollaborationBOId__c = originOppty.Id;
            cloneOppty.CollaborationInOut__c = 'IN';
            cloneOppty.Amount = 0;
            // cloneOppty.CurrencyIsoCode = user.CurrencyIsoCode;
            cloneOppty.CurrencyIsoCode = 'USD';
            cloneOppty.SalesDepartment__c = null;
            cloneOppty.cPrimarySalesDepartment__c = null;
            cloneOppty.ProposalPM__c = null;
            cloneOppty.ProposalPM_User__c = null;
            cloneOppty.BiddingMethod__c = null;
            cloneOppty.CustDivision__c = null;
            cloneOppty.FK__c = null;
            cloneOppty.ParentFK__c = null;
            cloneOppty.BO1stRegisteredById__c = null;
            cloneOppty.BO1stRegistrationDate__c = null;
            System.debug('Before Insert clone Opp from Collaboration class : '+ cloneOppty);    
            insert cloneOppty;
            System.debug('Inserted clone Opp from Collaboration class : '+ cloneOppty);

            // Collaboration Opportunity TeamMember에 Origin Opportunity Owner를 추가
            OpportunityTeamMember cloneOpptyTeam = new OpportunityTeamMember(
                OpportunityId = cloneOppty.Id,
                UserId = originOppty.OwnerId,
                TeamMemberRole = 'Sales Rep'
            );
            insert cloneOpptyTeam;
           
            originOppty.CollaborationBOId__c = cloneOppty.Id;
            originOppty.CollaborationInOut__c = 'OUT';
            originOppty.IsOriginal__c = true;
            update originOppty;

            // Origin Opportunity TeamMember에 Collaboration Opportunity Owner를 추가
            OpportunityTeamMember originOpptyTeam = new OpportunityTeamMember(
                OpportunityId = originOppty.Id,
                UserId = userId,
                TeamMemberRole = 'Sales Rep'
            );
            insert originOpptyTeam;
            

            rtnMsg = 'SUCCESS';
        }catch(Exception e){
            System.debug('**********************************************************************');
            System.debug(System.LoggingLevel.ERROR, ' e.getLineNumber() : ' + e.getLineNumber());
            System.debug(System.LoggingLevel.ERROR, ' e.getTypeName() : ' + e.getTypeName());
            System.debug(System.LoggingLevel.ERROR, ' e.getMessage() : ' + e.getMessage());
            System.debug('**********************************************************************');
            //V1.2 ->START - MySales -110 error issue fix.
            String errMsg = e.getMessage(); 
            if(errMsg.contains('Collaboration BO could not be created because the department information of the selected sales representative is invalid')){
                errMsg = System.Label.OPPTY_ERR_024;
            }
            //V1.2 ->END
            throw new AuraHandledException(errMsg);
        }
        return rtnMsg;
    }
}