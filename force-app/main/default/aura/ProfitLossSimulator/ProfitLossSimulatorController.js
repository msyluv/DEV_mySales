/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 05-07-2021
 * @last modified by  : woomg@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   01-21-2021   woomg@dkbmc.com   Initial Version
**/
({
    doInit : function(component, event, helper) {
        var device = $A.get("$Browser.formFactor");
        if(device != "DESKTOP"){
            component.set('v.isMobile',true);
        }

        helper.doInit(component, event);
    },

    onRender : function(component, event, helper) {
        console.log('onRender');
        if(component.find("main-box") != undefined && component.get("v.firstRender")){
            component.set("v.firstRender", false)
            helper.setWindowSize(component);
        }
        helper.setTablePaneScrollSync(component, event);
    },

    changeYear: function (component, event, helper) {
        var bizYear = event.getParam("value");
        component.set("v.bizYear", bizYear);
        helper.loadInitialData(component);
    },

    changeDept3: function (component, event, helper) {
        var dept3Code = event.getParam("value");
        component.set("v.dept3Code", dept3Code);
        helper.loadInitialData(component);
    },

    changeSimulVersion: function (component, event, helper) {
        var simul = event.getParam("value");
        component.set("v.simulationId", simul);
        helper.queryData(component)
            .then(function(result){
                console.log('query data', result);
            });
    },

    changeDept4: function (component, event, helper) {
        var dept4Code = event.getParam("value");
        component.set("v.dept4Code", dept4Code);
            helper.queryData(component)
            .then(function(result){
                console.log('query data', result);
            });
    },

    changeBizType1: function (component, event, helper) {
        var bizType1 = event.getParam("value");
        component.set("v.bizType1", bizType1);
        helper.queryData(component)
            .then(function(result){
                console.log('query data', result);
            });
    },

    changeRows: function (component, event, helper) {
        var pageSize = event.getParam("value");
        component.set("v.pageSize", pageSize);
        helper.queryData(component)
        .then(function(result){
            console.log('query data', result);
        });
    },

    changePage: function (component, event, helper) {
        var pageNum = event.getParam("value");
        component.set("v.pageNum", pageNum);
        helper.queryData(component)
        .then(function(result){
            console.log('query data', result);
        });
    },

    clickOpenInitSimul: function (component, event, helper){
        console.log("click open initsimul");
        helper.getVersion(component);
    },

    clickCancelInitSimul: function (component, event, helper){
        component.set("v.openInitSimul", false);
    },

    selectYear: function (component, event, helper) {
        var bizYear = event.getParam("value");
        component.set("v.initYear", bizYear);
    },

    selectDept3: function (component, event, helper) {
        var teamCode = event.getParam("value");
        component.set("v.initTeam", teamCode);
    },

    selectVersion: function (component, event, helper) {
        var version = event.getParam("value");
        component.set("v.version", version);
    },

    selectFromDate: function (component, event, helper) {
        var fromDate = event.getParam("value");
        component.set("v.fromDate", fromDate);
    },
    
    clickCreateInitSimul: function (component, event, helper) {
        console.log("click create");
        var simulVersion = component.get("v.simulationVersion");

        if(simulVersion == undefined || simulVersion == "" || simulVersion.length < 3){
            helper.showMyToast("error", "You should input the version of simulation!");
        } else {
            helper.createSimulation(component);
        }
    },

    clickGetProfitLoss: function (component, event, helper) {
        console.log("clickGetProfitLoss");
        helper.importProfitLoss(component);
    },

    clickGetOpportunity: function (component, event, helper) {
        console.log("clickGetProfitLoss");
        helper.importProfitLoss(component);
    },

    clickImportProfitLoss: function (component, event, helper){
        helper.importProfitLoss(component);
        //component.set("v.openInitSimul", false);
    },

    clickImportOppty: function (component, event, helper){
        helper.importOppty(component);
        //component.set("v.openInitSimul", false);
    },

    clickOpenResetSimul: function (component, event, helper){
        console.log("click open resetsimul");
        component.set("v.openResetSimul", true);
    },

    clickCancelResetSimul: function (component, event, helper){
        component.set("v.openResetSimul", false);
    },
    
    clickResetSimul: function (component, event, helper){
        helper.resetSimul(component);
        //component.set("v.openInitSimul", false);
    },

    clickOpenDeleteSimul: function (component, event, helper){
        console.log("click open deletesimul");
        component.set("v.openDeleteSimul", true);
    },

    clickCancelDeleteSimul: function (component, event, helper){
        component.set("v.openDeleteSimul", false);
    },
    
    clickDeleteSimul: function (component, event, helper){
        helper.deleteSimul(component);
        //component.set("v.openInitSimul", false);
    },

    clickAllCheckbox : function (component, event, helper){
        var records = component.get("v.records"),
            checked = event.getParam("checked");
        console.log('click all check> ', checked);
        records.forEach(function(rec){
            if(checked)
                rec.selected = true;
            else
                rec.selected = false;
        })
    },

    clickCheckbox : function (component, event, helper){
        var records = component.get("v.records"),
            recordId = event.getParam("name"),
            checked = event.getParam("checked");
        
        records.forEach(function(rec){
            if(rec.Id == recordId){
                if(checked)
                    rec.selected = true;
                else
                    rec.selected = false;
            }
        })
    },

    clickOpenCalcMarginRows: function (component, event, helper){
        var marginRate = component.get("v.marginRate");
        console.log("click open calc margin");
        if(marginRate == 0){
            helper.showMyToast("error", "Margin rate required!");
        } else {
            component.set("v.calcMethod", "rows");
            component.set("v.openCalcMargin", true);    
        }
    },

    clickOpenCalcMarginCondition: function (component, event, helper){
        var marginRate = component.get("v.marginRate");
        console.log("click open calc margin");
        if(marginRate == 0){
            helper.showMyToast("error", "Margin rate required!");
        } else {
            component.set("v.calcMethod", "condition");
            component.set("v.openCalcMargin", true);    
        }
    },

    clickCancelCalcMargin: function (component, event, helper){
        component.set("v.openCalcMargin", false);
    },
    
    clickCalcMargin: function (component, event, helper){
        helper.calcMargin(component);
        //component.set("v.openInitSimul", false);
    },

    clickOppty: function(component, event, helper){
        var companyCode = event.getParam("name"),
            opptyCode = event.getParam("title");

        helper.openOpportunity(component, companyCode, opptyCode);
    },

    clickRowEdit: function(component, event, helper){
        component.set("v.openRowEdit", true);
        // var recordId = event.getParam("name"),
        //     record = {},
        //     records = component.get("v.records");
        
        // records.forEach(function(rec){
        //     if(rec.Id == recordId){
        //         record = rec;
        //     }
        // });
        // if(record.Id != undefined){
        //     component.set("v.record", record);
        //     component.set("v.openRowEdit", true);
        // }
    },

    clickCancelRevenuePlan: function(component, event, helper){
        component.set("v.openRowEdit", false);
    },

    saveRowEdit: function(component, event, helper){
        helper.updateRevenuePlan(component);
    },

})