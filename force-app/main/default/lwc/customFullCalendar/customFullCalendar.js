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
import getWeekdate from '@salesforce/apex/customFullCalendarcontroller.getWeekdate';
import getuserdetail from '@salesforce/apex/customFullCalendarcontroller.getuserdetail';
import synctaskuserrec from '@salesforce/apex/customFullCalendarcontroller.synctaskuserrec';
import getAllTaskData from '@salesforce/apex/customFullCalendarcontroller.gettaskdata';
import synctaskcaltoknox from '@salesforce/apex/customFullCalendarcontroller.synctaskcaltoknox';
import { encodeDefaultFieldValues } from "lightning/pageReferenceUtils";
import LightningConfirm from 'lightning/confirm';
import { deleteRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {subscribe} from 'lightning/empApi';
import TasksyncMessage from '@salesforce/label/c.TasksyncMessage';
import SyncEventSuccessMsg from '@salesforce/label/c.SyncEventSuccessMsg';
import MysalesErrorMsg from '@salesforce/label/c.MysalesErrorMsg';
import Knoxtomysalesnodata from '@salesforce/label/c.Knoxtomysalesnodata';
import Noknoxuserpresent from '@salesforce/label/c.Noknoxuserpresent';


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
    startevntdate;
    syncknoxtask = false;
    @api calendarWidth;
    @api CalendarHeight;
    @track windowwidth = 0;
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
            console.log('eventlist',result.data['Eventdata']);
            if(result.data['Eventdata']){
            for(let evet of result.data['Eventdata']) {
                const stime = (evet.StartDateTime).toString();
               // const starttime = stime.substring(0,stime.indexof();
                const startdate = stime.split('T');
                const starttime = '\xa0' + stime;
                const etime = (evet.EndDateTime).toString();
                const endtime = etime.split('T');
                const subject = (evet.Subject).toString();
                const bgColor = (evet.Knox_Calendar_Id__c).toString();

                let subject1;
                if(subject.length > 20 && evet.IsAllDayEvent == false){
                   // subject1 = subject.substring(0,23)+ '...';
                    subject1 = '\xa0\xa0'+subject;
                }
                else {
                    subject1 = subject;
                }
                
                  const event = {
                    id: evet.Id,
                    editable: true, 
                    allDay : evet.IsAllDayEvent,
                    start: evet.IsAllDayEvent?startdate[0]:evet.StartDateTime,
                    end: evet.IsAllDayEvent?endtime[0]:evet.EndDateTime,
                    title: subject,
                    color: bgColor
                };
            
                this.timezone = evet.CreatedBy.TimeZoneSidKey;
                eventList.push(event);
            }
        }
        if(result.data['taskdata']){

            for(let evet of result.data['taskdata']){
                const bgColor = (evet.Knox_Calendar_Id__c).toString();

                const event = {
                    id: evet.Id,
                    editable: true, 
                    allDay : true,
                    start: evet.ActivityDate,
                    end: evet.ActivityDate,
                    title: evet.Subject,
                    color : bgColor
                   // color: '#87cefa'
                };
            
                eventList.push(event); 
            }
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
    /*@wire(getAllTaskData)
    WiredEvents(result) {
        console.log('resultevent',result);
         if(result.data) {
             const eventList = [];
 
             for(let evet of result.data) {
    
                   const event = {
                     id: evet.Id,
                     editable: true, 
                     allDay : true,
                     start: evet.ActivityDate,
                     end: evet.ActivityDate,
                     title: evet.Subject,
                     color: '#87cefa'
                 };
             
                  eventList.push(event);
             }
 
             this.dataToRefresh = result;
             //console.log('refreh',this.dataToRefresh);
             this.eventsList = eventList;
             this.refreshHandler();
         } else if(result.error){
             console.log(error);
         }
     } */
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
       // const updatelist = res;
       // const updalistsize = updatelist.length;
        const updalistsize = res;
        console.log('updalistsize',updalistsize);
        console.log('eventlistsize',this.eventlistsize);
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
            this.getuserdetail();
        })
        .catch(error => console.log(error))

       // this.handleSubscribe();
      // this.handelwindowsize();
       window.addEventListener('resize',this.handleResize);
    
    }
    disconnectedCallback() {
        // Remove resize listener when component is removed from the DOM
      window.removeEventListener('resize',this.handleResize);
    }
   
    handleResize = () => {
        // Handle resize event here
         this.handelwindowsize();
    }
    handelwindowsize(){
        console.log('Window width:',window.innerWidth);
        console.log('Window height:',window.innerHeight);
        console.log('widthnow',this.windowwidth);
            this.windowwidth = window.innerWidth;

            this.refreshHandler();
        

    }
   
    refreshHandler() {
        console.log('refreshevntcall');
        refreshApex(this.dataToRefresh)
        .then(() => {
            this.initializeCalendar();
        });
    }
     getheight(){
        console.log('coming to getheight');
        return $(window).height();
    }
    initializeCalendar() { 
        const calendarEl = this.template.querySelector('div.fullcalendar');
        const copyOfOuterThis = this;
        console.log('eventlistcoming',copyOfOuterThis.eventsList);
        const calendar = new FullCalendar.Calendar(calendarEl, {
            headerToolbar: false,
            initialDate: new Date(),
            timeZone: 'UTC',
            showNonCurrentDates: true,
            allDaySlot : true,
            override: false,
           
  //          initialView: 'dayGridMonth',
           // navLinks: true,
             fixedWeekCount: false,
            allDaySlot: true,
            selectable:false ,
            editable: true,
            handleWindowResize: true,
            windowResize: function(arg){
             height: getheight();
            },
           // droppable: true,
            // eventLimit: true,
           // dayMaxEvents: true,
          // dayMaxEventRows: 3,
           /*
            views: {
                timeGrid: {
                    eventLimit: 3,
                },
                dayGridMonth: {
                    eventLimit: 3,
                }
            }, */
            events: copyOfOuterThis.eventsList,
            eventDisplay: 'block',
          //  eventColor: '#87cefa',
            eventTimeFormat: {
                hour: 'numeric',
                minute: '2-digit',
                omitZeroMinute: true,
                meridiem: 'short'
            },
            
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
                      const startime = info.dateStr ;
                    copyOfOuterThis.getWeekdate(startime);
                    /*
                    const startimeevt = this.startevntdate ;

                    console.log('startimeelse',startimeevt);
                const defaultValues = encodeDefaultFieldValues({
                    StartDateTime: startimeevt,
                    IsAllDayEvent: info.allDay
                });
                copyOfOuterThis.navigateToNewRecordPage(copyOfOuterThis.objectApiName, defaultValues); */
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
            if(res == 'unknownerror'){
                const errormsg = MysalesErrorMsg;
                this.showEventErrorMsg(errormsg);
                this.isLoaded = false;
            }
            else if(res == 'noSchedulepresent'){
                const errormsg = Knoxtomysalesnodata;
                this.showEventErrorMsg(errormsg);
                this.isLoaded = false;
            }
            else if(res == 'noemprecord'){
                const errormsg = Noknoxuserpresent;
                this.showEventErrorMsg(errormsg);
                this.isLoaded = false;
            }
            else  {
                this.batchJobId = res;
                this.getBatchStatus();
            }
            
        }).catch(err => {
            console.log('err ', err);

          //  const errormsg = err.statusText;
            const errormsg = MysalesErrorMsg;
            this.showEventErrorMsg(errormsg);
            this.isLoaded = false;

        })
    }
    getBatchStatus() {
           console.log('Enter into getbaatchstatus');
        getjobstatus({ jobId: this.batchJobId }).then(res => {
            console.log('response => ', res);
            if (res!= null) {
                this.totalBatch = res.TotalJobItems;
                console.log('totalBatch',this.totalBatch);
                console.log('errosmsg',res.ExtendedStatus)

                if (res.Status == 'Completed') {
                    this.isBatchCompleted = true;
                    this.isLoaded = false;
                    if(res.ExtendedStatus != '' && res.ExtendedStatus != undefined){
                        var errormsg;
                        const errcoming = res.ExtendedStatus;
                        if(errcoming.includes('FIELD_INTEGRITY_EXCEPTION')) {
                          errormsg = errcoming.split('FIELD_INTEGRITY_EXCEPTION,')[1];
                          //console.log('errormsg1',errormsg1);
                        }
                        else {
                            errormsg = res.ExtendedStatus;

                        }

                        this.showEventErrorMsg(errormsg);
                    }
                    else {
                    const sucmessage = SyncEventSuccessMsg;
                    this.showEventMsg(sucmessage);
                    this.refreshHandler();
                    }
                }
               /* else if(res.ExtendedStatus != ''){
                    this.isBatchCompleted = true;
                    this.isLoaded = false;
                    const errormsg = res.ExtendedStatus;
                    this.showEventErrorMsg(errormsg);
                   // this.refreshHandler();
                } */
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
    getWeekdate(startime){
        getWeekdate({startdatetime: startime }).then(res => {
         console.log('startdateusertimezone',res);  
         const startimeevt = res ;

         console.log('startimeelse',startimeevt);
     const defaultValues = encodeDefaultFieldValues({
         StartDateTime: startimeevt
     });
     this.navigateToNewRecordPage(this.objectApiName, defaultValues);
    }).catch(err => {
        console.log('err ', err);

    })
   }
   callsynctask(event){
    const checkboval = event.target.checked;
    console.log('checkboval',checkboval);
        this.isLoaded = true;
        this.syncknoxtask = checkboval;
        console.log('before callsynctask');
        if(checkboval == true){
            synctaskcaltoknox({
            }).then(res => {
        console.log('responseknox => ', res);

    }).catch(err => {
        console.log('err ', err);
        const errormsg = err.statusText;
        this.showEventErrorMsg(errormsg);
        this.isLoaded = false;

    })
        }
    synctaskuserrec({syncknox : checkboval
    }).then(res => {
        console.log('response => ', res);
        this.isLoaded = false;
        const sucmessage = TasksyncMessage;

         this.showEventMsg(sucmessage);
    }).catch(err => {
        console.log('err ', err);
        const errormsg = err.statusText;
        this.showEventErrorMsg(errormsg);
        this.isLoaded = false;

    })

   }
   getuserdetail(){
    getuserdetail({
    }).then(res => {
        const userrcd = res;
        if(userrcd.Synchronize_task__c == true){
            this.syncknoxtask = true;

        }
        console.log('syncknoxtask',this.syncknoxtask);
        console.log('response => ', res);
    }).catch(err => {
        console.log('err ', err);
        const errormsg = err.statusText;
        this.showEventErrorMsg(errormsg);

    })
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