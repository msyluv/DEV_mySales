/**
 * @description       : 
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-05-21
 * @last modified by  : ghkil@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                      Modification
 * 1.0   2020-11-23   ghkil@partner.samsung.com   Initial Version
**/
@RestResource( UrlMapping='/IF007/*')
global class IF_EccProjectStatusController {

    private static final String INTERFACE_ID = 'IF-007';
    private static final String APEX_CLASS   = 'IF_EccProjectStatusController';
    private static final String METHOD_NAME  = 'updateProjectSatus';

    private static final Boolean DEBUG_FLAG = true;

    public IF_EccProjectStatusController() { }

    @HttpPost
    global static void updateProjectSatus(){

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
        Savepoint sp = Database.setSavepoint();
        if (DEBUG_FLAG) ifLog.addLog('해당정보 조회 시작');

        try {
            Set<String> projectCodeSet = new Set<String>();
            Set<String> comCodePrjCodeSet = new Set<String>();    // comCodePrjCodeSet : Opportunity__r.CompanyCode__c + '|' + Project Code
            Map<String, String> inputDataMap = new Map<String,String>();
            for( InputClass inClass :inputDataList){
                projectCodeSet.add(inClass.PSPID);
                comCodePrjCodeSet.add(inClass.BUKRS + '|' + inClass.PSPID);

                inputDataMap.put(inClass.BUKRS + inClass.PSPID, inClass.DELETE_FLAG);
            }

            // Project 정보, WBS 정보
            List<Project__c> prjList = [  

                SELECT  Id
                       ,Name
                       ,Opportunity__r.CompanyCode__c
                       ,Opportunity__r.Id
                       ,ProjectCode__c
                       ,DeletionFlag__c
                       ,fm_CompanyProjectCode__c
                       ,(
                          SELECT Id
                                ,DeletionFlag__c
                                ,Solution__c
                          FROM   WBS__r
                        )
                FROM    Project__c 
                WHERE   ProjectCode__c           IN :projectCodeSet
                AND     fm_CompanyProjectCode__c IN :comCodePrjCodeSet
            ];

            //  데이터 매핑
            List<Project__c> upPrjList = new List<Project__c>();
            List<WBS__c>     upWbList  = new List<WBS__c>();
            Map<Id, Boolean> solIdMap  = new Map<Id, Boolean>();

            for( Project__c prj : prjList) {

                String delFlag = 'N';
                if ( inputDataMap.get( prj.Opportunity__r.CompanyCode__c + prj.ProjectCode__c) == 'X') {
                    
                    prj.DeletionFlag__c = true;       // Delete
                    delFlag = 'Y';
                } else {

                    prj.DeletionFlag__c = false;      // UnDelete
                    delFlag = 'N';
                }
                upPrjList.add( new Project__c( Id = prj.Id, DeletionFlag__c = prj.DeletionFlag__c));


                // WBS 삭제 여부 체크 
                if( prj.WBS__r  != null){
                    
                    for( WBS__c wb : prj.WBS__r){

                        upWbList.add( new WBS__c( Id = wb.Id, DeletionFlag__c = delFlag));
                        if( wb.Solution__c != null) solIdMap.put( wb.Solution__c, prj.DeletionFlag__c);
                    }
                }
            }
            // 업데이트 처리 : Project/WBS
            update upPrjList;
            update upWbList;


            /// Solution, Service 정보
            List<Solution__c> solList = [

                SELECT Id
                      ,Service__c
                      ,Solution__c
                      ,Changed__c
                      ,DeletionFlag__c 
                FROM   Solution__c
                WHERE  Id   IN :solIdMap.KeySet() 
            ];

            List<Solution__c>   upSolList = new List<Solution__c>();
            Map<Id, Service__c> upSvMap   = new Map<Id, Service__c>();
            for( Solution__c sol : solList){

                Boolean delFlag = solIdMap.get( sol.Id);
                upSolList.add( new Solution__c( Id = sol.Id,  DeletionFlag__c = delFlag, sDeletionFlag__c = delFlag, Changed__c = !delFlag));
                upSvMap.put  ( sol.Service__c, new Service__c( Id = sol.Service__c, DeletionFlag__c = delFlag, sDeletionFlag__c = delFlag, Changed__c = !delFlag));
            }
            // Service/Solution
            update upSolList;

            // 삭제가 안된 내역이 있는지 확인
            List<Solution__c> sol2List = [

                SELECT Id
                      ,Service__c
                      ,Solution__c
                      ,Changed__c
                      ,DeletionFlag__c 
                FROM   Solution__c
                WHERE  Service__c      IN :upSvMap.KeySet()
                AND    DeletionFlag__c = false
            ];
            // 삭제가 안된 내역이 있다면 제외처리
            for( Solution__c sol2 : sol2List){

                upSvMap.remove( sol2.Service__c);
            }
            update upSvMap.values();



            // if( solList.size() == 0)  update upSvMap.values();

            if (DEBUG_FLAG) ifLog.addLog('Data 반영 완료');


            // 성공 로그 데이터
            outHeader.TOTAL_COUNT    = prjList.size(); // BUSINESS 데이터 기준
            outHeader.EV_RESULT      = IF_Util.RESULT_STATUS_SUCCESS;
            outHeader.EV_MESG        = IF_Util.RESULT_MESSAGE_SUCCESS;
            sendData                 = JSON.serialize(outHeader);

            ifLog.addLog('Response : ' + sendData);            
            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, inputJsonData, sendData);  

        }catch( Exception e){            
            Database.rollback(sp);

            // 에러 로그 데이터
            outHeader.TOTAL_COUNT    = 0;
            outHeader.EV_RESULT      = IF_Util.RESULT_STATUS_ERROR;
            outHeader.EV_MESG        = IF_Util.RESULT_MESSAGE_ERROR + ' | ' + e.getMessage();
            sendData                 = JSON.serialize(outHeader);

            ifLog.addLog('Response : ' + sendData);            
            ifLog.addLog('Exception : ' + e.getMessage());
            errorMsgList.add('Exception : ' + e.getMessage());

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
        public String BUKRS;            // Company code
        @AuraEnabled
        public String PSPID;            // Project code
        @AuraEnabled
        public String DELETE_FLAG;      // delete flag
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