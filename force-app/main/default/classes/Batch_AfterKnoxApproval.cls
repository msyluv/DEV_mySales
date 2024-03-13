/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2021-10-07
 * @last modified by  : younghoon.kim@dkbmc.com
**/
global class Batch_AfterKnoxApproval implements DataBase.Batchable<SObject>, DataBase.stateful{
    private List<KnoxApproval__c> new_KnoxList = new List<KnoxApproval__c>();
    private Map<String, String> old_KnoxMap = new Map<String, String>(); // Status__c, syncFlag__c

    global DataBase.QueryLocator start(DataBase.BatchableContext BC){
        DateTime targetTime = (System.now()).addHours(-1);
        String query_Select = ' SELECT ';
        String query_Fields = Utils.retrieveFieldList('KnoxApproval__c');
        String query_From   = ' FROM KnoxApproval__c ';
        String query_Where  = ' WHERE LastModifiedDate > :targetTime';
        String query_Order  = '';

        return DataBase.getQueryLocator(query_Select + query_Fields + query_From + query_Where + query_Order);
    }
    
    global void execute(DataBase.BatchableContext BC, List<KnoxApproval__c> scope){
        new_KnoxList = scope;

        Set<String> knoxIdSet = new Set<String>();
        for(KnoxApproval__c knox : scope){
            knoxIdSet.add(knox.Id);
        }

        List<KnoxApproval__History> knoxHistoryList = [SELECT Id, ParentId, CreatedById, CreatedDate, Field, DataType, OldValue, NewValue 
                                                         FROM KnoxApproval__History 
                                                        WHERE Field IN ('Status__c', 'syncFlag__c') 
                                                          AND ParentId =: knoxIdSet
                                                        ORDER BY CreatedDate DESC];
        if(knoxHistoryList.size() > 0){
            for(KnoxApproval__History kh : knoxHistoryList){
                if(kh.Field == 'Status__c') if(old_KnoxMap.get(kh.ParentId + '_Status') == null) old_KnoxMap.put(kh.ParentId + '_Status', String.valueOf(kh.OldValue));
                if(kh.Field == 'syncFlag__c') if(old_KnoxMap.get(kh.ParentId + '_SyncFlag') == null) old_KnoxMap.put(kh.ParentId + '_SyncFlag', String.valueOf(kh.OldValue));
            }
        }


    }
    
    global void finish(DataBase.BatchableContext BC){
        
    }

    /*
    public void opptyAutoWonIdSet(List<KnoxApproval__c> newList){
        // 수주품의(최초) 결재 승인 후 상태 마감(WON) 변경 기준
        // 1. 단품 사업기회(입력된 솔루션의 사업속성(BizAttribute)가 S124, S125로 구성된 Oppty)
        // 2. 계약대행 사업기회(계약대행 check X , 계약 대행 예외 check false인 사업기회)
        // 3. 자회사/해외법인 사업기회의 경우
        Set<Id> wonUpdateOpptyIdSet = new Set<Id>();

        Set<String> opptyIdSet = new Set<String>();
        for(KnoxApproval__c knox : newList){
            if(old_KnoxMap.get(knox.Id + '_Status') == null || String.isBlank(knox.Opportunity__c) || String.isBlank(knox.OpportunityActivity__c) ) continue;  // insert Pass
            if(old_KnoxMap.get(knox.Id + '_Status') != null && (old_KnoxMap.get(knox.Id + '_Status') == knox.Status__c)) continue;  // Status 가 바뀌지 않은 경우 Pass
            if(knox.Status__c != KnoxApprovalHelper.KNOX_APPROVAL_STATUS_COMPLETED) continue;   // 완료가 아닌 경우
            
            opptyIdSet.add(knox.Opportunity__c);
        }
        
        // 사업기회 정보 조회
        Map<Id, Opportunity> opptyMap = new Map<Id, Opportunity>([SELECT Id, Name, OpportunityStatus__c , AgencyContract__c, AgencyContractException__c, CompanyCode__c, StageName FROM Opportunity WHERE Id IN :opptyIdSet]);

        // 최초 수주품의 완료된 knox Approval 정보 조회
        List<AggregateResult> knoxApprovalList =  [
                SELECT Opportunity__c 
                FROM KnoxApproval__c 
                WHERE Opportunity__c = :opptyIdSet
                  AND OpportunityActivity__r.TransactionName__c = :OpportunityActivityHelper.ACT_CODE_CONTRACT_APPROVAL
                  AND Status__c = :KnoxApprovalHelper.KNOX_APPROVAL_STATUS_COMPLETED
                GROUP BY Opportunity__c 
                HAVING COUNT(Status__c) = 1         ];

        //최초 수주품의 완료된 사업기회 recordId List
        Set<String> opptyIdList = new Set<String>();  
        for(AggregateResult knox: knoxApprovalList){
            opptyIdList.add((String)knox.get('Opportunity__c'));
        }
        
        // 단품 사업기회 찾기
        List<Solution__c> solutionList = [SELECT Id, Name, Opportunity__c, BizAttribute__c, BizAttribute__r.Code__c FROM Solution__c WHERE Opportunity__c IN :opptyIdList AND SendSAP__c = true AND DeletionFlag__c = false ORDER BY Opportunity__c];
        Map<String,Boolean> OpptySolBizMap = new Map<String,Boolean>();

        for(String Id: opptyIdList){
            Integer solutionCnt = 0;       // SAP전송 된 솔루션 갯수
            Integer notSigleBiz = 0;       // 단품유형(S124, S125)이 아닌 bizAatribute 갯수
            for(Solution__c sol: solutionList){
                if(Id == sol.Opportunity__c){
                    solutionCnt ++;
                    if(sol.BizAttribute__r.Code__c != 'S124' && sol.BizAttribute__r.Code__c != 'S125'){
                        notSigleBiz++;
                    }
                }
            }

            if(solutionCnt > 0){
                if(notSigleBiz == 0) OpptySolBizMap.put(Id,true);  //단품유형만 있는 솔루션
                else OpptySolBizMap.put(Id,false);
            }else{
                //전송된 솔루션갯수가 0이면 update 하지않음.
                OpptySolBizMap.put(Id,false);
            }
        }
        
        // 사업기회 stageName update
        Boolean stageUpdate = false;
        for(AggregateResult knox: knoxApprovalList){
            Opportunity oppty = opptyMap.get((String)knox.get('Opportunity__c'));
            if(oppty.StageName == OpportunityActivityHelper.OPP_STAGE_CLEANSED) continue;   //2021.07.05 seonju.jin / StageName Cleansed(Z08) 제외

            //1. 단품 사업기회
            if(OpptySolBizMap.containsKey(oppty.Id)){
                if(OpptySolBizMap.get(oppty.Id)) stageUpdate = true;
            }
            
            //2. 계약대행 사업기회
            if(oppty.AgencyContract__c && !oppty.AgencyContractException__c){
                stageUpdate = true;
            }
            
            //3. 자회사/해외법인 사업기회의 경우
            if(oppty.CompanyCode__c != 'T100'){
                stageUpdate = true;
            }
            
            // Won 업데이트 할 사업기회 대상 Id Add
            if(stageUpdate){
                wonUpdateOpptyIdSet.add(oppty.Id);
            }
        }

        //사업기회 stageName Won할 대상인 Knox Approval Id Set 반환
        return wonUpdateOpptyIdSet;
    }
    */
}