/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 02-05-2021
 * @last modified by  : woomg@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   02-04-2021   woomg@dkbmc.com   Initial Version
**/
({
    doInit : function(component, event) {
        var self = this;
        console.log('window ->', window);
        console.log('window screen ->', window.screen);

        window.addEventListener('resize', function(){
            self.setWindowSize(component);
        });
    },

    setWindowSize : function(component){
        var screenWidth = window.screen.width,
            screenHeight = window.screen.height,
            windowWidth = window.innerWidth,
            windowHeight = window.innerHeight,
            headerHeight = 234;

        var modal = component.find('main-box');
        if(window.innerWidth == window.outerWidth && window.innerHeight == window.outerHeight){
            $A.util.addClass(modal, "slds-modal");
            $A.util.addClass(modal, "slds-fade-in-open");
            component.set("v.bodyHeight", windowHeight - 100);
            component.set("v.gridHeight", windowHeight - (100 + 25));
        } else {
            $A.util.removeClass(modal, "slds-modal");
            $A.util.removeClass(modal, "slds-fade-in-open");
            component.set("v.bodyHeight", windowHeight - headerHeight);
            component.set("v.gridHeight", windowHeight - (headerHeight + 10));
        }
    },

})