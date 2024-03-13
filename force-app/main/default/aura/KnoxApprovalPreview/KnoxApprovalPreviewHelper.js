/**
 * @description       : 
 * @author            : seonju.jin@dkbmc.com
 * @group             : 
 * @last modified on  : 2023-06-06
 * @last modified by  : anish.jain@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                 Modification
 * 1.0   2021-06-02   seonju.jin@dkbmc.com   Initial Version
 * 1.1   2023-06-06   anish.jain@partner.samsung.com Add department validation logic for contract approval activity -> My Sales- 215
**/
({
	doInit : function(component, event, type, isInit) {
		var self = this;
		component.set('v.showSpinner', true);
		console.log('KnoxApprovalPreview doInit!');
			this.confirmMSG(component, event);
		
		
		
		//self.getApprovalBody(component, event);
		
		
		
		
	},
	confirmMSG : function(component, event){
		var self = this;
		component.set('v.showSpinner', true);
		var message = '';
		var apexAction = 'getConfirmMSG',
			apexParams = {
				'opptyId' 	 : component.get('v.opptyId'),
				'opptyActId' : component.get("v.opptyactId"),
			};
		self.apex(component, apexAction, apexParams)
		.then((result) => {
            console.log('ANI_RESULT', result);
			if(result.BID_CONFIRM_MSG != ''){
				//self.showToast(component, 'WARNING', 'sticky', null,result.BID_CONFIRM_MSG, 10000);
				component.set("v.confirmMSG",result.BID_CONFIRM_MSG);
				component.set('v.confirm', true);
                if(result.RESULT_ANI == 'F'){
                    self.showToast(null, 'ERROR', 'sticky', 'ERROR' , result.MESSAGE_ANI);  //Added by Anish - v 1.1
                  }
			}else{
				
				this.getApprovalBody(component, event);
               if(result.RESULT_ANI == 'F'){
                    self.showToast(null, 'ERROR', 'sticky', 'ERROR' , result.MESSAGE_ANI);  //Added by Anish - v 1.1
                 }
			}
		})
		.catch((errors) => {
			self.errorHander(errors);
		})
		.finally(() => {
			console.log('-------- [E] confirmMSG.finally' );
		});
		component.set('v.showSpinner', false);
	},

	/**
	 * 결재 본문 가져오기
	 * @param {*} component 
	 * @param {*} event 
	 */
	 getApprovalBody : function(component, event) {
		
		var self = this;
		console.log('recordId',component.get('v.recordId') );
		component.set('v.confirm', false);
		component.set('v.showSpinner', true);
	    
		//RecordTypeId = '0122w000000JQo9AAG'
		//CompanyCode__c = 'T100'
		//select Id, Opportunity__c  from KnoxApproval__c where Opportunity__c ='0060p00000AtQH4AAN'
		/*
		//select Id, BiddingMethod__c, RecordTypeId, CompanyCode__c from opportunity where Id='0060p00000AtXM2AAN'
		BiddingMethod__c = 'BID001'
		RecordTypeId = '0122w000000JQo9AAG'
		CompanyCode__c = 'T100'
		select 
		select Id, Opportunity__c  from KnoxApproval__c where Opportunity__c ='0060p00000AtQH4AAN'
		*/

		
		if(!$A.util.isEmpty(component.get('v.approvalMISID'))){
			console.log('[getApprovalBody]상신화면에서 MISID 생성:' + component.get('v.approvalMISID'));
		} 
		var message = '';
		var apexAction = 'getApprovalBodyHtml',
			apexParams = {
				'recordId' 	 : component.get('v.recordId'),
				'opptyId' 	 : component.get('v.opptyId'),
				'opptyActId' : component.get("v.opptyactId"),
				'useApprovalLineBody' : true,
				'MISID'		 : component.get('v.approvalMISID')
			};

		var htmlReplaceEvt = $A.get("e.c:knoxApprovalPreviewReplaceEvent");

		self.apex(component, apexAction, apexParams)
			.then((result) => {
				console.log('init.result', result);
				component.set("v.data", result);
				
				if(result.RESULT) {
					component.set("v.htmlData",result.HTML);
                    console.log('Ani result', result.HTML);
					component.set("v.approvalMISID", result.MISID);
					console.log('[getApprovalBody] after:' + component.get('v.approvalMISID'));
				} else {
					var isApprovalValidation = false,
						toastType,toastMode,toastTitle;
					
					isApprovalValidation = (result.RESULT_TYPE && result.RESULT_TYPE == 'BEFORE');
					toastType  = isApprovalValidation ? 'WARNING' 		: 'ERROR';
					toastMode  = 'sticky';
					toastTitle = isApprovalValidation ? $A.get('$Label.c.VAPP_LAB_VALID_CHECK') : $A.get('$Label.c.COMM_LAB_ERROR');
					
					component.set("v.approvalMISID", '');		//실패 시 misid 초기화

					self.showToast(component, toastType, toastMode, toastTitle, result.MESSAGE, 10000);
				}
				
				component.set('v.showSpinner', false);

				console.log('-------- [S] getApprovalBodyHtml.then' );
			})
			.catch((errors) => {
				self.errorHander(errors);
			})
			.finally(() => {
				console.log('-------- [E] getApprovalBodyHtml.finally' );
				// 필드 정보 변환
				htmlReplaceEvt.fire();

				// html 본문 전달
				self.firePreviewPassEvent(component, event);

			});
	},
	

	/**
	 * 결재 상신
	 * @param {*} component 
	 * @param {*} event 
	 */
	clickApprove : function(component, event) {
		var self = this;
		
		var isSelectedApprovalTab = component.get('v.isSelectedApprovalTab');
		console.log('==== isSelectedApprovalTab ', isSelectedApprovalTab);
		if(isSelectedApprovalTab == false) {
			console.log('==== isSelectedApprovalTab  false ');
			self.showToast(component, 'ERROR', 'sticky', $A.get('$Label.c.COMM_LAB_ERROR'), $A.get('$Label.c.APPR_MSG_0031'), 10000);

		} else {
			var knoxApprovalSubmit = $A.get("e.c:knoxApprovalSubmitEvent");
			console.log('knoxApprovalSubmit', JSON.parse(JSON.stringify(knoxApprovalSubmit)));
			knoxApprovalSubmit.fire();
		}
	},

	/**
	 * Knox Approval Field Value 교체
	 * @param {*} component 
	 * @param {*} event 
	 */
	setKnoxApprovalField : function(component, event){        
		console.warn('{ setKnoxApprovalField }');
		var requestBusinessLevel = event.getParam("requestBusinessLevel") == null ? '' : event.getParam("requestBusinessLevel");
		var htmlData = component.get("v.htmlData");
		if(htmlData) {
			var replaceHtmlData = '';
			// Event에서 받아온 request field 교체
			var replaceTarget = /<TH id="RequestBusinessLevel" class="noline">Opportunity Class<\/TH><TD>.*<\/TD>/img;
			replaceHtmlData = htmlData.replace(replaceTarget, '<TH id="RequestBusinessLevel" class="noline">Opportunity Class</TH><TD>' + requestBusinessLevel + '</TD>');

			component.set('v.htmlData', replaceHtmlData);

			// html 본문 전달
			this.firePreviewPassEvent(component, event);
		}
	},

	/**
	 * html 본문 전달 이벤트 호출
	 * @param {*} component 
	 * @param {*} event 
	 */
	firePreviewPassEvent : function(component, event) {
		console.warn('{ firePreviewPassEvent } ');
		var htmlPassEvt = $A.get("e.c:knoxApprovalPreviewPassEvent");
		htmlPassEvt.setParams({
			'approvalHTML' : component.get("v.htmlData")
		});
		htmlPassEvt.fire();
	},

	errorHander : function(errors){
        var self = this;
        if(Array.isArray(errors)){
            errors.forEach(function(err){
				console.log('err', err);
				self.showToast(null, 'ERROR', 'dismissible', $A.get('$Label.c.COMM_LAB_ERROR') , err.message);
            });
        } else {
            console.log(errors);
			self.showToast(null, 'ERROR', 'dismissible', $A.get('$Label.c.COMM_LAB_ERROR') , errors);
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
        switch (type.toLowerCase()) {
            case 'error':
                mode = 'sticky';
                break;
            case 'warning':
                mode = 'sticky';
                break;
            case 'success':
                mode = 'dismissible';
                duration = 5000;
                break;
		}
		
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            type : type,
            mode : mode,
            title: title,
            message : message,
            duration : duration
        });
        toastEvent.fire();
    }
	
})