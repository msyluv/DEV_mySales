/**
 * @description       : 
 * @author            : jiiiiii.park@partner.samsung.com.sds.dev
 * @group             : 
 * @last modified on  : 2020-12-21
 * @last modified by  : jiiiiii.park@partner.samsung.com.sds.dev
 * Modifications Log 
 * Ver   Date         Author                                     Modification
 * 1.0   2020-11-25   jiiiiii.park@partner.samsung.com.sds.dev   Initial Version
**/
({
    doInit : function(component, event, helper) {
        // 모바일 체크 여부
        var dvModule = $A.get( "$Browser.formFactor");
        if( dvModule === "PHONE" || dvModule === "IPHONE"){
            component.set( "v.isMobile", "M");
        }else{
            component.set( "v.isMobile", "W");
        }
        helper.helperInit(component, event);
    },

    cancel : function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire();
    },

    save : function (component, event, helper) {
        helper.helperSave(component, event);
    },

    onchangeAction : function(component, event, helper){
    },
})