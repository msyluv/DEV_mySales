({
	init : function(cmp) {
		
	}
,    
loadFirstValue : function(cmp){
 
        var action = cmp.get('c.getCurrentValue');
        var self = this;
        action.setParams({
            'type' : cmp.get('v.sObjectAPIName'),
            'value' : cmp.get('v.recordId'),
        });
 
        action.setCallback(this, function(a) {
            if(a.error && a.error.length){
             //   return $A.error('Unexpected error: '+a.error[0].message);
            }
            var result = a.getReturnValue();
            cmp.set("v.searchString", result);
 
            if (null!=result){
              // Show the Lookup pill
              var lookupPill = cmp.find("lookup-pill");
              $A.util.removeClass(lookupPill, 'slds-hide');
 
              // Lookup Div has selection
              var inputElement = cmp.find('lookup-div');
              $A.util.addClass(inputElement, 'slds-has-selection');
            }
        });
        $A.enqueueAction(action); 
    }
})