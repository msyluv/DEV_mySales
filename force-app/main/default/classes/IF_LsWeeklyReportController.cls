/**
 * @description       : 
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-06-08
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                            Modification
 * 1.0   2021-01-27   ghkil@partner.samsung.com         Initial Version (Batch_LsWeeklyReportController와 같은 기능을 하는 Callout)
 * 1.1   2021-02-05   kilhwan.an@partner.samsung.com    신규/수정 : M / 삭제 : D
 * 1.2   2021-02-16   ghkil@partner.samsung.com         UPDATE_EMP_NAME, RESP_EMP_NAME, REG_EMP_NAME의 이름을 Employee__c의 Name으로 변경
 * 1.3   2021-02-16   ghkil@partner.samsung.com         전달한 WeeklyReport 전송여부, 전송일자 업데이트 처리 (IsDeleted가 false인 경우만)
 * 1.4   2021-02-17   kilhwan.anm@partner.samsung.com   삭제 버튼으로 삭제 처리 한 경우
**/
global class IF_LsWeeklyReportController {

    private static final String INTERFACE_ID = 'IF-127';
    private static final String APEX_CLASS   = 'IF_LsWeeklyReportController';
    private static final String METHOD_NAME  = 'calloutWeeklyInfo';

    private static final Boolean DEBUG_FLAG = IF_Util.DEBUG_FLAG;

    private static String guId = IF_Util.generateGuid();

    private static IF_Log ifLog;
    private static IF_Log.InterfaceLog interfaceLog;
    private static List<String> errorMsgList = new List<String>();
        
    public IF_LsWeeklyReportController() {  }

    public static String QUERY_STRING = 'Select  Id, ' +                                    // Activity ID
                                        '        Opportunity__r.OpportunityCode__c, ' +     // 사업기회코드
                                        '        Opportunity__r.CompanyCode__c, ' +         // BO 회사코드 SAP 코드
                                        '        Contents__c,  ' +                          // Activity 내용
                                        '        ReportingDate__c, ' +                      // Reporting Date
                                        '        Flag__c, ' +                               // Flag (I, U, D)
                                        '        CreatedDate, ' +                           // 최초등록일
                                        '        CreatedById, ' +                           // 최초등록자 ID
                                        '        CreatedBy.EmployeeNumber, ' +              // 최초등록자 사번
                                        '        CreatedBy.Name, ' +                        // 최초등록자명
                                        '        LastModifiedDate, ' +                      // 최종수정일            
                                        '        LastModifiedById, ' +                      // 최종수정자 ID
                                        '        LastModifiedBy.EmployeeNumber, ' +         // 최종수정자 사번
                                        '        IsDeleted, ' +                             // 삭제 여부
                                        '        LastModifiedBy.Name ' +                    // 최종수정자명
                                        'From   WeeklyReport__c ';

    @Future(callout=true)
    public static void calloutWeeklyInfo(List<String> selectIdList){      

        Map<String, Object> result = new Map<String, Object>();

        String reqMsg = '';
        String resMsg = '';

        ifLog = new IF_Log();
        ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 시작' + ' ####################');

        String queryString = QUERY_STRING + 'Where    Id IN :selectIdList ALL ROWS ';

        List<WeeklyReport__c> scopeList = Database.query(queryString);

        if (DEBUG_FLAG) ifLog.addLog('처리 대상 : ' + scopeList.size());

        // *************************************
        // 상세정보 정보 가져오기
        // *************************************
        OutputHeader outHeader = getDetailInfo(scopeList);

        // *************************************
        // Interface 통신
        // *************************************
        try {            
            IF_Callout ifCallout = new IF_Callout(INTERFACE_ID);

            // Client에서 전달받은 데이터를 callout 규격에 맞게 변환하여 requestbody 만들기
            // OutputHeader outHeader = (OutputHeader) JSON.deserialize(inputJsonData, OutputHeader.class);
            if (DEBUG_FLAG) ifLog.addLog('Client에서 전달받은 데이터를 callout 규격에 맞게 변환하여 requestbody 생성');

            result = ifCallout.httpCallout(JSON.serialize(outHeader), '');
            // ifLog.addLog('result : '  + result);

            reqMsg = String.valueOf(result.get('Request'));
            resMsg = String.valueOf(result.get('Response'));

            if (DEBUG_FLAG) ifLog.addLog('StatusCode : '  + String.valueOf(result.get('StatusCode')));
            if (DEBUG_FLAG) ifLog.addLog('HttpResponse : '+ String.valueOf(result.get('HttpResponse')));
            // if (DEBUG_FLAG) ifLog.addLog('Log : '         + String.valueOf(result.get('Log')));
            // if (DEBUG_FLAG) ifLog.addLog('Message : '     + String.valueOf(result.get('Message')));

            Integer resStatusCode = (Integer)result.get('StatusCode');

            if (resStatusCode != null && (resStatusCode == 200 || resStatusCode == 202)) {
                HttpResponse hRes = (HttpResponse)result.get('HttpResponse');

                // 전달한 WeeklyReport 전송여부, 전송일자 업데이트 처리
                List<WeeklyReport__c> updateweeklyReportList = new List<WeeklyReport__c>();
                for (WeeklyReport__c weeklyReportData : scopeList) {

                    if (weeklyReportData.IsDeleted == false) {
                        weeklyReportData.Transmitdate__c = system.now();        // 전송일자
                        weeklyReportData.IsTransmit__c = true;                  // 전송여부
    
                        updateweeklyReportList.add(weeklyReportData);
                    }
                }

                update updateweeklyReportList;

                if (DEBUG_FLAG) ifLog.addLog('Response Body : ' + hRes.getBody());

                interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqMsg, resMsg);
            } else {
                ifLog.addLog('Communication Error : ' + String.valueOf(result.get('Message')) + ' / StatusCode : ' + String.valueOf(resStatusCode));
                errorMsgList.add('Communication Error : ' + String.valueOf(result.get('Message')) + ' / StatusCode : ' + String.valueOf(resStatusCode));

                interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqMsg, resMsg, errorMsgList);
            }            
        } catch(Exception e){
            ifLog.addLog('Exception : ' + String.valueOf(e.getMessage()));
            errorMsgList.add('Exception : ' + String.valueOf(e.getMessage()));

            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqMsg, resMsg, e);
        } finally {
            ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 종료' + ' ####################');

            ifLog.createLog(interfaceLog);
        }
    }

    public static OutputHeader getDetailInfo(List<WeeklyReport__c> scopeList) {
        
        // *************************************
        // 상세정보 정보 가져오기
        // *************************************
        ReceiveHeader recHeader;

        String reqMsg = '';
        String resMsg = '';
            
        // 데이터 처리
        // List<Map<String, Object>> outputList = new List<Map<String, Object>>();
        OutputHeader outHeader = new OutputHeader();
        outHeader.Weekly_Report= new List<OutputClass>();

        // Employee__c에서 Name 가져오기
        Set<String> evEmpNoSet = new Set<String>();
        for (WeeklyReport__c weeklyReportData : scopeList) {
            evEmpNoSet.add(weeklyReportData.CreatedBy.EmployeeNumber);
            evEmpNoSet.add(weeklyReportData.LastModifiedBy.EmployeeNumber);
        }

        List<Employee__c> employeeList = [
            Select  Id
                    , Name
                    , EvEmpNo__c
            From    Employee__c
            Where   EvEmpNo__c IN :evEmpNoSet
        ];
        Map<String, Employee__c> employeeMap = new Map<String, Employee__c>();
        for (Employee__c employeeData : employeeList) {
            employeeMap.put(employeeData.EvEmpNO__c, employeeData);
        }

        List<OutputClass> outClassList = new List<OutputClass>();

        // WeeklyReport 정보
        for (WeeklyReport__c weeklyReportData : scopeList) {
            OutputClass outClass = new OutputClass();

            String createdByName = null;
            if (employeeMap.get(weeklyReportData.CreatedBy.EmployeeNumber) != null) {
                createdByName = employeeMap.get(weeklyReportData.CreatedBy.EmployeeNumber).Name;
            }
            String lastModifiedByName = null;
            if (employeeMap.get(weeklyReportData.LastModifiedBy.EmployeeNumber) != null) {
                lastModifiedByName = employeeMap.get(weeklyReportData.LastModifiedBy.EmployeeNumber).Name;
            }

            outClass.BO_ID              = weeklyReportData.Opportunity__r.OpportunityCode__c;                   // 사업기회코드 (Opportunity, OpportunityCode__c)
            outClass.SAP_COMPANY        = weeklyReportData.Opportunity__r.CompanyCode__c;                       // BO 회사코드 SAP코드 (Opportunity, CompanyCode__c)
            outClass.ACT_TYPE           = 'ZAC3';                                                               // Activity Type (하드코딩, "ZAC3")
            outClass.OBJECT_ID          = weeklyReportData.Id;                                                  // Activity ID (WeeklyReport__c, Id)
            outClass.CONTENTS           = weeklyReportData.Contents__c;                                         // Activity 내용 (WeeklyReport__c, Contents__c)
            outClass.ACT_STATUS         = 'E0010';                                                              // Activity Status Code (하드코딩, "E0010")
            outClass.START_DATE         = Util_String.convertDateString(weeklyReportData.ReportingDate__c);     // Activity 시작일 (WeeklyReport__c, ReportingDate__c)
            outClass.END_DATE           = Util_String.convertDateString(weeklyReportData.ReportingDate__c);     // Activity 종료일 (WeeklyReport__c, ReportingDate__c)
            outClass.RESP_EMP_NO        = weeklyReportData.LastModifiedBy.EmployeeNumber;                       // 담당자 사번 (WeeklyReport__c, LastModifiedBy.EmployeeNumber)
            // outClass.RESP_EMP_NAME      = weeklyReportData.LastModifiedBy.Name;                                 // 담당자 명 (WeeklyReport__c, LastModifiedBy.Name)
            outClass.RESP_EMP_NAME      = lastModifiedByName;                                                   // 담당자 명 (WeeklyReport__c, LastModifiedBy.Name, Employee__c의 Name으로 변경)
            outClass.REG_DATE           = Util_String.convertDateTimeString(weeklyReportData.CreatedDate, 'Asia/Seoul');      // 등록일 (WeeklyReport__c, CreatedDate)
            outClass.REG_EMP_NO         = weeklyReportData.CreatedBy.EmployeeNumber;                            // 등록자 사번 (WeeklyReport__c, CreatedBy.EmployeeNumber)
            // outClass.REG_EMP_NAME       = weeklyReportData.CreatedBy.Name;                                      // 등록자 명 (WeeklyReport__c, CreatedBy.Name)
            outClass.REG_EMP_NAME       = createdByName;                                                        // 등록자 명 (WeeklyReport__c, CreatedBy.Name, Employee__c의 Name으로 변경)
            outClass.UPDATE_DATE        = Util_String.convertDateTimeString(weeklyReportData.LastModifiedDate, 'Asia/Seoul'); // 최종 수정일 (WeeklyReport__c, LastModifedDate)
            outClass.UPDATE_EMP_NO      = weeklyReportData.LastModifiedBy.EmployeeNumber;                       // 최종 수정자 사번 (WeeklyReport__c, LastModifiedBy.EmployeeNumber)
            // outClass.UPDATE_EMP_NAME    = weeklyReportData.LastModifiedBy.Name;                                 // 최종 수정자 명 (WeeklyReport__c, LastModifiedBy.Name)
            outClass.UPDATE_EMP_NAME    = lastModifiedByName;                                                   // 최종 수정자 명 (WeeklyReport__c, LastModifiedBy.Name, Employee__c의 Name으로 변경)
            // outClass.FLAG               = weeklyReportData.Flag__c;                                             // 등록/수정/삭제 (WeeklyReport__c, Flag__c)
            // 신규/수정 : M, 삭제 : D

            System.debug( 'weeklyReportData.IsDeleted::::' + weeklyReportData.IsDeleted);
            if( weeklyReportData.IsDeleted == true){ // 삭제 버튼으로 삭제 처리 한 경우
                outClass.FLAG   =  'D';
            }else if( weeklyReportData.Flag__c == 'I' || weeklyReportData.Flag__c == 'U'){
                outClass.FLAG   =  'M';
            }else {
                outClass.FLAG   =  weeklyReportData.Flag__c;
            }
            // weeklyReportData.Flag__c;    // 등록/수정/삭제 (WeeklyReport__c, Flag__c)

            outClassList.add(outClass);
        }
        outHeader.Weekly_Report = outClassList;

        return outHeader;
    }

    // 전달 값: JitterBit
    public class OutputHeader{

        @AuraEnabled
        public List<OutputClass> Weekly_Report;
    }

    public class OutputClass{

        @AuraEnabled
        public String BO_ID;            // 사업기회코드 (Opportunity, OpportunityCode__c)
        @AuraEnabled
        public String SAP_COMPANY;      // BO 회사코드 SAP코드 (Opportunity, CompanyCode__c)
        @AuraEnabled
        public String ACT_TYPE;         // Activity Type (하드코딩, "ZAC3")
        @AuraEnabled
        public String OBJECT_ID;        // Activity ID (WeeklyReport__c, Id)
        @AuraEnabled
        public String CONTENTS;         // Activity 내용 (WeeklyReport__c, Contents__c)
        @AuraEnabled
        public String ACT_STATUS;       // Activity Status Code (하드코딩, "E0010")
        @AuraEnabled
        public String START_DATE;       // Activity 시작일 (WeeklyReport__c, ReportingDate__c)
        @AuraEnabled
        public String END_DATE;         // Activity 종료일 (WeeklyReport__c, ReportingDate__c)
        @AuraEnabled
        public String RESP_EMP_NO;      // 담당자 사번 (WeeklyReport__c, LastModifiedBy.EmployeeNumber)
        @AuraEnabled
        public String RESP_EMP_NAME;    // 담당자 명 (WeeklyReport__c, LastModifiedBy.Name)
        @AuraEnabled
        public String REG_DATE;         // 등록일 (WeeklyReport__c, CreatedDate)
        @AuraEnabled
        public String REG_EMP_NO;       // 등록자 사번 (WeeklyReport__c, CreatedBy.EmployeeNumber)
        @AuraEnabled
        public String REG_EMP_NAME;     // 등록자 명 (WeeklyReport__c, CreatedBy.Name)
        @AuraEnabled
        public String UPDATE_DATE;      // 최종 수정일 (WeeklyReport__c, LastModifedDate)
        @AuraEnabled
        public String UPDATE_EMP_NO;    // 최종 수정자 사번 (WeeklyReport__c, LastModifiedBy.EmployeeNumber)
        @AuraEnabled
        public String UPDATE_EMP_NAME;  // 최종 수정자 명 (WeeklyReport__c, LastModifiedBy.Name)
        @AuraEnabled
        public String FLAG;             // 등록/수정/삭제 (WeeklyReport__c, Flag__c)
    }

    // 받은 값 : Jitterbit 입력정보 (Request에 대한 Response)
    public class ReceiveHeader{

        @AuraEnabled
        public String EV_RESULT; // Message type: S Success, E Error, W Warning, I Info, A Abort
        @AuraEnabled
        public String EV_MESG;        
    }
    public class ReceiveClass{        
    }
}