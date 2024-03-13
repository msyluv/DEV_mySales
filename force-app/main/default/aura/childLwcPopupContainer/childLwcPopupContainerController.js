/**
  @author            : rakshit.s@samsung.com
  @description       : View All and Opp Specific Lost Type Custom Table with common merged cells. 
  @last modified on  : 2022-10-17
  @last modified by  : rakshit.s@samsung.com
  Modifications Log 
  Ver   Date         Author                   	Modification
  1.0   2023-01-24   rakshit.s@samsung.com        Initial Version
**/
({
    handleClick : function(component, event, helper) {
        component.destroy();
    },
    
    
    doInit: function(cmp) {
        // Set the attribute value. 
        // You could also fire an event here instead.
        //cmp.set("v.setMeOnInit", "controller init magic!");
        console.log('on load language passeedd-->' + cmp.get('v.isKorean'));
        
        let isLangKorean = false;
        //added locale calculation seperately here
        var locale = $A.get("$Locale.language");
        console.log('the user lang:'+locale);
        if(locale == 'ko'){
            console.log('language is korean from child');
            cmp.set('v.isKorean' , true);
        }
        
        else{
            console.log('language is english from child');
            cmp.set('v.isKorean' , false);
        }
        
        
        var myArgument = cmp.get("v.activityId");
        var action = cmp.get("c.isLostOrDrop");
        action.setParams({ activityId : myArgument,
                          oppId : cmp.get("v.opprecordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('intiresultmodalwindow-->' + result);
                if(result){
                    cmp.set("v.isLost" , true);
                    
                }
                
                else{
                    cmp.set("v.isDrop" , true);
                }
            }
            else {
                console.log("Error calling Apex method: " + state);
            }
        });
        $A.enqueueAction(action);
        
    }
    
})