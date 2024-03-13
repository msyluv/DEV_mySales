/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 2020-12-18
 * @last modified by  : hj.lee@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   11-20-2020   woomg@dkbmc.com   Initial Version
**/
({
    viewDetail : function(component, event, helper) {
        helper.showMyToast('info', 'display the activity information');
        component.set("v.showModal", true);
        window.setTimeout(function(){
            component.set("v.showModal", false);
        }, 3000);
    },


     /**
     * Detail Component Modal
     */
    showActivity: function(component, event, helper) {
        event.preventDefault();
        component.set("v.isShowMobileDetail", true);

        /*
        var componentName = 'opportunityMobileActivityDetail';
        var attributeParams = {
            'parentId' : component.get('v.parentId')
            , 'activityItem' : component.get('v.activityItem')
            , 'isDisabledClick' : true
            , 'maximize' : true
        };
        var cssClass = 'slds-modal_medium';
        var closeCallback = function() {
            var refreshEvt = component.getEvent("opportunityActivityPanelRefreshEvent");
            if(refreshEvt) refreshEvt.fire();
        };
        
        helper.showComponentModal(component, componentName, attributeParams, cssClass, closeCallback); 
        */ 
    }
})