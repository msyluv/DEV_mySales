trigger ReferenceReportDashboardTrigger on ReferenceReportDashboard__c (After Insert) {
/**
 * @description       : 
 * @author            : divyam.gupta@samsung.com
 * @group             : 
 * @last modified on  : 2023-07-14
 * @last modified by  : divyam.gupta@samsung.com
 * Modifications Log 
 * Ver   Date         Author                     Modification
 * 1.0   2020-12-01   divyam.gupta@samsung.com   Initial Version
**/
    
     TriggerSwitch__c trSwitch = TriggerSwitch__c.getInstance(UserInfo.getUserId()); 
    Boolean AllSwitch = trSwitch.All__c; 					
  //  Boolean refdashSwitch = trSwitch.ReferenceReportDashboard__c;
    
    
    if(AllSwitch ) {
        
         switch on Trigger.OperationType {
            when AFTER_INSERT {
                   system.debug('After insert');
                   AddRefreportdashcount(Trigger.newMap);
                }
         }
            }
    
         private static void AddRefreportdashcount(Map<Id,ReferenceReportDashboard__c> newMap){
             List<ReferenceReportDashboard__c> refdashlist =[ Select id,Name,Information__c from ReferenceReportDashboard__c where Id IN: newMap.keySet()];
            List<Ref_repdash_count__c> LISTcust = Ref_repdash_count__c.getall().values();
            // system.debug('LISTcust'+LISTcust);
             Map<String,Ref_repdash_count__c> custmp = new  Map<String,Ref_repdash_count__c>();
             Map<Id,Ref_repdash_count__c> mapupdate =new Map<Id,Ref_repdash_count__c>();
             Map<Id,Ref_repdash_count__c> mapinsert =new Map<Id,Ref_repdash_count__c>();
             Map<String,Integer> FoldernameRepeatD = new Map<String,Integer>();

             for(Ref_repdash_count__c refdas : LISTcust){
                 custmp.put(refdas.Name,refdas);
             }
             List<Ref_repdash_count__c>  refcountlist = new List<Ref_repdash_count__c>();
                          List<Ref_repdash_count__c>  refcountlistupt = new List<Ref_repdash_count__c>();

             for(ReferenceReportDashboard__c rlsit : refdashlist){
                 Ref_repdash_count__c repdash = new Ref_repdash_count__c();
                 if(custmp.containsKey(rlsit.Information__c)){
                        repdash = custmp.get(rlsit.Information__c);
                     system.debug('record val'+repdash);
                     repdash.Information_Type_count__c = repdash.Information_Type_count__c + 1;
                      system.debug('record val list'+refcountlistupt);
                     mapupdate.put(repdash.Id,repdash);

                 }


                 else {
                       if(!FoldernameRepeatD.containsKey(rlsit.Information__c)){
                        FoldernameRepeatD.put(rlsit.Information__c,000);
                    }
                    Integer currentCount=FoldernameRepeatD.get(rlsit.Information__c)+001;
                    FoldernameRepeatD.put(rlsit.Information__c,currentCount);
                    

                 }
                  

             }
              refcountlistupt= mapupdate.values();
              system.debug('refcountlistupt-->'+refcountlistupt);
             if(refcountlistupt.size() > 0){
              update refcountlistupt;
             }
             for (String key : FoldernameRepeatD.keySet()) {
                  Ref_repdash_count__c repdash1 = new Ref_repdash_count__c();
                  repdash1.Name = key;
                 repdash1.Information_Type_count__c = FoldernameRepeatD.get(key);
                 refcountlist.add(repdash1);
                 // ... emailing logic
             }
             if(refcountlist.size() > 0){
                
              insert refcountlist;
                  }
    }
}