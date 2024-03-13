/**
 * @description       : LBS 에서 SFDC BO 상태동기화
 * @author            : soohong0.kim@partner.samsung.com
 * @group             : 
 * @last modified on  : 2023-10-23
 * @last modified by  : gitesh.s@samsung.com
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   12-10-2020   soohong0.kim@partner.samsung.com   Initial Version
 * 1.0.1 12-14-2020   raegganja@partner.samsung.com      class name change
 * 1.0.2 12-16-2020   raegganja@partner.samsung.com      BizDevelopmentType__c -> LogisticsBizDevelopmentType__c 변경
 * 1.0.2 12-21-2020   kilhwan.an@partner.samsung.com     Opportunity Id 처리
 * 1.0.3 01-27-2021   kilhwan.an@partner.samsung.com     LBS UPSERT 처리
 * 1.0.4 03-15-2021   raeganja@partner.samsung.com       Opportunity Activity 처리
 * 1.0.4 10-20-2021   seonju.jin@dkbmc.com               LBS Status 'DEL' 상태처리
 * 1.0.5 04-11-2022   hyunhak.roh@dkbmc.com				 Cello에서 전송받는 Final LBS 상태값에 따라 MySales 의 Stage Update
 * 1.0.6 2022-04-19   hyunhak.roh@dkbmc.com				 Opportunity Activity, 상태값 확인
 * 1.0.7 2022-04-21   hyunhak.roh@dkbmc.com				 Final LBS 상태값이 'FCHK'인 경우에 대해서도 단계 변경 추가
 * 1.0.8 2023-08-08	  aditya.r2@samsung.com				 Don't update SalesOrganization__c & DeliveryOrganization__c when SalesOrganization & DeliveryOrganization is null and generate IF_Log with Warning status  MySales-273
 * 1.0.9 2023-10-23   gitesh.s@samsung.com               MYSALES-333 (OwnerId null error and Duplicate IF-Log error)
**/
@RestResource(urlMapping = '/IF069/*')
global class IF_CelloLbsStatusController {
    private static final String INTERFACE_ID = 'IF-069';
    private static final String APEX_CLASS   = 'IF_CelloLbsStatusController';
    private static final String METHOD_NAME  = 'saveData';

    public IF_CelloLbsStatusController() {
    }

    @HttpPost
    global static OutputHeader saveData() {
        String       guId      = IF_Util.generateGuid();
        IF_Log.InterfaceLog infLog;
        IF_Log       log       = new IF_Log();
        RestRequest  req       = RestContext.request;
        Blob         reqBody   = req.requestBody;
        OutputHeader outHeader = new OutputHeader();

        String ifStatus = '';	//v1.0.8 MySales-273
        SavePoint sp = DataBase.setSavePoint();
        try{
            InputHeader inHeader = (InputHeader)JSON.deserializeStrict(reqBody.toString(), InputHeader.class);
            // 데이터가 존재 하지 않는 경우
            if( inHeader.DATA == null){

                outHeader.EV_RESULT = IF_Util.RESULT_MESSAGE_ERROR;
                outHeader.EV_MESG   = 'No Data';
                infLog = new IF_Log.InterfaceLog( INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqBody.toString(), JSON.serialize(outHeader));
                log.createLog( infLog);
                return outHeader;
            }

            // Opportunity 
            Set<String> ownerIdSet = new Set<String>();
            Set<Id>     oppIdSet   = new Set<Id>();
            Set<String> orgNmSet   = new Set<String>();
            
            Map<String, LBS> lbsObjMap= new Map<String, LBS>();
            List<Oppty>      oppDtList= new List<Oppty>();
            List<LBS>        lbsDtList= new List<LBS>();


            for( InputClass inClass: inHeader.DATA){
                if( inClass.Opportunity != null){
                    for( Oppty opp: inClass.Opportunity){

                        ownerIdSet.add( opp.OwnerID);
                        oppIdSet.add( opp.Id);
                        orgNmSet.add( opp.SalesBranch);
                        orgNmSet.add( opp.DeliveryBranch);
                        oppDtList.add( opp);
                    }
                }

                if( inClass.LBS != null){
                    for( LBS obj : inClass.LBS){

                        lbsObjMap.put( obj.OpportunityId, obj);
                        lbsDtList.add( obj);
                    }
                }                    
            }
            
            

            // 사용자 정보
            List<User> userList = [

                SELECT Id
                      ,FederationIdentifier 
                FROM   User 
                WHERE  FederationIdentifier IN :ownerIdSet
            ];
            Map<String,String> userMap  = new Map<String,String>();
            for(User obj : userList){
                userMap.put( obj.FederationIdentifier,obj.id);
            }

            // Opportnity 정보
            Map<Id, Opportunity> opptyMap = new Map<Id, Opportunity>([
                SELECT Id
                      ,LogisticsBizDevelopmentType__c
                      ,Name
                      ,LogisticsBizType__c
                      ,OwnerId 
                      ,SalesOrganization__c
                      ,DeliveryOrganization__c 
                FROM   Opportunity 
                WHERE  Id IN :oppIdSet
            ]);

            // Organization 정보
            List<Organization__c> orgList = [ 
                
                SELECT Id
                      ,Name
                      ,Code__c
                      ,Region__c 
                FROM   Organization__c
                WHERE  Code__c IN :orgNmSet
            ];
            Map<String,Object> orgMap = new Map<String,Object>();
            for(Organization__c obj : orgList){
                orgMap.put(obj.Code__c, obj);
            }


            //LBS UPDATE 정보
            List<LBS__c> lbsUpdateList = new List<LBS__c>();
            Set<String>  oppLbsKeySet  = new Set<String>();
            for(LBS obj : lbsDtList){

                // LBS__c lbs = lbsMap.get(obj.LBSID);
                // if( lbs == null) continue;
                LBS__c                  lbs = new LBS__c();
                lbs.Name                    = obj.LBSID;
                lbs.LogisticsServiceType__c = obj.LogisticsServiceType.replaceAll(',', ';');
                lbs.BiddingDeadline__c  = Util_String.convertStringDate(obj.BiddingDeadline);
                lbs.CloseDate__c        = Util_String.convertStringDate(obj.CloseDate);
                lbs.cRevenueStartDate__c= Util_String.convertStringDate(obj.cRevenueStartDate);
                lbs.cRevenueEndDate__c  = Util_String.convertStringDate(obj.cRevenueEndDate);
                lbs.Type__c             = obj.Type;
                lbs.LBSStatus__c        = obj.LBSStatus;
                lbs.Amount__c           = Util_String.nvlDec( obj.Amount);
                lbs.LegalReviewNo__c    = obj.LEGAL_SYS_CNTRT_NO;
                lbs.Opportunity__c      = obj.OpportunityId;
                
                lbsUpdateList.add(lbs);

                // 기존 LBS 값을 구하기 위한 KEY 값
                if( lbs.LBSStatus__c == 'DEL'){

                    oppLbsKeySet.add( lbs.Opportunity__c + '_' + lbs.Name);
                }
            }

            // 이전 lbs 값 확인
            List<LBS__c> lbsList = [

                SELECT Id
                      ,Name
                      ,LBSStatus__c
                      ,Opportunity__c
                FROM   LBS__c
                WHERE  Opportunity__c IN :oppIdSet
                AND    OppLbsKey__c   IN :oppLbsKeySet
            ];
            
            // Map<String, LBSWraffer> orgLbsMap  = new Map<String, LBSWraffer>();
            Set<String> lbsExtIdSet = new Set<String>();
            for( LBS__c lbsObj : lbsList){

                String extId = null;
                if(lbsObj.LBSStatus__c == 'REQ' || lbsObj.LBSStatus__c == 'ONGO' || lbsObj.LBSStatus__c == 'PASS' || lbsObj.LBSStatus__c == 'BREJ' || lbsObj.LBSStatus__c == 'BREG' || lbsObj.LBSStatus__c == 'BRJQ'){

                    extId = lbsObj.Opportunity__c + '_' +  OpportunityActivityHelper.ACT_CODE_BIDDING_LBS; //'2.3.2.';
                } else if(lbsObj.LBSStatus__c == 'FREQ' || lbsObj.LBSStatus__c == 'FCHK' || lbsObj.LBSStatus__c == 'CMPT' || lbsObj.LBSStatus__c == 'FREJ' || lbsObj.LBSStatus__c == 'FREG' || lbsObj.LBSStatus__c == 'FRJQ'){

                    extId = lbsObj.Opportunity__c + '_' +  OpportunityActivityHelper.ACT_CODE_FINAL_LBS; // '2.4.5.';
                }else if(lbsObj.LBSStatus__c == 'DEL'){
                    lbsExtIdSet.add(lbsObj.Opportunity__c + '_' +  OpportunityActivityHelper.ACT_CODE_FINAL_LBS);
                    lbsExtIdSet.add(lbsObj.Opportunity__c + '_' +  OpportunityActivityHelper.ACT_CODE_BIDDING_LBS);
                }

                if( extId != null){
                    // LBSWraffer waffer = new LBSWraffer();
                    // waffer.lbsName    = lbsObj.Name;
                    // waffer.lbsId      = lbsObj.Id;
                    // waffer.oppId      = lbsObj.Opportunity__c;
                    // waffer.lbsStatus  = lbsObj.LBSStatus__c;
                    // waffer.activyExtId= extId;

                    // String strKey     = lbsObj.Opportunity__c + '_' + lbsObj.Name;
                    // orgLbsMap.put( strKey, waffer);
                    lbsExtIdSet.add( extId);
                }
            }

            System.debug('lbsExtIdSet:' + lbsExtIdSet);

            // 이전 Activity 확인
            List<Opportunity_Activity__c> oppActyList = [

                SELECT Id
                      ,WhatId__c
                      ,Status__c
                      ,ExtId__c
                FROM   Opportunity_Activity__c
                WHERE  ExtId__c IN :lbsExtIdSet
            ];
            System.debug(oppActyList);

            Map<String, Opportunity_Activity__c> activityMap = new Map<String, Opportunity_Activity__c>();
            for( Opportunity_Activity__c  oppActy : oppActyList){
                
                activityMap.put( oppActy.ExtId__c, oppActy);
            }


            // Opportunity 데이터
            List<Organization__c> orgUpdateList = new List<Organization__c>();
            List<Opportunity>     oppUpdateList = new List<Opportunity>();
            List<Opportunity>     oppList = new List<Opportunity>();
            List<Opportunity_Activity__c> oppActList = new List<Opportunity_Activity__c>();
            for(Oppty obj : oppDtList){

                String      oppId = obj.Id;
                Opportunity oppty= opptyMap.get( oppId);
                if( oppty == null) continue;

                oppty.LogisticsBizDevelopmentType__c = obj.BizDevelopmentType;
                oppty.Name                = obj.Name;
                oppty.LogisticsBizType__c = obj.LogisticsBizType.replaceAll(',', ';');
                //v1.0.9 - MYSALES-333
                //if(obj.OwnerID != null && userMap.get(obj.OwnerID) != null) oppty.OwnerID = userMap.get(obj.OwnerID);
				//v1.0.9
                Organization__c salesOrg    = (Organization__c) orgMap.get(obj.SalesBranch);

                if(salesOrg != null){
                    oppty.SalesOrganization__c = salesOrg.Id;
                }else {
                    //oppty.SalesOrganization__c = null; v1.0.8	MySales-273                   
                    ifStatus = 'SW';					//v1.0.8	MySales-273
                }
                
                Organization__c deliveryOrg = (Organization__c) orgMap.get(obj.DeliveryBranch);
                if(deliveryOrg != null) {
                    oppty.DeliveryOrganization__c = deliveryOrg.Id;
                }else {
                    //oppty.DeliveryOrganization__c = null;	v1.0.8	MySales-273 
                    ifStatus = ifStatus + 'DW';				//v1.0.8	MySales-273
                }

                
                //  LBS 마지막값
                LBS lbsObj                  = lbsObjMap.get( oppId);
                if( lbsObj != null){
                    oppty.LegalReviewNo__c  = lbsObj.LEGAL_SYS_CNTRT_NO;
                }

                //2022-04-11, hyunhak.roh@dkbmc.com, Cello에서 전송받는 Final LBS 상태값에 따라 MySales 의 Stage Update
                if(lbsObj.LBSStatus == 'FREQ' || lbsObj.LBSStatus == 'FREJ' || lbsObj.LBSStatus == 'FRJQ'
                //2022-04-21, hyunhak.roh@dkbmc.com, Final LBS 상태값이 'FCHK'인 경우에 대해서도 단계 변경 추가
                	|| lbsObj.LBSStatus == 'FCHK'){
                	oppty.StageName = OpportunityActivityHelper.OPP_STAGE_QUALIFIED;	//Qualified - OPP_STAGE_QUALIFIED
                    //
                    System.debug('##### oppty.StageName ##### => OPP_STAGE_QUALIFIED');
                }else if(lbsObj.LBSStatus == 'CMPT'){
                    oppty.StageName = OpportunityActivityHelper.OPP_STAGE_SOLUTIONED;	//Solutioned - OPP_STAGE_SOLUTIONED
                    //
                    System.debug('##### oppty.StageName ##### => OPP_STAGE_SOLUTIONED');
                }
                //System.debug('##### oppty.StageName ##### => ' + oppty.StageName);
                
                //v1.0.8 MySales-273
                if(salesOrg != null && deliveryOrg != null){
                	oppUpdateList.add(oppty);
                }else{
                    oppList.add(oppty);
                }
                

                // Opportunity Activity 정보 등록
                Opportunity_Activity__c oppAct = new Opportunity_Activity__c();
                String transactionName = '';
                if(lbsObj.LBSStatus == 'REQ' || lbsObj.LBSStatus == 'ONGO' || lbsObj.LBSStatus == 'PASS' || lbsObj.LBSStatus == 'BREJ' || lbsObj.LBSStatus == 'BREG' || lbsObj.LBSStatus == 'BRJQ'){
                    //Bidding LBS
                    transactionName = '2.3.2.';

                    oppAct.TransactionName__c = transactionName;
                    if(lbsObj.LBSStatus == 'BREG'){
                        oppAct.Status__c = 'Not Started';
                    } else if(lbsObj.LBSStatus == 'REQ' || lbsObj.LBSStatus == 'ONGO' || lbsObj.LBSStatus == 'BREJ' || lbsObj.LBSStatus == 'BRJQ'){
                        oppAct.Status__c = 'In Progress';
                    } else if(lbsObj.LBSStatus == 'PASS'){
                        oppAct.Status__c = 'Completed';
                    }
                    if(lbsObj.LBSStatus == 'BREG'){
                        oppAct.DueDate__c = Util_String.convertStringDate(lbsObj.BiddingDeadline);
                    }
                    if(lbsObj.LBSStatus == 'REQ'){
                        oppAct.StartDate__c = Date.today();
                    }
                    if(lbsObj.LBSStatus == 'PASS'){
                        oppAct.EndDate__c = Date.today();
                    }
                    oppAct.CurrencyIsoCode = 'KRW';
                    oppAct.WhatId__c = oppId;
                    oppAct.ExtID__c = oppId + '_' + transactionName;
                    
                    //2022-04-19, hyunhak.roh@dkbmc.com, Opportunity Activity, 상태값 확인
                    oppActList.add(oppAct);
                } else if(lbsObj.LBSStatus == 'FREQ' || lbsObj.LBSStatus == 'FCHK' || lbsObj.LBSStatus == 'CMPT' || lbsObj.LBSStatus == 'FREJ' || lbsObj.LBSStatus == 'FREG' || lbsObj.LBSStatus == 'FRJQ'){
                    //Final LBS
                    transactionName = '2.4.5.';
                    oppAct.TransactionName__c = transactionName;
                    if(lbsObj.LBSStatus == 'FREG'){
                        oppAct.Status__c = 'Not Started';
                    } else if(lbsObj.LBSStatus == 'FREQ' || lbsObj.LBSStatus == 'FCHK' || lbsObj.LBSStatus == 'FREJ' || lbsObj.LBSStatus == 'FRJQ'){
                        oppAct.Status__c = 'In Progress';
                    } else if(lbsObj.LBSStatus == 'CMPT'){
                        oppAct.Status__c = 'Completed';
                    }
                    if(lbsObj.LBSStatus == 'FREG'){
                        oppAct.DueDate__c = Util_String.convertStringDate(lbsObj.BiddingDeadline);
                    }
                    if(lbsObj.LBSStatus == 'FREQ'){
                        oppAct.StartDate__c = Date.today();
                    }
                    if(lbsObj.LBSStatus == 'CMPT'){
                        oppAct.EndDate__c = Date.today();
                    }
                    oppAct.CurrencyIsoCode = 'KRW';
                    oppAct.WhatId__c = oppId;
                    oppAct.ExtID__c = oppId + '_' + transactionName;
                    
                    //2022-04-19, hyunhak.roh@dkbmc.com, Opportunity Activity, 상태값 확인
                    oppActList.add(oppAct);
                }else if( lbsObj.LBSStatus == 'DEL'){       //2021.10.20 LBS Status 'DEL' 상태처리

                    // String     strKey = lbsObj.OpportunityId + '_' + lbsObj.LBSID;
                    // LBSWraffer waffer = orgLbsMap.get( strKey);
                    // Opportunity_Activity__c oppActivy = activityMap.get( waffer.activyExtId);

                    Opportunity_Activity__c oppActivy_biddingLbs = activityMap.get( obj.Id + '_' + OpportunityActivityHelper.ACT_CODE_BIDDING_LBS);
                    Opportunity_Activity__c oppActivy_finalLbs = activityMap.get( obj.Id + '_' + OpportunityActivityHelper.ACT_CODE_FINAL_LBS);
                    
                    if( oppActivy_biddingLbs != null){
                        if(String.isNotBlank(oppActivy_biddingLbs.Status__c)){
                            oppActivy_biddingLbs.Status__c  = 'Not Started';
                            oppActivy_biddingLbs.EndDate__c = null;
                            oppActivy_biddingLbs.DueDate__c = Date.today();
                            oppActList.add(oppActivy_biddingLbs);
                        } 
                    }
                    if( oppActivy_finalLbs != null){
                        if(String.isNotBlank(oppActivy_finalLbs.Status__c)){
                            oppActivy_finalLbs.Status__c  = 'Not Started';
                            oppActivy_finalLbs.EndDate__c = null;
                            oppActivy_finalLbs.DueDate__c = Date.today();
                            oppActList.add(oppActivy_finalLbs);
                        } 
                    }
                }
            }

            //update oppUpdateList;
            upsert lbsUpdateList Name;
            if (oppActList != null && oppActList.size() > 0) {
                upsert oppActList ExtID__c;
            }
            //2022-04-19, hyunhak.roh@dkbmc.com, Opportunity Activity, 상태값 확인
            //v1.0.8	MySales-273
            if(!oppUpdateList.isEmpty()){
            	update oppUpdateList;
            
            	// outHeader.TOTAL_COUNT    = inHeader.DATA.size();
            	outHeader.EV_RESULT      = IF_Util.RESULT_STATUS_SUCCESS;
            	outHeader.EV_MESG        = IF_Util.RESULT_MESSAGE_SUCCESS;
            }else if(!oppList.isEmpty()){
                update oppList;
                outHeader.EV_RESULT      = 'W';
                if(ifStatus == 'SWDW'){
                    outHeader.EV_MESG        = 'Sales / Delivery Organization information was not updated. Please check IF-Log';
                }else if(ifStatus == 'SW'){
                    outHeader.EV_MESG        = 'Sales Organization information was not updated. Please check IF-Log';
                }else if(ifStatus == 'DW'){
                    outHeader.EV_MESG        = 'Delivery Organization information was not updated. Please check IF-Log';
                }
            }
            //v1.0.9 MYSALES-333
            //v1.0.8 MySales-273
            if(String.isBlank(ifStatus)){
                infLog = new IF_Log.InterfaceLog( INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqBody.toString(), JSON.serialize(outHeader));
            }else{
                infLog = new IF_Log.InterfaceLog( INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqBody.toString(), JSON.serialize(outHeader), ifStatus);
            }
            
            log.createLog( infLog);
            //v1.0.9
        }catch(Exception e){
            
            DataBase.rollback( sp);
            system.debug(e);
            outHeader.EV_RESULT      = IF_Util.RESULT_STATUS_ERROR;
            outHeader.EV_MESG        = IF_Util.RESULT_MESSAGE_ERROR + ' |' + e.getMessage();
            infLog = new IF_Log.InterfaceLog( INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqBody.toString(), JSON.serialize(outHeader),e);
            log.createLog( infLog);
        }
        return outHeader;
    }

    global class LBSWraffer{

        public Id      lbsId;
        public Id      oppId;
        public String  lbsStatus;
        public String  lbsName;
        public String  activyExtId;
    }


    // 전달 값: JitterBit
    global class OutputHeader{

        @AuraEnabled
        public Integer TOTAL_COUNT = 0; // 전체 데이터 건수
        @AuraEnabled
        public String EV_RESULT = ''; // 처리 결과
        @AuraEnabled
        public String EV_MESG = ''; // 처리 메세지
        @AuraEnabled
        public List<OutputClass> DATA; // 데이터 포멧
    }

    public class OutputClass{

    }

    // 받은 값 : 입력정보
    public class InputHeader{

        @AuraEnabled
        public Integer TOTAL_COUNT;
        @AuraEnabled
        public Integer PAGE_COUNT;
        @AuraEnabled
        public Integer PAGE_NUM;  
        @AuraEnabled
        public List<InputClass> DATA;
    }

    public class InputClass{

        @AuraEnabled
        public List<Oppty> Opportunity;
        @AuraEnabled
        public List<LBS> LBS;
    }

    public class Oppty{

        @AuraEnabled
        public String Id;
        @AuraEnabled
        public String BizDevelopmentType;
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public String LogisticsBizType;
        @AuraEnabled
        public String OwnerID;
        @AuraEnabled
        public String SalesRegionalHQ;
        @AuraEnabled
        public String SalesBranch;
        @AuraEnabled
        public String DeliveryRegionalHQ;
        @AuraEnabled
        public String DeliveryBranch;
    }
    public class LBS{

        @AuraEnabled
        public String OpportunityId;
        @AuraEnabled
        public String LBSID;
        @AuraEnabled
        public String LogisticsServiceType;
        @AuraEnabled
        public String BiddingDeadline;
        @AuraEnabled
        public String CloseDate;
        @AuraEnabled
        public String cRevenueStartDate;
        @AuraEnabled
        public String cRevenueEndDate;
        @AuraEnabled
        public String Type;
        @AuraEnabled
        public String LBSStatus;
        @AuraEnabled
        public String Amount;
        @AuraEnabled
        public String LEGAL_SYS_CNTRT_NO;
    }
}