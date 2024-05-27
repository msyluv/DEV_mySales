/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 11-11-2021
 * @last modified by  : zenith21c@test.com
**/
trigger LeadTrigger on Lead (before insert, before update, after update) {

    // Trigger Switch
    TriggerSwitch__c trSwitch = TriggerSwitch__c.getInstance(UserInfo.getUserId()); // Current User 기준으로 Custom Setting 가져옴
    Boolean MigSwitch = trSwitch.Migration__c;  // Data Migration 시 제외할 로직인 경우 true

    switch on trigger.operationType{
        when BEFORE_INSERT{
            if(!MigSwitch) statusSetting(Trigger.new);
            if(!MigSwitch) descriptionSetting(Trigger.new);
            // if(!MigSwitch) costCenterSetting(Trigger.new);
        }
        when BEFORE_UPDATE{
            if(!MigSwitch) stageSetting(Trigger.new, Trigger.oldMap);
            if(!MigSwitch) statusSetting(Trigger.new);
            if(!MigSwitch) cancelClose(Trigger.new, Trigger.oldMap);
            if(!MigSwitch) descriptionSetting(Trigger.new);
            if(!MigSwitch) afterConvertedCheck(Trigger.new, Trigger.oldMap);
            if(!MigSwitch) cancelConvert(Trigger.new, Trigger.oldMap);
            // if(!MigSwitch) costCenterSetting(Trigger.new);
        }
        when AFTER_UPDATE{
            if(!MigSwitch) sendOwnerChangeKnoxEmail(Trigger.new, Trigger.old);

            //owner변경시 knox 공지 채팅 전송
            if(!MigSwitch) sendOwnerChangeKnoxChat(Trigger.new, Trigger.old);
        }
    }
    
    // Stage Setting
    // 1. Stage는 역행할 수 없음 (Stage 순서 : Cold -> Warm -> Converted)
    // 2. 소유자가 변경되는경우 Stage를 Warm으로 자동 변경(Type이 'Spam인 경우는 제외)
    private static void stageSetting(List<Lead> newList, Map<Id, Lead> oldMap){
        
        User u = [Select Id,Profile.Name from User where Id =: UserInfo.getUserId()];
        
        for(Lead lead : newList){
            if(lead.LeadStage__c != null){
                Integer afterStage = 0;
                if(lead.LeadStage__c == 'Cold') afterStage = 1;
                if(lead.LeadStage__c == 'Warm') afterStage = 2;
                if(lead.LeadStage__c == 'Converted') afterStage = 3;
                
                Integer beforeStage = 0;
                Lead oldLead = oldMap.get(lead.Id);
                if(oldLead.LeadStage__c == 'Cold') beforeStage = 1;
                if(oldLead.LeadStage__c == 'Warm') beforeStage = 2;
                if(oldLead.LeadStage__c == 'Converted') beforeStage = 3;
                
                if(beforeStage > afterStage){
                if(!(u.Profile.Name == 'CxO-Overseas Corp' || u.Profile.Name == 'Sales Manager(Overseas Corp)' || u.Profile.Name == 'Sales Rep.(Overseas Corp)')){
                    lead.addError(System.Label.CONVERT_LAB_MSG21); // The Lead Stage cannot be retrograde.
                }
                }
                
                if(lead.LeadType__c != null && lead.LeadType__c != '04' && (lead.OwnerId != oldLead.OwnerId)){
                    if(lead.LeadStage__c != 'Warm') lead.LeadStage__c = 'Warm';
                }

                if(lead.LeadType__c == null && (lead.OwnerId != oldLead.OwnerId)){
                    lead.addError(System.Label.CONVERT_LAB_MSG25); // You can change the owner only by selecting the Lead Type.
                }
			}
        }
    }

    // Status Setting
    // 1. Lead Type이 Spam(04)으로 변경되는 경우 자동으로 Status를 Close(종료)처리
    private static void statusSetting(List<Lead> newList){
        for(Lead lead : newList){
            if(lead.LeadType__c == '04'){
                if(lead.Status != 'Close') lead.Status = 'Close';
                if(lead.CloseReason__c == '') lead.CloseReason__c = 'Spam';
            }
        }
    }

    // Description Setting
    // 1. 마케팅리드의 Description 필드를 리스트뷰 표시용 필드 Decription__c에 복사(최대 255자 까지만)
    private static void descriptionSetting(List<Lead> newList){
        for(Lead lead : newList){
            if(lead.Description != null) lead.Description__c = (lead.Description).left(255);
        }
    }

    // After Converted Check
    // 1. 사업리드 변환이 완료된 마케팅리드는 리드상태, 종결사유, 리드유형 변경 불가능
    private static void afterConvertedCheck(List<Lead> newList, Map<Id, Lead> oldMap){
        for(Lead lead : newList){
            Lead oldLead = oldMap.get(lead.Id);
            if((lead.LeadStage__c == 'Converted' && oldLead.LeadStage__c == 'Converted') && (lead.Status != oldLead.Status || lead.CloseReason__c != oldLead.CloseReason__c || lead.LeadType__c != oldLead.LeadType__c)){
                lead.addError(System.Label.CONVERT_LAB_MSG22); // Marketing leads that have been converted cannot change Lead Status, Close Reason, Lead Type.
            }
        }
    }

    // Cancel Close
    // 1. Lead Status가 Close에서 In Process로 변경되는 경우 Close Reason(종결사유) 초기화
    private static void cancelClose(List<Lead> newList, Map<Id, Lead> oldMap){
        for(Lead lead : newList){
            Lead oldLead = oldMap.get(lead.Id);
            if(lead.Status == 'In Process' && oldLead.Status == 'Close'){
                lead.CloseReason__c = '';
            }
        }
    }
    
    private static void cancelConvert(List<Lead> newList, Map<Id, Lead> oldMap){
        //User u = [Select Id,Profile.Name from User where Id =: UserInfo.getUserId()];
        for(Lead lead : newList){
            Lead oldLead = oldMap.get(lead.Id);
            if(lead.SalesLeadID__c == null && (oldLead.SalesLeadID__c != lead.SalesLeadID__c) ){
                
                
                lead.CloseReason__c = '';
                lead.Status = 'In Process';
                lead.LeadStage__c = 'Warm';
                   
                
            }
        }
    }
    
    
    // CostCenter Setting
    // 1. 마케팅리드의 소유자가 속한 Cost Center를 자동으로 세팅
    // private static void costCenterSetting(List<Lead> newList){
    //     Set<Id> userIdSet = new Set<Id>();
    //     for(Lead lead : newList){
    //         userIdSet.add(lead.ownerId);
    //     }
    //     
    //     Map<Id, User> userMap = new Map<Id, User>([SELECT Id, FederationIdentifier, CompanyCode__c FROM User where Id =: userIdSet]);
    //     List<User> userList = userMap.values();
    //     Set<String> epIdSet = new Set<String>();
    //     for(User obj : userList){
    //         if(String.isNotBlank(obj.FederationIdentifier)){
    //             epIdSet.add(obj.FederationIdentifier);
    //         }
    //     }
    // 
    //     //Employee
    //     Map<String, Employee__c> empMap = new Map<String, Employee__c>();
    //     List<Employee__c> empList = [SELECT Id, EvKostl__c, EvUniqID__c, EvSapBukrs__c FROM Employee__c where EvUniqId__c =: epIdSet];
    //     for(Employee__c e : empList){  
    //         if(String.isNotBlank(e.EvUniqID__c)){
    //             empMap.put(e.EvUniqID__c, e);
    //         }
    //     }
    // 
    //     //CostCenter
    //     Map<String, CostCenter__c> costMap = new Map<String, CostCenter__c>();
    //     Set<Id> getCostCenterSet = new Set<Id>();
    //     List<CostCenter__c> costList = [SELECT Id, CostCenter__c, ZZCheck__c, Closed__c 
    //                                     				  FROM CostCenter__c  
    //         											WHERE ZZCheck__c = true 
    //                                     				    AND Closed__c = false];
    //     for(CostCenter__c c : costList){
    //         costMap.put(c.CostCenter__c,c);
    //         getCostCenterSet.add(c.Id);
    //     }
    // 
    //     for(Lead lead : newList) {
    //         if(userMap.get(lead.ownerId) != null){
    //             if(empMap.get(String.valueOf(userMap.get(lead.ownerId).FederationIdentifier)) != null){
    //                 if(costMap.get(String.valueOf(empMap.get(String.valueOf(userMap.get(lead.ownerId).FederationIdentifier)).EvKostl__c)) != null){
    //                     lead.SalesDepartment__c = costMap.get(String.valueOf(empMap.get(String.valueOf(userMap.get(lead.ownerId).FederationIdentifier)).EvKostl__c)).id;
    //                 }else{
    //                     lead.SalesDepartment__c = null;
    //                 }
    //             }
    //         }
    //     }
    // }

    // Owner가 변경되는 경우 알림메일 발송
    private static void sendOwnerChangeKnoxEmail(List<Lead> newList, List<Lead> oldList){ // Migration에서는 제외
        // Email Template조회
        EmailTemplate emailTemplate = getEmailTemplate('Lead_Owner_Change_Email');

        List<KnoxEmail__c> KnoxEmailList = new List<KnoxEmail__c>();
    
        for(Lead lead : newList){
            System.debug('lead : ' + lead);
            Map<Id, Lead> oldMap = new Map<Id, Lead>(oldList);
            String oldOwnerId = oldMap.get(lead.Id).ownerId;
            String newOwnerId = lead.ownerId;
            Boolean isOwnerChange = (oldOwnerId != newOwnerId);
    
            // String leadName = lead.FirstName != null ? lead.FirstName : '' + ' ' + lead.LastName != null ? lead.LastName : '';
            String lastName = (lead.LastName == null) ? '' : lead.LastName;
            String firstName = (lead.FirstName == null) ? '' : lead.FirstName;
            String leadName = lastName + (String.isBlank(firstName) ? '' : ' ' + firstName);
            String leadBeforeOwner = '';
            String leadAfterOwner = '';
            String leadDescription = lead.Description;
            Datetime modifyDate = lead.LastModifiedDate;
            String leadCahngeDate = modifyDate.format('yyyy-MM-dd a HH:mm:ss');
            
            String oldOwnerEmail = '';
            String oldOwnerEpId = '';
            String newOwnerEmail = '';
            String newOwnerEpId = '';
            String systemEmail = '';
            String systemId = '';
            String subject = String.valueOf(emailTemplate.Subject);
            String LinkAddress = '';
            
            if(isOwnerChange) { // Owner가 변경되었으면 Knox Email을 발송
                Boolean isSandbox = Utils.getIsSandbox();
                User oldUser = getUser(oldOwnerId);
                Employee__c oldEmployee = Utils.getEmployeeData(oldUser.FederationIdentifier);
                User newUser = getUser(newOwnerId);
                Employee__c newEmployee = Utils.getEmployeeData(newUser.FederationIdentifier);
                Employee__c senderEmployee;

                leadBeforeOwner = oldUser.LastName + oldUser.FirstName;
                oldOwnerEmail = oldEmployee.EvMailAddr__c;
                oldOwnerEpId = oldUser.FederationIdentifier;
                leadAfterOwner = newUser.LastName + newUser.FirstName;
                newOwnerEmail = newEmployee.EvMailAddr__c;
                newOwnerEpId = newUser.FederationIdentifier;

                if(isSandbox){// QA
                    systemEmail = 'oldman.sea@stage.samsung.com';
                    systemId    = 'a091s0000035Ax2AAE';
                    LinkAddress = 'https://sdssfa--qa.lightning.force.com/lightning/r/Sales_Lead__c/'+lead.Id+'/view';

                    if(oldOwnerEmail == null) oldOwnerEmail = 'oldman.sea@stage.samsung.com';
                    if(newOwnerEmail == null) newOwnerEmail = 'oldman.sea@stage.samsung.com';
                    oldOwnerEmail = oldOwnerEmail.replace('@samsung.com', '@stage.samsung.com');
                    newOwnerEmail = newOwnerEmail.replace('@samsung.com', '@stage.samsung.com');
                }else{ // Production
                    systemEmail = 'mysales@samsung.com';
                    LinkAddress = 'https://sdssfa.lightning.force.com/lightning/r/Sales_Lead__c/'+lead.Id+'/view';

                    List<User> userList = [SELECT Id, Name From User WHERE Username = :systemEmail];
		            if(userList.size() > 0) senderEmployee = Utils.getLoginEmployeeData(userList.get(0).Id);
                    if(senderEmployee != null) systemId = senderEmployee.Id;
                }

                // Email 본문 처리
                String body = String.valueOf(emailTemplate.HtmlValue).replace('\r\n', '');
                if(leadName==null)          leadName = '';
                if(leadBeforeOwner==null)   leadBeforeOwner = '';
                if(leadAfterOwner==null)    leadAfterOwner = '';
                if(leadDescription==null)   leadDescription = '';
                if(leadCahngeDate==null)    leadCahngeDate = '';
                body = body.replace('{!LeadName}', leadName);
                body = body.replace('{!LeadBeforeOwner}', leadBeforeOwner);
                body = body.replace('{!LeadAfterOwner}', leadAfterOwner);
                body = body.replace('{!LeadDescription}', leadDescription);
                body = body.replace('{!LeadCahngeDate}', leadCahngeDate);
                body = body.replace('{!LinkAddress}',    LinkAddress); 
    
                // Knox mail 송신자 정보 처리
                IF_KnoxEmailSendController.Sender sender = new IF_KnoxEmailSendController.Sender(systemEmail.split('@')[0], systemEmail);
    
                // Knox mail 수신자 정보 처리
                List<IF_KnoxEmailSendController.Recipients> recipientsList = new List<IF_KnoxEmailSendController.Recipients>();
                List<String> toList = new List<String>();
                toList.add(oldOwnerEmail);
                toList.add(newOwnerEmail);
                recipientsList.add(new IF_KnoxEmailSendController.Recipients(oldOwnerEmail, 'TO'));
                recipientsList.add(new IF_KnoxEmailSendController.Recipients(newOwnerEmail, 'TO'));
                
                // Knox mail 전송처리
                IF_KnoxEmailSendController.InputClass bodyMap = new IF_KnoxEmailSendController.InputClass();
                bodyMap.subject = subject;
                bodyMap.contents = body;
                bodyMap.contentType = 'HTML';
                bodyMap.docSecuType = 'PERSONAL';
                bodyMap.sfdcId = lead.Id;
                bodyMap.recipients = recipientsList;
                bodyMap.sender = sender;
                bodyMap.isMulti = true;
                Map<String,Object> resMap = new Map<String,Object>();
                Map<String,Object> response = new Map<String, Object>();
                IF_KnoxEmailSendController.send2(JSON.serialize(bodyMap));
    
                KnoxEmail__c knoxemail = new KnoxEmail__c(
                    RecordId__c = lead.Id
                    , Sender__c = systemId
                    , ToAddress__c = String.join(toList, ',')
                    , Name = subject
                    , HtmlBody__c = leadDescription
                    , MailId__c = systemEmail
                    , Status__c = 'Send'
                );
                knoxemailList.add(knoxemail);
            }
        }
        insert knoxemailList;
    }

    //User 정보 조회
    private static User getUser(String userId){
        User returnUser = [SELECT Id, LastName, FirstName, Email, FederationIdentifier
                             FROM User
                            WHERE id = :userId];
        return returnUser;
    }
    
    //Email 템플릿 조회
    private static EmailTemplate getEmailTemplate(String templateName){
        EmailTemplate template = [SELECT Id, Name, DeveloperName, Subject, HtmlValue, Body 
                                    FROM EmailTemplate
                                   WHERE DeveloperName = :templateName 
                                   LIMIT 1];
        return template;
    }

    //Employee 정보 조회
    // private static Employee__c getEmployee(String FederationIdentifier){
    //     Employee__c returnEmployee = [SELECT Id, EvUniqID__c, EvMailAddr__c 
    //                                     FROM Employee__c 
    //                                    WHERE EvUniqID__c = :FederationIdentifier
    //                                    LIMIT 1];
    //     return returnEmployee;
    // }


    //Lead Owner변경시 Knox 공지 Chat(AppCard) 전송
    public static void sendOwnerChangeKnoxChat(List<Lead> newList, List<Lead> oldObjList){
        
        List<KnoxEmail__c> KnoxEmailList = new List<KnoxEmail__c>();
    
        for(Lead marketingLead : newList){
            Map<Id, Lead> oldMap = new Map<Id,Lead>(oldObjList);
            String oldOwnerId = oldMap.get(marketingLead.Id).ownerId;
            String newOwnerId = marketingLead.ownerId;
            Boolean isOwnerChange = (oldOwnerId != newOwnerId);
    
            String lastName = (marketingLead.LastName == null) ? '' : marketingLead.LastName;
            String firstName = (marketingLead.FirstName == null) ? '' : marketingLead.FirstName;
            String marketingLeadName = lastName + (String.isBlank(firstName) ? '' : ' ' + firstName);

            String marketingLeadBeforeOwner = '';
            String marketingLeadAfterOwner = '';
            String marketingLeadDescription = marketingLead.Description__c;
            Datetime modifyDate = marketingLead.LastModifiedDate;
            String marketingLeadChangeDate = modifyDate.format('yyyy-MM-dd a HH:mm:ss');
            
            String oldOwnerEmail = '';
            String oldOwnerEpId  = '';
            String newOwnerEmail = '';
            String newOwnerEpId  = '';
            String systemEmail   = '';
            String systemId = '';
            String linkAddress = '';
    
            //------------------------------------------------------------------------------------------
            //Owner가 변경되었으면 Knox Chat을 발송
            if(isOwnerChange) { 
                Boolean isSandbox = Utils.getIsSandbox();
                User oldUser = getUser(oldOwnerId);
                Employee__c oldEmployee = Utils.getEmployeeData(oldUser.FederationIdentifier);
                User newUser = getUser(newOwnerId);
                Employee__c newEmployee = Utils.getEmployeeData(newUser.FederationIdentifier);
                Employee__c senderEmployee;
    
                marketingLeadBeforeOwner   = oldUser.LastName + oldUser.FirstName;
                oldOwnerEmail          = oldEmployee.EvMailAddr__c;
                oldOwnerEpId           = oldUser.FederationIdentifier;
                marketingLeadAfterOwner    = newUser.LastName + newUser.FirstName;
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
                    linkAddress = 'https://sdssfa--qa.lightning.force.com/lightning/r/Lead/'+marketingLead.Id+'/view';
                }
                //REAL
                else{
                    linkAddress = 'https://sdssfa.lightning.force.com/lightning/r/Lead/'+marketingLead.Id+'/view';
                }
    
                /* ------------------------------------------------------------------------- */
                /* Jitterbit 통해 Knox Rest API 호출 시작 */
                Map<String, String> inputMap = new Map<String, String>();
                inputMap.put('oldSingleId', oldOwnerId);
                inputMap.put('newSingleId', newOwnerId);
                inputMap.put('marketingLeadName', marketingLeadName);
                inputMap.put('marketingLeadBeforeOwner', marketingLeadBeforeOwner);
                inputMap.put('marketingLeadAfterOwner', marketingLeadAfterOwner);
                inputMap.put('oldOwnerEmail', oldOwnerEmail);
                inputMap.put('newOwnerEmail', newOwnerEmail);
                inputMap.put('marketingLeadChangeDate', marketingLeadChangeDate);
                inputMap.put('marketingLeadDescription', marketingLeadDescription);
                inputMap.put('linkAddress', linkAddress);
                IF_KnoxChatSendController.sendMarketingLeadOwnerChangeChat(inputMap);
                /* Jitterbit 통해 Knox Rest API 호출 종료*/
                /* ------------------------------------------------------------------------- */                
            }
            //------------------------------------------------------------------------------------------
        }//end of for
    }
}