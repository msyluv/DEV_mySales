({
    init : function(component, event, helper) {
        console.log(':::::StrategyCommitteeCheckList init:::::');
        component.set('v.isLoading', true);
        var columns = [
            {label: $A.get("$Label.c.STRATEGY_COMMITTEE_LAB_NAME"), fieldName: 'Url', type: 'url', typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' }},
            {label: $A.get("$Label.c.STRATEGY_COMMITTEE_LAB_VERSION"), fieldName: 'Version', type: 'text'},
            {label: $A.get("$Label.c.STRATEGY_COMMITTEE_LAB_OPPORTUNITY"), fieldName: 'oppUrl', type: 'url', typeAttributes: { label: { fieldName: 'Opportunity' }, target: '_blank' }},
            {label: $A.get("$Label.c.STRATEGY_COMMITTEE_LAB_MANAGER"), fieldName: 'Manager', type: 'text'},
            {label: $A.get("$Label.c.STRATEGY_COMMITTEE_LAB_DEADLINE"), fieldName: 'DeadLine', type: 'date'},
            {label: $A.get("$Label.c.STRATEGY_COMMITTEE_LAB_DECISION"), fieldName: 'Decision', type: 'text'},
            {label: $A.get("$Label.c.STRATEGY_COMMITTEE_LAB_TOTAL_QUESTION"), fieldName: 'TotalQuestionCount', type: 'text'},
            {label: $A.get("$Label.c.STRATEGY_COMMITTEE_LAB_ANSWER_QUESTION"), fieldName: 'IsAnswerCount', type: 'text'},
            {label: $A.get("$Label.c.STRATEGY_COMMITTEE_LAB_PM_ANSWERED_QUESTION"), fieldName: 'IsPMAnswerCount', type: 'text'},
            //{label: $A.get("$Label.c.STRATEGY_COMMITTEE_LAB_CONFIRM_DATE"), fieldName: 'ConfirmDate', type: 'date'},
            {label: '', type: 'button', initialWidth: 118, typeAttributes: { label: $A.get("$Label.c.STRATEGY_COMMITTEE_BTN_ANSWER"), name: 'view_checklist', title: 'Click to Check List', disabled: { fieldName: 'isCreater' }}}
            
        ];

        component.set('v.columns', columns);

        helper.doInit(component, event, helper);
        helper.getPickValue(component, event, helper);
    },

    reInit : function(component, event, helper) {
        console.log(':::::StrategyCommitteeCheckList reInit:::::');
        var init = component.get('c.init');
        $A.enqueueAction(init);
    },

    handleRowAction : function(component, event, helper){
        var isModal = component.get('v.isModal');
        var action = event.getParam('action');
        if(action.name == 'view_checklist'){
            var row = event.getParam('row');
            console.log(action);
            console.log(row.Id);
            component.set('v.recordId', row.Id);
            if(row.isLock){
                helper.showtoast('', '', $A.get("$Label.c.STRATEGY_COMMITTEE_MSG_RECORD_LOCK"));
                return;
            } else {
                helper.getCheckList(component, event, helper, row.Id);
            }
        }
        component.set('v.isModal', !isModal);
    },
    
    handleSelectAns : function(component ,event, helper) {
        var dataSetId = event.currentTarget.dataset.id,
            dataSetLength = event.currentTarget.dataset.length,
            selectedItemNew = document.getElementById(dataSetId),
            hasClass = $A.util.hasClass(selectedItemNew, 'selectAnswer'),
            hasClassPM = $A.util.hasClass(selectedItemNew, 'selectAnswerPM'),
            checkList = component.get('v.checkList'),
            questionList = checkList.questionWrapperList;
        // console.log('select Val');
        // console.log(dataSetId);
        // console.log(questionList);
        
        var idSplit = dataSetId.split('-');
        
        console.log('hasClass : ' + hasClass);
        if(hasClass || hasClassPM){
            if(checkList.isPm){
                questionList[idSplit[0]].answerList[idSplit[1]].IsPMChecked__c = false;
                $A.util.removeClass(selectedItemNew, 'selectAnswerPM');
                questionList[idSplit[0]].question.TotalPMScore__c = 0;
            } else {
                questionList[idSplit[0]].answerList[idSplit[1]].IsChecked__c = false;
                $A.util.removeClass(selectedItemNew, 'selectAnswer');
                questionList[idSplit[0]].question.TotalScore__c = 0;
            }
            checkList.questionWrapperList = questionList;
            component.set('v.checkList', checkList);
            helper.countCheckAnswer(component);
            return;
        }
        
        // console.log(selectedItemNew)
        for(var i=0; i<dataSetLength; i++) {
            
            if(checkList.isPm){
                questionList[idSplit[0]].answerList[i].IsPMChecked__c = false;
            } else {
                questionList[idSplit[0]].answerList[i].IsChecked__c = false;
            }
            console.log('IsChecked__c : ' + questionList[idSplit[0]].answerList[i].IsChecked__c);
            // console.log(questionList[questionIdx].answerList[i]);
            
            // $A.util.removeClass(document.getElementById(removeAttr), 'selectAnswer');
        }
        // console.log(dataSetId.split('-')[0]);
        // console.log(dataSetId.split('-')[1]);
        // console.log(questionList[dataSetId.split('-')[0]]);
        // console.log(questionList[dataSetId.split('-')[0]].answerList[dataSetId.split('-')[1]]);
        
        console.log(idSplit);
        // console.log(questionList[idSplit[0]].answerList[idSplit[1]].Score__c);
        if(checkList.isPm){
            questionList[idSplit[0]].answerList[idSplit[1]].IsPMChecked__c = true;
            questionList[idSplit[0]].question.TotalPMScore__c = questionList[idSplit[0]].answerList[idSplit[1]].Score__c == null ? 0 : questionList[idSplit[0]].answerList[idSplit[1]].Score__c;
        } else {
            questionList[idSplit[0]].answerList[idSplit[1]].IsChecked__c = true;
            questionList[idSplit[0]].question.TotalScore__c = questionList[idSplit[0]].answerList[idSplit[1]].Score__c == null ? 0 : questionList[idSplit[0]].answerList[idSplit[1]].Score__c;
        }
        // console.log( questionList[idSplit[0]].answerList[idSplit[1]].IsChecked__c);
        // console.log(selectedItemNew);
        checkList.questionWrapperList = questionList;

        component.set('v.checkList', checkList);
        $A.util.addClass(selectedItemNew, 'selectAnswer');
        helper.countCheckAnswer(component);
    },
    
    handleSaveAnswer : function(component, event, helper){
        if(component.get('v.isSave')){
            console.log('isSaving');
            return;
        }
        component.set('v.isSave', true);
        component.set('v.isModalLoading', true);
        
        var isEditModal = component.get('v.isEditModal'),
            checkList = component.get('v.checkList'),
            updateQuestionList  = checkList.questionWrapperList,
            //nonCheckQuestion = [],
            checkQuestion = [];

        component.set('v.isEditModal', !isEditModal);
        //component.set('v.isLoading', true);
        // console.log(updateQuestionList);
        // console.log('=======================================');
        for(var i=0; i<updateQuestionList.length; i++){
            var answerCheck = false;
            console.log('******************' + i + '********************');
            console.log(updateQuestionList[i].question);
            var QanswerList = updateQuestionList[i].answerList;
            for(var j=0; j<QanswerList.length; j++){
                console.log(QanswerList[j].IsChecked__c);
                if(QanswerList[j].IsChecked__c == true){
                    answerCheck = true;
                    console.log(i + ' - - ' + j);
                    console.log(answerCheck);
                }
                // 2021-03-25 답변 미체크일경우에도 평가 근거 저장
                //if(QanswerList[j].IsChecked__c || QanswerList[j].IsPMChecked__c){
                    //console.log(updateQuestionList[i].BasisMap);
                    QanswerList[j].EvaluationDepartmentEvaluationBasis__c = updateQuestionList[i].BasisMap.User;
                    QanswerList[j].ProposalPMEvaluationBasis__c = updateQuestionList[i].BasisMap.PM;
                //} else {
                //    QanswerList[j].EvaluationDepartmentEvaluationBasis__c = '';
                //    QanswerList[j].ProposalPMEvaluationBasis__c = '';
                //}
                //if(QanswerList.length == (j + 1) && answerCheck == false){
                //    nonCheckQuestion.push(updateQuestionList[i].question.Question__c);
                //}
                //console.log(QanswerList[j]);
                checkQuestion.push(QanswerList[j]);
            }
            console.log('***********************************************');
        }
        /*
        if(nonCheckQuestion.length > 0){
            var isTrue = confirm(nonCheckQuestion + ' 의 문제가 완료되지 않음 저장?');
            if(!isTrue) {
                console.log('저장안함');
                return;
            }
        }
        */
        helper.saveAnswer(component, event, helper,checkQuestion);
    },
    
    handleSelectAnsMulti : function(component, event, helper){
        console.log('::::: handleSelectAnsMulti :::::')
        var dataSetId = event.currentTarget.dataset.id,
            dataSetLength = event.currentTarget.dataset.length,
            selectedItemNew = document.getElementById(dataSetId),
            hasClass = $A.util.hasClass(selectedItemNew, 'selectAnswer'),
            hasClassPM = $A.util.hasClass(selectedItemNew, 'selectAnswerPM'),
            checkList = component.get('v.checkList'),
            questionList = checkList.questionWrapperList;
        // console.log('select Val');
        // console.log(dataSetId);
        // console.log(questionList);
        
        var idSplit = dataSetId.split('-');
        console.log('idSplit : ' + idSplit);
        console.log('hasClass : ' + hasClass);
        if(hasClass || hasClassPM){
            if(checkList.isPm){
                questionList[idSplit[0]].answerList[idSplit[1]].IsPMChecked__c = false;
                questionList[idSplit[0]].question.TotalPMScore__c -= questionList[idSplit[0]].answerList[idSplit[1]].Score__c*1;
                $A.util.removeClass(selectedItemNew, 'selectAnswerPM');
            } else {
                questionList[idSplit[0]].answerList[idSplit[1]].IsChecked__c = false;
                questionList[idSplit[0]].question.TotalScore__c -= questionList[idSplit[0]].answerList[idSplit[1]].Score__c*1;
                $A.util.removeClass(selectedItemNew, 'selectAnswer');
            }
            console.log('setScore')
            checkList.questionWrapperList = questionList;
            component.set('v.checkList', checkList);
            helper.countCheckAnswer(component);
            return;
        }

        if(questionList[idSplit[0]].answerList[idSplit[1]].No__c == 0){
            for(var i=0; i<dataSetLength; i++) {
                if(checkList.isPm){
                    questionList[idSplit[0]].answerList[i].IsPMChecked__c = false;
                } else {
                    questionList[idSplit[0]].answerList[i].IsChecked__c = false;
                }
                var removeId = idSplit[0] + '-' + i + '-' + questionList[idSplit[0]].answerList[i].No__c;
                console.log('removeId : ' + removeId);
                var removeEle = document.getElementById(removeId);
                $A.util.removeClass(removeEle, 'selectAnswer');
            }
        }

        console.log('not class');
        for(var i=0; i<dataSetLength; i++) {
            // console.log(questionList[idSplit[0]].answerList[i].No__c);
            // console.log(idSplit[2]);
            //console.log('questionList[idSplit[0]].answerList[' + i + '].IsChecked__c : ' + questionList[idSplit[0]].answerList[i].IsChecked__c);
            if(questionList[idSplit[0]].answerList[i].No__c == 0 && questionList[idSplit[0]].answerList[i].IsChecked__c){
                questionList[idSplit[0]].answerList[i].IsChecked__c = false;
            }
            if(questionList[idSplit[0]].answerList[i].No__c == 0 && questionList[idSplit[0]].answerList[i].IsPMChecked__c){
                questionList[idSplit[0]].answerList[i].IsPMChecked__c = false;
            }

            if(questionList[idSplit[0]].answerList[i].No__c == idSplit[2]){
                if(checkList.isPm){
                    questionList[idSplit[0]].answerList[i].IsPMChecked__c = false;
                } else {
                    questionList[idSplit[0]].answerList[i].IsChecked__c = false;
                }
                var removeId = idSplit[0] + '-' + i + '-' + questionList[idSplit[0]].answerList[i].No__c;
                console.log('removeId : ' + removeId);
                var removeEle = document.getElementById(removeId);
                $A.util.removeClass(removeEle, 'selectAnswer');
                
            }
        }
        
        if(checkList.isPm){
            questionList[idSplit[0]].answerList[idSplit[1]].IsPMChecked__c = true;
        } else {
            questionList[idSplit[0]].answerList[idSplit[1]].IsChecked__c = true;
        }
        questionList[idSplit[0]].question.TotalScore__c = 0;
        questionList[idSplit[0]].question.TotalPMScore__c = 0;

        for(var i=0; i<dataSetLength; i++) {
            // console.log('==============='+i+'================');
            // console.log(checkList.isPm + ' && ' + questionList[idSplit[0]].answerList[i].IsPMChecked__c);
            // console.log('totalScore : ' + questionList[idSplit[0]].question.TotalScore__c);
            // console.log('totalScore : ' + questionList[idSplit[0]].answerList[i]);
            
            var TScore = questionList[idSplit[0]].answerList[i].Score__c;
            TScore = (TScore == null ? 0 : TScore*1);

            if(checkList.isPm && questionList[idSplit[0]].answerList[i].IsPMChecked__c){
                questionList[idSplit[0]].question.TotalPMScore__c += TScore;
            }
            if(!checkList.isPm && questionList[idSplit[0]].answerList[i].IsChecked__c){
                questionList[idSplit[0]].question.TotalScore__c += TScore;
            }
        }
     
        checkList.questionWrapperList = questionList;
        component.set('v.checkList', checkList);
        $A.util.addClass(selectedItemNew, 'selectAnswer');
        helper.countCheckAnswer(component);
    },

    handleSelectLR : function(component, event, helper){
        console.log('::::: handleSelectLR :::::')
        var dataSetId = event.currentTarget.dataset.id,
            dataSetLength = event.currentTarget.dataset.length,
            selectedItemNew = document.getElementById(dataSetId),
            hasClass = $A.util.hasClass(selectedItemNew, 'selectAnswer'),
            hasClassPM = $A.util.hasClass(selectedItemNew, 'selectAnswerPM'),
            checkList = component.get('v.checkList'),
            questionList = checkList.questionWrapperList;
        // console.log('select Val');
        // console.log(dataSetId);
        // console.log(questionList);
        
        var idSplit = dataSetId.split('-');
        
        console.log('hasClass : ' + hasClass);
        if(hasClass || hasClassPM){
            if(checkList.isPm){
                questionList[idSplit[0]].answerList[idSplit[1]].IsPMChecked__c = false;
                $A.util.removeClass(selectedItemNew, 'selectAnswerPM');
                questionList[idSplit[0]].question.TotalPMScore__c -= questionList[idSplit[0]].answerList[idSplit[1]].Score__c*1;
            } else {
                questionList[idSplit[0]].answerList[idSplit[1]].IsChecked__c = false;
                $A.util.removeClass(selectedItemNew, 'selectAnswer');
                questionList[idSplit[0]].question.TotalScore__c -= questionList[idSplit[0]].answerList[idSplit[1]].Score__c*1;
            }
            console.log('setScore')
            checkList.questionWrapperList = questionList;
            component.set('v.checkList', checkList);
            helper.countCheckAnswer(component);
            return;
        }
        
        console.log('not class');
        for(var i=0; i<dataSetLength; i++) {
            // console.log(questionList[idSplit[0]].answerList[i].No__c);
            // console.log(idSplit[2]);

            if(questionList[idSplit[0]].answerList[i].No__c == 0 && questionList[idSplit[0]].answerList[i].IsChecked__c){
                questionList[idSplit[0]].answerList[i].IsChecked__c = false;
            }
            if(questionList[idSplit[0]].answerList[i].No__c == 0 && questionList[idSplit[0]].answerList[i].IsPMChecked__c){
                questionList[idSplit[0]].answerList[i].IsPMChecked__c = false;
            }

            console.log(questionList[idSplit[0]].answerList[i].IsChecked__c);
            if(questionList[idSplit[0]].answerList[i].AnswerType__c == '법적리스크') {
                var removeId = idSplit[0] + '-' + i;
                console.log('removeId : ' + removeId);
                var removeEle = document.getElementById(removeId);
                if(checkList.isPm){
                    questionList[idSplit[0]].answerList[i].IsPMChecked__c = false;
                    $A.util.removeClass(removeEle, 'selectAnswerPM');
                } else {
                    questionList[idSplit[0]].answerList[i].IsChecked__c = false;
                    $A.util.removeClass(removeEle, 'selectAnswer');
                }
                
            }
            if(questionList[idSplit[0]].answerList[i].AnswerType__c == '손해배상'){
                if(checkList.isPm && questionList[idSplit[0]].answerList[i].IsPMChecked__c){
                    questionList[idSplit[0]].question.TotalPMScore__c = questionList[idSplit[0]].answerList[i].Score__c*1
                }
                if(!checkList.isPm && questionList[idSplit[0]].answerList[i].IsChecked__c){
                    questionList[idSplit[0]].question.TotalScore__c = questionList[idSplit[0]].answerList[i].Score__c*1
                }
            }
        }
        
        if(checkList.isPm){
            questionList[idSplit[0]].answerList[idSplit[1]].IsPMChecked__c = true;
            questionList[idSplit[0]].question.TotalPMScore__c += questionList[idSplit[0]].answerList[idSplit[1]].Score__c == null ? 0 : questionList[idSplit[0]].answerList[idSplit[1]].Score__c*1;
            questionList[idSplit[0]].question.TotalPMScore__c = questionList[idSplit[0]].question.TotalPMScore__c > 5 ? 5 : questionList[idSplit[0]].question.TotalPMScore__c;
        } else {
            questionList[idSplit[0]].answerList[idSplit[1]].IsChecked__c = true;
            questionList[idSplit[0]].question.TotalScore__c += questionList[idSplit[0]].answerList[idSplit[1]].Score__c == null ? 0 : questionList[idSplit[0]].answerList[idSplit[1]].Score__c*1;
            questionList[idSplit[0]].question.TotalScore__c = questionList[idSplit[0]].question.TotalScore__c > 5 ? 5 : questionList[idSplit[0]].question.TotalScore__c;
        }
        checkList.questionWrapperList = questionList;
        component.set('v.checkList', checkList);
        $A.util.addClass(selectedItemNew, 'selectAnswer');
        helper.countCheckAnswer(component);
    },

    handleSelectCFD : function(component, event, helper){
        console.log('::::: handleSelectCFD :::::')
        var dataSetId = event.currentTarget.dataset.id,
            dataSetLength = event.currentTarget.dataset.length,
            selectedItemNew = document.getElementById(dataSetId),
            hasClass = $A.util.hasClass(selectedItemNew, 'selectAnswer'),
            hasClassPM = $A.util.hasClass(selectedItemNew, 'selectAnswerPM'),
            checkList = component.get('v.checkList'),
            questionList = checkList.questionWrapperList;
        // console.log('select Val');
        // console.log(dataSetId);
        // console.log(questionList);
        
        var idSplit = dataSetId.split('-');
        
        console.log('hasClass : ' + hasClass);
        if(hasClass || hasClassPM){
            if(checkList.isPm){
                questionList[idSplit[0]].answerList[idSplit[1]].IsPMChecked__c = false;
                $A.util.removeClass(selectedItemNew, 'selectAnswerPm');
                questionList[idSplit[0]].question.TotalPMScore__c -= questionList[idSplit[0]].answerList[idSplit[1]].Score__c*1;
            } else {
                questionList[idSplit[0]].answerList[idSplit[1]].IsChecked__c = false;
                $A.util.removeClass(selectedItemNew, 'selectAnswer');
                questionList[idSplit[0]].question.TotalScore__c -= questionList[idSplit[0]].answerList[idSplit[1]].Score__c*1;
            }
            console.log('setScore')
            checkList.questionWrapperList = questionList;
            component.set('v.checkList', checkList);
            helper.countCheckAnswer(component);
            return;
        }
        console.log('not class')
        for(var i=0; i<dataSetLength; i++) {
            // console.log(questionList[idSplit[0]].answerList[i].No__c);
            // console.log(idSplit[2]);

            if(questionList[idSplit[0]].answerList[i].No__c == 0 && questionList[idSplit[0]].answerList[i].IsChecked__c){
                questionList[idSplit[0]].answerList[i].IsChecked__c = false;
            }
            if(questionList[idSplit[0]].answerList[i].No__c == 0 && questionList[idSplit[0]].answerList[i].IsPMChecked__c){
                questionList[idSplit[0]].answerList[i].IsPMChecked__c = false;
            }

            console.log(questionList[idSplit[0]].answerList[i].IsChecked__c);
            if(questionList[idSplit[0]].answerList[i].AnswerType__c == '손해배상') {
                var removeId = idSplit[0] + '-' + i;
                console.log('removeId : ' + removeId);
                var removeEle = document.getElementById(removeId);
                if(checkList.isPm){
                    questionList[idSplit[0]].answerList[i].IsPMChecked__c = false;
                    $A.util.removeClass(removeEle, 'selectAnswerPM');
                } else {
                    questionList[idSplit[0]].answerList[i].IsChecked__c = false;
                    $A.util.removeClass(removeEle, 'selectAnswer');
                }
            }
            if(questionList[idSplit[0]].answerList[i].AnswerType__c == '법적리스크'){
                if(checkList.isPm && questionList[idSplit[0]].answerList[i].IsPMChecked__c){
                    questionList[idSplit[0]].question.TotalPMScore__c = questionList[idSplit[0]].answerList[i].Score__c*1
                }
                if(!checkList.isPm && questionList[idSplit[0]].answerList[i].IsChecked__c){
                    questionList[idSplit[0]].question.TotalScore__c = questionList[idSplit[0]].answerList[i].Score__c*1
                }
            }
        }
        
        if(checkList.isPm){
            questionList[idSplit[0]].answerList[idSplit[1]].IsPMChecked__c = true;
            questionList[idSplit[0]].question.TotalPMScore__c += questionList[idSplit[0]].answerList[idSplit[1]].Score__c == null ? 0 : questionList[idSplit[0]].answerList[idSplit[1]].Score__c*1;
            questionList[idSplit[0]].question.TotalPMScore__c = questionList[idSplit[0]].question.TotalPMScore__c > 5 ? 5 : questionList[idSplit[0]].question.TotalPMScore__c;
        } else {
            questionList[idSplit[0]].answerList[idSplit[1]].IsChecked__c = true;
            questionList[idSplit[0]].question.TotalScore__c += questionList[idSplit[0]].answerList[idSplit[1]].Score__c == null ? 0 : questionList[idSplit[0]].answerList[idSplit[1]].Score__c*1;
            questionList[idSplit[0]].question.TotalScore__c = questionList[idSplit[0]].question.TotalScore__c > 5 ? 5 : questionList[idSplit[0]].question.TotalScore__c;
        }
        console.log(questionList[idSplit[0]].answerList[idSplit[1]]);
        checkList.questionWrapperList = questionList;
        component.set('v.checkList', checkList);
        $A.util.addClass(selectedItemNew, 'selectAnswer');
        helper.countCheckAnswer(component);
    },

    handleShortAnswer : function(component, event, helper){
        var type = event.getSource().get('v.name'),
            value = event.getSource().get('v.value'),
            checkList = component.get('v.checkList'),
            idx = type.split('-'),
            answercheckflag;

        console.log('Answer Type : ' + type);
        console.log(value);
        console.log(checkList.questionWrapperList[idx[0]]);

        if(value == ''){
            value = 0;
            answercheckflag = false;
        } else {
            
            answercheckflag = true;
        }
        
        if(idx[1] == 'PM') {
            checkList.questionWrapperList[idx[0]].question.TotalPMScore__c = value;
            checkList.questionWrapperList[idx[0]].answerList[idx[2]].IsPMChecked__c = answercheckflag;
        } else {
            checkList.questionWrapperList[idx[0]].question.TotalScore__c = value;
            checkList.questionWrapperList[idx[0]].answerList[idx[2]].IsChecked__c = answercheckflag;
        }

        component.set('v.checkList', checkList);
        helper.countCheckAnswer(component);
    },

    handleClose : function(component, event, helper){
        component.set('v.checkList', null);
        component.set('v.checkAnswerCount', '0');
        var isModal = component.get('v.isModal');
        component.set('v.isModal', !isModal);
        
        var init = component.get('c.init');
        $A.enqueueAction(init);
        
    },

    loadMoreData: function (component, event, helper) {

        if(component.get('v.loding')) return;
        
        console.log('+++++++++++++++++++++++++++++++++++++loadMoreData+++++++++++++++++++++++++++++++++++++');


        component.set('v.isLoading', true);
        component.set('v.loding', true);

        helper.moreData(component, event, helper);
    },

    handleSearch : function (component, event, helper) {
        var type = event.getSource().get('v.name');
        var value = event.getSource().get('v.value');
        component.set('v.isLoading', true);
        component.set('v.data', []);
        component.set('v.enableInfiniteLoading', true);
        if(type == 'DeadLine') {
            console.log('type is deadline : ' + value);
            helper.doInit(component, event, helper);
        } else if (type == 'Decision') {
            console.log('type is Decision: ' + value);
            helper.doInit(component, event, helper);
        } else if (type == 'Approval') {
            var value = event.getSource().get('v.checked');
            console.log('type is Approval: ' + value);
            helper.doInit(component, event, helper);
        }
    }
})