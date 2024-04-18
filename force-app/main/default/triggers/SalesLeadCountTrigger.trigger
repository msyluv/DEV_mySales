/**
* @description       : 
* @author            : Junghwa.Kim@dkbmc.com
* @group             : 
* @last modified on  : 2024-04-17
* @last modified by  : sarthak.j1@samsung.com
* Modifications Log 
* Ver   Date         Author                  Modification
* 1.0   2020-12-17   Junghwa.Kim@dkbmc.com   Initial Version
* 1.1   2021-05-18   seonju.jin@dkbmc.com    INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY 에러 수정(원인: Share에  SaleLead Owner가 추가되어 에러발생)
* 1.2   2021-07-12   seonju.jin@dkbmc.com    Marketing Lead에서 Sales Lead로 변환된 경우 Marketing Lead의 Owner가 Sales Lead의 Read 권한을 갖도록 로직 추가
* 1.3	2022-06-16   hyunhak.roh@dkbmc.com	 사업리드 Converted BO가 삭제 시 해당 사업리드 단계를 되돌리는 로직 추가
* 1.4	2023-09-22   chae_ho.yang@samsung.com SDSA 미발송처리
* 1.5   2024-01-24   sarthak.j1@samsung.com  Sales Lead Enhancement -> MYSALES-413 / MYSALES-413 Additional Changes
* 1.6   2024-01-25   vikrant.ks@samsung.com  Added a new function 'OwnershipChangeTime' and commented a function 'shareSetting'.(MySales-389)
* 1.7   2024-02-15   sarthak.j1@samsung.com  Sales Lead - Internal/External field changing -> MYSALES-448
* 1.8   2024-04-17   sarthak.j1@samsung.com  Sales Lead Enhancement -> MYSALES-497
**/
trigger SalesLeadCountTrigger on Sales_Lead__c (before insert, before update, before delete, after insert, after update) {

    // Trigger Switch
    TriggerSwitch__c trSwitch = TriggerSwitch__c.getInstance(UserInfo.getUserId()); // Current User 기준으로 Custom Setting 가져옴
    Boolean MigSwitch = trSwitch.Migration__c;  // Data Migration 시 제외할 로직인 경우 true
    
    //Start v-1.7 [MYSALES-448]
    Sales_Lead_Update__c slUpdate = Sales_Lead_Update__c.getValues('UpdateLead');
    Boolean applyValidation = false;
    if(!Test.isRunningTest()){
    	applyValidation = slUpdate.Update_Through_Account__c;
    }
    //End v-1.7 [MYSALES-448]
    
    public static String RT_SL_HQ_ID = Sales_Lead__c.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('HQ').getRecordTypeId(); //Added v-1.5 [MYSALES-413]
    System.debug('SJOSHI01>'+RT_SL_HQ_ID); //Added v-1.5 [MYSALES-413]

    //2022-06-16, hyunhak.roh@dkbmc.com, 사업리드 Converted BO가 삭제 시 해당 사업리드 단계를 되돌리는 로직 추가
    if(!TriggerControl.isOpptyDeleteToSalesLead) {
        
        switch on trigger.operationType{    
            
            when BEFORE_INSERT{
                bantCheck(Trigger.new, 'I');
                //if(!MigSwitch) validation(Trigger.new);	//Commented out v-1.5 [MYSALES-413]
                //Start v-1.5 [MYSALES-413]
                if(!MigSwitch){
                    validation(Trigger.new);
                    //validation2(Trigger.new); //Commented out v-1.5 [MYSALES-413]
                    checkSalesLeadStage(Trigger.new); // Added as part of v-1.8
                }
                //End v-1.5 [MYSALES-413]
                costCenterSetting(Trigger.new);
                //Start v-1.5 [MYSALES-413]
                setSLIntExtOnInsert(Trigger.new);
                if(!MigSwitch){
                    validation2(Trigger.new);
                }
                //End v-1.5 [MYSALES-413]
            }
            
            when BEFORE_UPDATE{
                bantCheck(Trigger.new, 'U');
                if(!MigSwitch){
                    stageSetting(Trigger.new, Trigger.oldMap);
                    validation(Trigger.new);
                } 
                cancelClose(Trigger.new, Trigger.oldMap);
                //Start v-1.5 [MYSALES-413]
                setSLIntExtOnUpdate(Trigger.new, Trigger.oldMap);
                if(!MigSwitch && applyValidation){ //Added '&& applyValidation' as part of v-1.7 [MYSALES-448]
                    validation2(Trigger.new);
                }
                //End v-1.5 [MYSALES-413]
                OwnershipChangeTime(Trigger.new, Trigger.oldMap);//V1.6
            }
            when BEFORE_DELETE{
                //관련 캠페인에 변환한 sales lead 갯수 설정
                beforeDeleteSL(Trigger.old);
            }
            
            when AFTER_INSERT{
                //관련 캠페인에 변환한 sales lead 갯수 설정
                afterInsertSL(Trigger.new);
    
                // Sales Lead 공유대상 추가
                //if(!MigSwitch) shareSetting(Trigger.new);//V1.6
    
                // 마케팅리드 -> 사업리드 변환된 경우 마케팅리드의 Status와 SalesLeadID__C 필드 업데이트
                // updateParantLeadStatus(Trigger.new);
            }
            
            when AFTER_UPDATE{
                //관련 캠페인에 변환한 sales lead 갯수 설정
                afterUpdateSL(Trigger.new, Trigger.old);
    
                //owner변경시 knox 이메일 발송
                sendOwnerChangeKnoxEmail(Trigger.new, Trigger.old);
    
                //owner변경시 knox 공지 채팅 전송
                sendOwnerChangeKnoxChat(Trigger.new, Trigger.old);
                
                OwnershipChange(Trigger.new, Trigger.oldMap);//V1.6
            }
        }
    }
    //
    System.debug('### SalesLeadCountTrigger :: TriggerControl.isOpptyDeleteToSalesLead :: ' + TriggerControl.isOpptyDeleteToSalesLead);
    
    private static void validation(List<Sales_Lead__c> newList){
        //Marketing Lead 에서 넘어온 Lead의 Channel 세팅.
        for(Sales_Lead__c rowSalesLead : newList){
            if(rowSalesLead.Lead__c != null) {
                //rowSalesLead.LeadChannel__c = 'Marketing Lead Converted';
                if(!'Marketing Lead Converted'.equals(rowSalesLead.LeadChannel__c)){
                    rowSalesLead.addError('LeadChannel__c',System.Label.CONVERT_LAB_MSG28);
                }
            }else{
                //Marketing Lead 에서 넘어오지 않았는데 Marketing Lead 선택시
                if('Marketing Lead Converted'.equals(rowSalesLead.LeadChannel__c)){	
                    rowSalesLead.addError('LeadChannel__c',System.Label.CONVERT_LAB_MSG27);
                } 
            }
            
        } 
        
    }
    
        
    private static void bantCheck(List<Sales_Lead__c> newObjList, String type){
        for(Sales_Lead__c sl : newObjList){
            if(sl.LeadStage__c != 'Converted'){
                Integer cnt = 0;
                if(sl.Budget__c) cnt++;
                if(sl.Authority__c) cnt++;
                if(sl.Needs__c) cnt++;
                if(sl.TimeLine__c) cnt++;
                if(type == 'U' || (type == 'I' && sl.Lead__c == null)){ // Lead에서 Convert되지 않은 경우
                    sl.LeadStage__c = cnt >= 2 ? 'Hot' : sl.LeadStage__c;
                    if(sl.LeadStage__c == null) sl.LeadStage__c = 'Cold';
                }

                if(cnt < 2 && sl.LeadStage__c == 'Hot'){
                    sl.addError(System.Label.CONVERT_LAB_MSG24); // To change Stage to Hot, two or more BANT must be checked.
                }
            }
        }
    }
    
    // Stage Setting
    // 1. Stage는 역행할 수 없음 (Stage 순서 : Cold -> Warm -> Hot -> Converted)
    private static void stageSetting(List<Sales_Lead__c> newList, Map<Id, Sales_Lead__c> oldMap){
        for(Sales_Lead__c sl : newList){
            if(sl.LeadStage__c != null){
                Integer afterStage = 0;
                if(sl.LeadStage__c == 'Cold') afterStage = 1;
                if(sl.LeadStage__c == 'Warm') afterStage = 2;
                if(sl.LeadStage__c == 'Hot') afterStage = 3;
                if(sl.LeadStage__c == 'Converted') afterStage = 4;
                
                Integer beforeStage = 0;
                Sales_Lead__c oldSL = oldMap.get(sl.Id);
                if(oldSL.LeadStage__c == 'Cold') beforeStage = 1;
                if(oldSL.LeadStage__c == 'Warm') beforeStage = 2;
                if(oldSL.LeadStage__c == 'Hot') beforeStage = 3;
                if(oldSL.LeadStage__c == 'Converted') beforeStage = 4;
                
                if(beforeStage > afterStage){
                    sl.addError(System.Label.CONVERT_LAB_MSG21); // The Lead Stage cannot be retrograde.
                }
			}
        }
    }

    // Cancel Close
    // 1. Sales Lead Status가 Close에서 In Process로 변경되는 경우 Close Reason(종결사유) 초기화
    private static void cancelClose(List<Sales_Lead__c> newList, Map<Id, Sales_Lead__c> oldMap){
        for(Sales_Lead__c sl : newList){
            Sales_Lead__c oldSL = oldMap.get(sl.Id);
            if(sl.LeadStatus__c == 'In Process' && oldSL.LeadStatus__c == 'Close'){
                sl.CloseReason__c = '';
            }
        }
    }

    
   // CostCenter Setting
    // 1. 사업리드의 소유자가 속한 Cost Center를 자동으로 세팅(최초 생성시에만 동작 / Owner 변경시에는 실행 X)
    private static void costCenterSetting(List<Sales_Lead__c> newList){
        
        //화면에 값이 매핑되어 있으면 자동 매핑 수행 하지 않음. 자동 매핑 대상만 타겟으로 설정
        List<Sales_Lead__c> listTargetSalesLead = new List<Sales_Lead__c>();        
        for(Sales_Lead__c rowSalesLead : newList){
            if(rowSalesLead.SalesDepartment__c == null) { //Added condition after && as part of v-1.5 [MYSALES-413] //Removed condition (&& rowSalesLead.LeadChannel__c != 'Direct Registration') as part of v-1.5 [MYSALES-413 Additional Changes]
                listTargetSalesLead.add(rowSalesLead);
            }
        }        
        
        system.debug('### SalesLeadCountTrigger :: costCenterSetting :: listTargetSalesLead = ' + listTargetSalesLead);
        
        Set<Id> userIdSet = new Set<Id>();
        for(Sales_Lead__c sl : listTargetSalesLead){
            userIdSet.add(sl.ownerId);
        }
        
        List<User> listUser = new List<User>([SELECT Id, FederationIdentifier, CompanyCode__c, EvKostl__c FROM User where Id =: userIdSet]);        
        //Set<String> setUserCompanyCode = new Set<String>(); //--> Commented Out for v-1.5 [MYSALES-413 Additional Changes]
        Map<Id, String> mapUserEvKostl = new Map<Id, String>();
        for(User rowUser : listUser){
            //if(String.isNotBlank(rowUser.CompanyCode__c)){ //--> Commented Out for v-1.5 [MYSALES-413 Additional Changes]
            if(String.isNotBlank(rowUser.EvKostl__c)){ //--> Added for v-1.5 [MYSALES-413 Additional Changes]
                //setUserCompanyCode.add(rowUser.CompanyCode__c); //--> Commented Out for v-1.5 [MYSALES-413 Additional Changes]
                mapUserEvKostl.put(rowUser.Id, rowUser.EvKostl__c);
            }
        }    

        //CostCenter (사업리드에서는 손익부서 여부 체크 안함 - 2021-10-25 제인호 프로 요청)
        Map<String, CostCenter__c> costMap = new Map<String, CostCenter__c>();
        List<CostCenter__c> costList = [SELECT Id, CostCenter__c, ZZCheck__c, Closed__c 
                                        FROM CostCenter__c  
                                      //WHERE Closed__c = false AND CompanyCode__c =: setUserCompanyCode];//--> Commented Out for v-1.5 [MYSALES-413 Additional Changes]
                                        WHERE Closed__c = false AND CostCenter__c IN : mapUserEvKostl.values()]; //--> Added for v-1.5 [MYSALES-413 Additional Changes]
        
        for(CostCenter__c c : costList){
            costMap.put(c.CostCenter__c,c);
        }
        
        system.debug('### SalesLeadCountTrigger :: costCenterSetting :: costMap = ' + costMap);
        // 부서코드에 매핑되는 CostCenter가 존재시에만 매핑.
        for(Sales_Lead__c sl : listTargetSalesLead) {
            if(mapUserEvKostl.get(sl.ownerId) != null){               
                if(costMap.get(mapUserEvKostl.get(sl.ownerId)) != null){                     
                    sl.SalesDepartment__c = costMap.get(mapUserEvKostl.get(sl.ownerId)).id;  
                }              
            }            
        }
                
    }
    
    /**
    * @description 관련 캠페인에 변환한 sales lead 갯수 설정
    * @author Junghwa.Kim@dkbmc.com | 2021-05-18 
    * @param List<Sales_Lead__c> oldObjList
    **/
    private static void beforeDeleteSL(List<Sales_Lead__c> oldObjList){
        System.debug('::::: beforeDeleteSL :::::');
        Set<String> campaignIdSet = new Set<String>();
        for(Sales_Lead__c s : oldObjList){
            if(s.LeadStage__c == 'Converted'){
                s.addError('Sales Leads converted to Opportunity cannot be deleted.'); // Sales Leads converted to Opportunity cannot be deleted.
            }else{
                if(s.CampaignId__c != null){
                    campaignIdSet.add(s.CampaignId__c);
                }
            }
        }
        if(campaignIdSet.size() > 0){
            System.debug('===== beforeDeleteSL campaignIdSet =====');
            List<Campaign> CList = [SELECT Id, SalesLeadConvertedNumber__c FROM Campaign WHERE Id IN :campaignIdSet];
            if(CList.size() > 0){
                for(Campaign c : CList){
                    System.debug(c);
                    if(c.SalesLeadConvertedNumber__c == 0){
                        c.SalesLeadConvertedNumber__c = 0;
                    } else {
                        c.SalesLeadConvertedNumber__c -= 1;
                    }
                }
                update CList;
            }
        }
    }

    /**
    * @description 관련 캠페인에 변환한 sales lead 갯수 설정
    * @author Junghwa.Kim@dkbmc.com | 2021-05-18 
    * @param List<Sales_Lead__c> newObjList 
    * @param List<Sales_Lead__c> oldObjList 
    **/
    private static void afterUpdateSL(List<Sales_Lead__c> newObjList, List<Sales_Lead__c> oldObjList){
        System.debug('::::: afterUpdateSL :::::');
        Map<Id, Sales_Lead__c> oldMap = new Map<Id,Sales_Lead__c>(oldObjList);
        Set<String> newCampaignIdSet = new Set<String>();
        Set<String> oldCampaignIdSet = new Set<String>();
        for(Sales_Lead__c s : newObjList){
            Sales_Lead__c oldSl = oldMap.get(s.Id);
            if(s.CampaignId__c != oldSl.CampaignId__c){
                newCampaignIdSet.add(s.CampaignId__c);
                oldCampaignIdSet.add(oldSl.CampaignId__c);
            }
        }
        if(newCampaignIdSet.size() > 0){
            System.debug('===== afterUpdateSL newCampaignIdSet =====');
            List<Campaign> CList = [SELECT Id, SalesLeadConvertedNumber__c FROM Campaign WHERE Id IN :newCampaignIdSet];
            if(CList.size() > 0){
                for(Campaign c : CList){
                    System.debug(c);
                    if(c.SalesLeadConvertedNumber__c == null){
                        c.SalesLeadConvertedNumber__c = 1;
                    } else {
                        c.SalesLeadConvertedNumber__c += 1;
                    }
                }
                update CList;
            }
        }
        if(oldCampaignIdSet.size() > 0){
            System.debug('===== afterUpdateSL oldCampaignIdSet =====');
            List<Campaign> CList = [SELECT Id, SalesLeadConvertedNumber__c FROM Campaign WHERE Id IN :oldCampaignIdSet];
            if(CList.size() > 0){
                for(Campaign c : CList){
                    System.debug(c);
                    if(c.SalesLeadConvertedNumber__c == 0){
                        c.SalesLeadConvertedNumber__c = 0;
                    } else {
                        c.SalesLeadConvertedNumber__c -= 1;
                    }
                }
                update CList;
            }
        }
    }

    /**
    * @description 관련 캠페인에 변환한 sales lead 갯수 설정
    * @author Junghwa.Kim@dkbmc.com | 2021-05-18 
    * @param List<Sales_Lead__c> newObjList 
    **/
    private static void afterInsertSL(List<Sales_Lead__c> newObjList){
        System.debug('::::: afterInsertSL :::::');
        Set<String> campaignIdSet = new Set<String>();
        for(Sales_Lead__c s : newObjList){
            if(s.CampaignId__c != null){
                campaignIdSet.add(s.CampaignId__c);
            }
        }
        if(campaignIdSet.size() > 0){
            System.debug('===== afterInsertSL campaignIdSet =====');
            List<Campaign> CList = [SELECT Id, SalesLeadConvertedNumber__c FROM Campaign WHERE Id IN :campaignIdSet];
            if(CList.size() > 0){
                for(Campaign c : CList){
                    System.debug(c);
                    if(c.SalesLeadConvertedNumber__c == null){
                        c.SalesLeadConvertedNumber__c = 1;
                    } else {
                        c.SalesLeadConvertedNumber__c += 1;
                    }
                }
                update CList;
            }
        }
    }
    
    /**
    * @description 사업리드 공유 대상을 자동으로 추가
    *              Case 1. 사업리드의 소유자가 사업리드 팀을 등록한 경우 -> 사업리드 팀에 등록된 사용자는 사업리드 공유대상에 자동으로 포함
    *              Case 2. 마케팅리드를 변환하여 사업리드가 생성된 경우, 사업리드에 마케팅리드가 연결되어있는경우 -> 마케팅리드의 소유자를 사업리드 공유 대상으로 추가
    * @author younghoon.kim@dkbmc.com | 2021-05-18 
    * 2021-05-18 INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY 에러 수정 (seonju.jin@dkbmc.com)
    * @param List<Sales_Lead__c> newObjList 
    **/
    /*V1.6
     private static void shareSetting(List<Sales_Lead__c> newObjList){
        //seonju.jin Lead의 소유자 획득하기 위해 추가
        system.debug('Inside Method');//V
        Set<Id> leadIdSet = new Set<Id>();
        for(Sales_Lead__c sl : newObjList){
            leadIdSet.add(sl.Lead__c);
        }
        Map<Id,Lead> leadMap = new Map<Id,Lead>([SELECT Id, Name, OwnerId FROM Lead WHERE Id IN :leadIdSet]);

        Set<String> slOwnerIdSet = new Set<String>();
        for(Sales_Lead__c sl : newObjList){
            slOwnerIdSet.add(sl.OwnerId);
        }
        System.debug('slOwnerIdSet : ' + slOwnerIdSet);
        
        Map<String, List<Sales_Lead_Team__c>> sltMap = new Map<String, List<Sales_Lead_Team__c>>();
        if(slOwnerIdSet.size() > 0){
            List<Sales_Lead_Team__c> sltmList = [SELECT Id, Name, OwnerId, SalesLead_TeamMember__c, AccessLevel__c FROM Sales_Lead_Team__c WHERE OwnerId =: slOwnerIdSet AND SalesLead_TeamMember__r.IsActive = true];
            if(sltmList.size() > 0){
                for(Sales_Lead_Team__c slt : sltmList){
                    List<Sales_Lead_Team__c> sltList;
                    if(sltMap.get(slt.OwnerId) == null){
                        sltList  = new List<Sales_Lead_Team__c>();
                    }else{
                        sltList = sltMap.get(slt.OwnerId);
                    }
                    sltList.add(slt);
                    sltMap.put(slt.OwnerId, sltList);
                }
            }
        }
        System.debug('sltMap : ' + sltMap);
        
        List<Sales_Lead__Share> insertList = new List<Sales_Lead__Share>();
        for(Sales_Lead__c sl : newObjList){
            System.debug('sl.OwnerId'+sltMap.get(sl.OwnerId));
            Id leadOwnerId = null;
            if(sl.Lead__c != null && leadMap.get(sl.Lead__c) != null){
                leadOwnerId = leadMap.get(sl.Lead__c).OwnerId;

                System.debug('sl.Lead__c : ' + sl.Lead__c);
                Sales_Lead__Share sLeadShare = new Sales_Lead__Share();
                sLeadShare.ParentId = sl.Id; //사업리드 레코드ID
                sLeadShare.UserOrGroupId = leadMap.get(sl.Lead__c).OwnerId; //소유자의 팀멤버
                sLeadShare.AccessLevel = 'Edit'; //Access Level
                sLeadShare.RowCause = 'Manual'; //RowCause

                if(leadOwnerId != sl.OwnerId) insertList.add(sLeadShare);
            }
            if(sltMap.get(sl.OwnerId) != null){
                for(Sales_Lead_Team__c slt : sltMap.get(sl.OwnerId)){
                    if(slt.SalesLead_TeamMember__c != sl.OwnerId){ // SalesLead Owner는 Share에서 제외
                        if(slt.SalesLead_TeamMember__c != leadOwnerId){ // 추가되어야하는 SalesLead Teammember가 Lead__c의 Owner인 경우 제외 -> 위에서 이미 추가했기 때문에 //V1.6 removed leadOwnerId != null condition from if.
                            Sales_Lead__Share sls = new Sales_Lead__Share();
                            sls.ParentId = sl.Id; //사업리드 레코드ID
                            sls.UserOrGroupId = slt.SalesLead_TeamMember__c; //소유자의 팀멤버
                            sls.AccessLevel = slt.AccessLevel__c; //Access Level
                            sls.RowCause = 'Manual'; //RowCause
                            
                            insertList.add(sls);
                        } 
                    }
                }
            }
        }
        System.debug('insertList : ' + insertList);
        
        if(insertList.size() > 0) insert insertList;
    }  */

    /**
    * @description 마케팅리드 -> 사업리드 변환된 경우 마케팅리드의 Status와 SalesLeadID__C 필드 업데이트
    * @author younghoon.kim@dkbmc.com | 2021-07-07
    * @param List<Sales_Lead__c> newObjList 
    **/
    // private static void updateParantLeadStatus(List<Sales_Lead__c> newObjList){
    //     Map<String, String> leadSalesLeadMap = new Map<String, String>();
    // 
    //     for(Sales_Lead__c salesLead : newObjList){
    //         if(salesLead.Lead__c != null) leadSalesLeadMap.put(salesLead.Lead__c, salesLead.Id);
    //     }
    // 
    //     List<Lead> leadList = [SELECT Id, Name, Status, SalesLeadID__c FROM Lead WHERE Id =: leadSalesLeadMap.KeySet()];
    //     if(leadList.size() > 0){
    //         for(Lead lead : leadList){
    //             lead.SalesLeadID__c = leadSalesLeadMap.get(lead.Id);
    //             lead.Status = 'Warm';
    //         }
    //         update leadList;
    //     }
    // }

    private static void sendOwnerChangeKnoxEmail(List<Sales_Lead__c> newList, List<Sales_Lead__c> oldObjList){ // Migration에서는 제외

        //Email : Template조회
        EmailTemplate emailTemplate = getEmailTemplate('SalesLead_Owner_Change_Email');
        List<KnoxEmail__c> KnoxEmailList = new List<KnoxEmail__c>();
    
        for(Sales_Lead__c sales : newList){
            Map<Id, Sales_Lead__c> oldMap = new Map<Id,Sales_Lead__c>(oldObjList);
            String oldOwnerId = oldMap.get(sales.Id).ownerId;
            String newOwnerId = sales.ownerId;
            Boolean isOwnerChange = (oldOwnerId != newOwnerId);
    
            String SalesLeadName = sales.Name;
            String SalesLeadBeforeOwner = '';
            String SalesLeadAfterOwner = '';
            String SalesLeadDescription = sales.Description__c;
            Datetime modifyDate = sales.LastModifiedDate;
            String SalesLeadCahngeDate = modifyDate.format('yyyy-MM-dd a HH:mm:ss');
            
            String oldOwnerEmail = '';
            String oldOwnerEpId  = '';
            String newOwnerEmail = '';
            String newOwnerEpId  = '';
            String systemEmail   = '';
            String systemId = '';
            String subject = String.valueOf(emailTemplate.Subject);
            String LinkAddress = '';

            // chae_ho.yang 23.09.22 SDSA 의 경우 발송하지 않음
            Boolean isSDSA = false;
            User oldUser = getUser(oldOwnerId);
            User newUser = getUser(newOwnerId);
            if (oldUser.EPCompanyName__c == 'SDSA' || newUser.EPCompanyName__c == 'SDSA') isSDSA = true;
            
            //------------------------------------------------------------------------------------------
            //Owner가 변경되었으면 Knox Email을 발송
            if(isOwnerChange && !isSDSA) { 
                System.debug('Owner changed from: ' + oldOwnerId + ', to: ' + newOwnerId);
    
                Boolean isSandbox = Utils.getIsSandbox();
                //User oldUser = getUser(oldOwnerId);
                Employee__c oldEmployee = Utils.getEmployeeData(oldUser.FederationIdentifier);
                //User newUser = getUser(newOwnerId);
                Employee__c newEmployee = Utils.getEmployeeData(newUser.FederationIdentifier);
                Employee__c senderEmployee;

                SalesLeadBeforeOwner   = oldUser.LastName + oldUser.FirstName;
                oldOwnerEmail          = oldEmployee.EvMailAddr__c;
                oldOwnerEpId           = oldUser.FederationIdentifier;
                SalesLeadAfterOwner    = newUser.LastName + newUser.FirstName;
                newOwnerEmail          = newEmployee.EvMailAddr__c;
                newOwnerEpId           = newUser.FederationIdentifier;

                //QA
                if(isSandbox){
                    systemEmail = 'chae_ho.yang@stage.samsung.com'; //'oldman.sea@stage.samsung.com';
                    systemId    = 'a091s0000035Ax2AAE';
                    LinkAddress = 'https://sdssfa--qa.lightning.force.com/lightning/r/Sales_Lead__c/'+sales.Id+'/view';

                    oldOwnerEmail = oldOwnerEmail.replace('@samsung.com', '@stage.samsung.com');
                    newOwnerEmail = newOwnerEmail.replace('@samsung.com', '@stage.samsung.com');
                }
                //REAL
                else{
                    systemEmail = 'mysales@samsung.com';
                    LinkAddress = 'https://sdssfa.lightning.force.com/lightning/r/Sales_Lead__c/'+sales.Id+'/view';

                    List<User> userList = [SELECT Id, Name From User WHERE Username = :systemEmail];
		            if(userList.size() > 0)
                        senderEmployee = Utils.getLoginEmployeeData(userList.get(0).Id);
                    if(senderEmployee != null) 
                        systemId = senderEmployee.Id;
                }

                //------------------------------------------------------------------------------------------
                //Email : 본문 가져와서 처리
                String body = String.valueOf(emailTemplate.HtmlValue).replace('\r\n', '');
                if (SalesLeadName==null) SalesLeadName = '';
                if (SalesLeadBeforeOwner==null) SalesLeadBeforeOwner = '';
                if (SalesLeadAfterOwner==null) SalesLeadAfterOwner = '';
                if (SalesLeadDescription==null) SalesLeadDescription = '';
                if (SalesLeadCahngeDate==null) SalesLeadCahngeDate = '';
                body = body.replace('{!SalesLeadName}'       , SalesLeadName);
                body = body.replace('{!SalesLeadBeforeOwner}', SalesLeadBeforeOwner);
                body = body.replace('{!SalesLeadAfterOwner}' , SalesLeadAfterOwner);
                body = body.replace('{!SalesLeadDescription}', SalesLeadDescription);
                body = body.replace('{!SalesLeadCahngeDate}' , SalesLeadCahngeDate);
                body = body.replace('{!LinkAddress}' , LinkAddress); 
    
                //------------------------------------------------------------------------------------------
                //Email : Knox mail 송신자 정보 처리
                IF_KnoxEmailSendController.Sender sender = new IF_KnoxEmailSendController.Sender(systemEmail.split('@')[0], systemEmail);
    
                //------------------------------------------------------------------------------------------
                //Email : Knox mail 수신자 정보 처리
                List<IF_KnoxEmailSendController.Recipients> recipientsList = new List<IF_KnoxEmailSendController.Recipients>();
                List<String> toList = new List<String>();
                toList.add(oldOwnerEmail);
                toList.add(newOwnerEmail);
                recipientsList.add(new IF_KnoxEmailSendController.Recipients(oldOwnerEmail, 'TO'));
                recipientsList.add(new IF_KnoxEmailSendController.Recipients(newOwnerEmail, 'TO'));
                
                //------------------------------------------------------------------------------------------
                //Email : Knox mail 전송처리
                IF_KnoxEmailSendController.InputClass bodyMap = new IF_KnoxEmailSendController.InputClass();
                bodyMap.subject = subject;
                bodyMap.contents = body;
                bodyMap.contentType = 'HTML';
                bodyMap.docSecuType = 'PERSONAL';
                bodyMap.sfdcId = sales.Id;
                bodyMap.recipients = recipientsList;
                bodyMap.sender = sender;
                bodyMap.isMulti = true;
                Map<String,Object> resMap = new Map<String,Object>();
                Map<String,Object> response = new Map<String, Object>();
    
                    IF_KnoxEmailSendController.send2(JSON.serialize(bodyMap));
    
                        KnoxEmail__c knoxemail = new KnoxEmail__c(
                            RecordId__c = sales.Id
                            , Sender__c = systemId
                            , ToAddress__c = String.join(toList, ',')
                            , Name = subject
                            , HtmlBody__c = SalesLeadDescription
                            , MailId__c = systemEmail
                            , Status__c = 'Send'
                        );
                        knoxemailList.add(knoxemail);
    
            }
            //------------------------------------------------------------------------------------------
        }//end of for
    
        insert knoxemailList;
    }
    
    //User 정보 조회
    private static User getUser(String userId){
        User returnUser = [Select Id
                            , LastName
                            , FirstName
                            , Email //knox email address
                            , FederationIdentifier
                            , EPCompanyName__c
                            from User
                            where id = :userId];
        return returnUser;
    }
    
    //Email 템플릿 조회
    private static EmailTemplate getEmailTemplate(String templateName){
        EmailTemplate template = [  SELECT Id
                                    , Name
                                    , DeveloperName
                                    , Subject
                                    , HtmlValue
                                    , Body 
                                FROM EmailTemplate
                                WHERE DeveloperName = :templateName LIMIT 1];
        return template;
    }

    //Employee 정보 조회
    // private static Employee__c getEmployee(String FederationIdentifier){
    //     Employee__c returnEmployee = [SELECT Id, 
    //                                          EvUniqID__c, 
    //                                          EvMailAddr__c 
    //                                     FROM Employee__c 
    //                                    WHERE EvUniqID__c = :FederationIdentifier
    //                                    LIMIT 1];
    //     return returnEmployee;
    // }

    //Lead Owner변경시 Knox 공지 Chat(AppCard) 전송
    public static void sendOwnerChangeKnoxChat(List<Sales_Lead__c> newList, List<Sales_Lead__c> oldObjList){
        
        List<KnoxEmail__c> KnoxEmailList = new List<KnoxEmail__c>();
    
        for(Sales_Lead__c sales : newList){
            Map<Id, Sales_Lead__c> oldMap = new Map<Id,Sales_Lead__c>(oldObjList);
            String oldOwnerId = oldMap.get(sales.Id).ownerId;
            String newOwnerId = sales.ownerId;
            Boolean isOwnerChange = (oldOwnerId != newOwnerId);
    
            String SalesLeadName = sales.Name;
            String SalesLeadBeforeOwner = '';
            String SalesLeadAfterOwner = '';
            String SalesLeadDescription = sales.Description__c;
            Datetime modifyDate = sales.LastModifiedDate;
            String SalesLeadCahngeDate = modifyDate.format('yyyy-MM-dd a HH:mm:ss');
            
            String oldOwnerEmail = '';
            String oldOwnerEpId  = '';
            String newOwnerEmail = '';
            String newOwnerEpId  = '';
            String systemEmail   = '';
            String systemId = '';
            String subject = String.valueOf(emailTemplate.Subject);
            String LinkAddress = '';
    
            //------------------------------------------------------------------------------------------
            //Owner가 변경되었으면 Knox Chat을 발송
            if(isOwnerChange) { 
                Boolean isSandbox = Utils.getIsSandbox();
                User oldUser = getUser(oldOwnerId);
                Employee__c oldEmployee = Utils.getEmployeeData(oldUser.FederationIdentifier);
                User newUser = getUser(newOwnerId);
                Employee__c newEmployee = Utils.getEmployeeData(newUser.FederationIdentifier);
                Employee__c senderEmployee;
    
                SalesLeadBeforeOwner   = oldUser.LastName + oldUser.FirstName;
                oldOwnerEmail          = oldEmployee.EvMailAddr__c;
                oldOwnerEpId           = oldUser.FederationIdentifier;
                SalesLeadAfterOwner    = newUser.LastName + newUser.FirstName;
                newOwnerEmail          = newEmployee.EvMailAddr__c;
                newOwnerEpId           = newUser.FederationIdentifier;
                
                if(String.isNotBlank(oldOwnerEmail)){
                    oldOwnerId = oldOwnerEmail.left(oldOwnerEmail.indexOf('@'));
                }
                if(String.isNotBlank(newOwnerEmail)){
                    newOwnerId = newOwnerEmail.left(newOwnerEmail.indexOf('@'));
                }
    
                //QA
                if(isSandbox){
                    LinkAddress = 'https://sdssfa--qa.lightning.force.com/lightning/r/Sales_Lead__c/'+sales.Id+'/view';
                }
                //REAL
                else{
                    LinkAddress = 'https://sdssfa.lightning.force.com/lightning/r/Sales_Lead__c/'+sales.Id+'/view';
                }
    
                /* ------------------------------------------------------------------------- */
                /* Jitterbit 통해 Knox Rest API 호출 시작 */
                List<String> inputVarList = new List<String>();
                inputVarList.add(oldOwnerId);
                inputVarList.add(newOwnerId);
                inputVarList.add(SalesLeadName);
                inputVarList.add(SalesLeadBeforeOwner);
                inputVarList.add(SalesLeadAfterOwner);
                inputVarList.add(oldOwnerEmail);
                inputVarList.add(newOwnerEmail);
                inputVarList.add(SalesLeadCahngeDate);
                inputVarList.add(SalesLeadDescription);
                inputVarList.add(LinkAddress);
                IF_KnoxChatSendController.sendLeadOwnerChangeChat(inputVarList);
                /* Jitterbit 통해 Knox Rest API 호출 종료*/
                /* ------------------------------------------------------------------------- */                
            }
            //------------------------------------------------------------------------------------------
        }//end of for
    }
    
    //Start v-1.5 [MYSALES-413]
    public static void setSLIntExtOnInsert(List<Sales_Lead__c> newSLList){
        Set<Id> accIds = new Set<Id>();
        List<Sales_Lead__c> slList = new List<Sales_Lead__c>();
        Map<Id, Account> accGIMap;
        for(Sales_Lead__c sl: newSLList){
            System.debug('SJOSHISL1>>' +sl.AccountId__r.mDomesticForeign__c);
            System.debug('SJOSHISL2>>' +sl.AccountId__c);
            if(sl.AccountId__c != null){
                accIds.add(sl.AccountId__c);
                slList.add(sl);
            }
        }
        if(accIds.size() > 0){
            accGIMap = new Map<Id, Account>([SELECT Id, mDomesticForeign__c FROM Account WHERE Id IN: accIds]);
        }
        System.debug('SJOSHISL3>>' +accGIMap);
        if(slList.size() > 0){
            for(Sales_Lead__c sl: slList){
                //Start v-1.7 [MYSALES-448]
                if(sl.Internal_External__c == null || sl.Internal_External__c == 'Undefined'){
                //End v-1.7 [MYSALES-448]
                    if(accGIMap.containsKey(sl.AccountId__c)){
                        System.debug('SJOSHISL4>>' +accGIMap.get(sl.AccountId__c).mDomesticForeign__c);
                        if(accGIMap.get(sl.AccountId__c).mDomesticForeign__c == '10'){
                            sl.Internal_External__c = 'Internal';
                        }
                        if(accGIMap.get(sl.AccountId__c).mDomesticForeign__c == '20'){
                            sl.Internal_External__c = 'External';
                        }
                        //Start v-1.7 [MYSALES-448]
                        if(accGIMap.get(sl.AccountId__c).mDomesticForeign__c == null){
                        	sl.Internal_External__c = 'Undefined';
                    	}
                        //End v-1.7 [MYSALES-448]
                    }
                } // Added as part of v-1.7 [MYSALES-448]
        	}
        }
    }
    
    public static void setSLIntExtOnUpdate(List<Sales_Lead__c> newSLList, Map<Id,Sales_Lead__c> oldSLMap){
        Set<Id> accIds = new Set<Id>();
        List<Sales_Lead__c> slList = new List<Sales_Lead__c>();
        List<Sales_Lead__c> slList2 = new List<Sales_Lead__c>();
        Map<Id, Account> accGIMap;
        
        for(Sales_Lead__c sl: newSLList){
            if(sl.AccountId__c != null){
                accIds.add(sl.AccountId__c);
                slList.add(sl);
            }
            if(sl.AccountId__c == null && sl.AccountId__c != oldSLMap.get(sl.Id).AccountId__c){
                slList2.add(sl);
            }
        }
        
        if(accIds.size() > 0){
            accGIMap = new Map<Id, Account>([SELECT Id, mDomesticForeign__c FROM Account WHERE Id IN: accIds]);
        }
        
        if(slList.size() > 0){
            for(Sales_Lead__c sl: slList){
                //Start v-1.7 [MYSALES-448]
                if((sl.Internal_External__c == null || sl.Internal_External__c == 'Undefined') || (sl.AccountId__c != oldSLMap.get(sl.Id).AccountId__c  && accGIMap.get(sl.AccountId__c).mDomesticForeign__c != null)){
                //End v-1.7 [MYSALES-448]   
                    if(accGIMap.containsKey(sl.AccountId__c)){
                        if(accGIMap.get(sl.AccountId__c).mDomesticForeign__c == '10'){
                            sl.Internal_External__c = 'Internal';
                        }
                        if(accGIMap.get(sl.AccountId__c).mDomesticForeign__c == '20'){
                            sl.Internal_External__c = 'External';
                        }
                        if(accGIMap.get(sl.AccountId__c).mDomesticForeign__c == null){
                            sl.Internal_External__c = 'Undefined';
                        }
                    }
                } // Added as part of v-1.7 [MYSALES-448] 
        	}
        }
        
        if(slList2.size() > 0){
            for(Sales_Lead__c sl: slList2){
                sl.Internal_External__c = 'Undefined';
        	}
        }
    }
    
    private static void validation2(List<Sales_Lead__c> newList){
        String a;
        Set<Id> userIds = new Set<Id>();
        Map<Id, User> userToCompanyCodeMap;
        for(Sales_Lead__c rowSalesLead : newList){
            if(rowSalesLead.OwnerId != null){
                userIds.add(rowSalesLead.OwnerId);
            }
        }
        
        if(userIds.size() > 0){
            userToCompanyCodeMap =  new Map<Id, User>([SELECT Id, CompanyCode__c FROM USER WHERE Id IN : userIds]);
        }     
            
        for(Sales_Lead__c rowSalesLead : newList){
            if(rowSalesLead.RecordTypeId == RT_SL_HQ_ID && userToCompanyCodeMap.get(rowSalesLead.OwnerId).CompanyCode__c == 'T100' && rowSalesLead.LeadChannel__c == 'Direct Registration'){
                if(rowSalesLead.AccountId__c == null || rowSalesLead.Amount__c == null || rowSalesLead.SalesDepartment__c == null || rowSalesLead.Internal_External__c == 'Undefined'){
                    //Start v-1.5 [MYSALES-413 Additional Changes]
                    if(rowSalesLead.AccountId__c == null){
                        rowSalesLead.AccountId__c.addError(System.Label.SL_ERR_NULL_CHK_ACC);
                    }
                    if(rowSalesLead.Amount__c == null){
                        rowSalesLead.Amount__c.addError(System.Label.SL_ERR_NULL_CHK_AMT);
                    }
                    if(rowSalesLead.Internal_External__c == 'Undefined'){
                        rowSalesLead.addError(System.Label.SL_ERR_NULL_CHK_IE);
                    }
                    if(rowSalesLead.SalesDepartment__c == null){
                        rowSalesLead.SalesDepartment__c.addError(System.Label.SL_ERR_NULL_CHK_SD);
                    }
                    //End v-1.5 [MYSALES-413 Additional Changes]
                    //rowSalesLead.addError(System.Label.SL_ERR_NULL_CHK); // Commented out as part of v-1.5 [MYSALES-413 Additional Changes]
                }  
             }
         }    
    } 
    //End v-1.5 [MYSALES-413]
    //Start v-1.6
    private static void OwnershipChange(List<Sales_Lead__c> newList, Map<Id, Sales_Lead__c> oldMap){
        Set<Id> SalesLeadIdSet = new Set<Id>();
        for(Sales_Lead__c sales : newList){
            if(sales.ownerId != oldMap.get(sales.Id).ownerId){
                SalesLeadIdSet.add(sales.Id);
            } 
        }  
        if(SalesLeadIdSet.size()>0){
        	List<Sales_Lead_Team__c> sltList = [SELECT Id, OwnerId, AccessLevel__c, SalesLead_TeamMember__c, Sales_Lead__c, Team_Role__c FROM Sales_Lead_Team__c where Sales_Lead__c IN :SalesLeadIdSet];
            List<Sales_Lead__Share> slsList = [Select Id,UserOrGroupId,ParentId,AccessLevel from Sales_Lead__Share where ParentId IN :SalesLeadIdSet and RowCause = 'Manual'];
            if(sltList.size()>0) Delete sltList;
            if(slsList.size()>0) Delete slsList;
        }
        
    }
    private static void OwnershipChangeTime(List<Sales_Lead__c> newList, Map<Id, Sales_Lead__c> oldMap){
        for(Sales_Lead__c sales : newList){
            if(sales.ownerId != oldMap.get(sales.Id).ownerId){
                sales.Owner_Change_Time__c = DateTime.now();
            } 
        }
    }
    //End v-1.6
    //Start v-1.8
    public static void checkSalesLeadStage(List<Sales_Lead__c> newList){
        for(Sales_Lead__c sl :newList){
            if(sl.LeadStatus__c != 'In Process'){
                sl.LeadStatus__c.addError(System.Label.SALES_LEAD_STATUS_ERR);
            }
        }
    }
    //End v-1.8
}