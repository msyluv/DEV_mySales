({
	init : function(component, event, helper) {
		var loginUserId = $A.get("$SObjectType.CurrentUser.Id");
		component.set('v.loginUserId', loginUserId);

		component.set('v.selectedValue', {
			'Company' : {},				// 회사코드
			'Account' : {},				// 고객
			'OriginAccount' : {},		// 원청
			'SalesOrganization' : {},				// Sales Org
			'DeliveryOrganization' : {},		// Delivery Organization
			'lbsExceptionType' : '',		// LBS Exception Type
            'globalBidding' : '',               //Global Bidding
			'bizDevelopment' : '',			// Biz Development
			'customerType' : '',			// customerType
			'opportunityType' : '',			// opportunityType
			'BOName' : '',				// BO명
			'Collaboration' : '',		// 협업여부
			'GroupInternal' : '',		// 대내/대외
            'CSP' : '',               //Added by Anish- v 1.2
            'MSP' : '',               //Added by Anish- v 1.2
            'SCP' : '',               //Added by Anish- v 1.2
            'ERP' : '',               //Added by Anish- v 1.2
            'MES' : '',               //Added by Anish- v 1.2
            'TechAttribute' : '',     //Added by Anish- v 1.2
			'Service' : '',				// 서비스
			'Solution' : '',			// 솔루션
			'Status' : '',				// Status
            'StrategicAccount' : '',    // Added by Anish - v 1.3
			'StartDate' : null,			// 수주예정일(Start)
			'EndDate' : null,			// 수주예정일(End)
			'Owner' : {},				// 영업대표
			'OpptyCode' : '',			// 사업기회 코드
			'SalesDept' : {},			// 주수주부서
			'PrimarySalesDept' : {},	// 주매출부서
			'RecordType' : '',			// 사업기회 유형
			'ContractStartDate' : null, //Contract Start DAte
			'ContractEndDate' : null,    //Contact End DATE
			'FirstStartDate' : null,	// 최초수주일자(Start)
			'FirstEndDate' : null		// 최초수주일자(End)
		});

		component.set('v.nowPage', 1);

		helper.doInit(component, event);
	},
	
	search : function(component, event, helper) {
		component.set("v.loading", true);

		component.set('v.nowPage', 1);
		helper.getOppList(component, event, '', '');
    },
    
	onPrev : function(component, event, helper) {
		component.set("v.loading", true);

		var nowPage = component.get('v.nowPage');
		component.set('v.nowPage', nowPage - 1);

		var dataList = component.get('v.OpptyList');
		var firstRecordId = dataList[0].CloseDateSort;   //TODO Change  by from  BO1stRegistrationDate__c  to close date
		
		helper.getOppList(component, event, firstRecordId, 'Prev');
	},

    onNext : function(component, event, helper) {
		component.set("v.loading", true);

		var nowPage = component.get('v.nowPage');
		component.set('v.nowPage', nowPage + 1)
		
		var dataList = component.get('v.OpptyList');
		var lastRecordId = dataList[dataList.length - 1].CloseDateSort;  //TODO Change  by from  BO1stRegistrationDate__c  to close date

		helper.getOppList(component, event, lastRecordId, 'Next');
	},
	
	
	scriptLoaded : function(component, event, helper) {
        helper.scriptLoaded(component, event);
    },
    
    
    CBCheck : function (component, event, helper) {
        
        
        component.set("v.globalBiddingCheck",document.getElementById("checkbox-unique-id-82").checked);
        //Start- Added by Anish - v 1.2
       
        if(document.getElementById("checkbox-unique-id-82").checked == true){
        component.set("v.selectedValue.globalBidding","true");
        }
        else{
        component.set("v.selectedValue.globalBidding","false");    
        }
        
        
	},
    
})