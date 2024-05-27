/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2024-05-26
 * @last modified by  : akash.g@samsung.com
 * Modifications Log 
 * Ver   Date         Author                    	Modification
 * 1.0   2020-11-05   younghoon.kim@dkbmc.com   	Initial Version
 * 1.1   2020-07-15   seonju.jin@dkbmc.com      	CompanyName 필드 추가
 * 1.2   2022-04-25   kj78.yu@partner.samsung.net   TA CheckBox 선택시 TA에 해당되는 Service의 Solution를 리턴
 * 1.3   2023-02-07   anish.jain@partner.samsung.com Changes made for data mismatch for TA checkbox and other scenarios (My Sales - 125)
 * 1.4   2023-02-22   anish.jain@partner.samsung.com   Changes Added for new Search box 'Intensive BO' regarding (My Sales - 141)
 * 1.6   2023-03-10   anish.jain@partner.samsung.com   Changes Added for Excel download regarding (My Sales - 148)
 * 1.7   2023-03-13   anish.jain@partner.samsung.com   Changes Added for Strategic Account regarding (My Sales - 149)
 * 1.8   2023-03-28   anish.jain@partner.samsung.com   Changes Added for Service/Solution Excel Download regarding (My Sales - 158)
 * 1.9   2023-09-18   vikrant.ks@samsung.com    	   Result should be ordered by BO1stRegistrationDate desc (My Sales - 301)
 * 2.0   2023-10-01   anish.jain@partner.samsung.com   MS-304
 * 2.1   2024-05-26   akash.g@samsung.com              Changes added for MYSALES-534
**/
global without sharing class OpportunitySearchController {
    public static Map<String,String> stageMap;
    public static Map<String,String> statusMap;
    public static Map<String,String> bizTypeMap;

    static{
        stageMap = new Map<String,String>();
        
        Schema.DescribeFieldResult stageFieldResult = Opportunity.StageName.getDescribe();
        List<Schema.PicklistEntry> stageList = stageFieldResult.getPicklistValues();
        for (Schema.PicklistEntry stage: stageList) {
            stageMap.put(stage.getValue(), stage.getLabel());
        }

        statusMap = new Map<String,String>();
        
        Schema.DescribeFieldResult statusFieldResult = Opportunity.OpportunityStatus__c.getDescribe();
        List<Schema.PicklistEntry> statusList = statusFieldResult.getPicklistValues();
        for (Schema.PicklistEntry status: statusList) {
            statusMap.put(status.getValue(), status.getLabel());
        }

        bizTypeMap = new Map<String,String>();

        Schema.DescribeFieldResult bizTypeFieldResult = Opportunity.BusinessType__c.getDescribe();
        List<Schema.PicklistEntry> bizTypeList = bizTypeFieldResult.getPicklistValues();
        for (Schema.PicklistEntry bizType: bizTypeList) {
            bizTypeMap.put(bizType.getValue(), bizType.getLabel());
        }
    }

    @AuraEnabled    
    global static Map<String, List<Map<String, String>>> defaultSetting(){
        Map<String, List<Map<String, String>>> rtnMap = new Map<String, List<Map<String, String>>>();
        
        // Default Map Setting
        Map<String, String> defaultMap = new Map<String, String>();
        defaultMap.put('label', System.Label.BOSEARCH_LAB_ALL);
        defaultMap.put('value', '');

        // Status Picklist Setting
        List<Map<String, String>> statusPickList = new List<Map<String, String>>();
        statusPickList.add(defaultMap);

        List<Map<String, String>> opptyStatusList = Utils.getPicklistOptionType('Opportunity', 'OpportunityStatus__c');
        for(Integer i = 0; i < opptyStatusList.size(); i++){
            statusPickList.add(opptyStatusList[i]);
        }
        rtnMap.put('Status', statusPickList);
        
        // Record Type Picklist Setting
        List<Map<String,String>> rcdMapList = new List<Map<String,String>>();
        rcdMapList.add(defaultMap);
        List<RecordType> rcdList = [SELECT Id, toLabel(Name), DeveloperName, SobjectType, IsActive FROM RecordType WHERE SobjectType = 'Opportunity' AND IsActive = TRUE];
        for (RecordType rcd : rcdList) {
            Map<String,String> rcdMap = new Map<String,String>();
            rcdMap.put('label', rcd.Name);
            rcdMap.put('value', rcd.Id);
            rcdMapList.add(rcdMap);
        }
        rtnMap.put('RecordType', rcdMapList);

        // Service Picklist Setting
        List<Map<String,String>> svcMapList = new List<Map<String,String>>();
        svcMapList.add(defaultMap);
        //TA Service 는 조회 되지 않도록 수정.
        List<Master_Service__c> masterSvcList = [SELECT Id, Name 
                                                   FROM Master_Service__c 
                                                  WHERE Use__c = true 
                                                    AND (ValidityStartDate__c < :System.today() AND ValidityEndDate__c > :System.today()) 
                                                 	AND TechAttribute__c = false
                                                  ORDER BY Name];
        for(Master_Service__c masterSvc : masterSvcList){
            Map<String,String> masterSvcMap = new Map<String,String>();
            masterSvcMap.put('label', masterSvc.Name);
            masterSvcMap.put('value', masterSvc.Id);
            svcMapList.add(masterSvcMap);
        }
        rtnMap.put('Service', svcMapList);

        // Solution Picklist Setting
        List<Map<String,String>> solMapList = new List<Map<String,String>>();
        solMapList.add(defaultMap);
        rtnMap.put('Solution', solMapList);

        // Collaboration Picklist Setting
        List<Map<String,String>> collaboMapList = new List<Map<String,String>>();
        collaboMapList.add(defaultMap);

        Map<String,String> collabo_OMap = new Map<String,String>();
        collabo_OMap.put('label', System.Label.BOSEARCH_LAB_COLLABO_O);
        collabo_OMap.put('value', 'true');
        collaboMapList.add(collabo_OMap);

        Map<String,String> collabo_XMap = new Map<String,String>();
        collabo_XMap.put('label', System.Label.BOSEARCH_LAB_COLLABO_X);
        collabo_XMap.put('value', 'false');
        collaboMapList.add(collabo_XMap);

        rtnMap.put('Collaboration', collaboMapList);

        // Internal Biz Picklist Setting
        List<Map<String,String>> internalBizMapList = new List<Map<String,String>>();
        internalBizMapList.add(defaultMap);

        Map<String,String> internalBizMap = new Map<String,String>();
        internalBizMap.put('label', System.Label.BOSEARCH_LAB_INTERNALBIZ);
        internalBizMap.put('value', 'true');
        internalBizMapList.add(internalBizMap);

        Map<String,String> externalBizMap = new Map<String,String>();
        externalBizMap.put('label', System.Label.BOSEARCH_LAB_EXTERNALBIZ);
        externalBizMap.put('value', 'false');
        internalBizMapList.add(externalBizMap);

        rtnMap.put('InternalBiz', internalBizMapList);
     
        return rtnMap;
    }

    @AuraEnabled    
    global static List<Map<String, String>> getSolutionList(String serviceId, Boolean bTechAttribute){
        // Default Map Setting
        Map<String, String> defaultMap = new Map<String, String>();
        defaultMap.put('label', System.Label.BOSEARCH_LAB_ALL);
        defaultMap.put('value', '');
        
        List<Map<String, String>> rtnList = new List<Map<String, String>>();
        rtnList.add(defaultMap);
        //Start - Modified by Anish - v 1.4
        List<Master_Solution__c> masterSolList = new List<Master_Solution__c>();
        //TA CheckBox 선택시 TA에 해당되는 Service의 Solution를 리턴
        if(bTechAttribute){
            masterSolList = [SELECT Id, Name, Use__c, ValidityStartDate__c, ValidityEndDate__c, Service__c 
                             FROM Master_Solution__c 
                             WHERE Use__c = TRUE 
                             AND Service__r.TechAttribute__c = TRUE
                             AND (ValidityStartDate__c < :System.today() AND ValidityEndDate__c > :System.today()) 
                             ORDER BY Name];
        }
        else{
            masterSolList = [SELECT Id, Name, Use__c, ValidityStartDate__c, ValidityEndDate__c, Service__c 
                             FROM Master_Solution__c 
                             WHERE Use__c = TRUE 
                             AND Service__c =: serviceId
                             AND (ValidityStartDate__c < :System.today() AND ValidityEndDate__c > :System.today()) 
                             ORDER BY Name];
        }
        //End - Modified by Anish - v 1.4
        if(masterSolList.size() > 0){
            for(Master_Solution__c masterSol : masterSolList){
                Map<String, String> masterSolMap = new Map<String, String>();
                masterSolMap.put('label', masterSol.Name);
                masterSolMap.put('value', masterSol.Id);
                rtnList.add(masterSolMap);
            }
        }
        
        return rtnList;
    }

    @AuraEnabled
    global static Map<String, String> getOpptyList(String pageSize, String rcdId, String searchType, String selectedValue, Boolean bTechAttribute,  Boolean CSPCheck, Boolean MSPCheck, Boolean SCPCheck, Boolean ERPCheck, Boolean SaaSCheck){ //Added by Anish - v 1.4
        selectedValue sv = (selectedValue)JSON.deserialize(selectedValue, selectedValue.class);
        System.debug('sv Company : ' + (sv.Company).Id);
        System.debug('sv Account : ' + (sv.Account).Id);
        System.debug('sv OriginAccount : ' + (sv.OriginAccount).Id);
        System.debug('sv BOName : ' + sv.BOName);
        System.debug('sv Collaboration : ' + sv.Collaboration);
        System.debug('sv GroupInternal : ' + sv.GroupInternal);
        System.debug('sv Service : ' + sv.Service);
        System.debug('sv Solution : ' + sv.Solution);
        System.debug('sv Status : ' + sv.Status);
        System.debug('sv StartDate : ' + sv.StartDate);
        System.debug('sv EndDate : ' + sv.EndDate);
        System.debug('sv Owner : ' + (sv.Owner).Id);
        System.debug('sv OpptyCode : ' + sv.OpptyCode);
        System.debug('sv SalesDept : ' + (sv.SalesDept).Id);
        System.debug('sv PrimarySalesDept : ' + (sv.PrimarySalesDept).Id);
        System.debug('sv RecordType : ' + sv.RecordType);
        System.debug('sv FirstStartDate : ' + sv.FirstStartDate);
        System.debug('sv FirstEndDate : ' + sv.FirstEndDate);
        System.debug('sv Strategic Account : ' + sv.StrategicAccount);
        
        Map<String, String> rtnMap = new Map<String, String>();

        String str_COUNT = 'SELECT COUNT() FROM Opportunity';
        String str_SELECT = '';
        str_SELECT += 'SELECT Id, Name, OpportunityCode__c, OpportunityStatus__c, StageName, CompanyCode__c, AccountId, Account.Name, Account.AccountNumber, ';
        str_SELECT += 'cOriginAcc__c, cOriginAcc__r.Name, cOriginAcc__r.AccountNumber, BusinessLevel__c, OwnerId, Owner.Name, SalesDivision__c, ';
        str_SELECT += 'SalesDepartment__c, SalesDepartment__r.Name, cPrimaryDeliveryDivision__c, cPrimarySalesDepartment__c, cPrimarySalesDepartment__r.Name, ';
        str_SELECT += 'Collaboration__c, GroupInternal__c, KoreaDomestic__c, BusinessType__c, DealBreak__c, CloseDate, FirstCloseDate__c, RecordTypeId, RecordType.Name, BO1stRegistrationDate__c ';//v1.9 Added BO1stRegistrationDate__c
        str_SELECT += 'FROM Opportunity';
        String str_WHERE = ' WHERE (Name LIKE \'%' + sv.BOName + '%\')';
        str_WHERE += ' AND (OpportunityCode__c LIKE \'%' + sv.OpptyCode + '%\')';
        String str_ORDER = ' order by BO1stRegistrationDate__c desc nulls Last'; //v1.9 //Added by Anish - v 2.0
        String str_LIMIT = ' LIMIT ' + pageSize;

        if(sv.Collaboration == 'true') str_WHERE += ' AND Collaboration__c = true';
        else if(sv.Collaboration == 'false') str_WHERE += ' AND Collaboration__c = false';
        if(sv.GroupInternal == 'true') str_WHERE += ' AND GroupInternal__c = true';
        else if(sv.GroupInternal == 'false') str_WHERE += ' AND GroupInternal__c = false';
        if(sv.Status != '') str_WHERE += ' AND OpportunityStatus__c = \'' + sv.Status + '\'';
        if(sv.RecordType != '') str_WHERE += ' AND RecordTypeId = \'' + sv.RecordType + '\'';
        
        //Start - Added by Anish - v 1.7
        if(sv.StrategicAccount == 'Strategic Account O'){
          str_WHERE += ' AND cOriginAccIsStrCustomer__c = true';  
        }
        if(sv.StrategicAccount == 'Strategic Account X'){
          str_WHERE += ' AND cOriginAccIsStrCustomer__c = false';  
        }
        //End - Added by Anish - v 1.7

        if((sv.Company).Id != null){
            String companyCode = [SELECT Id, Name, CompanyCode__c FROM Company__c WHERE Id =: (sv.Company).Id].CompanyCode__c;
            str_WHERE += ' AND CompanyCode__c = \'' + companyCode + '\'';
        }

        if((sv.Account).Id != null){
            str_WHERE += ' AND AccountId = \'' + (sv.Account).Id + '\'';
        }

        if((sv.OriginAccount).Id != null){
            str_WHERE += ' AND cOriginAcc__c = \'' + (sv.OriginAccount).Id + '\'';
        }

        if((sv.Owner).Id != null){
            str_WHERE += ' AND OwnerId = \'' + (sv.Owner).Id + '\'';
        }

        if((sv.SalesDept).Id != null){
            str_WHERE += ' AND SalesDepartment__c = \'' + (sv.SalesDept).Id + '\'';
        }

        if((sv.PrimarySalesDept).Id != null){
            str_WHERE += ' AND cPrimarySalesDepartment__c = \'' + (sv.PrimarySalesDept).Id + '\'';
        }
        if(sv.ProjectCode != null && sv.ProjectCode != ''){
            if(sv.ProjectCode.length()>15){
                sv.ProjectCode = sv.ProjectCode.substring(0,15);
            }
            List<Project__c> projectList= [SELECT Opportunity__c FROM Project__c WHERE ProjectCode__c =:sv.ProjectCode LIMIT 1];
            String opptyId = '';
            if(!projectList.isEmpty()){
                opptyId = projectList[0].opportunity__c;
            }
            str_WHERE += ' AND Id = \'' + opptyId + '\'';
        }
        
        //Start- Added by Anish - v 1.5
        //Set<String> OpptySCIdSet  = new Set<String>();
        //Set<String> OpptySCIdSet1 = new Set<String>();
        Set<String> OpptyMSPIdSet = new Set<String>();
        Set<String> OpptyCSPIdSet = new Set<String>();
        //Set<String> OpptySaaSIdSet = new Set<String>();
        Set<String> OpptySCPIdSet = new Set<String>();
        Set<String> OpptySCIdSet  = new Set<String>();
        Set<String> OpptySCIdSet1 = new Set<String>();
        //Set<String> OpptyMESIdSet = new Set<String>();
        //V2.1 Akash changes start
        if(MSPCheck == true || CSPCheck == true || SCPCheck == true){
           // List<Opportunity> oppList = [sELECT Id,CspMspType__c, CMBizType__c from Opportunity where (Name LIKE '%%') AND (OpportunityCode__c LIKE '%%') AND (CspMspType__c = 'CSP' OR CspMspType__c = 'MSP')];
            List<Solution__c> sList = [Select Id,Opportunity__c,Solution__r.intensivetype__c from Solution__c where (Opportunity__r.Name LIKE '%%') AND 
                                       (Opportunity__r.OpportunityCode__c LIKE '%%') AND 
                                       (Solution__r.intensivetype__c = 'CSP' OR Solution__r.intensivetype__c = 'MSP')];
            if(sList.size() > 0){
                for(Solution__c sol: sList){
                    if(sol.Solution__r.intensivetype__c == 'CSP'){
                        OpptyCSPIdSet.add(sol.Opportunity__c);
                    }
                    if(sol.Solution__r.intensivetype__c == 'MSP'){
                        OpptyMSPIdSet.add(sol.Opportunity__c); 
                    }
                }
            } 
            System.debug('Anish Testing OpptySCIdSet 5 :');
            List<Opportunity> oppList = [SELECT Id,CspMspType__c, CMBizType__c from Opportunity where (Name LIKE '%%') AND (OpportunityCode__c LIKE '%%') AND 
                                         (CspMspType__c = 'CSP'  OR CspMspType__c = 'MSP'  OR CMBizType__c = 'CSP_SCP')];
             for(Opportunity opp: oppList){
                 if(opp.CspMspType__c == 'CSP'){
                     OpptyCSPIdSet.add(opp.Id);
                 }
                 if(opp.CspMspType__c == 'MSP'){
                     OpptyMSPIdSet.add(opp.Id); 
                 }
                 if(opp.CMBizType__c == 'CSP_SCP'){
                     OpptySCPIdSet.add(opp.Id);
                 }
             }
        }
        //Akash chnages end V2.1
        if(ERPCheck == true){
            List<Service__c> sList = [Select Id,Opportunity__c from Service__c where sService__r.Code__c = '20000028' AND sService__r.Name = 'ERP' AND DeletionFlag__c = False AND sendSAP__c = True AND TechAttribute__c =:bTechAttribute];
            if(sList.size() > 0){
                for(Service__c svc : sList){
                    OpptySCIdSet.add(svc.Opportunity__c);
                }
                System.debug('Anish Testing OpptySCIdSet 4 :'+ OpptySCIdSet);
            }
        }
        
        if(SaaSCheck == true){
            List<Solution__c> sList = [Select Id,Opportunity__c from Solution__c where Solution__r.intensivetype__c = 'SaaS'];
            if(sList.size() > 0){
                for(Solution__c sol : sList){
                    OpptySCIdSet1.add(sol.Opportunity__c);
                }
                System.debug('Anish Testing OpptySCIdSet 4 :'+ OpptySCIdSet1);
            }
        }
        
     	if(CSPCheck == true && MSPCheck == true && SCPCheck == true && ERPCheck == true && SaaSCheck == true){
            OpptySCIdSet1.addAll(OpptySCIdSet);
            OpptySCIdSet1.addAll(OpptyCSPIdSet);
            OpptySCIdSet1.addAll(OpptyMSPIdSet);
            OpptySCIdSet1.addAll(OpptySCPIdSet);
            System.debug('Anish Testing OpptySCIdSet1 6 : '+ OpptySCIdSet1.Size());
            str_WHERE += ' AND ( Id IN: OpptySCIdSet1)';
        }
        
        else{
            if(CSPCheck == true){
                str_WHERE += ' AND (Id IN: OpptyCSPIdSet(Int. CSP))';
                System.debug('finalstring Ani :'+str_WHERE);
            }
            
            if(MSPCheck == true){
                if(str_WHERE.contains('(Int. CSP)')){
                    OpptyMSPIdSet.addAll(OpptyCSPIdSet);
                    str_WHERE = str_WHERE.replace(' AND (Id IN: OpptyCSPIdSet(Int. CSP))', '') + ' AND (Id IN: OpptyMSPIdSet(Int. CSP/MSP))';
                }
                else{
                    str_WHERE += ' AND (Id IN: OpptyMSPIdSet(Int. MSP))';  
                }
                System.debug('finalstring Ani 12 :'+str_WHERE);
            }
            
            if(SCPCheck == true){
                if(str_WHERE.contains(' AND (Id IN: OpptyCSPIdSet(Int. CSP))')){
                    OpptyCSPIdSet.addAll(OpptySCPIdSet);
                    str_WHERE = str_WHERE.replace(' AND (Id IN: OpptyCSPIdSet(Int. CSP))', '') + ' AND (Id IN: OpptyCSPIdSet(Int. CSP/SCP))';
                }
                else if(str_WHERE.contains(' AND (Id IN: OpptyMSPIdSet(Int. CSP/MSP))'))
                {
                    OpptyMSPIdSet.addAll(OpptySCPIdSet);
                    str_WHERE =  str_WHERE.replace(' AND (Id IN: OpptyMSPIdSet(Int. CSP/MSP))', '') + ' AND (Id IN: OpptyMSPIdSet(Int. CSP/MSP/SCP))';
                }
                else if(str_WHERE.contains(' AND (Id IN: OpptyMSPIdSet(Int. MSP))'))
                {
                    OpptyMSPIdSet.addAll(OpptySCPIdSet);
                    str_WHERE =  str_WHERE.replace(' AND (Id IN: OpptyMSPIdSet(Int. MSP))', '') + ' AND (Id IN: OpptyMSPIdSet(Int. SCP/MSP))';
                }
                else{
                    str_WHERE += ' AND (Id IN: OpptySCPIdSet(Int. SCP))';
                }
                System.debug('finalstring Ani 123 :'+str_WHERE);
            }
            
            
            if(ERPCheck == true){
                system.debug('akash1');
                if(str_WHERE.contains(' AND (Id IN: OpptyCSPIdSet(Int. CSP))')){
                    OpptyCSPIdSet.addAll(OpptySCIdSet);
                    str_WHERE  = str_WHERE.replace(' AND (Id IN: OpptyCSPIdSet(Int. CSP))', '') + ' AND (Id IN: OpptyCSPIdSet(Int. CSP/ERP))';
                }
                else if(str_WHERE.contains(' AND (Id IN: OpptyMSPIdSet(Int. CSP/MSP))'))
                {
                    OpptyMSPIdSet.addAll(OpptySCIdSet);
                    str_WHERE  = str_WHERE.replace(' AND (Id IN: OpptyMSPIdSet(Int. CSP/MSP))', '') + ' AND (Id IN: OpptyMSPIdSet(Int. CSP/MSP/ERP))';
                }
                else if(str_WHERE.contains(' AND (Id IN: OpptyMSPIdSet(Int. MSP))'))
                {
                    OpptyMSPIdSet.addAll(OpptySCIdSet);
                    str_WHERE  = str_WHERE.replace(' AND (Id IN: OpptyMSPIdSet(Int. MSP))', '') + ' AND (Id IN: OpptyMSPIdSet(Int. MSP/ERP))';
                }
                else if (str_WHERE.contains(' AND (Id IN: OpptySCPIdSet(Int. SCP))')){
                    OpptySCPIdSet.addAll(OpptySCIdSet);
                    str_WHERE  =  str_WHERE.replace(' AND (Id IN: OpptySCPIdSet(Int. SCP))', '') + ' AND (Id IN: OpptySCPIdSet(Int. SCP/ERP))';
                }
                else if(str_WHERE.contains(' AND (Id IN: OpptyCSPIdSet(Int. CSP/SCP))')){
                    OpptyCSPIdSet.addAll(OpptySCIdSet);
                    str_WHERE  = str_WHERE.replace(' AND (Id IN: OpptyCSPIdSet(Int. CSP/SCP))', '') + ' AND (Id IN: OpptyCSPIdSet(Int. CSP/SCP/ERP))';
                }
                else if(str_WHERE.contains(' AND (Id IN: OpptyMSPIdSet(Int. SCP/MSP))'))
                {
                    OpptyMSPIdSet.addAll(OpptySCIdSet);
                    str_WHERE  = str_WHERE.replace(' AND (Id IN: OpptyMSPIdSet(Int. SCP/MSP))', '') + ' AND (Id IN: OpptyMSPIdSet(Int. SCP/MSP/ERP))';
                }
                else if(str_WHERE.contains(' AND (Id IN: OpptyMSPIdSet(Int. CSP/MSP/SCP))'))
                {
                    OpptyMSPIdSet.addAll(OpptySCIdSet);
                    str_WHERE  = str_WHERE.replace(' AND (Id IN: OpptyMSPIdSet(Int. CSP/MSP/SCP))', '') + ' AND (Id IN: OpptyMSPIdSet(Int. CSP/MSP/SCP/ERP))';
                }
                else  {
                    str_WHERE += str_WHERE =  ' AND (Id IN: OpptySCIdSet(Int. ERP))';
                }
                System.debug('finalstring Ani ERP 123 :'+str_WHERE);
            }
            
            if(SAASCheck == true){
                if(str_WHERE.contains(' AND (Id IN: OpptyCSPIdSet(Int. CSP))')){
                    OpptyCSPIdSet.addAll(OpptySCIdSet1);
                    str_WHERE = str_WHERE.replace(' AND (Id IN: OpptyCSPIdSet(Int. CSP))', '') + ' AND (Id IN: OpptyCSPIdSet(Int. CSP/SaaS))';
                }
                else if(str_WHERE.contains(' AND (Id IN: OpptyMSPIdSet(Int. CSP/MSP))'))
                {
                    OpptyMSPIdSet.addAll(OpptySCIdSet1);
                    str_WHERE =  str_WHERE.replace(' AND (Id IN: OpptyMSPIdSet(Int. CSP/MSP))', '') + ' AND (Id IN: OpptyMSPIdSet(Int. CSP/MSP/SaaS))';
                }
                else if(str_WHERE.contains(' AND (Id IN: OpptyMSPIdSet(Int. MSP))'))
                {
                    OpptyMSPIdSet.addAll(OpptySCIdSet1);
                    str_WHERE =  str_WHERE.replace(' AND (Id IN: OpptyMSPIdSet(Int. MSP))', '') + ' AND (Id IN: OpptyMSPIdSet(Int. MSP/SaaS))';
                }
                else if (str_WHERE.contains(' AND (Id IN: OpptySCPIdSet(Int. SCP))')){
                    OpptySCPIdSet.addAll(OpptySCIdSet1);
                    str_WHERE  =  str_WHERE.replace(' AND (Id IN: OpptySCPIdSet(Int. SCP))', '') + ' AND (Id IN: OpptySCPIdSet(Int. SCP/SaaS))';
                }
                else if(str_WHERE.contains(' AND (Id IN: OpptyCSPIdSet(Int. CSP/SCP))')){
                    OpptyCSPIdSet.addAll(OpptySCIdSet1);
                    str_WHERE  = str_WHERE.replace(' AND (Id IN: OpptyCSPIdSet(Int. CSP/SCP))', '') + ' AND (Id IN: OpptyCSPIdSet(Int. CSP/SCP/SaaS))';
                }
                else if(str_WHERE.contains(' AND (Id IN: OpptyMSPIdSet(Int. SCP/MSP))'))
                {
                    OpptyMSPIdSet.addAll(OpptySCIdSet1);
                    str_WHERE  = str_WHERE.replace(' AND (Id IN: OpptyMSPIdSet(Int. SCP/MSP))', '') + ' AND (Id IN: OpptyMSPIdSet(Int. SCP/MSP/SaaS))';
                }
                else if(str_WHERE.contains(' AND (Id IN: OpptyMSPIdSet(Int. CSP/MSP/SCP))'))
                {
                    OpptyMSPIdSet.addAll(OpptySCIdSet1);
                    str_WHERE  = str_WHERE.replace(' AND (Id IN: OpptyMSPIdSet(Int. CSP/MSP/SCP))', '') + ' AND (Id IN: OpptyMSPIdSet(Int. CSP/MSP/SCP/SaaS))';
                }
                else if(str_WHERE.contains(' AND (Id IN: OpptySCIdSet(Int. ERP))'))
                {   OpptySCIdSet.addAll(OpptySCIdSet1);
                    str_WHERE = str_WHERE.replace(' AND (Id IN: OpptySCIdSet(Int. ERP))', '') + ' AND (Id IN: OpptySCIdSet(Int. ERP/SaaS))';
                }
                else if(str_WHERE.contains(' AND (Id IN: OpptyMSPIdSet(Int. CSP/MSP/SCP/ERP))')){
                    OpptyMSPIdSet.addAll(OpptySCIdSet1);
                    str_WHERE = str_WHERE.replace(' AND (Id IN: OpptyMSPIdSet(Int. CSP/MSP/SCP/ERP))', '') + ' AND (Id IN: OpptyMSPIdSet(Int. CSP/MSP/SCP/ERP/SaaS))';  //Added by Anish - v 1.6
                }
                else if(str_WHERE.contains(' AND (Id IN: OpptyMSPIdSet(Int. MSP/ERP))'))
                {
                    OpptyMSPIdSet.addAll(OpptySCIdSet1);
                    str_WHERE =  str_WHERE.replace(' AND (Id IN: OpptyMSPIdSet(Int. MSP/ERP))', '') + ' AND (Id IN: OpptyMSPIdSet(Int. MSP/ERP/SaaS))';
                }
                else if(str_WHERE.contains(' AND (Id IN: OpptyCSPIdSet(Int. CSP/ERP))'))
                {
                    OpptyCSPIdSet.addAll(OpptySCIdSet1);
                    str_WHERE =  str_WHERE.replace(' AND (Id IN: OpptyCSPIdSet(Int. CSP/ERP))', '') + ' AND (Id IN: OpptyCSPIdSet(Int. CSP/ERP/SaaS))';
                }
                else if(str_WHERE.contains(' AND (Id IN: OpptySCPIdSet(Int. SCP/ERP))'))
                {   
                    OpptySCPIdSet.addAll(OpptySCIdSet1);
                    str_WHERE =  str_WHERE.replace(' AND (Id IN: OpptySCPIdSet(Int. SCP/ERP))', '') + ' AND (Id IN: OpptySCPIdSet(Int. SCP/ERP/SaaS))';
                }
                else if(str_WHERE.contains(' AND (Id IN: OpptyMSPIdSet(Int. CSP/MSP/ERP))')){
                    OpptyMSPIdSet.addAll(OpptySCIdSet1);
                    str_WHERE = str_WHERE.replace(' AND (Id IN: OpptyMSPIdSet(Int. CSP/MSP/ERP))', '') + ' AND (Id IN: OpptyMSPIdSet(Int. CSP/MSP/ERP/SaaS))';
                }
                else if(str_WHERE.contains(' AND (Id IN: OpptyMSPIdSet(Int. SCP/MSP/ERP))'))
                {
                    OpptyMSPIdSet.addAll(OpptySCIdSet1);
                   str_WHERE = str_WHERE.replace(' AND (Id IN: OpptyMSPIdSet(Int. SCP/MSP/ERP))', '') + ' AND (Id IN: OpptyMSPIdSet(Int. SCP/MSP/ERP/SaaS))'; 
                }
                else if(str_WHERE.contains(' AND (Id IN: OpptyCSPIdSet(Int. CSP/SCP/ERP))'))
                {
                    OpptyCSPIdSet.addAll(OpptySCIdSet1);
                str_WHERE = str_WHERE.replace(' AND (Id IN: OpptyCSPIdSet(Int. CSP/SCP/ERP))', '') + ' AND (Id IN: OpptyCSPIdSet(Int. CSP/SCP/ERP/SaaS))';
                System.debug('finalstring Ani :'+str_WHERE);
                }
                else{
                    str_WHERE += ' AND (Id IN: OpptySCIdSet1(Int. SaaS))';
                }
                System.debug('finalstring Ani 123 :'+str_WHERE);
            }
            
            
            if((MSPCheck == true || CSPCheck == true || SCPCheck == true || ERPCheck == true || SaaSCheck == true))
             {
                str_WHERE = str_WHERE.replace('(Int. CSP)','');
                str_WHERE = str_WHERE.replace('(Int. MSP)','');
                str_WHERE = str_WHERE.replace('(Int. CSP/MSP)','');
                str_WHERE = str_WHERE.replace('(Int. CSP/SCP)','');
                str_WHERE = str_WHERE.replace('(Int. CSP/MSP/SCP)','');
                str_WHERE = str_WHERE.replace('(Int. SCP/MSP)','');
                str_WHERE = str_WHERE.replace('(Int. SCP)','');
                str_WHERE = str_WHERE.replace('(Int. CSP/ERP)','');
                str_WHERE = str_WHERE.replace('(Int. CSP/MSP/ERP)','');
                str_WHERE = str_WHERE.replace('(Int. MSP/ERP)','');
                str_WHERE = str_WHERE.replace('(Int. SCP/ERP)','');
                str_WHERE = str_WHERE.replace('(Int. CSP/SCP/ERP)','');
                str_WHERE = str_WHERE.replace('(Int. SCP/MSP/ERP)','');
                str_WHERE = str_WHERE.replace('(Int. CSP/MSP/SCP/ERP)','');
                str_WHERE = str_WHERE.replace('(Int. ERP)',''); 
                str_WHERE = str_WHERE.replace('(Int. CSP/SaaS)','');
                str_WHERE = str_WHERE.replace('(Int. CSP/MSP/SaaS)','');
                str_WHERE = str_WHERE.replace('(Int. MSP/SaaS)','');
                str_WHERE = str_WHERE.replace('(Int. SCP/SaaS)','');
                str_WHERE = str_WHERE.replace('(Int. CSP/SCP/SaaS)','');
                str_WHERE = str_WHERE.replace('(Int. SCP/MSP/SaaS)','');
                str_WHERE = str_WHERE.replace('(Int. CSP/MSP/SCP/SaaS)','');
                str_WHERE = str_WHERE.replace('(Int. ERP/SaaS)','');
                str_WHERE = str_WHERE.replace('(Int. CSP/MSP/SCP/ERP/SaaS)','');
                str_WHERE = str_WHERE.replace('(Int. MSP/ERP/SaaS)','');
                str_WHERE = str_WHERE.replace('(Int. CSP/ERP/SaaS)','');
                str_WHERE = str_WHERE.replace('(Int. SCP/ERP/SaaS)','');
                str_WHERE = str_WHERE.replace('(Int. CSP/MSP/ERP/SaaS)','');
                str_WHERE = str_WHERE.replace('(Int. SCP/MSP/ERP/SaaS)','');
                str_WHERE = str_WHERE.replace('(Int. CSP/SCP/ERP/SaaS)',''); 
                str_WHERE = str_WHERE.replace('(Int. SaaS)',''); 
            }
            
            
        }
        //End- Added by Anish - v 1.5
        
        //Start - Modified by Anish - v 1.4
        Set<String> OpptyIdSet = new Set<String>();
        Set<String> OpptyIdSet1 = new Set<String>();
        List<Service__c> svcList = new List<Service__c>();
        List<Solution__c> solList = new List<Solution__c>();
        
        if(sv.Service == '' && sv.Solution == '' && bTechAttribute == false){
        }
        
        else{
        if(sv.Service != ''){
            System.debug('Anish Testing Service 3 :'+ sv.Service);            
            svcList = [SELECT Id, Name, Service__c, Opportunity__c FROM Service__c WHERE Service__c =: sv.Service AND DeletionFlag__c = false AND TechAttribute__c =:bTechAttribute AND sendSAP__c = True]; //Added by Anish - v 1.5
        }
        
        if(sv.Service == '' && bTechAttribute == true){
            System.debug('Anish Testing Service 31 :'+ sv.Service);
            svcList = [SELECT Id, Name, Service__c, Opportunity__c FROM Service__c WHERE DeletionFlag__c = false AND TechAttribute__c =:bTechAttribute AND sendSAP__c = True]; //Added by Anish - v 1.5
        }
        
        if(svcList.size() > 0){
            for(Service__c svc : svcList){
                OpptyIdSet.add(svc.Opportunity__c);
            }
            System.debug('Anish Testing OpptyIdSet 4 :'+ OpptyIdSet);
        }
        
        if(sv.Solution != ''){
            System.debug('Anish Testing Solution 3 :'+ sv.Solution);
            solList = [SELECT Id, Name, Solution__c, Opportunity__c FROM Solution__c WHERE Opportunity__c =: OpptyIdSet AND Solution__c =: sv.Solution AND DeletionFlag__c = false];
        }
        
        if(sv.Solution == ''){
            System.debug('Anish Testing Solution 31 :'+ sv.Solution);
            solList = [SELECT Id, Name, Solution__c, Opportunity__c FROM Solution__c WHERE Opportunity__c =: OpptyIdSet AND DeletionFlag__c = false];
        }
        
        if(solList.size() > 0){
            for(Solution__c sol : solList){
                OpptyIdSet1.add(sol.Opportunity__c);
            }
            System.debug('Anish Testing opptyId :'+ OpptyIdSet1.size());
        }
		        
        //if(OpptyIdSet1.size() >0){
             str_WHERE += ' AND Id IN: OpptyIdSet1'; 
        }  
           
        
        //End - Modified by Anish - v 1.4
        if(sv.StartDate != null && sv.EndDate != null){
            String srt_StartYear = String.valueOf((sv.StartDate).year());
            String srt_StartMonth = ((sv.StartDate).month()) < 10 ? '0' + String.valueOf((sv.StartDate).month()) : String.valueOf((sv.StartDate).month());
            String srt_StartDay = ((sv.StartDate).day()) < 10 ? '0' + String.valueOf((sv.StartDate).day()) : String.valueOf((sv.StartDate).day());
            String str_StartDate = srt_StartYear + '-' + srt_StartMonth + '-' + srt_StartDay;

            String srt_EndYear = String.valueOf((sv.EndDate).year());
            String srt_EndMonth = ((sv.EndDate).month()) < 10 ? '0' + String.valueOf((sv.EndDate).month()) : String.valueOf((sv.EndDate).month());
            String srt_EndDay = ((sv.EndDate).day()) < 10 ? '0' + String.valueOf((sv.EndDate).day()) : String.valueOf((sv.EndDate).day());
            String str_EndDate = srt_EndYear + '-' + srt_EndMonth + '-' + srt_EndDay;

            str_WHERE += ' AND CloseDate >= ' + str_StartDate;
            str_WHERE += ' AND CloseDate <= ' + str_EndDate;
        }

        if(sv.FirstStartDate != null && sv.FirstEndDate != null){
            String srt_FirstStartYear = String.valueOf((sv.FirstStartDate).year());
            String srt_FirstStartMonth = ((sv.FirstStartDate).month()) < 10 ? '0' + String.valueOf((sv.FirstStartDate).month()) : String.valueOf((sv.FirstStartDate).month());
            String srt_FirstStartDay = ((sv.FirstStartDate).day()) < 10 ? '0' + String.valueOf((sv.FirstStartDate).day()) : String.valueOf((sv.FirstStartDate).day());
            String str_FirstStartDate = srt_FirstStartYear + '-' + srt_FirstStartMonth + '-' + srt_FirstStartDay;

            String srt_FirstEndYear = String.valueOf((sv.FirstEndDate).year());
            String srt_FirstEndMonth = ((sv.FirstEndDate).month()) < 10 ? '0' + String.valueOf((sv.FirstEndDate).month()) : String.valueOf((sv.FirstEndDate).month());
            String srt_FirstEndDay = ((sv.FirstEndDate).day()) < 10 ? '0' + String.valueOf((sv.FirstEndDate).day()) : String.valueOf((sv.FirstEndDate).day());
            String str_FirstEndDate = srt_FirstEndYear + '-' + srt_FirstEndMonth + '-' + srt_FirstEndDay;

            str_WHERE += ' AND FirstCloseDate__c >= ' + str_FirstStartDate;
            str_WHERE += ' AND FirstCloseDate__c <= ' + str_FirstEndDate;
        }
        
        /*if(String.isNotEmpty(searchType)){
            String sign = '';
            if(searchType.equals('Next')){
                sign = '<';
                str_ORDER += ' ASC';
            }else if(searchType.equals('Prev')){
                sign = '<';
                str_ORDER += ' DESC';
            }

            if(String.isNotEmpty(rcdId)) str_WHERE += ' AND Id' + sign + '\'' + rcdId + '\'';
        }*/
        //v1.9 Start
        if(String.isNotEmpty(searchType)){
            String sign = '';
            if(searchType.equals('Next')){
                sign = '<';
                str_ORDER = ' order by BO1stRegistrationDate__c DESC nulls Last'; //Added by Anish - v 2.0
            }else if(searchType.equals('Prev')){
                sign = '>';
                str_ORDER = ' order by BO1stRegistrationDate__c ASC nulls Last'; //Added by Anish - v 2.0
            }

            if(String.isNotEmpty(rcdId)) str_WHERE += ' AND BO1stRegistrationDate__c ' + sign + ' ' + rcdId ;
        }
		//v1.9 End
		
        System.debug('str_COUNT : ' + str_COUNT);
        System.debug('str_SELECT : ' + str_SELECT);
        System.debug('akash1 str_WHERE : ' + OpptyCSPIdSet.size());
        System.debug('akash2 str_WHERE : ' + OpptyIdSet1.size());
        System.debug('akash3 str_WHERE : ' + str_WHERE);
        System.debug('str_ORDER : ' + str_ORDER);
        System.debug('str_LIMIT : ' + str_LIMIT);
        System.debug('result String : ' + str_SELECT + str_WHERE + str_ORDER + str_LIMIT);

        String resultMSG = '';
        Decimal totalPage = 0;
        Decimal totalCount = 0;
        String str_totalCount = '';
        List<Opportunity> resultOpptyList = new List<Opportunity>();
        List<returnObject> returnList = new List<returnObject>();
        try{
            resultMSG = 'SUCCESS';

            totalPage = Database.countQuery(str_COUNT + str_WHERE);
            totalCount = totalPage;
            //if(totalCount > 1000) str_totalCount = '1000+';
            //else str_totalCount = String.valueOf(totalCount);
            str_totalCount = String.valueOf(totalCount);
            totalPage = Math.ceil(totalPage/20);
            totalPage = (totalPage == 0) ? 1 : totalPage;
            //OpptyIdSet1.addAll(OpptyMSPIdSet); //Anish Testing
            //str_WHERE += ' AND Id IN: OpptyIdSet1'; //Anish Testing
            System.debug('Ani Size :' + OpptyIdSet1.Size() + '-' + OpptyMSPIdSet.Size());
            System.debug('Ani Query String : '+ str_SELECT + str_WHERE + str_ORDER + str_LIMIT);
            resultOpptyList = Database.query(str_SELECT + str_WHERE + str_ORDER + str_LIMIT);

            Set<String> resultIdSet = new Set<String>();
            Map<String, Boolean> opptyPermissionMap = new Map<String, Boolean>();
           
            if(resultOpptyList.size() > 0){
                for(Opportunity opp : resultOpptyList){
                    resultIdSet.add(opp.Id);
                }

                List<UserRecordAccess> accessList = [SELECT RecordId, HasReadAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :resultIdSet];
                for(UserRecordAccess access : accessList){
                    opptyPermissionMap.put(access.RecordId, access.HasReadAccess);
                }
               

                List<Company__c> companyList = [SELECT Name, CompanyCode__c FROM Company__c];
                for(Opportunity opp : resultOpptyList){
                    returnObject rtnObj = new returnObject();
                    rtnObj.OpptyCode = opp.OpportunityCode__c;
                    rtnObj.Id = opp.Id;
                    rtnObj.Name = opp.Name;
                    rtnObj.Status = statusMap.get(opp.OpportunityStatus__c);
                    rtnObj.Stage = stageMap.get(opp.StageName);
                    rtnObj.CompCode = opp.CompanyCode__c;
                    for(Company__c comp : companyList){
                        if(opp.CompanyCode__c == comp.CompanyCode__c){
                            rtnObj.CompName = comp.Name;
                        }
                    }
                    rtnObj.AccNumber = opp.Account.AccountNumber;
                    rtnObj.AccName = opp.Account.Name;
                    rtnObj.OriginAccNum = opp.cOriginAcc__r.AccountNumber;
                    rtnObj.OriginAcctName = opp.cOriginAcc__r.Name;
                    rtnObj.AccId = opp.AccountId; // MYSALES-522
                    rtnObj.ContractAccId = opp.cOriginAcc__c; // MYSALES-522
                    rtnObj.BizLevel = opp.BusinessLevel__c;
                    rtnObj.OwnerName = opp.Owner.Name;
                    rtnObj.SalesDiv = opp.SalesDivision__c;
                    rtnObj.SalesDept = opp.SalesDepartment__r.Name;
                    rtnObj.DeliveryDiv = opp.cPrimaryDeliveryDivision__c;
                    rtnObj.DeliveryDept = opp.cPrimarySalesDepartment__r.Name;
                    rtnObj.Collaboration = opp.Collaboration__c;
                    rtnObj.GroupInternal = opp.GroupInternal__c;
                    rtnObj.KoreaDomestic = opp.KoreaDomestic__c;
                    rtnObj.BizType = bizTypeMap.get(opp.BusinessType__c);
                    rtnObj.DealBreak = opp.DealBreak__c;
                    String formattedDateStr = DateTime.newInstance(opp.CloseDate.year(), opp.CloseDate.month(), opp.CloseDate.day()).format(Utils.getUserDateFormat());
                    rtnObj.CloseDate = formattedDateStr;
                    if(opp.FirstCloseDate__c != null){
                        String formattedDateStr_first = DateTime.newInstance(opp.FirstCloseDate__c.year(), opp.FirstCloseDate__c.month(), opp.FirstCloseDate__c.day()).format(Utils.getUserDateFormat());
                        rtnObj.FirstCloseDate = formattedDateStr_first;
                    }else{
                        rtnObj.FirstCloseDate = '';
                    }
                    rtnObj.Permission = opptyPermissionMap.get(opp.Id);
                    
                    rtnObj.BO1stRegistrationDate = opp.BO1stRegistrationDate__c; //v1.9

                    returnList.add(rtnObj);
                }                
            }
        }catch(Exception e){
            System.debug('ERROR : ' + e.getMessage());
            resultMSG = 'ERROR : ' + e.getMessage();
        }

        rtnMap.put('MESSAGE', resultMSG);
        rtnMap.put('COUNT', String.valueOf(totalPage));
        rtnMap.put('LIST', JSON.serialize(returnList));
        // rtnMap.put('TOTALCOUNT', String.valueOf(totalCount));
        rtnMap.put('TOTALCOUNT', str_totalCount);

        return rtnMap;
    }

    public List<Opportunity> opptySearchList {get;set;}
    //public List<List<Opportunity>> objList {get;set;}
    public List<List<returnObject>> objList {get;set;}
    @AuraEnabled
    public static Map<String,String> generateHTML(String selectedValue ) { 
        System.debug('Ani Excel : '+selectedValue);

        Map<String,String> returnMap = new Map<String,String>();
        String resultMsg = '';  
        String strippedBody = '';

        //String match.replaceAll 용량 제한을 위해 String을 나눠서 replaceAll 수행
        
        if(getOpptyCnt(selectedValue) > 1000){
            resultMsg = System.Label.BOSEARCH_LAB_EXPORT_LIMIT;
        }else{
            try{
                PageReference html = Page.OpportunityExcel;
            
                // this.searchKeywords = selectedValue;
                html.getParameters().put('searchKeywords', selectedValue);
    
                Blob b;
                if(Test.isRunningTest()){
                    b = Blob.valueOf('<script>var x;</script><table><tr><td>test</td></tr></table>');
                } else {
                    b = html.getContent();
                    
                }
                //HTML Contents만 남김
                resultMsg = 'SUCCESS';
                
                Integer index = (b.toString()).indexOf ('<table');
                Integer endIndex = (b.toString()).indexOf('</table>');
                if(index != -1 && endIndex != -1){
                    if(index < endIndex){
                        strippedBody = (b.toString()).substring(index, endIndex);
                    }
                }
                returnMap.put('RESULT', strippedBody);
    
            }catch(Exception e){
                resultMsg = e.getMessage();
                System.debug(e.getStackTraceString());
            }
        }

        returnMap.put('MSG',resultMsg);
        
        return returnMap;
    }

    @AuraEnabled
    public static Integer getOpptyCnt(String keywords){
        selectedValue sv = (selectedValue)JSON.deserialize(keywords, selectedValue.class);
        System.debug('Ani keywords : '+keywords);
        System.debug('Ani sv : '+sv);
        
        System.debug('Ani sv1 : '+sv.CSP);
        System.debug('Ani sv2 : '+sv.MSP);
        System.debug('Ani sv3 : '+sv.SCP);
        System.debug('Ani sv4 : '+sv.ERP);
        System.debug('Ani sv5 : '+sv.SaaS);
        System.debug('Ani sv6 : '+sv.TechAttribute);
         
        Set<String> opptyIdSet = getOpptyIdSet(sv.Service, sv.Solution, sv.TechAttribute); //Modified by Anish - v 1.8
        Set<String> opptyIBIdSet = getIBOpptyIdSet(sv.CSP, sv.MSP, sv.SCP, sv.ERP, sv.SaaS,sv.TechAttribute); //Added by Anish - v 1.6
        
        String str_WHERE = formatWhereClause(sv);
        //Start - Added by Anish - v 1.6 //Start - Modified by Anish v 1.8
        if(opptyIdSet.size() > 0 ){
            str_WHERE += ' AND Id IN: opptyIdSet';
            System.debug('Ani str_WHERE : '+opptyIdSet.Size());
        }
        if(opptyIBIdSet.size() > 0){
            str_WHERE += ' AND Id IN: opptyIBIdSet';
            System.debug('Ani str_WHERE : '+opptyIBIdSet.Size());
        }
        //End - Added by Anish - v 1.6 //End - Modified by Anish v 1.8
        System.debug('Ani str_WHERE : '+str_WHERE);
        
        
        return database.countQuery('select count() from Opportunity' + str_WHERE/*  + ' LIMIT 1000' */);
    }

    private static Set<String> getOpptyIdSet(String serviceId, String solutionId, String TechAttribute){ //Modified by Anish - v 1.8
        //Start - Modified by Anish - v 1.8
        Set<String> OpptyIdSet = new Set<String>();
        Set<String> OpptyIdSet1 = new Set<String>();
        List<Service__c> svcList = new List<Service__c>();
        List<Solution__c> solList = new List<Solution__c>();
        Boolean bTechAttribute;
        
        if(TechAttribute == 'true'){
            bTechAttribute = true;
        }
        else{
            bTechAttribute = false; 
        }
        
        if(serviceId != ''){
            System.debug('Anish Testing Service 3 :'+ serviceId);            
            svcList = [SELECT Id, Name, Service__c, Opportunity__c FROM Service__c WHERE Service__c =: serviceId AND DeletionFlag__c = false AND TechAttribute__c =:bTechAttribute AND sendSAP__c = True]; //Added by Anish - v 1.5
        }
        
        if(serviceId == '' && bTechAttribute == true){
            System.debug('Anish Testing Service 31 :'+ serviceId);
            svcList = [SELECT Id, Name, Service__c, Opportunity__c FROM Service__c WHERE DeletionFlag__c = false AND TechAttribute__c =:bTechAttribute AND sendSAP__c = True]; //Added by Anish - v 1.5
        }
        
        if(svcList.size() > 0){
            for(Service__c svc : svcList){
                OpptyIdSet.add(svc.Opportunity__c);
            }
            System.debug('Anish Testing OpptyIdSet 4 :'+ OpptyIdSet);
        }
        
        if(solutionId != ''){
            System.debug('Anish Testing Solution 3 :'+ solutionId);
            solList = [SELECT Id, Name, Solution__c, Opportunity__c FROM Solution__c WHERE Opportunity__c =: OpptyIdSet AND Solution__c =: solutionId AND DeletionFlag__c = false];
        }
        
        if(solutionId == ''){
            System.debug('Anish Testing Solution 31 :'+ solutionId);
            solList = [SELECT Id, Name, Solution__c, Opportunity__c FROM Solution__c WHERE Opportunity__c =: OpptyIdSet AND DeletionFlag__c = false];
        }
        
        if(solList.size() > 0){
            for(Solution__c sol : solList){
                OpptyIdSet1.add(sol.Opportunity__c);
            }
            System.debug('Anish Testing opptyId :'+ OpptyIdSet1);
        }
        
             return OpptyIdSet1;
        
        //End - Modified by Anish - v 1.8
    }
     
    
    //Start-Added by Anish - v 1.6
    public static Set<String> getIBOpptyIdSet(String CSP, String MSP, String SCP, String ERP, String SaaS,String TechAttribute){
        Set<String> OpptyIdSet = new Set<String>();
        
        Set<String> OpptySCIdSet  = new Set<String>();
        Set<String> OpptySCIdSet1 = new Set<String>();
        Set<String> OpptyMSPIdSet = new Set<String>();
        Set<String> OpptyCSPIdSet = new Set<String>();
        Set<String> OpptySCPIdSet = new Set<String>();
        Set<String> OpptyERPIdSet = new Set<String>();
        Set<String> OpptySaaSIdSet = new Set<String>();
        Set<String> OpptyFinalIdSet = new Set<String>();
        Boolean bTechAttribute;
        
        if(TechAttribute == 'true'){
            bTechAttribute = true;
        }
        if(TechAttribute == 'false'){
            bTechAttribute = false;
        }
        
        if(MSP == 'true' || CSP == 'true' || SCP == 'true'){
            //List<Opportunity> oppList = [sELECT Id,CspMspType__c, CMBizType__c from Opportunity where (Name LIKE '%%') AND (OpportunityCode__c LIKE '%%') AND (CspMspType__c = 'CSP' OR CspMspType__c = 'MSP' OR CMBizType__c = 'CSP_SCP')];
			List<Solution__c> sList = [Select Id,Opportunity__c,Opportunity__r.CspMspType__c,Opportunity__r.CMBizType__c,Solution__r.intensivetype__c from Solution__c where (Opportunity__r.Name LIKE '%%') AND (Opportunity__r.OpportunityCode__c LIKE '%%') 
                                       AND (Solution__r.intensivetype__c = 'CSP' OR Solution__r.intensivetype__c = 'MSP')];
            
            if(sList.size() > 0){
                for(Solution__c sol: sList){
                    if(sol.Solution__r.intensivetype__c == 'CSP'){
                        OpptyCSPIdSet.add(sol.Opportunity__c);
                    }
                    if(sol.Solution__r.intensivetype__c == 'MSP'){
                        OpptyMSPIdSet.add(sol.Opportunity__c); 
                    }
                }
               // System.debug('Anish Testing OpptySCIdSet 4 :'+ OpptyCSPIdSet.Size() + '-' + OpptyMSPIdSet.Size() + '-' + OpptySCPIdSet.Size());
            }
            
            System.debug('Anish Testing OpptySCIdSet 5 :');
            List<Opportunity> oppList = [SELECT Id,CspMspType__c, CMBizType__c from Opportunity where (Name LIKE '%%') AND (OpportunityCode__c LIKE '%%') AND 
                                         (CspMspType__c = 'CSP'  OR CspMspType__c = 'MSP'  OR CMBizType__c = 'CSP_SCP')];
             for(Opportunity opp: oppList){
                 if(opp.CspMspType__c == 'CSP'){
                     OpptyCSPIdSet.add(opp.Id);
                 }
                 if(opp.CspMspType__c == 'MSP'){
                     OpptyMSPIdSet.add(opp.Id); 
                 }
                 if(opp.CMBizType__c == 'CSP_SCP'){
                     OpptySCPIdSet.add(opp.Id);
                 }
             }
        }
        
        if(ERP == 'true'){
            //List<Service__c> sList = new List<Service__c>();
            List<Service__c> sList = [Select Id,Opportunity__c from Service__c where sService__r.Code__c = '20000028' AND sService__r.Name = 'ERP' AND DeletionFlag__c = False AND sendSAP__c = True AND TechAttribute__c =:bTechAttribute];
            if(sList.size() > 0){
                for(Service__c svc : sList){
                    OpptySCIdSet.add(svc.Opportunity__c);
                }
                System.debug('Anish Testing OpptySCIdSet 4 :'+ OpptySCIdSet);
            }
        }
        
        if(SaaS == 'true'){
            List<Solution__c> sList = [Select Id,Opportunity__c from Solution__c where Solution__r.intensivetype__c = 'SaaS'];
            if(sList.size() > 0){
                for(Solution__c sol : sList){
                    OpptySCIdSet1.add(sol.Opportunity__c);
                }
                System.debug('Anish Testing OpptySCIdSet 4 :'+ OpptySCIdSet1);
            }
        }
        
        
        if(CSP == 'true' && MSP == 'true' && SCP == 'true' && ERP == 'true' && SaaS == 'true'){
        OpptySCIdSet1.addAll(OpptySCIdSet);
        OpptySCIdSet1.addAll(OpptyCSPIdSet);
        OpptySCIdSet1.addAll(OpptyMSPIdSet);
        OpptySCIdSet1.addAll(OpptySCPIdSet);
        OpptyFinalIdSet.addAll(OpptySCIdSet1);
            System.debug('Anish Testing OpptySCIdSet1 6 : '+ OpptyFinalIdSet.Size());
        }
        
        else{
            if(CSP == 'true'){
                OpptyFinalIdSet.addAll(OpptyCSPIdSet);
                System.debug('finalstring Ani :'+OpptyFinalIdSet);
            }
            
            if(MSP == 'true'){
                if(CSP == 'true'){
                    OpptyMSPIdSet.addAll(OpptyCSPIdSet);
                    OpptyFinalIdSet.addAll(OpptyMSPIdSet);
                }
                else{
                    OpptyFinalIdSet.addAll(OpptyMSPIdSet);
                }
                System.debug('finalstring Ani 12 :'+OpptyFinalIdSet);
            }
            
            
            if(SCP == 'true'){
                if(CSP == 'true'){
                    OpptyCSPIdSet.addAll(OpptySCPIdSet);
                    OpptyFinalIdSet.addAll(OpptyCSPIdSet);
                }
                else if(CSP == 'true' && MSP == 'true')
                {
                    OpptyMSPIdSet.addAll(OpptySCPIdSet);
                    OpptyFinalIdSet.addAll(OpptyMSPIdSet);
                }
                else if(MSP == 'true')
                {
                    OpptyMSPIdSet.addAll(OpptySCPIdSet);
                    OpptyFinalIdSet.addAll(OpptyMSPIdSet);
                }
                else{
                    OpptyFinalIdSet.addAll(OpptySCPIdSet);
                }
                System.debug('finalstring Ani 123 :'+OpptyFinalIdSet);
            }
            
            if(ERP == 'true'){
                if(CSP == 'true'){
                    OpptyCSPIdSet.addAll(OpptySCIdSet);
                    OpptyFinalIdSet.addAll(OpptyCSPIdSet);
                }
                else if(CSP == 'true' && MSP == 'true')
                {
                    OpptyMSPIdSet.addAll(OpptySCIdSet);
                    OpptyFinalIdSet.addAll(OpptyMSPIdSet);
                }
                else if(MSP == 'true')
                {
                    OpptyMSPIdSet.addAll(OpptySCIdSet);
                    OpptyFinalIdSet.addAll(OpptyMSPIdSet);
                }
                else if (SCP == 'true'){
                    OpptySCPIdSet.addAll(OpptySCIdSet);
                    OpptyFinalIdSet.addAll(OpptySCPIdSet);
                }
                else if(CSP == 'true' && SCP == 'true'){
                    OpptyCSPIdSet.addAll(OpptySCIdSet);
                    OpptyFinalIdSet.addAll(OpptyCSPIdSet);
                }
                else if(MSP == 'true' && SCP == 'true')
                {
                    OpptyMSPIdSet.addAll(OpptySCIdSet);
                    OpptyFinalIdSet.addAll(OpptyMSPIdSet);
                }
                else if(MSP == 'true' && SCP == 'true' && CSP == 'true')
                {
                    OpptyMSPIdSet.addAll(OpptySCIdSet);
                    OpptyFinalIdSet.addAll(OpptyMSPIdSet);
                }
                else  {
                    OpptyFinalIdSet.addAll(OpptySCIdSet);
                }
                System.debug('finalstring Ani 123 :'+OpptyFinalIdSet);
            }
            
            if(SaaS == 'true'){
                 if(CSP == 'true'){
                    OpptyCSPIdSet.addAll(OpptySCIdSet1);
                    OpptyFinalIdSet.addAll(OpptyCSPIdSet);
                }
                else if(CSP == 'true' && MSP == 'true')
                {
                    OpptyMSPIdSet.addAll(OpptySCIdSet1);
                    OpptyFinalIdSet.addAll(OpptyMSPIdSet);
                }
                else if(MSP == 'true')
                {
                    OpptyMSPIdSet.addAll(OpptySCIdSet1);
                    OpptyFinalIdSet.addAll(OpptyMSPIdSet);
                }
                else if (SCP == 'true'){
                    OpptySCPIdSet.addAll(OpptySCIdSet1);
                    OpptyFinalIdSet.addAll(OpptySCPIdSet);
                }
                else if(CSP == 'true' && SCP == 'true'){
                    OpptyCSPIdSet.addAll(OpptySCIdSet1);
                    OpptyFinalIdSet.addAll(OpptyCSPIdSet);
                }
                else if(SCP == 'true' && MSP == 'true')
                {
                    OpptyMSPIdSet.addAll(OpptySCIdSet1);
                    OpptyFinalIdSet.addAll(OpptyMSPIdSet);
                }
                else if(SCP == 'true' && MSP == 'true' && CSP == 'true')
                {
                    OpptyMSPIdSet.addAll(OpptySCIdSet1);
                    OpptyFinalIdSet.addAll(OpptyMSPIdSet);
                }
                else if(ERP == 'true')
                {   
                    OpptySCIdSet.addAll(OpptySCIdSet1);
                    OpptyFinalIdSet.addAll(OpptySCIdSet);
                }
                else if(SCP == 'true' && MSP == 'true' && CSP == 'true' && ERP == 'true'){
                    OpptyMSPIdSet.addAll(OpptySCIdSet1);
                    OpptyFinalIdSet.addAll(OpptyMSPIdSet);
                }
                else if(MSP == 'true' && ERP == 'true')
                {
                    OpptyMSPIdSet.addAll(OpptySCIdSet1);
                    OpptyFinalIdSet.addAll(OpptyMSPIdSet);
                }
                else if(CSP == 'true' && ERP == 'true')
                {
                    OpptyCSPIdSet.addAll(OpptySCIdSet1);
                    OpptyFinalIdSet.addAll(OpptyCSPIdSet);
                }
                else if(SCP == 'true' && ERP == 'true')
                {   
                    OpptySCPIdSet.addAll(OpptySCIdSet1);
                    OpptyFinalIdSet.addAll(OpptySCPIdSet);
                }
                else if(CSP == 'true' && ERP == 'true' && MSP == 'true'){
                    OpptyMSPIdSet.addAll(OpptySCIdSet1);
                    OpptyFinalIdSet.addAll(OpptyMSPIdSet);
                }
                else if(SCP == 'true' && ERP == 'true' && MSP == 'true')
                {
                    OpptyMSPIdSet.addAll(OpptySCIdSet1);
                    OpptyFinalIdSet.addAll(OpptyMSPIdSet);
                }
                else if(SCP == 'true' && ERP == 'true' && CSP == 'true')
                {
                    OpptyCSPIdSet.addAll(OpptySCIdSet1);
                    OpptyFinalIdSet.addAll(OpptyMSPIdSet);
                System.debug('finalstring Ani :'+OpptyFinalIdSet);
                }
                else{
                    OpptyFinalIdSet.addAll(OpptySCIdSet1);
                }
                System.debug('finalstring Ani 123 :'+OpptyFinalIdSet);
            }
            
            
            
        }
        
        return OpptyFinalIdSet;
    } 
    
    private static String formatWhereClause(selectedValue sv){
        String str_WHERE = ' WHERE (Name LIKE \'%' + sv.BOName + '%\')';
        str_WHERE += ' AND (OpportunityCode__c LIKE \'%' + sv.OpptyCode + '%\')';

        if(sv.StartDate != null && sv.EndDate != null){
            String srt_StartYear = String.valueOf((sv.StartDate).year());
            String srt_StartMonth = ((sv.StartDate).month()) < 10 ? '0' + String.valueOf((sv.StartDate).month()) : String.valueOf((sv.StartDate).month());
            String srt_StartDay = ((sv.StartDate).day()) < 10 ? '0' + String.valueOf((sv.StartDate).day()) : String.valueOf((sv.StartDate).day());
            String str_StartDate = srt_StartYear + '-' + srt_StartMonth + '-' + srt_StartDay;

            String srt_EndYear = String.valueOf((sv.EndDate).year());
            String srt_EndMonth = ((sv.EndDate).month()) < 10 ? '0' + String.valueOf((sv.EndDate).month()) : String.valueOf((sv.EndDate).month());
            String srt_EndDay = ((sv.EndDate).day()) < 10 ? '0' + String.valueOf((sv.EndDate).day()) : String.valueOf((sv.EndDate).day());
            String str_EndDate = srt_EndYear + '-' + srt_EndMonth + '-' + srt_EndDay;

            str_WHERE += ' AND CloseDate >= ' + str_StartDate;
            str_WHERE += ' AND CloseDate <= ' + str_EndDate;
        }

        if(sv.FirstStartDate != null && sv.FirstEndDate != null){
            String srt_FirstStartYear = String.valueOf((sv.FirstStartDate).year());
            String srt_FirstStartMonth = ((sv.FirstStartDate).month()) < 10 ? '0' + String.valueOf((sv.FirstStartDate).month()) : String.valueOf((sv.FirstStartDate).month());
            String srt_FirstStartDay = ((sv.FirstStartDate).day()) < 10 ? '0' + String.valueOf((sv.FirstStartDate).day()) : String.valueOf((sv.FirstStartDate).day());
            String str_FirstStartDate = srt_FirstStartYear + '-' + srt_FirstStartMonth + '-' + srt_FirstStartDay;

            String srt_FirstEndYear = String.valueOf((sv.FirstEndDate).year());
            String srt_FirstEndMonth = ((sv.FirstEndDate).month()) < 10 ? '0' + String.valueOf((sv.FirstEndDate).month()) : String.valueOf((sv.FirstEndDate).month());
            String srt_FirstEndDay = ((sv.FirstEndDate).day()) < 10 ? '0' + String.valueOf((sv.FirstEndDate).day()) : String.valueOf((sv.FirstEndDate).day());
            String str_FirstEndDate = srt_FirstEndYear + '-' + srt_FirstEndMonth + '-' + srt_FirstEndDay;

            str_WHERE += ' AND FirstCloseDate__c >= ' + str_FirstStartDate;
            str_WHERE += ' AND FirstCloseDate__c <= ' + str_FirstEndDate;
        }

        if(sv.Collaboration == 'true') str_WHERE += ' AND Collaboration__c = true';
        else if(sv.Collaboration == 'false') str_WHERE += ' AND Collaboration__c = false';
        if(sv.GroupInternal == 'true') str_WHERE += ' AND GroupInternal__c = true';
        else if(sv.GroupInternal == 'false') str_WHERE += ' AND GroupInternal__c = false';
        if(sv.Status != '') str_WHERE += ' AND OpportunityStatus__c = \'' + sv.Status + '\'';
        if(sv.RecordType != '') str_WHERE += ' AND RecordTypeId = \'' + sv.RecordType + '\'';
        
        //Start - Added by Anish - v 1.7
        if(sv.StrategicAccount == 'Strategic Account O'){
          str_WHERE += ' AND cOriginAccIsStrCustomer__c = true';  
        }
        if(sv.StrategicAccount == 'Strategic Account X'){
          str_WHERE += ' AND cOriginAccIsStrCustomer__c = false';  
        }
        //End - Added by Anish - v 1.7

        if((sv.Company).Id != null){
            String companyCode = [SELECT Id, Name, CompanyCode__c FROM Company__c WHERE Id =: (sv.Company).Id].CompanyCode__c;
            str_WHERE += ' AND CompanyCode__c = \'' + companyCode + '\'';
        }
        if((sv.Account).Id != null) str_WHERE += ' AND AccountId = \'' + (sv.Account).Id + '\'';
        if((sv.OriginAccount).Id != null) str_WHERE += ' AND cOriginAcc__c = \'' + (sv.OriginAccount).Id + '\'';
        if((sv.Owner).Id != null) str_WHERE += ' AND OwnerId = \'' + (sv.Owner).Id + '\'';
        if((sv.SalesDept).Id != null) str_WHERE += ' AND SalesDepartment__c = \'' + (sv.SalesDept).Id + '\'';
        if((sv.PrimarySalesDept).Id != null) str_WHERE += ' AND cPrimarySalesDepartment__c = \'' + (sv.PrimarySalesDept).Id + '\'';
        if(sv.ProjectCode != null && sv.ProjectCode !=''){
            if(sv.ProjectCode.length()>15){
                sv.ProjectCode = sv.ProjectCode.substring(0,15);
            }
            List<Project__c> projectList= [SELECT Opportunity__c FROM Project__c WHERE ProjectCode__c =:sv.ProjectCode LIMIT 1];
            String opptyId = '';
            if(!projectList.isEmpty()){
                opptyId = projectList[0].opportunity__c;
            }
            str_WHERE += ' AND Id = \'' + opptyId + '\'';
        }


        if(sv.Service != ''){
            Set<String> OpptyIdSet = new Set<String>();
            List<Service__c> svcList = [SELECT Id, Name, Service__c, Opportunity__c FROM Service__c WHERE Service__c =: sv.Service AND DeletionFlag__c = false];
            if(svcList.size() > 0){
                for(Service__c svc : svcList){
                    OpptyIdSet.add(svc.Opportunity__c);
                }
            }

            if(sv.Solution != ''){
                List<Solution__c> solList = [SELECT Id, Name, Solution__c, Opportunity__c FROM Solution__c WHERE Opportunity__c =: OpptyIdSet AND Solution__c =: sv.Solution AND DeletionFlag__c = false];
                if(solList.size() > 0){
                    OpptyIdSet = new Set<String>();
                    for(Solution__c sol : solList){
                        OpptyIdSet.add(sol.Opportunity__c);
                    }
                }
            }
            // if(OpptyIdSet.size() > 0){
                //str_WHERE += ' AND Id IN: OpptyIdSet';
            // }
        }
        return str_WHERE;
    }

    public void getOpptyListAll() {
        selectedValue sv = (selectedValue)JSON.deserialize(ApexPages.currentPage().getParameters().get('searchKeywords'), selectedValue.class);

        String str_SELECT = '';
        str_SELECT += 'SELECT Id, Name, OpportunityCode__c, OpportunityStatus__c, StageName, CompanyCode__c, AccountId, Account.Name, Account.AccountNumber, ';
        str_SELECT += 'cOriginAcc__c, cOriginAcc__r.Name, cOriginAcc__r.AccountNumber, BusinessLevel__c, OwnerId, Owner.Name, SalesDivision__c, ';
        str_SELECT += 'SalesDepartment__c, SalesDepartment__r.Name, cPrimaryDeliveryDivision__c, cPrimarySalesDepartment__c, cPrimarySalesDepartment__r.Name, ';
        str_SELECT += 'Collaboration__c, GroupInternal__c, KoreaDomestic__c, BusinessType__c, DealBreak__c, CloseDate, FirstCloseDate__c, RecordTypeId, RecordType.Name ';
        str_SELECT += 'FROM Opportunity';
        
        Set<String> opptyIdSet = getOpptyIdSet(sv.Service, sv.Solution, sv.TechAttribute); // Modified by Anish - v 1.8
        //change by akash
        Set<String> opptyIBIdSet = getIBOpptyIdSet(sv.CSP, sv.MSP, sv.SCP, sv.ERP, sv.SaaS,sv.TechAttribute); //Added by Anish - v 1.6
        System.debug('Ani Size :' + opptyIdSet.Size() + '-' + opptyIBIdSet.Size());
        String str_WHERE = formatWhereClause(sv);
        //Start - Added by Anish - v 1.6 //Start - Modified by Anish v 1.8
        if(opptyIdSet.size() > 0 ){
            str_WHERE += ' AND Id IN: opptyIdSet';
            System.debug('Ani str_WHERE : '+opptyIdSet.Size());
        }
        if(opptyIBIdSet.size() > 0){
            str_WHERE += ' AND Id IN: opptyIBIdSet';
            System.debug('Ani str_WHERE : '+opptyIBIdSet.Size());
        }
        //End - Added by Anish - v 1.6 //End - Modified by Anish v 1.8

        List<Opportunity> opptyList = new List<Opportunity>();
        //objList = new List<List<Opportunity>>();
        objList = new List<List<returnObject>>();
        
        Integer opptyCount;
            
        opptyCount = database.countQuery('select count() from Opportunity' + str_WHERE/*  + ' LIMIT 1000' */);
        System.debug('opportunity count:' + opptyCount);
        System.debug('Ani Query String final : '+ str_SELECT + str_WHERE + ' ORDER BY BO1stRegistrationDate__c desc LIMIT 1000');
        

        //Integer cnt = 0;
        //Integer idx = 0;                //for문 idx
        //final Integer eachSize  = 1000; //1000건씩 OpptyList를 objList에 추가
     
        for(Opportunity oppty : Database.query(str_SELECT + str_WHERE + ' ORDER BY BO1stRegistrationDate__c desc nulls Last LIMIT 1000')){  //Added by Anish - v 2.0
            opptyList.add(oppty);
            /* idx++; 
            cnt++;
            opptyList.add(oppty);

            if(opptyCount < eachSize){  //1000건 미만일 경우
                objList.add(opptyList);
                opptyList = new List<Opportunity>();
            }else{                      //1000건 이상일 경우
                if(cnt == eachSize){
                    objList.add(opptyList);
                    opptyList = new List<Opportunity>();
                    cnt = 0;
                }else if(idx == opptyCount){
                    objList.add(opptyList);
                    opptyList = new List<Opportunity>();
                    cnt = 0;
                }
            } */
        }
        

        List<Company__c> companyList = [SELECT Name, CompanyCode__c FROM Company__c];
        List<returnObject> rtnObjList = new List<returnObject>();
        System.debug('OpptyList Size Finale : '+ opptyList.Size());
        for(Opportunity opp : opptyList){
            returnObject rtnObj = new returnObject();
            rtnObj.OpptyCode = opp.OpportunityCode__c;
            rtnObj.Id = opp.Id;
            rtnObj.Name = opp.Name;
            rtnObj.Status = statusMap.get(opp.OpportunityStatus__c);
            rtnObj.Stage = stageMap.get(opp.StageName);
            rtnObj.CompCode = opp.CompanyCode__c;
            for(Company__c comp : companyList){
                if(opp.CompanyCode__c == comp.CompanyCode__c){
                    rtnObj.CompName = comp.Name;
                }
            }
            rtnObj.AccNumber = opp.Account.AccountNumber;
            rtnObj.AccName = opp.Account.Name;
            rtnObj.OriginAccNum = opp.cOriginAcc__r.AccountNumber;
            rtnObj.OriginAcctName = opp.cOriginAcc__r.Name;
            rtnObj.BizLevel = opp.BusinessLevel__c;
            rtnObj.OwnerName = opp.Owner.Name;
            rtnObj.SalesDiv = opp.SalesDivision__c;
            rtnObj.SalesDept = opp.SalesDepartment__r.Name;
            rtnObj.DeliveryDiv = opp.cPrimaryDeliveryDivision__c;
            rtnObj.DeliveryDept = opp.cPrimarySalesDepartment__r.Name;
            rtnObj.Collaboration = opp.Collaboration__c;
            rtnObj.GroupInternal = opp.GroupInternal__c;
            rtnObj.KoreaDomestic = opp.KoreaDomestic__c;
            rtnObj.BizType = bizTypeMap.get(opp.BusinessType__c);
            rtnObj.DealBreak = opp.DealBreak__c;
            String formattedDateStr = DateTime.newInstance(opp.CloseDate.year(), opp.CloseDate.month(), opp.CloseDate.day()).format(Utils.getUserDateFormat());
            rtnObj.CloseDate = formattedDateStr;
            if(opp.FirstCloseDate__c != null){
                String formattedDateStr_first = DateTime.newInstance(opp.FirstCloseDate__c.year(), opp.FirstCloseDate__c.month(), opp.FirstCloseDate__c.day()).format(Utils.getUserDateFormat());
                rtnObj.FirstCloseDate = formattedDateStr_first;
            }else{
                rtnObj.FirstCloseDate = '';
            }
            // rtnObj.Permission = opptyPermissionMap.get(opp.Id);

            rtnObjList.add(rtnObj);
        } 
        // objList.add(opptyList);
        objList.add(rtnObjList);
    }
    
    global class selectedValue {
        @AuraEnabled
        global customObject Company {get; set;}
        @AuraEnabled
        global customObject Account {get; set;}
        @AuraEnabled
        global customObject OriginAccount {get; set;}
        @AuraEnabled
        global String BOName {get; set;}
        @AuraEnabled
        global String Collaboration {get; set;}
        @AuraEnabled
        global String GroupInternal {get; set;}
        @AuraEnabled
        global String Service {get; set;}
        @AuraEnabled
        global String Solution {get; set;}
        @AuraEnabled
        global String Status {get; set;}
        @AuraEnabled
        global Date StartDate {get; set;}
        @AuraEnabled
        global Date EndDate {get; set;}
        @AuraEnabled
        global customObject Owner {get; set;}
        @AuraEnabled
        global String OpptyCode {get; set;}
        @AuraEnabled
        global String ProjectCode {get; set;}
        @AuraEnabled
        global customObject SalesDept {get; set;}
        @AuraEnabled
        global customObject PrimarySalesDept {get; set;}
        @AuraEnabled
        global String RecordType {get; set;}
        @AuraEnabled
        global Date FirstStartDate {get; set;}
        @AuraEnabled
        global Date FirstEndDate {get; set;}
        //Start-Added by Anish - v 1.6
        @AuraEnabled
        global String CSP {get; set;}
        @AuraEnabled
        global String MSP {get; set;}
        @AuraEnabled
        global String SCP {get; set;}
        @AuraEnabled
        global String ERP {get; set;}
        @AuraEnabled
        global String SaaS {get; set;}
        @AuraEnabled
        global String TechAttribute {get; set;}
        //End-Added by Anish - v 1.6
        @AuraEnabled
        global String StrategicAccount {get; set;} //Added by Anish - v 1.7
    }

    global class customObject {
        @AuraEnabled
        global String Id {get; set;}
        @AuraEnabled
        global String Name {get; set;}
    }

    global class returnObject {
        @AuraEnabled
        global String OpptyCode {get; set;}
        @AuraEnabled
        global String Id {get; set;}
        @AuraEnabled
        global String Name {get; set;}
        @AuraEnabled
        global String Status {get; set;}
        @AuraEnabled
        global String Stage {get; set;}
        @AuraEnabled
        global String CompCode {get; set;}
        @AuraEnabled 
        global String CompName {get; set;}
        @AuraEnabled
        global String AccNumber {get; set;}
        @AuraEnabled
        global String AccName {get; set;}
        @AuraEnabled
        global String OriginAccNum {get; set;}
        @AuraEnabled
        global String OriginAcctName {get; set;}
        @AuraEnabled
        global String BizLevel {get; set;}
        @AuraEnabled
        global String OwnerName {get; set;}
        @AuraEnabled
        global String SalesDiv {get; set;}
        @AuraEnabled
        global String SalesDept {get; set;}
        @AuraEnabled
        global String DeliveryDiv {get; set;}
        @AuraEnabled
        global String DeliveryDept {get; set;}
        @AuraEnabled
        global Boolean Collaboration {get; set;}
        @AuraEnabled
        global Boolean GroupInternal {get; set;}
        @AuraEnabled
        global Boolean KoreaDomestic {get; set;}
        @AuraEnabled
        global String BizType {get; set;}
        @AuraEnabled
        global Boolean DealBreak {get; set;}
        @AuraEnabled
        global String CloseDate {get; set;}
        @AuraEnabled
        global String FirstCloseDate {get; set;}
        @AuraEnabled
        global Boolean Permission {get; set;}
        @AuraEnabled
        global String AccId {get; set;}   // MYSALES-522
        @AuraEnabled
        global String ContractAccId {get; set;} // MYSALES-522
        @AuraEnabled
        global DateTime BO1stRegistrationDate {get; set;}//v1.9
    }
}