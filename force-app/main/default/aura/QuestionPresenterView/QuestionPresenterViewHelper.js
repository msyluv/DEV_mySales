({
    getMasterQuestion : function(component, event, helper) {
        console.log(':::::QuestionPresenterView getMasterQuestion:::::');
        var self = this;

        self.apex(component, 'getOpportunityId', {recordId : component.get('v.recordId')})
        .then(function(result){
            console.log(result);
            component.set('v.isEdit', result.isEdit);
            
            if(component.get('v.isEdit')){
                console.log(result.bizRivewId);
                component.set('v.bizRivewId', result.bizRivewId);
            }
            if(result.oppId == 'OppIdIsNull'){//STRATEGY_COMMITTEE_MSG_OPTYID_NULL
                helper.showtoast('warning', '', $A.get("$Label.c.STRATEGY_COMMITTEE_MSG_OPTYID_NULL"));
                self.navigatieToSObject(component.get('v.recordId'), 'detail');
            } else if(result.status == 'Confirm'){//STRATEGY_COMMITTEE_MSG_CHECKLIST_CONFIRMED
                // component.set('v.objName', result.objName);
                // component.set('v.oppId', result.oppId);
                // component.set('v.modalType', 'NewVersion');
                // component.set('v.isModal', true);
                helper.showtoast('warning', '', $A.get("$Label.c.STRATEGY_COMMITTEE_MSG_CHECKLIST_CONFIRMED"));
                self.navigatieToSObject(component.get('v.recordId'), 'detail');
            } else {
                component.set('v.objName', result.objName);
                component.set('v.oppId', result.oppId);
                return self.apex(component, 'getInit', {objName : component.get('v.objName'), 
                                                        oppId : component.get('v.oppId'),
                                                        recordId : component.get('v.recordId')});
            }
        })
        .then(function(result){
            console.log('reslut : ', result);
            if(result != undefined){
                var selectedRows = [];
                for(var i=0; i<result.length; i++){
                    result[i].Question = result[i].Question.replace(/<(\/)?([a-zA-Z]*)(\s[a-zA-Z]*=[^>]*)?(\s)*(\/)?>/ig, "").replaceAll('&amp;', '&');
                    if(component.get('v.isEdit')){
                        //result[i].Question = result[i].Question.replaceAll("</p><p>","\r\n").replace(/(<([^>]+)>)/ig,"").replaceAll('&amp;', '&');
                        if(result[i].Selected){
                            selectedRows.push(result[i].Id);
                        }
                    } else {
                        selectedRows.push(result[i].Id);
                    }
                }
                component.set('v.insertQuestion', selectedRows);
                console.log(selectedRows);
                component.set('v.masterQuestion', result);
                component.set('v.data', result);
                component.set('v.selectData', result);
                component.set('v.selectedRows', selectedRows);
                component.set('v.selectRow', selectedRows);
                return self.apex(component, 'getPickVal', {});
            }
        })
        .then(function(result){
            console.log('PickVal');
            console.log(result);
            if(result != undefined){
                var option = [{
                    "label": $A.get("$Label.c.ACCTEAM_LAB_NONE"),
                    "value": '- None -'
                }];
                result.forEach(function(value){
                    var item = {
                        "label": value.label,
                        "value": value.value
                    }
                    option.push(item);
                });
                component.set('v.options', option);
            }
        })
        .catch(function(errors){
            console.log(errors);
            self.errorHander(errors);
            //helper.showtoast('warning', '', errors);
        }).finally(function(){
            component.set('v.isLoading', false);
        });
    },

    createTemplate : function(component, event, helper, checkList) {
        console.log(':::::QuestionPresenterView createTemplate:::::');
        console.log(checkList); 

        var self = this;

        console.log(component.get('v.isEdit'));

        self.apex(component, 'getQuestionDetail', {recordList : checkList,
                                                   oppId : component.get('v.oppId'),
                                                   isEdit : component.get('v.isEdit'),
                                                   bizRivewId : component.get('v.bizRivewId'),
                                                   recordId : component.get('v.recordId')}
        )
        .then(function(result){
            helper.hiddenClass(component, component.get('v.isHidden'));
            console.log('reslut : ', result);
            if(result.isSuccess == 'true'){
                var columns = [
                    {label: $A.get("$Label.c.STRATEGY_COMMITTEE_LAB_REVIEWDIVISION"), fieldName: 'ReviewDivision__c', type: 'text', sortable: false, hideDefaultActions: true},
                    {label: $A.get("$Label.c.STRATEGY_COMMITTEE_LAB_QUESTION"), fieldName: 'Question', type: 'text', wrapText: true, sortable: false, hideDefaultActions: true},
                    {label: $A.get("$Label.c.STRATEGY_COMMITTEE_LAB_ANSWER_USER"), fieldName: 'AnswerUserName', initialWidth: 200, type: 'text', sortable: false, hideDefaultActions: true},
                ];
                var qdl = result.questionDetailList;
                var Qdata = [];
                var RDSet = new Set();
                var RDList = [];
                for(var i=0; i<qdl.length; i++){
                    
                    qdl[i].question.Selected = true;
                    if(qdl[i].question.AnswerUser__c == null){
                        qdl[i].question.AnswerUser__c = null;
                        if(qdl[i].question.AnswerUser__r == null){
                            qdl[i].question.AnswerUser__r = {'Id' : null, 'Name' : null};
                        }
                    	qdl[i].question.Selected = false;
                    } else {
                        qdl[i].question.AnswerUserName = qdl[i].question.AnswerUser__r.Name;
                    }
                    
                    qdl[i].question.Question = qdl[i].question.Question__c.replace(/<(\/)?([a-zA-Z]*)(\s[a-zA-Z]*=[^>]*)?(\s)*(\/)?>/ig, "").replaceAll('&amp;', '&');
                    Qdata.push(qdl[i].question)
                    RDSet.add(qdl[i].question.ReviewDivision__c);
                }
                
                RDList = [{
                    "label": $A.get("$Label.c.ACCTEAM_LAB_NONE"),
                    "value": '- None -'
                }];
                RDSet.forEach(function(value){
                    
                    var item = {
                        "label": value,
                        "value": value
                    }
                    RDList.push(item);
                });

                component.set('v.Qcolumns', columns);
                component.set('v.Qdata', Qdata);
                component.set('v.QSelectData', Qdata);
                component.set('v.QreviewDivisionList', RDList);

                component.set('v.selectQuestionList', qdl);
                component.set('v.bizRivewId', result.BizRivewId);
                component.set('v.DescriptionNew' , result.Description);
                component.set('v.picVal', '- None -');
            } else {
                helper.showtoast('warning', '', result.isSuccess);
            }
        })
        .catch(function(errors){
            console.log(errors);
            //helper.showtoast('warning', '', errors);
            self.errorHander(errors);
        }).finally(function(){
            component.set('v.isLoading', false);
        });
    },

    deleteTemplate : function(component , event, helper) {
        console.log(':::::QuestionPresenterView deleteTemplate:::::');

        var self = this

        self.apex(component, 'deleteTemplate', {
            tempId : component.get('v.bizRivewId'),
            isEdit : component.get('v.isEdit')
        })
        .then(function(result){
            //console.log('reslut : ', result);
            self.hiddenClass(component, component.get('v.isHidden'));
            component.set('v.masterQuestion', []);
            return self.apex(component, 'getInit', {objName : component.get('v.objName'), 
                                                    oppId : component.get('v.oppId'),
                                                    recordId : component.get('v.recordId')});
        }).then(function(result){
            console.log('reslut : ', result);
            var reviewDivisionSet = new Set();
            var reviewDivisionList = [];
            if(result != undefined){
                var selectedRows = [];
                for(var i=0; i<result.length; i++){
                    reviewDivisionSet.add(result[i].ReviewDivision);
                    result[i].Question = result[i].Question.replace(/<(\/)?([a-zA-Z]*)(\s[a-zA-Z]*=[^>]*)?(\s)*(\/)?>/ig, "").replaceAll('&amp;', '&');
                    if(component.get('v.isEdit')){
                        //result[i].Question = result[i].Question.replaceAll("</p><p>","\r\n").replace(/(<([^>]+)>)/ig,"").replaceAll('&amp;', '&');
                        if(result[i].Selected){
                            selectedRows.push(result[i].Id);
                        }
                    } else {
                        selectedRows.push(result[i].Id);
                    }
                }
                reviewDivisionList.push('- None -');
                reviewDivisionSet.forEach(function(value){
                    reviewDivisionList.push(value);
                });

                console.log(reviewDivisionList);
                component.set('v.reviewDivisionList', reviewDivisionList);
                component.set('v.insertQuestion', selectedRows);
                console.log(selectedRows);
                component.set('v.masterQuestion', result);
                component.set('v.data', result);
                component.set('v.selectData', result);
                component.set('v.selectedRows', selectedRows);
                component.set('v.selectRow', selectedRows);
            }
        })
        .catch(function(errors){
            self.errorHander(errors);
        }).finally(function(){
            component.set('v.isLoading', false);
        });
    },

    updateAnswerUser : function(component, event, helper) {
        console.log(':::::QuestionPresenterView updateAnswerUser:::::');
        var self = this;
        self.apex(component, 'updateAnswerUser', {objList : component.get('v.selectQuestionList'),
                                                  recordId : component.get('v.recordId'),
                                                  isEdit : component.get('v.isEdit'),
                                                  bizRivewId : component.get('v.bizRivewId'),
                                                  Description : component.get('v.DescriptionNew')}
        )
        .then(function(result){
            console.log(result);
            if(result == 'SUCCESS'){
                var message = component.get('v.isEdit') ? 'Save Success!' : 'Create Success!'
                self.showtoast('success', '', message);
            } else {
                self.showtoast('warning', '', result);
            }
            component.set('v.isLoading', false);
            //self.navigatieToSObject(component.get('v.recordId'), 'detail');
        })
        .catch(function(errors){
            console.log(errors);
            self.errorHander(errors);
        }).finally(function(){

        });
    },
    
    checkListConfirm : function(component, event, helper){
        console.log(':::::QuestionPresenterView checkListConfirm:::::');
        var self = this;
        self.apex(component, 'updateAnswerUser', {objList : component.get('v.selectQuestionList'),
                                                      recordId : component.get('v.recordId'),
                                                      isEdit : component.get('v.isEdit'),
                                                      bizRivewId : component.get('v.bizRivewId'),
                                                      Description : component.get('v.DescriptionNew')}
                 )
        .then(function(result){
            console.log(result);
            if(result != 'SUCCESS'){
                self.showtoast('warning', '', result);
                self.navigatieToSObject(component.get('v.recordId'), 'detail');
            }
            return self.apex(component, 'checkListConfirm', {bizReviewId : component.get('v.bizRivewId')} )
        })
        .then(function(result){
            self.showtoast('success', $A.get("$Label.c.STRATEGY_COMMITTEE_MSG_CONFIRM_TITLE"), $A.get("$Label.c.STRATEGY_COMMITTEE_MSG_CONFIRM"));
            self.navigatieToSObject(component.get('v.recordId'), 'detail');
        })
        .catch(function(errors){
            console.log(errors);
            self.errorHander(errors);
        }).finally(function(){
                
        });
    },

    getNewChecklist : function(component, event, helper){
        console.log(':::::::::: getNewChecklist ::::::::::');
        var self = this;
        console.log(component.get('v.oppId'));
        self.apex(component, 'getNewChecklist', {oppId : component.get('v.oppId')})
        .then(function(result){
            console.log('reslut : ', result);
            var reviewDivisionSet = new Set();
            var reviewDivisionList = [];
            if(result != undefined){
                var selectedRows = [];
                for(var i=0; i<result.length; i++){
                    reviewDivisionSet.add(result[i].ReviewDivision);
                    result[i].Question = result[i].Question.replace(/<(\/)?([a-zA-Z]*)(\s[a-zA-Z]*=[^>]*)?(\s)*(\/)?>/ig, "").replaceAll('&amp;', '&');
                    if(component.get('v.isEdit')){
                        //result[i].Question = result[i].Question.replaceAll("</p><p>","\r\n").replace(/(<([^>]+)>)/ig,"").replaceAll('&amp;', '&');
                        if(result[i].Selected){
                            selectedRows.push(result[i].Id);
                        }
                    } else {
                        selectedRows.push(result[i].Id);
                    }
                }
                reviewDivisionList.push('- None -');
                reviewDivisionSet.forEach(function(value){
                    reviewDivisionList.push(value);
                });

                console.log(reviewDivisionList);
                component.set('v.reviewDivisionList', reviewDivisionList);
                component.set('v.insertQuestion', selectedRows);
                console.log(selectedRows);
                component.set('v.masterQuestion', result);
                component.set('v.data', result);
                component.set('v.selectData', result);
                component.set('v.selectedRows', selectedRows);
                component.set('v.selectRow', selectedRows);
            }
        })
        .catch(function(errors){
            console.log(errors);
            self.errorHander(errors);
            //helper.showtoast('warning', '', errors);
        }).finally(function(){
            component.set('v.isLoading', false);
            component.set('v.isModal', false);
        });
    },

    navigatieToSObject : function (recordId, slideName) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          "recordId": recordId,
          "slideDevName": slideName
        });
        navEvt.fire();
    },    

    showtoast : function(type, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type" : type,
            "title": title,
            "duration": 10000,
            "message": message
        });
        toastEvent.fire();
    },

    hiddenClass : function(component, isHidden) {
        isHidden = !isHidden;
        component.set('v.isHidden', isHidden);

        var section1 = component.find('section1');
        var section2 = component.find('section2');

        if(isHidden) {
            $A.util.addClass(section2, 'hidden');
            $A.util.removeClass(section1, 'hidden');
        } else {
            $A.util.addClass(section1, 'hidden');
            $A.util.removeClass(section2, 'hidden');
        }
    },

    /**
     * Common Functions
     */
    apex : function(component, apexAction, params) {
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

    errorHander : function(errors){
        var self = this;
        if(Array.isArray(errors)){
            errors.forEach(function(err){
                self.showtoast('error', '', err.exceptionType + " : " + err.message);
            });
        } else {
            console.log(errors);
            self.showtoast('error', '', 'Unknown error in javascript controller/helper.')
        }
    }
})