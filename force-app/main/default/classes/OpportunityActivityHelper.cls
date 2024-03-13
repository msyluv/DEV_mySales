/**
 * @description       : Opportunity 및 Opportunity Activity Code Picklist 값 참조
 * @author            : hj.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 2023-07-24
 * @last modified by  : d.ashish@samsung.com
 * Modifications Log 
 * Ver   Date         Author             Modification
 * 1.0   2021-01-05   hj.lee@dkbmc.com   Initial Version
 * 1.1   2021-01-26   hj.lee@dkbmc.com   [HQ] 계약대행 예외처리 Activity 비활성화 조건 추가
 * 1.2   2021-01-28   hj.lee@dkbmc.com   [Logistics] LBS Type Activity 비활성화 조건 중 Customer Type 조건 변경 (대외→"SEC-SET제외" / 대내→"SEC-SET")
 * 1.3   2021-04-21   hj.lee@dkbmc.com   [HQ] 수전위 관련 Activity 비활성화, BusinessType 에 따라 사전영업자원요청 비활성화
 * 1.4   2022-07-14   hyunhak.roh@dkbmc.com Cello Square 사업 확대에 따른 Bidding LBS 조정안
 * 1.5   2022-11-14   kajal.c@samsung.com Bidding Logistics CP Review and Final Logistics CP Review enable/disable logic
 * 1.6   2023-02-10   Added Condition to disable Credit Assessment Activity related to My sales-128
 * 1.7   2023-07-24   MYSALES-261 Added Condition to Avoid Strategy Sisters Activation when Opportunity is HQ collaboration and Related Subsidery business type is Implementation.
**/
public without sharing class OpportunityActivityHelper {
    /** 
     * Opportunity RecordType
    **/
    public static Map<String, RecordType> rtOpptyMap = new Map<String, RecordType>();
    public static RecordType RT_OPPTY_HQ = getRecordTypeOppty('HQ');
    public static RecordType RT_OPPTY_LOGISTICS = getRecordTypeOppty('Logistics');
    public static RecordType getRecordTypeOppty(String devName){
        if(rtOpptyMap.size() == 0) {    
            List<RecordType> rtOpptyList = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Opportunity'];
            for(RecordType rt : rtOpptyList) {
                rtOpptyMap.put(rt.DeveloperName, rt);
            }
        }
        return rtOpptyMap.get(devName);
    }

    /** 
     * Opportunity.StageName
    **/
    public static final String OPP_STAGE_IDENTIFIED = 'Z01';
    public static final String OPP_STAGE_VALIDATED = 'Z02';
    public static final String OPP_STAGE_QUALIFIED = 'Z03';
    public static final String OPP_STAGE_SOLUTIONED = 'Z04';
    // Closed Stage
    public static final String OPP_STAGE_WON = 'Z05';
    public static final String OPP_STAGE_LOST = 'Z06';
    public static final String OPP_STAGE_DROP = 'Z07';
    public static final String OPP_STAGE_CLEANSED = 'Z08';

    public static final Set<String> OPP_STAGE_CLOSED_SET = new Set<String> { 
        OPP_STAGE_WON,
        OPP_STAGE_LOST,
        OPP_STAGE_DROP
    };
    
    /**
     * Opportunity.LogisticsCustomerType__c : Picklist
    **/
    public static final String OPP_CUSTOMER_TYPE_EXTERNAL = 'EXTAC';
    public static final String OPP_CUSTOMER_TYPE_SEC_SET = 'SECSET';
    public static final String OPP_CUSTOMER_TYPE_SEC_DS = 'SECDS';
    public static final String OPP_CUSTOMER_TYPE_SAMSUNG_AFFILIATES = 'NSEC';
    
    /**
     * Opportunity.Type : Picklist
    **/
    public static final String OPP_TYPE_NEW_OPPORTUNITY = '01';
    public static final String OPP_TYPE_RETENTION = '02';

    /**
     * Opportunity.LBSExceptionType__c : Picklist
    **/
    public static final String OPP_LBS_TYPE_NA = '01';
    public static final String OPP_LBS_TYPE_NOMI = '05';
    public static final String OPP_LBS_TYPE_SMALL = '07';
    public static final String OPP_LBS_TYPE_MEDIUM = '08';
    //2022-07-14, hyunhak.roh@dkbmc.com Cello Square 사업 확대에 따른 Bidding LBS 조정안
    //Custom Type(대외) & BO Type(신규 or Retention) & Biz Development Type : Square 사업, LBS Exception Type : Square Product 인 경우
    //Tariff Verification, Bidding LBS 비활성화 처리 & Final LBS 활성화
    public static final String OPP_LBS_TYPE_SQUARE_PRODUCT = '11'; //V1.6-->Mysales-128, Api value is changed.

    /** 
     * Opportunity_Activity__c.TransactionName__c
    **/
    public static final String ACT_CODE_REGISTER_BO = 'XP11';
    public static final String ACT_CODE_REVIEW_BO = 'ZP21';
    public static final String ACT_CODE_REQUEST_RESOURCES = 'ZP32';
    public static final String ACT_CODE_RECEIVE_RFP = 'XP31';
    public static final String ACT_CODE_REQUEST_STRATEGY_COMMITTEE = 'ZP31';
    public static final String ACT_CODE_STRATEGY_COMMITTEE_COST_PLAN_COMPLETION = 'XP32';
    public static final String ACT_CODE_REQUEST_COMMITTEE_APPROVAL = 'ZP62';
    //신규추가시작
    public static final String ACT_CODE_REQUEST_STRATEGY_COMMITTEE_01= 'XP61';
    public static final String ACT_CODE_COMMITTEE_COST_PLAN_01 = 'XP62';
    public static final String ACT_CODE_REQUEST_COMMITTEE_APPROVAL_01 = 'XP63';
    public static final String ACT_CODE_REQUEST_STRATEGY_COMMITTEE_02 = 'XP71';
    public static final String ACT_CODE_COMMITTEE_COST_PLAN_02 = 'XP72';
    public static final String ACT_CODE_REQUEST_COMMITTEE_APPROVAL_02 = 'XP73';
    //신규추가종료    
    public static final String ACT_CODE_VRB_PROPOSAL_STRATEGY = 'ZP50';
    public static final String ACT_CODE_VRB_PROPOSAL_REVIEW = 'ZP51';
    public static final String ACT_CODE_VRB = 'ZP52';
    public static final String ACT_CODE_AGENCY_CONTRACT_EXCEPTION = 'ZPZ3';
    public static final String ACT_CODE_SUBMIT_PROPOSAL = 'ZP61';
    public static final String ACT_CODE_PRESENTATION = 'XP41';
    public static final String ACT_CODE_PREFERRED_BIDDER = 'XP42';
    public static final String ACT_CODE_CUSTOMER_APPROVAL = 'XP43';
    public static final String ACT_CODE_NEGOTIATION = 'XP44';
    public static final String ACT_CODE_CONTRACT_P_L = 'XP51';
    public static final String ACT_CODE_LEGAL_REVIEW = 'XP52';
    public static final String ACT_CODE_CONTRACT_APPROVAL = 'ZP82';
    public static final String ACT_CODE_CLOSING = 'XP57';
    public static final String ACT_CODE_ABORT_OPPORTUNITY = 'XPX1';
    public static final String ACT_CODE_DROP_OPPORTUNITY = 'ZPZ2'; 
    public static final String ACT_CODE_HOLD_OPPORTUNITY = 'ZAC1';
    public static final String ACT_CODE_LOST_OPPORTUNITY = 'ZPZ1';
    public static final String ACT_CODE_UNHOLD_OPPORTUNITY = 'ZAC4';
    public static final String ACT_CODE_CREDIT_ASSESSMENT = '2.2.1.';           // 신용 평가
    public static final String ACT_CODE_REQUEST_AP_APS = '2.2.2.';
    public static final String ACT_CODE_TARIFF_VERIFICATION = '2.2.3.';           // 전자사업 손익점검
    public static final String ACT_CODE_BIDDING_LBS = '2.3.2.';
    public static final String ACT_CODE_TEST_SHIPMENT = '2.3.3.';
    public static final String ACT_CODE_FINAL_LBS = '2.4.5.';
    public static final String ACT_CODE_RECEIVE_CONTRACT = '2.5.1.';
    public static final String ACT_CODE_RATE_CHANGE_LBS = '2.5.3.';
    public static final String ACT_CODE_CHANGE_APPROVAL_REQUEST = 'ZPG1';
    public static final String ACT_CODE_STRATEGY_COMMITTEE_PREPARATION = 'XP33';

    /**
     * [IF-135] 결재 ECC 중간처리 및 후처리 Activity 대상
     * Transaction Activity Target : 사전영업자원요청,수전위,수주품의,변경품의  'ZP32', 'ZP62', 'ZP82'
     */
    public static final Set<String> OPPACT_TARGET_SET_IF135 = new Set<String> { 
        ACT_CODE_REQUEST_RESOURCES,
        ACT_CODE_REQUEST_COMMITTEE_APPROVAL,
        ACT_CODE_CONTRACT_APPROVAL
    };

    /**
     * [HQ] Opportunity Record Type
     * HQ Panel Activity 접근 가능 확인, OpportunityActivityPanelController 에서 호출
     */
    public static Boolean checkAccessHQActivity(Opportunity oppty, OpportunityActivityPanelController.ActivityItem actItem) {
        
        Boolean isAccessible = true;
        // MASTER ACTIVITY 정보
        String masterActCode = actItem.MasterAct.TransactionName__c;
        
        /**
         * [2021-01-26] 계약대행 예외처리(ZPZ3) 생성 가능 기준 : 고객사가 국내, 그룹내인 경우만 가능 (KoreaDomestic__c, GroupInternal__c = True)
         */
        if(masterActCode.equals(ACT_CODE_AGENCY_CONTRACT_EXCEPTION)) {   
            if(oppty.KoreaDomestic__c && oppty.GroupInternal__c) {
                isAccessible = true;
            } else {
                isAccessible = false;
            }
        }
 system.debug('ashish opptyactihelper isAccessible::'+isAccessible);
        
        /**
         * [2021-04-21] 수전위 관련 Activity 선택할 수 없도록 비활성화, 
         */
        Set<String> StrategyCommitteeActivitySet = new Set<String>{
            ACT_CODE_REQUEST_STRATEGY_COMMITTEE,
            ACT_CODE_STRATEGY_COMMITTEE_COST_PLAN_COMPLETION,
            ACT_CODE_REQUEST_COMMITTEE_APPROVAL,
            ACT_CODE_STRATEGY_COMMITTEE_PREPARATION
        };
            system.debug('ashish StrategyCommitteeActivitySet'+StrategyCommitteeActivitySet);
                    system.debug('ashish masterActCode'+masterActCode);
        if(StrategyCommitteeActivitySet.contains(masterActCode)) {   
            isAccessible = false;
        }
         system.debug('ashish opptyactihelper isAccessible::'+isAccessible);
        
        //신규추가종료
       /**
         * [2021-07-16] 신규 수전위 관련 Activity 
         * 1. 자회사 
         * 2. 법인의 협업BO 
         * 3. 사업유형1 = 판매형/서비스형
         * 4. 사업심의유형확정 = BO점검회의 
         * 5. BO점검결과 완료 + 컴플라이언스 체크시 선택할 수 없도록 비활성화, 
         */
        String BusinessType_SalesBusiness = 'TD';
        String BusinessType_ServiceBusiness = 'TS';

        Set<String> NewStrategyCommitteeActivitySet = new Set<String>{
            ACT_CODE_REQUEST_STRATEGY_COMMITTEE_01,
            ACT_CODE_COMMITTEE_COST_PLAN_01,
            ACT_CODE_REQUEST_COMMITTEE_APPROVAL_01,
            ACT_CODE_REQUEST_STRATEGY_COMMITTEE_02,
            ACT_CODE_COMMITTEE_COST_PLAN_02,
            ACT_CODE_REQUEST_COMMITTEE_APPROVAL_02
        };
		//MYSALES-261 V1.7
        List<Opportunity> optyList = [SELECT Id, BusinessType__c,CollaborationBOId__c,CollaborationBOId__r.BusinessType__c FROM Opportunity WHERE OpportunityCode__c =:oppty.OpportunityCode__c];
        Boolean implementation =  false;
        Boolean is_SubsideryImplementation = false;
        for(Opportunity opty : optyList){
            if('TI'==opty.BusinessType__c){
                implementation = true;
            }
            //MYSALES-261 V1.7
            if(opty.CollaborationBOId__c != null && 'TI'==opty.CollaborationBOId__r.BusinessType__c)
            is_SubsideryImplementation = true;
        }
        
        if(NewStrategyCommitteeActivitySet.contains(masterActCode) 
            && (Utils.isSubsidiary(oppty.CompanyCode__c) 
                || (!'T100'.equals(oppty.CompanyCode__c) && oppty.Collaboration__c)
                || ('T100'.equals(oppty.CompanyCode__c) && oppty.Collaboration__c && is_SubsideryImplementation && !oppty.Opportunity_Review_Confirm__c)	// V1.7 MYSALES-261
                || (!implementation)
                || ('30'.equals(oppty.Opportunity_Review_VRB_Type_Confirm__c))
                || (oppty.Opportunity_Review_Confirm__c && (oppty.Opportunity_Review_Checkbox1__c || oppty.Opportunity_Review_Checkbox2__c)))) {     
            isAccessible = false;
        }
        
        /**
         * [2021-04-21] BusinessType__c 판매형('TD'), 서비스형('TS') 인 경우, 사전영업자원요청 비활성화
         */
         if(masterActCode.equals(ACT_CODE_REQUEST_RESOURCES)) {  
            if(oppty.BusinessType__c == BusinessType_SalesBusiness || oppty.BusinessType__c == BusinessType_ServiceBusiness) {
                isAccessible = false; // BusinessType__c 판매형인 경우 사전영업자원요청 수행 불가
            } else {
                isAccessible = true;
            }
        }
        //신규추가종료        
        return isAccessible;
               
    }
    
    /**
     * [Logistics] Opportunity Record Type
     * 물류 Panel Activity 접근 가능 확인, OpportunityActivityPanelController 에서 호출
     * [2021-01-21] 사업기회현황판의 전자사업손익점검 (Tariff Verification) 단계
     *              Customer Type = 'SEC-SET' 만 해당됨 
     *              나머지 Customer Type인 사업기회들은 전자사업손익점검 (Tariff Verification)를 비활성 처리 요청
     * [2021-01-28] LBS Type Activity 비활성화 조건 중 Customer Type 조건 변경 (대외→"SEC-SET제외" / 대내→"SEC-SET")
     */
    // This method is deprecated. Use checkAccessLogisticsActivityV2 instead.   
    /*
    public static Boolean checkAccessLogisticsActivity(Opportunity oppty, OpportunityActivityPanelController.ActivityItem actItem) {
        Boolean isAccessible = true;
        System.debug('[S] checkAccessLogisticsActivity  ─────────────────────────────────');

        try {
            // Customer Type : (External, SEC-DS, Samsung Affiliates)
            Set<String> OPP_CUSTOMER_TYPE_EXTERNAL_SET = new Set<String> {
                OPP_CUSTOMER_TYPE_EXTERNAL,
                OPP_CUSTOMER_TYPE_SEC_DS,
                OPP_CUSTOMER_TYPE_SAMSUNG_AFFILIATES
            };
            
            // Customer Type : (SEC-SET)
            Set<String> OPP_CUSTOMER_TYPE_INTERNAL_SET = new Set<String> {
                OPP_CUSTOMER_TYPE_SEC_SET
            };
            
            Set<String> ACT_CODE_LBS_SET = new Set<String> {
                ACT_CODE_BIDDING_LBS,
                ACT_CODE_FINAL_LBS,
                ACT_CODE_RATE_CHANGE_LBS
            };

            // OPPORTUNITY 정보
            String opptyStage        = Util_String.nvlStr(oppty.StageName);
            String opptyCustomerType = Util_String.nvlStr(oppty.LogisticsCustomerType__c);
            String opptyType         = Util_String.nvlStr(oppty.Type);
            String opptyLBSType      = Util_String.nvlStr(oppty.LBSExceptionType__c);

            // MASTER ACTIVITY 정보
            String masterActCode = actItem.MasterAct.TransactionName__c;
            
            
            // [2021-01-21 요청] Customer Type = 'SEC-SET' 제외한 Tariff Verification 비활성화
            
            if(masterActCode == ACT_CODE_TARIFF_VERIFICATION) { 
                if(opptyCustomerType != OPP_CUSTOMER_TYPE_SEC_SET) {    
                    isAccessible = false;   
                } else {
                    isAccessible = true;
                }
            }

            
             // Opportunity Stage + Opportunity 필드(Customer Type, Opportunity Type, LBS Exception Type) 에 따른
             // LBS Activity Disabled 제어
             
            // 조건 Opportunity Field 정보가 있는 경우 동작
            Boolean isValidOpptyFieldCondition = (String.isNotBlank(opptyCustomerType) && String.isNotBlank(opptyType) && String.isNotBlank(opptyLBSType));
            // Master Activity가 LBS Activity 인 경우에만 체크
            Boolean isLBSActivity= ACT_CODE_LBS_SET.contains(masterActCode);
            if(isLBSActivity && isValidOpptyFieldCondition) {

                System.debug('[S] LBS Type Activity  ─────────────────────────────────');
                System.debug('=== (Customer Type, Opportunity Type, LBS Exception Type) ' + opptyCustomerType + '/' + opptyType + '/' + opptyLBSType );
                

                // 기본 False 설정 후 아래 분기문에서 신청가능한 경우 True 처리
                isAccessible = false;

                
                 // Case [Customer Type + Opportunity Type + LBS Exception Type]
                 
                // Customer Type : 대외 조건 변경 → (External, SEC-DS, Samsung Affiliates)
                Boolean C1_EXTERNAL_NEW_NA = OPP_CUSTOMER_TYPE_EXTERNAL_SET.contains(opptyCustomerType) 
                                                && opptyType.equals(OPP_TYPE_NEW_OPPORTUNITY)
                                                && opptyLBSType.equals(OPP_LBS_TYPE_NA);

                Boolean C2_EXTERNAL_NEW_SMALL_NOMI = OPP_CUSTOMER_TYPE_EXTERNAL_SET.contains(opptyCustomerType) 
                                                && opptyType.equals(OPP_TYPE_NEW_OPPORTUNITY)
                                                && (opptyLBSType.equals(OPP_LBS_TYPE_SMALL) || opptyLBSType.equals(OPP_LBS_TYPE_NOMI));
                
                Boolean C3_EXTERNAL_NEW_MEDIUM = OPP_CUSTOMER_TYPE_EXTERNAL_SET.contains(opptyCustomerType) 
                                                && opptyType.equals(OPP_TYPE_NEW_OPPORTUNITY)
                                                && opptyLBSType.equals(OPP_LBS_TYPE_MEDIUM);

                Boolean C4_EXTERNAL_RETENTION_NA = OPP_CUSTOMER_TYPE_EXTERNAL_SET.contains(opptyCustomerType) 
                                                && opptyType.equals(OPP_TYPE_RETENTION)
                                                && opptyLBSType.equals(OPP_LBS_TYPE_NA);

                Boolean C5_EXTERNAL_RETENTION_SMALL_NOMI = OPP_CUSTOMER_TYPE_EXTERNAL_SET.contains(opptyCustomerType) 
                                                        && opptyType.equals(OPP_TYPE_RETENTION)
                                                        && (opptyLBSType.equals(OPP_LBS_TYPE_SMALL) || opptyLBSType.equals(OPP_LBS_TYPE_NOMI));

                Boolean C6_EXTERNAL_RETENTION_MEDIUM = OPP_CUSTOMER_TYPE_EXTERNAL_SET.contains(opptyCustomerType) 
                                                    && opptyType.equals(OPP_TYPE_RETENTION)
                                                    && opptyLBSType.equals(OPP_LBS_TYPE_MEDIUM);


                // Customer Type : 대내 조건 변경 → (SEC-SET)
                Boolean C1_INTERNAL_NEW_NA = OPP_CUSTOMER_TYPE_INTERNAL_SET.contains(opptyCustomerType) 
                                            && opptyType.equals(OPP_TYPE_NEW_OPPORTUNITY)
                                            && opptyLBSType.equals(OPP_LBS_TYPE_NA);

                Boolean C2_INTERNAL_NEW_SMALL_NOMI = OPP_CUSTOMER_TYPE_INTERNAL_SET.contains(opptyCustomerType) 
                                                    && opptyType.equals(OPP_TYPE_NEW_OPPORTUNITY)
                                                    && (opptyLBSType.equals(OPP_LBS_TYPE_SMALL) || opptyLBSType.equals(OPP_LBS_TYPE_NOMI));

                Boolean C3_INTERNAL_NEW_MEDIUM = OPP_CUSTOMER_TYPE_INTERNAL_SET.contains(opptyCustomerType) 
                                                && opptyType.equals(OPP_TYPE_NEW_OPPORTUNITY)
                                                && opptyLBSType.equals(OPP_LBS_TYPE_MEDIUM);

                Boolean C4_INTERNAL_RETENTION_NA = OPP_CUSTOMER_TYPE_INTERNAL_SET.contains(opptyCustomerType) 
                                                && opptyType.equals(OPP_TYPE_RETENTION)
                                                && opptyLBSType.equals(OPP_LBS_TYPE_NA);

                Boolean C5_INTERNAL_RETENTION_SMALL_NOMI = OPP_CUSTOMER_TYPE_INTERNAL_SET.contains(opptyCustomerType) 
                                                        && opptyType.equals(OPP_TYPE_RETENTION)
                                                        && (opptyLBSType.equals(OPP_LBS_TYPE_SMALL) || opptyLBSType.equals(OPP_LBS_TYPE_NOMI));

                Boolean C6_INTERNAL_RETENTION_MEDIUM = OPP_CUSTOMER_TYPE_INTERNAL_SET.contains(opptyCustomerType) 
                                                && opptyType.equals(OPP_TYPE_RETENTION)
                                                && opptyLBSType.equals(OPP_LBS_TYPE_MEDIUM);

                // [Stage] Identified
                if(opptyStage == OPP_STAGE_IDENTIFIED) {
            
                // [Stage] Validated
                } else if(opptyStage == OPP_STAGE_VALIDATED) {
                    
                    // [Activity] Bidding LBS 신청 가능
                    if(masterActCode.equals(ACT_CODE_BIDDING_LBS)) {
                        
                        // (Case 1) 대외 고객, New Opportunity, N/A
                        if(C1_EXTERNAL_NEW_NA) {
                            isAccessible = true;
                        }

                        // (Case 1') 대내 고객, New Opportunity, N/A
                        if(C1_INTERNAL_NEW_NA) {
                            isAccessible = true;
                        }
                    }

                // [Stage] Qualified
                } else if(opptyStage == OPP_STAGE_QUALIFIED) {

                    // [Activity] Final LBS 신청 가능
                    if(masterActCode.equals(ACT_CODE_FINAL_LBS)) {
                        // ---------------------------------------------- 대외 고객 → (External, SEC-DS, Samsung Affiliates)
                        // (Case 1) 대외 고객, New Opportunity, N/A
                        if(C1_EXTERNAL_NEW_NA) {
                            isAccessible = true;
                        }

                        // (Case 3) 대외 고객, New Opportunity, 중규모
                        if(C3_EXTERNAL_NEW_MEDIUM) {
                            isAccessible = true;
                        }

                        // (Case 4) 대외 고객, Retention, N/A
                        if(C4_EXTERNAL_RETENTION_NA) {
                            isAccessible = true;
                        }

                        // (Case 6) 대외 고객, Retention, 중규모
                        if(C6_EXTERNAL_RETENTION_MEDIUM) {
                            isAccessible = true;
                        }

                        // ---------------------------------------------- 대내 고객 → (SEC-SET)
                        // (Case 1) 대내 고객, New Opportunity, N/A
                        if(C1_INTERNAL_NEW_NA) {
                            isAccessible = true;
                        }

                        // (Case 3') 대내 고객, New Opportunity, 중규모
                        if(C3_INTERNAL_NEW_MEDIUM) {
                            isAccessible = true;
                        }

                        // (Case 4') 대내 고객, Retention, N/A
                        if(C4_INTERNAL_RETENTION_NA) {
                            isAccessible = true;
                        }

                        // (Case 6') 대내 고객, Retention, 중규모
                        if(C6_INTERNAL_RETENTION_MEDIUM) {
                            isAccessible = true;
                        }
                    }
        
                // [Stage] Solutioned
                } else if(opptyStage == OPP_STAGE_SOLUTIONED) {
                    

                // [Stage] Won, Lost, Abort, Drop
                } else if(OPP_STAGE_CLOSED_SET.contains(opptyStage)) {

                    // [Activity] Rate Change LBS 신청 가능
                    if(masterActCode.equals(ACT_CODE_RATE_CHANGE_LBS)) {

                        // ---------------------------------------------- 대외 고객 
                        // (Case 1) 대외 고객, New Opportunity, N/A
                        if(C1_EXTERNAL_NEW_NA) {
                            isAccessible = true;
                        }

                        // (Case 3) 대외 고객, New Opportunity, 중규모
                        if(C3_EXTERNAL_NEW_MEDIUM) {
                            isAccessible = true;
                        }

                        // (Case 4) 대외 고객, Retention, N/A
                        if(C4_EXTERNAL_RETENTION_NA) {
                            isAccessible = true;
                        }

                        // (Case 6) 대외 고객, Retention, 중규모
                        if(C6_EXTERNAL_RETENTION_MEDIUM) {
                            isAccessible = true;
                        }

                        // ---------------------------------------------- 대내 고객 
                        // (Case 1') 대내 고객, New Opportunity, N/A
                        if(C1_INTERNAL_NEW_NA) {
                            isAccessible = true;
                        }

                        // (Case 3') 대내 고객, New Opportunity, 중규모
                        if(C3_INTERNAL_NEW_MEDIUM) {
                            isAccessible = true;
                        }

                        // (Case 4') 대내 고객, Retention, N/A
                        if(C4_INTERNAL_RETENTION_NA) {
                            isAccessible = true;
                        }

                        // (Case 6') 대내 고객, Retention, 중규모
                        if(C6_INTERNAL_RETENTION_MEDIUM) {
                            isAccessible = true;
                        }

                    }
                    
                } // [E] 
            }
            //2022-07-14, hyunhak.roh@dkbmc.com Cello Square 사업 확대에 따른 Bidding LBS 조정안
            //Custom Type(대외) & BO Type(신규 or Retention) & Biz Development Type : Square 사업, LBS Exception Type : Square Product 인 경우
            //Tariff Verification, Bidding LBS 비활성화 처리 & Final LBS 활성화
            if(     OPP_CUSTOMER_TYPE_EXTERNAL_SET.contains(opptyCustomerType)
               && (opptyType.equals(OPP_TYPE_NEW_OPPORTUNITY) || opptyType.equals(OPP_TYPE_RETENTION))
               && oppty.LogisticsBizDevelopmentType__c == '10' 
               && opptyLBSType == OPP_LBS_TYPE_SQUARE_PRODUCT) {
                   //Tariff Verification, Bidding LBS
                   if(      masterActCode.equals(ACT_CODE_TARIFF_VERIFICATION) 
                      ||    masterActCode.equals(ACT_CODE_BIDDING_LBS)) {
                       isAccessible = false;
                   }
                   //Register Opportunity, Credit Assessment, Final LBS
                   if(      masterActCode.equals(ACT_CODE_REGISTER_BO) 
                      ||    masterActCode.equals(ACT_CODE_CREDIT_ASSESSMENT)    
                      ||    masterActCode.equals(ACT_CODE_FINAL_LBS)) {
                       isAccessible = true;
                   }
               }
        }
        catch (Exception e) {
            System.debug(System.LoggingLevel.ERROR, '=== ' + e.getMessage());
        }

        System.debug('=== isAccessible : ' + isAccessible);
        System.debug('[E] checkAccessLogisticsActivity ───────────────────────────────── ');

        return isAccessible;
    }
    */
    
    //checkAccessLogisticsActivity 메소드의 버젼업.
    //기존 로직 처리를, Master
    public static Boolean checkAccessLogisticsActivityV2(Opportunity oppty, OpportunityActivityPanelController.ActivityItem actItem) {
                
        //LBS Type의 Activity
        
        Set<String> ACT_CODE_LBS_SET = new Set<String> { 
            ACT_CODE_BIDDING_LBS,
            ACT_CODE_FINAL_LBS,
            ACT_CODE_RATE_CHANGE_LBS,
            '2.3.1','2.4.4'               //kajal
        };
                
        //Activy Accessible Default Value
        Boolean isAccessible = true;
        
        // MASTER ACTIVITY 정보
        String masterActCode = actItem.MasterAct.TransactionName__c;
        String oppstatus = actItem.BoAct.Status__c;
        system.debug('masterActcodval'+masterActCode + 'oppstatus'+oppstatus);
        
        try {                
            // External Customer Type : (External, SEC-DS, Samsung Affiliates)
            // Internal Customer Type : (SEC-SET)
                 
                  if (ACT_CODE_LBS_SET.contains(masterActCode)){
                System.debug('### OpportunityActivityHelper :: checkAccessLogisticsActivityV2 :: masterActCode = ' + masterActCode);
                
                MasterActivityLogisticsAttribute__c rowMAA = [SELECT Id, DefaultValue__c, FilterCriteria__c FROM MasterActivityLogisticsAttribute__c WHERE RecordType.DeveloperName = 'Definition' AND Attribute__c = 'Accessible' AND TransactionName__c = :masterActCode LIMIT 1];
                isAccessible = Boolean.valueOf(rowMAA.DefaultValue__c);
                String genSOQL = MasterActivityLogisticsAttributeHelper.dynamicSOQL(rowMAA.FilterCriteria__c, oppty, 'Accessible', masterActCode);
                
                List<MasterActivityLogisticsAttribute__c> listMAACondition = Database.query(genSOQL);                
                system.debug('### OpportunityActivityHelper :: checkAccessLogisticsActivityV2 :: listMAACondition = '+listMAACondition);
                //조건을 만족하는 값이 2건 이상일 경우 어떻게 처리할것인가!
                //최근 수정된 데이터를 유효값으로 간주.
                system.debug('before loo mcode'+actItem.BoAct.Status__c);
                /**
                if( (masterActCode == '2.4.4' || masterActCode == '2.3.1') &&  oppstatus == 'Completed') {
                    system.debug('inside loop');
                    isAccessible = true;
                }
                else { **/ 
                if(!listMAACondition.IsEmpty()){
                    isAccessible = listMAACondition[0].isAccessible__c;
                }     
                
           
                System.debug('### OpportunityActivityHelper :: checkAccessLogisticsActivityV20 :: isAccessible = ' + isAccessible);
				system.debug('Akash2**' + isAccessible);
            }
            
            /** V1.6 -- Start My Sales-128 -- Added by Kajal -- **/
            else if(masterActCode == '2.2.1.'){
                system.debug('masterActCode**' + masterActCode);
                system.debug('LogisticsCustomerType**' +oppty.LogisticsCustomerType__c);
                if(oppty.LogisticsCustomerType__c == 'EXTAC' && (oppty.Type =='01' ||oppty.Type == '02' ) 
                   && oppty.LBSExceptionType__c  == '11'){
                       isAccessible = false;
                   }
            }
             /** V1.6 End **/
            
        }catch (Exception e) {
            System.debug(System.LoggingLevel.ERROR, '=== ' + e.getMessage());
        }        
		system.debug('Akash3**' + isAccessible);
        return isAccessible;
    }

    /**
     * 임시로 생성된 Status 가 빈 값인 Oppty 삭제
     */
    public static void deleteTempOpportunityActivity(String opptyId) {
        try {
            List<Opportunity_Activity__c> delOpptyActList = [
                SELECT Id
                FROM Opportunity_Activity__c
                WHERE WhatId__c = :opptyId
                    AND Status__c = null
                    AND CreatedDate != TODAY
            ];
        
            if(delOpptyActList.size() > 0) DELETE delOpptyActList;

        } catch(Exception e) {
            System.debug(e.getMessage());
        }
    }
    /** 
     * Opportunity Activity External Key 생성
     **/
    public static String generateOpportunityActivityExtKey(Opportunity_Activity__c opptyAct) {
        return opptyAct.WhatId__c+'_'+opptyAct.TransactionName__c;
    }

}