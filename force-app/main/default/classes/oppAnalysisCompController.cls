/**
* @description       : Add new tab Analysis of Competition Result.
* @author            : divyam.gupta@samsung.com
* @group             : 
* @last modified on  : 2023-02-22
* @last modified by  : Kajal.c@samsung.com
* Modifications Log 
* Ver   Date         Author                      Modification
* 1.0   2022-10-17   divyam.gupta@samsung.com   Initial Version
* 1.1   2023-02-22   Kajal.c@samsung.com    IF-159 Calling related to MySales-96
* 1.2   2023-04-20   rakshit.s@samsung.com       logic to check if the scenario of activity is lost or drop.
* 1.3   2023-05-30   divyam.gupta@samsung.com   Add on changes Lost Enchacement(Mysales -204)
**/

public class oppAnalysisCompController {
    
    
    @AuraEnabled
    public static Opportunity_Activity__c getOppActivitystatus(Id oppActid){
        Opportunity_Activity__c opact =[select id,Status__c,LostType__c from Opportunity_Activity__c where id =: oppActid];
        return opact;
        
    }
    //START 1.3
       @AuraEnabled
    public static String getProfilecheck(){
        String userid = userInfo.getUserId();
        String profileacess = 'Read Access';
        user getprofile = [select id, Profile.Name from user where id=: userid];
        string profilename = getprofile.Profile.Name;
        system.debug('profilename'+profilename);
        List<String> profilefromlabl = System.Label.ProfileCheck.Split(',');
        for(String i : profilefromlabl){
            if(i == Profilename){
                profileacess = 'Edit Access';
            }
           
        }
        return profileacess;

     }
    //END 1.3
    @AuraEnabled
    public static String getLosttype1(Id OppId,Boolean korlang,Id oppActid){
     Opportunity_Activity__c opact =[select id,Status__c,LostType__c from Opportunity_Activity__c where Id =: oppActid];
        String lostdroptype;
        if(opact.LostType__c == 'Z06'){
        lostdroptype = 'Lost';
        }
        if(opact.LostType__c == 'Z07'){
          lostdroptype = 'Drop';
 
        }
        system.debug('lostdroptype'+lostdroptype);
        Set<String> lvl1seteng = new Set<String>();
        Set<String> lvl1setval = new Set<String>();
        Set<String> lvl2setval = new Set<String>();
        Set<String> lvl3setval = new Set<String>();
        
        Set<String> masterlstcode = new Set<String>();
        
        List<Master_LostType__c> losttypelist = new  List<Master_LostType__c>();
        
        Map<String, Set<String>> maplosttype = new Map<String, Set<String>>{
            'level1val' => lvl1setval,
                'level2val' => lvl2setval,
                'level3val' => lvl3setval};
                    
                    losttypelist = [select id,Code__c,Type_Kor__c,Type_Eng__c,Level1_Code__c,
                                    Level1_Type_Kor__c,Level2_Code__c,Level2_Type_Kor__c,Level3_Code__c,
                                    Level3_Type_Kor__c,Level1_Type_Eng__c,Level2_Type_Eng__c,
                                    Level3_Type_Eng__c,Lost_Drop_Type__c from Master_LostType__c where Use__c = True AND Lost_Drop_Type__c =:lostdroptype
                                    ORDER BY Order_Number__c];
        if(losttypelist.size() > 0){
            for(Master_LostType__c losttype: losttypelist ){
                if(korlang == false){
                    lvl1setval.add(losttype.Level1_Type_Eng__c);
                    lvl2setval.add(losttype.Level2_Type_Eng__c);
                    lvl3setval.add(losttype.Type_Eng__c);
                }
                else {
                    lvl1setval.add(losttype.Level1_Type_Kor__c);
                    lvl2setval.add(losttype.Level2_Type_Kor__c);
                    lvl3setval.add(losttype.Type_Kor__c);
                    
                }
                
            }
            
        }
        
        return JSON.serialize(maplosttype);
        
        
    }
    
    @AuraEnabled
    public static String getLosttype2(Id OppId,String level1combo,Boolean korlang,String lostdroptype){
        Set<String> lvl2setval = new Set<String>();
        
        List<Master_LostType__c> losttypelist = new  List<Master_LostType__c>();
        
        Map<String, Set<String>> maplosttype = new Map<String, Set<String>>{
            'level2val' => lvl2setval
                };
                    
                    if(level1combo != '' && level1combo != null ){
                        List<Master_LostType__c> losttypelist1 = [select id,Code__c,Level2_Code__c,Level2_Type_Kor__c,Level2_Type_Eng__c
                                                                  from Master_LostType__c where Use__c = True AND Lost_Drop_Type__c	=:lostdroptype
                                                                  AND (Level1_Type_Eng__c =: level1combo OR Level1_Type_Kor__c =: level1combo) ORDER BY Order_Number__c];
                        
                         system.debug('losttypelist1-->'+losttypelist1);
                        for(Master_LostType__c losttype: losttypelist1 ){
                            if(korlang == false){
                                lvl2setval.add(losttype.Level2_Type_Eng__c);
                            }
                            else {
                                lvl2setval.add(losttype.Level2_Type_Kor__c);
                                
                            }
                        }
                        
                    }
        
        
        return JSON.serialize(maplosttype);
        
        
    }
    
    @AuraEnabled
    public static String getLosttype3(Id OppId,String level2combo,Boolean korlang,String lostdroptype){
        Set<String> lvl3setval = new Set<String>();
        
        List<Master_LostType__c> losttypelist = new  List<Master_LostType__c>();
        
        Map<String, Set<String>> maplosttype = new Map<String, Set<String>>{
            'level3val' => lvl3setval};
                
                if(level2combo != '' && level2combo != null ){
                    List<Master_LostType__c> losttypelist1 = [select id,Code__c,Type_Kor__c,Type_Eng__c from Master_LostType__c where Use__c = True 
                                                              AND (Level2_Type_Eng__c =: level2combo OR Level2_Type_Kor__c =: level2combo) AND Lost_Drop_Type__c=: lostdroptype ORDER BY Order_Number__c];
                    
                    for(Master_LostType__c losttype: losttypelist1 ){
                        if(korlang == false){
                            lvl3setval.add(losttype.Type_Eng__c);
                        }
                        else {
                            lvl3setval.add(losttype.Type_Kor__c);
                        }
                    }
                    
                }
        
        
        return JSON.serialize(maplosttype);
        
        
    }
    
    @AuraEnabled
    public static List<tableDataWrap> getLosttype(Id OppId, Boolean korlang, Id oppActid){
       Opportunity_Activity__c opact =[select id,Status__c,LostType__c from Opportunity_Activity__c where Id =: oppActid];
        String lostdroptype;
        if(opact.LostType__c == 'Z06'){
        lostdroptype = 'Lost';
        }
        if(opact.LostType__c == 'Z07'){
          lostdroptype = 'Drop';
 
        }
        List<tableDataWrap> tdWrapList = new list<tableDataWrap>();
        List<Master_LostType__c> losttypelist = new List<Master_LostType__c>();
        List<LostResult__c> lostRes = new List<LostResult__c>();
        List<LostResult__c> dellostres = new List<LostResult__c>();
        List<Lost_Countermeasure__c> dellostcountr = new List<Lost_Countermeasure__c>();

        Integer indexsize = 1;
        losttypelist   =[select id,Code__c,Type_Kor__c,Type_Eng__c,Level1_Code__c,
                         Level1_Type_Kor__c,Level2_Code__c,Level2_Type_Kor__c,Level3_Code__c,
                         Level3_Type_Kor__c,Level1_Type_Eng__c,Level2_Type_Eng__c,
                         Level3_Type_Eng__c from Master_LostType__c  
                         ORDER BY Order_Number__c];
        
        /**lostRes = [Select id,LOST_DETAIL__c,Rate__c,losttypecode__c, IsCheck__c,ApproveStatus__c,Master_LostType__c,Master_LostType__r.Level1_Type_Eng__c,Master_LostType__r.Level2_Type_Eng__c
                   from LostResult__c  where Opportunity__c =: OppId and IsCheck__c = true AND Master_LostType__r.Lost_Drop_Type__c =:lostdroptype	ORDER BY CreatedDate];**/
        //V 1.3
        lostRes = [Select id,LOST_DETAIL__c,Rate__c,losttypecode__c, IsCheck__c,ApproveStatus__c,Master_LostType__c,Master_LostType__r.Level1_Type_Eng__c,Master_LostType__r.Level2_Type_Eng__c
                   from LostResult__c  where Opportunity__c =: OppId AND  LostActivity__c=: oppActid AND IsCheck__c = true AND Master_LostType__r.Lost_Drop_Type__c =:lostdroptype	ORDER BY CreatedDate];
        system.debug('lostRes coming-->'+lostRes);
        dellostres = [select id from LostResult__c where Opportunity__c =: OppId AND  Master_LostType__r.Lost_Drop_Type__c !=:lostdroptype];
        dellostcountr = [select id from Lost_Countermeasure__c where Opportunity__c =: OppId AND  Master_LostType__r.Lost_Drop_Type__c !=:lostdroptype];
        if(dellostres.size() > 0){
            delete dellostres;
        }
         if(dellostcountr.size() > 0){
            delete dellostcountr;
        }
        //logic for filling data on load.
        for(LostResult__c lRes : lostRes)
        {
            tableDataWrap tdWrap = new tableDataWrap();
            SelectRecord lv2recd = new SelectRecord();
            SelectRecord lv3recd = new SelectRecord();
            Set<String> lvl2Recordlsteng = new  Set<String>();
            Set<String> lvl2Recordlstkor = new  Set<String>();
            Set<String> lvl3Recordlsteng = new  Set<String>();
            Set<String> lvl3Recordlstkor = new  Set<String>();
            
            List<Master_LostType__c> lstmstrlost = [select Level2_Type_Kor__c,Level2_Type_Eng__c,Type_Eng__c,Type_Kor__c from Master_LostType__c where Level1_Type_Eng__c=: lRes.Master_LostType__r.Level1_Type_Eng__c];
            List<Master_LostType__c> lstmstrlost1 = [select Level2_Type_Kor__c,Level2_Type_Eng__c,Type_Eng__c,Type_Kor__c from Master_LostType__c where Level2_Type_Eng__c=: lRes.Master_LostType__r.Level2_Type_Eng__c];
            
            if(lstmstrlost.size() > 0){
                for(Master_LostType__c mslst : lstmstrlost){
                    lvl2Recordlsteng.add(mslst.Level2_Type_Eng__c);
                    lvl2Recordlstkor.add(mslst.Level2_Type_Kor__c);
                } 
            }
            if(lstmstrlost1.size() > 0){
                for(Master_LostType__c mslst : lstmstrlost1){
                    lvl3Recordlsteng.add(mslst.Type_Eng__c);  
                    lvl3Recordlstkor.add(mslst.Type_Kor__c);  
                }
            }
            List<String> lvl2Recordlisteng = new  List<String>();
            List<String> lvl2Recordlistkor = new  List<String>();
            List<String> lvl3Recordlisteng = new  List<String>();
            List<String> lvl3Recordlistkor = new  List<String>();
            
            lvl2Recordlisteng.addAll(lvl2Recordlsteng);
            lvl2Recordlistkor.addAll(lvl2Recordlstkor);
            lvl3Recordlisteng.addAll(lvl3Recordlsteng);
            lvl3Recordlistkor.addAll(lvl3Recordlstkor);
            
            // tdWrap.masterList = lostTypeData; 
            if(lostRes.size()>0){
                system.debug('inside first if for size');
                for(Master_LostType__c lostTypeData : losttypelist) {   
                    system.debug('inside for loop-->' + lostTypeData.Code__c == lRes.losttypecode__c);
                    if(lRes.losttypecode__c == lostTypeData.Code__c)
                    {
                        system.debug('inside for loop first if #####' + lostTypeData.Code__c + '2nd vallllueee' + lRes.losttypecode__c);
                        tdWrap.Checked = true;
                        tdWrap.ratepercent =  lRes.Rate__c;
                        tdWrap.indexval = indexsize++;
                        tdWrap.detail = lRes.LOST_DETAIL__c;
                        tdWrap.recordId = lRes.Id;
                        tdWrap.Apporvestatus = lRes.ApproveStatus__c;
                        
                        
                        if(korlang == false){
                            tdWrap.lvl1Record = lostTypeData.Level1_Type_Eng__c;
                            tdWrap.lvl2Record = lostTypeData.Level2_Type_Eng__c;
                            tdWrap.lvl3Record = lostTypeData.Type_Eng__c;
                            tdWrap.lvl2Recordlst = lvl2Recordlisteng;
                            tdWrap.lvl3Recordlst = lvl3Recordlisteng; 
                            
                        }
                        else {
                            tdWrap.lvl1Record = lostTypeData.Level1_Type_Kor__c;
                            tdWrap.lvl2Record = lostTypeData.Level2_Type_Kor__c;
                            tdWrap.lvl3Record = lostTypeData.Type_Kor__c;
                            tdWrap.lvl2Recordlst = lvl2Recordlistkor;
                            tdWrap.lvl3Recordlst = lvl3Recordlistkor; 
                        }
                    }
                    
                    
                }
                
                tdWrapList.add(tdWrap);
                
            }
            /**  else {
system.debug('Enter in to the else -->');
tdWrap.isChecked = false;
tdWrap.precompval =  '';
tdWrap.rsltaftrbidval = '';
tdWrap.ratepercent =  0;
tdWrapList.add(tdWrap); 
} **/
            
        }
        system.debug('the wrap list size -->'+tdWrapList.size());
        return tdWrapList;
        //End V 1.1 @rakshit.s@samsung.com Dynamic CheckBox Function 
    }
    
    @AuraEnabled
    public static List<tableDataWrap1> getLostResultRec(Id OppId,Boolean korlang, String lostdroptype,String oppcActid){
        
        List<tableDataWrap1> tdWraplist = new List<tableDataWrap1>();
        system.debug('getOppId'+OppId);
        //V 1.3
        List<LostResult__c> lostRes = [Select id,losttypecode__c,Master_LostType__r.Level1_Type_Eng__c,Master_LostType__r.Level1_Type_Kor__c,
                                       Master_LostType__r.Level2_Type_Eng__c, Master_LostType__r.Level2_Type_Kor__c,Master_LostType__r.Type_Eng__c,Master_LostType__r.Type_Kor__c        
                                       from LostResult__c  where Opportunity__c =:OppId AND LostActivity__c =:oppcActid AND IsCheck__c = true AND Master_LostType__r.Lost_Drop_Type__c =:lostdroptype ORDER BY CreatedDate];
       
        if(lostRes.size() > 0){
        for(LostResult__c lrs: lostRes){
            tableDataWrap1 tdWrap = new tableDataWrap1();
            Set<String> lvl2Recordlsteng = new  Set<String>();
            Set<String> lvl2Recordlstkor = new  Set<String>();
            Set<String> lvl3Recordlsteng = new  Set<String>();
            Set<String> lvl3Recordlstkor = new  Set<String>();
            List<Master_LostType__c> lstmstrlost = [select Level2_Type_Kor__c,Level2_Type_Eng__c,Type_Eng__c,Type_Kor__c from Master_LostType__c where Level1_Type_Eng__c=: lrs.Master_LostType__r.Level1_Type_Eng__c];
            List<Master_LostType__c> lstmstrlost1 = [select Level2_Type_Kor__c,Level2_Type_Eng__c,Type_Eng__c,Type_Kor__c from Master_LostType__c where Level2_Type_Eng__c=: lrs.Master_LostType__r.Level2_Type_Eng__c];
            if(lstmstrlost.size() > 0){
                for(Master_LostType__c mslst : lstmstrlost){
                    lvl2Recordlsteng.add(mslst.Level2_Type_Eng__c);
                    lvl2Recordlstkor.add(mslst.Level2_Type_Kor__c);
                } 
            }
            if(lstmstrlost1.size() > 0){
                for(Master_LostType__c mslst : lstmstrlost1){
                    lvl3Recordlsteng.add(mslst.Type_Eng__c);  
                    lvl3Recordlstkor.add(mslst.Type_Kor__c);  
                }
            }
            List<String> lvl2Recordlisteng = new  List<String>();
            List<String> lvl2Recordlistkor = new  List<String>();
            List<String> lvl3Recordlisteng = new  List<String>();
            List<String> lvl3Recordlistkor = new  List<String>();
            
            lvl2Recordlisteng.addAll(lvl2Recordlsteng);
            lvl2Recordlistkor.addAll(lvl2Recordlstkor);
            lvl3Recordlisteng.addAll(lvl3Recordlsteng);
            lvl3Recordlistkor.addAll(lvl3Recordlstkor);
            
            if(korlang == true){
                tdWrap.lvl1Record = lrs.Master_LostType__r.Level1_Type_Kor__c;
                tdWrap.lvl2Record = lrs.Master_LostType__r.Level2_Type_Kor__c;
                tdWrap.lvl3Record = lrs.Master_LostType__r.Type_Kor__c;  
                tdWrap.lvl2Recordlst = lvl2Recordlistkor;
                tdWrap.lvl3Recordlst = lvl3Recordlistkor; 
            }
            else {
                tdWrap.lvl1Record = lrs.Master_LostType__r.Level1_Type_Eng__c;
                tdWrap.lvl2Record = lrs.Master_LostType__r.Level2_Type_Eng__c;
                tdWrap.lvl3Record = lrs.Master_LostType__r.Type_Eng__c;
                tdWrap.lvl2Recordlst = lvl2Recordlisteng;
                tdWrap.lvl3Recordlst = lvl3Recordlisteng; 
            }
            tdWrap.Checked = true;
            tdWrap.detailResn='';
            tdWrap.imprvResn='';
            tdWrap.cId =lrs.Id;
            
            tdWraplist.add(tdWrap);
        }
        }
        
        system.debug('tdWraplistval'+tdWraplist);
        return tdWraplist;
    }
    
    
    
    @AuraEnabled
    public static List<tableDataWrap1> getcounterMeasure(Id OppId, Boolean korlang, Id oppActid){
          Opportunity_Activity__c opact =[select id,Status__c,LostType__c from Opportunity_Activity__c where Id =: oppActid];
        String lostdroptype;
        if(opact.LostType__c == 'Z06'){
        lostdroptype = 'Lost';
        }
        if(opact.LostType__c == 'Z07'){
          lostdroptype = 'Drop';
 
        }
          List<Lost_Countermeasure__c> countmsrlist = new List<Lost_Countermeasure__c>();
        /* lostactionlist =[select ActionItem_InChargeDept__c,ActionItem_RelavantDept__c,ActionItem__c,Countermeasure__r.DetailReason__c,Countermeasure__r.Improvement__c,
Countermeasure__r.Master_LostType__r.Type_Kor__c,Countermeasure__r.Master_LostType__r.Type_Eng__c,Countermeasure__r.Master_LostType__r.Level1_Type_Eng__c,
Countermeasure__r.Master_LostType__r.Level1_Type_Kor__c,Countermeasure__r.Master_LostType__r.Level2_Type_Eng__c,Countermeasure__r.Master_LostType__r.Level2_Type_Kor__c from LostActionItem__c where Opportunity__c =:OppId]; */
        //V 1.4
        countmsrlist =[select id,Action_Item__c,Countermeasures__c,Managing_Department__c,Deadline__c,Master_LostType__r.Type_Kor__c,Master_LostType__r.Type_Eng__c,Master_LostType__r.Level1_Type_Kor__c,
                       Master_LostType__r.Level1_Type_Eng__c,Master_LostType__r.Level2_Type_Kor__c,Master_LostType__r.Level2_Type_Eng__c,Master_LostType__r.Use__c
                       from Lost_Countermeasure__c where Opportunity__c =:OppId AND LostActivity__c =:oppActid AND Master_LostType__r.Lost_Drop_Type__c =: lostdroptype ORDER BY CreatedDate];
        
        
        List<tableDataWrap1> tdWraplist = new List<tableDataWrap1>();
        
        if(countmsrlist.size() > 0) {
            
            for(Lost_Countermeasure__c lstcount: countmsrlist) {
                Set<String> lvl2Recordlsteng = new  Set<String>();
                Set<String> lvl2Recordlstkor = new  Set<String>();
                Set<String> lvl3Recordlsteng = new  Set<String>();
                Set<String> lvl3Recordlstkor = new  Set<String>();
                List<Master_LostType__c> lstmstrlost = [select Level2_Type_Kor__c,Level2_Type_Eng__c,Type_Eng__c,Type_Kor__c from Master_LostType__c where Level1_Type_Eng__c=: lstcount.Master_LostType__r.Level1_Type_Eng__c AND Lost_Drop_Type__c =: lostdroptype];
                List<Master_LostType__c> lstmstrlost1 = [select Level2_Type_Kor__c,Level2_Type_Eng__c,Type_Eng__c,Type_Kor__c from Master_LostType__c where Level2_Type_Eng__c=: lstcount.Master_LostType__r.Level2_Type_Eng__c AND Lost_Drop_Type__c =: lostdroptype];
                if(lstmstrlost.size() > 0){
                    for(Master_LostType__c mslst : lstmstrlost){
                        lvl2Recordlsteng.add(mslst.Level2_Type_Eng__c);
                        lvl2Recordlstkor.add(mslst.Level2_Type_Kor__c);
                    } 
                }
                if(lstmstrlost1.size() > 0){
                    for(Master_LostType__c mslst : lstmstrlost1){
                        lvl3Recordlsteng.add(mslst.Type_Eng__c);  
                        lvl3Recordlstkor.add(mslst.Type_Kor__c);  
                    }
                }
                List<String> lvl2Recordlisteng = new  List<String>();
                List<String> lvl2Recordlistkor = new  List<String>();
                List<String> lvl3Recordlisteng = new  List<String>();
                List<String> lvl3Recordlistkor = new  List<String>();
                
                lvl2Recordlisteng.addAll(lvl2Recordlsteng);
                lvl2Recordlistkor.addAll(lvl2Recordlstkor);
                lvl3Recordlisteng.addAll(lvl3Recordlsteng);
                lvl3Recordlistkor.addAll(lvl3Recordlstkor);
                
                tableDataWrap1 tdWrap = new tableDataWrap1();
                if(korlang == false){
                    tdWrap.lvl1Record = lstcount.Master_LostType__r.Level1_Type_Eng__c;
                    tdWrap.lvl2Record = lstcount.Master_LostType__r.Level2_Type_Eng__c;
                    tdWrap.lvl3Record = lstcount.Master_LostType__r.Type_Eng__c;
                    tdWrap.lvl2Recordlst = lvl2Recordlisteng;
                    tdWrap.lvl3Recordlst = lvl3Recordlisteng; 
                    
                    
                }
                else {
                    tdWrap.lvl1Record = lstcount.Master_LostType__r.Level1_Type_Kor__c;
                    tdWrap.lvl2Record = lstcount.Master_LostType__r.Level2_Type_Kor__c;
                    tdWrap.lvl3Record = lstcount.Master_LostType__r.Type_Kor__c;  
                    tdWrap.lvl2Recordlst = lvl2Recordlistkor;
                    tdWrap.lvl3Recordlst = lvl3Recordlistkor; 
                }
                tdWrap.Checked = true;
                tdWrap.actionItem=lstcount.Action_Item__c;
                tdWrap.countermeasure=lstcount.Countermeasures__c;
                tdWrap.mangdeptcode=lstcount.Managing_Department__c;
                tdWrap.deadline=lstcount.Deadline__c;
                tdWrap.cId =lstcount.Id;
              
                tdWraplist.add(tdWrap);
            }
        }
        
        return tdWraplist;
        
    }
    
    @AuraEnabled
    public static List<String> insertLostresult(String inpVal,String Oppid,String oppActivityid,Boolean korlang,String lostdroptype){
        system.debug('inpVal**' + inpval);
        List<Object> masterList = new  List<Object>();
        /**  if(Test.isRunningTest()){
String inpval1 ='[{"Apporvestatus":"Completed","Checked":true,"indexval":1,"lvl1Record":"Execution","lvl2Record":"Execution Ready","lvl2Recordlst":[{"label":"Execution Ready","value":"Execution Ready"},{"label":"Proposal","value":"Proposal"}],"lvl3Record":"Biz Experience/Competency","lvl3Recordlst":[{"label":"Biz Experience/Competency","value":"Biz Experience/Competency"},{"label":"PM/Manpower/Partner","value":"PM/Manpower/Partner"}],"precompval":"test233","ratepercent":100,"recordId":"a1f1s000001GORfAAO","rsltaftrbidval":"trrd","isChecked":true,"lv1disable":true,"lv2disable":true,"lv3disable":true,"isdeleted":false,"variant":"brand"}]';

masterList = (List<Object>)JSON.deserializeUntyped(inpval1);
} **/
        masterList = (List<Object>)JSON.deserializeUntyped(inpVal);
        
        
        Map<String,LostResult__c> lresultmap = new Map<String,LostResult__c>();
        List<LostResult__c> lresultquery = [select id, LostTypeCode__c  from LostResult__c where Opportunity__c =: Oppid AND LostActivity__c =: oppActivityid];
        List<Master_LostType__c> losttypelist = [select id,code__c,Type_Kor__c,Type_Eng__c from Master_LostType__c where Lost_Drop_Type__c=: lostdroptype];
        Map<String,String> maplostcode = new Map<String,String>();
        Map<String,Master_LostType__c> maplostcode1 = new Map<String,Master_LostType__c>();
        
        for(Master_LostType__c ml1 : losttypelist){
            if(korlang == true){
                maplostcode.put(ml1.Type_Kor__c, ml1.code__c);
            }
            else {
                maplostcode.put(ml1.Type_Eng__c, ml1.code__c);
                
            }
            maplostcode1.put(ml1.code__c, ml1);
        }
        for(LostResult__c lr1 :lresultquery ){
            //lresultmap.put(lr1.LostTypeCode__c,lr1);
            lresultmap.put(lr1.Id,lr1);
        }
        List<LostResult__c> lresult = new List<LostResult__c>();
        string rcid = Oppid;
        List<String> lstcode = new List<String>();
        List<String> lstrcdidlist = new List<String>();

        system.debug('the rcid-->'+Oppid);
        
        for(Object m1: masterList){
            Map<String,Object> data = (Map<String,Object>)m1;
            system.debug('the all data-->'+data);
            String lvl3name = (String)data.get('lvl3Record');  
            String lostcode = maplostcode.get(lvl3name);
            String recdid = (String)data.get('recordId'); 
            lstcode.add(lostcode);
            lstrcdidlist.add(recdid);
            if(lresultmap.containsKey(recdid))   {  
                LostResult__c lrs = lresultmap.get(recdid);
                lrs.LostTypeCode__c= lostcode;  
                lrs.Opportunity__c = Oppid;
                //lrs.LostActivity__c =oppActivityid;
                system.debug('detailval-->'+(String)data.get('detail'));
                lrs.LOST_DETAIL__c = (String)data.get('detail');
                lrs.Rate__c =  Integer.valueOf(data.get('ratepercent'));
                lrs.MasterLosttype_Eng__c = maplostcode1.get(lostcode).Type_Eng__c;
                lrs.MasterLosttype_Kor__c = maplostcode1.get(lostcode).Type_Kor__c;
                lrs.Master_LostType__c = maplostcode1.get(lostcode).Id;
                lrs.IsCheck__c = true;
                system.debug('lostdetail'+lrs.LOST_DETAIL__c );
                lresult.add(lrs);
               }
            else {
                LostResult__c lrs = new LostResult__c();
                lrs.LostTypeCode__c= lostcode;  
                lrs.Opportunity__c = Oppid;
                lrs.LostActivity__c =oppActivityid;
                lrs.LOST_DETAIL__c = (String)data.get('detail');
                lrs.Rate__c =  Integer.valueOf(data.get('ratepercent'));
                system.debug('Rate val');
                lrs.MasterLosttype_Eng__c = maplostcode1.get(lostcode).Type_Eng__c;
                lrs.MasterLosttype_Kor__c = maplostcode1.get(lostcode).Type_Kor__c;
                lrs.Master_LostType__c = maplostcode1.get(lostcode).Id;
                lrs.IsCheck__c = true;
                lresult.add(lrs);
            }
        }
        List<LostResult__c> deletelostlist =[select id, LostTypeCode__c  from LostResult__c where Opportunity__c =: Oppid AND Id NOT IN:lstrcdidlist];
        if(deletelostlist.size() > 0){
        delete deletelostlist; 
        }
        if(lresult.size() > 0){
        upsert lresult;
            system.debug('afterupsert lresult'+lresult);
        }
        /**V1.1 START Added By Kajal- IF-159 calling  **/
        Set<ID> idSet = new Set<ID>();
        List<Opportunity_Activity__c> oActList = [Select id,WhatId__c from Opportunity_Activity__c where WhatId__c =: Oppid 
                                                  AND (TransactionName__c = 'ZPZ1' OR TransactionName__c = 'ZPZ2')  And  Status__c = 'Completed'];
        if(oActList.size() > 0){
            for(Opportunity_Activity__c oAct : oActList){
                idSet.add(oAct.WhatId__c);
            }
        }
        if(idSet.size() > 0){
            IF_LostAnalysisCallOutAPIController infoCallout159IF = new IF_LostAnalysisCallOutAPIController(idSet);
            System.enqueueJob(infoCallout159IF);
        }
        /**V1.1 END **/
        return  lstcode;
    }
    
    @AuraEnabled
    public static List<String> insertCounterMeasure(String inpVal,String Oppid,String oppActivityid,Boolean korlang,String lostdroptype){
        system.debug('inpVal**' + inpval);
        List<Object> masterList = (List<Object>)JSON.deserializeUntyped(inpVal);
        system.debug('masterList**' + masterList);
        Map<String,Lost_Countermeasure__c> lresultmap = new Map<String,Lost_Countermeasure__c>();
        Map<String,String> maplostcode = new Map<String,String>();
        Map<String,Master_LostType__c> maplostcode1 = new Map<String,Master_LostType__c>();
        List<String> lstactiondelname = new List<String>();
        List<Lost_Countermeasure__c> lcountermsr = new List<Lost_Countermeasure__c>();
        string rcid = Oppid;
        List<String> lstcode = new List<String>();
        CostCenter__c ctc = new CostCenter__c();
        List<String> countrmsrId = new List<String>();

        
        List<Lost_Countermeasure__c> lresultquery = [select id,Action_Item__c,Countermeasures__c,Deadline__c,Master_LostType__c,Master_Lost_Type_Code__c
                                                     from Lost_Countermeasure__c where Opportunity__c =: Oppid AND LostActivity__c =: oppActivityid];
        system.debug('checktest'+lresultquery);
        List<Master_LostType__c> losttypelist = [select Id,code__c,Type_Kor__c,Type_Eng__c from Master_LostType__c where Lost_Drop_Type__c=: lostdroptype];

        for(Master_LostType__c ml1 : losttypelist){
            if(korlang == true){
                maplostcode.put(ml1.Type_Kor__c, ml1.code__c);
            }
            else {
                maplostcode.put(ml1.Type_Eng__c, ml1.code__c);
                
            }
            maplostcode1.put(ml1.code__c, ml1);
        }
        for(Lost_Countermeasure__c lr1 :lresultquery ){
            lresultmap.put(lr1.Id,lr1);
        }
        
        system.debug('the rcid-->'+Oppid);
        
        for(Object m1: masterList){
            Map<String,Object> data = (Map<String,Object>)m1;
            system.debug('the all data-->'+data);
            String lvl3name = (String)data.get('lvl3Record');  
            String lostcode = maplostcode.get(lvl3name);
            String Countrid = (String)data.get('cid');
             countrmsrId.add(Countrid);

            lstcode.add(lostcode);
            if(lresultmap.containsKey(Countrid))  {  
                Lost_Countermeasure__c lrs = lresultmap.get(Countrid);
                lrs.Master_Lost_Type_Code__c = lostcode;
                lrs.Opportunity__c = Oppid;
                lrs.LostActivity__c = oppActivityid;
                lrs.Action_Item__c	= (String)data.get('actionItem');
                lrs.Countermeasures__c	 = (String)data.get('countermeasure');
                lrs.Master_LostType__c = maplostcode1.get(lostcode).Id;
                String deadlinedate = (String)data.get('deadline');
                   date blankdate;
                  if(deadlinedate == '' || deadlinedate == Null){
                            lrs.Deadline__c = blankdate;
                            
                        }
                        else{
                            lrs.Deadline__c = date.valueOf(deadlinedate);
                        }
                        String Managdept = (String)data.get('mangdeptcode');
                        if(Managdept !=  '' && Managdept != null){
                            lrs.Managing_Department__c = Managdept;
                        }
                        else {
                            lrs.Managing_Department__c = ctc.Id; 
                        }
                lcountermsr.add(lrs);
                
            }
            else {
                Lost_Countermeasure__c lrs = new Lost_Countermeasure__c();
                lrs.Master_Lost_Type_Code__c= lostcode;  
                lrs.Opportunity__c = Oppid;
                lrs.LostActivity__c = oppActivityid;
                 lrs.Action_Item__c	= (String)data.get('actionItem');
                lrs.Countermeasures__c	 = (String)data.get('countermeasure');
                lrs.Master_LostType__c = maplostcode1.get(lostcode).Id;
                String deadlinedate = (String)data.get('deadline');
                   date blankdate;
                  if(deadlinedate == '' || deadlinedate == Null){
                            lrs.Deadline__c = blankdate;
                            
                        }
                        else{
                            lrs.Deadline__c = date.valueOf(deadlinedate);
                        }
                        String Managdept = (String)data.get('mangdeptcode');
                        if(Managdept !=  '' && Managdept != null){
                            lrs.Managing_Department__c = Managdept;
                        }
                        else {
                            lrs.Managing_Department__c = ctc.Id; 
                        }
                lcountermsr.add(lrs);
              //  insert lrs;
               // countrmsrId.add(lrs.Id);
                System.debug('new list counter'+lrs);
              
            }
        }
        
        List<Lost_Countermeasure__c> deletecounrlist =[select id, Master_Lost_Type_Code__c  from Lost_Countermeasure__c where Opportunity__c =: Oppid AND Id NOT IN:countrmsrId];
        
        if(deletecounrlist.size() > 0){
            delete deletecounrlist;
        }
        
        if(lcountermsr.size() > 0){
            upsert lcountermsr;
        }
        
        
        /**V1.1 START Added By Kajal- IF-159 calling  **/
        Set<ID> idSet = new Set<ID>();
        List<Opportunity_Activity__c> oActList = [Select id,WhatId__c from Opportunity_Activity__c where WhatId__c =: Oppid 
                                                  AND (TransactionName__c = 'ZPZ1' OR TransactionName__c = 'ZPZ2')  And  Status__c = 'Completed'];
        if(oActList.size() > 0){
            for(Opportunity_Activity__c oAct : oActList){
                idSet.add(oAct.WhatId__c);
            }
        }
        if(idSet.size() > 0){
            IF_LostAnalysisCallOutAPIController infoCallout159IF = new IF_LostAnalysisCallOutAPIController(idSet);
            System.enqueueJob(infoCallout159IF);
        }
        return  lstcode;  
    } 
    /**V1.1 END **/
    
    //added by @rakshit.s@samsung.com
    //date: 04-20-2023
    //Logic to check if it is a Lost or Drop scenario.
    @AuraEnabled
    public static boolean checkIfLostOrDropOnLoad(String recId){
       return MasterLostTypeDataController.isLostOrDrop('', recId);
        
    }
     //START 1.3
     @AuraEnabled
     public static String copyAnalysisLevelValue(String OppId,String OppactId){
         List<Lost_Countermeasure__c> lostcounter = new List<Lost_Countermeasure__c>();
         lostcounter = [select id from Lost_Countermeasure__c where Opportunity__c =:OppId AND Opportunity__r.Post_Moterm_Type__c= true AND LostActivity__c =:OppactId];
         String retunrnVal;
         if(lostcounter.size() > 0){
            retunrnVal ='NotCopyAnalysis';
         }
         else {
              retunrnVal ='CopyAnalysis';

         }
         return retunrnVal;    
    }
     // END 1.3
    
    public class tableDataWrap{
        
        /**  @AuraEnabled
Public Master_LostType__c masterList = new Master_LostType__c(); **/
        
        @AuraEnabled
        public String lvl1Record;
        
        //   @AuraEnabled
        // public SelectRecord lvl2Record {get; set;}
        @AuraEnabled
        public String lvl2Record;
        
        @AuraEnabled
        public String lvl3Record;
        
        @AuraEnabled
        public boolean Checked;
        

        
        @AuraEnabled
        public string detail;
        

        
        @AuraEnabled
        public Decimal ratepercent;
        
        @AuraEnabled
        public Decimal indexval;
        
        @AuraEnabled
        public String recordId;  
        
        @AuraEnabled
        public String Apporvestatus; 
        
        @AuraEnabled
        public List<String> lvl2Recordlst;  
        
        @AuraEnabled
        public List<String> lvl3Recordlst;  
    }
    
    public class tableDataWrap1{
        
        @AuraEnabled
        public String lvl1Record;
        
        @AuraEnabled
        public String cId;
        
        @AuraEnabled
        public String lvl2Record;
        
        @AuraEnabled
        public String lvl3Record;
        
        @AuraEnabled
        public boolean Checked;
        
        @AuraEnabled
        public string detailResn;
        
        @AuraEnabled
        public string imprvResn;
        
        @AuraEnabled
        public string actionItem;
        
        @AuraEnabled
        public string countermeasure;  
  
        @AuraEnabled
        public string mangdeptcode;  
 
        @AuraEnabled
        public Date deadline; 
        
        
        @AuraEnabled
        public List<String> lvl2Recordlst;  
        
        @AuraEnabled
        public List<String> lvl3Recordlst;  
        
        
    }
    public class SelectRecord{
        @AuraEnabled
        public String Code {get; set;}
        @AuraEnabled
        public String Name {get; set;}
    }
    
}