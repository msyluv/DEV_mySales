/**
* @description       : 
* @author            : saurav.k@partner.samsung.com
* @group             : 
* @last modified on  :  18/07/2023
* @last modified by  :  divyam.gupta@samsung.com 
* Modifications Log 
* Ver     Date             Author                         Modification 
* 1.0   05/06/2023      saurav.k@partner.samsung.com      Initial Version(Report&Dahboard Reference Page Development)-MySales -217
* 1.1   14/06/2023      saurav.k@partner.samsung.com      Reference Report/Dashboard Modification(MySales - 231)
* 1.2   18/07/2023      divyam.gupta@samsung.com          Reference Report/Dashboard Modification(MySales - 252)

**/
public class reportDasboardReference {
    public  Boolean isAllowed {get;set;}
	public Id RecordId {get;set;}  //v1.1(MySales - 231)      
    Public  Void getReportRefData(){   
        
        Map<String,Integer> FoldernameRepeat = new   Map<String,Integer>();
        Map<String,Integer> FoldernameRepeatD = new   Map<String,Integer>();
        Map<String,Integer> FoldernameRepval = new   Map<String,Integer>();

        RecordId  = ApexPages.currentPage().getParameters().get('id');//v1.1(MySales - 231)
        Id profileId=userinfo.getProfileId();
        Integer totalval= 0;
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        List<ReferenceReportDashboard__c> listofReportReference = New List<ReferenceReportDashboard__c>();
        List<ReferenceReportDashboard__c> listofDashBoardReference = New List<ReferenceReportDashboard__c>(); 
        String Refernce = 'Ref\\_%';	
        List<Report> listofReports = [SELECT Id,Name,DeveloperName,FolderName,Description,CreatedDate from Report 
                                      WHERE DeveloperName LIKE : Refernce];
        List<Id> listofreprtid = new List<Id>();
        List<Id> Listofdashid = new List<Id>();
        Map<id,String> mapforrefdashid = new Map<id,String>();
        Map<id,String> mapforrefdashidd = new Map<id,String>();
                     
        for(Report lrep : listofReports){
            mapforrefdashid.put(lrep.Id,lrep.DeveloperName);
        }
        system.debug('key'+mapforrefdashid.keySet());
        List<Dashboard> listofDashboards = [SELECT Id,Title, DeveloperName,FolderName,Description,Folder.DeveloperName,CreatedDate from Dashboard 
                                            WHERE Folder.DeveloperName LIKE : Refernce]; 
          for(Dashboard drep : listofDashboards){
            mapforrefdashidd.put(drep.Id,drep.DeveloperName);
        }
        List<ReferenceReportDashboard__c> listofrefreport =[Select id,Name,Report_ID__c,Dashboard_ID__c from ReferenceReportDashboard__c where Report_ID__c 
                                                            NOT IN: mapforrefdashid.keySet() AND Type__c= 'Report'];
        system.debug('listofrefreport'+listofrefreport);
           List<ReferenceReportDashboard__c> listofrefreportd =[Select id,Name,Report_ID__c,Dashboard_ID__c from ReferenceReportDashboard__c where 
                                                            Dashboard_ID__c NOT IN: mapforrefdashidd.keySet() AND Type__c= 'Dashboard'];
         
      
         List<ReferenceReportDashboard__c> listreportdash =[Select id,Name,Report_ID__c,Dashboard_ID__c,Information__c from ReferenceReportDashboard__c];
        Map<Id,String> mapreportdash = new Map<Id,String>();
        Map<String,Integer> mapcount = new Map<String,Integer>();
        for(ReferenceReportDashboard__c lrep :listreportdash){
            mapreportdash.put(lrep.Report_ID__c,lrep.Name);
            mapreportdash.put(lrep.Dashboard_ID__c,lrep.Name);

                 }
         List<Ref_repdash_count__c> LISTcust = Ref_repdash_count__c.getall().values();
             Map<String,Ref_repdash_count__c> custmp = new  Map<String,Ref_repdash_count__c>();
             for(Ref_repdash_count__c refdas : LISTcust){
                 custmp.put(refdas.Name,refdas);
             }

        if(profileName == 'System Administrator' || profileName == '시스템 관리자'){
            isAllowed = false;            
            if(listofReports != Null && !listofReports.IsEmpty()){
                for(Report refReports : listofReports){                    
                    ReferenceReportDashboard__c ref = new  ReferenceReportDashboard__c(); 
                    String Addformat;
                    Integer countref =0 ;
                    //refReports.Name;
                    if(mapreportdash.containskey(refReports.Id)){
                        ref.Name = mapreportdash.get(refReports.Id);
                    }
                    else {
                     if(custmp.containskey(refReports.FolderName)){
                         if(mapcount.containskey(refReports.FolderName)){
                               countref = mapcount.get(refReports.FolderName);
                              countref++;
                                  mapcount.put(refReports.FolderName,countref);
                         }
                         else {
                            Ref_repdash_count__c refrecod = custmp.get(refReports.FolderName);
                       countref = Integer.valueOf(refrecod.Information_Type_count__c);
                     countref++;  
                          mapcount.put(refReports.FolderName,countref);
                         }
                    }
                        else {
                    if(!FoldernameRepeatD.containsKey(refReports.FolderName)){
                        FoldernameRepeatD.put(refReports.FolderName,000);
                    }
                    Integer currentCount=FoldernameRepeatD.get(refReports.FolderName)+001;
                    FoldernameRepeatD.put(refReports.FolderName,currentCount);
                               countref = Integer.valueOf(FoldernameRepeatD.get(refReports.FolderName));
                        }
                        String countrefstr = String.valueOf(countref);
                       if(countrefstr.length() == 1 ){
                      Addformat = '-00';
                    }
                    else {
                      Addformat = '-0';

                    }   
                    ref.Name = refReports.FolderName+Addformat+countref;//refReports.Name;

                    }
                  
                    ref.Report_Name__c = refReports.Name;
                    ref.Type__c = 'Report';
                    ref.Information__c = refReports.FolderName;
                    ref.Description__c = refReports.Description;
                    ref.CreatedDate__c = refReports.CreatedDate;
                    ref.Report_ID__c = refReports.Id;  
                    /*Start - v1.1(MySales -231)*/
                    String DeveloperName = refReports.DeveloperName;                     
                    if(DeveloperName != null && DeveloperName.startsWith('Ref_A_')){                        
                        ref.Shared_Range__c = '1';
                    }else{                        
                        ref.Shared_Range__c = '2';
                    }  
                    /*End - v1.1(MySales -231)*/
                    listofReportReference.add(ref);
                }                
                if(listofReportReference.Size() > 0) 
                    try {
                        upsert listofReportReference Report_ID__c;
                        delete listofrefreport;

                    } catch(DmlException e) {
                        System.debug('The following exception has occurred: ' + e.getMessage());
                    }
            }
            if(listofDashboards != Null && !listofDashboards.IsEmpty()){
                for(Dashboard refDashboard : listofDashboards){                    
                    ReferenceReportDashboard__c ref = new  ReferenceReportDashboard__c();
                     String Addformat;
                    Integer countref =0 ;
                    //refReports.Name;
                    if(mapreportdash.containskey(refDashboard.Id)){
                        ref.Name = mapreportdash.get(refDashboard.Id);
                    }
                    else {
                     if(custmp.containskey(refDashboard.FolderName)){
                         if(mapcount.containskey(refDashboard.FolderName)){
                               countref = mapcount.get(refDashboard.FolderName);
                              countref++;
                                  mapcount.put(refDashboard.FolderName,countref);
                         }
                         else {
                       Ref_repdash_count__c refrecod = custmp.get(refDashboard.FolderName);
                       countref =  Integer.valueOf(refrecod.Information_Type_count__c);
                     countref++;  
                             mapcount.put(refDashboard.FolderName,countref);
                         }
                    }
                        else {
                            if(!FoldernameRepeatD.containsKey(refDashboard.FolderName)){
                        FoldernameRepeatD.put(refDashboard.FolderName,000);
                    }
                    Integer currentCount=FoldernameRepeatD.get(refDashboard.FolderName)+001;
                    FoldernameRepeatD.put(refDashboard.FolderName,currentCount);
                               countref = Integer.valueOf(FoldernameRepeatD.get(refDashboard.FolderName));

                        }
                        String countrefstr = String.valueOf(countref);
                       if(countrefstr.length() == 1 ){
                      Addformat = '-00';
                    }
                    else {
                      Addformat = '-0';

                    }   
                    ref.Name = refDashboard.FolderName+Addformat+countref;//refReports.Name;

                    }
                  //  ref.Name = refDashboard.FolderName;//refDashboard.Title;
                    ref.Dashboard_Name__c = refDashboard.Title;
                    ref.Type__c = 'Dashboard';
                    ref.Information__c = refDashboard.FolderName;
                    ref.Description__c = refDashboard.Description;
                    ref.CreatedDate__c = refDashboard.CreatedDate;
                    ref.Dashboard_ID__c = refDashboard.Id;
                    /*Start - v1.1(MySales -231)*/
                    String FolderDeveloperName = refDashboard.Folder.DeveloperName;                    
                    if(FolderDeveloperName != null && FolderDeveloperName.startsWith('Ref_A_')){
                        ref.Shared_Range__c = '1';
                    }else{
                        ref.Shared_Range__c = '2';
                    } 
                    /*End - v1.1(MySales -231)*/
                    listofDashBoardReference.add(ref);
                }              
                if(listofDashBoardReference.Size() > 0) 
                    try {
                        upsert listofDashBoardReference Dashboard_ID__c;
                        delete listofrefreportd;
                    } catch(DmlException e) {
                        System.debug('The following exception has occurred: ' + e.getMessage());
                    }
            }                       
        }
        
        
    }
    
}