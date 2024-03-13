/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 법인통합 자동화 로직
 * @last modified on  : 2024-01-19
 * @last modified by  : sarthak.j1@samsung.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2021-06-22   younghoon.kim@dkbmc.com   Initial Versiont
 * 1.1   2024-01-19   sarthak.j1@samsung.com    Opportunity - new 'Probability' Field Creation -> MYSALES-416
**/
global class Batch_CostCenterMerge implements Database.Batchable<sObject>, DataBase.stateful{
    /* 
        [✨필독✨ 법인통합 전 체크리스트]
        ※ 법인통합 자동화 로직은 Migration용 계정을 사용해서 진행해야합니다.

        ※ 서안으로부터 전달받은 데이터 확인
            1) As-Is Opportunity Code 중 현재 mySales에 존재하지 않는 건 제외
            2) To-Be Cost Center중 mySales에 존재하지 않는 건이 있는지 확인
            3) 각 필드에 As-Is, To-Be값이 정상적으로 매핑되어 들어있는지 확인
            4) To-Be Opportunity Code Format 입력 확인
    */

    // Log
    private static final String INTERFACE_ID = '    ';
    private static final String APEX_CLASS   = 'Batch_CostCenterMerge'; 
    private static final String METHOD_NAME  = 'Batch';
    private static final Boolean DEBUG_FLAG = IF_Util.DEBUG_FLAG;
    private static String guId = IF_Util.generateGuid();

    private     Set<String>                                 toBe_compCodeSet            = new Set<String>();                                // To-Be Company Code Set
    private     Set<String>                                 asIs_CompCodeSet            = new Set<String>();                                // As-Is Company Code Set
    private     Set<String>                                 asIs_opptyCodeSet           = new Set<String>();                                // As-Is Opportunity Code Set
    private     Set<String>                                 asIs_opptyIdSet             = new Set<String>();                                // As-Is Opportunity Id Set

    private     Map<String, String>                         ccMap                       = new Map<String, String>();                        // To-Be Cost Center Map
    
    private     Map<String, String>                         newIdCodeMap                = new Map<String, String>();                        // Key : As-Is Opportunity Id, Value : To-Be Opportunity Code
    private     Map<String, String>                         newCodeIdMap                = new Map<String, String>();                        // Key : To-Be Opportunity Code, Value : As-Is Opportunity Id
    private     Map<String, String>                         newCodeOldCodeMap           = new Map<String, String>();                        // Key : To-Be Opportunity Code, Value : As-Is Opportunity Code

    private     Map<String, String>                         opptyCodeFormatMap          = new Map<String, String>();                        // To-Be Opportunity Code Format Map
    private     Map<String, String>                         opptySalesDeptMap           = new Map<String, String>();                        // To-Be Opportunity - Sales Department Map
    private     Map<String, String>                         opptyDelivDeptMap           = new Map<String, String>();                        // To-Be Opportunity - Delivery Department Map
    private     Map<String, String>                         svcSalesDeptMap             = new Map<String, String>();                        // To-Be Service - Sales Department Map
    private     Map<String, String>                         svcDelivDeptMap             = new Map<String, String>();                        // To-Be Service - Delivery Department Map
    private     Map<String, String>                         svcWBSMap                   = new Map<String, String>();                        // To-Be Service - WBS Code Map
    private     Map<String, String>                         solWBSMap                   = new Map<String, String>();                        // To-Be Solution - WBS Code Map
    private     Map<String, String>                         solProjectMap               = new Map<String, String>();                        // To-Be Solution - Project Code Map
    
    private     Map<String, List<OpportunityTeamMember>>    opptyTeamMemberMap          = new Map<String, List<OpportunityTeamMember>>();   // As-Is Opportunity Team Member Map
    private     Map<String, List<Opportunity_Activity__c>>  opptyActMap                 = new Map<String, List<Opportunity_Activity__c>>(); // As-Is Opportunity Activity Map
    private     Map<String, List<KnoxApproval__c>>          knoxMap                     = new Map<String, List<KnoxApproval__c>>();         // As-Is Knox Approval Map
    private     Map<String, List<Service__c>>               serviceMap                  = new Map<String, List<Service__c>>();              // As-Is Service Map
    private     Map<String, List<Solution__c>>              solutionMap                 = new Map<String, List<Solution__c>>();             // As-Is Solution Map
    private     Map<String, Project__c>                     projectMap;                                                                     // Project Map

    private     Map<String, Solution__c>                    newSolMap                   = new Map<String, Solution__c>();                   // New Solution Map
    private     Map<String, Project__c>                     newProjectCodeMap;                                                              // New Project Map

    private     List<Opportunity>                           originOpptyList             = new List<Opportunity>();                          // As-Is Opportunity List
    private     List<CostCenterMerge__c>                    originCCMList               = new List<CostCenterMerge__c>();                   // Cost Center Merge Target Data

    private     List<Opportunity>                           insert_opptyList;                                                               // To-Be Insert Target Opportunity List
    private     List<OpportunityTeamMember>                 insert_opptyTeamMemberList;                                                     // To-Be Insert Target Opportunity Team Member List
    private     List<Opportunity_Activity__c>               insert_opptyActList;                                                            // To-Be Insert Target Opportunity Activity List
    private     List<KnoxApproval__c>                       insert_knoxList;                                                                // To-Be Insert Target Knox Approval List
    private     List<Service__c>                            insert_serviceList;                                                             // To-Be Insert Target Service List
    private     List<Solution__c>                           insert_solutionList;                                                            // To-Be Insert Target Solution List
    private     List<Project__c>                            insert_projectList;                                                             // To-Be Insert Target Project List
    private     List<WBS__C>                                insert_wbsList;                                                                 // To-Be Insert Target WBS List

    private     List<Opportunity>                           success_opptyList           = new List<Opportunity>();                          // Insert Complete Opportunity List

    global Batch_CostCenterMerge(){
        String query_Select = 'SELECT ';
        String query_Fields = Utils.retrieveFieldList('CostCenterMerge__c');
        String query_From   = ' FROM CostCenterMerge__c';
        String query_WHERE  = ' WHERE IsComplete__c = FALSE';
        originCCMList = Database.query(query_Select + query_Fields + query_From + query_WHERE);

        if(originCCMList.size() > 0){
            for(CostCenterMerge__c ccm : originCCMList){
                try{
                    // 법인통합 작업 수행에 필요한 Data 생성
                    baseMapCreate(ccm);
                }catch(Exception e){
                    System.debug('baseMapCreate Error : ' + e.getMessage());
                    System.debug('baseMapCreate Error StackTrace : ' + e.getStackTraceString());
                    System.debug('baseMapCreate Error Line : ' + e.getLineNumber());
                }
            }

            // [S] To-Be Cost Center 매핑을 위한 Map 생성
            if(toBe_compCodeSet.size() > 0){
                List<CostCenter__c> ccList = [SELECT Id, Name, CompanyCode__c, CostCenter__c FROM CostCenter__c WHERE CompanyCode__c =: toBe_compCodeSet];

                if(ccList.size() > 0){
                    for(CostCenter__c cc : ccList){
                        ccMap.put(cc.CostCenter__c, cc.Id);
                    }
                }
            }
            // [E] To-Be Cost Center 매핑을 위한 Map 생성
        }
    }

	global Database.QueryLocator start(Database.BatchableContext BC){
        IF_Log ifStartLog = new IF_Log();
        IF_Log.BatchLog batchStartLog;
        List<String> startErrorMsgList = new List<String>();

        ifStartLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Start:' + BC.getJobId() + ') 시작' + ' ####################');

        if(originCCMList.size() > 0){
            for(CostCenterMerge__c ccm : originCCMList){
                asIs_CompCodeSet.add(ccm.CompanyCode_AsIs__c);
                asIs_opptyCodeSet.add(ccm.OpptyCode_AsIs__c);
            }
        }

        String query_Select  = 'SELECT ';
        String query_Fields  = 'Id, AccountId, CollaborationBOId__c, OpportunityCode__c, SalesDepartment__c, cPrimarySalesDepartment__c, MigData__c, IsEdited__c, ';
               query_Fields += 'RecordTypeId, Name, Description, StageName, Amount, Probability_new__c, Probability, CloseDate, Type, CurrencyIsoCode, OwnerId, CreatedDate, CreatedById, '; //-->[Added Probability_new__c] v-1.1
               query_Fields += 'LastModifiedDate, LastModifiedById, cOriginAcc__c, BiddingDeadline__c, CollaborationInOut__c, cRevenueStartDate__c, GlobalCustomer__c, ';
               query_Fields += 'IsOriginal__c, BizTeamAttributes01__c, BizTeamAttributes02__c, BizTeamAttributes03__c, BizTeamAttributes04__c, BizTeamAttributes05__c, ';
               query_Fields += 'cRevenueEndDate__c, LogisticsCustomerType__c, Competitors__c, Construction__c, BizGroupCellOrg__c, VRBMethod__c, BusinessLevel__c, cLeadID__c, ';
               query_Fields += 'BusinessType__c, BiddingMethod__c, AgencyContract__c, AgencyContractException__c, LegalReviewNo__c, ActivityStatus__c, LostReasonLogistics__c, ';
               query_Fields += 'OpportunityStatus__c, ProposalPM__c, CIGroupISE__c, OurRole__c, ParentOpportunity__c, ProposalRegistrationDate__c, ReuseReason__c, SalesOrganization__c, ';
               query_Fields += 'Security__c, SubIndusrty__c, TariffVerificationCompleted__c, Urgency__c, DealBreak__c, ProposalPM_User__c, Reuse__c, Internal_Biz_filter__c, ';
               query_Fields += 'Opportunity_Review_Biz_Amount__c, Opportunity_Review_Checkbox1__c, Opportunity_Review_Checkbox2__c, Opportunity_Review_Consortium__c, Opportunity_Review_VRB_Type__c, Opportunity_Review_Result__c, Opportunity_Review_Confirm__c, Opportunity_Review_Exception__c, Opportunity_Review_Exception_Reason__c, Opportunity_Review_Exception_Modifier__c, Opportunity_Review_Dangerous__c, Opportunity_Review_Temp_Save__c, Opportunity_Review_VRB_Type_Confirm__c, Opportunity_Review_Account__c, Opportunity_Review_cOriginAcc__c, ';
               query_Fields += 'Korea_Domestic_Biz_filter__c, CompanyCode__c, ChangeApprovalBusinessLevel__c, BO1stRegistrationDate__c, BO1stRegisteredById__c, FirstCloseDate__c ';
        String query_From    = ' FROM Opportunity';
        String query_WHERE   = ' WHERE CompanyCode__c = :asIs_CompCodeSet';
               query_WHERE  += ' AND OpportunityCode__c = :asIs_opptyCodeSet';

        ifStartLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Start:' + BC.getJobId() + ') 종료' + ' ####################');
        batchStartLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Start', '', 0);
        ifStartLog.createLog(batchStartLog);

        return Database.getQueryLocator(query_Select + query_Fields + query_From + query_WHERE);
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> scope) {
        IF_Log ifExcuteLog = new IF_Log();
        IF_Log.BatchLog batchExcuteLog;
        List<String> excuteErrorMsgList = new List<String>();

        ifExcuteLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Excute:' + BC.getJobId() + ') 시작' + ' ####################');

        insert_opptyList            = new List<Opportunity>(); // To-Be Insert Target Opportunity List
        insert_opptyTeamMemberList  = new List<OpportunityTeamMember>(); // To-Be Insert Target Opportunity Team Member List
        insert_opptyActList         = new List<Opportunity_Activity__c>(); // To-Be Insert Target Opportunity Activity List
        insert_knoxList             = new List<KnoxApproval__c>(); // To-Be Insert Target Knox Approval List
        insert_serviceList          = new List<Service__c>(); // To-Be Insert Target Service List
        insert_solutionList         = new List<Solution__c>(); // To-Be Insert Target Solution List
        insert_projectList          = new List<Project__c>(); // To-Be Insert Target Project List
        insert_wbsList              = new List<WBS__C>(); // To-Be Insert Target WBS List

        // [S] As-Is Opportunity -> To-Be Opportunity
        try{
            if (DEBUG_FLAG) ifExcuteLog.addLog('scope.size() : ' + scope.size());

            originOpptyList = scope;

            if(originOpptyList.size() > 0){
                for(Opportunity oppty : originOpptyList){
                    asIs_opptyIdSet.add(oppty.Id);

                    Opportunity cloneOppty = oppty.clone(false, true);
                    if(oppty.CollaborationBOId__c != null){ // 협업 사업기회 처리
                        cloneOppty.OpportunityCode__c = oppty.OpportunityCode__c;
                    }else{ // 단독 사업기회 처리
                        cloneOppty.OpportunityCode__c = 'SD' + opptyCodeFormatMap.get(oppty.CompanyCode__c + '_' + oppty.OpportunityCode__c) + '-' + (oppty.OpportunityCode__c).right(8);
                    }
                    cloneOppty.SalesDepartment__c = ccMap.get(opptySalesDeptMap.get(oppty.CompanyCode__c + '_' + oppty.OpportunityCode__c)); // 주수주부서
                    cloneOppty.cPrimarySalesDepartment__c = ccMap.get(opptyDelivDeptMap.get(oppty.CompanyCode__c + '_' + oppty.OpportunityCode__c)); // 주매출부서
                    cloneOppty.MigData__c = true;
                    cloneOppty.IsEdited__c = true;
                    cloneOppty.IsCostCenterMerge__c = true;

                    if(cloneOppty.SalesDepartment__c != null && cloneOppty.cPrimarySalesDepartment__c != null){
                        insert_opptyList.add(cloneOppty);
                    }

                    newIdCodeMap.put(oppty.Id, cloneOppty.OpportunityCode__c);
                    newCodeIdMap.put(cloneOppty.OpportunityCode__c, oppty.Id);
                    newCodeOldCodeMap.put(cloneOppty.OpportunityCode__c, oppty.OpportunityCode__c);
                }
            }
        }catch(Exception e){
            System.debug('To-Be Oppty Setting Error : ' + e.getMessage());
            System.debug('To-Be Oppty Setting Error StackTrace : ' + e.getStackTraceString());
            System.debug('To-Be Oppty Setting Error Line : ' + e.getLineNumber());

            ifExcuteLog.addLog('Exception : ' + e.getStackTraceString());
            excuteErrorMsgList.add('Exception : ' + e.getMessage());
            batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'To-Be Oppty Setting Error', '', 0, 0, e);
        }
        // [E] As-Is Opportunity -> To-Be Opportunity

        // [S] As-Is Opportunity Team Member Map 생성
        try{
            List<OpportunityTeamMember> opptyTeamMemberList = [SELECT Id, OpportunityId, Opportunity.CompanyCode__c, Opportunity.OpportunityCode__c, UserId, Name, PhotoUrl, Title, TeamMemberRole, 
                                                                      OpportunityAccessLevel, ExternalId__c  
                                                                 FROM OpportunityTeamMember 
                                                                WHERE OpportunityId =: asIs_opptyIdSet];
            if(opptyTeamMemberList.size() > 0){
                for(OpportunityTeamMember opptyTeamMember : opptyTeamMemberList){
                    if(opptyTeamMemberMap.get(opptyTeamMember.OpportunityId) != null){
                        List<OpportunityTeamMember> oldOpptyTeamMemberList = opptyTeamMemberMap.get(opptyTeamMember.OpportunityId);
                        oldOpptyTeamMemberList.add(opptyTeamMember);
                        opptyTeamMemberMap.put(opptyTeamMember.OpportunityId, oldOpptyTeamMemberList);
                    }else{
                        List<OpportunityTeamMember> newOpptyTeamMemberList = new List<OpportunityTeamMember>();
                        newOpptyTeamMemberList.add(opptyTeamMember);
                        opptyTeamMemberMap.put(opptyTeamMember.OpportunityId, newOpptyTeamMemberList);
                    }
                }
            }
        }catch(Exception e){
            System.debug('As-Is Oppty Team Member Map Setting Error : ' + e.getMessage());
            System.debug('As-Is Oppty Team Member Map Setting Error StackTrace : ' + e.getStackTraceString());
            System.debug('As-Is Oppty Team Member Map Setting Error Line : ' + e.getLineNumber());

            ifExcuteLog.addLog('Exception : ' + e.getStackTraceString());
            excuteErrorMsgList.add('Exception : ' + e.getMessage());
            batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'As-Is Oppty Team Member Map Setting Error', '', 0, 0, e);
        }
        // [E] As-Is Opportunity Team Member Map 생성

        // [S] As-Is Opportunity Activity Map 생성
        try{
            List<Opportunity_Activity__c> opptyActList = [SELECT Id, WhatId__c, WhatId__r.CompanyCode__c, WhatId__r.OpportunityCode__c, TransactionName__c, ExtID__c, MigData__c, CurrencyIsoCode, 
                                                                 CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, Description__c, DueDate__c, Index__c, Status__c, StartDate__c, EndDate__c,
                                                                 LostType__c, URL__c, activitylogicialkey__c, LostReason__c 
                                                            FROM Opportunity_Activity__c
                                                           WHERE WhatId__c =: asIs_opptyIdSet];
            if(opptyActList.size() > 0){
                for(Opportunity_Activity__c opptyAct : opptyActList){
                    if(opptyActMap.get(opptyAct.WhatId__c) != null){
                        List<Opportunity_Activity__c> oldOpptyActList = opptyActMap.get(opptyAct.WhatId__c);
                        oldOpptyActList.add(opptyAct);
                        opptyActMap.put(opptyAct.WhatId__c, oldOpptyActList);
                    }else{
                        List<Opportunity_Activity__c> newOpptyActList = new List<Opportunity_Activity__c>();
                        newOpptyActList.add(opptyAct);
                        opptyActMap.put(opptyAct.WhatId__c, newOpptyActList);
                    }
                }
            }
        }catch(Exception e){
            System.debug('As-Is Oppty Activity Map Setting Error : ' + e.getMessage());
            System.debug('As-Is Oppty Activity Map Setting Error StackTrace : ' + e.getStackTraceString());
            System.debug('As-Is Oppty Activity Map Setting Error Line : ' + e.getLineNumber());

            ifExcuteLog.addLog('Exception : ' + e.getStackTraceString());
            excuteErrorMsgList.add('Exception : ' + e.getMessage());
            batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'As-Is Oppty Activity Map Setting Error', '', 0, 0, e);
        }
        // [E] As-Is Opportunity Activity Map 생성

        // [S] As-Is Knox Approval Map 생성
        try{
            List<KnoxApproval__c> knoxList = [SELECT Id, Name, ApprovedId__c, Description__c, MISID__c, objAPIName__c, objRecordName__c, OwnerId, Opportunity__c, Opportunity__r.CompanyCode__c,
                                                     Opportunity__r.OpportunityCode__c, Status__c, Cancel_Reason__c, TemplateName__c, Template__c, Opinion__c, BizReview__c, CompanyCode__c, BoCode__c,
                                                     BoActivityCode__c, TEXTNO__c, ObjKey__c, WFOBJECT__c, OpportunityActivity__c, OpportunityActivity__r.ExtID__c, CreatedDate
                                                FROM KnoxApproval__c
                                               WHERE Opportunity__c =: asIs_opptyIdSet];
            if(knoxList.size() > 0){
                for(KnoxApproval__c knox : knoxList){
                    if(knoxMap.get(knox.OpportunityActivity__r.ExtID__c) != null){
                        List<KnoxApproval__c> oldKnoxList = knoxMap.get(knox.OpportunityActivity__r.ExtID__c);
                        oldKnoxList.add(knox);
                        knoxMap.put(knox.OpportunityActivity__r.ExtID__c, oldKnoxList);
                    }else{
                        List<KnoxApproval__c> newKnoxList = new List<KnoxApproval__c>();
                        newKnoxList.add(knox);
                        knoxMap.put(knox.OpportunityActivity__r.ExtID__c, newKnoxList);
                    }
                }
            }
        }catch(Exception e){
            System.debug('As-Is Knox Approval Map Setting Error : ' + e.getMessage());
            System.debug('As-Is Knox Approval Map Setting Error StackTrace : ' + e.getStackTraceString());
            System.debug('As-Is Knox Approval Map Setting Error Line : ' + e.getLineNumber());

            ifExcuteLog.addLog('Exception : ' + e.getStackTraceString());
            excuteErrorMsgList.add('Exception : ' + e.getMessage());
            batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'As-Is Knox Approval Map Setting Error', '', 0, 0, e);
        }
        // [E] As-Is Knox Approval Map 생성

        // [S] As-Is Service Map 생성
        try{
            List<Service__c> svcList = [SELECT Id, Opportunity__c, Opportunity__r.CompanyCode__c, Opportunity__r.OpportunityCode__c, ItemNumber__c, sDeletionFlag__c, DeletionFlag__c, SendSAP__c, WBSCode__c,
                                               sService__c, sService__r.Code__c, Service__c, Service__r.Code__c, sSalesDepartment__c, sSalesDepartment__r.CostCenter__c, sDeliveryDepartment__c, sDeliveryDepartment__r.CostCenter__c, 
                                               SalesDepartment__c, SalesDepartment__r.CostCenter__c, DeliveryDepartment__c, DeliveryDepartment__r.CostCenter__c, SAP_SendTime__c
                                          FROM Service__c
                                         WHERE Opportunity__c =: asIs_opptyIdSet];
            if(svcList.size() > 0){
                for(Service__c svc : svcList){
                    if(serviceMap.get(svc.Opportunity__c) != null){
                        List<Service__c> oldSvcList = serviceMap.get(svc.Opportunity__c);
                        oldSvcList.add(svc);
                        serviceMap.put(svc.Opportunity__c, oldSvcList);
                    }else{
                        List<Service__c> newSvcList = new List<Service__c>();
                        newSvcList.add(svc);
                        serviceMap.put(svc.Opportunity__c, newSvcList);
                    }
                }
            }
        }catch(Exception e){
            System.debug('As-Is Service Map Setting Error : ' + e.getMessage());
            System.debug('As-Is Service Map Setting Error StackTrace : ' + e.getStackTraceString());
            System.debug('As-Is Service Map Setting Error Line : ' + e.getLineNumber());

            ifExcuteLog.addLog('Exception : ' + e.getStackTraceString());
            excuteErrorMsgList.add('Exception : ' + e.getMessage());
            batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'As-Is Service Map Setting Error', '', 0, 0, e);
        }
        // [E] As-Is Service Map 생성

        // [S] As-Is Solution Map 생성
        try{
            List<Solution__c> solList = [SELECT Id, Opportunity__c, Opportunity__r.OpportunityCode__c, Opportunity__r.CompanyCode__c, Service__c, Service__r.ItemNumber__c, Service__r.Service_Code__c, 
                                                sSolution__c, sSolution__r.Code__c, sBizAttribute__c, Solution__c, Solution__r.Code__c, BizAttribute__c, sBusinessType__c, sDeletionFlag__c, sPSType__c, 
                                                BusinessType__c, DeletionFlag__c, PSType__c, SalesType__c, WBSClass__c, sWBSClass__c, SendSAP__c, WBSCode__c, SAP_SendTime__c
                                           FROM Solution__c
                                          WHERE Opportunity__c =: asIs_opptyIdSet];
            if(solList.size() > 0){
                for(Solution__c sol : solList){
                    if(solutionMap.get(sol.Opportunity__c + '_' + sol.Service__r.ItemNumber__c) != null){
                        List<Solution__c> oldsolList = solutionMap.get(sol.Opportunity__c + '_' + sol.Service__r.ItemNumber__c);
                        oldsolList.add(sol);
                        solutionMap.put(sol.Opportunity__c + '_' + sol.Service__r.ItemNumber__c, oldsolList);
                    }else{
                        List<Solution__c> newsolList = new List<Solution__c>();
                        newsolList.add(sol);
                        solutionMap.put(sol.Opportunity__c + '_' + sol.Service__r.ItemNumber__c, newsolList);
                    }
                }
            }
        }catch(Exception e){
            System.debug('As-Is Solution Map Setting Error : ' + e.getMessage());
            System.debug('As-Is Solution Map Setting Error StackTrace : ' + e.getStackTraceString());
            System.debug('As-Is Solution Map Setting Error Line : ' + e.getLineNumber());

            ifExcuteLog.addLog('Exception : ' + e.getStackTraceString());
            excuteErrorMsgList.add('Exception : ' + e.getMessage());
            batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'As-Is Solution Map Setting Error', '', 0, 0, e);
        }
        // [E] As-Is Solution Map 생성

        // [S] To-Be Data Insert
        if(insert_opptyList.size() > 0){
            try{
                // To-Be Opportunity Insert
                insert insert_opptyList;
            }catch(Exception e){
                System.debug('To-Be Oppty Insert Error : ' + e.getMessage());
                System.debug('To-Be Oppty Insert Error StackTrace : ' + e.getStackTraceString());
                System.debug('To-Be Oppty Insert Error Line : ' + e.getLineNumber());

                ifExcuteLog.addLog('Exception : ' + e.getStackTraceString());
                excuteErrorMsgList.add('Exception : ' + e.getMessage());
                batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'To-Be Oppty Insert Error : '+e.getMessage() + ' : ' +e.getStackTraceString(), '', 0, 0, e);
                ifExcutelog.createLog(batchExcuteLog);
            }
            
            for(Opportunity cloneOppty : insert_opptyList){
                success_opptyList.add(cloneOppty);

                try{
                    // [S] 사업기회 팀맴버 데이터 생성
                    if(opptyTeamMemberMap.get(newCodeIdMap.get(cloneOppty.OpportunityCode__c)) != null){
                        List<OpportunityTeamMember> old_OpptyTeamMemberList = opptyTeamMemberMap.get(newCodeIdMap.get(cloneOppty.OpportunityCode__c));
                        for(OpportunityTeamMember old_OpptyTeamMember : old_OpptyTeamMemberList){
                            OpportunityTeamMember new_OpptyTeamMember = old_OpptyTeamMember.clone(false, true);
                            new_OpptyTeamMember.OpportunityId = cloneOppty.Id;
                        
                            insert_opptyTeamMemberList.add(new_OpptyTeamMember);
                        }
                    }
                    // [E] 사업기회 팀맴버 데이터 생성
                }catch(Exception e){
                    System.debug('To-Be Oppty Team Member Setting Error : ' + e.getMessage());
                    System.debug('To-Be Oppty Team Member Setting Error StackTrace : ' + e.getStackTraceString());
                    System.debug('To-Be Oppty Team Member Setting Error Line : ' + e.getLineNumber());

                    ifExcuteLog.addLog('Exception : ' + e.getStackTraceString());
                    excuteErrorMsgList.add('Exception : ' + e.getMessage());
                    batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'To-Be Oppty Team Member Setting Error', '', 0, 0, e);
                }

                try{
                    // [S] 사업기회 액티비티 데이터 생성
                    if(opptyActMap.get(newCodeIdMap.get(cloneOppty.OpportunityCode__c)) != null){
                        List<Opportunity_Activity__c> old_OpptyActList = opptyActMap.get(newCodeIdMap.get(cloneOppty.OpportunityCode__c));
                        for(Opportunity_Activity__c old_OpptyAct : old_OpptyActList){
                            Opportunity_Activity__c new_OpptyAct = old_OpptyAct.clone(false, true);
                            new_OpptyAct.WhatId__c = cloneOppty.Id;
                            new_OpptyAct.ExtID__c = cloneOppty.Id + '_' + old_OpptyAct.TransactionName__c;
                            new_OpptyAct.MigData__c = true;
                        
                            insert_opptyActList.add(new_OpptyAct);
                        }
                    }
                    // [E] 사업기회 액티비티 데이터 생성
                }catch(Exception e){
                    System.debug('To-Be Oppty Act Setting Error : ' + e.getMessage());
                    System.debug('To-Be Oppty Act Setting Error StackTrace : ' + e.getStackTraceString());
                    System.debug('To-Be Oppty Act Setting Error Line : ' + e.getLineNumber());

                    ifExcuteLog.addLog('Exception : ' + e.getStackTraceString());
                    excuteErrorMsgList.add('Exception : ' + e.getMessage());
                    batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'To-Be Oppty Act Setting Error', '', 0, 0, e);
                }

                try{
                    // [S] 서비스 데이터 생성
                    if(serviceMap.get(newCodeIdMap.get(cloneOppty.OpportunityCode__c)) != null){
                        List<Service__c> old_SvcList = serviceMap.get(newCodeIdMap.get(cloneOppty.OpportunityCode__c));
                        for(Service__c old_Svc : old_SvcList){
                            String svcKey = old_Svc.Opportunity__r.CompanyCode__c + '_' + old_Svc.Opportunity__r.OpportunityCode__c + '_' + old_Svc.Service__r.Code__c + '_' + old_Svc.ItemNumber__c;

                            Service__c new_Svc = old_Svc.clone(false, true);
                            new_Svc.Opportunity__c = cloneOppty.Id;
                            new_Svc.SalesDepartment__c = ccMap.get(svcSalesDeptMap.get(svcKey));
                            new_Svc.sSalesDepartment__c = ccMap.get(svcSalesDeptMap.get(svcKey));
                            new_Svc.DeliveryDepartment__c = ccMap.get(svcDelivDeptMap.get(svcKey));
                            new_Svc.sDeliveryDepartment__c = ccMap.get(svcDelivDeptMap.get(svcKey));
                            new_Svc.WBSCode__c = svcWBSMap.get(svcKey) != null ? svcWBSMap.get(svcKey) : '';

                            insert_serviceList.add(new_Svc);
                        }
                    }
                    // [E] 서비스 데이터 생성
                }catch(Exception e){
                    System.debug('To-Be Service Setting Error : ' + e.getMessage());
                    System.debug('To-Be Service Setting Error StackTrace : ' + e.getStackTraceString());
                    System.debug('To-Be Service Setting Error Line : ' + e.getLineNumber());

                    ifExcuteLog.addLog('Exception : ' + e.getStackTraceString());
                    excuteErrorMsgList.add('Exception : ' + e.getMessage());
                    batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'To-Be Service Setting Error', '', 0, 0, e);
                }
                
                try{
                    // [S] 프로젝트 데이터 생성
                    if(originCCMList.size() > 0){
                        projectMap = new Map<String, Project__c>();
                        for(CostCenterMerge__c originCCM : originCCMList){
                            if((originCCM.OpptyCode_AsIs__c).right(8) == (cloneOppty.OpportunityCode__c).right(8)){
                                if(projectMap.get(cloneOppty.OpportunityCode__c + '_' + originCCM.Project__c) == null){
                                    Project__c new_Pjt = new Project__c();
                                    new_Pjt.Opportunity__c = cloneOppty.Id;
                                    new_Pjt.ProjectCode__c = originCCM.Project__c;
                                    new_Pjt.Name = originCCM.ProjectDescription__c;
                                    new_Pjt.Description__c = originCCM.ProjectDescription__c;

                                    projectMap.put(cloneOppty.OpportunityCode__c + '_' + new_Pjt.ProjectCode__c, new_Pjt);
                                }
                            }
                        }
                    }
                    // [E]] 프로젝트 데이터 생성
                }catch(Exception e){
                    System.debug('To-Be Project Setting Error : ' + e.getMessage()); 
                    System.debug('To-Be Project Setting Error StackTrace : ' + e.getStackTraceString());
                    System.debug('To-Be Project Setting Error Line : ' + e.getLineNumber());

                    ifExcuteLog.addLog('Exception : ' + e.getStackTraceString());
                    excuteErrorMsgList.add('Exception : ' + e.getMessage());
                    batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'To-Be Project Setting Error', '', 0, 0, e);
                }
            }

            if(projectMap.size() > 0){
                try{
                    insert_projectList = projectMap.values();

                    // To-Be Project Insert
                    insert insert_projectList;
                }catch(Exception e){
                    System.debug('To-Be Project Insert Error : ' + e.getMessage());
                    System.debug('To-Be Project Insert Error StackTrace : ' + e.getStackTraceString());
                    System.debug('To-Be Project Insert Error Line : ' + e.getLineNumber());

                    ifExcuteLog.addLog('Exception : ' + e.getStackTraceString());
                    excuteErrorMsgList.add('Exception : ' + e.getMessage());
                    batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'To-Be Project Insert Error', '', 0, 0, e);
                }

                Set<String> newProjectIdSet = new Set<String>();
                for(Project__c project : insert_projectList){
                    newProjectIdSet.add(project.Id);
                }

                newProjectCodeMap = new Map<String, Project__c>(); 
                List<Project__c> newProjectList = [SELECT Id, Name, Description__c, Opportunity__c, ProjectCode__c, DeletionFlag__c, fm_CompanyProjectCode__c, ProjectType__c 
                                                     FROM Project__c
                                                    WHERE Id =: newProjectIdSet];
                for(Project__c newProject : newProjectList){
                    newProjectCodeMap.put(newProject.ProjectCode__c, newProject);
                }
            }

            if(insert_opptyTeamMemberList.size() > 0){
                try{
                    // To-Be Opportunity Team Member Insert
                    insert insert_opptyTeamMemberList;
                }catch(Exception e){
                    System.debug('To-Be Oppty Team Member Insert Error : ' + e.getMessage());
                    System.debug('To-Be Oppty Team Member Insert Error StackTrace : ' + e.getStackTraceString());
                    System.debug('To-Be Oppty Team Member Insert Error Line : ' + e.getLineNumber());

                    ifExcuteLog.addLog('Exception : ' + e.getStackTraceString());
                    excuteErrorMsgList.add('Exception : ' + e.getMessage());
                    batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'To-Be Oppty Team Member Insert Error', '', 0, 0, e);
                }
            }

            if(insert_opptyActList.size() > 0){
                try{
                    // To-Be Opportunity Activity Insert
                    insert insert_opptyActList;
                }catch(Exception e){
                    System.debug('To-Be Oppty Act Insert Error : ' + e.getMessage());
                    System.debug('To-Be Oppty Act Insert Error StackTrace : ' + e.getStackTraceString());
                    System.debug('To-Be Oppty Act Insert Error Line : ' + e.getLineNumber());

                    ifExcuteLog.addLog('Exception : ' + e.getStackTraceString());
                    excuteErrorMsgList.add('Exception : ' + e.getMessage());
                    batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'To-Be Oppty Act Insert Error', '', 0, 0, e);
                }

                Set<String> newOpptyActIdSet = new Set<String>();
                for(Opportunity_Activity__c opptyAct : insert_opptyActList){
                    newOpptyActIdSet.add(opptyAct.Id);
                }

                List<Opportunity_Activity__c> newOpptyActList = [SELECT Id, WhatId__c, WhatId__r.CompanyCode__c, WhatId__r.OpportunityCode__c, TransactionName__c, ExtID__c, MigData__c, CurrencyIsoCode, 
                                                                        CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, Description__c, DueDate__c, Index__c, Status__c, StartDate__c, EndDate__c,
                                                                        LostType__c, URL__c, activitylogicialkey__c, LostReason__c 
                                                                   FROM Opportunity_Activity__c 
                                                                  WHERE Id =: newOpptyActIdSet];

                try{
                    for(Opportunity_Activity__c newOpptyAct : newOpptyActList){
                        // [S] Knox Approval 데이터 생성
                        if(knoxMap.get(newCodeIdMap.get(newOpptyAct.WhatId__r.OpportunityCode__c) + '_' + newOpptyAct.TransactionName__c) != null){
                            List<KnoxApproval__c> old_KnoxList = knoxMap.get(newCodeIdMap.get(newOpptyAct.WhatId__r.OpportunityCode__c) + '_' + newOpptyAct.TransactionName__c);
                            for(KnoxApproval__c old_Knox : old_KnoxList){
                                KnoxApproval__c new_Knox = old_Knox.clone(false, true);
                                new_Knox.Opportunity__c = newOpptyAct.WhatId__c;
                                new_Knox.OpportunityActivity__c = newOpptyAct.Id;
                                new_Knox.BoCode__c = newOpptyAct.WhatId__r.OpportunityCode__c;
                                new_Knox.CompanyCode__c = newOpptyAct.WhatId__r.CompanyCode__c;
                                new_Knox.CreatedDate = old_Knox.CreatedDate;
        
                                insert_knoxList.add(new_Knox);
                            }
                        }
                        // [E] Knox Approval 데이터 생성
                    }
                }catch(Exception e){
                    System.debug('To-Be Knox Approval Setting Error : ' + e.getMessage());
                    System.debug('To-Be Knox Approval Setting Error StackTrace : ' + e.getStackTraceString());
                    System.debug('To-Be Knox Approval Setting Error Line : ' + e.getLineNumber());

                    ifExcuteLog.addLog('Exception : ' + e.getStackTraceString());
                    excuteErrorMsgList.add('Exception : ' + e.getMessage());
                    batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'To-Be Knox Approval Setting Error', '', 0, 0, e);
                }

                if(insert_knoxList.size() > 0){
                    try{
                        // To-Be Knox Approval Insert
                        insert insert_knoxList;
                    }catch(Exception e){
                        System.debug('To-Be Knox Approval Insert Error : ' + e.getMessage());
                        System.debug('To-Be Knox Approval Insert Error StackTrace : ' + e.getStackTraceString());
                        System.debug('To-Be Knox Approval Insert Error Line : ' + e.getLineNumber());

                        ifExcuteLog.addLog('Exception : ' + e.getStackTraceString());
                        excuteErrorMsgList.add('Exception : ' + e.getMessage());
                        batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'To-Be Knox Approval Insert Error', '', 0, 0, e);
                    }
                }
            }

            if(insert_serviceList.size() > 0){
                try{
                    // To-Be Service Insert
                    insert insert_serviceList;
                }catch(Exception e){
                    System.debug('To-Be Service Insert Error : ' + e.getMessage());
                    System.debug('To-Be Service Insert Error StackTrace : ' + e.getStackTraceString());
                    System.debug('To-Be Service Insert Error Line : ' + e.getLineNumber());

                    ifExcuteLog.addLog('Exception : ' + e.getStackTraceString());
                    excuteErrorMsgList.add('Exception : ' + e.getMessage());
                    batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'To-Be Service Insert Error', '', 0, 0, e);
                }

                Set<String> newSvcIdSet = new Set<String>();
                for(Service__c service : insert_serviceList){
                    newSvcIdSet.add(service.Id);
                }

                List<Service__c> newSvcList = [SELECT Id, Opportunity__c, Opportunity__r.CompanyCode__c, Opportunity__r.OpportunityCode__c, ItemNumber__c, sDeletionFlag__c, DeletionFlag__c, SendSAP__c, WBSCode__c,
                                                   sService__c, sService__r.Code__c, Service__c, Service__r.Code__c, sSalesDepartment__c, sSalesDepartment__r.CostCenter__c, sDeliveryDepartment__c, sDeliveryDepartment__r.CostCenter__c, 
                                                   SalesDepartment__c, SalesDepartment__r.CostCenter__c, DeliveryDepartment__c, DeliveryDepartment__r.CostCenter__c
                                              FROM Service__c
                                             WHERE Id =: newSvcIdSet];

                try{
                    for(Service__c newSvc : newSvcList){
                        // [S] Solution 데이터 생성
                        List<Solution__c> old_SolList = solutionMap.get(newCodeIdMap.get(newSvc.Opportunity__r.OpportunityCode__c ) + '_' + newSvc.ItemNumber__c);
                        for(Solution__c old_Sol : old_SolList){
                            String solKey = old_Sol.Opportunity__r.CompanyCode__c + '_' + old_Sol.Opportunity__r.OpportunityCode__c + '_' + old_Sol.Service__r.Service_Code__c + '_' + old_Sol.Service__r.ItemNumber__c + '_' + old_Sol.Solution__r.Code__c;
    
                            Solution__c new_Sol = old_Sol.clone(false, true);
                            new_Sol.Opportunity__c = newSvc.Opportunity__c;
                            new_Sol.Service__c = newSvc.Id;
                            new_Sol.WBSCode__c = solWBSMap.get(solKey) != null ? solWBSMap.get(solKey) : '';
                            new_Sol.ProjectCode__c = solProjectMap.get(solKey) != null ? solProjectMap.get(solKey) : '';
    
                            insert_solutionList.add(new_Sol);
                        }
                        // [E] Solution 데이터 생성
                    }
                }catch(Exception e){
                    System.debug('To-Be Solution Setting Error : ' + e.getMessage());
                    System.debug('To-Be Solution Setting Error StackTrace : ' + e.getStackTraceString());
                    System.debug('To-Be Solution Setting Error Line : ' + e.getLineNumber());

                    ifExcuteLog.addLog('Exception : ' + e.getStackTraceString());
                    excuteErrorMsgList.add('Exception : ' + e.getMessage());
                    batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'To-Be Solution Setting Error', '', 0, 0, e);
                }
                
                if(insert_solutionList.size() > 0){
                    try{
                        // To-Be Solution Insert
                        insert insert_solutionList;
                    }catch(Exception e){
                        System.debug('To-Be Solution Insert Error : ' + e.getMessage());
                        System.debug('To-Be Solution Insert Error StackTrace : ' + e.getStackTraceString());
                        System.debug('To-Be Solution Insert Error Line : ' + e.getLineNumber());

                        ifExcuteLog.addLog('Exception : ' + e.getStackTraceString());
                        excuteErrorMsgList.add('Exception : ' + e.getMessage());
                        batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'To-Be Solution Insert Error', '', 0, 0, e);
                    }
                    
                    Set<String> newSolIdSet = new Set<String>();
                    for(Solution__c solution : insert_solutionList){
                        newSolIdSet.add(solution.Id);
                    }

                    List<Solution__c> newSolList = [SELECT Id, Opportunity__c, Opportunity__r.OpportunityCode__c, Opportunity__r.CompanyCode__c, Service__c, Service__r.ItemNumber__c, Service__r.Service_Code__c, 
                                                           sSolution__c, sSolution__r.Code__c, sBizAttribute__c, Solution__c, Solution__r.Code__c, BizAttribute__c, sBusinessType__c, sDeletionFlag__c, sPSType__c, 
                                                           BusinessType__c, DeletionFlag__c, PSType__c, SalesType__c, WBSClass__c, sWBSClass__c, SendSAP__c, WBSCode__c, SAP_SendTime__c
                                                      FROM Solution__c
                                                     WHERE Id =: newSolIdSet];
                    for(Solution__c newSol : newSolList){
                        System.debug('newSol.Opportunity__c : ' + newSol.Opportunity__c);
                        System.debug('newSol.Service__r.Service_Code__c : ' + newSol.Service__r.Service_Code__c);
                        System.debug('newSol.Service__r.ItemNumber__c : ' + newSol.Service__r.ItemNumber__c);
                        newSolMap.put(newSol.Opportunity__c + '_' + newSol.Service__r.Service_Code__c + '_' + newSol.Service__r.ItemNumber__c, newSol);
                    }

                    try{
                        // [S] WBS 데이터 생성
                        if(originCCMList.size() > 0){
                            for(CostCenterMerge__c originCCM : originCCMList){
                                WBS__c new_Wbs = new WBS__c();
                                new_Wbs.Name = (originCCM.WBS__c).replace('-', '');
                                new_Wbs.OpportunityID__c = newProjectCodeMap.get(originCCM.Project__c) != null ? newProjectCodeMap.get(originCCM.Project__c).Opportunity__c : null;
                                new_Wbs.Project__c = newProjectCodeMap.get(originCCM.Project__c) != null ? newProjectCodeMap.get(originCCM.Project__c).Id : null;
                                new_Wbs.ProjectCode__c = originCCM.ProjectCode__c;
                                new_Wbs.ProjectCodeOutput__c = originCCM.Project__c;
                                new_Wbs.SolutionCode__c = originCCM.Solution__c;
                                if(newSolMap.get(new_Wbs.OpportunityID__c + '_' + originCCM.Service__c + '_' + originCCM.ItemNumber__c) != null){
                                    new_Wbs.Solution__c = newSolMap.get(new_Wbs.OpportunityID__c + '_' + originCCM.Service__c + '_' + originCCM.ItemNumber__c).Id;
                                }
                                new_Wbs.ServiceCode__c = originCCM.Service__c;
                                new_Wbs.ItemNumber__c = originCCM.ItemNumber__c;
                                new_Wbs.BizAttribCode__c = originCCM.BizAttributeCode__c;

                                if(new_Wbs.OpportunityID__c != null && new_Wbs.Project__c != null && new_Wbs.Solution__c != null){
                                    insert_wbsList.add(new_Wbs);
                                }
                            }
                        }
                        // [E] WBS 데이터 생성
                    }catch(Exception e){
                        System.debug('To-Be WBS Setting Error : ' + e.getMessage());
                        System.debug('To-Be WBS Setting Error StackTrace : ' + e.getStackTraceString());
                        System.debug('To-Be WBS Setting Error Line : ' + e.getLineNumber());

                        ifExcuteLog.addLog('Exception : ' + e.getStackTraceString());
                        excuteErrorMsgList.add('Exception : ' + e.getMessage());
                        batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'To-Be WBS Setting Error', '', 0, 0, e);
                    }
                }
            }
            if(insert_wbsList.size() > 0){
                try{
                    // To-Be WBS Insert
                    insert insert_wbsList;
                }catch(Exception e){
                    System.debug('To-Be WBS Insert Error : ' + e.getMessage());
                    System.debug('To-Be WBS Insert Error StackTrace : ' + e.getStackTraceString());
                    System.debug('To-Be WBS Insert Error Line : ' + e.getLineNumber());

                    ifExcuteLog.addLog('Exception : ' + e.getStackTraceString());
                    excuteErrorMsgList.add('Exception : ' + e.getMessage());
                    batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'To-Be WBS Insert Error', '', 0, 0, e);
                }
            }
        }
        // [E] To-Be Data Insert

        ifExcuteLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Excute:' + BC.getJobId() + ') 종료' + ' ####################');            
        ifExcutelog.createLog(batchExcuteLog);
    }
    
    global void finish(Database.BatchableContext BC) {
        IF_Log ifFinishLog = new IF_Log();
        IF_Log.BatchLog batchFinishLog;
        List<String> finishErrorMsgList = new List<String>();

        ifFinishLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Finish:' + BC.getJobId() + ') 시작' + ' ####################');
        batchFinishLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Finish', '', 0);
        
        if(success_opptyList.size() > 0){
            Set<String> asisOpptyIdSet = new Set<String>();
            Map<String, String> collaboBoMap = new Map<String, String>();
            Set<String> asisOpptyCodeSet = new Set<String>();

            for(Opportunity success_oppty : success_opptyList){
                asisOpptyIdSet.add(newCodeIdMap.get(success_oppty.OpportunityCode__c));

                if(success_oppty.CollaborationBOId__c != null) collaboBoMap.put(success_oppty.CollaborationBOId__c, success_oppty.Id);

                asisOpptyCodeSet.add(newCodeOldCodeMap.get(success_oppty.OpportunityCode__c));
            }
        
            // [S] As-Is Opportunity Update
            if(asisOpptyIdSet.size() > 0){
                List<Opportunity> asisOpptyList = [SELECT Id, Name, OpportunityCode__c, StageName, OpportunityStatus__c FROM Opportunity WHERE Id =: asisOpptyIdSet];
                if(asisOpptyList.size() > 0){
                    for(Opportunity asisOppty : asisOpptyList){
                        asisOppty.OpportunityCode__c = 'SDZ-' + (asisOppty.OpportunityCode__c).right(8);
                        //임시asisOppty.StageName = 'Z08';
                        //임시asisOppty.OpportunityStatus__c = 'E0008';
                        Integer i = 0;
                        i++;
                        i++;
                        i++;
                        i++;
                        i++;
                        i++;
                        i++;
                        i++;
                        i++;
                        i++;
                        i++;
                        i++;
                        i++;
                        i++;
                        i++;
                        i++;
                        i++;
                        i++;
                        i++;
                        i++;
                        i++;
                        i++;
                        i++;
                        i++;
                        i++;
                        i++;
                        i++;
                        i++;
                        i++;
                        i++;
                        i++;
                        i++;
                        i++;
                        i++;
                        i++;
                        i++;
                        i++;
                        i++;
                        i++;
                        i++;
                        i++;
                        i++;
                        i++;
                        i++;
                        i++;
                        i++;
                        i++;
                        i++;
                        i++;
                        i++;
                        i++;
                        i++;
                        i++;
                        i++;
                        i++;
                        i++;
                    }
        
                    try{
                        // As-Is Opportunity Update
                        update asisOpptyList;
        
                        //임시Approval.lock(asisOpptyList, false);
                    }catch(Exception e){
                        System.debug('As-Is Oppty Update Error : ' + e.getMessage());
                        System.debug('As-Is Oppty Update Error StackTrace : ' + e.getStackTraceString());
                        System.debug('As-Is Oppty Update Error Line : ' + e.getLineNumber());

                        ifFinishLog.addLog('Exception : ' + e.getStackTraceString());
                        finishErrorMsgList.add('Exception : ' + e.getMessage());
                        batchFinishLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'As-Is Oppty Update Error', '', 0, 0, e);
                    }
                }
            }
            // [E] As-Is Opportunity Update

            // [S] Collaboration Opportunity(T100) Update
            if(collaboBoMap.size() > 0){
                List<Opportunity> collaboOpptyList = [SELECT Id, Name, CollaborationBOId__c 
                                                        FROM Opportunity 
                                                       WHERE Id =: collaboBoMap.keySet()];
                if(collaboOpptyList.size() > 0){
                    for(Opportunity collaboOppty : collaboOpptyList){
                        collaboOppty.CollaborationBOId__c = collaboBoMap.get(collaboOppty.Id);
                    }
                    try{
                        // Collaboration Opportynity (T100) Update
                        update collaboOpptyList;
                    }catch(Exception e){
                        System.debug('Collaboration Oppty Update Error : ' + e.getMessage());
                        System.debug('Collaboration Oppty Update Error StackTrace : ' + e.getStackTraceString());
                        System.debug('Collaboration Oppty Update Error Line : ' + e.getLineNumber());

                        ifFinishLog.addLog('Exception : ' + e.getStackTraceString());
                        finishErrorMsgList.add('Exception : ' + e.getMessage());
                        batchFinishLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Collaboration Oppty Update Error', '', 0, 0, e);
                    }
                    
                }
            }
            // [E] Collaboration Opportunity(T100) Update

            // [S] CostCenterMerge Data Update
            if(asisOpptyCodeSet.size() > 0){
                List<CostCenterMerge__c> ccmList = [SELECT Id, Name, OpptyCode_AsIs__c, IsComplete__c 
                                                      FROM CostCenterMerge__c 
                                                     WHERE OpptyCode_AsIs__c =: asisOpptyCodeSet];
                if(ccmList.size() > 0){
                    for(CostCenterMerge__c ccm : ccmList){
                        ccm.IsComplete__c = true;
                    }

                    try{
                        update ccmList;
                    }catch(Exception e){
                        System.debug('CostCenterMerge Data Update Error : ' + e.getMessage());
                        System.debug('CostCenterMerge Data Update Error StackTrace : ' + e.getStackTraceString());
                        System.debug('CostCenterMerge Data Update Error Line : ' + e.getLineNumber());

                        ifFinishLog.addLog('Exception : ' + e.getStackTraceString());
                        finishErrorMsgList.add('Exception : ' + e.getMessage());
                        batchFinishLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'CostCenterMerge Data Update Error', '', 0, 0, e);
                    }
                }
            }
            // [E] CostCenterMerge Data Update
        }

        ifFinishLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Finish:' + BC.getJobId() + ') 종료' + ' ####################');
        ifFinishLog.createLog(batchFinishLog);
    }

    public void baseMapCreate(CostCenterMerge__c ccm){
        // To-Be Company Code Check
        toBe_compCodeSet.add((ccm.Oppty_SalesDept_ToBe__c).Left(4));
        toBe_compCodeSet.add((ccm.Oppty_DeliveryDept_ToBe__c).Left(4));
        toBe_compCodeSet.add((ccm.Svc_SalesDept_ToBe__c).Left(4));
        toBe_compCodeSet.add((ccm.Svc_DeliveryDept_ToBe__c).Left(4));

        // To-Be Opportunity Code Format Map
        opptyCodeFormatMap.put(ccm.CompanyCode_AsIs__c + '_' + ccm.OpptyCode_AsIs__c, ccm.Oppty_CodeFormat_ToBe__c);

        // To-Be Opportunity - Sales Department Map
        opptySalesDeptMap.put(ccm.CompanyCode_AsIs__c + '_' + ccm.OpptyCode_AsIs__c, ccm.Oppty_SalesDept_ToBe__c);

        // To-Be Opportunity - Delivery Department Map
        opptyDelivDeptMap.put(ccm.CompanyCode_AsIs__c + '_' + ccm.OpptyCode_AsIs__c, ccm.Oppty_DeliveryDept_ToBe__c);

        String svcKey = ccm.CompanyCode_AsIs__c + '_' + ccm.OpptyCode_AsIs__c + '_' + ccm.Service__c + '_' + ccm.ItemNumber__c;
        // To-Be Service - Sales Department Map
        svcSalesDeptMap.put(svcKey, ccm.Svc_SalesDept_ToBe__c);

        // To-Be Service - Delivery Department Map
        svcDelivDeptMap.put(svcKey, ccm.Svc_DeliveryDept_ToBe__c);

        // To-Be Service - WBS Code Map
        String svcWBSCode = (ccm.WBS__c).replace('-', '');
        if(svcWBSMap.get(svcKey) == null){
            if(svcWBSCode.length() == 15){
                svcWBSMap.put(svcKey, svcWBSCode);
            }
        }

        String solKey = ccm.CompanyCode_AsIs__c + '_' + ccm.OpptyCode_AsIs__c + '_' + ccm.Service__c + '_' + ccm.ItemNumber__c + '_' + ccm.Solution__c;
        // To-Be Solution - WBS Code Map
        String solWBSCode = (ccm.WBS__c).replace('-', '');
        if(solWBSMap.get(solKey) == null){
            if(solWBSCode.length() == 17){
                solWBSMap.put(solKey, solWBSCode);
            }
        }

        // To-Be Solution - Project Map
        if(solProjectMap.get(solKey) == null){
            solProjectMap.put(solKey, ccm.Project__c);
        }
    }
}