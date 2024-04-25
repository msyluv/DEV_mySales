/**	
* @description       : 	
* @author            : ukhyeon.lee@samsung.com	
* @group             : 	
* @last modified on  : 2024-03-28
* @last modified by  : vikrant.ks@samsung.com	
* Modifications Log 	
* Ver   Date         Author                    Modification	
* 1.0   07-13-2021   ukhyeon.lee@samsung.com   Initial Version	
* 1.1	02-11-2022   younghoon.kim@dkbmc.com 수전위 수정사항 추가(수전위 요청일, 수전위 시행일, RFP 공고일, 제안 제출일, 사업기회 개요)	
* 1.2   2022-11-02   Kajal.c@samsung.com 	   Add IV_VRB_TYPE value to store in 'Opportunity_Review_VRB_Type__c' opportunity field.
* 1.3   2024-03-28   vikrant.ks@samsung.com    If IV_VERSION = 'XP63' OR 'XP73' then updated the 'XP63_EndDate_c' OR 'XP73_EndDate_c' field as APPR_DATE respectively.(MySales-481)
**/
@RestResource(urlMapping = '/IF144/*')
global class IF_SdUpdateVRBStatusController {
    private static final String INTERFACE_ID = 'IF-144';
    private static final String APEX_CLASS   = 'IF_SdUpdateVRBStatusController';
    private static final String METHOD_NAME  = 'doPost';
    private static Boolean validate;    
    private static String errorMsg;    
    //V1.2 Kajal-> Add  oppVrbRewiewType, oppVrbRewiewConfirm
    private static String boCode, companyCode, transactionName, reqDate, chkDate, costDate, apprDate, vrbApporvalType, vrbNew, conductDate, announceDate, submitDate, boOverView,oppVrbRewiewType;
    private static Opportunity opportunity;
    
    private static final String ACTIVITY_STATUS_COMPLETED = 'Completed';
    private static final String ACTIVITY_STATUS_INPROGRESS = 'In Progress';
    private static final String ACTIVITY_BIZ_PART_REQ = 'XP61'; // Request for strategy committee (Biz. Participation)
    private static final String ACTIVITY_BIZ_PART_COST = 'XP62'; // P&L for strategy committee (Biz. Participation)
    private static final String ACTIVITY_BIZ_PART_APPR = 'XP63'; // Approval for strategy committee (Biz. Participation)
    private static final String ACTIVITY_BID_DECI_REQ = 'XP71'; // Request for strategy committee (Bidding. Decision)
    private static final String ACTIVITY_BID_DECI_COST = 'XP72'; // P&L for strategy committee (Bidding. Decision)
    private static final String ACTIVITY_BID_DECI_APPR = 'XP73'; // Approval for strategy committee (Bidding. Decision)
    private static final String ACTIVITY_RECEIVE_RFP = 'XP31'; // Receive RFP
    private static final String ACTIVITY_SUBMIT_PROP = 'ZP61'; // Submit Proposal
    private static final String VRB_APPROVAL_TYPE_PARTICIPATION = '10';
    private static final String VRB_APPROVAL_TYPE_NON_ATTENDANCE = '20';
    private static final String VRB_APPROVAL_TYPE_HOLD = '30';
    private static final String VRB_NEW = 'Y';
    private static final String[] ACTIVITY_BIZ_PART = new String[]{ACTIVITY_BIZ_PART_REQ, ACTIVITY_BIZ_PART_COST, ACTIVITY_BIZ_PART_APPR};
        private static final String[] ACTIVITY_BID_DECI = new String[]{ACTIVITY_BID_DECI_REQ, ACTIVITY_BID_DECI_COST, ACTIVITY_BID_DECI_APPR};
            private static final String[] ACTIVITY_BIZ_AND_BID = new String[]{ACTIVITY_BIZ_PART_REQ, ACTIVITY_BIZ_PART_COST, ACTIVITY_BIZ_PART_APPR, ACTIVITY_BID_DECI_REQ, ACTIVITY_BID_DECI_COST, ACTIVITY_BID_DECI_APPR};
                
                @HttpPost
                global static OutputHeader doPost() {
                    String guId      = IF_Util.generateGuid();
                    IF_Log.InterfaceLog infLog;
                    IF_Log log = new IF_Log();
                    RestRequest req = RestContext.request;
                    Blob    reqBody = req.requestBody;
                    
                    InputHeader input = (InputHeader)JSON.deserializeStrict(reqBody.toString(),InputHeader.class);
                    OutputHeader outHeader = new OutputHeader();
                    SavePoint sp = DataBase.setSavePoint();
                    try{
                        boCode = input.IV_ZZORDER_ID;
                        companyCode = input.IV_BUKRS;
                        transactionName = input.IV_VERSION;
                        reqDate = input.REQ_DATE;
                        chkDate = input.CHK_DATE;
                        costDate = input.COST_DATE;
                        apprDate = input.APPR_DATE;
                        vrbApporvalType = input.VRB_APPROVAL_TYPE;
                        vrbNew = input.VRB_NEW;
                        
                        // 2022-02-11 / [Strat] 수전위 수정사항 추가
                        conductDate = input.CONDUCT_DATE;
                        announceDate = input.RFP_ANNOUNCE_DATE;
                        submitDate = input.PROPOSAL_SUBMIT_DATE;
                        boOverView = input.BO_OVERVIEW;
                        // 2022-02-11 / [End] 수전위 수정사항 추가
                        oppVrbRewiewType = input.IV_VRB_TYPE;  // V1.2 --Kajal
                        if(validate()){
                            List<Opportunity_Activity__c> opportunityActivityList;
                            Set<String> transactionList = new Set<String>();
                            String[] queryTransactionArr =  new String[]{};
                                String[] transactionArr =  new String[]{};
                                    
                                    if(!VRB_NEW.equals(vrbNew)){                                        //품의결과수신           
                                        if(ACTIVITY_BIZ_PART_APPR.equals(transactionName)){
                                            queryTransactionArr = ACTIVITY_BIZ_PART;
                                            if(String.isNotBlank(vrbApporvalType)){
                                                opportunity.XP63_VRB_APPROVAL_TYPE__c = vrbApporvalType;
                                            }
                                        } 
                                        else if(ACTIVITY_BID_DECI_APPR.equals(transactionName)){
                                            queryTransactionArr = ACTIVITY_BID_DECI;
                                            if(String.isNotBlank(vrbApporvalType)){
                                                opportunity.XP73_VRB_APPROVAL_TYPE__c = vrbApporvalType;
                                                if(VRB_APPROVAL_TYPE_NON_ATTENDANCE.equals(vrbApporvalType) || VRB_APPROVAL_TYPE_HOLD.equals(vrbApporvalType)){
                                                    opportunity.DealBreak__c = true;
                                                }
                                            }
                                        }
                                    } else {                                                            //신규차수진행
                                        opportunity.DealBreak__c = false;
                                        if(ACTIVITY_BIZ_PART_APPR.equals(transactionName)){  
                                            queryTransactionArr = ACTIVITY_BIZ_AND_BID;
                                            opportunity.XP63_VRB_APPROVAL_TYPE__c = null;
                                            opportunity.XP73_VRB_APPROVAL_TYPE__c = null;
                                        } else if(ACTIVITY_BID_DECI_APPR.equals(transactionName)){
                                            queryTransactionArr = ACTIVITY_BID_DECI;                    
                                            opportunity.XP73_VRB_APPROVAL_TYPE__c = null;
                                        }                    
                                    }
                            
                            /**V1.2-START--Kajal**/	
                            if(ACTIVITY_BIZ_PART_APPR.equals(transactionName)){
                                system.debug('Entry1');
                                //Required Date START
                                transactionArr.add(ACTIVITY_BIZ_PART_REQ);
                                opportunity.XP6_REQ_DATE__c = Util_String.convertStringDate(reqDate); 
                                //Required Date END
                                //Cost Date
                                transactionArr.add(ACTIVITY_BIZ_PART_COST);
                                //Approval Date
                                transactionArr.add(ACTIVITY_BIZ_PART_APPR);
                                //Conduct Date
                                opportunity.XP6_CONDUCT_DATE__c = Util_String.convertStringDate(conductDate);
                                opportunity.XP63_EndDate__c = Util_String.convertStringDate(apprDate);//V1.3
                                
                            }else if(ACTIVITY_BID_DECI_APPR.equals(transactionName)){
                                system.debug('Entry2');
                                //Required Date START
                                transactionArr.add(ACTIVITY_BID_DECI_REQ);
                                opportunity.XP7_REQ_DATE__c = Util_String.convertStringDate(reqDate);
                                //Required Date END
                                //Cost Date
                                transactionArr.add(ACTIVITY_BID_DECI_COST);
                                //Approval Date
                                transactionArr.add(ACTIVITY_BID_DECI_APPR);
                                //Conduct Date
                                opportunity.XP7_CONDUCT_DATE__c = Util_String.convertStringDate(conductDate);
                                opportunity.XP73_EndDate__c = Util_String.convertStringDate(apprDate);//V1.3
                            }   
                            /**V1.2-END--Kajal**/
                            system.debug('Entry3' + transactionArr.size());
                            system.debug('Entry4' + queryTransactionArr.size());
                            
                            
                            opportunity.XP31_RFP_ANNOUNCE_DATE__c = Util_String.convertStringDate(announceDate); // RFP 공고일
                            opportunity.ZP61_PROPOSAL_SUBMIT_DATE__c = Util_String.convertStringDate(submitDate); // 제안 제출일    
                            
                            /**V1.2-START--Kajal**/	
                            if(String.isNotBlank(oppVrbRewiewType)){	
                                opportunity.Opportunity_Review_VRB_Type__c = oppVrbRewiewType;	
                                opportunity.Opportunity_Review_VRB_Type_Confirm__c = oppVrbRewiewType;	
                            }	
                            /**V1.2-END--Kajal**/
                            
                            //SD기능 롤백
                            //if(String.isNotBlank(boOverView)){
                            //opportunity.Description = boOverView.replace('\\r\\n','\r\n'); // 사업기회 개요
                            //}
                            // 2022-02-11 / [End] 수전위 수정사항 추가
                            
                            opportunityActivityList = [SELECT Id, TransactionName__c, WhatId__c, StartDate__c, EndDate__c, Status__c 
                                                       FROM Opportunity_Activity__c 
                                                       WHERE WhatId__c =: opportunity.id AND TransactionName__c in : queryTransactionArr];
                            
                            system.debug('Test@@1' + opportunityActivityList.size());
                            if(!opportunityActivityList.isEmpty()){
                                for(Opportunity_Activity__c activity : opportunityActivityList){
                                    transactionList.add(activity.TransactionName__c);
                                }                                                
                            }   
                            system.debug('Test@@2' + transactionList.size());
                            system.debug('Test@@3' + transactionArr.size());
                            
                            /**V1.2-START--Kajal**/	
                            for(String trans : transactionArr){
                                if(transactionList==null || !transactionList.contains(trans)){
                                    Opportunity_Activity__c opptyAct = new Opportunity_Activity__c();
                                    opptyAct.WhatId__c = opportunity.id;
                                    opptyAct.TransactionName__c = trans;
                                    opportunityActivityList.add(opptyAct);
                                }
                            }
                            for(Opportunity_Activity__c opptyAct : opportunityActivityList){ 
                                if(ACTIVITY_BIZ_PART_REQ.equals(opptyAct.TransactionName__c) || ACTIVITY_BID_DECI_REQ.equals(opptyAct.TransactionName__c)){
                                    opptyAct.EndDate__c = Util_String.convertStringDate(reqDate);                           
                                }                            
                                if(ACTIVITY_BIZ_PART_COST.equals(opptyAct.TransactionName__c) || ACTIVITY_BID_DECI_COST.equals(opptyAct.TransactionName__c)){
                                    opptyAct.EndDate__c = Util_String.convertStringDate(costDate);
                                }
                                if(ACTIVITY_BIZ_PART_APPR.equals(opptyAct.TransactionName__c) || ACTIVITY_BID_DECI_APPR.equals(opptyAct.TransactionName__c)){
                                    opptyAct.EndDate__c = Util_String.convertStringDate(apprDate);
                                }
                            }
                            if(!VRB_NEW.equals(vrbNew)){  
                                system.debug('Test@@4');
                                for(Opportunity_Activity__c opptyAct : opportunityActivityList){                 
                                    opptyAct.StartDate__c = opptyAct.EndDate__c;                        
                                    opptyAct.Status__c = ACTIVITY_STATUS_COMPLETED;
                                    if(opptyAct.EndDate__c == null){
                                        opptyAct.Status__c = ACTIVITY_STATUS_INPROGRESS;         
                                    }
                                }
                            } else{
                                system.debug('Test@@5');
                                //신규차수일 경우 사업참여/입찰결정 요청 액티비티는 필요함
                                if(transactionList==null || (ACTIVITY_BIZ_PART_APPR.equals(transactionName) && !transactionList.contains(ACTIVITY_BIZ_PART_REQ))){
                                    system.debug('Test@@6');
                                    Opportunity_Activity__c opptyAct = new Opportunity_Activity__c();
                                    opptyAct.WhatId__c = opportunity.id;
                                    opptyAct.TransactionName__c = ACTIVITY_BIZ_PART_REQ;
                                    opportunityActivityList.add(opptyAct);
                                } 
                                if(transactionList==null || (ACTIVITY_BID_DECI_APPR.equals(transactionName) && !transactionList.contains(ACTIVITY_BID_DECI_REQ))){
                                    system.debug('Test@@7');
                                    Opportunity_Activity__c opptyAct = new Opportunity_Activity__c();
                                    opptyAct.WhatId__c = opportunity.id;
                                    opptyAct.TransactionName__c = ACTIVITY_BID_DECI_REQ;
                                    opportunityActivityList.add(opptyAct);
                                }
                                system.debug('Test@@8'+ opportunityActivityList.size());
                                //신규차수 - Activity 빈값 처리
                                if(!opportunityActivityList.isEmpty()){
                                    system.debug('Test@@9');
                                    for(Opportunity_Activity__c opptyAct : opportunityActivityList){
                                        system.debug('Test@@10' + opptyAct.TransactionName__c);
                                        system.debug('test@@11'+ transactionName);
                                        if((ACTIVITY_BIZ_PART_APPR.equals(transactionName) && ACTIVITY_BIZ_PART_REQ.equals(opptyAct.TransactionName__c))
                                           ||(ACTIVITY_BID_DECI_APPR.equals(transactionName) && ACTIVITY_BID_DECI_REQ.equals(opptyAct.TransactionName__c))){
                                               system.debug('test@@12');
                                               opptyAct.EndDate__c = Util_String.convertStringDate(reqDate);
                                               opptyAct.StartDate__c = opptyAct.EndDate__c;
                                               opptyAct.Status__c = ACTIVITY_STATUS_COMPLETED;
                                           } else{
                                               system.debug('test@@13');
                                               opptyAct.StartDate__c = Util_String.convertStringDate(reqDate);
                                               opptyAct.EndDate__c = null;
                                               opptyAct.DueDate__c = null;
                                               opptyAct.Status__c = ACTIVITY_STATUS_INPROGRESS;
                                           }
                                        
                                    }
                                }
                            }
                            //Update - Opportunity
                            update opportunity;
                            //Upsert - Opportunity Activity
                            if(!opportunityActivityList.isEmpty()){
                                upsert opportunityActivityList;
                            }                
                            
                            outHeader.VRB_RESULT            = IF_Util.RESULT_STATUS_SUCCESS;
                            outHeader.VRB_RESULT_MSG        = IF_Util.RESULT_MESSAGE_SUCCESS;    
                        } else{            
                            outHeader.VRB_RESULT            = IF_Util.RESULT_STATUS_ERROR;    
                            outHeader.VRB_RESULT_MSG        = errorMsg;                
                        }   
                        infLog = new IF_Log.InterfaceLog( INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqBody.toString(), JSON.serialize(outHeader));         
                    }catch(Exception e){
                        DataBase.rollback( sp);            
                        outHeader.VRB_RESULT                = IF_Util.RESULT_STATUS_ERROR;
                        outHeader.VRB_RESULT_MSG            = e.getCause()+e.getMessage()+e.getTypeName()+e.getLineNumber();
                        infLog = new IF_Log.InterfaceLog( INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqBody.toString(), JSON.serialize(outHeader),e);
                    }
                    
                    log.createLog( infLog);        
                    return outHeader;
                }   
    
    // I/F 데이터 유효성 검증
    private static Boolean validate(){
        if(String.isBlank(boCode)){
            errorMsg = 'BO code is empty.';
            return false;
        }
        if(String.isBlank(companyCode)){
            errorMsg = 'Company code is empty.';
            return false;
        }
        List<Opportunity> opportunityList = [SELECT Id, OpportunityCode__c, CompanyCode__c, cRevenueStartDate__c, cRevenueEndDate__c, Amount, CurrencyIsoCode, DealBreak__c,  XP63_VRB_APPROVAL_TYPE__c,  XP73_VRB_APPROVAL_TYPE__c
                                             FROM Opportunity 
                                             WHERE OpportunityCode__c=:boCode AND CompanyCode__c=:companyCode ];
        if(opportunityList.isEmpty()){
            errorMsg = 'BO does not exist.';
            return false;
        }
        opportunity = opportunityList[0];
        
        if(String.isBlank(transactionName)){
            errorMsg = 'Transaction name is empty.';
            return false;
        }
        if(!ACTIVITY_BIZ_PART_APPR.equals(transactionName) && !ACTIVITY_BID_DECI_APPR.equals(transactionName)){
            errorMsg = 'Invalid Transaction name.';
            return false;
        }
        if(!validateDate(reqDate)){
            errorMsg = 'Invalid Request date.';
            return false;
        }
        if(!validateDate(chkDate)){
            errorMsg = 'Invalid Checklist date.';
            return false;
        }
        if(!validateDate(costDate)){
            errorMsg = 'Invalid Cost date.';
            return false;
        }
        if(!validateDate(apprDate)){
            errorMsg = 'Invalid Approval date.';
            return false;
        }
        if(String.isNotBlank(vrbApporvalType) 
           && !VRB_APPROVAL_TYPE_PARTICIPATION.equals(vrbApporvalType) 
           && !VRB_APPROVAL_TYPE_NON_ATTENDANCE.equals(vrbApporvalType) 
           && !VRB_APPROVAL_TYPE_HOLD.equals(vrbApporvalType)){
               errorMsg = 'Invalid VRB Approval type.';
               return false;
           }
        if(String.isNotBlank(apprDate) && String.isBlank(vrbApporvalType)){
            errorMsg = 'VRB Approval Type is empty.';
            return false;
        }
        if(String.isBlank(apprDate) && String.isNotBlank(vrbApporvalType)){
            errorMsg = 'Approval date is empty.';
            return false;
        }
        if(String.isNotBlank(vrbNew) && !VRB_NEW.equals(vrbNew)){
            errorMsg = 'Invalid VRB new flag.';
            return false;
        }
        
        // 2022-02-11 / [Strat] 수전위 수정사항 추가
        if(!validateDate(conductDate)){
            errorMsg = 'Invalid Conduct date.';
            return false;
        }
        if(!validateDate(announceDate)){
            errorMsg = 'Invalid RFP Announce date.';
            return false;
        }
        if(!validateDate(submitDate)){
            errorMsg = 'Invalid Proposal Submit date.';
            return false;
        }
        // 2022-02-11 / [End] 수전위 수정사항 추가
        
        return true;
    }
    
    private static Boolean validateDate(String stringDate){
        if(String.isNotBlank(stringDate) && stringDate.length()!=8){
            return false;
        }
        return true;
    }
    
    global class OutputHeader{
        public String VRB_RESULT    = '';       // 처리 결과
        public String VRB_RESULT_MSG    = '';      // 에러메세지
    }
    
    global class InputHeader{
        public String IV_ZZORDER_ID;
        public String IV_BUKRS;
        public String IV_VERSION;
        public String REQ_DATE;
        public String CHK_DATE;
        public String COST_DATE;
        public String APPR_DATE;
        public String VRB_APPROVAL_TYPE;
        public String VRB_NEW;
        // 2022-02-11 / [Start] 수전위 수정사항 추가(수전위 요청일, 수전위 시행일, RFP 공고일, 제안 제출일, 사업기회 개요)
        // public String REQ_DATE;
        public String CONDUCT_DATE;
        public String RFP_ANNOUNCE_DATE;
        public String PROPOSAL_SUBMIT_DATE;
        public String BO_OVERVIEW;
        // 2022-02-11 / [End] 수전위 수정사항 추가(수전위 요청일, 수전위 시행일, RFP 공고일, 제안 제출일, 사업기회 개요)
        public String IV_VRB_TYPE;  //V1.2 Kajal
    }
}