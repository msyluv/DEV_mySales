/**
 * @description       : 
 * @author            : wonjune.oh@partner.samsung.com
 * @group             : 
 * @last modified on  : 06-23-2023
 * @last modified by  : chae_ho.yang@samsung.com
 * Modifications Log 
 * Ver   Date         Author                           Modification
 * 1.0   2020-11-16   wonjune.oh@partner.samsung.com   Initial Version
**/
({
    init : function (component, event, helper) {
        helper.init(component, event);
    },


    handleActivityClick : function(component, event, helper) {
        var dbClickProhibition = component.get("v.dbClickProhibition");
        if(!dbClickProhibition){
            component.set("v.dbClickProhibition", true);
            event.preventDefault();
            helper.checkStatusActivity(component, event);
        }else{
            component.set('v.showSpinner',false);
        }
    },

})