/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2023-09-01
 * @last modified by  : Atul.k1@samusng.com
 * Ver   Date         Author                   Modification
 * 1.0   2023-09-06   atul.k1@samsung.com   Initial Version(MySales 290)

**/
({
	init : function(component, event, helper) {
		helper.init(component, event);
	},
     /*Added by Atul Start Mysales-290 v-1.0*/
    searchBox : function(component,event,helper){
        console.log('Box'+component.get('v.showSearchBox'));
        var visibilityBox = component.get('v.showSearchBox');
        if(visibilityBox === true){
            console.log('visibilityBox1'+visibilityBox);
            component.set("v.showSearchBox",false);
        }
        if(visibilityBox === false){
            console.log('visibilityBox2'+visibilityBox);
            component.set('v.showSearchBox',true);
            console.log('Box2'+component.get('v.showSearchBox'));
        }
    },
    searchEnterKey : function(component,event,helper){
        if(event.keyCode == 13){
        console.log('value'+event.target.value);
        var URL = 'http://70.225.5.3:2007/ArisamWeb/smartSearch/list.do?search_Text='+event.target.value;
        window.open(URL,'_blank');
      }
      
    },
     searchButton : function(component,event,helper){
         var textVal =  document.getElementById("someId").value;
         console.log('document.getElementById("nameofid").value'+document.getElementById("someId").value)
         var URL = 'http://70.225.5.3:2007/ArisamWeb/smartSearch/list.do?search_Text='+textVal;
         window.open(URL,'_blank');
      
    }
    /*Added by Atul End v-1.0*/
})