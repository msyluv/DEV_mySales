({
    handleOpenModal: function(component, event, helper) {
        //For Display Modal, Set the "openModal" attribute to "true"
        component.set("v.openModal", true);
    },
     
    handleCloseModal: function(component, event, helper) {
        //For Close Modal, Set the "openModal" attribute to "fasle"  
        component.set("v.openModal", false);
    },
    closeModal: function(component, event, helper) {
        console.log('Before Close Modal');
        component.set("v.isOpen", false);
        window.history.back();
        console.log('After Close Modal');
    }
})