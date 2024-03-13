/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 2023-10-24
 * @last modified by  : divyam.gupta@samsung.com
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   12-24-2020   woomg@dkbmc.com   Initial Version
 * 1.1   2022-10-11   kajal.c@samsung.com  CP Review Activity Added.
 * 1.2   2023-10-24   divyam.gupta@samsung.com Mysales-331 (Logistics) CP Review logic change.
**/
public with sharing class CelloParameterController {

    @AuraEnabled
    public static map<String, String> getCelloParameters(String menuname, String lbsType, String lbsCode, String boId, String billToId,String rvType){
        map<String, String> params = new map<String, String>();
        try {
            String timestamp = String.valueOf(system.now().getTime()/1000);
            String epId = [SELECT FederationIdentifier FROM User WHERE Id = :UserInfo.getUserId()].FederationIdentifier;
            String loginIp = '';
            if(Test.isRunningTest()){
                loginIp = '192.168.0.1';
            } else {
                loginIp = Auth.SessionManagement.getCurrentSession().get('SourceIp');
            }
            if(epId == null || epId == '') return null;

            // String menuBase64 = EncodingUtil.base64Encode(Blob.valueOf(menuname));
            // String p3Param = 'TEMP=TEMP&MC=' + menuBase64 + '&boId=' + boId + '&type=pop';
            // V 1.2 Changes by Divyam
            String p3Param = getP3(menuname, lbsType, lbsCode, boId, billToId,rvType);
            Blob secret = Blob.valueOf(Label.CELLO_AES_SECRET_KEY);
            Blob urlParams = Blob.valueOf('TEMP=TEMP&F2=' + timestamp + '&F3=INT&F6=' + epId + '&F7=' + loginIp);
            system.debug('KajalurlParams'+ 'TEMP=TEMP&F2=' + timestamp + '&F3=INT&F6=' + epId + '&F7=' + loginIp );
            Blob p2enc = Crypto.encryptWithManagedIV(Label.CELLO_AES_METHOD, secret, urlParams);
            Blob p3enc = Crypto.encryptWithManagedIV(Label.CELLO_AES_METHOD, secret, Blob.valueOf(p3Param));
            params.put('p0', EncodingUtil.base64Encode(Blob.valueOf('SFDC')));
            params.put('p2', EncodingUtil.convertToHex(p2enc));
            params.put('p3', EncodingUtil.convertToHex(p3enc));

            system.debug(p3Param);
            system.debug(params);
        } catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return params;
    }

    private static String getP3(String menuname, String lbsType, String lbsCode, String boId, String billToId, String rvType){
        system.debug('Kajalmenuname'+menuname);
        String menuBase64 = EncodingUtil.base64Encode(Blob.valueOf(menuname));       
        system.debug('Divyamtest'+'TEMP=TEMP&MC=' + menuname + '&boId=' + boId);
        String p3Param = 'TEMP=TEMP&MC=' + menuBase64 + '&boId=' + boId;
        if(menuname == 'WKS_CRAS_REG') p3Param += '&billtoId=' + billToId;
        if(menuname == 'WKS_LBS_REG') p3Param += '&rlbsAddTcd=' + lbsType + '&rlbsCcd=' + lbsCode;
        //V1.1 -> CP Review Activity Added
        //V 1.2 Changes by Divyam
        if(menuname == 'WKS_LOGICP_REG') p3Param += '&LogiCpCcd=' + lbsCode + '&rvType=' +rvType ;
        p3Param += '&type=pop';
        system.debug('Kajalp3Param'+p3Param);
        return p3Param;
    } 
    //V1.1 Added by KAJAL
    @AuraEnabled
    public static Boolean getExceptionBoolean(ID opptyID){
        system.debug('getExceptionBoolean@@' + opptyID);
        Boolean booleanFinalLogisticsCPCheck = false;
        Boolean booleanFinalLBS = false;
        Boolean booleanException = false;
        opportunity oppty = [Select id,StageName,LBSExceptionType__c,LogisticsBizDevelopmentType__c,Type,
                             LogisticsCustomerType__c from opportunity where ID =: opptyID];
        MasterActivity__c masterActFinalLogisticsCPCheck = [Select id,TransactionName__c from MasterActivity__c where TransactionName__c = '2.4.4'];
        OpportunityActivityPanelController.ActivityItem actItemFinalLogisticsCPCheck = new OpportunityActivityPanelController.ActivityItem(masterActFinalLogisticsCPCheck,null,null);
        booleanFinalLogisticsCPCheck =  OpportunityActivityHelper.checkAccessLogisticsActivityV2(oppty,actItemFinalLogisticsCPCheck);
        system.debug('booleanFinalLogisticsCPCheck@@=' + booleanFinalLogisticsCPCheck);
        MasterActivity__c masterActFinalLBS = [Select id,TransactionName__c from MasterActivity__c where TransactionName__c = '2.4.5.'];
        OpportunityActivityPanelController.ActivityItem actItemFinalLBS = new OpportunityActivityPanelController.ActivityItem(masterActFinalLBS,null,null);
        booleanFinalLBS =  OpportunityActivityHelper.checkAccessLogisticsActivityV2(oppty,actItemFinalLBS);
        system.debug('booleanFinalLBS@@=' + booleanFinalLBS);
        if(booleanFinalLogisticsCPCheck == True && booleanFinalLBS == False){
            booleanException = true;
        }
        return  booleanException;
    }
}