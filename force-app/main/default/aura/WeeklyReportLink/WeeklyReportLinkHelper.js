/**
 * @description       : 
 * @author            : ukhyeon.lee@samsung.com
 * @group             : 
 * @last modified on  : 02-17-2022
 * @last modified by  : ukhyeon.lee@samsung.com
**/
({    
    showToast : function(type, msg) {
          var mode = 'sticky';
          if(type.toLowerCase() == 'success') mode = 'dismissible';
          
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
              type: type,
              duration: 5000,
              mode: mode,
              message: msg
          });
          toastEvent.fire();
      },    
  })