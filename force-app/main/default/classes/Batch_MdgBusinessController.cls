/**
 * @description       : IF-109 로 받은 Service/Solution Master 정보를 SFDC에 이관
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-08-20
 * @last modified by  : seonju.jin@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                            Modification
 * 1.0   2020-11-30   ghkil@partner.samsung.com         Initial Version (IF_109BIZ, IF_109SVC, IF_109SOL, IF_109CDESC에서 수신 받은 데이터를 Batch로 해당 Object에 반영한다. Batch 기준은 systemmodstamp의 -2일로 처리)
 * 1.1   2020-11-30   ghkil@partner.samsung.com         Relation 없는 Data 처리하지 않는 Logic 추가와 처리 후 IF_Flag 관리
 * 1.2   2021-01-05   ghkil@partner.samsung.com         Busness__c, Master_Service__c, Master_Solution__c에 모두 없는 ClassDesc에 대해 Skip 처리, Name정보 없는 경우 Code정보 입력 처리
 * 1.3   2021-02-03   ghkil@partner.samsung.com         ClassDesc 정보 처리 대상 중 'K'로 처리 된 내역이 있는 것은 Skip 처리 (기존 'K'로 처리 한 것을 'E'로 업데이트 하지 않기 위함)
 * 1.3   2021-02-04   kilhwan.an@partner.samsung.com    touppercase에서 null값이 발생 할 경우 예외 처리
 * 1.4   2021-02-25   ghkil@partner.samsung.com         Batch Log 생성 시 ApexMethod 추가 (JobId 제거)
 * 1.5   2021-08-20   seonju.jin@dkbmc.com              TechAttribute 파라미터 추가
**/
global class Batch_MdgBusinessController implements DataBase.Batchable<SObject>, DataBase.stateful, DataBase.AllowsCallouts, Schedulable {

    private final String INTERFACE_ID = 'IF-109';
    private final String APEX_CLASS   = 'Batch_MdgBusinessController'; 
    private final String METHOD_NAME  = 'Batch';

    private final Boolean DEBUG_FLAG = false;

    String guId = IF_Util.generateGuid();

    public Batch_MdgBusinessController() { }

    public DataBase.QueryLocator start(DataBase.BatchableContext BC){

        IF_Log ifStartLog = new IF_Log();
        IF_Log.BatchLog batchStartLog;
        List<String> startErrorMsgList = new List<String>();

        ifStartLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Start:' + BC.getJobId() + ') 시작' + ' ####################');

        String queryString;
        Database.QueryLocator returnScope;

        // 기본 쿼리 검색
        try{

            queryString =   'Select Id, Name ' + 
                            '       , IFType__c ' +          // Data 구분 (Business, Service, Solution, ClassDesc) 
                            '       , ExternalId__c ' +      // ExternalId
                            '       , CLASS__c ' +           // 클래스 코드 번호, 서비스 코드, 솔루션코드
                            '       , HCLAS__c ' +           // 사업 대분류 
                            '       , KLAGR__c ' +           // Class Group
                            '       , VONDT__c ' +           // 유효기간(From Date)
                            '       , BISDT__c ' +           // 유효기간(To date)
                            '       , USEYN__c ' +           // 사용여부 (Yes/No)
                            '       , SRVBNC__c ' +          // 사업부 코드
                            '       , SRVBNT__c ' +          // 사업부 명
                            '       , SRVDPC__c ' +          // 서비스 팀 코드
                            '       , SRVDPT__c ' +          // 서비스 팀명
                            '       , SOLTY__c ' +           // 솔루션 타입
                            '       , PRDYN__c ' +           // Product
                            '       , SOLMNC__c ' +          // 솔루션 매니저 사번
                            '       , SOLMNT__c ' +          // 솔루션 매니저 이름
                            '       , SOLDPC__c ' +          // 솔루션 부서 코드  
                            '       , SOLDPT__c ' +          // 솔루션 부서명
                            '       , BRAND__c ' +           // Code Name/Sub Brand
                            '       , COMPC__c ' +           // Company Code
                            '       , PLLEV__c ' +           // P/L Management Level                            
                            '       , PLCST__c ' +           // PLC Status
                            '       , LODAT__c ' +           // LOD (Last Order) Date                            
                            '       , EOPDT__c ' +           // EOP(End Of Production) Date
                            '       , EOSDT__c ' +           // EOS(End Of Service) Date
                            '       , SPRAS__c ' +           // Language Key
                            '       , KSCHL__c ' +           // 사업 대분류 이름
                            '       , NORMB__c ' +            // Industry Standard Description
                            '       , systemModStamp ' +
                            '       , IFFlag__c ' +
                            '       , ZZTECH_YN__c ' +        // 2021.08.20 TA여부 추가
                            'From   MDGBusinessMaster__c ' +
                            'Where  IFFlag__c in (\'I\', \'S\') ' +   // Insert 된 것과 Skip한 Data 기준
                            'Order by ExternalId__c ';

            system.debug('처리 대상 조회');

            returnScope = DataBase.getQueryLocator(queryString);

            ifStartLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Start:' + BC.getJobId() + ') 종료' + ' ####################');
                          
            batchStartLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Start', '', 0);
            
            ifStartLog.createLog(batchStartLog);
        }catch(Exception e){

            batchStartLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Start', '', 0, 0, e);
            startErrorMsgList.add('Batch exception : ' + e.getMessage());

            ifStartLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Start:' + BC.getJobId() + ') 종료' + ' ####################');

            ifStartLog.createLog(batchStartLog);            
        }

        return returnScope;
    }
    
    public void execute(DataBase.BatchableContext BC, List<MDGBusinessMaster__c> batchTargetList){

        IF_Log ifExcuteLog = new IF_Log();
        IF_Log.BatchLog batchExcuteLog;
        List<String> excuteErrorMsgList = new List<String>();
        
        system.debug('### Batch_MdgBusinessController :: execute :: batchTargetList = ' + batchTargetList);

        ifExcuteLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Excute:' + BC.getJobId() + ') 시작' + ' ####################');

        ifExcuteLog.addLog('처리 대상 : ' + batchTargetList.size());
        system.debug('처리 대상 : ' + batchTargetList.size());
        system.debug('처리 Data : ' + batchTargetList);

        // Interface Flag 관리
        Set<Id> IfSkipIdSet = new Set<Id>();
        Set<Id> IfFinishIdSet = new Set<Id>();

        // 처리할 데이터별 Map에 적재
        Map<String, MDGBusinessMaster__c> businessMap       = new Map<String, MDGBusinessMaster__c>();   // Business Data Map
        Map<String, MDGBusinessMaster__c> serviceMap        = new Map<String, MDGBusinessMaster__c>();   // Service Data Map
        Set<String> upBusinessCodeSet                       = new Set<String>();                         // 상위 Business Code Set
        Map<String, MDGBusinessMaster__c> solutionMap       = new Map<String, MDGBusinessMaster__c>();   // Solution Data Map
        Set<String> upServiceCodeSet                        = new Set<String>();                         // 상위 Service Code Set        
        Map<String, MDGBusinessMaster__c> classDescMap      = new Map<String, MDGBusinessMaster__c>();   // ClassDesc Data Map
        Map<String, MDGBusinessMaster__c> classDescCodeMap  = new Map<String, MDGBusinessMaster__c>();   // ClassDesc Data Map
        Set<String> selectNameCheckBusinessSet              = new Set<String>();                         // 기 적용한 Name 조회용 Set (Business__c)
        Set<String> selectNameCheckServiceSet               = new Set<String>();                         // 기 적용한 Name 조회용 Set (Master_Service__c)
        Set<String> selectNameCheckSolutionSet              = new Set<String>();                         // 기 적용한 Name 조회용 Set (Master_Solution__c)                
        for (MDGBusinessMaster__c dummyData : batchTargetList) {
            if (dummyData.IFType__c == 'Business') {
                businessMap.put(dummyData.CLASS__c, dummyData);
                selectNameCheckBusinessSet.add(dummyData.CLASS__c);                
            } else if (dummyData.IFType__c == 'Service') {
                serviceMap.put(dummyData.CLASS__c, dummyData);
                upBusinessCodeSet.add(dummyData.HCLAS__c);
                selectNameCheckServiceSet.add(dummyData.CLASS__c);                
            } else if (dummyData.IFType__c == 'Solution') {
                solutionMap.put(dummyData.CLASS__c, dummyData);
                upServiceCodeSet.add(dummyData.HCLAS__c);
                selectNameCheckSolutionSet.add(dummyData.CLASS__c);
            } else if (dummyData.IFType__c == 'ClassDesc') {
                classDescMap.put(dummyData.CLASS__c + dummyData.SPRAS__c, dummyData);
                classDescCodeMap.put(dummyData.CLASS__c, dummyData);
            }
        }
        ifExcuteLog.addLog('처리할 데이터별 Map에 적재');

        // 해당정보 반영
        Savepoint sp = Database.setSavepoint();

        try {
            // 기 반영된 Name 조회 (Business__c)
            List<Business__c> selectBusinessList = [
                Select  Id
                        , Name
                        , Code__c
                From    Business__c
                Where   Code__c IN :selectNameCheckBusinessSet
            ];
            Map<String, String> businessNameMap = new Map<String, String>();
            for (Business__c businessData : selectBusinessList) {
                businessNameMap.put(businessData.Code__c, businessData.Name);
            }

            // 기 반영된 Name 조회 (Master_Service__c)
            List<Master_Service__c> selectServiceList = [
                Select  Id
                        , Name
                        , Code__c
                From    Master_Service__c
                Where   Code__c IN :selectNameCheckServiceSet
            ];
            Map<String, String> serviceNameMap = new Map<String, String>();
            for (Master_Service__c serviceData : selectServiceList) {
                serviceNameMap.put(serviceData.Code__c, serviceData.Name);
            }
            
            // 기 반영된 Name 조회 (Master_Solution__c)
            List<Master_Solution__c> selectSolutionList = [
                Select  Id
                        , Name
                        , Code__c
                From    Master_Solution__c
                Where   Code__c IN :selectNameCheckSolutionSet
            ];
            Map<String, String> solutionNameMap = new Map<String, String>();
            for (Master_solution__c solutionData : selectSolutionList) {
                solutionNameMap.put(solutionData.Code__c, solutionData.Name);
            }            

            // Business 정보 처리
            List<Business__c> saveBusinessList = new List<Business__c>();

            for (String businessCode : businessMap.keySet()) {
                Business__c saveBusiness = new Business__c();
                Boolean useYn;

                String strUseYn = ( businessMap.get(businessCode).USEYN__c + '').toUppercase();

                if (strUseYn == 'YES' || strUseYn == 'Y') useYn = true;
                else useYn = false;
                
                saveBusiness.Code__c = businessCode;                                                                            // 사업 대분류 코드
                if (classDescMap.get(businessCode + 'K') != null) {
                    saveBusiness.Name = classDescMap.get(businessCode + 'K').KSCHL__c;                                          // 사업 대분류 이름 (K인 경우, K가 우선순위로 있으면 업데이트)
                    
                    IfFinishIdSet.add(classDescMap.get(businessCode + 'K').Id);         // Business ClassDesc 정보 처리 Id 저장
                } else if (classDescMap.get(businessCode + 'E') != null) {
                    saveBusiness.Name = classDescMap.get(businessCode + 'E').KSCHL__c;                                          // 사업 대분류 이름 (E인 경우)

                    IfFinishIdSet.add(classDescMap.get(businessCode + 'E').Id);         // Business ClassDesc 정보 처리 Id 저장
                } else {
                    if (businessNameMap.get(businessCode) == null) {
                        saveBusiness.Name = businessCode;
                    }
                }
                saveBusiness.ValidityStartDate__c   = Util_String.convertStringDate(businessMap.get(businessCode).VONDT__c);    // 유효기간(From Date)
                saveBusiness.ValidityEndDate__c     = Util_String.convertStringDate(businessMap.get(businessCode).BISDT__c);    // 유효기간(To date)
                saveBusiness.Use__c                 = useYn;                                                                    // 사용여부 (Yes/No)

                saveBusinessList.add(saveBusiness);

                IfFinishIdSet.add(businessMap.get(businessCode).Id);    // Business 정보 처리 Id 저장
                if (DEBUG_FLAG) ifExcuteLog.addLog('IfFinishIdSet : ' + IfFinishIdSet);
            }
            if (DEBUG_FLAG) ifExcuteLog.addLog('Business 정보 처리');

            // Business 정보 반영
            upsert saveBusinessList Code__c;
            ifExcuteLog.addLog('Business 정보 반영 완료 : ' + saveBusinessList.size());

            // Service 정보 처리
            Map<String, Id> businessCodeMap = new Map<String, Id>();                              // Business Code Map
            List<Business__c> businessList = [  Select Id, Code__c From Business__c Where Code__c IN :upBusinessCodeSet  ];  // Service의 상위 Business Id 가져오기

            for (Business__c businessData : businessList) {
                businessCodeMap.put(businessData.Code__c, businessData.Id);
            }

            List<Master_Service__c> saveServiceList = new List<Master_Service__c>();

            for (String serviceCode : serviceMap.keySet()) {
                if (businessCodeMap.get(serviceMap.get(serviceCode).HCLAS__c) != null) {

                    Master_Service__c saveService = new Master_Service__c();
                    Boolean useYn, techAttributeYn;

                    String strUseYn = ( serviceMap.get(serviceCode).USEYN__c + '').toUppercase();
                    if (strUseYn == 'YES' || strUseYn == 'Y') useYn = true;
                    else useYn = false;
        
                    saveService.Code__c = serviceCode;                                                                              // 서비스 코드
                    if (classDescMap.get(serviceCode + 'K') != null) {
                        saveService.Name = classDescMap.get(serviceCode + 'K').KSCHL__c;                                            // 서비스 이름 (K인 경우, K가 우선순위로 있으면 업데이트)

                        IfFinishIdSet.add(classDescMap.get(serviceCode + 'K').Id);         // Service ClassDesc 정보 처리 Id 저장
                    } else if (classDescMap.get(serviceCode + 'E') != null) {
                        saveService.Name = classDescMap.get(serviceCode + 'E').KSCHL__c;                                            // 서비스 이름 (E인 경우)

                        IfFinishIdSet.add(classDescMap.get(serviceCode + 'E').Id);         // Service ClassDesc 정보 처리 Id 저장
                    } else {
                        if (serviceNameMap.get(serviceCode) == null) {
                            saveService.Name = serviceCode;
                        }
                    }

                    //2021.08.20 TA여부 추가
                    String strTechAttributeYn = ( serviceMap.get(serviceCode).ZZTECH_YN__c + '').toUppercase();
                    if (strTechAttributeYn == 'YES' || strTechAttributeYn == 'Y') techAttributeYn = true;
                    else techAttributeYn = false;

                    saveService.Business__c	             = businessCodeMap.get(serviceMap.get(serviceCode).HCLAS__c);               // 사업 대분류                
                    saveService.ValidityStartDate__c     = Util_String.convertStringDate(serviceMap.get(serviceCode).VONDT__c);     // 유효기간(From Date)
                    saveService.ValidityEndDate__c       = Util_String.convertStringDate(serviceMap.get(serviceCode).BISDT__c);     // 유효기간(To date)
                    saveService.Use__c                   = useYn;                                                                   // 사용여부 (Yes/No)
                    saveService.ServiceBizUnitCode__c    = serviceMap.get(serviceCode).SRVBNC__c;                                   // 사업부 코드
                    saveService.ServiceBizUnit__c        = serviceMap.get(serviceCode).SRVBNT__c;                                   // 사업부 명
                    saveService.ServiceDepartmentCode__c = serviceMap.get(serviceCode).SRVDPC__c;                                   // 서비스 팀 코드
                    saveService.ServiceDepartment__c     = serviceMap.get(serviceCode).SRVDPT__c;                                   // 서비스 팀
                    saveService.TechAttribute__c         = techAttributeYn;                                                         // TA 여부

                    saveServiceList.add(saveService);
                    
                    IfFinishIdSet.add(serviceMap.get(serviceCode).Id);              // Service 정보 처리 Id 저장
                    if (DEBUG_FLAG) ifExcuteLog.addLog('[Service]IfFinishIdSet : ' + IfFinishIdSet);                
                } else {
                    IfSkipIdSet.add(serviceMap.get(serviceCode).Id);                    // Service 정보 Skip 처리 Id 저장

                    if (classDescCodeMap.get(serviceCode) != null) {
                        IfSkipIdSet.add(classDescCodeMap.get(serviceCode).Id);          // Service ClassDesc 정보 처리 Id 저장
                    }
                    
                    if (DEBUG_FLAG) ifExcuteLog.addLog('[Service]IfSkipIdSet : ' + IfSkipIdSet);
                }
            }
            if (DEBUG_FLAG) ifExcuteLog.addLog('Service 정보 처리');
            
            system.debug('### Batch_MdgBusinessController :: execute :: saveServiceList = ' + saveServiceList);

            // Service 정보 반영            
            upsert saveServiceList Code__c;
            ifExcuteLog.addLog('Service 정보 반영 완료 : ' + saveServiceList.size());

            // Solution 정보 처리
            Map<String, Id> serviceCodeMap = new Map<String, Id>();                              // Service Id Map
            List<Master_Service__c> serviceList = [  Select Id, Code__c From Master_Service__c Where Code__c IN :upServiceCodeSet  ];  // Solution의 상위 Service Id 가져오기   

            for (Master_Service__c serviceData : serviceList) {
                serviceCodeMap.put(serviceData.Code__c, serviceData.Id);
            }

            List<Master_Solution__c> saveSolutionList = new List<Master_Solution__c>();

            for (String solutionCode : solutionMap.keySet()) {           
                if (serviceCodeMap.get(solutionMap.get(solutionCode).HCLAS__c) != null) {

                    Master_Solution__c saveSolution = new Master_Solution__c();
                    Boolean useYn;

                    String strUseYn = ( solutionMap.get(solutionCode).USEYN__c + '').toUppercase();
                    if (strUseYn == 'YES' || strUseYn == 'Y') useYn = true;
                    else useYn = false;
        
                    Boolean producYn;

                    String strPrdYn = solutionMap.get(solutionCode).PRDYN__c;
                    if (strPrdYn == 'YES' || strPrdYn == 'Y') producYn = true;
                    else producYn = false;
                                            
                    saveSolution.Code__c = solutionCode;                                                                                // 솔루션 코드
                    if (classDescMap.get(solutionCode + 'K') != null) {
                        saveSolution.Name = classDescMap.get(solutionCode + 'K').KSCHL__c;                                              // 솔루션 이름 (K인 경우, K가 우선순위로 있으면 업데이트)

                        IfFinishIdSet.add(classDescMap.get(solutionCode + 'K').Id);         // Solution ClassDesc 정보 처리 Id 저장
                    } else if (classDescMap.get(solutionCode + 'E') != null) {
                        saveSolution.Name = classDescMap.get(solutionCode + 'E').KSCHL__c;                                              // 솔루션 이름 (E인 경우)

                        IfFinishIdSet.add(classDescMap.get(solutionCode + 'E').Id);         // Solution ClassDesc 정보 처리 Id 저장
                    } else {
                        if (solutionNameMap.get(solutionCode) == null) {
                            saveSolution.Name = solutionCode;
                        }
                    }
                    saveSolution.Service__c                 = serviceCodeMap.get(solutionMap.get(solutionCode).HCLAS__c);               // 서비스
                    saveSolution.ValidityStartDate__c       = Util_String.convertStringDate(solutionMap.get(solutionCode).VONDT__c);    // 유효기간(From Date)
                    saveSolution.ValidityEndDate__c         = Util_String.convertStringDate(solutionMap.get(solutionCode).BISDT__c);    // 유효기간(To date)
                    saveSolution.Use__c                     = useYn;                                                                    // 사용여부 (Yes/No)              
                    saveSolution.SolutionType__c            = solutionMap.get(solutionCode).SOLTY__c;                                   // Soution Type
                    saveSolution.Product__c                 = producYn;                                                                 // Product
                    saveSolution.SolutionManagerNo__c       = solutionMap.get(solutionCode).SOLMNC__c;                                  // 솔루션 매니저 사번
                    saveSolution.SolutionManageName__c      = solutionMap.get(solutionCode).SOLMNT__c;                                  // 솔루션 매니저 이름
                    saveSolution.SolutionDepartmentCode__c  = solutionMap.get(solutionCode).SOLDPC__c;                                  // 솔루션 부서 코드
                    saveSolution.SolutionDepartment__c      = solutionMap.get(solutionCode).SOLDPT__c;                                  // 솔루션 부서 명
                    saveSolution.CompanyCode__c             = solutionMap.get(solutionCode).COMPC__c;                                   // Company Code
                    saveSolution.PLManagementLevel__c       = solutionMap.get(solutionCode).PLLEV__c;                                   // P/L Management Level
                    saveSolution.PLCStatus__c               = solutionMap.get(solutionCode).PLCST__c;                                   // PLC Status

                    String lodat = solutionMap.get(solutionCode).LODAT__c;
                    String eopdt = solutionMap.get(solutionCode).EOPDT__c;
                    String eosdt = solutionMap.get(solutionCode).EOSDT__c;

                    if( lodat != '00000000'){   // 날짜 Null 대신 00000000로 입력
                        saveSolution.LODDate__c = Util_String.convertStringDate( lodat);    // LOD (Last Order) Date
                    }
                    if( eopdt != '00000000'){   // 날짜 Null 대신 00000000로 입력
                        saveSolution.EOPDate__c = Util_String.convertStringDate( eopdt);    // EOP(End Of Production) Date
                    }
                    if( eosdt != '00000000'){   // 날짜 Null 대신 00000000로 입력
                        saveSolution.EOSDate__c = Util_String.convertStringDate( eosdt);    // EOS(End Of Service) Date
                    }

                    saveSolutionList.add(saveSolution);
        
                    IfFinishIdSet.add(solutionMap.get(solutionCode).Id);        // Solution 정보 처리 Id 저장
                    if (DEBUG_FLAG) ifExcuteLog.addLog('[Solution]IfFinishIdSet : ' + IfFinishIdSet);                
                } else {

                    IfSkipIdSet.add(solutionMap.get(solutionCode).Id);                  // Service 정보 Skip 처리 Id 저장

                    if (classDescCodeMap.get(solutionCode) != null) {
                        IfSkipIdSet.add(classDescCodeMap.get(solutionCode).Id);         // Solution ClassDesc 정보 처리 Id 저장
                    }

                    if (DEBUG_FLAG) ifExcuteLog.addLog('[Solution]IfSkipIdSet : ' + IfSkipIdSet);                
                }
            }
            if (DEBUG_FLAG) ifExcuteLog.addLog('Solution 정보 처리');

            // Solution 정보 반영            
            upsert saveSolutionList Code__c;
            ifExcuteLog.addLog('Solution 정보 반영 완료 : ' + saveSolutionList.size());

            // ClassDesc 정보 처리
            // 위에서 처리된 ClassDesc는 제외
            for (String mapKey : classDescCodeMap.keySet()) {
                if (businessMap.get(mapKey) != null) {
                    classDescCodeMap.remove(mapKey);
                } else if (serviceMap.get(mapKey) != null) {
                    classDescCodeMap.remove(mapKey);
                } else if (solutionMap.get(mapKey) != null) {
                    classDescCodeMap.remove(mapKey);
                }
            }
        
            // ClassDesc 정보 처리 대상 중 'K'로 처리 된 내역이 있는 것은 Skip 처리 (기존 'K'로 처리 한 것을 'E'로 업데이트 하지 않기 위함)
            List<MDGBusinessMaster__c> AlreadyProcessedList = [
                Select  Id
                        , CLASS__c
                        , SPRAS__c
                        , IFType__c
                        , IFFlag__c
                From    MDGBusinessMaster__c
                Where   CLASS__c IN :classDescCodeMap.keySet()
                And     SPRAS__c = 'K'
                And     IFType__c = 'ClassDesc'
                And     IFFlag__c = 'C'
            ];
            for (MDGBusinessMaster__c data : AlreadyProcessedList) {
                IfSkipIdSet.add(data.Id);
                classDescCodeMap.remove(data.CLASS__c);
            }

            if (classDescCodeMap.size() > 0 ) {
                // ClassDesc(Business) 정보 처리 (Business 정보 없이 ClassDesc만 오는 경우 때문에 별도 처리)
                List<Business__c> classDescBusinessList = [
                    Select  Id,
                            Code__c,
                            Name
                    From    Business__c
                    Where   Code__c IN :classDescCodeMap.keySet()
                ];

                List<Business__c> saveDescBusinessList = new List<Business__c>();               

                for (Business__c businessData : classDescBusinessList) {
                    Business__c updateBusiness = new Business__c();

                    updateBusiness.Id = businessData.Id;
                    updateBusiness.Code__c = businessData.Code__c;
                    if (classDescCodeMap.get(businessData.Code__c).SPRAS__c == 'K') {
                        updateBusiness.Name = classDescCodeMap.get(businessData.Code__c).KSCHL__c;
                        IfFinishIdSet.add(classDescCodeMap.get(businessData.Code__c).Id);         // Business ClassDesc 정보 처리 Id 저장                                
                    } else if (classDescCodeMap.get(businessData.Code__c).SPRAS__c == 'E') {
                        updateBusiness.Name = classDescCodeMap.get(businessData.Code__c).KSCHL__c;

                        if (classDescMap.get(businessData.Code__c + 'K') != null) {
                            updateBusiness.Name = classDescMap.get(businessData.Code__c + 'K').KSCHL__c;
                        }
                        IfFinishIdSet.add(classDescCodeMap.get(businessData.Code__c).Id);         // Business ClassDesc 정보 처리 Id 저장                                
                    } else {
                        IfSkipIdSet.add(classDescCodeMap.get(businessData.Code__c).Id);           // Business ClassDesc 정보 Skip 처리 Id 저장                                
                    }
                    saveDescBusinessList.add(updateBusiness);
                }

                // ClassDesc(Service) 정보 처리 (Service 정보 없이 ClassDesc만 오는 경우 때문에 별도 처리)
                List<Master_Service__c> classDescServiceList = [
                    Select  Id,
                            Code__c,
                            Name
                    From    Master_Service__c
                    Where   Code__c IN :classDescCodeMap.keySet()
                ];
                
                List<Master_Service__c> saveDescServiceList = new List<Master_Service__c>();

                for (Master_Service__c serviceData : classDescServiceList) {
                    Master_Service__c updateService = new Master_Service__c();

                    updateService.Id = serviceData.Id;
                    updateService.Code__c = serviceData.Code__c;
                    if (classDescCodeMap.get(serviceData.Code__c).SPRAS__c == 'K') {
                        updateService.Name = classDescCodeMap.get(serviceData.Code__c).KSCHL__c;
                        IfFinishIdSet.add(classDescCodeMap.get(serviceData.Code__c).Id);         // Service ClassDesc 정보 처리 Id 저장                    
                    } else if (classDescCodeMap.get(serviceData.Code__c).SPRAS__c == 'E') {
                        updateService.Name = classDescCodeMap.get(serviceData.Code__c).KSCHL__c;

                        if (classDescMap.get(serviceData.Code__c + 'K') != null) {
                            updateService.Name = classDescMap.get(serviceData.Code__c + 'K').KSCHL__c;
                        }
                        IfFinishIdSet.add(classDescCodeMap.get(serviceData.Code__c).Id);         // Service ClassDesc 정보 처리 Id 저장                    
                    } else {
                        IfSkipIdSet.add(classDescCodeMap.get(serviceData.Code__c).Id);           // Service ClassDesc 정보 Skip 처리 Id 저장                    
                    }
                    saveDescServiceList.add(updateService);
                }

                // ClassDesc(Solution) 정보 처리 (Solution 정보 없이 ClassDesc만 오는 경우 때문에 별도 처리)
                List<Master_Solution__c> classDescSolutionList = [
                    Select  Id,
                            Code__c,
                            Name
                    From    Master_Solution__c
                    Where   Code__c IN :classDescCodeMap.keySet()
                ];

                List<Master_Solution__c> saveDescSolutionList = new List<Master_Solution__c>();

                for (Master_Solution__c solutionData : classDescSolutionList) {
                    Master_Solution__c updateSolution = new Master_Solution__c();

                    updateSolution.Id = solutionData.Id;
                    updateSolution.Code__c = solutionData.Code__c;
                    if (classDescCodeMap.get(solutionData.Code__c).SPRAS__c == 'K') {
                        updateSolution.Name = classDescCodeMap.get(solutionData.Code__c).KSCHL__c;
                        IfFinishIdSet.add(classDescCodeMap.get(solutionData.Code__c).Id);         // Solution ClassDesc 정보 처리 Id 저장                    
                    } else if (classDescCodeMap.get(solutionData.Code__c).SPRAS__c == 'E') {
                        updateSolution.Name = classDescCodeMap.get(solutionData.Code__c).KSCHL__c;

                        if (classDescMap.get(solutionData.Code__c + 'K') != null) {
                            updateSolution.Name = classDescMap.get(solutionData.Code__c + 'K').KSCHL__c;
                        }
                        IfFinishIdSet.add(classDescCodeMap.get(solutionData.Code__c).Id);         // Solution ClassDesc 정보 처리 Id 저장                    
                    } else {
                        IfSkipIdSet.add(classDescCodeMap.get(solutionData.Code__c).Id);           // Solution ClassDesc 정보 Skip 처리 Id 저장
                    }
                    saveDescSolutionList.add(updateSolution);
                }

                // Busness__c, Master_Service__c, Master_Solution__c에 모두 없는 ClassDesc에 대해 Skip 처리
                for (String mapKey : classDescCodeMap.keySet()) {
                    if (IfFinishIdSet.contains(classDescCodeMap.get(mapKey).Id)) {
                        classDescCodeMap.remove(mapKey);
                    }
                }
                for (String mapKey : classDescCodeMap.keySet()) {
                    IfSkipIdSet.add(classDescCodeMap.get(mapKey).Id);
                }

                if (DEBUG_FLAG) ifExcuteLog.addLog('CassDesc 정보 처리');

                // ClassDesc 정보 반영            
                upsert saveDescBusinessList Code__c;
                ifExcuteLog.addLog('Business ClassDesc 정보 반영 완료 : ' + saveDescBusinessList.size());
                upsert saveDescServiceList Code__c;
                ifExcuteLog.addLog('Service ClassDesc 정보 반영 완료 : ' + saveDescServiceList.size());
                upsert saveDescSolutionList Code__c;
                ifExcuteLog.addLog('Solution ClassDesc 정보 반영 완료 : ' + saveDescSolutionList.size());
            }
            
            // Interface Object(MDGBusinessMaster__c)의 IFFlag__c Update
            List<MDGBusinessMaster__c> updateList = new List<MDGBusinessMaster__c>();

            // 정상처리 한 경우
            List<MDGBusinessMaster__c> finishList = [   Select Id, IFFlag__c From MDGBusinessMaster__c Where Id in :IfFinishIdSet  ];
            if (DEBUG_FLAG) ifExcuteLog.addLog('정상처리 대상 갯수 : ' + finishList.size() + ' | ' + finishList);
            for (MDGBusinessMaster__c data : finishList) {
                MDGBusinessMaster__c updateData = new MDGBusinessMaster__c();

                updateData.Id = data.Id;
                updateData.IFFlag__c = 'C';
                
                updateList.add(updateData);
            }

            // Skip 처리 한 경우
            List<MDGBusinessMaster__c> skipList = [   Select Id, IFFlag__c From MDGBusinessMaster__c Where Id in :IfSkipIdSet  ];
            if (DEBUG_FLAG) ifExcuteLog.addLog('Skip한 대상 갯수 : ' + skipList.size() + ' | ' + skipList);            
            for (MDGBusinessMaster__c data : skipList) {
                MDGBusinessMaster__c updateData = new MDGBusinessMaster__c();

                updateData.Id = data.Id;
                updateData.IFFlag__c = 'S';
                
                updateList.add(updateData);
            }
            update updateList;
            ifExcuteLog.addLog('MDGBusinessMaster__c 정보 반영 완료 : ' + updateList.size());

            batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Excute', '', saveBusinessList.size() + saveServiceList.size() + saveSolutionList.size());                        
        } catch (Exception e) {
            Database.rollback(sp);
            
            ifExcuteLog.addLog('Exception : ' + e.getMessage());

            batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Excute', '', 0, 0, e);                        
        }

        ifExcuteLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 종료' + ' ####################');

        ifExcuteLog.createLog(batchExcuteLog);        
    }

    public void finish(DataBase.BatchableContext BC){

        IF_Log ifFinishLog = new IF_Log();
        IF_Log.BatchLog batchFinishLog;
        List<String> finishErrorMsgList = new List<String>();

        ifFinishLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Finish:' + BC.getJobId() + ') 시작' + ' ####################');

        batchFinishLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Finish', '', 0);

        ifFinishLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Finish:' + BC.getJobId() + ') 종료' + ' ####################');

        ifFinishLog.createLog(batchFinishLog);
    }

    // 스케줄 호출 (매일 1:00:00 AM)
    public void execute( SchedulableContext SC){

        DataBase.executeBatch( new Batch_MdgBusinessController(), 2000);
    }  
}