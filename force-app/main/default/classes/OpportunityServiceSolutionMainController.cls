/**
 * @description       : 
 * @author            : seonju.jin@dkbmc.com
 * @group             : 
 * @last modified on  : 2023-10-26
 * @last modified by  : anish.jain@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                 Modification
 * 1.0   2020-11-18   seonju.jin@dkbmc.com   Initial Version
 * 1.1   2020-12-16   seonju.jin@dkbmc.com   1.solution salesType 추가 / 2.opportunity BusinessType__c update 추가
 * 1.2   2020-12-24   seonju.jin@dkbmc.com   IF 호출시 비정상 오류에 대한 예외처리  
 * 1.3   2020-12-24   seonju.jin@dkbmc.com   Batch_LsDashboardController batch exceute 추가
 * 1.4   2020-01-04   seonju.jin@dkbmc.com   Opportunity Activity의 Status 조회값 파라미터 추가
 * 1.5   2020-01-15   seonju.jin@dkbmc.com   Solution__c.ProjectCode__c 필드추가, WBS__c.Solution__c 필드추가
 * 1.6   2020-01-19   seonju.jin@dkbmc.com   PJT/WBS Upsert -> Delte/Insert DML 변경
 * 1.7   2020-01-20   seonju.jin@dkbmc.com   Opportunity Amount 0원일경우 PJT 생성 안되도록 수정
 * 1.7   2020-01-20   seonju.jin@dkbmc.com   Batch 클래스 변경 Batch_LsDashboardController -> IF_LsDashboardController
 * 1.8   2020-01-28   seonju.jin@dkbmc.com   SFDC에서 사용하는 필드와 SAP전송시 사용하는 필드 구분.(SFDC 필드는 기존 필드명 앞에 s 추가)
 * 1.9   2020-01-28   seonju.jin@dkbmc.com   SvcSolBizAttr__c.PSType__c 필드 추가. PSType__C 관련 로직 추가 
 * 2.0   2020-01-28   seonju.jin@dkbmc.com   Opportunity BiddingMethod__c필드 SAP전송시 필수 필드 체크 추가
 * 2.1   2020-02-17   seonju.jin@dkbmc.com   Opportunity ReuseReason__c(재활용 결정사유)필드 SAP전송시 필수 필드 체크 추가
 * 2.2   2020-02-17   seonju.jin@dkbmc.com   수주품의 완료시에 CloseDate 체크,법인/자회사일 경우 에만 ReuseReason__c 체크 
 * 2.3   2020-03-24   seonju.jin@dkbmc.com   마이그 시 폐쇄된 서비스/솔루션인경우 리스트 추가하여 화면에서 보여지도록 customObject에 origin필드 추가
 * 2.4   2020-03-25   seonju.jin@dkbmc.com   IF-040 ZZFHD_CD를 zzfhd_cd-> null값으로 파라미터 전달 변경
 * 2.5   2020-05-07   seonju.jin@dkbmc.com   IF-093 IV_STATUS":"" -> "AP"  , (마이그에디터) 협업데이터가 collaborationInOut 필드가 마이그안되어 처리
 * 2.6   2020-05-17   seonju.jin@dkbmc.com   upsertOpportunityActivity 임시저장 or 프로젝트 최초 생성 후 Activity Status 값 변경 추가 / IF-050 SERVICE_NAME 파라미터 수정
 * 2.7   2020-05-18   seonju.jin@dkbmc.com   IF040,050 파라미터 값 수정(SERVICE_NAME = ItemNumber + ' : ' + ServiceName) - itemnumber, serviceName 사이 공백 추가함
 * 2.8   2020-07-12   seonju.jin@dkbmc.com   ChangeProject Test 중 변경 요청(김룡일프로) : IF-050 요청파라미터 수정 (OPTION D->I일 때, IT_SERVICE구성을 IT_SOLUTION과 1:1 되도록 구성 변경)
 * 2.9   2020-07-14   seonju.jin@dkbmc.com   ChangeProject IT_SERVICE 구성 이전 로직으로 재변경
 * 3.0   2020-07-26   seonju.jin@dkbmc.com   SaveProject: 서비스, 솔루션 WBSCode 구분 수정(ZZSOLUTION == null -> POSID.length 15)
 * 3.1   2020-07-27   seonju.jin@dkbmc.com   LsDashboard serviceId null 오류 수정   
 * 3.2   2021-08-17   seonju.jin@dkbmc.com   @성유라프로 요청 - Project 수정/생성 이후 사업기회 사업유형 1 업데이트
 * 3.3   2021-11-05   seonju.jin@dkbmc.com   서비스 하위 솔루션 모두 삭제처리 되면 서비스도 삭제처리
 * 3.4   2021-11-17   seonju.jin@dkbmc.com   BizType2 필수 체크 추가
 * 3.5   2022-01-17   seonju.jin@dkbmc.com   checkRequiredVal ProposalPM_User__c 체크로직 제외
 * 3.6   2022-07-04   hyunhak.roh@dkbmc.com  IF-050(PJT 변경) 응답으로 ET_MESSAGE가 오지 않을 때의 처리 로직 변경
 * 3.7   2022-09-26   hyunhak.roh@dkbmc.com  Project 생성 IF(IF-040) 관련 로직 개선
 * 3.8   2022-11-29   divyam.gupta@samsung.com        IF -040 & IF-050 added condition for check project name length.
 * 3.9   2022-11-16   anish.jain@partner.samsung.com          IF -171 call on Service/Solution tab
 * 4.0   2023-02-09   akash.g@samsung.com             MySales 131 -Change error expression
 * 4.1   2023-01-23   anish.jain@partner.samsung.com  'Review Opportunity' Post Processing IF logs (My Sales - 107)
 * 4.2   2023-04-21   saurav.k@partner.samsung.com  (MySales -171) -IF-042(Send Service/Solution Info to Legacy) modification
 * 4.3   2023-05-23   gitesh.s@samsung.com    MYSALES-196 - Added error to check invalid Primary Sales Dept. (Lv.3) and Primary Delivery Dept. (Lv.3)
 * 4.4   2023-07-24   d.ashish@samsung.com    MYSALES-261 - Added Condition to not Complete BO Review automatically  when Opportunity is HQ collaboration and Related Subsidery business type is Implementation.
 * 4.5   2023-10-26   anish.jain@partner.samsung.com  MS-302
**/
public without sharing class OpportunityServiceSolutionMainController {
    //Use resultMap Key name
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

    /**
    * @description oppty 정보, 협업 정보 조회
    * @author seonju.jin@dkbmc.com | 2021-02-17 
    * @param String opportId 
    * @param String opptyActId 
    * @return Map<String, Object> 
    **/
    @AuraEnabled
    public static Map<String, Object> getOpptyInfo(String opportId, String opptyActId){
        System.debug('### OpportunityServiceSolutionMainController, getOpptyInfo, opportId:' + opportId + ',opptyActId:' + opptyActId);
        Map<String, Object> resultMap = new Map<String, Object>();
        Map<String, Object> infoMap = new Map<String, Object>();
        List<Opportunity> opptyList;
        String returnMsg = 'SUCCESS';
        String actStatus;
        Integer techStatus = INIT_SERVICE;

        try {
            String sobjectType = (Id.valueOf(opportId)).getSObjectType().getDescribe().getName();

            if(sobjectType != 'Opportunity'){
                throw new AuraHandledException(System.Label.SVC_ERR_MSG_09);
            }

            //2020-01-04 status 조회 추가
            List<Opportunity_Activity__c> opprtyActInfo = [SELECT Id,Name,Status__c FROM Opportunity_Activity__c WHERE Id =: opptyActId];
            actStatus = (opprtyActInfo.size() > 0) ? Util_String.nvlStr(opprtyActInfo[0].Status__c) : '';

            opptyList = [SELECT Id
                            , Name
                            , CollaborationInOut__c     //본사 IN, 법인 OUT
                            , Collaboration__c          //Collaboration flag
                            , CollaborationBOId__c      //Collabo BO Id
                            , CompanyCode__c            //CompanyCode
                            FROM Opportunity 
                            WHERE Id = :opportId];

            if(opptyList.size() == 0) {
                returnMsg = System.Label.SVCSOL_NO_OPPRTY;
            }
            
            //TA 상태
            List<Service__c> svcList = [SELECT Id, Name, TechAttribute__c, sService__r.TechAttribute__c, Service__r.TechAttribute__c, SendSAP__c, sDeletionFlag__c FROM Service__c WHERE Opportunity__c = :opportId AND DeletionFlag__c = false AND SendSAP__c = true];

            Integer sendSAPCnt = 0;
            for(Service__c svc : svcList){
                if(svc.SendSAP__c) sendSAPCnt++;
            }

            Boolean initService = (sendSAPCnt > 0) ? false : true; 
            for(Service__c svc : svcList){
                if(!svc.SendSAP__c && svc.sDeletionFlag__c) continue;

                if(initService){
                    if(svc.sService__r.TechAttribute__c){
                        techStatus = TECH_SERVICE;
                        break;
                    }else{
                        techStatus = NORMAL_SERVICE;
                        break;
                    }
                }else{
                    if(svc.Service__r.TechAttribute__c){
                        techStatus = TECH_SERVICE;
                        break;
                    }else{
                        techStatus = NORMAL_SERVICE;
                        break;
                    }
                }
            }

        } catch (Exception e) {
            returnMsg = e.getMessage();
            e.getCause();
        }

        system.debug('### OpportunityServiceSolutionMainController, getOpptyInfo, opptyList:' + opptyList);
        infoMap.put('oppty'     , opptyList.get(0));                        //Opportunity Info
        infoMap.put('actStatus' , actStatus);                               //Activity Status
        infoMap.put('locked'    , Approval.isLocked(opptyList.get(0).Id));  //Lock 여부
        infoMap.put('techStatus', techStatus);                              //서비스 솔루션 TA 상태값
        infoMap.put('initService', (techStatus == INIT_SERVICE));           //TA 변경 가능 여부
        
        resultMap.put(KEY_MSG, returnMsg);
        resultMap.put(KEY_RESULT, infoMap);
        return resultMap;
    }

    /**
    * @description service/solution 조회
    * @author seonju.jin@dkbmc.com | 2020-11-24 
    * @param String opportId opportunity recordId
    * @return List<ServiceSolution> 
    **/
    @AuraEnabled
    public static Map<String,Object> selectSvcSol(String opportId){
        Map<String,Object> returnMap = new Map<String,Object>();

        
        List<ServiceSolution> serviceList = new List<ServiceSolution>();
        List<Integer> itemNumbers = new List<Integer>();
        Boolean isTempSave = false;
        try{
            //select Service__c 
            List<Service__c> lservice = [SELECT Id
                                                , Name
                                                , sDeletionFlag__c                           //삭제여부
                                                , DeletionFlag__c                           //삭제여부
                                                , ItemNumber__c                             //ItemNumber
                                                , sService__c                                //MasterService.Id
                                                , sService__r.Name                           //MasterService.Name
                                                , sService__r.Code__c                           //MasterService.Name
                                                , sDeliveryDepartment__c                     //매출부서
                                                , sDeliveryDepartment__r.CostCenterName__c
                                                , sSalesDepartment__c                        //수주부서
                                                , sSalesDepartment__r.CostCenterName__c
                                                , SendSAP__c
                                                , Changed__c                                //수정여부
                                                , TechAttribute__c                          //2021.08.25 TA 여부 추가
                                                , sService__r.TechAttribute__c
                                                , ( SELECT Id
                                                        , Name
                                                        , Service__c                
                                                        , ItemNumber__c             
                                                        , sSolution__c              
                                                        , sSolution__r.Name
                                                        , Solution__c              
                                                        , sBizAttribute__c       
                                                        , sBizAttribute__r.Name
                                                        , sBizAttribute__r.Code__c
                                                        , sDeletionFlag__c       
                                                        , SalesType__c          
                                                        , sSolutionType__c
                                                        , SolutionType__c
                                                        , sWBSClass__c           
                                                        , sPLCStatus__c          
                                                        , sBusinessType__c       
                                                        , SendSAP__c
                                                        , Changed__c
                                                        , sPSType__c
                                                        , PSType__c
                                                        , Service__r.TechAttribute__c
                                                        , Service__r.sService__c
                                                        , sSolution__r.Service__c
                                                    FROM Solution__r
                                                    WHERE sDeletionFlag__c = false
                                                    ORDER BY Name ASC
                                                )
                                        FROM Service__c
                                        WHERE Opportunity__c = : opportId
                                        /* AND sDeletionFlag__c = false */
                                        ORDER BY ItemNumber__c ASC]; 

            Set<String> sid = new Set<String>();

            if(lservice.size() > 0){
                for(Service__c svc: lservice){
                    if(svc.Changed__c) isTempSave = true;
                    for(Solution__c sol : svc.Solution__r){
                        if(sol.Changed__c) isTempSave = true;
                    }
                    sid.add(svc.Id);
                }
            }
            
            serviceList = renderServiceList(lservice);

            //서비스 ItemNumber 정보 조회
            List<Service__c> litemNumber = [SELECT Id, ItemNumber__c  FROM Service__c WHERE Opportunity__c = : opportId ORDER BY ItemNumber__c];

            if(litemNumber.size() > 0){
                for(Service__c svc: litemNumber){
                    itemNumbers.add(svc.ItemNumber__c.intValue());
                }
            }

        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }

        returnMap.put('serviceList', serviceList);
        returnMap.put('itemNumberInfo', itemNumbers);
        returnMap.put('isTempSave', isTempSave);
        return returnMap;
    }


    /**
    * @description 화면에서 사용가능하도록 parsing
    * @author seonju.jin@dkbmc.com | 2020-11-24 
    * @param List<Service__c> lservice select Service__c
    * @param List<Solution__c> lsolution select Solution__c
    * @return List<ServiceSolution> 
    **/
    @AuraEnabled
    public static List<ServiceSolution> renderServiceList(List<Service__c> lservice){
        List<ServiceSolution> serviceList = new List<ServiceSolution>();

        List<Map<String,String>> SolutionTypeMap = Utils.getPicklistOptionType('Master_Solution__c', 'SolutionType__c');
        List<Map<String,String>> PLCMap = Utils.getPicklistOptionType('Master_Solution__c', 'PLCStatus__c');
        List<Map<String,String>> BizTypeMap = Utils.getPicklistOptionType('SvcSolBizAttr__c', 'BusinessType__c');
        // Map<Id, Master_Service__c> masterSvcMap = new Map<Id, Master_Service__c>([SELECT Id, Name, TechAttribute__c FROM Master_Service__c]);

        try{
            Integer idx = 0;
            Boolean isChecked = true;
            for(Service__c svc: lservice){
                ServiceSolution ssObj = new ServiceSolution();
                Service service = new Service();
                SelectRecord salesRecord = new SelectRecord();
                SelectRecord deptRecord = new SelectRecord();
                String deptNm = Util_String.nvlStr(svc.sDeliveryDepartment__r.CostCenterName__c);
                
                service.recordId    = svc.Id;
                service.itemNumber  = svc.ItemNumber__c.intValue();
                service.serviceId   = svc.sService__c;
                service.serviceNm   = svc.sService__r.Name;
                service.serviceCode   = svc.sService__r.Code__c;

                salesRecord.Id      = svc.sSalesDepartment__c;
                salesRecord.Name    = svc.sSalesDepartment__r.CostCenterName__c;
                service.salesRecord = salesRecord;

                deptRecord.Id       = svc.sDeliveryDepartment__c;
                deptRecord.Name     = deptNm;
                service.deptRecord  = deptRecord;

                service.isSendSAP   = svc.SendSAP__c;
                
                service.checked     = (!svc.sDeletionFlag__c && isChecked) ? true : false;      //화면에 보여지는 첫번재 행 checked true 처리
                if(service.checked)  isChecked = false;

                service.isDeleted   = svc.sDeletionFlag__c;
                System.debug('### OpportunityServiceSolutionMainController, renderServiceList, service delete:' + service.isDeleted);
                service.isChanged   = svc.Changed__c;

                SelectRecord serviceRecord = new SelectRecord();
                serviceRecord.Id = service.serviceId;
                serviceRecord.Name = service.serviceNm;
                service.originService = serviceRecord;
                // service.originSales = service.salesRecord;
                service.originDept = service.deptRecord;

                service.techyn = svc.TechAttribute__c;
                System.debug('### OpportunityServiceSolutionMainController, renderServiceList, service: ' + svc);
                System.debug('### OpportunityServiceSolutionMainController, renderServiceList, service ta:' + service.techyn);
                // service.techDisable = (masterSvcMap.get(service.serviceId) != null) ? masterSvcMap.get(service.serviceId).TechAttribute__c : false ; //sService__c 의 TA여부가 true인경우 disable true /  TA여부가 false인경우 false

                List<SolutionObj> solutionList = new List<SolutionObj>();
                for(Integer i = 0; i < svc.Solution__r.size(); i++){
                    Solution__c sol = svc.Solution__r[i];
                    Solution solution = new Solution();
                    SolutionObj solObj = new SolutionObj();
                    solution.serviceRecordId = sol.Service__c;
                    solution.recordId = sol.Id;
                    solution.serviceId = service.serviceId;
                    solution.serviceIdx = idx;
                    solution.solutionId = sol.sSolution__c;
                    solution.solutionNm = Util_String.nvlStr(sol.sSolution__r.Name);
                    solution.attributeId = sol.sBizAttribute__c;
                    solution.attributeNm = Util_String.nvlStr(sol.sBizAttribute__r.Name);
                    solution.isSendSAP = sol.SendSAP__c;
                    solution.wbsClass = sol.sWBSClass__c;
                    
                    //2020.12.16 요청필드 추가 salesType, solutionType, plcStaus
                    solution.salesType = (sol.SalesType__c == null)  ? '' : sol.SalesType__c;
                    solution.salesTypeEnable = String.isNotBlank(sol.SalesType__c);
                    solution.solutionType = (sol.sSolutionType__c == null) ? '' : sol.sSolutionType__c;
                    solution.psType = sol.sPSType__c;
                    
                    solution.solutionTypeNm = sol.sSolutionType__c;
                    String solutionTypeNm = '';
                    for(Map<String,String> map1 : SolutionTypeMap){
                        if(map1.get('value').toUpperCase() == (solution.solutionType).toUpperCase()){
                            solutionTypeNm = map1.get('label');
                            break;
                        } 
                    }
                    solution.solutionTypeNm = solutionTypeNm;

                    String plcStaus = '';
                    for(Map<String,String> map1 : PLCMap){
                        String temp = Util_String.nvlStr(sol.sPLCStatus__c);
                        if(map1.get('value').toUpperCase() == (temp).toUpperCase()){
                            plcStaus = map1.get('label');
                            break;
                        } 
                    }
                    solution.plcStatus = plcStaus;
                    
                    String bizType = '';
                    for(Map<String,String> map1 : BizTypeMap){
                        String sBizType = Util_String.nvlStr(sol.sBusinessType__c);
                        if(map1.get('value').toUpperCase() == (sBizType).toUpperCase()){
                            bizType = map1.get('label');
                            break;
                        } 
                    }
                    solution.bizType = bizType;

                    solution.itemNumber = svc.ItemNumber__c.intValue();
                    solution.isChanged = sol.Changed__c;
                    solution.isDeleted = sol.sDeletionFlag__c;

                    /**
                     * 2022.01.25 TA 마이그로 인해, 
                     * sSolution - 마스터솔루션의 부모 서비스와, 상위 서비스의 마스터 서비스가 같지 않을경우
                     * 강제로 솔루션 콤보박스 옵션에 추가하기 위함.
                     */
                    // if(sol.Service__r.sService__c != sol.sSolution__r.Service__c){ 
                    solution.originSolId = sol.sSolution__c;
                    solution.originSolNm = sol.sSolution__r.Name;
                    solution.originSvcId = svc.sService__c;
                    // } 
                    solution.originSolType = sol.sSolutionType__c;
                    solution.originSolTypeNm = solutionTypeNm;
                    solution.originPlcStatus = plcStaus;
                    
                    /* saved data */
                    SelectRecord solutionRecord = new SelectRecord();
                    solutionRecord.Id = solution.solutionId;
                    solutionRecord.Name = solution.solutionNm;

                    SelectRecord attrRecord = new SelectRecord();
                    attrRecord.Id = solution.attributeId;
                    attrRecord.Name = solution.attributeNm;

                    SelectRecord solTypeRecord = new SelectRecord();
                    solTypeRecord.Id = solution.solutionType;
                    solTypeRecord.Name = solution.solutionTypeNm;
                    solObj.solution = solution;
                    solutionList.add(solObj);
                }

                ssObj.service = service;
                ssObj.solutionList = solutionList;

                serviceList.add(ssObj);
                idx++;
            }
        }catch(Exception e){
            System.debug(LoggingLevel.ERROR, e.getMessage());
            System.debug(LoggingLevel.ERROR, e.getStackTraceString());
            serviceList = new List<ServiceSolution>();
        }

        return serviceList;
    }

    /**
     * (Professianl Service) 추가가능여부 체크
     * WBS체크
     * @param List<String> itemNumberList 용역솔루션을 추가할 itemNumbeList
     * @return Map<String,Object> key: itemNumber / value: 용역솔루션 추가 가능 여부
     */
    @AuraEnabled
    public static Map<String,Object> addSolType10Check(String opptyId, String companyCode, List<String> itemNumberList){
        Map<String,Object> returnMap = new Map<String,Object>();
        for(String numberStr : itemNumberList){
            returnMap.put(numberStr, true);
        }

        try {
            // wbs정보 조회
            WBSHelper wbsHelper = WBSHelper.getInstance(opptyId, companyCode);
            List<WBS__c> wbsList = wbsHelper.getWBSList();
            for(WBS__c wbs : wbsList){
                String wbsCode = wbs.Name;
                if(wbs.WBSLevel__c != '3') continue;
                if(wbsCode.right(2) != '11') continue;  //용역솔루션만 체크

                for(String numberStr: itemNumberList){
                    Integer itemNumber = Integer.valueOf(numberStr);
                    if(itemNumber == wbs.ItemNumberInt__c){
                        returnMap.put(String.valueOf(itemNumber), false);
                        break;
                    }
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return returnMap;
    }

    /**
    * @description service/solution 저장
    * @author seonju.jin@dkbmc.com | 2020-11-23 
    * @param String opportId opportunity.Id
    * @param String jsonStr service, solution List
    * @param Boolean isSendSAP true: create/project 전 임시저장 / false: 임시저장
    * @return String return msg
    **/
    @AuraEnabled
    public static Map<String, Object> saveServiceList(String opportId, String jsonStr, Boolean isSendSAP){
        System.debug('saveServiceList');
        System.debug('isSendSAP__' + isSendSAP);
        System.debug('### OpportunityServiceSolutionMainController, saveServiceList ### ');
        System.debug('### OpportunityServiceSolutionMainController, saveServiceList, jsonStr : ' + jsonStr);
        Map<String, Object> resultMap = new Map<String, Object>();
        String resultMsg = 'SUCCESS';

        List<Opportunity> opptyList = [SELECT Id, CompanyCode__c
                    FROM Opportunity
                    WHERE id =: opportId 
                    LIMIT 1];

        try{
            List<ServiceSolution> ssList = (List<ServiceSolution>)JSON.deserialize(jsonStr, List<ServiceSolution>.class);

            if(ssList.size() > 0){
                resultMap = saveService(opportId, ssList);
            }else{
                resultMsg = System.Label.SVC_ERR_MSG_06;
                resultMap.put('SAVE_MSG', resultMsg);
            }


            //2021.07.29 seonju.jin@dkbmc.com (조미옥 프로요청) 서비스솔루션 임시저장 후 신대시보드 전송 추가
          //  if(!Test.isRunningTest() && !isSendSAP) IF_LsDashboardController.calloutDashboardInfo(new Set<Id>{Id.valueOf(opportId)});//4.1(MySales - 172)
            system.debug('isSendSAP______' + isSendSAP);
        }catch(Exception e){
            resultMap.put('SAVE_MSG', e.getMessage());
        }finally{
            if(resultMap.get('SAVE_MSG') == 'SAVE_SUCCESS') {
                if(resultMap.get('SAVE_MSG') == 'SAVE_SUCCESS') upsertOpportunityActivity(opportId, opptyList.get(0).CompanyCode__c, OPPTYACT_STATUS_INPROGRESS);
            }
        }

        return resultMap;
    }

    
    /**
    * @description service 저장
    * @author seonju.jin@dkbmc.com | 2020-12-02 
    * @param String opportId opportunity Id
    * @param List<ServiceSolution> ssList service&solution list
    **/
    @AuraEnabled
    public static Map<String, Object> saveService(String opportId, List<ServiceSolution> ssList){

        //use resultMap
        Map<String, Object> resultMap = new Map<String, Object>();      //result
        String resultMsg = '';
        String saveErrMsg = '';

        Map<Integer,String> mitemUpsertInfo = new Map<Integer,String>();
        try{
            //화면에서 생성 or 수정한 service, soluion 정보
            List<ServiceSolution> lchangeSvc = new List<ServiceSolution>();     
            List<SolutionObj> lupsertSolution = new List<SolutionObj>();
            List<Service__c> lupsertService = new List<Service__c>();

            List<String> lchangeSvcId = new List<String>();
            Set<String> lsvcId = new Set<String>();

            for(ServiceSolution obj : ssList){
                Service sObj = obj.service;
                String Id = sObj.recordId;
                //lnewss.add(obj);

                if(String.isEmpty(Id)){ //INSERT
                    Service__c service = new Service__c();
                    service.ItemNumber__c           = sObj.itemNumber;      //ItemNumber
                    service.Changed__c              = true;
                    service.Opportunity__c          = opportId;             //Opportunity.Id
                    service.sService__c             = sObj.serviceId;       //MasterService.Id
                    service.sDeliveryDepartment__c  = sObj.deptRecord.Id;   //CostCenter.Id(DEPT-매출부서)
                    service.sSalesDepartment__c     = sObj.salesRecord.Id;  //CostCenterD.Id(SALES-수주부서)
                    service.TechAttribute__c        = sObj.techyn;
                    lupsertService.add(service);
                }else{                  //CHANGE or DELETE
                    lchangeSvcId.add(Id);
                    lchangeSvc.add(obj);
                }
                
                for(SolutionObj solObj : obj.solutionList){
                    lupsertSolution.add(solObj);
                }
            }

            //수정할 service 정보 조회
            Map<Id, Service__c> svcMap = new Map<Id, Service__c>([
                SELECT Id
                    , Name
                    , sDeletionFlag__c                          //삭제여부
                    , DeletionFlag__c                           //삭제여부
                    , ItemNumber__c                             //ItemNumber
                    , sService__c                               //MasterService.Id
                    , sService__r.Name                          //MasterService.Name
                    , sService__r.Code__c                       //MasterService.Code
                    , Service__c                                //MasterService.Id
                    , Service__r.Name                           //MasterService.Name
                    , Service__r.Code__c                        //MasterService.Code
                    , sDeliveryDepartment__c                    //매출부서
                    , sDeliveryDepartment__r.CostCenterName__c
                    , sDeliveryDepartment__r.CostCenter__c
                    , DeliveryDepartment__c                     //매출부서
                    , DeliveryDepartment__r.CostCenterName__c
                    , DeliveryDepartment__r.CostCenter__c
                    , sSalesDepartment__c                       //수주부서
                    , sSalesDepartment__r.CostCenterName__c
                    , sSalesDepartment__r.CostCenter__c
                    , SalesDepartment__c                        //수주부서
                    , SalesDepartment__r.CostCenterName__c
                    , SalesDepartment__r.CostCenter__c
                    , SendSAP__c
                    , Changed__c                                //수정여부
                FROM Service__c
                WHERE Id = :lchangeSvcId
                AND DeletionFlag__c = false
                ORDER BY ItemNumber__c]);

            //Update CHANGE or Delete Service info
            for(ServiceSolution obj: lchangeSvc){
                Service sObj = obj.service;
                Service__c service = svcMap.get(sObj.recordId);

                if(service == null) continue;
                if(sObj.isDeleted){
                    Boolean isChanged = true;
                    if(service.SendSAP__c) isChanged  = true;
                    else isChanged  = false;
                    service.Changed__c = isChanged;

                    service.sDeletionFlag__c         = sObj.isDeleted;      //삭제여부
                }else{
                    service.ItemNumber__c            = sObj.itemNumber;
                    service.sService__c              = sObj.serviceId;      //serviceId
                    service.sDeliveryDepartment__c   = sObj.deptRecord.Id;  //DeliveryDepartment
                    service.sSalesDepartment__c      = sObj.salesRecord.Id; //salesDepartment
                    service.TechAttribute__c         = sObj.techyn;
                    Boolean isChanged = false;
                    //SAP정보와 달라지면 Chagned__c = true
                    if(service.sService__c !=  service.Service__c) isChanged = true;
                    if(service.sDeliveryDepartment__c != service.DeliveryDepartment__c ) isChanged = true;
                    if(service.sSalesDepartment__c != service.SalesDepartment__c) isChanged = true;
                    
                    /* 2021.05.14  마이그 데이터 chaged 로직처리 */
                    if(!service.SendSAP__c) isChanged  = true;
                    
                    service.Changed__c = isChanged;
                }
                lupsertService.add(service);
            }

            //update service info
            upsert lupsertService;
            //Solution save
            Map<String,Object> solResult = saveSolution(lupsertSolution, opportId, lupsertService);
            //get result to solution info
            String msg = (String) solResult.get(KEY_MSG);
            //saveErrMsg = (String) solResult.get('DUPLICATE_SOl');
            if(msg == 'SAVE_SUCCESS') resultMsg = 'SAVE_SUCCESS';
            else resultMsg = msg;
        }catch(Exception e){
            //V 4.0 MySales -131
            resultMsg = e.getMessage();
            System.debug(LoggingLevel.ERROR, resultMsg);
        }

        resultMap.put('SAVE_MSG', resultMsg);
        return resultMap;
    }

    /**
    * @description solution 저장
    * @author seonju.jin@dkbmc.com | 2020-12-07 
    * @param List<SolutionObj> lsolution 
    * @param String opportId 
    * @param List<Service__c> lservice 서비스 
    * @return Map<String, Object> 
    **/
    public static Map<String, Object> saveSolution(List<SolutionObj> lsolution, String opportId, List<Service__c> lservice){
        System.debug('### OpportunityServiceSolutionMainController, saveSolution ###');
        Map<String, List<String>> solSaveInfo = new Map<String, List<String>>();
        Map<String, Object> resultMap = new Map<String, Object>();  //result
        String resultMsg = '';
        
        List<String> solIds = new List<String>();
        List<Solution__c> lupsertSolution = new List<Solution__c>();    //update solution.
        List<Solution__c> ldelSolution = new List<Solution__c>();       //update solution.
        List<SolutionObj> luptSolutionObj = new List<SolutionObj>();

        List<String> solutionCIds = new List<String>();
        List<String> bizattrCIds = new List<String>();
        List<Opportunity> opptyList = [SELECT Id, Name, CompanyCode__c FROM Opportunity WHERE Id = :opportId];

        for(SolutionObj sol : lsolution){
            solutionCIds.add(sol.solution.solutionId);
            bizattrCIds.add(sol.solution.attributeId);
        }

        String duplMsg = '';

        //SvcSolBizAttr 의 WBSClass__c, BusinessType__c                            
        List<SvcSolBizAttr__c> lsolBizAttr = [SELECT Id, BizAttribute__c, BusinessType__c , WBSClass__c, Solution__c  FROM SvcSolBizAttr__c WHERE Solution__c = : solutionCIds  AND BizAttribute__c = : bizattrCIds];                            
        //SAP에 전송된 Solution 조회.(솔루션 신규 추가 시 중복처리 확인용)
        List <Solution__c> solcheckList = [SELECT Id, ItemNumber__c, PSType__c , BusinessType__c, WBSClass__c, Changed__c, Solution__c, BizAttribute__c FROM Solution__c WHERE Opportunity__c = :opportId/*  AND DeletionFlag__c = true */ AND SendSAP__c = true];

        for(SolutionObj obj: lsolution){
            Solution sObj = obj.solution;
        }

        try{
            for(SolutionObj obj: lsolution){
                Solution sObj = obj.solution;
                String Id = sObj.recordId;
                //Solution 신규
                if(String.isEmpty(Id) && !sObj.isDeleted){
                    Solution__c solution = new Solution__c();
                    //get Service__c
                    String svcRecordId = '';
                    for(Service__c service: lservice){
                        if(sObj.itemNumber == service.ItemNumber__c){
                            svcRecordId = service.Id;
                        }
                    }
                    solution.Service__c             = svcRecordId;
                    solution.sDeletionFlag__c       = false;
                    solution.Changed__c             = true;

                    String solId = sObj.solutionId;
                    String attrId = sObj.attributeId;
                    String salesType = sObj.salesType;
                    solution.sSolution__c       = solId;         //MasterSolution__c
                    solution.sBizAttribute__c   = attrId;    //Biz.Attribute

                    if(salesType == null) salesType = '';
                    solution.SalesType__c   = Util_String.nvlStr(salesType);

                    String WBSClass = '';
                    String BusinessType = '';
                    String psType = '';
                    for(SvcSolBizAttr__c solBiz :lsolBizAttr){
                        if(solBiz.Solution__c == solId && solBiz.BizAttribute__c == attrId){
                            BusinessType = solBiz.BusinessType__c;
                            break;
                        }
                    }
                    solution.Opportunity__c = opportId;
                    solution.sWBSClass__c = sObj.wbsClass;
                    solution.sBusinessType__c = BusinessType;
                    solution.sPSType__c = sObj.psType;
                    lupsertSolution.add(solution);
                } else{
                    luptSolutionObj.add(obj);      //upsert SolutionObj info
                    solIds.add(Id);                 //Solution__c RecordId add
                }
            }

            //솔루션 수정건 , 삭제건 add
            Map<Id, Solution__c> solMap = new Map<Id, Solution__c>([SELECT Id
                                                    , Name
                                                    , Service__c            //Service__c.Id
                                                    , Service__r.sDeletionFlag__c
                                                    , ItemNumber__c         //ItemNumber
                                                    , sSolution__c           //MasterSolution.Id
                                                    , sSolution__r.Name
                                                    , sSolution__r.Code__c
                                                    , Solution__c           
                                                    , Solution__r.Name
                                                    , Solution__r.Code__c
                                                    , sBizAttribute__c       
                                                    , sBizAttribute__r.Name
                                                    , sBizAttribute__r.Code__c
                                                    , BizAttribute__c       
                                                    , BizAttribute__r.Name
                                                    , BizAttribute__r.Code__c
                                                    , sDeletionFlag__c       //화면삭제여부
                                                    , DeletionFlag__c       //SAP삭제여부
                                                    , SalesType__c          //SalesType
                                                    , sSolutionType__c
                                                    , SolutionType__c
                                                    , sWBSClass__c           //WBSClass
                                                    , WBSClass__c           //WBSClass
                                                    , sPLCStatus__c          //PLCStatus
                                                    , sBusinessType__c       //BizType
                                                    , BusinessType__c       //BizType
                                                    , SendSAP__c
                                                    , Changed__c 
                                                    , Service__r.sDeliveryDepartment__c
                                                    , Service__r.DeliveryDepartment__c
                                                    , Service__r.sSalesDepartment__c
                                                    , Service__r.SalesDepartment__c
                                                    , Service__r.TechAttribute__c
                                                    , Service__r.SendSAP__c
                                                    , Service__r.ItemNumber__c
                                                FROM Solution__c WHERE Opportunity__c  = :opportId]);
            
            for(SolutionObj obj: luptSolutionObj){
                Solution sObj = obj.solution;
                Solution__c solution = solMap.get(sObj.recordId);
                if(solution == null) continue;

                //service의 deletionFlag__c가 true면 하위 soltuion 모두 true
                Boolean deletionFlag = (solution.Service__r.sDeletionFlag__c) ? true : sObj.isDeleted;   
                System.debug('### OpportunityServiceSolutionMainController, saveServiceList, sol ' + sObj.recordId + '-deletionFlag:' + deletionFlag);
                if(deletionFlag){
                    //SAP에 전송된 데이터이면 DeletionFlag false로
                    if(solution.SendSAP__c){            
                        solution.sDeletionFlag__c = deletionFlag;
                        solution.Changed__c = true;
                        lupsertSolution.add(solution);   //Delete
                    }else{
                        //SAP에 전송되지 않은 데이터는 삭제처리
                        ldelSolution.add(solution);
                    }
                }else{
                    String solId = sObj.solutionId;
                    String attrId = sObj.attributeId;
                    String salesType = sObj.salesType;
                    solution.sSolution__c = solId;    
                    solution.sBizAttribute__c = attrId;
                    
                    if(salesType == null) salesType = '';
                    solution.SalesType__c   = salesType;    //SalesType__c
                    
                    String WBSClass = '';
                    String BusinessType = '';
                    for(SvcSolBizAttr__c solBiz :lsolBizAttr){
                        if(solBiz.Solution__c == solId && solBiz.BizAttribute__c == attrId){
                            WBSClass = solBiz.WBSClass__c;
                            BusinessType = solBiz.BusinessType__c;
                            break;
                        }
                    }

                    solution.sWBSClass__c = WBSClass;
                    solution.sBusinessType__c = BusinessType;
                    solution.sPSType__c = sObj.psType;

                    Boolean isChanged = false;
                    // SAP전송정보와 달라지면 Changed__c = true
                    if(solution.sSolution__c != solution.Solution__c) isChanged = true;
                    if(solution.sBizAttribute__c != solution.BizAttribute__c) isChanged = true;
                    if(solution.sWBSClass__c != solution.WBSClass__c) isChanged = true;
                    
                    /* 2021.05.14  마이그 데이터 chaged 로직처리 */
                    if(!solution.SendSAP__c) isChanged  = true;
                    
                    solution.Changed__c = isChanged;
                    lupsertSolution.add(solution);  
                }
            }

            List<Service__c> luptService = [SELECT Id, Name , Changed__c, sService__c, Service__c, SendSAP__c, sDeletionFlag__c, ItemNumber__c,
            (SELECT Id, Name FROM Solution__r WHERE DeletionFlag__c = false)
            ,sDeliveryDepartment__c,DeliveryDepartment__c, sSalesDepartment__c, SalesDepartment__c  FROM Service__c WHERE Opportunity__c = :opportId];
            
            delete ldelSolution;
            upsert lupsertSolution;

            //솔루션이 변경되면 서비스Changed__c true로 update
            for(Service__c svc: luptService){
                if(!svc.Changed__c){
                    Boolean isChanged = false;
                    //SAP정보와 달라지면 Chagned__c = true
                    if(svc.sService__c !=  svc.Service__c) isChanged = true;
                    if(svc.sDeliveryDepartment__c != svc.DeliveryDepartment__c ) isChanged = true;
                    if(svc.sSalesDepartment__c != svc.SalesDepartment__c) isChanged = true;
                    if(!svc.SendSAP__c && svc.sDeletionFlag__c ) isChanged = false;
                    //하위 Solution의 Changed__c = true이면 Changed__c = true로 변경
                    for(Solution__c sol: lupsertSolution){
                        if(sol.Service__c == svc.Id){
                            if(sol.Changed__c) isChanged = true;
                        }    
                    }
                    svc.Changed__c = isChanged;
                }

                //11.05 서비스 하위 솔루션 모두 삭제처리 되면 서비스도 삭제처리
                //(PS쪽에서 솔루션을 삭제처리만 되고 추가가 안되는 케이스로 서비스만 살아있는 경우 삭제처리 하기 위한 로직)
                List<Solution__c> solList = svc.Solution__r;
                if(svc.SendSAP__c && solList.size() == 0){
                    svc.Changed__c =  false;
                    svc.sDeletionFlag__c = true;
                    svc.DeletionFlag__c = true;
                }
            }
            update luptService;

            //update opportunity
            resultMsg = 'SAVE_SUCCESS';

        }catch(Exception e){
            resultMsg = e.getStackTraceString();
            System.debug(LoggingLevel.ERROR, e.getMessage());
            System.debug(LoggingLevel.ERROR, e.getStackTraceString());
        }

        //set resultmap
        resultMap.put(KEY_MSG , resultMsg);
        resultMap.put('DUPLICATE_SOl' , duplMsg);
        return resultMap;
    }

    /**
    * @description 확정된 서비스에 추가가능한 솔루션인지 임시 저장 전 체크
    * @author seonju.jin@dkbmc.com | 2021-11-01 
    * @param List<Solution__c> solutionList 
    **/
    public static String solutionCheck(List<Service__c> serviceList, List<Solution__c> solutionList){
        String errorMsg;
        //이미 확정된(프로젝트가 생성된) 서비스에서 다른 PSType으로 솔루션 추가가 불가능하도록 체크
        // 다른 PSType으로 추가하기 위해서 해당 PSType으로 생성된 서비스 하위에 추가하거나 새로운 서비스라인으로 생성해야함
        System.debug('### OpportunityServiceSolutionMainController, solutionCheck ###');
        Map<Id, Service__c> serviceMap = new Map<Id, Service__c>();     //확정 서비스 map
        for(Service__c obj : serviceList){
            if(obj.SendSAP__c) serviceMap.put(obj.Id, obj);
        }
        
        for(Solution__c sol : solutionList){
            if(sol.SendSAP__c || sol.Changed__c == false || sol.sDeletionFlag__c == true ) continue;

            if(serviceMap.get(sol.Service__c) != null){  
                Service__c svc = serviceMap.get(sol.Service__c);
                List<Solution__c> solSAPList = svc.Solution__r;    //확정된 솔루션 목록
                Set<String> pstypeSet = new Set<String>();
                for(Solution__c sapSol: solSAPList){
                    if(String.isNotBlank(sapSol.PSType__c)) pstypeSet.add(sapSol.PSType__c);
                }

                String psType = sol.sPSType__c;
                if(!pstypeSet.contains(psType)){
                    System.debug('변경할 PSType으로 생성된 솔루션이 없음. 솔루션 추가불가');
                    errorMsg = '서비스 No.' + svc.ItemNumber__c + '에 ' + psType + ' 솔루션을 추가할 수 없습니다.';
                }
            }
        }

        return errorMsg;
    }

    /**
    * @description 사업기회 사업유형 업데이트
    * @author seonju.jin@dkbmc.com
    * @param Id opptyId 
    * 2021-08-17 @성유라 프로요청 Project/WBS 생성 이후 변경 되도록 수정
    **/
    public static void updateOpptyBizType(Opportunity oppty, List<Solution__c> solList){
        try{
            /** 2020.12.16 opportunity BusinessType__c update
             *  TI 가 하나라도 있으면 --> TI    
                TI 가 하나도 없고 TD가 한 개 이상 있으면 --> TD
                TI, TD가 하나도 없으면 --> TS
            */
            // List<Solution__c> lsolutionAll = [SELECT Id, Name, BusinessType__c FROM Solution__c WHERE Opportunity__c = :oppty.Id AND SendSAP__c = true AND DeletionFlag__c = false/*  sDeletionFlag__c = false */];
            String bizType = 'TS';
            for(Solution__c obj: solList){
                if(obj.BusinessType__c == 'TI'){
                    bizType = 'TI';
                    break;
                }else if(obj.BusinessType__c == 'TD'){
                    bizType = 'TD';
                }
            }
            oppty.BusinessType__c = bizType;
            update oppty;
            createInterfaceLog3('updateOpptyBizType', 'BO_CODE : '+oppty.OpportunityCode__c + ', COMPANY_CODE : ' + oppty.CompanyCode__c + '\n' + '5.Biz type 1 Updated : Success , Value : ' + bizType , 'S'); //Added by Anish - v 4.1
        }catch(Exception e){
            createInterfaceLog3('updateOpptyBizType', 'BO_CODE : '+oppty.OpportunityCode__c + ', COMPANY_CODE : ' + oppty.CompanyCode__c + '\n' + '5.Biz type 1 Failed : ' +e.getStackTraceString()  + ' Message : ' + e.getMessage() , 'F'); //Added by Anish - v 4.1
            System.debug(LoggingLevel.ERROR, e.getStackTraceString());
        }
    }

    /**
    * @description SAP으로 전송
    * @author seonju.jin@dkbmc.com | 2020-12-03 
    * @param Map<String Object> svcSolMap 
    * @return Map<String, Object> 
    **/
    @AuraEnabled
    public static Map<String,Object> onConfirmToSAP(String opprtyId){ 
        Boolean initialRegi = false;
        Map<String,Object> resultMap = new Map<String,Object>();
        Map<String,Object> result = new Map<String,Object>();
        String resultMsg = 'S';

        try {
            //select Insert, Update, Delete Service
            List<Service__c> lnewSvc = new List<Service__c>();
            List<Service__c> luptSvc = new List<Service__c>();

            //select Insert, Update, Delete Solution
            List<Solution__c> lnewSol = new List<Solution__c>();
            List<Solution__c> luptSol = new List<Solution__c>();
            System.debug('onConfirmToSAP AJ Entry');
            /* Opprtunity 정보 조회 */
            Opportunity opprty = [SELECT Id, Name
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
                System.debug('IF Ani Entry');
                            
                /* 수정 or 삭제할 Service&Solution 조회
                    *[WBS 수정 조건] Service__c, Solution__c : SendSAP__c true, Chnaged__c true
                        -> Service__r.Service__c가 변경, Soluiton.sPsType__c가 변경 된 경우 삭제(OPTION: 'D')후 신규건(OPTION:'I')으로 
                    *[WBS 삭제] Service__c, Solution__c : SendSAP__c true, Changed__c true, sDeletionFlag__c = true
                        -> WBS삭제 진행
                */
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

                Integer svcSolCnt = lnewSol.size() + lnewSvc.size() + luptSvc.size() + luptSol.size();

                Object objectLog = null;
                if(svcSolCnt > 0){
                    List<Project__c> lpjt = [SELECT Id, Name, DeletionFlag__c, ProjectType__c FROM Project__c WHERE Opportunity__c = : opprtyId ];

                    /* 2021.05.18 IF-040/050 여부 로직 추가 (https://sdssfa--qa.lightning.force.com/lightning/r/VOC__c/a131s000000f5UuAAI/view) */
                    //1. 하위 PJT가 모두 삭제된 경우: IF-040호출
                    //2. 하위 PJT가 Business Plan만 있는 경우 : IF-040
                    //3. 하위 PJT가 Business Plan 포함 기타 다른 PJT가 있는 경우: IF-050

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
                    System.debug('### onConfirmToSAP, interface 호출:' + ((initialRegi) ? 'IF-040 callout' : 'IF-050 callout'));
                    //dev org 테스트
                    // String urlStr = url.getOrgDomainUrl().toExternalForm();
                    // if(urlStr.contains('--dev')){
                    //     Map<String,String> ifresultMap = new Map<String,String>{
                    //         KEY_RESULT => 'S',
                    //         KEY_MSG => 'SUCCESSS'
                    //     };

                    //     List<Service__c> lsvcSAP = new List<Service__c>();
                    //     List<Solution__c> lsolSAP = new List<Solution__c>();
                    //     result.put('CHANGE_PROJECT', ifresultMap);
                    //     lsvcSAP.addAll(luptSvc);
                    //     lsvcSAP.addAll(lnewSvc);
                    //     lsolSAP.addAll(luptSol);
                    //     lsolSAP.addAll(lnewSol); 
                    //     resultMsg = 'S';
                    //     upsertOpportunityActivity(opprty.Id, opprty.CompanyCode__c, OPPTYACT_STATUS_COMPLETED);
                    //     devSave(lsvcSAP,lsolSAP);
                    // }else{
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
                            if(resultMsg != 'E') upsertOpportunityActivity(opprty.Id, opprty.CompanyCode__c, OPPTYACT_STATUS_COMPLETED);
                        }
                    }else{          /* IF-050 Proejct Change */
                        //Interface Result
                        Map<String,Object> pjtChangeResult = new Map<String,Object>();
                        Map<String,Object> pjtDeleteResult = new Map<String,Object>();

                        List<Service__c> lsvcSAP = new List<Service__c>();
                        List<Solution__c> lsolSAP = new List<Solution__c>();
                        
                        lsvcSAP.addAll(luptSvc);
                        lsvcSAP.addAll(lnewSvc);
                        lsolSAP.addAll(luptSol);
                        lsolSAP.addAll(lnewSol);

                        List<Service__c> ldelSvc = new List<Service__c>();
                        List<Solution__c> ldelSol = new List<Solution__c>();
                        for(Service__c svc: luptSvc){
                            if(svc.SendSAP__c && (svc.sDeletionFlag__c || (svc.Service__c != svc.sService__c))){
                                ldelSvc.add(svc);
                            }
                        }

                        for(Solution__c sol: luptSol){
                            if(sol.SendSAP__c && ((sol.Service__r.Service__c != sol.Service__r.sService__c) ||sol.sDeletionFlag__c || (sol.sPSType__c != sol.PSType__c)  || (sol.sSolutionType__c != sol.SolutionType__c))){
                                ldelSol.add(sol);
                            }
                        }
    
                        String IF058_resultMsg = 'SUCCESS';
                        if(ldelSvc.size() > 0 || ldelSol.size() > 0){
                            IF_EccWbsDeleteController.OutputHeader outputHeader = render_IF_058(opprty, ldelSvc, ldelSol);
                            pjtDeleteResult = IF_EccWbsDeleteController.calloutWbsDelete(JSON.serialize(outputHeader));

                            Integer statusCode = Util_String.nvlInt( pjtDeleteResult.get( 'StatusCode'));
                            if( statusCode >= 300) {
                                IF058_resultMsg = '[' + statusCode+ ']' + Util_String.nvlStr( pjtDeleteResult.get( 'IF_MSG')); // 알림 메세지 값
                            }else{
                                HttpResponse res = (HttpResponse)pjtDeleteResult.get('HttpResponse');
                                Map<String,Object> returnMap = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
                                IF058_resultMsg = beforDelete_IF058((List<Object>)returnMap.get('ET_MESSAGE'));
                            }

                            Map<String, String> delResultMap = new Map<String,String>();
                            if(IF058_resultMsg != 'SUCCESS') {
                                //afterRollback(ldelSvc, ldelSol);
                                syncWBSInfo(opprty.Id, null);
                                delResultMap.put(KEY_MSG, System.Label.SVC_IF_DEL_FAIL + ' ' + IF058_resultMsg);
                                delResultMap.put(KEY_RESULT,'E');
                                result.put('CHANGE_PROJECT', delResultMap);
                                resultMsg = 'E';
                            }
                        }

                        System.debug('### OpportunityServiceSolutionMainController, onConfirmToSAP, lsvcSAP : ' +  lsvcSAP);
                        if(IF058_resultMsg == 'SUCCESS' && (lsvcSAP.size() > 0 || lsolSAP.size() > 0)){
                            IF_PsChangePjtController.InputClass input = render_IF_050(opprty, lsvcSAP, lsolSAP);
                            pjtChangeResult = IF_PsChangePjtController.changePjt(input);
                                
                            Integer statusCode = Util_String.nvlInt( pjtChangeResult.get( 'StatusCode'));
                            if( statusCode >= 300) {
                                //인터페티스 로그 생성
                                if(pjtChangeResult != null) createInterfaceLog(pjtChangeResult.get('INTERFACE_LOG'), opprty.Id);
                                resultMsg = '[' + statusCode+ ']' + Util_String.nvlStr( pjtChangeResult.get( 'IF_MSG')); // 알림 메세지 값
                            }else{
                                Map<String,String> changeResultMap = saveProject(opprty, lsvcSAP, lsolSAP, pjtChangeResult, 'IF-050');
                                result.put('CHANGE_PROJECT', changeResultMap);
                                resultMsg = changeResultMap.get(KEY_RESULT);

                                /* 2021.05.17 추가 activity 상태값 업데이트 */
                                if(resultMsg != 'E') upsertOpportunityActivity(opprty.Id,opprty.CompanyCode__c, OPPTYACT_STATUS_COMPLETED); 
                            }
                        }

                        //IF-058 인터페이스 로그 생성
                        if(pjtDeleteResult != null) createInterfaceLog(pjtDeleteResult.get('INTERFACE_LOG'), opprty.Id);
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

        return resultMap;
    }

    /**
    * @description IF-040 
    * @author seonju.jin@dkbmc.com | 2020-12-07 
    * @param List<Solution__C> lnewsol 
    * @return IF_PsCreatePjtNoController.InputClass 
    * @see IF_PsCreatePjtNoController
    **/
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
            String gubun = WBSHelper.getGubun(sol.sSolutionType__c, companyCode);

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
    
    /** 
    * @description 
    * @author seonju.jin@dkbmc.com | 2020-12-09 
    * @param Opportunity opprty 
    * @param List<Service__C> lsvcChange 
    * @param List<Solution__c> lsolChange 
    * @return IF_PsChangePjtController.InputClass 
    * @see IF_PsChangePjtController
    * history 2021-07-13 ChangeProject Test 중 변경 요청(김룡일프로) IF-050 요청파라미터 수정 (OPTION D->I일 때, IT_SERVICE구성을 IT_SOLUTION과 1:1 되도록 구성 변경)
    **/
    public static IF_PsChangePjtController.InputClass render_IF_050(Opportunity opprty, List<Service__C> lsvcChange, List<Solution__c> lsolChange){
        IF_PsChangePjtController.InputClass input = new IF_PsChangePjtController.InputClass();
        IF_PsChangePjtController.IS_HEADER header = new IF_PsChangePjtController.IS_HEADER();
        List<IF_PsChangePjtController.IT_SERVICE> litService = new List<IF_PsChangePjtController.IT_SERVICE>();
        List<IF_PsChangePjtController.IT_SOLUTION> litSolution = new List<IF_PsChangePjtController.IT_SOLUTION>();

        /**
         * Servie코드변경, Solution의 WBS Class가 변경이 되면 삭제 후 신규 데이터로 JSON 생성되도록
         */
        String boCode           = opprty.OpportunityCode__c;                        //사업기회코드
        String boNm             = opprty.Name;                                      //사업기회명
        String companyCode      = opprty.CompanyCode__c;                            //회사코드   opprty.CompanyCode__c
        String main_fkstl       = opprty.cPrimarySalesDepartment__r.CostCenter__c;  //매출부서코드
        String main_akstl       = opprty.SalesDepartment__r.CostCenter__c;          //수주부서코드
        String opportunityId    = opprty.Id;                                        //사내대체 프로젝트코드
        String owrner           = opprty.Owner.EmployeeNumber;                      //영업담당자사번
        String proposalPm       = opprty.ProposalPM__r.EvSapEmpNO__c;               //제안PM사번
        String originCustomer   = opprty.cOriginAcc__r.AccountNumber;               //원청사 고객사번호
        String bizlevel         = opprty.BusinessLevel__c;                          //사업등급
        Date closeDate          = opprty.closeDate;                                 //수주예상일
        Date revenueStartDate   = opprty.cRevenueStartDate__c ;                     //프로젝트 시작일
        Date revenueEndDate     = opprty.cRevenueEndDate__c;                        //프로젝트 종료일

        String closeDateStr = convertDateFormat(closeDate);
        String revenueStartDateStr = convertDateFormat(revenueStartDate);
        String revenueEndDateStr = convertDateFormat(revenueEndDate);

        //[IS_HEADER JSON 구성]
        header.ZZORDER_ID           = boCode;  
        header.DESCRIPTION          = boNm;
        header.BUKRS                = companyCode; //defaultvalue T100
        header.KOKRS                = 'T100';
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

        //[IT_SERVICe,IT_SOLUTION JSON] 구성 
        /** IT_SERVICE , IT_SOLUTION 구성 정보
         * (TI_SERVICE는 생성되어있는 솔루션 라인만큼 구성해야함)
         * 1. 신규 서비스라인 생성. IT_SERVICE OPTION 'I' / IT_SOLUTION OPTION 'I'
         * 2. 신규 솔루션 생성 IT_SERVICE OPTION 'C' or 'I' / IT_SOLUTION: OPTION 'I'.
         * 3. 서비스의 실행부서, 영업부서만 변경된 경우 IT_SERVICE만 구성 
         * 
         * 4. 솔루션이 변경된 경우 JSON 구성 ↓↓↓↓↓
         * 4-1 솔루션 변경 : IT_SERVICE OPTION 'C' / IT_SOLUTION OPTION 'C'로 구성
         * 4-2 사업속성(bizAttr) 변경 : IT_SERVICE OPTION 'C' / IT_SOLUTION OPTION 'D' , IT_SOLUTION OPTION 'I'로 구성 - 화면단에서 해당 구성으로 안되도록 막음
         * 
         * 2021.11.05 로직 추가****************************************************************
             - 현재 서비스라인에 PSType이 있으면 C/I
             - PSType이 Bo에 생성되지 않았다면 C/I
             - 현재 서비스라인에 없고 다른 서비스라인에 PSType이 이미 생성되어있었다면 I/I
         */

        WBSHelper wHelper = WBSHelper.getInstance(opprty.Id, opprty.CompanyCode__c);
        // Set<String> serviceHeaderSet = new Set<String>();       //IT_SERVICE 구성 시 중복된 서비스 정보를 막기위한 변수

        
        Map<Integer,Set<String>> itemNumberPSTypeMap = new Map<Integer,Set<String>>();  //ItemNumber별 PSType으로 구성된 프로젝트 리스트
        Set<String> createdPSTypeSet = new Set<String>();                               //BO에 프로젝트 생성된 PSType 종류
        for(Service__c svc: [SELECT Id, Name, ItemNumber__c, (SELECT Id, Name, SendSAP__c, DeletionFlag__c, Service__r.Service__r.Code__c, PSType__c, Changed__c, sDeletionFlag__c FROM Solution__r 
                            WHERE SendSAP__c = true AND DeletionFlag__c = false) FROM Service__c WHERE Opportunity__c =:opprty.Id AND SendSAP__c = true AND DeletionFlag__c = false]){
            Set<String> psTypeSet =  new Set<String>();
            for(Solution__c sol : svc.Solution__r){
                // if(!(sol.Changed__c && sol.sDeletionFlag__c)){   //삭제할 솔루션은 제외
                psTypeSet.add(sol.PSType__c);
                createdPSTypeSet.add(sol.PSType__c);
                // }
            }
            itemNumberPSTypeMap.put(svc.ItemNumber__c.intValue(), psTypeSet);
        }

        for(Solution__c sol: lsolChange){
            //IT_SERVICE JSON 구성
            IF_PsChangePjtController.IT_SERVICE itService = new IF_PsChangePjtController.IT_SERVICE();
            String NUMBER_INT = String.valueOf(sol.itemNumber__c);          //ItemNumber
            String ZZSERVICE_REP_X = (sol.itemNumber__c == 10) ? 'X' : '';
            String SVC_OPTION = KEY_CREATE;
            Service__c svc = sol.Service__r;

            Boolean beforeDelete = false;   // D->I 여부(솔루션 PSType 변경여부)
            Boolean svcChanged = false;     // 서비스 변경여부
            String OPTION = KEY_CHANGE;     // IT_SOLUTION의 OPTION
            String svcWBSCode = sol.SvcWBSCode__c;      //SERVICE_WBS 정보   

            if(sol.Changed__c && sol.SendSAP__c){
                //PSType__c 가 달라지면 delete -> insert
                if(!sol.sDeletionFlag__c){
                    if(sol.Service__r.Service__c != sol.Service__r.sService__c) beforeDelete = true;
                    if(sol.sPSType__c != sol.PSType__c) beforeDelete = true;
                    if(sol.sSolutionType__c != sol.SolutionType__c) beforeDelete = true;
                }
            }

            //IT_SERVICE.OPTION Setting
            if(!svc.SendSAP__c){ SVC_OPTION = KEY_CREATE;}                        //신규 서비스 OPTION
            else{ SVC_OPTION = (svc.sDeletionFlag__c) ? KEY_DELETE : KEY_CHANGE;} //등록된 서비스 OPTION

            //Service 변경 여부
            if(sol.Changed__c){
                svcChanged = true;
            }else{
                svcChanged = (sol.Service__r.sDeliveryDepartment__c != sol.Service__r.DeliveryDepartment__c
                                    || sol.Service__r.sSalesDepartment__r != sol.Service__r.SalesDepartment__r);
            }

            //IT_SOLUTION. OPTION Setting
            if(!sol.SendSAP__c){
                OPTION = KEY_CREATE;
            }else{
                if(beforeDelete) OPTION = KEY_CREATE;
                else OPTION = (sol.sDeletionFlag__c) ? KEY_DELETE : KEY_CHANGE;
            }

            
            if(SVC_OPTION == KEY_CHANGE && OPTION == KEY_CREATE){
                if(String.isBlank(svcWBSCode)){
                    svcWBSCode = wHelper.getServicCode(sol);
                    System.debug('### OpportunityServiceSolutionMainController, render_IF_050, sol' + sol);
                    System.debug('### OpportunityServiceSolutionMainController, render_IF_050, wHelper.getServicCode(sol):"' + svcWBSCode);
                } 
            }
            
            /* 2021.11.05 ****************************************************************
             - 현재 서비스라인에 PSType이 있으면 C/I
             - PSType이 Bo에 생성되지 않았다면 C/I
             - 현재 서비스라인에 없고 다른 서비스라인에 PSType이 이미 생성되어있었다면 I/I
             */
            if(SVC_OPTION == KEY_CHANGE && OPTION == KEY_CREATE){
                if(itemNumberPSTypeMap.get(sol.itemNumber__c.intValue()) != null) SVC_OPTION = KEY_CHANGE;

                if(!createdPSTypeSet.contains(sol.sPSType__c)){ //현재 BO에 PSType으로 생성된 프로젝트 없음
                    SVC_OPTION = KEY_CHANGE;
                } else{
                    if(itemNumberPSTypeMap.get(sol.itemNumber__c.intValue()).contains(sol.sPSType__c)){     //현재 서비스라인에 생성된 PSType 존재
                        SVC_OPTION = KEY_CHANGE;
                    }else{
                        Boolean hasPSType = false;
                        for(Integer key : itemNumberPSTypeMap.keySet()){
                            System.debug('### OpportunityServiceSolutionMainController, render_IF_050, key:' + key + ',' + 'values:' + itemNumberPSTypeMap.get(key));
                            if(sol.ItemNumber__c.intValue() != key){
                                if(itemNumberPSTypeMap.get(key) != null && itemNumberPSTypeMap.get(key).contains(sol.sPSType__c)){  //현재 서비스라인에 없고 다른 서비스라인에 PSType 존재
                                    hasPSType = true;
                                }
                            }
                        }
                        if(hasPSType) SVC_OPTION = KEY_CREATE;
                    }
                }
            }

            //추가할려고 하는 솔루션이 Professional Service인경우 -> SERVICE OPTION : I
            //2021.12.28) 현재 I / I 로 보내면 프로젝트 생성에 문제가 있어 C / I 로 구성하여 보내기 위해 주석처리함
            // if(OPTION == KEY_CREATE){
            //     if(sol.sSolutionType__c == '10') SVC_OPTION = KEY_CREATE;
            // }
            
            // if(opprty.Id == Id.valueOf('0061s000006vj8CAAQ') && sol.ItemNumber__c.intValue() == 50 && sol.sSolutionType__c == '10'){
            //     SVC_OPTION = KEY_CREATE;
            // }

            //IT_SERVICE 구성
            if(svcChanged){
                itService.SERVICE_WBS       = (SVC_OPTION == KEY_CREATE) ? '' : svcWBSCode; //솔루션 신규건에 대해서 값비워서 보냄
                itService.SERVICE           = (SVC_OPTION == KEY_DELETE) ? svc.Service__r.Code__c : svc.sService__r.Code__c;
                itService.SERVICE_NAME      = NUMBER_INT + ' : ' + svc.sService__r.Name;      //2021.05.17 서비스명 itemnumber 추가
                itService.SUB_FKSTL         = (SVC_OPTION == KEY_DELETE) ? svc.DeliveryDepartment__r.CostCenter__c : svc.sDeliveryDepartment__r.CostCenter__c; 
                itService.SUB_AKSTL         = (SVC_OPTION == KEY_DELETE) ? svc.SalesDepartment__r.CostCenter__c : svc.sSalesDepartment__r.CostCenter__c;
                itService.OPTION            = /* (beforeDelete) ? KEY_CREATE : */ SVC_OPTION;
                itService.NUMBER_INT        = NUMBER_INT;
                itService.ZZSERVICE_REP_X   = ZZSERVICE_REP_X;
                itService.ZZTECH_YN         = (svc.TechAttribute__c) ? 'Y' : 'N';
                litService.add(itService);
                // ITSERVICE 중복 처리
                // if(!serviceHeaderSet.contains(NUMBER_INT + '_' + itService.SERVICE + '_' + SVC_OPTION)){
                //     litService.add(itService);
                //     serviceHeaderSet.add(NUMBER_INT + '_' + itService.SERVICE + '_' + SVC_OPTION);
                // } 
            }
            
            if(!sol.Changed__c) continue;       //서비스 실행/영업부서만 변경된 경우 IT_SOLUTION 구성 x
            //IT_SOLUTION JSON 구성
            IF_PsChangePjtController.IT_SOLUTION itSolution = new IF_PsChangePjtController.IT_SOLUTION();
            if(beforeDelete){
                IF_PsChangePjtController.IT_SOLUTION itSolutionDel = new IF_PsChangePjtController.IT_SOLUTION();
                String gubun = WBSHelper.getGubun(sol.SolutionType__c, companyCode);

                itSolutionDel.SERVICE_CODE     = sol.SvcWBSCode__c;
                itSolutionDel.SOLUTION_CODE    = sol.WBSCode__c;
                itSolutionDel.SOLUTION         = sol.Solution__r.Code__c;
                itSolutionDel.SOLUTION_NAME    = sol.Solution__r.Name;
                itSolutionDel.GUBUN            = gubun;
                itSolutionDel.OPTION           = KEY_DELETE;
                itSolutionDel.NUMBER_INT       = NUMBER_INT;
                itSolutionDel.ZZORDER_TYPE_S   = sol.BizAttribute__r.Code__c;
                itSolutionDel.ZZBIZ_TYPE_S     = sol.BusinessType__c; 
                itSolutionDel.ZZWBS_CLASS_S    = sol.WBSClass__c;
                litSolution.add(itSolutionDel);
            }
            
            String gubun = WBSHelper.getGubun((OPTION == KEY_DELETE) ? sol.SolutionType__c : sol.sSolutionType__c, companyCode);
            itSolution.SERVICE_CODE     = (beforeDelete || (SVC_OPTION == KEY_CREATE && OPTION == KEY_CREATE)) ? '' : svcWBSCode;
            itSolution.SOLUTION_CODE    = (beforeDelete || OPTION == KEY_CREATE) ? ''       : sol.WBSCode__c;
            itSolution.SOLUTION         = (OPTION == KEY_DELETE) ? sol.Solution__r.Code__c  : sol.sSolution__r.Code__c;
            itSolution.SOLUTION_NAME    = (OPTION == KEY_DELETE) ? sol.Solution__r.Name     : sol.sSolution__r.Name;
            itSolution.GUBUN            = gubun;
            itSolution.OPTION           = OPTION;
            itSolution.NUMBER_INT       = NUMBER_INT;
            itSolution.ZZORDER_TYPE_S   = (OPTION == KEY_DELETE) ? sol.BizAttribute__r.Code__c  : sol.sBizAttribute__r.Code__c;
            itSolution.ZZBIZ_TYPE_S     = (OPTION == KEY_DELETE) ? sol.BusinessType__c          : sol.sBusinessType__c; 
            itSolution.ZZWBS_CLASS_S    = (OPTION == KEY_DELETE) ? sol.WBSClass__c              : sol.sWBSClass__c;
            litSolution.add(itSolution);
        }
        input.IS_HEADER = header;
        input.IT_SERVICE = litService;
        input.IT_SOLUTION = litSolution;
        return input;
    }
    
    /**
    * @description 
    * @author seonju.jin@dkbmc.com | 2020-12-09 
    * @param Opportunity opprty 
    * @param List<Service__C> lsvcDelete 
    * @param List<Solution__c> lsolDelete 
    * @return IF_EccWbsDeleteController.OutputHeader 
    * @see IF_EccWbsDeleteController
    **/
    public static IF_EccWbsDeleteController.OutputHeader render_IF_058(Opportunity opprty, List<Service__C> lsvcDelete, List<Solution__c> lsolDelete){
        IF_EccWbsDeleteController.OutputHeader outputHeader = new IF_EccWbsDeleteController.OutputHeader();
        List<IF_EccWbsDeleteController.OUTPUT_IT_SERVICE> litService = new List<IF_EccWbsDeleteController.OUTPUT_IT_SERVICE>();
        List<IF_EccWbsDeleteController.OUTPUT_IT_SOLUTION> litSolution = new List<IF_EccWbsDeleteController.OUTPUT_IT_SOLUTION>();

        Map<String,Solution__c> solHeaderChangeMap = new Map<String,Solution__c>();   //key: SvcWBSCode__c
        Map<String,Solution__c> solHeaderCreateMap = new Map<String,Solution__c>();   //key: SvcWBSCode__c
        //Service WBSCode를 기준으로 IT_SERVICE 구성
        //Service WBSCode가 없는 경우 신규

        //SvcWBSCode를 KEY로 map 구성 (IT_SERVICE 요청JSON을 구성하기 위해 수행)
        for(Solution__c sol: lsolDelete){
            if(sol.WBSCode__c != null){
                String KEY = sol.SvcWBSCode__c;
                if(!solHeaderChangeMap.containsKey(KEY))solHeaderChangeMap.put(KEY, sol);   
            }
        }

        /* IT_SERVICE JSON 구성 */
        //Change or Delete IT_SERVICE
        // for(String key: solHeaderChangeMap.keySet()){
        //     Solution__c sol = solHeaderChangeMap.get(key);
        //     IF_EccWbsDeleteController.OUTPUT_IT_SERVICE itService = new IF_EccWbsDeleteController.OUTPUT_IT_SERVICE();
        //     String itemNumberStr = String.valueOf(sol.itemNumber__c);
        //     String ZZSERVICE_REP_X = (sol.itemNumber__c == 10) ? 'X' : '';
        //     Service__c svc = sol.Service__r;
        //     itService.SERVICE_CODE      = key;
        //     itService.SERVICE           = svc.Service__r.Code__c;     
        //     itService.SERVICE_NAME      = itemNumberStr + ' : ' + svc.Service__r.Name;      //2021.05.17 서비스명 itemnumber 추가
        //     itService.SUB_FKSTL         = svc.DeliveryDepartment__r.CostCenter__c; 
        //     itService.SUB_AKSTL         = svc.SalesDepartment__r.CostCenter__c;
        //     itService.OPTION            = (svc.sDeletionFlag__c) ? KEY_DELETE : KEY_CHANGE;
        //     itService.NUMBER_INT        = sol.itemNumber__c.intValue();
        //     itService.ZZSERVICE_REP_X   = ZZSERVICE_REP_X;
        //     itService.ZZTECH_YN         = (svc.TechAttribute__c) ? 'Y' : 'N';
        //     litService.add(itService);
        // }

        /* IT_SOLUTION JSON 구성 */
        for(Solution__c sol: lsolDelete){
            IF_EccWbsDeleteController.OUTPUT_IT_SERVICE itService = new IF_EccWbsDeleteController.OUTPUT_IT_SERVICE();
            String itemNumberStr = String.valueOf(sol.itemNumber__c);
            String ZZSERVICE_REP_X = (sol.itemNumber__c == 10) ? 'X' : '';
            Service__c svc = sol.Service__r;
            itService.SERVICE_CODE      = sol.SvcWBSCode__c;
            itService.SERVICE           = svc.Service__r.Code__c;     
            itService.SERVICE_NAME      = itemNumberStr + ' : ' + svc.Service__r.Name;      //2021.05.17 서비스명 itemnumber 추가
            itService.SUB_FKSTL         = svc.DeliveryDepartment__r.CostCenter__c; 
            itService.SUB_AKSTL         = svc.SalesDepartment__r.CostCenter__c;
            itService.OPTION            = (svc.sDeletionFlag__c) ? KEY_DELETE : KEY_CHANGE;
            itService.NUMBER_INT        = sol.itemNumber__c.intValue();
            itService.ZZSERVICE_REP_X   = ZZSERVICE_REP_X;
            itService.ZZTECH_YN         = (svc.TechAttribute__c) ? 'Y' : 'N';
            litService.add(itService);

            IF_EccWbsDeleteController.OUTPUT_IT_SOLUTION itSolution = new IF_EccWbsDeleteController.OUTPUT_IT_SOLUTION();
            Boolean beforeDelete = false;
            if(sol.SendSAP__c){
                //PSType__c 가 달라지면 delete -> insert
                if(!sol.sDeletionFlag__c){
                    if(sol.Service__r.Service__c != sol.Service__r.sService__c) beforeDelete = true;
                    if(sol.sPSType__c != sol.PSType__c) beforeDelete = true;
                    if(sol.sSolutionType__c != sol.SolutionType__c) beforeDelete = true;

                    if(beforeDelete){
                        IF_EccWbsDeleteController.OUTPUT_IT_SOLUTION itSolutionDel = new IF_EccWbsDeleteController.OUTPUT_IT_SOLUTION();
                        String gubun = WBSHelper.getGubun(sol.SolutionType__c, opprty.CompanyCode__c);

                        itSolutionDel.SERVICE_CODE     = sol.SvcWBSCode__c;
                        itSolutionDel.SOLUTION_CODE    = sol.WBSCode__c;
                        itSolutionDel.SOLUTION         = sol.Solution__r.Code__c;
                        itSolutionDel.SOLUTION_NAME    = sol.Solution__r.Name;
                        itSolutionDel.GUBUN            = gubun;
                        itSolutionDel.OPTION           = KEY_DELETE;
                        itSolutionDel.NUMBER_INT       = sol.itemNumber__c.intValue();
                        itSolutionDel.ZZORDER_TYPE_S   = sol.BizAttribute__r.Code__c;
                        itSolutionDel.ZZBIZ_TYPE_S     = sol.BusinessType__c; 
                        itSolutionDel.ZZWBS_CLASS_S    = sol.WBSClass__c;
                        litSolution.add(itSolutionDel);
                    }
                }else{
                    String gubun = WBSHelper.getGubun(sol.SolutionType__c, opprty.CompanyCode__c);
                    String svcWBSCode = sol.SvcWBSCode__c;
                    itSolution.SERVICE_CODE     = svcWBSCode;
                    itSolution.SOLUTION_CODE    = sol.WBSCode__c;
                    itSolution.SOLUTION         = sol.Solution__r.Code__c;
                    itSolution.SOLUTION_NAME    = sol.Solution__r.Name;
                    itSolution.GUBUN            = gubun;
                    itSolution.OPTION           = KEY_DELETE;
                    itSolution.NUMBER_INT       = sol.itemNumber__c.intValue();
                    itSolution.ZZORDER_TYPE_S   = sol.BizAttribute__r.Code__c;
                    itSolution.ZZBIZ_TYPE_S     = sol.BusinessType__c;
                    itSolution.ZZWBS_CLASS_S    = sol.WBSClass__c;
                    litSolution.add(itSolution);
                }
            }
        }

        outputHeader.IT_SERVICE = litService;
        outputHeader.IT_SOLUTION = litSolution;
        return outputHeader;
    }

    /**
    * @description Interface Log Create
    * @author seonju.jin@dkbmc.com | 2020-12-11 
    * @param Object IFLog 
    **/
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
    
    //Added by Anish - v 4.1
    public static void createInterfaceLog3(String apexMethod,String logMessage,String statusCode ){

        try{
        System.debug( 'LOGIC_REVIEWOPP entry');
            IF_Log__c log = new IF_Log__c();
                log.ApexName__c = 'OpportunityServiceSolutionMainController';
                log.ApexMethod__c =  apexMethod;
                log.InterfaceId__c = 'LOGIC_REVIEWOPP';
                log.LogText__c = logMessage;
                log.StatusCode__c = statusCode;
                log.LogType__c = 'Interface';
                log.EndDatetime__c 	= System.now();
                log.StartDatetime__c = System.now();
                System.debug( 'LOGIC_REVIEWOPP creation'+ log);
                insert log;
        }catch(Exception e){
            System.debug( 'LOGIC_REVIEWOPP msg'+ e.getMessage());
        }
    }

    /**
    * @description IF-040/050 Response
    * @author seonju.jin@dkbmc.com | 2021-06-17 
    * @param Opportunity opprty
    * @param List<Service__c> lnewSvc
    * @param List<Solution__c> lnewSol 
    * @param Map<String Object> pjtResult 인터페이스 결과
    * @param String INTERFACE_ID InterfaceId= IF-040/IF-050
    * @return Map<String, String> 
    * 사업분류 체계 - (AS-IS) ET_MESSAGE 상관없이 후처리 진행 (TO-BE) ET_MESSAGE의 Type이 'S'인경우만 처리되도록 수정
    **/
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
            System.debug('### OpportunityServiceSolutionMainController, saveProject, paremeter, Opportunity :' + opprty);
            System.debug('### OpportunityServiceSolutionMainController, saveProject, paremeter, lnewSvc :' + lnewSvc);
            System.debug('### OpportunityServiceSolutionMainController, saveProject, paremeter, lnewSol :' + lnewSol);
            System.debug('### OpportunityServiceSolutionMainController, saveProject, paremeter, pjtResult :' + pjtResult);
            System.debug('### OpportunityServiceSolutionMainController, saveProject, paremeter, INTERFACE_ID :' + INTERFACE_ID);
            
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
                            //2022-09-26, hyunhak.roh@dkbmc.com, Project 생성 IF(IF-040) 관련 로직 개선
                            //TYPE 값은 'E'이지만, ID = CNIF_STATUS & MESSAGE에 "Error reading/locking" 포함 시 Error 로 처리하지 않음
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
                //2022-07-04, hyunhak.roh@dkbmc.com, IF-050(PJT 변경) 응답으로 ET_MESSAGE가 오지 않을 때의 처리 로직 변경
                isSuccess = true;
            }
            /* 2022.01.21 TA 도입으로 ET_MESSAGE 모두 성공일 때만 후처리 진행하도록 함. 주석처리
            else{  //ET_MESSAGE 없는경우 이후 로직 처리하도록 success true 로 설정 (개발 시 협의된 사항)
                hasEtMesage = false;
                isSuccess = true;
            } */

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
                }else if(INTERFACE_ID == 'IF-050'){
                    Set<String> setPSPID = new Set<String>();
                    for(Object obj : pjtWBSInfo){
                        Map<String, Object> objDataMap = (Map<String,Object>)obj;
                        String PSPID =  (String)objDataMap.get('PSPID_OUTPUT');     //프로젝트코드
                        setPSPID.add(PSPID);
                    }

                    //프로젝트 insert
                    for(String pspid: setPSPID){
                        Project__c pjt = new Project__c(
                                // DeletionFlag__c = false,
                                Description__c = '',      //05.03 BO Descrition 제외
                                Opportunity__c = opprty.Id,
                                ProjectCode__c = pspid
                              // Name = opprty.Name;
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
                createInterfaceLog3('saveProject', 'BO_CODE : '+opprty.OpportunityCode__c + ', COMPANY_CODE : ' + opprty.CompanyCode__c + '\n' + '3.New Project Created : Success' , 'S'); //Added by Anish - v 4.1
                
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
                
                // ----------------------------------------- 사기검 후처리
                // 사기검 후처리 - 1)IF-042 2)IF-093, 3)이메일 전송
                if(!Test.isRunningTest()) IF_LsDashboardController.calloutDashboardInfo(new Set<Id>{opprty.Id}); 
                system.debug('hi this project code' );
                //1) IF-042 신대시보드 전송. 2021.07.29 (조미옥 프로요청) 서비스솔루션 전송 후 신대시보드 전송(화면값 기준으로 전송함)
                if(lChangeService.size() > 0 || lChangeSolution.size() > 0){
                    System.enqueueJob(new Callout_IF093(opprty));   // 2) IF-093. 결재상태 변경하기 위해 수행
                    System.debug('Collab Mail Trigger');
                    // 3) 이메일 전송
                    // System.enqueueJob(new OpportunityBOReviewMailHelper(opprty, lChangeService, lChangeSolution, CHANGE_APPROVAL));  //FIXME 현재 소속부서장 이메일 이슈로 주석처리함
                    // if(INTERFACE_ID == 'IF-040'&& opprty.IsOriginal__c && opprty.Collaboration__c)  System.enqueueJob(new OpportunityBOReviewMailHelper(opprty, lChangeService, lChangeSolution, REVIEW_COMPLETED));   // Commented by Anish - V 4.5
                }

                update luptServiceWBSInfo;      //Service__c. WBSCode__c update
                update luptSolutionWBSInfo;     //Solution__c. WBSCode__c update
                
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
                createInterfaceLog3('saveProject', 'BO_CODE : '+opprty.OpportunityCode__c + ', COMPANY_CODE : ' + opprty.CompanyCode__c + '\n' + '4.New WBS Created : Success', 'S'); //Added by Anish - v 4.1
                if(solActiveList.size() > 0) updateOpptyBizType(opprty, solActiveList); //2021.08.17 @성유라프로 요청 - Project 수정/생성 이후 사업기회 사업유형 1 업데이트

                // result set
                resultType = 'S';
                if(INTERFACE_ID == 'IF-040') resultMsg = System.Label.SVCSOL_PJT_CREATE;        //Project change successfully.
                else if(INTERFACE_ID == 'IF-050') resultMsg = System.Label.SVCSOL_PJT_CHANGE;   //Project change successfully.
            }else{
                resultType = 'E';
                resultMsg = System.Label.SVC_IF_ERR_MSG_04; //ET_WBS_INFO is empty
            }
        }catch(Exception e){
        createInterfaceLog3('saveProject', 'BO_CODE : '+opprty.OpportunityCode__c + ', COMPANY_CODE : ' + opprty.CompanyCode__c + '\n' + '4.New WBS Creation Failed : ' +e.getStackTraceString()  + ' Message : ' + e.getMessage() , 'F'); //Added by Anish - v 4.1
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

    /**
     * callout IF-093 
     * [TODO] OutputHeader.IV_BUKRS에 사업기회 CompanyCode__c 추가해야할 수도 있음
     */
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

    /**
    * @description 삭제 전 삭제여부 체크(IF-058)
    * @author seonju.jin@dkbmc.com | 2020-12-09 
    * @param Opportunity Opportunity 
    * @param List<Object> ET_MESSAGE 
    * @return String 
    **/
    public static String beforDelete_IF058(List<Object> ET_MESSAGE){
        String resultMsg=  'SUCCESS';
        if(ET_MESSAGE == null){
            resultMsg = System.Label.SVC_IF_ERR_MSG_02; //ET_MESSAGE not received.
        }else{
            String errMsg= '';
            for(Object msgObj : ET_MESSAGE){
                Map<String,Object> objMap = (Map<String,Object>)msgObj;
                String type = (String)objMap.get('TYPE');
                String message = (String)objMap.get('MESSAGE');
                if(type != 'S'){         //인터페이스 결과 실패
                    errMsg += message + '\n';
                }
            }
            if(errMsg.length() != 0) resultMsg = errMsg;
        }
        return resultMsg;
    }

    /**
    * @description ET_WBS_INFO 또는 Mysales DB 기준으로 데이터 업데이트
    * @author seonju.jin@dkbmc.com | 2021-06-10 
    * @param Id opptyId 
    * @param Map<String Object> pjtResult 
    **/
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

    /**
    * @description ET_WBS_INFO 기준으로 Serivce, Solution Updte/Delete
    * @author seonju.jin@dkbmc.com | 2021-06-11 
    * @param List<Service__c> lSvc 
    * @param List<Object> pjtWBSInfoList IF040,050 결과 ET_WBS_INFO
    * @return Integer 
    **/
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

        System.debug('### OpportunityServiceSolutionMainController, syncByWBSInfo, luptSol,' + luptSol);
        System.debug('### OpportunityServiceSolutionMainController, syncByWBSInfo, luptSvc,' + luptSvc);
        System.debug('### OpportunityServiceSolutionMainController, syncByWBSInfo, Del_lsol,' + lsol);
        System.debug('### OpportunityServiceSolutionMainController, syncByWBSInfo, Del_lSvc,' + lSvc);

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

        //사업분류체계 도입되면서 mysales와 PS간의 마이그 대상이 다를 경우를 대비하여 동기화 처리시 삭제는 하지 않고 동기화 로그 추가
        //delete lsol;        //WBS_INFO에 매칭되지않은 솔루션은 삭제처리
        //delete delSvcList;  //WBS_INFO에 매칭되지않은 서비스는 삭제처리

        // 삭제처리 하지 않고 SvcSolSyncLog__c에 로그
        //SvcSolSyncLog__c 

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

    /**
    * @description ET_WBS_INFO 없을 경우 SFDC기준으로 데이터 rollback
    * @author seonju.jin@dkbmc.com | 2021-06-11 
    * @param List<Service__c> lSvc 
    **/
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

    public static final String OPPTYACT_STATUS_COMPLETED = 'Completed';
    public static final String OPPTYACT_STATUS_INPROGRESS = 'In Progress';
    /**
    * @description 사기검 (임시저장, IF-040 완료) 후 액티비티 상태값 업데이트
    * @author seonju.jin@dkbmc.com | 2021-05-17 
    * @param String opptyId     Activity Record Id
    * @param String actStatus   In Progress: 저장 후, Completed: IF-040/IF-050 후 값
    **/
    public static void upsertOpportunityActivity(String opptyId, String companyCode, String actStatus){ 
        System.debug('### OpportunityServiceSolutionMainController, upsertOpportunityActivity ###');
        //사기검 액티비티 조회
        List<Opportunity_Activity__c> opptyActList = [SELECT Id, Name ,Status__c, StartDate__c , DueDate__c, EndDate__c, ExtId__c, WhatId__c,WhatId__r.OpportunityCode__c, TransactionName__c,WhatId__r.CompanyCode__c,WhatId__r.GroupInternal__c  //Modified by Anish - v 3.9 //Modified by Anish - v 4.1 'WhatId__r.OpportunityCode__c'
            FROM Opportunity_Activity__c 
            WHERE WhatId__c =: opptyId AND TransactionName__c = :OpportunityActivityHelper.ACT_CODE_REVIEW_BO // ZP21
            ORDER BY CreatedDate DESC LIMIT 1];
        
        system.debug('### OpportunityServiceSolutionMainController :: onConfirmToSAP :: opptyActList = ' + opptyActList);
        system.debug('### OpportunityServiceSolutionMainController :: onConfirmToSAP :: actStatus = ' + actStatus);

        if(opptyActList.size() > 0){
            System.debug('### OpportunityServiceSolutionMainController, upsertOpportunityActivity 액티비티 상태 업데이트');
            Opportunity_Activity__c opptyAct = opptyActList[0];

            //if(opptyAct.Status__c == actStatus) return;

            if(actStatus == OPPTYACT_STATUS_INPROGRESS){        //1. 저장 후
                System.debug('### OpportunityServiceSolutionMainController, upsertOpportunityActivity, 임시저장 액티비티 업데이트');
                //Activity Completed 아닐 경우에만 Inprogress update
                if(opptyAct.Status__c != OPPTYACT_STATUS_COMPLETED){
                    opptyAct.Status__c =  OPPTYACT_STATUS_INPROGRESS;   //In Progress
                    //Start-Added by Anish - v 3.9 
                    if(opptyAct.StartDate__c == null && opptyAct.WhatId__r.CompanyCode__c == 'T100' && opptyAct.WhatId__r.GroupInternal__c == False){
                        IF_171CallOutAPIController.doCalloutSendingReviewOpportunityInfo(opptyId); 
                    }
                    //End-Added by Anish - v 3.9 
                }else{
                    return;
                }
            }else if(actStatus == OPPTYACT_STATUS_COMPLETED){   //2. IF-040/IF-050 후
                //신규추가시작
                //1. 자회사 X
                //2. 구축형 
                //3. BO점검 확정이력 X
                //4. 수주품의 이력 X
                //1~4 모두 만족하는 경우 In Progress, 그 외의 경우 Complete
                //V4.4 MYSALES-261
                List<Opportunity> opportunity = [SELECT Id, CompanyCode__c, BusinessType__c, Opportunity_Review_VRB_Type_Confirm__c, CollaborationBOId__c,CollaborationBOId__r.BusinessType__c,Collaboration__c
                    FROM Opportunity
                    WHERE id =: opptyId 
                    LIMIT 1];
           
                if(!Utils.isSubsidiary(opportunity[0].CompanyCode__c) && 'TI'.equals(opportunity[0].BusinessType__c) && opportunity[0].Opportunity_Review_VRB_Type_Confirm__c==null ){
                    String ACT_CODE_CONTRACT_APPROVAL = OpportunityActivityHelper.ACT_CODE_CONTRACT_APPROVAL;
                    List<KnoxApproval__c> knoxApproval = [
                        SELECT  Id
                        FROM    KnoxApproval__c
                        WHERE   Opportunity__c = :opptyId
                            AND OpportunityActivity__r.TransactionName__c = :ACT_CODE_CONTRACT_APPROVAL
                            AND ( Status__c = :KnoxApprovalHelper.KNOX_APPROVAL_STATUS_COMPLETED
                                OR Status__c = :KnoxApprovalHelper.KNOX_APPROVAL_STATUS_ARBITRARY_CONFIRMED
                                OR Status__c = :KnoxApprovalHelper.KNOX_APPROVAL_STATUS_AFTER_CONFIRMED
                                )
                    ];                
                    if(knoxApproval.size()>0){ 
                        opptyAct.Status__c = OPPTYACT_STATUS_COMPLETED;   
                    } else{
                        opptyAct.Status__c =  OPPTYACT_STATUS_INPROGRESS;  
                        String ACT_CODE_REQUEST_RESOURCES = OpportunityActivityHelper.ACT_CODE_REQUEST_RESOURCES;
                        List<KnoxApproval__c> requestApproval = [
                            SELECT  Id
                            FROM    KnoxApproval__c
                            WHERE   Opportunity__c = :opptyId
                                AND OpportunityActivity__r.TransactionName__c = :ACT_CODE_REQUEST_RESOURCES
                                AND ( Status__c = :KnoxApprovalHelper.KNOX_APPROVAL_STATUS_COMPLETED
                                    OR Status__c = :KnoxApprovalHelper.KNOX_APPROVAL_STATUS_ARBITRARY_CONFIRMED
                                    OR Status__c = :KnoxApprovalHelper.KNOX_APPROVAL_STATUS_AFTER_CONFIRMED
                                    )
                        ]; 
                        if(requestApproval.isEmpty()){
                            opptyAct.EndDate__c = null;
                        }                        
                    }                
                } else if(Utils.isSubsidiary(opportunity[0].CompanyCode__c) || opportunity[0].Collaboration__c == false || (opportunity[0].Collaboration__c == true && opportunity[0].CollaborationBOId__r.BusinessType__c != 'TI')){//V4.4 MYSALES-261
                    opptyAct.Status__c = OPPTYACT_STATUS_COMPLETED;   
                }
                //신규추가종료                                    
            }
            
            //액티비티 상태 완료일 때 Activity Date 비어있을 경우 today 입력
            if(opptyAct.Status__c == OPPTYACT_STATUS_COMPLETED){
                if( String.isBlank(String.ValueOf(opptyAct.StartDate__c)) ) {
                    opptyAct.StartDate__c = Date.today();
                } else if (opptyAct.StartDate__c > Date.today()) {
                    opptyAct.StartDate__c = Date.today();
                }

                //종료일자 빈경우만 현재날짜로 세팅    
                if( String.isBlank(String.ValueOf(opptyAct.EndDate__c)) ) { 
                    opptyAct.EndDate__c = Date.today(); 
                }
            }

            opptyAct.ExtId__c = OpportunityActivityHelper.generateOpportunityActivityExtKey(opptyAct);

            System.debug('### OpportunityServiceSolutionMainController, upsertOpportunityActivity, opptyAct:' + opptyAct.Status__c);
            try{
                upsert opptyAct;
                if(opptyAct.Status__c == OPPTYACT_STATUS_INPROGRESS){
                createInterfaceLog3('upsertOpportunityActivity', 'BO_CODE : '+ opptyActList[0].WhatId__r.OpportunityCode__c + ', COMPANY_CODE : ' + opptyActList[0].WhatId__r.CompanyCode__c + '\n' + '1.Opportunity Activity Status Updated : Success, Value : ' + opptyAct.Status__c, 'S'); //Added by Anish - v 4.1
                }
                if(opptyAct.Status__c == OPPTYACT_STATUS_COMPLETED){
                createInterfaceLog3('upsertOpportunityActivity', 'BO_CODE : '+ opptyActList[0].WhatId__r.OpportunityCode__c + ', COMPANY_CODE : ' + opptyActList[0].WhatId__r.CompanyCode__c + '\n' + '7.Opportunity Activity Status Updated : Success, Value : ' + opptyAct.Status__c, 'S'); //Added by Anish - v 4.1
                }
            }catch(Exception e){
                if(opptyAct.Status__c == OPPTYACT_STATUS_INPROGRESS){
                createInterfaceLog3('upsertOpportunityActivity', 'BO_CODE : '+ opptyActList[0].WhatId__r.OpportunityCode__c + ', COMPANY_CODE : ' + opptyActList[0].WhatId__r.CompanyCode__c + '\n' + '1.Opportunity Activity Status Failed : '+ e.getStackTraceString() + ' Message : ' + e.getMessage() , 'F'); //Added by Anish - v 4.1
                }
                if(opptyAct.Status__c == OPPTYACT_STATUS_COMPLETED){
                createInterfaceLog3('upsertOpportunityActivity', 'BO_CODE : '+ opptyActList[0].WhatId__r.OpportunityCode__c + ', COMPANY_CODE : ' + opptyActList[0].WhatId__r.CompanyCode__c + '\n' + '7.Opportunity Activity Status Failed : '+ e.getStackTraceString() + ' Message : ' + e.getMessage() , 'F'); //Added by Anish - v 4.1
                }
                System.debug('Error : ' + e.getMessage());
                System.debug('StackTrace : ' + e.getStackTraceString());
                System.debug('Line : ' + e.getLineNumber());
            }
        }
    }

    // public static void devSave(List<Service__c> svcList, List<Solution__c> solList){
    //     for(Service__c svc: svcList){
    //         svc.SendSAP__c = true;                                                                   //SAP 전송 여부
    //         svc.Changed__c = false;                                                                  //변경 여부
    //         svc.DeletionFlag__c = svc.sDeletionFlag__c;                                       //삭제여부
    //         svc.Service__c = svc.sService__c;                                                 //서비스
    //         svc.ServiceBackup__c = svc.sService__r.Code__c;                                   //서비스 코드 백업
    //         svc.ServiceNmBackup__c = svc.sService__r.Name;                                    //서비스 명 백업
    //         svc.DeliveryDepartment__c = svc.sDeliveryDepartment__c;                           //매출부서
    //         svc.DeliveryDepartmentBackup__c = svc.sDeliveryDepartment__r.CostCenter__c;       //매출부서 코드 백업
    //         svc.DeliveryDepartmentNmBackup__c = svc.sDeliveryDepartment__r.CostCenterName__c; //매출부서 명   백업
    //         svc.SalesDepartment__c = svc.sSalesDepartment__c;                                 //수주부서
    //         svc.SalesDepartmentBackup__c = svc.sSalesDepartment__r.CostCenter__c;             //수주부서 코드 백업
    //         svc.SalesDepartmentNmBackup__c = svc.sSalesDepartment__r.CostCenterName__c;       //수주부서 명 백업
    //         svc.SAP_SendTime__c = Datetime.now();         
    //     }

    //     for(Solution__c sol: solList){
    //         sol.SendSAP__c = true;                                                   //SAP전송여부
    //         sol.Changed__c = false;                                                  //변경여부
    //         sol.DeletionFlag__c = sol.sDeletionFlag__c;                       //삭제여부
    //         sol.Solution__c = sol.sSolution__c;                               //솔루션
    //         sol.SolutionBackup__c = sol.sSolution__r.Code__c;                 //솔루션 코드 백업
    //         sol.SolutionNmBackup__c = sol.sSolution__r.Name;                  //솔루션 명 백업
    //         sol.SolutionTypeBackup__c = sol.sSolution__r.SolutionType__c;     //솔루션 타입 백업
    //         sol.BizAttribute__c = sol.sBizAttribute__c;                       //사업속성
    //         sol.BizAttributeBackup__c = sol.sBizAttribute__r.Code__c;         //사업속성 코드 백업
    //         sol.BizAttributeNmBackup__c = sol.sBizAttribute__r.Name;          //사업속성 명 백업
    //         sol.BusinessType__c = sol.sBusinessType__c;                       //businessType
    //         sol.WBSClass__c = sol.sWBSClass__c;                               //수익인식기준
    //         sol.SAP_SendTime__c = Datetime.now();                                    //전송 시간
    //         sol.PSType__c = sol.sPSType__c;                                   //PSType
    //     }

    //     update svcList;
    //     update solList;
    // }

    /**
    * @description 인터페이스 전송 전 필수값 체크
    * @author seonju.jin@dkbmc.com | 2021-02-19 
    * @param Opportunity opprty 
    * @return Map<String, String> 
    **/
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

        //사업기회 본사이고, 사업유형 1이 "구축형"(TI) 일 때만 체크
        //2020.05.28 수주품의 완료시 체크로직 제외
        //2021.10.07 재사용여부  BO점검 Tab에서 저장할때 체크하는 것으로 변경
        // if(!ApprovalCompleted){
        //     if(opprty.CompanyCode__c == 'T100' && (opprty.BusinessType__c != null && opprty.BusinessType__c == 'TI')){
        //         if(String.isBlank(opprty.ReuseReason__c)) resultMsg += ((resultMsg.length() >  0) ? ', ' : '') + Util_String.nvlStr(fieldMap.get('ReuseReason__c'.toLowerCase()));
        //     }
        // }

        //2021-03-17 제안사원 PM 체크로직 수정(User, Employee 모두 체크)
        //User에 대응되는 Employee가 없을 경우 에러메시지 추가
        //2022-01-17 ProposalPM_User__c 체크로직 제외
        String unmmapedMsg = '';
        if(String.isBlank(opprty.ProposalPM__c)){
            unmmapedMsg = System.Label.SVC_ERR_MSG_07;
            resultMsg += ((resultMsg.length() >  0) ? ', ' : '') + Util_String.nvlStr(fieldMap.get('ProposalPM__c'.toLowerCase()));
        }else{
            if(String.isBlank(opprty.ProposalPM__r.EvSapEmpNO__c)){
                resultMsg += ((resultMsg.length() >  0) ? ', ' : '') + Util_String.nvlStr(fieldMap.get('ProposalPM__c'.toLowerCase()));
                unmmapedMsg = System.Label.SVC_ERR_MSG_08;
            }
            //2022-09-26, hyunhak.roh@dkbmc.com, Project 생성 IF(IF-040) 관련 로직 개선
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

    /**
     * 결재완료 전까지는 현재처럼 if전송일자로 보내고 그이후는 사기검완료일자로 SALES_PLFAZ 세팅
     */
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

    /* 화면에서 사용할 custom class */
    public class ServiceSolution{
        @AuraEnabled
        public Service service {get; set;}                  //서비스
        @AuraEnabled
        public List<SolutionObj> solutionList {get; set;}   //솔루션 정보
    }

    public class Service{
        @AuraEnabled
        public String recordId {get; set;}
        @AuraEnabled
        public Integer itemNumber {get; set;}
        @AuraEnabled
        public String serviceId {get; set;}
        @AuraEnabled
        public String serviceNm {get; set;}
        @AuraEnabled
        public String serviceCode {get; set;}
        @AuraEnabled
        public SelectRecord salesRecord {get; set;}
        @AuraEnabled
        public SelectRecord deptRecord {get; set;}
        @AuraEnabled
        public Boolean checked {get; set;}
        @AuraEnabled
        public Boolean isDeleted {get;set;}      // sDeletionFlag__c
        @AuraEnabled
        public Boolean isChanged {get;set;}      //itme changed at component
        @AuraEnabled
        public Boolean isSendSAP {get;set;}
        @AuraEnabled
        public Boolean techyn{get;set;}

        /* saved data */
        @AuraEnabled
        public SelectRecord originService {get; set;}
        // @AuraEnabled
        // public SelectRecord originSales {get; set;}
        @AuraEnabled
        public SelectRecord originDept {get; set;}
    }

    public class SolutionObj{
        @AuraEnabled
        public Solution solution {get; set;}
    }

    public class Solution{
        @AuraEnabled
        public String serviceRecordId {get; set;}       //master detail service__c Id
        @AuraEnabled
        public String recordId {get; set;}              //solution record Id
        @AuraEnabled
        public String serviceId {get; set;}
        @AuraEnabled
        public Integer serviceIdx {get; set;}
        @AuraEnabled
        public String solutionId {get; set;}
        @AuraEnabled
        public String solutionNm {get; set;}
        @AuraEnabled
        public String attributeId {get; set;}
        @AuraEnabled
        public String attributeNm {get; set;}
        @AuraEnabled
        public String salesType {get; set;}
        @AuraEnabled
        public Boolean salesTypeEnable {get; set;}
        @AuraEnabled
        public String solutionType {get; set;}
        @AuraEnabled
        public String solutionTypeNm {get; set;}
        @AuraEnabled
        public String plcStatus {get; set;}
        @AuraEnabled
        public String wbsClass {get; set;}
        @AuraEnabled
        public String bizType {get; set;}
        @AuraEnabled
        public Integer itemNumber {get; set;}
        @AuraEnabled
        public Boolean isChanged {get;set;}      //itme changed at component
        @AuraEnabled
        public Boolean isDeleted {get;set;}      //sDeletionFlag__c
        @AuraEnabled
        public Boolean isSendSAP {get;set;}
        @AuraEnabled
        public String psType {get;set;}

        //마이그데이터 대응(상위 서비스가 틀릴경우 강제로 화면에서 보여지도록) 을 위한 필드
        @AuraEnabled
        public String originSvcId {get;set;}
        @AuraEnabled
        public String originSolId {get;set;}
        @AuraEnabled
        public String originSolNm {get;set;}
        @AuraEnabled
        public String originPlcStatus {get;set;}
        @AuraEnabled
        public String originSolType {get;set;}
        @AuraEnabled
        public String originSolTypeNm {get;set;}
    }

    public class SelectRecord{
        @AuraEnabled
        public String Id {get; set;}
        @AuraEnabled
        public String Name {get; set;}
    }
    /* 화면에서 사용할 custom class */
}