/**
 * @description       : 
 * @author            : wonjune.oh@partner.samsung.com
 * @group             : 
 * @last modified on  : 2020-12-01
 * @last modified by  : wonjune.oh@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                           Modification
 * 1.0   2020-11-30   wonjune.oh@partner.samsung.com   Initial Version
**/
({
    /*
    * @Name             : doInit
    * @author           : Jonggil Kim, 2019/05/29
    * @Description      : Component가 실행될 때 해당레코드의 공유 정보와 Search Type을 설정함.
    */
    doInit : function(component, event, helper) {        
        var device = $A.get("$Browser.formFactor");
        component.set('v.device',device);

        if(device == "DESKTO"){   
            //helper.spinnerToggle(component, event);
            
            alert($A.get("$Label.c.COMM_MSG_0004"));                 
           // var navEvt = $A.get("e.force:navigateToSObject");
           // navEvt.setParams({
           //     "recordId": component.get("v.record").Id,
           //     "slideDevName":"detail",
           //     "isredirect":true
           // });
           // navEvt.fire();
            //helper.callToast(true, $A.get("$Label.c.COMM_MSG_0004"), 'error', 3000); //'모바일에서는 사용하실 수 없습니다.'              
            $A.get("e.force:closeQuickAction").fire();
            //$A.get("e.force:refreshView").fire();
             
        }else{
            helper.doInit(component, event);
            
            // 사용하지 않는 공유 타입에 대해서는 주석 //
            var selectType = [ ];        
            selectType.push({'label': 'User', 'value': 'User'});
            selectType.push({'label': 'Public Group', 'value': 'PublicGroup'});
            selectType.push({'label': 'Role', 'value': 'Role'});
            selectType.push({'label': 'Role And Subordinates', 'value': 'RoleAndSubordinates'});

            component.set('v.selectOptions', selectType);
        }
    }
    , searchKeyUp : function (component, event, helper) {
        console.log('searchKeyUp');
        var isEnterKey = event.keyCode === 13;
        console.log(isEnterKey);
        if (isEnterKey) {
            helper.getSearchData(component, event);
            
        }
    }
    /*
    * @Name             : insertSharing
    * @author           : Jonggil Kim, 2019/05/29
    * @Description      : 새로운 공유 규칙을 생성하는 helper 호출.
    */
    , insertSharing : function (component, event, helper) {
        helper.insertSharing(component, event);        
    }
    /*
    * @Name             : deleteSharing
    * @author           : Jonggil Kim, 2019/05/29
    * @Description      : 설정되어있는 공유 규칙을 삭제하는 helper 호출.
    */
    , deleteSharing : function (component, event, helper) {
        helper.deleteSharing(component, event);        
    }
    /*
    * @Name             : updateSharing    
    * @author           : Jonggil Kim, 2019/05/29
    * @Description      : 설정되어있는 공유 규칙의 권한을 업데이트하는 helper 호출.
    */
    , updateSharing : function (component, event, helper) {
        helper.updateSharing(component, event);        
    }
    /*
    * @Name             : changeSharing
    * @author           : Jonggil Kim, 2019/05/29
    * @Description      : 공유 대상 정보(Map type)가 변경되었을 때 해당 정보를 화면에 업데이트 함(List type).
    */
    , changeSharing : function (component) {
        var sharmap = component.get('v.SharingMap');
        var viewList = [];
               
        var objUncovered = JSON.parse(JSON.stringify(sharmap));
        
        for (var key in objUncovered) {
            if (objUncovered.hasOwnProperty(key)) {
                viewList.push(objUncovered[key]);
            }
        }
        console.log(viewList);
        component.set('v.viewList', viewList);      
    } 
    /*
    * @Name             : clearSearchResult
    * @author           : Jonggil Kim, 2019/05/29
    * @Description      : 타입을 변경할 때 검색결과를 초기화 해줌.
    */
   , clearSearchResult : function (component) {
        var clear = [];
        component.set('v.searchResult', clear);      
    } 
    , closeModal  : function () {
        $A.get("e.force:closeQuickAction").fire();
    }
})