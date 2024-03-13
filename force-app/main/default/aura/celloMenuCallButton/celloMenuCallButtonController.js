/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 2023-10-24 
 * @last modified by  : divyam.gupta@samsung.com
 * Modifications Log 
 * Ver   Date         Author               Modification
 * 1.0   12-24-2020   woomg@dkbmc.com      Initial Version
 * 1.1   2022-10-29   kajal.c@samsung.com  Add 'LogisticsCPreview Aura component'.
 * 1.2   2o23-10-24   divyam.gupta@samsung.com Mysales-331 (Logistics) CP Review logic change.
**/
({
    doInit : function(component, event, helper){
        helper.doInit(component);
    },
   // V1.1 added by kajal
    callCelloMenu : function(component, event, helper) {
        component.set("v.showSpinner", true);
        console.log('call cello get.....');
        var reDirectpopUP = component.get("v.getExceptionBooleanValue");
        console.log('reDirectpopUP1@@' + reDirectpopUP);
        if(reDirectpopUP == true){
           console.log('reDirectpopUP2@@');
           component.set("v.popUpWindowRedirect", true);
        }else{
            component.set("v.popUpWindowRedirect", false);
            //helper.callCelloMenu(component, event);
        }
        //V 1.2 Changes by Divyam
        helper.callCelloMenu(component, event);
        component.set("v.showSpinner", false);
	},
})