public class IF_KnoxCalendar {
    public String invitedYn;//knox Body Starting
    public String subject;       
    public String originalStartTime;
    public String originalScheduleId;        
    public String placeCode;
    public String userId;
    public String sendMailYn;
    public String calendarId;
    public String contentsType;
    public String contents;
    public String authority;
    public KnoxTime startTime = new KnoxTime();
    public String contentsCharset;
    public String allDayYn;
    public KnoxTime endTime = new KnoxTime();
    public String place;
    public String outclass;//Name Issue
    public String scheduleId;
    public String priority;
    public List<TaskAttendees> attendees = new List<TaskAttendees>();
    public String recurrenceModType;
    public Recurrence recurrence = new Recurrence();
    
    public class Recurrence{
        public String condition;
        public String freqInterval;
        public String endType;
        public String freq;
        public String count;
        public String lunarYn;
        public String until;
        public List<String> exceptions = new List<String>();   
    }

    public class KnoxTime{
        public String xdate;
        public String knoxDateTime;
        public String timeZone;
    }

    public class TaskAttendees{
        public String sourceType;
        public String displayName;
        public String replyStatus;
        public String type;
        public String userId;
        public String email;
        public integer seq;
    }

}