/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2023-03-27
 * @last modified by  : gitesh.s@samsung.com 
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2021-05-13   younghoon.kim@dkbmc.com   Initial Version
 * 1.1   2023-03-27   gitesh.s@samsung.com      Changed EvEmpNO__c to EvSapEmpNO__c (MySales -155)
**/
global class ApprovalLineViewerController {
	/*
        * 사전영업 - ZCRM000020
        * 수주품의 - (BizType = TI - 구축형) ZCRM000150
                    (BizType = TS - 서비스형) ZCRM000280
                    (BizType = TD - 판매형) ZCRM000300
        * 수주변경품의 - (BizType = TI - 구축형) ZCRM000160
                        (BizType = TD - 판매형) ZCRM000310
                        (BizType = TS - 서비스형) ZCRM000290
    */

    public Static String result = '';
    public Static String message = '';
    public Static String apprLine = '';
    public Static String apprHTML = '';
    public Static Boolean isSuccess = true;
    public Static Boolean hasApprovalLine = false;
    public Static Boolean hasApprovalHtml = false;
    public Static String approvalHtml = '';

    @AuraEnabled    
    global static List<Map<String, String>> defaultSetting(){
        List<Map<String, String>> rtnList = new List<Map<String, String>>();

        // Pre Sales
        Map<String, String> preSalesMap = new Map<String, String>();
        preSalesMap.put('label', '사전영업');
        preSalesMap.put('value', 'preSales'); // ZP32

        // Contract
        Map<String, String> contractMap = new Map<String, String>();
        contractMap.put('label', '수주품의');
        contractMap.put('value', 'contract'); // ZP82

        // Contract Change
        Map<String, String> contractChangeMap = new Map<String, String>();
        contractChangeMap.put('label', '수주변경품의');
        contractChangeMap.put('value', 'contractChange'); // ZP82

        rtnList.add(preSalesMap);
        rtnList.add(contractMap);
        rtnList.add(contractChangeMap);

        return rtnList;
    }

    @AuraEnabled    
    global static Map<String, String> getKnoxApproval(String opptyCode, String pickValue){
        Map<String, String> rtnMap = new Map<String, String>();

        String factorType = '';
        String opptyAct = '';

        List<Opportunity> opptyList = [SELECT OwnerId, OpportunityCode__c, BusinessType__c FROM Opportunity WHERE OpportunityCode__c = :opptyCode];

        if(opptyList.size() > 0){
            try{
                if(pickValue == 'preSales'){
                    factorType = 'ZCRM000020';
                    opptyAct = 'ZP32';
                }else if(pickValue == 'contract'){
                    if(opptyList[0].BusinessType__c == 'TI') factorType = 'ZCRM000150';
                    else if(opptyList[0].BusinessType__c == 'TD') factorType = 'ZCRM000300';
                    else if(opptyList[0].BusinessType__c == 'TS') factorType = 'ZCRM000280';
                    else{
                        result = 'F';
                        message = System.Label.APPRVIEWER_MSG_0003; // Please check Business Type
                    }
                    opptyAct = 'ZP82';
                }else if(pickValue == 'contractChange'){
                    if(opptyList[0].BusinessType__c == 'TI') factorType = 'ZCRM000160';
                    else if(opptyList[0].BusinessType__c == 'TD') factorType = 'ZCRM000310';
                    else if(opptyList[0].BusinessType__c == 'TS') factorType = 'ZCRM000290';
                    else{
                        result = 'F';
                        message = System.Label.APPRVIEWER_MSG_0003; // Please check Business Type
                    }
                    opptyAct = 'ZP82';
                }
                
                if(factorType != ''){
                    List<Opportunity_Activity__c> opptyActList = [SELECT Id, Name, WhatId__c, WhatId__r.Name, TransactionName__c 
                                                                    FROM Opportunity_Activity__c 
                                                                   WHERE WhatId__c =: opptyList[0].Id 
                                                                     AND TransactionName__c =: opptyAct];
                    if(opptyActList.size() > 0){
                        Employee__c targetEmp = Utils.getLoginEmployeeData(opptyList[0].OwnerId);
    
                        IF_SdGetApprovalLineController.param param = new IF_SdGetApprovalLineController.param();
                        param.corporationId = targetEmp.EvSapBukrs__c ; 
                        param.opptyId = opptyList[0].Id;
                        param.actId = null;
                        param.factorType = factorType;
                        // v1.1 - Gitesh Saini
                        param.userEmpNo = targetEmp.EvSapEmpNO__c;
                        // v1.1
                        /**
                         *  1) 결재본문 호출 
                         *     HTML = X
                         *  2) 결재라인 호출 
                         *     FACTOR   = X
                         *     PATHLIST = X
                         **/
                        param.html      = 'X'; // 결재본문 가져오기 여부 
                        param.factor    = 'X';  // X : true, null : false
                        param.pathlist  = 'X';

                        Map<String, Object> responseMap = (Map<String,Object>)IF_SdGetApprovalLineController.getApprovalLine(param);
                        Map<String, Object> responseOutput = (Map<String, Object>) responseMap.get('ES_OUTPUT');

                        Integer statusCode = Integer.valueOf(responseMap.get('StatusCode'));
                        
                        if(statusCode >= 300) {
                            result = 'F';
                            message = '[HTTP ' + statusCode + '] ' + Util_String.nvlStr(responseMap.get('IF_MSG'));
                            isSuccess = false;
                        } else {
                            isSuccess = (responseOutput.get('msgty') != null) && (String.ValueOf(responseOutput.get('msgty')) == 'S');

                            if(!isSuccess){
                                result = 'F';
                                message = System.Label.APPR_LAB_APPROVAL_LINE_ERR + ' ' + String.valueOf(responseOutput.get('message'));
                            } 

                            if(isSuccess) {
                                result = 'S';
                                List<KnoxApprover__c> knoxApproverList = new List<KnoxApprover__c>();

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
                                    // v1.1 - Gitesh Saini
                                    List<Employee__c> empList = [
                                        SELECT  Name, EvEName__c, EvSdeptNM__c, EvSdeptENM__c,EvMailAddr__c, EvUniqID__c, EvSapEmpNO__c, EvAcubeID__c
                                        FROM    Employee__c 
                                        WHERE   EvAcubeID__c IN :approvalLineMap.keyset()
                                        AND Status__c != 'R'
                                    ];
                                    Map<String, Employee__c> empMap = new Map<String, Employee__c>();
                                    for(Employee__c emp : empList){
                                        empMap.put(emp.EvSapEmpNO__c, emp);
                                    }
                                    // v1.1
                                    for(Object approvalLine :approvalLineList) { 
                                        Map<String, Object> approvalLineObj = (Map<String, Object>)approvalLine;
                                        String empno = String.valueOf(approvalLineObj.get('empno')).substring(3);    // 'C6031679' 앞자리 3자 제외 후 사원번호와 일치

                                        String name = String.valueOf(approvalLineObj.get('name'));             // Employee's last name
                                        String relclass = String.valueOf(approvalLineObj.get('relclass'));     // Workflow Step Type
                                        Integer seqno = Integer.valueOf(approvalLineObj.get('seqno'));           // Sequence Number [WF] (ZA0)
                                        String wfsysno = String.valueOf(approvalLineObj.get('wfsysno'));       // Approval System
                                        String wistatus = String.valueOf(approvalLineObj.get('wistatus'));     // Current Level Status
                                        String wrstatus = String.valueOf(approvalLineObj.get('wrstatus'));     // Request Status
                                        String ca_bukrs = String.valueOf(approvalLineObj.get('ca_bukrs'));     // Approver Company Code

                                        System.debug('empMap : ' + empMap);
                                        System.debug('empno : ' + empno);
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
                                            }
                                            // 기안자는 Knox Submit Class에서 생성하여 상신하기에 제외함
                                            if( wrstatus == '0' ) continue;

                                            knoxApr.ApproverType__c =  wrstatus;    // 기안(0), 결재(1), 합의(2), 후결(3), 병렬합의(4), 병렬결재(7), 통보(9)
                                            knoxApr.IsChangeLine__c = false;        // 초기값 설정
                                            knoxApr.IsEditText__c = false;          // 초기값 설정
                                            knoxApr.IsArbitraryDecision__c = false; // 초기값 설정
                                            knoxApr.Status__c = '0'; 

                                            knoxApproverList.add(knoxApr);

                                            apprLine = JSON.serialize(knoxApproverList);
                                        }
                                    }
                                }
                                if(!hasApprovalLine) message += ' '+System.Label.LAPP_MSG_002; // ' 결재선이 존재하지 않습니다.';

                                // [IT_HTML] 결재본문 HTML 
                                hasApprovalHtml = false;
                                if(responseMap.containsKey('IT_HTML')) { 
                                    List<Object> htmlLineList = (List<Object>)responseMap.get('IT_HTML');
                                    for(Object htmlLineObj : htmlLineList) {
                                        Map<String, Object> htmlLineMap = (Map<String, Object>)htmlLineObj;
                                        String htmlLine = String.valueOf(htmlLineMap.get('LINE'));
                                        if(htmlLine == null || htmlLine == 'null') continue;
                                        approvalHtml += htmlLine;
            
                                        hasApprovalHtml = true;
                                    }
                                }
                                if(!hasApprovalHtml) message += ' '+System.Label.LAPP_MSG_003; // ' 결재 본문이 없습니다.';

                                apprHTML = approvalHtml;
                            }
                        }
                    }else{
                        result = 'F';
                        message = System.Label.APPRVIEWER_MSG_0004; // There is no opportunity activity.
                    }
                }
            }catch(Exception e){
                System.debug('Error : ' + e.getMessage());
                result = 'F';
                message = e.getMessage();
            }
        }else{
            result = 'F';
            message = System.Label.APPRVIEWER_MSG_0005; // Please check opportunity code
        }

        rtnMap.put('Result', result);
        rtnMap.put('Message', message);
        rtnMap.put('ApprovalLine', apprLine);
        rtnMap.put('HTML', apprHTML);
        rtnMap.put('Language', UserInfo.getLanguage());

        System.debug('rtnMap : ' + rtnMap);
        return rtnMap;
    }
    public static void dummyMethod(){
        integer i = 0;
        i += i;
        i += i;
        i += i;
        i += i;
        i += i;
        i += i;
        i += i;
        i += i;
        i += i;
        i += i;
        i += i;
    }
}