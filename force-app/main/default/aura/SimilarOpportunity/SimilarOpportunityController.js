({
	init : function(component, event, helper) {
		
        var loginUserId = $A.get("$SObjectType.CurrentUser.Id");
		component.set('v.loginUserId', loginUserId);
        
        var recordId = component.get('v.recordId');
        component.set('v.recordId', recordId);
        console.log("Inside Controller Opp Id: "+recordId);
        
        component.set('v.nowPage', 1);

		helper.getOppList(component, event, '', '');
	},
    
    onPrev : function(component, event, helper) {
		component.set("v.loading", true);

		var nowPage = component.get('v.nowPage');
		component.set('v.nowPage', nowPage - 1);

		var dataList = component.get('v.OpptyList');
		var firstRecordId = dataList[0].BO1stRegistrationDate;
		
		helper.getOppList(component, event, firstRecordId, 'Prev');
	},

    onNext : function(component, event, helper) {
		component.set("v.loading", true);

		var nowPage = component.get('v.nowPage');
		component.set('v.nowPage', nowPage + 1)
		
		var dataList = component.get('v.OpptyList');
		var lastRecordId = dataList[dataList.length - 1].BO1stRegistrationDate;

		helper.getOppList(component, event, lastRecordId, 'Next');
	},
    
    urlopen : function(component, event, helper) {
        
        //console.log('value'+event.target.value);
        //var textVal =  document.getElementById("someId").value;
        var textVal= component.find("someId").get("v.value");
        console.log('value2'+textVal);
        var URL = 'http://70.225.5.3:2007/ArisamWeb/proposal/viewPage.do?catcode=A042&orderId='+textVal;
        window.open(URL,'_blank');
    }
})