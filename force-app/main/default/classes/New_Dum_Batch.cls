global class New_Dum_Batch implements DataBase.Batchable<SObject>, DataBase.AllowsCallouts, Schedulable {
    private static Boolean isSandbox = Utils.getIsSandbox();
    private List<IF_Log.InterfaceLog> ifLog = new List<IF_Log.InterfaceLog>();
    public static Map<String,Object> mailresult = new Map<String,Object>(); 
    private List<KnoxEmail__c> KnoxEmailList = new List<KnoxEmail__c>();
    private List<Id> listOpptyId = new List<Id>();
    private static List<IF_Log__c> listOpptyId1 = new List<IF_Log__c>();

    //System.debug('ani finale');
    
    private static Boolean bTest = false;	//운영 테스트를 위한 Flag 값;
    
    //T110,T120,T140,T640,T641,L1B0,L1E0,ZB01,ZB10
    private static Set<String> setSubsidiary = new Set<String>(System.Label.OPPTYACT_BO_SUBSIDIARY_LIST.split(','));  //자회사는 대상에서 제외
    
    //발송 제한된 이메일
    private static List<String> listRestrictedEmail = new List<String>{'mysales@samsung.com'};
    
    
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
        List<Opportunity> oppList = new List<Opportunity>();
        Set<Id> usrId = new Set<Id>();
        DateTime dt = DateTime.now().addDays(-7);
        Map<Id,List<Opportunity>> mIOpp = new Map<Id,List<Opportunity>>();
        usr = [select Id,Email,Name from User where Profile.Name = 'Sales Rep.(HQ)' AND IsActive = true];
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
        WHERE Opportunity__c IN : oppList ORDER BY ItemNumber__c ASC];
        
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
            WHERE Opportunity__c IN : oppFull ORDER BY ItemNumber__c ASC];
             
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
    }
        
        System.debug('### Batch_WeeklySalesReport :: start :: listUser uMapFinal = ' + uMapFinal);
        
        String queryString= '';
        Database.QueryLocator returnScope;
        //listOpptyId1 = [select Id from IF_Log__c];
             
            queryString += ' select Id,Email,Name from User';
            queryString += ' where Profile.Name = \'Sales Rep.(HQ)\' AND IsActive = true ';
        
        returnScope = DataBase.getQueryLocator(queryString);
        System.debug('### Batch_WeeklySalesReport :: start :: listUser size = ' + returnScope);

        return returnScope;

    }
    
    public void execute(Database.BatchableContext BC, List<User> listScope){
        
        System.debug('### Batch_OpptyEmailController :: execute :: listScope = ' + listScope);
        
        Employee__c senderEmployee = Utils.getLoginEmployeeData(UserInfo.getUserId());
        senderEmployee.EvMailAddr__c = 'chae_ho.yang@stage.samsung.com';

        List<String> ccList = new List<String>();
        List<String> bccList = new List<String>();
        List<Map<String, Object>> efileList = new List<Map<String, Object>>();
        List<Map<String, String>> nfileList = new List<Map<String, String>>();
        
       
            List<String> toList = new List<String>(); 
        if(isSandbox){
        //toList.add('anish.jain@stage.partner.samsung.com');
        //toList.add('boram85.jung@stage.samsung.com');
        toList.add('vikrant.ks@stage.samsung.com');//vikrant
        toList.add('saavi.96@stage.partner.samsung.com'); 
        }

            
            String strEmailTemp = '';
            String strEmail = '';
            EmailTemplate em = [SELECT Id,subject FROM EmailTemplate WHERE DeveloperName = 'HQ_Weekly_temp'];
            Id templateId = em.Id;
            strEmail = [SELECT HtmlValue FROM EmailTemplate WHERE Id = :templateId].HtmlValue;
            String strTitle = 'HQ Weekly Sales Report - Sales Rep';
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
            List<Opportunity> lstOpp99 = new List<Opportunity>();
            List<Opportunity> lstOpp999 = new List<Opportunity>();
            //Opportunity lstOpp = new Opportunity();
            lstOpp = [select Id, Amount,Name,OpportunityCode__c,ZP61_PROPOSAL_SUBMIT_DATE__c,ProposalPM__c,ProposalPM__r.Name, cOriginAcc__c, cOriginAcc__r.Owner.Name,cOriginAcc__r.Name, Opportunity_Review_VRB_Type_Confirm__c, StageName,toLabel(StageName) toLabel_StageName,BO1stRegistrationDate__c,CloseDate,XP7_CONDUCT_DATE__c,XP6_CONDUCT_DATE__c, Account.mDomesticForeign__c, CMBizType__c, AccountId,Account.Owner.Name,Account.Name,OriginAcc_BizTypeL1__c,BusinessLevel__c, RecordType.Name from opportunity where  OwnerId = : listScope[0].Id];
        
            Decimal dec= 0;
            Decimal dec1= 0;
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
                if(opp.StageName == 'Z01' || opp.StageName == 'Z02' || opp.StageName == 'Z05'){
                    lstOpp999.add(opp);
                }
                System.debug('Ani lstOpp999 :'+ lstOpp999.Size());
                if((opp.StageName == 'Z01' || opp.StageName == 'Z02' || opp.StageName == 'Z03' || opp.StageName == 'Z04') && Opp.BO1stRegistrationDate__c != null && str.contains(cntYear)){
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
                if((opp.StageName == 'Z01' || opp.StageName == 'Z02' || opp.StageName == 'Z03' || opp.StageName == 'Z04') && opp.Account.mDomesticForeign__c == '20'){
                    //if((System.now() < opp.CloseDate <= System.now().addMonths(+3)))
                    //{
                    lstOpp8.add(opp);
                    //}
                }
                if((opp.StageName == 'Z01' || opp.StageName == 'Z02' || opp.StageName == 'Z03' || opp.StageName == 'Z04') && opp.CMBizType__c == 'CSP_SCP'){
                    //if((System.now() < opp.CloseDate <= System.now().addMonths(+3)))
                    //{
                    lstOpp9.add(opp);
                    //}
                }
            }
            
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
            Integer HeadingCount = 1;
            
            String sDate = String.valueOf(System.now());
            strEmail = strEmail.replace('{!DateValue}', sDate);
            String strTemp = '';
            
            if(lstOpp1.Size()>0 || lstOpp2.Size()>0){
                
                strTemp += '<div class="tbl_tit">'+String.valueOf(HeadingCount) +'. 연간 누적 사업기회 수주 현황<br/>금액 : 백만단위 (KRW) </div>';
                HeadingCount++;
                
                strTemp += '<table  class="tbl_type01"> <tr>'+
                '<th style="text-align:center; padding: 13px 0px 12px 0; vertical-align: middle;">영업대표</th>'+
                '<th style="text-align:center; padding: 13px 0px 12px 0; vertical-align: middle;">수주완료 건수</th>'+
                '<th style="text-align:center; padding: 13px 0px 12px 0">수주완료 금액 </th>'+
                '<th style="text-align:center; padding: 13px 0px 12px 0">올해 수주 예상일로 진행 중인 BO 의 건수</th>'+
                '<th style="text-align:center; padding: 13px 0px 12px 0">올해 수주 예상일로 진행 중인 BO 의 금액 </th>'+
               '</tr>'+
                '<tr>'+
                 '<td style="text-align:center; padding: 12px 0px 10px 0">' + listScope[0].Name + '</td>' +
                 '<td style="text-align:center; padding: 12px 0px 10px 0">' + lstOpp1.Size() + '</td>' +
                 '<td style="text-align:center; padding: 12px 0px 10px 0">' + dec/1000000 + '</td>' +
                 '<td style="text-align:center; padding: 12px 0px 10px 0">' + lstOpp2.Size() + '</td>' +
                 '<td style="text-align:center; padding: 12px 0px 10px 0">' + dec1/1000000 + '</td>'+ 
                 '</tr></table><br/>' ;
              
            }
            Integer subHeadingCount = 1;
            
            if(lstOpp3.Size()>0){
                strTemp += '<div class="tbl_tit">'+String.valueOf(HeadingCount) +'.지연 BO 및 수주 예상일 도래 BO<br/>- 금액 단위: 백만단위 (KRW)</div><br/>';
                strTemp += '<div class="tbl_tit">'+IntRoman(subHeadingCount)+'. 지연 BO</div>';
    			HeadingCount++;subHeadingCount++;
                
                strTemp += '<table  class="tbl_type01"> <tr>'+
                '<th style="text-align:center; padding: 13px 0px 12px 0; vertical-align: middle;">영업대표</th>'+
                '<th style="text-align:center; padding: 13px 0px 12px 0; vertical-align: middle;">사업기회 명</th>'+
                '<th style="text-align:center; padding: 13px 0px 12px 0">사업기회 코드</th>'+
                '<th style="text-align:center; padding: 13px 0px 12px 0">수주예상일</th>'+
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
                    strTemp +=  '<tr>'+
                     '<td style="text-align:center; padding: 12px 0px 10px 0">' + listScope[0].Name  + '</td>' +
                     '<td style="text-align:center; padding: 12px 0px 10px 0">' + '<a href="' + str + '">'+ opp.Name + '</a>' + '</td>' +
                     '<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.OpportunityCode__c + '</td>' +
                     '<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.CloseDate + '</td>' +
                     '<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.get('toLabel_StageName') + '</td>'+ 
                     '<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.Amount/1000000 + '</td>'+ 
                     '</tr>' ;
                }
                //strEmail = strEmail.replace('<div class="tbl_tit">1. 연간 누적 사업기회 수주 현황<br/>금액 : 백만단위 (KRW) </div>','');
                //strEmail = strEmail.replace('<table  class="tbl_type01"> {!tableString1}</table><br/>','');
                //strEmail = strEmail.replace('2.지연 BO 및','1.지연 BO 및');
                strTemp +=  '</table><br/>';
                
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
              
            
            
            if(lstOpp4.Size()>0){
                
                if(subHeadingCount == 1){ 
                    strTemp += '<div class="tbl_tit">'+String.valueOf(HeadingCount) +'.지연 BO 및 수주 예상일 도래 BO<br/>- 금액 단위: 백만단위 (KRW)</div><br/>';
                	HeadingCount++;
            	}
                strTemp += '<div class="tbl_tit">'+IntRoman(subHeadingCount)+'. 수주예상일 도래 BO  </div>';
                strTemp += ' <table><tr>'+
            '<th style="text-align:center; padding: 13px 0px 12px 0; vertical-align: middle;">영업대표</th>'+
            '<th style="text-align:center; padding: 13px 0px 12px 0; vertical-align: middle;">사업기회 명</th>'+
            '<th style="text-align:center; padding: 13px 0px 12px 0">사업기회 코드</th>'+
            '<th style="text-align:center; padding: 13px 0px 12px 0">수주예상일</th>'+
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
            strTemp +=  '<tr>'+
             '<td style="text-align:center; padding: 12px 0px 10px 0">' + listScope[0].Name  + '</td>' +
             '<td style="text-align:center; padding: 12px 0px 10px 0">' + '<a href="' + str + '">'+ opp.Name + '</a>' + '</td>' + 
             '<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.OpportunityCode__c + '</td>' +
             '<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.CloseDate + '</td>' +
             '<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.get('toLabel_StageName') + '</td>'+ 
             '<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.Amount/1000000 + '</td>'+ 
             '</tr>' ;
                }
                //strEmail = strEmail.replace('<div class="tbl_tit"> 2.지연 BO 및 수주 예상일 도래 BO<br/>- 금액 단위: 백만단위 (KRW)<br/>i. ', '');
                //strEmail = strEmail.replace('지연 BO</div><br/><table  class="tbl_type01"> {!tableString2}</table><br/>  ', '');
                //strEmail = strEmail.replace('ii. 수주예상일 도래 BO   ', 'i. 수주예상일 도래 BO ');
                strTemp += '</table><br/>';
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
                
            if(lstOpp5.Size()>0){
                
                strTemp += ' <tr>'+
            '<th style="text-align:center; padding: 13px 0px 12px 0; vertical-align: middle;">수전위 Type </th>'+
            '<th style="text-align:center; padding: 13px 0px 12px 0; vertical-align: middle;">사업 심의 유형 확정 </th>'+
            '<th style="text-align:center; padding: 13px 0px 12px 0">사업기회 명</th>'+
            '<th style="text-align:center; padding: 13px 0px 12px 0">금액</th>'+
            '<th style="text-align:center; padding: 13px 0px 12px 0">입찰결정 실행일</th>'+
            '<th style="text-align:center; padding: 13px 0px 12px 0">제안 제출일	</th>'+
           '</tr>';
                for(Opportunity opp : lstOpp5){
                String str; 
                    if(isSandbox){
                    str = 'https://sdssfa--qa.sandbox.lightning.force.com/lightning/r/Opportunity/' + opp.Id + '/view';
                    }
                    else{
                    str = 'https://sdssfa.lightning.force.com/lightning/r/Opportunity/' + opp.Id + '/view';    
                    } 
            strTemp +=  '<tr>'+
             '<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.Type  + '</td>' +
             '<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.Opportunity_Review_VRB_Type_Confirm__c + '</td>' +
             '<td style="text-align:center; padding: 12px 0px 10px 0">' + '<a href="' + str + '">'+ opp.Name + '</a>' + '</td>' + 
             '<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.Amount/1000000 + '</td>' +
             '<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.XP7_CONDUCT_DATE__c + '</td>'+ 
             '<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.ZP61_PROPOSAL_SUBMIT_DATE__c + '</td>'+ 
             '</tr>' ;
                }
                //strEmail = strEmail.replace('<div class="tbl_tit">1. 연간 누적 사업기회 수주 현황<br/>금액 : 백만단위 (KRW) </div><br/>','');
                //strEmail = strEmail.replace('<table  class="tbl_type01"> {!tableString1}</table><br/>','');
                //strEmail = strEmail.replace('<div class="tbl_tit"> 2.지연 BO 및 수주 예상일 도래 BO<br/>- 금액 단위: 백만단위 (KRW)<br/>i. ', '');
                //strEmail = strEmail.replace('지연 BO</div><br/><table  class="tbl_type01"> {!tableString2}</table><br/>  ', '');
                //strEmail = strEmail.replace('3. 사업수행 사전준비','1. 사업수행 사전준비');
                //strEmail = strEmail.replace('{!tableString4}', strTemp);
                //String sDate = String.valueOf(System.now());
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
            '<th style="text-align:center; padding: 13px 0px 12px 0">제안 제출일	</th>'+
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
            '<th style="text-align:center; padding: 13px 0px 12px 0">제안 제출일	</th>'+
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
            '<th style="text-align:center; padding: 13px 0px 12px 0">제안 제출일	</th>'+
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
            
            
        	subHeadingCount = 1;
            if(lstOpp6.Size()>0){
                strTemp += '<div class="tbl_tit">'+String.valueOf(HeadingCount) +'. 사업수행 사전준비<br/>- 금액 단위: 백만단위 (KRW)</div><br/>';
                strTemp += '<div class="tbl_tit">'+IntRoman(subHeadingCount)+'. 수전위 사전준비</div>';
                HeadingCount++;subHeadingCount++;
                
                strTemp += '<table> <tr>'+
            '<th style="text-align:center; padding: 13px 0px 12px 0; vertical-align: middle;">수전위 Type </th>'+
            '<th style="text-align:center; padding: 13px 0px 12px 0; vertical-align: middle;">사업 심의 유형 확정 </th>'+
            '<th style="text-align:center; padding: 13px 0px 12px 0">사업기회 명</th>'+
            '<th style="text-align:center; padding: 13px 0px 12px 0">금액</th>'+
            '<th style="text-align:center; padding: 13px 0px 12px 0">사업참여 실행일</th>'+
            '<th style="text-align:center; padding: 13px 0px 12px 0">제안 제출일	</th>'+
           '</tr>';
                for(Opportunity opp : lstOpp6){
                  String str; 
                    if(isSandbox){
                    str = 'https://sdssfa--qa.sandbox.lightning.force.com/lightning/r/Opportunity/' + opp.Id + '/view';
                    }
                    else{
                    str = 'https://sdssfa.lightning.force.com/lightning/r/Opportunity/' + opp.Id + '/view';    
                    }
            strTemp +=  '<tr>'+
             '<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.Type  + '</td>' +
             '<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.Opportunity_Review_VRB_Type_Confirm__c + '</td>' +
             '<td style="text-align:center; padding: 12px 0px 10px 0">' + '<a href="' + str + '">'+ opp.Name + '</a>' + '</td>' + 
             '<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.Amount/1000000 + '</td>' +
             '<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.XP6_CONDUCT_DATE__c + '</td>'+ 
             '<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.ZP61_PROPOSAL_SUBMIT_DATE__c + '</td>'+ 
             '</tr>' ;
                }
                strTemp += '</table><br/>';
            }
            
            
            if(lstOpp7.Size()>0){
                if(subHeadingCount == 1){ 
                    strTemp += '<div class="tbl_tit">'+String.valueOf(HeadingCount) +'. 사업수행 사전준비<br/>- 금액 단위: 백만단위 (KRW)</div><br/>';
                	HeadingCount++;
            	}
                strTemp += '<div class="tbl_tit">'+IntRoman(subHeadingCount)+'. 인력투입 계획 수립 요청</div>';
                subHeadingCount++;
                
                strTemp += ' <table><tr>'+
            '<th style="text-align:center; padding: 13px 0px 12px 0; vertical-align: middle;">사업기회 코드 </th>'+
            '<th style="text-align:center; padding: 13px 0px 12px 0; vertical-align: middle;"> 사업기회 명 </th>'+
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
            strTemp +=  '<tr>'+
             '<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.OpportunityCode__c  + '</td>' +
             '<td style="text-align:center; padding: 12px 0px 10px 0">' + '<a href="' + str + '">'+ opp.Name + '</a>' + '</td>' + 
             '<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.CloseDate + '</td>' +
             '<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.Amount/1000000 + '</td>' +
             '<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.get('toLabel_StageName')+ '</td>'+ 
             '<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.ProposalPM__r.Name + '</td>'+
             '<td style="text-align:center; padding: 12px 0px 10px 0">' +  '</td>'+ 
             '<td style="text-align:center; padding: 12px 0px 10px 0">' +  '</td>'+ 
             '</tr>' ;
                }
                strTemp += '</table><br/>';
            }
            
            
            if(lstOpp8.Size()>0){
                if(subHeadingCount == 1){ 
                    strTemp += '<div class="tbl_tit">'+String.valueOf(HeadingCount) +'. 사업수행 사전준비<br/>- 금액 단위: 백만단위 (KRW)</div><br/>';
                	HeadingCount++;
            	}
                strTemp += '<div class="tbl_tit">'+IntRoman(subHeadingCount)+'. 고객 정보 <br/> - opendart 정보가 원청고객/계약고객에 대해 현행화 되었으므로 이를 확인하시어 고객 정보를 현행화 하시기 바랍니다 </div>';
                subHeadingCount++;
                
                strTemp += ' <table><tr>'+
            '<th style="text-align:center; padding: 13px 0px 12px 0; vertical-align: middle;">사업기회 명 </th>'+
            '<th style="text-align:center; padding: 13px 0px 12px 0; vertical-align: middle;"> 수주예상일 </th>'+
            '<th style="text-align:center; padding: 13px 0px 12px 0"> 원청고객 </th>'+
            '<th style="text-align:center; padding: 13px 0px 12px 0">원청고객 owner</th>'+
            '<th style="text-align:center; padding: 13px 0px 12px 0"> 계약고객</th>'+
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
                    
            strTemp +=  '<tr>'+
             '<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.Name  + '</td>' +
             '<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.CloseDate + '</td>' +
             '<td style="text-align:center; padding: 12px 0px 10px 0">' + '<a href="' + str + '">'+ opp.cOriginAcc__r.Name + '</a>' + '</td>' +
             '<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.cOriginAcc__r.Owner.Name + '</td>' +
             '<td style="text-align:center; padding: 12px 0px 10px 0">' + '<a href="' + str1 + '">'+ opp.Account.Name + '</a>' + '</td>' + 
             '<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.Account.Owner.Name + '</td>'+ 
             '</tr>' ;
                }
                strTemp += '</table><br/>';
            }
            
            
            if(lstOpp9.Size()>0){
                if(subHeadingCount == 1){ 
                    strTemp += '<div class="tbl_tit">'+String.valueOf(HeadingCount) +'. 사업수행 사전준비<br/>- 금액 단위: 백만단위 (KRW)</div><br/>';
                	HeadingCount++;
            	}
                strTemp += '<div class="tbl_tit">'+IntRoman(subHeadingCount)+'. SCP 견적 등록 요청<br/> </div>';
                subHeadingCount++;
                
                strTemp += ' <table><tr>'+
            '<th style="text-align:center; padding: 13px 0px 12px 0; vertical-align: middle;">사업기회 명 </th>'+
            '<th style="text-align:center; padding: 13px 0px 12px 0; vertical-align: middle;"> 수주예상일 </th>'+
            '<th style="text-align:center; padding: 13px 0px 12px 0"> SCP 견적 등록 여부 </th>'+
            '<th style="text-align:center; padding: 13px 0px 12px 0">사업기회 코드</th>'+
            '<th style="text-align:center; padding: 13px 0px 12px 0"> 수주예상일 </th>'+
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
            strTemp +=  '<tr>'+
             '<td style="text-align:center; padding: 12px 0px 10px 0">' + '<a href="' + str + '">'+ opp.Name + '</a>' + '</td>' +
             '<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.CloseDate + '</td>' +
             '<td style="text-align:center; padding: 12px 0px 10px 0">' + '</td>' +
             '<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.OpportunityCode__c + '</td>' +
             '<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.Amount/1000000 + '</td>' +
             '<td style="text-align:center; padding: 12px 0px 10px 0">' + opp.get('toLabel_StageName') + '</td>'+  
             '</tr>' ;
                }
                
            }
            strEmail = strEmail.replace('{!tableString}', strTemp);
            
        	for(User usr : listScope){
                    String htmlvalue = '';
                    //strEmailTemp = strEmail;
                    List<String> emUser = new List<String>();
                    emUser.add(usr.Email);
                    System.debug('Ani strEmailTemp : '+strEmail);
                    htmlvalue  += '<tr style="background-color: #eeeeee;">' + '<td colspan="2" style="text-align: center;font-weight: bold;">'+usr.Name+'</td>' + '<td style="font-weight: bold;">'+usr.Id+'</td>' + '<td style="text-align: right;font-weight: bold;">'+usr.Id+'</td>' + '</tr>';
                    strEmail = strEmail.replace('{!tableString}', '');
                    /*strEmail = strEmail.replace('{!tableString2}', '');
                    strEmail = strEmail.replace('{!tableString3}', '');
                    strEmail = strEmail.replace('{!tableString4}', '');
                    strEmail = strEmail.replace('{!tableString5}', '');
                    strEmail = strEmail.replace('{!tableString6}', '');
                    strEmail = strEmail.replace('{!tableString7}', '');
                    strEmail = strEmail.replace('{!tableString8}', '');
                    strEmail = strEmail.replace('{!tableString9}', '');*/
                    System.debug('Ani strEmail : '+strEmail);
                    if(isSandbox){
                if(!Test.isRunningTest()) mailresult = OpportunityEmailAlertController.sendKnoxEmailMulti(senderEmployee, usr.Id, toList, ccList, bccList, strTitle, strEmail, efileList, nfileList);
                if(mailresult.get('INTERFACE_LOG') != null) ifLog.add((IF_Log.InterfaceLog)mailresult.get('INTERFACE_LOG'));
                    }
                    else{
                if(!Test.isRunningTest()) mailresult = OpportunityEmailAlertController.sendKnoxEmailMulti(senderEmployee, usr.Id, emUser, ccList, bccList, strTitle, strEmailTemp, efileList, nfileList);
                if(mailresult.get('INTERFACE_LOG') != null) ifLog.add((IF_Log.InterfaceLog)mailresult.get('INTERFACE_LOG')); 
                    }
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
        DataBase.executeBatch(new Batch_OpptyEmailController(), 5);
    }    
    public static string IntRoman(Integer i){
        if(i == 1) return 'i';
        if(i == 2) return 'ii';
        if(i == 3) return 'iii';
        if(i == 4) return 'iv';
        if(i == 5) return 'v';
        return '';
    }
   
}