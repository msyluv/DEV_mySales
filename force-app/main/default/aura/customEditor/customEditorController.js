({
	afterScript: function(component, event, helper) {       
       console.log('Inside the Component Controller Adi After');
       //var cafeContainer = component.find("cafeDemo").getElement();
       //cafe.create("cafeDemo", "{!$Resource.cafe}" + "/2.3.27/config.json", "GET");
    },
    beforeScript: function(component, event, helper) {       
       console.log('Inside the Component Controller Adi Before');
    }
})