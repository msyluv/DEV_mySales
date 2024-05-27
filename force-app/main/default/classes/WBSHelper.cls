/**
 * @description       : 
 * @author            : seonju.jin@dkbmc.com
 * @group             : 
 * @last modified on  : 05-08-2024
 * @last modified by  : chae_ho.yang@samsung.com
 * Modifications Log 
 * Ver   Date         Author                 	Modification
 * 1.0   2021-07-16   seonju.jin@dkbmc.com   	Initial Version
 * 1.1   2023-12-08   vikrant.ks@samsung.com 	Changed the value assignment logic of "GUBUN" field(MySales-378)
 * 1.2   2024-05-08   chae_ho.yang@samsung.com  MYSALES-523 Miracom getGubun modification
**/
public class WBSHelper {
    //WBS Code Level
    private final String LEVEL_1 = '1';     // Project
    private final String LEVEL_2 = '2';     // WBS Service Code
    private final String LEVEL_3 = '3';     // WBS Soltuion Code

    //Project Code Type
    private final String PJT_TYPE_BIZ_PLAN = 'Business Plan';
    private final String PJT_TYPE_EXE_PJT = 'Execute Project';
    private final String PJT_TYPE_SALES_PJT = 'Sales Project';
    private final String PJT_TYPE_OTHER_PJT = 'Other Project';

    private List<WBS__c> wbsList;                               // WBS__c List
    private Map<String,List<String>> wbsCodeMap;                // Key: SERVICE_WBS , values: SOLUITION_WBS LIST
    private Map<String,Master_Solution__c> masterSolutionMap;   // key: SolutionCode, value: Master_Solution__c
    private Map<String,SvcSolBizAttr__c> svcSolBizMap;          // key: SolutionCode_AttributeCode, value: SvcSolBizAttr__c
    private String companyCode;                                 // Opportunity companyCode
    List<SvcSolBizAttr__c> lsolBizAttr;                         //

    private static WBSHelper instance;

    /**
    * @description Opportunity에 관련된 WBS정보 획득
    * constructor에서 soql 쿼리 사용. For문에서 사용 x
    * @author seonju.jin@dkbmc.com | 2021-07-19 
    * @param Id opptyId 
    **/
    public static WBSHelper getInstance(Id opptyId, String companyCode){
        return instance == null? new WBSHelper(opptyId, companyCode) : instance;
    }

    private WBSHelper(Id opptyId, String companyCode){
        //required ORDER BY Name, WBSLevel__c
        this.wbsList = [SELECT Id, Name, ProjectCode__c, WBSLevel__c, SolutionCode__c, ServiceCode__c, ItemNumberInt__c, WBSClass__c, DeletionFlag__c, Project__r.ProjectType__c , BizAttribCode__c, OpportunityID__r.CompanyCode__c 
                         FROM WBS__c 
                        WHERE OpportunityID__c =: opptyId AND ItemNumberInt__c != 0 
                          AND Project__r.ProjectType__c = :PJT_TYPE_EXE_PJT   //C코드만 조회
                        ORDER BY Name, WBSLevel__c];

        this.companyCode = companyCode;
        initCodeMap();  //wbsCodeMap, masterSolutionMap, svcSolBizMap 초기화
    }

    /**
    * @description wbsCodeMap, masterSolutionMap, svcSolBizMap 초기화
    * @author seonju.jin@dkbmc.com | 2021-07-21 
    **/
    private void initCodeMap(){
        wbsCodeMap = new Map<String,List<String>>();
        List<String> solWbsList = new List<String>();
        Set<String> solCodeSet = new Set<String>();
        Set<String> bizCodeSet = new Set<String>();
        String ServiceCodekey = '';                        //Service WBS
        Integer i = 0;
        for(WBS__c wbs: wbsList){
            String level = wbs.WBSLevel__c;     // '2': Service WBS , '3': Solution WBS
            if(level == LEVEL_2){               //LEVEL 2(Service WBS)
                if(ServiceCodekey != '') wbsCodeMap.put(ServiceCodekey,solWbsList);
                
                solWbsList = new List<String>();
                ServiceCodekey = wbs.Name;
            }else{                              //LEVEL 3(Solution WBS)
                solWbsList.add(wbs.Name);

                solCodeSet.add(wbs.SolutionCode__c);
                bizCodeSet.add(wbs.BizAttribCode__c);
            }

            i++;
            if(i == wbslist.size()){
                wbsCodeMap.put(ServiceCodekey,solWbsList);
            }
        }

        this.masterSolutionMap = getMasterSolutionCodeMap(solCodeSet);   //set Maseter Solution Info map
        this.svcSolBizMap = getSvcSolBizMap(solCodeSet, bizCodeSet);     //set SvcSolBizAttr Info map
    }

    /**
    * @description 서비스에 솔루션을 추가하는 경우 사용가능한 서비스코드 조회
    * @author seonju.jin@dkbmc.com | 2022-01-06 
    * @param Solution__c sol 필수필드: sWBSClass__c, Service__r.sService__r.Code__c, ItemNumber__c, sSolutionType__c
    * @return String 
    **/
    public String getServicCode(Solution__c sol){
        String serviceWBS = '';
        
        String sol_wbsClass = sol.sWBSClass__c;                         // wbsclass
        String sol_serviceCode = sol.Service__r.sService__r.Code__c;    // 서비스 코드
        Integer sol_itemNUmber = sol.ItemNumber__c.intValue();
        
        for(WBS__c wbs: wbsList){
            String level        = wbs.WBSLevel__c;                  // '2': Service WBS , '3': Solution WBS
            String wbsClass     = wbs.WBSClass__c;                  // SI / SC / SM
            String wbsCode      = wbs.Name;                         // WBS Code
            Boolean deleted     = (wbs.DeletionFlag__c == 'Y') ? true : false;

            if(wbs.ItemNumberInt__c == null) continue;
            Integer itemNumber = wbs.ItemNumberInt__c.intValue();
            
            if(level != LEVEL_2) continue;                          //WBS Level 2만 검색
            if(deleted) continue;
            
            Map<String,Object> validateMap;
            Boolean findSvcCode = (itemNumber == sol_itemNUmber && sol_wbsClass == wbsClass && wbs.ServiceCode__c == sol_serviceCode);

            if(findSvcCode){
                validateMap = checkCodeValidate(sol,wbsCode);
                if(!(Boolean)validateMap.get('availableCode')){
                    if((Integer)validateMap.get('createdGubun1') >= 3) {
                        System.debug(wbsCode +'- GUBUN 1로 11,21,31 WBSCode 생성됨.');
                        continue;//GUBUN 1로 11,21,31 생성되어 더이상 솔루션을 추가할 수 없으므로 빈값 반환하기 위해 continue처리.
                    }
    
                    if((Boolean)validateMap.get('hasLimit')){
                        System.debug(wbsCode +'- can not use this code. code limit');
                        continue;//사용가능한 코드가 아닌경우 더이상 솔루션을 추가할 수 없으므로 빈값 반환하기 위해 continue처리.
                    }
                }
            }
            if(validateMap == null) continue;

            serviceWBS = wbsCode;
            if(String.isNotBlank(serviceWBS)) break;
        }

        System.debug('serviceWBS:' + serviceWBS);
        return serviceWBS;
    }

    /**
    * @description 솔루션 추가 시 3level 수준의 wbs 기준으로 중복되는 정보가 있는지 조회. 중복되면 솔루션 추가 불가능함.
    * @author seonju.jin@dkbmc.com | 2021-07-20 
    * @param Solution__c sol 
    * @return Boolean True: 중복
    **/
    public Boolean checkDuplicateWBS(Solution__c sol, Integer itemNumber){
        //WBS가 삭제된 것 중 ItemNumber, 사업유형(SoutionType), PSType, 수익인식기준(WBSClass)가 동일하면 프로젝트 생성 불가
        Boolean duplCheck = false;
        for(WBS__c wbs: wbsList){
            SvcSolBizAttr__c wbsSolBizAttr = svcSolBizMap.get(wbs.SolutionCode__c + '_' + wbs.BizAttribCode__c);
            System.debug(wbsSolBizAttr);

            if(wbsSolBizAttr == null) continue;
            if(wbs.WBSLevel__c != LEVEL_3) continue;
            if(wbs.DeletionFlag__c != 'Y') continue;

            if(wbs.ItemNumberInt__c.intValue() == itemNumber && masterSolutionMap.get(wbs.SolutionCode__c).Id == sol.sSolution__c && wbs.WBSClass__c == sol.sWBSClass__c){
                duplCheck = (sol.sPSType__c == wbsSolBizAttr.PSType__c && sol.sBusinessType__c == wbsSolBizAttr.BusinessType__c);
            }
        }

        system.debug('duplCheck:' + duplCheck);
        return duplCheck;
    }

    /**
    * @description WBSCode가 사용가능한지 유효성 체크
    * @author seonju.jin@dkbmc.com | 2021-07-21 
    * @param Solution__c sol 
    * @param String wbsCode 
    * @return Map<String, Object> 
    **/
    private Map<String,Object> checkCodeValidate(Solution__c sol, String wbsCode){
        /**
         * 1) 이미 11, 21, 31로 생성되어있는 ServiceCode가 있으면 GUBUN 1로 더이상 추가할 수 없음. (GUBUN 1)
         * 2) 22, 23, 24 ... 로 생성되어있는 경우 코드는 22~29까지 생성가능함 (GUBUN 2)
         * 3) 32, 33, 34 ... 로 생성되어있는 경우 코드는 22~29까지 생성가능함 (GUBUN 4)
        */
        Map<String,Object> returnMap = new Map<String,Object>{
            'createdGubun1' => 0,       // Gubun1인 경우 구성된 11,21,31로 구성되어있는지 Count(11,21,31로 구성되어 값이 3이면 해당 코드는 더 이상 사용 불가)
            'hasLimit' => false,        // Gubun2, 4인 경우 코드 22~29 / 32~39 까지 생성 체크 
            'availableCode' => false
        };

        Integer createdGubun1 = 0;
        Boolean hasLimit = false;
        String sol_gubun = getGubun(sol.sSolutionType__c, companyCode, sol);   //솔루션 타입 구분 (1,2,4)
        Integer createdWbsLimit = 0;                //WBSCode 생성 limit

        if(sol_gubun == '2'){ createdWbsLimit = 29;}
        else if(sol_gubun == '3' || sol_gubun == '4'){ createdWbsLimit = 39;}

        //검색된 WBSCode가 사용할 수 있는 코드인지 유효성 확인
        //1) GUBUN이 1일때만체크- WBSCode 하위의 3레벨 WBSCode가 11,21,31이 생성되어있는경우 사용x
        for(String solWbsCode: wbsCodeMap.get(wbsCode)){
            if(sol_gubun == '1'){
                //GUBUN '1'로 생성된 3레벨 WBSCode
                //31 단일로 생성되는 경우가 있어 11,21,31코드 모두 체크하도록함.
                if(solWbsCode.right(2) == '11') createdGubun1++;
                else if(solWbsCode.right(2) == '21') createdGubun1++;
                else if(solWbsCode.right(2) == '31') createdGubun1++;
            }else{
                // 2) 22, 23, 24 ... 로 생성되어있는 경우 코드는 22~29까지 생성가능함 (GUBUN 2)
                // 3) 32, 33, 34 ... 로 생성되어있는 경우 코드는 32~39까지 생성가능함 (GUBUN 3,4)
                if(Integer.valueOf(solWbsCode.right(2)) == createdWbsLimit){
                    hasLimit = true;
                    break;
                }
            }
        }

        returnMap.put('createdGubun1', createdGubun1);
        returnMap.put('hasLimit', hasLimit);
        returnMap.put('availableCode', ((createdGubun1 < 3 && !hasLimit) ? true : false));
        return returnMap;
    }

    // public Map<String,String> getSolWBSCodeMap(){
    //     Map<String,String> solWBSCodeMap = new Map<String,String>();
    //     for(WBS__c wbs: this.wbsList){
    //         String wbsCode = wbs.Name;
    //         if(String.isBlank(wbsCode)) continue;
    //         if(wbsCode.length() != 17) continue;
    //         if(wbs.WBSLevel__c != LEVEL_3) continue;
    //         if(wbs.DeletionFlag__c == 'Y') continue;    //삭제된 WBSCode 제외
    //         if(wbsCode.right(2) == '21' || wbsCode.right(2) == '31') continue;  // 인터페이스 연계 시, wbscode는 끝자리가 11인 코드만 사용함
    //         if(String.isBlank(wbs.SolutionCode__c)) continue;

    //         System.debug(wbs.Name);

    //         //NUMBER_INT, servicecode, solutioncode, bizcode, wbsclass
    //         solWBSCodeMap.put(wbs.ItemNumberInt__c.intValue() + wbs.ServiceCode__c + wbs.SolutionCode__c + wbs.BizAttribCode__c + wbs.WBSClass__c, wbs.Name);
    //     }

    //     return solWBSCodeMap;
    // }

    /**
    * @description Solution코드를 기준으로 Master Solution 정보를 조회
    * @author seonju.jin@dkbmc.com | 2021-07-16 
    * @param Set<String> solCodeSet 솔루션 코드 Set
    * @return Map<String, Master_Solution__c>
    **/
    private Map<String,Master_Solution__c> getMasterSolutionCodeMap(Set<String> solCodeSet){
        Map<String,Master_Solution__c> masterSolutionMap = new Map<String,Master_Solution__c>();    //key: SolutionCode

        List<Master_Solution__c> masterSolList = [SELECT Id, Name,Code__c, SolutionType__c FROM Master_Solution__c WHERE Use__c = true AND Code__c IN :solCodeSet];
        Set<Id> solutionIdSet = new Set<Id>();

        for(Master_Solution__c masterSol : masterSolList){
            solutionIdSet.add(masterSol.Id);
            masterSolutionMap.put(masterSol.Code__c, masterSol);
        }

        return masterSolutionMap;
    }

    public List<WBS__c> getWBSList(){
        return this.wbsList;
    }

    /**
    * @description SolutionCode, BizAttributeCode를 기준으로 SvcSolBizAatr정보 조회
    * @author seonju.jin@dkbmc.com | 2021-07-20 
    * @param Set<String> solbizString 
    * @return Map<String, SvcSolBizAttr__c> 
    **/
    private Map<String,SvcSolBizAttr__c> getSvcSolBizMap(Set<String> solCodeSet , Set<String> bizCodeSet){
        Map<String,SvcSolBizAttr__c> returnMap = new Map<String,SvcSolBizAttr__c>();
        List<SvcSolBizAttr__c> solBizList = [SELECT Id, Solution__c, Solution__r.Code__c, BizAttribute__c, BizAttribute__r.Code__c, PSType__c, BusinessType__c FROM SvcSolBizAttr__c WHERE Use__c = true
                                                AND Solution__r.Code__c IN :solCodeSet AND BizAttribute__r.Code__c IN :bizCodeSet
                                            ];

        for(SvcSolBizAttr__c solBizAttr : solBizList){
            if(solBizAttr.Solution__r.Code__c != null && solBizAttr.BizAttribute__r.Code__c != null){
                returnMap.put(solBizAttr.Solution__r.Code__c + '_' + solBizAttr.BizAttribute__r.Code__c, solBizAttr);
            }
        }

        return returnMap;
    }

    public static String getGubun(String solutionType, String companyCode, Solution__c solution){ //v1.2 solution added
        if(String.isBlank(solutionType)) return '';

        String gubun = '';
        List<String> miracomExceptionalSol = new List<String>{'32000004', '32000005'};
        system.debug('CHLOG ::: solcode : ' + solution.sSolution__r.Code__c);
        Boolean isMiracom = false;
        for (String s : miracomExceptionalSol) {
            if (solution.sSolution__r.Code__c.equals(s)) isMiracom = true;
        }
        system.debug('CHLOG ::: isMiracom : ' + isMiracom);
        switch on solutionType {
            when '10' { //Professinal Service
                gubun = '1';
            }
            when '20' { //H/W
                gubun = '2';
            }
            when '30' { //S/W
                if(companyCode == 'T140' && isMiracom) { gubun = '4'; } //V1.2 Added miracom condition
                else {
                    if(companyCode == 'T100' || companyCode == 'T170') gubun = '4'; //V1.1 Added T170 condition
                    else gubun = '3';
                }
            }
            when '60' { //Saas
                if(companyCode == 'T140' && isMiracom) { gubun = '4'; } //V1.2 Added miracom condition
                else {
                    if(companyCode == 'T100' || companyCode == 'T170') gubun = '4'; //V1.1 Added T170 condition
                    else gubun = '3';
                }
            }
            when else{
                gubun ='4';
            }
        }

        system.debug('CHLOG ::: getGubun : ' + gubun);
        return gubun;
    }
}