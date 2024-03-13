/**
 * @author            : younghoon.kim@dkbmc.com
 * @description       : 
 * @last modified on  : 2021-11-12
 * @last modified by  : younghoon.kim@dkbmc.com
 * @Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2021-10-18   younghoon.kim@dkbmc.com   Initial Version
 * 1.1   2021-10-29   younghoon.kim@dkbmc.com   스크롤 로딩 기능 추가
 * 1.2   2021-11-01   younghoon.kim@dkbmc.com   검색 레이아웃 수정, 엑셀 다운로드 기능 추가
**/

global with sharing class WonLostDropListViewController {
    /**
    * @description Won_Lost_Drop__c 오브젝트의 모든 필드 라벨 조회(화면 표시용)
    * @author younghoon.kim@dkbmc.com | 2021-10-21 
    * @return Map<String, String> 
    **/
    @AuraEnabled
    global static Map<String, String> getFieldLabel(){
        Map<String, String> rtnMap = new Map<String, String>();
        rtnMap.put('Object', Utils.getObjectLabel('Won_Lost_Drop__c'));
        rtnMap.put('Field', JSON.serialize(Utils.getFieldLabel('Won_Lost_Drop__c')));

        Map<String, String> defaultMap = new Map<String, String>();
        defaultMap.put('label', System.Label.WONLOSTDROP_LAB_ALL);
        defaultMap.put('value', '');

        List<Map<String, String>> rtnWldTypeMapList = new List<Map<String, String>>();
        rtnWldTypeMapList.add(defaultMap);
        List<Map<String, String>> wldTypeMapList = Utils.getPicklistOptionType('Won_Lost_Drop__c', 'Won_Lost_Drop_Type__c');
        rtnWldTypeMapList.addAll(wldTypeMapList);
        rtnMap.put('WLDType', JSON.serialize(rtnWldTypeMapList));

        Map<String,List<Map<String, String>>> wldReasonMap = Utils.getDependentPicklist(Won_Lost_Drop__c.Won_Lost_Drop_Reason_Type__c);
        rtnMap.put('WLDReasonType', JSON.serialize(wldReasonMap));

        return rtnMap;
    }

    /**
    * @description 검색 조건에 해당하는 데이터 조회
    * @author younghoon.kim@dkbmc.com | 2021-10-28 
    * @param String selectedValue 
    * @return List<Won_Lost_Drop__c> 
    **/
    @AuraEnabled
    global static Map<String, String> getDataList(Integer limits, Integer offsets, String selectedValue, String type){
        Map<String, String> rtnMap = new Map<String, String>();

        List<Won_Lost_Drop__c> resultList = new List<Won_Lost_Drop__c>();
        Integer resultCount = 0;
        String resultMsg = '';

        selectedValue sv = (selectedValue)JSON.deserialize(selectedValue, selectedValue.class);

        String query_Select = 'SELECT ';
        String query_Fields = Utils.retrieveFieldList('Won_Lost_Drop__c');
               query_Fields += ', Opportunity__r.Name, Opportunity__r.OwnerId, Owner.Name ';
               query_Fields += ', toLabel(Won_Lost_Drop_Type__c) Type_Label, toLabel(Won_Lost_Drop_Reason_Type__c) Reason_Label ';
        String query_Count  = ' count() ';
        String query_From   = ' FROM Won_Lost_Drop__c';
        String query_WHERE  = ' WHERE (Title__c LIKE \'%' + sv.Title + '%\')';
        if(String.isNotBlank(sv.opptyCode))     query_WHERE += ' AND (Opportunity_Code__c LIKE \'%' + sv.opptyCode + '%\')';
        if(String.isNotBlank(sv.WLDType))       query_WHERE += ' AND Won_Lost_Drop_Type__c = \'' + sv.WLDType + '\'';
        if(String.isNotBlank(sv.WLDReasonType)) query_WHERE += ' AND Won_Lost_Drop_Reason_Type__c = \'' + sv.WLDReasonType + '\'';
        if(String.isNotBlank((sv.SalesRep).Id)) query_WHERE += ' AND Opportunity__r.OwnerId = \'' + (sv.SalesRep).Id + '\'';
        if(String.isNotBlank((sv.Owner).Id))    query_WHERE += ' AND OwnerId = \'' + (sv.Owner).Id + '\'';
        String query_Order  = ' ORDER BY CreatedDate DESC';
        String query_Limit  = ' LIMIT ' + String.valueOf(limits);
        String query_Offset = ' OFFSET ' + String.valueOf(offsets);
        
        String query_Result = query_Select + query_Fields + query_From + query_WHERE + query_Order;
        if(type == 'List') query_Result += query_Limit + query_Offset;

        try{
            resultList = Database.query(query_Result);
            resultCount = Database.countQuery(query_Select + query_Count + query_From + query_WHERE);

            if(resultCount >= 50000) resultMsg = 'There are too many results according to your search criteria. Please change your search criteria.';
            else resultMsg = 'Success';
        }catch(Exception e){
            System.debug('Error Message : ' + e.getMessage());
            System.debug('Error StackTrace : ' + e.getStackTraceString());
            System.debug('Error Line : ' + e.getLineNumber());

            resultMsg = 'Error : ' + e.getMessage();
        }
        rtnMap.put('LIST', JSON.serialize(resultList));
        rtnMap.put('COUNT', String.valueOf(resultCount));
        rtnMap.put('MESSAGE', resultMsg);

        return rtnMap;
    }

    /**
    * @description 
    * @author younghoon.kim@dkbmc.com | 2021-10-28 
    * @param String lastSelectedValue 
    * @return Map<String, String> 
    **/
    @AuraEnabled
    public static Map<String,String> generateHTML(String lastSelectedValue) {
        Map<String,String> returnMap = new Map<String,String>();
        String resultMsg = '';
        String strippedBody = '';

        Map<String, String> recordMap = getDataList(0, 0, lastSelectedValue, 'Excel');
        if(Integer.valueOf(recordMap.get('COUNT')) > 1000){
            resultMsg = System.Label.BOSEARCH_LAB_EXPORT_LIMIT; // You can download up to 1000. Please reduce the search results to download.
        }else{
            try{
                PageReference html = Page.WonLostDropExcel;
            
                html.getParameters().put('searchKeywords', lastSelectedValue);
    
                Blob b;
                if(Test.isRunningTest()){
                    b = Blob.valueOf('<script>var x;</script><table><tr><td>test</td></tr></table>');
                } else {
                    b = html.getContent();
                }
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
                System.debug('Error Message : ' + e.getMessage());
                System.debug('Error StackTrace : ' + e.getStackTraceString());
                System.debug('Error Line : ' + e.getLineNumber());

                resultMsg = e.getMessage();
            }
        }
        returnMap.put('MSG',resultMsg);
        
        return returnMap;
    }

    // Excel Download용
    public List<excelValue> excelValueList {get; set;}
    /**
    * @description 검색조건에 따른 결과값 조회(Excel Download용)
    * @author younghoon.kim@dkbmc.com | 2021-10-28 
    **/
    public void getDataList(){
        excelValueList = new List<excelValue>();

        selectedValue sv = (selectedValue)JSON.deserialize(ApexPages.currentPage().getParameters().get('searchKeywords'), selectedValue.class);

        String query_Select = 'SELECT ';
        String query_Fields = Utils.retrieveFieldList('Won_Lost_Drop__c');
               query_Fields += ', Opportunity__r.Name, Opportunity__r.OwnerId, Owner.Name ';
               query_Fields += ', toLabel(Won_Lost_Drop_Type__c) Type_Label, toLabel(Won_Lost_Drop_Reason_Type__c) Reason_Label ';
        String query_Count  = ' count() ';
        String query_From   = ' FROM Won_Lost_Drop__c';
        String query_WHERE  = ' WHERE (Title__c LIKE \'%' + sv.Title + '%\')';
        if(String.isNotBlank(sv.opptyCode))     query_WHERE += ' AND (Opportunity_Code__c LIKE \'%' + sv.opptyCode + '%\')';
        if(String.isNotBlank(sv.WLDType))       query_WHERE += ' AND Won_Lost_Drop_Type__c = \'' + sv.WLDType + '\'';
        if(String.isNotBlank(sv.WLDReasonType)) query_WHERE += ' AND Won_Lost_Drop_Reason_Type__c = \'' + sv.WLDReasonType + '\'';
        if(String.isNotBlank((sv.SalesRep).Id)) query_WHERE += ' AND Opportunity__r.OwnerId = \'' + (sv.SalesRep).Id + '\'';
        if(String.isNotBlank((sv.Owner).Id))    query_WHERE += ' AND OwnerId = \'' + (sv.Owner).Id + '\'';
        String query_Order = ' ORDER BY Opportunity_Code__c DESC';
        String query_Limit = ' LIMIT 50000';
        
        try{
            List<Won_Lost_Drop__c> resultList = Database.query(query_Select + query_Fields + query_From + query_WHERE + query_Order + query_Limit);
            if(!resultList.isEmpty()){
                for(Won_Lost_Drop__c wld : resultList){
                    excelValue ev = new excelValue();
                    ev.Title = wld.Title__c;
                    ev.OpptyCode = wld.Opportunity_Code__c;
                    ev.OpptyName = wld.Opportunity__r.Name;
                    ev.AccName = wld.Contract_Account__c;
                    ev.OriginAccName = wld.Origin_Account__c;
                    ev.WLDType = String.valueOf(wld.get('Type_Label'));
                    ev.WLDReasonType = String.valueOf(wld.get('Reason_Label'));
                    ev.OccDate = DateTime.newInstance(wld.Date_of_occurrence__c.year(), wld.Date_of_occurrence__c.month(), wld.Date_of_occurrence__c.day()).format(Utils.getUserDateFormat());
                    ev.SalesRep = wld.Sales_Rep__c;
                    ev.Owner = wld.Owner.Name;
                    ev.CreatedDate = DateTime.newInstance(wld.CreatedDate.year(), wld.CreatedDate.month(), wld.CreatedDate.day()).format(Utils.getUserDateFormat());

                    excelValueList.add(ev);
                }
            }
        }catch(Exception e){
            System.debug('Error Message : ' + e.getMessage());
            System.debug('Error StackTrace : ' + e.getStackTraceString());
            System.debug('Error Line : ' + e.getLineNumber());
        }
    }

    global class selectedValue{
        @AuraEnabled
        global String Title {get; set;}
        @AuraEnabled
        global String OpptyCode {get; set;}
        @AuraEnabled
        global String WLDType {get; set;}
        @AuraEnabled
        global String WLDReasonType {get; set;}
        @AuraEnabled
        global customUser SalesRep {get; set;}
        @AuraEnabled
        global customUser Owner {get; set;}
    }

    global class customUser {
        @AuraEnabled
        global String Id {get; set;}
        @AuraEnabled
        global String Name {get; set;}
    }

    global class excelValue{
        @AuraEnabled
        global String Title {get; set;}
        @AuraEnabled
        global String OpptyCode {get; set;}
        @AuraEnabled
        global String OpptyName {get; set;}
        @AuraEnabled
        global String AccName {get; set;}
        @AuraEnabled
        global String OriginAccName {get; set;}
        @AuraEnabled
        global String WLDType {get; set;}
        @AuraEnabled
        global String WLDReasonType {get; set;}
        @AuraEnabled
        global String OccDate {get; set;}
        @AuraEnabled
        global String SalesRep {get; set;}
        @AuraEnabled
        global String Owner {get; set;}
        @AuraEnabled
        global String CreatedDate {get; set;}
    }
}