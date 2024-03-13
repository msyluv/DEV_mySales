/**
 * @description       : Opportunity Stage 등 Validation 유효성 체크
 * @Test Class        : OpportunityTrigger_Test
 * @author            : leehyo
 * @last modified on  : 2021-03-25
 * @last modified by  : kajal.c@samsung.com
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   2020-12-29   leehyo                   Initial Version
 * 1.1   2021-01-12   Junghwa.Kim@dkbmc.com    dateDefaultValue() 추가
 * 1.2   2021-01-12   leehyo                   validateStageLogistics 조건에 Opportunity.Type 추가
 * 1.3   2022-09-29   hyunhak.roh@dkbmc.com	   물류 - Auto Stage Update 관련 로직 추가 변경건
 * 1.4   2023-02-15   kajal.c@samsung.com	   Added condition for LBS Exception type related to Mysales-128
**/
public class OpportunityValidateHelper {    
    public static final Id RT_ID_LOGISTICS = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Logistics').getRecordTypeId();
    
    /**
     * Opportunity Record Type [Logistics] 
     * 물류 Stage 변경 가능 조건 체크
     */
    public static void validateStageLogistics(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        
        // Opportunity Stage Map
        List<Map<String, String>> stage = Utils.getPicklistOptionType('Opportunity','StageName');
        Map<String, Integer> stageMap = new Map<String, Integer>();
        for(Integer i =0 ;i< stage.size();i++){
            stageMap.put(stage[i].get('value'),i);
        }

        // Opportunity Activity Status Map
        List<Map<String, String>> opptActStatus = Utils.getPicklistOptionType('Opportunity_Activity__c','TransactionName__c');
        Map<String, String> opptActNameLabelMap = new Map<String, String>(); // <key : Api Name,  value : label>
        for(Integer i =0 ;i< opptActStatus.size();i++){
            opptActNameLabelMap.put(opptActStatus[i].get('value'), opptActStatus[i].get('label'));
        }

        
        // Validate 대상 Oppty Id Set 만들기
        Set<Id> opptyIdSet = new Set<Id>();
        for(Opportunity newOppty : newList) {
            Opportunity oldOppty;
            Boolean isStageChanged = true;
            Boolean isMigData = newOppty.MigData__c; // // Oppty Migration에서는 제외
            if(oldMap != null) {
                oldOppty = oldMap.get(newOppty.Id);
                isStageChanged = newOppty.StageName != oldOppty.StageName;
            }

            if(!isMigData && isStageChanged && (newOppty.RecordTypeId == RT_ID_LOGISTICS)) {
                opptyIdSet.add(newOppty.Id);
            }
        }

        system.debug(' 1.opptyIdSet.size() :' + opptyIdSet.size() );

        // Oppty with Oppty Act List
        // TODO : 물류일 경우에만 SOQL 수행되도록 수정. opptyIdSet Size 체크.
        Map<Id, Map<String, Opportunity_Activity__c>> opptyActListMap = new Map<Id, Map<String, Opportunity_Activity__c>>();
        List<Opportunity> opptyList = [
            SELECT  Id, (SELECT  Id, WhatId__c, TransactionName__c, Status__c FROM BO_Activity__r)
            FROM    Opportunity
            WHERE   Id IN :opptyIdSet
        ];
        for(Opportunity oppty : opptyList) {
            Map<String, Opportunity_Activity__c> opptyActMap = new Map<String, Opportunity_Activity__c>();
            for(Opportunity_Activity__c opptyAct : oppty.BO_Activity__r) {
                opptyActMap.put(opptyAct.TransactionName__c, opptyAct);
            }
            opptyActListMap.put(oppty.Id, opptyActMap);
        }

        for(Opportunity newOppty : newList) {
            Opportunity oldOppty;
            Boolean isStageChanged = true;
            Boolean isMigData = newOppty.MigData__c; // // Oppty Migration에서는 제외
            if(oldMap != null) {
                oldOppty = oldMap.get(newOppty.Id);
                isStageChanged = newOppty.StageName != oldOppty.StageName;
            }
            if(!isMigData && isStageChanged && (newOppty.RecordTypeId == RT_ID_LOGISTICS)) {
                
                /**
                 * Oppty 필드 조합 Customer Type + Opportunity Type + LBS ExceptionType 에 따라 Stage 변경할 수 있는 조건 확인
                 */
                // Stage 
                String STAGE_IDENTIFIED = OpportunityActivityHelper.OPP_STAGE_IDENTIFIED;
                String STAGE_VALIDATED  = OpportunityActivityHelper.OPP_STAGE_VALIDATED;
                String STAGE_QUALIFIED  = OpportunityActivityHelper.OPP_STAGE_QUALIFIED;
                String STAGE_SOLUTIONED = OpportunityActivityHelper.OPP_STAGE_SOLUTIONED;
                // Closed Stage
                String STAGE_WON        = OpportunityActivityHelper.OPP_STAGE_WON;
                String STAGE_LOST       = OpportunityActivityHelper.OPP_STAGE_LOST;
                String STAGE_DROP       = OpportunityActivityHelper.OPP_STAGE_DROP;
                
                // Customer Type : Picklist
                String CUSTOMER_TYPE_EXTERNAL           = OpportunityActivityHelper.OPP_CUSTOMER_TYPE_EXTERNAL;
                String CUSTOMER_TYPE_SEC_SET            = OpportunityActivityHelper.OPP_CUSTOMER_TYPE_SEC_SET;
                String CUSTOMER_TYPE_SEC_DS             = OpportunityActivityHelper.OPP_CUSTOMER_TYPE_SEC_DS;
                String CUSTOMER_TYPE_SAMSUNG_AFFILIATES = OpportunityActivityHelper.OPP_CUSTOMER_TYPE_SAMSUNG_AFFILIATES;

                // Opportunity Type : Picklist
                String OPP_TYPE_NEW_OPPORTUNITY         = OpportunityActivityHelper.OPP_TYPE_NEW_OPPORTUNITY;
                String OPP_TYPE_RETENTION               = OpportunityActivityHelper.OPP_TYPE_RETENTION;
                
                // LBS Exception Type : Picklist
                String OPP_LBS_TYPE_NOMI    = OpportunityActivityHelper.OPP_LBS_TYPE_NOMI;
                String OPP_LBS_TYPE_SMALL   = OpportunityActivityHelper.OPP_LBS_TYPE_SMALL;
                String OPP_LBS_TYPE_MEDIUM  = OpportunityActivityHelper.OPP_LBS_TYPE_MEDIUM;
                String OPP_LBS_TYPE_NA      = OpportunityActivityHelper.OPP_LBS_TYPE_NA;
                String OPP_LBS_TYPE_SQUARE_PRODUCT  = OpportunityActivityHelper.OPP_LBS_TYPE_SQUARE_PRODUCT; // V1.4 --> MySales-128

                // Opportunity Activity Transaction Name : Picklist
                String ACT_CODE_CREDIT_ASSESSMENT   = OpportunityActivityHelper.ACT_CODE_CREDIT_ASSESSMENT;      // 신용 평가
                String ACT_CODE_TARIFF_VERIFICATION = OpportunityActivityHelper.ACT_CODE_TARIFF_VERIFICATION;    // 전자사업 손익점검
                String ACT_CODE_BIDDING_LBS         = OpportunityActivityHelper.ACT_CODE_BIDDING_LBS;
                String ACT_CODE_FINAL_LBS           = OpportunityActivityHelper.ACT_CODE_FINAL_LBS;
                
                // Opportunity Activity Status : Picklist
                String ACT_STATUS_IN_PROGRESS = 'In Progress';
                String ACT_STATUS_COMPLETED = 'Completed';
                Set<String> progresscompletedSet = new Set<String>{ACT_STATUS_IN_PROGRESS, ACT_STATUS_COMPLETED}; //  진행중+완료 Set
                Set<String> completedSet = new Set<String>{ACT_STATUS_COMPLETED};                                 //  완료 Set

                Map<String, Opportunity_Activity__c> opptyActMap = opptyActListMap.get(newOppty.Id);
                
                String checkStage = '';
                String errorMsg = '';
                
                Set<String> passValidateStageSet = new Set<String>{ STAGE_WON, STAGE_LOST, STAGE_DROP };
                String opptyLogisticsCustomerType = newOppty.LogisticsCustomerType__c;
                String opptyType = newOppty.Type;
                String opptyLBSType = newOppty.LBSExceptionType__c;
                String opptyStage = newOppty.StageName;


                /**
                 * 변경할 Stage 로 이동시에만 Check (누적 X)
                 * 누적인 경우 아래 for문 주석 해제시킴
                **/

                // for(String tempStage : stageMap.keySet()){
                //     checkStage = tempStage;
                    // if(passValidateStageSet.contains(newOppty.StageName)) continue;
                
                // [C1~C6. Customer Type (External)]
                if(opptyLogisticsCustomerType == CUSTOMER_TYPE_EXTERNAL) { 
                    // I → V : 신용평가 '진행 이후' 변경 가능
                    
                    if(opptyStage == STAGE_VALIDATED) {
                        // V1.4 - START--> Added LBS Exception type condition.
                        if(opptyLBSType != OPP_LBS_TYPE_SQUARE_PRODUCT ){
                            if( !isValidOpptyAct(opptyActMap, ACT_CODE_CREDIT_ASSESSMENT, progresscompletedSet) ) {
                                // '{0}' Activity가 진행되지 않았습니다.
                                errorMsg += ' ' + String.format(System.Label.OPPTY_ERR_002,new String[]{opptActNameLabelMap.get(ACT_CODE_CREDIT_ASSESSMENT)}); 
                            }
                        }
                    }
                    
                    //2022-09-29, hyunhak.roh@dkbmc.com, 물류 - Auto Stage Update 관련 로직 추가 변경건
                    //External인 경우, 신용평가 엑티비티 완료 이후에만 다음 Stage인 Qualified로 진행 가능
                    if(opptyStage == STAGE_QUALIFIED || opptyStage == STAGE_SOLUTIONED || opptyStage == STAGE_WON) {
                        // V1.4 - START--> Added LBS Exception type condition.
                        if(opptyLBSType != OPP_LBS_TYPE_SQUARE_PRODUCT ){
                            if( !isValidOpptyAct(opptyActMap, ACT_CODE_CREDIT_ASSESSMENT, completedSet) ) {
                                // "{0}" BO 액티비티가 완료되지 않았습니다.
                                errorMsg += ' ' + String.format(System.Label.OPPTY_ERR_003,new String[]{opptActNameLabelMap.get(ACT_CODE_CREDIT_ASSESSMENT)}); 
                            }
                        }
                    }

                    // [C3. Customer Type (External) + Opportunity Type (New Opportunity) + LBS Exception Type (N/A)]
                    if(opptyType == OPP_TYPE_NEW_OPPORTUNITY && opptyLBSType == OPP_LBS_TYPE_NA) {

                        // ? → Q : Bidding LBS '완료' 이후
                        if(opptyStage == STAGE_QUALIFIED) {
                            //2022-09-29, hyunhak.roh@dkbmc.com, 물류 - Auto Stage Update 관련 로직 추가 변경건
                    		//Final LBS 상태 처리 및 Stage 자동 업데이트 시 Bidding LBS 상태 체크하는 로직 제거
                            /*if( !isValidOpptyAct(opptyActMap, ACT_CODE_BIDDING_LBS, completedSet) ) {                                
                                // '{0}' Activity가 완료되지 않았습니다.
                                errorMsg += ' ' + String.format(System.Label.OPPTY_ERR_003,new String[]{opptActNameLabelMap.get(ACT_CODE_BIDDING_LBS)}); 
                            }*/
                        }

                        // ? → S : Final LBS '완료' 이후
                        if(opptyStage == STAGE_SOLUTIONED) {
                            if( !isValidOpptyAct(opptyActMap, ACT_CODE_FINAL_LBS, completedSet) ) {
                                errorMsg += ' ' + String.format(System.Label.OPPTY_ERR_003,new String[]{opptActNameLabelMap.get(ACT_CODE_FINAL_LBS)}); 
                            }
                        }
                    }

                    // [C6. Customer Type (External) + Opportunity Type (Retention) + LBS Exception Type (N/A)]
                    if (opptyType == OPP_TYPE_RETENTION && opptyLBSType == OPP_LBS_TYPE_NA) {

                        // ? → S : Final LBS '완료' 이후
                        if(opptyStage == STAGE_SOLUTIONED) {
                            if( !isValidOpptyAct(opptyActMap, ACT_CODE_FINAL_LBS, completedSet) ) {
                                errorMsg += ' ' + String.format(System.Label.OPPTY_ERR_003,new String[]{opptActNameLabelMap.get(ACT_CODE_FINAL_LBS)}); 
                            }
                        }
                        
                    }
                }

                // [C7~C12. Customer Type (SEC-SET)]
                if(opptyLogisticsCustomerType == CUSTOMER_TYPE_SEC_SET) { 
                    // I → V : Tariff Verification '완료' 이후
                    // 필요 없어짐 삭제 처리
                    /*
                    if(opptyStage == STAGE_VALIDATED) {
                        if( !isValidOpptyAct(opptyActMap, ACT_CODE_TARIFF_VERIFICATION, completedSet) ) {
                            errorMsg += ' ' + String.format(System.Label.OPPTY_ERR_003,new String[]{opptActNameLabelMap.get(ACT_CODE_TARIFF_VERIFICATION)}); 
                        }
                    }
					*/

                    // [C9. Customer Type (SEC-SET) + Opportunity Type (New Opportunity) + LBS Exception Type (N/A)]
                    if(opptyType == OPP_TYPE_NEW_OPPORTUNITY && opptyLBSType == OPP_LBS_TYPE_NA) {

                        // ? → S : Final LBS '완료' 이후
                        if(opptyStage == STAGE_SOLUTIONED) {
                            if( !isValidOpptyAct(opptyActMap, ACT_CODE_FINAL_LBS, completedSet) ) {
                                errorMsg += ' ' + String.format(System.Label.OPPTY_ERR_003,new String[]{opptActNameLabelMap.get(ACT_CODE_FINAL_LBS)}); 
                            }
                        }
                    }
                    
                    // [C12. Customer Type (SEC-SET) + Opportunity Type (Retention) + LBS Exception Type (N/A)]
                    if (opptyType == OPP_TYPE_RETENTION && opptyLBSType == OPP_LBS_TYPE_NA) {

                        // ? → S : Final LBS '완료' 이후
                        if(opptyStage == STAGE_SOLUTIONED) {
                            if( !isValidOpptyAct(opptyActMap, ACT_CODE_FINAL_LBS, completedSet) ) {
                                errorMsg += ' ' + String.format(System.Label.OPPTY_ERR_003,new String[]{opptActNameLabelMap.get(ACT_CODE_FINAL_LBS)}); 
                            }
                        }
                    }

                }

                // [C13~C18. Customer Type (SEC-DS, Samsung Affiliates)]
                if(opptyLogisticsCustomerType == CUSTOMER_TYPE_SEC_DS || opptyLogisticsCustomerType == CUSTOMER_TYPE_SAMSUNG_AFFILIATES) { 

                    // [C15. Customer Type (SEC-DS, Samsung Affiliates) + Opportunity Type (New Opportunity) + LBS Exception Type (N/A)]
                    if(opptyType == OPP_TYPE_NEW_OPPORTUNITY && opptyLBSType == OPP_LBS_TYPE_NA) {

                        // ? → S : Final LBS '완료' 이후
                        if(opptyStage == STAGE_SOLUTIONED) {
                            if( !isValidOpptyAct(opptyActMap, ACT_CODE_FINAL_LBS, completedSet) ) {
                                errorMsg += ' ' + String.format(System.Label.OPPTY_ERR_003,new String[]{opptActNameLabelMap.get(ACT_CODE_FINAL_LBS)}); 
                            }
                        }
                    }

                    // [C18. Customer Type (SEC-DS, Samsung Affiliates) + Opportunity Type (Retention) + LBS Exception Type (N/A)]
                    if (opptyType == OPP_TYPE_RETENTION && opptyLBSType == OPP_LBS_TYPE_NA) {

                        // ? → S : Final LBS '완료' 이후
                        if(opptyStage == STAGE_SOLUTIONED) {
                            if( !isValidOpptyAct(opptyActMap, ACT_CODE_FINAL_LBS, completedSet) ) {
                                errorMsg += ' ' + String.format(System.Label.OPPTY_ERR_003,new String[]{opptActNameLabelMap.get(ACT_CODE_FINAL_LBS)}); 
                            }
                        }
                    }
                    
                }
                 

                //     if(checkStage == newOppty.StageName) break; // checkStage가 변경할 Stage에 도달하면 종료
                // }

                // 에러 메시지 alert
                if(errorMsg != '') {
                    String notValidConditionLabel = '📢 ' + System.Label.OPPTY_ERR_001 + ' '; // 해당 단계의 조건이 충족되지 않았습니다.
                    newOppty.addError(notValidConditionLabel + errorMsg);
                }

            }
        }
    }

    /**
     * Map 내에 필요조건 Activity가 수행되었는지 확인. 충족시 true / 미충족시 False 반환
     * @param   opptyActMap         key:TransactionName__c, value:OpptyAct
     * @param   transactionName     check transactionName
     * @param   validStatusSet      check status Set
     */
    private static Boolean isValidOpptyAct(Map<String, Opportunity_Activity__c> opptyActMap, String transactionName, Set<String> validStatusSet) {
        Boolean isValid = false;
        if(opptyActMap != null && opptyActMap.size() > 0) {
            if(opptyActMap.containsKey(transactionName) ) {
                Opportunity_Activity__c opptyAct = opptyActMap.get(transactionName);
                if(validStatusSet.contains(opptyAct.Status__c)){
                    isValid = true;
                }
            }
        }
        return isValid;
    }

    /**
     * Bidding Deadline, CloseDate 기본값 입력
     * Bidding Deadline validate Check
     */
    public static void dateDefaultValueLogistics(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        System.debug('::::dateDefaultValue::::');

        for(Opportunity newOpp : newList){
            if(newOpp.RecordTypeId != RT_ID_LOGISTICS){
                continue;
            }

            if(newOpp.MigData__c) {
                continue;
            }
            /**
             * [유효 조건] BiddingDeadline__c < CloseDate < cRevenueStartDate__c (Contract Start Date)
             */
            Map<String, String> opptyFieldLabel = Utils.getFieldLabel('Opportunity');

            if(newOpp.BiddingDeadline__c == null && newOpp.CloseDate != null) {
                Date closeDate = Date.valueOf(newOpp.CloseDate);
                newOpp.BiddingDeadline__c = closeDate.addMonths(-1);
            }
            if(newOpp.BiddingDeadline__c != null && newOpp.CloseDate != null) {
                String errMsg = String.valueOf(System.Label.OPPTY_ERR_004).replace('{date1}', opptyFieldLabel.get('biddingdeadline__c') ).replace('{date2}', opptyFieldLabel.get('closedate') );
                if(newOpp.BiddingDeadline__c >= newOpp.CloseDate) newOpp.addError(errMsg);
            }
            if(newOpp.CloseDate != null && newOpp.cRevenueStartDate__c != null) {
                String errMsg = String.valueOf(System.Label.OPPTY_ERR_004).replace('{date1}', opptyFieldLabel.get('closedate') ).replace('{date2}',opptyFieldLabel.get('crevenuestartdate__c'));
                if(newOpp.CloseDate >= newOpp.cRevenueStartDate__c) newOpp.addError(errMsg);
            }
            if(newOpp.BiddingDeadline__c != null && newOpp.cRevenueStartDate__c != null) {
                String errMsg = String.valueOf(System.Label.OPPTY_ERR_004).replace('{date1}', opptyFieldLabel.get('biddingdeadline__c')).replace('{date2}',opptyFieldLabel.get('crevenuestartdate__c'));
                if(newOpp.BiddingDeadline__c >= newOpp.cRevenueStartDate__c) newOpp.addError(errMsg);
            }
        }
    }
}