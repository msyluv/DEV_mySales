/**
 * @description       : 
 * @author            : ukhyeon.lee@samsung.com
 * @group             : 
 * @last modified on  : 28-10-2022
 * @last modified by  : gitesh.s@samsung.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   07-05-2021   ukhyeon.lee@samsung.com   Initial Version
 * 1.1   28-10-2022   gitesh.s@samsung.com      Legal Review Link Change
**/
({
    init : function(component, event, helper) {        
        var opportunityType = component.get('v.opportunity.Type');
        var accountNumber = component.get('v.opportunity.Account.AccountNumber');
       	//신규추가시작
        var hasEditAccess = component.get('v.hasEditAccess');
        //신규추가종료
        var lbsType = '';
        switch (opportunityType) {
            case '01' :  // New Opportunity
                lbsType = 'NEW';
                break;
            case '02':  // Retention
                lbsType = 'RETEN';
                break;
        }
        component.set('v.lbsType', lbsType);
        component.set('v.billToId', accountNumber);

        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        var buttonHiddenDate = $A.localizationService.formatDate($A.get('$Label.c.OPPTYACT_VAL_BTN_HIDDEN_DATE'), "YYYY-MM-DD");
        component.set('v.today', today);
        component.set('v.buttonHiddenDate', buttonHiddenDate);

        /**V1.1 - START - GITESH **/
        helper.getRecordNameHQ(component);
        helper.getRecordNameLogistics(component);
        helper.checkOrg(component);
        /**V1.1 - END - GITESH **/
    },

    handleOpenLink : function(component, event, helper) {
        helper.handleOpenLink(component, event);
    }
})