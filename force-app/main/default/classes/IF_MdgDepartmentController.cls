/**
 * @description       : [SFDC] Org Data(CCTR) 정보 수신
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-01-28
 * @last modified by  : ghkil@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                            Modification
 * 1.0   2020-11-06   ghkil@partner.samsung.com         Initial Version
 * 1.1   2020-12-02   kilhwan.an@partner.samsung.com    하기 사항 반영
 *                                                          - 날짜 type을 문자열 변환 : 효력시작일, 종료일, 폐쇠일자를 문자열로 변환
 *                                                          - ExternalId 값 변경 String.valueOf(datei)=> "inputData.DATABI"
 *                                                          - 필드 null값 매핑 처리
 * 1.2   2020-12-30   ghkil@partner.samsung.com         동일 정보 요청 시 처리되도록 보완
**/
@RestResource( urlMapping= '/IF112/*')
global class IF_MdgDepartmentController {

    private static final String INTERFACE_ID = 'IF-112';
    private static final String APEX_CLASS   = 'IF_MdgDepartmentController';
    private static final String METHOD_NAME  = 'regDepartment';

    private static final Boolean DEBUG_FLAG = true;

    public IF_MdgDepartmentController() { }

    @HttpPost
    global static void regDepartment(){


        // 목업
        String guId = IF_Util.generateGuid();
        // String returnVal = '{  "TOTAL_COUNT":1,"EV_RESULT":"S","EV_MESG" : "Success","DATA":[] }';
        // IF_Util.makePayLoad( INTERFACE_ID, APEX_CLASS, METHOD_NAME, returnVal);
        // if( 1==1) return;

        OutputHeader outHeader   = new OutputHeader();
        outHeader.DATA           = new List<OutputClass>();
        OutputClass outClass     = new OutputClass();
        outHeader.TOTAL_COUNT    = 0;
        outHeader.EV_RESULT      = 'S';
        outHeader.EV_MESG        = '';

        outHeader.DATA.add(outClass);

        IF_Log ifLog;
        IF_Log.InterfaceLog interfaceLog;
        List<String> errorMsgList = new List<String>();        

		ifLog = new IF_Log();
        ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 시작' + ' ####################');

        // RequestBody 데이터 확인
        RestRequest req = RestContext.request;
        Blob    reqBody = req.requestBody;

        RestResponse rep = RestContext.response;
        rep.addHeader('Content-Type', 'application/json');

        if( reqBody == null ) {
            rep.responseBody = Blob.valueOf(JSON.serialize(outHeader));
            return;
        }
        if (DEBUG_FLAG) ifLog.addLog('클라이언트 데이터 수신');

        // 데이터 파싱
        String inputJsonData = reqBody.toString();//.escapeJava();
        ifLog.addLog('HttpRequest : ' + inputJsonData);        
        InputHeader inputHeader = (InputHeader) JSON.deserialize(inputJsonData, InputHeader.class);        
        List<InputClass> inputDataList = inputHeader.DATA;
        if( inputDataList == null || inputDataList.size() == 0 ) {
            rep.responseBody = Blob.valueOf(JSON.serialize(outHeader));
            return;
        } 
        if (DEBUG_FLAG) ifLog.addLog('데이터 파싱');

        // 1) 해당정보 반영
        Savepoint sp = Database.setSavepoint();

        try {                                                        

            List<Department__c> regDepartmentList = new List<Department__c>();
            Map<String, InputClass> insertInputClassMap = new Map<String, InputClass>();  // 요청 데이터 중복 체크용
            Integer upsertCount = 0;
            for (InputClass inputData : inputDataList) {
                Department__c regDepartment = new Department__c();

                String departmentExternalId = inputData.KOSTL + inputData.DATBI + inputData.KOKRS;
                
                // 중복 건 있으면 먼저 반영 후 먼저 반영한 List, Map 초기화 후 다시 진행
                if (insertInputClassMap.get(departmentExternalId) != null) {
                    
                    upsert regDepartmentList ExternalId__c;
                    upsertCount = upsertCount + regDepartmentList.size();

                    regDepartmentList.clear();
                    insertInputClassMap.clear();
                }
                insertInputClassMap.put(departmentExternalId, inputData);       // 중복 체크용 Map에 적재

                // 효력종료일 Date Max 체크하여 4000-12-31로 취환 (convertStringDate 함수 내에서 처리)
                Date databi = Util_String.convertStringDate( inputData.DATBI);

                regDepartment.ExternalId__c = departmentExternalId;         // ExternalID 입력 (Kostl__c 코스트 센터 + DatabI__c 효력 종료일 + Kokrs__c 관리회계 영역, ExternalId내 효력종료일은 99991231로 입력) 
                regDepartment.Kostl__c      = inputData.KOSTL;              // Kostl__c 코스트 센터
                regDepartment.DatabI__c     = databi;                       // DatabI__c 효력 종료일 
                regDepartment.Kokrs__c      = inputData.KOKRS;              // Kokrs__c 관리회계 영역
                regDepartment.Abtel__c      = inputData.ABTEI;              // Abtel__c 부서 
                regDepartment.Bkzer__c      = inputData.BKZER;              // Bkzer__c 실제수익 전기에 대한 잠금지시자
                regDepartment.Bkzkp__c      = inputData.BKZKP;              // Bkzkp__c 실제 1차 전기에 대한 잠금지시자
                regDepartment.Bkzks__c      = inputData.BKZKS;              // Bkzks__c 실제 2차원가요소에 대한 잠금지시자
                regDepartment.Bkzob__c      = inputData.BKZOB;              // Bkzob__c 약정사항 갱신에 대한 잠금지시자
                regDepartment.Datab__c      = (inputData.DATAB != null && inputData.DATAB != '00000000') ? Util_String.convertStringDate( inputData.DATAB) : null; // 효력시작일
                regDepartment.Khinr__c      = inputData.KHINR;              // Khinr__c 표준계층구조영역
                regDepartment.FuncArea__c   = inputData.FUNC_AREA;          // FuncArea__c 기능 영역
                regDepartment.Gsber__c      = inputData.GSBER;              // Gsber__c 사업 영역
                regDepartment.Kosar__c      = inputData.KOSAR;              // Kosar__c 코스트센터 범주
                regDepartment.Mgefl__c      = inputData.MGEFL;              // Mgefl__c 소비수량을 기록하기 위한 지시자
                regDepartment.Pkzer__c      = inputData.PKZER;              // Pkzer__c 수익계획에 대한 잠금지시자
                regDepartment.Pkzkp__c      = inputData.PKZKP;              // Pkzkp__c 계획 1차원가요소에 대한 잠금지시자
                regDepartment.Pkzks__c      = inputData.PKZKS;              // Pkzks__c 계획 2차원가요소에 대한 잠금지시자
                regDepartment.Prctr__c      = inputData.PRCTR;              // Prctr__c 손익 센터
                regDepartment.Txjcd__c      = inputData.TXJCD;              // Txjcd__c 조세 관할 구역
                regDepartment.Verak__c      = inputData.VERAK;              // Verak__c 책임자 
                regDepartment.VerakUser__c  = inputData.VERAK_USER;         // VerakUser__c 책임자 
                regDepartment.Waers__c      = inputData.WAERS;              // Waers__c 통화 키 
                regDepartment.ZZBranch__c   = inputData.ZZBRANCH;           // ZZBranch__c 사업장
                regDepartment.ZZDelete__c   = inputData.ZZDELETE;           // ZZDelete__c Delete Flag
                regDepartment.ZZPrflg__c    = inputData.ZZPRFLG;            // ZZPrflg__c	Update Flag
                regDepartment.ZZSecCode__c  = inputData.ZZSECCODE;          // ZZSecCode__c 섹션 코드

                if( '00000000' == inputData.ZZEXPIRED || Util_String.nvlStr( inputData.ZZEXPIRED) == '') {
                    regDepartment.ZZExpired__c  = null ;
                } else {
                    regDepartment.ZZExpired__c  = Util_String.convertStringDate( inputData.ZZEXPIRED);  // 코스트센터 폐쇄일자
                }
                // regDepartment.ZZExpired__c = String.valueOf(inputData.ZZEXPIRED) != '' ? inputData.ZZEXPIRED : null; // ZZExpired__c 코스트센터 폐쇄일자
                
                regDepartment.ZZCheck__c = inputData.ZZCHECK;               // ZZCheck__c 손익여부체크지시자
                regDepartment.Bukrs__c   = inputData.BUKRS;                 // Bukrs__c Company Code
                regDepartment.ZZDummy__c = inputData.ZZDUMMY;               // ZZDummy__c	Dummy Flag

                for (CCTR_TEXT cctrTextData : inputData.CCTR_TEXT_DATA) {
                    // SPRAS Language Key이 'K'인 경우와 'E'인 경우 나눠 처리
                    if (cctrTextData.SPRAS == 'KO') {
                        regDepartment.KKText__c = cctrTextData.KKTEXT;      // KKText__c 일반이름(K)  
                        regDepartment.KLText__c = cctrTextData.KLTEXT;      // KLText__C Long 이름(K) 

                        if( Util_String.nvlStr( regDepartment.KLText__c) != '' && regDepartment.Name  == null) {
                            regDepartment.Name  = regDepartment.KLText__c;
                        }
                    } else if (cctrTextData.SPRAS == 'EN') {
                        regDepartment.EKText__c = cctrTextData.EKTEXT;      // EKText__c 일반이름(E)   
                        regDepartment.ELText__c = cctrTextData.ELTEXT;      // ELText__C Long 이름(E)  
                        
                        if( Util_String.nvlStr( regDepartment.ELText__c) != '' && regDepartment.Name  == null ) {
                            regDepartment.Name  = regDepartment.ELText__c;
                        }
                    }
                }

                regDepartmentList.add(regDepartment);
            }
        
            upsert regDepartmentList ExternalId__c;
            upsertCount = upsertCount + regDepartmentList.size();

            // 2) 성공 로그 데이터
            outHeader.TOTAL_COUNT    = upsertCount;
            outHeader.EV_RESULT      = IF_Util.RESULT_STATUS_SUCCESS;
            outHeader.EV_MESG        = IF_Util.RESULT_MESSAGE_SUCCESS;
            String sendData          = JSON.serialize(outHeader);

            ifLog.addLog('Response : ' + sendData);

            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, inputJsonData, sendData);
            if (DEBUG_FLAG) ifLog.addLog('데이터 반영');

        } catch (Exception e) {
            Database.rollback(sp);

            // 에러 로그 데이터
            outHeader.TOTAL_COUNT    = 0;
            outHeader.EV_RESULT      = IF_Util.RESULT_STATUS_ERROR;
            outHeader.EV_MESG        = IF_Util.RESULT_MESSAGE_ERROR + ' |' + e.getMessage();
            String sendData          = JSON.serialize(outHeader);

            ifLog.addLog('Response : ' + sendData);            
            ifLog.addLog('Exception : ' + e.getMessage());
            errorMsgList.add('Exception : ' + e.getMessage());

            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, inputJsonData, sendData, e);    
        }

        ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 종료' + ' ####################');

        ifLog.createLog(interfaceLog);        

        rep.responseBody = Blob.valueOf(JSON.serialize(outHeader));
    
    }

    // 받은 값 : 입력정보
    public class InputHeader{

        @AuraEnabled
        public Integer TOTAL_COUNT; // 토탈카운트
        @AuraEnabled
        public Integer PAGE_COUNT;  // 페이지당 전송 건수
        @AuraEnabled
        public Integer PAGE_NUM;    // 현재페이지
        @AuraEnabled
        public List<InputClass> DATA;
    }
    public class InputClass{

        @AuraEnabled
        public String KOSTL;        // Kostl__c	코스트 센터
        @AuraEnabled
        public String DATBI;        // DatabI__c 효력 종료일 
        @AuraEnabled
        public String KOKRS;        // Kokrs__c 관리회계 영역
        @AuraEnabled
        public String ABTEI;        // Abtel__c 부서 
        @AuraEnabled
        public String BKZER;        // Bkzer__c 실제수익 전기에 대한 잠금지시자
        @AuraEnabled
        public String BKZKP;        // Bkzkp__c 실제 1차 전기에 대한 잠금지시자
        @AuraEnabled
        public String BKZKS;        // Bkzks__c 실제 2차원가요소에 대한 잠금지시자
        @AuraEnabled
        public String BKZOB;        // Bkzob__c 약정사항 갱신에 대한 잠금지시자
        @AuraEnabled
        public String DATAB;        // Datab__c 효력 시작일 
        @AuraEnabled
        public String KHINR;        // Khinr__c 표준계층구조영역
        @AuraEnabled
        public String FUNC_AREA;    // FuncArea__c 기능 영역
        @AuraEnabled
        public String GSBER;        // Gsber__c 사업 영역
        @AuraEnabled
        public String KOSAR;        // Kosar__c 코스트센터 범주
        @AuraEnabled
        public String MGEFL;        // Mgefl__c 소비수량을 기록하기 위한 지시자
        @AuraEnabled
        public String PKZER;        //Pkzer__c 수익계획에 대한 잠금지시자
        @AuraEnabled        
        public String PKZKP;        // Pkzkp__c 계획 1차원가요소에 대한 잠금지시자
        @AuraEnabled        
        public String PKZKS;        // Pkzks__c 계획 2차원가요소에 대한 잠금지시자
        @AuraEnabled        
        public String PRCTR;        // Prctr__c 손익 센터
        @AuraEnabled        
        public String TXJCD;        // Txjcd__c 조세 관할 구역
        @AuraEnabled        
        public String VERAK;        // Verak__c 책임자 
        @AuraEnabled
        public String VERAK_USER;   // VerakUser__c 책임자 
        @AuraEnabled
        public String WAERS;        // Waers__c 통화 키 
        @AuraEnabled
        public String ZZBRANCH;     // ZZBranch__c 사업장
        @AuraEnabled
        public String ZZDELETE;     // ZZDelete__c Delete Flag
        @AuraEnabled
        public String ZZPRFLG;      // ZZPrflg__c Update Flag
        @AuraEnabled
        public String ZZSECCODE;    // ZZSecCode__c 섹션 코드
        @AuraEnabled
        public String ZZEXPIRED;    // ZZExpired__c 코스트센터 폐쇄일자
        @AuraEnabled
        public String ZZCHECK;      // ZZCheck__c	손익여부체크지시자
        @AuraEnabled
        public String BUKRS;        // Bukrs__c Company Code
        @AuraEnabled
        public String ZZDUMMY;      // ZZDummy__c	Dummy Flag
        @AuraEnabled
        public List<CCTR_TEXT> CCTR_TEXT_DATA;
    }
    public class CCTR_TEXT{

        @AuraEnabled
        public String SPRAS;        // SPRAS Language Key (CRM Deparment__c에는 없는 항목임)
        @AuraEnabled
        public String KKTEXT;       // KKText__c 일반이름(K)  
        @AuraEnabled
        public String KLTEXT;       // KLText__C Long 이름(K)     
        @AuraEnabled
        public String EKTEXT;       // EKText__c 일반이름(E)   
        @AuraEnabled
        public String ELTEXT;       // ELText__C Long 이름(E)         
    }

    // 전달 값: JitterBit
    public class OutputHeader{

        @AuraEnabled
        public Integer TOTAL_COUNT;     // 전체 데이터 건수
        @AuraEnabled
        public String EV_RESULT;        // 처리 결과
        @AuraEnabled
        public String EV_MESG;          // 처리 메세지
        @AuraEnabled
        public List<OutputClass> DATA;  // 데이터 포멧
    }
    public class OutputClass{

    }    

}