/**
      @author            : divyam.gupta@samsung.com
      @description       : Add new tab Analysis of Competition Result. 
      @last modified on  : 2022-10-17
      @last modified by  : divyam.gupta@samsung.com
      Modifications Log save
      Ver   Date         Author                   	Modification
      1.0   2022-10-17   Divyam.gupta@samsung.com       Initial Version
    **/

({
    REFRESH_TREEITEM:'refreshTreeItem',
    POP_SAVE_MODAL:'popupSaveModal',	// opportunityServiceSolutionMain 컴포넌트 Event Parameter
    
    getOppActivitystatus: function(component,event){
        var self = this;
        var oppActid = component.get("v.opptyActId");
        self.apex(component, 'getOppActivitystatus', {oppActid: oppActid}).then(function(result){
            window.console.log('result : ', result);
            console.log('activity status Test@@ : ', result);  
            if(result != '')
            {
                if(result.LostType__c == 'Z06'){
                    component.set("v.losttypeval","Lost");
                    
                }
                if(result.LostType__c == 'Z07'){
                    component.set("v.losttypeval","Drop");
                    
                }
                
                console.log('assignval',component.get("v.losttypeval"));
                
                
                component.set("v.activitystatus",result.Status__c);
                if(component.get("v.activitystatus") == 'In Progress')
                {
                    component.set("v.savedisable",true);
                }
                else {
                    component.set("v.savedisable",false);
                }
            }
            
        }).catch(function(errors){
            self.errorHandler(errors);
        });
        
    },
    addRow: function(component,event){
        /* var curntlistsize = component.get("v.lostresltsize");
            var addsize = curntlistsize + 1;
            component.set("v.lostresltsize",addsize);
            */
        var lostresltlist=  component.get("v.lostReslist");
        var sizeoflostlist = lostresltlist.length + 1;
        console.log('sizeoflostlist',sizeoflostlist);
        console.log('currentindx-->',component.get("v.currIndex"));
        lostresltlist.push({
            'lvl1Record': '',
            'lvl2Record' : '',
            'lvl3Record' : '',
            'recordId'  : '',
            'isChecked': (lostresltlist.length == 0) ? true : false				//use radio button check value
            ,'Checked' : true
            ,'indexval' : sizeoflostlist,
            'detail' : '',
            'ratepercent'   : 0,
            'lvl2Recordlst' : [],
            'lvl3Recordlst'  : [],
            'lv1disable' : false,
            'lv2disable' : false,
            'lv3disable' : false,
            'ratedisable' : false,
            'detaildisable' : false,
            'isdeleted' : true,
            'variant'   : 'error'
        });
        console.log('pushnewelement',lostresltlist);
        component.set("v.lostReslist",lostresltlist);
        console.log('pushnewelementnew',component.get("v.lostReslist"));
        var lostresltlist1 = component.get("v.lostReslist");
        var addsize1;
        for(let i=0;i <lostresltlist1.length; i++){
            if(lostresltlist[i].Checked == true){
                addsize1 = i;
            }
            
        }
        component.set("v.lostresltsize",addsize1);
        
        /* var curnidexval = parseInt(lostresltlist.length) - parseInt(1);
            console.log('curnidexval',curnidexval);
            component.set('v.currIndex',curnidexval);  */
        //  this.rowSelect(component,event);
        
        // this.sendMainEvt(component,this.REFRESH_TREEITEM);
        
    },
    
    rowSelect: function(component,event){
        var currIndex = component.get('v.currIndex');
        var lostresltlist=  component.get("v.lostReslist");
        console.log('currIndex',currIndex);
        if(lostresltlist == undefined || lostresltlist == null) return;
        
        if(lostresltlist.length > 0){
            for(var i =0; i < lostresltlist.length; i++){
                if(i == currIndex) lostresltlist[i].isChecked = true;
                
                else lostresltlist[i].isChecked = false;
            }
            component.set('v.lostReslist', lostresltlist);
        } 
    },
    
    removeRow: function(component,event){
        
        var lostresltlist = component.get("v.lostReslist");
        console.log('Divyam3');
        
        //Get the target object
        var index = event.currentTarget.getAttribute("data-itemId");
        var rcid = lostresltlist[index].recordId;
        //  var recordId = lostresltlist[index].lvl1Record;
        console.log('indexval',index);
        
        if(lostresltlist[index].isdeleted == true){
            var lostresltlist1 =[]; 
            
            lostresltlist[index].Checked = false;
            
            
            
            for(let i=index; i < lostresltlist.length ;i++){
                lostresltlist[i].indexval = parseInt(i)+ parseInt(1);
            }
            console.log('After splice',lostresltlist);
            
            var totalvalue =0;
            var lostresltlist1 = [];
            for(let i=0 ;i < lostresltlist.length; i++){
                if(lostresltlist[i].Checked == true){
                    totalvalue = parseInt(totalvalue) + parseInt(lostresltlist[i].ratepercent);
                    lostresltlist1.push(lostresltlist[i]);
                    console.log('lostrsval-->',lostresltlist[i]);
                }
            }  
            
            
            component.set("v.totalval",totalvalue);
            component.set("v.currIndex",parseInt(index) -1);
            this.rowSelect(component,event);
            
            // lostresltlatestlist = lostresltlist;
            //Set modified account list
            /*var inpt1 =[];
             for(let i=0;i<lostresltlist.length;i++){
                if(lostresltlist[i].Checked == true){
                    inpt1.push(inpt[i]);
                }
            }*/
                component.set("v.lostReslist", lostresltlist);
                var lostresltlist1 = component.get("v.lostReslist");
                console.log('Divyam3');
                var addsize1;
                for(let i=0;i <lostresltlist1.length; i++){
                    if(lostresltlist[i].Checked == true){
                        addsize1 = i;
                    }
                    
                }
                component.set("v.lostresltsize",addsize1);
            }
        },
    
    
    sendMainEvt: function(component, actionName){
        var evt = component.getEvent('mainActEvt');
        evt.setParams({'action': actionName});
        evt.fire();
    },
    
    changeLostType: function(component,event){
        console.log('divyam111-->');
        var itemId = event.getSource().get('v.name'); 
        console.log('divyam112-->');
        component.set('v.currIndex',itemId.replace('combobox1_',''));
        var curntindx = component.get("v.currIndex");
        console.log('divyam113-->',curntindx);
        
        var lostResltlist = component.get("v.lostReslist");
        var curntval = lostResltlist[curntindx].lvl1Record;
        console.log('currentval-->'+curntval);
        component.set("v.combo1val",curntval);
        console.log('divyam1-->');
        lostResltlist[curntindx].lvl2Record = '';
        lostResltlist[curntindx].lvl3Record = '';
        component.set("v.lostReslist",lostResltlist);
        this.rowSelect(component,event);
        
        this.getLosttype2(component,event);
        //  if(lostResltlist[curntindx].lvl2Record != ''){
        //            this.getLosttype3(component,event);
        
        //        }
        
        
    },
    
    
    changeLostType1: function(component,event){
        console.log('divyam111-->');
        var itemId = event.getSource().get('v.name'); 
        console.log('divyam112-->');
        component.set('v.currIndex',itemId.replace('combobox2_',''));
        var curntindx = component.get("v.currIndex");
        var lostResltlist = component.get("v.lostReslist");
        var curntval = lostResltlist[curntindx].lvl2Record;
        console.log('currentval1-->'+curntval);
        // var checkcom1boval = component.find("combobox2");
        //  var getvalue1 = checkcom1boval.get("v.value");
        component.set("v.combo2val",curntval);
        lostResltlist[curntindx].lvl3Record = '';
        component.set("v.lostReslist",lostResltlist);
        
        this.getLosttype3(component,event);
        console.log('divyam1-->');
        //this.getLosttype1(component,event);
        
        
        
    },
    
    getLosttype: function(component,event){ 
        var self=this;
        var lostresltlist = component.get("v.lostReslist");
        var lav2list =[];
        var totalvalue = 0;
        var apexParams = { 'OppId' : component.get('v.opprecordId'),
                          'korlang' : component.get('v.setLangKor'),
                          'oppActid' : component.get('v.opptyActId')}; 
        self.apex(component, 'getLosttype', apexParams).then(function(result){
            if(result.length > 0){
                var listsize = parseInt(result.length) - parseInt(1);
                console.log('listsize',listsize);
                component.set("v.lostresltsize",listsize);
                lostresltlist = result;
                console.log('resultslost-->' + JSON.stringify(lostresltlist));
                // totalvalist = result;
                lostresltlist[0].isChecked = true;
                for(let i=0; i < lostresltlist.length; i++){
                    totalvalue = parseInt(totalvalue) + parseInt(lostresltlist[i].ratepercent);
                    var lv2data = lostresltlist[i].lvl2Recordlst;
                    console.log('lv2data',lv2data);
                    var lv3data = lostresltlist[i].lvl3Recordlst;
                    var lv2data1 = [];
                    var lv3data1 = [];
                    for(let i=0;i<lv2data.length;i++){
                        lv2data1.push({label: lv2data[i], value: lv2data[i]});           
                    }
                    for(let i=0;i<lv3data.length;i++){
                        lv3data1.push({label: lv3data[i], value: lv3data[i]});           
                    }
                    console.log('lv2data coming->',lv2data1);
                    lostresltlist[i].lvl2Recordlst = lv2data1;
                    lostresltlist[i].lvl3Recordlst = lv3data1;
                    
                    if(component.get('v.activitystatus') == 'In Progress'){
                        lostresltlist[i].lv1disable = true;
                        lostresltlist[i].lv2disable = true;
                        lostresltlist[i].lv3disable = true;                       
                        lostresltlist[i].ratedisable = true;		
                        lostresltlist[i].detaildisable = true;
                        lostresltlist[i].variant = 'brand';
                        
                    }
                    if(lostresltlist[i].Apporvestatus == 'Completed'){
                        lostresltlist[i].lv1disable = true;
                        lostresltlist[i].lv2disable = true;
                        lostresltlist[i].lv3disable = true;  
                        lostresltlist[i].isdeleted = false;
                        lostresltlist[i].variant = 'brand';
                        
                    }
                    else if(lostresltlist[i].Apporvestatus != 'In Progress' && lostresltlist[i].Apporvestatus != 'Completed'){
                        lostresltlist[i].isdeleted = true;
                        lostresltlist[i].variant = 'error';
                        
                    }
                    
                    
                }
                component.set("v.lostReslist",lostresltlist);    
                
            }
            // window.console.log('result : ', JSON.stringify(result));
            
            
            else {
                self.addRow(component,event);
                component.set("v.lostresltsize",0);
                
            }
            component.set("v.totalval",totalvalue);
            // self.apex()
        }).catch(function(errors){
            self.errorHandler(errors);
        });
        
        
    },
    //to get returned wrapper from apex on load of component so as to prepopulate the data.
    getLosttype1: function(component,event){ 
        
        var self=this;
        //Start V 1.1 @rakshit.s@samsung.com Dynamic CheckBox Function 
        //
        var tableData = [];
        var checkedIndexes = [];
        var uncheckedIndexes = [];
        
        console.log('recid------>'  + component.get('v.opprecordId'));
        console.log('oppactrecid------>'  + component.get('v.opptyActId'));
        
        var selectedrecord = []
        var apexParams = { 'OppId' : component.get('v.opprecordId'),
                          'korlang' : component.get('v.setLangKor'),
                          'oppActid' : component.get('v.opptyActId')}
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
            var lostresltlist = component.get("v.lostReslist");
            
            for (let i = 0; i < lostresltlist.length; i++) {
                //  lostresltlist[i].lvl2Recordlst = lostdata2;
                //  lostresltlist[i].lvl3Recordlst = lostdata3;
                
                
            }
            component.set("v.LostTypeList", lostdata1);
            //  component.set("v.lostReslist", lostresltlist);
            
            
            
            
            // self.apex()
        }).catch(function(errors){
            self.errorHandler(errors);
        });
        
    },
    getLosttype2: function(component,event){ 
        
        var self=this;
        //Start V 1.1 @rakshit.s@samsung.com Dynamic CheckBox Function 
        var tableData = [];
        var checkedIndexes = [];
        var uncheckedIndexes = [];
        
        console.log('recid------>'  + component.get('v.opprecordId'));
        console.log('lostdropval',component.get('v.losttypeval'));
        var selectedrecord = []
        var apexParams = { 'OppId' : component.get('v.opprecordId'),
                          'korlang' : component.get('v.setLangKor'),
                          'level1combo': component.get('v.combo1val'),
                          'lostdroptype' : component.get('v.losttypeval')}
        self.apex(component, 'getLosttype2', apexParams).then(function(result){
            window.console.log('result : ', JSON.stringify(result));
            var lostdata = [];
            var lostdata1 = [];
            var lostdata2 = [];
            var lostdata3 = [];
            
            var resultdata =  JSON.parse(result);
            var losttypelv2eng  = resultdata.level2val;
            
            
            for (let i = 0; i < losttypelv2eng.length; i++) {
                lostdata2.push({label: losttypelv2eng[i], value: losttypelv2eng[i]});           
            }
            
            var curntindx = component.get("v.currIndex");
            var lostResltlist = component.get("v.lostReslist");
            var lostrst = lostResltlist[curntindx];
            lostrst.lvl2Recordlst = lostdata2;
            component.set("v.lostReslist",lostResltlist);
            
            
            
            // self.apex()
        }).catch(function(errors){
            self.errorHandler(errors);
        });
        
    },
    
    getLosttype3: function(component,event){ 
        
        var self=this;
        //Start V 1.1 @rakshit.s@samsung.com Dynamic CheckBox Function 
        var tableData = [];
        var checkedIndexes = [];
        var uncheckedIndexes = [];
        
        console.log('recid------>'  + component.get('v.opprecordId'));
        
        var selectedrecord = []
        var apexParams = { 'OppId' : component.get('v.opprecordId'),
                          'korlang' : component.get('v.setLangKor'),
                          'level2combo': component.get('v.combo2val'),
                          'lostdroptype' : component.get('v.losttypeval')}
        self.apex(component, 'getLosttype3', apexParams).then(function(result){
            window.console.log('result : ', JSON.stringify(result));
            var lostdata = [];
            var lostdata1 = [];
            var lostdata2 = [];
            var lostdata3 = [];
            
            var resultdata =  JSON.parse(result);
            var losttypelv3eng  = resultdata.level3val;
            
            
            for (let i = 0; i < losttypelv3eng.length; i++) {
                lostdata3.push({label: losttypelv3eng[i], value: losttypelv3eng[i]});           
            }
            
            var curntindx = component.get("v.currIndex");
            var lostResltlist = component.get("v.lostReslist");
            var lostrst = lostResltlist[curntindx];
            lostrst.lvl3Recordlst = lostdata3;
            console.log('data3val-->',lostdata3);
            component.set("v.lostReslist",lostResltlist);
            
            
            
            // self.apex()
        }).catch(function(errors){
            self.errorHandler(errors);
        });
        
    },
    
    
    
    handleTotalHelper: function(component,event){
        // var checkvalue = component.find("checkContact");
        var totalvalue = component.get("v.totalval");
        var curntindx = component.get("v.currIndex");
        var lostResltlist = component.get("v.lostReslist");
        var totalnum = 0;
        for (var i = 0; i < lostResltlist.length; i++)        
        {   
            if(lostResltlist[i].Checked == true){
                var rateval =lostResltlist[i].ratepercent;
                console.log('rateval',rateval);
                
                totalnum =  parseInt(totalnum) + parseInt(rateval);
            }
        }
        console.log('totalvalue-->',totalnum);
        component.set("v.totalval",totalnum);
        
        /** var checkvalue2 = component.find("fieldlv3");
            
            if(!Array.isArray(checkvalue2)){
                if (checkvalue2.get("v.value") != '' ) {
                    var getvalue = checkvalue2.get("v.value");
                    totalval = parseInt(getvalue);
                }
            }else{
                for (var i = 0; i < checkvalue2.length; i++) {
                    if (checkvalue2[i].get("v.value") != '' ) {
                        var getvalue = checkvalue2[i].get("v.value");
                        console.log('val value-->'+getvalue);   
                        totalval = parseInt(totalval) + parseInt(getvalue);
                        // component.set("v.checkboxList",selectedrecord);
                        
                    }
                }
            }**/
            /*totalval = parseInt(totalval) + parseInt(rateval);
    
            component.set("v.totallv7",totalval);
            console.log('totalval'+totalval);
            /**{
                if (totalval == '100'){
                    component.set("v.setTempprary",false);
                }
                else{
                    component.set("v.setTempprary",true);
                }
            }**/
        },
    checkDuplicateValue: function(component,event){
        var lostresltlist = component.get("v.lostReslist");
        var index = 0;
        var duplicatevallist = [];
        for (let i = 0; i < lostresltlist.length - 1; i++) {
            if(lostresltlist[i].Checked == true){
                for (let j = i + 1; j < lostresltlist.length; j++) {
                    if(lostresltlist[j].Checked == true){
                        if (lostresltlist[i].lvl3Record === lostresltlist[j].lvl3Record) {
                            duplicatevallist[index] = lostresltlist[i].lvl3Record;
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
    
    CheckCharacterLength: function(component,event){
        component.set("v.CheckCharacterlength",false);
        console.log('TestCheckValidation@@1');
        var CharLength = false;
        var lostresltlist = component.get("v.lostReslist");
        for (var i = 0; i < lostresltlist.length; i++)        
        {   
            if(lostresltlist[i].Checked == true){
                var detailvalue = lostresltlist[i].detail;
                console.log('detailvalueLength' +detailvalue.length);
                if(detailvalue.length < 50){
                    lostresltlist[i].CheckCharacterlength = true;
                    component.set("v.CheckCharacterlength",true);
                    
                }
                else{
                    lostresltlist[i].CheckCharacterlength = false;
                }
                
            }
        }
        component.set("v.lostReslist",lostresltlist);
        /**  var lostresltlist1 = component.get("v.lostReslist");
            for (var i = 0; i < lostresltlist1.length; i++) {
                if(lostresltlist1[i].CheckCharacterlength == true){
                     component.set("v.CheckCharacterlength",true);
                }
                
            }
            **/
            
            /**if(CharLength != true){
               component.set('v.showDetailErrMsg', true);
            }
            else{
               component.set('v.showDetailErrMsg', false); 
            } **/
            
        },
    /** START 1.3 **/
    checkRate: function(component,event){
        component.set("v.CheckRateVal",false);
        var lostresltlist = component.get("v.lostReslist");
        for (var i = 0; i < lostresltlist.length; i++)        
        {   
            if(lostresltlist[i].Checked == true){
                if(lostresltlist[i].ratepercent == 0){
                    component.set("v.CheckRateVal",true);
                    //  this.showMyToast('error',$A.get("$Label.c.Check_Rate_Value"));
                    lostresltlist[i].checkRateVal = true;
                    
                }
                else{
                    lostresltlist[i].checkRateVal = false;
                    
                }
                
            }
        }
        component.set("v.lostReslist",lostresltlist);
        
        
        
    },
    /** END 1.3 **/
    insertLostresult: function(component,event){
        var self=this;
        var inpt1 = [];
        var inpt = component.get("v.lostReslist");
        for(let i=0;i<inpt.length;i++){
            if(inpt[i].Checked == true){
                inpt1.push(inpt[i]);
            }
        }
        console.log('inpt1',inpt1);
        var allInput= JSON.stringify(inpt1);
        console.log('allInputlosres',allInput);
        var OppparendId = component.get("v.opprecordId");
        console.log('the oppid-->'+OppparendId);
        var oppActid = component.get("v.opptyActId");
        console.log('the oppactid-->'+oppActid);
        var kornlang = component.get('v.setLangKor');
        console.log('divyam1');
        var lostdroptypeval = component.get('v.losttypeval');
        self.apex(component, 'insertLostresult', {inpVal: allInput,Oppid: OppparendId, oppActivityid: oppActid, korlang : kornlang, lostdroptype : lostdroptypeval}).then(function(result){
            window.console.log('result  code: ', result);
            component.set("v.lvl3allvalue",  result);
            console.log('codevalueafterset: ', component.get("v.lvl3allvalue"));
            
            if(result != ''){
                self.showMyToast('success',$A.get("$Label.c.Saved_Success_Msg"));
            }
        }).catch(function(errors){
            self.errorHandler(errors);
        });
    },
    /** START 1.3 **/
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
    /** END 1.3 **/
    
    refresh : function(component, event) {
        var action = component.get('c.opportunityAnalysisofCompetition');
        action.setCallback(component,
                           function(response) {
                               //  var state = response.getState();
                               var state = 'SUCCESS';
                               if (state === 'SUCCESS'){
                                   // Refresh the view
                                   // after data is updated
                                   $A.get('e.force:refreshView').fire();
                               } else {
                                   // Handle the 'ERROR' or 'INCOMPLETE' state
                               }
                           }
                          );
        $A.enqueueAction(action);
    },
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
    },
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
    }
    
})