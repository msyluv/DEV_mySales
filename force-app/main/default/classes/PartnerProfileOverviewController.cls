/**
 * @description       : 
 * @author            : ukhyeon.lee@samsung.com
 * @group             : 
 * @last modified on  : 08-30-2022
 * @last modified by  : ukhyeon.lee@samsung.com
**/
public without sharing class PartnerProfileOverviewController {
    
    @AuraEnabled(cacheable=true)
    public static Account getUserAccountInformation(String recId) {
        if(Utils.isAdmin()){
            return [SELECT Id, Name FROM Account WHERE isPartner=true AND isDeleted=false LIMIT 1];
        }
        return [SELECT Id, Name From Account WHERE Id IN (SELECT AccountId FROM User WHERE Id=:recId) LIMIT 1];
    }


    @AuraEnabled(cacheable=true)
    public static Map<String, Object> partnerProfileOverview(String recId) {
        Map<String, Object> resultMap = new Map<String, Object>();
        
        //Check current user is admin
        if(Utils.isAdmin()){
            resultMap.put('adminAccountList', [SELECT Id, Name FROM Account WHERE isPartner=true AND isDeleted=false]);
        }

        //Account
        List<Account> accountList = [SELECT Id, Name, Partner_Type__c, Phone, Website, CorporateNumber__c, BillingStreet FROM Account WHERE isDeleted = false AND Id=: recId];
        if(!accountList.isEmpty()){
            Account account = accountList[0];
            resultMap.put('account', account);

            //Partner_Business_Management__c : Sum of Amount, Project Name
            List<Partner_Business_Management__c> pbmList = [SELECT Id, Project_Name__c, Amount__c FROM Partner_Business_Management__c WHERE isDeleted = false AND Partner_Account__c=:account.Id ORDER BY CreatedDate DESC];
            Decimal totalAmount = 0;
            String projectName = '';
            if(!pbmList.isEmpty()){
                projectName = pbmList[0].Project_Name__c;
                for(Partner_Business_Management__c pbm : pbmList){
                    totalAmount += pbm.Amount__c;
                }
            }
            resultMap.put('totalAmount', totalAmount);
            resultMap.put('projectName', projectName);

            //Partnership_Info__c
            List<Partnership_Info__c> partnershipInfoList = [SELECT Contract_End_Date__c, Contract_Start_Date__c, Partner_Grade__c, SDS_PDM__r.Name, SDS_SA__r.Name, Partner_Manager__r.Name, Partner_Manager__r.Email FROM Partnership_Info__c WHERE isDeleted = false AND Account__c=:account.Id LIMIT 1];
            if(!partnershipInfoList.isEmpty()){
                Partnership_Info__c partnerShipInfo = partnershipInfoList[0];
                resultMap.put('partnershipInfo', partnerShipInfo);
            }
            
            //Partner Network User List
            List<User> userList = [SELECT Id, AccountId, Name, Contact.Title, Contact.MSP_Role__c, Email, Profile.Name, Phone, CreatedDate FROM User WHERE isActive = true AND AccountId=:account.Id];
            if(!userList.isEmpty()){
                resultMap.put('userList', userList);
            }
            
            //Partner_ReAuth_Requirement__c
            List<Partner_ReAuth_Requirement__c> prrList = [SELECT Id, toLabel(Category__c),  toLabel(Detail1__c),  toLabel(Detail2__c), Goal__c, Performance__c, Achievability__c FROM Partner_ReAuth_Requirement__c WHERE Account__c=:account.Id AND isDeleted=false ORDER BY Category__c, Detail1__c, Detail2__c];
            if(!prrList.isEmpty()){

                //Group by category for rowspan
                List<AggregateResult> agg = [SELECT tolabel(Category__c) CATEGORY, COUNT(account__c) CNT FROM Partner_ReAuth_Requirement__c WHERE Account__c=:account.Id AND isDeleted=false GROUP BY Category__c ORDER BY Category__c ];

                Map<String, Integer> countMap = new Map<String, Integer>(); //set the category rowspan
                Map<String, Boolean> achieveMap = new Map<String, Boolean>(); //search detail2 Achievability for set detail1 Achievability
                Map<String, Boolean> level1Map = new Map<String, Boolean>(); // search detail1 and detail2(goal and performance are not null) for set category's Achievability
                Boolean isTotal = true;

                for (AggregateResult data  : agg) {
                    //Rowspan
                    countMap.put(String.valueOf(data.get('CATEGORY')), Integer.valueOf(data.get('CNT')));
                }
                
                for(Partner_ReAuth_Requirement__c prr : prrList){
                    if(countMap.get(String.valueOf(prr.Category__c))!=null){
                        //set first row's rowspan and remove from countMap
                        prr.rowspan__c = countMap.get(prr.Category__c);
                        countMap.remove(prr.Category__c);
                    }

                    if(prr.Detail2__c==null && prr.Goal__c==null && prr.Performance__c==null){
                        achieveMap.put(prr.Detail1__c, true);
                    } else if(prr.Detail2__c!=null){
                        if(!prr.Achievability__c){
                            achieveMap.put(prr.Detail1__c, false);
                        }
                    } 

                    //Level 1 Check
                    if(prr.Goal__c!=null || prr.Performance__c!=null){
                        if(prr.Achievability__c && level1Map.get(prr.Category__c)==null){
                            level1Map.put(prr.Category__c, true);
                        } else if(!prr.Achievability__c){
                            level1Map.put(prr.Category__c, false);
                        }
                    }

                    //Total check
                    if(prr.Goal__c!=null && prr.Performance__c!=null && !prr.Achievability__c){
                        isTotal = false;
                    }
                }


                for(Partner_ReAuth_Requirement__c prr : prrList){
                    if(prr.Detail2__c==null && prr.Goal__c==null && prr.Performance__c==null){
                        if(achieveMap.get(prr.Detail1__c)){
                            prr.Performance__c = '달성';  //Detail1's Achievability__c(view side)               
                        } else{
                            prr.Performance__c = '미달성'; //Detail1's Achievability__c(view side)                 
                        }
                        if(level1Map.get(prr.Category__c)){
                            prr.Goal__c = '달성'; //category's Achievability__c(view side)                                    
                        } else{
                            prr.Goal__c = '미달성'; //category's Achievability__c(view side)                                       
                        }

                        }
                }            
                
                resultMap.put('TOTAL', isTotal);
                resultMap.put('prrAddList', prrList);                   
            }


            //Partner Benefit 
            Decimal partnerDiscount = 0;    
            Decimal paidMarketingFund = 0;
            Decimal paidMigrationFund = 0;
            Decimal paidFund = 0;
            Decimal incentive = 0;
            
            
            for(PartnerFundClaim pfc : [SELECT Id, Amount FROM PartnerFundClaim WHERE Status__c='Paid' AND ChannelPartnerId=:account.Id]){
                paidMarketingFund += pfc.Amount;
            }
            
            paidFund = paidMarketingFund + paidMigrationFund;

            resultMap.put('partnerDiscount', partnerDiscount);
            resultMap.put('paidMarketingFund', paidMarketingFund);
            resultMap.put('paidMigrationFund', paidMigrationFund);
            resultMap.put('paidFund', paidFund);
            resultMap.put('incentive', incentive);
            
        }

        return resultMap;
    }
}