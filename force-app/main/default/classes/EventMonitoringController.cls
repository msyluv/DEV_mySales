/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 04-07-2021
 * @last modified by  : woomg@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   04-02-2021   woomg@dkbmc.com   Initial Version
**/
public with sharing class EventMonitoringController {

    @AuraEnabled
    public static Boolean checkAccessPermission(){
        return Schema.sObjectType.EventLogFile.isQueryable();
    }

    @AuraEnabled
    public static list<Object> getDateRanges(){
        list<Object> loption = new list<Object>();
        DateTime startdate = system.now().addDays(-2);
        DateTime endDate = startDate.addMonths(-1);
        DateTime wd = startDate;

        do {
            map<String, String> option = new map<String, String>();
            String logDate = wd.format('yyyy-MM-dd');
            option.put('value', logDate);
            option.put('label', logDate);
            loption.add(option);
            wd = wd.addDays(-1);
        } while( wd > endDate);

        return loption;
    }

    @AuraEnabled
    public static list<Object> getEventTypes(){
        list<Object> loption = new list<Object>();
        Schema.DescribeFieldResult dfr = Schema.sObjectType.EventLogFile.fields.EventType;
        for(Schema.PicklistEntry pe : dfr.getPicklistValues()){
            map<String, String> option = new map<String, String>();
            option.put('value', pe.getValue());
            option.put('label', pe.getLabel());
            loption.add(option);
        }
        return loption;
    }

    @AuraEnabled
    public static list<EventLogFile> getEventLogs(String eventType, String interval, String logDate){
        list<EventLogFile> eventLogs = new list<EventLogFile>();
        try {
            list<String> dates = logDate.split('-');
            Date target = Date.newInstance(Integer.valueOf(dates[0]), Integer.valueOf(dates[1]), Integer.valueOf(dates[2]));
            String query = '';
            query += 'SELECT Id, ApiVersion, EventType, Interval, LogDate, Sequence, ';
            query += 'LogFileContentType, LogFileFieldNames, LogFileFieldTypes, LogFileLength ';
            query += 'FROM EventLogFile ';
            query += 'WHERE EventType = :eventType AND Interval = :interval ';
            if(interval == 'Hourly')
                query += ' AND DAY_ONLY(LogDate) = :target ';
            query += 'ORDER BY LogDate DESC';
            system.debug(query);
            return Database.query(query);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String getSessionId(){
        return Test.isRunningTest() ? 'session-id' : Page.GenerateSessionId4LWC.getContent().toString().replaceAll('\n','');
    }
}