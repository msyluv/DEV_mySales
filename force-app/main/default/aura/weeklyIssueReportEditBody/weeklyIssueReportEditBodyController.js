/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 01-04-2021
 * @last modified by  : woomg@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author            		Modification
 * 1.0   01-04-2021   woomg@dkbmc.com   		Initial Version
 * 1.1   2024-03-26   aditya.r2@samsung.com		Communication between Aura and VF page Bidirectionally
**/
({
    doInit : function(component, event, helper) {
		console.log('Inside clickSave Edit Body 31 : ');
        
        //Start v1.1
        const handlePostMessage = event => {
        	console.log('post message data', event.data);
            console.log('post message data', event.data.message);
            component.set("v.vfValue", event.data.message);
            component.set("v.pressMe", "1");
            var abc = component.get("v.vfValue");
            console.log('vfvalue data', abc);
        }
        window.addEventListener('message', handlePostMessage);
    	console.log('after event msg');
        //End v1.1
        helper.doInit(component, event);
    },

    clickSave : function(component, event, helper) {
        //Start v1.1
        var vfWindow = component.find("vfFrame").getElement().contentWindow;
        vfWindow.postMessage({channel : 'channelId1', message1 : 'saveDesc();'}, '*');
        setTimeout(function(){
            helper.saveContent(component);  
        }, 3000);
        //End v1.1
        //helper.saveContent(component); 
    }

})