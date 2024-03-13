/**
* @description       : Add the LostResult record for amount 0 dropped case.
* @author            : divyam.gupta@samsung.com
* @group             : 
* @last modified on  : 2023-12-10
* @last modified by  : anish.jain@partner.samsung.com 
* Modifications Log 
* Ver   Date         Author                      Modification
* 1.0   2023-09-20   divyam.gupta@samsung.com   Initial Version
* 1.1   2023-12-10   anish.jain@partner.samsung.com  Create IF-159(send drop/lost info to legacy) scheduled batch job (MS-373) Part of MS-216
**/
public class dropActivtyLostResultRecCreation {
    public static void addLostResultforDrop(List<Opportunity_Activity__c> upsertLostOpptyActTargetList,Map<Id,Opportunity_Activity__c> oppactmap){    
        system.debug('calling adddroplost');
        Set<Id> Oppidset = new Set<Id>();
        List<Id> Oppactid = new List<Id>();
        List<LostResult__c> lresultinsrt = new List<LostResult__c>();
        Master_LostType__c Droptyperec = [Select Id, Code__c,Type_Eng__c,Type_Kor__c from Master_LostType__c Where Code__c ='LOST_TYPE_15'];
        for(Opportunity_Activity__c opact: upsertLostOpptyActTargetList){
            Oppactid.add(opact.Id);
        }
        List<LostResult__c> lresultdel = [select id, LostTypeCode__c  from LostResult__c where LostActivity__c IN :Oppactid AND LostActivity__r.Status__c ='Completed' AND LostActivity__r.TransactionName__c ='ZPZ2'];
        List<Opportunity_Activity__c> oppactlist= [select Id,WhatId__c,WhatId__r.CompanyCode__c,Status__c,TransactionName__c from  Opportunity_Activity__c where Id IN :Oppactid];
        for(Opportunity_Activity__c oppact1 : oppactlist){
            if(oppact1.TransactionName__c == 'ZPZ2' && oppact1.Status__c == 'Completed'){
                if(!oppactmap.containskey(oppact1.Id)){
                    Oppidset.add(oppact1.WhatId__c);
                }
                
                String compcode = oppact1.WhatId__r.CompanyCode__c;
                {
                    LostResult__c lostrecd = new LostResult__c();
                    if(compcode == 'T100' || compcode == 'T110'||compcode =='T120' || compcode =='T140'|| compcode =='L1B0' || compcode =='ZB01'){
                        lostrecd.LOST_DETAIL__c = '[금액 0 중도종결] 고객 사업 취소로 인해 금액 0원 변경 품의로 중도 종결 처리되었습니다.';
                        
                    }
                    else {
                        lostrecd.LOST_DETAIL__c = '[Dropped : Amount 0] Due to the cancellation of the customer business, it was dropped with amount 0 approval.';
                        
                    }
                    lostrecd.LostTypeCode__c= 'LOST_TYPE_15';
                    lostrecd.Opportunity__c = oppact1.WhatId__c;
                    lostrecd.LostActivity__c =oppact1.Id;
                    lostrecd.Rate__c =  100;
                    lostrecd.MasterLosttype_Eng__c = Droptyperec.Type_Eng__c;
                    lostrecd.MasterLosttype_Kor__c = Droptyperec.Type_Kor__c;
                    lostrecd.Master_LostType__c = Droptyperec.Id;
                    lostrecd.ApproveStatus__c = 'Completed';
                    lostrecd.IsCheck__c = true;
                    lresultinsrt.add(lostrecd);
                }
            }
        }
        if(lresultinsrt.size() > 0){
            insert lresultinsrt;
        }
        if(lresultdel.size() > 0){
            Delete lresultdel;
        }
        if(Oppidset.size() > 0){
            system.debug('callIF159 from knox');
            
            IF_LostAnalysisCallOutAPIController infoCallout159IF = new IF_LostAnalysisCallOutAPIController(Oppidset);
            //System.enqueueJob(infoCallout159IF); Commented by Anish - v 1.1
        }
    }
    

}