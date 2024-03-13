/**
 * @description       : 
 * @author            : chae_ho.yang@samsung.com
 * @group             : 
 * @last modified on  : 07-28-2023
 * 
 * @last modified by  : chae_ho.yang@samsung.com
**/
global class Batch_weeklySalesHeap_Test implements DataBase.Batchable<SObject>, DataBase.AllowsCallouts, Schedulable {
    private static Boolean isSandbox = Utils.getIsSandbox();
    private List<IF_Log.InterfaceLog> ifLog = new List<IF_Log.InterfaceLog>();
    public static Map<String,Object> mailresult = new Map<String,Object>(); 
    private List<KnoxEmail__c> KnoxEmailList = new List<KnoxEmail__c>();
    private List<Id> listOpptyId = new List<Id>();
    private static List<IF_Log__c> listOpptyId1 = new List<IF_Log__c>();
    private  Map<id, set<id>> OpptyMatchingMap = new Map<id, set<id>>();
    private  Map<Id,Opportunity> matchedoppLst;
    
    //System.debug('ani finale');
    
    private static Boolean bTest = false;  //운영 테스트를 위한 Flag 값;
    
    //T110,T120,T140,T640,T641,L1B0,L1E0,ZB01,ZB10
    private static Set<String> setSubsidiary = new Set<String>(System.Label.OPPTYACT_BO_SUBSIDIARY_LIST.split(','));  //자회사는 대상에서 제외
    
    //발송 제한된 이메일
    private static List<String> listRestrictedEmail = new List<String>{'mysales@samsung.com'};
        
        public Batch_weeklySalesHeap_Test(){
            
        }
    
    /*public Batch_WeeklySalesReport(Boolean isMigData){
if(isMigData){
List<MigOppCode__c> migOppCdList = [
SELECT Id 
,Name                 // ID
,OpportunityCode__c
FROM   MigOppCode__c
WHERE  Systemmodstamp = today
AND    Send_Check__c  = false
AND    InterfaceId__c = 'IF-075'
];

Set<String> oppCdSet = new Set<String>();
for( MigOppCode__c migOpp : migOppCdList){            
listOpptyId.add(migOpp.Name);
}
}        
}*/
    
    public DataBase.QueryLocator start(Database.BatchableContext BC){
        System.debug('### Batch_WeeklySalesReport :: start');
        
        List<User> usr = new List<User>();
        Set<Id> usrId = new Set<Id>();
        DateTime dt = DateTime.now().addDays(-7);
        Map<Id,List<Opportunity>> mIOpp = new Map<Id,List<Opportunity>>();
        /*Uncommented Ashish*///and id = '0051s000003VUcAAAW'  Profile.Name = 'Sales Rep.(HQ)'
        usr = [select Id,Email,Name from User where  id = '0051s000003VUcAAAW' AND IsActive = true];
        for(User user : usr){
            usrId.add(user.Id); 
        }
        Map<id,Opportunity> oppList = new Map<id,Opportunity>([Select Id , OriginAcc_BizTypeL1__c , OriginAcc_BizTypeL2__c , BusinessLevel__c , Createdby.Id From Opportunity where 
                                                               Createdby.Id IN : usrId and BO1stRegistrationDate__c >= : dt]);
        system.debug('ashish  oppList'+oppList);
        Set<String> opptybiz1IdSet = new Set<String>();
        Set<String> opptybiz2IdSet = new Set<String>();
        Set<String> opptybussLabelIdSet = new Set<String>();
        //Set<id> oppIds = new set<id>();
        
        for(Id id : usrId){
            List<Opportunity> oppLst = new List<Opportunity>();
            for(String s : oppList.keyset()){
                Opportunity opp = oppList.get(s);
                //          oppIds.add(opp.id);
                if(opp.OriginAcc_BizTypeL1__c != null)
                    opptybiz1IdSet.add(opp.OriginAcc_BizTypeL1__c);
                if(opp.OriginAcc_BizTypeL2__c != null)
                    opptybiz2IdSet.add(opp.OriginAcc_BizTypeL2__c);
                if(opp.BusinessLevel__c != null)
                    opptybussLabelIdSet.add(opp.BusinessLevel__c);
                if(opp.Createdby.Id == id){
                    oppLst.add(opp); 
                }
            }
            mIOpp.put(id, oppLst);
        }
        Map<id,Set<String>> opptyServiceMap = new Map<id,Set<String>>();
        Map<id,Set<String>> opptySolMap = new Map<id,Set<String>>();
        Set<id> opptySerIdSet = new Set<id>();
        Set<id> opptySolIdSet = new Set<id>();
        /*List<Service__c> svcNew =  new List<Service__c>();
svcNew = [SELECT Id , Name ,sService__r.Name, sService__r.TechAttribute__c , Opportunity__c, 
( SELECT Id , Name , Service__c , sSolution__r.Name
FROM Solution__r
WHERE sDeletionFlag__c = false
ORDER BY sSolution__r.Name ASC
)
FROM Service__c
WHERE Opportunity__c IN : oppIds  AND sDeletionFlag__c = false  ORDER BY sService__r.Name ASC];*/
        for(Service__c serObj:[SELECT Id , Name ,sService__r.Name, sService__r.TechAttribute__c , Opportunity__c
                               FROM Service__c
                               WHERE Opportunity__c IN : oppList.keyset()  AND sDeletionFlag__c = false  ORDER BY sService__r.Name ASC]){
                                   opptySerIdSet.add(serObj.Id);
                                   if(opptyServiceMap.containskey(serObj.Opportunity__c)) {
                                       set<String> servName = opptyServiceMap.get(serObj.Opportunity__c);
                                       servName.add(serObj.sService__r.Name);
                                       opptyServiceMap.put(serObj.Opportunity__c,servName);
                                   }
                                   else{
                                       set<String> servName = new Set<String>();
                                       servName.add(serObj.sService__r.Name);
                                       opptyServiceMap.put(serObj.Opportunity__c,servName);
                                   }
                               } 
        /*
List<Solution__c> solNew =  new List<Solution__c>();
solNew = [ SELECT Id , Name , Service__c , sSolution__r.Name,Opportunity__c
FROM Solution__c
WHERE Opportunity__c in: oppIds AND sDeletionFlag__c = false
ORDER BY sSolution__r.Name ASC
];*/
        for(Solution__c serObj:[ SELECT Id , Name , Service__c , sSolution__r.Name,Opportunity__c
                                FROM Solution__c
                                WHERE Opportunity__c in: oppList.keyset() AND sDeletionFlag__c = false
                                ORDER BY sSolution__r.Name ASC
                               ]){
                                   opptySolIdSet.add(serObj.id);
                                   if(opptySolMap.containskey(serObj.Opportunity__c)) {
                                       set<String> servName = opptySolMap.get(serObj.Opportunity__c);
                                       servName.add(serObj.sSolution__r.Name);
                                       opptySolMap.put(serObj.Opportunity__c,servName);
                                   }
                                   else{
                                       set<String> servName = new Set<String>();
                                       servName.add(serObj.sSolution__r.Name);
                                       opptySolMap.put(serObj.Opportunity__c,servName);
                                   }
                               }
        //Map<id, set<id>> OpptyMatchingMap = new Map<id, set<id>>() ;
        matchedoppLst = new Map<Id,Opportunity>([Select Id,ProposalPM__c,RepresentativePM__c,OriginAcc_BizTypeL1__c,OriginAcc_BizTypeL2__c,BusinessLevel__c,name,closedate,amount,StageName,toLabel(StageName) toLabel_StageName From Opportunity where RecordType.Name = 'HQ' and CompanyCode__c = 'T100' and OriginAcc_BizTypeL1__c in:opptybiz1IdSet  AND OriginAcc_BizTypeL2__c in:opptybiz2IdSet  AND BusinessLevel__c in:opptybussLabelIdSet and id in (SELECT opportunity__c from service__c where id in :opptySerIdSet) and id in (SELECT opportunity__c from solution__c where id in :opptySolIdSet) LIMIT 50000]);
        system.debug(' ashish matchedoppLst'+matchedoppLst);
        /*List<Service__c> svcNew1 =  new List<Service__c>();
svcNew1 = [SELECT Id , Name ,sService__r.Name, sService__r.TechAttribute__c , Opportunity__c, 
( SELECT Id , Name , Service__c , sSolution__r.Name
FROM Solution__r
WHERE sDeletionFlag__c = false
ORDER BY sSolution__r.Name ASC
)
FROM Service__c
WHERE Opportunity__c IN : matchedoppLst.keyset()  AND sDeletionFlag__c = false  ORDER BY sService__r.Name ASC];*/
        for(Service__c serObj:[SELECT Id , Name ,sService__r.Name, sService__r.TechAttribute__c , Opportunity__c
                               
                               FROM Service__c
                               WHERE Opportunity__c IN : matchedoppLst.keyset()  AND sDeletionFlag__c = false  ORDER BY sService__r.Name ASC]){
                                   opptySerIdSet.add(serObj.Id);
                                   if(opptyServiceMap.containskey(serObj.Opportunity__c)) {
                                       set<String> servName = opptyServiceMap.get(serObj.Opportunity__c);
                                       servName.add(serObj.sService__r.Name);
                                       opptyServiceMap.put(serObj.Opportunity__c,servName);
                                   }
                                   else{
                                       set<String> servName = new Set<String>();
                                       servName.add(serObj.sService__r.Name);
                                       opptyServiceMap.put(serObj.Opportunity__c,servName);
                                   }
                               }
        //    system.debug('ashish opptyServiceMap'+opptyServiceMap);
        for(Solution__c serObj:[ SELECT Id , Name , Service__c , sSolution__r.Name,Opportunity__c
                                FROM Solution__c
                                WHERE Opportunity__c in: matchedoppLst.keyset() AND sDeletionFlag__c = false
                                ORDER BY sSolution__r.Name ASC
                               ]){
                                   opptySolIdSet.add(serObj.id);
                                   if(opptySolMap.containskey(serObj.Opportunity__c)) {
                                       set<String> servName = opptySolMap.get(serObj.Opportunity__c);
                                       servName.add(serObj.sSolution__r.Name);
                                       opptySolMap.put(serObj.Opportunity__c,servName);
                                   }
                                   else{
                                       set<String> servName = new Set<String>();
                                       servName.add(serObj.sSolution__r.Name);
                                       opptySolMap.put(serObj.Opportunity__c,servName);
                                   }
                               }
        
        
        for(id myoppId : oppList.keyset()){
            opportunity oppObj = oppList.get(myoppId);
            set<String> oppservSet = opptyServiceMap.get(myoppId);
            set<String> oppsolSet = opptySolMap.get(myoppId);
            for(id mymatchedoppId : matchedoppLst.keyset()){
                opportunity matchedoppObj = matchedoppLst.get(mymatchedoppId);
                boolean servMatched = false;
                boolean solMatched = false;
                set<String> oppservSet1 = opptyServiceMap.get(mymatchedoppId);
                for(String s : oppservSet1){ if(oppservSet.contains(s)) servMatched = true; break;}
                set<String> oppsolSet1 = opptySolMap.get(mymatchedoppId);
                for(String s : oppsolSet1){ if(oppsolSet.contains(s)) solMatched = true; break;}
                
                if(oppObj.Id != matchedoppObj.Id && oppObj.OriginAcc_BizTypeL1__c == matchedoppObj.OriginAcc_BizTypeL1__c && oppObj.OriginAcc_BizTypeL2__c == matchedoppObj.OriginAcc_BizTypeL2__c && oppObj.BusinessLevel__c == matchedoppObj.BusinessLevel__c && servMatched && solMatched)
                    if(OpptyMatchingMap.containsKey(myoppId)){
                        Set<id> matchOpSet = OpptyMatchingMap.get(myoppId);
                        matchOpSet.add(mymatchedoppId);
                        OpptyMatchingMap.put(myoppId,matchOpSet);
                    }else{
                        Set<id> matchOpSet = new set<id>();
                        matchOpSet.add(mymatchedoppId);
                        OpptyMatchingMap.put(myoppId,matchOpSet);
                    }
            }
        }
        system.debug('ashish OpptyMatchingMap'+OpptyMatchingMap);
        
        /*ashish uncommented*/
        /*usr = [select Id,Email,Name from User where Profile.Name = 'Sales Rep.(HQ)' AND IsActive = true];
for(User user : usr){
usrId.add(user.Id); 
}

oppList = [Select Id , OriginAcc_BizTypeL1__c , OriginAcc_BizTypeL2__c , BusinessLevel__c , Createdby.Id From Opportunity where 
Createdby.Id IN : usrId and BO1stRegistrationDate__c >= : dt];
for(Id id : usrId){
List<Opportunity> oppLst = new List<Opportunity>();
for(Opportunity opp : oppList){
if(opp.Createdby.Id == id){
oppLst.add(opp); 
}
}
mIOpp.put(id, oppLst);
}

List<Service__c> svcNew =  new List<Service__c>();
svcNew = [SELECT Id , Name ,sService__r.Name, sService__r.TechAttribute__c , Opportunity__c, 
( SELECT Id , Name , Service__c , sSolution__r.Name
FROM Solution__r
WHERE sDeletionFlag__c = false
ORDER BY sSolution__r.Name ASC
)
FROM Service__c
WHERE Opportunity__c IN : oppList  AND sDeletionFlag__c = false  ORDER BY sService__r.Name ASC];

Map<Id,Map<String,List<String>>> mSer = new Map<Id,Map<String,List<String>>>();

Map< Id, Map<Id,Map<String,List<String>>> > usrMain = new Map< Id, Map<Id,Map<String,List<String>>> >();

for(Id id1 : mIOpp.KeySet()){
for(Opportunity oppId : mIOpp.get(id1)){
Map<String,List<String>> msm1 = new Map<String,List<String>>();
for(Service__c str : svcNew){
if(str.Opportunity__c == oppId.Id ){

System.debug('ser :' +str.sService__r.Name);
List<String> ms = new List<String>();
for(Solution__c sol : str.Solution__r){
System.debug('sam :' +sol.sSolution__r.Name);
ms.add(sol.sSolution__r.Name);
}
msm1.put(str.sService__r.Name,ms);
System.debug('sam :' +msm1);
}
}
System.debug('sami :' +msm1);
mSer.put(oppId.Id , msm1);
}
usrMain.put(id1 , mSer);
}

List<Opportunity> oppLst = [Select Id,OriginAcc_BizTypeL1__c,OriginAcc_BizTypeL2__c,BusinessLevel__c From Opportunity where RecordType.Name = 'HQ' and CompanyCode__c = 'T100' LIMIT 50000];
Map<Id,List<Opportunity>> mFull = new Map<Id,List<Opportunity>>();
Map<Id,Map<Id,List<Opportunity>>> uMFull = new Map<Id,Map<Id,List<Opportunity>>>();
List<Id> oppFull = new List<Id>();
for(Id uId :usrId){
for(Opportunity Opp : oppList){
if(uId == Opp.CreatedBy.Id){
List<Opportunity> oppMatch = new List<Opportunity>();
for(Opportunity Opp1 : oppLst){
if(Opp.OriginAcc_BizTypeL1__c == Opp1.OriginAcc_BizTypeL1__c && Opp.BusinessLevel__c == Opp1.BusinessLevel__c && Opp.OriginAcc_BizTypeL2__c == Opp1.OriginAcc_BizTypeL2__c) {
oppFull.add(Opp1.Id);
oppMatch.add(Opp1);
}  
}
mFull.put(Opp.Id,oppMatch);
}
}
uMFull.put(uId , mFull);
}

Map< Id, Map<Id,Map<Id,Map<String,List<String>>>> > uMapFinal = new Map< Id, Map<Id,Map<Id,Map<String,List<String>>>> >();
Map<Id,Map<Id,Map<String,List<String>>>> mFinal = new Map<Id,Map<Id,Map<String,List<String>>>>();
List<String> lnew = new List<String>();
String sNew ;
Map<String,List<String>> mFin = new Map<String,List<String>>();

List<Service__c> svcNew1 =  new List<Service__c>();
svcNew = [SELECT Id , Name ,sService__r.Name, sService__r.TechAttribute__c , Opportunity__c, ( SELECT Id , Name , Service__c , sSolution__r.Name
FROM Solution__r
WHERE sDeletionFlag__c = false
ORDER BY sSolution__r.Name ASC
)
FROM Service__c
WHERE Opportunity__c IN : oppFull and  AND sDeletionFlag__c = false  ORDER BY sService__r.Name ASC];

for(Id usId : uMFull.keySet()){
Map<Id,List<Opportunity>> mapFull = new Map<Id,List<Opportunity>>();
mapFull = uMFull.get(usId);
for(String Id : mapFull.keySet()){
System.debug('sami@#t :' +Id);
Map<Id,Map<String,List<String>>> mId = new Map<Id,Map<String,List<String>>>();
for(Opportunity oppFin : mapFull.get(Id)){
System.debug('sami@#tl :' +oppFin);
//Map<Id,Map<String,List<String>>> mId = new Map<Id,Map<String,List<String>>>();
for(Service__c ser : svcNew1) {
if(ser.Opportunity__c == oppFin.Id){
System.debug('ser :' +ser.sService__r.Name);
List<String> ms1 = new List<String>();
for(Solution__c sol : ser.Solution__r){
System.debug('sam :' +sol.sSolution__r.Name);
ms1.add(sol.sSolution__r.Name);
}
mFin.put(ser.sService__r.Name,ms1);
System.debug('sam :' +mFin);
}
} 
mId.put(oppFin.Id,mFin);
System.debug('sama :' +mId);
}
mFinal.put(Id,mId);
System.debug('sami :' +mFinal);
}
uMapFinal.put(usId,mFinal);
} */
        
        // System.debug('### Batch_WeeklySalesReport :: start :: listUser uMapFinal = ' + uMapFinal);
        
        String queryString= '';
        Database.QueryLocator returnScope;
        //listOpptyId1 = [select Id from IF_Log__c];
        
        if(isSandbox){
            queryString += ' select Id,Email,Name from User';
            queryString += ' where  Profile.Name = id =\'0051s000003VUcAAAW\' AND IsActive = true '; //id =\'0051s000003VUcAAAW\'  Profile.Name = \'Sales Rep.(HQ)\'
        }
        else{
            
            queryString += 'Select Id , name, Profile.Name,Email from User where Name = \'박 재만\' AND IsActive = true ';
        }
        returnScope = DataBase.getQueryLocator(queryString);
        System.debug('### Batch_WeeklySalesReport :: start :: listUser size = ' + returnScope);
        
        return returnScope;
        
    }
    
    public void execute(Database.BatchableContext BC, List<User> listScope){
        
        System.debug('### Batch_OpptyEmailController :: execute :: listScope = ' + listScope);
        
        Employee__c senderEmployee = Utils.getLoginEmployeeData(UserInfo.getUserId());
        senderEmployee.EvMailAddr__c = 'chae_ho.yang@stage.samsung.com';
        if(!isSandbox){
            senderEmployee.EvMailAddr__c =   'mysales@samsung.com';
        }
        
        List<String> ccList = new List<String>();
        List<String> bccList = new List<String>();
        List<Map<String, Object>> efileList = new List<Map<String, Object>>();
        List<Map<String, String>> nfileList = new List<Map<String, String>>();
        
        
        List<String> toList = new List<String>(); 
        if(isSandbox){
            //toList = new List<String>(System.label.WEEKLY_MAIL_RECIPIENT_STAGE.split(','));
            toList.add('rakshit.s@stage.samsung.com');
            //toList.add('d.ashish@stage.samsung.com');
            //toList.add('aditya.r2@stage.samsung.com');
            //toList.add('akash.g@stage.samsung.com');
            //toList.add('vikrant.ks@stage.samsung.com');
            //toList.add('saavi.96@stage.partner.samsung.com');
        }
        if(!isSandbox){
            toList = new List<String>(System.label.WEEKLY_MAIL_RECIPIENT.split(','));
        }
        
        
        String strEmailTemp = '';
        String strEmail = '';
        EmailTemplate em = [SELECT Id,subject FROM EmailTemplate WHERE DeveloperName = 'HQ_Weekly_Sales_Report_Sales_Rep'];
        Id templateId = em.Id;
        strEmail = [SELECT HtmlValue FROM EmailTemplate WHERE Id = :templateId].HtmlValue;
        String strTitle = system.label.WEEKLY_MAIL_TITLE;
        //Id str;
        
        List<Opportunity> lstOpp = new List<Opportunity>();
        List<Opportunity> lstOpp1 = new List<Opportunity>();
        List<Opportunity> lstOpp2 = new List<Opportunity>();
        List<Opportunity> lstOpp3 = new List<Opportunity>();
        List<Opportunity> lstOpp4 = new List<Opportunity>();
        List<Opportunity> lstOpp5 = new List<Opportunity>();
        List<Opportunity> lstOpp6 = new List<Opportunity>();
        List<Opportunity> lstOpp7 = new List<Opportunity>();
        List<Opportunity> lstOpp8 = new List<Opportunity>();
        List<Opportunity> lstOpp9 = new List<Opportunity>();
        //List<Opportunity> lstOpp99 = new List<Opportunity>();
        //List<Opportunity> lstOpp999 = new List<Opportunity>();
        //Added By Ashish 
        List<Opportunity> lstOppTable4  = new List<Opportunity>();
        
        //Opportunity lstOpp = new Opportunity();
        //lstOpp = [select Id, Amount,Name,OpportunityCode__c,ZP61_PROPOSAL_SUBMIT_DATE__c,ProposalPM__c,ProposalPM__r.Name, cOriginAcc__c, cOriginAcc__r.Owner.Name,cOriginAcc__r.Name, Opportunity_Review_VRB_Type_Confirm__c,toLabel(Opportunity_Review_VRB_Type_Confirm__c) toLabel_Opportunity_Review_VRB_Type_Confirm__c,Opportunity_Review_VRB_Type__c,toLabel(Opportunity_Review_VRB_Type__c) toLabel_Opportunity_Review_VRB_Type__c, StageName,toLabel(StageName) toLabel_StageName,BO1stRegistrationDate__c,CloseDate,XP7_CONDUCT_DATE__c,XP6_CONDUCT_DATE__c, Account.mDomesticForeign__c, CMBizType__c, AccountId,Account.Owner.Name,Account.Name,OriginAcc_BizTypeL1__c,BusinessLevel__c, RecordType.Name,Type from opportunity where  OwnerId = : listScope[0].Id];
        //addedby: rakshit.s@samsung.com
		//desc: ->  new optimized query in order to avoid unnecessary for loop on line 478. 
          lstOpp = [
SELECT Id, convertCurrency(Amount), Name, OpportunityCode__c, ZP61_PROPOSAL_SUBMIT_DATE__c, ProposalPM__c, ProposalPM__r.Name, cOriginAcc__c, cOriginAcc__r.Owner.Name, cOriginAcc__r.Name, Opportunity_Review_VRB_Type_Confirm__c, toLabel(Opportunity_Review_VRB_Type_Confirm__c) toLabel_Opportunity_Review_VRB_Type_Confirm__c, Opportunity_Review_VRB_Type__c, toLabel(Opportunity_Review_VRB_Type__c) toLabel_Opportunity_Review_VRB_Type__c, StageName, toLabel(StageName) toLabel_StageName, BO1stRegistrationDate__c, CloseDate, XP7_CONDUCT_DATE__c, XP6_CONDUCT_DATE__c, Account.mDomesticForeign__c, CMBizType__c, AccountId, Account.Owner.Name, Account.Name, OriginAcc_BizTypeL1__c, BusinessLevel__c, RecordType.Name, Type  
FROM Opportunity 
WHERE ((
(StageName = 'Z01' OR StageName = 'Z02' OR StageName = 'Z03' OR StageName = 'Z04') AND 
CMBizType__c = 'CSP_SCP' AND 
CloseDate >= TODAY AND 
CloseDate <= NEXT_N_MONTHS:3
) OR 
(
(StageName = 'Z01' OR StageName = 'Z02' OR StageName = 'Z03' OR StageName = 'Z04') AND 
Account.mDomesticForeign__c = '20' AND 
CloseDate >= TODAY AND 
CloseDate <= NEXT_N_MONTHS:3
) OR 
(
XP6_CONDUCT_DATE__c > TODAY AND 
CloseDate >= TODAY AND 
CloseDate <= NEXT_N_MONTHS:2
) OR 
(
XP7_CONDUCT_DATE__c > TODAY AND 
CloseDate >= TODAY AND 
CloseDate <= NEXT_N_DAYS:14
) OR 
(
(StageName = 'Z01' OR StageName = 'Z02' OR StageName = 'Z03' OR StageName = 'Z04') AND 
CloseDate >= TODAY AND 
CloseDate <= NEXT_N_DAYS:14
) OR 
(
(StageName = 'Z01' OR StageName = 'Z02' OR StageName = 'Z03' OR StageName = 'Z04') AND 
CloseDate < TODAY
) OR 
(
(StageName = 'Z01' OR StageName = 'Z02' OR StageName = 'Z03' OR StageName = 'Z04') AND 
BO1stRegistrationDate__c != null AND 
CloseDate >= THIS_YEAR AND 
CloseDate < NEXT_YEAR
) OR 
(
(StageName = 'Z01' OR StageName = 'Z02' OR StageName = 'Z03' OR StageName = 'Z04') AND 
CloseDate >= TODAY AND 
CloseDate <= NEXT_N_MONTHS:3
)
OR
(
BO1stRegistrationDate__c !=null AND BO1stRegistrationDate__c >= LAST_N_DAYS:7
)
) AND OwnerId = : listScope[0].Id

];
        system.debug('ashish opptySize::'+ lstOpp.size());  
        system.debug('Users name for opportunity : ' +  listScope[0].Name);
        Decimal dec= 0;
        Decimal dec1= 0;
        Integer count = 1;  //Adi
        Integer subHeadingCount = 1;	//Adi
        Boolean table1;
        Boolean table2;
        Boolean table3;
        Boolean table4;
        Boolean table5;
        Boolean table6;
        Boolean table7;
        Boolean table8;
        if(lstOpp.Size()>0){
            for(Opportunity Opp : lstOpp){
                String str = '';
                str = String.valueOf(Opp.BO1stRegistrationDate__c);
                System.debug('Ani str :'+ str);
                String cntYear = String.valueOf(System.today().year());
                String cntWeek = String.valueOf(System.today().addDays(-7));
                System.debug('Ani stryear :'+ cntYear);
                if(opp.StageName == 'Z05' && Opp.BO1stRegistrationDate__c != null && str.contains(cntYear)){
                    lstOpp1.add(opp);
                    dec = dec + opp.Amount;
                }
                /*
if(System.today().addDays(-7) <=Opp.BO1stRegistrationDate__c){
lstOpp999.add(opp);
}*/
                //Added By Ashish
                if(Opp.BO1stRegistrationDate__c != null && Opp.BO1stRegistrationDate__c >= System.today().addDays(-7)){
                    lstOppTable4.add(opp);
                }
                
                /*if(opp.StageName == 'Z01' || opp.StageName == 'Z02' || opp.StageName == 'Z05'){
lstOpp999.add(opp);
}*/
                //System.debug('Ani lstOpp999 :'+ lstOpp999.Size());
                if((opp.StageName == 'Z01' || opp.StageName == 'Z02' || opp.StageName == 'Z03' || opp.StageName == 'Z04') && Opp.BO1stRegistrationDate__c != null && Opp.CloseDate > System.today()){
                    lstOpp2.add(opp);
                    dec1 = dec1 + opp.Amount;
                }
                if((opp.StageName == 'Z01' || opp.StageName == 'Z02' || opp.StageName == 'Z03' || opp.StageName == 'Z04') && opp.CloseDate< System.today()){
                    lstOpp3.add(opp);
                }
                if((opp.StageName == 'Z01' || opp.StageName == 'Z02' || opp.StageName == 'Z03' || opp.StageName == 'Z04') && opp.CloseDate<= System.now().addDays(+14)){
                    lstOpp4.add(opp);
                }
                if(opp.XP7_CONDUCT_DATE__c> System.today() && opp.CloseDate<= System.now().addDays(+14)){
                    lstOpp5.add(opp);
                }
                if(opp.XP6_CONDUCT_DATE__c> System.today() && opp.CloseDate<= System.now().addMonths(+2)){
                    lstOpp6.add(opp);
                }
                if((opp.StageName == 'Z01' || opp.StageName == 'Z02' || opp.StageName == 'Z03' || opp.StageName == 'Z04')){
                    //if((System.now() < opp.CloseDate <= System.now().addMonths(+3)))
                    //{
                    lstOpp7.add(opp);
                    //}
                }
                if((opp.StageName == 'Z01' || opp.StageName == 'Z02' || opp.StageName == 'Z03' || opp.StageName == 'Z04') && opp.Account.mDomesticForeign__c == '20' && opp.CloseDate <= System.now().addMonths(+3)){
                    //if((System.now() < opp.CloseDate <= System.now().addMonths(+3)))
                    //{
                    lstOpp8.add(opp);
                    //}
                }
                if((opp.StageName == 'Z01' || opp.StageName == 'Z02' || opp.StageName == 'Z03' || opp.StageName == 'Z04') && opp.CMBizType__c == 'CSP_SCP' && opp.CloseDate <= System.now().addMonths(+3)){
                    //if((System.now() < opp.CloseDate <= System.now().addMonths(+3)))
                    //{
                    lstOpp9.add(opp);
                    //}
                }
            }
            lstOpp = null;
            
            /* if(lstOpp999.Size()>0){
//List<String> rts = new List<String>();
//rts.add('0061s000005fFd1AAE');
//rts.add('0061s00000b5OJ0AAM');
List<Service__c> svc =  new List<Service__c>();
svc = [SELECT Id , Name ,sService__r.Name, sService__r.TechAttribute__c , Opportunity__c, ( SELECT Id , Name , Service__c , sSolution__r.Name
FROM Solution__r
WHERE sDeletionFlag__c = false
ORDER BY sSolution__r.Name ASC
)
FROM Service__c
WHERE Opportunity__c IN : lstOpp999 ORDER BY ItemNumber__c ASC];

System.debug('svc@ : '+ svc[0].Solution__r[0].sSolution__r.Name);
System.debug('svc@ : '+ svc.Size());
System.debug('svc@ : '+ svc);
Map<Id,Map<String,List<String>>> mSer = new Map<Id,Map<String,List<String>>>();
//Map<String,List<String>> msm = new Map<String,List<String>>();
for(Opportunity oppId : lstOpp999){
Map<String,List<String>> msm = new Map<String,List<String>>();
for(Service__c str : svc){
if(str.Opportunity__c == oppId.Id ){

System.debug('ser :' +str.sService__r.Name);
List<String> ms = new List<String>();
for(Solution__c sol : str.Solution__r){
System.debug('sam :' +sol.sSolution__r.Name);
ms.add(sol.sSolution__r.Name);
}
msm.put(str.sService__r.Name,ms);
System.debug('sam :' +msm);
}
}
System.debug('sami :' +msm);
mSer.put(oppId.Id , msm);
}
System.debug('mSer' + mSer);
} */
            
            /*
List<Opportunity> oppLst = [Select Id,OriginAcc_BizTypeL1__c,BusinessLevel__c From Opportunity where RecordType.Name = 'HQ' LIMIT 500];
Map<Id,List<Opportunity>> mFull = new Map<Id,List<Opportunity>>();
List<Id> oppFull = new List<Id>();
for(Opportunity Opp : lstOpp999){
List<Opportunity> oppMatch = new List<Opportunity>();
for(Opportunity Opp1 : oppLst){
if(Opp.OriginAcc_BizTypeL1__c == Opp1.OriginAcc_BizTypeL1__c && Opp.BusinessLevel__c == Opp1.BusinessLevel__c) {
oppFull.add(Opp1.Id);
oppMatch.add(Opp1);
}  
}
mFull.put(Opp.Id,oppMatch);
}

Map<Id,Map<Id,Map<String,List<String>>>> mFinal = new Map<Id,Map<Id,Map<String,List<String>>>>();
List<String> lnew = new List<String>();
String sNew ;
Map<String,List<String>> mFin = new Map<String,List<String>>();
//Map<Id,Map<String,List<String>>> mId = new Map<Id,Map<String,List<String>>>();

List<Service__c> svcNew =  new List<Service__c>();
svcNew = [SELECT Id , Name ,sService__r.Name, sService__r.TechAttribute__c , Opportunity__c, ( SELECT Id , Name , Service__c , sSolution__r.Name
FROM Solution__r
WHERE sDeletionFlag__c = false
ORDER BY sSolution__r.Name ASC
)
FROM Service__c
WHERE Opportunity__c IN : oppFull ORDER BY ItemNumber__c ASC];

System.debug('sami :' +svcNew);
System.debug('sami@# :' +oppFull);
System.debug('sami@#$ :' +mFull);
*/            
            
            /*for(String Id : mFull.keySet()){
System.debug('sami@#t :' +Id);
Map<Id,Map<String,List<String>>> mId = new Map<Id,Map<String,List<String>>>();
for(Opportunity oppFin : mFull.get(Id)){
System.debug('sami@#tl :' +oppFin);
//Map<Id,Map<String,List<String>>> mId = new Map<Id,Map<String,List<String>>>();
for(Service__c ser : svcNew) {
if(ser.Opportunity__c == oppFin.Id){
System.debug('ser :' +ser.sService__r.Name);
List<String> ms1 = new List<String>();
for(Solution__c sol : ser.Solution__r){
System.debug('sam :' +sol.sSolution__r.Name);
ms1.add(sol.sSolution__r.Name);
}
mFin.put(ser.sService__r.Name,ms1);
System.debug('sam :' +mFin);
}
} 
mId.put(oppFin.Id,mFin);
System.debug('sama :' +mId);
}
mFinal.put(Id,mId);
System.debug('sami :' +mFinal);
}*/
            
            
            if(lstOpp1.Size()>0 || lstOpp2.Size()>0){
                String strTemp = '';
                String amt = String.valueOf(dec/1000000) ;
                String amt1 = String.valueOf(dec1/1000000) ;
                System.debug('amt Test@ :' + amt);
                List<String> amtStr = new List<String>();
                List<String> amtStr1 = new List<String>();
                String num,num1;
                if(amt.contains('.')){
                    amtStr= amt.split('\\.');
                    System.debug('amtStr Test@ :'+amtStr);
                    num = amtStr[0] +'.' + amtStr[1].substring(0,2);
                }
                else{
                    num = String.valueOf(dec/1000000);
                }
                if(amt1.contains('.')){
                    amtStr1= amt1.split('\\.');
                    System.debug('amtStr Test@ :'+amtStr1);
                    num1 = amtStr1[0] +'.' + amtStr1[1].substring(0,2);
                }
                else{
                    num1 = String.valueOf(dec1/1000000);
                }
                strTemp += ' <tr>'+
                    '<th style="text-align:center; padding: 13px 0px 12px 0; vertical-align: middle;">영업대표</th>'+
                    '<th style="text-align:center; padding: 13px 0px 12px 0; vertical-align: middle;">수주완료 건수</th>'+
                    '<th style="text-align:center; padding: 13px 0px 12px 0">수주완료 금액 </th>'+
                    '<th style="text-align:center; padding: 13px 0px 12px 0">올해 수주 예상일로 진행 중인 BO 의 건수</th>'+
                    '<th style="text-align:center; padding: 13px 0px 12px 0">올해 수주 예상일로 진행 중인 BO 의 금액 </th>'+
                    '</tr>'+
                    '<tr>'+
                    '<td style="text-align:center; padding: 12px 0px 10px 0">' + listScope[0].Name + '</td>' +
                    '<td style="text-align:center; padding: 12px 0px 10px 0">' + lstOpp1.Size() + '</td>' +
                    '<td style="text-align:center; padding: 12px 0px 10px 0">' + num + '</td>' +
                    '<td style="text-align:center; padding: 12px 0px 10px 0">' + lstOpp2.Size() + '</td>' +
                    '<td style="text-align:center; padding: 12px 0px 10px 0">' + num1 + '</td>'+ 
                    '</tr>' ;
                
                String sDate = String.valueOf(System.now());
                String sTemp = '<div class="tbl_tit">'+ count +'. 연간 누적 사업기회 수주 현황<br/>- 금액 : 백만단위 (KRW) </div>';    //Adi
                strEmail = strEmail.replace('<div class="tbl_tit">1. 연간 누적 사업기회 수주 현황<br/>- 금액 : 백만단위 (KRW) </div>', sTemp);    //Adi
                strEmail = strEmail.replace('{!DateValue}', sDate);
                strEmail = strEmail.replace('{!tableString1}', strTemp);
                table1 = true;
                count = count +1;  //Adi
            }
            Boolean a = false;
            if(lstOpp1.Size()==0 && lstOpp2.Size()==0){
                a= true; 
                strEmail = strEmail.replace('<div class="tbl_tit">1. 연간 누적 사업기회 수주 현황<br/>- 금액 : 백만단위 (KRW) </div>','');
                strEmail = strEmail.replace('<table  class="tbl_type01"> {!tableString1}</table><br/> ','');
            }
            lstOpp1 = null;
            lstOpp2 = null;
            if(lstOpp3.Size()>0){
                String strTemp = '';
                strTemp += ' <tr>'+
                    '<th style="text-align:center; padding: 13px 0px 12px 0; vertical-align: middle;">영업대표</th>'+
                    '<th colspan ="3" style="text-align:center; padding: 13px 0px 12px 0; vertical-align: middle; width:25%">사업기회 명</th>'+
                    '<th style="text-align:center; padding: 13px 0px 12px 0">사업기회 코드</th>'+
                    '<th colspan ="0.5" style="text-align:center; padding: 13px 0px 12px 0">수주예상일</th>'+
                    '<th style="text-align:center; padding: 13px 0px 12px 0">단계</th>'+
                    '<th style="text-align:center; padding: 13px 0px 12px 0">금액</th>'+
                    '</tr>';
                for(Opportunity opp : lstOpp3){
                    String str; 
                    if(isSandbox){
                        str = 'https://sdssfa--qa.sandbox.lightning.force.com/lightning/r/Opportunity/' + opp.Id + '/view';
                    }
                    else{
                        str = 'https://sdssfa.lightning.force.com/lightning/r/Opportunity/' + opp.Id + '/view';    
                    }
                    String clDate = String.valueOf(opp.CloseDate);
                    String closeDate = clDate.substring(0,10);
                    String amt = String.valueOf(opp.Amount/1000000) ;
                    System.debug('amt Test@ :' + amt);
                    List<String> amtStr = new List<String>();
                    String num;
                    if(amt.contains('.')){
                        amtStr= amt.split('\\.');
                        System.debug('amtStr Test@ :'+amtStr);
                        num = amtStr[0] +'.' + amtStr[1].substring(0,2);
                    }
                    else{
                        num = String.valueOf(opp.Amount/1000000);
                    }
                    System.debug('amtStr Test :'+amtStr);
                    
                    strTemp +=  '<tr>'+
                        '<td style="text-align:center; padding: 12px 0px 10px 0">' + listScope[0].Name  + '</td>' +
                        '<td colspan ="3" style="text-align:left; padding: 12px 0px 10px 0; text-decoration: underline">' + '<a style="color:blue" href="' + str + '">'+ opp.Name + '</a>' + '</td>' +
                        '<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.OpportunityCode__c + '</td>' +
                        '<td colspan ="0.5" style="text-align:center; padding: 12px 0px 10px 0">' + closeDate + '</td>' +
                        '<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.get('toLabel_StageName') + '</td>'+ 
                        '<td style="text-align:center; padding: 12px 0px 10px 0">' + num + '</td>'+ 
                        '</tr>' ;
                }
                String sDate = String.valueOf(System.now());
                //strEmail = strEmail.replace('<div class="tbl_tit">1. 연간 누적 사업기회 수주 현황<br/>금액 : 백만단위 (KRW) </div>','');
                //strEmail = strEmail.replace('<table  class="tbl_type01"> {!tableString1}</table><br/>','');
                //strEmail = strEmail.replace('2.지연 BO 및','1.지연 BO 및');
                String sTemp = IntRoman(subHeadingCount) +'. 지연 BO';    //Adi
                strEmail = strEmail.replace('i. 지연 BO', sTemp);    //Adi
                subHeadingCount++;
                strEmail = strEmail.replace('{!DateValue}', sDate);
                strEmail = strEmail.replace('{!tableString2}', strTemp);
                table2 = true;
            }
            
            /*if(lstOpp3.Size()>0 && table1== true){
String strTemp = '';
strTemp += ' <tr>'+
'<th style="text-align:center; padding: 13px 0px 12px 0; vertical-align: middle;">영업대표</th>'+
'<th style="text-align:center; padding: 13px 0px 12px 0; vertical-align: middle;">사업기회 명</th>'+
'<th style="text-align:center; padding: 13px 0px 12px 0">사업기회 코드</th>'+
'<th style="text-align:center; padding: 13px 0px 12px 0">수주예상일</th>'+
'<th style="text-align:center; padding: 13px 0px 12px 0">단계</th>'+
'<th style="text-align:center; padding: 13px 0px 12px 0">금액</th>'+
'</tr>';
for(Opportunity opp : lstOpp3){
String str = 'https://sdssfa--qa.sandbox.lightning.force.com/lightning/r/Opportunity/' + opp.Id + '/view';
strTemp +=  '<tr>'+
'<td style="text-align:center; padding: 12px 0px 10px 0">' + listScope[0].Name  + '</td>' +
'<td style="text-align:center; padding: 12px 0px 10px 0">' + '<a href="' + str + '">'+ opp.Name + '</a>' + '</td>' +
'<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.OpportunityCode__c + '</td>' +
'<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.CloseDate + '</td>' +
'<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.get('toLabel_StageName')+ '</td>'+ 
'<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.Amount/1000000 + '</td>'+ 
'</tr>' ;
}
//strEmail = strEmail.replace('<div class="tbl_tit">1. 연간 누적 사업기회 수주 현황<br/>금액 : 백만단위 (KRW) </div><br/>','');
//strEmail = strEmail.replace('<table  class="tbl_type01"> {!tableString1}</table><br/>','');
//strEmail = strEmail.replace('2.지연 BO 및','1.지연 BO 및');
String sDate = String.valueOf(System.now());
strEmail = strEmail.replace('{!DateValue}', sDate);
strEmail = strEmail.replace('{!tableString2}', strTemp);
table2 = true;
}*/
            
            Boolean b = false;
            if(lstOpp3.Size()==0){
                strEmail = strEmail.replace('i. 지연 BO', '');
                strEmail = strEmail.replace('<table  class="tbl_type01">{!tableString2}</table>', '');
                b= true;  
            }
            
            if(lstOpp4.Size()>0){
                String strTemp = '';
                strTemp += ' <tr>'+
                    '<th style="text-align:center; padding: 13px 0px 12px 0; vertical-align: middle;">영업대표</th>'+
                    '<th colspan ="3" style="text-align:center; padding: 13px 0px 12px 0; vertical-align: middle; width:25%">사업기회 명</th>'+
                    '<th style="text-align:center; padding: 13px 0px 12px 0">사업기회 코드</th>'+
                    '<th colspan ="0.5" style="text-align:center; padding: 13px 0px 12px 0">수주예상일</th>'+
                    '<th style="text-align:center; padding: 13px 0px 12px 0">단계</th>'+
                    '<th style="text-align:center; padding: 13px 0px 12px 0">금액</th>'+
                    '</tr>';
                for(Opportunity opp : lstOpp4){
                    String str; 
                    if(isSandbox){
                        str = 'https://sdssfa--qa.sandbox.lightning.force.com/lightning/r/Opportunity/' + opp.Id + '/view';
                    }
                    else{
                        str = 'https://sdssfa.lightning.force.com/lightning/r/Opportunity/' + opp.Id + '/view';    
                    }
                    String clDate = String.valueOf(opp.CloseDate);
                    String closeDate = clDate.substring(0,10);
                    String amt = String.valueOf(opp.Amount/1000000) ;
                    System.debug('amt Test@ :' + amt);
                    List<String> amtStr = new List<String>();
                    String num;
                    if(amt.contains('.')){
                        amtStr= amt.split('\\.');
                        System.debug('amtStr Test@ :'+amtStr);
                        num = amtStr[0] +'.' +  amtStr[1].substring(0,2);
                    }
                    else{
                        num = String.valueOf(opp.Amount/1000000);
                    }
                    System.debug('amtStr Test :'+amtStr);            strTemp +=  '<tr>'+
                        '<td style="text-align:center; padding: 12px 0px 10px 0">' + listScope[0].Name  + '</td>' +
                        '<td colspan ="3" style="text-align:left; padding: 12px 0px 10px 0; text-decoration: underline">' + '<a style="color:blue" href="' + str + '">'+ opp.Name + '</a>' + '</td>' + 
                        '<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.OpportunityCode__c + '</td>' +
                        '<td colspan ="0.5" style="text-align:center; padding: 12px 0px 10px 0">' + closeDate + '</td>' +
                        '<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.get('toLabel_StageName') + '</td>'+ 
                        '<td style="text-align:center; padding: 12px 0px 10px 0">' + num + '</td>'+ 
                        '</tr>' ;
                }
                //strEmail = strEmail.replace('<div class="tbl_tit"> 2.지연 BO 및 수주 예상일 도래 BO<br/>- 금액 단위: 백만단위 (KRW)<br/>i. ', '');
                //strEmail = strEmail.replace('지연 BO</div><br/><table  class="tbl_type01"> {!tableString2}</table><br/>  ', '');
                //strEmail = strEmail.replace('ii. 수주예상일 도래 BO   ', 'i. 수주예상일 도래 BO ');
                String sTemp = '<div class="tbl_tit">' + IntRoman(subHeadingCount) +'. 수주예상일 도래 BO  </div>';    //Adi
                strEmail = strEmail.replace('<div class="tbl_tit">ii. 수주예상일 도래 BO  </div>', sTemp);    //Adi
                strEmail = strEmail.replace('{!tableString3}', strTemp);
                String sDate = String.valueOf(System.now());
                strEmail = strEmail.replace('{!DateValue}', sDate);
                table3 = true;
            }
            
            /*if(lstOpp4.Size()>0 && b== false){
String strTemp = '';
strTemp += ' <tr>'+
'<th style="text-align:center; padding: 13px 0px 12px 0; vertical-align: middle;">영업대표</th>'+
'<th style="text-align:center; padding: 13px 0px 12px 0; vertical-align: middle;">사업기회 명</th>'+
'<th style="text-align:center; padding: 13px 0px 12px 0">사업기회 코드</th>'+
'<th style="text-align:center; padding: 13px 0px 12px 0">수주예상일</th>'+
'<th style="text-align:center; padding: 13px 0px 12px 0">단계</th>'+
'<th style="text-align:center; padding: 13px 0px 12px 0">금액</th>'+
'</tr>';
for(Opportunity opp : lstOpp4){
String str = 'https://sdssfa--qa.sandbox.lightning.force.com/lightning/r/Opportunity/' + opp.Id + '/view';
strTemp +=  '<tr>'+
'<td style="text-align:center; padding: 12px 0px 10px 0">' + listScope[0].Name  + '</td>' +
'<td style="text-align:center; padding: 12px 0px 10px 0">' + '<a href="' + str + '">'+ opp.Name + '</a>' + '</td>' + 
'<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.OpportunityCode__c + '</td>' +
'<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.CloseDate + '</td>' +
'<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.get('toLabel_StageName') + '</td>'+ 
'<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.Amount/1000000 + '</td>'+ 
'</tr>' ;
}
strEmail = strEmail.replace('{!tableString3}', strTemp);
String sDate = String.valueOf(System.now());
strEmail = strEmail.replace('{!DateValue}', sDate);
table3 = true;
}*/
            
            Boolean c = false;
            if(lstOpp4.Size()==0){
                strEmail = strEmail.replace('<div class="tbl_tit">ii. 수주예상일 도래 BO  </div>', '');
                strEmail = strEmail.replace('<table  class="tbl_type01">  {!tableString3} </table>', '');
                c= true;   
            }
            
            if(lstOpp4.Size()==0 && lstOpp3.Size()==0){
                strEmail = strEmail.replace('<div class="tbl_tit"> 2.지연 BO 및 수주 예상일 도래 BO<br/>- 금액 단위: 백만단위 (KRW)<br/>', '');  
            }else{  //Adi complete else part
                String sTemp = '<div class="tbl_tit">' + count + '.지연 BO 및 수주 예상일 도래 BO<br/>- 금액 단위: 백만단위 (KRW)<br/>';
                strEmail = strEmail.replace('<div class="tbl_tit"> 2.지연 BO 및 수주 예상일 도래 BO<br/>- 금액 단위: 백만단위 (KRW)<br/>', sTemp);
                count = count +1;
            }
            lstOpp3 = null;   
            lstOpp4 = null;
            subHeadingCount = 1;	//Adi
            
            if(lstOpp5.Size()>0){
                String strTemp = '';
                strTemp += ' <tr>'+
                    '<th style="text-align:center; padding: 13px 0px 12px 0; vertical-align: middle;">수전위 Type </th>'+
                    '<th style="text-align:center; padding: 13px 0px 12px 0; vertical-align: middle;">사업 심의 유형 확정 </th>'+
                    '<th colspan ="2" style="text-align:center; padding: 13px 0px 12px 0; width:25%">사업기회 명</th>'+
                    '<th style="text-align:center; padding: 13px 0px 12px 0">금액</th>'+
                    '<th style="text-align:center; padding: 13px 0px 12px 0">입찰결정 실행일</th>'+
                    '<th style="text-align:center; padding: 13px 0px 12px 0">제안 제출일  </th>'+
                    '</tr>';
                for(Opportunity opp : lstOpp5){
                    String str; 
                    if(isSandbox){
                        str = 'https://sdssfa--qa.sandbox.lightning.force.com/lightning/r/Opportunity/' + opp.Id + '/view';
                    }
                    else{
                        str = 'https://sdssfa.lightning.force.com/lightning/r/Opportunity/' + opp.Id + '/view';    
                    } 
                    String cnDate = String.valueOf(opp.XP7_CONDUCT_DATE__c);
                    String conductDate = cnDate.substring(0,10);
                    String propDate = String.valueOf(opp.ZP61_PROPOSAL_SUBMIT_DATE__c);
                    String proposalDate;
                    if(propDate != null || propDate != ''){
                        if(!Test.isRunningTest())
                        {
                            proposalDate = propDate.substring(0,10);
                        }
                    }
                    String amt = String.valueOf(opp.Amount/1000000) ;
                    System.debug('amt Test@ :' + amt);
                    List<String> amtStr = new List<String>();
                    String num;
                    if(amt.contains('.')){
                        amtStr= amt.split('\\.');
                        System.debug('amtStr Test@ :'+amtStr);
                        num = amtStr[0] + '.' + amtStr[1].substring(0,2);
                    }
                    else{
                        num = String.valueOf(opp.Amount/1000000);
                    }
                    System.debug('amtStr Test :'+amtStr);
                    strTemp +=  '<tr>'+
                        '<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.get('toLabel_Opportunity_Review_VRB_Type__c')  + '</td>' +
                        '<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.get('toLabel_Opportunity_Review_VRB_Type_Confirm__c') + '</td>' +
                        '<td colspan ="2" style="text-align:left; padding: 12px 0px 10px 0;  text-decoration: underline">' + '<a style="color:blue" href="' + str + '">'+ opp.Name + '</a>' + '</td>' + 
                        '<td style="text-align:center; padding: 12px 0px 10px 0">' + num + '</td>' +
                        '<td style="text-align:center; padding: 12px 0px 10px 0">' + conductDate + '</td>'+ 
                        '<td style="text-align:center; padding: 12px 0px 10px 0">' + proposalDate + '</td>'+ 
                        '</tr>' ;
                }
                //strEmail = strEmail.replace('<div class="tbl_tit">1. 연간 누적 사업기회 수주 현황<br/>금액 : 백만단위 (KRW) </div><br/>','');
                //strEmail = strEmail.replace('<table  class="tbl_type01"> {!tableString1}</table><br/>','');
                //strEmail = strEmail.replace('<div class="tbl_tit"> 2.지연 BO 및 수주 예상일 도래 BO<br/>- 금액 단위: 백만단위 (KRW)<br/>i. ', '');
                //strEmail = strEmail.replace('지연 BO</div><br/><table  class="tbl_type01"> {!tableString2}</table><br/>  ', '');
                //strEmail = strEmail.replace('3. 사업수행 사전준비','1. 사업수행 사전준비');
                //strEmail = strEmail.replace('{!tableString4}', strTemp);
                String sDate = String.valueOf(System.now());
                strEmail = strEmail.replace('{!DateValue}', sDate);
                table4 = true;
            }
            
            /*if(lstOpp5.Size()>0 && a== false && b== false){
String strTemp = '';
strTemp += ' <tr>'+
'<th style="text-align:center; padding: 13px 0px 12px 0; vertical-align: middle;">수전위 Type </th>'+
'<th style="text-align:center; padding: 13px 0px 12px 0; vertical-align: middle;">사업 심의 유형 확정 </th>'+
'<th style="text-align:center; padding: 13px 0px 12px 0">사업기회 명</th>'+
'<th style="text-align:center; padding: 13px 0px 12px 0">금액</th>'+
'<th style="text-align:center; padding: 13px 0px 12px 0">입찰결정 실행일</th>'+
'<th style="text-align:center; padding: 13px 0px 12px 0">제안 제출일  </th>'+
'</tr>';
for(Opportunity opp : lstOpp5){
String str = 'https://sdssfa--qa.sandbox.lightning.force.com/lightning/r/Opportunity/' + opp.Id + '/view';
strTemp +=  '<tr>'+
'<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.Type  + '</td>' +
'<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.Opportunity_Review_VRB_Type_Confirm__c + '</td>' +
'<td style="text-align:center; padding: 12px 0px 10px 0">' + '<a href="' + str + '">'+ opp.Name + '</a>' + '</td>' + 
'<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.Amount/1000000 + '</td>' +
'<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.XP7_CONDUCT_DATE__c + '</td>'+ 
'<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.ZP61_PROPOSAL_SUBMIT_DATE__c + '</td>'+ 
'</tr>' ;
}
strEmail = strEmail.replace('{!tableString4}', strTemp);
String sDate = String.valueOf(System.now());
strEmail = strEmail.replace('{!DateValue}', sDate);
table4 = true;
}

if(lstOpp5.Size()>0 && a== true && b== false){
String strTemp = '';
strTemp += ' <tr>'+
'<th style="text-align:center; padding: 13px 0px 12px 0; vertical-align: middle;">수전위 Type </th>'+
'<th style="text-align:center; padding: 13px 0px 12px 0; vertical-align: middle;">사업 심의 유형 확정 </th>'+
'<th style="text-align:center; padding: 13px 0px 12px 0">사업기회 명</th>'+
'<th style="text-align:center; padding: 13px 0px 12px 0">금액</th>'+
'<th style="text-align:center; padding: 13px 0px 12px 0">입찰결정 실행일</th>'+
'<th style="text-align:center; padding: 13px 0px 12px 0">제안 제출일  </th>'+
'</tr>';
for(Opportunity opp : lstOpp5){
String str = 'https://sdssfa--qa.sandbox.lightning.force.com/lightning/r/Opportunity/' + opp.Id + '/view';
strTemp +=  '<tr>'+
'<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.Type  + '</td>' +
'<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.Opportunity_Review_VRB_Type_Confirm__c + '</td>' +
'<td style="text-align:center; padding: 12px 0px 10px 0">' + '<a href="' + str + '">'+ opp.Name + '</a>' + '</td>' + 
'<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.Amount/1000000 + '</td>' +
'<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.XP7_CONDUCT_DATE__c + '</td>'+ 
'<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.ZP61_PROPOSAL_SUBMIT_DATE__c + '</td>'+ 
'</tr>' ;
}
strEmail = strEmail.replace('<div class="tbl_tit">1. 연간 누적 사업기회 수주 현황<br/>금액 : 백만단위 (KRW) </div><br/>','');
strEmail = strEmail.replace('<table  class="tbl_type01"> {!tableString1}</table><br/>','');
strEmail = strEmail.replace('3. 사업수행 사전준비', '2. 사업수행 사전준비');
strEmail = strEmail.replace('{!tableString4}', strTemp);
String sDate = String.valueOf(System.now());
strEmail = strEmail.replace('{!DateValue}', sDate);
table4 = true;
}

if(lstOpp5.Size()>0 && b== true && c== true){
String strTemp = '';
strTemp += ' <tr>'+
'<th style="text-align:center; padding: 13px 0px 12px 0; vertical-align: middle;">수전위 Type </th>'+
'<th style="text-align:center; padding: 13px 0px 12px 0; vertical-align: middle;">사업 심의 유형 확정 </th>'+
'<th style="text-align:center; padding: 13px 0px 12px 0">사업기회 명</th>'+
'<th style="text-align:center; padding: 13px 0px 12px 0">금액</th>'+
'<th style="text-align:center; padding: 13px 0px 12px 0">입찰결정 실행일</th>'+
'<th style="text-align:center; padding: 13px 0px 12px 0">제안 제출일  </th>'+
'</tr>';
for(Opportunity opp : lstOpp5){
String str = 'https://sdssfa--qa.sandbox.lightning.force.com/lightning/r/Opportunity/' + opp.Id + '/view';
strTemp +=  '<tr>'+
'<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.Type  + '</td>' +
'<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.Opportunity_Review_VRB_Type_Confirm__c + '</td>' +
'<td style="text-align:center; padding: 12px 0px 10px 0">' + '<a href="' + str + '">'+ opp.Name + '</a>' + '</td>' + 
'<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.Amount/1000000 + '</td>' +
'<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.XP7_CONDUCT_DATE__c + '</td>'+ 
'<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.ZP61_PROPOSAL_SUBMIT_DATE__c + '</td>'+ 
'</tr>' ;
}
strEmail = strEmail.replace('{!tableString4}', strTemp);
strEmail = strEmail.replace('<div class="tbl_tit"> 2.지연 BO 및 수주 예상일 도래 BO<br/>- 금액 단위: 백만단위 (KRW)<br/>i.', '');
strEmail = strEmail.replace('지연 BO</div><br/><table  class="tbl_type01"> {!tableString2}</table><br/> ', '');
strEmail = strEmail.replace(' <!-- 3rd Table --><div class="tbl_tit">ii. 수주예상일 도래 BO </div><br/>', '');
strEmail = strEmail.replace(' <table  class="tbl_type01">  {!tableString3} </table> <br/> ', '');
strEmail = strEmail.replace('3. 사업수행 사전준비','2. 사업수행 사전준비');
String sDate = String.valueOf(System.now());
strEmail = strEmail.replace('{!DateValue}', sDate);
table4 = true;
}*/
            Boolean d = false;
            if(lstOpp5.Size()==0){
                strEmail = strEmail.replace('i. 수전위 사전준비', '');
                strEmail = strEmail.replace('<table  class="tbl_type01">  {!tableString4} </table>', '');
                d= true; 
            }
            
            if(lstOpp6.Size()>0){
                String strTemp = '';
                strTemp += ' <tr>'+
                    '<th style="text-align:center; padding: 13px 0px 12px 0; vertical-align: middle;">수전위 Type </th>'+
                    '<th style="text-align:center; padding: 13px 0px 12px 0; vertical-align: middle;">사업 심의 유형 확정 </th>'+
                    '<th colspan ="2" style="text-align:center; padding: 13px 0px 12px 0; width:25%">사업기회 명</th>'+
                    '<th style="text-align:center; padding: 13px 0px 12px 0">금액</th>'+
                    '<th style="text-align:center; padding: 13px 0px 12px 0">사업참여 실행일</th>'+
                    '<th style="text-align:center; padding: 13px 0px 12px 0">제안 제출일  </th>'+
                    '</tr>';
                for(Opportunity opp : lstOpp6){
                    String str; 
                    if(isSandbox){
                        str = 'https://sdssfa--qa.sandbox.lightning.force.com/lightning/r/Opportunity/' + opp.Id + '/view';
                    }
                    else{
                        str = 'https://sdssfa.lightning.force.com/lightning/r/Opportunity/' + opp.Id + '/view';    
                    }
                    String cnDate = String.valueOf(opp.XP6_CONDUCT_DATE__c);
                    String conductDate = cnDate.substring(0,10);
                    String propDate = String.valueOf(opp.ZP61_PROPOSAL_SUBMIT_DATE__c);
                    //String proposalDate = propDate.substring(0,10);
                    String proposalDate;
                    if(propDate != null || propDate != ''){
                        if(!Test.isRunningTest())
                        {
                            proposalDate = propDate.substring(0,10);
                        }
                    }
                    String amt = String.valueOf(opp.Amount/1000000) ;
                    System.debug('amt Test@ :' + amt);
                    List<String> amtStr = new List<String>();
                    String num;
                    if(amt.contains('.')){
                        amtStr= amt.split('\\.');
                        System.debug('amtStr Test@ :'+amtStr);
                        num = amtStr[0] + '.' + amtStr[1].substring(0,2);
                    }
                    else{
                        num = String.valueOf(opp.Amount/1000000);
                    }
                    System.debug('amtStr Test :'+amtStr);
                    strTemp +=  '<tr>'+
                        '<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.get('toLabel_Opportunity_Review_VRB_Type__c')  + '</td>' +
                        '<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.get('toLabel_Opportunity_Review_VRB_Type_Confirm__c') + '</td>' +
                        '<td colspan ="2" style="text-align:left; padding: 12px 0px 10px 0; text-decoration: underline">' + '<a style="color:blue" href="' + str + '">'+ opp.Name + '</a>' + '</td>' + 
                        '<td style="text-align:center; padding: 12px 0px 10px 0">' + num + '</td>' +
                        '<td style="text-align:center; padding: 12px 0px 10px 0">' + conductDate + '</td>'+ 
                        '<td style="text-align:center; padding: 12px 0px 10px 0">' + proposalDate + '</td>'+ 
                        '</tr>' ;
                }
                String sTemp = IntRoman(subHeadingCount) +'. 수전위 사전준비';    //Adi
                strEmail = strEmail.replace('i. 수전위 사전준비', sTemp);    //Adi
                subHeadingCount++;	//Adi
                strEmail = strEmail.replace('{!tableString5}', strTemp);
                String sDate = String.valueOf(System.now());
                strEmail = strEmail.replace('{!DateValue}', sDate);
                table5 = true;
            }
            Boolean e = false;
            if(lstOpp6.Size()==0){
                strEmail = strEmail.replace('i. 수전위 사전준비', '');
                strEmail = strEmail.replace('<table  class="tbl_type01">  {!tableString5} </table>', '');  
                e= true;  
            } 
            
            if(lstOpp7.Size()>0){
                String strTemp = '';
                strTemp += ' <tr>'+
                    '<th style="text-align:center; padding: 13px 0px 12px 0; vertical-align: middle;">사업기회 코드 </th>'+
                    '<th colspan ="2" style="text-align:center; padding: 13px 0px 12px 0; vertical-align: middle; width:25%"> 사업기회 명 </th>'+
                    '<th style="text-align:center; padding: 13px 0px 12px 0">수주예상일 </th>'+
                    '<th style="text-align:center; padding: 13px 0px 12px 0">수주금액</th>'+
                    '<th style="text-align:center; padding: 13px 0px 12px 0"> 단계</th>'+
                    '<th style="text-align:center; padding: 13px 0px 12px 0">제안PM</th>'+
                    '<th style="text-align:center; padding: 13px 0px 12px 0">제안PM 가용 여부 </th>'+
                    '<th style="text-align:center; padding: 13px 0px 12px 0">인력투입계획 작성여부 </th>'+
                    '</tr>';
                for(Opportunity opp : lstOpp7){
                    String str; 
                    if(isSandbox){
                        str = 'https://sdssfa--qa.sandbox.lightning.force.com/lightning/r/Opportunity/' + opp.Id + '/view';
                    }
                    else{
                        str = 'https://sdssfa.lightning.force.com/lightning/r/Opportunity/' + opp.Id + '/view';    
                    }
                    String prop;
                    if(opp.ProposalPM__r.Name  == null){
                        prop = '';
                    }
                    else{prop = opp.ProposalPM__r.Name ;}
                    String clDate = String.valueOf(opp.CloseDate);
                    String closeDate = clDate.substring(0,10);
                    String amt = String.valueOf(opp.Amount/1000000) ;
                    System.debug('amt Test@ :' + amt);
                    List<String> amtStr = new List<String>();
                    String num;
                    if(amt.contains('.')){
                        amtStr= amt.split('\\.');
                        System.debug('amtStr Test@ :'+amtStr);
                        num = amtStr[0] + '.' + amtStr[1].substring(0,2);
                    }
                    else{
                        num = String.valueOf(opp.Amount/1000000);
                    }
                    System.debug('amtStr Test :'+amtStr);
                    strTemp +=  '<tr>'+
                        '<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.OpportunityCode__c  + '</td>' +
                        '<td colspan ="2" style="text-align:left; padding: 12px 0px 10px 0; text-decoration: underline; text-align:left">' + '<a style="color:blue" href="' + str + '">'+ opp.Name + '</a>' + '</td>' + 
                        '<td style="text-align:center; padding: 12px 0px 10px 0">' + closeDate + '</td>' +
                        '<td style="text-align:center; padding: 12px 0px 10px 0">' + num + '</td>' +
                        '<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.get('toLabel_StageName')+ '</td>'+ 
                        '<td style="text-align:center; padding: 12px 0px 10px 0">' + prop + '</td>'+
                        '<td style="text-align:center; padding: 12px 0px 10px 0">' + 'Y' + '</td>'+ 
                        '<td style="text-align:center; padding: 12px 0px 10px 0">' + 'Y' + '</td>'+ 
                        '</tr>' ;
                }
                String sTemp = '<div class="tbl_tit">' + IntRoman(subHeadingCount) +'. 인력투입 계획 수립 요청</div>';    //Adi
                strEmail = strEmail.replace('<div class="tbl_tit">ii. 인력투입 계획 수립 요청</div>', sTemp);    //Adi
                subHeadingCount++;	//Adi
                strEmail = strEmail.replace('{!tableString6}', strTemp);
                String sDate = String.valueOf(System.now());
                strEmail = strEmail.replace('{!DateValue}', sDate);
                table6 = true;
            }
            Boolean f = false;
            if(lstOpp7.Size()==0){
                f= true; 
                strEmail = strEmail.replace('<div class="tbl_tit">ii. 인력투입 계획 수립 요청</div>', '');
                strEmail = strEmail.replace('<table  class="tbl_type01">  {!tableString6} </table>', '');    
            }
            
            if(lstOpp8.Size()>0 || !isSandbox){
                /*String strTemp = '';
strTemp += ' <tr>'+
'<th style="text-align:center; padding: 13px 0px 12px 0; vertical-align: middle; width:25%">사업기회 명 </th>'+
'<th colspan ="1" style="text-align:center; padding: 13px 0px 12px 0; vertical-align: middle;"> 수주예상일 </th>'+
'<th colspan ="1" style="text-align:center; padding: 13px 0px 12px 0"> 원청고객 </th>'+
'<th style="text-align:center; padding: 13px 0px 12px 0">원청고객 owner</th>'+
'<th colspan ="1" style="text-align:center; padding: 13px 0px 12px 0"> 계약고객</th>'+
'<th style="text-align:center; padding: 13px 0px 12px 0">계약고객 owner </th>'+
'</tr>';
for(Opportunity opp : lstOpp8){
String str,str1;
if(isSandbox){
str = 'https://sdssfa--qa.sandbox.lightning.force.com/lightning/r/Account/' + opp.cOriginAcc__c + '/view';
str1 = 'https://sdssfa--qa.sandbox.lightning.force.com/lightning/r/Account/' + opp.AccountId + '/view';
}
else{
// String str = 'https://sdssfa.lightning.force.com/lightning/r/Opportunity/' + opp.Id + '/view'; 
str = 'https://sdssfa.lightning.force.com/lightning/r/Account/' + opp.cOriginAcc__c + '/view';
str1 = 'https://sdssfa.lightning.force.com/lightning/r/Account/' + opp.AccountId + '/view';
} 

String clDate = String.valueOf(opp.CloseDate);
String closeDate = clDate.substring(0,10);

strTemp +=  '<tr>'+
'<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.Name  + '</td>' +
'<td colspan ="1" style="text-align:center; padding: 12px 0px 10px 0">' + closeDate + '</td>' +
'<td colspan ="1" style="text-align:left; padding: 12px 0px 10px 0;  text-decoration: underline">' + '<a style="color:blue" href="' + str + '">'+ opp.cOriginAcc__r.Name + '</a>' + '</td>' +
'<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.cOriginAcc__r.Owner.Name + '</td>' +
'<td colspan ="1" style="text-align:left; padding: 12px 0px 10px 0;  text-decoration: underline">' + '<a style="color:blue" href="' + str1 + '">'+ opp.Account.Name + '</a>' + '</td>' + 
'<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.Account.Owner.Name + '</td>'+ 
'</tr>' ;
}
strEmail = strEmail.replace('{!tableString7}', strTemp);
String sDate = String.valueOf(System.now());
strEmail = strEmail.replace('{!DateValue}', sDate);
table7 = true;
*/
                String str = 'https://sdssfa.lightning.force.com/lightning/r/Account/0012w00000buILWAA2/view';
                String str1 = 'https://sdssfa.lightning.force.com/lightning/r/Account/0012w00000d8K3GAAU/view';
                String str2 = 'https://sdssfa.lightning.force.com/lightning/r/Opportunity/0062w00000N4royAAB/view';
                String strTemp = '';
                strTemp += ' <tr>'+
                    '<th colspan ="2" style="text-align:center; padding: 13px 0px 12px 0; vertical-align: middle; width:25%">사업기회 명 </th>'+
                    '<th colspan ="1" style="text-align:center; padding: 13px 0px 12px 0; vertical-align: middle;"> 수주예상일 </th>'+
                    '<th colspan ="1" style="text-align:center; padding: 13px 0px 12px 0"> 원청고객 </th>'+
                    '<th style="text-align:center; padding: 13px 0px 12px 0">원청고객 owner</th>'+
                    '<th colspan ="1" style="text-align:center; padding: 13px 0px 12px 0"> 계약고객</th>'+
                    '<th style="text-align:center; padding: 13px 0px 12px 0">계약고객 owner </th>'+
                    '</tr>';
                strTemp +=  '<tr>'+
                    '<td colspan ="2" style="text-align:left; padding: 12px 0px 10px 0; text-decoration: underline">' + '<a style="color:blue" href="' + str2 + '">'+ '[롯데마트] ERP 구축' + '</a>' + '</td>' +
                    '<td colspan ="1" style="text-align:center; padding: 12px 0px 10px 0">' + '2023. 11. 30' + '</td>' +
                    '<td colspan ="1" style="text-align:left; padding: 12px 0px 10px 0;  text-decoration: underline">' + '<a style="color:blue" href="' + str + '">'+ '롯데쇼핑 (주)롯데마트사업본부' + '</a>' + '</td>' +
                    '<td style="text-align:center; padding: 12px 0px 10px 0">' + 'mySales Admin.'+ '</td>' +
                    '<td colspan ="1" style="text-align:left; padding: 12px 0px 10px 0;  text-decoration: underline">' + '<a style="color:blue" href="' + str1+ '">'+ '롯데정보통신㈜' + '</a>' + '</td>' + 
                    '<td style="text-align:center; padding: 12px 0px 10px 0">' + 'mySales Admin.'+ '</td>'+ 
                    '</tr>' ;
                String sTemp = '<div class="tbl_tit">' + IntRoman(subHeadingCount) +'. 고객 정보 <br/>';    //Adi
                strEmail = strEmail.replace('<div class="tbl_tit">iii. 고객 정보 <br/>', sTemp);    //Adi
                subHeadingCount++;	//Adi
                strEmail = strEmail.replace('{!tableString7}', strTemp);
                String sDate = String.valueOf(System.now());
                strEmail = strEmail.replace('{!DateValue}', sDate);
                System.debug('entry repplace');
            }
            Boolean g = false;
            System.debug('entry repplace@ :'+ lstOpp8.Size());
            if(lstOpp8.Size()==0){
                System.debug('entry repplace');
                strEmail = strEmail.replace('<div class="tbl_tit">iii. 고객 정보 <br/>', '');
                strEmail = strEmail.replace('- opendart 정보가 원청고객/계약고객에 대해 현행화 되었으므로 이를 확인하시어 고객 정보를 현행화 하시기 바랍니다 </div>' , '' ); 
                System.debug('entry repplace :'+ strEmail);
                strEmail = strEmail.replace('<table  class="tbl_type01">  {!tableString7} </table>', '');     
                g= true;  
            }
            
            
            if(lstOpp9.Size()>0 || !isSandbox){
                /* String strTemp = '';
strTemp += ' <tr>'+
'<th colspan ="2" style="text-align:center; padding: 13px 0px 12px 0; vertical-align: middle; width:25%">사업기회 명 </th>'+
'<th style="text-align:center; padding: 13px 0px 12px 0; vertical-align: middle;"> 수주예상일 </th>'+
'<th style="text-align:center; padding: 13px 0px 12px 0"> SCP 견적 등록 여부 </th>'+
'<th style="text-align:center; padding: 13px 0px 12px 0">사업기회 코드</th>'+
'<th style="text-align:center; padding: 13px 0px 12px 0"> 수주금액 </th>'+
'<th style="text-align:center; padding: 13px 0px 12px 0">단계 </th>'+
'</tr>';
for(Opportunity opp : lstOpp9){
String str; 
if(isSandbox){
str = 'https://sdssfa--qa.sandbox.lightning.force.com/lightning/r/Opportunity/' + opp.Id + '/view';
}
else{
str = 'https://sdssfa.lightning.force.com/lightning/r/Opportunity/' + opp.Id + '/view';    
}

String clDate = String.valueOf(opp.CloseDate);
String closeDate = clDate.substring(0,10);
String amt = String.valueOf(opp.Amount/1000000) ;
System.debug('amt Test@ :' + amt);
List<String> amtStr = new List<String>();
String num;
if(amt.contains('.')){
amtStr= amt.split('\\.');
System.debug('amtStr Test@ :'+amtStr);
num = amtStr[0] + '.' + amtStr[1].substring(0,2);
}
else{
num = String.valueOf(opp.Amount/1000000);
}
System.debug('amtStr Test :'+amtStr);

strTemp +=  '<tr>'+
'<td colspan ="2" style="text-align:left; padding: 12px 0px 10px 0; text-decoration: underline">' + '<a style="color:blue" href="' + str + '">'+ opp.Name + '</a>' + '</td>' +
'<td style="text-align:center; padding: 12px 0px 10px 0">' + closeDate + '</td>' +
'<td style="text-align:center; padding: 12px 0px 10px 0">' + '</td>' +
'<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.OpportunityCode__c + '</td>' +
'<td style="text-align:center; padding: 12px 0px 10px 0">' + num + '</td>' +
'<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.get('toLabel_StageName') + '</td>'+  
'</tr>' ;
}
strEmail = strEmail.replace('{!tableString8}', strTemp);
String sDate = String.valueOf(System.now());
strEmail = strEmail.replace('{!DateValue}', sDate);
table8 = true; */
                
                String str = 'https://sdssfa.lightning.force.com/lightning/r/Opportunity/0062w00000B0Uf5AAF/view';
                //String str1 = 'https://sdssfa--qa.sandbox.lightning.force.com/lightning/r/Account/' +  '/view';
                String strTemp = '';
                strTemp += ' <tr>'+
                    '<th colspan ="2" style="text-align:center; padding: 13px 0px 12px 0; vertical-align: middle; width:25%">사업기회 명 </th>'+
                    '<th style="text-align:center; padding: 13px 0px 12px 0; vertical-align: middle;"> 수주예상일 </th>'+
                    '<th style="text-align:center; padding: 13px 0px 12px 0"> SCP 견적 등록 여부 </th>'+
                    '<th style="text-align:center; padding: 13px 0px 12px 0">사업기회 코드</th>'+
                    '<th style="text-align:center; padding: 13px 0px 12px 0"> 수주금액 </th>'+
                    '<th style="text-align:center; padding: 13px 0px 12px 0">단계 </th>'+
                    '</tr>';
                strTemp +=  '<tr>'+
                    '<td colspan ="2" style="text-align:left; padding: 12px 0px 10px 0; text-decoration: underline">' + '<a style="color:blue" href="' + str + '">'+ '[CSP](Q) [미라콤] 사내시스템 클라우드 전환 전환 제안' + '</a>' + '</td>' +
                    '<td  style="text-align:center; padding: 12px 0px 10px 0">' + '2023. 11. 30' + '</td>' +
                    '<td  style="text-align:center; padding: 12px 0px 10px 0">' + 'Y' + '</td>' +
                    '<td style="text-align:center; padding: 12px 0px 10px 0">' + 'SDS-21451890'+ '</td>' +
                    '<td  style="text-align:center; padding: 12px 0px 10px 0">' + '600' + '</td>' + 
                    '<td style="text-align:center; padding: 12px 0px 10px 0">' + 'Qualified'+ '</td>'+ 
                    '</tr>' ;
                String sTemp = '<div class="tbl_tit">' + IntRoman(subHeadingCount) +'. SCP 견적 등록 요청<br/> </div>';    //Adi
                strEmail = strEmail.replace('<div class="tbl_tit">iv. SCP 견적 등록 요청<br/> </div>', sTemp);    //Adi
                subHeadingCount++;	//Adi
                strEmail = strEmail.replace('{!tableString8}', strTemp);
                String sDate = String.valueOf(System.now());
                strEmail = strEmail.replace('{!DateValue}', sDate);
                System.debug('entry repplace'+strEmail);
            }
            Boolean h = false;
            if(lstOpp9.Size()==0){
                strEmail = strEmail.replace('<div class="tbl_tit">iv. SCP 견적 등록 요청<br/> </div>', '');
                strEmail = strEmail.replace('<table  class="tbl_type01"> {!tableString8}</table>', '');     
                h= true;  
            }
            
            if(lstOpp5.Size()==0 && lstOpp6.Size()==0 && lstOpp7.Size()==0 && lstOpp8.Size()==0 && lstOpp9.Size()==0){
                strEmail = strEmail.replace('<div class="tbl_tit"> 3. 사업수행 사전준비<br/>', '');
            }
            
            //Adi Complete If Else
            if(lstOpp5.Size()==0 && lstOpp6.Size()==0 && lstOpp7.Size()==0 && lstOpp8.Size()==0 && lstOpp9.Size()==0){
                strEmail = strEmail.replace('<div class="tbl_tit"> 3. 사업수행 사전준비<br/>', '');  
                strEmail = strEmail.replace('- 금액 단위: 백만단위 (KRW)<br/>', '');
            }else{  //Adi
                String sTemp = '<div class="tbl_tit">' + count + '. 사업수행 사전준비<br/>';
                //sTemp = sTemp + '- 금액 단위: 백만단위 (KRW)<br/>';
                strEmail = strEmail.replace('<div class="tbl_tit"> 3. 사업수행 사전준비<br/>', sTemp);
                //strEmail = strEmail.replace('- 금액 단위: 백만단위 (KRW)<br/>', '');
                count = count +1;
            }
            lstOpp5 = null; 
            lstOpp6 = null;
            lstOpp7 = null;
            lstOpp8 = null;
        }else{
            strEmail = strEmail.replace('<div class="tbl_tit">1. 연간 누적 사업기회 수주 현황<br/>- 금액 : 백만단위 (KRW) </div>','');
            strEmail = strEmail.replace('<table  class="tbl_type01"> {!tableString1}</table><br/> ','');
            strEmail = strEmail.replace('<div class="tbl_tit"> 2.지연 BO 및 수주 예상일 도래 BO<br/>- 금액 단위: 백만단위 (KRW)<br/>', '');
            strEmail = strEmail.replace('i. 지연 BO', '');
            strEmail = strEmail.replace('<table  class="tbl_type01">{!tableString2}</table>', '');
            strEmail = strEmail.replace('<div class="tbl_tit">ii. 수주예상일 도래 BO  </div>', '');
            strEmail = strEmail.replace('<table  class="tbl_type01">  {!tableString3} </table>', '');
            strEmail = strEmail.replace('<div class="tbl_tit"> 3. 사업수행 사전준비<br/>', '');  
            strEmail = strEmail.replace('- 금액 단위: 백만단위 (KRW)<br/>', '');
            strEmail = strEmail.replace('i. 수전위 사전준비</div>', '');
            strEmail = strEmail.replace('<table  class="tbl_type01">  {!tableString4} </table>', '');
            strEmail = strEmail.replace('<table  class="tbl_type01">  {!tableString5} </table>', ''); 
            strEmail = strEmail.replace('<div class="tbl_tit">ii. 인력투입 계획 수립 요청</div>', '');
            strEmail = strEmail.replace('<table  class="tbl_type01">  {!tableString6} </table>', ''); 
            strEmail = strEmail.replace('<div class="tbl_tit">iii. 고객 정보 <br/>' , '' ); 
            strEmail = strEmail.replace('- opendart 정보가 원청고객/계약고객에 대해 현행화 되었으므로 이를 확인하시어 고객 정보를 현행화 하시기 바랍니다 </div>', '');  
            strEmail = strEmail.replace('<table  class="tbl_type01">  {!tableString7} </table> ', '');
            strEmail = strEmail.replace('<div class="tbl_tit">iv. SCP 견적 등록 요청<br/> </div>', '');
            strEmail = strEmail.replace('<table  class="tbl_type01"> {!tableString8}</table>', '');
        }
        
        //Only fot Testing - Table 4
        String strTemp4 = '';
        strTemp4 += ' <tr>'+
            '<th style="text-align:center; padding: 13px 0px 12px 0; vertical-align: middle; width:20%">사업기회 명</th>'+
            '<th style="text-align:center; padding: 13px 0px 12px 0; vertical-align: middle; width:25%"> 유사 사업기회 명  </th>'+
            '<th style="text-align:center; padding: 13px 0px 12px 0"> 유사 사업기회 상태 </th>'+
            '<th style="text-align:center; padding: 13px 0px 12px 0">유사 수주예상액</th>'+
            '<th style="text-align:center; padding: 13px 0px 12px 0"> 수주예상일</th>'+
            '<th style="text-align:center; padding: 13px 0px 12px 0">수전위 </th>'+
            '<th style="text-align:center; padding: 13px 0px 12px 0"> 제안서</th>'+
            '<th style="text-align:center; padding: 13px 0px 12px 0">실행</th>'+
            '<th style="text-align:center; padding: 13px 0px 12px 0"> 위험</th>'+
            '<th style="text-align:center; padding: 13px 0px 12px 0">영업대표 </th>'+
            '<th style="text-align:center; padding: 13px 0px 12px 0">제안PM </th>'+        
            '</tr>';
        //Added By Ashish
        if(lstOppTable4.size() > 0){
            
            for(Opportunity opp : lstOppTable4) {
                integer i =0;
                system.debug('ashish OpptyMatchingMap::'+OpptyMatchingMap);
                if(OpptyMatchingMap.containskey(opp.Id)){
                    integer matchedOPSize = OpptyMatchingMap.get(opp.Id).size();
                    for(Id matchedOPID :  OpptyMatchingMap.get(opp.Id)){
                        Opportunity matchedopp = matchedoppLst.get(matchedOPID);
                        String amt = String.valueOf(matchedopp.Amount/1000000) ;
                        System.debug('amt Test@ :' + amt);
                        List<String> amtStr = new List<String>();
                        String num;
                        if(amt.contains('.')){
                            amtStr= amt.split('\\.');
                            System.debug('amtStr Test@ :'+amtStr);
                            num = amtStr[0] + '.' + amtStr[1].substring(0,2);
                        }
                        else{
                            num = String.valueOf(matchedopp.Amount/1000000);
                        }
                        strTemp4 +=  '<tr>';
                        if(i==0) strTemp4 += '<td rowspan="'+matchedOPSize+'" style="text-align:center; padding: 12px 0px 10px 0;  text-decoration: underline; vertical-align: middle;">' + '<a style="color:blue" href="' + 'https://sdssfa.lightning.force.com/lightning/r/Opportunity/'+opp.Id+'/view' + '">'+ opp.Name + '</a>' + '</td>' ;
                        i++;
                        
                        
                        strTemp4 += '<td style="text-align:center; padding: 12px 0px 10px 0;     ">' + matchedopp.Name + '</td>' +
                            '<td style="text-align:center; padding: 12px 0px 10px 0">' + matchedopp.get('toLabel_StageName') + '</td>' +
                            '<td style="text-align:center; padding: 12px 0px 10px 0">' + num + '</td>' +
                            '<td style="text-align:center; padding: 12px 0px 10px 0">' + matchedopp.CloseDate + '</td>' +
                            '<td style="text-align:center; padding: 12px 0px 10px 0 ">' + '<a style="color:blue" href="' + 'https://www.google.com' + '">'+ '<p style = "font-size:x-large">&bull;</p>' + '</a>' + '</td>' + 
                            '<td style="text-align:center; padding: 12px 0px 10px 0">' + '</td>' +
                            '<td style="text-align:center; padding: 12px 0px 10px 0 ">' + '<a style="color:blue" href="' + 'https://www.google.com' + '">'+ '<p style = "font-size:x-large">&bull;</p>' + '</a>' + '</td>' + 
                            '<td style="text-align:center; padding: 12px 0px 10px 0">' + '</td>'; 
                        if(matchedopp.ProposalPM__c != null) strTemp4 +=  '<td style="text-align:center; padding: 12px 0px 10px 0">' + matchedopp.ProposalPM__c + '</td>';
                        else strTemp4 +=  '<td style="text-align:center; padding: 12px 0px 10px 0"></td>';
                        if(matchedopp.RepresentativePM__c != null) strTemp4 +=  '<td style="text-align:center; padding: 12px 0px 10px 0">' + matchedopp.RepresentativePM__c  +'</td>';
                        else strTemp4 +=  '<td style="text-align:center; padding: 12px 0px 10px 0">	</td>' ;
                        
                        strTemp4 +=  '</tr>' ;
                    }
                }
            }
                   strEmail = strEmail.replace('{!tableString9}', strTemp4);
 
        }
        //Adi Complete If Else Block
        if(lstOppTable4.size() == 0){
            strEmail = strEmail.replace('<div class="tbl_tit">4. 유사 사업기회 정보<br/>', '');
            strEmail = strEmail.replace('- 금액 : 백만단위 (KRW)<br/>', ''); 
        }else{
            String sTemp = '<div class="tbl_tit">' + count + '. 유사 사업기회 정보<br/>';
            strEmail = strEmail.replace('<div class="tbl_tit">4. 유사 사업기회 정보<br/>', sTemp);
            count = count +1;
 
        }
        lstOppTable4 = null;
        /*
strTemp4 +=  '<tr>'+
'<td style="text-align:center; padding: 12px 0px 10px 0;  text-decoration: underline">' + '<a style="color:blue" href="' + 'https://sdssfa.lightning.force.com/lightning/r/Opportunity/0062w00000Hh7diAAB/view' + '">'+ '[US] 091-23 SPE New Factory Infra Network' + '</a>' + '</td>' +
'<td style="text-align:center; padding: 12px 0px 10px 0">' + '[삼성디스플레이(주)] SDC 23년 MIS 노후 네트워크 교체' + '</td>' +
'<td style="text-align:center; padding: 12px 0px 10px 0">' + '수주' + '</td>' +
'<td style="text-align:center; padding: 12px 0px 10px 0">' + '0.97' + '</td>' +
'<td style="text-align:center; padding: 12px 0px 10px 0">' + '2023. 07. 26' + '</td>' +
'<td style="text-align:center; padding: 12px 0px 10px 0 ">' + '<a style="color:blue" href="' + 'https://www.google.com' + '">'+ '<p style = "font-size:x-large">&bull;</p>' + '</a>' + '</td>' + 
'<td style="text-align:center; padding: 12px 0px 10px 0">' + '</td>' +
'<td style="text-align:center; padding: 12px 0px 10px 0 ">' + '<a style="color:blue" href="' + 'https://www.google.com' + '">'+ '<p style = "font-size:x-large">&bull;</p>' + '</a>' + '</td>' + 
'<td style="text-align:center; padding: 12px 0px 10px 0">' + '</td>' +
'<td style="text-align:center; padding: 12px 0px 10px 0">' + '전 병준' + '</td>' +
'<td style="text-align:center; padding: 12px 0px 10px 0">' + '장 현수' +'</td>' +
'</tr>' ;

strTemp4 +=  '<tr>'+
'<td style="text-align:center; padding: 12px 0px 10px 0;  text-decoration: underline">' + '<a style="color:blue" href="' + 'https://sdssfa.lightning.force.com/lightning/r/Opportunity/0062w00000Hh7diAAB/view' + '">'+ '[US] 091-23 SPE New Factory Infra Network' + '</a>' + '</td>' +
'<td style="text-align:center; padding: 12px 0px 10px 0">' + 'SEIB_Spain Wired Network Improvement' + '</td>' +
'<td style="text-align:center; padding: 12px 0px 10px 0">' + '수주' + '</td>' +
'<td style="text-align:center; padding: 12px 0px 10px 0">' + '0.39' + '</td>' +
'<td style="text-align:center; padding: 12px 0px 10px 0">' + '2023. 06. 27' + '</td>' +
'<td style="text-align:center; padding: 12px 0px 10px 0">' + '<a style="color:blue" href="' + 'https://www.google.com' + '">'+ '<p style = "font-size:x-large">&bull;</p>' + '</a>' + '</td>' + 
'<td style="text-align:center; padding: 12px 0px 10px 0">' + '</td>' +
'<td style="text-align:center; padding: 12px 0px 10px 0">' + '<a style="color:blue" href="' + 'https://www.google.com' + '">'+ '<p style = "font-size:x-large">&bull;</p>' + '</a>' + '</td>' + 
'<td style="text-align:center; padding: 12px 0px 10px 0">' + '</td>' +
'<td style="text-align:center; padding: 12px 0px 10px 0">' + '유 연성' + '</td>' +
'<td style="text-align:center; padding: 12px 0px 10px 0">' + '정 태원' +'</td>' +
'</tr>' ;

strTemp4 +=  '<tr>'+
'<td style="text-align:center; padding: 12px 0px 10px 0;  text-decoration: underline">' + '<a style="color:blue" href="' + 'https://sdssfa.lightning.force.com/lightning/r/Opportunity/0062w00000Hh7diAAB/view' + '">'+ '[US] 091-23 SPE New Factory Infra Network' + '</a>' + '</td>' +
'<td style="text-align:center; padding: 12px 0px 10px 0">' + '[삼성에스디아이 (주)] 무선 인프라 구축 확산' + '</td>' +
'<td style="text-align:center; padding: 12px 0px 10px 0">' + '수주' + '</td>' +
'<td style="text-align:center; padding: 12px 0px 10px 0">' + '58.94' + '</td>' +
'<td style="text-align:center; padding: 12px 0px 10px 0">' + '2023. 06. 16' + '</td>' +
'<td style="text-align:center; padding: 12px 0px 10px 0">' + '<a style="color:blue" href="' + 'https://www.google.com' + '">'+ '<p style = "font-size:x-large">&bull;</p>' + '</a>' + '</td>' + 
'<td style="text-align:center; padding: 12px 0px 10px 0">' + '</td>' +
'<td style="text-align:center; padding: 12px 0px 10px 0">' + '<a style="color:blue" href="' + 'https://www.google.com' + '">'+ '<p style = "font-size:x-large">&bull;</p>' + '</a>' + '</td>' + 
'<td style="text-align:center; padding: 12px 0px 10px 0">' + '</td>' +
'<td style="text-align:center; padding: 12px 0px 10px 0">' + '전 병준' + '</td>' +
'<td style="text-align:center; padding: 12px 0px 10px 0">' + '장 현수' +'</td>' +
'</tr>' ;*/
        
        for(User usr : listScope){
            String htmlvalue = '';
            //strEmailTemp = strEmail;
            List<String> emUser = new List<String>();
            emUser.add(usr.Email);
            System.debug('Ani strEmailTemp : '+strEmail);
            htmlvalue  += '<tr style="background-color: #eeeeee;">' + '<td colspan="2" style="text-align: center;font-weight: bold;">'+usr.Name+'</td>' + '<td style="font-weight: bold;">'+usr.Id+'</td>' + '<td style="text-align: right;font-weight: bold;">'+usr.Id+'</td>' + '</tr>';
            strEmail = strEmail.replace('{!tableString1}', '');
            strEmail = strEmail.replace('{!tableString2}', '');
            strEmail = strEmail.replace('{!tableString3}', '');
            strEmail = strEmail.replace('{!tableString4}', '');
            strEmail = strEmail.replace('{!tableString5}', '');
            strEmail = strEmail.replace('{!tableString6}', '');
            strEmail = strEmail.replace('{!tableString7}', '');
            strEmail = strEmail.replace('{!tableString8}', '');
            strEmail = strEmail.replace('{!tableString9}', '');
            strEmail = strEmail.replace('{!DateValue}', String.valueof(System.now()));
            System.debug('Ani strEmail : '+strEmail);
            if(isSandbox){
                if(!Test.isRunningTest()) mailresult = OpportunityEmailAlertController.sendKnoxEmailMulti(senderEmployee, usr.Id, toList, ccList, bccList, strTitle, strEmail, efileList, nfileList);
                if(mailresult.get('INTERFACE_LOG') != null) ifLog.add((IF_Log.InterfaceLog)mailresult.get('INTERFACE_LOG'));
            }
            else{
                if(!Test.isRunningTest()) mailresult = OpportunityEmailAlertController.sendKnoxEmailMulti(senderEmployee, usr.Id, toList, ccList, bccList, strTitle, strEmail, efileList, nfileList);
                if(mailresult.get('INTERFACE_LOG') != null) ifLog.add((IF_Log.InterfaceLog)mailresult.get('INTERFACE_LOG')); 
            }
        }
    }
    
    public void finish(Database.BatchableContext BC){
        System.debug('### Batch_OpptyEmailController :: finish');        
        System.debug('### Batch_OpptyEmailController :: finish :: ifLog.size() : ' + ifLog.size());
        if(ifLog.size() > 0){
            IF_Log log = new IF_Log();
            log.createLog(ifLog);
        }
        
    }
    
    public void execute(SchedulableContext SC){
        DataBase.executeBatch(new Batch_WeeklySalesReport(), 5);
    }    
    
    public static string IntRoman(Integer i){
        system.debug('trying to save');
        if(i == 1) return 'i';
        if(i == 2) return 'ii';
        if(i == 3) return 'iii';  
        if(i == 4) return 'iv';
        if(i == 5) return 'v';
        return '';
    }
    
 
   
}