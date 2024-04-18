/**
 * @description       : Opportunity 상황판 조회
 * @author            : wonjune.oh@partner.samsung.com
 * @group             : 
 * @last modified on  : 2024-03-20
 * @last modified by  : vikrant.ks@samusng.com  
 * Modifications Log 
 * Ver   Date         Author                           Modification
 * 1.0   2020-10-29   wonjune.oh@partner.samsung.com   Initial Version
 * 1.1   2023-10-27   gitesh.s@samsung.com             SCP Quotation Activity color change (MYSALES-339)
 * 1.3   2024-01-30   atul.k1@samusng.com              Task - (IT) Add TXP link Button in BO Activity (MYSALES-421)
 * 1.4   2024-03-20   vikrant.ks@samusng.com           Task - (IT) Add BO Priority Check List Button in BO Activity (MYSALES-468)
**/
public without sharing class OpportunityActivityPanelController{
    
    public static Boolean canClickSwitch = FunctionSwitch__c.getInstance(UserInfo.getUserId()).OpportunityActivityPanel__c; // 상황판 클릭 가능 여부
    
    @AuraEnabled
    public static Map<String, Object> initComponent(String recordId, Boolean isDelTempAct){
        Map<String,List<List<ActivityItem>>> panelMap = new Map<String,List<List<ActivityItem>>>();
        Opportunity oppty = new Opportunity();
        String recordTypeDevName = '';
        Boolean hasEditAccess = [SELECT     RecordId, HasEditAccess  
                                 FROM       UserRecordAccess 
                                 WHERE      UserId = :UserInfo.getUserId() 
                                            AND RecordId = :recordId].HasEditAccess;
        SCPSimulation__c scpList = new SCPSimulation__c();
        Boolean isSubsidiary = false; //V 1.3 MYSALES-421
	    Boolean isSandbox = Utils.getIsSandbox(); // V 1.4 MYSALES-468

        Map<String, Object> resultMap = new Map<String, Object>{
            'panelList'     => panelMap,
            'oppty'         => oppty,
            'recordTypeDevName'    => recordTypeDevName,
            'hasEditAccess' => hasEditAccess,
            'canClickSwitch' => canClickSwitch,
            'isSubsidiary'          => isSubsidiary, // V 1.3 MYSALES-421
	        'isSandbox'          => isSandbox, // V 1.4 MYSALES-468
            // v1.1 - Gitesh Saini (MYSALES-339)
            'scpList'       => scpList
        };

        try{
            // 임시로 저장된 Status가 빈 값인 Activity 삭제
            System.debug('OpportunityActivityPanelController, initComponent recordId ' + recordId);
            System.debug('OpportunityActivityPanelController, initComponent isDelTempAct ' + isDelTempAct);
            if(isDelTempAct) OpportunityActivityHelper.deleteTempOpportunityActivity(recordId);

            // Get Opportunity Info
      //      String opptySOQL = Utils.getQueryAddSelect('Opportunity', 'RecordType.DeveloperName, Account.AccountNumber, cLeadID__r.CreatedDate', ' WHERE  Id = \'' + recordId + '\'', false);
       // V 1.4 Added Collaboration field in the query.
            String opptySOQL = Utils.getQueryAddSelect('Opportunity', 'RecordType.DeveloperName, Account.AccountNumber, cLeadID__r.CreatedDate', ' WHERE  Id = \'' + recordId + '\'', false);
            List<Opportunity> opptyList = System.Database.query(opptySOQL);
            System.debug('### opptyList.size() ' + opptyList.size());
            
            if(opptyList.size() > 0) {
                oppty = opptyList[0];
                recordTypeDevName = oppty.RecordType.DeveloperName;

                List<MasterActivity__c> masterActList = Utils.queryObjectWithoutRichText('MasterActivity__c'
                                                        , 'WHERE ObjectApiName__c	 = \'Opportunity\' AND IsActive__c = true AND Type__c = \'' + recordTypeDevName + '\''
                                                        + ' ORDER BY Stage__c , Order__c'
                                                    );

                panelMap = arrangement(masterActList,recordId);
                isSubsidiary = Utils.isSubsidiary(oppty.CompanyCode__c); // V 1.3 MYSALES-421
            }

            // v1.1 - Gitesh Saini (MYSALES-339)
            List<SCPSimulation__c> scp = [SELECT Id, BOCode__c, quotStat__c, Opportunity__c FROM SCPSimulation__c WHERE Opportunity__c =: recordId ORDER BY LastModifiedDate DESC];
            if(scp.size() > 0){
                scpList = scp[0];
            }

            resultMap = new Map<String, Object>{
                'panelList'     => panelMap,
                'oppty'         => oppty,
                'recordTypeDevName'    => recordTypeDevName,
                'hasEditAccess' => hasEditAccess,
                'canClickSwitch' => canClickSwitch,
                'isSubsidiary'   => isSubsidiary, //V 1.3 MYSALES-421
                'scpList'       => scpList,
                'isSandbox'          => isSandbox // V 1.4 MYSALES-468
            };
            // v1.1 - Gitesh Saini
            
        } catch (Exception e) {
            // "Convert" the exception into an AuraHandledException
            System.debug(System.LoggingLevel.ERROR, e.getLineNumber());
            System.debug(System.LoggingLevel.ERROR, e.getTypeName());
            System.debug(System.LoggingLevel.ERROR, e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        return resultMap;
    }

    @AuraEnabled
    public static Map<String,List<List<ActivityItem>>> arrangement(List<MasterActivity__c> masterActList,String recordId){
        List<MasterActivity__c> position1 = new List<MasterActivity__c>();
        List<MasterActivity__c> position2 = new List<MasterActivity__c>();
        Map<String,List<List<ActivityItem>>> result = new Map<String,List<List<ActivityItem>>>();
        
        for(MasterActivity__c masterAct : masterActList){
            if(masterAct.Position__c == '1'){
                position1.add(masterAct);
            }else if(masterAct.Position__c == '2'){
                position2.add(masterAct);
            }
        }
    
        result.put('1',sortList(extract(position1,recordId)));
        result.put('2',sortList(extract(position2,recordId)));
        
        return result;
    }

    @AuraEnabled
    public static List<ActivityItem> extract(List<MasterActivity__c> masterActList, String recordId){
        List<ActivityItem> actItemList = new List<ActivityItem>();
        List<Opportunity_Activity__c> boActList = Utils.queryObjectWithoutRichText('Opportunity_Activity__c'
                                                    , 'WHERE WhatId__c = ' + '\'' + recordId + '\'' 
                                                   + ' ORDER BY TransactionName__c, CreatedDate DESC'
                                                );

        String opptySOQL = Utils.getQueryAddSelect('Opportunity', 'RecordType.DeveloperName', ' WHERE  Id = \'' + recordId + '\'', false);
        List<Opportunity> opptyList = System.Database.query(opptySOQL);

        if(opptyList.size() > 0) {
            Opportunity oppty = opptyList[0];

            Boolean isHQRecordType        = oppty.RecordTypeId == OpportunityActivityHelper.RT_OPPTY_HQ.Id;
            Boolean isLogisticsRecordType = oppty.RecordTypeId == OpportunityActivityHelper.RT_OPPTY_LOGISTICS.Id;
            
            Map<String, String> boActStatusMap = new Map<String, String>();

            String ACT_CODE_DROP_OPPORTUNITY = OpportunityActivityHelper.ACT_CODE_DROP_OPPORTUNITY;
            String ACT_CODE_LOST_OPPORTUNITY = OpportunityActivityHelper.ACT_CODE_LOST_OPPORTUNITY;
            for(MasterActivity__c masterAct : masterActList){
                ActivityItem actItem = new ActivityItem(null, null, null);
                actItem.opptyId = recordId;
                actItem.MasterAct = masterAct;

                for(Opportunity_Activity__c boAct : boActList){
                    boActStatusMap.put(boAct.TransactionName__c, boAct.Status__c);

                    if(actItem.MasterAct.TransactionName__c ==  boAct.TransactionName__c
                        // 중도종결 (Drop/Lost) : Master Activity Code : Drop(ZPZ2) 이며 Oppty Activity 생성시 Lost Type (Lost 'ZPZ1', Drop 'ZPZ2') 에 따라 분기 생성됨
                        || (actItem.MasterAct.TransactionName__c == ACT_CODE_DROP_OPPORTUNITY 
                            && (boAct.TransactionName__c == ACT_CODE_LOST_OPPORTUNITY || boAct.TransactionName__c == ACT_CODE_DROP_OPPORTUNITY)) ) {
                    actItem.boAct = boAct;
                    
                    // Activity Box 노출 Date Setting
                        switch on boAct.Status__c {
                            when 'Not Started' {
                                actItem.DateItem = boAct.DueDate__c;
                            }
                            when 'In Progress' {
                                actItem.DateItem = boAct.StartDate__c;
                            }
                            when 'Completed' {
                                actItem.DateItem = boAct.EndDate__c;
                            }
                            //2022-08-08 수주품의 액티비티 상태 표시 상세화
                            when 'Rejected' {
                                actItem.DateItem = boAct.StartDate__c;
                            }
                            when 'Cancelled' {
                                actItem.DateItem = boAct.StartDate__c;
                            }
                        }
                    break;
                    }
                }
                
                /**
                 * [HQ Record Type] Activity 접근 가능 여부 처리
                 */
                if(isHQRecordType) {
                    actItem.isAccessible = OpportunityActivityHelper.checkAccessHQActivity(oppty, actItem);
                }

                /**
                 * [Logistics Record Type] Activity 접근 가능 여부 처리
                 */
                if(isLogisticsRecordType) {
                    //actItem.isAccessible = OpportunityActivityHelper.checkAccessLogisticsActivity(oppty, actItem);
                    
                    actItem.isAccessible = OpportunityActivityHelper.checkAccessLogisticsActivityV2(oppty, actItem);
                          
                }
                
                actItemList.add(actItem);
            }
        }
        return actItemList;
    }

    public static List<List<ActivityItem>> sortList(List<ActivityItem> actlist){
        String temp='1';
        String order = '';
        List<Map<String, String>> valueCnt = Utils.getPicklistOptionType('Opportunity','StageName');
        List<List<ActivityItem>> sortResult = new List<List<ActivityItem>>();
        List<ActivityItem> sortTemp = new List<ActivityItem>();

        Integer lostStageCount = 3;	// Lost Stage 개수
        Integer cnt = valueCnt.size() - lostStageCount;
        Integer itemIndex = 1;
        for(ActivityItem act : actlist ){ 
            order = act.MasterAct.Stage__c.substring(2);
            act.Index = itemIndex++;

            if(temp != '1' && String.valueOf(Integer.valueOf(temp)+1) !=order && temp !=order){
                List<ActivityItem> fakeTemp = new List<ActivityItem>();
                sortResult.add(fakeTemp);
            }
            if(temp == order){
                sortTemp.add(act);
                
            }else{
                sortResult.add(sortTemp);
                sortTemp = new List<ActivityItem>();
                System.debug(' temp' + temp);
                System.debug(' order' + order);
                temp = order;
                sortTemp.add(act);
            }
        }
        
        if(actlist.size() !=0 ){
            sortResult.add(sortTemp);
            if(Integer.valueOf(order) < cnt){
                List<ActivityItem> fakeTemp = new List<ActivityItem>();
                for(Integer i=Integer.valueOf(temp); i<cnt; i++){
                    sortResult.add(fakeTemp);
                }
            }
        }

        for(List<ActivityItem> act : sortResult ){
            for(ActivityItem act2 : act ){
                System.debug('sortResult : ' + act2.MasterAct.TransactionName__c);
            }
          
        }


        return sortResult;
    }

    public class ActivityItem {
        @AuraEnabled 
        public String opptyId {get; set;}
        @AuraEnabled 
        public MasterActivity__c MasterAct {get; set;}
        @AuraEnabled 
        public Opportunity_Activity__c BoAct {get; set;}
        @AuraEnabled 
        public Date DateItem {get; set;}
        @AuraEnabled 
        public Integer Index {get; set;}
        @AuraEnabled 
        public Boolean isAccessible {set; get;}
         
        public ActivityItem(MasterActivity__c MasterAct, Opportunity_Activity__c BoAct, Date DateItem) {
            this.MasterAct = MasterAct;
            this.BoAct = BoAct;
            this.DateItem = DateItem;
            this.isAccessible = true;
        }
    }
}