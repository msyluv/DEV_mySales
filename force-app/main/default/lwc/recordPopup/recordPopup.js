import { LightningElement,api,wire,track } from 'lwc';
import getEventData from '@salesforce/apex/recordpopupcontroller.getEventData';
import getTaskData from '@salesforce/apex/recordpopupcontroller.getTaskData';

import updateEventData from '@salesforce/apex/recordpopupcontroller.updateEventData';
import updateTaskData from '@salesforce/apex/recordpopupcontroller.updateTaskData';
import { refreshApex } from '@salesforce/apex';
import deleteEventData from '@salesforce/apex/recordpopupcontroller.deleteEventData';
import deleteTaskData from '@salesforce/apex/recordpopupcontroller.deleteTaskData';
import {getObjectInfo} from 'lightning/uiObjectInfoApi';
import EVENT_OBJECT from '@salesforce/schema/Event';
import EVENT_SUBJECT from '@salesforce/schema/Event.Subject';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getUserInfo } from 'lightning/uiRecordApi';
import searchUsers from '@salesforce/apex/recordpopupcontroller.searchUsers';
import searchContacts from '@salesforce/apex/recordpopupcontroller.searchContacts';
import getEventTypes from '@salesforce/apex/recordpopupcontroller.getEventTypes';
import getTaskTypes from '@salesforce/apex/recordpopupcontroller.getTaskTypes';
import getTaskTypesP from '@salesforce/apex/recordpopupcontroller.getTaskTypesP';



export default class RecordPopup extends LightningElement {
    fields =[EVENT_SUBJECT];
    modalDisplay = 'none';
    recordUrl;
    showmodal = false;
     evtrecordId;
    objApiname;
    @track eventdata;
    taskdata;
    @track showmodalevent =false;
    @track showmodaltask = false;
    datetype;
    @track showdatetime =false;
    @track showdate=false
    @track selectedOwnerId;
    @track userOptions = [];

    @track searchTerm = '';
    @track searchTermtask ='';
    @track searchTermcontact ='';
    @track searchedval = '';
    @track showDropdown = false;
    @track showDropdowncont = false;
    @track filteredUsers = [];
    @track filteredContacts =[];
    @track eventTypes = [];
    @track taskStatus =[];
    @track taskpriority =[];
    picklistWidth = '200px';

    @wire(getEventTypes)
    wiredEventTypes({ error, data }) {
        if (data) {
            this.eventTypes = data.map(option => ({
                label: option,
                value: option
            }));
        } else if (error) {
            // Handle error
        }
    }
    @wire(getTaskTypes)
    wiredTaskTypes({ error, data }) {
        if (data) {
            this.taskStatus = data.map(option => ({
                label: option,
                value: option
            }));
        } else if (error) {
            // Handle error
        }
            
    }
    @wire(getTaskTypesP)
    wiredTaskTypesP({ error, data }) {
        if (data) {
            this.taskpriority = data.map(option => ({
                label: option,
                value: option
            }));
           /* const taskprioritylist = this.taskpriority;
            for(let key of taskprioritylist){

               if( taskprioritylist[key].value == this.taskdata.Priority){
                taskprioritylist.splice(key,1);
               }
            }
            console.log('taskprioritylist',taskprioritylist);
            this.taskpriority = taskprioritylist; */
        } else if (error) {
            // Handle error
        }
    }

    handleInputChangeTask(event){
         console.log('inputtaskvaluechange');
        this.searchTermtask = event.target.value;
        this.showDropdown = true;
        this.filterUsersTask();
    }
    handleInputChange(event) {
        this.searchTerm = event.target.value;
        this.showDropdown = true;
        this.filterUsers();
    }
    handleInputChangeTaskCon(event){
       this.searchTermcontact = event.target.value;
       this.showDropdowncont = true;
       this.filterContacts();
   }
    async filterUsers() {
        if (this.searchTerm.length > 2) {
            try {
                this.filteredUsers = await searchUsers({ searchTerm: this.searchTerm });
            } catch (error) {
                // Handle error
            }
        } else {
            this.filteredUsers = [];
        }
    }
    async filterUsersTask() {
        if (this.searchTermtask.length > 2) {
            try {
                this.filteredUsers = await searchUsers({ searchTerm: this.searchTermtask });
            } catch (error) {
                // Handle error
            }
        } else {
            this.filteredUsers = [];
        }
    }
    async filterContacts() {
        if (this.searchTermcontact.length > 2) {
            try {
                this.filteredContacts = await searchContacts({ searchTerm: this.searchTermcontact });
            } catch (error) {
                // Handle error
            }
        } else {
            this.filteredUsers = [];
        }
    }
    handleActivityCurrencyChange(event){
        console.log('currencyval',event.target.value);
        this.eventdata.CurrencyIsoCode = event.target.value;
    }
    handleActivityCurrencyChangetsk(event){
        this.taskdata.CurrencyIsoCode = event.target.value;

    }
    handleUserSelect(event) {
        const userId = event.currentTarget.dataset.id;
        this.eventdata.OwnerId = userId;
        const selecteduser = this.filteredUsers.find(user => user.Id === userId);
        console.log('userid',selecteduser.Name);
        this.searchTerm = selecteduser.Name;
        console.log('value coming', this.searchTerm );
        

        // Handle user selection
        //this.searchTerm = '';
        this.showDropdown = false;
        // Dispatch event or perform other actions with the selected userId
    }
    handleUserSelectTask(event) {
        console.log('comingtousertask');
        const userId = event.currentTarget.dataset.id;
        this.taskdata.OwnerId = userId;
        const selecteduser = this.filteredUsers.find(user => user.Id === userId);
        console.log('userid',selecteduser.Name);
        this.searchTermtask = selecteduser.Name;
        console.log('value coming', this.searchTermtask );
        

        // Handle user selection
        //this.searchTerm = '';
        this.showDropdown = false;
        // Dispatch event or perform other actions with the selected userId
    }

    handleUserSelectTaskCon(event){
        const userId = event.currentTarget.dataset.id;
    
        this.taskdata.WhoId = userId;
        const selecteduser = this.filteredContacts.find(user => user.Id === userId);
        this.searchTermcontact = selecteduser.Name;
        this.showDropdowncont = false;


    }

    connectedCallback(){
        console.log('cometoconnected');
        this.addEventListener('openpopup', this.handleOpenpopup.bind(this));
    }
  
    handleOpenpopup(event) {
        console.log('popupopen');
      //  this.recordUrl = event.detail;
        this.evtrecordId =event.detail.recordid;
        this.objApiname = event.detail.recordtype;
        this.showmodalevent = false;
        console.log('evtrecordId',this.evtrecordId);
        console.log('objApiname',this.objApiname);
        if(this.objApiname == 'Event'){
        this.geteventData();
    
        }
        else {
            this.getTaskData();
         
        }
    }
    geteventData(){
        getEventData({evntrecdid: this.evtrecordId }).then(res => {
            this.eventdata =res;
            this.showmodalevent = true;
            
            this.searchTerm = res.Owner.Name;
   //         this.template.querySelector('template').render();
            if(this.eventdata.IsAllDayEvent == true){
                this.showdatetime =false;
                this.showdate= true;
           
            }
            else {
                this.showdatetime =true;
                this.showdate= false;

            }
            console.log('eventdatacoming',this.eventdata);
            console.log('modaleventval-->',this.showmodalevent);

   
           
       }).catch(err => {
           console.log('err ', err);
   
       })
    }
    getTaskData(){
        getTaskData({taskrecdid: this.evtrecordId }).then(res => {
            this.taskdata =res;
            this.searchTermtask = res.Owner.Name;
            
                //Start by Waris
                for(var i=0;i<this.taskStatus.length;i++)
                {
                    if(this.taskStatus[i].value==this.taskdata.Status)
                    {
                        let spliced=this.taskStatus.splice(i, 1);
                    }
                }

                // End by Waris
            console.log('taskStatus COMING',this.taskStatus[0].value);
            console.log('taskdatacoming',this.taskdata);
            this.showmodalevent = false;
            this.showmodaltask = true;
            

   
           
       }).catch(err => {
           console.log('err ', err);
   
       })
    }
    saveModal(){
        console.log('evnntdatabeforeupdat',this.eventdata);
        updateEventData({eventrecd: this.eventdata}).then(res => {
            console.log('eventdatacoming',res);
            this.showmodalevent = false;
            const sucmessage = 'Saved Successfully';
            const event = new CustomEvent('sendata',{
                detail: 'Saved Successfully' 
            });
            this.dispatchEvent(event);
            this.showEventMsg(sucmessage);
        }).catch(err => {
            console.log('err ', err);
            this.showEventErrorMsg(err.statusText);

        })
    }
    saveModalTask(){
        console.log('Taskdatabeforeupdate',this.taskdata);
        updateTaskData({taskrecd: this.taskdata}).then(res => {
            console.log('taskdatacoming',res);
            this.showmodaltask = false;
            const sucmessage = 'Saved Successfully';
            const event = new CustomEvent('sendata',{
                detail: 'Saved Successfully' 
            });
            this.dispatchEvent(event);
            this.showEventMsg(sucmessage);
        }).catch(err => {
            console.log('err ', err);
            this.showEventErrorMsg(err.statusText);

        })
    }
    
     
    closeModal() {
        this.showmodalevent = false;
        this.showmodaltask = false;

        this.modalDisplay = 'none';
    }
   
    handlechange(event){
        this.showDropdown = false;
        const label = event.target.label;
        const idval = event.target.id;
        const evntdata = this.eventdata;
        if(label == 'Subject'){
             evntdata.Subject = event.target.value;
        }
      
        if(label == 'All-Day Event'){
            evntdata.IsAllDayEvent = event.target.checked;
            if(evntdata.IsAllDayEvent == false){
                this.showdatetime = true;
                this.showdate = false;
            }
            else {
                this.showdatetime = false;
                this.showdate = true; 
            }
 
        }

        if(label == 'Private'){
            evntdata.IsPrivate = event.target.checked;
 
        }
        if(label == 'Description'){
            evntdata.Description = event.target.value;
 
        }  if(label == 'Assigned To'){
          //  evntdata.eventdata.Owner = event.target.value;
 
        }
        if(label == 'CurrencyIsoCode'){
            evntdata.CurrencyIsoCode = event.target.value;
 
        }
        if(label == 'Location'){
            evntdata.Location = event.target.value;
 
        }
        if(label == 'Type'){
            evntdata.Type = event.target.value;
 
        }
        if(label == 'Start' && this.showdatetime == true){
            evntdata.StartDateTime = event.target.value;
        }
        if(label == 'End' && this.showdatetime == true){
            evntdata.EndDateTime = event.target.value;
        }
        if(label == 'Start' && this.showdate == true){
            evntdata.StartDateTime = event.target.value;
        }
        if(label == 'End' && this.showdate == true){
            evntdata.EndDateTime = event.target.value;
        }

        console.log('evntdata',evntdata);
        console.log('Eventmain',this.eventdata);
    
       // console.log('subject',subject);
    }
    handetaskchange(event){
        this.showDropdown = false;
        this.showDropdowncont = false;
        const fieldname = event.target.name;
        console.log('idvalue',fieldname);
        const taskaldata = this.taskdata;
        if(fieldname == 'task_subject'){
            taskaldata.Subject = event.target.value;
        }
        if(fieldname == 'task_Assignor'){
            taskaldata.Assignor__c = event.target.value;

        }
        if(fieldname == 'task_Private'){
            taskaldata.PrivateTask__c = event.target.checked;
 
        }
        if(fieldname == 'task_date'){
            taskaldata.ActivityDate = event.target.value;

        }
      
        if(fieldname == 'task_Comments'){
            taskaldata.Description = event.target.value;

        }
    }
    handetaskchangestatus(event){
        this.taskdata.Status = event.target.value;
        this.showDropdown = false;
        this.showDropdowncont = false;
    }
    handetaskchangepriority(event){
        this.taskdata.Priority = event.target.value;
        this.showDropdown = false;
        this.showDropdowncont = false;

    }
    handleDelete(event){
        deleteEventData({eventrecdid: this.evtrecordId}).then(res => {
            console.log('eventdatacoming',res);
            this.showmodalevent = false;

            const sucmessage = 'Deleted Successfully';
          const event = new CustomEvent('sendata',{
                detail: 'Deleted Successfully' 
            });
            this.dispatchEvent(event);
            this.showEventMsg(sucmessage);
        }).catch(err => {
            console.log('err ', err);
    
        })
    }
    handleDeletetask(event){
        deleteTaskData({taskrecdid: this.evtrecordId}).then(res => {
            this.showmodaltask = false;

            const sucmessage = 'Deleted Successfully';
          const event = new CustomEvent('sendata',{
                detail: 'Deleted Successfully' 
            });
            this.dispatchEvent(event);
            this.showEventMsg(sucmessage);
        }).catch(err => {
            console.log('err ', err);
    
        })
    }
    showEventMsg(sucmessage){
        const event = new ShowToastEvent({
            message: sucmessage,
            variant: 'success',
            mode: 'dismissable',
            duration : 5000
        });
        this.dispatchEvent(event);
    }
    showEventErrorMsg(errormsg){
        const event = new ShowToastEvent({
            message: errormsg,
            variant: 'error',
            mode: 'dismissable',
            duration : 5000
        });
        this.dispatchEvent(event);
    }
}