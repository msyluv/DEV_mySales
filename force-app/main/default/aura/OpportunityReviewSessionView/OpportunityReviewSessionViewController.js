/**
 * @description       : 
 * @author            : akash.g@samsung.com
 * @group             : 
 * @last modified on  : 2024-05-09
 * @last modified by  : akash.g@samsung.com
 * Modifications Log 
 * Ver   Date         Author                           Modification
 * 1.0   2024-05-09   akash.g@samsung.com              Initial Version(MYSALES -499)
**/
({
    doInit: function(component, event, helper) {
        helper.getReviewSession(component, event, helper);
        helper.getReviewTargetList(component, event, helper);
    } 
})