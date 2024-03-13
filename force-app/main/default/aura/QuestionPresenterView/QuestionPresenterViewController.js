({
    init : function(component, event, helper) {
        console.log(':::::QuestionPresenterView Init:::::');
        // 모바일 체크 여부
        var dvModule = $A.get( "$Browser.formFactor");
        if( dvModule === "PHONE" || dvModule === "IPHONE"){
            helper.showtoast('warning', '', $A.get("$Label.c.COMM_MSG_0004"));
            window.history.back();
        }
        component.set('v.isLoading', true);

        var pageRef = component.get("v.pageReference");
        var recordId = pageRef.state.c__recordId;
        console.log('recordId : '+recordId);    
        
        //var recordId = component.get('v.recordId');
        component.set('v.recordId', recordId);
        
        var columns = [
            {label: $A.get("$Label.c.STRATEGY_COMMITTEE_LAB_CATEGORY"), fieldName: 'Category1', type: 'text', sortable: false, hideDefaultActions: true, editable: false},
            {label: '', fieldName: 'Category2', type: 'text', sortable: false, hideDefaultActions: true},
            {label: $A.get("$Label.c.STRATEGY_COMMITTEE_LAB_QUESTION"), initialWidth: 900, fieldName: 'Question', type: 'rich-text', sortable: false, hideDefaultActions: true},
            {label: $A.get("$Label.c.STRATEGY_COMMITTEE_LAB_REVIEWDIVISION"), fieldName: 'ReviewDivision', type: 'text', sortable: false, hideDefaultActions: true},
            {label: $A.get("$Label.c.STRATEGY_COMMITTEE_BTN_DETAIL"), fixedWidth: 116, type: 'button', typeAttributes: { label: $A.get("$Label.c.STRATEGY_COMMITTEE_BTN_DETAIL"), name: 'Question_details', title: 'Click to Question Details'}, hideDefaultActions: true}
        ];
        component.set('v.columns', columns);
        console.log(component.get('v.recordId'));
        helper.getMasterQuestion(component, event, helper);
    },

    handleChangeVal : function(component, event, helper) {
        console.log(':::::QuestionPresenterView changeVal:::::');
        var idx = event.currentTarget.dataset.idx;
        var QList = component.get('v.masterQuestion');
        QList[idx].Selected = !QList[idx].Selected;
        component.set('v.masterQuestion', QList);
        /*
        var selectList = component.get('v.selectMasterQuestionList');
        var checked = event.getSource().get("v.checked");
        // console.log(checked);
        var idVal = event.getSource().get("v.name");
        // console.log(idVal);
        
        if(checked){
            // console.log('if');
            selectList.push(idVal);
        } else {
            // console.log('else');
            // console.log(selectList.indexOf(idVal));
            selectList.splice(selectList.indexOf(idVal),1);
        }
        // console.log(selectList);
        component.set('v.selectMasterQuestionList', selectList);
        */
    },

    handleCreateTemplate : function(component, event, helper){
        console.log(':::::QuestionPresenterView handleCreateTemplate:::::');
        console.log(component.get('v.insertQuestion'));
        
        component.set('v.isLoading', true);

        var QuestionCheckList = component.get('v.insertQuestion');
        
        if(QuestionCheckList.length < 1){
            helper.showtoast('warning', '', $A.get("$Label.c.STRATEGY_COMMITTEE_MSG_NO_QUESTION"));
            
            component.set('v.isLoading', false);
            return;
        }
        console.log(QuestionCheckList);
        

        helper.createTemplate(component, event, helper, QuestionCheckList);
        
    },

    selectOwner : function(component, event, helper){
        console.log('Select Owner');
        var additionalFields = 'filter, name';
        var record ={'filter':'test', 'name':'kim'};
        var listField = additionalFields.replace(" ","").split(",");
        var additionalData = '';
		for(var i=0;i<listField.length;i++){
			var key = listField[i];
            additionalData += record[key];
            console.log(i , listField.length);
			if(i > 0 && i != listField.length) additionalData += ', ';
        }
        console.log(additionalData);
    },  

    recordSelectedEventHandler : function(component, event, helper) {
        var recordFromEvent = event.getParam("recordByEvent");
        console.log('recordFromEvent', JSON.stringify(recordFromEvent));
        component.set('v.selectedOwnerId', recordFromEvent.Id);
        component.set('v.selectedOwnerName', recordFromEvent.Name);
    },

    handleSaveUser : function(component, event, helper){
        console.log(':::::QuestionPresenterView handleSaveUser:::::');
        
        var QselectedRows = component.get('v.QselectedRows');
        console.log(QselectedRows); 
    },

    handleSave : function(component, event, helper){
        
        console.log('save');
        component.set('v.isLoading', true);
        helper.updateAnswerUser(component, event, helper);
    },

    handleBack : function(component, event, helper){
        /*
        if(confirm('')){
            helper.deleteTemplate(component ,event, helper);
        } 
        */
        component.set('v.isLoading', true);
        component.set('v.picVal', '- None -');
        helper.deleteTemplate(component ,event, helper);
    },

    handleChangeAddUser : function(component, event, helper){
        console.log(':::::QuestionPresenterView handleChangeAddUser:::::');
        
        var idx = event.currentTarget.dataset.idx;
        var id = event.currentTarget.dataset.id;
        var question = event.currentTarget.dataset.question;
        var selectQuestionList = component.get('v.selectQuestionList');
        console.log(id + ' : ' + question);
        
        if(selectQuestionList[idx].question.AnswerUser__r.Name != null){
            console.log('selec user');
            return;
        }
        
        selectQuestionList[idx].question.Selected = !selectQuestionList[idx].question.Selected;
        
        var answerUserList = component.get('v.answerUserList');
        var idxList = component.get('v.idxList');
        console.log(selectQuestionList[idx].question.Selected);
        question = question.split('□')[1];
        question = question.replace(/<(\/)?([a-zA-Z]*)(\s[a-zA-Z]*=[^>]*)?(\s)*(\/)?>/ig, "");


        if(selectQuestionList[idx].question.Selected){
        	answerUserList.push(question);
            idxList.push(idx);
        } else {
        	answerUserList.splice(answerUserList.indexOf(question), 1);
            idxList.splice(idxList.indexOf(idx), 1);
        }
        console.log(answerUserList);
        console.log(idxList);
        component.set('v.idxList', idxList);
        component.set('v.answerUserList', answerUserList);
        component.set('v.selectQuestionList', selectQuestionList);
        /*
        var answerList = component.get('v.answerUserList');
        var selectQuestionList = component.get('v.selectQuestionList');

        var checked = event.getSource().get("v.checked");
        // console.log(checked);
        var idx = event.getSource().get("v.name");
        // console.log(idx);
        var idxList = component.get('v.idxList');
        // console.log(idxList);
        
        var question = selectQuestionList[idx].question;
        // console.log(question);

        if(checked){
            // console.log('if');
            answerList.push(question.Question__c);
            idxList.push(idx);
        } else {
            // console.log('else');
            // console.log(answerList.indexOf(question));
            answerList.splice(answerList.indexOf(question.Question__c),1);
            idxList.splice(idxList.indexOf(idx),1);
        }
        // console.log(answerList);

        component.set('v.idxList', idxList);
        component.set('v.answerUserList', answerList);
        */

    },

    handleRemove: function (component, event) {
        var idx = event.getSource().get("v.name");
        var selectQuestionList = component.get('v.selectQuestionList');

        selectQuestionList[idx].question.AnswerUser__r.Name = null;
        selectQuestionList[idx].question.AnswerUser__c = null;
        selectQuestionList[idx].question.Selected = false;


        component.set('v.selectQuestionList', selectQuestionList);
    },

    reInit : function(component, event, helper) {
        console.log(':::::QuestionPresenterView reInit:::::');
        component.set('v.isHidden', false);
        helper.hiddenClass(component, component.get('v.isHidden'));
        component.set('v.masterQuestion', []);
        component.set('v.picVal', '- None -');
        var init = component.get('c.init');
        $A.enqueueAction(init);
    },
    
    handleConfirm : function(component, event, helper) {
        console.log(':::::QuestionPresenterView handleConfirm:::::');
        
        var selectQuestionList = component.get('v.selectQuestionList');
        for(var i=0; i<selectQuestionList.length; i++){
            if(selectQuestionList[i].question.AnswerUser__c == null || selectQuestionList[i].question.AnswerUser__c == ''){
                helper.showtoast('warning', '', $A.get("$Label.c.STRATEGY_COMMITTEE_MSG_NO_ANSWER_USER"));
                return;
            }
        }

        if(component.get('v.confirmCheck')) return;
        component.set('v.confirmCheck', true);
        
        helper.checkListConfirm(component, event, helper);
    },

    updateSelectedText : function(component, event, helper){
        console.log(':::::QuestionPresenterView updateSelectedText:::::');
        /*
        var selectedRows = event.getParam('selectedRows');
        console.log(selectedRows);
        var insertQuestion = [];
        for(var i=0; i<selectedRows.length; i++){
            insertQuestion.push(selectedRows[i].Id);
        }
        component.set('v.insertQuestion', insertQuestion);
        //component.set('v.selectedRows', selectedRows);
        */

        var evtSelectRows = event.getParam('selectedRows');
        var data = component.get('v.data');
        var picVal = component.get('v.picVal');
        var selectRows = [];
        var insertRows = [];

        console.log(evtSelectRows);
        console.log(data);
        console.log(picVal);

        var selectMap = new Map();
        evtSelectRows.map(function(currentValue, index, arr){
            //console.log(currentValue);
            //console.log(index);
            selectMap.set(currentValue.Id, currentValue);
        })

        console.log(selectMap);

        for(var i=0; i<data.length; i++){
            if(picVal == '- None -'){
                if(selectMap.has(data[i].Id)){
                    data[i].Selected = true;
                } else {
                    data[i].Selected = false;
                }
            } else if(picVal == data[i].ReviewDivision){
                if(selectMap.has(data[i].Id)){
                    data[i].Selected = true;
                } else {
                    data[i].Selected = false;
                }
            }

            if(data[i].Selected){
                selectRows.push(data[i].Id);
                insertRows.push(data[i].Id);
            }
        }

        component.set('v.selectedRows', selectRows);
        component.set('v.insertQuestion', insertRows);
        component.set('v.data', data);
        
    },

    handleRowAction : function(component, event, helper){
        var isModal = component.get('v.isModal');
        isModal = !isModal;
        if(isModal){
            var action = event.getParam('action');
            if(action.name == 'Question_details'){
                var row = event.getParam('row');
                console.log(action);
                console.log(row);
                component.set('v.QuestionDetail', row.QuestionDetail);
            }
        }
        component.set('v.modalType', 'Question_Detail');
        component.set('v.isModal', isModal);
    },

    updateSelectedUser : function(component, event, helper){
        console.log(':::::QuestionPresenterView updateSelectedUser:::::');
        var selectedRows = event.getParam('selectedRows');
        console.log(selectedRows);
        var QselectQuestion = [];
        for(var i=0; i<selectedRows.length; i++){
            QselectQuestion.push({question : selectedRows[i].Question});
        }
        component.set('v.QselectRow', selectedRows);
        component.set('v.QselectQuestion', QselectQuestion);
    },

    handleAddUser : function(component, event, helper){
        console.log(':::::QuestionPresenterView handleAddUser:::::');
        var label = event.getSource().get('v.label');
        var QselectRow = component.get('v.QselectRow');
        var selectMap = new Map();
        var QpicVal = component.get('v.QpicVal');

        console.log(QselectRow)

        QselectRow.map(function(currentValue, index, arr){
            //console.log(currentValue);
            //console.log(index);
            selectMap.set(currentValue.Id, currentValue);
        })

        // var QselectRow = component.get('v.QselectRow');
        if(label == $A.get("$Label.c.STRATEGY_COMMITTEE_BTN_ADDUSER")){
            if(QselectRow.length == 0){
                helper.showtoast('warning', '', $A.get("$Label.c.STRATEGY_COMMITTEE_MSG_NO_QUESTION"));
                return;
            }
        }
        if(label == $A.get("$Label.c.STRATEGY_COMMITTEE_BTN_SAVE")){
            // component.set('v.selectedOwnerId', recordFromEvent.Id);
            // component.set('v.selectedOwnerName', recordFromEvent.Name);
            var selectedOwnerId = component.get('v.selectedOwnerId');
            var selectedOwnerName = component.get('v.selectedOwnerName');
            var Qdata = component.get('v.Qdata');
            var QSelectDate = [];
            if(selectedOwnerId != null || selectedOwnerId != ''){
                console.log(QselectRow);
                for(var i=0; i<Qdata.length; i++){
                    if(selectMap.has(Qdata[i].Id)){
                        Qdata[i].AnswerUser__c = selectedOwnerId;
                        Qdata[i].AnswerUser__r.Id = selectedOwnerId;
                        Qdata[i].AnswerUser__r.Name = selectedOwnerName;
                        Qdata[i].AnswerUserName = selectedOwnerName;
                    }
                    if(QpicVal == '- None -'){
                        QSelectDate.push(Qdata[i]);
                    } else if (QpicVal == Qdata[i].ReviewDivision__c){
                        QSelectDate.push(Qdata[i]);
                    }
                    console.log(Qdata[i].AnswerUser__r.Name);
                }
                component.set('v.QSelectData', QSelectDate);
                component.set('v.Qdata', Qdata);
            } else if (selectedOwnerId == null || selectedOwnerId == ''){
                helper.showtoast('warning', '', $A.get("$Label.c.STRATEGY_COMMITTEE_MSG_NO_SELECT_USER"));
            }
            component.set('v.QselectedRows', []);
            component.set('v.QselectRow', []);
            component.set('v.QselectQuestion', []);
        }
        if (label == 'cancel'){
            component.set('v.QselectedRows', []);
            component.set('v.QselectRow', []);
            component.set('v.QselectQuestion', []);
        } 
        var isModal = component.get('v.isModal');
        isModal = !isModal;
        
        component.set('v.isModal', isModal);
        component.set('v.modalType', 'AddUser');
    },

    handleDescription : function(component, event, helper){
        console.log(':::::QuestionPresenterView handleDescription:::::');
        var label = event.getSource().get('v.label');
        if(label == $A.get("$Label.c.STRATEGY_COMMITTEE_LAB_DESCRIPTION")){
            component.set('v.DescriptionOld', component.get('v.DescriptionNew'));
        }
        if(label == $A.get("$Label.c.STRATEGY_COMMITTEE_BTN_SAVE")){
            
        }
        if (label == $A.get("$Label.c.STRATEGY_COMMITTEE_BTN_CLOSE")){
            component.set('v.DescriptionNew', component.get('v.DescriptionOld'));
        } 
        console.log(label);
        var isModal = component.get('v.isModal');
        isModal = !isModal;
        component.set('v.isModal', isModal);
        component.set('v.modalType', 'Description');
    },

    onChange : function(component, event, helper){
        console.log(':::::QuestionPresenterView onChange:::::');
        
        console.log(component.get('v.isHidden'));

        if(component.get('v.isHidden')){
                
            //console.log(event.getSource().get('v.value'));
            var data = component.get('v.data'),
                picVal = event.getSource().get('v.value'),
                selectRow = component.get('v.selectRow'),
                pickData = [],
                pickRow = [];

            console.log(selectRow);

            for(var i=0; i<data.length; i++){
                console.log(data[i].Selected)
                //console.log(data[i])
                if(data[i].ReviewDivision == picVal){
                    //console.log('pickData');
                    pickData.push(data[i]);
                    if(data[i].Selected){
                        pickRow.push(data[i].Id);
                    }
                }

                if(picVal == '- None -'){
                    pickData.push(data[i]);
                    if(data[i].Selected){
                        pickRow.push(data[i].Id);
                    }
                }
            }


            component.set('v.selectData', pickData);
            component.set('v.selectedRows', pickRow);
            component.set('v.picVal', picVal);
        } else {
            var data = component.get('v.Qdata'),
                picVal = event.getSource().get('v.value'),
                selectRow = component.get('v.QselectedRows'),
                pickData = [],
                pickRow = [];

            for(var i=0; i<data.length; i++){
                console.log(data[i].Selected)
                //console.log(data[i])
                if(data[i].ReviewDivision__c == picVal){
                    //console.log('pickData');
                    pickData.push(data[i]);
                }

                if(picVal == '- None -'){
                    pickData.push(data[i]);
                }
            }


            component.set('v.QSelectData', pickData);
            component.set('v.QpicVal', picVal);
        }
        
    },

    handleCancel : function(component, event, helper){
        helper.navigatieToSObject(component.get('v.recordId'), 'detail');
    },

    handleNewChecklist : function(component ,event, helper){
        console.log(':::::::::: handleNewChecklist ::::::::::');
        
        var label = event.getSource().get('v.label');

        if(label == $A.get("$Label.c.STRATEGY_COMMITTEE_BTN_CREATE")){
            helper.getNewChecklist(component, event, helper);
        }

        if(label == $A.get("$Label.c.STRATEGY_COMMITTEE_BTN_CANCEL")){
            helper.navigatieToSObject(component.get('v.recordId'), 'detail');
        }
    }
})