/**
 * @description       : 
 * @author            : seonju.jin@dkbmc.com
 * @group             : 
 * @last modified on  : 2022-02-07
 * @last modified by  : seonju.jin@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                 Modification
 * 1.0   2020-11-19   seonju.jin@dkbmc.com   Initial Version
 * 1.1   2023-08-02   divyam.gupta@samsung.com  Mysales-267 Add validation logic for changing solution
**/
public without sharing class OpportunitySolutionItemController {
    
    @AuraEnabled
    public static List<Options> getSolutionOptions(String serviceId, String boId, String collaboBoId, Boolean isHQ, Boolean isCollaboration, Boolean getAllTA){
        List<Options> loptions = new List<Options>();
        Set<Options> setOptions = new set<Options>();
        List<Master_Solution__c> masterSolList;
        /**
         * companyCode가 본사이고 법인과 협업인 경우
         * 법인이 선택한 솔루션 pickvalue만 나와야한다.
         */
        List<Map<String,String>> lmap = Utils.getPicklistOptionType('Master_Solution__c', 'SolutionType__c');
        List<Map<String,String>> PLCMap = Utils.getPicklistOptionType('Master_Solution__c', 'PLCStatus__c');
        Set<Id> solIdSet = new Set<Id>();

        Date today = System.today();
        String queryStr= 'SELECT Id, Name, SolutionType__c, toLabel(PLCStatus__c), Service__c FROM Master_Solution__c WHERE Use__c = true AND (ValidityStartDate__c  < :today AND ValidityEndDate__c  > :today)';
        if(isHQ && isCollaboration){
            Set<Id> boIdSet = new Set<Id>();
            boIdSet.add(boId);
            boIdSet.add(collaboBoId);

            List<Solution__c> lsolution = [SELECT Id, Solution__c, sSolution__c FROM Solution__c 
                                            WHERE Service__r.Opportunity__c =: boIdSet ORDER BY Solution__r.Name];
            
            for(Solution__c sol : lsolution){
                solIdSet.add(sol.Solution__c);
                solIdSet.add(sol.sSolution__c);
            }
        }

        if(solIdSet.size() > 0) queryStr += ' AND Id IN :solIdSet';
        if(getAllTA){
            queryStr += ' AND Service__r.TechAttribute__c = true';
        } else{
            queryStr += ' AND Service__c = :serviceId';
        }
        
        System.debug('queryStr:' + queryStr);
        masterSolList = Database.query(queryStr);
        Set<String> solutionNameSet = new Set<String>();
        for(Master_Solution__c masterSol : masterSolList){
            
            Options opts = new Options();
            opts.Id = masterSol.Id;
            opts.Name = masterSol.Name;
            opts.Code = masterSol.SolutionType__c;
            opts.parentId = masterSol.Service__c;
            String codeNm = '';
            
            for(Map<String,String> map1 : lmap){
                if(map1.get('value') == masterSol.SolutionType__c){
                    codeNm = map1.get('label');
                    break;
                } 
            }
            Map<String,String> otherCodeMap = new Map<String,String>();
            otherCodeMap.put('PLCStatus',masterSol.PLCStatus__c );

            opts.CodeNm = codeNm;
            opts.otherCode = otherCodeMap;

            if(solutionNameSet.contains(opts.Name)) continue;   //중복옵션 continue
            
            solutionNameSet.add(opts.Name);
            loptions.add(opts);
        }

        return loptions;
    }

    @AuraEnabled
    public static Boolean professionalServiceCheck(Id opptyId, Integer itemNumber){
        System.debug('opptyId:' + opptyId);
        System.debug('itemNumber:' + itemNumber);
        List<Solution__c> solList = [SELECT Id, Name FROM Solution__c WHERE Opportunity__c =:opptyId and SendSAP__c = true AND ItemNumber__c =:itemNumber AND Solution__r.SolutionType__c = '10'];
        return (solList.size() == 0) ? true : false;
    }
    
    /** 
    * @description 솔루션과 관련된 BizAttribute 리스트 조회
    * @author seonju.jin@dkbmc.com | 2021-09-09 
    * @param List<String> solIdList     솔루션 룩업 Id List
    * @param Boolean solChangeCheck        화면에서 솔루션 변경시에만 체크
    * @return Map<String, List<Options>> 
    **/
    @AuraEnabled
    public static Map<String,Object> getBizAttributeOptions(List<String> solIdList, String solPSType, Boolean solChangeCheck){
        System.debug(solIdList);
        Set<String> solIdSet = new Set<String>();
        for(String s : solIdList){solIdSet.add(s);}
        Map<String,List<Options>> returnOpts = new Map<String,List<Options>>();
        
        Boolean returnMsg = true;
        Map<String,Object> returnMap = new Map<String,Object>{
            'OPTIONS' => new List<Options>(),
            'MESSAGE' => true                   //변경할 솔루션 하위 bizAttirbute 리스트에 동일한 PSType이 존재하지 않으면 false
        };

        System.debug('solPSType:' + solPSType);

        List<SvcSolBizAttr__c> objList = [SELECT Id, Solution__c, Solution__r.PLCStatus__c, BizAttribute__c, WBSClass__c, PSType__c, toLabel(BusinessType__c) FROM SvcSolBizAttr__c WHERE Solution__c IN :solIdSet AND Use__c = true];

        List<String> a = new List<String>();
        for(SvcSolBizAttr__c o : objList) a.add(String.valueOf(o.BizAttribute__c));

        List<BizAttribute__c> lattr = [SELECT Id, Name , Code__c
                                           FROM BizAttribute__c 
                                          WHERE Id IN : a AND Active__c = true ORDER BY Name];

        Boolean samePsType = false;
        for(SvcSolBizAttr__c solbiz : objList){
            List<Options> optionList = new List<Options>();
            for(BizAttribute__c attr: lattr){
                if(solbiz.BizAttribute__c == attr.Id){
                    Options opt = new Options();
                    opt.Id = attr.Id;
                    opt.Name = attr.Name;
                    opt.Code = attr.Code__c;

                    String wbsClass = (solbiz.WBSClass__c == null) ? '' : solbiz.WBSClass__c;
                    String psType = (solbiz.PSType__c == null) ? '' : solbiz.PSType__c;
                    String bizType = (solbiz.BusinessType__c == null) ? '' : solbiz.BusinessType__c;
                    String plcStatus = (solbiz.Solution__r.PLCStatus__c == null) ? '' : solbiz.Solution__r.PLCStatus__c;

                    //2021.09.09
                    if(solChangeCheck && !samePsType){
                        samePsType = (solPSType == psType) ? true : false;
                    }

                    Map<String,String> otherCodeMap = new Map<String,String>();
                    otherCodeMap.put('WBSClass', wbsClass);
                    otherCodeMap.put('PSType', psType);
                    otherCodeMap.put('BizType', bizType);
                    opt.otherCode = otherCodeMap;
                    optionList = (returnOpts.get(solbiz.Solution__c) == null) ? new List<Options>() : returnOpts.get(solbiz.Solution__c);
                    optionList.add(opt);
                    returnOpts.put(solbiz.Solution__c , optionList);
                }
            }
        }
        returnMsg = (solChangeCheck) ? samePsType : true;

        returnMap.put('OPTIONS',returnOpts);
        returnMap.put('MESSAGE',returnMsg);
        return returnMap;
    }

    @AuraEnabled
    public static List<Options> getSalesTypeOptions(){
        Schema.DescribeFieldResult salesTypeFieldResult = Solution__c.SalesType__c.getDescribe();
        List<Schema.PicklistEntry> salesTypeList = salesTypeFieldResult.getPicklistValues();
        List<Options> options = new List<Options>();
        for (Schema.PicklistEntry salesType: salesTypeList) {
            Options opt = new Options();
            opt.Id = salesType.getValue();
            opt.Name = salesType.getLabel();
            options.add(opt);
        }
        options.sort();
        return options;
    }
    //START V 1.1
 @AuraEnabled
    public static String getSolutionduplicterecord(String serviceId,String boId,String attributeid,String solutiontype){
        List<Solution__c> sollist = [select id,Name from Solution__c where Opportunity__c=:boId AND sSolution__c=:solutiontype AND Service__c =:serviceId AND sBizAttribute__c=:attributeid AND DeletionFlag__c = false];
        String returnval;
        if(sollist.size() > 0){
            returnval = 'DupliSolrecord';
        }
        else {
            returnval = 'NotDupliSolrecord';
        }
        
        
        return returnval;
    }
    //END V 1.1
    public class Options implements Comparable {
        @AuraEnabled
        public String Id {get;set;}
        @AuraEnabled
        public String Name {get;set;}
        @AuraEnabled
        public String Code {get;set;}
        @AuraEnabled
        public String CodeNm {get;set;}
        @AuraEnabled
        public String parentId {get;set;}   //master service record id
        @AuraEnabled
        public Boolean migCheck {get;set;}
        @AuraEnabled
        public Map<String,String> otherCode {get;set;}

        public Integer compareTo(Object compareTo) {
            Options compareToOpt = (Options)compareTo;
            if (Name == compareToOpt.Name) return 0;
            if (Name > compareToOpt.Name) return 1;
            return -1;
        }
    }
}