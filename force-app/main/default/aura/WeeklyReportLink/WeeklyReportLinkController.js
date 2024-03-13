/**
 * @description       : 
 * @author            : ukhyeon.lee@samsung.com
 * @group             : 
 * @last modified on  : 02-17-2022
 * @last modified by  : ukhyeon.lee@samsung.com
**/
({
    doInit: function(component, event, helper) {
        var boCode = component.get("v.pageReference").state.c__boCode;
        console.log("BOCODE: "+boCode);
        if(typeof boCode == "undefined" || boCode == null || boCode == ""){
            helper.showToast("error","사업기회번호를 입력해주세요.");   //TO-DO 라벨처리
        }else {
            var action = component.get("c.getBOId");
            action.setParams({ 
                "boCode": boCode
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var cnt = Number(response.getReturnValue().cnt);
                    if(cnt===0){
                        helper.showToast("error","사업기회번호에 해당하는 사업기회가 존재하지 않습니다.");    //TO-DO 라벨처리
                    } else if(cnt>1){
                        helper.showToast("error","사업기회번호에 해당하는 사업기회가 중복으로 존재합니다.");  //TO-DO 라벨처리
                    } else{
                        var urlEvent = $A.get("e.force:navigateToURL");
                        urlEvent.setParams({
                            "url": "/lightning/r/Opportunity/"+response.getReturnValue().id+"/related/Weekly_Report__r/view"
                        });
                        urlEvent.fire();
                    }
                }
                else if (state === "ERROR"){
                    helper.showToast("error","에러가 발생하였습니다.");   //TO-DO 라벨처리
                }
            });
        }
        $A.enqueueAction(action);
    },

    
})