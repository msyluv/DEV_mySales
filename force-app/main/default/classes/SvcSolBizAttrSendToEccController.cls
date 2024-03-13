/**
 * @description       : 
 * @author            : wonjune.oh@partner.samsung.com
 * @group             : 
 * @last modified on  : 2022-01-06
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                           Modification
 * 1.0   2021-01-05   wonjune.oh@partner.samsung.com   Initial Version
**/
public with sharing class SvcSolBizAttrSendToEccController {
    @AuraEnabled
    public static Map<String,String> solBizAttrSendToEcc() {
        Map<String, Object> resMap = new Map<String, Object>();  
        Map<String,String> resList = new Map<String,String>();
        try{
            List<SvcSolBizAttr__c> svcSolBizAttrList = [
                SELECT  Id, BusinessType__c, WBSClass__c, Use__c, PSType__c,
                        BizAttribute__c,
                        BizAttribute__r.Name,
                        BizAttribute__r.Code__c,
                        BizAttribute__r.Active__c, 
                        Solution__c,
                        Solution__r.Name,
                        Solution__r.Code__c,
                        ExternalKey__c
                FROM    SvcSolBizAttr__c
                ORDER BY ExternalKey__c
                LIMIT 10000
                /* WHERE   Solution__c = :solId */
            ];

            Map<String,SvcSolBizAttr__c> bizMap = new Map<String,SvcSolBizAttr__c>();
            for(SvcSolBizAttr__c svcSolBizAttr : svcSolBizAttrList){
                bizMap.put(svcSolBizAttr.ExternalKey__c,svcSolBizAttr); //ExternalKey__c : Soltuion__r.Code__c + '_' + BizAttribute__r.Code__c
            }
            
            IF_EccProjectAttrController.OutputHeader outputHeaderput = new IF_EccProjectAttrController.OutputHeader();  

            outputHeaderput.IT_DATA = new List<IF_EccProjectAttrController.OUTPUT_IT_DATA>();
            outputHeaderput.IT_ORDER_TYPE = new List<IF_EccProjectAttrController.OUTPUT_IT_ORDER_TYPE>();
            
            List<IF_EccProjectAttrController.OUTPUT_IT_DATA> ItDataList = new List<IF_EccProjectAttrController.OUTPUT_IT_DATA>();
            List<IF_EccProjectAttrController.OUTPUT_IT_ORDER_TYPE> ItOrderTypeList = new List<IF_EccProjectAttrController.OUTPUT_IT_ORDER_TYPE>();
            
            // [IF] Input Param
            for(SvcSolBizAttr__c svcSolBizAttr : svcSolBizAttrList){
                
                IF_EccProjectAttrController.OUTPUT_IT_DATA itDatainput = new IF_EccProjectAttrController.OUTPUT_IT_DATA();
                IF_EccProjectAttrController.OUTPUT_IT_ORDER_TYPE itOrderTypeinput = new IF_EccProjectAttrController.OUTPUT_IT_ORDER_TYPE();                                                                                
                
                itDatainput.CLASS_SFDC = svcSolBizAttr.Solution__r.Code__c;
                itDatainput.ZZORDER_TYPE = svcSolBizAttr.BizAttribute__r.Code__c;
                itDatainput.ZOPPT_TYPE = svcSolBizAttr.BusinessType__c;
                itDatainput.ZZWBS_CLASS = svcSolBizAttr.WBSClass__c;
                itDatainput.ZZUSEYN = (svcSolBizAttr.Use__c) ? 'Y' : 'N';
                itDatainput.ZZPS_TYPE = svcSolBizAttr.PSType__c;
                ItDataList.add(itDatainput);

                itOrderTypeinput.SPRAS = 'EN';
                itOrderTypeinput.ZZORDER_TYPE = svcSolBizAttr.BizAttribute__r.Code__c;
                itOrderTypeinput.ZZORDER_TYPE_T = svcSolBizAttr.BizAttribute__r.Name;   //2021.07.06 seonju.jin / Description -> Name
                itOrderTypeinput.ZZUSERYN = (svcSolBizAttr.BizAttribute__r.Active__c) ? 'Y' : 'N';
                ItOrderTypeList.add(itOrderTypeinput);
            }
            
            outputHeaderput.IT_DATA = ItDataList;
            outputHeaderput.IT_ORDER_TYPE = ItOrderTypeList;

            //IF-009 사업기회 속성 제공하기 (CRM -> PS)
            resMap  = IF_EccProjectAttrController.calloutSendProjectAttrInfo(JSON.serialize(outputHeaderput));
            Integer statusCode = Integer.valueOf(resMap.get('StatusCode'));
           
            if(statusCode <= 300) { // S
                Map<String,Object> IF_ResMap = (Map<String,Object>)Json.deserializeUntyped(String.valueOf(resMap.get('Response')));
                System.debug(IF_ResMap);
                Map<String,Object> Es_RtMsgMap = (Map<String,Object>)IF_ResMap.get('ES_RTMSG');
                String resType = String.valueOf(Es_RtMsgMap.get('TYPE'));
                resType = resType.replace('{', '');
                resType = resType.replace('}', '');
                
                resList.put('StatusCode',String.valueOf(resMap.get('StatusCode')));
                resList.put('resType',resType);
                resList.put('Message',String.valueOf(resMap.get('Message')));

                if(IF_ResMap.containsKey('IT_DATA')){
                    List<SvcSolBizAttr__c> updateAttrList = new List<SvcSolBizAttr__c>();
                    List<Object> It_DataList = (List<Object>)IF_ResMap.get('IT_DATA');

                    for(Object obj : It_DataList){
                        Map<String,Object> dataMap = (Map<String,Object>) obj;
                        String SolutionCode = Util_String.nvlStr(dataMap.get('CLASS'));         // 솔루션 코드
                        String bizAttrCode  = Util_String.nvlStr(dataMap.get('ZZORDER_TYPE'));  // 사업속성 코드
                        String psType       = Util_String.nvlStr(dataMap.get('ZZPS_TYPE'));     // PS Type (업데이트 대상)

                        SvcSolBizAttr__c bizAttr = bizMap.get(SolutionCode + '_' + bizAttrCode);
                        if(bizAttr != null){
                            bizAttr.PSType__c = psType;
                            updateAttrList.add(bizAttr);
                        } 
                    }

                    update updateAttrList;
                }

            } else { // F
                System.debug(Util_String.nvlStr(resMap.get('Message')));
                String errorMsg = '[HTTP ' + statusCode + '] ' + Util_String.nvlStr(resMap.get('Message')); // 알림 메세지 값
                resList.put('StatusCode',String.valueOf(resMap.get('StatusCode')));
                resList.put('resType','F');
                resList.put('Message',errorMsg);
            }
        }
        catch(Exception e){
            System.debug('catch : ' + e.getMessage());
            resList.put('StatusCode','F');
            resList.put('resType','F');
            resList.put('Message','F');
        }

        return resList;
        
    }
}