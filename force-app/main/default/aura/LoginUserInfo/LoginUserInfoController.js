/**
 * @description       : 
 * @author            : jiiiiii.park@partner.samsung.com.sds.dev
 * @group             : 
 * @last modified on  : 2021-04-02
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                                     Modification
 * 1.0   2020-11-05   jiiiiii.park@partner.samsung.com.sds.dev   Initial Version
**/
({ 
    init : function(component, event, helper) {
        window.console.log('init Start');        
        helper.helperInit(component, event); 
    },
        
    userOverlayClick: function(component, event, helper) {
        var modalBody;
        $A.createComponent("c:UserRegistrationApplicationOverlay", {},
            function(content, status) {
                if (status === "SUCCESS") {
                    modalBody = content;
                    component.find('overlayLib').showCustomModal({
                        body: modalBody,
                        showCloseButton: true,
                        cssClass: "mymodal"
                    })
                }
            }
        );
    }
})