({
    init : function(cmp, event, helper){
        try{
            //first load the current value of the lookup field
            helper.init(cmp);
            helper.loadFirstValue(cmp);
            
        }catch(ex){
            console.log(ex);
        }
    }

})