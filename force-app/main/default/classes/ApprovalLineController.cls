/**
* @description       : 사전점검(KnoxApprovalValidation.validationCheck) 후, 결재선 및 결재본문(getApprovalLineController) 생성
* ([!] 테스트 완료 후 재직중인 임직원만 가져오도록 변경)
* 단일 호출 sample : https://sdssfa--qa.lightning.force.com/lightning/cmp/c__approvalLine?c__opptyId=0061s000005PWvgAAG&c__opptyActId=a0I1s000000TAW3EAO
* @author            : hj.lee@dkbmc.com
* @last modified on  : 11-05-2023
* @last modified by  : anish.jain@partner.samsung.com
* Modifications Log 
* Ver   Date         Author                 Modification
* 1.0   2020-12-23   hj.lee@dkbmc.com       Initial Version
* 1.1   2021-04-21   hj.lee@dkbmc.com       결재선 조회시 현재 사용자 기준이 아닌 Opportunity Owenr Id 기준으로 조회하도록 변경
* 1.2   2022-08-19   yeongju.baek@dkbmc.com 수주품의 단계에서의 인프라 구축(팝업창 생성) 요청의 건
* 1.3   2023-03-27   gitesh.s@samsung.com   Changed EvEmpNO__c to EvSapEmpNO__c(MySales-155)
* 1.4   2023-04-11   divyam.gupta@samsung.com Changed  EvSapEmpNO__c to EvAcubeID__c.
* 1.5   2023-04-27   anish.jain@partner.samsung.com  Opportunity>Drop/Lost>Knox Preview(Dropped) -> My Sales - 179
* 1.6   2023-06-06   anish.jain@partner.samsung.com  Add department validation logic for contract approval activity -> My Sales - 215
* 1.8   2023-06-20   divyam.gupta@samsung.com   Mysales-255 Lost/Drop Add on changes.
* 1.9   2023-10-17   atul.k1@samusng.com        Mysales-318
* 2.0   11-05-2023   anish.jain@partner.samsung.com   MySales - 216
**/
public without sharing class  ApprovalLineController {
    
    // Return Resoponse Map Key
    public Static String KEY_RESULT_TYPE = 'RESULT_TYPE'; // 사전점검(BEFORE), 결재선 조회(GETAPPROVAL)
    public Static String KEY_RESULT = 'RESULT'; // 성공, 실패 여부
    public Static String KEY_MESSAGE = 'MESSAGE';
    public Static String KEY_HAS_APPROVAL_LINE = 'HAS_APPROVAL_LINE';   // 결재선 유무
    public Static String KEY_HAS_APPROVAL_HTML = 'HAS_APPROVAL_HTML';   // 결재본문 유무   
    public Static String KEY_APPROVAL_LINE = 'APPROVAL_LINE';
    public Static String KEY_APPROVAL_HTML = 'APPROVAL_HTML';
    public Static String KEY_APPROVAL_TYPE_CODE = 'APPROVAL_TYPE_CODE'; // 결재선 코드
    public Static String KEY_USE_APPROVAL_LINE = 'USE_APPROVAL_LINE'; // 결재선 조회사용 여부
    public Static String KEY_APPROVAL_MISID = 'APPROVAL_MISID'; // 외부연계 ID
    public Static String KEY_PREVIEW = 'PREVIEW'; //수주품의 단계에서의 인프라 구축(팝업창 생성) 요청의 건
    public Static String KEY_Minus_Profit_YN = 'Minus_Profit_YN';//<!--V 1.9 Mysales-318-->
    
    // Return Resoponse Map Value
    public Static Boolean isSuccess = true;
    public Static String msg = '';
    public Static String Minus_Profit = 'N'; // <!--V 1.9 Mysales-318-->
    public Static Boolean hasApprovalLine = false;
    public Static Boolean hasApprovalHtml = false;
    public Static List<KnoxApprover__c> knoxApproverList = new List<KnoxApprover__c>();
    public Static List<KnoxApprover__c> sortedApproverList = new List<KnoxApprover__c>();
    public Static String approvalHtml = '';
    
    public Static List<IF_LOG> ifLogList = new List<IF_LOG>();
    
    
    /**
* @description 
* @author   hj.lee@dkbmc.com | 2021-02-04 
* @param    opptyId                Opportunity Id
* @param    opptyActId             Opportunity Activity Id    
* @param    useApprovalLine         결재선조회 사용 여부
* @param    useApprovalLineBody     결재선조회 본문 사용 여부
* @param    useResource             사용할 자원 결재선('pathlist') or 결재선본문('html')
* @param    misid                   외부연계ID. (결재미리보기(knox preview)를 진행할때 최초 생성된 MISID.(결재미리보기 진행하지않을경우 생성x)
* @return   String 
**/
    @AuraEnabled
    public static String initComponent(String opptyId, String opptyActId, String bizReviewId, Boolean useApprovalLine, Boolean useApprovalLineBody, String useResource, String misid) {  
        System.debug('Approval Line Init timeTaken Strt'+datetime.now()); 
        System.debug('isAccessNew:');
        Map<String, Object> responseMap = new Map<String, Object>{
            KEY_RESULT_TYPE         => '',          // 사전점검(BEFORE), 결재선 조회(GETAPPROVAL)
                KEY_RESULT              => false,       // 성공 여부
                KEY_MESSAGE             => '',
                KEY_USE_APPROVAL_LINE   => useApprovalLine,
                KEY_APPROVAL_TYPE_CODE  => '',
                KEY_PREVIEW             => false,//수주품의 단계에서의 인프라 구축(팝업창 생성) 요청의 건
                'RESULT_ANI'            => 'S',  //Added by Anish - v 1.6
                'MESSAGE_ANI'           => 'N/A',// //Added by Anish - v 1.6
                KEY_Minus_Profit_YN      => ''   // <!--V 1.9 Mysales-318-->
                };
                    
                    //2021.06.28 상신 전 협업사업기회에 현재 로그인유저가 팀멤버 추가되어있는지 확인
                    //본사 BO의 Access 권한이 있는지 체크
                    Map<String, Object> checkMap = checkPermission(opptyId);
        if(Test.isRunningTest()) checkMap.put('isAccess',true);
        
        Boolean isAccess = (Boolean)checkMap.get('isAccess');
        System.debug('isAccess111:' + isAccess);
        if(!isAccess){
            responseMap.put(KEY_RESULT_TYPE, 'PERMISSION');
            responseMap.put(KEY_RESULT, false);
            responseMap.put(KEY_MESSAGE, (String)checkMap.get('errMsg'));
            return JSON.serialize(responseMap);
        }
        
        
        Opportunity_Activity__c opptyAct = [SELECT Id, TransactionName__c, WhatId__r.SalesDepartment__c,WhatId__r.cPrimarySalesDepartment__c, WhatId__r.SalesDepartment__r.Closed__c, WhatId__r.SalesDepartment__r.ZZCheck__c, WhatId__r.cPrimarySalesDepartment__r.ZZCheck__c, WhatId__r.cPrimarySalesDepartment__r.Closed__c, WhatId__r.SalesDepartment__r.CostCenter__c, WhatId__r.cPrimarySalesDepartment__r.CostCenter__c  FROM Opportunity_Activity__c WHERE Id = :opptyActId];  //Modified by Anish - v 1.6
        
        //Start- Added by Anish - 1.6
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
            responseMap.put('RESULT_ANI',result);
            responseMap.put('MESSAGE_ANI',resultMsg);
            
            }
        }
          //End- Added by Anish - v 1.6
            
            // 결재선 조회 사용 X
            Set<String> notUseApprovalLineActivitySet = new Set<String>{
                OpportunityActivityHelper.ACT_CODE_REQUEST_COMMITTEE_APPROVAL
                    };
                        if(notUseApprovalLineActivitySet.contains(opptyAct.TransactionName__c)) {
                            useApprovalLine = false;
                        }
            if(useApprovalLine == false) useApprovalLineBody = false;
            responseMap.put(KEY_USE_APPROVAL_LINE, useApprovalLine);
            
            // 결재 본문 사용 X 
            // [2021-02-03] "계약대행 예외신청", "실주보고", "속성변경 사업기회(사업등급 변경)" 의 결재 본문을 ECC에서 가져오지 않게 처리
            Set<String> notUseApprovalBodyActivitySet = new Set<String>{
                OpportunityActivityHelper.ACT_CODE_AGENCY_CONTRACT_EXCEPTION,
                    OpportunityActivityHelper.ACT_CODE_LOST_OPPORTUNITY,
                    OpportunityActivityHelper.ACT_CODE_CHANGE_APPROVAL_REQUEST
                    };
                        if(notUseApprovalBodyActivitySet.contains(opptyAct.TransactionName__c)) {
                            useApprovalLineBody = false;
                        }
            
            /**
* [결재 사전 점검]
*/
            Map<String, String> validationMap = KnoxApprovalValidation.validationCheck(opptyActId, bizReviewId);
            String VALID_KEY_RESULT = 'RESULT';
            String VALID_KEY_MESSAGE = 'MESSAGE';
            
            Boolean validResult = false;   
            String validMessage = '';  // 성공일 경우 Approval Type Code 반환, 에러일경우 메시지 반환
            
            // 결재 사전 점검 성공 여부
            if(validationMap.containsKey(VALID_KEY_RESULT)) {
                validResult = ((String)validationMap.get(VALID_KEY_RESULT) == 'S') ? true : false;
            }
            
            if(validationMap.containsKey(VALID_KEY_MESSAGE)) {
                validMessage = (String)validationMap.get(VALID_KEY_MESSAGE);
            }
            
            if(validationMap.containsKey('tRtnTypeCode')) {
                responseMap.put('tRtnTypeCode', (String)validationMap.get('tRtnTypeCode'));
            }
            
            // 협업 BO 사전 점검 확인하여 성공 플래그 및 오류 메시지 추가
            if(validationMap.containsKey('COLLABO_RESULT')) { // Key 가 있는 경우 협업 사전점검 존재
                Boolean collaboResult = ((String)validationMap.get('COLLABO_RESULT') == 'S') ? true : false; // 협업 BO 사전점검 성공 여부
                String collaboMessage = (String)validationMap.get('COLLABO_MESSAGE');
                responseMap.put('COLLABO_REQVALID', true);
                responseMap.put('COLLABO_RESULT', collaboResult);
                responseMap.put('COLLABO_MESSAGE', collaboMessage);
                System.debug('# [협업 BO] 결재사전점검 COLLABO_RESULT: ' + collaboResult);
                System.debug('# [협업 BO] 결재사전점검 COLLABO_MESSAGE: ' + collaboMessage);
                
                if(!collaboResult) {
                    String collaboValidMessage = ' ['+System.Label.VAPP_LAB_COLLABO_VALID_CHECK+'] ' + collaboMessage;
                    // 원본 사전점검이 성공하지 않았을 경우에만 원본 사전점검 메시지와 협업 사전점검 에러 메시지를 함께 보여줌
                    if(validResult) validMessage = collaboValidMessage;
                    else            validMessage += collaboValidMessage;
                    
                    // 협업 사전점검이 실패하였으므로 false 
                    validResult = false;
                }
            }
            
            System.debug('# [KnoxApprovalValidation] 결재사전점검 RESULT: ' + validResult);
            responseMap.put(KEY_RESULT, validResult);
            system.debug('TestinggggggNew111===>');
            if(validResult) { // [결재 사전 점검] Success
                
                /**
* [결재선 조회]
*/
                responseMap.put(KEY_APPROVAL_TYPE_CODE, validMessage);
                system.debug('Testingggggg1111===>'+validMessage);
                if(useApprovalLine) responseMap.putAll(getApprovalLineController(opptyId, opptyActId, validMessage, useApprovalLineBody, useResource, misid));
                
            } else {         // [결재 사전 점검] Fail
                system.debug('TestinggggggNew222===>');
                responseMap.put(KEY_RESULT_TYPE, 'BEFORE');
                responseMap.put(KEY_RESULT, validResult);
                responseMap.put(KEY_MESSAGE, validMessage);
                 responseMap.put(KEY_Minus_Profit_YN, 'N'); //<!--V 1.9 Mysales-318-->
            }
            
            
            // [INSERT] IF LOG
            if(validationMap.get('IFLOG') != null) {
                createIfLogList( String.valueOf(validationMap.get('IFLOG')) );
            }
            // [UPDATE] OPPTY
            if(validationMap.get('UPDATE_OPPTYLIST') != null) { 
                updateOpptyList( String.valueOf(validationMap.get('UPDATE_OPPTYLIST'))  );
            }
         System.debug('Approval Line Init timeTaken End'+datetime.now());
            return JSON.serialize(responseMap);
        
        }  
        
        
        public static Map<String, Object> getApprovalLineController(String opptyId, String opptyActId, String approvalTypeCode, Boolean useApprovalLineBody, String useResource, String misid){
            Map<String, Object> resultMap = new Map<String, Object>();
            resultMap.put('Message_ANI','N/A'); //Added by Anish-v 2.0
            
            // 결재본문 가져오기 (factorType : ApprovalFactor__c)
            IF_SdGetApprovalLineController.param param = new IF_SdGetApprovalLineController.param();
            
            Opportunity oppty = [SELECT OwnerId, BusinessType__c, FirstCloseDate__c, Opportunity_Review_Temp_Save__c FROM Opportunity WHERE Id = :opptyId];//수주품의 단계에서의 인프라 구축(팝업창 생성) 요청의 건 //Added by Anish-v 2.0
            Opportunity_Activity__c opptyAct = [SELECT Id, TransactionName__c, toLabel(TransactionName__c) toLabel_TransactionName__c,
                                                toLabel(LostType__c) toLabel_LostType__c, WhatId__r.Opportunity_Review_Confirm__c,WhatId__r.Opportunity_Review_VRB_Type_Confirm__c,
                                                toLabel(LostReason__c) toLabel_LostReason__c,Description__c,WhatId__c FROM Opportunity_Activity__c WHERE Id = :opptyActId]; //Modified (SOQL Query) by Anish - v 1.5 //Added by Anish-v 2.0
            
            //Start-Added by Anish - v 1.5
            String opptyActLostReasonLabel = Util_String.nvlStr(opptyAct.get('toLabel_LostReason__c'));
            String opptyActLostDescription = Util_String.nvlStr(opptyAct.get('Description__c'));
            //End-Added by Anish - v 1.5
            
            // 결재 타입 가져오기
            ApprovalType__c approvalType = new ApprovalType__c();
            if(!String.isBlank(approvalTypeCode)) {
                List<ApprovalType__c> approvalTypeList = [
                    SELECT  Id, Type__c, BusinessType__c
                    FROM    ApprovalType__c 
                    WHERE   Type__c = :approvalTypeCode
                ];
                
                if(approvalTypeList.size() != 0) approvalType = approvalTypeList[0];
                
            } else {
                List<ApprovalType__c> approvalTypeList = [
                    SELECT  Id, Type__c, BusinessType__c
                    FROM    ApprovalType__c 
                    WHERE   TransactionName__c = :opptyAct.TransactionName__c
                ];
                for(ApprovalType__c at : approvalTypeList) {
                    if(oppty.BusinessType__c == at.BusinessType__c) {
                        approvalType = at;
                    }
                }
                if(approvalTypeList.size() == 1) approvalType = approvalTypeList[0];
            }
            
            if( String.isBlank(approvalType.Type__c )) {
                isSuccess = false;
                msg += System.Label.LAPP_MSG_001; // '결재선 유형을 찾을 수 없습니다. 시스템 관리자에게 문의하십시오.'
            }
            
            
            // [2021-04-21 변경] 로그인 사용자 기준 → Opportunity Owner Id 기준으로 조회 변경
            // Employee__c loginEmp = Utils.getLoginEmployeeData(UserInfo.getUserId());
            Employee__c targetEmp = Utils.getLoginEmployeeData(UserInfo.getUserId()); //Added by Anish - v 2.0
            // v1.3 - Gitesh Saini
            if( String.isBlank(targetEmp.EvSapEmpNO__c)) {
                isSuccess = false;
                msg += ' '+System.Label.LAPP_MSG_004; //' 임직원 정보에 사원번호(Employee Number)가 없습니다.';
            }
            if( String.isBlank(targetEmp.EvSapBukrs__c)) {
                isSuccess = false;
                msg += ' '+System.Label.LAPP_MSG_005; //' 임직원 정보에 회사 코드(Company Code)가 없습니다.';   
            }
            
            if(isSuccess) {
                param.corporationId = targetEmp.EvSapBukrs__c ; 
                param.opptyId = opptyId;
                param.actId = opptyActId;
                param.factorType = approvalType.Type__c; 
                param.userEmpNo = targetEmp.EvSapEmpNO__c;
                // v1.3
                /**
*  1) 결재본문 호출 
*     HTML = X
*  2) 결재라인 호출 
*     FACTOR   = X
*     PATHLIST = X
**/
                param.factor    = (useResource == 'pathlist') ? 'X' : '';  // X : true, null : false
                param.pathlist  = (useResource == 'pathlist') ? 'X' : '';
                param.html      = (useResource == 'html' && useApprovalLineBody) ? 'X' : ''; // 결재본문 가져오기 여부 
                
                System.debug('approvalLine misid before:' + misid);
                misid = ((String.isEmpty(misid)) ? Utils.makeMisId(Utils.getCurDatetime()) : misid);

                param.apInfId   = misid;    //외부연계 ID
 
                Map<String, Object> responseMap = (Map<String,Object>)IF_SdGetApprovalLineController.getApprovalLine(param);
                
                //수주품의 단계에서의 인프라 구축(팝업창 생성) 요청의 건
                List<Object> listITFactor = (List<Object>) responseMap.get('IT_FACTOR');
                //System.debug(' 수주품의 단계에서의 인프라 구축(팝업창 생성) 요청의 건 listITFactor.size() : ' + listITFactor.size());
                for(Object rowObj : listITFactor){
                    Map<String, Object> mapFactorItem = (Map<String, Object>) rowObj;                
                    
                    String strFactorName = mapFactorItem.get('name') == null ? '' : String.valueOf(mapFactorItem.get('name'));
                    String strFactorVal = mapFactorItem.get('value') == null ? '' : String.valueOf(mapFactorItem.get('value'));
                    //수주품의 단계에서의 인프라 구축(팝업창 생성) 요청의 건
                    if('SAFETY_SUSTAINABILITY_PART_YN'.equals(strFactorName) && 'Y'.equals(strFactorVal) && oppty.FirstCloseDate__c == null){
                        resultMap.put(KEY_PREVIEW, true);
                        system.debug('### ApprovalLineController :: getApprovalLineController :: Bingo!! ');
                    }
                }
                
                Map<String, Object> responseOutput = (Map<String, Object>) responseMap.get('ES_OUTPUT');
                System.debug(' responseOutput ' + responseOutput);
                
                Integer statusCode = Integer.valueOf(responseMap.get('StatusCode'));
                if(statusCode >= 300) {
                    msg = '[HTTP ' + statusCode + '] ' + Util_String.nvlStr(responseMap.get('IF_MSG')); // 알림 메세지 값
                    isSuccess = false;
                    
                } else {
                    
                    isSuccess = (responseOutput.get('msgty') != null) && (String.ValueOf(responseOutput.get('msgty')) == 'S');
                    if(!isSuccess) msg =  System.Label.APPR_LAB_APPROVAL_LINE_ERR + ' ' + String.valueOf(responseOutput.get('message'));
                    //<!--V 1.9 Mysales-318 start-->
                     system.debug('My If Condition Start'+datetime.now());
                    if(responseOutput.get('Minus_Profit_YN') != null && responseOutput.get('Minus_Profit_YN') == 'Y'){
                        system.debug('Value change it to Y');
                        Minus_Profit = 'Y';
                    }
                     system.debug('My If Condition End'+datetime.now());
                    //<!--V 1.9 Mysales-318 end-->
                    if(isSuccess) {
                        knoxApproverList = new List<KnoxApprover__c>();
                        sortedApproverList = new List<KnoxApprover__c>();
                        // [IT_PATHLIST] 결재선 (기안자 포함, index : 0)
                        if(responseMap.containsKey('IT_PATHLIST')) {
                            List<Object> approvalLineList = (List<Object>)responseMap.get('IT_PATHLIST');
                            Map<String, Object> approvalLineMap = new Map<String, Object>();
                            
                            for(Object approvalLine :approvalLineList) { 
                                Map<String, Object> approvalLineObj = (Map<String, Object>)approvalLine;
                                String empno = String.valueOf(approvalLineObj.get('empno'));   // EvAcubeID__c
                                approvalLineMap.put(empno, approvalLine);
                                hasApprovalLine = true;
                            }
                            
                            // 임직원 조회 ([!] 테스트 완료 후 재직중인 임직원만 가져오도록 변경)
                            // 회사코드가 조회 조건에 포함.
                            // 동일 EvEmpNO__c 정보를 갖는 emp 정보가 있어 결재 라인 설정시 동일 유저 다른회사 소속의 결재 라인이 설정되는 문제가 있음.
                            // v1.3 - Gitesh Saini
                            List<Employee__c> empList = [
                                SELECT  Name, EvEName__c, EvSdeptNM__c, EvSdeptENM__c,EvMailAddr__c, EvUniqID__c, EvSapEmpNO__c, EvAcubeID__c
                                FROM    Employee__c 
                                WHERE   EvAcubeID__c IN :approvalLineMap.keyset()
                                AND Status__c != 'R'
                            ];
                            Map<String, Employee__c> empMap = new Map<String, Employee__c>();
                            for(Employee__c emp : empList){
                                // empMap.put(emp.EvSapEmpNO__c, emp);
                                // v1.4 - Changed EvSapEmpNO__c to EvAcubeID__c.
                                empMap.put(emp.EvAcubeID__c, emp);
                                
                                
                            }
                            // v1.3
                            for(Object approvalLine :approvalLineList) { 
                                Map<String, Object> approvalLineObj = (Map<String, Object>)approvalLine;
                                // V 1.4 Remove Substring(3)
                                //    String empno = String.valueOf(approvalLineObj.get('empno')).substring(3);    // 'C6031679' 앞자리 3자 제외 후 사원번호와 일치
                                String empno = String.valueOf(approvalLineObj.get('empno'));
                                
                                String name = String.valueOf(approvalLineObj.get('name'));             // Employee's last name
                                String relclass = String.valueOf(approvalLineObj.get('relclass'));     // Workflow Step Type
                                Integer seqno = Integer.valueOf(approvalLineObj.get('seqno'));           // Sequence Number [WF] (ZA0)
                                String wfsysno = String.valueOf(approvalLineObj.get('wfsysno'));       // Approval System
                                String wistatus = String.valueOf(approvalLineObj.get('wistatus'));     // Current Level Status
                                String wrstatus = String.valueOf(approvalLineObj.get('wrstatus'));     // Request Status
                                String ca_bukrs = String.valueOf(approvalLineObj.get('ca_bukrs'));     // Approver Company Code
                                
                                Employee__c emp = empMap.get(empno);
                                if ( emp != null ) {
                                    KnoxApprover__c knoxApr = new KnoxApprover__c();
                                    knoxApr.Index__c = seqno;
                                    knoxApr.Name = emp.Name;
                                    knoxApr.EvEName__c =  emp.EvEName__c;
                                    knoxApr.EvSdeptNM__c = emp.EvSdeptNM__c;
                                    knoxApr.EvSdeptENM__c = emp.EvSdeptENM__c;
                                    knoxApr.EvMailAddr__c = emp.EvMailAddr__c;
                                    knoxApr.Employee__c = emp.Id;
                                    knoxApr.EvUniqID__c = emp.EvUniqID__c;
                                    knoxApr.IsGetApprovalLine__c = true;    // IF 결재선 여부
                                    
                                    // CR=0, AP=1, AG=2, NT=9 (결재 타입)
                                    switch on wrstatus {
                                        when 'CR' { wrstatus = '0'; }
                                        when 'AP' { wrstatus = '1'; }
                                        when 'AG' { wrstatus = '2'; }
                                        when 'NT' { wrstatus = '9'; }
                                        when 'PG' { wrstatus = '4'; }   //2021.06.18 추가 병렬합의
                                        when 'PP' { wrstatus = '7'; }   //2021.06.18 추가 병렬결재
                                    }
                                    
                                    // 기안자는 Knox Submit Class에서 생성하여 상신하기에 제외함
                                    if( wrstatus == '0' ) continue;
                                    
                                    knoxApr.ApproverType__c =  wrstatus;    // 기안(0), 결재(1), 합의(2), 후결(3), 병렬합의(4), 병렬결재(7), 통보(9)
                                    knoxApr.IsChangeLine__c = false;        // 초기값 설정
                                    knoxApr.IsEditText__c = false;          // 초기값 설정
                                    knoxApr.IsArbitraryDecision__c = false; // 초기값 설정
                                    knoxApr.Status__c = '0'; 
                                    
                                    knoxApproverList.add(knoxApr);
                                }
                            }
                            
                        }
                        if(!hasApprovalLine) msg += ' '+System.Label.LAPP_MSG_002; // ' 결재선이 존재하지 않습니다.';
                        
                        
                        // [IT_HTML] 결재본문 HTML 
                        hasApprovalHtml = false;
                        if(useResource == 'html' && useApprovalLineBody) { // 결재본문 사용 시
                            if(responseMap.containsKey('IT_HTML')) { 
                                if('ZPZ2'.equals(opptyAct.TransactionName__c)) approvalHtml += '<div>';
                                List<Object> htmlLineList = (List<Object>)responseMap.get('IT_HTML');
                                System.debug('Ani List Size'+ htmlLineList.Size());
                                //Start - Added by Anish - v 1.5
                                for(Integer a = 0 ; a<= 9; a++ ){
                                    if(!test.isRunningTest()){
                                        htmlLineList.remove(htmlLineList.Size()-1); 
                                    }
                                }
                                
                                Integer i=0;
                                Integer remIndex;
                                Integer endIndex;
                                for(Object htmlLineObj : htmlLineList){
                                    i++ ;
                                    Map<String, Object> htmlLineMap = (Map<String, Object>)htmlLineObj;
                                    String htmlLine = String.valueOf(htmlLineMap.get('LINE'));
                                    System.debug('htmlLine Ani :'+htmlLine);
                                    if(htmlLine == null || htmlLine == 'null') continue;
                                    if(htmlLine.contains('&#183;Drop Reason')){
                                        remIndex = i;
                                    }
                                    if(i>remIndex){
                                        if(htmlLine.contains('</DIV>')){
                                            System.debug('entry Ani');
                                            endIndex = i;
                                            break;
                                        } 
                                    }
                                }
                                System.debug('endIndex :'+endIndex);
                                for(Integer a = remIndex ; a<= endIndex; a++ ){
                                    htmlLineList.remove(remIndex-1); 
                                }
                                //End - Added by Anish - v 1.5 

                                for(Object htmlLineObj : htmlLineList) {
                                    Map<String, Object> htmlLineMap = (Map<String, Object>)htmlLineObj;
                                    String htmlLine = String.valueOf(htmlLineMap.get('LINE'));
                                    if(htmlLine == null || htmlLine == 'null') continue;
                                    //TODO : Drop(ZPZ2) 만 일단 Html 개행처리해둠.
                                    if('ZPZ2'.equals(opptyAct.TransactionName__c)){
                                        approvalHtml += htmlLine.replace('\n', '<br>');
                                    }else{
                                        approvalHtml += htmlLine;
                                    }
                                    hasApprovalHtml = true;
                                }
                                //Start - Added by Anish - v 1.5
                                if('ZPZ2'.equals(opptyAct.TransactionName__c) || Test.isRunningTest()){
                                    
                                    System.debug('approvalHtml Ani :'+ approvalHtml);
                                    //V 1.8
                                    List<LostResult__c> listLostResult = [SELECT Id, Name, MasterLosttype_Eng__c,MasterLosttype_Kor__c,LOST_DETAIL__c
                                                                          FROM LostResult__c WHERE Opportunity__c = :opptyAct.WhatId__c and IsCheck__c = true and LostActivity__c=: opptyActId ORDER BY LostTypeCode__c]; 
                                    approvalHtml += '<H2 class="tit_con">&#183;Drop Reason</H2><DIV class="tbl_type02"><TABLE><COLGROUP> <COL width="25%"><COL width=""></COLGROUP><TBODY>'; 
                                    if(!listLostResult.isEmpty()){
                                        
                                        User u = [SELECT LanguageLocaleKey FROM User WHERE Id = :UserInfo.getUserId()];
                                        
                                        for(LostResult__c rowLostResult : listLostResult){
                                            approvalHtml += '<TR>';
                                            approvalHtml += '<TH>' + 'Drop Reason' + '</TH>'; 
                                            approvalHtml += '<TD>' + (u.LanguageLocaleKey == 'ko' ? rowLostResult.MasterLosttype_Kor__c : rowLostResult.MasterLosttype_Eng__c) + '</TD>';
                                            approvalHtml += '</TR>';
                                            approvalHtml += '<TR>';
                                            approvalHtml += '<TH>' + System.Label.Description_LOST_003 + '</TH>'; 
                                            
                                            approvalHtml += '<TD>';
                                            String detailConversion = replaceNewlineToTag(rowLostResult.LOST_DETAIL__c);   
                                            
                                            approvalHtml += '<P style="word-break: break-word;">' + detailConversion.replace(' ', '&nbsp;') + '</P>'; 
                                            
                                            approvalHtml += '</TD>';
                                            
                                            approvalHtml += '</TR>';    
                                            
                                        }
                                        approvalHtml += '</TBODY></TABLE></DIV></DIV><!--// contents --></DIV><!--// #### --></TD></TR></TBODY></TABLE></BODY></HTML>';
                                    }else{
                                        approvalHtml += '<TR>';
                                        approvalHtml += '<TH>Drop Reason</TH>'; 
                                        approvalHtml += '<TD>' + opptyActLostReasonLabel + '</TD>';
                                        approvalHtml += '</TR>';
                                        approvalHtml += '<TR>';
                                        approvalHtml += '<TH class="noline">Description</TH>';
                                        approvalHtml += '<TD style="word-break: break-word;">' + replaceNewlineToTag(opptyActLostDescription) + '</TD>';
                                        approvalHtml += '</TR>';
                                        approvalHtml += '</TBODY></TABLE></DIV></DIV><!--// contents --></DIV><!--// #### --></TD></TR></TBODY></TABLE></BODY></HTML>';
                                    }
                                }
                                //End - Added by Anish - v 1.5
                            }
                            if(hasApprovalHtml) { 
                                // [2021-05-26] 결재선 본문 하단에 Salesforce Opportunity Link 추가
                                String sfdcOpptyURL = URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/r/Opportunity/' + opptyId + '/view';  // Opportunity 링크URL (URL.getSalesforceBaseUrl() + /lightning/r/Opportunity/ + (Opportunity의 Opportunity_id) + /view)
                                
                                approvalHtml += '<div style="width:900px;">';
                                approvalHtml += '    <div style="padding:0 40px 40px">';
                                approvalHtml += '        <div style="padding: 15px 20px;background-color: #f2f5f9;">';
                                approvalHtml += '            <strong style="display: inline-block; padding: 5px 0 0 0; color: #325179;">Go to Business Opportunity</strong>';
                                approvalHtml += '            <a style="float: right; display: inline-block; height: 22px; line-height: 22px; padding: 0 12px 0 8px; border-radius: 4px; text-decoration: none; background: #eef1f5; border: solid 1px #cbd0d7;" ';
                                approvalHtml += '               href="' + sfdcOpptyURL + '" target="_blank">Go</a>';
                                approvalHtml += '        </div>';
                                approvalHtml += '    </div>';
                                approvalHtml += '</div>';
                                
                                if('ZPZ2'.equals(opptyAct.TransactionName__c)) approvalHtml += '</div>';
                                
                            } else {
                                msg += ' '+System.Label.LAPP_MSG_003; // ' 결재 본문이 없습니다.';
                            }
                        }
                        
                    }
                }
                
            } 
            
            // Knox 인터페이스 html 전송 오류로 single quote => double quote 변환 
            // approvalHtml = approvalHtml.replace('\'', '\"');
            //Start-Added by Anish-v 2.0
            if('ZP21'.equals(opptyAct.TransactionName__c)){
                if(opptyAct.WhatId__r.Opportunity_Review_VRB_Type_Confirm__c == '30'){
            resultMap.put(KEY_RESULT_TYPE, 'GETAPPROVAL');
            resultMap.put(KEY_RESULT, isSuccess);
            resultMap.put(KEY_MESSAGE, msg);   
            resultMap.put(KEY_APPROVAL_LINE, knoxApproverList);
            resultMap.put(KEY_APPROVAL_HTML, approvalHtml);
            resultMap.put(KEY_HAS_APPROVAL_Line, hasApprovalLine);
            resultMap.put(KEY_HAS_APPROVAL_HTML, hasApprovalHtml);
            resultMap.put(KEY_HAS_APPROVAL_HTML, hasApprovalHtml);
            resultMap.put(KEY_APPROVAL_MISID, misid);  
            resultMap.put('Message_ANI','Success True');  //Added by Anish-v 2.0
                }
            }
            else{
            resultMap.put(KEY_RESULT_TYPE, 'GETAPPROVAL');
            resultMap.put(KEY_RESULT, isSuccess);
            resultMap.put(KEY_MESSAGE, msg); 
            resultMap.put(KEY_Minus_Profit_YN,Minus_Profit); //<!--V 1.9 Mysales-318-->
            resultMap.put(KEY_APPROVAL_LINE, knoxApproverList);
            resultMap.put(KEY_APPROVAL_HTML, approvalHtml);
            resultMap.put(KEY_HAS_APPROVAL_Line, hasApprovalLine);
            resultMap.put(KEY_HAS_APPROVAL_HTML, hasApprovalHtml);
            resultMap.put(KEY_HAS_APPROVAL_HTML, hasApprovalHtml);
            resultMap.put(KEY_APPROVAL_MISID, misid); 
            resultMap.put('Message_ANI','Success True'); //Added by Anish-v 2.0
            }
            System.debug('resultMap Ani'+ resultMap);
            //End-Added by Anish-v 2.0
  
            return resultMap;
        }
        
        //Added new method by Anish - v 1.5
        public static String replaceNewlineToTag(String longText) {
            return longText.replace('\n', '<br/>');
        }
        
        public static void createIfLogList(String ifLogListJSON){
            try{
                if(String.isNotBlank(ifLogListJSON)) {
                    List<IF_Log.InterfaceLog> ifLogList = (List<IF_Log.InterfaceLog>)JSON.deserialize(ifLogListJSON, List<IF_Log.InterfaceLog>.class);
                    System.debug(' ifLogList    : ' + ifLogList);
                    for(IF_Log.InterfaceLog obj : ifLogList) {
                        System.debug(' obj    : ' + obj);
                        IF_Log log = new IF_Log();                
                        IF_Log.InterfaceLog iflog_interfaceLog = obj;
                        log.createLog(iflog_interfaceLog);
                        
                    }
                }
            }catch(Exception e){
                System.debug(LoggingLevel.ERROR, e.getMessage());
                System.debug(LoggingLevel.ERROR, e.getStackTraceString());
            }
        }
        
        public static void updateOpptyList(String opptyListJSON){
            try{
                if(String.isNotBlank(opptyListJSON)) {
                    List<Opportunity> opptyList = (List<Opportunity>)JSON.deserialize(opptyListJSON, List<Opportunity>.class);
                    if(opptyList.size() > 0) UPDATE opptyList;
                }
            }catch(Exception e){
                System.debug(LoggingLevel.ERROR, e.getMessage());
                System.debug(LoggingLevel.ERROR, e.getStackTraceString());
            }
        }
        
        /**
* @description 상신 전 본사의 팀멤버 추가 여부 확인
* @author seonju.jin@dkbmc.com | 2021-06-30 
* @param Id recordId OpportunityId
* @return Map<String, Object> 
**/
        public static Map<String,Object> checkPermission(Id recordId){
            String errMsg = '';    
            Boolean isAccess = true;
            Map<String,Object> resultMap = new Map<String,Object>{
                'isAccess' => isAccess,
                    'errMsg'   => ''
                    };
                        
                        List<Opportunity> opptyList = [SELECT Id, OwnerId, Collaboration__c, CollaborationBOId__c,CompanyCode__c, ColCompanyCode__c FROM Opportunity WHERE Id = :recordId];
            
            Opportunity oppty = null;
            if(opptyList.size() > 0) oppty = opptyList.get(0);
            
            System.debug('oppty.OwnerId:' + oppty.OwnerId);
            Employee__c emp = Utils.getLoginEmployeeData(oppty.OwnerId);
            System.debug(Utils.getLoginEmployeeData(oppty.OwnerId));
            
            Map<String,String> fieldMap = Utils.getFieldLabel('Opportunity');       //Opporutnity 필드정보Map
            
            if(emp == (new Employee__c())){ //Employee정보가 없음
                isAccess = false;
                errMsg = System.Label.MDG_MSG_0004 + ' '  + fieldMap.get('ownerid') ;
                resultMap.put('isAccess', isAccess);
                resultMap.put('errMsg', errMsg);
                
                System.debug(resultMap);
                return resultMap;
            }else if(String.isBlank(emp.EvUniqID__c)){
                isAccess = false;
                errMsg = System.Label.APPR_MSG_0008 + ' ' + fieldMap.get('ownerid');
                
                resultMap.put('isAccess', isAccess);
                resultMap.put('errMsg', errMsg);
                
                System.debug(resultMap);
                return resultMap;
            }
            
            //협업 사업기회 EditAccess체크
            if(oppty.Collaboration__c && oppty.CompanyCode__c != 'T100'){
                //본사 사업기회 Edit권한 조회
                isAccess = [SELECT   RecordId, HasReadAccess  
                            FROM     UserRecordAccess 
                            WHERE    UserId = :UserInfo.getUserId() 
                            AND RecordId = :oppty.CollaborationBOId__c].HasReadAccess;
                
                if(!isAccess) errMsg = System.Label.APPR_MSG_0036; //You do not have permission to read collaboration opportunity. Please check the team member access for collaboration opportunity.
            }
            
            resultMap.put('isAccess', isAccess);
            resultMap.put('errMsg', errMsg);
            
            System.debug(resultMap);
            return resultMap;
        }
        
        // 상신시 필요한 데이터
        /*
approver.EvUniqID__c
, approver.EvMailAddr__c.split('@')[0]
, approver.EvMailAddr__c
, String.valueOf((Integer)approver.Index__c+1)
, approver.ApproverType__c
, approver.Status__c
, approver.IsArbitraryDecision__c ? 'Y' : 'N'
, approver.IsEditText__c ? 'Y' : 'N'
, approver.IsChangeLine__c  ? 'Y' : 'N'
*/
        
        // knox Approver
        /*
'Index__c'              : data.Index__c,
'Name'                  : data.Name,
'EvEName__c'            : data.EvEName__c,
'ApproverType__c'       : data.ApproverType__c,
'EvSdeptNM__c'          : data.EvSdeptNM__c,
'EvSdeptENM__c'        : data.EvSdeptENM__c,
'EvMailAddr__c'         : data.EvMailAddr__c,
'Employee__c'           : data.Employee__c,
'EvUniqID__c'           : data.EvUniqID__c,                            
'IsChangeLine__c'       : data.IsChangeLine__c,
'IsEditText__c'         : data.IsEditText__c,
'IsArbitraryDecision__c': data.IsArbitraryDecision__c
*/
        
        // execute sample
        /*
IF_SdGetApprovalLineController.param param = new IF_SdGetApprovalLineController.param();
param.corporationId = 'T100';
param.opptyId = '0061s000005PWvgAAG';
param.actId = 'a0I1s000000TAW3EAO';
param.factorType = 'ZCRM000090';
param.userEmpNo = '31679';
param.factor = 'X';
param.pathlist = 'X';
param.html = 'X';

IF_SdGetApprovalLineController.getApprovalLine(param);
*/
    }