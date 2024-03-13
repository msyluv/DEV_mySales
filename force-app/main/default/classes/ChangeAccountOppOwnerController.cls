/**
* @author            : divyam.gupta@samsung.com
* @group             :
* @description       : Apex class for Change Account/Opportunity Owner Screen Aura component.
* @last modified on  : 2022-09-02
* @last modified by  : divyam.gupta@samsung.com
* Modifications Log
* Ver   Date         Author                    Modification
* 1.0   2022-08-17   Divyam.Gupta@samsung.com  Initial Version
**/
public class ChangeAccountOppOwnerController {
    @AuraEnabled
    public static Map<String,String> getAccInfo(String accnumber){
        List<Account> acc = new List<Account>();
        Map<String,String> accmap = new Map<String,String>();
        if(accnumber == '' || accnumber== null){
                        accmap.put('Accblank','Blank');

        }
        else if(accnumber != '' || accnumber != null){
        acc = [select Name, OwnerId,Owner.Name from account where AccountNumber =:accnumber Limit 1];
         if(acc.size() == 1){
            accmap.put('Validacc',JSON.serialize(acc[0]));
            system.debug('the acc result'+acc[0]);
        }
        else if(acc.size() == 0){
            accmap.put('error',null);
        }
        }
        return accmap;
    }
    
    @AuraEnabled
    public static Map<String,String> getOppInfo(String opportunityCode){
        Map<String,String> oppmap = new Map<String,String>();
        List<Opportunity> oppList = new List<Opportunity>();
        oppList=[select Id,Name,CompanyCode__c, OwnerId,Owner.Name from Opportunity where OpportunityCode__c=:opportunityCode ];
        system.debug('the size of opplist:'+oppList.size());
        for(Opportunity opp : oppList){
            if(opplist.size() == 1 ){
                oppmap.put('NO_Collabaration',JSON.serialize(opp));
                 system.debug('the map of opp1'+oppmap);
            }
            else if(oppList.size() == 2 ){
                if(opp.CompanyCode__c == 'T100'){
                    oppmap.put('HQ',JSON.serialize(opp));
                     system.debug('the map of opp2'+oppmap);
                }
                else{
                    oppmap.put('Subsidiary',JSON.serialize(opp));
                }
            }
            else if(oppList.size() == 0 ){
                oppmap.put('error',null);
            }
        }
        system.debug('the map of opp'+oppmap);
        return oppmap;
    }
    
   
    @AuraEnabled
    public static account updateAcc(String accnumber, String searchUserAcc){
        Account updateAcc = new Account();
        updateAcc= [select Name, OwnerId from account where AccountNumber =:accnumber ];
        system.debug('the ownerid' + searchUserAcc);
        updateAcc.OwnerId= searchUserAcc;
        update updateAcc;
        system.debug('updated owner' + updateAcc.OwnerId);
        return updateAcc;
    }
    @AuraEnabled
    public static Map<String,String> updateOpp(String oppcode, String searchUserOpp, String compcode){
        Opportunity updateOpp = new Opportunity();
        Map<String,String> mapopp1 = new Map<String,String>();
        updateOpp=[select Id,Name,CompanyCode__c, OwnerId from Opportunity where OpportunityCode__c=:oppcode AND CompanyCode__c=:compcode limit 1];       
        
        updateOpp.OwnerId= searchUserOpp;
        update updateOpp;
        system.debug('updated owner' + updateOpp.OwnerId);
        mapopp1.put('Owner_udpated',JSON.serialize(updateOpp));
           
        return mapopp1;
    }
    
}