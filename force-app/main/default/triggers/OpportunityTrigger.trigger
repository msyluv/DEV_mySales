/**
* @description       : 
* @author            : hj.lee@dkbmc.com
* @group             : 
* @last modified on  : 2024-04-23
* @last modified by  : vikrant.ks@samsung.com   
* Modifications Log 
* Ver   Date         Author                              Modification
* 1.0   2020-11-10   hj.lee@dkbmc.com                    Initial Version
* 1.1   2020-11-26   jiiiiii.park@partner.samsung.com
* 1.2   2020-11-30   bh.hwang@dkbmc.com                  Sales Department 입력  
* 1.3   2020-12-03   younghoon.kim@dkbmc.com             checkCollaboration 로직 추가(협업BO 삭제 방지)
* 1.4   2020-12-23   younghoon.kim@dkbmc.com             setBizLv 로직 추가(Amount를 기준으로 Biz Level 설정)
* 1.5   2020-12-30   hj.lee@dkbmc.com                    validateStageLogistics 로직 추가(RecordType Logistics Stage 변경 시 유효성 확인)
* 1.6   2021-01-12   Junghwa.Kim@dkbmc.com               dateDefaultValueLogistics 로직 추가(date 필드 기본값 입력 및 BiddingDeadline 유효성확인)
* 1.7   2021-01-22   hj.lee@dkbmc.com                    Closed Lost, Dropped 인 경우 Oppty Record Lock
* 1.8   2021-01-28   hj.lee@dkbmc.com                    sendToSAP : 물류 RecordType 전송 I/F 분기 추가
* 1.9   2021-02-09   hj.lee@dkbmc.com                    sendToSAP : "Logistics" RecordType 전송 I/F 추가 (IF-125, IF-094)
* 2.0   2021-03-10   seonju.jin@dkbmc.com                setProposalPM 로직 추가
* 2.1   2021-03-23   younghoon.kim@dkbmc.com             closedWonValidation 로직 추가
* 2.1   2021-03-23   seonju.jin@dkbmc.com                사업기회 복제 및 협업 BO 생성 시 , 주수주/매출 부서 값 생성 로직 수정
* 2.2   2021-04-28   seonju.jin@dkbmc.com                OPP_STAGE_CLEANSED Stage 추가. setOpptyStatus 수정
* 2.3   2021-05-13   hj.lee@dkbmc.com                    insertOpptyTeamProposalPmUser : Proposel PM User 사업기회 팀 추가 로직
* 2.4   2021-05-20   hj.lee@dkbmc.com                    setOriginAccount, setValueFilterPicklist : Before Trigger 필드 셋팅
* 2.5   2021-05-28   hj.lee@dkbmc.com                    upsertOpportunityAmountHistory 로직 추가
* 2.6   2021-06-23   younghoon.kim@dkbmc.com             closedWonValidation에 로직 추가 - 품의가 완료되지않은 사업기회는 WON단계로 변경 불가능
* 2.7   2021-07-12   younghoon.kim@dkbmc.com             set1stCloseDate 추가 / 사업기회 Stage가 최초로 Won이 되는 날짜를 한번만 세팅 / 사업기회 Stage 전환 소요시간과 사전영업 단계별 전환 비율을 측정하기 위함
* 2.7   2021-08-04   younghoon.kim@dkbmc.com             setlockRecordClosedStage 수정 / Cleansed 단계로 변경될때도 Record Lock이 걸리도록 로직 수정
* 2.8   2021-08-19   seonju.jin@dkbmc.com                checkChangeStage - 결재상신 시, Amount가 0인 경우 Lost로 스테이지 변경체크 제외
* 2.9   2021-10-21   younghoon.kim@dkbmc.com             checkBizType2 추가 / IT 사업기회 중 본사(T100)이면서 대외 사업기회인 경우 Biz. Type2 필수 입력
* 3.0   2021-10-22   seonju.jin@dkbmc.com                Employee 조회 공통처리
* 3.0   2021-11-09   seonju.jin@dkbmc.com                checkAmount 추가
* 3.1   2021-11-17   seonju.jin@dkbmc.com                checkBizType2 주석처리 (사기검에서 체크)
* 3.2   2021-11-29   younghoon.kim@dkbmc.com             syncTeamMember 추가 / 사업기회의 소유자가 변경되는 경우 협업 사업기회의 팀멤버 수정
* 3.3   2021-12-21   seonju.jin@dkbmc.com                LBS 예외 유형(LBS Exception Type) 필드 속성에 따른 Won 단계 변경시 체크 로직 추가
* 3.4   2022-02-16   kj78.yu@dkbmc.com                   물류 BO의 경우 Drop/Lost 상태 변경 시 Locked 처리에서 제외. IT 일 경우만 Locked 처리함.
* 3.5   2022-03-21   hyunhak.roh@dkbmc.com               Proposal PM 등록/변경시 Owner와 동일하면 TeamMember 등록안함. 다르면 등록. & Owner 변경시 Proposal PM과 같아지면 TeamMember에서 삭제. 다르면 등록.
* 3.6   2022-04-20   kj78.yu@dkbmc.com                   CSP/MSP 상세 데이터 추가. CSP/MSP Type이 CSP/MSP/SaaS인 경우, 수주품의 품의 없어도 WON으로 Stage 변경 가능.
* 3.7   2022-05-27   akash.g@samsung.com                 Change functionality for Contract/Origin Account change.
* 3.8   2022-05-30   akash.g@samsung.com                 Changes related to functionality of restriction of change in CSP/MSP type in case of won & closed stage opportunity
* 3.9   2022-06-16   hyunhak.roh@dkbmc.com               사업리드 Converted BO가 삭제 시 해당 사업리드 단계를 되돌리는 로직 추가
* 4.0   2022-09-07   hyunhak.roh@dkbmc.com               MSP사업의 수주금액 관리를 위한 안내메세지 요청
* 4.1   2022-09-08   divyam.gupta@samsung.com            Prevent deletion of the opportunity for profile Service Desk Agency.
* 4.2   2022-09-14   hyunhak.roh@dkbmc.com               BO 생성 시 Stage 변경 불가하도록 로직 추가
* 4.3   2023-01-16   akash.g@samsung.com                 Add error condition for MY-Sales-114
* 4.4   2023-01-13   akash.g@samsung.com                 Remove error condition from csp/msp type validation for company code 'T100'-> MYSALES-112 
* 4.5   2023-01-31   kajal.c@samsung.com                 Cp Enhancement User story - MySales:42
* 4.6   2023-02-02   akash.g@samsung.com                 Add manual sharing for group 'mig20005' (MYSALES-103)
* 4.7   2023-02-02   akash.g@samsung.com                 Add error condition in case of creation of collaboration BO -> MYSALES-110
* 4.8   2023-03-31   anish.jain@partner.samsung.com      To set Opportunity VRB Type to null for non-TI Biz Type -> MYSALES-159
* 4.9   2023-04-12   saurav.k@partner.samsung.com        Opportunity Manual Sharing Enhancement(MySales-168)
* 5.0   2023-06-13   chae_ho.yang@samsung.com            Avoid custom validation when modifying amount by admin
* 5.1   2023-09-18   divyam.gupta@samsung.com            mySales-293 Warning if Close Date is later than Contract Start Date.
* 5.2   2023-09-20   atul.k1@samsung.com                 Task - (Logistics) Create Alert Message
* 5.3   2023-10-20   aditya.r2@samsung.com               Add IF Log on Opportunity Manual Sharing (MySales-330)
* 5.4   2023-10-20   sarthak.j1@samsung.com              Query optimization to avoid "Too many SOQL Queries: 101" exception. -> MYSALES-334
* 5.5   2023-10-23   vikrant.ks@samsung.com              When the Stage becomes Lost/Drop set FirstCloseDate__c to null. (MySales-332)
* 5.6   2023-11-01   divyam.gupta@samsung.com            Added Try catch for exception handling on Opportunity Manual Sharing.
* 5.7   2023-11-15   vikrant.ks@samsung.com              when changed 'Proposal PM' or 'Execution PM' field, call IF-184 by BO code. (MySales-356)
* 5.8   2023-11-29   anish.jain@partner.samsung.com      Modify the permission logic for collaboration BO (MS-366)
* 5.9   2023-12-05   vikrant.ks@samsung.com              Restructure of IF-184 calling from opportunityTrigger. (MySales-374)
* 6.0   2024-01-17   sarthak.j1@samsung.com              Opportunity - new 'Probability' Field Creation -> MYSALES-416
* 6.1   2024-02-19   anish.jain@partner.samsung.com      BO Review Approval Issue Check (MS-418)
* 6.2   2024-02-26   sarthak.j1@samsung.com              Sales Lead Conversion Issue [SOQL-101] -> MYSALES-452
* 6.3   2024-03-06   atul.k1@samsung.com                 Opportunity-Checking BA when Delivery Department is changed (MYSALES-462)
* 6.4   2024-03-11   sarthak.j1@samsung.com              Apply new Probability Field to Logistics -> MYSALES-470
* 6.5   2024-03-12   vikrant.ks@samsung.com              Create new delivery_probability__c record everytime a new HQ opportunity is created. (MySales-447)
* 6.6   2024-03-28   sarthak.j1@samsung.com              Task - (IT) When BO Closed (WON/DROP/LOST) change Delivery Prob on Delivery_Probabiliy__c -> MYSALES-478
* 6.7   2024-03-26   vipul.k1@samsung.com                Update the firstDate field on opportunity record -> MYSALES-477
* 6.8   2024-04-03   sarthak.j1@samsung.com              IF_USER & Mig01 user related changes -> [MYSALES-477]
* 6.9   2024-04-23   vikrant.ks@samsung.com              Modifying the Delivery_Probabiliy__c creation logic in case of Collaboration BO [MYSALES-517]
* 7.0   2024-04-03   vikrant.ks@samsung.com              Success probability field should not be populated or changed in insertion and stage change respectively incase of IT-T100-non collab opportunity. [MYSALES-468]
**/
trigger OpportunityTrigger on Opportunity (before insert, before update, before delete, after insert, after update, after delete) {
    
    // Trigger Switch
    TriggerSwitch__c trSwitch = TriggerSwitch__c.getInstance(UserInfo.getUserId()); // Current User 기준으로 Custom Setting 가져옴
    Boolean AllSwitch = trSwitch.All__c;                                            // All Trigger Switch
    Boolean OpportunitySwitch = trSwitch.Opportunity__c;                            // Obejct Trigger Switch (필드 생성)
    Boolean OpportunityCodeSettingSwitch = trSwitch.OpportunityCodeSetting__c;      // Opportunity Code 설정 스위치
    Boolean OpportunityBizLvSwitch = trSwitch.OpportunityBizLvSetting__c;           // Opportunity Business Level 자동 설정 스위치
    Boolean OpportunityDeleteSwitch = trSwitch.OpportunityDeleteSetting__c;         // Opportunity Delete 가능 여부 
    Boolean OpportunityLogisticsValidationSwitch = trSwitch.OpportunityLogisticsValidation__c;  // Opportunity Logistics 레코드 타입 유효성 체크
    Boolean OpportunitySendToSAPSwitch = trSwitch.OpportunitySendToSAP__c;                      // Opportunity 작성/수정/삭제 시 SAP 정보 전송
    Boolean MigSwitch = trSwitch.Migration__c;  // Data Migration 시 제외할 로직인 경우 true
    
    // Opportunity Record Type ID
    public static String RT_OPPTY_HQ_ID        = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('HQ').getRecordTypeId(); 
    public static String RT_OPPTY_LOGISTICS_ID = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Logistics').getRecordTypeId();
    // Opportunity Constant
    public static String CSPAndMSPType = 'N/A';//V6.7 Added By Vipul
    public static String opportunityWonStage = 'Z05';//V6.7 Added By Vipul
    // Opportunity.StageName
    public static final String OPP_STAGE_IDENTIFIED = OpportunityActivityHelper.OPP_STAGE_IDENTIFIED;
    public static final String OPP_STAGE_VALIDATED  = OpportunityActivityHelper.OPP_STAGE_VALIDATED;
    public static final String OPP_STAGE_QUALIFIED  = OpportunityActivityHelper.OPP_STAGE_QUALIFIED;
    public static final String OPP_STAGE_SOLUTIONED = OpportunityActivityHelper.OPP_STAGE_SOLUTIONED;
    public static final String OPP_STAGE_WON        = OpportunityActivityHelper.OPP_STAGE_WON;
    public static final String OPP_STAGE_LOST       = OpportunityActivityHelper.OPP_STAGE_LOST;
    public static final String OPP_STAGE_DROP       = OpportunityActivityHelper.OPP_STAGE_DROP;
    public static final String OPP_STAGE_CLEANSED =   OpportunityActivityHelper.OPP_STAGE_CLEANSED;
    public static Map<STRING,ID> hqMap = new map<STRING,ID>();
    //Cloud Service. CSP/MSP/SaaS
    public static final Set<String> OPP_CMSP_TYPE = new Set<String> {'CSP', 'MSP', 'SaaS'};
        //CspMspType__c 값이 변경됨에 따라 ReSet이 필요한 필드
        public static final Set<String> OPP_CMSP_TYPE_RESET_FIELD = 
        new Set<String> {'CMBizType__c','CMCollaboDept3__c','CMCollaboDept2__c','CMCollaboDept1__c','ConversionType__c'
            ,'OtherCSP__c','PartnerAccount__c','SCP_DC__c','SCPScale__c','ServiceSales__c'};
                // Start v 5.4 (MYSALES-334)
                /*Map<Id, Profile> profileMap = new Map<Id, Profile>([SELECT Id, Name, UserLicenseId, UserLicense.Name, UserType, Description 
FROM Profile 
WHERE Id = :UserInfo.getProfileId()]);*/
                
                String systemAdministratorProfileID;
    String interfaceAdminProfileID;
    String mSPAdminProfileID;
    String pIAdministratorProfileID;
    String customSystemAdministratorProfileID;
    String salesRepHQProfileID;
    String salesRepOverseasCorpProfileID;
    String pIBizOwnerProfileID;
    String salesRepSubsProfileID;
    String serviceDeskAgencyProfileID;
    
    //Start v-6.8
    public static final String USER_NAME = UserInfo.getName();
    List<String> ifMigUserNames = new List<String>();
    ifMigUserNames = System.Label.IF_Mig_User_Names.split(';');
    Set<String> ifMigUserNamesSet = new Set<String>(ifMigUserNames);
    //End v-6.8
    
    System.Domain domain = System.DomainParser.parse(URL.getOrgDomainURL());
    String sandboxName = domain.getSandboxName();
    System.debug('sandbox is: '+sandboxName);
    if(!String.isBlank(sandboxName))
    {
        System.debug('Inside QA block');
        
        systemAdministratorProfileID = Profile_IDs_QA__mdt.getInstance('System_Administrator').Profile_ID__c;
        interfaceAdminProfileID = Profile_IDs_QA__mdt.getInstance('Interface_Admin').Profile_ID__c;
        mSPAdminProfileID = Profile_IDs_QA__mdt.getInstance('MSP_Admin').Profile_ID__c;
        pIAdministratorProfileID = Profile_IDs_QA__mdt.getInstance('PI_Administrator').Profile_ID__c;
        customSystemAdministratorProfileID = Profile_IDs_QA__mdt.getInstance('Custom_System_Administrator').Profile_ID__c;
        salesRepHQProfileID = Profile_IDs_QA__mdt.getInstance('Sales_Rep_HQ').Profile_ID__c;
        salesRepOverseasCorpProfileID = Profile_IDs_QA__mdt.getInstance('Sales_Rep_Overseas_Corp').Profile_ID__c;
        pIBizOwnerProfileID = Profile_IDs_QA__mdt.getInstance('PI_Biz_Owner').Profile_ID__c;
        salesRepSubsProfileID = Profile_IDs_QA__mdt.getInstance('Sales_Rep_Subs').Profile_ID__c;
        serviceDeskAgencyProfileID = Profile_IDs_QA__mdt.getInstance('Service_Desk_Agency').Profile_ID__c;      
    }
    else{
        System.debug('Inside Prod block');
        
        systemAdministratorProfileID = Profile_IDs_Prod__mdt.getInstance('System_Administrator').Profile_ID__c;
        interfaceAdminProfileID = Profile_IDs_Prod__mdt.getInstance('Interface_Admin').Profile_ID__c;
        mSPAdminProfileID = Profile_IDs_Prod__mdt.getInstance('MSP_Admin').Profile_ID__c;
        customSystemAdministratorProfileID = Profile_IDs_Prod__mdt.getInstance('Custom_System_Administrator').Profile_ID__c;
        salesRepHQProfileID = Profile_IDs_Prod__mdt.getInstance('Sales_Rep_HQ').Profile_ID__c;
        salesRepOverseasCorpProfileID = Profile_IDs_Prod__mdt.getInstance('Sales_Rep_Overseas_Corp').Profile_ID__c;
        pIBizOwnerProfileID = Profile_IDs_Prod__mdt.getInstance('PI_Biz_Owner').Profile_ID__c;
        salesRepSubsProfileID = Profile_IDs_Prod__mdt.getInstance('Sales_Rep_Subs').Profile_ID__c;
        serviceDeskAgencyProfileID = Profile_IDs_Prod__mdt.getInstance('Service_Desk_Agency').Profile_ID__c;        
    }
    System.debug('SysAdminID>>'+systemAdministratorProfileID+' SalesRepHQID>>'+salesRepHQProfileID);
    
    //String userProfileName = profileMap.get(UserInfo.getProfileId()).Name;
    String userProfileId = UserInfo.getProfileId();
    //Boolean isAdminProfile = userProfileName.contains('Admin') || userProfileName.contains('관리자');
    Boolean isAdminProfile = false;
    if(userProfileId.equals(systemAdministratorProfileID) || userProfileId.equals(interfaceAdminProfileID) || userProfileId.equals(mSPAdminProfileID) || userProfileId.equals(customSystemAdministratorProfileID) || userProfileId.equals(pIAdministratorProfileID)){
        isAdminProfile = true;
    }
    System.debug('isAdminProfile check>> '+isAdminProfile );
    // End v 5.4 (MYSALES-334)
    String userName = UserInfo.getName();
    Boolean isIFUser = userName.contains('IF_USER');
    private List<IF_Log__c> allLog = new List<IF_Log__c>();     //v 5.3 (MySales-330)
    
    //Start v-6.2 MYSALES-452
    Opportunity_Code_Update_Setting__c oppUpdate = Opportunity_Code_Update_Setting__c.getValues('UpdateOppCode');
    Boolean oppCodeNotUpdated = true;
    if(!Test.isRunningTest()){
        oppCodeNotUpdated = oppUpdate.Opp_Code_Update__c;
    }
    //End v-6.2 MYSALES-452
    
    if(AllSwitch && OpportunitySwitch){
        System.debug(' ■ [' + Trigger.operationType + '] OpportunityTrigger');
        
        switch on trigger.operationType{
            when BEFORE_INSERT {
                checkAmount(Trigger.new);
                //Start v-6.0 [MYSALES-416]
                setSuccessProbability(Trigger.new);
                //End v-6.0 [MYSALES-416]                
                if(!MigSwitch) {
                    if(OpportunityCodeSettingSwitch) setCC(Trigger.new);
                    if(OpportunityBizLvSwitch) setBizLv(Trigger.new);
                    if(OpportunityLogisticsValidationSwitch) OpportunityValidateHelper.validateStageLogistics(Trigger.new, null); // Stage Validation Check
                    setProposalPM(Trigger.new);
                    // checkCloseReason(Trigger.new);
                    // checkBizType2(Trigger.new, null, 'I');
                    // 2022-09-01, hyunhak.roh@dkbmc.com, BO 생성 시 Stage 변경 불가하도록 로직 추가
                    checkOpportunityInfo(Trigger.new);
                    
                }
                
                setOriginAccount(Trigger.new);
                setValueFilterPicklist(Trigger.new, null);
                setOpptyStatus(Trigger.new);
                set1stCloseDate(Trigger.new);
                
                checkCMSPValidation(Trigger.new);
                setCMSPBoReName(Trigger.new);
                setBORegisteredInfo(Trigger.new);
                //Added by Divyam Gupta V 5.1
                checkCloseDate1(Trigger.new);
                //Boolean ActionType = ;
                checkOppAmountValue(Trigger.new, null); // Atul MySales-296 V 5.2
                setBOFirstclosedate(Trigger.new); //V5.5
            }
            
            when BEFORE_UPDATE {
                system.debug('Opp Before Calling');
                if(oppCodeNotUpdated){ //Added as part of v-6.2 MYSALES-452
                    System.debug('SJ>> Opp After Calling'); //SJOSHI
                    checkAmount(Trigger.new);
                    if(!MigSwitch) {
                        if(OpportunityBizLvSwitch) setBizLv(Trigger.new);
                        if(OpportunityLogisticsValidationSwitch) {
                            OpportunityValidateHelper.validateStageLogistics(Trigger.new, Trigger.oldMap); // Stage Validation Check
                            if(!isAdminProfile) OpportunityValidateHelper.dateDefaultValueLogistics(Trigger.new, Trigger.oldMap);
                        }
                        setProposalPM(Trigger.new);
                        setFieldIsEdited(Trigger.new, Trigger.oldMap);
                        if(!isAdminProfile) closedWonValidation(Trigger.new);
                        checkChangeStage(Trigger.new);
                        
                        // checkCloseReason(Trigger.new);
                        // checkBizType2(Trigger.new, Trigger.oldMap, 'U');
                    }
                    setValueFilterPicklist(Trigger.new, Trigger.oldMap);
                    setOpptyStatus(Trigger.new);
                    set1stCloseDate(Trigger.new);
                    syncTeamMember(Trigger.new, Trigger.oldMap); 
                    if(!isIFUser) boReviewCheck(Trigger.new, Trigger.oldMap);
                    reSetCMSPTypeField(Trigger.new, Trigger.oldMap);
                    checkCMSPValidation(Trigger.new);
                    setCMSPBoReName(Trigger.new);
                    setOpptyVRBType(Trigger.new, Trigger.oldMap); //Added by Anish - v 4.8
                    //Added by Divyam Gupta V 5.1
                    checkCloseDate(Trigger.new,Trigger.oldMap);
                    checkOppAmountValue(Trigger.new, Trigger.oldMap); // Atul MySales-296 V 5.2
                    checkingBusinessArea(Trigger.new, Trigger.oldMap); //Atul Mysales-462 V 6.3
                    setBOFirstclosedate(Trigger.new); //V5.5
                    //Start v-6.0 [MYSALES-416]
                    setSuccessProbability(Trigger.new);
                    //End v-6.0 [MYSALES-416]
                    setOpptyFirstCloseDateForHQ(Trigger.new, Trigger.oldMap); //Added By Vipul MySales-477 V6.7 
                } //Added as part of v-6.2 MYSALES-452
                
            }
            
            when BEFORE_DELETE {
                if(OpportunityDeleteSwitch){
                    checkDelete(Trigger.old);
                }
            }
            
            when AFTER_INSERT {
                if(!MigSwitch) {
                    //Start v-6.2 MYSALES-452
                    setOpportunityCode(Trigger.new);
                    //End v-6.2 MYSALES-452
                    setOpptyActList(Trigger.new);
                    chkAmtValid(Trigger.new);
                    insertOpptyTeamProposalPmUser(Trigger.new, null);
                    upsertOpportunityAmountHistory(Trigger.new, null);
                    
                    if(OpportunitySendToSAPSwitch) sendToSAP(Trigger.new);// We can check
                    //V 4.6 -> Add manual sharing for group 'mig20005' (MYSALES-103)
                    setManualSharingCloudRoleInsert(Trigger.new); 
                    updateTXPManpowerInfo(Trigger.new);//V5.7
                    CreateDeliveryprobability(Trigger.new);//V6.5
                }
            }
            
            when AFTER_UPDATE {
                if(oppCodeNotUpdated){ //Added as part of v-6.2 MYSALES-452 
                    if(!MigSwitch) {
                        system.debug('Opp After Calling');
                        setlockRecordClosedStage(Trigger.new, Trigger.oldMap); // [2021-01-22 변경] - Closed Lost, Dropped 인 경우 Oppty Record Lock
                        chkAmtValid(Trigger.new);
                        insertOpptyTeamProposalPmUser(Trigger.new, Trigger.oldMap);
                        upsertOpportunityAmountHistory(Trigger.new, Trigger.oldMap);
                        System.debug('SJ-504'); //SJOSHI
                        if(OpportunitySendToSAPSwitch) sendToSAP(Trigger.new); // We Can check
                        //owner변경시 knox 이메일 발송
                        sendOwnerChangeKnoxEmail(Trigger.new, Trigger.old);
                        updateOpptyTeamSalesRepUser(Trigger.new, Trigger.oldMap); //Added by Anish-v 5.8
                        
                        //owner변경시 knox 공지 채팅 전송
                        sendOwnerChangeKnoxChat(Trigger.new, Trigger.old);
                        if(test.isRunningTest()){
                            saveSalesLeadConvertedBO(Trigger.old); 
                            sendToSAP(Trigger.old);// we can check
                            closedWonValidation(Trigger.new);
                        }
                        //V 4.6 -> Add manual sharing for group 'mig20005' (MYSALES-103)
                        setManualSharingCloudRoleUpdate(Trigger.new, Trigger.oldMap);    // we can Check
                        updateTXPManpower(Trigger.new, Trigger.oldMap); //V5.7
                    }
                }//Added as part of v-6.2 MYSALES-452
            }
            
            when AFTER_DELETE {      
                if(!MigSwitch) {          
                    if(OpportunitySendToSAPSwitch) sendToSAP(Trigger.old);
                    //2022-06-16, hyunhak.roh@dkbmc.com, 사업리드 Converted BO가 삭제 시 해당 사업리드 단계를 되돌리는 로직 추가
                    saveSalesLeadConvertedBO(Trigger.old);
                    CollabBOUpdate(Trigger.old); //V4.7 - My Sales 110
                }
            }
        }
    }
    
    //사용자가 값을 입력하면 입력값을 사용. 입력값이 없으면 System Default 값 사용.
    private static void setBORegisteredInfo(List<Opportunity> newList){
        for(Opportunity rowBO : newList){
            
            if(rowBO.BO1stRegisteredById__c == null){
                rowBO.BO1stRegisteredById__c = Userinfo.getUserId();
            }
            if(rowBO.BO1stRegistrationDate__c == null){
                rowBO.BO1stRegistrationDate__c = System.now();
            }
            
        }
    }
    
    //CSP/MSP Type 입력값에 따른 Validtaion 체크
    private static void checkCMSPValidation(List<Opportunity> newList){
        //사용자가 본사(T100) 인지 체크. 본사 사용자의 경우에만 CSP/MSP Type 입력 가능. 그외 N/A만 입력가능.
        //사용자가 본사(T100) 인지 체크 => BO CompanyCode 값으로 변경.
        //List<User> listUser = [SELECT id, CompanyCode__c FROM user WHERE Id =: UserInfo.getUserId() AND CompanyCode__c = 'T100'];
        
        
        for(Opportunity rowBO : newList){
            if('CSP'.equals(rowBO.CspMspType__c)){
                if(rowBO.OtherCSP__c != null && !test.isRunningTest()){
                    rowBO.addError('OtherCSP__c',System.Label.OPPTY_ERR_016);
                }
                // 2022-08-02 MSP 수주금액필드 추가.
                if(rowBO.MSP_Amount__c != null  && !test.isRunningTest()){
                    rowBO.addError('MSP_Amount__c',System.Label.OPPTY_ERR_018);
                }
                //V 4.3 -> Add error condition for MY-Sales-114
                if((rowBO.StageName == 'Z05' || rowBO.StageName == 'Z06') 
                   && rowBO.cPrimarySalesDepartment__c == null
                   && (!ifMigUserNamesSet.contains(USER_NAME))){ //Added as part of v-6.8
                       if(!Test.isRunningTest()){
                           rowBO.addError('cPrimarySalesDepartment__c',System.Label.OPPTY_ERR_025);
                       }
                   }
                //V4.4 ->START -  MySales 112
                if(rowBO.Collaboration__c == True){
                    if(!Test.isRunningTest()){
                        rowBO.addError(System.Label.OPPTY_ERR_026);
                    }
                }
                //V4.4 ->END -  MySales 112
            }else if('MSP'.equals(rowBO.CspMspType__c)){
                if(rowBO.SCPScale__c != null && !test.isRunningTest()){
                    rowBO.addError('SCPScale__c',System.Label.OPPTY_ERR_015);
                }
                // 2022-08-02 MSP 수주금액필드 추가.
                if(rowBO.ConversionType__c != null && rowBO.CMBizType__c != null && rowBO.MSP_Amount__c == null){
                    rowBO.addError('MSP_Amount__c',System.Label.OPPTY_ERR_019);
                }
                //V 4.3 -> Add error condition for MY-Sales-114
                if((rowBO.StageName == 'Z05' || rowBO.StageName == 'Z06') 
                   && rowBO.cPrimarySalesDepartment__c == null
                   && (!ifMigUserNamesSet.contains(USER_NAME))){ //Added as part of v-6.8)
                       if(!Test.isRunningTest()){  //Added by Anish
                           rowBO.addError('cPrimarySalesDepartment__c',System.Label.OPPTY_ERR_025);
                       }
                   }
            }else if('SaaS'.equals(rowBO.CspMspType__c)){
                if(rowBO.SCPScale__c != null && !test.isRunningTest()){
                    rowBO.addError('SCPScale__c',System.Label.OPPTY_ERR_015);
                }
                if(rowBO.OtherCSP__c != null && !test.isRunningTest()){
                    rowBO.addError('OtherCSP__c',System.Label.OPPTY_ERR_016);
                }
            }
            /**V 4.4- START - (MYSALES-112 )**/
            if((
                ('T140'.equals(rowBO.CompanyCode__c)) || ('ZB01'.equals(rowBO.CompanyCode__c)) || ('T110'.equals(rowBO.CompanyCode__c)) || ('T120'.equals(rowBO.CompanyCode__c)) 
            )
               && OPP_CMSP_TYPE.contains(rowBO.CspMspType__c) 
               && !test.isRunningTest()){
                   rowBO.addError('CspMspType__c',System.Label.OPPTY_ERR_014);
               }
            /**V 4.4- END - (MYSALES-112 )**/
        }
        
        
    }
    
    //CSP/MSP Type 값 변경시 관련 필드 ReSet
    private static void reSetCMSPTypeField(List<Opportunity> newList, Map<Id, Opportunity> oldMap){
        for(Opportunity rowBO : newList){
            if(rowBO.CspMspType__c != oldMap.get(rowBO.Id).CspMspType__c){
                //CSP/MSP Type 값 변경시 관련 필드 ReSet
                for(String strFieldName : OPP_CMSP_TYPE_RESET_FIELD){
                    rowBO.put(strFieldName, null);                    
                }
                //CSP/MSP Type 값 변경시 Alert Count = 0으로 설정하여 Alert창이 뜨게 설정.
                if(OPP_CMSP_TYPE.contains(rowBO.CspMspType__c)){
                    rowBO.CMEntAlertCnt__c = 0;
                }                
            }
            //2022-09-07, hyunhak.roh@dkbmc.com, MSP사업의 수주금액 관리를 위한 안내메세지 요청
            if(rowBO.Amount != oldMap.get(rowBO.Id).Amount && rowBO.RecordTypeId == RT_OPPTY_HQ_ID && 'MSP'.equals(rowBO.CspMspType__c)) {
                rowBO.isChangeCMSPAmount__c = true;
                //rowBO.Amount              = oldMap.get(rowBO.Id).Amount;  // 수정 이전의 금액으로 원복 처리
            }
            //System.debug('### reSetCMSPTypeField :: rowBO.isChangeCMSPAmount__c = ' + rowBO.isChangeCMSPAmount__c);
            //System.debug('### reSetCMSPTypeField :: rowBO.Amount = ' + rowBO.Amount);
            //System.debug('### reSetCMSPTypeField :: oldMap.get(rowBO.Id) = ' + oldMap.get(rowBO.Id));
            //System.debug('### reSetCMSPTypeField :: rowBO.RecordTypeId = ' + rowBO.RecordTypeId);
            //System.debug('### reSetCMSPTypeField :: RT_OPPTY_HQ_ID = ' + RT_OPPTY_HQ_ID);
            //System.debug('### reSetCMSPTypeField :: rowBO.Amount = ' + RT_OPPTY_HQ_ID);
            
            //system.debug('### reSetCMSPTypeField :: CurrencyIsoCode = ' + rowBO.CurrencyIsoCode);
            //Currency 값이 KRW 이면 Count = 0으로 리셋.
            if('KRW'.equals(rowBO.CurrencyIsoCode)){
                rowBO.KRWNoticeCnt__c = 0;
            }
        }
    }
    
    //CSP/MSP Type 선택시 BO Name에 Prefix "[CSP]","[MSP]","[Saas]" 붙임.
    private static void setCMSPBoReName(List<Opportunity> newList){
        //&& row.Name.indexOf('['+ row.CspMspType__c + ']')
        for(Opportunity rowBO : newList){
            //"[CSP]","[MSP]","[Saas]" 포함되어 있으면 삭제.
            for(String strType : OPP_CMSP_TYPE){
                if(rowBO.Name.indexOf('['+ strType + ']') >= 0){
                    rowBO.Name = rowBO.Name.replace('['+ strType + ']','');
                }
            }
            //Prefix 붙임.
            if(OPP_CMSP_TYPE.contains(rowBO.CspMspType__c)){
                rowBO.Name = '['+ rowBO.CspMspType__c + ']' + rowBO.Name;
            }
        }
    }
    
    
    /**
* @description Origin Account 가 입력되지 않은 경우, Account를 자동 Setting
* @author hj.lee@dkbmc.com | 2021-05-20 
* @param newList 
* @param oldMap 
**/
    private static void setOriginAccount(List<Opportunity> newList){
        Set<Id> accIds = new Set<Id>();
        for(Opportunity newOppty : newList) {
            accIds.add(newOppty.AccountId);
        }
        Map<Id, Account> accMap = new Map<Id, Account>([SELECT MDGCheck__c FROM Account WHERE Id IN :accIds]);
        
        for(Opportunity newOppty : newList) {
            // Setting 제외 로직
            if(newOppty.AccountId == null) continue;
            if(newOppty.cOriginAcc__c != null) continue;
            if(accMap.containsKey(newOppty.AccountId) && accMap.get(newOppty.AccountId).MDGCheck__c == false) continue;
            
            newOppty.cOriginAcc__c = newOppty.AccountId;
        }
    }
    
    /**
* @description 대시보드 filter를 걸기 위해(수식필드 필터 불가) 수식 필드로 정의되어 있는 대내/대외 여부 필드, 국내/해외 필드를 Picklist에 Setting
* @author hj.lee@dkbmc.com | 2021-05-20 
* @param newList 
* @param oldMap 
**/
    private static void setValueFilterPicklist(List<Opportunity> newList, Map<Id, Opportunity> oldMap){
        Set<Id> originAccIds = new Set<Id>();
        for(Opportunity newOppty : newList) {
            originAccIds.add(newOppty.cOriginAcc__c);
        }
        Map<Id, Account> originAccMap = new Map<Id, Account>([SELECT mDomesticForeign__c, mCountry__c FROM Account WHERE Id IN :originAccIds]);
        
        for(Opportunity newOppty : newList) {
            if(newOppty.cOriginAcc__c == null) {
                newOppty.Internal_Biz_filter__c = null;
                newOppty.Korea_Domestic_Biz_filter__c = null;
                
            } else {
                Account originAccount = originAccMap.get(newOppty.cOriginAcc__c);
                
                // Internal_Biz_filter__c Setting (대내/대외 : Group In / Group Out)
                if(newOppty.RecordTypeId == RT_OPPTY_HQ_ID) {
                    newOppty.Internal_Biz_filter__c = (originAccount.mDomesticForeign__c == '10') ? 'Group In' : 'Group Out';
                    
                } else if(newOppty.RecordTypeId == RT_OPPTY_LOGISTICS_ID) {
                    newOppty.Internal_Biz_filter__c = (newOppty.LogisticsCustomerType__c == 'SECSET' 
                                                       || newOppty.LogisticsCustomerType__c == 'SECDS'
                                                       || newOppty.LogisticsCustomerType__c == 'NSEC') ? 'Group In' : 'Group Out';
                }
                
                // Korea_Domestic_Biz_filter__c Setting (국내/해외 : Korea / Non-Korea)
                newOppty.Korea_Domestic_Biz_filter__c = (originAccount.mCountry__c == 'KR') ? 'Korea' : 'Non-Korea';
                
            }
        }
        
    }
    
    private static void chkAmtValid(List<Opportunity> objList){
        Map<String, DatedConversionRate> conversionRateMap = IF_Util.getRecentlyDatedConversionRate();                    // 최근 환율정보
        
        //company info
        Set<String> companyCodeSet = new Set<String>();
        Set<Date> closeDateSet = new Set<Date>();
        for (Opportunity obj : objList) {
            companyCodeSet.add(obj.CompanyCode__c);    // Company정보 가져올 companyCodeSet 적재
            closeDateSet.add(obj.CloseDate);       // 환율정보 조회를 위한 CloseDate Set 적재
        }
        Map<Date, Date> quarterDateMap = IF_Util.getQuarterStartDate(closeDateSet);
        Map<String, DatedConversionRate> conversionPastRateMap = IF_Util.getDatedConversionRate(quarterDateMap.values()); // 분기별 환율정보
        List<Company__c> companyList = [
            SELECT  Id, 
            CompanyCode__c,
            Name,
            Country__c,
            CurrencyIsoCode,
            EPCompanyCode__c,
            Headquarter__c,
            CompanyFullName__c
            FROM    Company__c
            WHERE   CompanyCode__c IN :companyCodeSet
        ];
        System.debug('Number of Queries used in this apex code so far:'+ Limits.getQueries());
        Map<String, Company__c> companyMap = new Map<String, Company__c>();
        for (Company__c companyData : companyList) {
            companyMap.put(companyData.CompanyCode__c, companyData);
        }
        
        
        
        for(Opportunity obj :  objList){
            
            //Amount
            Decimal orderAmt = 0;
            if (obj.Amount != null) {
                orderAmt = obj.Amount;
            }
            String strAmt = orderAmt.setScale(2, System.RoundingMode.HALF_UP).toPlainString();
            String CompanyCurrencyIsoCode = null;
            if (companyMap.get(obj.CompanyCode__c) != null) {
                CompanyCurrencyIsoCode = companyMap.get(obj.CompanyCode__c).CurrencyIsoCode;
            }
            
            //Local Amount
            Decimal calculationResult = 0;
            if (conversionRateMap.get(obj.CurrencyIsoCode) != null && conversionRateMap.get(CompanyCurrencyIsoCode) != null) {
                if (obj.CurrencyIsoCode == CompanyCurrencyIsoCode) {
                    calculationResult = obj.Amount;
                } else {
                    
                    String fromIsoCode = obj.CurrencyIsoCode;
                    String toIsocode = CompanyCurrencyIsoCode;
                    Date startDate = quarterDateMap.get(obj.CloseDate);
                    Decimal fromUsdRate = 0;
                    Decimal toUsdRate = 0;
                    
                    if (conversionPastRateMap.get(fromIsoCode + startDate) != null) {
                        fromUsdRate = conversionPastRateMap.get(fromIsoCode + startDate).ConversionRate;
                    } else {
                        fromUsdRate = conversionRateMap.get(fromIsoCode).ConversionRate;
                    }
                    
                    if (conversionPastRateMap.get(toIsoCode + startDate) != null) {
                        toUsdRate = conversionPastRateMap.get(toIsoCode + startDate).ConversionRate;
                    } else {
                        toUsdRate = conversionRateMap.get(toIsoCode).ConversionRate;
                    }
                    
                    if( Util_String.nvlDec( obj.Amount) > 0){
                        calculationResult = IF_Util.calculationCurrency(fromIsoCode
                                                                        , obj.Amount
                                                                        , toIsoCode
                                                                        , fromUsdRate
                                                                        , toUsdRate  );
                    }
                }
            }
            if (calculationResult == null) {
                calculationResult = 0;
            }
            
            
            
            if(calculationResult != 0){
                String strLocalAmt = calculationResult.setScale(2, System.RoundingMode.HALF_UP).toPlainString();
                System.debug('strLocalAmt : '+strLocalAmt);
                if( strLocalAmt.split('\\.')[0].length() > 13 || strLocalAmt.split('\\.')[1].length() > 2 ){
                    
                    obj.addError('You can not enter more than 15 digits for the amount of order.');
                } 
                
            }
            
            if( orderAmt > 0){
                if( strAmt.split('\\.')[0].length() > 13 || strAmt.split('\\.')[1].length() > 2) {
                    
                    obj.addError('You can not enter more than 15 digits for the amount of order.');
                }   
            }
        }
    }
    
    //CostCenter 자동 매핑(5-3)
    private static void setCC(List<Opportunity> objList){ // Migration에서는 제외 - 확인필요
        // [S] Opportunity Code 계산
        // Opportunity Code 형식
        // SDS-{YY}{00000}0
        // SDS-년도(2자리) / 고유넘버(5자리) / 0 <- (맨 마지막 한자리)사업기회 고유표시
        
        // TODO : BO 코드 채번 어떻게 했었는지 김영훈 과장에 확인 후 아래 로직 주석 처리.(-1)
        integer codeInt = 0;
        Date today = system.today();
        string year = (String.valueof(today)).substring(2,4);
        String searchString = '%SDS-' + year + '%';
        
        List<AggregateResult> maxCode = [SELECT max(OpportunityCode__c) mx FROM opportunity WHERE OpportunityCode__c LIKE: searchString];
        String codeSt = String.valueof(maxCode[0].get('mx'));
        
        if((maxCode[0].get('mx') != null)&&(year==codeSt.substring(4,6))){
            codeInt = Integer.valueOf(codeSt.substring(6,11))+1;
        } else {
            codeInt =  1;
        }
        
        // [E] Opportunity Code 계산
        
        Set<Id> userIDs = new Set<Id>();
        for(Opportunity obj : objList){
            userIds.add(obj.ownerId);
        }
        
        //2020-11-30 추가, Sales Department 입력
        //TODO : 굳이 조회할필요가 있을까??(-1)
        Map<Id, User> userMap = new Map<Id, User>([SELECT Id, FederationIdentifier, CompanyCode__c FROM User where id in: userIds]);
        //2020-12-23 추가, Employee Query 조건문 추가
        
        //seonju.jin@dkbmc.com | 2021-03-29  유저,사원정보 쿼리 수정
        
        //유저정보
        //Map<String, User> userMap = new Map<String,User>();
        List<User> userList = userMap.values();
        Set<String> empNo = new Set<String>();
        for(User obj : userList){
            if(String.isNotBlank(obj.FederationIdentifier)){
                empNo.add(obj.FederationIdentifier);
            }
        }
        
        //Employee
        // TODO : 굳이 User 정보를 한번더 조회할 필요가 있을까?? 그리고 위험해 보임. 해당 Util를 루프문 안에 사용할 가능성 있음.(-1)
        Map<String, Employee__c> empMap = Utils.getEmployeeMap(empNo);
        // List<Employee__c> empList = [SELECT Id, EvKostl__c, EvUniqID__c, EvSapBukrs__c FROM Employee__c where EvUniqId__c in: empNo];
        // for(Employee__c e : empList){  
        //     if(String.isNotBlank(e.EvUniqID__c)){
        //         empMap.put(e.EvUniqID__c, e);
        //     }
        // }
        
        //CostCenter
        Map<String, CostCenter__c> costMap = new Map<String, CostCenter__c>();
        Set<Id> getCostCenterSet = new Set<Id>();
        List<CostCenter__c> costList = [SELECT Id, CostCenter__c, ZZCheck__c, Closed__c FROM CostCenter__c  
                                        WHERE ZZCheck__c = true AND Closed__c = false ];
        for(CostCenter__c c : costList){
            costMap.put(c.CostCenter__c,c);
            getCostCenterSet.add(c.Id);
        }
        
        /** seonju.jin@dkbmc.com | 2021-03-29 로직 수정
* 사업기회 복제 및 협업 BO 생성 시 , 주수주/매출 부서 값 생성 로직
* 1)협업 사업기회 생성 - OWner의 주/매출 부서 자동 등록
* 2)사업기회 복제 - 사업기회의 주 수주/매출부서 copy
* 주 수주/매출부서 손익여부(x), 폐쇠여부(0)이면 blank처리
*/
        
        for(Opportunity opp : objList) {
            // [S] OpportunityCode__c 에 증번 update
            /*
if(opp.Collaboration__c == false && opp.OpportunityCode__c == null){ // Opportunity Code를 입력한 경우는 채번 X for Migration
String nextCode = 'SDS-'+year+String.valueof(codeInt).LeftPad(5, '0')+0;
opp.OpportunityCode__c = nextCode;
codeInt++;
}
*/
            // [E] OpportunityCode__c 에 증번 update
            
            if(!opp.MigData__c ){
                if(opp.Collaboration__c && !opp.IsOriginal__c){
                    if(userMap.get(opp.ownerId) != null){
                        if(empMap.get(String.valueOf(userMap.get(opp.ownerId).FederationIdentifier)) != null){
                            if(costMap.get(String.valueOf(empMap.get(String.valueOf(userMap.get(opp.ownerId).FederationIdentifier)).EvKostl__c)) != null){
                                opp.SalesDepartment__c = costMap.get(String.valueOf(empMap.get(String.valueOf(userMap.get(opp.ownerId).FederationIdentifier)).EvKostl__c)).id;
                                opp.cPrimarySalesDepartment__c = costMap.get(String.valueOf(empMap.get(String.valueOf(userMap.get(opp.ownerId).FederationIdentifier)).EvKostl__c)).id;
                            }else{
                                //V 4.7 -> Changes for MySales-110
                                //opp.SalesDepartment__c = null;
                                //opp.cPrimarySalesDepartment__c = null;
                                opp.addError(System.Label.OPPTY_ERR_024);
                            }
                        }else{
                            //V 4.7 -> Changes for MySales-110
                            opp.addError(System.Label.OPPTY_ERR_024);
                        }
                    }else{
                        //V 4.7 -> Changes for MySales-110
                        opp.addError(System.Label.OPPTY_ERR_024);
                    }
                }else{
                    if(!getCostCenterSet.contains(opp.SalesDepartment__c)){
                        opp.SalesDepartment__c = null;
                    }
                    if(!getCostCenterSet.contains(opp.cPrimarySalesDepartment__c)){
                        
                        opp.cPrimarySalesDepartment__c = null;
                    }
                }
            }
        }
    }
    
    /*
private static void checkBizType2(List<Opportunity> objList, Map<Id, Opportunity> oldMap, String operationType){
for(Opportunity oppty : objList){
if(oppty.RecordTypeId == RT_OPPTY_HQ_ID && oppty.CompanyCode__c == 'T100' && !oppty.GroupInternal__c){
if(operationType == 'I'){ // Insert
if(oppty.BusinessType2__c == null) oppty.BusinessType2__c.addError('Please enter Biz. Type2');
}else{ // Update
String oldBizType2 = oldMap.get(oppty.Id).BusinessType2__c;
if(oldBizType2 != null && oppty.BusinessType2__c == null) oppty.BusinessType2__c.addError('Please enter Biz. Type2');
}
}
}
}
*/
    
    //Business Level (by amount). Amount 에 따라 비지니스 등급 설정.
    private static void setBizLv(List<Opportunity> objList){ // Migration에서는 제외 - 확인필요
        /*
Biz Level은 한화 기준
100억 초과                 ->      S
50억 초과, 100억 이하       ->      A
20억 초과, 50억 이하        ->      B
20억 이하                  ->      C
*/
        Map<String, Decimal> rateMap = new Map<String, Decimal>();
        // 통화별 환율 Map 생성 -> Map<통화, 환율>
        List<DatedConversionRate> rateList = [SELECT Id, isoCode, Conversionrate, nextStartDate, startDate FROM DatedConversionRate WHERE nextStartDate >= TODAY ORDER BY NextStartDate DESC];
        if(rateList.size() > 0){
            for(DatedConversionRate rate : rateList){
                rateMap.put(rate.isoCode, rate.Conversionrate);
            }
        }
        
        for(Opportunity oppty : objList){
            Decimal conversionRate = 0;
            Decimal opptyAmount = 0;
            Decimal targetAmount = 0;
            if(oppty.Amount != null){
                if(oppty.CurrencyIsoCode != 'KRW'){ // 외화일 경우 KRW로 전환 (입력 Currency -> USD -> KRW)
                    conversionRate = rateMap.get(oppty.CurrencyIsoCode);
                    opptyAmount = (oppty.Amount / conversionRate) * rateMap.get('KRW');
                    targetAmount = opptyAmount;
                }else{ // 한화일 경우 그대로 사용
                    targetAmount = oppty.Amount;
                }
                
                // 금액별 등급 설정
                if(targetAmount > 10000000000.0){
                    oppty.BusinessLevel__c = 'S';
                }else if(targetAmount <= 10000000000.0 && targetAmount > 5000000000.0){
                    oppty.BusinessLevel__c = 'A';
                }else if(targetAmount <= 5000000000.0 && targetAmount > 2000000000.0){
                    oppty.BusinessLevel__c = 'B';
                }else{
                    oppty.BusinessLevel__c = 'C';
                }
            }
        }
    }
    
    private static void setOpptyStatus(List<Opportunity> objList){ 
        for(Opportunity oppty : objList){
            if(oppty.StageName == OPP_STAGE_IDENTIFIED || oppty.StageName == OPP_STAGE_VALIDATED 
               || oppty.StageName == OPP_STAGE_QUALIFIED || oppty.StageName == OPP_STAGE_SOLUTIONED) { 
                   oppty.OpportunityStatus__c = 'E0002';
               } else if (oppty.StageName == OPP_STAGE_WON) {
                   oppty.OpportunityStatus__c = 'E0003';
               } else if (oppty.StageName == OPP_STAGE_LOST) {
                   oppty.OpportunityStatus__c = 'E0004';
               } else if (oppty.StageName == OPP_STAGE_DROP) {
                   oppty.OpportunityStatus__c = 'E0007';
               } else if (oppty.StageName == OPP_STAGE_CLEANSED){
                   oppty.OpportunityStatus__c = 'E0008';
               }
        }
    }
    
    // Added by Anish - v 4.8
    public static void setOpptyVRBType(List<Opportunity> objList, Map<Id,Opportunity> oldMap ){ 
        for(Opportunity oppty :objList){
            if(oppty.BusinessType__c != 'TI' && oldMap.get(oppty.Id).BusinessType__c == 'TI'){
                oppty.Opportunity_Review_VRB_Type_Confirm__c = null;
                oppty.Opportunity_Review_VRB_Type__c = null;

            }
        }
    }
    
    /**
* Mig Data 를 수정한 이력이 있으면, 운영중인 사업기회로 판단하여 IsEdited__c = true Setting
* Mig Data = true and IsEdited__c = true 인 경우 sendToSAP 전송쿼리에 포함
*/
    private static void setFieldIsEdited(List<Opportunity> objList, Map<Id, Opportunity> oldMap){ 
        for(Opportunity oppty : objList){
            if(oppty.MigData__c) {
                oppty.IsEdited__c = true;
            }
        }
    }
    // Atul Start MySales-296 V 5.2
    private static void checkOppAmountValue(List<Opportunity> objList, Map<Id, Opportunity> oldMap){ 
        List<DatedConversionRate> currencyTypeList = [SELECT Id, IsoCode, ConversionRate, nextStartDate, startDate FROM DatedConversionRate where StartDate <= TODAY AND NextStartDate > TODAY ORDER BY NextStartDate DESC];
        
        Map<String , Decimal> isoWithRateMap = new Map<String, Decimal>();
        for(DatedConversionRate d : currencyTypeList) {
            isoWithRateMap.put(d.IsoCode , d.ConversionRate);
        }
        for(Opportunity oppty : objList){
            
            if(oppty.Amount != null && oppty.CurrencyIsoCode != null && oppty.Amount_Change__c == false ){
                Decimal exchnageRate = (isoWithRateMap.get('USD')/isoWithRateMap.get(oppty.CurrencyIsoCode));
                Decimal USDAmount = (oppty.Amount*exchnageRate).setscale(2);
                
                if(((trigger.isUpdate) && oppty.Amount !=  oldMap.get(oppty.Id).Amount && USDAmount >= 10000000 && oppty.RecordTypeId == RT_OPPTY_LOGISTICS_ID ) || 
                   ((trigger.isInsert) &&  USDAmount >= 10000000 && oppty.RecordTypeId == RT_OPPTY_LOGISTICS_ID)) {
                       system.debug('Update to True');
                       oppty.Amount_Change__c = true;
                   }
            }
        }
    }
    /* Atul Start MySales-462  V 6.3*/
    private static void checkingBusinessArea(List<Opportunity> objList, Map<Id, Opportunity> oldMap){
        Set<String> oppCodeSet = new Set<String>();
        Map<Id,Id> oppIdCostCenterRecOld = new  Map<Id,Id>();
        Map<Id,Id> oppIdCostCenterRecNew = new  Map<Id,Id>();
        List<CostCenter__c> costCenterLst = new List<CostCenter__c>();
        Map<Id,CostCenter__c> costCenterMap = new Map<Id,CostCenter__c>();
        for (Opportunity obj : objList) {
            oppCodeSet.add(obj.id);
            if(obj.cPrimarySalesDepartment__c != oldMap.get(obj.id).cPrimarySalesDepartment__c && obj.cPrimarySalesDepartment__c != null){
                oppIdCostCenterRecOld.put(obj.Id ,oldMap.get(obj.id).cPrimarySalesDepartment__c);
                oppIdCostCenterRecNew.put(obj.Id ,obj.cPrimarySalesDepartment__c);
            }
        }
        if(oppIdCostCenterRecOld != null || oppIdCostCenterRecNew != null){
            costCenterLst = [SELECT id,name,BA__c FROM CostCenter__c Where id IN: oppIdCostCenterRecOld.values() OR id IN: oppIdCostCenterRecNew.values()];
            if(!costCenterLst.isEmpty()){
                For(CostCenter__c eachCostCenter : costCenterLst){
                    
                    costCenterMap.put(eachCostCenter.id,eachCostCenter);
                }
            }
        }
        Map<String,Integer> pjtMap = getValidPjtInfo(oppCodeSet);
        for (Opportunity oppty : objList) {
            if(pjtMap.get(oppty.Id) > 0){
                if(oppty.cPrimarySalesDepartment__c != oldMap.get(oppty.id).cPrimarySalesDepartment__c){
                    if(oppty.cPrimarySalesDepartment__c == null && oldMap.get(oppty.id).cPrimarySalesDepartment__c != null){
                        oppty.addError(system.label.BO_Primary_Delivery_Dept_Lv_3_Validation);
                    }
                    if(costCenterMap.containsKey(oppty.cPrimarySalesDepartment__c) && costCenterMap.containsKey(oldMap.get(oppty.id).cPrimarySalesDepartment__c)){
                        if(costCenterMap.get(oppty.cPrimarySalesDepartment__c).BA__c != costCenterMap.get(oldMap.get(oppty.id).cPrimarySalesDepartment__c).BA__c){
                            oppty.addError(system.label.BO_Primary_Delivery_Dept_Lv_3_Validation);
                        }
                    }
                }
            }
            
        }
    }
    /* Atul End MySales-462  V 6.3*/
    private static void checkDelete(List<Opportunity> objList){
        Set<String> oppCodeSet = new Set<String>();
        for (Opportunity obj : objList) {
            oppCodeSet.add(obj.id); 
        }
        
        Map<String,Integer> pjtMap = getPjtInfo(oppCodeSet);
        
        //*Version: 4.1  -- Start-- Prevent deletion of the opportunity for profile Service Desk Agency.        
        String profileNameUserInfo = [SELECT Name FROM Profile WHERE Id =: UserInfo.getProfileId()].Name;
        String Sdeskprofile = 'Service Desk Agency';
        //*Version: 4.1  -- End--.  
        
        for(Opportunity oppty : objList){
            //생성된 Project가 하나라도 있으면 삭제 불가능
            if(pjtMap.get(oppty.Id) > 0){  
                oppty.addError(System.Label.OPPTY_MSG_003 );
            }
            
            // 법인은 협업중인 Opportunity 삭제 불가능
            if(oppty.Collaboration__c && oppty.CollaborationInOut__c ==  'OUT'){
                oppty.addError(System.Label.OPPTY_MSG_001); // Opportunity in collaboration cannot be deleted.
            }
            
            // Idendified 이외의 Stage는 삭제 불가능
            if(oppty.StageName != OPP_STAGE_IDENTIFIED ){ 
                oppty.addError(System.Label.OPPTY_MSG_002); // If it is a stage other than Idendified, it cannot be deleted.
            }
            
            
            //*Version: 4.1  -- Start-- Prevent deletion of the opportunity for profile Service Desk Agency.        
            
            if(profileNameUserInfo == Sdeskprofile){
                oppty.addError(System.Label.Deleteoppserivedesk);
            }
            //*Version: 4.1  -- End--.        
            
        }
    }
    
    private static void setOpptyActList(List<Opportunity> objList){ // Migration에서는 제외
        /*
* Opportunity 최초 등록시 Opportunity Activity 최초 번호 자동 생성
*/
        List<Opportunity_Activity__c> opptyActList = new List<Opportunity_Activity__c>();
        String transaction1stValue = Utils.getPicklistOptionType('Opportunity_Activity__c','TransactionName__c')[0].get('value');
        for(Opportunity n : objList){
            Opportunity_Activity__c opptyAct = new Opportunity_Activity__c(
                WhatId__c = n.Id,
                TransactionName__c = transaction1stValue,
                Status__c = 'Completed',
                StartDate__c = Date.today(),
                EndDate__c = Date.today()
            );
            opptyActList.add(opptyAct);
        }
        if(!test.isRunningTest())
            insert opptyActList;
    }    
    
    private static void setlockRecordClosedStage(List<Opportunity> newList, Map<Id, Opportunity> oldMap){ // Migration에서는 제외
        List<Id> lockIds = new List<Id>();
        for(Opportunity opp : newList){
            String oldStage = oldMap.get(opp.Id).StageName;
            String newStage = opp.StageName;
            Boolean isStageChange = oldStage != newStage;
            
            Set<String> OPP_STAGE_CLOSED_SET = OpportunityActivityHelper.OPP_STAGE_CLOSED_SET;
            
            if(isStageChange) { 
                if(OPP_STAGE_CLOSED_SET.contains(newStage)) {
                    System.debug('Stage Name : ' +newStage);
                    if(newStage == OpportunityActivityHelper.OPP_STAGE_LOST || newStage == OpportunityActivityHelper.OPP_STAGE_DROP || newStage == OpportunityActivityHelper.OPP_STAGE_CLEANSED){ 
                        //IT BO의 경우에만 Locked 처리함. 물류 BO는 Locked 처리하지 않음.
                        if(opp.RecordTypeId == RT_OPPTY_HQ_ID){
                            lockIds.add(opp.id);
                            System.debug('### OpportunityTrigger :: setlockRecordClosedStage :: BO Id = ' + opp.id);
                        }
                    }
                }
            }
        }
        if(lockIds.size() > 0) Approval.lock(lockIds);
    }
    
    private static void sendToSAP(List<Opportunity> objList){ // Migration에서는 제외
        /**
* SAP 실시간 전송 : RecordType 에 따라 전송 I/F 상이함
* [21-02-09] RecordType "Logistics"  전송 I/F 추가 (IF-125, IF-094)
* - "Logistics"      :  IF_EccOpportunityController + IF_EccOpportunityLogisController (IF-125, IF-094)
* - "Logistics 제외"  : IF_EccOpportunityLogisController (IF-094)
*/
        List<String> opptyIdList_if094_logi = new List<String>();
        List<String> opptyIdList_if125_hq = new List<String>();
        for(Opportunity oppty : objList){
            if(String.isNotBlank(oppty.RecordTypeId)) {
                if(oppty.RecordTypeId == RT_OPPTY_LOGISTICS_ID) {
                    opptyIdList_if094_logi.add(oppty.Id);
                    opptyIdList_if125_hq.add(oppty.Id); 
                } else {
                    opptyIdList_if125_hq.add(oppty.Id);  
                    System.debug('SJ-504-a'); //SJOSHI
                }
            }
        }
        Boolean isBatch = System.isBatch();
        Boolean isQueueable = System.isQueueable();
        System.debug('=== OpportunityTrigger.isBatch ? ' + isBatch);
        System.debug('=== OpportunityTrigger.isQueueable ? ' + isQueueable);
        if(isBatch || Test.isRunningTest()) { //Added by Anish-v 6.1
            /** Batch 에서 호출 시, Batch 호출 */
            if(opptyIdList_if094_logi.size() > 0) { 
                Batch_EccOpportunityLogisController batch_opptyToSAPLogis = new Batch_EccOpportunityLogisController();
                batch_opptyToSAPLogis.selectIdList = opptyIdList_if094_logi;
                Database.executeBatch(batch_opptyToSAPLogis);
            }
            if(opptyIdList_if125_hq.size() > 0) { 
                Batch_EccOpportunityController batch_opptytoSAP = new Batch_EccOpportunityController();
                batch_opptytoSAP.selectIdList = opptyIdList_if125_hq;
                Database.executeBatch(batch_opptytoSAP);
            }
            
        } else {
            /** Trigger 첫 시작 시 */
            if(opptyIdList_if094_logi.size() > 0) IF_EccOpportunityLogisController.calloutOpportunityLogisInfo(opptyIdList_if094_logi);  
            if(opptyIdList_if125_hq.size() > 0){
                System.debug('SJ-504-b'); //SJOSHI
                IF_EccOpportunityController.calloutOpportunityInfo(opptyIdList_if125_hq); 
                System.debug('SJ-504-c'); //SJOSHI
            } 
            
            // System.enqueueJob(new IF_EccOpportunityLogisController(opptyIdList_if094_logi)); // Logistics
            // System.enqueueJob(new IF_EccOpportunityController(opptyIdList_if125_hq)); // hq
        }
        
    }
    
    private static void setProposalPM(List<Opportunity> objList){
        /*
1. Proposal PM으로 입력된 User 정보를 검색
2. 1에서 검색한 User의 정보로 Key 생성하여 Map 생성 (Key: FederationIdentifier + CompanyCode)
3. 2에서 생성한 Key에 해당하는 Employee를 검색
4. 3에서 찾은 Employee를 Proposal PM으로 입력하여 저장

2022-01-04 로직 수정 
기존 User -> Employee를 찾는 방식에서 Employee -> User를 찾는 방식으로 변경
*/
        List<Opportunity> updateTargetList = new List<Opportunity>();
        Map<String, String> opptyUpdateMap = new Map<String, String>();
        Set<String> empIdSet = new Set<String>();
        for(Opportunity oppty : objList){            
            if(oppty.ProposalPM__c != null){
                empIdSet.add(oppty.ProposalPM__c);
                opptyUpdateMap.put(oppty.Id, oppty.ProposalPM__c);
                
                updateTargetList.add(oppty);
            }
        }
        
        Map<String, String> empKeyMap = new Map<String, String>();
        Set<String> epIdSet = new Set<String>();
        Set<String> compCodeSet = new Set<String>();
        List<Employee__c> empList = [SELECT Id, Name, EvUniqID__c, EvSapBukrs__c, EvMailAddr__c, Status__c, EvStatus__c FROM Employee__c WHERE Id = :empIdSet];
        if(!empList.isEmpty()){
            for(Employee__c emp : empList){
                if(emp.EvSapBukrs__c != null && emp.EvUniqID__c != null){
                    String key = emp.EvSapBukrs__c + '_' + emp.EvUniqID__c;
                    
                    empKeyMap.put(emp.Id, key);
                    
                    epIdSet.add(emp.EvUniqID__c);
                    compCodeSet.add(emp.EvSapBukrs__c);
                }
            }
        }
        
        Map<String, String> userKeyMap = new Map<String, String>();
        List<User> userList = [SELECT Id, Name, FederationIdentifier, CompanyCode__c, IsActive 
                               FROM User 
                               WHERE FederationIdentifier != null 
                               AND CompanyCode__c != null 
                               AND FederationIdentifier = :epIdSet 
                               AND CompanyCode__c = :compCodeSet];
        if(!userList.isEmpty()){
            for(User user : userList){
                String key = user.CompanyCode__c + '_' + user.FederationIdentifier;
                userKeyMap.put(key, user.Id);
            }
        }
        
        try{
            for(Opportunity oppty : updateTargetList){
                if(opptyUpdateMap.get(oppty.Id) != null){
                    if(empKeyMap.get(opptyUpdateMap.get(oppty.Id)) != null){
                        if(userKeyMap.get(empKeyMap.get(opptyUpdateMap.get(oppty.Id))) != null){
                            oppty.ProposalPM_User__c = userKeyMap.get(empKeyMap.get(opptyUpdateMap.get(oppty.Id)));
                        }
                    }
                }
            }
            update updateTargetList;            // Before 에 수행되기 때문에 불필요한 코드 방지
        }catch(Exception e){
            System.debug('Error Message : ' + e.getMessage());
            System.debug('Error StackTrace : ' + e.getStackTraceString());
            System.debug('Error Line : ' + e.getLineNumber());
        }
    }
    
    
    /**
* @description BO stage를 Identified 단계로 변경시 하위에 Project 코드나 WBS 코드 가 존재하면 메시지 보여주고  저장 불가하도록 로직을 보완.
* @author yeongju.baek@dkbmc.com | 2021-07-06 
* @param List<Opportunity> objList 
**/
    // private Static void closeIdentifiedValidation(List<Opportunity> objList){
    //     Set<String> oppCodeSet = new Set<String>();
    //     for (Opportunity obj : objList) {
    //         oppCodeSet.add(obj.id); 
    //     }
    
    //     Map<String,Integer> pjtMap = getPjtInfo(oppCodeSet);
    //     for(Opportunity oppty : objList){
    //         Opportunity oldOppty = trigger.oldmap.get(oppty.id);
    //         if(oldOppty.StageName != oppty.StageName && oppty.StageName == 'Z01'){
    
    //             //생성된 Project가 하나라도 있으면 Stage변경 불가
    //             if(pjtMap.get(oppty.Id) > 0) oppty.addError(System.Label.OPPTY_ERR_008);
    //         }
    //     }
    // }
    
    /**
* @description Opportunity 하위 Project정보 조회
* @author seonju.jin@dkbmc.com | 2021-07-06 
* @param Set<String> opptyIdSet 
* @return Map<String, Integer> String: Opportunity RecordId, Project cnt
**/
    private static Map<String,Integer> getPjtInfo(Set<String> opptyIdSet){
        Map<String,Integer> pjtMap = new Map<String,Integer>();
        
        //init map
        for(String id: opptyIdSet){ pjtMap.put(id,0);}
        
        for(AggregateResult agg : [SELECT Opportunity__c ,Count(Id) pjtCnt FROM Project__c WHERE Opportunity__c IN :opptyIdSet GROUP BY Opportunity__c]){
            String oppty = String.valueOf(agg.get('Opportunity__c'));
            Integer pjtCnt = Integer.valueOf(agg.get('pjtCnt'));
            
            pjtMap.put(oppty,pjtCnt);
        }
        
        return pjtMap;
    }
    //MYSALES-462 Start V 6.3
    private static Map<String,Integer> getValidPjtInfo(Set<String> opptyIdSet){
        Map<String,Integer> pjtMap = new Map<String,Integer>();
        
        //init map
        for(String id: opptyIdSet){ pjtMap.put(id,0);}
        
        for(AggregateResult agg : [SELECT Opportunity__c ,Count(Id) pjtCnt FROM Project__c WHERE Opportunity__c IN :opptyIdSet AND DeletionFlag__c = FALSE GROUP BY Opportunity__c]){
            String oppty = String.valueOf(agg.get('Opportunity__c'));
            Integer pjtCnt = Integer.valueOf(agg.get('pjtCnt'));
            
            pjtMap.put(oppty,pjtCnt);
        }
        
        return pjtMap;
    }
    //MYSALES-462 End V 6.3
    
    /* 
1. 사업기회의 Stage가 Closed/Won인 경우 아래 필드 수정 불가능 (단, Admin은 제외)
- 수주예상일(CloseDate)
- 계약시작일(cRevenueStartDate__c)
- 계약종료일(cRevenueEndDate__c)
- 통화(CurrencyIsoCode)
- 금액(Amount)
- 고객사(AccountId)
- 원청사(cOriginAcc__c)

2. 완결되지 않은 수주품의, 변경품의가 있는 경우 WON으로 Stage변경 불가능 (단, Admin은 제외)
*/
    private static void closedWonValidation(List<Opportunity> objList){
        System.debug('::Inside closedWonValidation::');
        for(Opportunity oppty : objList){
            if(oppty.IsWon && oppty.IsClosed){
                Map<String, String> opptyFieldLabel = Utils.getFieldLabel('Opportunity');
                
                Opportunity oldOppty = trigger.oldmap.get(oppty.id);
                // 1. 수정 불가능 필드 체크
                if(oldOppty.CloseDate != oppty.CloseDate 
                   || oldOppty.cRevenueStartDate__c != oppty.cRevenueStartDate__c
                   || oldOppty.cRevenueEndDate__c != oppty.cRevenueEndDate__c
                   || oldOppty.CurrencyIsoCode != oppty.CurrencyIsoCode
                   || oldOppty.Amount != oppty.Amount
                   || oldOppty.AccountId != oppty.AccountId
                   || oldOppty.cOriginAcc__c != oppty.cOriginAcc__c
                   || oldOppty.CspMspType__c != oppty.CspMspType__c) {
                       if(!oppty.isUpdatedAuto__c) { // Knox 결재 상태 조회, 상신 취소 기능 버튼에서 호출하여 Update하는 경우 통과
                           String cannotChangedFieldLabel = ' ('
                               + (String)opptyFieldLabel.get('CloseDate'.toLowerCase()) + ', '
                               + (String)opptyFieldLabel.get('cRevenueStartDate__c'.toLowerCase()) + ', '
                               + (String)opptyFieldLabel.get('cRevenueEndDate__c'.toLowerCase()) + ', '
                               + (String)opptyFieldLabel.get('CurrencyIsoCode'.toLowerCase()) + ', '
                               + (String)opptyFieldLabel.get('Amount'.toLowerCase()) + ', '
                               + (String)opptyFieldLabel.get('AccountId'.toLowerCase()).removeEndIgnoreCase(' ID') + ', '
                               + (String)opptyFieldLabel.get('cOriginAcc__c'.toLowerCase()) + ', '
                               + (String)opptyFieldLabel.get('CspMspType__c'.toLowerCase())
                               + ')';
                           
                           oppty.addError(System.Label.OPPTY_ERR_005 + cannotChangedFieldLabel); // Closed/Won된 사업기회는 다음 필드를 업데이트 할 수 없습니다. (수주예상일, 계약시작일, 계약종료일, 통화, 금액, 고객사, 원청사)
                       }
                       if(oppty.isUpdatedAuto__c) oppty.isUpdatedAuto__c = false; // flag 초기화
                   }
            }
        }
    }
    
    /**
* Proposal PM (User Lookup) 등록 시 기존 PM User 사업기회 팀 삭제 후 새 PM User 를 사업기회 팀에 추가
*/
    private static void insertOpptyTeamProposalPmUser(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        try {
            Set<String> oldPmUserKeySet = new Set<String>();
            //2022-03-21, Owner 변경시 Proposal PM과 같아지면 TeamMember에서 삭제. 다르면 등록.
            //Set<String> oldOwnerKeySet = new Set<String>();
            
            List<OpportunityTeamMember> deleteOpptyTeamList = new List<OpportunityTeamMember>();
            List<OpportunityTeamMember> insertOpptyTeamList = new List<OpportunityTeamMember>();
            
            if(oldMap != null){
                for(Opportunity oldOppty : oldMap.values()){
                    if(String.isNotBlank(oldOppty.ProposalPM_User__c)) {
                        oldPmUserKeySet.add(oldOppty.Id + '_' + oldOppty.ProposalPM_User__c);                        
                        //
                        //oldOwnerKeySet.add(oldOppty.Id + '_' + oldOppty.OwnerId);
                    }
                }
                
                List<OpportunityTeamMember> otmList = [SELECT   Id, OpportunityId, UserId 
                                                       FROM    OpportunityTeamMember 
                                                       WHERE   OpportunityId IN :newList 
                                                       AND TeamMemberRole = 'Proposal PM'];
                for(OpportunityTeamMember otm : otmList) {
                    String compareKey = otm.OpportunityId + '_' + otm.UserId;
                    if( oldPmUserKeySet.contains(compareKey) ) {
                        deleteOpptyTeamList.add(otm);
                    }
                }
            }
            /*
//2022-03-21, Owner 변경시 Proposal PM과 같아지면 TeamMember에서 삭제. 다르면 등록.
List<OpportunityTeamMember> chkOtmList = [SELECT   Id, OpportunityId, UserId 
FROM    OpportunityTeamMember 
WHERE   OpportunityId IN :newList];
*/
            for(Opportunity newOppty : newList){
                if(String.isNotBlank(newOppty.ProposalPM_User__c)) {    
                    insertOpptyTeamList.add(new OpportunityTeamMember(OpportunityId = newOppty.Id   
                                                                      , UserId = newOppty.ProposalPM_User__c                                                                
                                                                      , TeamMemberRole = 'Proposal PM'  
                                                                      , OpportunityAccessLevel = 'Read'));
                }
                
                /*
if(String.isNotBlank(newOppty.ProposalPM_User__c)
&& String.isNotBlank(newOppty.OwnerId)){
//
System.debug('### newOppty.ProposalPM_User__c ==> ' + newOppty.ProposalPM_User__c);
System.debug('### newOppty.OwnerId ==> '            + newOppty.OwnerId);

if( !newOppty.ProposalPM_User__c.equals(newOppty.OwnerId) ) {   //2022-03-21, Proposal PM 등록/변경시 Owner와 동일하면 TeamMember 등록안함. 다르면 등록

insertOpptyTeamList.add(new OpportunityTeamMember(OpportunityId = newOppty.Id
, UserId = newOppty.ProposalPM_User__c                                                            
, TeamMemberRole = 'Proposal PM'
, OpportunityAccessLevel = 'Read'));
}else {
//
for(OpportunityTeamMember chkOtm : chkOtmList) {
String tmpKey = chkOtm.OpportunityId + '_' + chkOtm.UserId;
if( oldOwnerKeySet.contains(tmpKey) ) {
deleteOpptyTeamList.add(chkOtm);
}
}
}
}
*/
            }
            
            if(deleteOpptyTeamList.size() > 0) delete deleteOpptyTeamList;
            if(insertOpptyTeamList.size() > 0) insert insertOpptyTeamList;
            
        } catch(DmlException e){
            System.debug(' e.getMessage : ' + e.getMessage());
            System.debug(' e.getDMLMessage(0) : ' + e.getDMLMessage(0));
            newList[0].addError(e.getDMLMessage(0));
            
        } catch(Exception e) {
            System.debug(' ex.getMessage : ' + e.getMessage());
            newList[0].addError(e.getMessage());
        }
        
    }
    
    //Added by Anish- v 5.8 (MS-366)
    private static void updateOpptyTeamSalesRepUser(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        try {
            Set<String> oldPmUserKeySet = new Set<String>();
            System.debug('Ani updateOpptyTeamSalesRepUser');
            List<OpportunityTeamMember> deleteOpptyTeamList = new List<OpportunityTeamMember>();
            List<OpportunityTeamMember> insertOpptyTeamList = new List<OpportunityTeamMember>();
            List<Id> collabBOId = new List<Id>();
            for(Opportunity opp : newList){
                if(String.isNotBlank(opp.CollaborationBOId__c) && opp.Collaboration__c){
                    collabBOId.add(opp.CollaborationBOId__c); 
                }
            }
            
            if(oldMap != null){
                for(Opportunity oldOppty : oldMap.values()){
                    if(String.isNotBlank(oldOppty.OwnerId)) {
                        oldPmUserKeySet.add(oldOppty.CollaborationBOId__c + '_' + oldOppty.OwnerId);                        
                    }
                }
                System.debug('oldPmUserKeySet Ani '+ oldPmUserKeySet);
                List<OpportunityTeamMember> otmList = [SELECT   Id, OpportunityId, UserId 
                                                       FROM    OpportunityTeamMember 
                                                       WHERE   OpportunityId IN :collabBOId 
                                                       AND TeamMemberRole = 'Sales Rep'];
                for(OpportunityTeamMember otm : otmList) {
                    String compareKey = otm.OpportunityId + '_' + otm.UserId;
                    System.debug('compareKey Ani '+ compareKey);
                    if( oldPmUserKeySet.contains(compareKey) ) {
                        deleteOpptyTeamList.add(otm);
                        System.debug('deleteOpptyTeamList Ani '+ deleteOpptyTeamList);
                    }
                }
            }
            
            for(Opportunity newOppty : newList){
                if(String.isNotBlank(newOppty.CollaborationBOId__c) && newOppty.Collaboration__c) {
                    insertOpptyTeamList.add(new OpportunityTeamMember(OpportunityId = newOppty.CollaborationBOId__c   
                                                                      , UserId = newOppty.OwnerId                                                                
                                                                      , TeamMemberRole = 'Sales Rep'  
                                                                      , OpportunityAccessLevel = 'Read'));
                    insertOpptyTeamList.add(new OpportunityTeamMember(OpportunityId = newOppty.Id   
                                                                      , UserId = newOppty.PM_Owner__c                                                                
                                                                      , TeamMemberRole = 'Sales Rep'  
                                                                      , OpportunityAccessLevel = 'Read'));
                }
            }
            
            System.debug('Ani deleteOpptyTeamList' + deleteOpptyTeamList);
            System.debug('Ani insertOpptyTeamList' + insertOpptyTeamList);
            if(deleteOpptyTeamList.size() > 0) delete deleteOpptyTeamList;
            if(insertOpptyTeamList.size() > 0) insert insertOpptyTeamList;
            
        } catch(DmlException e){
            System.debug(' e.getMessage : ' + e.getMessage());
            System.debug(' e.getDMLMessage(0) : ' + e.getDMLMessage(0));
            newList[0].addError(e.getDMLMessage(0));
            
        } catch(Exception e) {
            System.debug(' ex.getMessage : ' + e.getMessage());
            newList[0].addError(e.getMessage());
        }
        
    }
    
    /**
* @description  Amount History [AFTER TRIGGER] UPSERT Opportunity_AmountHistory__c
수주품의 결재 후 IF-093 받은 정보에서 Opportunity를 업데이트 치기 전까지(업데이트 여부 : IsUpdatedByIf093__c) Opportunity Amount History Object Amount 첫번째 행을 생성/수정
* @author       hj.lee@dkbmc.com | 2021-05-28
* @param        newList 
* @param        oldMap 
**/
    private static void upsertOpportunityAmountHistory(List<Opportunity> newList, Map<Id, Opportunity> oldMap){
        List<Opportunity_AmountHistory__c> opptyAmountHistoryList = new List<Opportunity_AmountHistory__c>();
        
        for(Opportunity newOppty : newList) {
            Boolean isChangedAmount = false;
            
            if(oldMap == null) { // Insert
                isChangedAmount = true;
                
            } else { // Update
                Opportunity oldOppty = oldMap.get(newOppty.Id);
                // IF-093 에서 기회 업데이트 전, CloseDate, Amount, Stage, CurrencyIsoCode이 바뀐 경우 Upsert Amount History
                if(!newOppty.IsUpdatedByIf093__c && (oldOppty.CloseDate != newOppty.CloseDate 
                                                     || oldOppty.Amount != newOppty.Amount 
                                                     || oldOppty.StageName != newOppty.StageName
                                                     || oldOppty.CurrencyIsoCode != newOppty.CurrencyIsoCode)) {
                                                         isChangedAmount = true;
                                                     }
            }
            
            if(isChangedAmount) {
                Opportunity_AmountHistory__c opptyAmountHistory = new Opportunity_AmountHistory__c(
                    Opportunity__c      = newOppty.Id
                    , FK__c             = newOppty.Id   // External Key Oppty Id
                    , CloseDate__c      = newOppty.CloseDate
                    , Stage__c          = newOppty.StageName
                    , Amount_Old__c     = 0             // FIX
                    , Amount_New__c     = newOppty.Amount
                    , CurrencyIsoCode   = newOppty.CurrencyIsoCode
                );
                opptyAmountHistoryList.add(opptyAmountHistory);
            }
        }
        
        if(opptyAmountHistoryList.size() > 0) UPSERT opptyAmountHistoryList FK__c;
        
    }
    
    /**
* @description Stage Drop, Lost인 경우 CloseReason 체크
* @author seonju.jin@dkbmc.com | 2021-06-04 
* @param List<Opportunity> newList 
**/
    // private static void checkCloseReason(List<Opportunity> newList){
    //     Set<String> OPP_STAGE_CLOSED_SET = new Set<String> { 
    //         OPP_STAGE_LOST,
    //         OPP_STAGE_DROP
    //     };
    //     for(Opportunity oppty : newList){
    //         if(OPP_STAGE_CLOSED_SET.contains(oppty.StageName)){
    //             if(String.isEmpty(oppty.LostReasonLogistics__c)){
    //                 if(!Test.isRunningTest()) oppty.addError(System.Label.OPPTY_ERR_006);  //Please enter Close Reason.
    //             } 
    //         }
    //     }
    // }
    
    /**
* @description 본사 사업기회 teamMember 자동추가
* @author seonju.jin@dkbmc.com | 2021-06-29 
* @param List<Opportunity> newOpptyList 
**/
    /* public static void syncHQOpptyTeamMember(List<Opportunity> newOpptyList){
Set<Id> opptyIdSet = new Set<Id>();
for(Opportunity oppty : newOpptyList){
if(oppty.Collaboration__c && oppty.CompanyCode__c != 'T100'){    //협업 사업기회(법인,자회사)
opptyIdSet.add(oppty.Id);
opptyIdSet.add(oppty.CollaborationBOId__c);
}
}

if(opptyIdSet.size() > 0){
Map<Id, Opportunity> opptyMap = new Map<Id, Opportunity>(
[SELECT Id, Name, OwnerId, CollaborationBOId__c, CompanyCode__c 
,(SELECT Id, OpportunityId, UserId, Name, PhotoUrl, Title, TeamMemberRole, OpportunityAccessLevel, SystemModstamp, IsDeleted, ExternalId__c FROM OpportunityTeamMembers)
FROM Opportunity WHERE Id IN :opptyIdSet ]
);

List<OpportunityTeamMember> addTeamMemberList = new List<OpportunityTeamMember>();
for(Id id: opptyMap.keySet()){
Opportunity oppty =  opptyMap.get(id);
Id collaboBoId = oppty.CollaborationBOId__c;        //협업 ID
Boolean isHQ = (oppty.CompanyCode__c == 'T100');    //법인, 본사 여부
System.debug('#CoallboInfo - isHQ:' + isHQ + ', CollaboId:' + collaboBoId);

Opportunity hqOppty = opptyMap.get(collaboBoId);    //본사 Opportunity

List<OpportunityTeamMember> teamList = (List<OpportunityTeamMember>) oppty.OpportunityTeamMembers;  //법인 TeamMemberList
List<OpportunityTeamMember> hqTeamList = (List<OpportunityTeamMember>) hqOppty.OpportunityTeamMembers;  //본사 TeamMemberList

//본사, 협업 Opportunity TeamMember 비교
Boolean hasTeamMem = false;
for(OpportunityTeamMember team: teamList){
for(OpportunityTeamMember hqTeam: hqTeamList){
if(team.UserId == hqTeam.UserId || team.UserId == hqOppty.OwnerId){
hasTeamMem = true;
break;
}
}

if(!hasTeamMem){        //본사 사업기회팀에 없는 경우 팀멤버 추가
OpportunityTeamMember addNewTeam = (OpportunityTeamMember)team.clone();
addNewTeam.OpportunityId = hqOppty.Id;
addTeamMemberList.add(addNewTeam);
}
}
}

insert addTeamMemberList;
}
} */
    
    // 2021-07-12 / YoungHoon.Kim / 사업기회 Stage가 최초로 Won이 되는 날짜를 한번만 세팅 / 사업기회 Stage 전환 소요시간과 사전영업 단계별 전환 비율을 측정하기 위함
    // 2022-01-14 / YoungHoon.Kim / CloseDate가 미래일자인 경우 오늘날짜가 입력되도록 수정
    private static void set1stCloseDate(List<Opportunity> objList){
        for(Opportunity oppty : objList){
            if(oppty.RecordTypeId == RT_OPPTY_HQ_ID) { // HQ 사업기회만 First Clost Date를 입력
                // if(oppty.StageName == OPP_STAGE_WON && oppty.FirstCloseDate__c == null && oppty.CloseDate <= Date.today()){
                //     oppty.FirstCloseDate__c = oppty.CloseDate != null ? oppty.CloseDate : Date.today();
                // }
                // 
                /*
if(oppty.StageName == OPP_STAGE_WON && oppty.FirstCloseDate__c == null){
if(oppty.CloseDate >= Date.today()){ // 예상수주일자가 미래날짜인 경우
oppty.FirstCloseDate__c = Date.today();
}else{ // 예상수주일자가 미래날짜가 아닌경우
oppty.FirstCloseDate__c = oppty.CloseDate != null ? oppty.CloseDate : Date.today();
}
}
*/
            }            
        }
    }
    
    
    /**
* @description 스테이지 변경 체크 (Stage 변경 시 KnoxApproval 완결건 있는지 체크)
* @author seonju.jin@dkbmc.com | 2021-07-26 
* @param List<Opportunity> objList 
**/
    private static void checkChangeStage(List<Opportunity> objList){
        system.debug('checkChangeStage');
        // closeIdentifiedValidation(Trigger.new);
        
        List<Opportunity> opptyHQList = new List<Opportunity>();        // IT 사업기회 리스트
        Set<String> opptyIdSet = new Set<String>();
        List<Opportunity> opptyLogiList = new List<Opportunity>();      // 물류 사업기회 리스트
        Set<String> opptyLogiIdSet  = new Set<String>();
        Map<Id, Integer> opptyApprCntMap = new Map<Id, Integer>();      //사업기회별 녹스결재 갯수
        for(Opportunity oppty : objList){
            //if(oppty.RecordTypeId == RT_OPPTY_LOGISTICS_ID) continue;   //물류 사업기회는 결재 체크 제외
            if(oppty.RecordTypeId == RT_OPPTY_HQ_ID){
                opptyHQList.add(oppty);
                opptyIdSet.add(oppty.Id);
                opptyApprCntMap.put(oppty.Id,0);                            // Map 초기화
            }else if(oppty.RecordTypeId == RT_OPPTY_LOGISTICS_ID){
                opptyLogiList.add(oppty);
                opptyLogiIdSet.add(oppty.Id);
            }
        }
        
        //HQ 사업기회 Stage check
        if(opptyHQList.size() > 0){
            Set<String> APPROVAL_CMPL_STATUS_SET = new Set<String> { 
                KnoxApprovalHelper.KNOX_APPROVAL_STATUS_COMPLETED,
                    KnoxApprovalHelper.KNOX_APPROVAL_STATUS_ARBITRARY_CONFIRMED,
                    KnoxApprovalHelper.KNOX_APPROVAL_STATUS_AFTER_CONFIRMED
                    };
                        
                        Map<String,Integer> pjtMap = getPjtInfo(opptyIdSet);
            
            //결재 데이터 조회
            List<KnoxApproval__c> apprList = [SELECT Id, Name, RecordTypeId, Opportunity__c, Status__c, CreatedDate, OpportunityActivity__c, ActivityTransactionName__c 
                                              FROM KnoxApproval__c WHERE Opportunity__c =: opptyIdSet
                                              AND OpportunityActivity__c != null
                                              AND Status__c NOT IN('')
                                              /* AND ( Status__c = :KnoxApprovalHelper.KNOX_APPROVAL_STATUS_COMPLETED
OR Status__c = :KnoxApprovalHelper.KNOX_APPROVAL_STATUS_ARBITRARY_CONFIRMED
OR Status__c = :KnoxApprovalHelper.KNOX_APPROVAL_STATUS_AFTER_CONFIRMED
) */
                                              ORDER BY Opportunity__c, ActivityTransactionName__c];
            
            List<KnoxApproval__c> apprCmplList = new List<KnoxApproval__c>();
            for(KnoxApproval__c appr: apprList){
                if(APPROVAL_CMPL_STATUS_SET.contains(appr.Status__c)) apprCmplList.add(appr);       //전결, 완결, 후완결 데이터
                
                Integer opptyApprCnt = (opptyApprCntMap.get(appr.Opportunity__c) == null) ? 0 : opptyApprCntMap.get(appr.Opportunity__c);
                opptyApprCntMap.put(appr.Opportunity__c, ++opptyApprCnt);
            }
            
            system.debug(opptyApprCntMap);
            
            // 완결되지 않은 품의가 있는 경우 WON, Lost ,Drop으로 Stage변경 불가능
            for(Opportunity oppty : opptyHQList){
                Opportunity oldOppty = trigger.oldmap.get(oppty.id);
                
                system.debug('checkChangeStage-old stage:' + oldOppty.StageName);
                system.debug('checkChangeStage-new stage:' + oppty.StageName);
                if(oldOppty.StageName == oppty.StageName) continue;                                 // 스테이지 변경 아닌 사업기회 제외
                
                Boolean changeZ01 = (oldOppty.StageName != oppty.StageName && oppty.StageName == 'Z01'); // Identified
                Boolean changeZ05 = (oldOppty.StageName != oppty.StageName && oppty.StageName == 'Z05'); // Won
                Boolean changeZ06 = (oldOppty.StageName != oppty.StageName && oppty.StageName == 'Z06'); // Lost
                Boolean changeZ07 = (oldOppty.StageName != oppty.StageName && oppty.StageName == 'Z07'); // Drop
                Boolean changeZ08 = (oldOppty.StageName != oppty.StageName && oppty.StageName == 'Z08'); // Cleansed
                
                System.debug('changeZ01:' + changeZ01);
                System.debug('changeZ05:' + changeZ05);
                System.debug('changeZ06:' + changeZ06);
                System.debug('changeZ07:' + changeZ07);
                System.debug('changeZ08 : ' + changeZ08);
                System.debug('isAdminProfile : ' + isAdminProfile);
                
                if(!(changeZ01 || changeZ05 || changeZ06 || changeZ07 || changeZ08)) continue;      //stage change가 일어나지 않으면 pass
                
                if(changeZ01){
                    //생성된 Project가 하나라도 있으면 Stage변경 불가
                    if(pjtMap.get(oppty.Id) > 0) oppty.addError(System.Label.OPPTY_ERR_008);
                }else if(changeZ08){
                    // 일반 사용자 변경 불가
                    if(!isAdminProfile) if(!Test.isRunningTest()) oppty.addError(System.Label.OPPTY_ERR_009); // Cleansed 단계는 관리자만 변경 가능합니다.
                }else{
                    //2021.08.19 결재상신 시, Amount가 0인 경우 Lost로 스테이지 변경체크 제외
                    //if(changeZ06 && oppty.Amount == 0){
                    //2022-06-10, hyunhak.roh@dkbmc.com, 결재상신 시, Amount가 0인 경우 Drop 스테이지 변경체크 제외
                    if(changeZ07 && oppty.Amount == 0){
                        system.debug('changez07,' + opptyApprCntMap.get(oppty.Id));
                        if(opptyApprCntMap.get(oppty.Id) > 0) continue;
                    }
                    
                    //전결, 완결, 후완결 결재 체크
                    List<KnoxApproval__c> opptyApprovalList = new List<KnoxApproval__c>();
                    for(KnoxApproval__c approval : apprCmplList){
                        if(approval.Opportunity__c == oppty.Id){
                            opptyApprovalList.add(approval);
                        }
                    }
                    system.debug('### opptyApprovalList = ' + opptyApprovalList);
                    //set Stage Name
                    String stage = '';
                    if(oppty.StageName == OpportunityActivityHelper.OPP_STAGE_WON) stage = 'Won';
                    else if(oppty.StageName == OpportunityActivityHelper.OPP_STAGE_LOST) stage = 'Lost';
                    else if(oppty.StageName == OpportunityActivityHelper.OPP_STAGE_DROP) stage = 'Drop';
                    
                    if(opptyApprovalList.size() == 0){  //전결, 완결, 후완결 결재이력 없음                        
                        //CSP/MSP Type이 CSP/MSP인 경우, 수주품의 없어도 WON으로 Stage 변경 가능. 그외 변경불가.
                        if(oppty.StageName == OpportunityActivityHelper.OPP_STAGE_WON){
                            if(!OPP_CMSP_TYPE.contains(oppty.CspMspType__c)){
                                if(!Test.isRunningTest()) oppty.addError(String.format( System.Label.OPPTY_ERR_007, new List<String>{stage}));
                            }else{//CSP/MSP 값 존재, WON으로 변경시 필수 값 없으면 에러발생.
                                // 2022-08-02 MSP 수주금액필드 추가.
                                if((String.isBlank(oppty.CMBizType__c) || String.isBlank(oppty.ConversionType__c))||(oppty.CspMspType__c == 'MSP' && oppty.MSP_Amount__c == null)){
                                    if(!Test.isRunningTest()) oppty.addError(String.format( System.Label.OPPTY_ERR_017, new List<String>{stage}));
                                }
                            }
                        }else{
                            if(!Test.isRunningTest()) oppty.addError(String.format( System.Label.OPPTY_ERR_007, new List<String>{stage}));
                        }                        
                    }else{
                        Boolean findApproval = false;
                        for(KnoxApproval__c approval : opptyApprovalList){
                            if(changeZ05 && approval.ActivityTransactionName__c == OpportunityActivityHelper.ACT_CODE_CONTRACT_APPROVAL){
                                //전결, 완결, 후완결 녹스 결재 중 'ZP82' 데이터가 있으면 WON으로 변경 가능
                                findApproval = true;
                                break;
                            }
                            
                            if(changeZ06 && approval.ActivityTransactionName__c == OpportunityActivityHelper.ACT_CODE_LOST_OPPORTUNITY){
                                //전결, 완결, 후완결 녹스 결재 중 'ZPZ1' 데이터가 있으면 Lost으로 변경 가능
                                findApproval = true;
                                break;
                            }
                            
                            if(changeZ07 && approval.ActivityTransactionName__c == OpportunityActivityHelper.ACT_CODE_DROP_OPPORTUNITY){
                                //전결, 완결, 후완결 녹스 결재 중 'ZPZ2' 데이터가 있으면 Drop으로 변경 가능
                                findApproval = true;
                                break;
                            }
                        }
                        system.debug('### findApproval = ' + findApproval);
                        
                        if(!findApproval){
                            if(!Test.isRunningTest()) oppty.addError(String.format( System.Label.OPPTY_ERR_007, new List<String>{stage})); // 품의를 완료하지않은 사업기회는 Won 단계로 변경할 수 없습니다.
                        }
                    }
                }
            }
        }
        
        //Logistics Won Stage check - 2021.12.21 LBS 예외 유형(LBS Exception Type) 필드 속성에 따른 Won 단계 변경시 체크 로직 추가
        if(opptyLogiList.size() > 0){
            List<LBS__c> lbsList = [SELECT Id, LBSStatus__c, Opportunity__c FROM LBS__c WHERE Opportunity__c IN :opptyLogiIdSet AND Opportunity__r.LBSExceptionType__c IN ('01','08') AND LBSStatus__c = 'CMPT'];
            Set<Id> lbsOpptyIdSet = new Set<Id>();
            for(LBS__c lbs: lbsList){
                lbsOpptyIdSet.add(lbs.Opportunity__c);
            }
            
            List<ContentDocumentLink> docList = [ SELECT LinkedEntityId , ContentDocumentId FROM ContentDocumentLink  WHERE LinkedEntityId IN :opptyLogiIdSet];
            Set<Id> docOpptyIdSet = new Set<Id>();
            for(ContentDocumentLink document: docList){
                docOpptyIdSet.add(document.LinkedEntityId);
            }
            
            /**
N/A - 01
Origin Nomi - 05
Small & Spot Forwarding - 07
Medium-sized Forwarding - 08
*/
            for(Opportunity oppty : opptyLogiList){
                Opportunity oldOppty = trigger.oldmap.get(oppty.id);
                Boolean changeZ05 = (oldOppty.StageName != oppty.StageName && oppty.StageName == 'Z05');    // Won단계 변경 여부
                
                if(!changeZ05) continue;        //Won 단계 변경시에만 체크
                /**START V4.5 - Change by Kajal**/
                if(oppty.LBSExceptionType__c == '05' || oppty.LBSExceptionType__c == '07'){
                    system.debug('Entry@@1*');
                    if((oppty.type == '01' || oppty.type == '02') && 
                       (oppty.LogisticsBizDevelopmentType__c =='10' || oppty.LogisticsBizDevelopmentType__c == '09' || oppty.LogisticsBizDevelopmentType__c == '06'|| 
                        oppty.LogisticsBizDevelopmentType__c =='04')
                      ){
                          system.debug('Entry@@2*');
                          if(!(oppty.Opportunity_Logistics_CPReviewStatus_FIN__c == 'CNFM' && 
                               (oppty.Opportunity_Logistics_CPReviewResult_FIN__c == 'A' || oppty.Opportunity_Logistics_CPReviewResult_FIN__c == null) ) ){
                                   system.debug('Entry@@3*');
                                   oppty.addError(System.Label.OPPTY_ERR_20);
                               }
                      }
                }
                
                //if(oppty.LBSExceptionType__c == '05') continue;                                 //Case3. Origin Nomi : 제한 없음
                /**STOP V4.5 - Change by Kajal**/
                if(oppty.LBSExceptionType__c == '01' || oppty.LBSExceptionType__c == '08'){     //Case1. Meduim-sized Forwarding 과 N/A(LBS 대상 사업들)
                    if(!lbsOpptyIdSet.contains(oppty.Id)){                                      //Final LBS가 완료된 사업만 수주 완료처리로 변경 가능
                        oppty.addError(System.Label.OPPTY_ERR_012);
                    }
                }else if(oppty.LBSExceptionType__c == '07'){                                    //Case2. 해당 사업기회 내에 첨부파일이 등록되어 있어야만 수주 단계로 변경 가능
                    if(!docOpptyIdSet.contains(oppty.Id)){                                      //첨부파일이 등록되어 있어야만 수주 단계로 변경 가능
                        oppty.addError(System.Label.OPPTY_ERR_013);
                    }
                }
            }
        }
    }
    
    
    private static void sendOwnerChangeKnoxEmail(List<Opportunity> newList, List<Opportunity> oldObjList){
        
        //Email : Template조회
        EmailTemplate emailTemplate = getEmailTemplate('Opportunity_Owner_Change_Email');
        List<KnoxEmail__c> KnoxEmailList = new List<KnoxEmail__c>();
        
        for(Opportunity opportunity : newList){
            Map<Id, Opportunity> oldMap = new Map<Id,Opportunity>(oldObjList);
            Set<String> ownerIdSet = new Set<String>();
            ownerIdSet.add( oldMap.get(opportunity.Id).ownerId);
            ownerIdSet.add(opportunity.ownerId);
            String oldOwnerId = oldMap.get(opportunity.Id).ownerId;
            String newOwnerId = opportunity.ownerId;
            System.debug('oldOwnerId : ' + oldOwnerId);
            System.debug('newOwnerId : ' + newOwnerId);
            
            Boolean isOwnerChange = (oldOwnerId != newOwnerId);
            System.debug('isOwnerChange : ' + isOwnerChange);
            
            String OpportunityName = opportunity.Name;
            String OpportunityCode = opportunity.OpportunityCode__c;
            String OpportunityBeforeOwner = '';
            String OpportunityAfterOwner = '';
            String OpportunityDescription = opportunity.Description;
            Datetime modifyDate = opportunity.LastModifiedDate;
            String OpportunityCahngeDate = modifyDate.format('yyyy-MM-dd a HH:mm:ss');
            
            String oldOwnerEmail = '';
            String oldOwnerEpId = '';
            String newOwnerEmail = '';
            String newOwnerEpId = '';
            String systemEmail   = '';
            String systemId = '';
            String subject = String.valueOf(emailTemplate.Subject);
            String LinkAddress = '';
            
            //------------------------------------------------------------------------------------------
            //Owner가 변경되었으면 Knox Email을 발송
            if(isOwnerChange || test.isRunningTest()) { 
                Boolean isSandbox = Utils.getIsSandbox();
                List<User> ownerUserList = new List<User>();
                for(String ownerId : ownerIdSet){
                    ownerUserList.add(getUser(ownerId));
                }
                User oldUser = getUser(oldOwnerId);
                Employee__c oldEmployee = oldUser.FederationIdentifier != '' ? Utils.getEmployeeData(oldUser.FederationIdentifier) : null;
                User newUser = getUser(newOwnerId);
                Employee__c newEmployee = newUser.FederationIdentifier != '' ? Utils.getEmployeeData(newUser.FederationIdentifier) : null;
                Employee__c senderEmployee;
                OpportunityBeforeOwner = oldUser.LastName + oldUser.FirstName;
                if(oldEmployee != null) oldOwnerEmail          = oldEmployee.EvMailAddr__c;
                oldOwnerEpId           = oldUser.FederationIdentifier;
                OpportunityAfterOwner  = newUser.LastName + newUser.FirstName;
                if(newEmployee != null) newOwnerEmail          = newEmployee.EvMailAddr__c;
                newOwnerEpId           = newUser.FederationIdentifier;
                
                
                System.debug('### isSandbox : ' + isSandbox);
                
                //QA
                if(isSandbox){
                    systemEmail = 'oldman.sea@stage.samsung.com';
                    systemId    = 'a091s0000035Ax2AAE';
                    //systemId    = 'a0H0p000004w6iHEAQ';
                    LinkAddress = 'https://sdssfa--qa.lightning.force.com/lightning/r/Opportunity/'+opportunity.Id+'/view';
                    
                    // oldOwnerEmail = oldOwnerEmail.replace('@samsung.com', '@stage.samsung.com');
                    // newOwnerEmail = newOwnerEmail.replace('@samsung.com', '@stage.samsung.com');
                    
                    if(String.isNotBlank(oldOwnerEmail)){
                        String oldOwnerMailAddress = oldOwnerEmail.left(oldOwnerEmail.indexOf('@'));
                        oldOwnerEmail = oldOwnerMailAddress + '@stage.samsung.com';
                        System.debug('oldOwnerEmail ### :'+oldOwnerEmail);
                    }
                    if(String.isNotBlank(newOwnerEmail)){
                        String newOwnerMailAddress = newOwnerEmail.left(newOwnerEmail.indexOf('@'));
                        newOwnerEmail = newOwnerMailAddress + '@stage.samsung.com';
                        System.debug('newOwnerEmail ### :'+newOwnerEmail);
                    }
                }
                //REAL
                else{
                    systemEmail = 'mysales@samsung.com';
                    LinkAddress = 'https://sdssfa.lightning.force.com/lightning/r/Opportunity/'+opportunity.Id+'/view';
                    
                    List<User> userList = [SELECT Id, Name From User WHERE Username = :systemEmail];
                    if(userList.size() > 0)
                        senderEmployee = Utils.getLoginEmployeeData(userList.get(0).Id);
                    if(senderEmployee != null) 
                        systemId = senderEmployee.Id;
                }
                
                //------------------------------------------------------------------------------------------
                //Email : 본문 가져와서 처리
                String body = String.valueOf(emailTemplate.HtmlValue).replace('\r\n', '');
                if (OpportunityName==null) OpportunityName = '';
                if (OpportunityBeforeOwner==null) OpportunityBeforeOwner = '';
                if (OpportunityAfterOwner==null) OpportunityAfterOwner = '';
                if (OpportunityDescription==null) OpportunityDescription = '';
                if (OpportunityCahngeDate==null) OpportunityCahngeDate = '';
                body = body.replace('{!BusinessOpportunityName}'       , OpportunityName);
                body = body.replace('{!BusinessOpportunityCode}'       , OpportunityCode);
                body = body.replace('{!BusinessOpportunityBeforeOwner}', OpportunityBeforeOwner);
                body = body.replace('{!BusinessOpportunityAfterOwner}' , OpportunityAfterOwner);
                body = body.replace('{!BusinessOpportunityDescription}', OpportunityDescription);
                body = body.replace('{!BusinessOpportunityCahngeDate}' , OpportunityCahngeDate);
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
                bodyMap.sfdcId = opportunity.Id;
                bodyMap.recipients = recipientsList;
                bodyMap.sender = sender;
                bodyMap.isMulti = true;
                Map<String,Object> resMap = new Map<String,Object>();
                Map<String,Object> response = new Map<String, Object>();
                
                IF_KnoxEmailSendController.send2(JSON.serialize(bodyMap));
                system.debug('### OpportunityTrigger :: systemId = '+systemId);
                
                KnoxEmail__c knoxemail = new KnoxEmail__c(
                    RecordId__c = opportunity.Id
                    , Sender__c = systemId
                    , ToAddress__c = String.join(toList, ',')
                    , Name = subject
                    , HtmlBody__c = OpportunityDescription
                    , MailId__c = systemEmail
                    , Status__c = 'Send'
                );
                knoxemailList.add(knoxemail);
                
            }
            //------------------------------------------------------------------------------------------
        }//end of for
        system.debug('### OpportunityTrigger :: knoxemailList = ' + knoxemailList);
        
        insert knoxemailList;
    }   
    
    //User 정보 조회
    private static User getUser(String userId){
        User returnUser = [Select Id
                           , LastName
                           , FirstName
                           , Email //knox email address
                           , FederationIdentifier
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
    //     List<Employee__c> empList = [SELECT Id, 
    //                                         EvUniqID__c, 
    //                                         EvMailAddr__c 
    //                                    FROM Employee__c 
    //                                   WHERE EvUniqID__c = :FederationIdentifier
    //                                   LIMIT 1];
    //     if(empList.size() > 0) return empList[0];
    //     else return null;
    // }
    
    
    
    //BO Owner변경시 Knox 공지 Chat(AppCard) 전송
    public static void sendOwnerChangeKnoxChat(List<Opportunity> newList, List<Opportunity> oldObjList){
        
        List<KnoxEmail__c> KnoxEmailList = new List<KnoxEmail__c>();
        for(Opportunity opportunity : newList){
            Map<Id, Opportunity> oldMap = new Map<Id,Opportunity>(oldObjList);
            Set<String> ownerIdSet = new Set<String>();
            ownerIdSet.add( oldMap.get(opportunity.Id).ownerId);
            ownerIdSet.add(opportunity.ownerId);
            String oldOwnerId = oldMap.get(opportunity.Id).ownerId;
            String newOwnerId = opportunity.ownerId;
            System.debug('oldOwnerId : ' + oldOwnerId);
            System.debug('newOwnerId : ' + newOwnerId);
            Boolean isOwnerChange = (oldOwnerId != newOwnerId);
            System.debug('isOwnerChange : ' + isOwnerChange);
            String OpportunityName = opportunity.Name;
            String OpportunityCode = opportunity.OpportunityCode__c;
            String OpportunityBeforeOwner = '';
            String OpportunityAfterOwner = '';
            String OpportunityDescription = opportunity.Description;
            Datetime modifyDate = opportunity.LastModifiedDate;
            String OpportunityCahngeDate = modifyDate.format('yyyy-MM-dd a HH:mm:ss');
            
            String oldOwnerEmail = '';
            String oldOwnerSingleId = '';
            String newOwnerEmail = '';
            String newOwnerSingleId = '';
            String systemId = '';
            String LinkAddress = '';
            //------------------------------------------------------------------------------------------
            //Owner가 변경되었으면 Knox Chat을 발송
            if(isOwnerChange || test.isRunningTest()) { 
                system.debug('### OpportunityTrigger :: sendOwnerChangeKnoxChat :: Owner Change');
                Boolean isSandbox = Utils.getIsSandbox();
                List<User> ownerUserList = new List<User>();
                for(String ownerId : ownerIdSet){
                    ownerUserList.add(getUser(ownerId));
                }
                User oldUser = getUser(oldOwnerId);
                Employee__c oldEmployee = oldUser.FederationIdentifier != '' ? Utils.getEmployeeData(oldUser.FederationIdentifier) : null;
                User newUser = getUser(newOwnerId);
                Employee__c newEmployee = newUser.FederationIdentifier != '' ? Utils.getEmployeeData(newUser.FederationIdentifier) : null;
                Employee__c senderEmployee;
                OpportunityBeforeOwner = oldUser.LastName + oldUser.FirstName;
                if(oldEmployee != null) oldOwnerEmail          = oldEmployee.EvMailAddr__c;
                OpportunityAfterOwner  = newUser.LastName + newUser.FirstName;
                if(newEmployee != null) newOwnerEmail          = newEmployee.EvMailAddr__c;
                
                systemId = 'mysales';
                if(String.isNotBlank(oldOwnerEmail)){
                    oldOwnerId = oldOwnerEmail.left(oldOwnerEmail.indexOf('@'));
                }
                if(String.isNotBlank(newOwnerEmail)){
                    newOwnerId = newOwnerEmail.left(newOwnerEmail.indexOf('@'));
                }
                //QA
                if(isSandbox){
                    LinkAddress = 'https://sdssfa--qa.lightning.force.com/lightning/r/Opportunity/'+opportunity.Id+'/view';
                }
                //REAL
                else{
                    LinkAddress = 'https://sdssfa.lightning.force.com/lightning/r/Opportunity/'+opportunity.Id+'/view';
                }
                /* ------------------------------------------------------------------------- */
                /* Jitterbit 통해 Knox Rest API 호출 시작 */
                List<String> inputVarList = new List<String>();
                inputVarList.add(oldOwnerId);
                inputVarList.add(newOwnerId);
                inputVarList.add(OpportunityName);
                inputVarList.add(OpportunityCode);
                inputVarList.add(OpportunityBeforeOwner);
                inputVarList.add(OpportunityAfterOwner);
                inputVarList.add(oldOwnerEmail);
                inputVarList.add(newOwnerEmail);
                inputVarList.add(OpportunityCahngeDate);
                inputVarList.add(OpportunityDescription);
                inputVarList.add(LinkAddress);
                IF_KnoxChatSendController.sendBOOwnerChangeChat(inputVarList);
                /* Jitterbit 통해 Knox Rest API 호출 종료*/
                /* ------------------------------------------------------------------------- */                
            }
            //------------------------------------------------------------------------------------------
        }//end of for
    }
    
    public static void checkAmount(List<Opportunity> opptyList){
        for(Opportunity oppty :opptyList){
            if(oppty.Amount < 0){
                oppty.addError(System.Label.OPPTY_ERR_011); //'Please enter an amount greater than 0.'
            }
        }
    }
    
    //Start v-6.0 [MYSALES-416]
    public static void setSuccessProbability(List<Opportunity> opptyList){
        for(Opportunity oppty :opptyList){
            if((!((oppty.Probability_new__c >= 0) && (oppty.Probability_new__c <= 100))) && (oppty.Probability_new__c != null)){
                oppty.addError('Probability_new__c', System.Label.OPPTY_ERR_SUC_PB);
            }//V7.0 Start
            if(!(oppty.RecordTypeId == RT_OPPTY_HQ_ID && oppty.CompanyCode__c == 'T100' && oppty.Collaboration__c == false)){
                if(trigger.isInsert && oppty.Probability_new__c == Null){
                    oppty.Probability_new__c = 10;
                }
                if(oppty.StageName == 'Z05'){
                    oppty.Probability_new__c = 100;
                }
                if(oppty.StageName == 'Z06' || oppty.StageName == 'Z07' || oppty.StageName == 'Z08'){
                    oppty.Probability_new__c = 0;
                }
            }//V7.0 End
        }
    }
    //End v-6.0 [MYSALES-416] 
    //Start v-6.2 MYSALES-452
    public static void setOpportunityCode(List<Opportunity> opptyList){
        //System.debug('SJ Entry'+OpportunityCodeHandler.isFirstTime);
        //OpportunityCodeHandler.isFirstTime = false;
        //System.debug('SJ Exit'+OpportunityCodeHandler.isFirstTime);
        Set<Id> oppIds = new Set<Id>();
        List<Opportunity> updateOppList = new List<Opportunity>();
        List<Opportunity> oppList = new List<Opportunity>();
        //List<Opportunity> oppList = new List<Opportunity>();
        for(Opportunity oppty : opptyList){
            if(oppty.SalesLeadChannel__c == 'Marketing Lead Converted'){
                oppIds.add(oppty.Id);
            }
        }
        
        if(oppIds.size() > 0){
            oppList = new List<Opportunity>([SELECT Id, OpportunityCode__c, Collaboration__c, Auto_OpptyCode__c,SalesLeadChannel__c
                                             FROM Opportunity WHERE Id IN : oppIds]);
        }
        
        for(Opportunity opp : oppList){
            system.debug('salesleadchannelvalue'+opp.SalesLeadChannel__c);
            if(opp.Collaboration__c == false && opp.OpportunityCode__c == null){
                System.debug('SJOSHI TEST2>>'+opp.OpportunityCode__c);
                opp.OpportunityCode__c = 'SDS-'+opp.Auto_OpptyCode__c+'0';
                updateOppList.add(opp);
                System.debug('SJOSHI TEST1>>'+opp.OpportunityCode__c);
            }   
        }
        
        Opportunity_Code_Update_Setting__c oppUpdate = Opportunity_Code_Update_Setting__c.getValues('UpdateOppCode');
        if(!Test.isRunningTest()){
            oppUpdate.Opp_Code_Update__c = false;
            update oppUpdate;
        }
        
        if(updateOppList.size() > 0){
            update updateOppList;
        }
        
        //OpportunityCodeHandler.isFirstTime = true;
        //System.debug('SJ Final Exit'+OpportunityCodeHandler.isFirstTime);
        if(!Test.isRunningTest()){
            oppUpdate.Opp_Code_Update__c = true;
            update oppUpdate;
        }     
    }
    //End v-6.2 MYSALES-452
    
    public static void checkOpportunityInfo(List<Opportunity> opptyList){
        
        for(Opportunity oppty :opptyList){
            // BO 생성시에만 해당함.
            if(oppty.StageName != OpportunityActivityHelper.OPP_STAGE_IDENTIFIED){
                //'생성 시 단계는 Identified만 선택 가능합니다.' (Only 'Identified' can be selected for the Stage.)
                oppty.StageName.addError(System.Label.OPPTY_ERR_020);
            }
        }
    }
    
    /**
* @description 사업기회의 소유자가 변경되는 경우 협업 사업기회 팀멤버 수정
* @author younghoon.kim@dkbmc.com | 2021-11-29 
* @param List<Opportunity> opptyList 
* @param Map<Id Opportunity> oldMap 
**/
    private static void syncTeamMember(List<Opportunity> opptyList, Map<Id, Opportunity> oldMap){
        List<OpportunityTeamMember> deleteOtmList = new List<OpportunityTeamMember>();
        List<OpportunityTeamMember> insertOtmList = new List<OpportunityTeamMember>();
        
        Map<String, String> deleteOtMap = new Map<String, String>();
        Map<String, String> insertOtMap = new Map<String, String>();
        
        for(Opportunity oppty :opptyList){
            // 협업 사업기회 중 영업대표(Owner)가 변경된 경우만 수행
            if(oppty.CollaborationBOId__c != null && oldMap.get(oppty.Id).OwnerId != oppty.OwnerId){
                deleteOtMap.put(oppty.CollaborationBOId__c, oldMap.get(oppty.Id).OwnerId);
                insertOtMap.put(oppty.CollaborationBOId__c, oppty.OwnerId);
            }
        }
        
        List<OpportunityTeamMember> otmList = [SELECT Id, OpportunityId, UserId FROM OpportunityTeamMember WHERE OpportunityId = :insertOtMap.keySet()];
        if(!otmList.isEmpty()){
            for(OpportunityTeamMember otm : otmList){
                // 삭제 대상(기존 소유자)이 존재하는지 체크
                if(deleteOtMap.get(otm.OpportunityId) == otm.UserId){
                    deleteOtmList.add(otm);
                }
                
                // 생성 대상(신규 소유자)중 이미 등록된 대상이 존재하는지 체크
                if(insertOtMap.get(otm.OpportunityId) == otm.UserId){
                    insertOtMap.remove(otm.OpportunityId);
                }
            }
        }
        
        try{
            // 삭제 대상(기존 소유자)이 있는경우
            if(!deleteOtmList.isEmpty()) {
                delete deleteOtmList;
            }
            
            // 생성 대상(신규 소유자)이 있는경우
            if(!insertOtMap.isEmpty()){
                for(String opptyId : insertOtMap.keySet()){
                    OpportunityTeamMember newOtm = new OpportunityTeamMember();
                    newOtm.OpportunityId = opptyId;
                    newOtm.UserId = insertOtMap.get(opptyId);
                    newOtm.TeamMemberRole = 'Sales Rep';
                    
                    insertOtmList.add(newOtm);
                }
                
                if(!insertOtmList.isEmpty()) insert insertOtmList;
            }
        }catch(Exception e){
            System.debug('Error Message : ' + e.getMessage());
            System.debug('Error StackTrace : ' + e.getStackTraceString());
            System.debug('Error Line : ' + e.getLineNumber());
        }
    }
    
    //V4.7- My Sales-110
    public static void CollabBOUpdate(List<Opportunity> objList){
        Set<String> BOSet = new Set<String>();
        for(Opportunity opp : objList){
            if(opp.Collaboration__c == true && (opp.CompanyCode__c == 'T100' || opp.CompanyCode__c == null) && opp.CollaborationInOut__c == 'IN'){
                BOSet.add(opp.OpportunityCode__c);
            }
        }
        
        List<Opportunity> oppList = [Select Id,IsOriginal__c From Opportunity where OpportunityCode__c IN : BOSet 
                                     AND CompanyCode__c != 'T100' AND CollaborationInOut__c = 'OUT'];
        
        Set<Opportunity> updateOppSet = new Set<Opportunity>();
        List<Opportunity> finalOpptyList = new List<Opportunity>();
        for(Opportunity opp : oppList){
            opp.IsOriginal__c = False;
            updateOppSet.add(opp);
        }
        if(updateOppSet.Size()>0){
            finalOpptyList.addAll(updateOppSet);
        }
        
        if(finalOpptyList.size()>0){
            update finalOpptyList;
        }
        
    } 
    
    
    private static void boReviewCheck(List<Opportunity> opptyList, Map<Id, Opportunity> oldMap){
        Boolean isBatch = System.isBatch();
        Map<String, KnoxApproval__c> opptyKnoxMap = new Map<String, KnoxApproval__c>();
        Map<String, KnoxApproval__c> opptyKnoxMapNew = new Map<String, KnoxApproval__c>();
        Map<String, KnoxApproval__c> opptyKnoxMapRBO = new Map<String, KnoxApproval__c>(); //Added by Anish-v 6.1
        Set<String> opptyIdSet = new Set<String>();
        Set<String> BOCodeSet = new Set<String>();
        for(Opportunity oppty : opptyList){ 
            opptyIdSet.add(oppty.Id);
            BOCodeSet.add(oppty.OpportunityCode__c);
        }
        if(!opptyIdSet.isEmpty()){
            //List to get knox approval of Contract Approval.
            List<KnoxApproval__c> knoxList = [SELECT Id, Name, Opportunity__c, Opportunity__r.Name, Opportunity__r.CompanyCode__c, Opportunity__r.OpportunityCode__c, 
                                              OpportunityActivity__c, OpportunityActivity__r.TransactionName__c, OpportunityActivity__r.Status__c, Status__c
                                              FROM KnoxApproval__c 
                                              WHERE Opportunity__c = :opptyIdSet
                                              AND ( OpportunityActivity__r.TransactionName__c = 'ZP82' OR OpportunityActivity__r.TransactionName__c = 'ZP21')
                                              AND Status__c IN ('1','2', '5', '6')]; //Added by Anish-v 6.1
            /** 3.7 ->  Change functionality for Contract/Origin Account change.**/
            if(!knoxList.isEmpty()){
                for(KnoxApproval__c knox : knoxList){
                    if(knox.OpportunityActivity__r.TransactionName__c == 'ZP82'){ //Added by Anish-v 6.1
                        if(knox.Status__c =='2' || knox.Status__c =='5' || knox.Status__c =='6'){
                            opptyKnoxMap.put(knox.Opportunity__c, knox);
                        }
                        if(knox.Status__c =='1' || knox.Status__c =='2' || knox.Status__c =='5' || knox.Status__c =='6')
                            opptyKnoxMapNew.put(knox.Opportunity__c, knox);
                    }
                    if(knox.OpportunityActivity__r.TransactionName__c == 'ZP21'){ //Added by Anish-v 6.1
                        if(knox.Status__c =='1')
                            opptyKnoxMapRBO.put(knox.Opportunity__c, knox);
                        
                    }
                }
            }
            
        }
        /** 3.7 ->  Change functionality for Contract/Origin Account change.**/
        Map<ID,String> oppActMap = new Map<ID,String>();
        if(!opptyIdSet.isEmpty()){
            //2022-06-10, hyunhak.roh@dkbmc.com, Too many SOQL queries: 101
            oppActMap = createOppActivityMap(opptyList,BOCodeSet);
        }
        
        for(Opportunity oppty : opptyList){
            if(!oppty.IsCustom__c && !isBatch){ // 스탠다드에서 수정하는 경우
                System.debug('Change functionality@@@');
                if(oppty.Opportunity_Review_Confirm__c ){
                    if(opptyKnoxMap.get(oppty.Id) == null && oppty.Amount != oldMap.get(oppty.Id).Amount){ // 수주예상금액(Amount) 수정 불가능
                        // v5.0 Avoid custom validation when modifying amount by admin
                        if(!isAdminProfile) oppty.addError('The opportunity review type has been confirmed. To change the amount, change it on the "Review Opportunity - BO Review tab".'); // The opportunity review type has been confirmed. To change the amount, change it on the "Review Opportunity - BO Review tab".
                    }
                    if( oppty.cOriginAcc__c != oldMap.get(oppty.Id).cOriginAcc__c || oppty.AccountId != oldMap.get(oppty.Id).AccountId ){
                        if(oppty.Opportunity_Review_VRB_Type_Confirm__c == '10' || oppty.Opportunity_Review_VRB_Type_Confirm__c == '20' || oppty.Opportunity_Review_VRB_Type_Confirm__c == '21'){
                            if(oppty.Collaboration__c == true && oppty.CompanyCode__c != 'T100'){
                                if(hqMap.containsKey(oppty.OpportunityCode__c) && oppActMap.containsKey(hqMap.get(oppty.OpportunityCode__c)) && oppActMap.get(hqMap.get(oppty.OpportunityCode__c)) == 'Completed'){
                                    oppty.addError(System.Label.OPPTY_ERR_OriginnAccountChange001);
                                }else{
                                    oppty.Is_Change_Account__c = true;
                                }
                            }else if(oppActMap.containsKey(oppty.Id) && oppActMap.get(oppty.Id) == 'Completed'){
                                oppty.addError(System.Label.OPPTY_ERR_OriginnAccountChange001);
                            }else{
                                oppty.Is_Change_Account__c = true;
                            }
                        }else if(oppty.Opportunity_Review_VRB_Type_Confirm__c == '30'){
                            if(opptyKnoxMapNew.get(oppty.Id) != null){
                                oppty.addError(System.Label.OPPTY_ERR_OriginnAccountChange002);
                            }
                            if(opptyKnoxMapRBO.get(oppty.Id) != null){ //Added by Anish-v 6.1
                                oppty.addError(System.Label.OPPTY_ERR_OriginnAccountChange003);
                            }
                            else{
                                oppty.Is_Change_Account__c = true;
                            }
                        }else{
                            System.debug('Change functionality@@@');
                            oppty.Is_Change_Account__c = true;
                        }
                    }
                    /** START -> 3.7 ->  Change functionality for Contract/Origin Account change.**/
                }
            }else{ // 커스텀에서 수정하는 경우
                oppty.IsCustom__c = false;
            }
        }
    }
    /** 3.7 ->  Change functionality for Contract/Origin Account change.**/
    // It returns map which contains Opportunity_Activity__c of Request participation committee type.
    private static Map<ID,STRING> createOppActivityMap(List<Opportunity> oppList,Set<String> BOCodeSet){
        hqMap = createHQOppActivityMap(BOCodeSet);
        Set<ID> opIDSet = new Set<ID>();
        for(Opportunity opp:oppList){
            if(opp.Collaboration__c == true && opp.CompanyCode__c != 'T100'){
                ID hqID = hqMap.get(opp.OpportunityCode__c);
                opIDSet.add(hqID);
            }else{
                opIDSet.add(opp.ID);
            }
        }
        
        Map<ID,string> opActMap = new Map<ID, String>();
        List<Opportunity_Activity__c> opActList = [Select WhatID__c,status__c from Opportunity_Activity__c where WhatID__c IN: opIDSet AND TransactionName__c = 'XP61'];
        for(Opportunity_Activity__c opAct : opActList){
            opActMap.put(opAct.WhatID__c,opAct.status__c);
        }
        
        return opActMap;
    }
    //Function to return Map having HQ code and ID basically in case of collaboration BO.
    private static Map<STRING,ID> createHQOppActivityMap(Set<String> BOCodeSet){
        List<Opportunity> HQLIST = [Select id,OpportunityCode__c from Opportunity where CompanyCode__c = 'T100' AND Collaboration__c = TRUE AND OpportunityCode__c IN: BOCodeSet];
        Map<String,ID> hqMap1 = new Map<String,ID>();
        for(Opportunity HQ:HQLIST){
            hqMap1.put(HQ.OpportunityCode__c,HQ.ID);
        }
        return hqMap1;
    }
    //2022-06-16, hyunhak.roh@dkbmc.com, 사업리드 Converted BO가 삭제 시 해당 사업리드 단계를 되돌리는 로직 추가
    private static void saveSalesLeadConvertedBO(List<Opportunity> objList){ // Migration에서는 제외
        
        List<Sales_Lead__c> slList = new List<Sales_Lead__c>();
        //
        for(Opportunity oppty : objList){
            //세일즈 리드에서 컨버트 되지 않은 경우는 제외 처리
            if(oppty.cLeadID__c != NULL){
                //
                Sales_Lead__c sl    = new Sales_Lead__c();
                sl.Id               = oppty.cLeadID__c;
                sl.LeadStage__c     = 'Hot';
                sl.LeadStatus__c    = 'In Process';
                
                slList.add(sl);
            }
        }
        //
        System.debug('### saveSalesLeadConvertedBO, slList : '+ slList);
        
        if(slList.size() > 0) {
            TriggerControl.isOpptyDeleteToSalesLead = true;
            
            System.debug('### saveSalesLeadConvertedBO, isOpptyDeleteToSalesLead : '+ TriggerControl.isOpptyDeleteToSalesLead);
            Approval.unlock(slList, false);
            
            update slList;
            //
            TriggerControl.isOpptyDeleteToSalesLead = false;
        }
    }
    //V 4.6 ->  Add manual sharing for group 'mig20005' in case of After Insert(MYSALES-103)
    private static void setManualSharingCloudRoleInsert(List<Opportunity> newList){
        //V 5.6 Divyam
        String Apex_Methodname = 'setManualSharingCloudRoleInsert';
        String guId     = IF_Util.generateGuid();
        
        // String cloudRoleId = [select Id from group where DeveloperName  = 'mig20005' and type = 'RoleAndSubordinates'].Id;
        List<Group> listofcloudRole = [Select Id from Group Where (DeveloperName = 'mig20005' OR DeveloperName = 'mig20002') //v 4.9(MySales-168)
                                       AND type = 'RoleAndSubordinates'ORDER By DeveloperName desc limit 2];
        System.debug('CHLOG::START :: OpportunityManualSharing after insert START==============================');
        List<OpportunityShare> optyShareList  = new List<OpportunityShare>();
        Map<Id, CostCenter__c> costMap = new Map<Id, CostCenter__c>();
        Set<ID> ccLitsId = new Set<Id>();
        String logData1;                                                //v 5.3 (MySales-330)
        String OpporId = '';                                            //v 5.3 (MySales-330)
        system.debug('newList_________' + newList);
        
        for(Opportunity opp: newList){
            system.debug('department_______________' + opp.cPrimarySalesDepartment__c);
            ccLitsId.add(opp.cPrimarySalesDepartment__c);
            OpporId += opp.id + ', ';                   //v 5.3 (MySales-330)
        }
        
        system.debug('ccLitsId____' + ccLitsId);
        List<CostCenter__c> deliveryCostCenterList = [SELECT Id, CostCenter__c,Node2__c FROM CostCenter__c where id IN: ccLitsId];
        system.debug('deliveryCostCenterList__' + deliveryCostCenterList);
        for(CostCenter__c c : deliveryCostCenterList){
            costMap.put(c.ID,c);
        }
        
        try {
            for(Opportunity opty : newList) {
                // Start v 5.3 (MySales-330)
                String logData = '1. Inside setManualSharingCloudRoleInsert';                               
                logData += '\n' + 'Opp Id and Name ' + opty.Id + ' ' + opty.name;                           
                logData += '\n' + '2. Opp Primary Sales Dept ' + opty.cPrimarySalesDepartment__c;           
                //End v 5.3 (MySales-330)
                if(opty.cPrimarySalesDepartment__c != null){
                    CostCenter__c deliveryCostCenter = costMap.get(opty.cPrimarySalesDepartment__c);
                    system.debug('CHLOG::deliveryCostCenter : ' + deliveryCostCenter);
                    // Start v 5.3 (MySales-330)
                    logData += '\n' + '3. Opp Delivery Cost center '+ deliveryCostCenter;    
                    if(deliveryCostCenter != null)
                        logData += ' Delivery Cost Center Node2 ' +  deliveryCostCenter.Node2__c;   
                    //End v 5.3 (MySales-330)
                    if (deliveryCostCenter != null && deliveryCostCenter.Node2__c=='T100S3') {
                        OpportunityShare optyShare = new OpportunityShare();
                        optyShare.OpportunityId = opty.Id;
                        optyShare.UserOrGroupId = listofcloudRole[0].Id;
                        optyShare.OpportunityAccessLevel = 'Read';
                        optyShare.RowCause = 'Manual';
                        optyShareList.add(optyShare);
                        logData += '\n' + '4. Inside if Shared Oppty ' + optyShareList;     //v 5.3 (MySales-330)
                        //v 4.9 ->START (MySales-168)
                    }else if (deliveryCostCenter != null && deliveryCostCenter.Node2__c=='T100S4') {
                        OpportunityShare optyShare = new OpportunityShare();
                        optyShare.OpportunityId = opty.Id;
                        optyShare.UserOrGroupId = listofcloudRole[1].Id;
                        optyShare.OpportunityAccessLevel = 'Read';
                        optyShare.RowCause = 'Manual';
                        optyShareList.add(optyShare);
                        logData += '\n' + '5. Inside ElseIf Shared Oppty ' + optyShareList;     //v 5.3 (MySales-330)
                    }
                    //v 4.9- END (MySales-168)
                }
                String oppId = String.valueOf(opty.Id);                                     //v 5.3 (MySales-330)
                System.debug('SJ: before createInterfaceLog>>'); //SJOSHI MYSALES-467
                createInterfaceLog('setManualSharingCloudRoleInsert',logData, oppId);       //v 5.3 (MySales-330)
                System.debug('SJ: after createInterfaceLog>>'); //SJOSHI MYSALES-467
            }
            logData1 = '1. Before Database SaveResult Cumulative result';                   //v 5.3 (MySales-330)
            if(optyShareList.size() >0){
                Database.SaveResult[] lsr = Database.insert(optyShareList,false); 
                system.debug('result updated**');
                // Start v 5.3 (MySales-330)
                for(Database.SaveResult sv : lsr){
                    if(sv.isSuccess()){
                        logData1 += '\n' + 'Inserted optyShareList ' + sv.getId() + ' ';
                    }
                    else{
                        for(Database.Error err : sv.getErrors()){
                            logData1 += '\n' + 'Error ' + err;
                        }
                    }
                }            
            }
            
            logData1 += '\n' + '2. After Database SaveResult ';
            System.debug('SJ: before createInterfaceLog1>>'); //SJOSHI MYSALES-467
            createInterfaceLog1('setManualSharingCloudRoleInsert',logData1,OpporId);
            System.debug('SJ: after createInterfaceLog1>>'); //SJOSHI MYSALES-467
            
        }
        // V 5.6 Divyam
        catch(Exception e){
            system.debug('e : '+e);
            system.debug('e.getLine : '+e.getLineNumber());
            system.debug('e.message : '+e.getMessage());
            createInterfaceLog2(guId,Apex_Methodname,OpporId,e);
        }
        if(allLog.size()>0){
            System.debug('SJ: before insert allLog>>'); //SJOSHI MYSALES-467
            insert allLog;
            System.debug('SJ: after insert allLog>>'); //SJOSHI MYSALES-467
        }
        // End v 5.3 (MySales-330)
        System.debug('CHLOG::END :: OpportunityManualSharing after insert END==============================');
    }
    
    //V 4.6 ->  Add manual sharing for group 'mig20005' in case of After update(MYSALES-103)
    private static void setManualSharingCloudRoleUpdate(List<Opportunity> newList,Map<Id,Opportunity> oldMap){
        System.debug('CHLOG::START :: OpportunityManualSharing after update START==============================');
        // V 5.6 Divyam 
        String Apex_Methodname = 'setManualSharingCloudRoleUpdate';
        String guId = IF_Util.generateGuid();
        
        //String cloudRoleId = [select Id from group where DeveloperName  = 'mig20005' and type = 'RoleAndSubordinates'].Id;
        List<OpportunityShare> deleteOptShareListFinal  = new List<OpportunityShare>();
        List<OpportunityShare> upsertOptShareListFinal  = new List<OpportunityShare>();
        Map<Id, CostCenter__c> costMap = new Map<Id, CostCenter__c>();
        Set<ID> ccLitsId = new Set<Id>();
        String logData1;                                                //v 5.3 (MySales-330)
        String OpporId = '';                                            //v 5.3 (MySales-330)
        //String setofmig20005Id;
        
        Set<String> setofCloudRoleId = new Set<String>();
        List<Group> listofcloudRole = [Select Id from Group Where (DeveloperName = 'mig20005' OR DeveloperName = 'mig20002') //v 4.9(MySales-168)
                                       AND type = 'RoleAndSubordinates'ORDER By DeveloperName desc limit 2];                  //v 4.9(MySales-168)
        system.debug('listofcloudRole__________' + listofcloudRole);
        for(Group g : listofcloudRole){//v 4.9(MySales-168)
            setofCloudRoleId.add(g.Id);//v 4.9(MySales-168)
        }
        for(Opportunity opp: newList){
            ccLitsId.add(opp.cPrimarySalesDepartment__c); 
            OpporId += opp.id + ', ';               //v 5.3 (MySales-330)
        }
        List<CostCenter__c> deliveryCostCenterList = [SELECT Id, CostCenter__c,Node2__c FROM CostCenter__c where ID IN: ccLitsId];
        for(CostCenter__c c : deliveryCostCenterList){
            costMap.put(c.ID,c);
        }
        List<OpportunityShare> optyShareList1 = [SELECT Id, OpportunityId, UserOrGroupId //v 4.9(MySales-168)
                                                 FROM OpportunityShare WHERE UserOrgroupId IN: setofCloudRoleId AND OpportunityId =: oldMap.keyset()];
        system.debug('optyShareList1__________' + optyShareList1);
        
        Map<Id, List<OpportunityShare>> optShareListMap = new Map<Id, List<OpportunityShare>>();
        
        for(OpportunityShare optyShare : optyShareList1) {
            if(optShareListMap.containsKey(optyShare.OpportunityId)) {
                List<OpportunityShare> opShareList = optShareListMap.get(optyShare.OpportunityId);
                opShareList.add(optyShare);
                optShareListMap.put(optyShare.OpportunityId, opShareList);
            } else {
                optShareListMap.put(optyShare.OpportunityId, new List<OpportunityShare> {optyShare});
            }
        }
        system.debug('optShareListMap**' + optShareListMap);
        try {
            for(Opportunity opty : newList) {
                Opportunity oldOpty = oldMap.get(opty.id);
                System.debug('CHLOG::oldMapOpty : ' + oldOpty);
                
                //Start v 5.3 (MySales-330)
                String logData = '1. Inside setManualSharingCloudRoleUpdate';                               
                logData += '\n' + 'Opp Id and Name ' + opty.Id + ' ' + opty.name;                           
                logData += '\n' + '2. Opp Current Primary Sales Dept ' + opty.cPrimarySalesDepartment__c + ' Opp Old Primary Sales Dept' + oldOpty.cPrimarySalesDepartment__c;      //v 5.3 (MySales-330)           
                logData += '\n' + 'Opp OwnerId ' + opty.OwnerId + ' Opp Old OwnerID ' + oldOpty.OwnerId;    
                //End v 5.3 (MySales-330)
                
                if(oldOpty.cPrimarySalesDepartment__c != opty.cPrimarySalesDepartment__c || (oldOpty.OwnerId != opty.OwnerId)) {
                    CostCenter__c newCostCenter = costMap.get(opty.cPrimarySalesDepartment__c);
                    logData += '\n' + '3. Opp Cost center '+ newCostCenter;       //v 5.3 (MySales-330)
                    if(newCostCenter != null)
                        logData += ' Cost Center Node2 ' +  newCostCenter.Node2__c;       //v 5.3 (MySales-330)                                             
                    if (newCostCenter == null || newCostCenter.Node2__c != 'T100S3') {//v 4.9(MySales-168)
                        System.debug('CHLOG::Cloud Deletion 1');
                        if(optShareListMap.size() > 0){
                            List<OpportunityShare> deleteOptShareList = optShareListMap.get(opty.Id);
                            deleteOptShareListFinal.addAll(deleteOptShareList);
                            logData += '\n' + '4. Inside if DeleteOppShareList ' + deleteOptShareListFinal;         //v 5.3 (MySales-330)
                        }
                    }else if(newCostCenter.Node2__c != 'T100S4'){//v 4.9(MySales-168)
                        System.debug('CHLOG::Cloud Deletion 2');
                        if(optShareListMap.size() > 0){
                            List<OpportunityShare> deleteOptShareList = optShareListMap.get(opty.Id);
                            deleteOptShareListFinal.addAll(deleteOptShareList);
                            logData += '\n' + '5. Inside Elseif DeleteOppShareList ' + deleteOptShareListFinal;     //v 5.3 (MySales-330)
                        }
                        
                    }
                    if (newCostCenter != null && newCostCenter.Node2__c == 'T100S3') {
                        System.debug('CHLOG::Changed to Cloud');
                        OpportunityShare optyShare = new OpportunityShare();
                        optyShare.OpportunityId = opty.Id;
                        optyShare.UserOrGroupId = listofcloudRole[0].Id;//v 4.9(MySales-168)
                        optyShare.OpportunityAccessLevel = 'Read';
                        optyShare.RowCause = 'Manual';
                        upsertOptShareListFinal.add(optyShare);
                        logData += '\n' + '6. Inside if UpsertOppShareList ' + upsertOptShareListFinal;             //v 5.3 (MySales-330)
                        /*v 4.9 START(MySales-168)*/
                    } else if(newCostCenter != null && newCostCenter.Node2__c == 'T100S4'){
                        OpportunityShare optyShare = new OpportunityShare();
                        optyShare.OpportunityId = opty.Id;
                        optyShare.UserOrGroupId = listofcloudRole[1].Id;
                        optyShare.OpportunityAccessLevel = 'Read';
                        optyShare.RowCause = 'Manual';
                        upsertOptShareListFinal.add(optyShare);
                        logData += '\n' + '7. Inside Elseif UpsertOppShareList ' + upsertOptShareListFinal;         //v 5.3 (MySales-330)
                    }
                    //v 4.9 END(MySales-168)
                } 
                String oppId = String.valueOf(opty.Id);                                                                     //v 5.3 (MySales-330)
                createInterfaceLog('setManualSharingCloudRoleUpdate',logData, oppId);                                       //v 5.3 (MySales-330)
            }
            logData1 = '1. Before Database DeleteResult Cumulative result';                                                 //v 5.3 (MySales-330)
            if(deleteOptShareListFinal.size() > 0){
                Set<OpportunityShare> opshareSet = new Set<OpportunityShare>(deleteOptShareListFinal);
                List<OpportunityShare> FinalDeleteList = new List<OpportunityShare>(opshareSet);
                DataBase.DeleteResult[] lsr = Database.delete(FinalDeleteList, false);
                // Start v 5.3 (MySales-330)
                for(Database.DeleteResult sv : lsr){
                    if(sv.isSuccess()){
                        logData1 += '\n' + 'Deleted optyShareList ' + sv.getId() + ' ';
                    }
                    else{
                        for(Database.Error err : sv.getErrors()){
                            logData1 += '\n' + 'Error ' + err;
                        }
                    }
                }
                // End v 5.3 (MySales-330)
            }
            logData1 += '\n' + '2. After Database DeleteResult & Before UpsertResult ';                                     //v 5.3 (MySales-330)
            if(upsertOptShareListFinal.size() >0){
                DataBase.UpsertResult[] lsr = Database.upsert(upsertOptShareListFinal, false);
                // Start v 5.3 (MySales-330)
                for(Database.UpsertResult sv : lsr){
                    if(sv.isSuccess()){
                        logData1 += '\n' + 'Deleted optyShareList ' + sv.getId() + ' ';
                    }
                    else{
                        for(Database.Error err : sv.getErrors()){
                            logData1 += '\n' + 'Error ' + err;
                        }
                    }
                }
            }
            logData1 += '\n' + '3. After Database UpsertResult ';
            createInterfaceLog1('setManualSharingCloudRoleUpdate',logData1,OpporId);
            // V 5.6 Divyam
        } catch(Exception e){
            system.debug('e : '+e);
            system.debug('e.getLine : '+e.getLineNumber());
            system.debug('e.message : '+e.getMessage());
            createInterfaceLog2(guId,Apex_Methodname,OpporId,e);
        }
        if(allLog.size()>0){
            insert allLog;
        }
        // Start v 5.3 (MySales-330)
        System.debug('CHLOG::END :: OpportunityManualSharing after update END==============================');
    }
    
    
    // START V 5.1
    // --> Set 'Check Close Date' field value if 'Close Date' is later than 'Contract Start Date' 
    private static void checkCloseDate(List<Opportunity> newList,Map<Id,Opportunity> oldmapList){
        
        List<Opportunity> opplostnew = new List<Opportunity>();
        // Start v 5.4 (MYSALES-334)
        //system.debug('profileofuser'+userProfileName);
        //if(userProfileName == 'System Administrator' || userProfileName == '시스템 관리자' || userProfileName == 'Sales Rep.(HQ)' || userProfileName == 'Sales Rep.(Overseas Corp)' || userProfileName == 'PI (Biz. Owner)' || userProfileName == 'Sales Rep.(Subs)' || userProfileName == 'Service Desk Agency' || userProfileName == 'Custom System Administrator'){
        if(userProfileId.equals(systemAdministratorProfileID) || userProfileId.equals(salesRepHQProfileID) || userProfileId.equals(salesRepOverseasCorpProfileID) || userProfileId.equals(pIBizOwnerProfileID) || userProfileId.equals(salesRepSubsProfileID) || userProfileId.equals(serviceDeskAgencyProfileID) || userProfileId.equals(customSystemAdministratorProfileID)){
            // End v 5.4 (MYSALES-334)    
            for(Opportunity  opprecd :newList){
                if(opprecd.RecordTypeId == RT_OPPTY_HQ_ID && opprecd.cRevenueStartDate__c != null && opprecd.CloseDate > opprecd.cRevenueStartDate__c && opprecd.FirstCloseDate__c == null ){
                    if(oldmapList.get(opprecd.Id).Check_Close_Date__c == false && (oldmapList.get(opprecd.Id).CloseDate != opprecd.CloseDate || oldmapList.get(opprecd.Id).cRevenueStartDate__c != opprecd.cRevenueStartDate__c)){
                        opprecd.Check_Close_Date__c = true;
                        
                    }
                    
                    
                }
                else {
                    opprecd.Check_Close_Date__c=false;
                    
                }
            }
        }
        
        
    }
    
    private static void checkCloseDate1(List<Opportunity> newList){
        
        // List<Opportunity> opplost = newList;
        //  opplost = [select id,RecordTypeId,CloseDate,cRevenueStartDate__c,Check_Close_Date__c from Opportunity where id IN : newmapList.keyset()];
        List<Opportunity> opplostnew = new List<Opportunity>();
        // Start v 5.4 (MYSALES-334)
        //if(userProfileName == 'System Administrator' || userProfileName == '시스템 관리자' || userProfileName == 'Sales Rep.(HQ)' || userProfileName == 'Sales Rep.(Overseas Corp)' || userProfileName == 'PI (Biz. Owner)' || userProfileName == 'Sales Rep.(Subs)' || userProfileName == 'Service Desk Agency' || userProfileName == 'Custom System Administrator'){
        if(userProfileId.equals(systemAdministratorProfileID) || userProfileId.equals(salesRepHQProfileID) || userProfileId.equals(salesRepOverseasCorpProfileID) || userProfileId.equals(pIBizOwnerProfileID) || userProfileId.equals(salesRepSubsProfileID) || userProfileId.equals(serviceDeskAgencyProfileID) || userProfileId.equals(customSystemAdministratorProfileID)){
            System.debug('Inside If>>checkCloseDate1()');
            // End v 5.4 (MYSALES-334)
            
            for(Opportunity  opprecd :newList){
                
                if(opprecd.RecordTypeId == RT_OPPTY_HQ_ID && opprecd.cRevenueStartDate__c != null && opprecd.CloseDate > opprecd.cRevenueStartDate__c  && opprecd.FirstCloseDate__c == null){
                    opprecd.Check_Close_Date__c = true;
                    
                    
                    
                    
                }
                else {
                    opprecd.Check_Close_Date__c=false;
                    
                }
            }
        }
        
        
    }
    // END V 5.1
    
    // Start v 5.3 (MySales-330)
    private static void createInterfaceLog(String apexMethod, String logMessage, String oppId){
        IF_Log__c log = new IF_Log__c();
        log.ApexName__c = 'OpportunityTrigger';
        log.ApexMethod__c =  apexMethod;
        log.InterfaceId__c = 'TRIGGER_LOG';
        log.LogText__c = logMessage;
        log.StatusCode__c = 'S';
        log.LogType__c = 'Trigger';
        log.EndDatetime__c  = System.now();
        log.StartDatetime__c = System.now();
        log.RequestMessage__c = oppId;
        System.debug( 'Trigger Log creation'+ log);
        System.debug('SJ: Inside createInterfaceLog'); //SJOSHI MYSALES-467
        allLog.add(log);
    }
    
    private static void createInterfaceLog1(String apexMethod, String logMessage, String OpporId){
        IF_Log__c log = new IF_Log__c();
        log.ApexName__c = 'OpportunityTrigger';
        log.ApexMethod__c =  apexMethod;
        log.InterfaceId__c = 'TRIGGER_LOG';
        log.LogText__c = logMessage;
        log.StatusCode__c = 'S';
        log.LogType__c = 'Trigger';
        log.EndDatetime__c  = System.now();
        log.StartDatetime__c = System.now();
        log.RequestMessage__c = OpporId;
        System.debug( 'Trigger Log creation'+ log);
        System.debug('SJ: Inside createInterfaceLog1'); //SJOSHI MYSALES-467
        allLog.add(log);
    }
    // START V 5.6 Divyam
    private static void createInterfaceLog2(String guid, String apexmethod,String OpporId,Exception e) {
        IF_Log__c log = new IF_Log__c();
        log.InterfaceId__c = 'TRIGGER_LOG';
        log.InterfaceGuid__c = guid;
        log.ApexMethod__c = apexmethod;
        log.ApexName__c = 'OpportunityTrigger';
        log.RequestMessage__c = OpporId;
        log.StatusCode__c = 'E';
        log.LogType__c = 'Trigger';
        log.EndDatetime__c  = System.now();
        log.StartDatetime__c = System.now();
        log.ExceptionType__c = e.getTypeName();
        log.ErrorMessage__c = e.getMessage();
        log.StackTrace__c = e.getStackTraceString();
        
    }
    // END V 5.6 Divyam
    // End v 5.3 (MySales-330)
    
    // Start v 5.5 (MySales-332)
    private static void setBOFirstclosedate(List<Opportunity> newList){
        for(Opportunity rowBO : newList){
            
            if(rowBO.RecordTypeId == RT_OPPTY_HQ_ID && rowBO.FirstCloseDate__c != null){
                if(rowBO.StageName == OPP_STAGE_LOST || rowBO.StageName == OPP_STAGE_DROP){
                    rowBO.FirstCloseDate__c = null;
                }
            }
        }
    }
    // End v 5.5 (MySales-332) 
    
    // Start v 5.7 (MySales-356)
    private static void updateTXPManpower(List<Opportunity> newList,Map<Id, Opportunity> oldMap){
        Set<String> BoList = new Set<String>();
        for(Opportunity rowBO : newList){
            if(rowBO.ProposalPM__c != oldMap.get(rowBO.Id).ProposalPM__c || rowBO.RepresentativePM__c != oldMap.get(rowBO.Id).RepresentativePM__c){
                if(rowBO.RecordTypeId == RT_OPPTY_HQ_ID){
                    BoList.add(rowBO.Id);
                }
            }
        }
        
        Boolean isBatch = System.isBatch();
        System.debug('=== OpportunityTrigger.isBatch ? ' + isBatch);
        
        if(BoList.size()>0) {//V5.9 Start
            if(isBatch) { 
                Batch_SendTXPManpowerInfo Batch_SendTXPInfo = new Batch_SendTXPManpowerInfo();
                Batch_SendTXPInfo.BoIdList = BoList;
                DataBase.executeBatch(Batch_SendTXPInfo, 200); 
            }
            else{ 
                IF_SendTXPManpowerInfo.SendTXPManpowerInfo(BoList);
            } //V5.9 End
        } 
        
    }
    private static void updateTXPManpowerInfo(List<Opportunity> newList){
        Set<String> BoList = new Set<String>();
        for(Opportunity rowBO : newList){
            if(rowBO.ProposalPM__c != null && rowBO.RecordTypeId == RT_OPPTY_HQ_ID){
                BoList.add(rowBO.Id);
            }
        }
        Boolean isBatch = System.isBatch();
        System.debug('=== OpportunityTrigger.isBatch ? ' + isBatch);
        
        if(BoList.size()>0) {//V5.9 Start
            if(isBatch) { 
                Batch_SendTXPManpowerInfo Batch_SendTXPInfo = new Batch_SendTXPManpowerInfo();
                Batch_SendTXPInfo.BoIdList = BoList;
                DataBase.executeBatch(Batch_SendTXPInfo, 200); 
            }
            else{ 
                IF_SendTXPManpowerInfo.SendTXPManpowerInfo(BoList);
            } //V5.9 End
        } 
        /*if(BoList.size()>0){
System.enqueueJob(new TXPInfoUpdateQueue(BoList));
}*/
    }
    // End v 5.7 (MySales-356) 
    // Start v6.5 
    private static void CreateDeliveryprobability(List<Opportunity> newList){
        List<Delivery_Probabiliy__c> DPList = new List<Delivery_Probabiliy__c>();
        for(Opportunity rowBO : newList){
            if(rowBO.RecordTypeId == RT_OPPTY_HQ_ID){
                if(rowBO.Collaboration__c == True){//V6.9 Start
                    List<Opportunity> oppList = [Select id,OpportunityCode__c from Opportunity where Id = :rowBO.CollaborationBOId__c];
                    String BOCODE = '';
                    String TXPBoCode = '';
                    if(oppList.size()>0){
                        String s = oppList[0].OpportunityCode__c;
                        TXPBoCode = s.substring(4,s.length()-1);
                        BOCODE = oppList[0].OpportunityCode__c;
                    }
                    Delivery_Probabiliy__c DP = new Delivery_Probabiliy__c();
                    DP.Opportunity__c = rowBO.Id; 
                    DP.Companycode__c = rowBO.CompanyCode__c;
                    DP.TXP_Link__c    = 'http://txp.sds.samsung.net/front/#/management/?busn='+TXPBoCode;
                    DP.Dashboardlink__c = 'http://bos.sds.samsung.net/app/detail?orderId='+BOCODE+'&sapCompany='+rowBO.CompanyCode__c+'&lang=ko';
                    DPList.add(DP);
                }
                else{//V6.9 End
                    Delivery_Probabiliy__c DP = new Delivery_Probabiliy__c();
                    DP.Opportunity__c = rowBO.Id; 
                    DP.Companycode__c = rowBO.CompanyCode__c;
                    DP.TXP_Link__c    = 'http://txp.sds.samsung.net/front/#/management/?busn='+rowBO.Auto_OpptyCode__c;
                    DP.Dashboardlink__c = 'http://bos.sds.samsung.net/app/detail?orderId=SDS-'+rowBO.Auto_OpptyCode__c+'0&sapCompany='+rowBO.CompanyCode__c+'&lang=ko';
                    DPList.add(DP);
                }
            }
        }
        if(DPList.size() > 0){ insert DPList;}
    }
    // End v6.5
    // Added By Vipul MYSALES-477 Start V6.7
    private static void setOpptyFirstCloseDateForHQ(List<Opportunity> newList,Map<Id, Opportunity> oldMap){ 
        try{
            for(Opportunity rowBO : newList){
                if(rowBO.RecordTypeId == RT_OPPTY_HQ_ID && rowBO.StageName != oldMap.get(rowBO.Id).StageName 
                   && rowBO.StageName == opportunityWonStage && rowBO.CspMspType__c != CSPAndMSPType && rowBO.FirstCloseDate__c == null){
                       rowBO.FirstCloseDate__c = System.today();
                   }  
            }
        }
        catch(exception e){
            System.debug('Exception '+ e);  
        }
    } //End V6.7
}