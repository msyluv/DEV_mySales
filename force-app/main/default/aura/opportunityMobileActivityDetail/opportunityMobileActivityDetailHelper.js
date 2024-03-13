/**
 * @description       : 
 * @author            : wonjune.oh@partner.samsung.com
 * @group             : 
 * @last modified on  : 2020-11-26
 * @last modified by  : wonjune.oh@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                           Modification
 * 1.0   2020-11-26   wonjune.oh@partner.samsung.com   Initial Version
**/
({
    close : function(component, event) {
		component.find('overlayLib').notifyClose();
	},
})