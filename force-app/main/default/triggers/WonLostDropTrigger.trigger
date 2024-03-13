/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2021-10-28
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                              Modification
 * 1.0   2021-10-27   younghoon.kim@dkbmc.com             Initial Version / duplicateCheck, copyCurrency 추가
**/
trigger WonLostDropTrigger on Won_Lost_Drop__c (before insert, before update) {
    switch on trigger.operationType{
        when BEFORE_INSERT{
            duplicateCheck(Trigger.new);
            copyCurrency(Trigger.new);
        }
        when BEFORE_UPDATE{
            duplicateCheck(Trigger.new);
            copyCurrency(Trigger.new);
        }
    }
    
    /**
    * @description 수주실주중도종결 중복체크 - 각 사업기회 별 Won / Lost / Drop 1건씩만 등록 가능
    * @author younghoon.kim@dkbmc.com | 2021-10-27 
    * @param List<Won_Lost_Drop__c> newList 
    **/
    private static void duplicateCheck(List<Won_Lost_Drop__c> newList){
        Map<String, String> duplicateCheckMap = new Map<String, String>();
        Set<String> opptyIdSet = new Set<String>();
        for(Won_Lost_Drop__c wld : newList){
            opptyIdSet.add(wld.Opportunity__c);
        }

        if(!opptyIdSet.isEmpty()){
            List<Won_Lost_Drop__c> wldList = [SELECT Id, Name, Opportunity__c, Won_Lost_Drop_Type__c FROM Won_Lost_Drop__c WHERE Opportunity__c = :opptyIdSet];
            for(Won_Lost_Drop__c wld : wldList){
                duplicateCheckMap.put(wld.Opportunity__c + '_' + wld.Won_Lost_Drop_Type__c, wld.Id);
            }
        }

        for(Won_Lost_Drop__c wld : newList){
            if(duplicateCheckMap.get(wld.Opportunity__c + '_' + wld.Won_Lost_Drop_Type__c) != null && duplicateCheckMap.get(wld.Opportunity__c + '_' + wld.Won_Lost_Drop_Type__c) != wld.Id) wld.addError(System.Label.WONLOSTDROP_MSG_0001); // There is already registered data.
        }
    }

    /**
    * @description 사업기회의 Currency를 수주실주중도종결에도 동일하게 적용
    * @author younghoon.kim@dkbmc.com | 2021-10-27 
    * @param List<Won_Lost_Drop__c> newList 
    **/
    private static void copyCurrency(List<Won_Lost_Drop__c> newList){
        Map<String, String> opptyCurrncyMap = new Map<String, String>();
        Set<String> opptyIdSet = new Set<String>();
        for(Won_Lost_Drop__c wld : newList){
            opptyIdSet.add(wld.Opportunity__c);
        }

        if(!opptyIdSet.isEmpty()){
            List<Opportunity> opptyList = [SELECT Id, Name, CurrencyIsoCode FROM Opportunity WHERE Id = :opptyIdSet];
            for(Opportunity oppty : opptyList){
                opptyCurrncyMap.put(oppty.Id, oppty.CurrencyIsoCode);
            }
        }

        for(Won_Lost_Drop__c wld : newList){
            wld.CurrencyIsoCode = opptyCurrncyMap.get(wld.Opportunity__c);
        }
    }
}