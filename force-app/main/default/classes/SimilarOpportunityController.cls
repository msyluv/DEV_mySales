global without sharing class SimilarOpportunityController {

    @AuraEnabled
    global static Map<String, String> getOpptyList(String pageSize, String rcdId, String searchType, String recordId){
        
        Map<String, String> rtnMap = new Map<String, String>();
        system.debug('Inside Apex Parameters : PageSize : ' + pageSize);
        system.debug('Inside Apex Parameters : Previous Record Id : ' + rcdId);
        system.debug('Inside Apex Parameters : Search Type : ' + searchType);
        system.debug('Inside Apex Parameters : Parent opp Id : ' + recordId);
        
        Opportunity lstOppTable4 = ([SELECT Id, cOriginAcc__r.LastModifiedById,convertCurrency(Amount), Name, account.lastmodifiedbyId, OpportunityCode__c, ZP61_PROPOSAL_SUBMIT_DATE__c, ProposalPM__c, ProposalPM__r.Name, cOriginAcc__c, cOriginAcc__r.Owner.Name, cOriginAcc__r.Name, Opportunity_Review_VRB_Type_Confirm__c, toLabel(Opportunity_Review_VRB_Type_Confirm__c) toLabel_Opportunity_Review_VRB_Type_Confirm__c, FirstCloseDate__c, Opportunity_Review_VRB_Type__c, toLabel(Opportunity_Review_VRB_Type__c) toLabel_Opportunity_Review_VRB_Type__c, StageName, toLabel(StageName) toLabel_StageName, BO1stRegistrationDate__c, CloseDate, XP7_CONDUCT_DATE__c, XP6_CONDUCT_DATE__c, Account.mDomesticForeign__c, CMBizType__c, AccountId, Account.Owner.Name, Account.Name, OriginAcc_BizTypeL1__c, BusinessLevel__c, RecordType.Name, Type,XP7_REQ_DATE__c,XP6_REQ_DATE__c,Opportunity_Review_Confirm__c  
                                                  ,OpportunityStatus__c,XP63_EndDate__c,LastModifiedDate,LastModifiedById,OriginAcc_BizTypeL2__c,CompanyCode__c FROM Opportunity 
                                                  WHERE Id = : recordId
                                                 ]);
        System.debug('Table 4 Parent Opp Details : '+ lstOppTable4);
        
        Set<String> opptybiz1IdSet = new Set<String>();
        Set<String> opptybiz2IdSet = new Set<String>();
        Set<String> opptybussLabelIdSet = new Set<String>();
        List<Opportunity> resultOpptyList1 = new List<Opportunity>();
        
        Map<id,Set<String>> opptyServiceMap = new Map<id,Set<String>>();
        Map<id,Set<String>> opptySolMap = new Map<id,Set<String>>();
        Set<String> opptySerIdSet = new Set<String>();
        Set<String> opptySolIdSet = new Set<String>();
        
        String str_COUNT1 = 'SELECT COUNT() FROM Opportunity';
        
        String str_SELECT1 = '';
        str_SELECT1 += 'Select Id, companycode__c,OpportunityCode__c,Opportunity_Review_VRB_Type_Confirm__c,Opportunity_Review_Confirm__c,BO1stRegistrationDate__c,';
        str_SELECT1 += ' (select TransactionName__c,Status__c from BO_Activity__r where transactionname__c= ' + '\'' + 'ZP61' + '\'' + ' and status__c= ' + '\'' + 'Completed' + '\'' + ') ,';
        str_SELECT1 += ' ProposalPM__c,RepresentativePM__c,ProposalPM__r.name,RepresentativePM__r.name,OriginAcc_BizTypeL1__c,OriginAcc_BizTypeL2__c,';
        str_SELECT1 += ' BusinessLevel__c,name,closedate,convertcurrency(amount),toLabel(StageName),ownerid, owner.name From Opportunity ';
        
        String str_WHERE1 = '';
        str_WHERE1 += ' where  OriginAcc_BizTypeL1__c in:opptybiz1IdSet  AND OriginAcc_BizTypeL2__c in:opptybiz2IdSet  AND BusinessLevel__c in:opptybussLabelIdSet';
        str_WHERE1 += ' and RecordType.Name = ' + '\'' + 'HQ' + '\'' + ' and id in (SELECT opportunity__c from service__c where sService__r.Name in :opptySerIdSet  AND sDeletionFlag__c = false)';
		str_WHERE1 += ' and id in (SELECT opportunity__c from solution__c where sSolution__r.Name in :opptySolIdSet  AND sDeletionFlag__c = false) and';
        str_WHERE1 += ' (closedate = LAST_N_YEARS:4 OR closedate = THIS_YEAR) ';
        
        String str_ORDER1 = ' order by BO1stRegistrationDate__c desc';
        
        String str_LIMIT1 = ' LIMIT ' + pageSize;
        
        if(lstOppTable4.OriginAcc_BizTypeL1__c != null)
        	opptybiz1IdSet.add(lstOppTable4.OriginAcc_BizTypeL1__c);
        if(lstOppTable4.OriginAcc_BizTypeL2__c != null)
            opptybiz2IdSet.add(lstOppTable4.OriginAcc_BizTypeL2__c);
        if(lstOppTable4.BusinessLevel__c != null)
            opptybussLabelIdSet.add(lstOppTable4.BusinessLevel__c);

        system.debug('Opp Biz1 : '+ opptybiz1IdSet);
        system.debug('Opp Biz2 : '+ opptybiz2IdSet);
        system.debug('Opp Biz Label : '+ opptybussLabelIdSet);
        
        for(Service__c serObj:[SELECT Id , Name ,sService__r.Name, sService__r.TechAttribute__c , Opportunity__c
                               FROM Service__c
                               WHERE Opportunity__c = : lstOppTable4.Id  AND sDeletionFlag__c = false  ORDER BY sService__r.Name ASC]){
                                   opptySerIdSet.add(serObj.sService__r.Name);
                                   system.debug('opptySerIdSet==>'+opptySerIdSet);
                                   if(opptyServiceMap.containskey(serObj.Opportunity__c)) {
                                       set<String> servName = opptyServiceMap.get(serObj.Opportunity__c);
                                       servName.add(serObj.sService__r.Name);
                                       opptyServiceMap.put(serObj.Opportunity__c,servName);
                                   }
                                   else{
                                       set<String> servName = new Set<String>();
                                       servName.add(serObj.sService__r.Name);
                                       opptyServiceMap.put(serObj.Opportunity__c,servName);
                                   }
                               } 
        
        for(Solution__c serObj:[ SELECT Id , Name , Service__c , sSolution__r.Name,Opportunity__c
                                FROM Solution__c
                                WHERE Opportunity__c = : lstOppTable4.Id AND sDeletionFlag__c = false
                                ORDER BY sSolution__r.Name ASC
                               ]){
                                   opptySolIdSet.add(serObj.sSolution__r.Name);
                                   system.debug('opptySolIdSet==>'+opptySolIdSet);
                                   if(opptySolMap.containskey(serObj.Opportunity__c)) {
                                       set<String> servName = opptySolMap.get(serObj.Opportunity__c);
                                       servName.add(serObj.sSolution__r.Name);
                                       opptySolMap.put(serObj.Opportunity__c,servName);
                                   }
                                   else{
                                       set<String> servName = new Set<String>();
                                       servName.add(serObj.sSolution__r.Name);
                                       opptySolMap.put(serObj.Opportunity__c,servName);
                                   }
                               }
        
        system.debug('Opp Service Map : '+ opptyServiceMap);
        system.debug('Opp Service Map : '+ opptySolMap);
        
        if(String.isNotEmpty(searchType)){
            String sign = '';
            if(searchType.equals('Next')){
                sign = '<';
                //str_ORDER1 += ' DESC';
                str_ORDER1 = ' order by BO1stRegistrationDate__c DESC';
            }else if(searchType.equals('Prev')){
                sign = '>';
                //str_ORDER1 += ' ASC';
                str_ORDER1 = ' order by BO1stRegistrationDate__c ASC';
            }

            if(String.isNotEmpty(rcdId)) str_WHERE1 += ' AND BO1stRegistrationDate__c ' + sign + ' ' + rcdId ;
        }

        System.debug('str_COUNT : ' + str_COUNT1);
        System.debug('str_SELECT : ' + str_SELECT1);
        System.debug('str_WHERE : ' + str_WHERE1);
        System.debug('str_ORDER : ' + str_ORDER1);
        System.debug('str_LIMIT : ' + str_LIMIT1);
        System.debug('result String : ' + str_SELECT1 + str_WHERE1 + str_ORDER1 + str_LIMIT1);

        String resultMSG = '';
        Decimal totalPage = 0;
        Decimal totalCount = 0;
        String str_totalCount = '';
        String opptybiz1 = lstOppTable4.OriginAcc_BizTypeL1__c;
        String opptybiz2 = lstOppTable4.OriginAcc_BizTypeL2__c;
        String opptybussLabel = lstOppTable4.BusinessLevel__c;
        String Service = String.join(opptySerIdSet, ', ');
        String Solution = String.join(opptySolIdSet, ', ');
        List<Opportunity> resultOpptyList = new List<Opportunity>();
        List<returnObject> returnList = new List<returnObject>();
        try{
            resultMSG = 'SUCCESS';

            totalPage = Database.countQuery(str_COUNT1 + str_WHERE1);
            totalCount = totalPage;
            
            if(totalPage > 0){
                str_totalCount = String.valueOf(totalCount-1);
            }
            else{
                str_totalCount = String.valueOf(totalCount);
            }
            totalPage = Math.ceil(totalPage/20);
            totalPage = (totalPage == 0) ? 1 : totalPage;

            System.debug('Query String : '+ str_SELECT1 + str_WHERE1 + str_ORDER1 + str_LIMIT1);
            resultOpptyList = Database.query(str_SELECT1 + str_WHERE1 + str_ORDER1 + str_LIMIT1);

            for(Integer i=0; i< resultOpptyList.size(); i++){
                if(resultOpptyList[i].Id == lstOppTable4.Id){
                    resultOpptyList.remove(i);
                    break;
                }
            }
            
            if(resultOpptyList.size()>20){
                resultOpptyList.remove(resultOpptyList.size()-1);
            }

            Set<String> resultIdSet = new Set<String>();
            Map<String, Boolean> opptyPermissionMap = new Map<String, Boolean>();
            if(resultOpptyList.size() > 0){
                for(Opportunity opp : resultOpptyList){
                    resultIdSet.add(opp.Id);
                }

                List<UserRecordAccess> accessList = [SELECT RecordId, HasReadAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :resultIdSet];
                for(UserRecordAccess access : accessList){
                    opptyPermissionMap.put(access.RecordId, access.HasReadAccess);
                }
                List<Company__c> companyList = [SELECT Name, CompanyCode__c FROM Company__c];
                for(Opportunity opp : resultOpptyList){
                    List<Opportunity_Activity__c> oAct = new List<Opportunity_Activity__c>();
                    oAct = opp.BO_Activity__r;
                    returnObject rtnObj = new returnObject();
                    rtnObj.OpptyCode = opp.OpportunityCode__c;
                    rtnObj.Id = opp.Id;
                    rtnObj.Name = opp.Name;
                    //rtnObj.Status = statusMap.get(opp.OpportunityStatus__c);
                    rtnObj.Stage = opp.StageName;
                    rtnObj.CompCode = opp.CompanyCode__c;
                    for(Company__c comp : companyList){
                        if(opp.CompanyCode__c == comp.CompanyCode__c){
                            rtnObj.CompName = comp.Name;
                        }
                    }
                    String amt = '0';
                    if(opp.Amount != null)
                    	amt = String.valueOf(opp.Amount/1000000) ;
                            //  System.debug('amt Test@ :' + amt);
                    List<String> amtStr = new List<String>();
                    String num = '';
                    if(amt.contains('.')){
                    	amtStr= amt.split('\\.');
                                //  System.debug('amtStr Test@ :'+amtStr);
                        num = amtStr[0] + '.' + amtStr[1].substring(0,2);
                    }
                    else{
                    	if(opp.Amount != null)
                        	num = String.valueOf(opp.Amount/1000000);
                    }
                    if(oAct!=null && oAct.size()>0 && opp.companycode__c == 'T100'){
                    	//rtnObj.Proposal = '<a style="color:blue" href="' + 'http://70.225.5.3:2007/ArisamWeb/proposal/viewPage.do?catcode=A042&orderId='+opp.Opportunitycode__c+ '">'+'<p style = "font-size:x-large">•</p>'+'</a>';
                    	rtnObj.Proposal = True;
                    }else{
                        //rtnObj.Proposal = '';
                        rtnObj.Proposal = False;
                    }
                    rtnObj.Amount = num;
                    rtnObj.VRBConfirmType = vrbTypeValues(opp.Opportunity_Review_VRB_Type_Confirm__c);
                    rtnObj.ProposalPM = opp.ProposalPM__r.name;
                    rtnObj.OwnerName = opp.Owner.Name;
                    String formattedDateStr = DateTime.newInstance(opp.CloseDate.year(), opp.CloseDate.month(), opp.CloseDate.day()).format(Utils.getUserDateFormat());
                    rtnObj.CloseDate = formattedDateStr;
                    rtnObj.BO1stRegistrationDate = opp.BO1stRegistrationDate__c;
                    rtnObj.Permission = opptyPermissionMap.get(opp.Id);

                    returnList.add(rtnObj);
                }                
            }
        }catch(Exception e){
            System.debug('ERROR : ' + e.getMessage());
            resultMSG = 'ERROR : ' + e.getMessage();
        }

        rtnMap.put('MESSAGE', resultMSG);
        rtnMap.put('COUNT', String.valueOf(totalPage));
        rtnMap.put('LIST', JSON.serialize(returnList));
        // rtnMap.put('TOTALCOUNT', String.valueOf(totalCount));
        rtnMap.put('TOTALCOUNT', str_totalCount);
        rtnMap.put('Type1', opptybiz1);
        rtnMap.put('Type2', opptybiz2);
        rtnMap.put('BizLevel', opptybussLabel);
        rtnMap.put('Service', Service);
        rtnMap.put('Solution', Solution);
		
        system.debug('Type1 : '+ opptybiz1);
        system.debug('Type2 : '+ opptybiz2);
        system.debug('BizLevel : '+ opptybussLabel);
        system.debug('Service : '+ Service);
        system.debug('Solution : '+ Solution);
        system.debug('rtnMap : '+rtnMap);
        return rtnMap;
    }

    public static string vrbTypeValues(String vrbTypeVal){
        String BO_Strategy_Type = '';
        
        if(vrbTypeVal == '10' ) BO_Strategy_Type = '전사';
        else if(vrbTypeVal == '20') BO_Strategy_Type = '사업부';
        else if(vrbTypeVal == '21') BO_Strategy_Type = 'AM 담당';
        
        return BO_Strategy_Type;
    }
    

    global class returnObject {
        @AuraEnabled
        global String OpptyCode {get; set;}
        @AuraEnabled
        global String Id {get; set;}
        @AuraEnabled
        global String Name {get; set;}
        @AuraEnabled
        global String Stage {get; set;}
        @AuraEnabled
        global String CompCode {get; set;}
        @AuraEnabled 
        global String CompName {get; set;}
        @AuraEnabled
        global String OwnerName {get; set;}
        @AuraEnabled
        global String CloseDate {get; set;}
        @AuraEnabled
        global String Amount {get; set;}
        @AuraEnabled
        global String VRBConfirmType {get; set;}
        @AuraEnabled
        global String ProposalPM {get; set;}
        @AuraEnabled
        global Boolean Permission {get; set;}
        @AuraEnabled
        global DateTime BO1stRegistrationDate {get; set;}
        @AuraEnabled
        global Boolean Proposal {get; set;}
        
    }
}