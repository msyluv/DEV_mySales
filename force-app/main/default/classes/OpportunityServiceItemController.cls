/**
 * @description       : 
 * @author            : seonju.jin@dkbmc.com
 * @group             : 
 * @last modified on  : 2022-02-14
 * @last modified by  : seonju.jin@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                 Modification
 * 1.0   2020-11-18   seonju.jin@dkbmc.com   Initial Version
 * 1.1   2021-02-23   seonju.jin@dkbmc.com   CostCenter 폐쇄 조건 추가
 * 1.2   2021-08-25   seonju.jin@dkbmc.com   TechAttribute 추가
**/
public without sharing class OpportunityServiceItemController {

    /**
    * @description 
    * @author seonju.jin@dkbmc.com | 2020-12-03 
    * @param Boolean isHQ 
    * @param Boolean isCollaboration 
    * @return List<Master_Service__c> 
    **/
    @AuraEnabled
    public static List<Options> getServiceOptions(String boId, Boolean isHQ, Boolean isCollaboration){

        List<Options> loptions = new List<Options>();
        Set<Options> setOptions = new Set<Options>();

        /**
         * companyCode가 본사이고 법인과 협업인 경우
         * 법인이 선택한 서비스 pickvalue만 나와야한다.
         */
        if(isHQ && isCollaboration){
            Set<String> serviceNameSet = new Set<String>();
            System.debug('collabo boid:' + boId);
            List<Service__c> lservice = [SELECT Id, sService__r.Id, sService__r.Name, TechAttribute__c, sService__r.Code__c
                                        FROM Service__c 
                                        WHERE Opportunity__c = :boId 
                                        AND sDeletionFlag__c = false 
                                        AND sService__r.TechAttribute__c = false 
                                        AND (Service__c != null AND Service__r.TechAttribute__c = false)
                                        ORDER BY sService__r.Name ];
            for(Service__c svc :lservice){
                Options opts = new Options();
                opts.Id = svc.sService__r.Id;
                opts.Name = svc.sService__r.Name;
                opts.techyn = svc.TechAttribute__c;
                opts.Code = svc.sService__r.Code__c;
                
                if(serviceNameSet.contains(opts.Name)) continue;   //중복옵션 continue;

                serviceNameSet.add(opts.Name);
                setOptions.add(opts);
            }

            for(Options opt : setOptions){
                loptions.add(opt);
            }
        }else{

            List<Master_Service__c> lmasterService =  [SELECT Id, Name, TechAttribute__c, Code__c FROM Master_Service__c WHERE Use__c = true
            AND (ValidityStartDate__c  < :System.today() AND ValidityEndDate__c  > :System.today()) AND TechAttribute__c = false ORDER BY Name];
            for(Master_Service__c masterSvc :lmasterService){
                System.debug('service:' + masterSvc);
                Options opts = new Options();
                opts.Id = masterSvc.Id;
                opts.Name = masterSvc.Name;
                opts.techyn = masterSvc.TechAttribute__c;
                opts.Code = masterSvc.Code__c;
                loptions.add(opts);
            }
        }

        return loptions;
    }

    /**
    * @description Department 정보 조회
    * @author seonju.jin@dkbmc.com | 2020-12-03 
    * @param List<String> svcIdList Master_Service__c Id List
    * @return Map<String,List<CostCenter__c>>
    **/
    @AuraEnabled
    public static Map<String,List<CostCenter__c>> getDepartmentOptions(List<String> svcIdList){
        Map<String,List<CostCenter__c>> returnOptions = new Map<String,List<CostCenter__c>>();
        List<CostCenter__c> options = new List<CostCenter__c>();
        List<SvcDlvrDept__c> lsvcDept = new List<SvcDlvrDept__c>();
        Map<String,String> deptMap = new Map<String,String>();

        //svcIdList 중복제거
        Set<String> svcIdSet = new Set<String>();
        svcIdSet.addAll(svcIdList);

        lsvcDept = [SELECT Id, DeliveryDepartment__c, DeliveryDepartment__r.CostCenterName__c, Service__c
                         FROM SvcDlvrDept__c
                        WHERE Service__c IN :svcIdSet AND DeliveryDepartment__r.Closed__c = false AND DeliveryDepartment__r.ZZCheck__c = true
                        ORDER BY DeliveryDepartment__r.CostCenterName__c ASC];
        
        List<String> ids = new List<String>();
        for(SvcDlvrDept__c obj : lsvcDept){
            CostCenter__c costCenter = obj.DeliveryDepartment__r;
            String serviceId = obj.Service__c;

            if(returnOptions.get(serviceId) == null){
                returnOptions.put(serviceId, new List<CostCenter__c>{costCenter});
            }else{
                List<CostCenter__c> costList = returnOptions.get(serviceId);
                costList.add(costCenter);
                returnOptions.put(serviceId,costList);
            }
        }
        return returnOptions;
    }

    public class Options{
        @AuraEnabled
        public String Id {get;set;}
        @AuraEnabled
        public String Name {get;set;}
        @AuraEnabled
        public String Code {get;set;}
        @AuraEnabled
        public Boolean techyn {get;set;}
    }
}