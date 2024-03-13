/**
 * @description       : JS controller of showLogisticOpptyCount Aura cmp 
 * @author            : d.ashish@samsung.com
 * @group             : 
 * @last modified on  : 2023-06-06
 * @last modified by  : d.ashish@samsung.com
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   2023-06-06   d.ashish@samsung.com   Initial Version
**/
({
	doInit : function(component, event, helper){
		helper.getBOCount(component, event, helper);
        helper.getUserCountries(component, event, helper);
	}       
})