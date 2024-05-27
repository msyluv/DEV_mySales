/**
 * @description       : 
 * @author            : chae_ho.yang@samsung.com
 * @group             : 
 * @last modified on  : 05-08-2024
 * @last modified by  : chae_ho.yang@samsung.com
 * 
 * v1.1 2024-05-08   chae_ho.yang@samsung.com  MYSALES-523 Miracom getGubun modification
**/
public class IF_040_Automation {
    
    private final static String KEY_MSG = 'MSG';
    private final static String KEY_RESULT = 'RESULT';

    //D : DELETE, C:CHANGE(UPDATE), I:CREATE(INSERT)
    private final static String KEY_CREATE = 'I';
    private final static String KEY_CHANGE = 'C';
    private final static String KEY_DELETE = 'D';

    private final static String CHANGE_APPROVAL = 'CHANGE_APPROVAL';
    private final static String REVIEW_COMPLETED = 'REVIEW_COMPLETED';

    //TA 여부 판단에 사용
    public final static Integer INIT_SERVICE = 0;      //TA 대상 / 비대상 모두 선택 가능
    public final static Integer NORMAL_SERVICE = 1;    //TA 비대상 서비스
    public final static Integer TECH_SERVICE = 2;      //TA 대상 서비스
    public static final String OPPTYACT_STATUS_COMPLETED = 'Completed';
    public static final String OPPTYACT_STATUS_INPROGRESS = 'In Progress';

    
    private static final String INTERFACE_ID = 'IF-040';
    private static final String APEX_CLASS   = 'IF_040_Automation';
    private static final String METHOD_NAME  = 'Project_WBS';
    
    private static final Boolean DEBUG_FLAG = IF_Util.DEBUG_FLAG;
    
    private static String guId = IF_Util.generateGuid();
    
    private static IF_Log ifLog;
    private static IF_Log.InterfaceLog interfaceLog;
    private static List<String> errorMsgList = new List<String>();
    
    public IF_040_Automation() { }
    
     public static Map<String,Object> Project_WBS(String opprtyId){ 
        Boolean initialRegi = false;
        Map<String,Object> resultMap = new Map<String,Object>();
        Map<String,Object> result = new Map<String,Object>();
        String resultMsg = 'S';
        Opportunity opprty = new Opportunity();
        try {
            //select Insert, Update, Delete Service
            List<Service__c> lnewSvc = new List<Service__c>();
            List<Service__c> luptSvc = new List<Service__c>();

            //select Insert, Update, Delete Solution
            List<Solution__c> lnewSol = new List<Solution__c>();
            List<Solution__c> luptSol = new List<Solution__c>();

            /* Opprtunity 정보 조회 */
             opprty = [SELECT Id, Name
                                    , OpportunityCode__c
                                    , CompanyCode__c
                                    , cOriginAcc__r.AccountNumber
                                    , cPrimarySalesDepartment__r.CostCenter__c
                                    , cPrimarySalesDepartment__r.CostCenterName__c
                                    , SalesDepartment__r.CostCenterName__c
                                    , SalesDepartment__r.CostCenter__c
                                    , cRevenueStartDate__c
                                    , cRevenueEndDate__c
                                    , CloseDate
                                    , ProposalPM_User__c
                                    , ProposalPM_User__r.Name
                                    , ProposalPM__r.EvSapEmpNO__c
                                    , ProposalPM__r.EvEmpNO__c
                                    , OwnerId
                                    , Owner.EmployeeNumber
                                    , Owner.FederationIdentifier
                                    , Amount
                                    , StageName
                                    , Description
                                    , cOriginAcc__r.Name
                                    , GroupInternal__c
                                    , KoreaDomestic__c
                                    , Account.Name
                                    , Owner.Name
                                    , ProposalPM__r.Name
                                    , VRBMethod__c
                                    , CurrencyIsoCode 
                                    , BusinessLevel__c 
                                    , FinalBusinessLevel__c
                                    , AccountId
                                    , BiddingMethod__c 
                                    , cPrimarySalesDepartment__r.DeptManagerEmail__c    //매출부서 부서장 이메일
                                    , SalesDepartment__r.DeptManagerEmail__c            //수주부서 부서장 이메일
                                    , CollaborationInOut__c                             //본사 IN, 법인 OUT
                                    , Collaboration__c                                  //Collaboration flag
                                    , CollaborationBOId__c                              //Collabo BO Id
                                    , CollaborationBOId__r.cPrimarySalesDepartment__c   //본사 매출부서
                                    , CollaborationBOId__r.SalesDepartment__c           //본사 수주부서
                                    , CollaborationBOId__r.Owner.Id                     //본사 사업기회 Owner Id
                                    , CollaborationBOId__r.Owner.FederationIdentifier   //본사 사업기회 Owner EPID
                                    , CollaborationBOId__r.CompanyCode__c               //본사 사업기회 Company Code
                                    , ReuseReason__c                                    //재활용 결정사유
                                    , BusinessType__c
                                    , IsOriginal__c
                                    , BusinessType2__c
                                    FROM Opportunity WHERE Id = : opprtyId];
                                    
            // opprty 필수값 체크
            Map<String,String> checkMap = checkRequiredVal(opprty);
            boolean isReqiredVal = (checkMap.get(KEY_MSG) == 'S') ? true : false;
            System.debug('Ani isReqiredVal '+isReqiredVal);
            if(isReqiredVal){
                /* 신규 service& Solution조회(SAP에 전송하지않은 Solution 조회)*/
                lnewSvc = [SELECT Id
                                , Name
                                , itemNumber__c
                                , DeletionFlag__c
                                , sService__r.Code__c                               //서비스 코드
                                , sService__r.Name                                  //서비스 명
                                , Service__r.Code__c                                //서비스 코드
                                , Service__r.Name                                   //서비스 명
                                , DeliveryDepartment__c                             //매출부서
                                , DeliveryDepartment__r.CostCenter__c               //매출부서 CostCenter
                                , DeliveryDepartment__r.CostCenterName__c           //매출부서 CostCenter
                                , sDeliveryDepartment__c                            //매출부서
                                , sDeliveryDepartment__r.CostCenter__c              //매출부서 CostCenter
                                , sDeliveryDepartment__r.CostCenterName__c          //매출부서 CostCenter
                                , sSalesDepartment__c                               //수주부서
                                , sSalesDepartment__r.CostCenter__c                 //수주부서 CostCenter
                                , sSalesDepartment__r.CostCenterName__c             //수주부서 CostCenter
                                , SalesDepartment__c                                //수주부서
                                , SalesDepartment__r.CostCenter__c                  //수주부서 CostCenter
                                , SalesDepartment__r.CostCenterName__c              //수주부서 CostCenter
                                , WBSClass__c
                                , SendSAP__c
                                , WBSCode__c
                                , ServiceBackup__c
                                , ServiceNmBackup__c
                                , DeliveryDepartmentBackup__c
                                , SalesDepartmentBackup__c
                                , DeliveryDepartmentNmBackup__c
                                , SalesDepartmentNmBackup__c
                                , sDeletionFlag__c
                                , Changed__c
                                , TechAttribute__c                          //2021.08.25 TA 여부 추가
                            FROM Service__c 
                            WHERE Opportunity__c =: opprtyId 
                            AND SendSAP__c = false
                            AND sDeletionFlag__c = false
                            AND DeletionFlag__c = false
                            AND Changed__c = true
                            ORDER BY ItemNumber__c];
                
                System.debug('Ani lnewSvc '+lnewSvc);
    
                lnewSol = [SELECT Id, Name
                                , Service__c                                    //ServiceId
                                , Service__r.ServiceBackup__c
                                , Service__r.Service__r.Name                    //Service 명
                                , Service__r.Service__r.Code__c                 //서비스 코드
                                , Service__r.DeliveryDepartment__r.CostCenter__c //매출부서
                                , Service__r.DeliveryDepartment__r.CostCenterName__c //매출부서
                                , Service__r.SalesDepartment__r.CostCenter__c   //수주부서
                                , Service__r.SalesDepartment__r.CostCenterName__c   //수주부서
                                , Service__r.Service__c                            //Service
                                , Service__r.sService__r.Name                    //Service 명
                                , Service__r.sDeliveryDepartment__r.CostCenter__c //매출부서
                                , Service__r.sDeliveryDepartment__r.CostCenterName__c //매출부서
                                , Service__r.sSalesDepartment__r.CostCenter__c   //수주부서
                                , Service__r.sSalesDepartment__r.CostCenterName__c   //수주부서
                                , Service__r.sService__r.Code__c                 //서비스 코드
                                , Service__r.sDeletionFlag__c
                                , Service__r.DeletionFlag__c
                                , Service__r.SendSAP__c
                                , Service__r.Changed__c
                                , Service__r.WBSCode__c
                                , Solution__c                                   //Solution ID
                                , Solution__r.Name                              //Solution 명
                                , Solution__r.Code__c                           //Solution 코드
                                , toLabel(Solution__r.SolutionType__c)                   //GUBUN(solutionType)
                                , sSolution__c                                   //Solution ID
                                , sSolution__r.Name                              //Solution 명
                                , sSolution__r.Code__c                           //Solution 코드
                                , toLabel(sSolution__r.SolutionType__c)                   //GUBUN(solutionType)
                                , BizAttribute__r.Code__c                       //사업 속성 코드
                                , BizAttribute__c                               //사업 속성
                                , BizAttribute__r.Name
                                , sBizAttribute__r.Code__c                       //사업 속성 코드
                                , sBizAttribute__c                               //사업 속성
                                , sBizAttribute__r.Name
                                , SolutionType__c
                                , sSolutionType__c
                                , ItemNumber__c                                 //ItemNumber
                                , BusinessType__c                               //사업유형
                                , sBusinessType__c                               //사업유형
                                , WBSClass__c                                   //WBSClass
                                , sWBSClass__c                                   //WBSClass
                                , WBSCode__c                                    //WBSCode
                                , ProjectCode__c                                //Project Code
                                , SolutionBackup__c
                                , SolutionNmBackup__c
                                , BizAttributeBackup__c
                                , BizAttributeNmBackup__c
                                , Service__r.ServiceNmBackup__c
                                , Service__r.DeliveryDepartmentNmBackup__c
                                , Service__r.SalesDepartmentNmBackup__c
                                , SendSAP__c
                                , sDeletionFlag__c 
                                , DeletionFlag__c  
                                , Changed__c
                                , sPSType__c
                                , PSType__c
                                , SvcWBSCode__c
                                , Service__r.TechAttribute__c
                            FROM Solution__c 
                            WHERE Service__r.Opportunity__c =: opprtyId 
                            AND SendSAP__c = false
                            AND DeletionFlag__c = false     // SAP에서 삭제된 데이터들은 제외 
                            AND Changed__c = true
                            ORDER BY Service__r.ItemNumber__c];
                System.debug('Ani lnewSol '+lnewSol);
                
                //신규 솔루션 중 sPSType__c, sBusinessType__c, sWBSClass__c 누락 데이터 보완(필수값)
                List<SvcSolBizAttr__c> svcSolBizList = [SELECT Service__c
                                                             , Solution__c
                                                             , BizAttribute__c
                                                             , PSType__c
                                                             , BusinessType__c
                                                             , WBSClass__c
                                                          FROM SvcSolBizAttr__c
                                                         WHERE IsDeleted = false
                                                           AND Use__c = true     
                                                        ];
                
                for(Solution__c sol : lnewSol){
                    if (sol.sPSType__c == null || sol.sBusinessType__c == null || sol.sWBSClass__c == null ){
                        for(SvcSolBizAttr__c svc : svcSolBizList){
                            if(svc.Service__c == sol.Service__r.sService__r.Name 
                                && svc.Solution__c == sol.sSolution__c 
                                && svc.BizAttribute__c == sol.sBizAttribute__c){
                                if(sol.sPSType__c == null){
                                    sol.sPSType__c = svc.PSType__c;
                                }
    
                                if(sol.sBusinessType__c == null){
                                    sol.sBusinessType__c = svc.BusinessType__c;
                                }
                                
                                if(sol.sWBSClass__c == null){
                                    sol.sWBSClass__c = svc.WBSClass__c;
                                }
                            }
                            
                        }
                    }

                }

                luptSvc = [SELECT Id
                                , Name
                                , itemNumber__c
                                , DeletionFlag__c
                                , sService__r.Code__c                               //서비스 코드
                                , sService__r.Name                                  //서비스 명
                                , Service__r.Code__c                                //서비스 코드
                                , Service__r.Name                                   //서비스 명
                                , DeliveryDepartment__c                             //매출부서
                                , DeliveryDepartment__r.CostCenter__c               //매출부서 CostCenter
                                , DeliveryDepartment__r.CostCenterName__c           //매출부서 CostCenter
                                , sDeliveryDepartment__c                            //매출부서
                                , sDeliveryDepartment__r.CostCenter__c              //매출부서 CostCenter
                                , sDeliveryDepartment__r.CostCenterName__c          //매출부서 CostCenter
                                , sSalesDepartment__c                               //수주부서
                                , sSalesDepartment__r.CostCenter__c                 //수주부서 CostCenter
                                , sSalesDepartment__r.CostCenterName__c             //수주부서 CostCenter
                                , SalesDepartment__c                                //수주부서
                                , SalesDepartment__r.CostCenter__c                  //수주부서 CostCenter
                                , SalesDepartment__r.CostCenterName__c              //수주부서 CostCenter
                                , WBSClass__c
                                , SendSAP__c
                                , WBSCode__c
                                , ServiceBackup__c
                                , ServiceNmBackup__c
                                , DeliveryDepartmentBackup__c
                                , SalesDepartmentBackup__c
                                , DeliveryDepartmentNmBackup__c
                                , SalesDepartmentNmBackup__c
                                , sDeletionFlag__c
                                , Changed__c
                                , TechAttribute__c                          //2021.08.25 TA 여부 추가
                            FROM Service__c 
                            WHERE Opportunity__c =: opprtyId 
                            AND SendSAP__c = true
                            AND Changed__c = true
                            AND DeletionFlag__c = false     // SAP에서 삭제된 데이터들은 제외 
                            ORDER BY ItemNumber__c, sDeletionFlag__c DESC];
                
                System.debug('Ani luptSvc '+luptSvc);
                
                luptSol = [SELECT Id, Name
                                , Service__c                                        //ServiceId
                                , Service__r.Service__r.Name                        //Service 명
                                , Service__r.Service__r.Code__c                     //서비스 코드
                                , Service__r.ServiceBackup__c                       //서비스 코드
                                , Service__r.DeliveryDepartment__r.CostCenter__c    //매출부서
                                , Service__r.SalesDepartment__r.CostCenter__c       //수주부서
                                , Service__r.SalesDepartment__r.CostCenterName__c   //수주부서
                                , Service__r.Service__c                             //Service 명
                                , Service__r.sService__r.Name                       //Service 명
                                , Service__r.sDeliveryDepartment__r.CostCenter__c   //매출부서
                                , Service__r.sDeliveryDepartment__r.CostCenterName__c //매출부서명
                                , Service__r.sSalesDepartment__r.CostCenter__c      //수주부서
                                , Service__r.sSalesDepartment__r.CostCenterName__c  //수주부서
                                , Service__r.sService__r.Code__c                    //서비스 코드
                                , Service__r.sDeletionFlag__c
                                , Service__r.DeletionFlag__c
                                , Service__r.SendSAP__c
                                , Service__r.Changed__c
                                , Service__r.WBSCode__c
                                , Solution__c                                   //Solution ID
                                , Solution__r.Name                              //Solution 명
                                , Solution__r.Code__c                           //Solution 코드
                                , toLabel(Solution__r.SolutionType__c)          //GUBUN(solutionType)
                                , sSolution__c                                  //Solution ID
                                , sSolution__r.Name                             //Solution 명
                                , sSolution__r.Code__c                          //Solution 코드
                                , toLabel(sSolution__r.SolutionType__c)         //GUBUN(solutionType)
                                , BizAttribute__r.Code__c                       //사업 속성 코드
                                , BizAttribute__c                               //사업 속성
                                , BizAttribute__r.Name
                                , sBizAttribute__r.Code__c                      //사업 속성 코드
                                , sBizAttribute__c                              //사업 속성
                                , sBizAttribute__r.Name
                                , SolutionType__c
                                , sSolutionType__c
                                , ItemNumber__c                                 //ItemNumber
                                , BusinessType__c                               //사업유형
                                , sBusinessType__c                              //사업유형
                                , WBSClass__c                                   //WBSClass
                                , sWBSClass__c                                  //WBSClass
                                , WBSCode__c                                    //WBSCode
                                , ProjectCode__c                                //Project Code
                                , SolutionBackup__c
                                , SolutionNmBackup__c
                                , BizAttributeBackup__c
                                , BizAttributeNmBackup__c
                                , Service__r.ServiceNmBackup__c
                                , Service__r.DeliveryDepartmentNmBackup__c
                                , Service__r.SalesDepartmentNmBackup__c
                                , SendSAP__c
                                , sDeletionFlag__c 
                                , DeletionFlag__c  
                                , Changed__c
                                , sPSType__c
                                , PSType__c
                                , SvcWBSCode__c
                                , Service__r.TechAttribute__c
                            FROM Solution__c 
                            WHERE Service__r.Opportunity__c =: opprtyId 
                            AND SendSAP__c = true
                            AND (Changed__c = true OR Service__r.Changed__c = true)
                            AND DeletionFlag__c = false     // SAP에서 삭제된 데이터들은 제외 
                            ORDER BY Service__r.ItemNumber__c, sDeletionFlag__c];
                
                System.debug('Ani luptSol '+luptSol);

                Integer svcSolCnt = lnewSol.size() + lnewSvc.size() + luptSvc.size() + luptSol.size();
                System.debug('Ani svcSolCnt '+svcSolCnt);
                
                Object objectLog = null;
                if(svcSolCnt > 0){
                    List<Project__c> lpjt = [SELECT Id, Name, DeletionFlag__c, ProjectType__c FROM Project__c WHERE Opportunity__c = : opprtyId ];

                    initialRegi = true;
                    if(lpjt.size() > 0){
                        for(Project__c pjt: lpjt){
                            if(!pjt.DeletionFlag__c){       //삭제된게 없음
                                if(pjt.ProjectType__c != 'Business Plan'){      //Business Plan 포함 기타 다른 PJT가 있는 경우
                                    initialRegi = false;
                                    break;
                                }
                            }
                        }
                    }
        
                    if(initialRegi){    /* IF-040 Project Create */
                        Map<String,Object> pjtCreateResult = new Map<String,Object>();
                        IF_PsCreatePjtNoController.InputClass input = render_IF_040(opprty, lnewSol);
                        pjtCreateResult = IF_PsCreatePjtNoController.createPjtNo(input);
                        
                        Integer statusCode = Util_String.nvlInt( pjtCreateResult.get( 'StatusCode'));
                        if( statusCode >= 300) {
                            //인터페티스 로그 생성
                            if(pjtCreateResult != null) createInterfaceLog(pjtCreateResult.get('INTERFACE_LOG'), opprty.Id);
                            resultMsg = '[' + statusCode+ ']' + Util_String.nvlStr( pjtCreateResult.get( 'IF_MSG')); // 알림 메세지 값
                        }else{
                            Map<String,String> createResultMap = saveProject(opprty, lnewSvc, lnewSol , pjtCreateResult, 'IF-040');
                            result.put('CREATE_PROJECT', createResultMap);
                            resultMsg = createResultMap.get(KEY_RESULT);
                            
                            system.debug('### OpportunityServiceSolutionMainController :: onConfirmToSAP :: resultMsg = ' + resultMsg);

                            /* 2021.05.17 추가 activity 상태값 업데이트 */
                            if(resultMsg != 'E'){ 
                                resultMap.put('Company Code',opprty.CompanyCode__c);
                                //upsertOpportunityActivity(opprty.Id, opprty.CompanyCode__c, 'Completed');
                                }
                        }
                    }
                }else{  //If(SvcSolSaveCnt>0)
                    resultMsg = System.Label.SVC_IF_NO_DATA; //There is no service/solution to send to SAP.
                }
            }else{
                resultMsg = checkMap.get(KEY_RESULT);
                System.debug('### OpportunityServiceSolutionMainController, onConfirmToSAP, resultMsg => ' + resultMsg);
            }
        } catch (Exception e) {
            resultMsg = e.getMessage();
            System.debug(e.getStackTraceString());
        }

        resultMap.put(KEY_MSG, resultMsg);
        resultMap.put(KEY_RESULT, result);
        System.debug('### OpportunityServiceSolutionMainController, onConfirmToSAP, resultMap => ' + resultMap);
        return resultMap;
    }
    
     public static Map<String,String> checkRequiredVal(Opportunity opprty){
        String resultMsg = '';
        String result = '';

        Map<String,String> resMap = new Map<String,String>();
        Map<String,String> fieldMap = Utils.getFieldLabel('Opportunity');       //Opporutnity 필드정보Map
        Map<String,String> fieldMapUser = Utils.getFieldLabel('User');          //User 필드정보Map

        String userObjectLabel = Util_String.nvlStr(Utils.getObjectLabel('User'));
        String empObjectLabel = Util_String.nvlStr(Utils.getObjectLabel('Employee__c'));

        Date closeDate = opprty.CloseDate;
        Date today = System.today();

        //closed stage set
        Set<String> OPP_STAGE_CLOSED_SET = new Set<String> { 
            OpportunityActivityHelper.OPP_STAGE_WON,
            OpportunityActivityHelper.OPP_STAGE_LOST,
            OpportunityActivityHelper.OPP_STAGE_DROP,
            OpportunityActivityHelper.OPP_STAGE_CLEANSED
        };

        Boolean ApprovalCompleted = false;
        // OPP_STAGE_CLOSED_SET에 포함되지않는 stage일 때, 수주품의 완료여부 체크
        if(!OPP_STAGE_CLOSED_SET.contains(opprty.StageName)){
            System.debug('### OpportunityServiceSolutionMainController, checkRequiredVal, 수주품의 완료여부 체크');
            //수주품의 완료 여부
            String transactionCode =  OpportunityActivityHelper.ACT_CODE_CONTRACT_APPROVAL;
            List<KnoxApproval__c> getApprovalInfo = [
                SELECT Id 
                FROM KnoxApproval__c 
                WHERE Status__c ='2' 
                AND Opportunity__c =: opprty.Id 
                AND OpportunityActivity__r.TransactionName__c =: transactionCode];


            if(getApprovalInfo.size() > 0){ 
                ApprovalCompleted = true;
            }
            
            if(ApprovalCompleted){
                Boolean isAdminProfile = Utils.isAdmin();
                
                //어드민 closeDate check 제외
                if(!isAdminProfile && closeDate < today){
                    system.debug('AkashanishTest1');
                    resultMsg = System.Label.OPPTYACT_MSG_009;
                    result = 'F';

                    resMap.put(KEY_MSG, result);
                    resMap.put(KEY_RESULT, resultMsg);

                    return resMap;
                }
            }
        }

        //Amount 금액 체크
        if(opprty.Amount == 0) resultMsg = Util_String.nvlStr(fieldMap.get('Amount'.toLowerCase()));

        //Opportunity 필수값 체크
        if(String.isBlank(opprty.OpportunityCode__c)) resultMsg = Util_String.nvlStr(fieldMap.get('OpportunityCode__c'.toLowerCase()));
        if(String.isBlank(opprty.CompanyCode__c)) resultMsg = Util_String.nvlStr(fieldMap.get('CompanyCode__c'.toLowerCase()));
        if(String.isBlank(opprty.cOriginAcc__c)) resultMsg += ((resultMsg.length() >  0) ? ', ' : '') + Util_String.nvlStr(fieldMap.get('cOriginAcc__c'.toLowerCase()));
        if(String.isBlank(opprty.cOriginAcc__r.AccountNumber)) resultMsg = Util_String.nvlStr(fieldMap.get('cOriginAcc__c'.toLowerCase()) + ' AccountNumber');
        if(String.isBlank(opprty.SalesDepartment__c) || String.isBlank(opprty.SalesDepartment__r.CostCenter__c)) resultMsg += ((resultMsg.length() >  0) ? ', ' : '') + Util_String.nvlStr(fieldMap.get('SalesDepartment__c'.toLowerCase()) + ' Code');
        if(String.isBlank(opprty.cPrimarySalesDepartment__c) || String.isBlank(opprty.cPrimarySalesDepartment__r.CostCenter__c)) resultMsg += ((resultMsg.length() >  0) ? ', ' : '') + Util_String.nvlStr(fieldMap.get('cPrimarySalesDepartment__c'.toLowerCase()) + ' Code');
        if(String.isBlank(opprty.Owner.EmployeeNumber)) resultMsg += ((resultMsg.length() >  0) ? ', ' : '') + userObjectLabel + '.' + Util_String.nvlStr(fieldMapUser.get('EmployeeNumber'.toLowerCase())); //' Owner.EmployeeNumber';
        if(opprty.cRevenueStartDate__c == null) resultMsg += ((resultMsg.length() >  0) ? ', ' : '') + Util_String.nvlStr(fieldMap.get('cRevenueStartDate__c'.toLowerCase()));
        if(opprty.cRevenueEndDate__c == null) resultMsg += ((resultMsg.length() >  0) ? ', ' : '') + Util_String.nvlStr(fieldMap.get('cRevenueEndDate__c'.toLowerCase()));
        if(String.isBlank(opprty.BiddingMethod__c)) resultMsg += ((resultMsg.length() >  0) ? ', ' : '') + Util_String.nvlStr(fieldMap.get('BiddingMethod__c'.toLowerCase()));
        if(String.isBlank(opprty.BusinessLevel__c)) resultMsg += ((resultMsg.length() >  0) ? ', ' : '') + Util_String.nvlStr(fieldMap.get('BusinessLevel__c'.toLowerCase()));

        // 2021.11.17 BusinessType2__c 체크 추가
        if(opprty.CompanyCode__c != null && opprty.CompanyCode__c == 'T100' && !opprty.GroupInternal__c && opprty.BusinessType2__c == null){
            resultMsg += ((resultMsg.length() >  0) ? ', ' : '') + Util_String.nvlStr(fieldMap.get('BusinessType2__c'.toLowerCase()));
        }

        String unmmapedMsg = '';
        if(String.isBlank(opprty.ProposalPM__c)){
            unmmapedMsg = System.Label.SVC_ERR_MSG_07;
            resultMsg += ((resultMsg.length() >  0) ? ', ' : '') + Util_String.nvlStr(fieldMap.get('ProposalPM__c'.toLowerCase()));
        }else{
            if(String.isBlank(opprty.ProposalPM__r.EvSapEmpNO__c)){
                resultMsg += ((resultMsg.length() >  0) ? ', ' : '') + Util_String.nvlStr(fieldMap.get('ProposalPM__c'.toLowerCase()));
                unmmapedMsg = System.Label.SVC_ERR_MSG_08;
            }

            else {
                //제안 PM의 사번 유효여부 체크(정수형)
                if(!Util_String.isInteger(opprty.ProposalPM__r.EvSapEmpNO__c)) {
                    resultMsg += ((resultMsg.length() >  0) ? ', ' : '') + System.Label.OPPTY_ERR_023;  //The Proposal PM's employee number is not valid.
                }
            }
        }

        // v4.3 -START Gitesh Saini
        String deptValidityMsg = '';
        if(String.isNotBlank(opprty.SalesDepartment__c) || String.isNotBlank(opprty.SalesDepartment__r.CostCenter__c) || String.isNotBlank(opprty.cPrimarySalesDepartment__c) || String.isNotBlank(opprty.cPrimarySalesDepartment__r.CostCenter__c)) {
            if(!Utils.isAdmin() && (opprty.OwnerId == UserInfo.getUserId())) {
                String errorMsg = System.Label.OPPTY_ERR_027;
                String fullErrorMsg = System.Label.OPPTY_ERR_028;
                String salesDeptId = String.valueOf(opprty.SalesDepartment__c);
                String deliveryDeptId = String.valueOf(opprty.cPrimarySalesDepartment__c);
                Boolean isSalesDeptValid, isDeliveryDeptValid;

                String userCompanyCode = [SELECT CompanyCode__c FROM User WHERE Id =: UserInfo.getUserId()].CompanyCode__c;
                
                if(String.isNotBlank(salesDeptId)) {
                    Map<Id, CostCenter__c> salesDept = new Map<Id, CostCenter__c>([SELECT Id, Closed__c, ZZCheck__c, CompanyCode__c FROM CostCenter__c WHERE Id =: salesDeptId]);
                    isSalesDeptValid = (salesDept.get(salesDeptId).Closed__c == false && salesDept.get(salesDeptId).ZZCheck__c == true && salesDept.get(salesDeptId).CompanyCode__c == userCompanyCode);
                }

                if(String.isNotBlank(deliveryDeptId)) {
                    Map<Id, CostCenter__c> deliveryDept = new Map<Id, CostCenter__c>([SELECT Id, Closed__c, ZZCheck__c, CompanyCode__c FROM CostCenter__c WHERE Id =: deliveryDeptId]);
                    isDeliveryDeptValid = (deliveryDept.get(deliveryDeptId).Closed__c == false && deliveryDept.get(deliveryDeptId).ZZCheck__c == true && deliveryDept.get(deliveryDeptId).CompanyCode__c == userCompanyCode);
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
        }

        if(!String.isBlank(resultMsg) || String.isNotBlank(deptValidityMsg)) result = 'F';    
        else result = 'S';

        if(Test.isRunningTest()) result = 'S';

        String requiredFields = resultMsg;

        resultMsg = System.Label.SVC_ERR_MSG_04 + '\n[' + resultMsg  + ']';//String.format( System.Label.SVC_ERR_MSG_04, new String[]{resultMsg});
        resultMsg += ((unmmapedMsg.length() > 0) ? '\n\n' : '') + unmmapedMsg;
        resultMsg = ((requiredFields.length() > 0) ? resultMsg + '\n\n' + deptValidityMsg : deptValidityMsg);
        // v4.3 -END- Gitesh Saini
        
        resMap.put(KEY_MSG, result);
        resMap.put(KEY_RESULT, resultMsg);

        System.debug('### OpportunityServiceSolutionMainController, checkRequiredVal, resMap => ' + resMap);
        return resMap;
    }
     
      public static Map<String,String> saveProject(Opportunity opprty, List<Service__c> lnewSvc, List<Solution__c> lnewSol ,Map<String,Object>  pjtResult, String INTERFACE_ID){
        Map<String,String> resultMap = new Map<String,String>();
        
        String resultMsg = 'SUCCESS';
        String resultType = 'S';
        String errMsg = '';         //인터페이스 에러 메시지
        Boolean isSave = true;      // Message TYPE이 모두 S일경우에만 저장. 외에는 처리x
        Boolean isSuccess = false;  //성공여부. true인 경우 후처리 로직 수행
        Integer scsCnt = 0;         //결과 성공 카운트
        Integer errCnt = 0;         //결과 실패 카운트
        Integer syncWBSCnt = 0;     //저장 후 데이터 Sync 결과값(ET_WBS_INFO가 있는 경우에만 Count)
        Id ifLogId;             //IF 로그 recordId. 동기화 로그를 위한 Id 변수

        try{
            List<Object> letMessage = (List<Object>)pjtResult.get('ET_MESSAGE');
            
            System.debug('### OpportunityServiceSolutionMainController, saveProject, letMessage :' + letMessage);
            if(letMessage != null){
                if (letMessage.size() > 0){
                    for(Object obj : letMessage){
                        Map<String,Object> objMap = (Map<String,Object>)obj;
                        String type = (String)objMap.get('TYPE');
                        String message = (String)objMap.get('MESSAGE');
                        //2022-09-26, hyunhak.roh@dkbmc.com, Project 생성 IF(IF-040) 관련 로직 개선
                        String id = (String)objMap.get('ID');
                        String excStr = 'Error reading/locking';
                        
                        if(type == 'S') {
                            scsCnt++;
                        }else if(type == 'W'){
                            errCnt++;
                            errMsg += '\n' + message;
                        }else if(type == 'E'){
                            if(id == 'CNIF_STATUS'
                               &&   message.contains(excStr)) {
                                System.debug('### OpportunityServiceSolutionMainController, saveProject, This is not an error.');
                            }
                            else {
                                errCnt++;
                                errMsg += '\n' + message;
                            }
                        }else{
                            errCnt++;
                            errMsg += 'unkown ET_MESSAGE.TYPE [' + type + '].' + '\n' + message;
                        }
                    }
                    if(errCnt == 0) isSuccess = true;
                } else {
                    isSuccess = false;
                    errMsg = 'ET_MESSAGE lit size 0.';
                }
            }else{
                isSuccess = true;
            }
          
            //
            if(!isSuccess){
                resultMsg = errMsg;
                resultType = 'E';
                resultMap.put(KEY_RESULT , resultType);
                resultMap.put(KEY_MSG , resultMsg);
                return resultMap;
            }

            //Knox메일에 사용할 서비스, 솔루션 정보
            List<Service__c> lchangeService= new List<Service__c>();
            List<Solution__c> lchangesolution = new List<Solution__c>();
            //update service,solution
            List<Service__c> luptServiceWBSInfo = new List<Service__c>();
            List<Solution__c> luptSolutionWBSInfo = new List<Solution__c>();

            //ET_WBS_INFO null check
            if(pjtResult.get('ET_WBS_INFO') == null){
                resultMsg = System.Label.SVC_ECC_ERR_01 + '\n' + errMsg + '\n ET_WBS_INFO return null';
                resultType = 'E';

                resultMap.put(KEY_RESULT , resultType);
                resultMap.put(KEY_MSG , resultMsg);
                return resultMap;
            }

            List<Object> pjtWBSInfo = (List<Object>)pjtResult.get('ET_WBS_INFO');
            List<Object> lpjtProject = new List<Object>();
            //IF-040인경우 PJTCode에 따라 Project 생성
            if(INTERFACE_ID == 'IF-040'){
                List<Object> ET_PJT_CODE_A = (pjtResult.get('ET_PJT_CODE_A')== null) ? new List<Object>() : (List<Object>)pjtResult.get('ET_PJT_CODE_A');
                List<Object> ET_PJT_CODE_C = (pjtResult.get('ET_PJT_CODE_C') == null) ? new List<Object>() : (List<Object>)pjtResult.get('ET_PJT_CODE_C');
                lpjtProject.addAll(ET_PJT_CODE_A);
                lpjtProject.addAll(ET_PJT_CODE_C);
            }
            System.debug('### OpportunityServiceSolutionMainController, saveProject, pjtWBSInfo:' + pjtWBSInfo);
            System.debug('### OpportunityServiceSolutionMainController, saveProject, lpjtProject:' + lpjtProject);
        
            List<WBS__c> lnewWBS = new List<WBS__c>();              //WBS Insert List
            List<Project__c> lnewProject = new List<Project__c>();  //Project Insert List

            if(pjtWBSInfo.size() > 0){
                if(INTERFACE_ID == 'IF-040'){
                    for(Object obj : lpjtProject){
                        String projectCode = (String) obj;      //projectCode: SMA-20061131-A0, SMC-20061131-A0...
                        Project__c pjt = new Project__c(
                            //DeletionFlag__c = false,
                            Description__c = '',      //05.03 BO Descrition 제외
                            Opportunity__c = opprty.Id,
                            ProjectCode__c = projectCode
                            //Name = opprty.Name;
                        );
                        //START V 3.8 Added by Divyam Gupta
                        String oppName = opprty.Name;
                        if(oppName.length() > 80){
                        String opprtyName = oppName.substring(0,80);
                        pjt.Name = opprtyName;
                           }
                        else {
                           pjt.Name = oppName;
                        }
                        //END V 3.8
                        lnewProject.add(pjt);
                    }
                }
                upsert lnewProject ProjectCode__c; //Project upsert. 2021.10.20 IF-007이 실시간으로 변경되어 Delete/Insert -> upsert로 dml 변경
                
                //WBS 생성, 서비스/솔루션 업데이트
                for(Integer i = 0 ; i < pjtWBSInfo.size(); i++){
                    Object obj = pjtWBSInfo[i];
                    Map<String, Object> objDataMap = (Map<String,Object>)obj;
                    String PSPID            = (objDataMap.get('PSPID') == null)          ? '' : objDataMap.get('PSPID').toString();             //프로젝트코드
                    String PSPID_OUTPUT     = (objDataMap.get('PSPID_OUTPUT') == null)   ? '' : objDataMap.get('PSPID_OUTPUT').toString();      //프로젝트코드(출력용)
                    String POSID            = (objDataMap.get('POSID') == null)          ? '' : objDataMap.get('POSID').toString();             //WBS코드
                    String ZZSOLUTION       = (objDataMap.get('ZZSOLUTION') == null)     ? '' : String.valueOf(objDataMap.get('ZZSOLUTION'));   //솔루션
                    String SERVICE          = (objDataMap.get('SERVICE') == null)        ? '' : String.valueOf(objDataMap.get('SERVICE'));      //서비스
                    String NUMBER_INT       = (objDataMap.get('NUMBER_INT') == null)     ? '' : String.valueOf(objDataMap.get('NUMBER_INT'));   //ItemNumber
                    String LOEVM            = (objDataMap.get('LOEVM') == null)          ? '' : objDataMap.get('LOEVM').toString();             //삭제여부
                    String SOLUTION_OWNER   = (objDataMap.get('SOLUTION_OWNER') == null) ? '' : objDataMap.get('SOLUTION_OWNER').toString();    //(손익기준)코스트센터코드
                    String ZZORDER_TYPE_S   = (objDataMap.get('ZZORDER_TYPE_S') == null) ? '' : objDataMap.get('ZZORDER_TYPE_S').toString();    //2021.02.28추가 BizAttributeCode
                    String ZZTECH_YN        = (objDataMap.get('ZZTECH_YN') == null)      ? '' : objDataMap.get('ZZTECH_YN').toString();         // Tech Attribute

                    Boolean loevmFlag = (LOEVM == 'X')  ? true : false;
                    Integer numberInt = Integer.valueOf(NUMBER_INT);
                    String WBSCLASS = POSID.substring(0,2);

                    if(String.isBlank(PSPID) || String.isBlank(POSID)){
                        String paramInfo = '';
                        paramInfo += (String.isBlank(PSPID)) ? 'PSPID ' : '';
                        paramInfo += (String.isBlank(POSID)) ? 'POSID ' : '';
                        resultMsg = String.format(System.Label.SVC_IF_ERR_MSG_01,new String[]{paramInfo});   //[IF-050] Error. Return Parameter ({ParamInfo}) is blank.
                        resultType = 'E';
                        break;
                    }

                    String projectType = POSID.substring(2,3);   //'C' : 실행코드, 'A': 사전영업코드. IF request시 C코드만 사용함
                    String project = '';    //Project Record Id
                    for(Project__c pjt : lnewProject){
                        if(pjt.ProjectCode__c == PSPID_OUTPUT){
                            project = pjt.Id;
                        }
                    }

                    //WBS정보 생성
                    WBS__c wbs = new WBS__c(
                        Name = POSID,
                        OpportunityID__c = opprty.Id,
                        DeletionFlag__c = (LOEVM == 'X')  ? 'Y' : 'N',  //'X' : true, '': false
                        ItemNumber__c = String.valueOf(numberInt),
                        ProjectCodeOutput__c = PSPID_OUTPUT,
                        ProjectCode__c = PSPID,
                        SolutionCode__c = ZZSOLUTION,
                        ServiceCode__c = SERVICE,
                        SolutionOwner__c = SOLUTION_OWNER,
                        Project__c = project,
                        BizAttribCode__c = ZZORDER_TYPE_S,
                        Solution__c = null,
                        ZZTECH_YN__c = ZZTECH_YN
                    );

                    if(projectType == 'C'){
                        //2021.07.25 서비스, 솔루션 WBSCode 구분 수정(ZZSOLUTION == null -> POSID.length 15)
                        if(POSID.length() == 15 && numberInt != 0){         //SERVICE WBS
                            Boolean hasService = false;
                            for(Integer j = 0; j < lnewSvc.size(); j++){
                                if(!lnewSvc[j].Changed__c) continue;

                                if(loevmFlag){
                                    //삭제된 경우 인터페이스에 저장된 값을 기준으로 판단
                                    hasService = (lnewSvc[j].ItemNumber__c.intValue() == numberInt 
                                                    && lnewSvc[j].Service__r.Code__c == SERVICE 
                                                    &&  lnewSvc[j].sDeletionFlag__c == true);
                                }else{
                                    //신규, 수정데이터는 현재 화면에 입력된 값 기준으로 판단
                                    hasService = (lnewSvc[j].ItemNumber__c.intValue() == numberInt 
                                                && lnewSvc[j].sService__r.Code__c == SERVICE 
                                                && lnewSvc[j].sDeletionFlag__c == false);
                                }

                                if(hasService){
                                    Service__c serClone = (Service__c)lnewSvc[j].clone(true);
                                    lChangeService.add(serClone);

                                    if(loevmFlag){
                                        lnewSvc[j].Changed__c = false;                                                                  //변경여부
                                        lnewSvc[j].SAP_SendTime__c = Datetime.now();                                                    //SAP 전송 시간
                                        lnewSvc[j].DeletionFlag__c = lnewSvc[j].sDeletionFlag__c;                                       //삭제여부
                                    }else{
                                        lnewSvc[j].WBSCode__c = POSID;                                                                  //WBSCode
                                        lnewSvc[j].SendSAP__c = true;                                                                   //SAP 전송 여부
                                        lnewSvc[j].Changed__c = false;                                                                  //변경 여부
                                        lnewSvc[j].DeletionFlag__c = lnewSvc[j].sDeletionFlag__c;                                       //삭제여부
                                        lnewSvc[j].Service__c = lnewSvc[j].sService__c;                                                 //서비스
                                        lnewSvc[j].DeliveryDepartment__c = lnewSvc[j].sDeliveryDepartment__c;                           //매출부서
                                        lnewSvc[j].SalesDepartment__c = lnewSvc[j].sSalesDepartment__c;                                 //수주부서
                                        lnewSvc[j].SAP_SendTime__c = Datetime.now();                                                    //SAP 전송 시간
                                        
                                        // 백업필드.(기록용)
                                        lnewSvc[j].ServiceBackup__c = lnewSvc[j].sService__r.Code__c;                                   //서비스 코드 백업
                                        lnewSvc[j].ServiceNmBackup__c = lnewSvc[j].sService__r.Name;                                    //서비스 명 백업
                                        lnewSvc[j].DeliveryDepartmentBackup__c = lnewSvc[j].sDeliveryDepartment__r.CostCenter__c;       //매출부서 코드 백업
                                        lnewSvc[j].DeliveryDepartmentNmBackup__c = lnewSvc[j].sDeliveryDepartment__r.CostCenterName__c; //매출부서 명 백업
                                        lnewSvc[j].SalesDepartmentBackup__c = lnewSvc[j].sSalesDepartment__r.CostCenter__c;             //수주부서 코드 백업
                                        lnewSvc[j].SalesDepartmentNmBackup__c = lnewSvc[j].sSalesDepartment__r.CostCenterName__c;       //수주부서 명 백업

                                    }
                                    luptServiceWBSInfo.add(lnewSvc[j]); //서비스의 WBS정보 update 하기위한 List
                                    lnewSvc.remove(j);                  //WBS정보를 가지고있는 Serivce는 remove
                                    break;
                                }
                            }
                        }else if(POSID.length() == 17){         //SOLUTION WBS
                            Boolean hasSolution = false;
                            for(Integer j = 0; j < lnewSol.size(); j++){
                                if(!lnewSol[j].Changed__c) continue;

                                if(loevmFlag){
                                    //삭제할 솔루션정보는 SAP에 등록되어있는 것을 기준으로 판단
                                    hasSolution = (lnewSol[j].ItemNumber__c.intValue() == Integer.valueOf(NUMBER_INT)  
                                                    && lnewSol[j].Service__r.Service__r.Code__c == SERVICE  
                                                    && lnewSol[j].Solution__r.Code__c == ZZSOLUTION  
                                                    && lnewSol[j].BizAttribute__r.Code__c == ZZORDER_TYPE_S 
                                                    && lnewSol[j].WBSClass__c == WBSCLASS
                                                    && lnewSol[j].sDeletionFlag__c == true);       
                                }else{          
                                    //신규, 수정데이터는 현재 화면에 입력된 값 기준으로 판단
                                    hasSolution = (lnewSol[j].ItemNumber__c.intValue() == Integer.valueOf(NUMBER_INT)  
                                                    && lnewSol[j].Service__r.sService__r.Code__c == SERVICE  
                                                    && lnewSol[j].sSolution__r.Code__c == ZZSOLUTION  
                                                    && lnewSol[j].sBizAttribute__r.Code__c == ZZORDER_TYPE_S 
                                                    && lnewSol[j].sWBSClass__c == WBSCLASS
                                                    && lnewSol[j].sDeletionFlag__c == false);
                                }

                                if(hasSolution){
                                    Solution__c solClone = (Solution__c )lnewSol[j].clone();
                                    lchangesolution.add(solClone);
                                    if(loevmFlag){
                                        lnewSol[j].Changed__c = false;                                                  //변경여부
                                        lnewSol[j].SAP_SendTime__c = Datetime.now();                                    //전송 시간
                                        lnewSol[j].DeletionFlag__c = lnewSol[j].sDeletionFlag__c;                       //삭제여부
                                    }else{
                                        lnewSol[j].WBSCode__c = POSID;                                                  //WBSCode__c update
                                        lnewSol[j].SendSAP__c = true;                                                   //SAP전송여부
                                        lnewSol[j].Changed__c = false;                                                  //변경여부
                                        lnewSol[j].DeletionFlag__c = lnewSol[j].sDeletionFlag__c;                       //삭제여부
                                        lnewSol[j].ProjectCode__c = PSPID_OUTPUT;                                       //ProjectCode
                                        lnewSol[j].Solution__c = lnewSol[j].sSolution__c;                               //솔루션
                                        lnewSol[j].BizAttribute__c = lnewSol[j].sBizAttribute__c;                       //사업속성
                                        lnewSol[j].BusinessType__c = lnewSol[j].sBusinessType__c;                       //businessType
                                        lnewSol[j].WBSClass__c = lnewSol[j].sWBSClass__c;                               //수익인식기준
                                        lnewSol[j].SAP_SendTime__c = Datetime.now();                                    //전송 시간
                                        lnewSol[j].PSType__c = lnewSol[j].sPSType__c;                                   //PSType

                                        //백업필드(기록용)
                                        lnewSol[j].SolutionBackup__c = lnewSol[j].sSolution__r.Code__c;                 //솔루션 코드 백업
                                        lnewSol[j].SolutionNmBackup__c = lnewSol[j].sSolution__r.Name;                  //솔루션 명 백업
                                        lnewSol[j].SolutionTypeBackup__c = lnewSol[j].sSolution__r.SolutionType__c;     //솔루션 타입 백업
                                        lnewSol[j].BizAttributeBackup__c = lnewSol[j].sBizAttribute__r.Code__c;         //사업속성 코드 백업
                                        lnewSol[j].BizAttributeNmBackup__c = lnewSol[j].sBizAttribute__r.Name;          //사업속성 명 백업
                                    }
                                    luptSolutionWBSInfo.add(lnewSol[j]);    //솔루션의 WBS정보 update 하기위한 List
                                    lnewSol.remove(j);                      //WBS정보를 가지고있는 솔루션 remove
                                    break;
                                }
                            }
                        }
                    }

                    lnewWBS.add(wbs); //WBS insert list
                }
                
                system.debug('hi this project code' );
                if(lChangeService.size() > 0 || lChangeSolution.size() > 0){
                    System.enqueueJob(new Callout_IF093(opprty));   // 2) IF-093. 결재상태 변경하기 위해 수행
                    System.debug('Collab Mail Trigger');
                }

                update luptServiceWBSInfo;      
                update luptSolutionWBSInfo;     
                
                // ----------------- WBS__c의 Solution__c 맵핑
                Map<String,Id> solInfoMap = new Map<String,Id>();
                List<Solution__c> solutionList = [SELECT Id, Name, ItemNumber__c, WBSCode__c, Service__r.Service__r.Code__c, Solution__r.Code__c, BizAttribute__r.Code__c, WBSClass__c, DeletionFlag__c, BusinessType__c, Service__r.TechAttribute__c FROM Solution__c WHERE Opportunity__c = : opprty.Id AND SendSAP__c = true];
                List<Solution__c> solActiveList = new List<Solution__c>();
                for(Solution__c sol : solutionList){
                    if(!sol.DeletionFlag__c) solActiveList.add(sol);       //SAP전송된 것 중 삭제되지않은 솔루션 add
                    String flag = sol.DeletionFlag__c ? 'Y' : 'N';
                    solInfoMap.put(sol.WBSCode__c, sol.Id);
                }

                for(WBS__c wbs: lnewWBS){
                    if(wbs.Name.subString(2,3) == 'A') continue;
                    if(String.isBlank(wbs.SolutionCode__c) || String.isBlank(wbs.ItemNumber__c) || Integer.valueOf(wbs.ItemNumber__c) == 0) continue;

                    Id solId = solInfoMap.get(wbs.Name);
                    wbs.Solution__c = solId;
                }
                upsert lnewWBS Name;  //WBS upsert. 2021.10.20 IF-007이 실시간으로 변경되어 Delete/Insert -> upsert로 dml 변경

                if(solActiveList.size() > 0) //updateOpptyBizType(opprty, solActiveList); //2021.08.17 @성유라프로 요청 - Project 수정/생성 이후 사업기회 사업유형 1 업데이트

                // result set
                resultType = 'S';
                if(INTERFACE_ID == 'IF-040') resultMsg = System.Label.SVCSOL_PJT_CREATE;        //Project change successfully.
                else if(INTERFACE_ID == 'IF-050') resultMsg = System.Label.SVCSOL_PJT_CHANGE;   //Project change successfully.
            }else{
                resultType = 'E';
                resultMsg = System.Label.SVC_IF_ERR_MSG_04; //ET_WBS_INFO is empty
            }
        }catch(Exception e){
            resultType = 'E';
            resultMsg = e.getMessage();
            System.debug(LoggingLevel.ERROR, e.getStackTraceString());
        }finally{
            //IF-040, IF-050 인터페이스 로그 생성
            if(pjtResult != null) ifLogId = createInterfaceLog2(pjtResult.get('INTERFACE_LOG'), opprty.Id);

            //ET_MESSAGE Type S인 경우 전체 데이터 동기화 진행
            if(isSuccess){
                List<SvcSolSyncLog__c> syncDataList = new List<SvcSolSyncLog__c>();
                if(INTERFACE_ID == 'IF-050') syncDataList = syncWBSInfo(opprty.Id, pjtResult); //WBS정보 mysales정보 Sync

                if(syncDataList != null && syncDataList.size() > 0){
                    for(SvcSOlSyncLog__c log : syncDataList){
                        log.IF_Log__c = ifLogId;
                    }
                }

                try{
                    insert syncDataList;
                }catch(Exception e){
                    System.debug(e.getStackTraceString());
                }

                if(syncDataList.size() > 0 ){
                    resultType = 'W';
                    resultMsg += '\n' + ' ' + System.Label.SVC_WAR_MSG_02;
                }
            }
        }

        resultMap.put(KEY_RESULT, resultType);
        resultMap.put(KEY_MSG, resultMsg);
        System.debug('### OpportunityServiceSolutionMainController, saveProject, resultMap => ' + resultMap);
        return resultMap;
    }

   public static void upsertOpportunityActivity(Map<Opportunity,Opportunity_Activity__c> oppMap, String actStatus){ 
        System.debug('### OpportunityServiceSolutionMainController, upsertOpportunityActivity ###' + oppMap);
        List<Opportunity_Activity__c> lstOppAcc = new List<Opportunity_Activity__c>();

       for(Opportunity opptyId : oppMap.keySet()){
           Opportunity_Activity__c oAcc = new Opportunity_Activity__c();
           oAcc.Id = oppMap.get(opptyId).Id;
            System.debug('### OpportunityServiceSolutionMainController, upsertOpportunityActivity 액티비티 상태 업데이트');
                
           
                if(!Utils.isSubsidiary(opptyId.CompanyCode__c) && 'TI'.equals(opptyId.BusinessType__c) && opptyId.Opportunity_Review_VRB_Type_Confirm__c==null ){
                    
                        oAcc.Status__c =  OPPTYACT_STATUS_INPROGRESS;  
                                          
                                  
                } else if(Utils.isSubsidiary(opptyId.CompanyCode__c) || opptyId.Collaboration__c == false || (opptyId.Collaboration__c == true && opptyId.CollaborationBOId__r.BusinessType__c != 'TI')){//V4.4 MYSALES-261
                    oAcc.Status__c = OPPTYACT_STATUS_COMPLETED;   
                }                                   
            
            
            if(oAcc.Status__c == OPPTYACT_STATUS_COMPLETED){
                if( String.isBlank(String.ValueOf(oAcc.StartDate__c)) ) {
                    oAcc.StartDate__c = Date.today();
                } else if (oAcc.StartDate__c > Date.today()) {
                    oAcc.StartDate__c = Date.today();
                }
   
                if( String.isBlank(String.ValueOf(oAcc.EndDate__c)) ) { 
                    oAcc.EndDate__c = Date.today(); 
                }
            }

            oAcc.ExtId__c = OpportunityActivityHelper.generateOpportunityActivityExtKey(oAcc);
           lstOppAcc.add(oAcc);
       }

            System.debug('### OpportunityServiceSolutionMainController, upsertOpportunityActivity, opptyAct:' + lstOppAcc);
            try{
                if(lstOppAcc.Size()>0){
                 upsert lstOppAcc;   
                }
                
            }catch(Exception e){
                System.debug('Error : ' + e.getMessage());
                System.debug('StackTrace : ' + e.getStackTraceString());
                System.debug('Line : ' + e.getLineNumber());
            }
        
    }

    public static void createInterfaceLog(Object ifLogObj,Id opptyId){
        try{
            IF_Log log = new IF_Log();
            if(ifLogObj != null){
                IF_Log.InterfaceLog iflog_interfaceLog = (IF_Log.InterfaceLog)ifLogObj;
                iflog_interfaceLog.RequestMsg =  'Opporunity:'+opptyId +'\n' + iflog_interfaceLog.RequestMsg;
                log.createLog(iflog_interfaceLog);
            } 
        }catch(Exception e){
            System.debug(LoggingLevel.ERROR, e.getStackTraceString());
        }
    }

    public static Id createInterfaceLog2(Object ifLogObj,Id opptyId){
        Id ifLogId;
        try{
            IF_Log log = new IF_Log();
            if(ifLogObj != null){
                IF_Log.InterfaceLog iflog_interfaceLog = (IF_Log.InterfaceLog)ifLogObj;
                iflog_interfaceLog.RequestMsg =  'Opporunity:'+opptyId +'\n' + iflog_interfaceLog.RequestMsg;
                ifLogId = log.createLog2(iflog_interfaceLog);
            } 
        }catch(Exception e){
            System.debug(LoggingLevel.ERROR, e.getStackTraceString());
        }
        return ifLogId;
    }
    
    
     public static List<SvcSolSyncLog__c> syncWBSInfo(Id opptyId, Map<String,Object> pjtResult){
        List<SvcSolSyncLog__c> syncDataList = new List<SvcSolSyncLog__c>();
        String syncResult = '';
        List<Service__c> lSvc = [SELECT Id, Name, ItemNumber__c, Changed__c,SendSAP__c, sDeletionFlag__c, DeletionFlag__c, sService__c,Service__r.Code__c, Service__r.Name, sService__r.Code__c, sService__r.Name, Service__c, sDeliveryDepartment__c, sDeliveryDepartment__r.CostCenter__c, DeliveryDepartment__c, DeliveryDepartment__r.CostCenter__c, sSalesDepartment__c, sSalesDepartment__r.CostCenter__c, SalesDepartment__c, SalesDepartment__r.CostCenter__c, TechAttribute__c, Opportunity__c, Opportunity__r.OpportunityCode__c,
            (SELECT Id, Name, ItemNumber__c,Service__c, Service__r.Service__r.Code__c, Service__r.Service__r.Name ,Service__r.sService__r.Code__c, Service__r.sService__r.Name, Service__r.TechAttribute__c, WBSCode__c, Changed__c, SendSAP__c, sDeletionFlag__c, DeletionFlag__c, sSolution__c, sSolution__r.Code__c, sSolution__r.Name, Solution__c, Solution__r.Code__c, Solution__r.Name, sBizAttribute__c, sBizAttribute__r.Code__c, BizAttribute__c, BizAttribute__r.Code__c, sWBSClass__c, WBSClass__c, sPSType__c, PSType__c ,sBusinessType__c , BusinessType__c
            , sSolutionType__c, SolutionType__c, Opportunity__c, Opportunity__r.OpportunityCode__c FROM Solution__r)
            FROM Service__c 
            WHERE Opportunity__c  = :opptyId];
        
        Boolean processSFDC = true;
        List<Object> pjtWBSInfoList = new List<Object>();

        if(pjtResult != null && pjtResult.get('ET_WBS_INFO') != null){
            pjtWBSInfoList= (List<Object>) pjtResult.get('ET_WBS_INFO');

            processSFDC = (pjtWBSInfoList.size() > 0) ? false : true;
        }
        
        if(processSFDC){
            //ET_WBS_INFO 가 없는경우 SFDC의 이전 SAP에 전송된 데이터를 기준으로 update
            rollbackSFDC(lSvc);
        }else{
            //ET_WBS_INFO 기준으로 데이터 update
            syncDataList = syncByWBSInfo(lSvc, pjtWBSInfoList);
        }

        return syncDataList;
    }
    
    public static List<SvcSolSyncLog__c> syncByWBSInfo(List<Service__c> lSvc, List<Object> pjtWBSInfoList){
        System.debug('### OpportunityServiceSolutionMainController, start syncByWBSInfo ###');
        Set<Id> svcIdSet = new Set<Id>();
        Set<Id> solIdSet = new Set<Id>();
        List<Solution__c> luptSol = new List<Solution__c>(); 
        List<Service__c> luptSvc = new List<Service__c>(); 
        List<Solution__c> lsol = new List<Solution__c>();

        Map<String, Service__c> svcMap = new Map<String, Service__c>();
        Map<String, Service__c> svcIFMap = new Map<String, Service__c>();
        Map<Integer, List<Solution__C>> solMap = new Map<Integer, List<Solution__C>>();
        Map<Integer, List<Solution__C>> solIFMap = new Map<Integer, List<Solution__C>>();
        
        List<SvcSolSyncLog__c> syncDataList = new List<SvcSolSyncLog__c>();
        for(Service__c svc: lSvc){
            lsol.addAll(svc.Solution__r);
        }

        System.debug('### OpportunityServiceSolutionMainController, syncByWBSInfo, pjtWBSInfoList.size: ' + pjtWBSInfoList.size());
        for(Object obj : pjtWBSInfoList){
            Map<String, Object> objDataMap = (Map<String,Object>)obj;
            System.debug('### OpportunityServiceSolutionMainController, syncByWBSInfo, objDataMap => ' + objDataMap);
            String ZZSOLUTION       = (objDataMap.get('ZZSOLUTION') == null)     ? '' : String.valueOf(objDataMap.get('ZZSOLUTION'));    //솔루션
            String PSPID            = (objDataMap.get('PSPID') == null)          ? '' : objDataMap.get('PSPID').toString();              //프로젝트코드
            String PSPID_OUTPUT     = (objDataMap.get('PSPID_OUTPUT') == null)   ? '' : objDataMap.get('PSPID_OUTPUT').toString();       //프로젝트코드(출력용)
            String POSID            = (objDataMap.get('POSID') == null)          ? '' : objDataMap.get('POSID').toString();              //WBS코드
            String SERVICE          = (objDataMap.get('SERVICE') == null)        ? '' : String.valueOf(objDataMap.get('SERVICE'));       //서비스
            String NUMBER_INT       = (objDataMap.get('NUMBER_INT') == null)     ? '' : String.valueOf(objDataMap.get('NUMBER_INT'));    //ItemNumber
            String LOEVM            = (objDataMap.get('LOEVM') == null)          ? '' : objDataMap.get('LOEVM').toString();              //삭제여부
            String SOLUTION_OWNER   = (objDataMap.get('SOLUTION_OWNER') == null) ? '' : objDataMap.get('SOLUTION_OWNER').toString();    //(손익기준)코스트센터코드
            String ZZORDER_TYPE_S   = (objDataMap.get('ZZORDER_TYPE_S') == null) ? '' : objDataMap.get('ZZORDER_TYPE_S').toString();    //BizAttributeCode
            String ZZTECH_YN        = (objDataMap.get('ZZTECH_YN') == null)      ? '' : objDataMap.get('ZZTECH_YN').toString();         // Tech Attribute
            
            if(String.isBlank(POSID)) continue;

            Integer numberInt = Integer.valueOf(NUMBER_INT);
            Boolean loevmFlag = (LOEVM == 'X')  ? true : false;
            String WBSCLASS = POSID.substring(0,2);

            if(POSID.length() == 15 && numberInt != 0){     //service
                for(Integer i = 0; i < lSvc.size(); i++){
                    Service__c svc = lSvc[i];
                    Boolean hasService = false;
                    hasService = (svc.ItemNumber__c.intValue() == numberInt 
                                        && svc.sService__r.Code__c == SERVICE);

                    if(hasService){
                        System.debug('### OpportunityServiceSolutionMainController, syncByWBSInfo, HAS SERVICE:' + svc);
                        lSvc.remove(i); 
                        break;
                    }else{
                        Boolean hasChangeService = false;

                        hasChangeService = (svc.ItemNumber__c.intValue() == numberInt 
                                && svc.Service__r.Code__c == SERVICE );
                        if(hasChangeService){
                            System.debug('### OpportunityServiceSolutionMainController, syncByWBSInfo, CHANGE_SERVICE:' + svc);
                            luptSvc.add(svc);
                            lSvc.remove(i);
                            break;
                        }
                    }
                }
            }else if(POSID.length() == 17){     //Solution
                for(Integer i =0; i <  lsol.size(); i++){
                    Solution__c sol = lsol[i];
                    Boolean hasSolution = (sol.ItemNumber__c.intValue() == numberInt 
                                        && sol.Service__r.sService__r.Code__c == SERVICE 
                                        && sol.sSolution__r.Code__c == ZZSOLUTION
                                        && sol.sBizAttribute__r.Code__c == ZZORDER_TYPE_S  
                                        && sol.sDeletionFlag__c == loevmFlag
                                        && sol.sWBSClass__c == WBSCLASS);
                    Boolean hasChangeSolution = false;

                    if(hasSolution){
                        System.debug('### OpportunityServiceSolutionMainController, syncByWBSInfo, HAS SOLUTION:' + sol);
                        lsol.remove(i);
                        break;
                    } else{
                        //화면에서 PSType 변경 시 IF-050에서는 D->I 를 수행하므로 삭제만 되고, 실제로 Insert되지 않는 경우가 있어서 deleteSolution = true인 경우
                        //원래 값으로 update 하기 위한 변수
                        Boolean deleteSolution = (sol.sPSType__c != sol.PSType__c || sol.sSolutionType__c != sol.SolutionType__c );   

                        hasChangeSolution = (sol.ItemNumber__c.intValue() == numberInt 
                                        && sol.Service__r.Service__r.Code__c == SERVICE 
                                        && sol.Solution__r.Code__c == ZZSOLUTION
                                        && sol.BizAttribute__r.Code__c == ZZORDER_TYPE_S
                                        && (sol.DeletionFlag__c == loevmFlag || deleteSolution == loevmFlag)
                                        && sol.WBSClass__c == WBSCLASS);
                        if(hasChangeSolution){
                            if(deleteSolution){
                                sol.DeletionFlag__c = loevmFlag;
                                sol.sDeletionFlag__c = loevmFlag;
                            } 
                            System.debug('### OpportunityServiceSolutionMainController, syncByWBSInfo, CHANGE_SOLUTION:' + sol);
                            luptSol.add(sol);
                            lsol.remove(i);
                            break;
                        }
                    }
                }
            }
        } 


        //rollback data
        for(Solution__c sol: luptSol){
            sol.sDeletionFlag__c = sol.DeletionFlag__c;
            sol.sSolution__c = sol.Solution__c;
            sol.sBizAttribute__c = sol.BizAttribute__c;
            sol.sBusinessType__c = sol.BusinessType__c;
            sol.sWBSClass__c = sol.WBSClass__c;
            sol.sPSType__c = sol.PSType__c;
            sol.Changed__c = false;
        }

        //rollback data
        for(Service__c svc: luptSvc) {
            svc.sDeletionFlag__c = svc.DeletionFlag__c;
            svc.sService__c = svc.Service__c;
            svc.sDeliveryDepartment__c = svc.DeliveryDepartment__c;
            svc.sSalesDepartment__c = svc.SalesDepartment__c;
            svc.Changed__c = false;
        }

        
        List<Service__c> delSvcList =  new List<Service__c>();
        for(Integer i = 0; i < lSvc.size(); i++){
            Service__c svc = lSvc.get(i);
            if(svc.sDeletionFlag__c && !svc.SendSAP__c) continue;

            delSvcList.add(svc);
        }

        update luptSol;     //솔루션 이전값으로 update
        update luptSvc;     //서비스 이전값으로 update

        String RT_SERVICE  = SvcSolSyncLog__c.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Service').getRecordTypeId(); 
        String RT_SOLUTION = SvcSolSyncLog__c.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Solution').getRecordTypeId();

        for(Service__c svc : delSvcList){
            syncDataList.add(
                new SvcSolSyncLog__c(
                    RecordTypeId = RT_SERVICE
                    , Opportunity__c = svc.Opportunity__c
                    , Service__c = svc.Id
                    , ItemNumber__c = svc.ItemNumber__c
                    , ServiceName__c = svc.Service__r.Name
                    , ServiceCode__c = svc.Service__r.Code__c
                    , sServiceCode__c = svc.sService__r.Code__c
                    , sServiceName__c = svc.sService__r.Name
                    , DeletionFlag__c = svc.DeletionFlag__c
                    , sDeletionFlag__c = svc.sDeletionFlag__c
                    , DeliveryDeptCode__c = svc.DeliveryDepartment__r.CostCenter__c
                    , sDeliveryDeptCode__c = svc.sDeliveryDepartment__r.CostCenter__c
                    , SalesDeptCode__c = svc.SalesDepartment__r.CostCenter__c
                    , sSalesDeptCode__c = svc.sSalesDepartment__r.CostCenter__c
                )
            );
        }

        for(Solution__c sol : lsol){
            syncDataList.add(
                new SvcSolSyncLog__c(
                    RecordTypeId = RT_SOLUTION
                    , Opportunity__c = sol.Opportunity__c
                    , Solution__c = sol.Id
                    , BizAttributeCode__c = sol.BizAttribute__r.Code__c
                    , DeletionFlag__c = sol.DeletionFlag__c
                    , ItemNumber__c = sol.ItemNumber__c
                    , sBizAttributeCode__c = sol.sBizAttribute__r.Code__c
                    , sDeletionFlag__c = sol.sDeletionFlag__c
                    , sSolutionCode__c = sol.sSolution__r.Code__c
                    , SolutionCode__c = sol.Solution__r.Code__c
                    , SolutionName__c = sol.Solution__r.Name
                    , sSolutionName__c = sol.sSolution__r.Name
                    , sWBSClass__c = sol.sWBSClass__c
                    , WBSClass__c = sol.WBSClass__c
                )
            );
        }
        
        //if(lsol.size() > 0 || delSvcList.size() > 0) resultMsg = '(테스트중)일치하지 않는 WBS 정보가 있습니다. SR 요청하세요.';
        return syncDataList;
    }

    public static void rollbackSFDC(List<Service__c> lSvc){
        System.debug('### OpportunityServiceSolutionMainController, rollbackSFDC, start rollbackSFDC ###');
        List<Service__c> ldelService = new List<Service__c>();
        List<Solution__c> ldelSolution = new List<Solution__c>();
        List<Solution__c> luptSolution = new List<Solution__c>();

         //changed__c= true 인 경우 IF-050의 ET_WBS_INFO 정보와 맵핑되지않은 데이터이므로 처리 안된건에 대해서 데이터 rollback처리함
        for(Service__c svc: lSvc) {
            if(svc.Changed__c){
                if(svc.SendSAP__c){
                    svc.sDeletionFlag__c = svc.DeletionFlag__c;
                    svc.sService__c = svc.Service__c;
                    svc.sDeliveryDepartment__c = svc.DeliveryDepartment__c;
                    svc.sSalesDepartment__c = svc.SalesDepartment__c;
                    svc.Changed__c = false;
                }else{                  
                    ldelService.add(svc);
                    // svc.sDeletionFlag__c = svc.DeletionFlag__c;
                }
            }
            
            List<Solution__c> lSol = svc.Solution__r;
            for(Solution__c sol: lSol) {
                if(sol.Changed__c){
                    if(sol.SendSAP__c){
                            sol.sDeletionFlag__c = sol.DeletionFlag__c;
                            sol.sSolution__c = sol.Solution__c;
                            sol.sBizAttribute__c = sol.BizAttribute__c;
                            sol.sBusinessType__c = sol.BusinessType__c;
                            sol.sWBSClass__c = sol.WBSClass__c;
                            sol.sPSType__c = sol.PSType__c;
                            sol.Changed__c = false;
                            luptSolution.add(sol);
                    }else{
                        ldelSolution.add(sol);
                    }
                }
            }
        }
        
        update luptSolution;
        update lSvc;
        delete ldelSolution;
        delete ldelService;
    }
    
    public static IF_PsCreatePjtNoController.InputClass render_IF_040(Opportunity opprty, List<Solution__C> lnewsol){
        IF_PsCreatePjtNoController.InputClass input = new IF_PsCreatePjtNoController.InputClass();
        IF_PsCreatePjtNoController.IS_HEADER header = new IF_PsCreatePjtNoController.IS_HEADER();
        List<IF_PsCreatePjtNoController.IT_SERVICE> litService = new List<IF_PsCreatePjtNoController.IT_SERVICE>();
        IF_PsCreatePjtNoController.IT_TLINE itTline = new IF_PsCreatePjtNoController.IT_TLINE();
        List<IF_PsCreatePjtNoController.IT_TLINE> litTline = new List<IF_PsCreatePjtNoController.IT_TLINE>();

        String boCode               = opprty.OpportunityCode__c;                       //사업기회코드
        String boNm                 = opprty.Name;                                     //사업기회명
        String companyCode          = opprty.CompanyCode__c;                           //회사코드   
        String zzfhd_cd             = opprty.CompanyCode__c;                           //총괄부서코드
        String main_fkstl           = opprty.cPrimarySalesDepartment__r.CostCenter__c; //매출부서코드
        String main_akstl           = opprty.SalesDepartment__r.CostCenter__c;         //수주부서코드
        String opportunityId        = opprty.Id;                                       //사내대체 프로젝트코드
        String owrner               = opprty.Owner.EmployeeNumber;                     //영업담당자사번
        String proposalPm           = opprty.ProposalPM__r.EvSapEmpNO__c;                 //제안PM사번
        String originCustomer       = opprty.cOriginAcc__r.AccountNumber;              //원청사 고객사번호
        String bizlevel             = opprty.BusinessLevel__c;                         //사업등급
        Date closeDate              = opprty.closeDate;                                //수주예상일
        Date revenueStartDate       = opprty.cRevenueStartDate__c ;                    //프로젝트 시작일
        Date revenueEndDate         = opprty.cRevenueEndDate__c;                       //프로젝트 종료일

        String closeDateStr         = convertDateFormat(closeDate);
        String revenueStartDateStr  = convertDateFormat(revenueStartDate);
        String revenueEndDateStr    = convertDateFormat(revenueEndDate);

        //make IS_HEADER
        header.ZZORDER_ID           = boCode;  
        header.DESCRIPTION          = boNm;
        header.BUKRS                = companyCode;          //defaultvalue T100
        header.KOKRS                = 'T100';               //this fileld value must be 'T100' 
        header.MAIN_FKSTL           = main_fkstl; 
        header.MAIN_AKSTL           = main_akstl; 
        header.ORIGIN_CUSTOMER      = originCustomer; 
        header.CUSTOMER             = originCustomer;//originCustomer;//'T100';
        header.SALES_PLFAZ          = getSalesPlfaz(opprty.Id);
        header.SALES_PLSEZ          = closeDateStr;
        header.PLFAZ                = revenueStartDateStr;
        header.PLSEZ                = revenueEndDateStr; 
        header.CONTRACT_EXP_DATE    = closeDateStr;
        header.ZZSALEMP_CNO         = owrner;
        header.ZZPROPOSAL_PM_CNO    = proposalPm;
        header.ZZBIZ_LEVEL          = bizlevel;
        header.ZZSUBS_PJT           = opportunityId; 

        //make IT_SERVICE
        String zzsubs_pjt = 'X';

        //SvcSolBizAttr__c 사업속성, 사업유형, 수익인식기준 조회
        for(Solution__c sol: lnewsol){
            IF_PsCreatePjtNoController.IT_SERVICE itService = new IF_PsCreatePjtNoController.IT_SERVICE();
            String gubun = WBSHelper.getGubun(sol.sSolutionType__c, companyCode, sol); //v1.1 sol added

            if(sol.ItemNumber__c != 10) zzsubs_pjt = '';
            itService.SERVICE           = sol.Service__r.sService__r.Code__c;                   //서비스
            itService.SERVICE_NAME      = String.valueOf(sol.ItemNumber__c) + ' : ' + sol.Service__r.sService__r.Name;                      //서비스 명 (2021.05.18 itemnumber 추가 )
            itService.SOLUTION          = sol.sSolution__r.Code__c;                             //솔루션 
            itService.SOLUTION_NAME     = sol.sSolution__r.Name;                                //솔루션 명
            itService.SUB_FKSTL         = sol.Service__r.sDeliveryDepartment__r.CostCenter__c;  //매출부서코드 
            itService.SUB_AKSTL         = sol.Service__r.sSalesDepartment__r.CostCenter__c;     //수주부서코드
            itService.ZZFHD_CD          = null;                                                 //총괄부서(2021.03.25  zzfhd_cd -> null값으로 변경 )
            itService.GUBUN             = gubun;                                                //1 : Labor, 2: HW&SW, 3: 도입 SOLUTION, 4: 자사 SOLUTION
            itService.NUMBER_INT        = String.valueOf(sol.ItemNumber__c);                    //Item Number
            itService.ZZORDER_TYPE_S    = sol.sBizAttribute__r.Code__c;                         //사업속성(솔루션)
            itService.ZZBIZ_TYPE_S      = sol.sBusinessType__c;                                 //사업유형(솔루션)
            itService.ZZWBS_CLASS_S     = sol.sWBSClass__c;                                     //수익인식기준(솔루션) SM,SI,SC...
            itService.ZZSERVICE_REP_X   = zzsubs_pjt;                                           //대표 서비스 구분값
            itService.ZZTECH_YN         = (sol.Service__r.TechAttribute__c) ? 'Y' : 'N';        //2021.08.27 TA 속성 여부 

            litService.add(itService);
        }

        itTline.TDLINE = '';    //Text Line
        litTline.add(itTline);

        input.IV_BIZ_PLAN = '';
        input.IS_HEADER = header;
        input.IT_SERVICE = litService;
        input.IT_TLINE = litTline;

        return input;
    }
    
    public static String getSalesPlfaz(Id opptyId){
        TimeZone tz = UserInfo.getTimeZone();
        DateTime dt = DateTime.now();
        String plfaz = dt.format('yyyy.MM.dd', tz.getId());
        List<KnoxApproval__c> knoxApprovalList = [
                SELECT  Id
                FROM    KnoxApproval__c
                WHERE   Opportunity__c = :opptyId
                    AND OpportunityActivity__r.TransactionName__c = :OpportunityActivityHelper.ACT_CODE_CONTRACT_APPROVAL
                    AND ( Status__c = :KnoxApprovalHelper.KNOX_APPROVAL_STATUS_COMPLETED
                        OR Status__c = :KnoxApprovalHelper.KNOX_APPROVAL_STATUS_ARBITRARY_CONFIRMED
                        OR Status__c = :KnoxApprovalHelper.KNOX_APPROVAL_STATUS_AFTER_CONFIRMED
                        )
        ];

        if(knoxApprovalList.size() > 0){
            List<Opportunity_Activity__c> actList = [SELECT Id, Name, EndDate__c FROM Opportunity_Activity__c 
            WHERE WhatId__c =: opptyId AND TransactionName__c = : OpportunityActivityHelper.ACT_CODE_REVIEW_BO];

            if(actList.size() > 0){
                Date endDate = actList.get(0).EndDate__c;
                plfaz = convertDateFormat(endDate);
            }
        }
        return plfaz;
    }

    public static String convertDateFormat(Date dateInfo){
        if(dateInfo == null) return '';
        String monthStr = String.valueOf(dateInfo.month());
        String dayStr = String.valueOf(dateInfo.day());
        return dateInfo.year() + '.' + (((monthStr.length()== 1)) ? '0' : '')  +dateInfo.month() + '.' + ((dayStr.length() == 1) ? '0': '') + dateInfo.day();
    }
    
    public class Callout_IF093 implements Queueable, Database.AllowsCallouts {
        private Opportunity oppty;

        public Callout_IF093(){}
        public Callout_IF093(Opportunity oppty){
            this.oppty = oppty;
        }

        public void execute(QueueableContext context) {
            ZP21ProgChange();
        }

        private void ZP21ProgChange(){
            IF_EccPaymentProgChangeController.OutputHeader output = new IF_EccPaymentProgChangeController.OutputHeader();
            output.IV_WFOBJECT = 'ZCRM000050';
            output.IV_OBJECTKEY = '';
            output.IV_STATUS = 'AP';
            output.IV_ZZORDER_ID = oppty.OpportunityCode__c;
            output.IV_PROCESS_TYPE = OpportunityActivityHelper.ACT_CODE_REVIEW_BO;
            output.CT_SOL = new List<IF_EccPaymentProgChangeController.CT_SOL>();
            
            Map<String,Object> returnMap = IF_EccPaymentProgChangeController.paymentProgChange(JSON.serialize(output));
            createInterfaceLog(returnMap.get('INTERFACE_LOG'), oppty.Id);
        }
    }
  
}