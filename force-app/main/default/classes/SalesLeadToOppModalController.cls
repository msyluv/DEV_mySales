/**
* @description       : 
* @author            : Junghwa.Kim@dkbmc.com
* @group             : 
* @last modified on  : 2024-04-19
* @last modified by  : vikrant.ks@samsung.com
* Modifications Log 
* Ver   Date         Author                    Modification
* 1.0   11-05-2020   Junghwa.Kim@dkbmc.com     Initial Version
* 1.1   2021-05-12   Junghwa.Kim@dkbmc.com     변환시 필수값 체크 추가
* 1.2   2022-08-09   akash.g@samsung.com       Add new condition when converting sales lead to opportunity in case of lead channel is demand i.e. can convert when Sales Lead Type is System Enhancement, New System ,Solution/Service or Consulting.
* 1.3   2023-07-10   divyam.gupta@samsung.com  Mysales-251 Change customer contact date with Date.today() to Datetime.now().
* 1.4   2023-09-27   chae_ho.yang@samsung.com  Mysales-304 Change customer contact date only on Marketing Lead
* 1.5   2024-04-19   vikrant.ks@samsung.com    If owner of converting Sales Lead doesn't have CREATE access on Opportunity object then show warning message and Added new field Owner in UI.(MySales-508)
**/
public without sharing class SalesLeadToOppModalController {
    @AuraEnabled
    public static Map<String, Boolean> isConverted(String recordId){
        Map<String, Boolean> returnMap = new Map<String, Boolean>();
        Boolean check_Convert = false;
        Boolean check_Warm = false;
        Boolean check_Account = false;
        Boolean check_MDG = false;
        Boolean check_Amount = false;
        Boolean check_CloseDate = false;
        Boolean check_SalesDepartment = false;
        Boolean check_RevenueStartDate = false;
        Boolean check_RevenueEndDate = false;
        Boolean check_Type = false;
        Boolean check_SalesOrganization = false;
        Boolean check_LeadType = false;
        Boolean check_Close = false;
        Boolean check_Contact = false;
        // V1.2 -> Add new condition when converting sales lead to opportunity in case of lead channel is demand
        Boolean check_LeadTypeDemand = false;
        Boolean check_OpportunityCreateAccess = true; //V1.5
        
        try{
            //V1.2 -> Add LeadChannel__c in SOQL query. //V1.5 Add Owner.Profile.Name in SOQL query.
            List<Sales_Lead__c> slList = [SELECT Id, Lead__c, LeadStage__c, OwnerId, recordTypeId, OpportunityName__c, AccountId__c, Amount__c, CloseDate__c, AccountId__r.MDGCheck__c,
                                                 SalesDepartment__c , RevenueEndDate__c, RevenueStartDate__c, Type__c, SalesOrganization__c, LeadType__c, LeadStatus__c, CustomerContactDate__c , LeadChannel__c,Owner.Profile.Name
                                            FROM Sales_Lead__c 
                                           WHERE Id = :recordId 
                                           LIMIT 1];
            if(slList.size() > 0){
                if(SLList[0].LeadStage__c == 'Converted') check_Convert = true;
                if(SLList[0].LeadStage__c == 'Warm' || SLList[0].LeadStage__c == 'Cold') check_Warm = true;

                if(SLList[0].AccountId__c == null) check_Account = true;
                else if(!SLList[0].AccountId__r.MDGCheck__c) check_MDG = true;
                
                if(SLList[0].Amount__c == null) check_Amount = true;
                if(SLList[0].CloseDate__c == null) check_CloseDate = true;
                /**START- V1.2 : Add new condition when converting sales lead to opportunity in case of lead channel is demand**/ 
                if(SLList[0].LeadChannel__c != 'Demand'){
                    if(SLList[0].LeadType__c != '01' && SLList[0].LeadType__c != '02'){
                        check_LeadType = true;   
                    }
                }else{
                    if(SLList[0].LeadType__c != '31' && SLList[0].LeadType__c != '32'  && SLList[0].LeadType__c != '33' && 
                       SLList[0].LeadType__c != '34'){
                        check_LeadTypeDemand = true;   
                    }
                } 
                /**END- V1.2**/
                if(SLList[0].LeadStatus__c == 'Close') check_Close = true;
                 //V1.3 -Mysales-251 Change customer contact date with Date.today() to Datetime.now()
                //if(SLList[0].CustomerContactDate__c == null || SLList[0].CustomerContactDate__c > Date.today()) check_Contact = true;
                //V1.4 chae_ho.yang Marketing Lead일때만 contact date validation logic
                if (SLList[0].LeadChannel__c == 'Marketing Lead Converted') {
                    if(SLList[0].CustomerContactDate__c == null || SLList[0].CustomerContactDate__c > Datetime.now()) check_Contact = true;
                }
                	
                // 2021-05-12 레코드 타입에 따른 필수값 체크
                RecordType rt = [SELECT Id, Name, DeveloperName FROM RecordType WHERE Id = :SLList[0].recordTypeId LIMIT 1];
                if(rt.DeveloperName == 'HQ'){
                    if(SLList[0].SalesDepartment__c == null) check_SalesDepartment = true;
                } else {
                    if(SLList[0].RevenueStartDate__c == null) check_RevenueStartDate = true;
                    if(SLList[0].RevenueEndDate__c == null) check_RevenueEndDate = true;	
                    if(SLList[0].Type__c == null) check_Type = true;
                    if(SLList[0].SalesOrganization__c == null) check_SalesOrganization = true;
                }
                //V1.5 Start
                List<ObjectPermissions> ObjPermission = [Select Id, PermissionsCreate from ObjectPermissions where SobjectType = 'Opportunity' and Parent.Profile.Name = :SLList[0].Owner.Profile.Name];
                if(ObjPermission.size() > 0){
                    if(ObjPermission[0].PermissionsCreate == true){
                        check_OpportunityCreateAccess = false;
                    }
                }
                //V1.5 End
                returnMap.put('check_Convert', check_Convert);
                returnMap.put('check_Warm', check_Warm);
                returnMap.put('check_Account', check_Account);
                returnMap.put('check_MDG', check_MDG);
                returnMap.put('check_Amount', check_Amount);
                returnMap.put('check_CloseDate', check_CloseDate);
                returnMap.put('check_SalesDepartment', check_SalesDepartment);
                returnMap.put('check_RevenueStartDate', check_RevenueStartDate);
                returnMap.put('check_RevenueEndDate', check_RevenueEndDate);
                returnMap.put('check_Type', check_Type);
                returnMap.put('check_SalesOrganization', check_SalesOrganization);
                returnMap.put('check_LeadType', check_LeadType);
                returnMap.put('check_Close', check_Close);
                returnMap.put('check_Contact', check_Contact);
                // V1.2 -> Add new condition when converting sales lead to opportunity in case of lead channel is demand
                returnMap.put('check_LeadTypeDemand', check_LeadTypeDemand);
                returnMap.put('check_OpportunityCreateAccess', check_OpportunityCreateAccess);//V1.5
            }
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
        return returnMap;
    }

    @AuraEnabled
    public static ReturnWrapper getOppLabel(String recordId){
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        
        Schema.SObjectType salesleadSchema = schemaMap.get('Sales_Lead__c');
        Map<String, Schema.SObjectField> SalesleadfieldMap = salesleadSchema.getDescribe().fields.getMap();
        
        Schema.SObjectType oppSchema = schemaMap.get('Opportunity');
        Map<String, Schema.SObjectField> oppfieldMap = oppSchema.getDescribe().fields.getMap();
        
        String selectquery = 'SELECT ';
        Integer i = 1;
        for (String f: SalesleadfieldMap.keySet()) {
            selectquery += f;
            if(i < SalesleadfieldMap.keySet().size()){
                selectquery += ', ';
            }
            i++;
        }
        String fromquery = ' FROM Sales_Lead__c';
        String wherequery = ' WHERE Id = \'' + recordId + '\'';
        wherequery += ' LIMIT 1';
        Sales_Lead__c salesleadVal = Database.query(selectquery + fromquery + wherequery);
        
        System.debug('### getOppLabel, salesleadVal : ' + salesleadVal);
        
        // 2021-02-17  startDate 와 endDate 순서 변경 로직 추가
        Integer idx = 0;
        Integer startidx = 0;
        Integer endidx = 0;
        
        List<Map<String, String>> fieldMaplist  = new List<Map<String, String>>();
        // Name, CurrencyIsoCode, AccountId__c, Amount__c, CampaignId__c, CloseDate__c, Description__c, RevenueStartDate__c, RevenueEndDate__c, Type__c, SalesDepartment__c, SalesOrganization__c
        
        //524
        String uProf;
        User u = new User();
        Id usrId = UserInfo.getUserId();
        u = [Select Id, Profile.Name from User where Id =: usrId ];
        uProf = u.Profile.Name ;
        List<String> apiStr = new List<String>(); 
        if(uProf == 'CxO-Overseas Corp' || uProf == 'Sales Manager(Overseas Corp)' || uProf == 'Sales Rep.(Overseas Corp)' || uProf == 'Sales Rep.(HQ)'){
        apiStr = System.Label.CONVERT_LAB_SALES_LEAD_TARGET_PROFILE.replaceAll(' ' , '').split(',');
        }
        else{
        apiStr = System.Label.CONVERT_LAB_SALES_LEAD_API.replaceAll(' ' , '').split(',');    
        }
        
        System.debug('### getOppLabel, apiStr : ' + apiStr);
        for (String sf: apiStr) {
            String label = SalesleadfieldMap.get(sf).getDescribe().getName();
            String custom = '';
            String standard = '';
            if(sf.indexOf('__c') == -1){
                custom = sf + '__c';
                standard = sf;
            } else {
                custom = sf;
                standard = sf.substring(0,sf.indexOf('__c'));
            }
            
            if(label.equals('RevenueStartDate__c') || label.equals('RevenueEndDate__c')){
                custom = 'c' + custom;
                standard = 'c' + standard;
                if(label.equals('RevenueStartDate__c')){
                    startidx = idx;
                } else {
                    endidx = idx;
                }
            }
            
            Map<String, String> sfMap = new Map<String, String>();
            if(oppfieldMap.get(custom) != null || oppfieldMap.get(standard) != null){
                String key = oppfieldMap.get(custom) == null ? String.valueOf(oppfieldMap.get(standard)) : String.valueOf(oppfieldMap.get(custom));
                String api = oppfieldMap.get(custom) == null ? standard : custom;
                String type = String.valueOf(oppfieldMap.get(api).getDescribe().getType());
                
                sfMap.put('sfName',String.valueOf(SalesleadfieldMap.get(sf).getDescribe().getLabel()));
                sfMap.put('sfValue', salesleadVal.get(sf) == null ? '' : String.valueOf(salesleadVal.get(sf)));
                sfMap.put('sfApi', SalesleadfieldMap.get(sf).getDescribe().getName());
                if(SalesleadfieldMap.get(sf).getDescribe().getName() == 'Amount__c') sfMap.put('sfLabel', String.valueOf(SalesleadfieldMap.get(sf).getDescribe().getLabel()));
                //V1.5 Start
                if(SalesleadfieldMap.get(sf).getDescribe().getName() == 'OwnerId'){
                    String s = String.valueOf(SalesleadfieldMap.get(sf).getDescribe().getLabel());
                    sfMap.put('sfLabel',s.remove('ID').trim());
                }
                //V1.5 End
                sfMap.put('oppName',String.valueOf(oppfieldMap.get(key).getDescribe().getLabel()));
                sfMap.put('oppValue', salesleadVal.get(sf) == null ? '' : String.valueOf(salesleadVal.get(sf)));
                sfMap.put('oppApi',  oppfieldMap.get(api).getDescribe().getName());
                if(oppfieldMap.get(api).getDescribe().getName() == 'Amount') sfMap.put('oppLabel', String.valueOf(oppfieldMap.get(key).getDescribe().getLabel()));
                
                fieldMaplist.add(sfMap);
            }
            idx = idx + 1;
        }
        System.debug('### getOppLabel, fieldMaplist : ' + fieldMaplist);
        List<Map<String, String>> returnlist  = fieldMaplist;
        Map<String, String> startMap = fieldMaplist.get(startidx);
        Map<String, String> endMap = fieldMaplist.get(endidx);
        
        returnlist.set(endidx, startMap);
        returnlist.set(startidx, endMap);
        
        System.debug('### getOppLabel, returnlist : ' + returnlist);
        
        ReturnWrapper rw = new ReturnWrapper(returnlist);
        return rw;
    }
    
    @AuraEnabled
    public static ConvertOppWrapper convertOpp(String recordId, List<Map<String, String>> opplist){
        // 본사 -> opp 변환시 acc 필수
        // 물류 -> opp 변환시 acc 옵션
        // convert 시 해당 opp로 이동
        ConvertOppWrapper cow;
        Database.LeadConvert lc = new Database.LeadConvert();
        Opportunity opp = new Opportunity();
        Sales_Lead__c sl = new Sales_Lead__c();
        String LeadStageVal = '';
        
        try {
            system.debug('Testingggg111'+recordId);
            sl = [SELECT Id, Lead__c, LeadStage__c, OwnerId, recordTypeId, OpportunityName__c, CreatedDate, AccountId__c, CampaignId__c FROM Sales_Lead__c WHERE Id = :recordId LIMIT 1];
            system.debug('Testingggg222'+sl);
            RecordType SLrt = [SELECT DeveloperName FROM RecordType WHERE Id = :sl.recordTypeId LIMIT 1];
            system.debug('Testingggg333'+SLrt);
            List<Account> accList = [SELECT Id, RecordTypeId, Active__c FROM Account WHERE Id = :sl.AccountId__c LIMIT 1];
            system.debug('Testingggg444'+accList);
            RecordType Opprt = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = :SLrt.DeveloperName AND sObjectType='Opportunity' LIMIT 1];
            system.debug('Testingggg555'+Opprt);
            
            if(sl.LeadStage__c == 'Converted'){
                // System.debug('이미 Convert 된 SalesLead');
                cow = new ConvertOppWrapper('', 'WARNNING', System.Label.CONVERT_LAB_MSG11);
                return cow;
            }
            
            LeadStageVal = sl.LeadStage__c;
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType oppSchema = schemaMap.get('Opportunity');
            Map<String, Schema.SObjectField> oppfieldMap = oppSchema.getDescribe().fields.getMap();
            
            String accid = '';
            String ownid = String.valueOf(sl.OwnerId);
            String recordtypeid = String.valueOf(Opprt.Id);
            System.debug('### convertOpp, opplist : ' + opplist);
            for(Integer i=0; i<opplist.size(); i++){
                String type = String.valueOf(oppfieldMap.get(opplist[i].get('Api')).getDescribe().getType());
                if(opplist[i].get('Api') == 'AccountId'){
                    accid = opplist[i].get('Value');
                }
                
                if(opplist[i].get('Value') != '' && !oppfieldMap.get(opplist[i].get('Api')).getDescribe().isCalculated()){
                    system.debug('Check111==>');
                    switch on type {
                        when 'DATE' {
                            opp.put(opplist[i].get('Api'), Date.valueOf(opplist[i].get('Value')));
                            system.debug('Check222==>');
                        }
                        when 'DATETIME' {
                            opp.put(opplist[i].get('Api'), Datetime.valueOf(opplist[i].get('Value')));
                            system.debug('Check333==>');
                        }
                        when 'BOOLEAN' {
                            opp.put(opplist[i].get('Api'), Boolean.valueOf(opplist[i].get('Value')));
                            system.debug('Check444==>');
                        }
                        when 'CURRENCY' {
                            opp.put(opplist[i].get('Api'), Decimal.valueOf(opplist[i].get('Value')));
                            system.debug('Check555==>');
                        }
                        when else {
                            opp.put(opplist[i].get('Api'), opplist[i].get('Value'));
                            system.debug('Check666==>');
                        }
                    }
                }
            }
            system.debug('Testingggg666'+opp);
            system.debug('Testingggg777'+recordId);
            opp.cOriginAcc__c = sl.AccountId__c;
            opp.StageName = 'Z01';
            opp.cLeadID__c = recordId;
            opp.OwnerId = ownid;
            opp.recordTypeId = recordtypeid;
            opp.SensingDate__c = Date.valueOf(sl.CreatedDate);
            System.debug('### convertOpp, opp : ' + opp);
            insert opp;
            
            sl.LeadStage__c = 'Converted';
            sl.LeadStatus__c = 'Close';
            sl.CloseReason__c = 'Opportunity Converted';
            sl.OpportunityName__c = opp.Id;
            update sl;
            
            if (Opprt.DeveloperName == 'HQ' && String.isBlank(accid)) {
                system.debug('Testingggg888');
                if(opp.Id != null){
                    system.debug('Testingggg999');
                    delete opp;
                }
                if(sl.Id != null){
                    system.debug('Testingggg000');
                    sl.OpportunityName__c = null;
                    sl.LeadStage__c = LeadStageVal;
                    update sl;
                }
                system.debug('Return==>'+new ConvertOppWrapper(String.valueOf(sl.Id), 'WARNNING', System.Label.CONVERT_LAB_MSG10));
                return new ConvertOppWrapper(String.valueOf(sl.Id), 'WARNNING', System.Label.CONVERT_LAB_MSG10);
            }
            system.debug('TestinggggNew111'+sl.Lead__c); 
            if(sl.Lead__c != null){
                if((Opprt.DeveloperName == 'HQ' && !String.isBlank(accid)) || (Opprt.DeveloperName == 'Logistics' && !String.isBlank(accid))) {
                     system.debug('TestinggggNew222');
                    lc.setAccountId(accid);
                    lc.setOpportunityId(opp.Id);
                }
                lc.setLeadId(sl.Lead__c);
                lc.setOwnerId(ownid);
                
                LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
                 system.debug('TestinggggNew333'+convertStatus);
                lc.setConvertedStatus(convertStatus.MasterLabel);
                system.debug('NewValue==>');
                Database.LeadConvertResult lcr = Database.convertLead(lc);
                system.debug('ConvertCheckPoint'); // Need to check from here in failing case.
                if(lcr.isSuccess()){
                    system.debug('TestinggggNew444');
                    //cow = new ConvertOppWrapper(String.valueOf(opp.Id), 'SUCCESS', '');
                    
                    List<Sales_Lead__c> slLockList = new List<Sales_Lead__c>();
                    slLockList.add(sl);
                    system.debug('TestingslLockList==>'+slLockList);
                    // Lock the accounts
                    Approval.LockResult[] LockList = Approval.lock(slLockList, false);
                    
                    // Iterate through each returned result
                    for(Approval.LockResult lr : LockList) {
                        if (lr.isSuccess()) {
                             system.debug('TestinggggNew555');
                            // Operation was successful, so get the ID of the record that was processed
                            cow = new ConvertOppWrapper(String.valueOf(opp.Id), 'SUCCESS', '');
                        } else {
                            // Operation failed, so get all errors
                             system.debug('TestinggggNew666');
                            String errorMsg = '';
                            for(Database.Error err : lr.getErrors()) {
                                errorMsg = String.valueOf(err.getMessage());
                            }
                            
                            cow = new ConvertOppWrapper(String.valueOf(opp.Id), 'ERROR', errorMsg);
                            system.debug('Cow Testing==>'+cow);
                        }
                    }
                    
                } else {
                    system.debug('elsetest11'+String.valueOf(opp.Id));
                    system.debug('elsetest22'+JSON.serialize(lcr.getErrors()));
                    cow = new ConvertOppWrapper(String.valueOf(opp.Id), 'ERROR', JSON.serialize(lcr.getErrors()));
                   system.debug('elsetest33'+opp.Id);
                    if(opp.Id != null){
                         system.debug('TestinggggNew777');
                        delete opp;
                    }
                     system.debug('elsetest33'+sl.Id);
                    if(sl.Id != null){
                         system.debug('TestinggggNew888');
                        sl.OpportunityName__c = null;
                        sl.LeadStage__c = LeadStageVal;
                        update sl;
                    }
                }
            } else {
                 system.debug('TestinggggNew999');
                // Lock the accounts
                List<Sales_Lead__c> slLockList = [SELECT Id, OwnerId, IsDeleted, Name, CurrencyIsoCode, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastViewedDate, LastReferencedDate, AccountId__c, Amount__c, Authority__c, Budget__c, CampaignId__c, CloseDate__c, CompanyCode__c, Description__c, ExpectedRevenue__c, LeadStage__c, Lead__c, Needs__c, RevenueEndDate__c, RevenueStartDate__c, SalesDivision__c, SalesTeam__c, TimeLine__c, Type__c, Company__c, Country__c, Email__c, FirstName__c, InterestSubject1__c, InterestSubject2__c, IsConverted__c, LastName__c, MobilePhone__c, PersonalInfoAgreementExpireDate__c, PersonalInfoAgreement__c, Phone__c, Title__c, LeadDescription__c, OpportunityName__c, SalesDepartment__c, SalesOrganization__c, SalesRegion__c 
                                                  FROM Sales_Lead__c
                                                  WHERE Id = : sl.Id];
                system.debug('slLockList==>'+slLockList);
                // Lock the accounts
                    Approval.LockResult[] LockList = Approval.lock(slLockList, false);
                    // Iterate through each returned result
                    for(Approval.LockResult lr : LockList) {
                        if (lr.isSuccess()) {
                             system.debug('TestinggggNew000');
                            // Operation was successful, so get the ID of the record that was processed
                            cow = new ConvertOppWrapper(String.valueOf(opp.Id), 'SUCCESS', '');
                    } else {
                         system.debug('TestinggggNew###11');
                        // Operation failed, so get all errors
                        String errorMsg = '';
                        for(Database.Error err : lr.getErrors()) {
                            errorMsg = String.valueOf(err.getMessage());
                        }
                        system.debug('TestinggggNew###22');
                        cow = new ConvertOppWrapper(String.valueOf(opp.Id), 'ERROR', errorMsg);
                    }
                }
                //cow = new ConvertOppWrapper(String.valueOf(opp.Id), 'SUCCESS', ''); 
            }
            //[SJOSHI(13-Oct-2023)]
            System.debug('#####SJOSHI_COUNT'+Limits.getQueries());
        } catch (Exception e) {
            system.debug('Catch Check');
            cow = new ConvertOppWrapper('', 'ERROR', JSON.serialize(e.getMessage()));
            system.debug('cow'+cow);
            if(opp.Id != null){
                system.debug('Del Opp'+opp);
                delete opp;
            } 
            
            if(sl.Id != null){
                system.debug('sl.Id Not Null'+sl.Id);
                sl.OpportunityName__c = null;
                sl.LeadStage__c = LeadStageVal;
                update sl;
            }
        }
        system.debug('Return Cow '+cow);
        return cow;
    }
    
    @AuraEnabled
    public static Map<String, String> getRecordType(String profileId, String ownerId){
        Map<String, String> resultMap = new Map<String, String>();
        
        Profile p = [SELECT Id, Name FROM Profile WHERE Id = :profileId];
        String profileName = String.valueOf(p.Name);
        String recordTypeId = '';
        RecordType rt = [SELECT Id,Name, DeveloperName FROM RecordType WHERE DeveloperName = 'HQ' AND sObjectType = 'Opportunity' LIMIT 1];
        
        if(profileName.contains('Logi')){
            rt = [SELECT Id,Name, DeveloperName FROM RecordType WHERE DeveloperName = 'Logistics' AND sObjectType = 'Opportunity' LIMIT 1];
        }
        
        recordTypeId = rt.Id;
        
        User u = [SELECT Id, Division, Title FROM User WHERE Id = :ownerId];
        
        resultMap.put('recordTypeId', recordTypeId);
        resultMap.put('Division', u.Division == null ? '' : String.valueOf(u.Division));
        resultMap.put('Title', u.Title == null ? '' : String.valueOf(u.Title));
        
        return resultMap;
    }
    
    public class ReturnWrapper{
        @AuraEnabled
        public List<Map<String, String>> sflist {get; set;}
        @AuraEnabled
        public List<RecordType> rtlist {get; set;}
        
        public ReturnWrapper(List<Map<String, String>> returnlist){
            this.sflist = returnlist;
            this.rtlist = [SELECT Id,Name, DeveloperName FROM RecordType WHERE sObjectType='Opportunity'];
        }
    }
    
    public class ConvertOppWrapper{
        @AuraEnabled
        public String oppId {get; set;}
        @AuraEnabled
        public String isSuccess {get; set;}
        @AuraEnabled
        public String errorMsg {get; set;}
        
        public ConvertOppWrapper(String oppId, String isSuccess, String errorMsg){
            this.oppId = oppId;
            this.isSuccess = isSuccess;
            this.errorMsg = errorMsg;
        }
    }
}