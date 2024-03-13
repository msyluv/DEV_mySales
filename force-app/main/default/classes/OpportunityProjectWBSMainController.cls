/**
 * @description       : 
 * @author            : dongyoung.kim@dkbmc.com
 * @group             : 
 * @last modified on  : 2021-01-14
 * @last modified by  : seonju.jin@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2020-12-02   dongyoung.kim@dkbmc.com   Initial Version
**/
public class OpportunityProjectWBSMainController {
    @AuraEnabled
    Public static List<Project__c> getProjectInfo(String opptyId){
        List<Project__c> lpjt = [SELECT Id, Name, ProjectCode__c, ProjectType__c, Description__c, Opportunity__c
                                FROM Project__c
                                WHERE Opportunity__c =:opptyId
                                AND DeletionFlag__c = false
                                ORDER BY ProjectCode__c ASC];

        List<String> pjtIds = new List<String>();
        for(Project__c pjt: lpjt){
            pjtIds.add(pjt.Id);
        }                                

        List<WBS__c> lwbs = [SELECT Id, Name, Project__c FROM WBS__c WHERE Project__c = : pjtIds AND DeletionFlag__c != 'Y' ORDER BY Name ASC];

        List<Project__c> lpjtInfo = new List<Project__c>();
        //Project__c 하위 WBS정보가 없는것은 조회안되도록
        for(Project__c pjt: lpjt){
            Integer cnt = 0;
            for(WBS__c wbs: lwbs){
                if(wbs.Project__c == pjt.Id){
                    cnt++;
                }
            }

            if(cnt != 0) lpjtInfo.add(pjt);
        }

        return lpjtInfo;
    }
    
    @AuraEnabled
    Public static List<WBS__c> getWBSInfo(String opptyId, String pjtId){
        return [SELECT Id, Name, OpportunityID__c, ItemNumber__c, ProjectCodeOutput__c, ProjectCode__c, ServiceCode__c, SolutionCode__c
                FROM WBS__c
            	WHERE OpportunityID__c =:opptyId
                   AND Project__c = :pjtId
                   AND DeletionFlag__c != 'Y' ORDER BY Name ASC];	//AND DeletionFlag__c = false
    }
    
    @AuraEnabled
    Public static Map<String,Object> getAllProejctWBSInfo(String opptyId){
        Map<String,Object> resultMap = new Map<String,Object>();
        List<Project__c> lproject =  [SELECT Id, Name, ProjectCode__c, ProjectType__c, Description__c, Opportunity__c
            							FROM Project__c
            							WHERE Opportunity__c =:opptyId
              							AND DeletionFlag__c = false
                                     ORDER BY ProjectCode__c ASC];
        
        List<String> lpjtIds = new List<String>();
        for(Project__c project : lproject){
            lpjtIds.add(project.Id);
        }
        
        List<WBS__c> lwbs = [SELECT Id, Name, OpportunityID__c, ItemNumber__c, ProjectCodeOutput__c, ProjectCode__c, ServiceCode__c, SolutionCode__c, Project__c
                                FROM WBS__c
                                WHERE OpportunityID__c =:opptyId
                                AND Project__c = :lpjtIds
                                AND DeletionFlag__c != 'Y'
                            	ORDER BY Name ASC];

        List<Project__c> lpjtInfo = new List<Project__c>();
        //Project__c 하위 WBS정보가 없는것은 조회안되도록
        for(Project__c pjt: lproject){
            Integer cnt = 0;
            for(WBS__c wbs: lwbs){
                if(wbs.Project__c == pjt.Id){
                    cnt++;
                }
            }

            if(cnt != 0) lpjtInfo.add(pjt);
        }
        
        resultMap.put('PROJECT', lpjtInfo);
        resultMap.put('WBS', lwbs);
        
        return resultMap;
    }
}