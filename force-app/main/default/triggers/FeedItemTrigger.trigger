trigger FeedItemTrigger on FeedItem (before insert, before update) {
    switch on Trigger.operationType{
        when before_insert, before_update{
           preventFileUpload(Trigger.new);
        }
    }
    
    
    private static void preventFileUpload(List<FeedItem> objList){
        for(FeedItem obj : objList){
            if(obj.Type.equals('ContentPost')) obj.addError(System.Label.Prevent_FileUpload_Chatter);
        }
    }
}