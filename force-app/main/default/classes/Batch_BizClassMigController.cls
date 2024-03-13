/**
* @description       : 
* @author            : kwangjin.yu@dkbmc.com
* @group             : 
* @last modified on  : 2022-01-13
* @last modified by  : kwangjin.yu@dkbmc.com
* Modifications Log 
* Ver   Date         Author                  Modification
* 1.0   2022-01-13   kwangjin.yu@dkbmc.com   Initial Version   사업분류체계 마이그레이션 프로그램.
* 설명 : Master Service/Solution 데이터가 변경됨에 따라 BO Service/Solution 데이터도 맞추어서 마이그가 필요함.
*        TO-BE Service/Solution Object 생성후 AS-IS Service/Solution 값과 매핑
*        마이그레이션 프로그램을 통해 TO-BE BO Service/Solution CSV파일을 생성함.
**/
global class Batch_BizClassMigController implements Database.StateFul,Database.Batchable<sObject>{
    
    //Execute batch
    //Set<Id> setParamOppId = new Set<Id>{'0061s000005RrPEAA0'};
    //Id batchJobId = Database.executeBatch(new Batch_BizClassMigController('유광진', setParamOppId), 200);    
    
    //Service
    //select Id, Name, BizAttribute__c, Service__c, WBSClass__c, SAP_SendTime__c, sService__c, sSalesDepartment__c, sDeliveryDepartment__c, sDeletionFlag__c from Service__c where Opportunity__c = '0061s000005RrPEAA0'
    //Solution
    //select Id, Name, Service__c, sBusinessType__c, sSolution__c, sSolutionType__c, sPSType__c from Solution__c where Opportunity__c = '0061s000005RrPEAA0'
    
    //1) Business__c / Master_Service__c / Master_Solution__c / BizAttribute__c Map을 생성.    
    //
    //select Id, Name, Opportunity__c, Solution__c, Solution__r.Name, Solution__r.Code__c from Solution__c where Opportunity__c IN ('0061s000005RrPEAA0', '0061s000005RslwAAC', '0061s000005RYK3AAO', '0061s000005Qi26AAC')
    
    
    private String strExportPrefix = 'NoName'; 	//import용  
    private String strCsvVerify = '';		//검증용 CSV
    private String strCsvService = '';		//Service용 CSV
    private String strCsvSolution = '';		//Solution용 CSV
    
    private Set<Id> setParamOppId = new Set<Id>();
    private DateTime endDateTime;
    private DateTime startDateTime;
    private Boolean isModified = false;
    
    private Map<String, MasterMap__c> mapMasterMap = new Map<String, MasterMap__c>();  		//L1, L2, L3 매핑 데이터
    //private Map<String, MasterMap__c> mapDeptMap = new Map<String, MasterMap__c>();			//Dept 매핑 데이터
    //private Map<String, MasterMap__c> mapBizAttrMap = new Map<String, MasterMap__c>();			//BizAttrMap 매핑 데이터
    
    //private Map<String, ossDataWrapper> mapAsisOssDataWrapper = new Map<String, ossDataWrapper>();	//Asis 데이터 셋
    //private Map<String, ossDataWrapper> mapTobeOssDataWrapper = new Map<String, ossDataWrapper>();  //Tobe 데이터 셋
    
    //private Map<String, Business__c> mapMasterBusiness = new Map<String, Business__c>();				//Master Business
    private Map<String, Master_Service__c> mapMasterService = new Map<String, Master_Service__c>();		//Master Service
    private Map<String, Master_Solution__c> mapMasterSolution = new Map<String, Master_Solution__c>();	//Master Solution
    //private Map<String, SvcDlvrDept__c> mapMasterDept = new Map<String, SvcDlvrDept__c>();				//Master Dept
    private Map<String, WBS__c> mapWBS = new Map<String, WBS__c>();		//검수용에 들어감.
    
    
    
    public Batch_BizClassMigController(String strExportPrefix, Set<Id> setParamOppId, String strStartDate, String strEndDate, Boolean isModified){
                
        //L1, L2, L3 매핑 데이터
        //List<MasterMap__c> listMasterMap = new List<MasterMap__c>(
        //    [SELECT Id, Name, Level__c, AsIsCode__c, ToBeCode__c, AsIsName__c, ToBeName__c, RelatedAB__c, TAFlag__c  
        //     FROM MasterMap__c WHERE Level__c IN ('L1','L2','L3')]);
        for(MasterMap__c rowMasterMap : [SELECT Id, Name, Level__c, AsIsCode__c, ToBeCode__c, AsIsName__c, ToBeName__c, RelatedAB__c, TAFlag__c  
        							     FROM MasterMap__c WHERE Level__c IN ('L2','L3')]){
            mapMasterMap.put(rowMasterMap.AsIsCode__c, rowMasterMap);
        }
        
        //Dept 매핑 데이터
        /*
        List<MasterMap__c> listDeptMap = new List<MasterMap__c>(
            [SELECT Id, Name, Level__c, AsIsCode__c, ToBeCode__c, AsIsName__c, ToBeName__c, RelatedAB__c  
             FROM MasterMap__c WHERE Level__c IN ('Dept')]);
        for(MasterMap__c rowDeptMap : listDeptMap){
            mapDeptMap.put(rowDeptMap.AsIsCode__c, rowDeptMap);
        }
		*/
        
        //BizAttr 매핑 데이터
        /*
        List<MasterMap__c> listBizAttrMap = new List<MasterMap__c>(
            [SELECT Id, Name, Level__c, AsIsCode__c, ToBeCode__c, AsIsName__c, ToBeName__c, RelatedAB__c, TAFlag__c, ToBeBizAttribute__c
             , ToBeBusinessType__c, ToBeSolution__c, ToBeWBSClass__c, ToBePSType__c  
             FROM MasterMap__c WHERE Level__c IN ('BizAttr')]);
        for(MasterMap__c rowBizAttrMap : listBizAttrMap){
            mapBizAttrMap.put(rowBizAttrMap.AsIsCode__c, rowBizAttrMap);
        }
		*/
        
        //Master Business
        /*
        List<Business__c> listMasterBusiness = [SELECT Id, Name, Code__c, Use__c FROM Business__c];
        for(Business__c rowBiz : listMasterBusiness){
            mapMasterBusiness.put(rowBiz.Code__c, rowBiz);
        }
		*/
        //Master Service
        //List<Master_Service__c> listMasterService = [SELECT Id, Name, Business__c, Code__c, ServiceBizUnitCode__c, ServiceBizUnit__c, ServiceDepartmentCode__c, ServiceDepartment__c, Use__c FROM Master_Service__c];
        for(Master_Service__c rowService : [SELECT Id, Name, Business__c, Code__c, ServiceBizUnitCode__c, ServiceBizUnit__c, ServiceDepartmentCode__c
                                            , ServiceDepartment__c, Use__c FROM Master_Service__c]){
            mapMasterService.put(rowService.Code__c, rowService);
        }
        //Master Solution
        //List<Master_Solution__c> listMasterSolution = [SELECT Id, Name, Code__c, CompanyCode__c, PLCStatus__c, PLManagementLevel__c, Product__c, Service__c, SolutionDepartmentCode__c, SolutionDepartment__c, SolutionManageName__c, SolutionManagerNo__c, SolutionType__c, Use__c FROM Master_Solution__c];
        for(Master_Solution__c rowSolution : [SELECT Id, Name, Code__c, CompanyCode__c, PLCStatus__c, PLManagementLevel__c, Product__c, Service__c
                                              , SolutionDepartmentCode__c, SolutionDepartment__c, SolutionManageName__c, SolutionManagerNo__c, SolutionType__c
                                              , Use__c FROM Master_Solution__c]){
            mapMasterSolution.put(rowSolution.Code__c, rowSolution);
        }
        //Master Dept
        /*
        List<SvcDlvrDept__c> listMasterDept = [SELECT Id, Service__c, Service__r.Code__c, DeliveryDepartment__c, DeliveryDepartment__r.CostCenter__c, DeliveryDepartment__r.Name FROM SvcDlvrDept__c];
        for(SvcDlvrDept__c rowDept : listMasterDept){
            mapMasterDept.put(rowDept.Service__r.Code__c + '_' + rowDept.DeliveryDepartment__r.CostCenter__c, rowDept);
        }
		*/
        
        if(!''.equals(strExportPrefix)){
            this.strExportPrefix = strExportPrefix;
        }
        
        system.debug('### Batch_BizClassMigController :: Constructor :: strStartDate = ' + strStartDate);
        system.debug('### Batch_BizClassMigController :: Constructor :: strEndDate = ' + strEndDate);        
        system.debug('### Batch_BizClassMigController :: Constructor :: isModified = ' + isModified);
        
        this.setParamOppId = setParamOppId;
        this.startDateTime = DateTime.valueOf(strStartDate).addHours(9);
        this.endDateTime = DateTime.valueOf(strEndDate).addHours(9);
        this.isModified = isModified;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){        
        //최대 조회 Record가 50000건을 넘지 않도록 조건 정의 필요.
        //Set<Id> setOppId = new Set<Id>{'0061s000005RrPEAA0', '0061s000005RslwAAC', '0061s000005RYK3AAO', '0061s000005Qi26AAC'};
        //마이그 대상은 2020년 이후 생성, IT(자회사 포함, 물류제외), Cleansed, Drop, Lost 제외 BO입니다. 
        //select id, CreatedDate, RecordType.Name from Opportunity where RecordType.Name <> 'Logistics' 
        //and CreatedDate > 2020-01-01T00:00:00.000+0000 and StageName not in ('Z06','Z07','Z08')  limit 10
        //
        //Z01 Identified
        //Z02 Validated
        //Z03 Qualified
        //Z04 Solutioned
        //Z05 Won
        //Z06 Lost
        //Z07 Dropped
        //Z08 Cleansed 
        DateTime dStartDateTime = this.startDateTime;
        DateTime dEndDateTime = this.endDateTime;
        Set<Id> setOppId = new Set<Id>();
        
        if(this.isModified){
            Set<Id> setModifiedOppId = new Set<Id>();
            if(setParamOppId.IsEmpty()){
                List<Service__c> listService = [SELECT Id, Opportunity__r.Id FROM Service__c WHERE LastModifiedDate >= :dStartDateTime AND LastModifiedDate <= :dEndDateTime];
                for(Service__c rowService : listService){
                    setOppId.add(rowService.Opportunity__r.Id);
                }
                List<Solution__c> listSolution = [SELECT Id, Opportunity__r.Id FROM Solution__c WHERE LastModifiedDate >= :dStartDateTime AND LastModifiedDate <= :dEndDateTime];
                for(Solution__c rowSolution : listSolution){
                    setOppId.add(rowSolution.Opportunity__r.Id);
                }
            }else{
                setOppId = setParamOppId;
            }
        }else{
            setOppId = setParamOppId;
        }
        
        
        //String query = 'SELECT Id FROM Opportunity WHERE Id = :setOppId';
        String query = ' SELECT Id, OpportunityCode__c FROM Opportunity WHERE RecordType.Name <> \'Logistics\' AND StageName NOT IN (\'Z06\',\'Z07\',\'Z08\') ';
        query += ' AND (OpportunityCode__c LIKE \'%-20%\' OR OpportunityCode__c LIKE \'%-21%\' OR OpportunityCode__c LIKE \'%-22%\') ';
        if(!setOppId.isEmpty()){
            query += ' AND Id = :setOppId ';
        }
        
        if(!this.isModified){            
            if(dStartDateTime != null){
                query += ' AND CreatedDate >= :dStartDateTime ';
            }           
            
            if(dEndDateTime != null){
                query += ' AND CreatedDate <= :dEndDateTime ';
            }
        }        
        
        query += ' ORDER BY LastModifiedDate ';
        
        system.debug('### Batch_BizClassMigController :: start :: isModified = ' + this.isModified);
        system.debug('### Batch_BizClassMigController :: start :: dStartDateTime = ' + dStartDateTime);
        system.debug('### Batch_BizClassMigController :: start :: dEndDateTime = ' + dEndDateTime);
        system.debug('### Batch_BizClassMigController :: start :: query = ' + query);        
        
        return Database.getQueryLocator(query);
    }
    
    //고려사항...
    //대량의 데이터를 변환해서 CSV 파일로 떨구어야함.
    //Record 핸들링 limit 확인.
    //CSV 파일 한번에 만들수 있는 용량확인. 복수개의 파일로 떨굴필요있음.
    //AS-IS/TO-BE 데이터 만들어야함. 박재영프로에게 보내야 하는 포맷도 필요.
    global void execute(Database.BatchableContext BC, List<Opportunity> listScope){
        //TODO 
        //1) Business__c / Master_Service__c / Master_Solution__c / BizAttribute__c Map Data 활용.
        //2) export용 Wrapper Class 생성. BO/Service/Solution 구조 가짐
        //3) BO Id 기준으로 BO Service/Solution을 조회하여 List<Wrapper> 구조 만듬.
        //4) List<Wrapper> 기준으로 
        //5) 검수용/Import용 따로 생성해야함.
        //
        Map<String, ossDataWrapper> mapAsisOssDataWrapper = new Map<String, ossDataWrapper>();	//Asis 데이터 셋
    	Map<String, ossDataWrapper> mapTobeOssDataWrapper = new Map<String, ossDataWrapper>();  //Tobe 데이터 셋
        
        system.debug('Tag 01: Heap size is ' + limits.getHeapSize() + ' enforced is ' + limits.getLimitHeapSize());
        
        system.debug('### Batch_BizClassMigController :: execute :: listScope = ' + listScope);
        Set<Id> setOppId = new Set<Id>();        
        
        for(Opportunity rowOpp : listScope){
            setOppId.add(rowOpp.Id);
        }
        /*
        List<WBS__c> listWBS = [SELECT Id, OpportunityID__c, ProjectCode__c, ProjectCodeOutput__c, Solution__c, SolutionCode__c, 
                                ServiceCode__c, ItemNumber__c, WBSLevel__c 
                                FROM WBS__c WHERE OpportunityID__c = :setOppId and Solution__c != null];
		*/
        for(WBS__c rowWBS : [SELECT Id, OpportunityID__c, ProjectCode__c, ProjectCodeOutput__c, Solution__c, SolutionCode__c, 
                                ServiceCode__c, ItemNumber__c, WBSLevel__c 
                                FROM WBS__c WHERE OpportunityID__c = :setOppId and Solution__c != null]){
            String mapKey = rowWBS.OpportunityID__c + '_' + rowWBS.ServiceCode__c + '_' + rowWBS.ItemNumber__c + '_' + rowWBS.SolutionCode__c;
            mapWBS.put(mapKey, rowWBS);
        }
		
        //List<Opportunity> listOpportunity = [SELECT Id, Name, OpportunityCode__c, CompanyCode__c FROM Opportunity WHERE Id = :setOppId];        
        for(Opportunity rowOpp : [SELECT Id, Name, OpportunityCode__c, CompanyCode__c FROM Opportunity WHERE Id = :setOppId]){
            ossDataWrapper rowOssData = new ossDataWrapper();        
            rowOssData.rowOpp = rowOpp;
            rowOssData.Services = new Map<String, ossDataWrapper.ServiceWrap>();            
            mapAsisOssDataWrapper.put(rowOpp.Id, rowOssData);
        }
        
        //system.debug('### Batch_BizClassMigController :: execute :: mapAsisOssDataWrapper = ' + mapAsisOssDataWrapper);
        /*
        List<Service__c> listService = new List<Service__c>(
            [SELECT Id, Name, Opportunity__c, ItemNumber__c, Service__c, Service__r.Name, Service__r.Code__c, sService__c
             , sService__r.Name, sService__r.Code__c, DeliveryDepartmentNmBackup__c, TechAttribute__c
             , DeliveryDepartment__c, DeliveryDepartment__r.Name, DeliveryDepartment__r.CostCenter__c
             , sDeliveryDepartment__c, sDeliveryDepartment__r.Name, sDeliveryDepartment__r.CostCenter__c
             FROM Service__c WHERE Opportunity__c = :setOppId]);
		*/
        for(Service__c rowService : [SELECT Id, Name, Opportunity__c, ItemNumber__c, Service__c, Service__r.Name, Service__r.Code__c, sService__c
                                     , sService__r.Name, sService__r.Code__c, TechAttribute__c, LastModifiedDate
                                     FROM Service__c WHERE Opportunity__c = :setOppId]){
            ossDataWrapper.ServiceWrap serviceWrap = new ossDataWrapper.ServiceWrap();
            serviceWrap.Service = rowService;
            serviceWrap.MasterServiceName = rowService.Service__r.Name == null ? '' : rowService.Service__r.Name;		//null일수 있음
            serviceWrap.MastersServiceName = rowService.sService__r.Name;            
            serviceWrap.ServiceCode = rowService.Service__r.Code__c == null ? '' : rowService.Service__r.Code__c;		//null일수 있음
            serviceWrap.sServiceCode = rowService.sService__r.Code__c;
            //serviceWrap.DlvDeptName = rowService.DeliveryDepartment__r.Name == null ? '' : rowService.DeliveryDepartment__r.Name;		//null일수 있음
            //serviceWrap.sDlvDeptName = rowService.sDeliveryDepartment__r.Name;
            //serviceWrap.DlvDeptCostCenter = rowService.DeliveryDepartment__r.CostCenter__c == null ? '' : rowService.DeliveryDepartment__r.CostCenter__c;		//null일수 있음
            //serviceWrap.sDlvDeptCostCenter = rowService.sDeliveryDepartment__r.CostCenter__c;
            
            serviceWrap.Solutions = new Map<String, ossDataWrapper.SolutionWrap>();
            mapAsisOssDataWrapper.get(rowService.Opportunity__c).Services.put(rowService.Opportunity__c + '_' + rowService.Id, serviceWrap);
        }
        
        system.debug('### Batch_BizClassMigController :: execute :: Service :: mapAsisOssDataWrapper = ' + mapAsisOssDataWrapper);
        /*
        List<Solution__c> listSolution = new List<Solution__c>(
            [SELECT Id, Name, Opportunity__c, Service__c, ItemNumber__c, Solution__c, Solution__r.Name, Solution__r.Code__c, sSolution__c, sSolution__r.Name, sSolution__r.Code__c
             , SolutionNmBackup__c, sDeletionFlag__c, SendSAP__c, SolutionType__c, BizAttribute__c, BusinessType__c, PLCStatus__c, PSType__c, sBizAttribute__c
             , sBusinessType__c, sPLCStatus__c, sPSType__c, sSolutionType__c, sWBSClass__c, BizAttributeBackup__c, Biz_Attribute_Code__c
             FROM Solution__c WHERE Opportunity__c = :setOppId]); 
		*/      
        for(Solution__c rowSolution : [SELECT Id, Name, Opportunity__c, Service__c, ItemNumber__c, Solution__c, Solution__r.Name, Solution__r.Code__c
                                       , sSolution__c, sSolution__r.Name, sSolution__r.Code__c, sDeletionFlag__c, SolutionType__c, sSolutionType__c, LastModifiedDate
                                       FROM Solution__c WHERE Opportunity__c = :setOppId]){
            ossDataWrapper.SolutionWrap solutionWrap = new ossDataWrapper.SolutionWrap();
            solutionWrap.Solution = rowSolution;
            solutionWrap.MasterSolutionName = rowSolution.Solution__r.Name == null ? '' : rowSolution.Solution__r.Name;		//null일수 있음
            solutionWrap.MastersSolutionName = rowSolution.sSolution__r.Name;
            solutionWrap.SolutionCode = rowSolution.Solution__r.Code__c == null ? '' : rowSolution.Solution__r.Code__c;		//null일수 있음
            solutionWrap.sSolutionCode = rowSolution.sSolution__r.Code__c;
            //Service Key : rowService.Opportunity__c + '_' + rowService.Id
            mapAsisOssDataWrapper.get(rowSolution.Opportunity__c).Services.get(rowSolution.Opportunity__c + '_' + rowSolution.Service__c).Solutions.put(rowSolution.Opportunity__c + '_' + rowSolution.Service__c + '_' + rowSolution.Id, solutionWrap);
        }
        //system.debug('### Batch_BizClassMigController :: execute :: mapAsisOssDataWrapper = ' + mapAsisOssDataWrapper);
        
        /*
        //AS-IS 데이터 검증 로직....        
        for(String strOppKey : mapAsisOssDataWrapper.keySet()){
            system.debug('### Batch_BizClassMigController :: execute :: mapAsisOssDataWrapper :: OppWrap = ' + mapAsisOssDataWrapper.get(strOppKey));
            for(String strServiceKey : mapAsisOssDataWrapper.get(strOppKey).Services.keySet()){
                system.debug('### Batch_BizClassMigController :: execute :: mapAsisOssDataWrapper :: ServiceWrap = ' + mapAsisOssDataWrapper.get(strOppKey).Services.get(strServiceKey));
                for(String strSolutionKey : mapAsisOssDataWrapper.get(strOppKey).Services.get(strServiceKey).Solutions.keySet()){
                    system.debug('### Batch_BizClassMigController :: execute :: mapAsisOssDataWrapper :: SolutionWrap = ' + mapAsisOssDataWrapper.get(strOppKey).Services.get(strServiceKey).Solutions.get(strSolutionKey));
                }
            }
        }
		*/        
        
        system.debug('Tag 02: Heap size is ' + limits.getHeapSize() + ' enforced is ' + limits.getLimitHeapSize());
        //전체 Deep Clone가 안됨...하나씩 Deep Clone 하기
        for(String strOppKey : mapAsisOssDataWrapper.keySet()){
            ossDataWrapper rowOssData = new ossDataWrapper();        
            rowOssData.rowOpp = mapAsisOssDataWrapper.get(strOppKey).rowOpp.clone(true, true);
            //테스트 구분 데이터
            //rowOssData.rowOpp.Name = 'Opportunity TOBE DATA';
            rowOssData.Services = new Map<String, ossDataWrapper.ServiceWrap>();            
            mapTobeOssDataWrapper.put(strOppKey, rowOssData);
            
            for(String strServiceKey : mapAsisOssDataWrapper.get(strOppKey).Services.keySet()){
                ossDataWrapper.ServiceWrap tobeServiceWrap = new ossDataWrapper.ServiceWrap();
                ossDataWrapper.ServiceWrap asisServiceWrap = mapAsisOssDataWrapper.get(strOppKey).Services.get(strServiceKey);
                    
                tobeServiceWrap.Service = asisServiceWrap.Service.clone(true, true);
                //테스트 구분 데이터
                //tobeServiceWrap.Service.DeliveryDepartmentNmBackup__c = 'Opportunity > Service TOBE DATA';                
                tobeServiceWrap.MasterServiceName = asisServiceWrap.MasterServiceName;		//null일수 있음
                tobeServiceWrap.MastersServiceName = asisServiceWrap.MastersServiceName;                
                tobeServiceWrap.ServiceCode = asisServiceWrap.ServiceCode;					//null일수 있음
                tobeServiceWrap.sServiceCode = asisServiceWrap.sServiceCode;
                //tobeServiceWrap.DlvDeptName = asisServiceWrap.DlvDeptName;					//null일수 있음
                //tobeServiceWrap.sDlvDeptName = asisServiceWrap.sDlvDeptName;
                //tobeServiceWrap.DlvDeptCostCenter = asisServiceWrap.DlvDeptCostCenter;		//null일수 있음
                //tobeServiceWrap.sDlvDeptCostCenter = asisServiceWrap.sDlvDeptCostCenter;
                
                tobeServiceWrap.Solutions = new Map<String, ossDataWrapper.SolutionWrap>();
                mapTobeOssDataWrapper.get(strOppKey).Services.put(strServiceKey, tobeServiceWrap);
                
                for(String strSolutionKey : mapAsisOssDataWrapper.get(strOppKey).Services.get(strServiceKey).Solutions.keySet()){
                    
                    ossDataWrapper.SolutionWrap tobeSolutionWrap = new ossDataWrapper.SolutionWrap();
                    ossDataWrapper.SolutionWrap asisSolutionWrap = mapAsisOssDataWrapper.get(strOppKey).Services.get(strServiceKey).Solutions.get(strSolutionKey);
                        
                    tobeSolutionWrap.Solution = asisSolutionWrap.Solution.clone(true, true);
                    //테스트 구분 데이터
                    //tobeSolutionWrap.Solution.SolutionNmBackup__c = 'Opportunity > Service > Solution TOBE DATA';
                    //null일수 있음
                    tobeSolutionWrap.MasterSolutionName = asisSolutionWrap.MasterSolutionName;
                    tobeSolutionWrap.MastersSolutionName = asisSolutionWrap.MastersSolutionName;
                    //null일수 있음
                    tobeSolutionWrap.SolutionCode = asisSolutionWrap.SolutionCode;
                    tobeSolutionWrap.sSolutionCode = asisSolutionWrap.sSolutionCode;
                    mapTobeOssDataWrapper.get(strOppKey).Services.get(strServiceKey).Solutions.put(strSolutionKey, tobeSolutionWrap);
                }
            }
        }
        
        /*
        //TO-BE 데이터 검증 로직....        
        for(String strOppKey : mapTobeOssDataWrapper.keySet()){
            //system.debug('### Batch_BizClassMigController :: execute :: mapTobeOssDataWrapper :: OppWrap = ' + mapTobeOssDataWrapper.get(strOppKey));
            system.debug('### Batch_BizClassMigController :: execute :: mapTobeOssDataWrapper :: OppWrap Id = ' + mapTobeOssDataWrapper.get(strOppKey).rowOpp.Id);
            for(String strServiceKey : mapTobeOssDataWrapper.get(strOppKey).Services.keySet()){
                //system.debug('### Batch_BizClassMigController :: execute :: mapTobeOssDataWrapper :: ServiceWrap = ' + mapTobeOssDataWrapper.get(strOppKey).Services.get(strServiceKey));
                for(String strSolutionKey : mapTobeOssDataWrapper.get(strOppKey).Services.get(strServiceKey).Solutions.keySet()){
                    //system.debug('### Batch_BizClassMigController :: execute :: mapTobeOssDataWrapper :: SolutionWrap = ' + mapTobeOssDataWrapper.get(strOppKey).Services.get(strServiceKey).Solutions.get(strSolutionKey));
                }
            }
        }
		*/
        
        
        
        system.debug('Tag 03: Heap size is ' + limits.getHeapSize() + ' enforced is ' + limits.getLimitHeapSize());
        
        system.debug('### Batch_BizClassMigController :: execute :: mapTobeOssDataWrapper = ' + mapTobeOssDataWrapper);
        //기타사항
        //DeletionFlag__c=true 이면 화면에서 제외. DeletionFlag__c인것도 모두 마이그 대상.
        //SendSAP__c는 PS와 정상적으로 동기화된 데이터
        //sService__c/sSolution__c 는 임시저장, Service__c/Solution__c는 "Create Project Code"
        //
        //현재 확인된 Mig 대상
        //임시저장 데이터는 무조건 있음(sService__c/sSolution__c). "Create Project Code"는 없을수 있음(Service__c/Solution__c)
        //Service : Service__c, sService__c
        //Solution : Solution__c, sSolution__c, BizAttribute__c(?), sBizAttribute__c(?)
        //AS-IS => TO-BE 데이터 핸들링.... 
        for(String strOppKey : mapAsisOssDataWrapper.keySet()){
            for(String strServiceKey : mapAsisOssDataWrapper.get(strOppKey).Services.keySet()){
                Boolean bMigService = false;
                //system.debug('### Batch_BizClassMigController :: execute :: @@@@111 ');
                
                for(String strSolutionKey : mapAsisOssDataWrapper.get(strOppKey).Services.get(strServiceKey).Solutions.keySet()){

                    //Solution__c을 마이그하는 로직
                    if(mapAsisOssDataWrapper.get(strOppKey).Services.get(strServiceKey).Solutions.get(strSolutionKey) != null){                        
                        
                        //######### Solution 임시 저장용 START #########
                        //변경해야할 TOBE Target Solution
                        ossDataWrapper.SolutionWrap targetSolution = mapTobeOssDataWrapper.get(strOppKey).Services.get(strServiceKey).Solutions.get(strSolutionKey);
                                                
                        //임시 저장용 무조건 있음.
                        String strAsisTempSolutionCode = mapAsisOssDataWrapper.get(strOppKey).Services.get(strServiceKey).Solutions.get(strSolutionKey).sSolutionCode;
                        //String strAsisTempBizAttrCode = mapAsisOssDataWrapper.get(strOppKey).Services.get(strServiceKey).Solutions.get(strSolutionKey).Solution.BizAttributeBackup__c;
                        
                        //임시 저장용 무조건 있음. 이건 없을수도 있음. invalid => Asis있음. Tobe없음.
                        //Asis의 Code 값이 Master Map에 존재 하지 않을경우 manual(data fix) 처리
                        MasterMap__c rowTobeTempMasterMap = mapMasterMap.get(strAsisTempSolutionCode);
                        if(rowTobeTempMasterMap != null){
                            String strTobeTempSolutionCode = rowTobeTempMasterMap.ToBeCode__c;
                            String strTobeTempL3RelatedAB = rowTobeTempMasterMap.RelatedAB__c;
                            Boolean bTobeTempL3TAFlag = rowTobeTempMasterMap.TAFlag__c;
                            
                            //임시 저장용
                            Master_Solution__c rowTobeTempMasterSolution = mapMasterSolution.get(strTobeTempSolutionCode);                            
                                
                            if('equalsAll'.equals(strTobeTempL3RelatedAB)){
                                //아무것도 할필요 없음.                            
                            }if('equalsCode'.equals(strTobeTempL3RelatedAB)){
                                //Solution Name만 변경.
                                targetSolution.MastersSolutionName = rowTobeTempMasterSolution.Name; 	//Obj 미존재, 검증용
                            }else if('newTobe'.equals(strTobeTempL3RelatedAB)){
                                //이케이스는 Asis 자체가 존재하지 않음으로 아무것도 할필요 없음.
                            }else if('invalidAsis'.equals(strTobeTempL3RelatedAB)){
                                //폐쇄 하는것임으로 아무것도 할필요 없음.
                            }else if('merge'.equals(strTobeTempL3RelatedAB)){
                                //sSolution__c, Code, Name 모두 변경.
                                targetSolution.Solution.sSolution__c = rowTobeTempMasterSolution.Id;	//Obj 존재
                                targetSolution.sSolutionCode = rowTobeTempMasterSolution.Code__c;	 	//Obj 미존재, 검증용
                                targetSolution.MastersSolutionName = rowTobeTempMasterSolution.Name; 	//Obj 미존재, 검증용
                            }
                            
                            //mapBizAttrMap
                            //system.debug('### Batch_BizClassMigController :: execute :: rowTempBizAttrMap = ' + strAsisTempSolutionCode + '_' + strAsisTempBizAttrCode);
                            /*
                            MasterMap__c rowTempBizAttrMap = mapBizAttrMap.get(strAsisTempSolutionCode + '_' + strAsisTempBizAttrCode);
                            if('merge'.equals(rowTempBizAttrMap?.RelatedAB__c)){ 
                                targetSolution.Solution.sBizAttribute__c = rowTempBizAttrMap.ToBeBizAttribute__c;
                                targetSolution.Solution.sBusinessType__c = rowTempBizAttrMap.ToBeBusinessType__c;
                                targetSolution.Solution.sPSType__c = rowTempBizAttrMap.ToBePSType__c;
                                targetSolution.Solution.sWBSClass__c = rowTempBizAttrMap.ToBeWBSClass__c;
                            }
							*/
                        }else{	//strAsisTempSolutionCode 에 해당하는 Master Map이 존재하지 않을경우
                            system.debug('### Batch_BizClassMigController :: execute :: Not Found Temp Solution Mapping Code');
                            //targetSolution.Solution.sSolution__c = '';	
                            targetSolution.sSolutionCode = '##manual(data fix)##';	 	
                            targetSolution.MastersSolutionName = '##manual(data fix)##'; 	
                        }
                        
                        
                        //######### Solution 임시 저장용 END #########
                        
                        //######### Solution IF 용  START #########
                        //IF용 없을수 있음.(검증필요). null일수 있음.
                        String strAsisSolutionCode = mapAsisOssDataWrapper.get(strOppKey).Services.get(strServiceKey).Solutions.get(strSolutionKey).SolutionCode;
                        //String strAsisBizAttrCode = mapAsisOssDataWrapper.get(strOppKey).Services.get(strServiceKey).Solutions.get(strSolutionKey).Solution.Biz_Attribute_Code__c;
                        String strTobeSolutionCode = '';
                        String strTobeL3RelatedAB = '';
                        Boolean bTobeL3TAFlag = false;
                        
                        if(String.isNotBlank(strAsisSolutionCode)){
                            ////IF용 없을수 있음. null일수 있음.
                            //Asis의 Code 값이 Master Map에 존재 하지 않을경우 manual(data fix) 처리
                        	MasterMap__c rowTobeMasterMap = mapMasterMap.get(strAsisSolutionCode);
                            if(rowTobeMasterMap != null){
                                strTobeSolutionCode = rowTobeMasterMap.ToBeCode__c;
                                strTobeL3RelatedAB = rowTobeMasterMap.RelatedAB__c;
                                bTobeL3TAFlag = rowTobeMasterMap.TAFlag__c;                               
                                    
                                //IF용
                                Master_Solution__c rowTobeMasterSolution = mapMasterSolution.get(strTobeSolutionCode);
                                
                                if('equalsAll'.equals(strTobeL3RelatedAB)){
                                    //아무것도 할필요 없음.                      
                                }if('equalsCode'.equals(strTobeL3RelatedAB)){
                                    //Solution Name만 변경.
                                    if(targetSolution.Solution.Solution__c != null){
                                        targetSolution.MasterSolutionName = rowTobeMasterSolution.Name;	//Obj 미존재, 검증용
                                    }else{
                                        targetSolution.MasterSolutionName = '';	//Obj 미존재, 검증용
                                    }
                                }else if('newTobe'.equals(strTobeL3RelatedAB)){
                                    //이케이스는 Asis 자체가 존재하지 않음으로 아무것도 할필요 없음.
                                }else if('invalidAsis'.equals(strTobeL3RelatedAB)){
                                    //폐쇄 하는것임으로 아무것도 할필요 없음.
                                }else if('merge'.equals(strTobeL3RelatedAB)){
                                    //Solution__c, Code, Name 모두 변경.
                                    if(targetSolution.Solution.Solution__c != null){
                                        targetSolution.Solution.Solution__c = rowTobeMasterSolution.Id;	//Obj 존재
                                        targetSolution.SolutionCode = rowTobeMasterSolution.Code__c;	//Obj 미존재, 검증용
                                        targetSolution.MasterSolutionName = rowTobeMasterSolution.Name;	//Obj 미존재, 검증용
                                    }else{
                                        //targetSolution.Solution.Solution__c = '';
                                        targetSolution.SolutionCode = '';	//Obj 미존재, 검증용
                                        targetSolution.MasterSolutionName = '';	//Obj 미존재, 검증용
                                    }
                                }
                                
                                //mapBizAttrMap
                                //system.debug('### Batch_BizClassMigController :: execute :: rowBizAttrMap = ' + strAsisSolutionCode + '_' + strAsisBizAttrCode);
                                /*
                                MasterMap__c rowBizAttrMap = mapBizAttrMap.get(strAsisSolutionCode + '_' + strAsisBizAttrCode);
                                if('merge'.equals(rowBizAttrMap.RelatedAB__c)){ 
                                    targetSolution.Solution.BizAttribute__c = rowBizAttrMap.ToBeBizAttribute__c;
                                    targetSolution.Solution.BusinessType__c = rowBizAttrMap.ToBeBusinessType__c;
                                    targetSolution.Solution.PSType__c = rowBizAttrMap.ToBePSType__c;
                                }	
								*/
                            }else{
                                system.debug('### Batch_BizClassMigController :: execute :: Not Found Solution Mapping Code');
                                //targetSolution.Solution.Solution__c = '';	
                                targetSolution.SolutionCode = '##manual(data fix)##';	 	
                                targetSolution.MasterSolutionName = '##manual(data fix)##'; 	
                            }						
                        }
                        //######### Solution IF 용  END #########
                        
                        //Service__c를 마이그하는 로직
                        //Soution 이후에 Service를 마이그하는 이유. 
                        //PS에서 보내준 마스터데이터는 SoutionCode를 알아야 ServiceCode 매핑이 가능함.
                        if(!bMigService){
                            
                            //system.debug('### Batch_BizClassMigController :: execute :: @@@@111111 ');
                            //######### Service 임시 저장용 START #########
                            //변경해야할 TOBE Target Service
                        	ossDataWrapper.ServiceWrap targetService = mapTobeOssDataWrapper.get(strOppKey).Services.get(strServiceKey);
                           
                            //임시 저장용 무조건 있음.
                            String strAsisTempServiceCode = mapAsisOssDataWrapper.get(strOppKey).Services.get(strServiceKey).sServiceCode;
                            
                            
                            //임시 저장용 무조건 있음. 이건 없을수도 있음. invalid => Asis있음. Tobe없음.
                            system.debug('### Batch_BizClassMigController :: equalsCode :: strAsisTempServiceCode = ' + strAsisTempServiceCode);
                            system.debug('### Batch_BizClassMigController :: equalsCode :: strAsisTempSolutionCode = ' + strAsisTempSolutionCode);
                            system.debug('### Batch_BizClassMigController :: equalsCode :: obj = ' + mapMasterMap.get(strAsisTempServiceCode + '_' + strAsisTempSolutionCode));
                            
                            //매핑조건 없을시 처리.
                            MasterMap__c rowTobeTempServiceMap = mapMasterMap.get(strAsisTempServiceCode + '_' + strAsisTempSolutionCode);
                            if(rowTobeTempServiceMap != null){
                                String strTobeTempServiceCode = rowTobeTempServiceMap.ToBeCode__c;
                                String strTobeTempServiceName = rowTobeTempServiceMap.ToBeName__c;
                                String strTobeTempL2RelatedAB = rowTobeTempServiceMap.RelatedAB__c;
                                Boolean bTobeTempL2TAFlag = rowTobeTempServiceMap.TAFlag__c;
                                
                                system.debug('### Batch_BizClassMigController :: equalsCode :: strTobeTempServiceCode = ' + strTobeTempServiceCode);
                                
                                //임시 저장용
                                //Master Service 변경이후에나 적용 가능
                                Master_Service__c rowTobeTempMasterService = mapMasterService.get(strTobeTempServiceCode);
                                
                                system.debug('### Batch_BizClassMigController :: equalsCode :: rowTobeTempMasterService = ' + rowTobeTempMasterService);
                                             
                                if('equalsAll'.equals(strTobeTempL2RelatedAB)){
                                    //TA 처리 해야함. TAFlag__c	설정하기.
                                    system.debug('### Batch_BizClassMigController :: bTobeTempL2TAFlag = ' + bTobeTempL2TAFlag);
                                    
                                    if(bTobeTempL2TAFlag){
                                        targetService.sServiceCode = '##manual##';
                                        targetService.MastersServiceName = '##manual##';
                                        targetService.Service.TechAttribute__c = bTobeTempL2TAFlag;
                                    }
                                }if('equalsCode'.equals(strTobeTempL2RelatedAB)){
                                    //Service__c, Code, Name 모두 변경.
                                    targetService.MastersServiceName = strTobeTempServiceName;	//Obj 미존재, 검증용
                                }else if('newTobe'.equals(strTobeTempL2RelatedAB)){
                                    //이케이스는 Asis 자체가 존재하지 않음으로 아무것도 할필요 없음.
                                }else if('invalidAsis'.equals(strTobeTempL2RelatedAB)){
                                    //폐쇄 하는것임으로 아무것도 할필요 없음.
                                }else if('merge'.equals(strTobeTempL2RelatedAB)){                                
                                    //sService__c
                                    targetService.Service.sService__c = rowTobeTempMasterService.Id;		//Obj 존재
                                    targetService.sServiceCode = rowTobeTempMasterService.Code__c;		//Obj 미존재, 검증용
                                    targetService.MastersServiceName = strTobeTempServiceName;	//Obj 미존재, 검증용
                                }
                                
                                //Cost Center Code   
                                /*                         
                                String strAsisTempDlvDeptCostCenter = mapAsisOssDataWrapper.get(strOppKey).Services.get(strServiceKey).sDlvDeptCostCenter;
                                system.debug('### aaa11=' + strAsisTempServiceCode + '_' + strAsisTempDlvDeptCostCenter);
                                MasterMap__c rowTempDeptMap = mapDeptMap.get(strAsisTempServiceCode + '_' + strAsisTempDlvDeptCostCenter);
                                if(rowTempDeptMap != null){
                                    String strTobeTempDlvDept = mapDeptMap.get(strAsisTempServiceCode + '_' + strAsisTempDlvDeptCostCenter).ToBeCode__c;
                                    String strTobeTempDlvDeptName = mapDeptMap.get(strAsisTempServiceCode + '_' + strAsisTempDlvDeptCostCenter).ToBeName__c; 
                                    String strTobeTempDlvRelatedAB = mapDeptMap.get(strAsisTempServiceCode + '_' + strAsisTempDlvDeptCostCenter).RelatedAB__c;
                                    if('merge'.equals(strTobeTempDlvRelatedAB)){                                
                                        //sService__c
                                        targetService.Service.sDeliveryDepartment__c = strTobeTempDlvDept;		//Obj 존재
                                        targetService.sDlvDeptName = strTobeTempDlvDeptName;		//Obj 미존재, 검증용
                                    }
                                }
								*/
                            }else{
                                targetService.sServiceCode = '##manual(data fix)##';		//Obj 미존재, 검증용
                                targetService.MastersServiceName = '##manual(data fix)##';	//Obj 미존재, 검증용
                            }
                            
                            //######### Service 임시 저장용 END #########
                            
                            
                            //######### Service IF 용  START #########
                            
                            //IF용 없을수 있음.(검증필요)                            
                            String strAsisServiceCode = mapAsisOssDataWrapper.get(strOppKey).Services.get(strServiceKey).ServiceCode;
                            
                            if(String.isNotBlank(strAsisServiceCode)){
                                ////IF용 없을수 있음.
                                MasterMap__c rowTobeServiceMap = mapMasterMap.get(strAsisServiceCode + '_' + strAsisSolutionCode);
                                if(rowTobeServiceMap != null){
                                    String strTobeServiceCode = rowTobeServiceMap.ToBeCode__c;
                                    String strTobeServiceName = rowTobeServiceMap.ToBeName__c;
                                    String strTobeL2RelatedAB = rowTobeServiceMap.RelatedAB__c;
                                    Boolean bTobeL2TAFlag = rowTobeServiceMap.TAFlag__c;
                                    
                                    //IF용
                                    Master_Service__c rowTobeMasterService = mapMasterService.get(strTobeServiceCode);                                
                                    system.debug('### Batch_BizClassMigController :: strTobeL2RelatedAB = ' + strTobeL2RelatedAB);
                                    system.debug('### Batch_BizClassMigController :: strTobeServiceName = ' + strTobeServiceName);
                                           
                                    
                                    if('equalsAll'.equals(strTobeL2RelatedAB)){
                                        //TA 처리 해야함.
                                        if(bTobeL2TAFlag){
                                            targetService.ServiceCode = '##manual##';
                                            targetService.MasterServiceName = '##manual##';
                                        }
                                    }if('equalsCode'.equals(strTobeL2RelatedAB)){
                                        //sService__c Name
                                        //targetService.MastersServiceName = rowTobeTempMasterService.Name;	//Obj 미존재, 검증용
                                        targetService.MasterServiceName = strTobeServiceName;
                                    }else if('newTobe'.equals(strTobeL2RelatedAB)){
                                        //이케이스는 Asis 자체가 존재하지 않음으로 아무것도 할필요 없음.
                                    }else if('invalidAsis'.equals(strTobeL2RelatedAB)){
                                        //폐쇄 하는것임으로 아무것도 할필요 없음.
                                    }else if('merge'.equals(strTobeL2RelatedAB)){
                                        //Service__c, Code, Name 모두 변경.
                                        if(mapAsisOssDataWrapper.get(strOppKey).Services.get(strServiceKey).Service.Service__c != null){
                                            targetService.Service.Service__c = rowTobeMasterService.Id;
                                            targetService.ServiceCode = rowTobeMasterService.Code__c;
                                            targetService.MasterServiceName = strTobeServiceName;
                                        }else{
                                            targetService.ServiceCode = '';
                                            targetService.MasterServiceName = '';
                                        }
                                    }
                                    
                                    //Cost Center Code
                                    /*
                                    String strAsisDlvDeptCostCenter = mapAsisOssDataWrapper.get(strOppKey).Services.get(strServiceKey).DlvDeptCostCenter;
                                    MasterMap__c rowDeptMap = mapDeptMap.get(strAsisServiceCode + '_' + strAsisDlvDeptCostCenter);
                                    if(rowDeptMap != null){
                                        String strTobeDlvDept = mapDeptMap.get(strAsisServiceCode + '_' + strAsisDlvDeptCostCenter).ToBeCode__c;
                                        String strTobeDlvDeptName = mapDeptMap.get(strAsisServiceCode + '_' + strAsisDlvDeptCostCenter).ToBeName__c; 
                                        String strTobeDlvRelatedAB = mapDeptMap.get(strAsisServiceCode + '_' + strAsisDlvDeptCostCenter).RelatedAB__c;
                                        if('merge'.equals(strTobeDlvRelatedAB)){                                
                                            //sService__c
                                            targetService.Service.DeliveryDepartment__c = (strTobeDlvDept == null ? '' : strTobeDlvDept);		//Obj 존재
                                            targetService.DlvDeptName = strTobeDlvDeptName;		//Obj 미존재, 검증용
                                        }
                                    }
									*/
                                }else{
                                    targetService.ServiceCode = '##manual(data fix)##';		//Obj 미존재, 검증용
                                    targetService.MasterServiceName = '##manual(data fix)##';	//Obj 미존재, 검증용
                                }                                
                            }
                            
                            //######### Service IF 용  END #########
                            
                            bMigService = true;
                        }
                    }
                }
            }
        }
        
        system.debug('Tag 04: Heap size is ' + limits.getHeapSize() + ' enforced is ' + limits.getLimitHeapSize());
        
        /*
        //TO-BE 데이터 검증 로직....   
        for(String strOppKey : mapTobeOssDataWrapper.keySet()){
            system.debug('### Batch_BizClassMigController :: finish :: mapTobeOssDataWrapper :: OppWrap = ' + mapTobeOssDataWrapper.get(strOppKey));
            
            for(String strServiceKey : mapTobeOssDataWrapper.get(strOppKey).Services.keySet()){
                system.debug('### Batch_BizClassMigController :: finish :: mapTobeOssDataWrapper :: ServiceWrap = ' + mapTobeOssDataWrapper.get(strOppKey).Services.get(strServiceKey));
                for(String strSolutionKey : mapTobeOssDataWrapper.get(strOppKey).Services.get(strServiceKey).Solutions.keySet()){
                    system.debug('### Batch_BizClassMigController :: finish :: mapTobeOssDataWrapper :: SolutionWrap = ' + mapTobeOssDataWrapper.get(strOppKey).Services.get(strServiceKey).Solutions.get(strSolutionKey));
                }
            }
        }
		*/  
        
        
        
		system.debug('############################## Batch_BizClassMigController ::  strCsvVerify DATA START ############################## ');    
        Map<String, String> mapSolType = new Map<String, String>{'10'=>'Professional Service','20'=>'H/W','30'=>'S/W','40'=>'Infra','60'=>'SaaS'};
        // ######################## 검수용 Body Data Start ########################
        //CSV Export Data  
        String csvData = '';
        for(String strOppKey : mapAsisOssDataWrapper.keySet()){
            //system.debug('### Batch_BizClassMigController :: finish :: csvData = @@@111');
            for(String strServiceKey : mapAsisOssDataWrapper.get(strOppKey).Services.keySet()){
                //system.debug('### Batch_BizClassMigController :: finish :: csvData = @@@222');
                for(String strSolutionKey : mapAsisOssDataWrapper.get(strOppKey).Services.get(strServiceKey).Solutions.keySet()){
                    //system.debug('### Batch_BizClassMigController :: finish :: csvData = @@@333');
                    
                    //Common
                    String strOppId = mapAsisOssDataWrapper.get(strOppKey).rowOpp.Id;                    
                    String strOppCode = mapAsisOssDataWrapper.get(strOppKey).rowOpp.OpportunityCode__c;
                    String strOppCompCode = mapAsisOssDataWrapper.get(strOppKey).rowOpp.CompanyCode__c;                    
                    
                    //AS-IS DATA
                    ossDataWrapper.ServiceWrap asisServiceWrap = mapAsisOssDataWrapper.get(strOppKey).Services.get(strServiceKey);
                    ossDataWrapper.SolutionWrap asisSolutionWrap = mapAsisOssDataWrapper.get(strOppKey).Services.get(strServiceKey).Solutions.get(strSolutionKey);
                    
                    String strAsisServiceId = asisServiceWrap.Service.Id;                    
                    Decimal strAsisItemNo = asisServiceWrap.Service.ItemNumber__c;                    
                    String strAsisTempSerCode = asisServiceWrap.sServiceCode;
                    String strAsisTempMasterSerName = asisServiceWrap.MastersServiceName;                    
                    String strAsisSerCode = asisServiceWrap.ServiceCode;
                    String strAsisMasterSerName = asisServiceWrap.MasterServiceName;
                    
                    String strAsisSolutionId = asisSolutionWrap.Solution.Id;                    
                    String strAsisTempSolCode = asisSolutionWrap.sSolutionCode;
                    String strAsisTempMasterSolName = asisSolutionWrap.MastersSolutionName;
                    String strAsisSolCode = asisSolutionWrap.SolutionCode;
                    String strAsisMasterSolName = asisSolutionWrap.MasterSolutionName;
                                        
                    String strAsisSolType = asisServiceWrap.Solutions.get(strSolutionKey).Solution.SolutionType__c;
                    strAsisSolType = (strAsisSolType == null ? '' : strAsisSolType);
                    String strAsisSolTypeName = (mapSolType.get(strAsisSolType) == null ? '' : mapSolType.get(strAsisSolType));
                    
                    String strWBSKey = strOppId + '_' + strAsisSerCode + '_' + strAsisItemNo + '_' + strAsisSolCode;                                       
                    String strProjectCode = (mapWBS.get(strWBSKey)?.ProjectCodeOutput__c == null ? '' : mapWBS.get(strWBSKey).ProjectCodeOutput__c);
                    
                    //TO-BE DATA
                    //Id 는 복제가 안됨으로 Asis 사용(확인필요)
                    ossDataWrapper.ServiceWrap tobeServiceWrap = mapTobeOssDataWrapper.get(strOppKey).Services.get(strServiceKey);
                    ossDataWrapper.SolutionWrap tobeSolutionWrap = mapTobeOssDataWrapper.get(strOppKey).Services.get(strServiceKey).Solutions.get(strSolutionKey);
                    
                    String strTobeServiceId = asisServiceWrap.Service.Id;
                    String strTobeTempSerCode = tobeServiceWrap.sServiceCode;
                    String strTobeTempMasterSerName = tobeServiceWrap.MastersServiceName;                    
                    String strTobeSerCode = tobeServiceWrap.ServiceCode;
                    String strTobeMasterSerName = tobeServiceWrap.MasterServiceName;
                    
                    //system.debug('### Batch_BizClassMigController :: finish :: strServiceKey = ' + strServiceKey);                    
                    Boolean bTobeTA = tobeServiceWrap.Service.TechAttribute__c;
                    String strTobeTA = (bTobeTA ? 'Y' : 'N');
                    
                    //mapTobeOssDataWrapper.get(strOppKey).Services.get(strServiceKey).Service.TechAttribute__c
                    
                    String strTobeSolutionId = asisSolutionWrap.Solution.Id;
                    String strTobeTempSolCode = tobeSolutionWrap.sSolutionCode;
                    String strTobeTempMasterSolName = tobeSolutionWrap.MastersSolutionName;
                    String strTobeSolCode = tobeSolutionWrap.SolutionCode;
                    String strTobeMasterSolName = tobeSolutionWrap.MasterSolutionName;
                    
                    //Common
                    csvData += '"' + strOppId + '","' + strOppCode + '","'  + strOppCompCode + '",';
                    //As-Is
                    csvData += '"' + strProjectCode + '","' + strAsisServiceId + '","' + strAsisItemNo + '","' + strAsisTempSerCode+ '","' + strAsisTempMasterSerName;
                    csvData += '","' + strAsisSerCode+ '","' + strAsisMasterSerName + '","' + strAsisSolutionId + '","' + strAsisTempSolCode + '","' + strAsisTempMasterSolName;
                    csvData += '","' + strAsisSolCode + '","' + strAsisMasterSolName + '","' + strAsisSolType + '","' + strAsisSolTypeName + '",';
                    //To-Be
                    csvData += '"' + strTobeServiceId + '","'  + strTobeTempSerCode +'","'  + strTobeTempMasterSerName + '","'  + strTobeSerCode +'","'  + strTobeMasterSerName;
                    csvData += '","' + strTobeTA + '","' + strTobeSolutionId + '","' + strTobeTempSolCode + '","' + strTobeTempMasterSolName +'","' + strTobeSolCode;
                    csvData += '","' + strTobeMasterSolName + '"\n';
            	}
            }
        }
        
        strCsvVerify += csvData;
        // ######################## 검수용 Body Data End ########################
        system.debug('############################## Batch_BizClassMigController ::  strCsvVerify DATA End ############################## '); 
        
        system.debug('############################## Batch_BizClassMigController ::  strCsvService DATA START ############################## '); 
        
        // ######################## Import Service Body Data Start ########################
        //CSV Export Data  
        String csvImportSerBody = '';
        for(String strOppKey : mapAsisOssDataWrapper.keySet()){
            //system.debug('### Batch_BizClassMigController :: finish :: csvData = @@@111');
            for(String strServiceKey : mapAsisOssDataWrapper.get(strOppKey).Services.keySet()){
                //system.debug('### Batch_BizClassMigController :: finish :: csvData = @@@222');
                //for(String strSolutionKey : mapAsisOssDataWrapper.get(strOppKey).Services.get(strServiceKey).Solutions.keySet()){
                    //system.debug('### Batch_BizClassMigController :: finish :: csvData = @@@333');
                                        
                    //Common
                    String strOppId = mapAsisOssDataWrapper.get(strOppKey).rowOpp.Id;
                    
                    //AS-IS DATA
                    ossDataWrapper.ServiceWrap asisServiceWrap = mapAsisOssDataWrapper.get(strOppKey).Services.get(strServiceKey);
                
                    String strAsisServiceId = asisServiceWrap.Service.Id;                    
                    Decimal strAsisItemNo = asisServiceWrap.Service.ItemNumber__c;                    
                    String strAsisTempSerCode = asisServiceWrap.sServiceCode;
                    String strAsisTempMasterSerName = asisServiceWrap.MastersServiceName;                    
                    String strAsisSerCode = asisServiceWrap.ServiceCode;
                    String strAsisMasterSerName = asisServiceWrap.MasterServiceName;
                    
                    //String strAsissDlvDept = asisServiceWrap.Service.sDeliveryDepartment__c;
                    //String strAsissDlvDeptName = asisServiceWrap.sDlvDeptName;
                    //String strAsisDlvDept = asisServiceWrap.Service.DeliveryDepartment__c;
                    //String strAsisDlvDeptName = asisServiceWrap.DlvDeptName;
                    DateTime dtAsisLastModifiedDate = asisServiceWrap.Service.LastModifiedDate;
                
                	//Cost Center Code
                    //String strAsisTempDlvDeptCostCenter = asisServiceWrap.sDlvDeptCostCenter;
                	//String strAsisDlvDeptCostCenter = asisServiceWrap.DlvDeptCostCenter;
                                        
                    //TO-BE DATA
                    ossDataWrapper.ServiceWrap tobeServiceWrap = mapTobeOssDataWrapper.get(strOppKey).Services.get(strServiceKey);
                
                    String strTobeServiceId = asisServiceWrap.Service.Id;	// Id는 Clone 안됨. Asis Id 사용.
                    Decimal strTobeItemNo = tobeServiceWrap.Service.ItemNumber__c;                    
                    String strTobeTempSerCode = tobeServiceWrap.sServiceCode;
                    String strTobeTempMasterSerName = tobeServiceWrap.MastersServiceName;          
                    String strTobeSerCode = tobeServiceWrap.ServiceCode;
                    String strTobeMasterSerName = tobeServiceWrap.MasterServiceName;
                
                	//system.debug('### Batch_BizClassMigController :: finish :: strTobesDlvDept Key = ' + strTobeTempSerCode + '_' + strAsisTempDlvDeptCostCenter);
                	//String strTobeTempDlvDept = tobeServiceWrap.Service.sDeliveryDepartment__c;
                	//String strTobeTempDlvDeptName = tobeServiceWrap.sDlvDeptName;
                	//String strTobeDlvDept = tobeServiceWrap.Service.DeliveryDepartment__c;
                	//String strTobeDlvDeptName = tobeServiceWrap.DlvDeptName;
                    
					//Import 용
                    String strImpServiceC = tobeServiceWrap.Service.Service__c;
                    strImpServiceC = (strImpServiceC == null ? '' : strImpServiceC);                    
                    String strImpsServiceC = tobeServiceWrap.Service.sService__c;
                
                	Boolean bTobeTA = tobeServiceWrap.Service.TechAttribute__c;
                    
                    //메뉴얼 입력
                    if('##manual##'.equals(strTobeSerCode)){
                        strImpServiceC = strTobeSerCode;
                    }else if('##manual(data fix)##'.equals(strTobeSerCode)){
                        strImpServiceC = strTobeSerCode;
                    }
                    if('##manual##'.equals(strTobeTempSerCode)){
                        strImpsServiceC = strTobeTempSerCode;
                    }else if('##manual(data fix)##'.equals(strTobeTempSerCode)){
                        strImpsServiceC = strTobeTempSerCode;
                    }
                   
                    //Import
                    //csvImportSerBody += '"' + strTobeServiceId + '","' + strImpServiceC + '","' + strTobeDlvDept + '","' + strImpsServiceC + '","' + strTobeTempDlvDept + '","' + bTobeTA + '",';
                    csvImportSerBody += '"' + strTobeServiceId + '","' + strImpServiceC + '","' + strImpsServiceC + '","' + bTobeTA + '",';
                    //As-Is
                    csvImportSerBody += '"' + strOppId + '","' + strAsisServiceId + '","' + strAsisItemNo + '","' + strAsisTempSerCode+ '","' + strAsisTempMasterSerName;
                	csvImportSerBody += '","' + strAsisSerCode + '","' + strAsisMasterSerName + '","' + dtAsisLastModifiedDate + '"' ;    
                	//csvImportSerBody += '","' + strAsisSerCode + '","' + strAsisMasterSerName + '","' + strAsissDlvDept + '","'  + strAsissDlvDeptName + '","'  + strAsisDlvDept;
                    //csvImportSerBody += '","'  + strAsisDlvDeptName + '",';
                    //To-Be
                    csvImportSerBody += ',"' + strTobeServiceId + '","' + strTobeItemNo + '","' + strTobeTempSerCode+ '","' + strTobeTempMasterSerName + '","' + strTobeSerCode;
                	csvImportSerBody += '","' + strTobeMasterSerName + '"\n';
                	//csvImportSerBody += '","' + strTobeMasterSerName + '","' + strTobeTempDlvDept + '","'  + strTobeTempDlvDeptName + '","'  + strTobeDlvDept + '","'  + strTobeDlvDeptName + '"\n';
            	//}
            }
        }
        // ######################## Import Service Body Data End ########################
        
        strCsvService += csvImportSerBody;
        
        system.debug('############################## Batch_BizClassMigController ::  strCsvService DATA End ############################## '); 
        
        system.debug('############################## Batch_BizClassMigController ::  strCsvSolution DATA Start ############################## '); 
        
        // ######################## Import Solution Body Data Start ########################
        //CSV Export Data  
        String csvImportSolBody = '';
        for(String strOppKey : mapAsisOssDataWrapper.keySet()){
            //system.debug('### Batch_BizClassMigController :: finish :: csvData = @@@111');
            for(String strServiceKey : mapAsisOssDataWrapper.get(strOppKey).Services.keySet()){
                //system.debug('### Batch_BizClassMigController :: finish :: csvData = @@@222');
                for(String strSolutionKey : mapAsisOssDataWrapper.get(strOppKey).Services.get(strServiceKey).Solutions.keySet()){
                    //system.debug('### Batch_BizClassMigController :: finish :: csvData = @@@333');
                                        
                    //Common
                    String strOppId = mapAsisOssDataWrapper.get(strOppKey).rowOpp.Id;
                    String strAsisServiceId = mapAsisOssDataWrapper.get(strOppKey).Services.get(strServiceKey).Service.Id;
                    
                    //AS-IS DATA 
                    ossDataWrapper.SolutionWrap asisSolutionWrap = mapAsisOssDataWrapper.get(strOppKey).Services.get(strServiceKey).Solutions.get(strSolutionKey);
                    
                    String strAsisSolutionId = asisSolutionWrap.Solution.Id;
                    String strAsisTempSolCode = asisSolutionWrap.sSolutionCode;
                    String strAsisTempMasterSolName = asisSolutionWrap.MastersSolutionName;
                    String strAsisSolCode = asisSolutionWrap.SolutionCode;
                    String strAsisMasterSolName = asisSolutionWrap.MasterSolutionName;
                    
                    
                    Decimal dAsisItemNumber = asisSolutionWrap.Solution.ItemNumber__c;    
                    //String strAsisBizAttribute = asisSolutionWrap.Solution.BizAttribute__c;
                    //String strAsisBusinessType = asisSolutionWrap.Solution.BusinessType__c;
                    //String strAsisPLCStatus = asisSolutionWrap.Solution.PLCStatus__c;
                    //String strAsisPSType = asisSolutionWrap.Solution.PSType__c;
                    //String strAsisTempBizAttribute = asisSolutionWrap.Solution.sBizAttribute__c;
                    //String strAsisTempBusinessType = asisSolutionWrap.Solution.sBusinessType__c;
                    //String strAsisTempPLCStatus = asisSolutionWrap.Solution.sPLCStatus__c;
                    //String strAsisTempPSType = asisSolutionWrap.Solution.sPSType__c;
                    //String strAsisTempSolutionType = asisSolutionWrap.Solution.sSolutionType__c;
                    //String strAsisTempWBSClass = asisSolutionWrap.Solution.sWBSClass__c;
                    DateTime dtAsisLastModifiedDate = asisSolutionWrap.Solution.LastModifiedDate;
                                     
                    //TO-BE DATA
                    ossDataWrapper.SolutionWrap tobeSolutionWrap = mapTobeOssDataWrapper.get(strOppKey).Services.get(strServiceKey).Solutions.get(strSolutionKey);
                    
                    String strTobeSolutionId = asisSolutionWrap.Solution.Id;
                    String strTobeTempSolCode = tobeSolutionWrap.sSolutionCode;
                    String strTobeTempMasterSolName = tobeSolutionWrap.MastersSolutionName;
                    String strTobeSolCode = tobeSolutionWrap.SolutionCode;
                    String strTobeMasterSolName = tobeSolutionWrap.MasterSolutionName;
                    
                    Decimal dTobeItemNumber = tobeSolutionWrap.Solution.ItemNumber__c;    
                    //String strTobeBizAttribute = tobeSolutionWrap.Solution.BizAttribute__c;
                    //String strTobeBusinessType = tobeSolutionWrap.Solution.BusinessType__c;
                    //String strTobePLCStatus = tobeSolutionWrap.Solution.PLCStatus__c;
                    //String strTobePSType = tobeSolutionWrap.Solution.PSType__c;
                    //String strTobeTempBizAttribute = tobeSolutionWrap.Solution.sBizAttribute__c;
                    //String strTobeTempBusinessType = tobeSolutionWrap.Solution.sBusinessType__c;
                    //String strTobeTempPLCStatus = tobeSolutionWrap.Solution.sPLCStatus__c;
                    //String strTobeTempPSType = tobeSolutionWrap.Solution.sPSType__c;
                    //String strTobeTempSolutionType = tobeSolutionWrap.Solution.sSolutionType__c;
                    //String strTobeTempWBSClass = tobeSolutionWrap.Solution.sWBSClass__c;
                   
                    //Import DATA
                    String strTobeSolutionC = tobeSolutionWrap.Solution.Solution__c;
                    strTobeSolutionC = (strTobeSolutionC == null ? '' : strTobeSolutionC);       
                    String strTobeTempSolutionC = tobeSolutionWrap.Solution.sSolution__c;
                     
                    //메뉴얼 입력
                    if('##manual(data fix)##'.equals(strTobeSolCode)){
                        strTobeSolutionC = '##manual(data fix)##';
                    }                    
                    if('##manual(data fix)##'.equals(strTobeTempSolCode)){
                        strTobeTempSolutionC = '##manual(data fix)##';
                    }
                    
                    //Import
                    //csvImportSolBody += '"' + strTobeSolutionId + '","' + strTobeSolutionC + '","' + strTobeBizAttribute + '","' + strTobeBusinessType + '","' + strTobePSType;
                    //csvImportSolBody += '","' + strTobeTempSolutionC + '","' + strTobeTempBizAttribute + '","' + strTobeTempBusinessType + '","' + strTobeTempPSType + '","' + strTobeTempWBSClass + '",';
                    csvImportSolBody += '"' + strTobeSolutionId + '","' + strTobeSolutionC + '","' + strTobeTempSolutionC  + '",';                    
                    
                    //As-Is  
                    csvImportSolBody += '"' + strOppId + '","' + strAsisServiceId + '","' + strAsisSolutionId + '","' + dAsisItemNumber + '","' + strAsisTempSolCode + '","' + strAsisTempMasterSolName;
                    //csvImportSolBody += '","' + strAsisTempBizAttribute + '","' + strAsisTempBusinessType + '","' + strAsisTempPLCStatus + '","' + strAsisTempPSType + '","' + strAsisTempSolutionType;
                    //csvImportSolBody += '","' + strAsisTempWBSClass + '","' + strAsisSolCode + '","' + strAsisMasterSolName + '","' + strAsisBizAttribute + '","' + strAsisBusinessType;
                    //csvImportSolBody += '","' + strAsisPLCStatus + '","' + strAsisPSType + '",';
                    csvImportSolBody += '","' + strAsisSolCode + '","' + strAsisMasterSolName + '","' + dtAsisLastModifiedDate + '",';
                    //To-Be
                    csvImportSolBody += '"' + strTobeSolutionId + '","' + dTobeItemNumber + '","' + strTobeTempSolCode + '","' + strTobeTempMasterSolName;
                    //csvImportSolBody += '","' + strTobeTempBizAttribute + '","' + strTobeTempBusinessType + '","' + strTobeTempPLCStatus + '","' + strTobeTempPSType + '","' + strTobeTempSolutionType;
                    //csvImportSolBody += '","' + strTobeTempWBSClass + '","' + strTobeSolCode + '","' + strTobeMasterSolName + '","' + strTobeBizAttribute + '","' + strTobeBusinessType;
                    //csvImportSolBody += '","' + strTobePLCStatus + '","' + strTobePSType + '"\n';
                    csvImportSolBody += '","' + strTobeSolCode + '","' + strTobeMasterSolName + '"\n';
            	}
            }
        }
        
        strCsvSolution += csvImportSolBody;
        // ######################## Import Solution Body Data End ########################
        
        system.debug('############################## Batch_BizClassMigController ::  strCsvSolution DATA End ############################## '); 
        
        system.debug('Tag 05: Heap size is ' + limits.getHeapSize() + ' enforced is ' + limits.getLimitHeapSize());
    }
    
    global void finish(Database.BatchableContext BC){
        /*
        //데이터 검증 로직....
        system.debug('############################## Batch_BizClassMigController :: finish :: mapAsisOssDataWrapper AS-IS DATA START ############################## ');
        
        //AS-IS 데이터 검증 로직....        
        for(String strOppKey : mapAsisOssDataWrapper.keySet()){
            //system.debug('### Batch_BizClassMigController :: execute :: mapAsisOssDataWrapper :: OppWrap = ' + mapAsisOssDataWrapper.get(strOppKey));
            for(String strServiceKey : mapAsisOssDataWrapper.get(strOppKey).Services.keySet()){
                //system.debug('### Batch_BizClassMigController :: execute :: mapAsisOssDataWrapper :: ServiceWrap = ' + mapAsisOssDataWrapper.get(strOppKey).Services.get(strServiceKey).sServiceCode);
                system.debug('### Batch_BizClassMigController :: execute :: mapAsisOssDataWrapper :: ServiceWrap = ' + mapAsisOssDataWrapper.get(strOppKey).Services.get(strServiceKey).MastersServiceName);
                for(String strSolutionKey : mapAsisOssDataWrapper.get(strOppKey).Services.get(strServiceKey).Solutions.keySet()){
                    //system.debug('### Batch_BizClassMigController :: execute :: mapAsisOssDataWrapper :: SolutionWrap = ' + mapAsisOssDataWrapper.get(strOppKey).Services.get(strServiceKey).Solutions.get(strSolutionKey));
                }
            }
        }
        system.debug('############################## Batch_BizClassMigController :: finish :: mapAsisOssDataWrapper TO-BE DATA END ############################## ');
        
        system.debug('############################## Batch_BizClassMigController :: finish :: mapTobeOssDataWrapper TO-BE DATA START ############################## ');
        
        //TO-BE 데이터 핸들링
        for(String strOppKey : mapTobeOssDataWrapper.keySet()){
            //system.debug('### Batch_BizClassMigController :: finish :: mapTobeOssDataWrapper :: OppWrap = ' + mapTobeOssDataWrapper.get(strOppKey));
            for(String strServiceKey : mapTobeOssDataWrapper.get(strOppKey).Services.keySet()){
                //system.debug('### Batch_BizClassMigController :: finish :: mapTobeOssDataWrapper :: ServiceWrap = ' + mapTobeOssDataWrapper.get(strOppKey).Services.get(strServiceKey).sServiceCode);
                //system.debug('### Batch_BizClassMigController :: finish :: mapTobeOssDataWrapper :: ServiceWrap = ' + mapTobeOssDataWrapper.get(strOppKey).Services.get(strServiceKey).MastersServiceName);
                for(String strSolutionKey : mapTobeOssDataWrapper.get(strOppKey).Services.get(strServiceKey).Solutions.keySet()){
                    //system.debug('### Batch_BizClassMigController :: finish :: mapTobeOssDataWrapper :: SolutionWrap = ' + mapTobeOssDataWrapper.get(strOppKey).Services.get(strServiceKey).Solutions.get(strSolutionKey));
                }
            }
        }
        */
        
        
        system.debug('############################## Batch_BizClassMigController :: finish :: mapTobeOssDataWrapper TO-BE DATA END ############################## ');
		//CSV Export Header  
		// ######################## 검수용 Header Start ########################
        String csvDataHeader = '"","","","As-Is","","","","","","","","","","","","","","To-Be","","","","","","","","","",""\n';
        csvDataHeader += '"OpportunityId","Opportunity Code","Company Code"'; 
        //AS-IS
        csvDataHeader += ',"Project Code","ServiceId","Item Number","(임시)Service Code","(임시)Service Name","Service Code","Service Name","SolutionId"';
        csvDataHeader += ',"(임시)Solution Code","(임시)Solution Name","Solution Code","Solution Name","Solution Type Code","Solution Type"'; 
        //TO-BE
        csvDataHeader += ',"ServiceId","(임시)Service Code","(임시)Service Name","Service Code","Service Name","TA여부(Y/N)","SolutionId","(임시)Solution Code"';
        csvDataHeader += ',"(임시)Solution Name","Solution Code","Solution Name"\n'; 
        // ######################## 검수용 Header End ########################
        
        system.debug('Tag 06: Heap size is ' + limits.getHeapSize() + ' enforced is ' + limits.getLimitHeapSize());
        //system.debug('### Batch_BizClassMigController :: finish :: csvData = ' + csvData);
        
        Set<Id> setCDId = new Set<Id>();
        
        DateTime dtNow = system.now().addHours(9);  
        Account rowAccount = [SELECT Id FROM Account WHERE Name = 'Batch_BizClassMigController_0214'];
        
        List<ContentDocumentLink> listCDL = 
            [SELECT Id, LinkedEntityId, ContentDocumentId
             FROM ContentDocumentLink WHERE LinkedEntityId =: rowAccount.Id];
        
        for(ContentDocumentLink rowCDL : listCDL){
            setCDId.add(rowCDL.ContentDocumentId);
        }
       
        List<ContentDocument> listCD = [SELECT Id, LatestPublishedVersionId FROM ContentDocument WHERE Id = :setCDId AND OwnerId = :UserInfo.getUserId() ];
        delete listCD;
        
        ContentVersion cv = new ContentVersion();
        cv.Title = '('+ strExportPrefix+')(검수용)BizMig_' + dtNow;
        cv.PathOnClient = '('+ strExportPrefix+')(검수용)BizMig_' + dtNow + '.csv';
        //UTF-8 Encode : '\uFEFF'
        cv.VersionData = Blob.valueOf('\uFEFF' + csvDataHeader + strCsvVerify);
        cv.IsMajorVersion = true;
        insert cv;
        
        //Get Content Document Id
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        
        //Create ContentDocumentLink 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = rowAccount.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        insert cdl;
        
        //CSV Export Header  
		// ######################## Import Service Header Start ########################
        //String csvImportSerHeader = '"Import Service","","","","As-Is","","","","","","","","","","","To-Be","","","","","","","","",""\n';
        String csvImportSerHeader = '"Import Service","","","","As-Is","","","","","","","","To-Be","","","","",""\n';
        //Import
        //csvImportSerHeader += '"Id","Service__c","DeliveryDepartment__c","sService__c","sDeliveryDepartment__c","TechAttribute__c",';
        csvImportSerHeader += '"Id","Service__c","sService__c","TechAttribute__c",';
        //AS-IS
        //csvImportSerHeader += '"OpportunityId","ServiceId","Item Number","(임시)Service Code","(임시)Service Name","Service Code","Service Name","(임시)DeliveryDepartment Id"';
        //csvImportSerHeader += ',"(임시)DeliveryDepartment Name","DeliveryDepartment Id","DeliveryDepartment Name",'; 
        csvImportSerHeader += '"OpportunityId","ServiceId","Item Number","(임시)Service Code","(임시)Service Name","Service Code","Service Name","LastModifiedDate"';
        //TO-BE
        csvImportSerHeader += ',"ServiceId","Item Number","(임시)Service Code","(임시)Service Name","Service Code","Service Name"\n';
		//csvImportSerHeader += ',"ServiceId","Item Number","(임시)Service Code","(임시)Service Name","Service Code","Service Name","(임시)DeliveryDepartment Id"';
        //csvImportSerHeader += ',"(임시)DeliveryDepartment Name","DeliveryDepartment Id","DeliveryDepartment Name"\n';
        // ######################## Import Service Header End ########################
        
        
        system.debug('Tag 07: Heap size is ' + limits.getHeapSize() + ' enforced is ' + limits.getLimitHeapSize());
        ContentVersion cv2 = new ContentVersion();
        cv2.Title = '('+ strExportPrefix+')(Import용)(Service)BizMig_' + dtNow;
        cv2.PathOnClient = '('+ strExportPrefix+')(Import용)(Service)BizMig_' + dtNow + '.csv';
        //UTF-8 Encode : '\uFEFF'
        cv2.VersionData = Blob.valueOf('\uFEFF' + csvImportSerHeader + strCsvService);
        cv2.IsMajorVersion = true;
        insert cv2;
        
        //Get Content Document Id
        Id conDocId2 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv2.Id].ContentDocumentId;
        
        //Create ContentDocumentLink 
        ContentDocumentLink cdl2 = New ContentDocumentLink();
        cdl2.LinkedEntityId = rowAccount.Id;
        cdl2.ContentDocumentId = conDocId2;
        cdl2.shareType = 'V';
        insert cdl2;         
        
        //CSV Export Header  
		// ######################## Import Solution Header Start ########################
        String csvImportSolHeader = '"Import Solution","","","As-Is","","","","","","","","","To-Be","","","","",""\n';
        //Import
        //csvImportSolHeader += '"Id","Solution__c","BizAttribute__c","BusinessType__c","PSType__c","sSolution__c","sBizAttribute__c","sBusinessType__c","sPSType__c","sWBSClass__c"';
        csvImportSolHeader += '"Id","Solution__c","sSolution__c"';
        //AS-IS
        csvImportSolHeader += ',"OpportunityId","ServiceId","SolutionId","ItemNumber","(임시)Solution Code","(임시)Solution Name"'; 
        //csvImportSolHeader += ',"(임시)BizAttribute","(임시)BusinessType","(임시)PLCStatus","(임시)PSType","(임시)SolutionType","(임시)WBSClass"'; 
        //csvImportSolHeader += ',"Solution Code","Solution Name","BizAttribute__c","BusinessType__c","PLCStatus__c","PSType__c",'; 
        csvImportSolHeader += ',"Solution Code","Solution Name","LastModifiedDate",'; 
		//TO-BE
        csvImportSolHeader += '"SolutionId","ItemNumber","(임시)Solution Code","(임시)Solution Name"';
        //csvImportSolHeader += ',"(임시)BizAttribute","(임시)BusinessType","(임시)PLCStatus","(임시)PSType","(임시)SolutionType","(임시)WBSClass"'; 
        //csvImportSolHeader += ',"Solution Code","Solution Name","BizAttribute__c","BusinessType__c","PLCStatus__c","PSType__c"\n';
        csvImportSolHeader += ',"Solution Code","Solution Name"\n';    
        // ######################## Import Solution Header End ########################
        
        
        
        ContentVersion cv3 = new ContentVersion();
        cv3.Title = '('+ strExportPrefix+')(Import용)(Solution)BizMig_' + dtNow;
        cv3.PathOnClient = '('+ strExportPrefix+')(Import용)(Solution)BizMig_' + dtNow + '.csv';
        //UTF-8 Encode : '\uFEFF'
        cv3.VersionData = Blob.valueOf('\uFEFF' + csvImportSolHeader + strCsvSolution);
        cv3.IsMajorVersion = true;
        insert cv3;
        
        //Get Content Document Id
        Id conDocId3 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv3.Id].ContentDocumentId;
        
        //Create ContentDocumentLink 
        ContentDocumentLink cdl3 = New ContentDocumentLink();
        cdl3.LinkedEntityId = rowAccount.Id;
        cdl3.ContentDocumentId = conDocId3;
        cdl3.shareType = 'V';
        insert cdl3;
        system.debug('Tag 08: Heap size is ' + limits.getHeapSize() + ' enforced is ' + limits.getLimitHeapSize());
       
    }    
}