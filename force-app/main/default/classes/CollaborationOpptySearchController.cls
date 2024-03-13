/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 09-30-2021
 * @last modified by  : yeongju.baek@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2020-11-26   younghoon.kim@dkbmc.com   Initial Version
**/
public class CollaborationOpptySearchController {
    @AuraEnabled
    public static List<Map<String, String>> init(){
        Map<String, String> inProgressMap = new Map<String, String>();
        inProgressMap.put('label', 'In Progress');
        inProgressMap.put('value', '1');

        Map<String, String> wonMap = new Map<String, String>();
        wonMap.put('label', 'Won');
        wonMap.put('value', '2');
        
        Map<String, String> lostMap = new Map<String, String>();
        lostMap.put('label', 'Lost & Drop');
        lostMap.put('value', '3');
        
        Map<String, String> ALLMap = new Map<String, String>();
        ALLMap.put('label', 'ALL');
        ALLMap.put('value', '4');
        
        List<Map<String, String>> rtnList = new List<Map<String, String>>();
        rtnList.add(inProgressMap);
        rtnList.add(wonMap);
        rtnList.add(lostMap);
        rtnList.add(ALLMap);

        return rtnList;
    }

    @AuraEnabled
    public static Map<String, String> getCollaboOpptyInfo(Integer limits, Integer offsets, String stage, String oppcode, String oppname){
        Map<String, String> returnMap = new Map<String, String>();

        List<String> adminProfileList = new List<String>{'Custom System Administrator', 'System Administrator', '시스템 관리자'};
        String profileName = [SELECT Id, Name FROM Profile WHERE Id =: UserInfo.getProfileId()].Name;
        
        String query_COUNT = 'SELECT count()';
        String query_SELECT = 'SELECT Id, Name, toLabel(StageName), RecordTypeId, AccountId, Account.Name, Amount, CurrencyIsoCode, CloseDate, OpportunityCode__c, Collaboration__c, CollaborationBOId__c, CollaborationInOut__c, CompanyCode__c, CompanyName__C, IsClosed, IsWon';
        String query_FROM = ' FROM Opportunity';
        String query_WHERE = ' WHERE Collaboration__c = true';
        if(!adminProfileList.contains(profileName)) query_WHERE += ' AND OwnerId = \'' + UserInfo.getUserId() + '\'';
        switch on stage{
            when '1' {
                query_WHERE += ' AND IsClosed = FALSE';
            }
            when '2' {
                query_WHERE += ' AND IsClosed = TRUE AND IsWon = TRUE';
            }
            when '3' {
                query_WHERE += ' AND IsClosed = TRUE AND IsWon = FALSE';
            }
        }
        /* System.debug('CollaborationOpptySearchController#####################################################' );
        System.debug('oppcode : ' + oppcode);
        System.debug('oppname : ' + oppname); */
        if(oppcode != null)query_WHERE += ' AND OpportunityCode__c LIKE \'%'+oppcode+'%\'';
        if(oppname != null)query_WHERE += ' AND Name  LIKE \'%'+oppname+'%\'';
        String query_ORDER = ' ORDER BY CloseDate DESC';
        String query_LIMIT = ' LIMIT ' + String.valueOf(limits);
        String query_OFFSET = ' OFFSET ' + String.valueOf(offsets);

        Integer totalCount = Database.countQuery(query_COUNT + query_FROM + query_WHERE);
        returnMap.put('TOTAL', String.valueOf(totalCount));

        List<Opportunity> opptyList = Database.query(query_SELECT + query_FROM + query_WHERE + query_ORDER + query_LIMIT + query_OFFSET);
        
        returnMap.put('LIST', JSON.serialize(opptyList));

        return returnMap;
    }

    @AuraEnabled
    public static List<Opportunity> getSelectedOppty(String selectedId){
        List<Opportunity> collaboOpptyList = [SELECT Id, Name FROM Opportunity WHERE Id =: selectedId];

        return collaboOpptyList;
    }
}