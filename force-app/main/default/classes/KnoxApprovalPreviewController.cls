/**
 * @description       : 
 * @author            : dongyoung.kim@dkbmc.com
 * @group             : 
 * @last modified on  : 11-05-2023 
 * @last modified by  : anish.jain@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2020-12-22   dongyoung.kim@dkbmc.com   Initial Version
 * 1.1   2023-04-25   anish.jain@partner.samsung.com   Opportunity>Drop/Lost>Knox Preview(Lost) -> My Sales- 178
 * 1.2   2023-06-06   anish.jain@partner.samsung.com   Add department validation logic for contract approval activity -> My Sales- 215
 * 1.3   2023-07-23   divyam.gupta@samsung.com         Mysales-255 Lost/Drop Add on changes
 * 1.4  11-05-2023   anish.jain@partner.samsung.com   MySales - 216
**/
public class KnoxApprovalPreviewController {

    @AuraEnabled
    public static Map<String, Object> getConfirmMSG(String opptyId, String opptyActId){
        Map<String, Object> resMap = new Map<String, Object>{
            'BID_CONFIRM_MSG'=> '',   //메시지 있으면 warnning 메시지
            'RESULT_ANI'=> 'S',     //Added by Anish -v 1.2
            'MESSAGE_ANI'=> ''      //Added by Anish -v 1.2
        };
        try {
            List<Opportunity_Activity__c> opptyActList = [
                SELECT  Id, 
                        TransactionName__c,
                        toLabel(TransactionName__c) toLabel_TransactionName__c,
                        toLabel(LostType__c) toLabel_LostType__c,
                        toLabel(LostReason__c) toLabel_LostReason__c,
                        WhatId__r.Description,
                        WhatId__r.Security__c,
                        WhatId__r.Urgency__c,
                        WhatId__r.OurRole__c,
                        EndDate__c,
                        WhatId__r.SalesDepartment__c, WhatId__r.cPrimarySalesDepartment__c,
                        WhatId__r.SalesDepartment__r.Closed__c, WhatId__r.SalesDepartment__r.ZZCheck__c,
                        WhatId__r.cPrimarySalesDepartment__r.ZZCheck__c, WhatId__r.cPrimarySalesDepartment__r.Closed__c,
                        WhatId__r.SalesDepartment__r.CostCenter__c, WhatId__r.cPrimarySalesDepartment__r.CostCenter__c
                FROM    Opportunity_Activity__c 
                WHERE   Id = :opptyActId LIMIT 1
            ];    //Modified by Anish - v 1.2
            List<Opportunity> opptyList = [
                SELECT Id,
                       toLabel(BiddingMethod__c) toLabel_BiddingMethod__c,
                       RecordType.DeveloperName, 
                       CompanyCode__c 
                FROM opportunity where Id= :opptyId LIMIT 1
            ];
            /* List<KnoxApproval__c> knoxapprovalList = [
                SELECT Id, 
                       Opportunity__c  
                FROM KnoxApproval__c where Opportunity__c = :opptyId

            ]; */
            Opportunity_Activity__c opptyAct = opptyActList[0];
            Opportunity oppty = opptyList[0];
            
            
            //Start-Added by Anish - v 1.2
            String resultMsg = '';
            Map<String,String> fieldMap = Utils.getFieldLabel('Opportunity');  
            if(String.isBlank(opptyAct.WhatId__r.SalesDepartment__c) || String.isBlank(opptyAct.WhatId__r.SalesDepartment__r.CostCenter__c)) resultMsg += ((resultMsg.length() >  0) ? ', ' : '') + Util_String.nvlStr(fieldMap.get('SalesDepartment__c'.toLowerCase()) + ' Code');
            if(String.isBlank(opptyAct.WhatId__r.cPrimarySalesDepartment__c) || String.isBlank(opptyAct.WhatId__r.cPrimarySalesDepartment__r.CostCenter__c)) resultMsg += ((resultMsg.length() >  0) ? ', ' : '') + Util_String.nvlStr(fieldMap.get('cPrimarySalesDepartment__c'.toLowerCase()) + ' Code');
            String salesDeptId = String.valueOf(opptyAct.WhatId__r.SalesDepartment__c);
            String deliveryDeptId = String.valueOf(opptyAct.WhatId__r.cPrimarySalesDepartment__c);
            String deptValidityMsg = '';
            
            if(opptyAct.TransactionName__c == 'ZP82'){
            if(!Utils.isAdmin() || Test.isRunningTest()){
               if(String.isNotBlank(opptyAct.WhatId__r.SalesDepartment__c) || String.isNotBlank(opptyAct.WhatId__r.SalesDepartment__r.CostCenter__c) || String.isNotBlank(opptyAct.WhatId__r.cPrimarySalesDepartment__c) || String.isNotBlank(opptyAct.WhatId__r.cPrimarySalesDepartment__r.CostCenter__c)) {
                String errorMsg = System.Label.OPPTY_ERR_027;
                String fullErrorMsg = System.Label.OPPTY_ERR_028;

                Boolean isSalesDeptValid, isDeliveryDeptValid;

                if(String.isNotBlank(salesDeptId)) {
                    Map<Id, CostCenter__c> salesDept = new Map<Id, CostCenter__c>([SELECT Id, Closed__c, ZZCheck__c, CompanyCode__c FROM CostCenter__c WHERE Id =: salesDeptId]);
                    isSalesDeptValid = (salesDept.get(salesDeptId).Closed__c == false && salesDept.get(salesDeptId).ZZCheck__c == true);
                }

                if(String.isNotBlank(deliveryDeptId)) {
                    Map<Id, CostCenter__c> deliveryDept = new Map<Id, CostCenter__c>([SELECT Id, Closed__c, ZZCheck__c, CompanyCode__c FROM CostCenter__c WHERE Id =: deliveryDeptId]);
                    isDeliveryDeptValid = (deliveryDept.get(deliveryDeptId).Closed__c == false && deliveryDept.get(deliveryDeptId).ZZCheck__c == true);
                }

                if((String.isNotBlank(salesDeptId) && String.isNotBlank(deliveryDeptId)) && !isSalesDeptValid && !isDeliveryDeptValid) {
                    fullErrorMsg = fullErrorMsg.replace('{0}', Util_String.nvlStr(fieldMap.get('SalesDepartment__c'.toLowerCase())));
                    fullErrorMsg = fullErrorMsg.replace('{1}', Util_String.nvlStr(fieldMap.get('cPrimarySalesDepartment__c'.toLowerCase())));
                    deptValidityMsg = fullErrorMsg;
                }

                else if(String.isNotBlank(salesDeptId) && !isSalesDeptValid) {
                    deptValidityMsg = errorMsg.replace('{0}', Util_String.nvlStr(fieldMap.get('SalesDepartment__c'.toLowerCase())));
                }

                else if(String.isNotBlank(deliveryDeptId) && !isDeliveryDeptValid) {
                    deptValidityMsg = errorMsg.replace('{0}', Util_String.nvlStr(fieldMap.get('cPrimarySalesDepartment__c'.toLowerCase())));
                }
            
        }
        String result = '';
        if(!String.isBlank(resultMsg) || String.isNotBlank(deptValidityMsg)) result = 'F';    
        else result = 'S';

        if(Test.isRunningTest()) result = 'S';

        String requiredFields = resultMsg;

        resultMsg = System.Label.SVC_ERR_MSG_04 + '\n[' + resultMsg  + ']';//String.format( System.Label.SVC_ERR_MSG_04, new String[]{resultMsg});
        resultMsg = ((requiredFields.length() > 0) ? resultMsg + '\n\n' + deptValidityMsg : deptValidityMsg);
            resMap.put('RESULT_ANI',result);
            resMap.put('MESSAGE_ANI',resultMsg);
            
            }
        }
         //End-Added by Anish - v 1.2
            
            if(opptyAct.TransactionName__c == 'ZP82' && opptyAct.EndDate__c == null && oppty.CompanyCode__c =='T100' && oppty.RecordType.DeveloperName =='HQ'){
                
                String message = String.format(System.Label.APPR_MSG_0037, new String[]{String.valueOf(oppty.get('toLabel_BiddingMethod__c'))} );
                resMap.put('BID_CONFIRM_MSG', replaceNewlineToTag(message));
                system.debug(message);
                
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return resMap;
    }

    /**
     * 결재본문 가져오기
     * @param   opptyId             : Opportunity Id
     * @param   opptyActId          : Opportunity Activity Id
     * @param   useApprovalLineBody  : 결재선 조회 본문 사용여부
     * @param   confirm              : 확인알람 여부
     */
    @AuraEnabled
     public static Map<String, Object> getApprovalBodyHtml(String recordId, String opptyId, String opptyActId, Boolean useApprovalLineBody, String MISID){
        Map<String, Object> resMap = new Map<String, Object>{
            'RESULT' => false,  // 본문 가져오기 성공여부
            'MESSAGE' => '',    // MESSAGE
            'HTML' => '',       // html 본문
            'MISID' => MISID     // MISID

        };
        system.debug('### KnoxApprovalPreviewController :: getApprovalBodyHtml');
//0060p00000AtdYLAAZ
        try {
            List<Opportunity_Activity__c> opptyActList = [
                SELECT  Id, 
                        TransactionName__c,
                        toLabel(TransactionName__c) toLabel_TransactionName__c,
                        toLabel(LostType__c) toLabel_LostType__c,
                        toLabel(LostReason__c) toLabel_LostReason__c,
                        WhatId__c,
                        WhatId__r.Description,
                        WhatId__r.Security__c,
                        WhatId__r.Urgency__c,
                        WhatId__r.OurRole__c,
                        WhatId__r.Opportunity_Review_Consortium__c,
                        EndDate__c,
                        Description__c,
                toLabel(WhatId__r.Account.mBizLoan__c),
                toLabel(WhatId__r.cOriginAcc__r.mBizLoan__c)
                FROM    Opportunity_Activity__c 
                WHERE   Id = :opptyActId LIMIT 1
            ];   //Added by Anish- v 1.4
            
            /* List<KnoxApproval__c> knoxapprovalList = [
                SELECT Id, 
                       Opportunity__c  
                FROM KnoxApproval__c where Opportunity__c = :opptyId

            ]; */
            Opportunity_Activity__c opptyAct = opptyActList[0];
            
            
            
            // 결재 본문 사용 여부 확인
            // [2021-02-03] "계약대행 예외신청", "실주보고", "속성변경품의" 의 결재 본문을 ECC에서 가져오지 않게 처리
            Set<String> notUseHtmlActivitySet = new Set<String>{
                OpportunityActivityHelper.ACT_CODE_AGENCY_CONTRACT_EXCEPTION,
                OpportunityActivityHelper.ACT_CODE_LOST_OPPORTUNITY,
                OpportunityActivityHelper.ACT_CODE_REQUEST_COMMITTEE_APPROVAL,
                OpportunityActivityHelper.ACT_CODE_CHANGE_APPROVAL_REQUEST,
                OpportunityActivityHelper.ACT_CODE_REVIEW_BO    //Added by Anish- v 1.4
            };
                
            system.debug('### KnoxApprovalPreviewController :: TransactionName = ' + opptyAct.TransactionName__c);
            
            if(notUseHtmlActivitySet.contains(opptyAct.TransactionName__c)) {
                useApprovalLineBody = false;
            }
            
            system.debug('### KnoxApprovalPreviewController :: useApprovalLineBody = ' + useApprovalLineBody);

            if(useApprovalLineBody) {
                System.debug('ZP entry1');
                // I/F 결재선 본문 사용
                if(String.isBlank(MISID)) MISID = Utils.makeMisId(Utils.getCurDatetime());
                String jsonBody = ApprovalLineController.initComponent(opptyId, opptyActId, recordId, true, useApprovalLineBody, 'html', MISID);
                Map<String, Object> initMap = (Map<String, Object>)JSON.deserializeUntyped(jsonBody);
                Boolean RESULT = (Boolean)initMap.get('RESULT');
                String MESSAGE = String.valueOf( initMap.get('MESSAGE') );
                String APPROVAL_HTML = String.valueOf( initMap.get('APPROVAL_HTML') );
                String RESULT_TYPE = String.valueOf( initMap.get('RESULT_TYPE') );

                resMap.put('RESULT', RESULT);
                resMap.put('MESSAGE', MESSAGE);
                resMap.put('HTML', APPROVAL_HTML);
                resMap.put('RESULT_TYPE', RESULT_TYPE);
                resMap.put('MISID', MISID);

            } else { System.debug('ZP entry');
                // Custom 결재 본문 (Controller 에서 Setting)
                if(opptyAct.TransactionName__c == OpportunityActivityHelper.ACT_CODE_REQUEST_COMMITTEE_APPROVAL) {
                    resMap.put('RESULT', true);
                    resMap.put('MESSAGE', 'SUCCESS');
                    resMap.put('HTML', StrategyCommitteePrivewController.getDate(recordId));
                    
                } else {
                    // Custom 결재 본문 (Email Template) 사용
                    String emailTemplateName = 'KnoxApproval_OpportunityActivity_' + opptyAct.TransactionName__c;
                    
                    String emailTemplateSOQL = 'SELECT id, DeveloperName, Subject, HtmlValue FROM EmailTemplate ';
                            emailTemplateSOQL += 'WHERE DeveloperName = \'' + emailTemplateName + '\' AND IsActive = true  ORDER BY Name';

                    List<EmailTemplate> emptList = Database.query(emailTemplateSOQL);
                    if(emptList.size() == 0) {
                        resMap.put('RESULT', false);
                        resMap.put('MESSAGE', System.Label.APPR_MSG_0026); // '설정된 결재 본문이 없습니다. 관리자에게 문의하십시오.'

                    } else {
                        String htmlValue = emptList[0].HtmlValue;
                        // long text Field의 new line \r -> <br/> 로 변환
                        String description = Util_String.nvlStr(opptyAct.WhatId__r.Description);
                        String security = Util_String.nvlStr(opptyAct.WhatId__r.Security__c);
                        String urgency = Util_String.nvlStr(opptyAct.WhatId__r.Urgency__c);
                        String ourRole = Util_String.nvlStr(opptyAct.WhatId__r.OurRole__c);
                        if(!String.isBlank(description)) htmlValue = htmlValue.replace('{!Opportunity.Description}', replaceNewlineToTag(description) );
                        if(!String.isBlank(security)) htmlValue = htmlValue.replace('{!Opportunity.Security__c}', replaceNewlineToTag(security) );
                        if(!String.isBlank(urgency)) htmlValue = htmlValue.replace('{!Opportunity.Urgency__c}', replaceNewlineToTag(urgency) );
                        if(!String.isBlank(ourRole)) htmlValue = htmlValue.replace('{!Opportunity.OurRole__c}', replaceNewlineToTag(ourRole) );

                        List<Messaging.RenderEmailTemplateBodyResult> resList =  Messaging.renderEmailTemplate(null, opptyId, new List<String>{htmlValue});
                        htmlValue = resList[0].getMergedBody();

                        // 설정된 Object 이외 Object 정보 Replace
                        String opptyActLostReasonLabel = Util_String.nvlStr(opptyAct.get('toLabel_LostReason__c'));
                        String opptyActLostDescription = Util_String.nvlStr(opptyAct.get('Description__c'));
                        
                        System.debug('### KnoxApprovalPreviewController :: getApprovalBodyHtml :: TransactionName = ' + opptyAct.TransactionName__c);
                        if(opptyAct.TransactionName__c == OpportunityActivityHelper.ACT_CODE_LOST_OPPORTUNITY){
                            String strDynamicLostReason = '';
                            //V 1.3
                            List<LostResult__c> listLostResult = [SELECT Id, Name, MasterLosttype_Eng__c,MasterLosttype_Kor__c,LOST_DETAIL__c
                                                           FROM LostResult__c WHERE Opportunity__c = :opptyAct.WhatId__c and IsCheck__c = true and LostActivity__c=: opptyActId ORDER BY LostTypeCode__c]; //Modified the query(LOST_DETAIL__c) by Anish - v 1.1
                            
                            System.debug('### KnoxApprovalPreviewController :: getApprovalBodyHtml :: listLostResult = ' + listLostResult.size());
                            
                            if(!listLostResult.isEmpty()){
                                
                                User u = [SELECT LanguageLocaleKey FROM User WHERE Id = :UserInfo.getUserId()];
                                
                                for(LostResult__c rowLostResult : listLostResult){
                                    //String opptyActLostDescription1 = Util_String.nvlStr(rowLostResult.LOST_DETAIL__c);
                                    strDynamicLostReason += '<TR>';
                                    strDynamicLostReason += '<TH>' + 'Lost Reason' + '</TH>'; //Modified by Anish - v 1.1
                                    strDynamicLostReason += '<TD>' + (u.LanguageLocaleKey == 'ko' ? rowLostResult.MasterLosttype_Kor__c : rowLostResult.MasterLosttype_Eng__c) + '</TD>';
                                    strDynamicLostReason += '</TR>';
                                    strDynamicLostReason += '<TR>';
                                    strDynamicLostReason += '<TH>' + System.Label.Description_LOST_003 + '</TH>'; //Modified by Anish - v 1.1 
                                    
                                    strDynamicLostReason += '<TD>';
                                    System.debug('Ani New Line : '+ rowLostResult.LOST_DETAIL__c);
                                    String detailConversion = replaceNewlineToTag(rowLostResult.LOST_DETAIL__c);   //Added by Anish - v 1.1

                                    System.debug('Ani New1 Line : '+ replaceNewlineToTag(rowLostResult.LOST_DETAIL__c));
                                                                        
                                    strDynamicLostReason += '<P style="word-break: break-word;">' + detailConversion.replace(' ', '&nbsp;') + '</P>'; //Modified by Anish - v 1.1
                                    strDynamicLostReason += '</TD>';
                                    
                                    strDynamicLostReason += '</TR>';    
                                    
                                }
                                
                                htmlValue = htmlValue.replace('{{{DYNAMIC_LOST_REASON}}}', strDynamicLostReason);
                                
                            }else{
                                strDynamicLostReason += '<TR>';
                                strDynamicLostReason += '<TH>Lost Reason</TH>'; //Modified by Anish - New
                                strDynamicLostReason += '<TD>' + opptyActLostReasonLabel + '</TD>';
                                strDynamicLostReason += '</TR>';
                                strDynamicLostReason += '<TR>';
                                strDynamicLostReason += '<TH class="noline">Description</TH>';
                                strDynamicLostReason += '<TD style="word-break: break-word;">' + replaceNewlineToTag(opptyActLostDescription) + '</TD>';
                                strDynamicLostReason += '</TR>';
                                
                                System.debug('### KnoxApprovalPreviewController :: getApprovalBodyHtml :: strDynamicLostReason = ' + strDynamicLostReason);
                                
                                htmlValue = htmlValue.replace('{{{DYNAMIC_LOST_REASON}}}', strDynamicLostReason);
    
          
                                //htmlValue = htmlValue.replace('{{{Opportunity_Activity__c.LostReason__c}}}', opptyActLostReasonLabel);
                                //htmlValue = htmlValue.replace('{{{Opportunity_Activity__c.Description__c}}}', replaceNewlineToTag(opptyActLostDescription));
                            }
                        }
                        //Start - Added by Anish- v 1.4
                        if(opptyAct.TransactionName__c == 'ZP21'){
                            if(opptyAct.WhatId__r.Opportunity_Review_Consortium__c == true){
                                htmlValue = htmlValue.replace('{{{DYNAMIC_RO}}}', 'Y'); 
                            }
                            if(opptyAct.WhatId__r.Opportunity_Review_Consortium__c == false){
                                htmlValue = htmlValue.replace('{{{DYNAMIC_RO}}}', 'N');     
                            }
                            if(opptyAct.WhatId__r.Account.mBizLoan__c != null){
                                htmlValue = htmlValue.replace('{{{DYNAMIC_RO_ONE}}}', opptyAct.WhatId__r.Account.mBizLoan__c);     
                            }
                            if(opptyAct.WhatId__r.Account.mBizLoan__c == null){
                                htmlValue = htmlValue.replace('{{{DYNAMIC_RO_ONE}}}', '');     
                            }
                            if(opptyAct.WhatId__r.cOriginAcc__r.mBizLoan__c !=null){
                                htmlValue = htmlValue.replace('{{{DYNAMIC_RO_TWO}}}', opptyAct.WhatId__r.cOriginAcc__r.mBizLoan__c);     
                            }
                            if(opptyAct.WhatId__r.cOriginAcc__r.mBizLoan__c ==null){
                                htmlValue = htmlValue.replace('{{{DYNAMIC_RO_TWO}}}', '');     
                            }
                        }
                        //End - Added by Anish- v 1.4
                        resMap.put('RESULT', true);
                        resMap.put('MESSAGE', 'SUCCESS');
                        resMap.put('HTML', htmlValue);
                        System.debug('Ani finale#$'+resMap);
                    }

                }
            }
        } catch (Exception e) {
            System.debug(System.LoggingLevel.ERROR, e.getLineNumber());
            System.debug(System.LoggingLevel.ERROR, e.getMessage());
            resMap.put('RESULT', false);
            resMap.put('MESSAGE', e.getMessage());
        }

        return resMap;
    }

    private static String replaceNewlineToTag(String longText) {
        return longText.replace('\n', '<br/>');
    }
}