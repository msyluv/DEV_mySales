/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 11-05-2023
 * @last modified by  : anish.jain@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2021-01-08   younghoon.kim@dkbmc.com   Initial Version
 * 1.1   2021-01-14   hj.lee@dkbmc.com          Opportunity의 실주 사유 Picklist는 Closed 되기 전에 입력 불가능하므로 Activity의 LostReason 필드 체크로 변경
 * 1.2   2021-01-18   younghoon.kim@dkbmc.com   ZP62, ZPG1 로직 추가
 * 1.3   2021-03-22   hj.lee@dkbmc.com          validationCheck_ZP82 (수주품의 Activity Check 메소드 분리, [협업 BO 최초 수주품의 Activity 제어] 로직 추가)
 * 1.4   2021-03-25   hj.lee@dkbmc.com          IF-102 호출 삭제 (IF-56에 IF-102가 포함되어 삭제 요청)
 * 1.5   2021-04-27   hj.lee@dkbmc.com          수주품의/수주변경 품의 구분, Approval Type Code 수정
 * 1.6   2021-05-05   hj.lee@dkbmc.com          IF-056 "T_RTN":[{"TYPE":"□"}] "□" 에 따른 체크 분기 로직 추가
 * 1.7   2021-05-07   hj.lee@dkbmc.com          수주품의/수주변경 품의 구분 : "완결(2), 전결(5), 후완결(6)" KnoxApproval.Status__c 조건 추가
 * 1.6   2021-05-11   hj.lee@dkbmc.com          수주변경품의 시, IF-056 "TYPE": "M" 일때, 법인/본사 동시 상신을 위하여 tRtnTypeCode Return 추가
 * 1.8   2022-10-28   anish.jain@partner.samsung.com         Changes done for Lost Reason Validation on Knox Approval Tab
 * 1.9   2022-10-28   divyam.gupta@samsung.com         Remove the LostReason__c check not required as per new requirement(Mysales-91)
 * 2.0   2023-11-21   vikrant.ks@samsung.com     Error Message Modification for checking contract approval (IF-056)(Mysales-364) - Part of MS-216 
 * 2.1   11-05-2023   anish.jain@partner.samsung.com   MySales - 216
**/
public class KnoxApprovalValidation {
    public static Map<String, String> validationCheck(String opptyActId, String bizReviewId){
        Map<String, String> returnMap = new Map<String, String>();

        List<Object> logList = new List<Object>();
        List<Opportunity> updateOpptyList = new List<Opportunity>();
        //Added by Anish -> Add LostType__c - v 1.8
        Opportunity_Activity__c opptyAct = [SELECT Id, Name,LostType__c, Status__c, TransactionName__c,WhatId__c, LostReason__c
                                              FROM Opportunity_Activity__c WHERE Id =: opptyActId];
        String transactionName = opptyAct.TransactionName__c;
        System.debug('++++++++++++++++++++++++++++++' + transactionName + '++++++++++++++++++++++++++++++');
        String status = opptyAct.Status__c == null ? '' : opptyAct.Status__c;

        Opportunity oppty = [SELECT Id, Name, StageName, 
                                    SalesDepartment__c, SalesDepartment__r.Name, CompanyCode__c, OpportunityCode__c, 
                                    Collaboration__c, CollaborationInOut__c, CollaborationBOId__c, 
                                    DealBreak__c, Construction__c, VRBMethod__c, BusinessType__c, LostReasonLogistics__c,
                                    Owner.CompanyCode__c
                               FROM Opportunity 
                              WHERE Id =: opptyAct.WhatId__c];

        List<Biz_Review__c> bizReviewList = [SELECT Id, Name, Opportunity__c, Costplanningreadiness__c, OriginalPriceVersion__c, Version__c, Decision__c 
                                               FROM Biz_Review__c 
                                              WHERE Id = :bizReviewId];

        Boolean dealBreak = oppty.DealBreak__c;
        String companyCode = oppty.CompanyCode__c;
        String opptyCode = oppty.OpportunityCode__c;
        String vrbMethod = oppty.VRBMethod__c;
        String bizType = oppty.BusinessType__c;
        String stage = oppty.StageName;
        String opptyOwnerCompanyCode = oppty.Owner.CompanyCode__c;
        Boolean isOpptyOwnerT100 = (opptyOwnerCompanyCode == 'T100') ? true : false;

        System.debug(' # oppty.SalesDepartment__r.Name: ' + oppty.SalesDepartment__r.Name);

        // Activity 결재 진행 중 확인
        Boolean IsPendingKnoxApproval = false;
        String knoxApprovalInProgress = '1';
        List<KnoxApproval__c> knoxApprovalInProgressList = [SELECT Id, Status__c FROM KnoxApproval__c WHERE OpportunityActivity__c = :opptyActId AND Status__c = :knoxApprovalInProgress];
        if(knoxApprovalInProgressList.size() > 0){
            IsPendingKnoxApproval = true;
        }
        
        /*
            [공통]
            - 특정 법인, 액티비티 유형 별로 일정기간 결재 상신을 제어하기 위함
            - 법인, Activity 유형 별로 결재 상신 불가능한(Block) 기간을 설정하는 Object 관리 기능 개발
                (예를 들면 특정 법인 모든 액티비티 불가 또는 일부 액티비티만 불가 등)
            - 마스터 설정에 따라, 해당 법인에서 액티비티 상신 가능 여부를 제어
            - 단, "Admin" 권한의 user는 Block 기간에 상관없이 예외적으로 상신 허용
            - 금지 기간에 상신할 때 오류 메시지 
                "Due to reorganization of the company, approval cannot be submitted during 1/28~1/30."
            - 기간은 Block 기간에 따라 가변적으로 표시해야 함
        */
        // 공통부분은 아직 협의중

        try{
            Switch on transactionName{
                when 'ZP32' { // Request Resources
                    System.debug('[ZP32]');
                    System.debug('[ZP32] - Status : ' + status);
                    //if(status.equals('In Progress')){ // Activity 상대로 결재수행 여부 점검
                    if(IsPendingKnoxApproval) { // [2021-01-14, hj.lee] Knox Approval Record 결재 진행중 확인
                        returnMap.put('RESULT', 'F');
                        returnMap.put('MESSAGE', Label.VAPP_MSG_001); // VAPP_MSG_001 / Knox Portal approval is being transferred.
                        
                    }else{
                        // IF-056 / ECC 결재상신 사전점검 Interface 호출 (ZP3SDC_CHECK_CRM_APPROVAL_STAT)
                        Map<String, Object> resultMap_056 = eccProjectStatusCheck(companyCode, opptyCode, transactionName);
                        if(resultMap_056 != null) logList.add(resultMap_056.get('INTERFACE_LOG'));
                        System.debug('[ZP32] - resultMap_056 : ' + resultMap_056);
                        System.debug('[ZP32] - StatusCode : ' + resultMap_056.get('StatusCode'));
                        
                        if(Integer.valueOf(resultMap_056.get('StatusCode')) == 200){
                            InputHeader_056 input_056 = (InputHeader_056) JSON.deserialize(String.valueOf(resultMap_056.get('Response')), InputHeader_056.class);
                            System.debug('[ZP32] - input_056 : ' + input_056);
                            System.debug('[ZP32] - input_056.EV_RTNST : ' + input_056.EV_RTNST);

                            Boolean isValidResult_056 = false;
                            String approvalTypeCode = 'ZCRM000020'; // [ZP32] 결재유형코드
                            String tRtnErrorMessage = '';
                            String tRtnTypeCode = '';

                            // 2021-05-05   hj.lee@dkbmc.com          IF-056 "T_RTN":[{"TYPE":"□"}] "□" 에 따른 체크 분기 로직 추가
                            if(input_056.EV_RTNST != 'S'){
                                isValidResult_056 = false;
                            } else {
                                isValidResult_056 = true;
                            }

                            List<INPUT_T_RTN> tRtnList = input_056.T_RTN;
                            if(tRtnList != null){
                                Integer tRtnCount = 0;
                                for(INPUT_T_RTN tRtn : tRtnList){
                                    tRtnCount++;
                                    
                                    if(tRtnCount == 1){ // 처음 온 것 저장
                                        tRtnTypeCode = tRtn.TYPE; 
                                        tRtnErrorMessage = '';
                                        if(tRtn.MESSAGE_V1 != null) tRtnErrorMessage = tRtn.MESSAGE_V1;
                                        if(tRtn.MESSAGE_V2 != null) tRtnErrorMessage += tRtn.MESSAGE_V2;
                                        if(tRtn.MESSAGE_V3 != null) tRtnErrorMessage += tRtn.MESSAGE_V3;//V2.0
                                        if(tRtn.MESSAGE_V4 != null) tRtnErrorMessage += tRtn.MESSAGE_V4;//V2.0
                                    }

                                    if(tRtn.TYPE == 'E') { // Error Type 저장
                                        tRtnTypeCode = tRtn.TYPE; 
                                        tRtnErrorMessage = '';
                                        if(tRtn.MESSAGE_V1 != null) tRtnErrorMessage = tRtn.MESSAGE_V1;
                                        if(tRtn.MESSAGE_V2 != null) tRtnErrorMessage += tRtn.MESSAGE_V2;
                                        if(tRtn.MESSAGE_V3 != null) tRtnErrorMessage += tRtn.MESSAGE_V3;//V2.0
                                        if(tRtn.MESSAGE_V4 != null) tRtnErrorMessage += tRtn.MESSAGE_V4;//V2.0
                                        break;
                                    }
                                }
                            
                        
                                switch on tRtnTypeCode {
                                    when 'E' {
                                        // E: 결재 진행불가  
                                        isValidResult_056 = false;
                                    }
                                    when 'M' {
                                        // M: 상신자가 T100(본사) 소속이면 에러메세지 보여주고 상신불가.(즉, 법인만 상신가능)
                                        // * 결재 상신시 상신자가 Oppty Owner로 지정되어 상신되므로 Oppty Owner로 비교함
                                        if(isOpptyOwnerT100)    isValidResult_056 = false; // 본사
                                        else                    isValidResult_056 = true;  // 법인
                                    }
                                    when 'H' {
                                        // H: 상신자가 T100(본사) 소속이 아니면 에러메세지 보여주고 상신불가.(즉, 본사(T100)만 상신가능)
                                        if(!isOpptyOwnerT100)   isValidResult_056 = false; // 법인
                                        else                    isValidResult_056 = true;  // 본사
                                    }
                                    when 'S' {
                                        // S: 상신자가 T100(본사) 소속이면 에러메세지 보여주고 상신불가. (즉, 법인만 상신가능)
                                        if(isOpptyOwnerT100)    isValidResult_056 = false; // 본사     
                                        else                    isValidResult_056 = true;  // 법인
                                    }
                                    when else {		  
                                        isValidResult_056 = true;
                                    }
                                }
                            }
                            
                            // if-056 결과
                            System.debug('isValidResult_056 : ' + isValidResult_056);
                            System.debug('tRtnTypeCode : ' + tRtnTypeCode);
                            System.debug('tRtnErrorMessage : ' + tRtnErrorMessage);

                            if(isValidResult_056) {
                                returnMap.put('RESULT', 'S');
                                returnMap.put('MESSAGE', approvalTypeCode);
                            } else {
                                returnMap.put('RESULT', 'F');
                                returnMap.put('MESSAGE', Label.VAPP_MSG_002 + ' : ' + tRtnErrorMessage);
                            }

                        } else {
                            // IF-056 Http Error
                            System.debug('[ERROR] resultMap_056 - http request Error ' + String.valueOf(resultMap_056.get('StatusCode')));
                            returnMap.put('RESULT', 'F');
                            returnMap.put('MESSAGE', 'HTTP CODE [' +String.valueOf(resultMap_056.get('StatusCode')) + '] ' + String.valueOf(resultMap_056.get('IF_MSG')));
                        } 

                    }
                }
                // TBD
                
                when 'ZP62' { // Request Committee Approval
                    System.debug('[ZP62]');
                    if(bizReviewList.size() == 0){ 
                        returnMap.put('RESULT', 'F');
                        returnMap.put('MESSAGE', 'Strategy Committee Record not found'); 
                    } else {
                        if(bizReviewList[0].Costplanningreadiness__c == null){
                            returnMap.put('RESULT', 'F');
                            returnMap.put('MESSAGE', Label.VAPP_MSG_003); // VAPP_MSG_003 / 'Cost planning readiness' is mandatory.
                            System.debug(' [ZP62] Costplanningreadiness__c == null : ');
                        }else{
                            if(bizReviewList[0].Decision__c == null){
                                returnMap.put('RESULT', 'F');
                                returnMap.put('MESSAGE', Label.VAPP_MSG_004); // VAPP_MSG_004 / 'Decision' is mandatory.
                                System.debug(' [ZP62] Decision__c == null : ');
                            }else{
                                if(bizReviewList[0].Costplanningreadiness__c == 'Yes'){
                                    
                                    // IF-134 / ECC Project version Interface 호출 (ZP3CRZ_GET_PJT_VERSIONS)
                                    // 호출하기 위한 필수 정보 확인
                                    if(String.isBlank(opptyCode) 
                                    || String.isBlank(bizReviewList[0].OriginalPriceVersion__c) 
                                    || String.isBlank(companyCode)) {

                                        System.debug(' opptyCode : ' + opptyCode);
                                        System.debug(' bizReviewList[0].OriginalPriceVersion__c : ' + bizReviewList[0].OriginalPriceVersion__c);
                                        System.debug(' companyCode : ' + companyCode);
                                        returnMap.put('RESULT', 'F'); returnMap.put('MESSAGE', Label.VAPP_MSG_012); // Check if the "Opportunity Code", "Opportunity Company Code", "Original Price Version" value is included.
                                    } else {

                                        Map<String, Object> resultMap_134 = sdGetConfirmInfo(opptyCode, bizReviewList[0].OriginalPriceVersion__c, companyCode);
                                        if(resultMap_134 != null) logList.add(resultMap_134.get('INTERFACE_LOG'));
                                        System.debug(' [ZP62] resultMap_134 ' + resultMap_134);
                                        System.debug('resultMap_134.get(Response) : '+resultMap_134.get('Response'));
                                        if(Integer.valueOf(resultMap_134.get('StatusCode')) == 200){
                                            Map<String,Object> resultMap_134_response = (Map<String,Object>) JSON.deserializeUntyped(String.valueOf(resultMap_134.get('Response')));
                                            System.debug('resultMap_134_response : ' + resultMap_134_response);
                                            List<Object> t_resultList = new List<Object>();
                                            outputHeader_134 output_134_T_RESULT = new outputHeader_134();
                                            if(resultMap_134_response.get('T_RESULT') != null) {
                                                t_resultList = (List<Object>)resultMap_134_response.get('T_RESULT');
                                                if(t_resultList.size() > 0 ) {
                                                    String t_result_json = JSON.serialize(t_resultList[0]);
                                                    output_134_T_RESULT = (outputHeader_134) JSON.deserialize(t_result_json, outputHeader_134.class);
                                                }
                                            }
                                            System.debug(' [ZP62] output_134_T_RESULT: ' +  output_134_T_RESULT);
                                            
                                            // A. ECC Proeject version 생성 여부
                                            // Version 미생성 시 오류처리
                                            System.debug('[ZP62] output_134_T_RESULT.Version ' + output_134_T_RESULT.Version);
                                            if(output_134_T_RESULT.Version == null || output_134_T_RESULT.Version == ''){ 
                                                returnMap.put('RESULT', 'F'); returnMap.put('MESSAGE', Label.VAPP_MSG_005); // VAPP_MSG_005 / Please create BO/PJT version.
                                            
                                            // B. 수전위 Original Price Version 과 ECC Proejct return Version 값 비교
                                            // 수전위 ECC Proejct return Version 은 'F' 가 포함되어야함
                                            } else if( !output_134_T_RESULT.Version.containsIgnoreCase('F') || bizReviewList[0].OriginalPriceVersion__c != output_134_T_RESULT.Version){
                                                returnMap.put('RESULT', 'F'); returnMap.put('MESSAGE', Label.VAPP_MSG_006); // VAPP_MSG_006 / Please refresh the activity and select the max version &1.

                                            } else if(output_134_T_RESULT.STATU == 'A2'){ // ECC Project Version이 A2인 경우 ECC 결재상신 사전점검 I/F 호출
                                                // IF-056 / ECC 결재상신 사전점검 Interface 호출 (ZP3SDC_CHECK_CRM_APPROVAL_STAT)
                                                Map<String, Object> resultMap_056 = eccProjectStatusCheck(companyCode, opptyCode, transactionName);
                                                if(resultMap_056 != null) logList.add(resultMap_056.get('INTERFACE_LOG'));
                                                System.debug('[ZP62] - resultMap_056 : ' + resultMap_056);
                                                System.debug('[ZP62] - StatusCode : ' + resultMap_056.get('StatusCode'));

                                                if(Integer.valueOf(resultMap_056.get('StatusCode')) == 200) {
                                                    InputHeader_056 input_056 = (InputHeader_056) JSON.deserialize(String.valueOf(resultMap_056.get('Response')), InputHeader_056.class);
                                                    System.debug('[ZP62] - input_056 : ' + input_056);
                                                    System.debug('[ZP62] - input_056.EV_RTNST : ' + input_056.EV_RTNST);
                        
                                                    Boolean isValidResult_056 = false;
                                                    String tRtnErrorMessage = '';
                                                    String approvalTypeCode = 'ZCRM000050'; // [ZP62] 결재유형코드
                                                    String tRtnTypeCode = '';
                        
                                                    // 2021-05-05   hj.lee@dkbmc.com          IF-056 "T_RTN":[{"TYPE":"□"}] "□" 에 따른 체크 분기 로직 추가
                                                    if(input_056.EV_RTNST != 'S'){
                                                        isValidResult_056 = false;
                                                    } else {
                                                        isValidResult_056 = true;
                                                    }

                                                    List<INPUT_T_RTN> tRtnList = input_056.T_RTN;
                                                    if(tRtnList != null) {
                                                        Integer tRtnCount = 0;
                                                        for(INPUT_T_RTN tRtn : tRtnList){
                                                            tRtnCount++;
                                                            
                                                            if(tRtnCount == 1){ // 처음 온 것 저장
                                                                tRtnTypeCode = tRtn.TYPE; 
                                                                tRtnErrorMessage = '';
                                                                if(tRtn.MESSAGE_V1 != null) tRtnErrorMessage = tRtn.MESSAGE_V1;
                                                                if(tRtn.MESSAGE_V2 != null) tRtnErrorMessage += tRtn.MESSAGE_V2;
                                                                if(tRtn.MESSAGE_V3 != null) tRtnErrorMessage += tRtn.MESSAGE_V3;//V2.0
                                        						if(tRtn.MESSAGE_V4 != null) tRtnErrorMessage += tRtn.MESSAGE_V4;//V2.0
                                                            }

                                                            if(tRtn.TYPE == 'E') { // Error Type 저장
                                                                tRtnTypeCode = tRtn.TYPE; tRtnErrorMessage = '';
                                                                if(tRtn.MESSAGE_V1 != null) tRtnErrorMessage = tRtn.MESSAGE_V1;
                                                                if(tRtn.MESSAGE_V2 != null) tRtnErrorMessage += tRtn.MESSAGE_V2;
                                                                if(tRtn.MESSAGE_V3 != null) tRtnErrorMessage += tRtn.MESSAGE_V3;//V2.0
                                        						if(tRtn.MESSAGE_V4 != null) tRtnErrorMessage += tRtn.MESSAGE_V4;//V2.0
                                                                break;
                                                            }
                                                        }
                                                        
                                                        switch on tRtnTypeCode {
                                                            when 'E' {
                                                                // E: 결재 진행불가  
                                                                isValidResult_056 = false;
                                                            }
                                                            when 'M' {
                                                                // M: 상신자가 T100(본사) 소속이면 에러메세지 보여주고 상신불가.(즉, 법인만 상신가능)
                                                                // * 결재 상신시 상신자가 Oppty Owner로 지정되어 상신되므로 Oppty Owner로 비교함
                                                                if(isOpptyOwnerT100)    isValidResult_056 = false; // 본사
                                                                else                    isValidResult_056 = true;  // 법인
                                                            }
                                                            when 'H' {
                                                                // H: 상신자가 T100(본사) 소속이 아니면 에러메세지 보여주고 상신불가.(즉, 본사(T100)만 상신가능)
                                                                if(!isOpptyOwnerT100)   isValidResult_056 = false; // 법인
                                                                else                    isValidResult_056 = true;  // 본사
                                                            }
                                                            when 'S' {
                                                                // S: 상신자가 T100(본사) 소속이면 에러메세지 보여주고 상신불가. (즉, 법인만 상신가능)
                                                                if(isOpptyOwnerT100)    isValidResult_056 = false; // 본사     
                                                                else                    isValidResult_056 = true;  // 법인
                                                            }
                                                            when else {		  
                                                                isValidResult_056 = true;
                                                            }
                                                        }
                                                    }
                                                        

                                                    // if-056 결과
                                                    System.debug('isValidResult_056 : ' + isValidResult_056);
                                                    System.debug('tRtnTypeCode : ' + tRtnTypeCode);
                                                    System.debug('tRtnErrorMessage : ' + tRtnErrorMessage);

                                                    if(isValidResult_056) {
                                                        returnMap.put('RESULT', 'S');
                                                        returnMap.put('MESSAGE', approvalTypeCode);
                                                    } else {
                                                        returnMap.put('RESULT', 'F');
                                                        returnMap.put('MESSAGE', Label.VAPP_MSG_002 + ' : ' + tRtnErrorMessage);
                                                    }
                        
                                                }else{
                                                    // IF-056 Http Error
                                                    System.debug('[ERROR] resultMap_056 - http request Error ' + String.valueOf(resultMap_056.get('StatusCode')));
                                                    returnMap.put('RESULT', 'F');
                                                    returnMap.put('MESSAGE', 'HTTP CODE [' +String.valueOf(resultMap_056.get('StatusCode')) + '] ' + String.valueOf(resultMap_056.get('IF_MSG')));
                                                } 

                                            }
                                        }else{
                                            returnMap.put('RESULT', 'F');
                                            returnMap.put('MESSAGE', String.valueOf(resultMap_134.get('Message')));
                                        }
                                    }
                                    

                                } else {
                                    // [Success]
                                    returnMap.put('RESULT', 'S');
                                    returnMap.put('MESSAGE', 'ZCRM000050');
                                }
                            }
                        }
                    }  //  [E]

                    if(IsPendingKnoxApproval) { // Knox Approval Record 결재 진행중 확인
                        returnMap.put('RESULT', 'F');
                        returnMap.put('MESSAGE', Label.VAPP_MSG_001); // VAPP_MSG_001 / Knox Portal approval is being transferred.
                    }
                }
                
                when 'ZP82' { // Contract Approval
                    Map<String, Object> originValidMap = validationCheck_ZP82(oppty.Id);
                    String originResult = (String)originValidMap.get('RESULT');
                    String originValideMsg = (String)originValidMap.get('MESSAGE');
                    returnMap.put('RESULT', originResult);
                    returnMap.put('MESSAGE', originValideMsg);

                    if(originValidMap.get('IFLOG') != null)             logList.addAll((List<Object>)originValidMap.get('IFLOG'));
                    if(originValidMap.get('UPDATE_OPPTYLIST') != null)  updateOpptyList.addAll((List<Opportunity>)originValidMap.get('UPDATE_OPPTYLIST'));

                    /**
                     * [협업 BO 최초 수주품의 Activity 제어] 법인에서 최초 수주 품의 결재 상신전, 본사 수주품의 상신전 체크로직도 같이 호출하여 본사 원가판 컨펌, 에러여부도 같이 확인되도록 추가
                     * 본사 체크 로직 진행 필요 여부 확인 후 Validation 호출
                     */
                    Boolean isRequiredCollaboCheck = false; // 본사 체크 로직 진행 필요 여부
                    Boolean isOpptyOut = oppty.Collaboration__c && oppty.CompanyCode__c != 'T100'; // 법인 협업 여부 확인 

                    List<KnoxApproval__c> opptyOutKnoxApprovalList = [
                        SELECT  Id
                        FROM    KnoxApproval__c
                        WHERE   Opportunity__c = :oppty.Id
                            AND OpportunityActivity__r.TransactionName__c = 'ZP82'
                            AND ( Status__c = :KnoxApprovalHelper.KNOX_APPROVAL_STATUS_COMPLETED
                                OR Status__c = :KnoxApprovalHelper.KNOX_APPROVAL_STATUS_ARBITRARY_CONFIRMED
                                OR Status__c = :KnoxApprovalHelper.KNOX_APPROVAL_STATUS_AFTER_CONFIRMED
                                )
                    ];
                    // 법인 Oppty 이고, 최초 수주품의인 경우 본사 체크 로직 필요
                    if(isOpptyOut && (opptyOutKnoxApprovalList.size() == 0) ){
                        isRequiredCollaboCheck = true;
                    }
                    if(isRequiredCollaboCheck){
                        // 본사 수주품의 Validation 진행
                        Map<String, Object> collaboValidMap = validationCheck_ZP82(oppty.CollaborationBOId__c);
                        String collaboResult = (String)collaboValidMap.get('RESULT');
                        String collaboValideMsg = (String)collaboValidMap.get('MESSAGE');
                        // 협업 BO 결과
                        returnMap.put('COLLABO_RESULT', collaboResult);
                        returnMap.put('COLLABO_MESSAGE', collaboValideMsg);

                        if(collaboValidMap.get('IFLOG') != null)            logList.addAll((List<Object>)collaboValidMap.get('IFLOG'));
                        if(collaboValidMap.get('UPDATE_OPPTYLIST') != null) updateOpptyList.addAll((List<Opportunity>)collaboValidMap.get('UPDATE_OPPTYLIST'));
                    } 

                    /**
                     * [수주변경품의 시] 법인 사전점검 후, IF-056 "TYPE": "M" 일때, 법인/본사 동시 상신을 위하여 협업 BO 결과를 성공으로 내려줌
                     */
                    if(isOpptyOut){
                        Opportunity hqCollaboOppty = [SELECT BusinessType__c FROM Opportunity WHERE Id = :oppty.CollaborationBOId__c LIMIT 1];
                        String collabo_bizType = hqCollaboOppty.BusinessType__c;

                        if(originValidMap.containsKey('tRtnTypeCode')) {
                            String origin_tRtnTypeCode = String.valueOf(originValidMap.get('tRtnTypeCode'));
                            if(origin_tRtnTypeCode == 'M') {
                                String approvalTypeCode = '';
                                // 변경품의 Type Code
                                if(collabo_bizType == 'TI') approvalTypeCode = 'ZCRM000160';  // 구축형
                                if(collabo_bizType == 'TD') approvalTypeCode = 'ZCRM000310'; // 판매형
                                if(collabo_bizType == 'TS') approvalTypeCode = 'ZCRM000290'; // 서비스형
                                    
                                returnMap.put('COLLABO_RESULT', 'S');   // 성공
                                returnMap.put('COLLABO_MESSAGE', approvalTypeCode);   // Type Code
                            }
                        }
                    }

                }

                when 'ZPZ1' { // Lost Opportunity
                    System.debug('[ZPZ1]');
                    // if(oppty.LostReasonLogistics__c == null){
                    // Added by ANISH -START - v 1.8
                    // Added by Divyam Gupta - v 1.9
                    if(opptyAct.LostType__c == 'Z06'){
                        returnMap.put('RESULT', 'S');
                        returnMap.put('MESSAGE', 'ZCRM000080');
                    } // END by ANISH -START - v 1.8
                      // END by Divyam -START - v 1.9
                 }

                when 'ZPZ2' { // Drop Opportunity
                    System.debug('[ZPZ2]');
                    returnMap.put('RESULT', 'S');
                    if(bizType == 'TI')        returnMap.put('MESSAGE', 'ZCRM000090');
                    else if(bizType == 'TD')   returnMap.put('MESSAGE', 'ZCRM000350');
                    else if(bizType == 'TS')   returnMap.put('MESSAGE', 'ZCRM000260');
                    else                       returnMap.put('MESSAGE', 'ZCRM000090');
                }
                when 'ZPZ3' { // Agency Contract Exception
                    System.debug('[ZPZ3]');
                    // IF-055 / ECC BPO Status RFC ZP3MMD_BPO_STATUS 호출
                    Map<String, Object> resultMap_055 = eccBePayPurchDetail(opptyCode);
                    if(resultMap_055 != null) logList.add(resultMap_055.get('INTERFACE_LOG'));
                    System.debug('resultMap_055 : ' + resultMap_055);

                    if(Integer.valueOf(resultMap_055.get('StatusCode')) == 200){
                        OutputHeader_055 output_055 = (OutputHeader_055) JSON.deserialize(String.valueOf(resultMap_055.get('Response')), OutputHeader_055.class);
                        if(output_055.EV_STATUS != '1'){
                            returnMap.put('RESULT', 'F');
                            returnMap.put('MESSAGE', output_055.EV_MSGTXT);
                        } else {
                            returnMap.put('RESULT', 'S');
                            returnMap.put('MESSAGE', 'ZCRM000530');
                        }
                    }else{
                        returnMap.put('RESULT', 'F');
                        returnMap.put('MESSAGE', String.valueOf(resultMap_055.get('Response')));
                    }

                    
                }
                when 'ZPG1' { // Change Approval Request
                    System.debug('[ZPG1]');
                    returnMap.put('RESULT', 'S');
                    returnMap.put('MESSAGE', 'ZCRM000100');
                }
                //Start - Added by Anish-v 2.1
                when 'ZP21' { 
                    System.debug('[ZP21]');
                        returnMap.put('RESULT', 'S');
                        returnMap.put('MESSAGE', 'ZCRM000180');
                 }
                //End - Added by Anish-v 2.1
                when else {
                    returnMap.put('RESULT', 'F');
                    returnMap.put('MESSAGE', 'This activity type is not subject to pre-check.'); // This activity type is not subject to pre-check.
                }
            }

            returnMap.put('IFLOG', JSON.serialize(logList));
            returnMap.put('UPDATE_OPPTYLIST', JSON.serialize(updateOpptyList));
            
        }catch(Exception e){
            System.debug('**********************************************************************');
            System.debug(System.LoggingLevel.ERROR, ' e.getLineNumber() : ' + e.getLineNumber());
            System.debug(System.LoggingLevel.ERROR, ' e.getTypeName() : ' + e.getTypeName());
            System.debug(System.LoggingLevel.ERROR, ' e.getMessage() : ' + e.getMessage());
            System.debug('**********************************************************************');
            
            System.debug('ERROR : ' + e.getMessage());
        }

        return returnMap;
    }


    /**
     * 수주품의 Contract Approval Check
     * @param   opptyId
     * @return  Map<String, Object> 'RESULT'    => (String) 'F' or 'S' (사전점검 성공여부)
     *                              'MESSAGE'   => (String) '실패 시 오류 메시지' or '성공 시 ApprovalTypeCode' 
     *                              'IFLOG'     => (List<IF_LOG.InterfaceLog>) Interface Log List
     *                              'UPDATE_OPPTYLIST' => (List<Opportunity>) 업데이트 대상 Oppty List
     */
    public static Map<String, Object> validationCheck_ZP82(Id opptyId) {
        System.debug('[validationCheck_ZP82]');

        // Activity 결재 수주품의/변경품의 확인
        // * 완결, 전결, 후완결된 수주 품의가 하나 이상인경우 수주변경품의
        Boolean isChangeContractApproval = false;
        List<KnoxApproval__c> knoxApprovalCompletedList = [SELECT   Id, Status__c 
                                                            FROM    KnoxApproval__c 
                                                            WHERE   Opportunity__c = :opptyId 
                                                                    AND ActivityTransactionName__c = :OpportunityActivityHelper.ACT_CODE_CONTRACT_APPROVAL
                                                                    AND ( Status__c = :KnoxApprovalHelper.KNOX_APPROVAL_STATUS_COMPLETED
                                                                        OR Status__c = :KnoxApprovalHelper.KNOX_APPROVAL_STATUS_ARBITRARY_CONFIRMED
                                                                        OR Status__c = :KnoxApprovalHelper.KNOX_APPROVAL_STATUS_AFTER_CONFIRMED
                                                                        )
                                                            ];
        if(knoxApprovalCompletedList.size() > 0) {
            isChangeContractApproval = true;
        }

        String transactionName = OpportunityActivityHelper.ACT_CODE_CONTRACT_APPROVAL;
        Map<String, Object> returnMap = new Map<String, Object>();
        List<Object> logList = new List<Object>();
        List<Opportunity> updateOpptyList = new List<Opportunity>();

        Opportunity oppty = [SELECT Id, Name, StageName, CompanyCode__c, OpportunityCode__c, Collaboration__c, DealBreak__c, Construction__c, VRBMethod__c, BusinessType__c, LostReasonLogistics__c,
                                    Owner.CompanyCode__c, SalesDepartment__r.ZZCheck__c, cPrimarySalesDepartment__r.ZZCheck__c, SalesDepartment__r.Closed__c, cPrimarySalesDepartment__r.Closed__c
                             FROM   Opportunity
                             WHERE  Id =:opptyId]; //Modified by Anish-v 2.1

        Boolean dealBreak = oppty.DealBreak__c;
        String companyCode = oppty.CompanyCode__c;
        String opptyCode = oppty.OpportunityCode__c;
        String vrbMethod = oppty.VRBMethod__c;
        String bizType = oppty.BusinessType__c;
        String stage = oppty.StageName;
        String opptyOwnerCompanyCode = oppty.Owner.CompanyCode__c;
        Boolean isOpptyOwnerT100 = (opptyOwnerCompanyCode == 'T100') ? true : false;

        if(dealBreak){ // 사업기회의 Deal Break (ZZDEALBREAK) = 'X' (true)일 경우 오류처리
            returnMap.put('RESULT', 'F');
            returnMap.put('MESSAGE', Label.VAPP_MSG_008); // VAPP_MSG_008 / Deal Break BO cannot make Contract Approval.
        }else{
            // IF-056 / ECC 결재상신 사전점검 Interface 호출 (ZP3SDC_CHECK_CRM_APPROVAL_STAT)
            Map<String, Object> resultMap_056 = eccProjectStatusCheck(companyCode, opptyCode, transactionName);
            if(resultMap_056 != null) logList.add(resultMap_056.get('INTERFACE_LOG'));
            System.debug('[ZP82] - resultMap_056 : ' + resultMap_056);
            System.debug('[ZP82] - StatusCode : ' + resultMap_056.get('StatusCode'));

            if(Integer.valueOf(resultMap_056.get('StatusCode')) == 200){
                InputHeader_056 input_056 = (InputHeader_056) JSON.deserialize(String.valueOf(resultMap_056.get('Response')), InputHeader_056.class);
                System.debug('[ZP82] - input_056 : ' + input_056);

                Boolean isValidResult_056 = false;
                String approvalTypeCode  = '';
                String tRtnErrorMessage = '';
                String tRtnTypeCode = '';

                // 2021-05-05   hj.lee@dkbmc.com          IF-056 "T_RTN":[{"TYPE":"□"}] "□" 에 따른 체크 분기 로직 추가
                if(input_056.EV_RTNST != 'S'){
                    isValidResult_056 = false;
                } else {
                    isValidResult_056 = true;
                }

                List<INPUT_T_RTN> tRtnList = input_056.T_RTN;
                if(tRtnList != null) {
                    Integer tRtnCount = 0;
                    for(INPUT_T_RTN tRtn : tRtnList){
                        tRtnCount++;
                        
                        if(tRtnCount == 1){ // 처음 온 것 저장
                            tRtnTypeCode = tRtn.TYPE; 
                            tRtnErrorMessage = '';
                            if(tRtn.MESSAGE_V1 != null) tRtnErrorMessage = tRtn.MESSAGE_V1;
                            if(tRtn.MESSAGE_V2 != null) tRtnErrorMessage += tRtn.MESSAGE_V2;
                            if(tRtn.MESSAGE_V3 != null) tRtnErrorMessage += tRtn.MESSAGE_V3;//V2.0
                            if(tRtn.MESSAGE_V4 != null) tRtnErrorMessage += tRtn.MESSAGE_V4;//V2.0
                        }

                        if(tRtn.TYPE == 'E') { // Error Type 저장
                            tRtnTypeCode = tRtn.TYPE; 
                            tRtnErrorMessage = '';
                            if(tRtn.MESSAGE_V1 != null) tRtnErrorMessage = tRtn.MESSAGE_V1;
                            if(tRtn.MESSAGE_V2 != null) tRtnErrorMessage += tRtn.MESSAGE_V2;
                            if(tRtn.MESSAGE_V3 != null) tRtnErrorMessage += tRtn.MESSAGE_V3;//V2.0
                            if(tRtn.MESSAGE_V4 != null) tRtnErrorMessage += tRtn.MESSAGE_V4;//V2.0
                            break;
                        }
                    }

                    // 하기 로직 최초 수주품의 체크 (X)
                    // tRtnTypeCode check 로직은 변경수주품의 시 체크 (O)
                    if(isChangeContractApproval) {                        
                        switch on tRtnTypeCode {
                            when 'E' {
                                // E: 결재 진행불가  
                                isValidResult_056 = false;
                            }
                            when 'M' {
                                // M: 상신자가 T100(본사) 소속이면 에러메세지 보여주고 상신불가.(즉, 법인만 상신가능)
                                // * 결재 상신시 상신자가 Oppty Owner로 지정되어 상신되므로 Oppty Owner로 비교함
                                if(isOpptyOwnerT100)    isValidResult_056 = false; // 본사
                                else                    isValidResult_056 = true;  // 법인
                            }
                            when 'H' {
                                // H: 상신자가 T100(본사) 소속이 아니면 에러메세지 보여주고 상신불가.(즉, 본사(T100)만 상신가능)
                                if(!isOpptyOwnerT100)   isValidResult_056 = false; // 법인
                                else                    isValidResult_056 = true;  // 본사
                            }
                            when 'S' {
                                // S: 상신자가 T100(본사) 소속이면 에러메세지 보여주고 상신불가. (즉, 법인만 상신가능)
                                if(isOpptyOwnerT100)    isValidResult_056 = false; // 본사     
                                else                    isValidResult_056 = true;  // 법인
                            }
                            when else {		  
                                isValidResult_056 = true;
                            }
                        }
                    } 
                }
                
                // if-056 결과
                System.debug('isValidResult_056 : ' + isValidResult_056);
                System.debug('tRtnTypeCode : ' + tRtnTypeCode);
                System.debug('tRtnErrorMessage : ' + tRtnErrorMessage);


                /**
                 - ZP82 결재 유형 코드 정의
                - 최초품의와 변경품의 기준은 stage가 아닌 승인된 결재 여부로 판단.
                    A 구축형 (TI)
                    [ZCRM000150]-수주품의_구축형
                    [ZCRM000160]-수주변경 품의_구축형

                    B 판매형 (TD)
                    [ZCRM000300]-수주품의_판매형
                    [ZCRM000310]-수주변경품의_판매형

                    C 서비스형 (TS)
                    [ZCRM000280]-수주품의_서비스형
                    [ZCRM000290]-수주변경 품의_서비스형
                */
                if(bizType == 'TI'){ // 구축형
                    approvalTypeCode = 'ZCRM000150';
                    if(isChangeContractApproval) approvalTypeCode = 'ZCRM000160';
                } else if (bizType == 'TD') { // 판매형
                    approvalTypeCode = 'ZCRM000300';
                    if(isChangeContractApproval) approvalTypeCode = 'ZCRM000310';
                } else if (bizType == 'TS') { // 서비스형
                    approvalTypeCode = 'ZCRM000280';
                    if(isChangeContractApproval) approvalTypeCode = 'ZCRM000290';
                }
                    
                // if-056 결과 매핑
                if(isValidResult_056) {
                    returnMap.put('RESULT', 'S');
                    returnMap.put('MESSAGE', approvalTypeCode);

                    /**
                     * (2021-05-11 추가)
                     * 협업건중 법인/본사 같이 결재 상신되는건의 추가 처리 요청 [2021. 5. 7 요청]
                     *  IF-56 return 메세지 중 아래와 같이 "TYPE": "M" 이면서 정상적으로 상신되는 경우,
                     *   -현재는 법인 BO만 결재상태반영, 결재후처리가 수행되나,
                     *   -TO-BE 는 본사 BO에도 결재이력 반영, 결재상태반영, 결재후처리가 반영되도록 추가요청합니다.
                     */
                    returnMap.put('tRtnTypeCode', tRtnTypeCode);
                } else {
                    returnMap.put('RESULT', 'F');
                    returnMap.put('MESSAGE', Label.VAPP_MSG_002 + ' : ' + tRtnErrorMessage);
                }

                // [2021-03-25] IF-102 호출 삭제 (IF-56에 IF-102가 포함되어 삭제 요청)
                /*
                System.debug('[ZP82] - Collaboration__c : ' + oppty.Collaboration__c);
                if(!oppty.Collaboration__c){ 
                    // IF-102 / 협업 BO가 아닌 것을 대상으로, ECC Project Version Status 점검
                    Map<String, Object> resultMap_102 = eccProjectPetition(companyCode, opptyCode, 'S');
                    if(resultMap_102 != null) logList.add(resultMap_102.get('INTERFACE_LOG'));
                    System.debug('resultMap_102 : ' + resultMap_102);

                    if(Integer.valueOf(resultMap_102.get('StatusCode')) == 200){
                        InputHeader_102 input_102 = (InputHeader_102) JSON.deserialize(String.valueOf(resultMap_102.get('Response')), InputHeader_102.class);
                        if(input_102.EV_BO_CHECK != 'X'){
                            returnMap.put('RESULT', 'F');
                            returnMap.put('MESSAGE', Label.VAPP_MSG_009); // VAPP_MSG_009 / Please create BO and Project version first.
                        }else{
                            if(input_102.EV_PJT_CHECK != 'X'){
                                returnMap.put('RESULT', 'F');
                                returnMap.put('MESSAGE', Label.VAPP_MSG_010); // VAPP_MSG_010 / Please create Project version first.
                            }else{
                                returnMap.put('RESULT', 'S');
                                if(bizType == 'TI' || bizType == 'TS'){
                                    if(stage == OpportunityActivityHelper.OPP_STAGE_WON) {
                                        returnMap.put('MESSAGE', 'ZCRM000160');
                                    } else {
                                        returnMap.put('MESSAGE', 'ZCRM000150');
                                    }
                                }else if(bizType == 'TD'){
                                    if(stage == OpportunityActivityHelper.OPP_STAGE_WON) {
                                        returnMap.put('MESSAGE', 'ZCRM000310');
                                    }else { 
                                        returnMap.put('MESSAGE', 'ZCRM000310');
                                    }
                                }
                            }
                        }
                    }else{
                        returnMap.put('RESULT', 'F');
                        returnMap.put('MESSAGE', String.valueOf(resultMap_102.get('Message')));
                        System.debug('[ERROR] resultMap_102 - http request Error ');
                    }
                    */

            } else {
                // IF-056 Http Error
                System.debug('[ERROR] resultMap_056 - http request Error ' + String.valueOf(resultMap_056.get('StatusCode')));
                returnMap.put('RESULT', 'F');
                returnMap.put('MESSAGE', 'HTTP CODE [' +String.valueOf(resultMap_056.get('StatusCode')) + '] ' + String.valueOf(resultMap_056.get('IF_MSG')));
            }

            // 사업기회 실행 프로젝트에 대한 공사유무 Interface 수행 후 결과값으로 사업기회 공사유무(Construction__c)를 Update
            List<Project__c> projectList = [SELECT Id, Name, Opportunity__c, ProjectCode__c, DeletionFlag__c, ProjectType__c 
                                                FROM Project__c 
                                                WHERE Opportunity__c =: opptyId
                                                AND ProjectType__c = 'Execute Project'];
            System.debug('projectList : ' + projectList);
            if(projectList.size() > 0){
                Integer i = 0;
                for(Project__c project : projectList){
                    // IF-067 / 사업기회 실행 프로젝트에 대한 공사유무 Interface 수행 후 결과값으로 사업기회 공사유무(Construction__c)를 Update
                    Map<String, Object> resultMap_067 = eccProjectConstruct(project);
                    if(resultMap_067 != null) logList.add(resultMap_067.get('INTERFACE_LOG'));

                    if(Integer.valueOf(resultMap_067.get('StatusCode')) == 200){
                        InputHeader_067 input_067 = (InputHeader_067) JSON.deserialize(String.valueOf(resultMap_067.get('Response')), InputHeader_067.class);
                        if(input_067.EV_RETURN == 'Y'){
                            i++;
                        }
                    }else{
                        returnMap.put('RESULT', 'F');
                        returnMap.put('MESSAGE', String.valueOf(resultMap_056.get('Message')));
                    }

                }
                if(i > 0)   oppty.Construction__c = true;
                else        oppty.Construction__c = false;
                
                // [UPDATE] Update Opportunity List 추가
                updateOpptyList.add(oppty); // 확인 필요
            }

        }        
        if(logList.size() > 0) returnMap.put('IFLOG', logList);
        if(updateOpptyList.size() > 0) returnMap.put('UPDATE_OPPTYLIST', updateOpptyList);
        return returnMap;
    }

    // IF-055 / ECC BPO Status RFC ZP3MMD_BPO_STATUS 호출
    public static Map<String, Object> eccBePayPurchDetail(String opptyCode){
        IF_EccBePayPurchDetailController.ParamClass param = new IF_EccBePayPurchDetailController.ParamClass();
        param.boCode = opptyCode;

        Map<String, Object> resultMap = IF_EccBePayPurchDetailController.bePayPurchDetailChk(JSON.serialize(param));
        
        return resultMap;
    }

    // IF-056 / ECC 결재상신 사전점검 Interface 호출 (ZP3SDC_CHECK_CRM_APPROVAL_STAT)
    public static Map<String, Object> eccProjectStatusCheck(String companyCode, String opptyCode, String transactionName){
        IF_EccProjectStatusCheckContrller.OutputClass output = new IF_EccProjectStatusCheckContrller.OutputClass();
        output.IV_BUKRS = companyCode; // Company Code / Opportunity, CompanyCode__c, Company Code 
        output.IV_ZZORDER_ID = opptyCode; // BO코드 / Opportunity, OpportunityCode__c, 사업기회코드 
        output.IV_PS_TYPE = transactionName; // 프로세스 타입 / Opportunity, ActivityStatus__c, Current BO Activity Status 
        // output.IV_PSPID; // 프로젝트코드 / Project__c, ProjectCode__c, Project Code
        // output.IV_PJTCHK = 'X'; // Character Field Length 1 / "X"
        system.debug('StartTime KnoxApprovalValidate whole time'+datetime.now());
        Map<String, Object> resultMap = IF_EccProjectStatusCheckContrller.calloutProjectStatusCheck(JSON.serialize(output));
        system.debug('EndTime KnoxApprovalValidate whole time'+datetime.now());
        
        return resultMap;
    }

    // IF-067 / 사업기회 실행 프로젝트에 대한 공사유무 Interface 수행 후 결과값으로 사업기회 공사유무(Construction__c)를 Update
    public static Map<String, Object> eccProjectConstruct(Project__c project){
        IF_EccProjectConstructController.OutputHeader output = new IF_EccProjectConstructController.OutputHeader();
        output.IV_PSPID = project.ProjectCode__c;

        Map<String, Object> resultMap = IF_EccProjectConstructController.calloutProjectConstruct(JSON.serialize(output));
        
        return resultMap;
    }

    // IF-102 / 협업 BO가 아닌 것을 대상으로, ECC Project Version Status 점검
    // IF-102 호출 삭제 (IF-56에 IF-102가 포함되어 삭제 요청)
    /*
    public static Map<String, Object> eccProjectPetition(String companyCode, String opptyCode, String vrbMethod){
        IF_EccProjectPetitionController.OutputHeader output = new IF_EccProjectPetitionController.OutputHeader();
        output.IV_BUKRS = companyCode;
        output.IV_ORDERID = opptyCode;
        output.IV_STEP = vrbMethod;

        Map<String, Object> resultMap = IF_EccProjectPetitionController.calloutProjectPetition(JSON.serialize(output));

        return resultMap;
    }
    */

    // IF-134 / 최종원가판내 Confirm된 정보 가져오기
    public static Map<String, Object> sdGetConfirmInfo(String opptyCode, String version, String companyCode){
        IF_SdGetConfirmInfoController.InputClass input = new IF_SdGetConfirmInfoController.InputClass();
        input.IV_ZZORDER_ID = opptyCode;    // BO 코드
        input.IV_VERSION = version;         // vesrion 구분
        input.IV_BUKRS = companyCode;       // 회사코드

        Map<String, Object> resultMap = IF_SdGetConfirmInfoController.getInfo(input);

        return resultMap;
    }

    public class OutputHeader_055{
        @AuraEnabled
        public String EV_STATUS; // Status (1:Possibility,2:Impossibility)
        @AuraEnabled
        public String EV_MSGTY; // Message type: S Success, E Error, W Warning, I Info, A Abort
        @AuraEnabled
        public String EV_MSGTXT; // Message Text 
    }

    public class InputHeader_056{
        @AuraEnabled
        public String EV_VERSION;           // 프로젝트 버젼
        @AuraEnabled    
        public String EV_VNCRE;             // 변경사유코드
        @AuraEnabled    
        public String EV_RTNST;             // 메시지 유형: S 성공, E 오류, W 경고, I 정보, A 중단
        @AuraEnabled    
        public String EV_HURDLERATE_OK;     // Hurdle rate 통과여부
        @AuraEnabled    
        public String EV_CONTAPRO_OK;       // 법무계약검토번호.
        @AuraEnabled    
        public String EV_EXTERN_ACT_ID;     // 법무 계약 검토 번호
        @AuraEnabled    
        public String EV_PRESALE_LIMIT;     // 사전영업비 한도초과여부
        @AuraEnabled    
        public String EV_OUTCOME_YN;        // 외주개발비 존재여부
        @AuraEnabled    
        public String EV_OUTCOST_YN;        // 재료비/외주서비스비 존재여부
        @AuraEnabled    
        public String EV_EXCEPT;            // 법무검토 예외여부
        @AuraEnabled
        public String EV_PRESALES_YN;       // 사전영업비실적여부
        @AuraEnabled
        public String EV_OPERATING_INCOME;  // 영업이익률
        @AuraEnabled
        public List<INPUT_T_RTN> T_RTN;
    }

    public class INPUT_T_RTN{    
        @AuraEnabled
        public String TYPE;             // Message type: S Success, E Error, W Warning, I Info, A Abort
        @AuraEnabled
        public String ID;               // Message Class
        @AuraEnabled
        public String NUMBER_SFDC;      // Message Number
        @AuraEnabled
        public String MESSAGE;          // Message Text
        @AuraEnabled
        public String LOG_NO;           // Application log: log number
        @AuraEnabled
        public String LOG_MSG_NO;       // Application log: Internal message serial number
        @AuraEnabled        
        public String MESSAGE_V1;       // Message Variable
        @AuraEnabled        
        public String MESSAGE_V2;       // Message Variable
        @AuraEnabled        
        public String MESSAGE_V3;       // Message Variable
        @AuraEnabled        
        public String MESSAGE_V4;       // Message Variable
        @AuraEnabled
        public String PARAMETER;        // Parameter Name
        @AuraEnabled
        public String ROW;              // Lines in parameter
        @AuraEnabled
        public String FIELD;            // Field in parameter
        @AuraEnabled
        public String SYSTEM_SFDC;      // Logical system from which message originates
    }

    public class InputHeader_067{
        @AuraEnabled
        public String EV_RETURN; // Single-Character Indicator ( Y / N )
        @AuraEnabled
        public String EV_RETMSG; // Message Text
    }

    public class InputHeader_102{
        @AuraEnabled
        public String EV_EXIST;     // 단계진행여부 ('X' 존재, ' ' 존재하지않음 )
        @AuraEnabled
        public String EV_BO_CHECK;  // IV_STEP 에 따른 BO 상태 ('X' 존재, ' ' 존재하지않음 )
        @AuraEnabled
        public String EV_PJT_CHECK; // IV_STEP 에 따른 PJT 상태 ('X' 존재, ' ' 존재하지않음 )
    }

    public class outputHeader_134{
        @AuraEnabled 
        public String Opportunity_ID;
        @AuraEnabled 
        public String Version;
        @AuraEnabled 
        public String STATU;    
        @AuraEnabled 
        public String ZCONF;
        @AuraEnabled 
        public String Contract_Amt;
        @AuraEnabled 
        public String Operating_Profit;
        @AuraEnabled 
        public String Labor_MM;
    }

}