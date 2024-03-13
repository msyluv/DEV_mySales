import { LightningElement, wire,api,track } from 'lwc';
import FullCalendarJS from '@salesforce/resourceUrl/Fullcandernew';
import FullCalendarCustom from '@salesforce/resourceUrl/CustomfullCalendarCss';
import { refreshApex } from '@salesforce/apex';
import { loadStyle ,loadScript} from 'lightning/platformResourceLoader';
import { NavigationMixin } from "lightning/navigation";
import getAllMeetingsData from '@salesforce/apex/customFullCalendarcontroller.getAllEvendata';
import getAllknoxData from '@salesforce/apex/customFullCalendarcontroller.getKnoxSchedules';
import getjobstatus from '@salesforce/apex/customFullCalendarcontroller.getAsnycjobStatus';
import geteventcount from '@salesforce/apex/customFullCalendarcontroller.geteventcount';

import { encodeDefaultFieldValues } from "lightning/pageReferenceUtils";
import LightningConfirm from 'lightning/confirm';
import { deleteRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {subscribe} from 'lightning/empApi';

export default class CustomCalendar extends NavigationMixin(LightningElement) {

    calendar;
    calendarTitle;
    objectLabel = '';
    timezone;
    eventsList = [];
    dataToRefresh;
    batchJobId;
    totalBatch;
    executedPercentage;
    executedBatch;
    executedIndicator;
    eventlistsize;
    refreshsave;
    /*
   @track latestPayload ='';
    subscription = null;
    channelName ='/event/Refresh_Record_Event__e';
    */
    @track isLoaded =false;
    objectApiName = 'Event';
    viewOptions = [
        {
            label: 'Day',
            viewName: 'timeGridDay',
            checked: false
        },
        {
            label: 'Week',
            viewName: 'timeGridWeek',
            checked: false
        },
        {
            label: 'Month',
            viewName: 'dayGridMonth',
            checked: true
        },
        {
            label: 'Table',
            viewName: 'listView',
            checked: false
        }
    ];
    @wire(getAllMeetingsData)
   WiredEvents(result) {
       console.log('resultevent',result);
        if(result.data) {
            const eventList = [];
            for(let evet of result.data) {
                const event = {
                    id: evet.Id,
                    editable: true, 
                    allDay : evet.IsAllDayEvent,
                    start: evet.StartDateTime,
                    end: evet.EndDateTime,
                    title: evet.Subject
                }
                this.timezone = evet.CreatedBy.TimeZoneSidKey;
                eventList.push(event);
            }
            const listsize = eventList.length;
            console.log('listsize',listsize);
            this.eventlistsize = listsize;
            console.log('timezoneval',this.timezone);
            this.eventsList = eventList;
            this.dataToRefresh = result;
            console.log('refreh',this.dataToRefresh);
            this.refreshHandler();
        } else if(result.error){
            console.log(error);
        }
    }
    changeViewHandler(event) {
        const viewName = event.detail.value;
        if(viewName != 'listView') {
            this.calendar.changeView(viewName);
            const viewOptions = [...this.viewOptions];
            for(let viewOption of viewOptions) {
                viewOption.checked = false;
                if(viewOption.viewName === viewName) {
                    viewOption.checked = true;
                }
            }
            this.viewOptions = viewOptions;
            this.calendarTitle = this.calendar.view.title;
        } else {
            this.handleListViewNavigation(this.objectApiName);
        }
    }

    handleListViewNavigation(objectName) {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: objectName,
                actionName: 'list'
            },
            state: {
                filterName: 'Recent' 
            }
        });
    }

    calendarActionsHandler(event) {
        const actionName = event.target.value;
        if(actionName === 'previous') {
            this.calendar.prev();
        } else if(actionName === 'next') {
            this.calendar.next();
        } else if(actionName === 'today') {
            this.calendar.today();
        } else if(actionName === 'new') {
            this.navigateToNewRecordPage(this.objectApiName,'');
        } else if(actionName === 'refresh') {
            this.refreshHandler();
        }
        this.calendarTitle = this.calendar.view.title;
    }

    navigateToNewRecordPage(objectName,defaultValues) {
        console.log('nvaigate');
        console.log('defaultvalueaftercalling',defaultValues);

      
        console.log('defaultvalueaftercalling1',defaultValues);
          
        this[NavigationMixin.Navigate]({
          type: "standard__objectPage",
          attributes: {
            objectApiName: objectName,
            actionName: "new",
          },
          state: {
              count: '1',
              nooverride : '1',
              useRecordTypeCheck : '1',
            defaultFieldValues: defaultValues,
            navigationLocation: 'RELATED_LIST'
          }
        })
        console.log('Enter after refresh');
        this.refreshsave = false;
        let count = 0;
        this._interval = setInterval(() => {
            if (this.refreshsave == true || count == 20){
                clearInterval(this._interval);  
            } else {
                this.getEventcount();
                count = count + 1;
                console.log('countcoming',count);

            }
        }, 5000); //refersh view every time
    }
    getEventcount(){
        geteventcount({}).then(res => {
        const updatelist = res;
        const updalistsize = updatelist.length;
        console.log('updalistsize',updalistsize);
        if(updalistsize != this.eventlistsize){
          this.refreshsave = true;
          this.refreshHandler();
        }
       
    }).catch(err => {
        console.log('err ', err);

    })
   }

    connectedCallback() {
        Promise.all([
            loadStyle(this, FullCalendarJS + '/lib/main.css'),
            loadStyle(this, FullCalendarCustom),

            loadScript(this, FullCalendarJS + '/lib/main.js')
        ])
        .then(() => {
            this.initializeCalendar();
        })
        .catch(error => console.log(error))

       // this.handleSubscribe();
    }
   
    refreshHandler() {
        console.log('refreshevntcall');
        refreshApex(this.dataToRefresh)
        .then(() => {
            this.initializeCalendar();
        });
    }
    initializeCalendar() { 
        const calendarEl = this.template.querySelector('div.fullcalendar');
        const copyOfOuterThis = this;
        console.log('eventlistcoming',copyOfOuterThis.eventsList);
        const calendar = new FullCalendar.Calendar(calendarEl, {
            headerToolbar: false,
            initialDate: new Date(),
            timeZone: this.timezone,
            showNonCurrentDates: true,
            fixedWeekCount: false,
            allDaySlot: true,
            navLinks: true ,   
            selectable: true ,
            events: copyOfOuterThis.eventsList,
            eventDisplay: 'block',
            eventColor: '#87cefa',
            eventTimeFormat: {
                hour: 'numeric',
                minute: '2-digit',
                omitZeroMinute: true,
                meridiem: 'short'
            },
            dayMaxEventRows: true,
            views : {
                timeGrid : {
                    dayMaxEventRows : 5
                }
            },
            moreLinkClick: true,
            eventTextColor: 'rgb(3, 45, 96)',   
            dateClick: function(info) {
                console.log('info',info);

                if(info.allDay){
                    const startime = info.dateStr + 'T00:00:00Z';
                console.log('startime',startime);
                    const defaultValues = encodeDefaultFieldValues({
                        StartDateTime: startime,
                        EndDateTime: startime,
                        IsAllDayEvent: info.allDay
                    });
                    copyOfOuterThis.navigateToNewRecordPage(copyOfOuterThis.objectApiName, defaultValues);    
                }
                else {
                    console.log('else part');
                const defaultValues = encodeDefaultFieldValues({
                    StartDateTime: info.dateStr,
                    IsAllDayEvent: info.allDay
                });
                copyOfOuterThis.navigateToNewRecordPage(copyOfOuterThis.objectApiName, defaultValues);
            }
            },
            eventClick: function(info) {
                console.log('infoevent',info.event._def);
                copyOfOuterThis.navigatetoEditpage(copyOfOuterThis.objectApiName,info.event);
            }
           
        });
        calendar.render();
        calendar.setOption('contentHeight', 550);
        this.calendarTitle = calendar.view.title;
        this.calendar = calendar;
    }
     navigatetoEditpage(objectName,event){

         console.log('idval',event._def.publicId);
         const recrdid = event._def.publicId;
         console.log('recordoid',recrdid);
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
             //   objectApiName: objectName,
              recordId: recrdid,
              actionName: "view",
            }
           
          });
    }

    calendarknoxHandler(event){
        const actionName = event.target.value;
        console.log('actionname',actionName);
        console.log('clicekd on knox');
        this.isLoaded = true;
        this.batchJobId ='';
        this.isBatchCompleted = false;
        console.log('batchJobId',this.batchJobId);
        getAllknoxData({
        }).then(res => {
            console.log('response => ', res);
            if (res) {
                this.batchJobId = res;
                this.getBatchStatus();
            }
        }).catch(err => {
            console.log('err ', err);

        })
    }
    getBatchStatus() {
           console.log('Enter into getbaatchstatus');
        getjobstatus({ jobId: this.batchJobId }).then(res => {
            console.log('response => ', res);
            if (res!= null) {
                this.totalBatch = res.TotalJobItems;
                console.log('totalBatch',this.totalBatch);
                if (res.Status == 'Completed') {
                    this.isBatchCompleted = true;
                    this.isLoaded = false;
                    this.showEventMsg();
                    this.refreshHandler();
                }
                else{
                if(res.JobItemsProcessed != 0){
                    console.log('entery1');
                this.executedPercentage = ((res.JobItemsProcessed / res.TotalJobItems) * 100).toFixed(2);
                console.log('Entry2');
                this.executedBatch = res.JobItemsProcessed;
                console.log('Entry3');
                var executedNumber = Number(this.executedPercentage);
                this.executedIndicator = Math.floor(executedNumber);
                }
                 this.refreshBatchOnInterval();  //enable this if you want to refresh on interval
            }
        }
        }).catch(err => {
            console.log('err ', err);

        })
    }
    
    refreshBatchOnInterval() {
        console.log('Enterinto refresh');
        this._interval = setInterval(() => {
            if (this.isBatchCompleted) {
                clearInterval(this._interval);
            } else {
                this.getBatchStatus();
            }
        }, 5000); //refersh view every time
    }
    showEventMsg(){
        const event = new ShowToastEvent({
            message: 'Successfully',
            variant: 'success',
            mode: 'dismissable',
            duration : 5000
        });
        this.dispatchEvent(event);
    }
    /*
    handleSubscribe(){
        const messageCallback = (response) => {
            this.latestPayload = JSON.stringify(response);
        };
        subscribe(this.channelName, -1, messageCallback).then((response) =>{
            console.log('subscription request sent to',JSON.stringify(response.channel));
        });
    } */
}