/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2021-11-29
 * @last modified by  : younghoon.kim@dkbmc.com
**/
global class Batch_MigrationForTA implements DataBase.Batchable<SObject>, DataBase.stateful{
    // ↓ 배치 실행코드
    // Database.executeBatch(new Batch_MigrationForTA(), 100);

    // ↓ 데이터 추출용 쿼리
    // SELECT Id, Opportunity__c, Opportunity__r.CompanyCode__c, Opportunity__r.OpportunityCode__c, Service__c, Service__r.Service__r.Name, Service__r.Service_Code__c, Service__r.ItemNumber__c, Solution__c, Solution__r.Solution__r.Name, Solution__r.Solution_Code__c, Solution__r.SolutionType__c, Project__c, Project__r.Name, Project__r.ProjectCode__c, WBS__c, WBS__r.Name FROM TA_Mig_Target__c 
    
    private Set<String> opptyIdSet = new Set<String>();
    
    global Batch_MigrationForTA(){  
        
    }

    global DataBase.QueryLocator start(DataBase.BatchableContext BC){
        String query_Select = 'SELECT';
        String query_Fields = ' Id, Name, Service_Code__c, Opportunity__c';
        String query_From   = ' FROM Service__c';
        String query_Where   = ' WHERE Service_Code__c IN (\'22000003\', \'22000004\', \'22000006\', \'22000007\', \'20000030\') ';
        query_Where += ' AND SendSAP__c = true';
		query_Where += ' AND DeletionFlag__c = false';
        String query_Order = ' ORDER BY Opportunity__c';
        
        return DataBase.getQueryLocator(query_Select + query_Fields + query_From + query_Where + query_Order);
    }
    
    global void execute(DataBase.BatchableContext BC, List<Service__c> scope){
        List<TA_Mig_Target__c> tmtList = new List<TA_Mig_Target__c>();
        Set<String> opptyIdSet = new Set<String>();

        for(Service__c svc : scope){
            opptyIdSet.add(svc.Opportunity__c);
        }

        List<Solution__c> solList = [SELECT Id, Name, Opportunity__c, Opportunity__r.OpportunityCode__c, Service__c
                                       FROM Solution__c 
                                      WHERE Opportunity__c =: opptyIdSet
                                        AND SendSAP__c = true
                                        AND DeletionFlag__c = false];

        if(solList.size() > 0){
            for(Solution__c sol : solList){
                TA_Mig_Target__c tmt = new TA_Mig_Target__c();
                tmt.Opportunity__c = sol.Opportunity__c;
                tmt.Service__c = sol.Service__c;
                tmt.Solution__c = sol.Id;
                
                tmtList.add(tmt);
            }
        }
                                        
        if(tmtList.size() > 0) insert tmtList;
    }
    
    global void finish(DataBase.BatchableContext BC){
        
    }
    
    /*
    global DataBase.QueryLocator start(DataBase.BatchableContext BC){
        String query_Select = 'SELECT ';
        String query_Fields = ' Id, Name, OpportunityID__r.CompanyCode__c, OpportunityID__r.OpportunityCode__c, Solution__r.Service__c, ServiceCode__c, ItemNumberInt__c, Solution__c, SolutionCode__c, ProjectCode__c, Project__r.ProjectCode__c, WBSLevel__c ';
        String query_From   = ' FROM WBS__c';
        String query_Where   = ' WHERE ServiceCode__c IN (\'22000003\', \'22000004\', \'22000006\', \'22000007\', \'20000030\') ';
        query_Where += ' AND WBSLevel__c = \'3\'  ';
		query_Where += ' AND ItemNumberInt__c != 0 ';
        // query_Where += ' AND Solution__r.Service__r.SendSAP__c = true ';
        // query_Where += ' AND Solution__r.Service__r.DeletionFlag__c = false ';
        String query_Order = ' ORDER BY OpportunityID__r.OpportunityCode__c, ServiceCode__c, ItemNumberInt__c ';
        
        return DataBase.getQueryLocator(query_Select + query_Fields + query_From + query_Where + query_Order);
    }
    
    global void execute(DataBase.BatchableContext BC, List<WBS__C> scope){
        if(scope.size() > 0){
            Map<String, TA_Mig_Target__c> tmtMap = new Map<String, TA_Mig_Target__c>();
            
            for(WBS__C wbs : scope){
                // if(!(wbs.OpportunityID__r.OpportunityCode__c).contains('SDZ')){
                    if(tmtMap.get(wbs.Name) == null){
                        TA_Mig_Target__c tmt = new TA_Mig_Target__c();
                        tmt.Opportunity__c = wbs.OpportunityID__c;
                        tmt.Service__c = wbs.Solution__r.Service__c;
                        tmt.Solution__c = wbs.Solution__c;
                        tmt.Project__c = wbs.Project__c;
                        tmt.WBS__c = wbs.Id;
                            
                        tmtMap.put(wbs.Name, tmt);
                    }
                // }
            }
            if(tmtMap.size() > 0) insert tmtMap.values();
        }
    }
    
    global void finish(DataBase.BatchableContext BC){
        
    }
    */
}