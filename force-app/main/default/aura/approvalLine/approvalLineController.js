/**
 * @description       : 
 * @author            : seonju.jin@dkbmc.com
 * @group             : 
 * @last modified on  : 2021-06-02
 * @last modified by  : seonju.jin@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                 Modification
 * 1.0   2021-06-02   seonju.jin@dkbmc.com   Initial Version
**/
({
    init : function(component, event, helper) {
        helper.init(component, event);
    },

    onPageReferenceChange : function(component, event, helper) {
        helper.onPageReferenceChange(component, event);
    },

    getApprovalLine : function(component, event, helper) { 
        helper.getApprovalLine(component, event);
    },
    //수주품의 단계에서의 인프라 구축(팝업창 생성) 요청의 건
    clickClose: function(component, event, helper) {
        component.set('v.preview', false);
	}
})