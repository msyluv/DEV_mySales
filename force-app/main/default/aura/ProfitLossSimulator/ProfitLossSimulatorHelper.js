/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 05-13-2021
 * @last modified by  : woomg@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   01-21-2021   woomg@dkbmc.com   Initial Version
**/
({
    doInit : function(component, event) {
        var self = this,
            today = new Date(),
            bizYear = today.getFullYear().toString(),
            companyCode = '',
            dept2Code = '',
            dept3Code = '',
            dept4Code = '';

        component.set("v.bizYear", bizYear);
        component.set("v.closeDate", bizYear + "-01-01");
        component.set("v.fromDate", bizYear + "-01-01")
        //self.setWindowSize(component);
        window.addEventListener('resize', function(){
            self.setWindowSize(component);
        });

        component.set("v.showSpinner", true);
        self.apex(component, 'getEmployeeInfo',  { })
            .then(function(result){
                console.log('getEmployeeInfo -> ', result);
                component.set("v.employeeInfo", result);
                companyCode = result.CompanyCode__c;
                dept2Code = result.Node2__c;
                dept3Code = result.Node4__c;
                //dept4Code = result.Node4__c;
                dept4Code = 'all';
                component.set("v.companyCode", companyCode);
                component.set("v.dept2Code", dept2Code);
                component.set("v.dept3Code", dept3Code);
                component.set("v.dept4Code", dept4Code);

                component.set("v.initYear", bizYear);
                component.set("v.initCompany", companyCode);
                component.set("v.initDept", dept2Code);
                component.set("v.initTeam", dept3Code);

                return self.apex(component, 'getCompany',  { });
            })
            .then(function(result){
                console.log('getCompany -> ', result);
                component.set("v.companyList", result);
                return self.apex(component, 'getDepartment2',  { companyCode : companyCode });
            })
            .then(function(result){
                console.log('getDepartment2 -> ', result);
                component.set("v.dept2List", result);
                return self.apex(component, 'getDepartment3',  { companyCode : companyCode, dept2Code : dept2Code });
            })
            .then(function(result){
                console.log('getDepartment3 -> ', result);
                component.set("v.dept3List", result);

                return self.apex(component, 'getDepartment4',  { companyCode : companyCode, dept2Code : dept2Code, dept3Code : dept3Code });
            })
            .then(function(result){
                console.log('getDepartment4 -> ', result);
                component.set("v.dept4List", result);

                return self.apex(component, 'getSimulations',  { bizYear : bizYear, companyCode : companyCode, dept2Code : dept2Code, dept3Code : dept3Code });
            })
            .then(function(result){
                console.log('getSimulations -> ', result);
                if(result.length > 0){
                    component.set("v.simulVersionList", result);
                    component.set("v.simulationId", result[0].value);    
                    return self.apex(component, 'getProfitLossSimulationHeader',  { headerId : result[0].value });
                }
            })
            .then(function(result){
                console.log('getProfitLossSimulationHeader -> ', result);
                if(result != undefined && result.SIMUL_VERSION__c != undefined){
                    component.set("v.simulation", result);
                    component.set("v.closeDate", result.FROM_DATE__c);
                    component.set("v.fromDate", result.FROM_DATE__c);
                    return self.loadInitialData(component);
                }
            })
            .then(function(result){
                console.log('loadInitialData -> ', result);
                component.set("v.showSpinner", false);
            })
            .catch(function(errors){
                self.errorHandler(errors);
                component.set("v.showSpinner", false);
            });
    },

    setWindowSize : function(component){
        var screenWidth = window.screen.width,
            screenHeight = window.screen.height,
            windowWidth = window.innerWidth,
            windowHeight = window.innerHeight,
            headerHeight = 143, sandboxHeader = 33, tablePadding = 58, tablePaddingFull = 34,
            searchPaneHeight = 120, footerPaneHeight = 37, summaryRowHeight = 30,
            pageHeight = 0, tableHeight = 0, tablePaneRightWidth = 0, 
            tablePaneLeftWidth = component.get("v.tablePaneLeftWidth"), 
            tablePaneScrollLeftHeight = 0, tablePaneScrollRightHeight = 0;

        var modal = component.find('main-box');
        if(screenWidth == windowWidth && screenHeight == windowHeight){
            // Full-size window by F11 Function Key
            $A.util.addClass(modal, "slds-modal");
            $A.util.addClass(modal, "slds-fade-in-open");
            pageHeight = windowHeight - 30; // slds-box padding
            tableHeight = pageHeight - (searchPaneHeight+footerPaneHeight+summaryRowHeight);
            //tableHeight = pageHeight - (searchPaneHeight+summaryRowHeight);
            tablePaneRightWidth = windowWidth - (tablePaneLeftWidth + tablePaddingFull);
        } else {
            $A.util.removeClass(modal, "slds-modal");
            $A.util.removeClass(modal, "slds-fade-in-open");
            pageHeight = windowHeight - (headerHeight + sandboxHeader);
            tableHeight = pageHeight - (searchPaneHeight+footerPaneHeight+summaryRowHeight);
            //tableHeight = pageHeight - (searchPaneHeight+summaryRowHeight);
            tablePaneRightWidth = windowWidth - (tablePaneLeftWidth + tablePadding);
        }
        // Left & Right table's scroll height balance
        tablePaneScrollLeftHeight = tableHeight - 81;
        tablePaneScrollRightHeight = tableHeight - 64;

        var mainPage = component.find("mainPage").getElement(),
            uiTablePane = component.find("uiTablePane").getElement(),
            uiTablePaneLeft = component.find("uiTablePaneLeft").getElement(),
            uiTablePaneLeftScroll = component.find("uiTablePaneLeftScroll").getElement(),
            uiTablePaneRight = component.find("uiTablePaneRight").getElement(),
            uiTablePaneScrollRight = component.find("uiTablePaneRightScroll").getElement(),
            uiTablePaneLeftSum = component.find("uiTablePaneLeftSum").getElement(),
            uiTablePaneRightSum = component.find("uiTablePaneRightSum").getElement();

        mainPage.style.height = pageHeight + 'px';
        mainPage.style.maxHeight = pageHeight + 'px';
        uiTablePane.style.height = tableHeight + 'px';
        uiTablePane.style.maxHeight = tableHeight + 'px';
        uiTablePaneLeft.style.width = tablePaneLeftWidth + 'px';
        uiTablePaneLeft.style.maxWidth = tablePaneLeftWidth + 'px';
        uiTablePaneLeftScroll.style.height = tablePaneScrollLeftHeight + 'px';
        uiTablePaneLeftScroll.style.maxHeight = tablePaneScrollLeftHeight + 'px';
        uiTablePaneRight.style.width = tablePaneRightWidth + 'px';
        uiTablePaneRight.style.maxWidth = tablePaneRightWidth + 'px';
        uiTablePaneScrollRight.style.width = tablePaneRightWidth + 'px';
        uiTablePaneScrollRight.style.maxWidth = tablePaneRightWidth + 'px';
        uiTablePaneScrollRight.style.height = tablePaneScrollRightHeight + 'px';
        uiTablePaneScrollRight.style.maxHeight = tablePaneScrollRightHeight + 'px';
        uiTablePaneLeftSum.style.width = tablePaneLeftWidth + 'px';
        uiTablePaneLeftSum.style.maxWidth = tablePaneLeftWidth + 'px';
        uiTablePaneRightSum.style.width = tablePaneRightWidth + 'px';
        uiTablePaneRightSum.style.maxWidth = tablePaneRightWidth + 'px';
    },

    setTablePaneScrollSync : function(component, event){
        var isSyncingLeftScroll = false,
            isSyncingRightScroll = false,
            isSyncingHorizScroll = false,
            leftPane = component.find("uiTablePaneLeftScroll").getElement(),
            rightPane = component.find("uiTablePaneRightScroll").getElement(),
            rightupPane = component.find("uiTablePaneRightGrid").getElement(),
            rightSumPane = component.find("uiTablePaneRightSum").getElement();

        leftPane.onscroll = function(){
            if (!isSyncingLeftScroll) {
                isSyncingRightScroll = true;
                rightPane.scrollTop = this.scrollTop;
            }
            isSyncingLeftScroll = false;
        };
        rightPane.onscroll = function(){
            if (!isSyncingRightScroll) {
                isSyncingLeftScroll = true;
                leftPane.scrollTop = this.scrollTop;
                //if(this.scrollTop > leftPane.scrollTop) this.scrollTop = leftPane.scrollTop;
            }
            if (!isSyncingHorizScroll) {
                rightupPane.scrollLeft = this.scrollLeft;
                rightSumPane.scrollLeft = this.scrollLeft;
                if(rightupPane.scrollLeft != this.scrollLeft)
                    this.scrollLeft = rightupPane.scrollLeft;
            }
            isSyncingRightScroll = false;
            isSyncingHorizScroll = false;
        };
    },

    loadInitialData : function(component){
        var self = this,
            simulationId = component.get("v.simulationId"),
            bizYear = component.get("v.bizYear"),
            companyCode = component.get("v.companyCode"),
            dept2Code = component.get("v.dept2Code"),
            dept3Code = component.get("v.dept3Code");
            
        component.set("v.dept4List",[]);
        component.set("v.dept4Code", 'all');
        component.set("v.bizType1List", []);
        component.set("v.showSpinner", true);

        self.apex(component, 'getDepartment4',  {
                bizYear : bizYear, 
                companyCode : companyCode, 
                dept2Code : dept2Code, 
                dept3Code : dept3Code 
            })
            .then(function(result){
                console.log('getDepartment4 -> ', result);
                component.set("v.dept4List", result);

                return self.queryData(component);
            })
            .then(function(result){
                console.log('queryData -> ', result);

                return self.apex(component, 'getBizType', { simulationId : simulationId });
            })
            .then(function(result){
                console.log('getBizType -> ', result);
                component.set("v.bizType1List", result);
                component.set("v.bizType1", "");

                component.set("v.showSpinner", false);
            })
            .catch(function(errors){
                self.errorHandler(errors);
                component.set("v.showSpinner", false);
            });
    },

    queryData: function(component) {
        var self = this,
            pageNum = component.get("v.pageNum"),
            pageSize = component.get("v.pageSize"),
            simulationId = component.get("v.simulationId"),
            dept4Code = component.get("v.dept4Code"),
            bizType = component.get("v.bizType1");

        if(simulationId != ''){
            component.set("v.showSpinner", true);
            var params = {
                headerId : simulationId,
                dept4Code : dept4Code,
                bizType : bizType,
                pageNum : pageNum,
                pageSize : pageSize
            };
            console.log('parameters ->', params);
            return self.apex(component, 'getProfitLossSimulations', params)
                .then(function(result){
                    var records = result.profitLoss,
                        totalPage = result.totalPage,
                        pageList = new Array();
                    records.forEach(function(record){
                        record.selected = false;
                    });
                    component.set("v.records", records);
                    component.set("v.totalPage", totalPage);
                    if(totalPage => 0){
                        for(var count = 1; count <= totalPage+1; count++){
                            pageList.push({'value': ''+count, 'label' : ''+count});
                        }
                    }
                    component.set("v.pageList", pageList);

                    console.log('getProfitLossSimulations -> ', result);
                    return self.apex(component, 'getSimulationSum', { headerId : simulationId, dept4Code : dept4Code, bizType : bizType });
                })
                .then(function(result){
                    console.log('getSimulationSum -> ', result);

                    component.set("v.showSpinner", false);
                    return 'completed query';
                })
                .catch(function(errors){
                    self.errorHandler(errors);
                    component.set("v.showSpinner", false);
                });    
        }
    },

    getVersion : function(component){
        var self = this,
            bizYear = component.get("v.initYear"),
            companyCode = component.get("v.initCompany"),
            dept2Code = component.get("v.initDept"),
            dept3Code = component.get("v.initTeam");
            
        component.set("v.showSpinner", true);
        self.apex(component, 'getVersion',  {
                bizYear : bizYear, 
                companyCode : companyCode, 
                dept2Code : dept2Code, 
                dept3Code : dept3Code 
            })
            .then(function(result){
                console.log('getVersion -> ', result);
                if(result.length > 0){
                    component.set("v.versionList", result);
                    component.set("v.version", result[0].value);
                }

                component.set("v.showSpinner", false);
                component.set("v.openInitSimul", true);
            })
            .catch(function(errors){
                self.errorHandler(errors);
                component.set("v.showSpinner", false);
            });
    },

    createSimulation : function(component){
        var self = this,
            initYear = component.get("v.initYear"),
            initCompany = component.get("v.initCompany"),
            initDept = component.get("v.initDept"),
            initTeam = component.get("v.initTeam"),
            version = component.get("v.version"),
            fromDate = component.get("v.fromDate"),
            initSimulVersion = component.get("v.simulationVersion"),
            nameCompany = "",
            nameDept = "",
            nameTeam = "",
            listCompany = component.get("v.companyList"),
            listDept = component.get("v.dept2List"),
            listTeam = component.get("v.dept3List");

        for(var i = 0; i < listCompany.length; i++){
            if(initCompany == listCompany[i].value){
                nameCompany = listCompany[i].label;
                break;
            }
        }
        for(var i = 0; i < listDept.length; i++){
            if(initDept == listDept[i].value){
                nameDept = listDept[i].label;
                break;
            }
        }
        for(var i = 0; i < listTeam.length; i++){
            if(initTeam == listTeam[i].value){
                nameTeam = listTeam[i].label;
                break;
            }
        }

        self.apex(component, "createNewSimulation", {
                bizYear : initYear,
                companyCode : initCompany,
                dept2Code : initDept,
                dept3Code : initTeam, 
                nameCompany : nameCompany,
                nameDept : nameDept,
                nameTeam : nameTeam,
                version : version, 
                closeDate : fromDate, 
                simulationVersion : initSimulVersion
            })
            .then(function(result){
                console.log('createNewSimulation -> ', result);
                component.set("v.simulation", result);
                component.set("v.simulationId", result.Id);
                component.set("v.closeDate", result.FROM_DATE__c);
                component.set("v.fromDate", result.FROM_DATE__c);

                component.set("v.showSpinner", false);
                component.set("v.openInitSimul", false);
            })
            .catch(function(errors){
                self.errorHandler(errors);
                component.set("v.showSpinner", false);
                component.set("v.openInitSimul", false);
            });
    },

    importProfitLoss : function(component){
        var self = this,
            simulationId = component.get("v.simulationId");
            
        component.set("v.showSpinner", true);
        self.apex(component, 'hasOrderSummaryInSimulation',  { simulationId : simulationId })
            .then(function(result){
                console.log('hasOrderSummaryInSimulation -> ', result);
                if(result){
                    self.showMyToast("error", "Simulation already have some order summarys, remove and try again!");
                } else {
                    return self.apex(component, "importOrderSummaries", { simulationId : simulationId });
                }
            })
            .then(function(result){
                console.log('importOrderSummaries -> ', result);
                component.set("v.showSpinner", false);
            })
            .catch(function(errors){
                self.errorHandler(errors);
                component.set("v.showSpinner", false);
            });

    },

    importOppty : function(component){
        var self = this,
            simulationId = component.get("v.simulationId");
            
        component.set("v.showSpinner", true);
        self.apex(component, 'hasOrderOpptyInSimulation',  { simulationId : simulationId })
            .then(function(result){
                console.log('hasOrderOpptyInSimulation -> ', result);
                if(result){
                    self.showMyToast("error", "Simulation already have some opportunities, remove and try again!");
                } else {
                    return self.apex(component, "importOpportunities", { simulationId : simulationId });
                }
            })
            .then(function(result){
                console.log('importOpportunities -> ', result);
                component.set("v.showSpinner", false);
            })
            .catch(function(errors){
                self.errorHandler(errors);
                component.set("v.showSpinner", false);
            });

    },

    resetSimul : function(component){
        var self = this,
            simulationId = component.get("v.simulationId");
            
        component.set("v.showSpinner", true);
        self.apex(component, 'resetSimulation',  { simulationId : simulationId })
            .then(function(result){
                console.log('resetSimulation -> ', result);

                return self.queryData(component);
            })
            .then(function(result){
                console.log('queryData -> ', result);
                component.set("v.showSpinner", false);
            })
            .catch(function(errors){
                self.errorHandler(errors);
                component.set("v.showSpinner", false);
            });

    },

    deleteSimul : function(component){
        var self = this,
            records = component.get("v.records"),
            ids = new Array();
            
        component.set("v.showSpinner", true);
        records.forEach(function(rec){
            if(rec.selected){
                ids.push(rec.Id);
            }
        });
        self.apex(component, 'deleteSimulations',  { simulIds : ids })
            .then(function(result){
                console.log('deleteSimulations -> ', result);

                return self.queryData(component);
            })
            .then(function(result){
                console.log('queryData -> ', result);
                component.set("v.showSpinner", false);
            })
            .catch(function(errors){
                self.errorHandler(errors);
                component.set("v.showSpinner", false);
            });

    },

    calcMargin : function(component){
        console.log("start calcuration");
        var self = this,
            calcMethod = component.get("v.calcMethod"); // rows or condition

        if(calcMethod == "rows")
            self.calcMarginRows(component);
        else
            self.calcMarginCondition(component);
    },

    calcMarginRows : function(component){
        console.log("start calcMarginRows");
        var self = this,
            marginRate = component.get("v.marginrate"),
            records = component.get("v.records"),
            ids = new Array();

        component.set("v.showSpinner", true);
        records.forEach(function(rec){
            if(rec.selected){
                ids.push(rec.Id);
            }
        });
        self.apex(component, 'calcurateProfit',  { simulIds : ids, marginRate : marginRate })
            .then(function(result){
                console.log('calcurateProfit -> ', result);

                return self.queryData(component);
            })
            .then(function(result){
                console.log('queryData -> ', result);
                component.set("v.showSpinner", false);
            })
            .catch(function(errors){
                self.errorHandler(errors);
                component.set("v.showSpinner", false);
            });
            
    },

    calcMarginCondition : function(component){
        console.log("start calcMarginCondition");
        var self = this,
            marginRate = component.get("v.marginrate"),
            similationId = component.get("v.simulationId"),
            dept4Code = component.get("v.dept4Code"),
            bizType = component.get("v.bizType1");

        component.set("v.showSpinner", true);
        self.apex(component, 'calcurateProfit',  { 
                similationId : similationId, 
                dept4Code : dept4Code,
                bizType : bizType, 
                marginRate : marginRate
            })
            .then(function(result){
                console.log('calcurateProfit -> ', result);

                return self.queryData(component);
            })
            .then(function(result){
                console.log('queryData -> ', result);
                component.set("v.showSpinner", false);
            })
            .catch(function(errors){
                self.errorHandler(errors);
                component.set("v.showSpinner", false);
            });
    },

    openOpportunity: function(component, companyCode, opptyCode){
        var self = this;
        
        component.set("v.showSpinner", true);
        self.apex(component, 'getOpportunity', { 
                companyCode : companyCode, 
                opptyCode : opptyCode
            })
            .then(function(result){
                console.log('getOpportunity -> ', result);
                window.open("/lightning/r/Opportunity/" + result.Id + "/view", "_blank");
                component.set("v.showSpinner", false);
            })
            .catch(function(errors){
                self.errorHandler(errors);
                component.set("v.showSpinner", false);
            });

    },

    updateRevenuePlan : function(component){
        var self = this,
            record = component.get("v.record");

        component.set("v.showSpinner", true);
        self.apex(component, 'updateRevenuePlan', { 
                simulation : record
            })
            .then(function(result){
                console.log('updateRevenuePlan -> ', result);
                return self.queryData(component);
            })
            .then(function(result){
                console.log('queryData -> ', result);
                component.set("v.showSpinner", false);
            })
            .catch(function(errors){
                self.errorHandler(errors);
                component.set("v.showSpinner", false);
            });
    },

    makeDateString: function(component, dt){
        var self = this;
        return dt.getFullYear() + "-" + self.pad(dt.getMonth(), 2) + "-" + self.pad(dt.getDate(), 2);
    },

    pad : function(num, digit){
        return ("" + num).padStart(digit, '0');
    },

    /**
     * Common Functions
     */
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
            duration: 10000,
            mode: 'dismissible',
            message: msg
        });
        toastEvent.fire();
	},
})