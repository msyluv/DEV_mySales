/**
 * @description       : 
 * @author            : wonjune.oh@partner.samsung.com
 * @group             : 
 * @last modified on  : 11-05-2023 
 * @last modified by  : anish.jain@partner.samsung.com  
 * Modifications Log 
 * Ver   Date         Author                           Modification
 * 1.0   2020-11-16   wonjune.oh@partner.samsung.com   Initial Version
 * 1.1   2022-04-28   hyunhak.roh@dkbmc.com            [설명] 필드 200자 이상 등록하도록 제어하는 기능
 * 1.2	 2022-05-03   hyunhak.roh@dkbmc.com            Drop/Lost 완결된 이후(=현재 완결 상태) Drop/Lost Activity에서 값 
 * 													   변경 후 '저장(Save)' 버튼 실행 시 전송
 * 1.3   2022-05-26   akash.g@samsung.com              Add functionality of User Manual Button in Service/Solution tab.
 * 1.4.  2022-05-27   hyunhak.roh@dkbmc.com			   BO Lock 상태에서 Drop/Lost Activity 필드 처리
 * 1.5   2023-04-03   divyam.gupta@samsung.com         Remove logic for udapting Activity Description while changing the Service Solution tab(MySales -161)
 * 1.6   2023-05-12   divyam.gupta@samsung.com         Add new tab Analysis of Reason for Drop Lost and Postmortem Result.
 * 1.7   11-05-2023   anish.jain@partner.samsung.com   MySales - 216
 * 1.8   2024-02-19   anish.jain@partner.samsung.com   BO Review Approval Issue Check (MS-418)
**/
({
	DEBUG : true,

	init : function(component, event) {
		var self = this;
        // Activity Code 값 Activity 가 생성된경우 Activity transaction Code로 Setting 
		var masterActCode = component.get('v.activityItem.MasterAct.TransactionName__c');
		var opptyAct = component.get('v.opportunityActivity');
		var opptyActCode = '';
        
		if(opptyAct) {
		  opptyActCode = opptyAct['TransactionName__c'];
		}
		var transactionCode = opptyActCode ? opptyActCode :masterActCode;
        component.set('v.TransactionName', transactionCode); 
         /**-- V 1.6 Change by Divyam gupta--**/
        var stageType = component.get('v.Activity_LostType');
        component.set('v.lostDropTypeVal',stageType);
        // 2022-02-11 / [Start] 수전위 수정사항 추가
        var bizActList = ['XP61', 'XP62', 'XP63']; // 사업참여결정 액티비티
        var bidActList = ['XP71', 'XP72', 'XP73']; // 입찰결정 액티비티
        var RFPProposalList = ['XP31', 'ZP61']; // RFP 접수, 견적/제안 제출 액티비티
        if(bizActList.includes(transactionCode)) component.set('v.isBiz', true);
        if(bidActList.includes(transactionCode)) component.set('v.isBid', true);
        if(RFPProposalList.includes(transactionCode)) component.set('v.IsRFPProposal', true);
		// 2022-02-11 / [Start] 수전위 수정사항 추가
        
		// Lost Type 초기화
		component.set('v.Activity_LostType', '');
	    /* initComponent */    
		// [2021-03-05 수정]
		/*
		var opptyActivityObj = {
		  Id : component.get('v.recordId'),
		  WhatId__c    : component.get('v.parentId'),
		  TransactionName__c : transactionCode,
		  Index__c : component.get('v.activityItem.Index')
		};
		*/
	    var apexAction = 'initComponent';
		var apexParams = {
		  'opptyId' : component.get('v.parentId'),
		  'transactionName' : component.get('v.MasterAct_TransactionName')
		};
		console.log(' transactionName ', component.get('v.MasterAct_TransactionName'));
		
	
		self.apex(component, apexAction, apexParams)
		.then((result) => {
            component.set('v.reloadForm', false);
			
			component.set('v.resultObj', JSON.parse(result));
			console.log('[NEW] initComponent.result', JSON.parse(result));
		
			var resultObj = component.get('v.resultObj');
            //for Anish-v 1.7 start
            component.set('v.selectedValueBOReview' , resultObj.knoxApprovalActivityForBOReview);
            
            //Start - Added by Anish-v 1.8
            if(resultObj.opportunity.VRB_Account_Change__c == false){
           
            component.set('v.updatedValueBOReview' , resultObj.knoxApprovalActivityForBOReview);
        }
            if(resultObj.opportunity.VRB_Account_Change__c == true){
            console.log(' VRB_Account_Change__c--1> ', resultObj.opportunity.VRB_Account_Change__c);
            component.set('v.updatedValueBOReview' , '7');
        }
            //End - Added by Anish-v 1.8
            
            if((resultObj.opportunity.Opportunity_Review_Confirm__c == true) /*|| resultObj.opportunity.Opportunity_Review_VRB_Type_Confirm__ != '30'*/){
            component.set('v.isConfirmed' , true);
        }
            
            if(component.get('v.MasterAct_TransactionName') == 'ZP21'){
            if(resultObj.opportunity.Opportunity_Review_VRB_Type__c == '30' && resultObj.isNotHQ == false){
            console.log(' transactionName--2> ', component.get('v.MasterAct_TransactionName'));
            component.set('v.isBoReviewTab' , true);
            if(resultObj.opportunity.CompanyCode__c == 'T100' && resultObj.opportunity.Collaboration__c == false && !(resultObj.opportunity.cOriginAcc__r.AccountGroup__c == 'ZIC2' || resultObj.opportunity.cOriginAcc__r.AccountGroup__c == 'ZIC') ){ //531
            console.log(' transactionName--1> ', component.get('v.MasterAct_TransactionName'));
            component.set('v.MasterAct_IsRequiredKnoxApproval',true);
        }
            else{
            component.set('v.MasterAct_IsRequiredKnoxApproval',false);
        }
            
         }
        }
            //for Anish-v 1.7 end
            if(resultObj.opportunity) {
            component.set('v.opportunity', resultObj.opportunity);
            /**--START V 1.6 Change by Divyam gupta--**/
            var opprcrd = component.get('v.opportunity');
            component.set('v.oppCompanyCode', opprcrd.CompanyCode__c);
            var checkcompcode = component.get('v.oppCompanyCode');
            component.set('v.postMotermTypeval',opprcrd.Post_Moterm_Type__c);
            
            //Divyam gupta  if (checkcompcode == 'T100' && stageType == 'Z06')
            if (stageType == 'Z06' || stageType == 'Z07') {
            
            component.set('v.analysisCompShow', true);
            component.set('v.reasonDesShow', false);
            /**--END V 1.6 --**/
        }
            
        }

            if(resultObj.opportunityActivityId) {
            component.set('v.recordId', resultObj.opportunityActivityId);
            /**--START V 1.6 Change by Divyam gupta--**/
            component.set('v.oppActstatus', resultObj.opprtunityactstatus);
            if(resultObj.opprtunityactstatus == 'Completed' || resultObj.opprtunityactstatus == 'In Progress'){
            component.set("v.oppactvalcompinprog",true);
            /**--END V 1.6 --**/
        }
        }

			if(resultObj.isPendingKnoxApproval) {
				component.set('v.isPendingKnoxApproval', resultObj.isPendingKnoxApproval);				
			}
            //
            if(resultObj.isDropLostLock) {
            	component.set('v.isDropLostLock', resultObj.isDropLostLock);
        	}
		  
           
		  	component.set('v.owner', resultObj.owner);	//물류 APS 버튼 처리를 위한 Owner 정보.
		  	component.set('v.hasEditAccess', resultObj.hasEditAccess);
			//신규추가시작
			component.set('v.isSubsidiary', resultObj.isSubsidiary);
			component.set('v.creditAssessmentText', resultObj.creditAssessmentText);
			//console.log('creditTextAni', component.get('v.isPendingKnoxApproval'));
			//신규추가종료
		  	component.set('v.reloadForm', true);
            
            //Submit Proposal 등록 여부.
            //component.set('v.isNotCompletedZP61', resultObj.cpZP82NotCompletedZP61);

            //신규추가시작
			if(resultObj.cannotProceedZP82){
				this.showToast(component, 'ERROR', 'dismissible', $A.get('$Label.c.COMM_LAB_ERROR'), $A.get('$Label.c.OPPTYACT_CONTRACT_APPROVAL_CANNOT_PROCEED')); 
			}
            if(resultObj.cannotProceedZP82Null){
				this.showToast(component, 'ERROR', 'dismissible', $A.get('$Label.c.COMM_LAB_ERROR'), $A.get('$Label.c.OPPTYACT_REQUEST_RESOURCES_CANNOT_PROCEED_NULL')); 
			}
			if(resultObj.cannotProceedZP32){
				this.showToast(component, 'ERROR', 'dismissible', $A.get('$Label.c.COMM_LAB_ERROR'), $A.get('$Label.c.OPPTYACT_REQUEST_RESOURCES_CANNOT_PROCEED')); 
			}
            if(resultObj.cannotProceedZP32Null){
				this.showToast(component, 'ERROR', 'dismissible', $A.get('$Label.c.COMM_LAB_ERROR'), $A.get('$Label.c.OPPTYACT_REQUEST_RESOURCES_CANNOT_PROCEED_NULL')); 
			}            
            if(resultObj.cannotProceedParticipation){
				this.showToast(component, 'ERROR', 'dismissible', $A.get('$Label.c.COMM_LAB_ERROR'), $A.get('$Label.c.OPPTYACT_REQUEST_RESOURCES_CANNOT_PROCEED_NULL')); 
			}
			if(resultObj.cannotProceedDecision){
				this.showToast(component, 'ERROR', 'dismissible', $A.get('$Label.c.COMM_LAB_ERROR'), $A.get('$Label.c.OPPTYACT_DECISION_CANNOT_PROCEED')); 
			}
           
            
                  //신규추가종료
            // //for Anish-v 1.7 start -> show/hide knox tabs based on recent knox approval value in case of BO review activity
            if(component.get('v.MasterAct_TransactionName') == 'ZP21'){
            console.log('value123--->' + component.get('v.selectedValueBOReview'));
            //Added by Anish-v 1.8
            if(resultObj.opportunity.VRB_Account_Change__c == false && resultObj.opportunity.Opportunity_Review_VRB_Type_Confirm__c== '30'){
            console.log('value1234--->' + resultObj.opportunity.VRB_Account_Change__c);
            if(component.get('v.selectedValueBOReview') == '' && resultObj.opptyAct == 'Completed'){
            component.set('v.isPendingKnoxApproval',true);
            if(resultObj.opportunity.BO_Review_Approval_MigYN__c == 'Y'){   //Migration Changes - Added by Anish - v 1.7
            component.set('v.boApprovalMigYN',true);
            component.set('v.boApprovalMigYNNon',false);
            }
            }
            else{
            if(component.get('v.selectedValueBOReview') == '3'  || component.get('v.selectedValueBOReview') == '4' || component.get('v.selectedValueBOReview') == '' ){
            console.log('KnoxStatus@#' + component.get('v.selectedValueBOReview'));
            if(resultObj.oppApproved == true)
            {
            console.log('inside show');
            component.set('v.isPendingKnoxApproval',true);
        }
            if(resultObj.oppApproved == false){
            component.set('v.isPendingKnoxApproval',false);
        }
        }
            else{
            console.log('KnoxStatus' + component.get('v.selectedValueBOReview'));
            component.set('v.isPendingKnoxApproval',true);
    
        }
        }
        }
            //Added by Anish-v 1.8
            if(resultObj.opportunity.VRB_Account_Change__c == true && resultObj.opportunity.Opportunity_Review_VRB_Type_Confirm__c== '30'){
            console.log('value12345--->' + resultObj.opportunity.VRB_Account_Change__c);
            component.set('v.isPendingKnoxApproval',false);
        }
        }
        
            //for Anish-v 1.7 end
		})
		.then((result) => {
            return self.getOpportunityActivity(component, event);
		})
		.catch((errors) => {
		  self.errorHander(errors);
		})
		.finally(() => {
		  //self.refresh(component, event);  
		});
	},

	onSelectTabSet : function(component, event){
		var self = this;
		var status = component.get('v.Activity_Status');
		var tabstep = component.get('v.activeStep');
        var transaction = component.get('v.MasterAct_TransactionName');
        var formfields = component.find('fields');
        var isDropLostDescErr = false;
		component.set('v.opptyCheckResult',true);

		var opptyAct = component.get('v.opportunityActivity');
		var opptyActLostType = ''; // 실제 Record 
        var opptyDropLostDesc = '';
          
        /*for V Anish-v 1.7 */ var updatedResult = component.get('v.resultBOReviewOppObj');
                			   var resultObj = component.get('v.resultObj');
		if(opptyAct) {
			opptyActLostType = opptyAct['LostType__c'];
			//console.log('(2)opptyActLostType',  opptyActLostType );
            opptyDropLostDesc = opptyAct['Description__c'];
            //console.log('(2)opptyDropLostDesc',  opptyDropLostDesc );            
            //console.log('### onSelectTabSet, initOpptyActDescription : ',  component.get('v.initOpptyActDescription'));
            //console.log('### onSelectTabSet, 상단의 formfields 를 가지고, 하단에서 Description 체크함 : ',  opptyDropLostDesc);
            //console.log('### onSelectTabSet, opptyAct : ',  opptyAct);
            //console.log('### onSelectTabSet, transaction : ',  transaction);
            //console.log('### onSelectTabSet, opptyAct[Description__c] : ',  opptyAct['Description__c']);
            //console.log('### onSelectTabSet, opptyAct[LostType__c] : ',  opptyAct['LostType__c']);
            //console.log('### onSelectTabSet, opptyAct[DueDate__c] : ',  opptyAct['DueDate__c']);
            //console.log('### onSelectTabSet, opptyAct[StartDate__c] : ',  opptyAct['StartDate__c']);
            //console.log('### onSelectTabSet, opptyAct[EndDate__c] : ',  opptyAct['EndDate__c']);
            //console.log('### onSelectTabSet, opptyAct[Status__c] : ',  opptyAct['Status__c']);
		}
        //for V Anish-v 1.7 rakshit.s@samsung.com
                  var transactionName =  component.get('v.TransactionName');
                console.log('updatedResult---->' + updatedResult);
                if(updatedResult!== null){
                         if((tabstep == '3_1' || tabstep == '3_2' || tabstep == '3_3') && (updatedResult.Opportunity_Review_VRB_Type__c == '30' && (updatedResult.Opportunity_Review_VRB_Type__c != updatedResult.Opportunity_Review_VRB_Type_Confirm__c) && transactionName == 'ZP21')){
                             component.set('v.activeStep','1');
                                this.showToast(component, 'ERROR', 'dismissible', $A.get('$Label.c.COMM_LAB_ERROR'), $A.get('$Label.c.BOReviewMessage'));
                            }
                }
                
                else{
                    console.log('inside else for tab error');
                        if((tabstep == '3_1' || tabstep == '3_2' || tabstep == '3_3') && (resultObj.opportunity.Opportunity_Review_VRB_Type__c == '30' && (resultObj.opportunity.Opportunity_Review_VRB_Type__c != resultObj.opportunity.Opportunity_Review_VRB_Type_Confirm__c) && transactionName == 'ZP21')){
                             component.set('v.activeStep','1');
                                this.showToast(component, 'ERROR', 'dismissible', $A.get('$Label.c.COMM_LAB_ERROR'), $A.get('$Label.c.BOReviewMessage'));
                            }
                    
                }
                        //for v Anish-v 1.7 end.
        //Add functionality of User Manual Button in Service/Solution tab.
        component.set('v.showUserManualButton', false);
		// [Review Opportunity] 
		if(transaction == 'ZP21'){
            // [Review Opportunity] Service / Solution 첫 클릭 시 Opporunity Activity New Form 의 Description 저장
			if(tabstep == '2'){
                //Add functionality of User Manual Button in Service/Solution tab.
                component.set('v.showUserManualButton', true);
                /**V:1.5-MySales-161**/
				//var hasEditAccess = component.get('v.hasEditAccess');
				//if(hasEditAccess) self.updateActivityDescription(component, event);
			}
			
			// [Review Opportunity] Project/wbs 클릭시 Refresh
			if(tabstep == '2_1'){
				component.set('v.reloadProjectWBS', true);
			} else {
				component.set('v.reloadProjectWBS', false);
			}
			//신규추가시작
			// [Review Opportunity] BO Review 클릭시 Refresh
			if(tabstep == '2_2'){
				component.set('v.reloadBOReview', true);
			} else {
				component.set('v.reloadBOReview', false);
			}
			//신규추가종료
		}
		
		// [Drop/Lost]
		if(transaction =='ZPZ2' || transaction =='ZPZ1'){
            /**if(opptyDropLostDesc){                
                if(opptyDropLostDesc.trim().length < 200){
                    isDropLostDescErr = true;
                }                      
            }**/
             /**--START V 1.6 Change by Divyam gupta--**/
            var analysiCompShow = component.get('v.analysisCompShow');
             console.log('tabstep =' + tabstep + 'opptyActLostType =' + opptyActLostType +
                'opptyDropLostDesc =' + opptyDropLostDesc +
                'isDropLostDescErr =' + isDropLostDescErr);
			if(tabstep != '1'){
                //var isNotCompletedZP61 = component.get('v.isNotCompletedZP61');
                //console.log('### onSelectTabSet, isNotCompletedZP61 = ' + isNotCompletedZP61);
                //console.log('### onSelectTabSet, transaction = ' + transaction);
                
               if (((!opptyActLostType || !opptyDropLostDesc) && !analysiCompShow) || isDropLostDescErr) {
                    /**--END V 1.6 --**/                   
                    component.set('v.activeStep','1');
                    this.showToast(component, 'ERROR', 'dismissible', $A.get('$Label.c.COMM_LAB_ERROR'), $A.get('$Label.c.OPPTYACT_MSG_006')); 
                    component.set('v.opptyCheckResult',false);                    
                //}else if(isNotCompletedZP61 && opptyActLostType =='Z06'){
                //    component.set('v.activeStep','1');
                //    this.showToast(component, 'WARNING', 'dismissible','', $A.get('$Label.c.OPPTYACT_MSG_017')); 
                //    component.set('v.opptyCheckResult',false); 
                }
			}
            /**--START V 1.6 Change by Divyam gupta--**/
            var stageType = component.get('v.Activity_LostType');
            var checkcompcode = component.get('v.oppCompanyCode');
            var oppactstatusval = component.get('v.oppActstatus');

            if (tabstep == '1.11') {
               // if (checkcompcode == 'T100' && stageType == 'Z06')
                 if (stageType == 'Z07' || stageType == 'Z06')  {
                    component.set('v.showknoxpreviewtable', false);
                    console.log('Ani Table');
                     debugger;
                }
            } else {
                component.set('v.showknoxpreviewtable', true);
                    console.log('Ani Table Reverse');
            }
            if (tabstep != '1.11' && tabstep != '1') {
                if ((stageType == 'Z07' || stageType == 'Z06') && oppactstatusval != 'Completed' && oppactstatusval != 'In Progress') {
                    var apexAction = 'checkoppactlostResultrcd';
                    var apexParams = {
                        opptId: component.get('v.parentId'),
                        opptyActId: component.get('v.recordId')
                    };
                    this.apex(component, apexAction, apexParams)
                        .then((result) => {
                            // console.log('resultcomingd',result);
                            var resultmap = JSON.parse(result);
                            var lostrest = resultmap.lostResultval;
                            console.log('the lenght of lostrst', lostrest.length);
                            if (lostrest.length == 0) {
                                component.set('v.activeStep', '1.11');
                                component.set('v.checkanalysisrecord',false); 
                                this.showToast(component, 'ERROR', 'dismissible', $A.get('$Label.c.COMM_LAB_ERROR'), $A.get('$Label.c.OPPTYACTY_ERR_MSG002'));

                            }
                              else {
                                component.set('v.checkanalysisrecord',true); 
                              var totalval=0;
                              for(let i=0;i<lostrest.length;i++){
                                    totalval= totalval + lostrest[i].Rate__c;
                                         }  
                    if(tabstep == '3_2' && totalval != 100){
                        this.showToast(component, 'ERROR', 'dismissible', $A.get('$Label.c.COMM_LAB_ERROR'), $A.get('$Label.c.knoxapprovaltotalmsg'));
                        component.set('v.lostResulTotalvl100',false);
                        
                         component.set('v.activeStep', '1.11');

                    }
                              }
                        })
                        .catch((errors) => {
                            self.errorHander(errors);
                        });
                }
            }
            if (tabstep != '1') {
                var oppactstatusval = component.get('v.oppActstatus');
                var checkstageval = component.find("LostType");
                            console.log('altenratestageval--->' + component.get('v.Activity_LostType'));
                         // console.log('stageval',checkstageval.get("v.value"));
                            
                //if (checkcompcode == 'T100' && checkstageval.get("v.value") == 'Z06') 
                if (component.get('v.Activity_LostType') == 'Z06' || component.get('v.Activity_LostType') == 'Z07'){
                    var apexAction = 'checkoppactlostResultrcd';
                    var apexParams = {
                        opptId: component.get('v.parentId'),
                        opptyActId: component.get('v.recordId')
                    };
                    this.apex(component, apexAction, apexParams)
                        .then((result) => {
                            // console.log('resultcomingd',result);
                            var resultmap = JSON.parse(result);
                            var oppActreslt = resultmap.opportunityActivity;
                            console.log('the lenght of oppActreslt', oppActreslt.length);
                            if (oppActreslt.length == 0) {
                                component.set('v.activeStep', '1');
                                this.showToast(component, 'ERROR', 'dismissible', $A.get('$Label.c.COMM_LAB_ERROR'), $A.get('$Label.c.OPPTYACTY_ERR_MSG001'));

                            }
                        })
                        .catch((errors) => {
                            self.errorHander(errors);
                        });

                }
            }
                            

            /**--END V 1.6 --**/
		}
		// [Exception]
		else if(transaction =='ZPZ3'){
			if(tabstep != '1' && tabstep != '2'){
				var opptyUrgency = component.get('v.Oppty_Urgency');
				var opptySecurity = component.get('v.Oppty_Security');

				if(opptyUrgency == null &&  opptySecurity == null){
					component.set('v.activeStep','2');
					this.showToast(component, 'ERROR', 'dismissible', $A.get('$Label.c.COMM_LAB_ERROR'), $A.get('$Label.c.OPPTYACT_MSG_007')); 
					component.set('v.opptyCheckResult',false);
				}
			}
		}
	},

	/**
	 * 
	 * @param {*} component 
	 * @param {*} event 
	 */
	submit : function(component, event) {
		this.log('{ submit }', '');
		
        /**--START V 1.6 Change by Divyam gupta--**/
        if(component.get('v.MasterAct_TransactionName') == 'ZPZ2' || component.get('v.MasterAct_TransactionName') =='ZPZ1'){
            var fields = event.getParams('fields');
            fields.Status__c =  component.get('v.selectedStatus');
        }
        else {
            var fields = event.getParam('fields');
        }
        /**--END V 1.6 --**/
		var dropLostTransaction = component.get('v.MasterAct_TransactionName');
		fields.WhatId__c = component.get('v.parentId');
        /**--START V 1.6 Change by Divyam gupta--**/
        var Stagevalue = component.get('v.Activity_LostType');
        window.console.log('the value of stage', Stagevalue);
        var checkcompcode = component.get('v.oppCompanyCode');
       // Divyam Gupta
       // if (Stagevalue == 'Z06' && checkcompcode == 'T100') 
         if (Stagevalue == 'Z06' || Stagevalue == 'Z07'){
            window.console.log('the value of Boolean');
            component.set('v.analysisCompShow', true);
        } else {
            component.set('v.analysisCompShow', false);

        }
        /**--END V 1.6 --**/

		// [Date Type] input 가져오기
		var dateFields = component.find('dateFields'); // aura-id가 하나인경우 object , 아니면 array 로 반환됨
		console.log('!Array.isArray(dateFields) ', !Array.isArray(dateFields));
		if(!Array.isArray(dateFields)) { 
			dateFields = new Array(dateFields);   // object to array 
		}
		for(var i in dateFields){
			var dateName = dateFields[i].get('v.name');
			var dateValue = dateFields[i].get('v.value');
			var dateDisabled = dateFields[i].get('v.disabled');
			if(dateDisabled == false) {
				fields[dateName] = dateValue;
			}
		}
		
		// [Picklist] Lost Type, Lost Reason 
		if(dropLostTransaction == 'ZPZ2'){
			fields.LostType__c = component.get('v.Activity_LostType'); 		// Opportunity Activity Field 에 업데이트
			fields.LostReason__c = component.get('v.Activity_LostReason');
		}
		
        this.log('[#] SUBMIT fields', fields);

        var isValid = this.validateForm(component, event, fields);	
		if(isValid){
			component.find('recordEditForm').submit(fields); // OpportunityActivity SUBMIT
			component.set('v.showSpinner', true);
		}
	},

	/**
	 * 유효성 확인
	 * @param {\} component 
	 * @param {*} event 
	 * @param {*} fields
	 */
	validateForm : function(component, event, fields) {
		this.log('{ validateForm }', '');
		var isValid = true;
		// 실제 Work 활동 완료 전, Status Completed 처리 불가능
		var MasterAct_IsRequiredWork = component.get('v.MasterAct_IsRequiredWork');
		var MasterAct_WorkName = component.get('v.MasterAct_WorkName');
		var MasterAct_IsAutoInProgress = component.get('v.MasterAct_IsAutoInProgress');
		var Activity_Status = component.get('v.Activity_Status');

		// if(MasterAct_IsAutoInProgress){
			
		// 	if(fields.Status__c == 'In Progress' && (Activity_Status != 'In Progress' && Activity_Status != 'Completed')){
		// 		this.showToast(component, 'ERROR', 'dismissible', $A.get('$Label.c.COMM_LAB_ERROR'), $A.get('$Label.c.OPPTYACT_MSG_002')); // 완료 처리 불가능합니다. Work를 완료하십시오.
		// 		isValid = false;
		// 	}
		// }
		// if(MasterAct_IsRequiredWork) {

		// 	if(fields.Status__c == 'Completed' && !fields.EndDate__c){
		// 		this.showToast(component, 'ERROR', 'dismissible', $A.get('$Label.c.COMM_LAB_ERROR'), $A.get('$Label.c.OPPTYACT_MSG_002')); // 완료 처리 불가능합니다. Work를 완료하십시오.
		// 		isValid = false;
		// 	} 
		// }
		
        //2022-04-28, hyunhak.roh@dkbmc.com, [설명] 필드 200자 이상 등록하도록 제어하는 기능
        var parentId = component.get('v.parentId');
        var recordId = component.get('v.recordId');
        var formfields = component.find('fields');
        var opptyActivityObj = {};
        opptyActivityObj['WhatId__c'] = parentId;
        opptyActivityObj['TransactionName__c'] = component.get('v.TransactionName');
        if(recordId) opptyActivityObj['Id'] = recordId;
        
        //Activity Name : Drop / Lost
        if(component.get('v.MasterAct_TransactionName') == 'ZPZ2') {
        	for(var idx in formfields) {
                //
                if(formfields[idx].get('v.fieldName') == 'Description__c') {
                    //
                    if(formfields[idx].get('v.value') != null && formfields[idx].get('v.value') != '') {
                        
                        opptyActivityObj[formfields[idx].get('v.fieldName')] = formfields[idx].get('v.value');
                        
                        if(opptyActivityObj[formfields[idx].get('v.fieldName')].trim().length < 200) {
                            component.set('v.showDescErrMsg', true);
                            isValid = false;
                        }
                        else {
                            component.set('v.showDescErrMsg', false);
                            isValid = true;
                        }
					}
                }
        	}
        }
        
        return isValid;
	},

	handleOpenLink  : function(component, event) {
		var urlValue = event.getSource().get('v.value');
        var buttonId = event.getSource().getLocalId();
        
		var oppty = component.get('v.opportunity');
		var projectList = component.get('v.resultObj.projectList');
		console.log('projectList', projectList);

        switch (buttonId) {
			/**
			 * 원가판 호출
			 * 1)P_BO : 해당 사업기회의 코드 (OpportunityCode__c) 
			 * 2) P_PSPID : 해당 사업기회의 프로젝트의 프로젝트 코드 (ProjectCode__c) // - 2021.01.12 P_PSPID 미전송
			 * 3) P_BURKS : 해당 사업기회의 법인코드 (CompanyCode__c)
			 * 4) P_STEP :
					C / Pre-sales Resource Request(사전영업자원요청) 
					F / Strategy Committee(수전위)
					S / Contract P&L(수주 원가 확정) - 2021.03.05 변경
			**/
            case 'PRE_SALES_COST': // 사전 영업 원가
				// urlValue = 'http://ieqh1201.sds.samsung.net:50000/irj/servlet/prt/portal/prtroot/controller.IViewController?type=GUI&param=System=SDS_ECC,TCode=ZLP3SDC2100C,AutoStart=TRUE,ApplicationParameter=';
				urlValue += 'P_BO=' + this.nullToString(oppty.OpportunityCode__c) + ';'
				// for(var i in projectList) {
				// 	urlValue += 'P_PSPID=' + projectList[i].ProjectCode__c + ';'
				// }
				urlValue += 'P_PSPID=;'
				urlValue += 'P_BUKRS=' + this.nullToString(oppty.CompanyCode__c)+ ';'
				urlValue += 'P_STEP=C'
				break;
			case 'COMMITTEE_COST_PLAN' : // 수전위 원가
				// urlValue = 'http://ieqh1201.sds.samsung.net:50000/irj/servlet/prt/portal/prtroot/controller.IViewController?type=GUI&param=System=SDS_ECC,TCode=ZLP3SDC2100C,AutoStart=TRUE,ApplicationParameter=';
				urlValue += 'P_BO=' + this.nullToString(oppty.OpportunityCode__c) + ';'
				urlValue += 'P_PSPID=;'
				urlValue += 'P_BUKRS=' + this.nullToString(oppty.CompanyCode__c) + ';'
				urlValue += 'P_STEP=F'
				break;
			case 'CONTRACT_P_L':	// 수주 원가 확정
				// urlValue = 'http://ieqh1201.sds.samsung.net:50000/irj/servlet/prt/portal/prtroot/controller.IViewController?type=GUI&param=System=SDS_ECC,TCode=ZLP3SDC2100C,AutoStart=TRUE,ApplicationParameter=';
				urlValue += 'P_BO=' + this.nullToString(oppty.OpportunityCode__c) + ';'
				urlValue += 'P_PSPID=;'
				urlValue += 'P_BUKRS=' + this.nullToString(oppty.CompanyCode__c) + ';'
				urlValue += 'P_STEP=S'
				break;
			case 'PRICE_SIMULATION':	// 솔루션 가격 시뮬레이션
                /**
                 * ZZBUKRS1=T100&ZZBO_NO=SDS-20050930
                 * - ZZBURKS1 : 해당 사업기회의 법인코드 (CompanyCode__c)
				 * - ZZBO_NO : 해당 사업기회의 코드 (OpportunityCode__c) 
                 **/
				urlValue += 'ZZBUKRS1=' + this.nullToString(oppty.CompanyCode__c);
                urlValue += '&ZZBO_NO=' + this.nullToString(oppty.OpportunityCode__c);
				break;

			case 'REG_CONTRACT' : // 계약서 입고
				urlValue += 'contractNo=' + this.nullToString(oppty.LegalReviewNo__c);
				break;

			case 'REG_PROPOSAL' : // 제안서 등록
				urlValue += 'orderId=' + this.nullToString(oppty.OpportunityCode__c);
				break;
        }
		console.log(' URL : ', urlValue);

        window.open(urlValue, '_blank');
	},

	nullToString : function(string) {
		return string ? string : '';
	},

	setSelectedStatus : function(component, event, selectedStatus) {
		// Status Picklist 선택에 따른 Require 필드를 위해 Selecetd Status 저장
		var status;
		if(selectedStatus) {
			status = selectedStatus;
		} else {
			var formfields = component.find('fields');
			for(var idx in formfields) {		
				var fieldName = formfields[idx].get('v.fieldName');
				if(fieldName == 'Status__c') {
					status = formfields[idx].get('v.value');
					break;
				}
			}
		}
		component.set('v.selectedStatus', status);
	},

	setLostType :function(component, event, selectedLostType){
		// [!] Stage 선택 시,Lost Reason 빈값 처리 
		// (Dependency Picklist에 값이 없는 경우 Disabled 되어 value를 가져올 수 없음)
		component.set('v.Activity_LostReason', '');

		/* 
			모든 Lost Type에 대하여 결재 필요하여 주석처리
			if(lostType == 'XPX1'){
				component.set('v.MasterAct_IsRequiredWork',false);
			}else{
				component.set('v.MasterAct_IsRequiredWork',true);			
			}
		*/
        /**--START V 1.6 Change by Divyam gupta--**/
        var checkcompcode = component.get('v.oppCompanyCode');
        var Stagevalue = component.get('v.Activity_LostType');
        //if (checkcompcode == 'T100' && Stagevalue == 'Z06')
        if (Stagevalue == 'Z07' || Stagevalue == 'Z06') {
            component.set('v.reasonDesShow', false);
            component.set('v.analysisCompShow', true);


        } else {

            component.set('v.reasonDesShow', true);
            component.set('v.analysisCompShow', false);


        }

        /**--END V 1.6 --**/
	},

	setLostReason : function(component, event, selectedValue) {
		component.set('v.Activity_LostReason', selectedValue);
	},

	/**
	 * 2022-05-03, hyunhak.roh@dkbmc.com, Drop/Lost 완결된 이후(=현재 완결 상태) Drop/Lost Activity에서 값 
     * 									  변경 후 '저장(Save)' 버튼 실행 시 전송
	 */
    setIF155CallByOpptyActId: function(component, event) {		
		var self = this;
		
        var isValid = false;
        
        //Activity Name : Drop / Lost
        if(component.get('v.MasterAct_TransactionName') == 'ZPZ2') {
            isValid = true;
        }
        
        if(isValid)
        {
            var apexAction = 'setIF155CallByOpptyActId';
            var apexParams = {
                opptyActId : component.get('v.recordId')
            };
            self.apex(component, apexAction, apexParams)
                .then((result) => {
                    var resultObj = JSON.parse(result);
                    
                    console.log('##### setIF155Call, isValid callback Start #####');
                    
                    /*
                    component.set('v.reloadForm', false);
    
                    var actLostType = '';
                    var actLostReason = '';
    
                    if(resultObj.opportunityActivity) {					
                        component.set('v.opportunityActivity', resultObj.opportunityActivity);
                        if(resultObj.opportunityActivity.LostType__c) actLostType = resultObj.opportunityActivity.LostType__c;
                        if(resultObj.opportunityActivity.LostReason__c) actLostReason = resultObj.opportunityActivity.LostReason__c;
                    }
                    component.set('v.Activity_LostType', actLostType);
                    component.set('v.Activity_LostReason', actLostReason);
    
                    component.set('v.reloadForm', true);		
                    */
                    
                    console.log('##### setIF155Call, isValid callback End #####');
                })
                .catch((errors) => {
                    self.errorHander(errors);
                });
		}
	},
            
	getOpportunityActivity: function(component, event) {		
		var self = this;
		
		var apexAction = 'getOpportunityActivity';
		var apexParams = {
			opptyActId : component.get('v.recordId')
		};
		self.apex(component, apexAction, apexParams)
			.then((result) => {		
				var resultObj = JSON.parse(result);
				component.set('v.reloadForm', false);

				var actLostType = '';
				var actLostReason = '';

				if(resultObj.opportunityActivity) {					
					component.set('v.opportunityActivity', resultObj.opportunityActivity);
					if(resultObj.opportunityActivity.LostType__c) actLostType = resultObj.opportunityActivity.LostType__c;
					if(resultObj.opportunityActivity.LostReason__c) actLostReason = resultObj.opportunityActivity.LostReason__c;
				}
				component.set('v.Activity_LostType', actLostType);
				component.set('v.Activity_LostReason', actLostReason);

				component.set('v.reloadForm', true);		
			})
			.catch((errors) => {
				self.errorHander(errors);
			});
	},

	/**
	 * from Child Component Event 
	 */
	updateOpportunityActivity: function(component, event) {
		console.log('{ opportunityActivityNew.updateOpportunityActivity }');
		var self = this;
		var parentId = component.get('v.parentId');
		var recordId = component.get('v.recordId');
		var eventParams = event.getParams();
		var eventStatus = eventParams.status;
		self.log('# eventParams', eventParams);

		var formfields = component.find('fields');
		var opptyActivityObj = {};
		for(var idx in formfields) {		
			opptyActivityObj[formfields[idx].get('v.fieldName')] = formfields[idx].get('v.value');
		}
		opptyActivityObj['WhatId__c'] = parentId;
		//opptyActivityObj['TransactionName__c'] = component.get('v.TransactionName');	//Lost'로 종료 품의 상신 시 Drop/Lost Activity 레코드 2건 생성 이슈 조치
		if(eventStatus) opptyActivityObj['Status__c'] = eventStatus;
		if(recordId) opptyActivityObj['Id'] = recordId;

		self.log('# opptyActivityObj', opptyActivityObj);
		
		var apexAction = 'upsertOpportunityActivity';
		var apexParams = {
			jsonData : JSON.stringify(opptyActivityObj)
		};
		self.apex(component, apexAction, apexParams)
			.then((result) => {		
				self.log(' # [apex] upsertOpportunityActivity result ', result);
				var resultObj = JSON.parse(result);

				if(resultObj.opportunityActivityId) {
					component.set('v.recordId', resultObj.opportunityActivityId);
				}
				// self.showToast(null, 'SUCCESS', 'dismissible', $A.get('$Label.c.COMM_LAB_SUCCESS') , $A.get('$Label.c.COMM_MSG_0002') ); // 성공적으로 저장되었습니다.
			})
			.catch((errors) => {
				self.errorHander(errors);
			})
			.finally(() => {
				self.refresh(component, event);	
			});
		
	},

	/**
	 * Description Update
	 * @param {*} component 
	 * @param {*} event 
	 */
	updateActivityDescription : function(component, event) {
		console.log('{ opportunityActivityNew.updateActivityDescription }');
		var self = this;
		var parentId = component.get('v.parentId');
		var recordId = component.get('v.recordId');
		var formfields = component.find('fields');
		
		var opptyActivityObj = {};
		opptyActivityObj['WhatId__c'] = parentId;
		opptyActivityObj['TransactionName__c'] = component.get('v.TransactionName');
		if(recordId) opptyActivityObj['Id'] = recordId;

		for(var idx in formfields) {
			console.log(formfields[idx].get('v.fieldName'));
			if(formfields[idx].get('v.fieldName') == 'Description__c') {
				opptyActivityObj[formfields[idx].get('v.fieldName')] = formfields[idx].get('v.value');
			}
		}

		console.log('opptyActivityObj', opptyActivityObj);
		var apexAction = 'upsertActivityDescription';
		var apexParams = {
			jsonData : JSON.stringify(opptyActivityObj)
		};
		self.apex(component, apexAction, apexParams)
			.then((result) => {		
				self.log(' # [apex] upsertActivityDescription result ', result);
			})
			.catch((errors) => {
				self.errorHander(errors);
			})
			.finally(() => {
				// self.refresh(component, event);	
			});
	},
                
     /**--START V 1.6 Change by Divyam gupta--**/
     handlelostdropPopup: function(component, event){
         if(component.get('v.MasterAct_TransactionName') == 'ZPZ2' || component.get('v.MasterAct_TransactionName') =='ZPZ1'){
       var lostdropprevval = component.get('v.lostDropTypeVal');  
        var currentStagevalue = component.get('v.Activity_LostType');
         if(lostdropprevval != currentStagevalue && lostdropprevval != '' && lostdropprevval != undefined){
             component.set('v.handlelostDropTypeVal',true);
             component.set('v.handleYeslostDropTypeVal',true);
         }
         else {
              component.set('v.handlelostDropTypeVal',false);
             

         }
         }
        },
     delteLostDropRecord: function(component,event){
        var self = this;
        var oppid = component.get('v.parentId');
              var Stagevalue = component.get('v.Activity_LostType');
             self.apex(component, 'delLostDropRecord', {OppId: oppid,Lostdroptypeval : Stagevalue}).then(function(result){
            console.log('result is-->: ', result);  
              
        }).catch(function(errors){
            self.errorHandler(errors);
        });
        
                                
          },
          /**--END V 1.6 --**/


	errorHander : function(errors){
        var self = this;
        if(Array.isArray(errors)){
            errors.forEach(function(err){
				console.log('err', err);
				self.showToast(null, 'ERROR', 'dismissible', $A.get('$Label.c.COMM_LAB_ERROR') , err.message);
            });
        } else {
            console.log(errors);
			self.showToast(null, 'ERROR', 'dismissible', $A.get('$Label.c.COMM_LAB_ERROR') , 'Unknown error in javascript controller/helper.');
        }
	},
	
	apex : function(component, apexAction, params){
        return new Promise( $A.getCallback( function( resolve, reject ) {
			var action = component.get("c."+apexAction+"");
			action.setParams( params );

            action.setCallback( this, function(callbackResult) {
                if(callbackResult.getState()=='SUCCESS') {
                    resolve( callbackResult.getReturnValue() );
                }
                if(callbackResult.getState()=='ERROR') {
                    console.log('ERROR', callbackResult.getError() ); 
                    reject( callbackResult.getError() );
                }
            });
            $A.enqueueAction( action );
        }));
    },

    log : function(msg, object) {
        var objectToJSONObject = object ? JSON.parse(JSON.stringify(object)) : object;
        if(this.DEBUG) console.log(msg, objectToJSONObject);
	},
	
	close : function(component, event) {
		component.find('overlayLib').notifyClose();
	},
	
    refresh : function(component, event) {
		this.log('✨ opportunityActivityNew refresh');

		this.init(component, event);

		var refreshEvt = component.getEvent("opportunityActivityPanelRefreshEvent");
		refreshEvt.fire();
	},
	
	/**
	 * 
	 * @param {*} component 
	 * @param {*} componentName 
	 * @param {*} attributeParams 
	 * @param {*} cssClass 
	 * @param {*} closeCallback 
	 */
	showComponentModal : function(component, componentName, attributeParams, cssClass, closeCallback) {        
        $A.createComponent('c:' + componentName
            , attributeParams
            , function(content, status, errorMessage) {
				if (status === "SUCCESS") {
					component.find('overlayLib').showCustomModal({
						body: content,
						showCloseButton: true,
						cssClass: cssClass,
						closeCallback: closeCallback
					})
				} else if (status === "ERROR") {
					console.log("Error: " + errorMessage);
				}
        });
	},
	
	/**
	 * 
	 * @param {*} component 
	 * @param {*} type 		'error', 'warning', 'success', 'info'
	 * @param {*} mode 		'pester', 'sticky', 'dismissible'
	 * @param {*} title 
	 * @param {*} message 
	 * @param {*} duration 
	 */
    showToast : function(component, type, mode, title, message, duration) {
		if(type == 'error') mode = 'sticky';
		var toastEvent = $A.get('e.force:showToast');
		toastEvent.setParams({
			type : type,
			mode : mode,
			title: title,
			message : message,
			duration : 10000
		});
		toastEvent.fire();
	}
})