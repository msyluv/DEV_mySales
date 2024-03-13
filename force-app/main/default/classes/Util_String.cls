/**
 * @File Name          : Util_String.cls
 * @Description        :
 * @Author             : kilhwan.an@partner.samsung.com
 * @Group              :
 * @Last Modified By   : woomg@dkbmc.com
 * @Last Modified On   : 05-04-2021
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    2020. 11. 12.   kilhwan.an@partner.samsung.com     Initial Version
**/
public class Util_String {

    /**
    * @description String 널처리
    * @author kilhwan.an@partner.samsung.com | 2020. 11. 12.
    * @param s 대상 값
    * @return String
    **/
    public static String nvlStr( Object s){

        if( s == null || s== 'null') s = '';
        return String.valueOf( s);
    }


    /**
    * @description Decimal 널처리
    * @author kilhwan.an@partner.samsung.com | 2020. 11. 12.
    * @param d 대상 값
    * @return Decimal
    **/
    public static Decimal nvlDec( Object d){

        if( d == null || d == '' || d == 'null') d = 0.0;
        return Decimal.valueOf( d + '');
    }


    /**
    * @description Integer 널처리
    * @author kilhwan.an@partner.samsung.com | 2020. 11. 12.
    * @param i 대상 값
    * @return Integer
    **/
    public static Integer nvlInt( Object i){

        if( i == null || i == '' || i == 'null') i = 0;
        return Integer.valueOf( i);
    }

    /**
    * @description Integer 널처리
    * @author kilhwan.an@partner.samsung.com | 2020. 11. 12.
    * @param i 대상 값
    * @return Integer
    **/
    public static Integer nvlInt( Object i, Object v){

        if( i == null || i == '' || i == 'null') i = v;
        return Integer.valueOf( i);
    }


    /**
    * @description Double 널처리
    * @author kilhwan.an@partner.samsung.com | 2020. 11. 12.
    * @param d 대상 값
    * @return Double
    **/
    public static Double nvlDob( Object d){

        return nvlDec( d);
    }

    /**
    * @description String null 처리 혹은 변환값 리턴
    * @author kilhwan.an@partner.samsung.com | 2020. 11. 12.
    * @param s : 대상값
    * @param v : 변환값
    * @return String
    **/
    public static String nvlStr( Object s, String v){

        if( s == null || s == '' || s == 'null') s = v;
        return String.valueOf( s);
    }


    /**
    * @description Decimal null 처리 혹은 변환값 리턴
    * @author kilhwan.an@partner.samsung.com | 2020. 11. 12.
    * @param d : 대상값
    * @param v : 변환값
    * @return Decimal
    **/
    public static Decimal nvlDec( Object d, Decimal v){

        if( d == null || d == '' || d == 'null' || d == 0) d = v;
        return Decimal.valueOf( d + '');
    }

    /**
    * @description 문자열을 날짜 타입으로 변환 : 9991231 => 40001231 참고
    * @author kilhwan.an@partner.samsung.com | 2020-11-18 
    * @param strDate : 날짜값
    * @return Date 
    **/
    public static Date convertStringDate( String strDate){

        if( nvlStr( strDate) == '' || strDate == 'null') return null;
        strDate = strDate.replaceAll( '[.]', '').replaceAll( '-', '').replaceAll( ' ', '');

        if( strDate > '40001231') strDate = '40001231';
        else if( strDate == '00010101') strDate = '19000101';

        Integer vYear  = Integer.valueOf( strDate.left(4));
        Integer vMonth = Integer.valueOf( strDate.mid(4, 2));
        Integer vDate  = Integer.valueOf( strDate.substring( 6, 8));

        return Date.newInstance( vYear, vMonth, vDate);
    }
    
        /**
    * @description 문자열을 날짜/시간 타입으로 변환 : 9991231 => 40001231 참고
    * @author minigyoon.woo@partner.samsung.com | 2021-05-04 
    * @param strDateTime : 날짜/시간값
    * @return Date 
    **/
    public static DateTime convertStringDateTime( String strDateTime){

        if( nvlStr( strDateTime) == '' || strDateTime == 'null') return null;
        strDateTime = strDateTime.replaceAll( '[.]', '').replaceAll( '-', '').replaceAll( ' ', '');

        Integer vYear  = Integer.valueOf( strDateTime.left(4));
        Integer vMonth = Integer.valueOf( strDateTime.mid(4, 2));
        Integer vDate  = Integer.valueOf( strDateTime.substring(6, 8));
        Integer vHour  = Integer.valueOf( strDateTime.substring(8, 10));
        Integer vMinute= Integer.valueOf( strDateTime.substring(10, 12));
        Integer vSecond= Integer.valueOf( strDateTime.substring(12, 14));

        return DateTime.newInstanceGmt( vYear, vMonth, vDate, vHour, vMinute, vSecond );
    }

    /**
    * @description Datetime 타입을 문자열로 변환
    * @author geunho.kil@partner.samsung.com | 2020-11-19
    * @param Datetime : 날짜값
    * @return String
    **/
    public static String convertDateString( Datetime dateTimeValue){

        if( dateTimeValue == null) return null;
        // String strDate = dateTimeValue.year() + '' + ( dateTimeValue.month() + '').leftPad( 2, '0') + '' + ( dateTimeValue.day() + '').leftPad( 2, '0');
        String strDate = ( dateTimeValue + '').replaceAll( '-', '').substring( 0, 8);

        if ( strDate > '40001231')  strDate = '99991231';

        return strDate;
    }


    /**
    * @description 
    * @author kilhwan.an@partner.samsung.com | 2021-03-31 
    * @param dateTimeValue 시간
    * @param timeZoneKey   변환 Timezone
    * @return String 
    **/
    public static String convertDateString( Datetime dateTimeValue, String timeZoneKey){

        if( dateTimeValue == null) return null;
        Timezone tz   = Timezone.getTimeZone( timeZoneKey);
        dateTimeValue = dateTimeValue.addSeconds( tz.getOffset( dateTimeValue) / 1000);

        return convertDateString( dateTimeValue);
    }

    /**
    * @description Datetime 타입을 문자열로 변환
    * @author geunho.kil@partner.samsung.com | 2020-11-19
    * @param Datetime : 날짜값
    * @return String
    **/
    public static String convertDateTimeString( Datetime dateTimeValue){

        if( dateTimeValue == null) return null;
        // dateTimeValue = dateTimeValue.dateGmt();
        // TimeZone tz     = UserInfo.getTimeZone();
        // dateTimeValue   = dateTimeValue.AddSeconds(tz.getOffset(dateTimeValue)/1000);
        // String strDate = dateTimeValue.year() + '' + ( dateTimeValue.month() + '').leftPad( 2, '0') + '' + ( dateTimeValue.day() + '').leftPad( 2, '0');
        // strDate += ( dateTimeValue.hour() +'').leftPad( 2, '0') + '' + ( dateTimeValue.minute() +'').leftPad( 2, '0') + '' + ( dateTimeValue.second() +'').leftPad( 2, '0');

        String strDate = ( dateTimeValue + '').replaceAll( '-', '').replaceAll( ' ', '').replaceAll( ':', '');

        return strDate;
    }


    /**
    * @description Datetime 타입을 문자열로 변환
    * @author kilhwan.an@partner.samsung.com | 2021-03-31 
    * @param dateTimeValue 날짜값
    * @param timeZoneKey   변환 Timezone
    * @return String 
    **/
    public static String convertDateTimeString( DateTime dateTimeValue, String timeZoneKey){

        if( dateTimeValue == null) return null;
        Timezone tz   = Timezone.getTimeZone( timeZoneKey);
        dateTimeValue = dateTimeValue.addSeconds( tz.getOffset( dateTimeValue) / 1000);        
        return convertDateTimeString ( dateTimeValue);
    }

    /**
    * @description Datetime 타입의 timezone 을 변경
    * @author kilhwan.an@partner.samsung.com | 2021-03-31 
    * @param dateTimeValue 날짜값
    * @param timeZoneKey   변환 Timezone
    * @return DateTime 
    **/
    public static Datetime convertTimeZone( DateTime dateTimeValue, String timeZoneKey){
        if( dateTimeValue == null) return null;
        Timezone tz   = Timezone.getTimeZone( timeZoneKey);
        dateTimeValue = dateTimeValue.addSeconds( tz.getOffset( dateTimeValue) / 1000);
        return  dateTimeValue;
    }

    /**
    * @description String 'yyyy-MM-dd' to Date
    * @author hyojinn.lee@partner.samsung.com | 2021-04-19
    * @param yyyy_MM_dd 날짜값
    * @return Date 
    **/
    public static Date convertStringHyphenFormatToDate(String yyyy_MM_dd){
        if(yyyy_MM_dd == null) return null;
        if(!yyyy_MM_dd.contains('-')) return null;

        List<String> dateStringSplits = yyyy_MM_dd.split('-');
        return Date.newInstance(Integer.valueOf(dateStringSplits[0]), Integer.valueOf(dateStringSplits[1]), Integer.valueOf(dateStringSplits[2]));
    }
    /**
     * 유효한 정수형 여부 체크
	 */
    public static Boolean isInteger(String tmpStr) {
        Boolean isInt = true;
        try{
            Integer iEmpNo = Integer.valueOf(tmpStr);
        }catch(Exception e){
         	isInt = false;
        }
        System.debug('### Util_String, isInteger = ' + isInt);        
        return isInt;
    }
}