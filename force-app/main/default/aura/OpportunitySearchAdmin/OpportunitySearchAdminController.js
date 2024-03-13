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
	
	serviceChange : function(component, event, helper) {
        //Start-Added by Anish - v 1.2
        if(component.get('v.techAttribute') == true){
        component.set("v.selectedValue.TechAttribute","true"); 
        }
        else{
        component.set("v.selectedValue.TechAttribute","false");   
        }
        //End-Added by Anish - v 1.2
		helper.solutionInfoGet(component, event, component.get('v.selectedValue.Service'));
	},

	scriptLoaded : function(component, event, helper) {
        helper.scriptLoaded(component, event);
    },
    
    //Start - Added by Anish - v 1.1
    CBCheck : function (component, event, helper) {
        
        component.set("v.CSPCheck",document.getElementById("checkbox-unique-id-81").checked);
        component.set("v.MSPCheck",document.getElementById("checkbox-unique-id-82").checked);
        component.set("v.SCPCheck",document.getElementById("checkbox-unique-id-83").checked);
        component.set("v.ERPCheck",document.getElementById("checkbox-unique-id-84").checked);
        component.set("v.MESCheck",document.getElementById("checkbox-unique-id-85").checked);
        
        //Start- Added by Anish - v 1.2
        if(document.getElementById("checkbox-unique-id-81").checked == true){
        component.set("v.selectedValue.CSP","true");
        }
        else{
        component.set("v.selectedValue.CSP","false");    
        }
        if(document.getElementById("checkbox-unique-id-82").checked == true){
        component.set("v.selectedValue.MSP","true");
        }
        else{
        component.set("v.selectedValue.MSP","false");    
        }
        if(document.getElementById("checkbox-unique-id-83").checked == true){
        component.set("v.selectedValue.SCP","true");
        }
        else{
        component.set("v.selectedValue.SCP","false");    
        }
        if(document.getElementById("checkbox-unique-id-84").checked == true){
        component.set("v.selectedValue.ERP","true");
        }
        else{
        component.set("v.selectedValue.ERP","false");    
        }
        if(document.getElementById("checkbox-unique-id-85").checked == true){
        component.set("v.selectedValue.MES","true");
        }
        else{
        component.set("v.selectedValue.MES","false");    
        }
        //End- Added by Anish - v 1.2
        
	},
    //End - Added by Anish - v 1.1
})