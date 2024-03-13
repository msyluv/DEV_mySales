/**  @author            : divyam.gupta@samsung.com
  @description       : Add new tab Analysis of Competition Result. 
  @last modified on  : 05-30-2023
  @last modified by  : divyam.gupta@samsung.com
  Modifications Log 
  Ver   Date         Author                   	Modification
  1.0   2022-10-17   Divyam.gupta@samsung.com       Initial Version
  1.1   2023-05-30   divyam.gupta@samsung.com   Add on changes Lost Enchacement(Mysales -204)
**/
({
	doInit : function(component, event, helper) {  
            var locale = $A.get("$Locale.language");
            console.log('the user lang:'+locale);
            if(locale == 'ko'){
                component.set("v.setLangEng",false);
                component.set("v.setLangKor",true);
            }
            else{
                component.set("v.setLangEng",true);
                component.set("v.setLangKor",false);
            }
           helper.getOppActivitystatus(component,event);
           helper.getcounterMeasure(component,event);
            helper.getLosttype1(component,event);
				//added by rakshit.s@samsung.com
            helper.checkIfDropOrLost(component,event);
            //START 1.1
            helper.copyAnalysisLevelValue(component,event);
             helper.getProfilecheck(component,event);
            //END 1.1
            
        },
     changeLostType : function(component, event, helper){
            // var checkcomboval = component.find("combobox2");
            //var getvalue = checkcomboval.set("v.value",'');
            //  component.set("v.combo2val",'');
            helper.changeLostType(component,event);
        },
        changeLostType1 : function(component, event, helper){
            helper.changeLostType1(component,event);
        },
    clickCancel: function(component,event , helper){
        helper.reload(component,event);
    },
      addRow: function(component, event, helper){
                            if(component.get("v.activitystatus") != 'In Progress')
                            {
             var itemId = event.currentTarget.getAttribute("data-itemId"); 
            component.set('v.currIndex',itemId);
             console.log('curIndex',component.get('v.currIndex'));
            helper.addRow(component,event);
                            }
        },
     lstactrowSelect: function(component,event,helper){
            var itemId = event.currentTarget.getAttribute("data-itemId"); 
            component.set('v.lostactIndex',itemId.replace('row',''));
            console.log('lostactIndex',component.get('v.lostactIndex'));
        },

    removeRow: function(component, event, helper){
              if(component.get("v.activitystatus") != 'In Progress')
                          {
            var lostReslistval = component.get("v.counterMeasureList");
              var lostReslistval1 = [];

            console.log('the lenght is',lostReslistval.length);
            
        
           
            for(let i=0; i < lostReslistval.length ; i++){
                if( lostReslistval[i].Checked ==  true){
                    lostReslistval1.push(lostReslistval[i]);
                   }   
            }
             if(lostReslistval1.length > 1)
            {
                helper.removeRow(component,event);
                
                console.log('the lenght is1',lostReslistval1.length);
                
            }
           
            if(lostReslistval1.length == 1){
                    helper.removeRow(component,event);
                   helper.addRow(component,event);
                
            }
                          }
            
        },
    
    //added by @rakshit.s@samsung.com
        //logic to implement popup view on button click.
           handlechildLwcViewAll: function(component, event, helper){
            // var oppId = component.get("v.opprecordId");
            console.log('calling form button' + event.getSource().getLocalId());
            component.set('v.showTablefromLWC' , true); 
            let isViewAll = false;
            if(event.getSource().getLocalId() == 'viewAll'){
                isViewAll = true;
            }
           
            
            $A.createComponent(
            "c:childLwcPopupContainer",{
                "opprecordId" : component.get('v.opprecordId'),
                "isViewAll" : isViewAll,
                "isCounterMeasureTable" : false,
                "isMasterLostTypeT" : true,
                "activityId" : component.get('v.opptyActId')

            },
            function(modalComponent, status, errorMessage){
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    var body = component.find('showChildModal').get("v.body"); 
                    body.push(modalComponent);
                    component.find('showChildModal').set("v.body", body);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                    // Show offline error
                }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                    // Show error message
                }
            }
        );
            
           
        },
        

        handlechildLwc: function(component, event, helper){
            // var oppId = component.get("v.opprecordId");
            console.log('calling form button' + event.getSource().getLocalId());
           // component.set('v.showTablefromLWC' , true); 
            $A.createComponent(
            "c:childLwcPopupContainer",{
                "opprecordId" : component.get('v.opprecordId'),
                "isCounterMeasureTable" : true,
                "isMasterLostTypeT" : false,
                "activityId" : component.get('v.opptyActId')

            },
            function(modalComponent, status, errorMessage){
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    var body = component.find('showChildModal').get("v.body"); 
                    body.push(modalComponent);
                    component.find('showChildModal').set("v.body", body);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                    // Show offline error
                }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                    // Show error message
                }
            }
        );
            
           
        },
    /**
     removeActionRow: function(component, event, helper){
        if(component.get("v.activitystatus") != 'In Progress')
                                   {
         var curntindx = component.get("v.currIndex");

        var countrmsrtlist=  component.get("v.counterMeasureList");
         var curntcntrlst = countrmsrtlist[curntindx].lostactnList;
            console.log('actlistsize',curntcntrlst.length);

            if(curntcntrlst.length > 1){
                helper.removeActionRow(component,event);
                
            }
              else if(curntcntrlst.length = 1){
                helper.removeActionRow(component,event);
                 helper.addActionRow(component,event);
                                       }
                                   }
            
        },  **/
        rowSelect: function(component,event ,helper){
            var itemId = event.currentTarget.getAttribute("data-itemId"); 
            component.set('v.currIndex',itemId.replace('row',''));
            helper.rowSelect(component,event);
        },
    
       addActionRow: function(component, event, helper){
           if(component.get("v.activitystatus") != 'In Progress')
           {
           var curntindx = component.get("v.currIndex") ;
           var lostresltlist=  component.get("v.counterMeasureList");
           console.log('lostresltlistlen',lostresltlist[curntindx].lostactnList.length);
            component.set('v.lostactIndex',lostresltlist[curntindx].lostactnList.length);
            console.log('lostactIndex',component.get('v.lostactIndex'));
            helper.addActionRow(component,event);
           }
    },       
       handlesave: function(component, event , helper){
           helper.checklvlvalue(component,event);
           helper.checkSpecialChar(component,event);
          // helper.checkDuplicateValue(component,event);
          // helper.checkCompletionDate(component,event);
          // if(component.get("v.checkspclChar") == false && component.get("v.lvlcheck") == false && component.get("v.level3duplicate") == false && component.get("v.checkComplDate") == false){
           if(component.get("v.lvlcheck") == false && component.get("v.checkspclChar") == false){
          helper.insertCounterMeasure(component,event);
           }
       },
      Changeindept : function(component, event , helper){
     
       var counterindx = component.get("v.currIndex");
       var lostItemIndex = component.get("v.lostactIndex");
       var countermsrlist = component.get("v.counterMeasureList");
       var currntval = (countermsrlist[counterindx].lostactnList[lostItemIndex]);
        console.log('currntvallstact',currntval);
},
    
      handleCopyLostType : function(component, event , helper){
        component.set("v.confirmpopup",true);
    },
    handlelvl3chkcbox : function(component,event,helper){
       var curntindx = component.get("v.currIndex") ;
       var countermsrlist = component.get("v.counterMeasureList");
       var countmstrcurntval = countermsrlist[curntindx];
        /*countmstrcurntval.lostresndisable = false;
        countmstrcurntval.imprvdisable = false;
        for(let j=0;j<countmstrcurntval.lostactnList.length;j++){
        countmstrcurntval.lostactnList[j].actionItemdisable = false;
        countmstrcurntval.lostactnList[j].deptdisable = false;
        countmstrcurntval.lostactnList[j].relevdeptdisable = false;   
        
        component.set('v.counterMeasureList',countermsrlist);
        */ 
    },
      closeModal : function(component,event,helper){
            component.set("v.confirmpopup",false);
},
      handleYes : function(component,event,helper){
                  helper.getlostresultlvlval(component,event);
                   helper.getLosttype1(component,event);
                   // helper.addActionRowCopy(component,event);
    }


        
})