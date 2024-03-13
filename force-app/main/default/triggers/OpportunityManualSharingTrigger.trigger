/**
 * @description       : 매출부서 insert/update 시, 해당 매출부서가 클라우드서비스사업부이면
 *                      클라우드서비스사업부 role 하위 모든 인원에게 BO 조회권한 추가
 * @author            : chae_ho.yang@samsung.com
 * @group             : 
 * @last modified on  : 01-27-2023
 * @last modified by  : chae_ho.yang@samsung.com
**/
trigger OpportunityManualSharingTrigger on Opportunity (after insert, after update) {

    public static Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    public static String cloudRoleId; // 클라우드서비스사업부
    if (isSandbox) cloudRoleId = '00G1s000001x10zEAA';
    else cloudRoleId = '00G2w000000kO4cEAE';
    
    if(Trigger.isInsert) {
        System.debug('CHLOG::START :: OpportunityManualSharing after insert START==============================');
        List<OpportunityShare> optyShareList  = new List<OpportunityShare>();
        OpportunityShare optyShare;
        List<CostCenter__c> deliveryCostCenterList;
        CostCenter__c deliveryCostCenter;

        for(Opportunity opty : trigger.new) {
        
            deliveryCostCenterList = [SELECT id, name, Node2__c,Text2__c, CostCenterName__c, CostCenter__c
                                      FROM CostCenter__c
                                      WHERE id =: opty.cPrimarySalesDepartment__c];
            system.debug('CHLOG::deliveryCostCenterList : ' + deliveryCostCenterList);

            if (deliveryCostCenterList.size()==1) deliveryCostCenter = deliveryCostCenterList.get(0);
            else continue;
            system.debug('CHLOG::deliveryCostCenter : ' + deliveryCostCenter);

            if (deliveryCostCenter.Node2__c=='T100S3') {
                optyShare = new OpportunityShare();
                optyShare.OpportunityId = opty.Id;
                optyShare.UserOrGroupId = cloudRoleId;
                optyShare.OpportunityAccessLevel = 'Read';
                optyShare.RowCause = 'Manual';

                optyShareList.add(optyShare);
            }

        }
        Database.SaveResult[] lsr = Database.insert(optyShareList,false);
        System.debug('CHLOG::END :: OpportunityManualSharing after insert END==============================');

    } else if(Trigger.isUpdate) {
        System.debug('CHLOG::START :: OpportunityManualSharing after update START==============================');
        List<OpportunityShare> optyShareList  = new List<OpportunityShare>();
        OpportunityShare optyShare;
        List<CostCenter__c> newCostCenterList;
        List<CostCenter__c> oldCostCenterList;
        CostCenter__c newCostCenter;
        CostCenter__c oldCostCenter;
        for(Opportunity opty : trigger.new) {
            Opportunity oldOpty = Trigger.oldMap.get(opty.id);

            System.debug('CHLOG::oldMapOpty : ' + oldOpty);
            if( (oldOpty.cPrimarySalesDepartment__c != opty.cPrimarySalesDepartment__c) || (oldOpty.OwnerId != opty.OwnerId)) {
                // if record owner changed added 23.01.27
                // make new manual sharing record because manual sharing record deleted automatically
                
                System.debug('CHLOG::Primary Devlivery Dept Changed');
                newCostCenterList = [SELECT id, name, Node2__c,Text2__c, CostCenterName__c, CostCenter__c
                                    FROM CostCenter__c
                                    WHERE id =:opty.cPrimarySalesDepartment__c];
                if (newCostCenterList.size()==1) newCostCenter=newCostCenterList.get(0);
                oldCostCenterList = [SELECT id, name, Node2__c,Text2__c, CostCenterName__c, CostCenter__c
                                    FROM CostCenter__c
                                    WHERE id =:oldOpty.cPrimarySalesDepartment__c];
                if (oldCostCenterList.size()==1) oldCostCenter=oldCostCenterList.get(0);

                if (newCostCenterList.size()==0 || newCostCenter.Node2__c != 'T100S3') {
                    System.debug('CHLOG::Cloud Deletion');
                    optyShareList = [SELECT Id, OpportunityId, UserOrGroupId
                                    FROM OpportunityShare WHERE UserOrgroupId =:cloudRoleId AND OpportunityId =: opty.Id];
                    DataBase.DeleteResult[] lsr = Database.delete(optyShareList, false);
                }
                if (newCostCenterList.size()!=0 && newCostCenter.Node2__c == 'T100S3') {
                    System.debug('CHLOG::Changed to Cloud');
                    optyShare = new OpportunityShare();
                    optyShare.OpportunityId = opty.Id;
                    optyShare.UserOrGroupId = cloudRoleId;
                    optyShare.OpportunityAccessLevel = 'Read';
                    optyShare.RowCause = 'Manual';
                    optyShareList.add(optyShare);
                    DataBase.UpsertResult[] lsr = Database.upsert(optyShareList, false);
                } 
            }
                
        }
        System.debug('CHLOG::END :: OpportunityManualSharing after update END==============================');
    }

}