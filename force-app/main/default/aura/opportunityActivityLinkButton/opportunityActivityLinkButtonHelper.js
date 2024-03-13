/**
 * @description       : 
 * @author            : ukhyeon.lee@samsung.com
 * @group             : 
 * @last modified on  : 10-31-2022
 * @last modified by  : ukhyeon.lee@samsung.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   07-05-2021   ukhyeon.lee@samsung.com   Initial Version
 * 1.1   28-10-2022   gitesh.s@samsung.com      Legal Review Link Change
**/
({
	/**V1.1 - START - GITESH **/
	getRecordNameHQ : function(component) {
        var action = component.get('c.getRecordTypeHQ');
        action.setCallback(this, function(response){
            var state = response.getState();   
            if(state == "SUCCESS"){
				component.set("v.recordTypeHQ", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },

	getRecordNameLogistics : function(component) {
        var action = component.get('c.getRecordTypeLogistics');          
        action.setCallback(this, function(response){
            var state = response.getState();   
            if(state == "SUCCESS"){
                component.set("v.recordTypeLogistics", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },

	checkOrg : function(component) {
		var action = component.get('c.checkOrg');
		action.setCallback(this, function(response){
            var state = response.getState();   
            if(state == "SUCCESS"){
                component.set("v.checkOrg", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	},
	/**V1.1 - END - GITESH **/

    handleOpenLink  : function(component, event) {
		var urlValue = event.getSource().get('v.value');
        var buttonId = event.getSource().getLocalId();
		var oppty = component.get('v.opportunity');

		/**V1.1 - START - GITESH **/
		var recordTypeHQ = component.get('v.recordTypeHQ');
		var recordTypeLogistics = component.get('v.recordTypeLogistics');
		var isSandbox = component.get('v.checkOrg');
		/**V1.1 - END - GITESH **/

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
				urlValue += 'P_PSPID=;'
				urlValue += 'P_BUKRS=' + this.nullToString(oppty.CompanyCode__c)+ ';'
				urlValue += 'P_STEP=C'
				break;

            case 'REG_RESOURCE_DEMAND': // 인력투입계획수립
				var opptySuffix = oppty.OpportunityCode__c.split('-')[1];
				urlValue = urlValue.replace('{0}', opptySuffix.substring(0,opptySuffix.length-1));
				break;
                
			case 'COMMITTEE_COST_PLAN' : // 수전위 원가
				// urlValue = 'http://ieqh1201.sds.samsung.net:50000/irj/servlet/prt/portal/prtroot/controller.IViewController?type=GUI&param=System=SDS_ECC,TCode=ZLP3SDC2100C,AutoStart=TRUE,ApplicationParameter=';
				urlValue += 'P_BO=' + this.nullToString(oppty.OpportunityCode__c) + ';'
				urlValue += 'P_PSPID=;'
				urlValue += 'P_BUKRS=' + this.nullToString(oppty.CompanyCode__c) + ';'
				urlValue += 'P_STEP=F'
				break;
			
            //신규추가시작
			case 'REQUEST_STRATEGY_COMMITTEE_01' : // XP61
				urlValue = urlValue.replace('{0}', this.nullToString(oppty.OpportunityCode__c));
				break;

			case 'REQUEST_STRATEGY_COMMITTEE_LIST_01' : // XP61 List
				urlValue = urlValue.replace('{0}', this.nullToString(oppty.OpportunityCode__c));
				urlValue = urlValue.replace('{1}', this.nullToString(oppty.CompanyCode__c));
				break;

			case 'REQUEST_STRATEGY_COMMITTEE_CHECKLIST_01' : // XP61 CheckList
				urlValue = urlValue.replace('{0}', this.nullToString(oppty.OpportunityCode__c));
				urlValue = urlValue.replace('{1}', this.nullToString(oppty.CompanyCode__c));
				break;	
                
			case 'COMMITTEE_COST_PLAN_01' : // XP62
				urlValue = urlValue.replace('{0}', this.nullToString(oppty.OpportunityCode__c));
				urlValue = urlValue.replace('{1}', this.nullToString(oppty.CompanyCode__c));
				break;
			
			case 'REQUEST_COMMITTEE_APPROVAL_01' : // XP63
				urlValue = urlValue.replace('{0}', this.nullToString(oppty.OpportunityCode__c));
				break;
			
			case 'REQUEST_COMMITTEE_APPROVAL_LIST_01' : // XP63 List
				urlValue = urlValue.replace('{0}', this.nullToString(oppty.OpportunityCode__c));
				break;	
			
			case 'REQUEST_STRATEGY_COMMITTEE_02' : // XP71
				urlValue = urlValue.replace('{0}', this.nullToString(oppty.OpportunityCode__c));
				break;
            
            case 'REQUEST_STRATEGY_COMMITTEE_LIST_02' : // XP71 List
				urlValue = urlValue.replace('{0}', this.nullToString(oppty.OpportunityCode__c));
				urlValue = urlValue.replace('{1}', this.nullToString(oppty.CompanyCode__c));
				break;
			
			case 'REQUEST_STRATEGY_COMMITTEE_CHECKLIST_02' : // XP71 Check List
				urlValue = urlValue.replace('{0}', this.nullToString(oppty.OpportunityCode__c));
				urlValue = urlValue.replace('{1}', this.nullToString(oppty.CompanyCode__c));
				break;

			case 'COMMITTEE_COST_PLAN_02' : // XP72
				urlValue = urlValue.replace('{0}', this.nullToString(oppty.OpportunityCode__c));
				urlValue = urlValue.replace('{1}', this.nullToString(oppty.CompanyCode__c));
				break;
			
			case 'REQUEST_COMMITTEE_APPROVAL_02' : // XP73
				urlValue = urlValue.replace('{0}', this.nullToString(oppty.OpportunityCode__c));
				break;
				
			case 'REQUEST_COMMITTEE_APPROVAL_LIST_02' : // XP73
				urlValue = urlValue.replace('{0}', this.nullToString(oppty.OpportunityCode__c));
				break;
			//신규추가종료
			
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

			/**V1.1 START-> By Gitesh**/
			case 'REQ_LEGAL_REVIEW':
				if(isSandbox) {
					if(oppty.RecordTypeId == recordTypeHQ) {
						//HQ
						urlValue = urlValue.split(',')[0];
						break;
					}
					else if(oppty.RecordTypeId == recordTypeLogistics) {
						//Logistics
						urlValue = urlValue.split(',')[2] + '/?MC=S01TX0NOVFJUX1JWV19MSVNU';
						break;
					}
					break;
				}
				else if(!isSandbox) {
					if(oppty.RecordTypeId == recordTypeHQ) {
						//HQ
						urlValue = urlValue.split(',')[1];
						break;
					}
					else if(oppty.RecordTypeId == recordTypeLogistics) {
						//Logistics
						urlValue = urlValue.split(',')[3] + '/?MC=S01TX0NOVFJUX1JWV19MSVNU';
						break;
					}
					break;
				}
				break;
			/**V1.1 END> **/

			case 'REG_CONTRACT' : // 계약서 입고
				urlValue += 'contractNo=' + this.nullToString(oppty.LegalReviewNo__c);
				break;

			case 'REG_PROPOSAL' : // 제안서 등록
				urlValue += 'orderId=' + this.nullToString(oppty.OpportunityCode__c);
				break;
                
            case 'REQUEST_STRATEGY_COMMITTEE' : // 수주전략위원회
				urlValue = urlValue.replace('{0}', this.nullToString(oppty.OpportunityCode__c));
				urlValue = urlValue.replace('{1}', this.nullToString(oppty.CompanyCode__c));
				break;
        }

		console.log(' # URL : ', urlValue);
        window.open(urlValue, '_blank');
	},

	nullToString : function(string) {
		return string ? string : '';
	}
})