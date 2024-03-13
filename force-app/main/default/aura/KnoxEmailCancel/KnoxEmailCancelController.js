({
    init : function(component, event, helper) {
        var record = component.get("v.record");
        if( record.Status__c == 'Cancel') {
            helper.showToast(component, 'error', 'dismissible', $A.get('$Label.c.COMM_LAB_ERROR'), $A.get('$Label.c.EMAIL_MSG_0015'), 3000); // 이미 발송 취소 되었습니다.
            $A.get("e.force:closeQuickAction").fire();

        } else {
            helper.cancelKnoxEmail(component, event);
        }
    }
})