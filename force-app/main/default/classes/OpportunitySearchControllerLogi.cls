/**
* @description       : Controller for OpportunitySearchLogistic Component 
* @author            : waris.m@samsung.com
* @group             : 
* @last modified on  : 2024-04-01
* @last modified by  : waris.m@samsung.com 
* Modifications Log 
* Ver   Date         Author                      Modification
* 1.0   2024-04-01   waris.m@samsung.com   Initial Version for MYSALES-472
**/
global without sharing class OpportunitySearchControllerLogi {
    public static Map<String,String> stageMap;
    public static Map<String,String> statusMap;
    public static Map<String,String> bizTypeMap;
    public static Map<String,String> oppTypeMap;
    public static Map<String,String> bizDevTypeMap;
    public static Map<String,String> LBSTypeMap;
    public static Map<String,String> subIndustryTypeMap;

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
        
        oppTypeMap = new Map<String,String>();

        Schema.DescribeFieldResult oppTypeFieldResult = Opportunity.Type.getDescribe();
        List<Schema.PicklistEntry> oppTypeList = oppTypeFieldResult.getPicklistValues();
        for (Schema.PicklistEntry oppType: oppTypeList) {
            oppTypeMap.put(oppType.getValue(), oppType.getLabel());
        }


        bizDevTypeMap = new Map<String,String>();

        Schema.DescribeFieldResult bizDevTypeFieldResult = Opportunity.LogisticsBizDevelopmentType__c.getDescribe();
        List<Schema.PicklistEntry> bizDevTypeList = bizDevTypeFieldResult.getPicklistValues();
        for (Schema.PicklistEntry bizDevType: bizDevTypeList) {
            bizDevTypeMap.put(bizDevType.getValue(), bizDevType.getLabel());
        }



        LBSTypeMap = new Map<String,String>();

        Schema.DescribeFieldResult LBSTypeFieldResult = Opportunity.LBSExceptionType__c.getDescribe();
        List<Schema.PicklistEntry> LBSTypeList = LBSTypeFieldResult.getPicklistValues();
        for (Schema.PicklistEntry LBSType: LBSTypeList) {
            LBSTypeMap.put(LBSType.getValue(), LBSType.getLabel());
        }


        subIndustryTypeMap = new Map<String,String>();

        Schema.DescribeFieldResult subIndustryTypeFieldResult = Opportunity.SubIndusrty__c.getDescribe();
        List<Schema.PicklistEntry> subIndustryTypeList = subIndustryTypeFieldResult.getPicklistValues();
        for (Schema.PicklistEntry subIndustryType: subIndustryTypeList) {
            subIndustryTypeMap.put(subIndustryType.getValue(), subIndustryType.getLabel());
        }


    }

    @AuraEnabled    
    global static Map<String, List<Map<String, String>>> defaultSetting(){
        Map<String, List<Map<String, String>>> rtnMap = new Map<String, List<Map<String, String>>>();
        
        // Default Map Setting
        Map<String, String> defaultMap = new Map<String, String>();
        defaultMap.put('label', System.Label.BOSEARCH_LAB_ALL);
        defaultMap.put('value', '');

        // Opportunity  Status Picklist Setting Start
        List<Map<String, String>> statusPickList = new List<Map<String, String>>();
        statusPickList.add(defaultMap);

        List<Map<String, String>> opptyStatusList = Utils.getPicklistOptionType('Opportunity', 'OpportunityStatus__c');
        for(Integer i = 0; i < opptyStatusList.size(); i++){
            statusPickList.add(opptyStatusList[i]);
        }
        rtnMap.put('Status', statusPickList);
        // Opportunity Status Picklist Setting End
         
        // Customer Type  Picklist Setting Start
         List<Map<String, String>> customerType = new List<Map<String, String>>();
         customerType.add(defaultMap);

        List<Map<String, String>> customerTypePicklist = Utils.getPicklistOptionType('Opportunity', 'LogisticsCustomerType__c');
         for(Integer i = 0; i < customerTypePicklist.size(); i++){
                  customerType.add(customerTypePicklist[i]);
                 }
         rtnMap.put('customerType', customerType);
         // Customer Type  Picklist Setting End

        // Opportunity Type Picklist Setting Start
       List<Map<String, String>> oppTypePicklist = new List<Map<String, String>>();
        oppTypePicklist.add(defaultMap);

        List<Map<String, String>> oppTypeList =  Utils.getPicklistOptionType('Opportunity', 'Type');
         for(Integer i = 0; i < oppTypeList.size(); i++){
            oppTypePicklist.add(oppTypeList[i]);
                }
         rtnMap.put('opportunityType', oppTypePicklist);
        // Opportunity Type Picklist Setting End
 
        // Biz Development Type Picklist Setting Start
        List<Map<String, String>> bizDevelopmentPicklist = new List<Map<String, String>>();
        bizDevelopmentPicklist.add(defaultMap);

        List<Map<String, String>> bizDevelopmentList =  Utils.getPicklistOptionType('Opportunity', 'LogisticsBizDevelopmentType__c');
         for(Integer i = 0; i < bizDevelopmentList.size(); i++){
            bizDevelopmentPicklist.add(bizDevelopmentList[i]);
                }
         rtnMap.put('bizDevelopment', bizDevelopmentPicklist);
        // Biz Development Type Picklist Setting Ends

       // LBS Exception Type Picklist Setting Start
       List<Map<String, String>> lbsExceptionTypePicklist = new List<Map<String, String>>();
        lbsExceptionTypePicklist.add(defaultMap);

       List<Map<String, String>> lbsExceptionTypeList =  Utils.getPicklistOptionType('Opportunity', 'LBSExceptionType__c');
         for(Integer i = 0; i < lbsExceptionTypeList.size(); i++){
            lbsExceptionTypePicklist.add(lbsExceptionTypeList[i]);
                }
         rtnMap.put('lbsExceptionType', lbsExceptionTypePicklist);
       // LBS Exception Type Picklist Setting End
     
        return rtnMap;
    }
      /*
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
     */
    @AuraEnabled
    global static Map<String, String> getOpptyList(String pageSize,String rcdId, String searchType, String selectedValue, Boolean globalBiddingCheck){
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
        System.debug('sv globalBidding  : ' + sv.globalBidding);
        
        Map<String, String> rtnMap = new Map<String, String>();

        String str_COUNT = 'SELECT COUNT() FROM Opportunity';
        String str_SELECT = '';
        str_SELECT += 'SELECT Id, Name, OpportunityCode__c, OpportunityStatus__c, StageName, CompanyCode__c, AccountId, Account.Name, Account.AccountNumber, ';
        str_SELECT += 'cOriginAcc__c, cOriginAcc__r.Name, cOriginAcc__r.AccountNumber, BusinessLevel__c, OwnerId, Owner.Name, SalesDivision__c, ';
        str_SELECT += 'SalesDepartment__c, SalesDepartment__r.Name, cPrimaryDeliveryDivision__c, cPrimarySalesDepartment__c, cPrimarySalesDepartment__r.Name, ';
        str_SELECT += 'Collaboration__c, GroupInternal__c, KoreaDomestic__c, BusinessType__c, DealBreak__c, CloseDate, FirstCloseDate__c, RecordTypeId, RecordType.Name, BO1stRegistrationDate__c, ';//v1.9 Added BO1stRegistrationDate__c
        str_SELECT += 'SalesRegion__c, Amount, CurrencyIsoCode, LogisticsCustomerType__c, SubIndusrty__c, Type, LogisticsBizDevelopmentType__c, LBSExceptionType__c, SalesOrganization__c,SalesOrganization__r.Name, DeliveryOrganization__c,DeliveryOrganization__r.Name,Global_Bidding_Y_N__c,cRevenueStartDate__c,cRevenueEndDate__c '; //TOdo Added in Query

        str_SELECT += 'FROM Opportunity';
        String str_WHERE = ' WHERE (Name LIKE \'%' + sv.BOName + '%\')';
        str_WHERE += ' AND (OpportunityCode__c LIKE \'%' + sv.OpptyCode + '%\')';
        str_WHERE += ' AND RecordTypeId = \'' + System.Label.BOSEARCH_LogisticRecordTypeId + '\''; //Todo 
        String str_ORDER = ' order by CloseDate desc nulls Last'; //v1.9 //Added by Anish - v 2.0 //todo order by changed from bofirst close date to close date
        String str_LIMIT = ' LIMIT ' + pageSize;

        
       
        if(sv.Status != '') str_WHERE += ' AND OpportunityStatus__c = \'' + sv.Status + '\'';
        if(sv.customerType != '') {
        str_WHERE += ' AND LogisticsCustomerType__c = \'' + sv.customerType + '\'';
        }

        if(sv.opportunityType != '') {
            str_WHERE += ' AND Type = \'' + sv.opportunityType + '\'';
        }

        if(sv.lbsExceptionType != '') {
            str_WHERE += ' AND LBSExceptionType__c = \'' + sv.lbsExceptionType + '\'';
        }


        if(sv.bizDevelopment != '') {
            str_WHERE += ' AND LogisticsBizDevelopmentType__c = \'' + sv.bizDevelopment + '\'';
        }
    

     /*   if((sv.Company).Id != null){
            String companyCode = [SELECT Id, Name, CompanyCode__c FROM Company__c WHERE Id =: (sv.Company).Id].CompanyCode__c;
            str_WHERE += ' AND CompanyCode__c = \'' + companyCode + '\'';
        }
      */
        if((sv.Account).Id != null){
            str_WHERE += ' AND AccountId = \'' + (sv.Account).Id + '\'';
        }
           
        if(!String.isBlank(sv.globalBidding)){
            str_WHERE += ' AND Global_Bidding_Y_N__c = ' + sv.globalBidding ;
        }
        

        if((sv.Owner).Id != null){
            str_WHERE += ' AND OwnerId = \'' + (sv.Owner).Id + '\'';
        }
        
        if((sv.SalesOrganization).Id != null){
            str_WHERE += ' AND SalesOrganization__c = \'' + (sv.SalesOrganization).Id + '\'';
        }

        if((sv.DeliveryOrganization).Id != null){
            str_WHERE += ' AND DeliveryOrganization__c = \'' + (sv.DeliveryOrganization).Id + '\'';
        }
           /*
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
        } */
        
        // TOdo Remove below Start- 
        Set<String> OpptySCIdSet  = new Set<String>();
        Set<String> OpptySCIdSet1 = new Set<String>();
        Set<String> OpptyMSPIdSet = new Set<String>();
        Set<String> OpptyCSPIdSet = new Set<String>();
        Set<String> OpptySCPIdSet = new Set<String>();
        Set<String> OpptyERPIdSet = new Set<String>();
        Set<String> OpptyMESIdSet = new Set<String>();
        // TOdo Remove below End-
                 
        
        
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

        if(sv.ContractStartDate != null && sv.ContractEndDate != null){
            String srt_FirstStartYear = String.valueOf((sv.ContractStartDate).year());
            String srt_FirstStartMonth = ((sv.ContractStartDate).month()) < 10 ? '0' + String.valueOf((sv.ContractStartDate).month()) : String.valueOf((sv.ContractStartDate).month());
            String srt_FirstStartDay = ((sv.ContractStartDate).day()) < 10 ? '0' + String.valueOf((sv.ContractStartDate).day()) : String.valueOf((sv.ContractStartDate).day());
            String str_FirstStartDate = srt_FirstStartYear + '-' + srt_FirstStartMonth + '-' + srt_FirstStartDay;

            String srt_FirstEndYear = String.valueOf((sv.ContractEndDate).year());
            String srt_FirstEndMonth = ((sv.ContractEndDate).month()) < 10 ? '0' + String.valueOf((sv.ContractEndDate).month()) : String.valueOf((sv.ContractEndDate).month());
            String srt_FirstEndDay = ((sv.ContractEndDate).day()) < 10 ? '0' + String.valueOf((sv.ContractEndDate).day()) : String.valueOf((sv.ContractEndDate).day());
            String str_FirstEndDate = srt_FirstEndYear + '-' + srt_FirstEndMonth + '-' + srt_FirstEndDay;

            str_WHERE += ' AND cRevenueStartDate__c >= ' + str_FirstStartDate;
            str_WHERE += ' AND cRevenueEndDate__c <= ' + str_FirstEndDate;
        }
        
       // TODO commented to maintain same order
        //v1.9 Start 
       if(String.isNotEmpty(searchType)){
            String sign = '';
            if(searchType.equals('Next')){
                sign = '<';
                str_ORDER = ' order by CloseDate DESC nulls Last'; //TODO Change order by from  BO1stRegistrationDate__c  to close date
            }else if(searchType.equals('Prev')){
                sign = '>';
                str_ORDER = ' order by CloseDate ASC nulls Last'; //TODO Change order by from  BO1stRegistrationDate__c  to close date
            }

            if(String.isNotEmpty(rcdId)) str_WHERE += ' AND CloseDate ' + sign + ' ' + rcdId ; //TODO Change  from  BO1stRegistrationDate__c  to close date
        } 
		//v1.9 End
		
        System.debug('str_COUNT : ' + str_COUNT);
        System.debug('str_SELECT : ' + str_SELECT);
        System.debug('str_WHERE : ' + str_WHERE);
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
             System.debug('Count query debug >> ' + str_COUNT + str_WHERE);
            totalPage = Database.countQuery(str_COUNT + str_WHERE);
            totalCount = totalPage;
            //if(totalCount > 1000) str_totalCount = '1000+';
            //else str_totalCount = String.valueOf(totalCount);
            str_totalCount = String.valueOf(totalCount);
            totalPage = Math.ceil(totalPage/20);
            totalPage = (totalPage == 0) ? 1 : totalPage;
            //OpptyIdSet1.addAll(OpptyMSPIdSet); //Anish Testing
            //str_WHERE += ' AND Id IN: OpptyIdSet1'; //Anish Testing
            
            System.debug('Ani Query String to display : '+ str_SELECT + str_WHERE  + str_ORDER + str_LIMIT);  
            resultOpptyList = Database.query(str_SELECT + str_WHERE  + str_ORDER + str_LIMIT); 

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
                    rtnObj.SalesRegion = opp.SalesRegion__c; //todo start
                    rtnObj.Amount = opp.Amount;
                    rtnObj.CurrencyType = opp.CurrencyIsoCode;
                    rtnObj.customerType = opp.LogisticsCustomerType__c;
                    rtnObj.SubIndusrty = subIndustryTypeMap.get(opp.SubIndusrty__c);
                    rtnObj.opportunityType = oppTypeMap.get(opp.Type);
                    rtnObj.bizDevelopment = bizDevTypeMap.get(opp.LogisticsBizDevelopmentType__c);
                    rtnObj.lbsExceptionType = LBSTypeMap.get(opp.LBSExceptionType__c);
                    rtnObj.SalesOrganization = opp.SalesOrganization__r.Name;
                    rtnObj.DeliveryOrganization = opp.DeliveryOrganization__r.Name;
                    rtnObj.globalBidding = opp.Global_Bidding_Y_N__c;
                    if(opp.cRevenueStartDate__c != null){
                        String formattedDateStr_start = DateTime.newInstance(opp.cRevenueStartDate__c.year(), opp.cRevenueStartDate__c.month(), opp.cRevenueStartDate__c.day()).format(Utils.getUserDateFormat());
                        rtnObj.ContractStartDate = formattedDateStr_start;
                    }else{
                        rtnObj.ContractStartDate = '';
                    }
                    if(opp.cRevenueEndDate__c != null){
                        String formattedDateStr_end = DateTime.newInstance(opp.cRevenueEndDate__c.year(), opp.cRevenueEndDate__c.month(), opp.cRevenueEndDate__c.day()).format(Utils.getUserDateFormat());
                        rtnObj.ContractEndDate = formattedDateStr_end;
                    }else{
                        rtnObj.ContractEndDate = '';
                    }  //todoends
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
                    rtnObj.Permission = opptyPermissionMap.get(opp.Id);
                    rtnObj.CloseDateSort = opp.CloseDate; //todo addded for sorting properly
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
                PageReference html = Page.OpportunityExcelLogistic;
            
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
       
         
     
        
        String str_WHERE = formatWhereClause(sv);

        System.debug('Ani str_WHERE : '+str_WHERE);
        
        
        return database.countQuery('select count() from Opportunity' + str_WHERE/*  + ' LIMIT 1000' */);
    }

  
     
    

    
    private static String formatWhereClause(selectedValue sv){
        String str_WHERE = ' WHERE (Name LIKE \'%' + sv.BOName + '%\')';
        str_WHERE += ' AND (OpportunityCode__c LIKE \'%' + sv.OpptyCode + '%\')';
        str_WHERE += ' AND RecordTypeId = \'' + System.Label.BOSEARCH_LogisticRecordTypeId + '\''; //Todo

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

        if(sv.ContractStartDate != null && sv.ContractEndDate != null){
            String srt_FirstStartYear = String.valueOf((sv.ContractStartDate).year());
            String srt_FirstStartMonth = ((sv.ContractStartDate).month()) < 10 ? '0' + String.valueOf((sv.ContractStartDate).month()) : String.valueOf((sv.ContractStartDate).month());
            String srt_FirstStartDay = ((sv.ContractStartDate).day()) < 10 ? '0' + String.valueOf((sv.ContractStartDate).day()) : String.valueOf((sv.ContractStartDate).day());
            String str_FirstStartDate = srt_FirstStartYear + '-' + srt_FirstStartMonth + '-' + srt_FirstStartDay;

            String srt_FirstEndYear = String.valueOf((sv.ContractEndDate).year());
            String srt_FirstEndMonth = ((sv.ContractEndDate).month()) < 10 ? '0' + String.valueOf((sv.ContractEndDate).month()) : String.valueOf((sv.ContractEndDate).month());
            String srt_FirstEndDay = ((sv.ContractEndDate).day()) < 10 ? '0' + String.valueOf((sv.ContractEndDate).day()) : String.valueOf((sv.ContractEndDate).day());
            String str_FirstEndDate = srt_FirstEndYear + '-' + srt_FirstEndMonth + '-' + srt_FirstEndDay;

            str_WHERE += ' AND cRevenueStartDate__c >= ' + str_FirstStartDate;
            str_WHERE += ' AND cRevenueEndDate__c <= ' + str_FirstEndDate;
        }

       
        if(sv.Status != '') str_WHERE += ' AND OpportunityStatus__c = \'' + sv.Status + '\'';
       
        if(sv.customerType != '') {
        str_WHERE += ' AND LogisticsCustomerType__c = \'' + sv.customerType + '\'';
        }

        if(sv.opportunityType != '') {
            str_WHERE += ' AND Type = \'' + sv.opportunityType + '\'';
        }

        if(sv.lbsExceptionType != '') {
            str_WHERE += ' AND LBSExceptionType__c = \'' + sv.lbsExceptionType + '\'';
        }


        if(sv.bizDevelopment != '') {
            str_WHERE += ' AND LogisticsBizDevelopmentType__c = \'' + sv.bizDevelopment + '\'';
        }
       
      
        if((sv.Account).Id != null) str_WHERE += ' AND AccountId = \'' + (sv.Account).Id + '\'';
        
        if(!String.isBlank(sv.globalBidding)){
            str_WHERE += ' AND Global_Bidding_Y_N__c = ' + sv.globalBidding ;
        }
       
        if((sv.Owner).Id != null) str_WHERE += ' AND OwnerId = \'' + (sv.Owner).Id + '\'';
       
        if((sv.SalesOrganization).Id != null){
            str_WHERE += ' AND SalesOrganization__c = \'' + (sv.SalesOrganization).Id + '\'';
        }

        if((sv.DeliveryOrganization).Id != null){
            str_WHERE += ' AND DeliveryOrganization__c = \'' + (sv.DeliveryOrganization).Id + '\'';
        }
      


        
        return str_WHERE;
    }

    public void getOpptyListAll() {
        selectedValue sv = (selectedValue)JSON.deserialize(ApexPages.currentPage().getParameters().get('searchKeywords'), selectedValue.class);

        String str_SELECT = '';
        str_SELECT += 'SELECT Id, Name, OpportunityCode__c, OpportunityStatus__c, StageName, CompanyCode__c, AccountId, Account.Name, Account.AccountNumber, ';
        str_SELECT += 'cOriginAcc__c, cOriginAcc__r.Name, cOriginAcc__r.AccountNumber, BusinessLevel__c, OwnerId, Owner.Name, SalesDivision__c, ';
        str_SELECT += 'SalesDepartment__c, SalesDepartment__r.Name, cPrimaryDeliveryDivision__c, cPrimarySalesDepartment__c, cPrimarySalesDepartment__r.Name, ';
        str_SELECT += 'Collaboration__c, GroupInternal__c, KoreaDomestic__c, BusinessType__c, DealBreak__c, CloseDate, FirstCloseDate__c, RecordTypeId, RecordType.Name, ';
        str_SELECT += 'SalesRegion__c, Amount, CurrencyIsoCode, LogisticsCustomerType__c, SubIndusrty__c, Type, LogisticsBizDevelopmentType__c, LBSExceptionType__c, SalesOrganization__c,SalesOrganization__r.Name, DeliveryOrganization__c,DeliveryOrganization__r.Name,Global_Bidding_Y_N__c,cRevenueStartDate__c,cRevenueEndDate__c '; //TOdo Added in Query
        str_SELECT += 'FROM Opportunity';
        
    
     
        String str_WHERE = formatWhereClause(sv);
       

        List<Opportunity> opptyList = new List<Opportunity>();
        
        objList = new List<List<returnObject>>();
        
        Integer opptyCount;
            
        opptyCount = database.countQuery('select count() from Opportunity' + str_WHERE/*  + ' LIMIT 1000' */);
        System.debug('opportunity count:' + opptyCount);
        System.debug('Ani Query String final : '+ str_SELECT + str_WHERE + ' order by CloseDate desc nulls Last LIMIT 1000');
        

       
     
        for(Opportunity oppty : Database.query(str_SELECT + str_WHERE + ' ORDER BY CloseDate desc nulls Last LIMIT 1000')){  //TODO Change order by from  BO1stRegistrationDate__c  to close date
            opptyList.add(oppty);
          
        }
        

        List<Company__c> companyList = [SELECT Name, CompanyCode__c FROM Company__c];
        List<returnObject> rtnObjList = new List<returnObject>();
        System.debug('OpptyList Size Finale : '+ opptyList.Size());
        for(Opportunity opp : opptyList){
            returnObject rtnObj = new returnObject();
            rtnObj.SalesRegion = opp.SalesRegion__c; //todo start
            rtnObj.Amount = opp.Amount;
            rtnObj.CurrencyType = opp.CurrencyIsoCode;
            rtnObj.customerType = opp.LogisticsCustomerType__c;
            rtnObj.SubIndusrty = subIndustryTypeMap.get(opp.SubIndusrty__c);
            rtnObj.opportunityType = oppTypeMap.get(opp.Type);
            rtnObj.bizDevelopment = bizDevTypeMap.get(opp.LogisticsBizDevelopmentType__c);
            rtnObj.lbsExceptionType = LBSTypeMap.get(opp.LBSExceptionType__c);
            rtnObj.SalesOrganization = opp.SalesOrganization__r.Name;
            rtnObj.DeliveryOrganization = opp.DeliveryOrganization__r.Name;
            rtnObj.globalBidding = opp.Global_Bidding_Y_N__c;
            rtnObj.CloseDateSort = opp.CloseDate; //todo addded for sorting properly
            if(opp.cRevenueStartDate__c != null){
                        String formattedDateStr_start = DateTime.newInstance(opp.cRevenueStartDate__c.year(), opp.cRevenueStartDate__c.month(), opp.cRevenueStartDate__c.day()).format(Utils.getUserDateFormat());
                        rtnObj.ContractStartDate = formattedDateStr_start;
            }else{
                        rtnObj.ContractStartDate = '';
            }
            if(opp.cRevenueEndDate__c != null){
                        String formattedDateStr_end = DateTime.newInstance(opp.cRevenueEndDate__c.year(), opp.cRevenueEndDate__c.month(), opp.cRevenueEndDate__c.day()).format(Utils.getUserDateFormat());
                        rtnObj.ContractEndDate = formattedDateStr_end;
            }else{
                        rtnObj.ContractEndDate = '';
            }  //todoends
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
           

            rtnObjList.add(rtnObj);
        } 
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
        global customObject SalesOrganization {get; set;}
         @AuraEnabled
        global customObject DeliveryOrganization {get; set;}
        @AuraEnabled
         global String lbsExceptionType {get; set;}
         @AuraEnabled
        global String customerType {get; set;}
        @AuraEnabled
        global String opportunityType {get; set;}
        @AuraEnabled
         global String globalBidding {get; set;}
        @AuraEnabled
         global String bizDevelopment {get; set;}
        @AuraEnabled
        global Date ContractStartDate {get; set;}
         @AuraEnabled
        global Date ContractEndDate {get; set;}
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
        global String MES {get; set;}
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
        global DateTime BO1stRegistrationDate {get; set;}//v1.9
         @AuraEnabled
        global Date CloseDateSort {get; set;}//todo new field added 
        @AuraEnabled  //todo Start 
        global String SalesRegion {get; set;}
        @AuraEnabled
        global Decimal Amount {get; set;}
        @AuraEnabled
        global String CurrencyType {get; set;}
        @AuraEnabled
        global String customerType {get; set;}
        @AuraEnabled
        global String SubIndusrty {get; set;}
        @AuraEnabled
        global String opportunityType {get; set;}
        @AuraEnabled
        global String bizDevelopment {get; set;}
        @AuraEnabled
        global String lbsExceptionType {get; set;}
        @AuraEnabled
        global String SalesOrganization {get; set;}
        @AuraEnabled
        global String DeliveryOrganization {get; set;}
        @AuraEnabled
        global String ContractStartDate {get; set;}
        @AuraEnabled
        global String ContractEndDate {get; set;}
        @AuraEnabled
        global Boolean globalBidding {get; set;}   //todo ends
    }
}