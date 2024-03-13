/**
 * @description       : 
 * @author            : seonju.jin@dkbmc.com
 * @group             : 
 * @last modified on  : 2021-02-16
 * @last modified by  : seonju.jin@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                 Modification
 * 1.0   2020-12-07   seonju.jin@dkbmc.com   Initial Version
**/
({
	helperinit : function(component, event) {
        var self = this;
        self.getProejct(component);
        self.initTreeItems(component);
	}, 
    
    getProejct: function(component){
        var self = this;
    	self.apex(component
                  , 'getProjectInfo'
                  , {opptyId: component.get('v.recordId')}
        ).then(function(result){
            component.set("v.project_data",result);
            if(result.length > 0) self.getWBS(component,result[0].Id);

        }).catch(function(errors){
            self.errorHandler(errors);
            console.log(errors);
        }).finally(function(){
            component.set('v.isLoading', false);
        });
	},
    
    initTreeItems: function(component){
        var self = this;
        self.apex(component
                  , 'getAllProejctWBSInfo'
                  , {opptyId: component.get('v.recordId')}
        ).then(function(result){
            self.renderTreeItem(component, result);
        }).catch(function(errors){
            self.errorHandler(errors);
            console.log(errors);
		});
    },
    
    renderTreeItem: function(component, result){
        var self = this;
    	var treeItem = new Array();
		var isExpanded = false;
		var name = 1;
        
        var projectList = result.PROJECT;
        var wbsList = result.WBS;
        var mappingItem = {};

		//[{label: '', name: '', expanded: false, items:[...]}, ...]
		/* depth 표현
		   1: Project
		   2: WBS */
		try{
			for(var i = 0; i < projectList.length; i++){
                var project = projectList[i];							//Project info
                var isExpanded = (name == 1) ? true : false;			//첫번재 item expand
                var obj = {};											//parent tree obj
                
                obj.name 		= String(name++);										//tree name
                obj.label 		= self.setLabel(project.Name) 
                					+ '(' + self.setLabel(project.ProjectCode__c) + ')';	//label
                obj.expanded 	= isExpanded;											//
                
                
                
                mappingItem[obj.name] = {Id : project.Id, ProjectCode__c: project.ProjectCode__c};
                
                var items = new Array();								//child tree obj
                 //set solution tree item
                for(var j = 0; j < wbsList.length; j++){
                    var wbs = wbsList[j];
                    if(wbs.ProjectCodeOutput__c == project.ProjectCode__c){
                        var cObj = {};	
                        cObj.name = String(name++);
                        //cObj.label = '[' + self.setLabel(wbs.ItemNumber__c) + ']' 
                                        //+ self.setLabel(wbs.ServiceCode__c) + (($A.util.isEmpty(wbs.SolutionCode__c)) ? '' : ',') + self.setLabel(wbs.SolutionCode__c);
                        cObj.label = wbs.Name;
                        cObj.expanded = false;
                        cObj.items = [];
                        items.push(cObj);
                    }
                }
                obj.items = items;	
                treeItem.push(obj);
			}
			component.set('v.treeItem', treeItem);
            component.set('v.mappingItem', mappingItem);
            component.set('v.selectedTreeItem', '1');
		}catch(e){
			console.log(e.toString());
		}
	},
    
    onRowSelect: function(component, event){
        var selectedRows = event.getParam('selectedRows');
        
        if(selectedRows.length > 0) {
            var pjtId = selectedRows[0].Id;
            this.getWBS(component, pjtId);
        }
    },
    
    getWBS: function(component, pjtId){
        var recordId = component.get('v.recordId');
        var self = this;
        self.apex(component,'getWBSInfo',{
            opptyId : recordId,
            pjtId : pjtId
        }).then(function(result){
            component.set('v.wbs_data',result);
        }).catch(function(errors){
           self.errorHandler(errors);
            console.log(errors);
        });
    },
    
    setLabel: function(str){
        if(str == undefined || str == null) str = '';
        return str;
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
				self.showToast('error', 'ERROR', err.exceptionType + " : " + err.message);
			});
		} else {
			console.log(errors);
			self.showToast('error', 'ERROR' ,'errors:'+ errors.message);
		}
	},

    showToast : function(type, title, message){
		var toastEvent = $A.get("e.force:showToast");
		var mode = (type == 'success') ? 'pester' : 'sticky';
        toastEvent.setParams({
            "type" : type,
            "title": title,
			"message": message,
			"mode": mode,
			"duration": 5000
        });
        toastEvent.fire();
	},
})