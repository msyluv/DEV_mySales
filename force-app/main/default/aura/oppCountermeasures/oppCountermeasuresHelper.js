/**  @author         : divyam.gupta@samsung.com
  @description       : Add new tab Analysis of Competition Result. 
  @last modified on  : 05-30-2023
  @last modified by  : divyam.gupta@samsung.com
  Modifications Log 
  Ver   Date         Author                   	Modification
  1.0   2022-10-17   Divyam.gupta@samsung.com       Initial Version
  1.1   2023-05-30   divyam.gupta@samsung.com   Add on changes Lost Enchacement(Mysales -204)
**/
({
    
    
    getOppActivitystatus: function(component,event){
        var self = this;
        var oppActid = component.get("v.opptyActId");
        self.apex(component, 'getOppActivitystatus', {oppActid: oppActid}).then(function(result){
            //   window.console.log('result : ', result);
            
            console.log('activity status Test@@ : ', result);  
            if(result != ''){
                console.log("losttypecoming-->",result.LostType__c);
                if(result.LostType__c == 'Z06'){
                    component.set("v.losttypeval",'Lost');
                }
                if(result.LostType__c == 'Z07'){
                    component.set("v.losttypeval",'Drop');
                }
                component.set("v.activitystatus",result.Status__c);
                if(component.get("v.activitystatus") == 'In Progress')
                {
                    component.set("v.savedisable",true);
                    component.set("v.copylostypedisble",true);
                }
                else {
                    component.set("v.savedisable",false);
                    component.set("v.copylostypedisble",false);
                    
                }
            }
            
        }).catch(function(errors){
            self.errorHandler(errors);
        });
        
    },
    getlostresultlvlval : function(component,event){
        var self = this;
        var oppid = component.get('v.opprecordId');
        console.log('oppidval',oppid);
        var apexParams = { 'OppId' : component.get('v.opprecordId'),
                          'korlang' : component.get('v.setLangKor'),
                          'lostdroptype' : component.get('v.losttypeval'),
                          'oppcActid' : component.get('v.opptyActId')}; 
        self.apex(component,'getLostResultRec',apexParams).then(function(result){
            console.log('test divyam-->');
            console.log('the size',result.length);
            if(result.length > 0){
                
                var countermsrlist = result;
                console.log('countermsrlistval',countermsrlist);
                countermsrlist[0].isChecked = true;
                var lostactnIndex = parseInt(component.get("v.lostactIndex"));
                for(let i=0; i < countermsrlist.length; i++){
                    
                    var lv2data = countermsrlist[i].lvl2Recordlst;
                    console.log('lv2data',lv2data);
                    var lv3data = countermsrlist[i].lvl3Recordlst;
                    var lv2data1 = [];
                    var lv3data1 = [];
                    for(let i=0;i<lv2data.length;i++){
                        lv2data1.push({label: lv2data[i], value: lv2data[i]});           
                    }
                    for(let i=0;i<lv3data.length;i++){
                        lv3data1.push({label: lv3data[i], value: lv3data[i]});           
                    }
                    countermsrlist[i].lvl2Recordlst = lv2data1;
                    countermsrlist[i].lvl3Recordlst = lv3data1;
                    
                    console.log('enter into the loop');
                    countermsrlist[i].actionItem = '';
                    countermsrlist[i].countermeasure = '';
                    countermsrlist[i].mangdeptcode = '';
                    countermsrlist[i].mangdeptcode = '';
                    
                    countermsrlist[i].variant = 'error';
                    
                }
                component.set("v.counterMeasureList",countermsrlist);
                // START 1.1
                var countcopy = 0;
                var countcopylr = component.get('v.countcopylost');
                if(component.get('v.checkcopyanlysisval') == 'CopyAnalysis'){
                    countcopy++;
                    countcopylr = countcopylr + countcopy;
                }
                component.set('v.countcopylost',countcopylr);
                console.log('countcopylost',component.get('v.countcopylost'));
                if(component.get('v.countcopylost') != 1){
                    self.showMyToast('success',$A.get("$Label.c.Copy_Success_Msg"));
                }
                
                // END 1.1
                component.set("v.confirmpopup",false);
                var lostresltlist1 = component.get("v.counterMeasureList");
                var addsize1;
                for(let i=0;i <lostresltlist1.length; i++){
                    if(lostresltlist1[i].Checked == true){
                        addsize1 = i;
                    }
                    
                }
                component.set("v.counterltsize",addsize1);
                // totalvalist = result;
                // START 1.1
                var countcopy = 0;
                var countcopylr = component.get('v.countcopylost1');
                if(component.get('v.checkcopyanlysisval') == 'CopyAnalysis'){
                    countcopy++;
                    countcopylr = countcopylr + countcopy;
                }
                component.set('v.countcopylost1',countcopylr);
                if(component.get('v.countcopylost1') == 1){
                    self.insertCounterMeasure(component,event);
                }
                
                // END 1.1
            }
            
            
            
            else {
                // self.addRow(component,event);
                component.set("v.confirmpopup",false);
                
                
            }
        }).catch(function(errors){
            self.errorHandler(errors);
        });
        
    },
    getcounterMeasure: function(component,event){ 
        var self=this;
        var countermsrlist = component.get("v.counterMeasureList");
        var lostactnList = component.get("v.lostActionList");
        var lav2list =[];
        var apexParams = { 'OppId' : component.get('v.opprecordId'),
                          'korlang' : component.get('v.setLangKor'),
                          'oppActid' : component.get('v.opptyActId')}; 
        self.apex(component, 'getcounterMeasure', apexParams).then(function(result){
            if(result.length > 0){
                var listsize = parseInt(result.length) - parseInt(1);
                component.set("v.counterltsize",listsize);
                countermsrlist = result;
                // totalvalist = result;
                countermsrlist[0].isChecked = true;
                for(let i = 0; i < countermsrlist.length; i++){
                    var lv2data = countermsrlist[i].lvl2Recordlst;
                    console.log('lv2data',lv2data);
                    var lv3data = countermsrlist[i].lvl3Recordlst;
                    var lv2data1 = [];
                    var lv3data1 = [];
                    for(let i=0;i<lv2data.length;i++){
                        lv2data1.push({label: lv2data[i], value: lv2data[i]});           
                    }
                    for(let i=0;i<lv3data.length;i++){
                        lv3data1.push({label: lv3data[i], value: lv3data[i]});           
                    }
                    console.log('lv2data coming->',lv2data1);
                    countermsrlist[i].lvl2Recordlst = lv2data1;
                    countermsrlist[i].lvl3Recordlst = lv3data1;
                    
                }
                component.set("v.counterMeasureList",countermsrlist);  
                
                if(component.get('v.activitystatus') == 'In Progress'){
                    for(let i = 0; i < countermsrlist.length; i++){
                        countermsrlist[i].lv1disable = true;
                        countermsrlist[i].lv2disable = true;
                        countermsrlist[i].lv3disable = true;
                        countermsrlist[i].actionItemdisable = true;
                        countermsrlist[i].countermsrdisable = true;
                        countermsrlist[i].mangdeptdisable = true;
                        countermsrlist[i].deadlinedisable = true;
                        countermsrlist[i].variant = 'brand';
                        
                    }
                    
                    
                }
                else{
                    for(let i = 0; i < countermsrlist.length; i++){
                        
                        countermsrlist[i].variant = 'error';
                        
                    }
                }
                component.set("v.counterMeasureList",countermsrlist);  
                
            }
            
            
            else {
                // self.getlostresultlvlval(component,event);
                self.addRow(component,event);
                component.set("v.counterltsize",0);
                
                
            }
        }).catch(function(errors){
            self.errorHandler(errors);
        });
        
    },
    changeLostType: function(component,event){
        var itemId = event.getSource().get('v.name'); 
        component.set('v.currIndex',itemId.replace('combobox1_',''));
        var curntindx = component.get("v.currIndex");
        console.log('divyam113-->',curntindx);
        
        var cuntrmsrlst = component.get("v.counterMeasureList");
        var curntval = cuntrmsrlst[curntindx].lvl1Record;
        console.log('currentval-->'+curntval);
        component.set("v.combo1val",curntval);
        console.log('divyam1-->');
        cuntrmsrlst[curntindx].lvl2Record = '';
        cuntrmsrlst[curntindx].lvl3Record = '';
        cuntrmsrlst[curntindx].lvl2Recordlst = [];
        cuntrmsrlst[curntindx].lvl3Recordlst = [];
        
        component.set("v.counterMeasureList",cuntrmsrlst);
        this.rowSelect(component,event);
        this.getLosttype2(component,event);
        
        
    },
    
    
    changeLostType1: function(component,event){
        var itemId = event.getSource().get('v.name'); 
        console.log('divyam112-->');
        component.set('v.currIndex',itemId.replace('combobox2_',''));
        var curntindx = component.get("v.currIndex");
        var countrmsrlst = component.get("v.counterMeasureList");
        var curntval = countrmsrlst[curntindx].lvl2Record;
        console.log('currentval1-->'+curntval);
        // var checkcom1boval = component.find("combobox2");
        //  var getvalue1 = checkcom1boval.get("v.value");
        component.set("v.combo2val",curntval);
        countrmsrlst[curntindx].lvl3Record = '';
        
        component.set("v.counterMeasureList",countrmsrlst);
        
        this.getLosttype3(component,event);
        console.log('divyam1-->');
        //this.getLosttype1(component,event);
        
    },
    
    addRow: function(component,event){
        var lostresltlist=  component.get("v.counterMeasureList");
        
        var lostactionlist = [];
        var lostactnIndex = component.get("v.lostactIndex");
        var actitem = ('ActionItem' + lostactnIndex);
        
        
        lostresltlist.push({
            'lvl1Record': '',
            'lvl2Record' : '',
            'lvl3Record' : '',
            'cId' : ''
            ,'Checked' : true,
            'isChecked': (lostresltlist.length == 0) ? true : false,		//use radio button check value
            'lvl2Recordlst' : [],
            'lvl3Recordlst'  : [],
            'lv1disable' : false,
            'lv2disable' : false,
            'lv3disable' : false, 
            'actionItem' : '',
            'countermeasure' : '',
            'mangdeptcode'   : '',
            'deadline'      : '',
            'actionItemdisable' : false,
            'countermsrdisable' : false,
            'mangdeptdisable'  : false,
            'deadlinedisable'  : false,
            'variant'   : 'error'
            
            
        });
        
        
        component.set("v.counterMeasureList",lostresltlist);
        var lostresltlist1 = component.get("v.counterMeasureList");
        var addsize1;
        for(let i=0;i <lostresltlist1.length; i++){
            if(lostresltlist1[i].Checked == true){
                addsize1 = i;
            }
            
        }
        component.set("v.counterltsize",addsize1);
    },
    
    /** addActionRowCopy : function(component,event){
             var countrmsrtlist=  component.get("v.counterMeasureList");
                    console.log('enter into the fun');

            var lostactnIndex = parseInt(component.get("v.lostactIndex"));

        for(let i=0; i < countrmsrtlist.length; i++){
            console.log('enter into the loop');
            var lostactionlist= [];
         var actitem = ('ActionItem' + lostactnIndex);
            lostactionlist.push({  Countermeasure__c : '',
             ActionItem_InChargeDept__c : '',
             ActionItem_RelavantDept__c : '',
             ACTION_ITEM_COMPLETION_DATE__c : '', 
             ActionItem__c : '',
            Name  : actitem  
                          });
           countrmsrtlist[i].lostactnList = lostactionlist;


        
        }
        component.set('v.counterMeasureList',countrmsrtlist);
        console.log('valeofcountrmsrtlist',component.get('v.counterMeasureList'));
    }, **/
    /*addActionRow: function(component,event){
         var curntindx = component.get("v.currIndex") ;
        var lostactnIndex = parseInt(component.get("v.lostactIndex"));
        console.log('lostactnIndexval',lostactnIndex);
        var lostactnlist =[];

        var countrmsrtlist=  component.get("v.counterMeasureList");
         var curntcntrlst = countrmsrtlist[curntindx].lostactnList;
         var actitem = ('ActionItem' + lostactnIndex);
         console.log('before insert-->',curntcntrlst);

        curntcntrlst.push({  Countermeasure__c : '',
             ActionItem_InChargeDept__c : '',
             ActionItem_RelavantDept__c : '',
             ActionItem__c : '',
            ACTION_ITEM_COMPLETION_DATE__c : '', 
            Name  : actitem ,
             variant : 'error'              
                          });
        
        console.log('after insert-->',curntcntrlst);
 
       
        component.set("v.counterMeasureList",countrmsrtlist);
     },
    */
    getLosttype1: function(component,event){ 
        
        var self=this;
        //Start V 1.1 @rakshit.s@samsung.com Dynamic CheckBox Function 
        //
        var tableData = [];
        var checkedIndexes = [];
        var uncheckedIndexes = [];
        
        console.log('recid------>'  + component.get('v.opprecordId'));
        
        var selectedrecord = []
        var apexParams = { 'OppId' : component.get('v.opprecordId'),
                          'korlang' : component.get('v.setLangKor'),
                          'oppActid' : component.get('v.opptyActId')}; 
        self.apex(component, 'getLosttype1', apexParams).then(function(result){
            window.console.log('result : ', JSON.stringify(result));
            var lostdata = [];
            var lostdata1 = [];
            var lostdata2 = [];
            var lostdata3 = [];
            
            var resultdata =  JSON.parse(result);
            var losttypelv1eng = resultdata.level1val;
            var losttypelv2eng = resultdata.level2val;
            var losttypelv3eng = resultdata.level3val;
            
            console.log('losttypeeng',losttypelv1eng);
            
            for (let i = 0; i < losttypelv1eng.length; i++) {
                lostdata1.push({label: losttypelv1eng[i], value: losttypelv1eng[i]});           
            }
            for (let i = 0; i < losttypelv2eng.length; i++) {
                lostdata2.push({label: losttypelv2eng[i], value: losttypelv2eng[i]});           
            }
            for (let i = 0; i < losttypelv3eng.length; i++) {
                lostdata3.push({label: losttypelv3eng[i], value: losttypelv3eng[i]});           
            }
            var countermsrlst = component.get("v.counterMeasureList");
            
            
            component.set("v.LostTypeList", lostdata1);
            //    component.set("v.counterMeasureList", countermsrlst);
            
            
            
            
            // self.apex()
        }).catch(function(errors){
            self.errorHandler(errors);
        });
        
    },
    getLosttype2: function(component,event){ 
        
        var self=this;
        //Start V 1.1 @rakshit.s@samsung.com Dynamic CheckBox Function 
        
        console.log('recid------>'  + component.get('v.opprecordId'));
        
        var apexParams = { 'OppId' : component.get('v.opprecordId'),
                          'korlang' : component.get('v.setLangKor'),
                          'level1combo': component.get('v.combo1val'),
                          'lostdroptype' : component.get('v.losttypeval')}; 
        
        self.apex(component, 'getLosttype2', apexParams).then(function(result){
            window.console.log('result : ', JSON.stringify(result));
            var lostdata = [];
            var lostdata2 = [];
            
            var resultdata =  JSON.parse(result);
            var losttypelv2eng  = resultdata.level2val;
            
            
            for (let i = 0; i < losttypelv2eng.length; i++) {
                lostdata2.push({label: losttypelv2eng[i], value: losttypelv2eng[i]});           
            }
            
            var curntindx = component.get("v.currIndex");
            console.log('current index',curntindx);
            var countermsrlst = component.get("v.counterMeasureList");
            var lostrst = countermsrlst[curntindx];
            lostrst.lvl2Recordlst = lostdata2;
            console.log('divyam2222',lostdata2);
            component.set("v.counterMeasureList",countermsrlst);
            
            
            
            // self.apex()
        }).catch(function(errors){
            self.errorHandler(errors);
        });
        
    },
    
    getLosttype3: function(component,event){ 
        
        var self=this;
        
        console.log('recid------>'  + component.get('v.opprecordId'));
        
        var selectedrecord = []
        var apexParams = { 'OppId' : component.get('v.opprecordId'),
                          'korlang' : component.get('v.setLangKor'),
                          'level2combo': component.get('v.combo2val'),
                          'lostdroptype' : component.get('v.losttypeval')};
        self.apex(component, 'getLosttype3', apexParams).then(function(result){
            console.log('result1 : ', JSON.stringify(result));
            var lostdata3 = [];
            
            var resultdata =  JSON.parse(result);
            var losttypelv3eng  = resultdata.level3val;
            
            
            for (let i = 0; i < losttypelv3eng.length; i++) {
                lostdata3.push({label: losttypelv3eng[i], value: losttypelv3eng[i]});           
            }
            
            var curntindx = component.get("v.currIndex");
            var countermsrlst = component.get("v.counterMeasureList");
            var lostrst = countermsrlst[curntindx];
            lostrst.lvl3Recordlst = lostdata3;
            // console.log('data3val-->',lostdata3);
            component.set("v.counterMeasureList",countermsrlst);
            
            
            
            // self.apex()
        }).catch(function(errors){
            self.errorHandler(errors);
        });
        
    },
    
    checkSpecialChar: function(component,event){
        var countrmsrlst=  component.get("v.counterMeasureList");
        //  var regex = /^[^a-zA-Z0-9^ㄱㄲㄴㄷㄸㄹㅁㅂㅃㅅㅆㅇㅈㅉㅊㅋㅌㅍㅎㅏㅐㅑㅐㅓㅔㅕㅖㅗㅘㅙㅚㅛㅜㅝㅞㅟㅠㅡㅢㅣ]+$/;
        
        // var regex = /^[^a-zA-Z0-9]+$/;
        var regurwexp = ['^','.','*','-','@','!','#','$','%','&','(',')','_','+','[',']','|','~','=','`','{','}',':',';','<','>','?','/',' '];
        var countrmsrchk = false;
        var actionchk = false;
        var checkspclchrdetails= false;
        var matchvar = '';
        var matchvar1 = '';
        for(let i=0 ; i<countrmsrlst.length; i++){
            if(countrmsrlst[i].Checked == true ){
                var countrmsrval;
                var actionval;
                var countrvalue = countrmsrlst[i].countermeasure;
                if(countrvalue != '' && countrvalue != undefined){
                    countrmsrval = countrvalue.replace(/[\r\n]+/gm,"");
                    for(let k=0;k < countrmsrval.length;k++  ){
                        for(let j=0 ; j < regurwexp.length; j++){
                            if(countrmsrval[k] == regurwexp[j]){
                                matchvar = matchvar + regurwexp[j];
                                break;
                            }
                        }
                        console.log('matchvar',matchvar);
                        
                    }
                    
                }
                
                var actionvalue = countrmsrlst[i].actionItem;
                if(actionvalue != '' && actionvalue != undefined){
                    // var imprvrsnval = imprvrsnvalue.replace(/ /g, "");
                    actionval = actionvalue.replace(/[\r\n]+/gm,"");
                    
                    for(let k=0;k < actionval.length;k++  ){
                        for(let j=0 ; j < regurwexp.length; j++){
                            if(actionval[k] == regurwexp[j]){
                                matchvar1 = matchvar1 + regurwexp[j];
                                break;
                            }
                        }
                        
                    }
                    
                }
                
                
                
                if(matchvar1 == actionval && actionvalue != '' && actionvalue != undefined){
                    actionchk = true;
                    
                }
                
                if(matchvar == countrmsrval && countrmsrval != '' && countrmsrval != undefined){
                    countrmsrchk = true;
                    
                    
                }
                
            }
            
            
        }
        if(actionchk == true || countrmsrchk == true){
            component.set("v.checkspclChar",true);
            this.showMyToast('error',$A.get("$Label.c.Special_Char_Err_Msg"));
        }
        else {
            component.set("v.checkspclChar",false);
            
        }
    },
    
    rowSelect: function(component,event){
        var currIndex = component.get('v.currIndex');
        var countrmsrlst=  component.get("v.counterMeasureList");
        
        if(countrmsrlst == undefined || countrmsrlst == null) return;
        
        if(countrmsrlst.length > 0){
            for(var i =0; i < countrmsrlst.length; i++){
                if(i == currIndex) countrmsrlst[i].isChecked = true;
                else countrmsrlst[i].isChecked = false;
            }
            component.set('v.counterMeasureList', countrmsrlst);
        } 
    },
    
    removeRow: function(component,event){
        var countermsrlst = component.get("v.counterMeasureList");
        var countermsrlst1 = [];
        //Get the target object
        var index = event.currentTarget.getAttribute("data-itemId");
        var rcid = countermsrlst[index].cId;
        console.log('indexval',index);
        countermsrlst[index].Checked = false;
        component.set("v.counterMeasureList",countermsrlst);
        var lostresltlist1 = component.get("v.counterMeasureList");
        var addsize1;
        for(let i=0;i <lostresltlist1.length; i++){
            if(lostresltlist1[i].Checked == true){
                addsize1 = i;
            }
            
        }
        component.set("v.counterltsize",addsize1);
        //Get the selected item index
        //Remove single record from account list
        
    },
    /*removeActionRow: function(component,event){
       var curntindx = component.get("v.currIndex");
        var countrmsrtlist=  component.get("v.counterMeasureList");
         var curntcntrlst = countrmsrtlist[curntindx].lostactnList;
        //Get the target object
        var index = event.currentTarget.getAttribute("data-itemId");
        console.log('indexval',index);
        //Get the selected item index
        //Remove single record from account list
        curntcntrlst.splice(index, 1);
        //Set modified account list
        component.set("v.counterMeasureList", countrmsrtlist);
    },
    */
    insertCounterMeasure: function(component,event){
        var self=this;
        var inptval = component.get("v.counterMeasureList");
        var inptcountmsr = [];
        for (let i = 0; i < inptval.length; i++) {
            if(inptval[i].Checked == true){
                inptcountmsr.push(inptval[i]);
                
            }
            var actmdept = inptval[i].mangdeptcode;
            if(typeof actmdept != 'string'){
                inptval[i].mangdeptcode = '';
            }
            
            
        }
        
        component.set('v.counterMeasureList',inptcountmsr);
        
        var inptval1 = component.get("v.counterMeasureList");
        console.log('inptval1',inptval1);
        
        var allInput= JSON.stringify(inptval1);
        console.log('data after stringify',allInput);
        var OppparendId = component.get("v.opprecordId");
        console.log('the oppid-->'+OppparendId);
        var oppActid = component.get("v.opptyActId");
        console.log('the oppactid-->'+oppActid);
        var kornlang = component.get('v.setLangKor');
        var lostdroptypeval =component.get('v.losttypeval');
        
        self.apex(component, 'insertCounterMeasure', {inpVal: allInput,Oppid: OppparendId, oppActivityid: oppActid, korlang : kornlang,lostdroptype : lostdroptypeval}).then(function(result){
            window.console.log('result  code: ', result);
            
            if(result != ''){
                // START 1.1
                var countcopy = 0;
                var countcopylr = component.get('v.countcopylost2');
                if(component.get('v.checkcopyanlysisval') == 'CopyAnalysis'){
                    countcopy++;
                    countcopylr = countcopylr + countcopy;
                }
                component.set('v.countcopylost2',countcopylr);
                if(component.get('v.countcopylost2') != 1){
                    self.showMyToast('success',$A.get("$Label.c.Saved_Success_Msg"));
                }
                // 
                var countrmsrlst = component.get('v.counterMeasureList');
                
                
            }
        }).catch(function(errors){
            self.errorHandler(errors);
        });
    },
    
    checklvlvalue: function(component,event){
        var inptval = component.get("v.counterMeasureList");
        for(let i = 0 ;i<inptval.length;i++){
            if(inptval[i].lvl3Record == '' &&  inptval[i].Checked == true){
                this.showMyToast('error',$A.get("$Label.c.Lvl_check_error"));
                component.set("v.lvlcheck",true);
                
            }
            else {
                component.set("v.lvlcheck",false);
                
            }
        }
    },
    checkDuplicateValue: function(component,event){
        var inptval = component.get("v.counterMeasureList");
        var index = 0;
        var duplicatevallist = [];
        for (let i = 0; i < inptval.length - 1; i++) {
            if(inptval[i].Checked == true){
                for (let j = i + 1; j < inptval.length; j++) {
                    if(inptval[j].Checked == true){
                        if (inptval[i].lvl3Record === inptval[j].lvl3Record) {
                            duplicatevallist[index] = inptval[i].lvl3Record;
                            index++;
                        }
                    }
                }
            }
        }
        console.log('duplicatevallist',duplicatevallist);
        
        if(duplicatevallist.length > 0){
            component.set("v.level3duplicate",true);
            this.showMyToast('error',$A.get("$Label.c.Error_Duplicate_Value"));
            
        }
        else{
            component.set("v.level3duplicate",false);
            
        }
    },
    
    checkCompletionDate: function(component, event){
        
        var getcountermsrlst = component.get("v.counterMeasureList");
        component.set("v.checkComplDate",false);
        
        for(let i=0; i < getcountermsrlst.length ; i++){
            if(getcountermsrlst[i].Checked == true){
                for(let j=0; j<getcountermsrlst[i].lostactnList.length ; j++){
                    var compdate = getcountermsrlst[i].lostactnList[j].ACTION_ITEM_COMPLETION_DATE__c;
                    console.log('compldate',compdate);
                    var today = new Date();
                    var dd = String(today.getDate()).padStart(2, '0');
                    var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
                    var yyyy = today.getFullYear();
                    
                    var today1 = yyyy + '-' + mm + '-' + dd;
                    console.log('next date',today1);
                    if(compdate >= today1)
                    {
                        console.log('yes');
                    }
                    else{
                        component.set('v.checkComplDate',true);
                        this.showMyToast('error',$A.get("$Label.c.CheckCompletionDate"));
                        
                        
                    }
                }
            }
        }
        
    },
    //START 1.1
    copyAnalysisLevelValue: function(component,event){ 
        
        var self=this;
        
        console.log('recid------>'  + component.get('v.opprecordId'));
        
        var apexParams = { 'OppId' : component.get('v.opprecordId'),
                          'OppactId' : component.get('v.opptyActId')}; 
        
        self.apex(component, 'copyAnalysisLevelValue', apexParams).then(function(result){
            console.log('result of copyanalysis',result);
            if(result == 'CopyAnalysis')
            {
                component.set('v.checkcopyanlysisval',result);
                console.log('value coming copyanal',component.get("v.checkcopyanlysisval"));
                self.getlostresultlvlval(component,event);
            }  
            // self.apex()
        }).catch(function(errors){
            self.errorHandler(errors);
        });
        
    },
    // END 1.1
    
    
    //added by rakshit segwal.
    
    checkIfDropOrLost : function(component,event){
        
        //var myArgument = cmp.get("v.activityId");
        var action = component.get("c.checkIfLostOrDropOnLoad");
        action.setParams({ recId : component.get("v.opprecordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('intiresultmodalwindow-->' + result);
                if(result){
                    component.set("v.isLost" , true);
                    
                }
                
                else{
                    component.set("v.isDrop" , true);
                }
            }
            else {
                console.log("Error calling Apex method: " + state);
            }
        });
        $A.enqueueAction(action);
    },
    // START 1.1
    getProfilecheck : function(component,event){
        var self=this;
        var apexParams ={}
        self.apex(component, 'getProfilecheck',apexParams).then(function(result){
            window.console.log('result profile check:',result);
            if(result != 'Edit Access'){
                component.set('v.savedisable',true);
            }
            
            // self.apex()
        }).catch(function(errors){
            self.errorHandler(errors);
        });
        
        
    },
    
    // END 1.1
    reload : function(component, helper){
        window.setTimeout(
            $A.getCallback(function() {
                component.find("overlayLib").notifyClose();
            })
            ,1000);
    },
    
    apex : function(component, apexAction, params){
        return new Promise( $A.getCallback( function( resolve, reject ) {
            var action = component.get("c."+apexAction+"");
            action.setParams( params );
            action.setCallback( this, function(callbackResult) {
                if(callbackResult.getState()=='SUCCESS') {
                    resolve( callbackResult.getReturnValue() );
                }
                if(callbackResult.getState()=='ERROR') {
                    console.log('ERROR', callbackResult.getError() ); 
                    reject( callbackResult.getError() );
                }
            });
            $A.enqueueAction( action );
        }));
    },
    
    errorHandler : function(errors){
        var self = this;
        if(Array.isArray(errors)){
            errors.forEach(function(err){
                self.showMyToast('error', err.exceptionType + " : " + err.message);                      
                
            });
        } else {
            console.log(errors);
            self.showMyToast('error', 'Unknown error in javascript controller/helper.')
        }
    },
    showMyToast : function(type, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            duration: 5000,
            mode: 'dismissible',
            message: msg
        });
        toastEvent.fire();
    }
    
})