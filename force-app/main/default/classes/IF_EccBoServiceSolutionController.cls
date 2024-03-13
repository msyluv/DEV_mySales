/**
 * @description       : 
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-02-19
 * @last modified by  : ghkil@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                      Modification
 * 1.0   2020-11-20   ghkil@partner.samsung.com   Initial Version
 * 1.1   2020-12-07   ghkil@partner.samsung.com   EV_DSOL항목에 대한 Logic 처리
 * 1.2   2021-01-28   ghkil@partner.samsung.com   Service__c, Solution__c 임시저장 기능 관련 Service__c, Solution__c 조회 조건 추가
**/
@RestResource( UrlMapping='/IF099/*')
global class IF_EccBoServiceSolutionController {
             
    private static final String INTERFACE_ID = 'IF-099';
    private static final String APEX_CLASS   = 'IF_EccBoServiceSolutionController';
    private static final String METHOD_NAME  = 'getBoServiceSolution';

    private static final Boolean DEBUG_FLAG = true;

    public IF_EccBoServiceSolutionController() { }

    @HttpPost
    global static void getBoServiceSolution(){

        String guId = IF_Util.generateGuid();
        
        OutputHeader outHeader   = new OutputHeader();
        outHeader.DATA           = new List<OutputClass>();
        outHeader.TOTAL_COUNT    = 0;
        outHeader.EV_RESULT      = 'S';
        outHeader.EV_MESG        = '';
        
        String sendData;

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
               
        // 해당정보 조회
        if (DEBUG_FLAG) ifLog.addLog('Data 조회 시작');

        try {

            List<Solution__c> selectSolutionList = [  
                Select  Id
                        , Service__r.Id
                        , Service__r.Name                                   // 서비스명
                        , Service__r.Service__r.Code__c                     // 서비스코드
                        , Service__r.Opportunity__r.CompanyCode__c          // 회사코드
                        , Service__r.Opportunity__r.OpportunityCode__c      // BO코드(사업기회코드)
                        , Opportunity__r.Id                     
                        , Solution__r.Code__c                               // 솔루션코드
                        , Solution__r.Name                                  // 솔루션명
                        , Solution__r.SolutionType__c                       // 솔루션타입
                From    Solution__c
                Where   SendSAP__c = true
                And 	DeletionFlag__c = false
                And 	Service__r.SendSAP__c = true
                And 	Service__r.DeletionFlag__c = false
                And     Service__r.Opportunity__r.CompanyCode__c       = :inputDataList[0].IV_BUKRS
                And     Service__r.Opportunity__r.OpportunityCode__c   = :inputDataList[0].IV_ZZORDER_ID
            ];

            ifLog.addLog('조회 데이터 : ' + selectSolutionList.size());

            //  데이터 매핑
            OutputClass outClass = new OutputClass();
            outClass.ET_TAB = new List<OUTPUT_ET_TABO>();
            if (selectSolutionList.size() > 0) {

                String solutionType = 'N';            
                for (Solution__c selectSolution : selectSolutionList) {
                    OUTPUT_ET_TABO outEtTabo    = new OUTPUT_ET_TABO();

                    if (selectSolution.Solution__r.SolutionType__c == '30' || selectSolution.Solution__r.SolutionType__c == '60') {
                        if (inputDataList[0].IV_BUKRS == selectSolution.Service__r.Opportunity__r.CompanyCode__c) {
                            solutionType = 'Y';
                        }
                    } else if (selectSolution.Solution__r.SolutionType__c == '40' || selectSolution.Solution__r.SolutionType__c == '50') {
                        solutionType = 'Y';
                    }

                    outEtTabo.BUKRS          = selectSolution.Service__r.Opportunity__r.CompanyCode__c;         // 회사코드
                    outEtTabo.ORDER_ID       = selectSolution.Service__r.Opportunity__r.OpportunityCode__c;     // BO코드
                    outEtTabo.SERVICE_CODE   = selectSolution.Service__r.Service__r.Code__c;                    // 서비스코드
                    outEtTabo.SOLUTION_CODE  = selectSolution.Solution__r.Code__c;                              // 솔루션코드
                    // outEtTabo.MAJOR_CODE     = '';                                                           // Transaction Description / [SD] 향후, BRIM에서 SD가 I/F받으면 됨
                    // outEtTabo.MINOR_CODE     = '';                                                           // (Primary) Sales Dept / [SD] 향후, BRIM에서 SD가 I/F받으면 됨
                    outEtTabo.SERVICE        = selectSolution.Service__r.Name;                                  // 서비스명
                    outEtTabo.SOLUTION       = selectSolution.Solution__r.Name;                                 // 솔루션명
                    // outEtTabo.MAJOR          = '';                                                           // (Primary) Delivery Dept / [SD] 향후, BRIM에서 SD가 I/F받으면 됨
                    // outEtTabo.MINOR          = '';                                                           // 사업유형 / [SD] 향후, BRIM에서 SD가 I/F받으면 됨      

                    if (DEBUG_FLAG) ifLog.addLog('solutionType : ' + solutionType);
                    if (DEBUG_FLAG) ifLog.addLog('outEtTabo : ' + outEtTabo);

                    outClass.ET_TAB.add(outEttabo);
                }
                outClass.EV_DSOL = solutionType;
            }
            outHeader.DATA.add(outClass);

            // 성공 로그 데이터
            outHeader.TOTAL_COUNT    = selectSolutionList.size(); // BUSINESS 데이터 기준
            outHeader.EV_RESULT      = IF_Util.RESULT_STATUS_SUCCESS;
            outHeader.EV_MESG        = IF_Util.RESULT_MESSAGE_SUCCESS;
            sendData                 = JSON.serialize(outHeader);

            ifLog.addLog('Response : ' + sendData);            
            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, inputJsonData, sendData);  

        }catch( Exception e){            

            // 에러 로그 데이터
            outHeader.TOTAL_COUNT    = 0;
            outHeader.EV_RESULT      = IF_Util.RESULT_STATUS_ERROR;
            outHeader.EV_MESG        = IF_Util.RESULT_MESSAGE_ERROR + ' | ' + e.getMessage();
            sendData                 = JSON.serialize(outHeader);

            ifLog.addLog('Response : ' + sendData);            
            ifLog.addLog('Webservice call exception : ' + e.getMessage());
            errorMsgList.add('Webservice call exception : ' + e.getMessage());

            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, inputJsonData, sendData, e);               
        }finally{

            ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 종료' + ' ####################');

            ifLog.createLog(interfaceLog);
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
        public String IV_BUKRS;         // Company Code
        @AuraEnabled
        public String IV_ZZORDER_ID;    // 사업코드(프로젝트)
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
        public List<OutputClass> DATA;
    }

    public class OutputClass{

        @AuraEnabled
        public String EV_DSOL;

        @AuraEnabled
        public List<OUTPUT_ET_TABO> ET_TAB; // 데이터 포멧
    }

    public class OUTPUT_ET_TABO{

        @AuraEnabled
        public String BUKRS;            // 회사코드
        @AuraEnabled
        public String ORDER_ID;         // BO코드
        @AuraEnabled
        public String SERVICE_CODE;     // 서비스코드
        @AuraEnabled
        public String SOLUTION_CODE;    // 솔루션코드
        @AuraEnabled
        public String MAJOR_CODE;       // Transaction Description / [SD] 향후, BRIM에서 SD가 I/F받으면 됨
        @AuraEnabled
        public String MINOR_CODE;       // (Primary) Sales Dept / [SD] 향후, BRIM에서 SD가 I/F받으면 됨
        @AuraEnabled
        public String SERVICE;          // 서비스명
        @AuraEnabled
        public String SOLUTION;         // 솔루션명
        @AuraEnabled
        public String MAJOR;            // (Primary) Delivery Dept / [SD] 향후, BRIM에서 SD가 I/F받으면 됨
        @AuraEnabled
        public String MINOR;            // 사업유형 / [SD] 향후, BRIM에서 SD가 I/F받으면 됨
    }    
}