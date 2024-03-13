/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2021-04-28
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2021-01-28   younghoon.kim@dkbmc.com   Initial Version
**/
global class AccountExternalInfoController {
    @AuraEnabled    
    public static String accountInfoCheck(String recordId){
        String rtnValue = '';
        Account acc = [SELECT Id, Name, CorporateNumber__c FROM Account WHERE Id =: recordId];

        if(acc.CorporateNumber__c != null) rtnValue = acc.CorporateNumber__c;

        return rtnValue;
    }

    @AuraEnabled
    public static Map<String, String> getExternalInformation(String corpNum){
        Map<String, String> rtnMap = new Map<String, String>();
        rtnMap.put('RESULT', '');
        rtnMap.put('MESSAGE', '');
        rtnMap.put('DATA', '');

        try{
            IF_RpaGetAccountInfoSchController.OutputHeader inputData = new IF_RpaGetAccountInfoSchController.OutputHeader();
            inputData.CorporateNumber = corpNum;

            Map<String,Object> resultMap = IF_RpaGetAccountInfoSchController.getAccountInfoSch(JSON.serialize(inputData));
            HttpResponse hRes = (HttpResponse)resultMap.get('HttpResponse');
            Map<String, Object> bodyMap = (Map<String, Object>)JSON.deserializeUntyped(hRes.getBody());
            System.debug('bodyMap : ' + bodyMap);
            System.debug('IT_DATA : ' + bodyMap.get('IT_DATA'));
            System.debug('IT_FINANCE : ' + bodyMap.get('IT_FINANCE'));
            System.debug('IT_HISTORY : ' + bodyMap.get('IT_HISTORY'));
            System.debug('IT_MANAGER : ' + bodyMap.get('IT_MANAGER'));
            System.debug('INTERFACE_LOG : ' + resultMap.get('INTERFACE_LOG'));

            // External Info Data
            if(bodyMap.get('IT_DATA') != null){
                rtnMap.put('RESULT', 'S');
                rtnMap.put('MESSAGE', 'SUCCESS');
                rtnMap.put('DATA', JSON.serialize(bodyMap.get('IT_DATA')));
            }else{
                rtnMap.put('RESULT', 'E');
                rtnMap.put('MESSAGE', (String)bodyMap.get('EV_MESSAGE'));
                rtnMap.put('DATA', '');
            }

            // Finance Data
            if(bodyMap.get('IT_FINANCE') != null) rtnMap.put('FINANCE', JSON.serialize(bodyMap.get('IT_FINANCE')));

            // History Data
            if(bodyMap.get('IT_HISTORY') != null) rtnMap.put('HISTORY', JSON.serialize(bodyMap.get('IT_HISTORY')));

            // Manager Data
            if(bodyMap.get('IT_MANAGER') != null) rtnMap.put('MANAGER', JSON.serialize(bodyMap.get('IT_MANAGER')));

            if(resultMap.get('INTERFACE_LOG') != null){
                IF_Log.InterfaceLog ifLog = (IF_Log.InterfaceLog) resultMap.get('INTERFACE_LOG');
                IF_Log log = new IF_Log(); 
                log.createLog(ifLog);
            } 

        }catch(Exception e){
            System.debug('ERROR : ' + e.getMessage());
            rtnMap.put('RESULT', 'E');
            rtnMap.put('MESSAGE', System.Label.EXINFO_MSG_0003); // Interface Error (IF-026)
            rtnMap.put('DATA', '');
        }
        
        return rtnMap;
    }

    @AuraEnabled
    public static Map<String, String> accInfoSave(String recordId, String exInfoData, String financeList, String historyList, String managerList){
        System.debug('exInfoData : ' + exInfoData);
        System.debug('financeList : ' + financeList);
        System.debug('historyList : ' + historyList);
        System.debug('managerList : ' + managerList);

        Map<String, String> rtnMap = new Map<String, String>();

        try{
            it_data exData = (it_data)JSON.deserialize(exInfoData, it_data.class);
            System.debug('exData : ' + exData);

            Account account = [SELECT Id
                                    , Name
                                    , RecordTypeId
                                    , RecordType.Name
                                    , AccountNumber
                                    , eInfoSource__c
                                    , eAccName__c
                                    , eAccNameE__c
                                    , eCEOName__c
                                    , eAddress__c
                                    , ePhoneNum__c
                                    , eFaxNum__c
                                    , eHomepage__c 
                                    , mAccNameE__c
                                    , mCEOName__c
                                    , BillingStreet
                                    , ShippingStreet
                                    , Phone
                                    , Fax
                                    , Website
                                 FROM Account 
                                WHERE Id =: recordId];

            account.eInfoSource__c = exData.InfoSource; // 외부 정보 소스
            account.eAccName__c = exData.NameKR; // 고객명
            account.eAccNameE__c = exData.NameEN; // 고객명(E)
            account.eCEOName__c = exData.CeoName; // 대표자명
            account.eAddress__c = exData.Address; // 고객주소
            account.ePhoneNum__c = exData.Phone; // 대표 전화번호
            account.eFaxNum__c = exData.Fax; // Fax 번호
            account.eHomepage__c = exData.Website; // 홈페이지
            account.eUpdateDateB__c = exData.UpdateDate; // 수정일자(B)
            
            // 아래 3개의 필드는 외부 정보 소스가 'OpenDart'인 경우에만 입력
            if(exData.InfoSource == 'OpenDart') account.eIndustryCode__c = exData.IndustryCode; // 업종 코드
            if(exData.InfoSource == 'OpenDart') account.eCorporateNum__c = exData.CustRegNo; // 사업자번호
            if(exData.InfoSource == 'OpenDart') account.eEstablishmentDate__c = exData.EstDate; // 설립일자

            // '고객 정보' 섹션과 '주소 정보' 섹션의 정보는 값이 없는 경우에만 입력
            if(account.RecordType.Name == 'Salesforce'){
                if(account.Name == '' || account.Name == null) account.Name = exData.NameKR;
                if(account.mAccNameE__c == '' || account.mAccNameE__c == null) account.mAccNameE__c = exData.NameEN;
                if(account.mCEOName__c == '' || account.mCEOName__c == null) account.mCEOName__c = exData.CeoName;
                if(account.BillingStreet == '' || account.BillingStreet == null) account.BillingStreet = exData.Address;
                if(account.ShippingStreet == '' || account.ShippingStreet == null) account.ShippingStreet = exData.Address;
                if(account.Phone == '' || account.Phone == null) account.Phone = exData.Phone;
                if(account.Fax == '' || account.Fax == null) account.Fax = exData.Fax;
                if(account.Website == '' || account.Website == null) account.Website = exData.Website;
            }

            update account;
            
            List<it_finance> list_Finance = (List<it_finance>)JSON.deserialize(financeList, List<it_finance>.class);
            List<it_history> list_History = (List<it_history>)JSON.deserialize(historyList, List<it_history>.class);
            List<it_manager> list_Manager = (List<it_manager>)JSON.deserialize(managerList, List<it_manager>.class);
            
            List<Financialinformation__c> fiList = new List<Financialinformation__c>();
            List<AccountHistory__c> ahList = new List<AccountHistory__c>();
            List<ExecutiveInformation__c> eiList = new List<ExecutiveInformation__c>();

            if(list_Finance.size() > 0){
                System.debug('list_Finance : ' + list_Finance); 
                for(it_finance finance : list_Finance){
                    System.debug('finance : ' + finance);
                    if(finance.BizRegNo != null){
                        Financialinformation__c fi = new Financialinformation__c();
                        fi.Account__c = recordId;
                        fi.BizRegNo__c = finance.BizRegNo;
                        fi.InformationSource__c = finance.InformationSource;
                        fi.Name = finance.Name;
                        fi.NetIncome__c = Decimal.valueOf(finance.NetIncome);
                        fi.OperatingProfit__c = Decimal.valueOf(finance.OperatingProfit);
                        fi.Revenue__c = Decimal.valueOf(finance.Revenue);
                        fi.TotalAssets__c = Decimal.valueOf(finance.TotalAssets);
                        fi.TotalCapital__c = Decimal.valueOf(finance.TotalCapital);
                        fi.TotalLiabilities__c = Decimal.valueOf(finance.TotalLiability);

                        //Upsert 를 위한 Key값
                        // fi.ExternalId__c = account.AccountNumber + '_' + finance.BizRegNo +'_'+ finance.InformationSource +'_'+ finance.Name;
                        fi.ExternalId__c = recordId + '_' + finance.BizRegNo +'_'+ finance.InformationSource +'_'+ finance.Name;
    
                        fiList.add(fi);
                    }
                }
                if(fiList.size() > 0) upsert fiList ExternalId__c;
            }
            if(list_History.size() > 0){ 
                System.debug('list_History : ' + list_History); 
                for(it_history history : list_History){
                    System.debug('history : ' + history);
                    if(history.BizRegNo != null){
                        AccountHistory__c ah = new AccountHistory__c();
                        ah.Account__c = recordId;
                        ah.BizRegNo__c = history.BizRegNo;
                        ah.Description__c = history.Description;
                        ah.HistoryDate__c = history.HistoryDate;
                        ah.InformationSource__c = history.InfoSource;

                        //삭제를 위한 Key값
                        // ah.DeleteExtId__c = account.AccountNumber + '_' + history.bizRegNo +'_'+ history.InfoSource;
                        // ah.ExternalId__c = account.AccountNumber + '_' + history.bizRegNo +'_'+ history.InfoSource +'_'+ history.HistoryDate;
                        ah.DeleteExtId__c = recordId + '_' + history.bizRegNo +'_'+ history.InfoSource;
                        ah.ExternalId__c = recordId + '_' + history.bizRegNo +'_'+ history.InfoSource +'_'+ history.HistoryDate;

                        ahList.add(ah);
                    }
                }
                if(ahList.size() > 0) upsert ahList ExternalId__c;
            }
            if(list_Manager.size() > 0){ 
                System.debug('list_Manager : ' + list_Manager); 
                for(it_manager manager : list_Manager){
                    System.debug('manager : ' + manager);
                    if(manager.BizRegNo != null){
                        ExecutiveInformation__c ei = new ExecutiveInformation__c();
                        ei.Account__c = recordId;
                        ei.BizRegNo__c = manager.BizRegNo;
                        ei.InfoSource__c = manager.InfoSource;
                        ei.SeqNo__c = manager.SeqNo;
                        ei.ExecName__c = manager.ExecName;
                        ei.Gender__c = manager.Gender;
                        ei.BirthDay__c = manager.BirthDay;
                        ei.JobTitle__c = manager.JobTitle;
                        ei.RegisteredExecutive__c = manager.RegisteredExecutive;
                        ei.WorkingType__c = manager.WorkingType;
                        ei.JobDescription__c = manager.JobDescription;
                        ei.Description__c = manager.Description;
                        ei.StockHolder__c = manager.StockHolder;
                        ei.EmploymentPeriod__c = manager.EmploymentPeriod;
                        ei.ExpirationDay__c = manager.ExpirationDay;
    
                        //Upsert 를 위한 Key값
                        // ei.ExternalId__c = account.AccountNumber + '_' + manager.BizRegNo +'_'+ manager.InfoSource +'_'+ manager.SeqNo;
                        ei.ExternalId__c = recordId + '_' + manager.BizRegNo +'_'+ manager.InfoSource +'_'+ manager.SeqNo;

                        eiList.add(ei);
                    }
                }
                if(eiList.size() > 0) upsert eiList ExternalId__c;
            }

            rtnMap.put('RESULT', 'S');
            rtnMap.put('MESSAGE', System.Label.EXINFO_MSG_0004); // Account information update success.
        }catch(Exception e){
            System.debug('ERROR : ' + e.getMessage());
            rtnMap.put('RESULT', 'E');
            rtnMap.put('MESSAGE', 'ERROR : ' + e.getMessage());
        }
        
        return rtnMap;
    }

    global class it_data {
        @AuraEnabled
        global String InfoSource {get; set;}
        @AuraEnabled
        global String NameKR {get; set;}
        @AuraEnabled
        global String NameEN {get; set;}
        @AuraEnabled
        global String CeoName {get; set;}
        @AuraEnabled
        global String Address {get; set;}
        @AuraEnabled
        global String Phone {get; set;}
        @AuraEnabled
        global String Fax {get; set;}
        @AuraEnabled
        global String Website {get; set;}
        @AuraEnabled
        global String CustRegNo {get; set;}
        @AuraEnabled
        global String JurirNo {get; set;}
        @AuraEnabled
        global String EstDate {get; set;}
        @AuraEnabled
        global String IndustryCode {get; set;}
        @AuraEnabled
        global String UpdateDate {get; set;}
    }

    global class it_finance  {
        @AuraEnabled
        global String BizRegNo {get; set;}
        @AuraEnabled
        global String InformationSource {get; set;}
        @AuraEnabled
        global String Name {get; set;}
        @AuraEnabled
        global String NetIncome {get; set;}
        @AuraEnabled
        global String OperatingProfit {get; set;}
        @AuraEnabled
        global String Revenue {get; set;}
        @AuraEnabled
        global String TotalAssets {get; set;}
        @AuraEnabled
        global String TotalCapital {get; set;}
        @AuraEnabled
        global String TotalLiability {get; set;}
    }

    global class it_history  {
        @AuraEnabled
        global String BizRegNo {get; set;}
        @AuraEnabled
        global String Description {get; set;}
        @AuraEnabled
        global String HistoryDate {get; set;}
        @AuraEnabled
        global String InfoSource {get; set;}
    }

    global class it_manager  {
        @AuraEnabled
        global String BizRegNo {get; set;}
        @AuraEnabled
        global String InfoSource {get; set;}
        @AuraEnabled
        global String SeqNo {get; set;}
        @AuraEnabled
        global String ExecName {get; set;}
        @AuraEnabled
        global String Gender {get; set;}
        @AuraEnabled
        global String BirthDay {get; set;}
        @AuraEnabled
        global String JobTitle {get; set;}
        @AuraEnabled
        global String RegisteredExecutive {get; set;}
        @AuraEnabled
        global String WorkingType {get; set;}
        @AuraEnabled
        global String JobDescription {get; set;}
        @AuraEnabled
        global String Description {get; set;}
        @AuraEnabled
        global String StockHolder {get; set;}
        @AuraEnabled
        global String EmploymentPeriod {get; set;}
        @AuraEnabled
        global String ExpirationDay {get; set;}
    }
}