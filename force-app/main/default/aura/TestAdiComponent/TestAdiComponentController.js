/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2023-03-13
 * @last modified by  : anish.jain@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2020-11-05   younghoon.kim@dkbmc.com   Initial Version
 * 1.1   2023-02-22   anish.jain@partner.samsung.com   Changes Added for new Search box 'Intensive BO' regarding (My Sales - 141)
 * 1.2   2023-03-10   anish.jain@partner.samsung.com   Changes Added for Excel download regarding (My Sales - 148)
 * 1.3   2023-03-13   anish.jain@partner.samsung.com   Changes Added for Strategic Account regarding (My Sales - 149)
**/
({
	init : function(component, event, helper) {
		var loginUserId = $A.get("$SObjectType.CurrentUser.Id");
		component.set('v.loginUserId', loginUserId);

		component.set('v.selectedValue', {
			'Company' : {},				// 회사코드
			'Account' : {},				// 고객
			'OriginAccount' : {},		// 원청
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
		var firstRecordId = dataList[0].Id
		
		helper.getOppList(component, event, firstRecordId, 'Prev');
	},

    onNext : function(component, event, helper) {
		component.set("v.loading", true);

		var nowPage = component.get('v.nowPage');
		component.set('v.nowPage', nowPage + 1)
		
		var dataList = component.get('v.OpptyList');
		var lastRecordId = dataList[dataList.length - 1].Id

		helper.getOppList(component, event, lastRecordId, 'Next');
	},
    
    onCheckboxChange : function(component, event, helper) {
        console.log("inside Checkbox");
        var checkboxes = component.find("checkOpp");
        var value = false;
        if(!Array.isArray(checkboxes)){
            checkboxes.set("v.value", value);
        }else{
            checkboxes.forEach(function(cb){
                cb.set("v.value", value);
            });
        }
        event.getSource().set("v.value",true);
        var oppId = event.getSource().get("v.text");
        console.log("Opp Id Adi : "+ oppId);
        
        component.set("v.recdId", oppId);
        console.log("Opp Record Id : ", component.get("v.recdId"));
    }

})