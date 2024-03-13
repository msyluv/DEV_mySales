/**
 * @description       : 
 * @author            : seonju.jin@dkbmc.com
 * @group             : 
 * @last modified on  : 2023-10-17
 * @last modified by  : atul.k1@samusng.com
 * Modifications Log 
 * Ver   Date         Author                 Modification
 * 1.0   2021-06-01   seonju.jin@dkbmc.com   Initial Version
 * 1.1   2023-06-06   anish.jain@partner.samsung.com  Add department validation logic for contract approval activity -> My Sales - 215 
 * 1.2   2023-10-17   atul.k1@samusng.com       Mysales-318
**/
({
    init : function(component, event) {
		var self = this;		
		// console.log('{ approvalLine.init }');

		this.onPageReferenceChange(component, event);

		var opptyId = component.get('v.opptyId');
        var opptyActId = component.get('v.opptyActId');
		var approvalMISID = component.get('v.approvalMISID');

		if(opptyId && opptyActId)  {
            console.log('Method Call11');
            
			this.getApprovalLine(component, event);
            console.log('Method Call22');
		}
		
		// this.doApprovalLineProcess(component, event);
	},

	onPageReferenceChange : function(component, event) {
		// Get URL Parameter
		var pageRef = component.get("v.pageReference");
		// console.log('pageRef', pageRef);
        var pageRef_opptyId;
        var pageRef_opptyActId;
        if(pageRef) {
            pageRef_opptyId = pageRef.state.c__opptyId;
			pageRef_opptyActId = pageRef.state.c__opptyActId;
			
			// console.log('pageRef_opptyId', pageRef_opptyId);
			// console.log('pageRef_opptyActId', pageRef_opptyActId);
        }

        if(pageRef_opptyId) component.set('v.opptyId', pageRef_opptyId);
        if(pageRef_opptyActId) component.set('v.opptyActId', pageRef_opptyActId);
	},

	

	getApprovalLine : function(component, event) {
		var self = this;
		// console.log('[getApprovalLine] v.approvalMISID:' + component.get('v.approvalMISID'));
        console.log('Method Call 11');
		var apexAction = 'initComponent';
        console.log('Method Call 22');
		var apexParams = {
            'opptyId' : component.get('v.opptyId'),
			'opptyActId' : component.get('v.opptyActId'),
			'bizReviewId' : component.get('v.bizReviewId'),
			'useApprovalLine' : true,
			'useApprovalLineBody' : true,
			'useResource' : 'pathlist',
			'misid' : component.get('v.approvalMISID')
		};

		// console.log('apexParams', apexParams);
		component.set('v.isLoading', true);

		self.apex(component, apexAction, apexParams)
		.then((result) => {		
			var resultObj = JSON.parse(result);
			console.log('resultObj 123@#',resultObj);
			//console.log('수주품의 단계에서의 인프라 구축(팝업창 생성) 요청의 건', resultObj.PREVIEW);
            if(resultObj.PREVIEW){//수주품의 단계에서의 인프라 구축(팝업창 생성) 요청의 건
            	component.set('v.preview', resultObj.PREVIEW);
       		}
			var approvalLineList = [];
			var approvalHTML = '';
            var Minus_Profit = '';  //<!--V 1.2 Mysales-318-->
			
			var resultStatus = resultObj.RESULT;
            console.log('Ani Result ', resultObj);
			
			if(resultStatus) {
				if(resultObj.RESULT_TYPE == 'GETAPPROVAL') { // 결재선 조회 성공
					self.showToast(null, 'SUCCESS', 'dismissible', $A.get('$Label.c.COMM_LAB_SUCCESS') , $A.get('$Label.c.LAPP_MSG_006') + resultObj.MESSAGE); 
                    if(resultObj.RESULT_ANI == 'F'){
                    self.showToast(null, toastType, toastMode, 'ERROR' , resultObj.MESSAGE_ANI);  //Added by Anish - v 1.1
                    }
				}
			} else {
				if(resultObj.RESULT_TYPE == 'PERMISSION'){	//현재 로그인유저가 협업 Oppty에 팀멤버 추가되어있지않으면 error
					self.showToast(null, 'ERROR', 'sticky', $A.get('$Label.c.COMM_LAB_ERROR') , resultObj.MESSAGE);
				}else{
					var isApprovalValidation = (resultObj.RESULT_TYPE == 'BEFORE');
					var toastType  = isApprovalValidation ? 'WARNING' 		: 'ERROR';
					var toastMode  = 'sticky';
					var toastTitle = isApprovalValidation ? $A.get('$Label.c.VAPP_LAB_VALID_CHECK') : $A.get('$Label.c.COMM_LAB_ERROR');
                    console.log('comment testing');
					self.showToast(null, toastType, toastMode, toastTitle , resultObj.MESSAGE);
                    if(resultObj.RESULT_ANI == 'F'){
                    self.showToast(null, toastType, toastMode, 'ERROR' , resultObj.MESSAGE_ANI);  //Added by Anish - v 1.1
                    }
				}
				
			}

      
        
			component.set('v.useApprovalLine', resultObj.USE_APPROVAL_LINE);
			//console.log('useApprovalLine', resultObj.USE_APPROVAL_LINE);

			//misid
			var misid = component.get('v.approvalMISID');
			// console.log('[approvalLine] misid before:' + misid);
			// console.log('resultObj.APPROVAL_MISID:' + resultObj.APPROVAL_MISID);
			if($A.util.isEmpty(misid)){
				misid = resultObj.APPROVAL_MISID;
				// console.log('[approvalLine] misid after:' + resultObj.APPROVAL_MISID);
			}

			component.set('v.approvalMISID', misid);
			
			// console.log('resultObj.APPROVAL_TYPE_CODE', resultObj.APPROVAL_TYPE_CODE);

			if(resultObj.APPROVAL_LINE) {
				approvalLineList = resultObj.APPROVAL_LINE;
				component.set('v.approvalLineList', resultObj.APPROVAL_LINE);
				//console.log(JSON.stringify(approvalLineList));
			}

			if(resultObj.APPROVAL_HTML) {
				approvalHTML = resultObj.APPROVAL_HTML;
				component.set('v.approvalHTML', resultObj.APPROVAL_HTML);
			}
        //console.log('Resulttttt11'+resultObj.Minus_Profit_YN)
        //<!--V 1.2 Mysales-318 Start-->
        if(resultObj.Minus_Profit_YN){
            Minus_Profit = resultObj.Minus_Profit_YN;
            console.log('Resulttttt22');
            component.set('v.Minus_Profit',resultObj.Minus_Profit_YN);
            
        } 
        //<!--V 1.2 Mysales-318 End-->


			// Send Data to Event
			// var approvalLineEvent = $A.get("e.c:approvalLinePassEvent");
			// approvalLineEvent.setParams({
			// 	"isSuccess" 		: resultObj.RESULT,
			// 	"approvalLineList" 	: resultObj.APPROVAL_LINE,
			// 	"approvalHTML" 		: resultObj.APPROVAL_HTML,
			// 	"isApprovalHTML" 	: resultObj.HAS_APPROVAL_HTML,
			// 	"useApprovalLine"	: resultObj.USE_APPROVAL_LINE,
			// 	"approvalTypeCode"	: resultObj.APPROVAL_TYPE_CODE,
				
			// 	"isRequiredCollaboValid" : isRequiredCollaboValid,
			// 	"isSuccessCollaboValid"  : isSuccessCollaboValid,
			// 	"collaboApprovalTypeCode": collaboApprovalTypeCode
			// });
			// approvalLineEvent.fire();
			var isRequiredCollaboValid = resultObj['COLLABO_REQVALID'] ? resultObj['COLLABO_REQVALID'] : false ;
			var isSuccessCollaboValid =  resultObj['COLLABO_RESULT']   ? resultObj['COLLABO_RESULT'] : false ;
			var collaboApprovalTypeCode = '';
			if(isSuccessCollaboValid) {
				collaboApprovalTypeCode = resultObj['COLLABO_MESSAGE']
			}
			console.log('result:'  +resultObj.RESULT);

			// Send Data to Event
			var approvalLineEvent = $A.get("e.c:approvalLinePassEvent");
			approvalLineEvent.setParams({
				"isSuccess" 			 : resultObj.RESULT,
				"approvalLineList" 		 : resultObj.APPROVAL_LINE,
				"approvalHTML" 			 : resultObj.APPROVAL_HTML,
				"isApprovalHTML" 		 : resultObj.HAS_APPROVAL_HTML,
				"useApprovalLine"		 : resultObj.USE_APPROVAL_LINE,
				"approvalTypeCode"		 : resultObj.APPROVAL_TYPE_CODE,
				"isRequiredCollaboValid" : isRequiredCollaboValid,
				"isSuccessCollaboValid"  : isSuccessCollaboValid,
				"collaboApprovalTypeCode": collaboApprovalTypeCode,
                "Minus_Profit"           : resultObj.Minus_Profit_YN   //<!--V 1.2 Mysales-318-->

			});
        if(resultObj.Message_ANI == 'Success True'){ //Added by Anish-Vikrant
			approvalLineEvent.fire();
        }
			
			// ======================================= temp emp list 
			/*
			var appLine = {		
				'Index__c' : 0,		
				'Name' : '김영훈',
				'EvEName__c' :  '',
				'EvSdeptNM__c' : '',
				'EvSdeptENM__c' : '',
				'EvMailAddr__c' : 'yeoguri.kim@stage.partner.samsung.com',
				'Employee__c' : 'a0M1s000000W4dhEAC',
				'EvUniqID__c' : 'M200810085139C603253',
				'ApproverType__c' :  '1',   // 기안(0), 결재(1), 합의(2), 후결(3), 병렬합의(4), 병렬결재(7), 통보(9)
				'IsChangeLine__c' : false,
				'IsEditText__c' : false,
				'IsArbitraryDecision__c' : false,
				'IsGetApprovalLine__c' : true
			}
			approvalLineList.push(appLine);

			appLine = {
				'Index__c' : 1,
				'Name' : '김동영',
				'EvEName__c' :  '',
				'EvSdeptNM__c' : '',
				'EvSdeptENM__c' : '',
				'EvMailAddr__c' : 'dong00.kim@stage.partner.samsung.com',
				'Employee__c' : 'a0M1s000000W9IaEAK',
				'EvUniqID__c' : 'M200810085139C603255',
				'ApproverType__c' :  '1',   // 기안(0), 결재(1), 합의(2), 후결(3), 병렬합의(4), 병렬결재(7), 통보(9)
				'IsChangeLine__c' : false,
				'IsEditText__c' : false,
				'IsArbitraryDecision__c' : false,
				'IsGetApprovalLine__c' : true
			}
			approvalLineList.push(appLine);
			*/
			// ======================================= temp emp list 

		})
		.catch((errors) => {
         console.log('isLoading errors' + errors);
			self.errorHandler(errors);
		})
		.finally(()=>{
			component.set('v.isLoading', false);
			console.log('isLoading ' + component.get('v.isLoading'));
		});
	},

	/**
	 * 1. [doKnoxValidationCheck] 결재사전점검 체크 후 SUCCESS 인 경우
	 * 2. [getApprovalLine] 결재선 호출 
	 */
	doApprovalLineProcess :  function(component, event) {
        alert('1Approval')
		var self = this;

		var apexAction = 'doKnoxValidationCheck';
		var apexParams = {
            'opptyId' : component.get('v.opptyId'),
			'opptyActId' : component.get('v.opptyActId'),
			'useApprovalLineBody' : true
		};		
		component.set('v.isLoading', true);

		self.apex(component, apexAction, apexParams)
			.then((result) => {		
				// console.log('✔ [doKnoxValidationCheck] result', result);
				if(result.RESULT == 'S') { 

					return self.apex(component, 'getApprovalLine', { opptyId : component.get('v.opptyId'),
																	 opptyActId : component.get('v.opptyActId'),
																	 approvalTypeCode : result.MESSAGE
																	}); 
				} else { 
					self.showToast(null, 'WARNING', 'sticky', $A.get('$Label.c.VAPP_LAB_VALID_CHECK') , result.MESSAGE); 
					return;
				}

			})
			.then((result) => {
				if(result) {
					// console.log('✔ [getApprovalLine] result', result);
					var resultMessage = result.MESSAGE ? result.MESSAGE : '';

					var toastType  	 = result.RESULT ? 'SUCCESS' 							: 'ERROR';
					var toastMode  	 = result.RESULT ? 'dismissible' 						: 'sticky';
					var toastTitle 	 = result.RESULT ? $A.get('$Label.c.COMM_LAB_SUCCESS')  : $A.get('$Label.c.COMM_LAB_ERROR');
					var toastMessage = result.RESULT ? $A.get('$Label.c.LAPP_MSG_006') + resultMessage :  resultMessage;
				
					if(result.APPROVAL_LINE) {
						approvalLineList = result.APPROVAL_LINE;
						component.set('v.approvalLineList', result.APPROVAL_LINE);
					}
		
					if(result.APPROVAL_HTML) {
						approvalHTML = result.APPROVAL_HTML;
						component.set('v.approvalHTML', result.APPROVAL_HTML);
					}
		
					// Send Data to Event
					var approvalLineEvent = $A.get("e.c:approvalLinePassEvent");
					approvalLineEvent.setParams({
						"isSuccess" 		: result.RESULT,
						"approvalLineList" 	: result.APPROVAL_LINE,
						"approvalHTML" 		: result.APPROVAL_HTML,
						"isApprovalHTML" 	: result.HAS_APPROVAL_HTML
					});
					approvalLineEvent.fire();

					self.showToast(null, toastType, toastMode, toastTitle , toastMessage);
				}
			})
			.catch((errors) => {
				self.errorHandler(errors);
			})
			.finally(()=>{
				component.set('v.isLoading', false);
			});
	},

	errorHandler : function(errors){
        var self = this;
        if(Array.isArray(errors)){
            errors.forEach(function(err){
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
            console.log('Approval Line Point==>');
            console.time();
            action.setCallback( this, function(callbackResult) {
				console.log('callbackResult.getState()', callbackResult.getState());
            console.timeEnd();
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

    showToast : function(component, type, mode, title, message, duration) {
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