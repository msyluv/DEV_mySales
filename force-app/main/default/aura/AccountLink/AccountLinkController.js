/**
 * @description       : 
 * @author            : ukhyeon.lee@samsung.com
 * @group             : 
 * @last modified on  : 02-04-2022
 * @last modified by  : ukhyeon.lee@samsung.com
**/
({
    doInit: function(component, event, helper) {
        var accNo = component.get("v.pageReference").state.c__accNo;
        if(typeof accNo == "undefined" || accNo == null || accNo == ""){
            helper.showToast("error","고객사번호를 입력해주세요.");   //TO-DO 라벨처리
        }else {
            var action = component.get("c.getAccountId");
            action.setParams({ 
                "accNo": accNo
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var cnt = Number(response.getReturnValue().cnt);
                    if(cnt===0){
                        helper.showToast("error","고객사번호에 해당하는 고객사가 존재하지 않습니다.");    //TO-DO 라벨처리
                    } else if(cnt>1){
                        helper.showToast("error","고객사번호에 해당하는 고객사가 중복으로 존재합니다.");  //TO-DO 라벨처리
                    } else{
                        var urlEvent = $A.get("e.force:navigateToURL");
                        urlEvent.setParams({
                            "url": "/lightning/r/Account/"+response.getReturnValue().id+"/view"
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