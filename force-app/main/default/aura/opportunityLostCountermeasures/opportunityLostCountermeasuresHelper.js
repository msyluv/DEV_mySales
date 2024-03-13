/**
  @author            : divyam.gupta@samsung.com
  @description       : Add new tab Analysis of Competition Result. 
  @last modified on  : 2022-10-17
  @last modified by  : divyam.gupta@samsung.com
  Modifications Log 
  Ver   Date         Author                   	Modification
  1.0   2022-10-17   Divyam.gupta@samsung.com       Initial Version
**/

({
    getOppActivitystatus: function(component,event){
        var self = this;
         var oppActid = component.get("v.opptyActId");
          self.apex(component, 'getOppActivitystatus', {oppActid: oppActid}).then(function(result){
            //   window.console.log('result : ', result);
            
            window.console.log('activity status Test@@ : ', result);  
            if(result != ''){
                component.set("v.activitystatus",result.Status__c);
             }
            
        }).catch(function(errors){
            self.errorHandler(errors);
        });

    },
    

    
    
  
    getLostresult: function(component,event){
        var self=this;
        var lostrcode = [];
        var OppparendId = component.get("v.opprecordId");
        self.apex(component, 'getLostresult', {oppid: OppparendId}).then(function(result){
            if(result != '' && result != null){
                window.console.log('entry in IF');
                component.set("v.Typevaluelst", result);
                component.set("v.showLostrtable",true);
                self.getSecondaryFilledValues(component,event);
                //component.set("v.setSave",false);
                window.console.log('result code #####', JSON.stringify(result));           
            } 
        }).catch(function(errors){
            self.errorHandler(errors);
        });
    },
    
    //Start V 1.1 @rakshit.s@samsung.com Dynamic CheckBox Function 
    //to get the secondary data values if they are prefilled in the database.
    getSecondaryFilledValues: function(component,event){
        console.log('Entry in getSecondaryFilledValues');
        var self=this;
        var apexParams = { 'OppId' : component.get('v.opprecordId') }; 
        var typeList = [];
        var checkedIndexes = [];
        
        self.apex(component, 'getSecondaryTableValues', apexParams).then(function(result){
            //   window.console.log('result : ', result);
            
            window.console.log('rakshit-->', result); 
            for(let a=0; a<component.get('v.Typevaluelst').length; a++){
                typeList.push(component.get('v.Typevaluelst')[a]);
            }
            console.log('data---->' + JSON.stringify(typeList));
            for(let i=0; i<result.length; i++){
                for(let j=0; j<typeList.length; j++){
                    console.log('first-->' + typeList[j].LostTypeCode__c + 'second---->' + result[i].LostReason_Type__c );
                    if(typeList[j].LostTypeCode__c  == result[i].LostReason_Type__c  ){
                        console.log('Entry in IF!!');
                        typeList[j].fieldVal1 = result[i].DetailReason__c;
                        typeList[j].fieldVal2 = result[i].Improvement__c;
                        typeList[j].fieldVal3 = result[i].Improve_InChargeDept__c;
                        typeList[j].fieldVal4 = result[i].Improve_RelavantDept__c;
                        typeList[j].fieldVal5 = result[i].ActionItem_1__c;
                        typeList[j].fieldVal6 = result[i].ActionItem_1_InChargeDept__c;
                        typeList[j].fieldVal7 = result[i].ActionItem_1_RelavantDept__c;
                        typeList[j].fieldVal8 = result[i].ActionItem_2__c;
                        typeList[j].fieldVal9 = result[i].ActionItem_2_InChargeDept__c;
                        typeList[j].fieldVal10 = result[i].ActionItem_2_RelavantDept__c;
                        typeList[j].fieldVal11 = result[i].ActionItem_3__c;
                        typeList[j].fieldVal12 = result[i].ActionItem_3_InChargeDept__c;
                        typeList[j].fieldVal13 = result[i].ActionItem_3_RelavantDept__c;
                        typeList[j].fieldVal14 = result[i].ActionItem_4__c;
                        typeList[j].fieldVal15 = result[i].ActionItem_4_InChargeDept__c;
                        typeList[j].fieldVal16 = result[i].ActionItem_4_RelavantDept__c;
                        typeList[j].fieldVal17 = result[i].ActionItem_5__c;
                        typeList[j].fieldVal18 = result[i].ActionItem_5_InChargeDept__c;
                        typeList[j].fieldVal19 = result[i].ActionItem_5_RelavantDept__c;
                    }
                }
            }
            component.set('v.Typevaluelst' , typeList);
            console.log('checked indexes--->' + checkedIndexes);
        }).catch(function(errors){
            console.log('End%%');
            self.errorHandler(errors);
        });
        
    },
    //END V 1.1 @rakshit.s@samsung.com Dynamic CheckBox Function
   
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
    insertLostCounter: function(component,event){
        var self=this;
        
        var inpt = component.get("v.LostCounterMsrList");
        var insertLC= JSON.stringify(inpt);
        var OppparendId = component.get("v.opprecordId");
        console.log('the oppid-->'+OppparendId);
        var inpt1 = component.get("v.piclistvalues");
        var picklistval= JSON.stringify(inpt1);
        var oppActid = component.get("v.opptyActId");
        console.log('the oppactid-->'+oppActid);
        
        self.apex(component, 'insertLostCounter', {inputLClist: insertLC,Oppid: OppparendId, oppActivityid: oppActid,piclistval: picklistval}).then(function(result){
            //   window.console.log('result : ', result);
            
            window.console.log('result code : ', result);  
            if(result != ''){
                self.showMyToast('success',$A.get("$Label.c.COMM_MSG_0002"));
            }
            
        }).catch(function(errors){
            self.errorHandler(errors);
        });
    },
      getLosttype: function(component,event){
        var self=this;
        //Start V 1.1 @rakshit.s@samsung.com Dynamic CheckBox Function 
        var tableData = [];
        var checkedIndexes = [];
         var uncheckedIndexes = [];

        console.log('recid------>'  + component.get('v.opprecordId'));
        
        var selectedrecord = []
        var apexParams = { 'OppId' : component.get('v.opprecordId') }; 
        self.apex(component, 'getLosttype', apexParams).then(function(result){
            window.console.log('result : ', JSON.stringify(result));
           for (let i = 0; i < result.length; i++) {
                tableData.push(result[i].masterList);

           }
            component.set("v.LostTypeList", tableData);
               
               
           // for (let z = 0; z < checkedIndexes.length; z++) {
                  
        }).catch(function(errors){
            self.errorHandler(errors);
        });
    },
    getpicklistcounter: function(component,event){

       // console.log('picklistval coming'+picklstval);
        var picklistvalue = component.get("v.picklistval");
        console.log('divyam picklistvalue-->'+picklistvalue);
        var OppparendId = component.get("v.opprecordId");
        var self=this;
        
        
        self.apex(component, 'getpicklistcounter', {Oppid: OppparendId,piclisval: picklistvalue}).then(function(result){
            window.console.log('result code pic: ', result);  
            if(result.getcounterlostlist != null){
                var getallval = result.getcounterlostlist;
                console.log('divyam val coming-->'+getallval);
                component.set("v.lostresndetail",getallval.DetailReason__c);
                console.log('detaillostreasn'+getallval.DetailReason__c);
                component.set("v.impresndetail",getallval.Improvement__c);
                component.set("v.action1detail",getallval.ActionItem_1__c);
                component.set("v.action2detail",getallval.ActionItem_2__c);
                component.set("v.action3detail",getallval.ActionItem_3__c);
                component.set("v.action4detail",getallval.ActionItem_4__c);
                component.set("v.action5detail",getallval.ActionItem_5__c);
                component.set("v.imprvchngdept",getallval.Improve_InChargeDept__c);
                component.set("v.imprvrevdept",getallval.Improve_RelavantDept__c);
                component.set("v.action1chngdept",getallval.ActionItem_1_InChargeDept__c);
                component.set("v.action2chngdept",getallval.ActionItem_2_InChargeDept__c);
                component.set("v.action3chngdept",getallval.ActionItem_3_InChargeDept__c);
                component.set("v.action4chngdept",getallval.ActionItem_4_InChargeDept__c);
                component.set("v.action5chngdept",getallval.ActionItem_5_InChargeDept__c);
                component.set("v.action1revdept",getallval.ActionItem_1_RelavantDept__c);
                component.set("v.action2revdept",getallval.ActionItem_2_RelavantDept__c);
                component.set("v.action3revdept",getallval.ActionItem_3_RelavantDept__c);
                component.set("v.action4revdept",getallval.ActionItem_4_RelavantDept__c);
                component.set("v.action5revdept",getallval.ActionItem_5_RelavantDept__c);
                
            }
                    if(result.TypeVal != '' && result.TypeVal != null){
                        console.log('Entry 2@@' + result.TypeVal);
                       var getpicval =  result.TypeVal;
                        var engLang = component.get("v.setLangEng");
                        if(engLang == true){
                            component.set("v.picklistval",getpicval.Type_Eng__c);
                        }else{
                            component.set("v.picklistval",getpicval.Type_Kor__c);
                        }
                    }

            
        }).catch(function(errors){
            self.errorHandler(errors);
        });
        
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