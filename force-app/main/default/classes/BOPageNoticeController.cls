/**
 * @description       : 
 * @author            : kj78.yu@partner.samsung.net
 * @group             : 
 * @last modified on  : 09-22-2023
 * @last modified by  : atul.k1@samsung.com
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   04-20-2022   kj78.yu@partner.samsung.net   Initial Version
 * 1.1   05-27-2022   akash.g@samsung.com           Change functionality for Contract/Origin Account change.
 * 1.2   2022-09-07   hyunhak.roh@dkbmc.com         MSP사업의 수주금액 관리를 위한 안내메세지 요청
 * 1.3   2023-09-20   atul.k1@samsung.com           Task - (Logistics) Create Alert Message
 * 1.4   2024-02-19   anish.jain@partner.samsung.com           BO Review Approval Issue Check (MS-418)
 **/

public class BOPageNoticeController {
    
    @AuraEnabled
    public static Map<String, Object> getCMEnterAlertMsg(String BOId){
        System.debug('### getCMEnterAlertMessage :: BOId = ' + BOId);
        
        Set<String> OPP_CMSP_TYPE = new Set<String> {'CSP', 'MSP', 'SaaS'};
        
        Map<String, Object> resMap = new Map<String, Object>{
            'CMEnterAlertMsg'=> ''  //메시지 있으면 warnning 메시지
        };        
        try {
			List<User> userList = [
                SELECT Id
                FROM User where Id= :UserInfo.getUserId() and CompanyCode__c ='T100' and DefaultCurrencyIsoCode = 'KRW'
            ]; 
            //V 1.1 : Add Is_change_Account__c Field in below SOQL query.
            List<Opportunity> listOppty = [SELECT Id,Is_change_Account__c, isChangeCMSPAmount__c, Amount, CspMspType__c, CMEntAlertCnt__c, CurrencyIsoCode, KRWNoticeCnt__c, Collaboration__c, RecordType.DeveloperName,Amount_Change__c,Opportunity_Review_VRB_Type_Confirm__c,Opportunity_Review_Confirm__c,CompanyCode__c,CollaborationBOId__r.BusinessType__c,BusinessType__c FROM Opportunity where Id= :BOId]; //Added by Atul MySales-296(Amount_Change__c) //Added by Anish-v 1.4
            Opportunity oppty = listOppty[0];
            
            /*List<DatedConversionRate> currencyTypeList = [SELECT Id, IsoCode, ConversionRate, nextStartDate, startDate FROM DatedConversionRate where StartDate <= TODAY AND NextStartDate > TODAY ORDER BY NextStartDate DESC];
        	Map<String , Decimal> isoWithRateMap = new Map<String, Decimal>();
        	for(DatedConversionRate d : currencyTypeList) {
            	isoWithRateMap.put(d.IsoCode , d.ConversionRate);
        	}
            Decimal exchnageRate = (isoWithRateMap.get('USD')/isoWithRateMap.get(oppty.CurrencyIsoCode));
            Decimal USDAmount = (oppty.Amount*exchnageRate).setscale(2);
            System.debug('USD Amount : '+ USDAmount);*/
            
            System.debug('### getCMEnterAlertMessage :: BOId = ' + oppty.CMEntAlertCnt__c);
            
            Boolean isUpdate = false;
            String strMessage = '';
            //OPPTY_MSG_004
            if(OPP_CMSP_TYPE.contains(oppty.CspMspType__c) && (oppty.CMEntAlertCnt__c == 0 || oppty.CMEntAlertCnt__c == null) && oppty.RecordType.DeveloperName == 'HQ'){                            
                //resMap.put('CMEnterAlertMsg', System.label.OPPTY_MSG_004);
                strMessage += '· ' + System.label.OPPTY_MSG_004 + '\n';
                oppty.CMEntAlertCnt__c = 1;
                isUpdate = true;
            }
            if(userList.size() > 0 && oppty.CurrencyIsoCode != 'KRW' && (oppty.KRWNoticeCnt__c == 0 || oppty.KRWNoticeCnt__c == null) 
               && oppty.Collaboration__c == false && oppty.RecordType.DeveloperName == 'HQ'){
                //String message = String.format(System.Label.KRW_NOTICE_MSG, new String[]{String.valueOf(oppty.CurrencyIsoCode)} );
                //resMap.put('KRWNoticeMessage', replaceNewlineToTag(message));
                strMessage += '· ' + String.format(System.Label.KRW_NOTICE_MSG, new String[]{String.valueOf(oppty.CurrencyIsoCode)}) + '\n';
                oppty.KRWNoticeCnt__c = 1;
                isUpdate = true;         
            }
            //START - V 1.1 :  Change functionality for Contract/Origin Account change.
            if(oppty.Is_change_Account__c == true && oppty.RecordType.DeveloperName == 'HQ'){
                strMessage += '· ' + System.label.OPPTY_Info_OriginnAccountChange003 + '\n' ;
                System.debug('If entry strMessage');
                //Added by Anish - v 1.4
                if(oppty.Opportunity_Review_VRB_Type_Confirm__c == '30' && oppty.Opportunity_Review_Confirm__c == true){
                    System.debug('If entry CSP');
                oppty.Is_change_Account__c = false;
                oppty.Opportunity_Review_Biz_Amount__c = null;
                oppty.Opportunity_Review_Checkbox1__c = false;
                oppty.Opportunity_Review_Checkbox2__c = false;
                oppty.Opportunity_Review_Consortium__c = false;
                oppty.Opportunity_Review_VRB_Type__c = null;
                oppty.Opportunity_Review_VRB_Type_Confirm__c = null;
                oppty.Opportunity_Review_Dangerous__c = null;
                oppty.Opportunity_Review_Result__c = null;
                oppty.Opportunity_Review_Confirm__c = false;
                oppty.Opportunity_Review_Exception__c = false;
                oppty.Opportunity_Review_Exception_Reason__c = null;
                oppty.Opportunity_Review_Exception_Modifier__c = null;
                oppty.Opportunity_Review_Temp_Save__c = false;
                oppty.Opportunity_Review_cOriginAcc__c = null;
                oppty.Opportunity_Review_Account__c = null;
                oppty.VRB_Account_Change__c = true;
                   
                }
                else{
                    System.debug('If entry MSP');
                oppty.VRB_Account_Change__c = true; //Added by Anish - v 1.4
                oppty.Is_change_Account__c = false;
                oppty.Opportunity_Review_Biz_Amount__c = null;
                oppty.Opportunity_Review_Checkbox1__c = false;
                oppty.Opportunity_Review_Checkbox2__c = false;
                oppty.Opportunity_Review_Consortium__c = false;
                oppty.Opportunity_Review_VRB_Type__c = null;
                oppty.Opportunity_Review_VRB_Type_Confirm__c = null;
                oppty.Opportunity_Review_Dangerous__c = null;
                oppty.Opportunity_Review_Result__c = null;
                oppty.Opportunity_Review_Confirm__c = false;
                oppty.Opportunity_Review_Exception__c = false;
                oppty.Opportunity_Review_Exception_Reason__c = null;
                oppty.Opportunity_Review_Exception_Modifier__c = null;
                oppty.Opportunity_Review_Temp_Save__c = false;
                oppty.Opportunity_Review_cOriginAcc__c = null;
                oppty.Opportunity_Review_Account__c = null;
                }
                List<Opportunity_Activity__c> reviewOppActivityList = [Select id from Opportunity_Activity__c where WhatID__c =: oppty.Id AND TransactionName__c = 'ZP21'  Limit 1]; 
                if(oppty.Collaboration__c == true){
                    if(oppty.CompanyCode__c == 'T100' && (oppty.CollaborationBOId__r.BusinessType__c == 'TI' || oppty.BusinessType__c == 'TI')){
                if(reviewOppActivityList.size() > 0){
                    reviewOppActivityList[0].status__c = 'In Progress';
                    update reviewOppActivityList;
                }
                    }
                    if(oppty.CompanyCode__c != 'T100' && (oppty.CollaborationBOId__r.BusinessType__c == 'TI' || oppty.BusinessType__c == 'TI')){
                if(reviewOppActivityList.size() > 0){
                    reviewOppActivityList[0].status__c = 'In Progress';
                    update reviewOppActivityList;
                }
                }
                }
                if(oppty.Collaboration__c == false && oppty.BusinessType__c == 'TI'){
                if(reviewOppActivityList.size() > 0){
                    reviewOppActivityList[0].status__c = 'In Progress';
                    update reviewOppActivityList;
                }    
                }
                isUpdate = true;  
            }
            //END - V 1.1 :  Change functionality for Contract/Origin Account change.
            //2022-09-07, hyunhak.roh@dkbmc.com, MSP사업의 수주금액 관리를 위한 안내메세지 요청
            if('MSP'.equals(oppty.CspMspType__c) && oppty.isChangeCMSPAmount__c == true && oppty.RecordType.DeveloperName == 'HQ'){
				strMessage += '· ' + System.label.OPPTY_ERR_021 + '\n' ;                //Please update the MSP Amount of CSP / MSP Detail.
                oppty.isChangeCMSPAmount__c = false;
                
                isUpdate = true;
            }
            //if(USDAmount >= 10000000 && oppty.RecordType.DeveloperName == 'Logistics'){
            // Atul Start MySales-296 V 1.3
            if(oppty.Amount_Change__c == true){
                strMessage += '· '+ System.label.OPPTY_ERR_029 + '\n' ; 
                isUpdate = true;
            }
            // Atul End MySales-296 V 1.3
            if(isUpdate){
                resMap.put('CMEnterAlertMsg', strMessage);
                resMap.put('OpptyDetail', oppty); //Added by Anish - v 1.4
                oppty.Amount_Change__c = false;        // Atul MySales-296 V 1.3
                update oppty;
            } 
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return resMap;
    }
    private static String replaceNewlineToTag(String longText) {
        return longText.replace('\n', '<br/>');
    }
}