/**
@author            : divyam.gupta@samsung.com
  @description       : Warning if Close Date is later than Contract Start Date. 
  @last modified on  : 09-18-2023
  @last modified by  : divyam.gupta@samsung.com
  Modifications Log 
  Ver   Date         Author                   	Modification
  1.0   2023-09-18   Divyam.gupta@samsung.com       Initial Version
 **/
({
	
     doInit : function(component, event, helper) {       
        console.log("recordId = " + component.get('v.recordId'));
          helper.getknxoxscheduledata(component,event);
    }
})