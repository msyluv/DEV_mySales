/**
 * @description       : 
 * @author            : kilhwan.an@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-12-13
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                           Modification
 * 1.0   2020-11-17   kilhwan.an@partner.samsung.com   Initial Version
 * 1.1   2020-12-30   ghkil@partner.samsung.com        동일 정보 요청 시 처리되도록 보완
 * 1.2   2021-01-22   ghkil@partner.samsung.com        Employee__c의 upsert Key 변경 (EvUniqID__c -> ExternalId__c)
 * 1.3   2021-01-29   kilhwan@partner.samsung.com      Employee__c의 upsert Key 변경 (EvUniqID__c -> ExternalId__c)
 * 1.4   2021-02-22   raeganja@partner.samsung.com     Dept Manager 업데이트를 위한 로직 추가
 * 1.5   2021-04-01   kilhwan.an@partner.samsung.com   부서장 정보 로직 삭제
 * 1.6   2021-04-07   raeganja@partner.samsung.com     ExternalId__c 변경(inClass.EV_COMPANY + '_' + inClass.EV_UNIQ_ID + '_' + inClass.EV_ACUBE_ID)
**/
@RestResource( UrlMapping='/IF118/*')
global class IF_EccEmployRegController {

    private static final String INTERFACE_ID = 'IF-118';
    private static final String APEX_CLASS   = 'IF_EccEmployRegController';
    private static final String METHOD_NAME  = 'regEmployeeInfo';

    private static final Boolean DEBUG_FLAG = true;

    @HttpPost
    global static void regEmployeeInfo(){
   
        LogSwitch__c logSwitch = LogSwitch__c.getValues('IF-118_FILTER');

        String guId = IF_Util.generateGuid();

        OutputHeader outHeader   = new OutputHeader();
        outHeader.DATA           = new List<OutputClass>();
        OutputClass outClass     = new OutputClass();
        outHeader.TOTAL_COUNT    = 0;
        outHeader.TYPE           = 'S';
        outHeader.MESSAGE        = '';
        
        String sendData;

        IF_Log ifLog;
        IF_Log.InterfaceLog interfaceLog;
        
        IF_Log ifFilterLog;		//필터 로그
        IF_Log.InterfaceLog interfaceFilterLog;		//필터 로그
        
        List<String> errorMsgList = new List<String>();        

		ifLog = new IF_Log();
        ifFilterLog = new IF_Log();	//필터 로그
        
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

        // 입력 받은 데이터
        String inputJsonData = reqBody.toString();
        system.debug('inputJsonData : ' + inputJsonData);
        InputHeader       inputHeader  =  ( InputHeader) JSON.deserialize( inputJsonData, InputHeader.class);
        List<InputClass> inputDataList = inputHeader.DATA;
        if (inputDataList == null || inputDataList.size() == 0) {
            rep.responseBody = Blob.valueOf(JSON.serialize(outHeader));
            return;
        }
        if (DEBUG_FLAG) ifLog.addLog('데이터 수신');
               
        // 해당정보 반영
        Savepoint sp = Database.setSavepoint();
        ifLog.addLog('Data 반영 시작');
        
        // 필터 로그
        String strFilterLog = '';

        try {
            //Dept Manager 업데이트를 위한 추가 변수
            Map<String, Object> costCenterListMap   = new Map<String, Object>();            
            // Set<Object>        costCenterList  = new Set<Object>();
            

            //  데이터 매핑
            List<Employee__c> empList = new List<Employee__c>();
            // Map<String, InputClass> insertInputClassMap = new Map<String, InputClass>();  // 요청 데이터 중복 체크용
            Integer upsertCount = 0;
            for (InputClass inClass : inputDataList) {

                Employee__c emp = new Employee__c();

                // // 중복 건 있으면 먼저 반영 후 먼저 반영한 List, Map 초기화 후 다시 진행
                // if (insertInputClassMap.get(inClass.EV_UNIQ_ID) != null) {
                    
                //     upsert empList EvUniqID__c;
                //     upsertCount = upsertCount + empList.size();

                //     empList.clear();
                //     insertInputClassMap.clear();
                // }
                // insertInputClassMap.put(inClass.EV_UNIQ_ID, inClass);       // 중복 체크용 Map에 적재

                if( ( inClass.EV_SAP_EMPNO + '').isNumeric()){
                    inClass.EV_SAP_EMPNO = Decimal.valueOf( inClass.EV_SAP_EMPNO) + '';
                }

                emp.EvSapEmpNO__c       = inClass.EV_SAP_EMPNO;   // PERNR                
                emp.EvAcubeID__c        = inClass.EV_ACUBE_ID;                              // ACUBE ID(COMPANY+EMPNO)
                emp.EvEmpNO__c          = inClass.EV_EMPNO;                                 // 마이싱글사번
                emp.EvUniqID__c         = inClass.EV_UNIQ_ID;                               // EP ID (싱글 UNIQ_ID)                
                emp.Name      		    = inClass.EV_HNAME;                                 // 한글이름
                emp.EvHName__c          = inClass.EV_HNAME;                                 // 한글이름
                emp.EvEName__c          = inClass.EV_ENAME;                                 // 영어이름
                emp.EvCompany__c        = inClass.EV_COMPANY;                               // 회사
                emp.EvSapBukrs__c       = inClass.EV_SAP_BUKRS;                             // Company code
                emp.EvCompNM__c         = inClass.EV_COMPNM;                                // 회사명
                emp.EvJikGiub__c        = inClass.EV_JIKGUB;                                // 직급
                emp.EvJikGiubNM__c      = inClass.EV_JIKGUBNM;                              // 직급/호칭
                emp.EvTitleJikChakNM__c = inClass.EV_TITLE_JIKCHAK_NM;                      // 직책명
                emp.EvDept__c           = inClass.EV_DEPT;                                  // 부서코드
                emp.EvSdeptNM__c        = inClass.EV_SDEPTNM;                               // 부서이름
                emp.EvJikGubNM__c       = inClass.EV_JIKGUBNM;                              // 직급/호칭
                emp.EvKostl__c          = inClass.EV_KOSTL;                                 // Cost Center
                emp.EvCellTel__c        = inClass.EV_CELL_TEL;                              // 핸드폰번호
                emp.EvCompTel__c        = inClass.EV_COMP_TEL;                              // 회사번호
                emp.EvSapUsrID__c       = inClass.EV_SAP_USRID;                             // USRID
                emp.EvMailAddr__c       = inClass.EV_MAIL_ADDR;                             // 이메일정보
                emp.EvStatus__c         = inClass.EV_STATUS;                                // 상태
                emp.EvMailReLanguage__c = inClass.EV_MAIL_RELANGUAGE;                       // 언어
                emp.EvCompENM__c        = inClass.EV_COMPENM;                               // 회사 영어이름
                emp.EvSdeptENM__c       = inClass.EV_SDEPTENM;                              // SDEPTENM
                emp.EvTitleJikchakEN__c = inClass.EV_TITLE_JIKCHAK_EN;                      // TITLE_JIKCHAK_ENAME
                emp.EvGsber__c          = inClass.EV_GSBER;                                 // Business Area
                emp.EvFlag__c           = inClass.EV_FLAG;                                  // FLAG
                emp.EvJikGubNM__c       = inClass.EvJikGubNM;                               // 직함 없음
                // emp.ExternalId__c       = inClass.EV_COMPANY + '_' + inClass.EV_UNIQ_ID;    // ExternalId (2021-01-22 추가)
                // COMPANY, UNIQ_ID, EMPNO
                // emp.ExternalId__c       = inClass.EV_COMPANY + '_' + inClass.EV_UNIQ_ID + '_' + inClass.EV_EMPNO;    // ExternalId (2021-01-22 추가)
                //emp.ExternalId__c       = inClass.EV_SAP_BUKRS + '_' + inClass.EV_UNIQ_ID + '_' + emp.EvSapEmpNO__c;    // ExternalId (2021-01-22 추가)
                emp.ExternalId__c       = inClass.EV_COMPANY + '_' + inClass.EV_UNIQ_ID + '_' + inClass.EV_ACUBE_ID;    // ExternalId (2021-04-07 변경)
                emp.Status__c = null; // 2021-12-13 추가 / IF-118으로 임직원 정보 수신 시 Status를 기본 null로 입력

                empList.add(emp);

                //Dept Manager 업데이트를 위한 추가 로직
                // if(String.isNotBlank(inClass.EV_KOSTL)){
                //     Map<String, Object> costCenterMap   = new Map<String, Object>();

                //     costCenterMap.put('KOSTL', inClass.EV_KOSTL);

                //     costCenterList.add(costCenterMap);
                // }
                if(logSwitch.IsActive__c && inClass.EV_HNAME == logSwitch.FilterValue__c){
                    strFilterLog += inClass+'\n';
                }                
            }
            
            System.debug('### IF_EccEmployRegController :: regEmployeeInfo :: strFilterLog = ' + strFilterLog);

            // upsert empList EvUniqID__c; // EPID 유니크
            upsert empList ExternalId__c;
            upsertCount = upsertCount + empList.size();

            // //Dept Manager 업데이트를 위한 추가 로직
            // costCenterListMap.put('IT_KOSTL_INFO', new List<Object> ( costCenterList));
            // String jsonData = JSON.serialize( costCenterListMap);
            
            // //부서장정보 업데이트 로직
            // IF_CoCostCenterHierarchyController.updateDeptManager(jsonData);

            // 성공 로그 데이터
            outHeader.TOTAL_COUNT    = upsertCount;
            outHeader.TYPE           = IF_Util.RESULT_STATUS_SUCCESS;
            outHeader.MESSAGE        = IF_Util.RESULT_MESSAGE_SUCCESS;
            sendData                 = JSON.serialize(outHeader);

            ifLog.addLog('Response : ' + sendData);            
            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, inputJsonData, sendData); 
            
            interfaceFilterLog = new IF_Log.InterfaceLog(logSwitch.Name, guId, APEX_CLASS, METHOD_NAME, strFilterLog, sendData); 

        }catch( Exception e){
            Database.rollback(sp);

            // 에러 로그 데이터
            outHeader.TOTAL_COUNT    = 0;
            outHeader.TYPE           = IF_Util.RESULT_STATUS_ERROR;
            outHeader.MESSAGE        = IF_Util.RESULT_MESSAGE_ERROR + ' |' + e.getMessage();
            sendData                 = JSON.serialize(outHeader);

            ifLog.addLog('Response : ' + sendData);            
            ifLog.addLog('Webservice call exception : ' + e.getMessage());
            errorMsgList.add('Webservice call exception : ' + e.getMessage());

            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, inputJsonData, sendData, e);               
        }finally{

            ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 종료' + ' ####################');

            ifLog.createLog(interfaceLog);
            
            if(strFilterLog != ''){
                ifFilterLog.createLog(interfaceFilterLog);	//필터 로그
            }
            
        }

        rep.responseBody = Blob.valueOf(JSON.serialize(outHeader));
     
    }

    public class InputHeader{

        @AuraEnabled
        public Integer TOTAL_COUNT;
        @AuraEnabled
        public Integer PAGE_COUNT;
        @AuraEnabled
        public Integer PAGE_NUM;        
        @AuraEnabled
        public List<InputClass> DATA;
    }

    //  넘어온값
    public class InputClass{

        @AuraEnabled
        public String EV_SAP_EMPNO;            // PERNR
        @AuraEnabled
        public String EV_ACUBE_ID;              // ACUBE ID(COMPANY+EMPNO)
        @AuraEnabled
        public String EV_EMPNO;                 // 마이싱글사번
        @AuraEnabled
        public String EV_UNIQ_ID;               // EP ID (싱글 UNIQ_ID)
        @AuraEnabled
        public String EV_HNAME;                 // 한글이름
        @AuraEnabled
        public String EV_ENAME;                 // 영어이름
        @AuraEnabled
        public String EV_COMPANY;               // 회사
        @AuraEnabled
        public String EV_SAP_BUKRS;             // Company Code
        @AuraEnabled
        public String EV_COMPNM;                // 회사명
        @AuraEnabled
        public String EV_JIKGUB;                // 직급
        @AuraEnabled
        public String EV_JIKGUBNM;              // 직급/호칭
        @AuraEnabled
        public String EV_TITLE_JIKCHAK_NM;      // 직책명
        @AuraEnabled
        public String EV_DEPT;                  // 부서코드
        @AuraEnabled
        public String EV_SDEPTNM;               // 부서이름
        @AuraEnabled
        public String EV_KOSTL;                 // Cost Center
        @AuraEnabled
        public String EV_CELL_TEL;              // 핸드폰번호
        @AuraEnabled
        public String EV_COMP_TEL;              // 회사번호
        @AuraEnabled
        public String EV_SAP_USRID;             // USRID
        @AuraEnabled
        public String EV_MAIL_ADDR;             // 이메일정보
        @AuraEnabled
        public String EV_STATUS;                // 상태
        @AuraEnabled
        public String EV_MAIL_RELANGUAGE;       // 언어
        @AuraEnabled
        public String EV_COMPENM;               // 회사 영어이름
        @AuraEnabled
        public String EV_SDEPTENM;              // SDEPTENM
        @AuraEnabled
        public String EV_TITLE_JIKCHAK_EN;      // TITLE_JIKCHAK_ENAME
        @AuraEnabled
        public String EV_GSBER;                 // Business Area
        @AuraEnabled
        public String EV_FLAG;                  // FLAG
        @AuraEnabled
        public String EvJikGubNM;               //	직함없음;
    }

    // 전달 값: JitterBit
    public class OutputHeader{

        @AuraEnabled
        public Integer TOTAL_COUNT;     // 전체 데이터 건수
        @AuraEnabled
        public String TYPE;             // 처리 결과
        @AuraEnabled
        public String MESSAGE;          // 처리 메세지
        @AuraEnabled
        public List<OutputClass> DATA;  // 데이터 포멧
    }

    public class OutputClass{

    }
}