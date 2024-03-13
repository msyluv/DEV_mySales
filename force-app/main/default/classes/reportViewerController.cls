/**
* @description       : Report group Column Dashboard/Page
* @author            : vikrant.ks@samsung.com
* @group             : 
* @last modified on  : 2023-08-08
* @last modified by  : vikrant.ks@samsung.com 
* Modifications Log 
* Ver   Date         Author                   Modification
* 1.0   2023-08-08   vikrant.ks@samsung.com   Initial Version(MySales 271)
**/
public class reportViewerController{
    @AuraEnabled
    public static String ReportController(){  
        Integer currentYear = 2023;
        
        List<DatedConversionRate> currencyTypeList = [SELECT Id, IsoCode, ConversionRate, nextStartDate, startDate FROM DatedConversionRate where StartDate <= TODAY AND NextStartDate > TODAY ORDER BY NextStartDate DESC];
        Map<String , Decimal> isoWithRateMap = new Map<String, Decimal>();
        for(DatedConversionRate d : currencyTypeList) {
            isoWithRateMap.put(d.IsoCode , d.ConversionRate);
        }
        String firstScheduleMonth = System.Label.ReportViewer_firstScheduleMonth;
        String lastScheduleMonth  = System.Label.ReportViewer_lastScheduleMonth;
        Date firstCloseDate       = Date.valueOf(System.Label.ReportViewer_firstCloseDate);
        Date lastCloseDate        = Date.valueOf(System.Label.ReportViewer_lastCloseDate);

        List<String> stageList               = new List<String>(System.Label.ReportViewer_stageList.split(','));
        List<String> PrimaryDeliveryTeamList = new List<String>(System.Label.ReportViewer_PrimaryDeliveryTeamList.split(','));
        
        System.debug('firstScheduleMonth: '+firstScheduleMonth+ ' lastScheduleMonth: '+lastScheduleMonth+' firstCloseDate: '+firstCloseDate+' lastCloseDate: '+lastCloseDate);
        System.debug('stageList: '+stageList);
        System.debug('PrimaryDeliveryTeamList: '+PrimaryDeliveryTeamList);
            
        List<RevenueScheduleOpportunity__c> revenueOpp = [Select RevenueDivide8__c,ScheduleMonth__c, Parent__r.cPrimaryDeliveryTeam__c,CurrencyIsoCode from RevenueScheduleOpportunity__c where Parent__r.StageName IN :stageList and ScheduleMonth__c >= :firstScheduleMonth and ScheduleMonth__c <= :lastScheduleMonth and Parent__r.cPrimaryDeliveryTeam__c  IN :PrimaryDeliveryTeamList and Parent__r.RecordType.Name = 'HQ' and Parent__r.CloseDate >= :firstCloseDate and Parent__r.CloseDate <= :lastCloseDate];
        Map<String,List<Decimal>> revenueMap = new Map<String,List<Decimal>>();
        
        for(RevenueScheduleOpportunity__c opp:revenueOpp){
    
            if(!revenueMap.containsKey(opp.Parent__r.cPrimaryDeliveryTeam__c)){
                revenueMap.put(opp.Parent__r.cPrimaryDeliveryTeam__c,new List<Decimal>{0,0,0,0,0,0,0,0,0,0,0,0,0});
            }
            List<Decimal> temp = revenueMap.get(opp.Parent__r.cPrimaryDeliveryTeam__c);
            Decimal exchnageRate = 1;
            if(opp.CurrencyIsoCode != 'KRW'){
                exchnageRate = (isoWithRateMap.get('KRW')/isoWithRateMap.get(opp.CurrencyIsoCode));
            }
            temp[Integer.valueOf(opp.ScheduleMonth__c.subString(5))-1] += opp.RevenueDivide8__c*exchnageRate;
            revenueMap.put(opp.Parent__r.cPrimaryDeliveryTeam__c,temp);
            
        }
        List<Decimal> subtotal = new List<Decimal>{0,0,0,0,0,0,0,0,0,0,0,0,0};
        for(String key:revenueMap.keySet()){
            List<Decimal> temp = revenueMap.get(key);
            Decimal Sum = 0;
            for(Integer i=0;i<12;i++){
                Sum += temp[i]; 
                subtotal[i] += temp[i];
            }
            temp[12] = Sum;
            subtotal[12] += Sum;
            revenueMap.put(key,temp);
        }
        revenueMap.put('Total',subtotal);
        
        String s = '<table style="background:white;color:rgb(22,50,92);"><tr><td nowrap style="height: 24px;font-size:13px;padding-left:18px;width:100%;border: 0px solid #FFF;">'+System.Label.ReportViewer_Total_Revenue+'</td></tr><tr><td style="height: 31px;font-size:16px;padding-left:18px;width:100%;border: 0px solid #FFF;">KRW '+DecimaltoString(revenueMap.get('Total')[12])+'</td></tr>';
        
        s += '<tr><td nowrap style="height: 31px;border: 1px solid #B1B1B1;padding: 5px;background:#EBEBEB;font-weight:bold;">Schedule Month</td>';
        
        for(Integer i=1;i<13;i++){
            String month = '';
            if(i<10) month = '0'+i;
            else{month+= i;}
            s+='<td style="height: 31px;border: 1px solid #B1B1B1;padding: 5px;background:#EBEBEB;">'+currentYear+'/'+month+'</td>';
        }
        s+='<td style="height: 31px;border: 1px solid #B1B1B1;padding: 5px;background:#EBF4FF;font-weight:bold;">'+System.Label.ReportViewer_Total+'</td></tr><tr><td nowrap style="height: 31px;border: 1px solid #B1B1B1;padding: 5px;background:#EBEBEB;font-weight:bold;">'+System.Label.ReportViewer_Primary_Delivery_Dept+'</td>';
        for(Integer i=0;i<13;i++){
            s+='<td nowrap style="height: 31px;border: 1px solid #B1B1B1;padding: 5px;background:#EBEBEB;">'+System.Label.ReportViewer_Sum_Revenue+'</td>';
        }
        s+='</tr>';
		
        String cellColor = 'white';
        String headingColor = '#EBEBEB';
        List<String> revKey = new List<string>(revenueMap.keySet());
        revKey.sort();
        for(String key:revKey){
            
            if(key != 'Total'){
            s+='<tr><td nowrap style="height: 31px;border: 1px solid #B1B1B1;padding: 5px;background:'+headingColor+'">'+key+'</td>';

            List<Decimal> temp = revenueMap.get(key);
            for(Integer i=0;i<12;i++){
                s+='<td style="height: 31px;border: 1px solid #B1B1B1;padding: 5px;text-align:right;background:'+cellColor+';">KRW '+DecimaltoString(temp[i])+'</td>';
            }
            s+='<td style="height: 31px;border: 1px solid #B1B1B1;padding: 5px;text-align:right;background:#EBF4FF;">KRW '+DecimaltoString(temp[12])+'</td>';            
            s+='</tr>';
            }
        }
        s+='<tr><td nowrap style="height: 31px;border: 1px solid #B1B1B1;padding: 5px;background:#EBF4FF">'+System.Label.ReportViewer_Total+'</td>';
        for(Decimal D:revenueMap.get('Total')){
                s+='<td style="height: 31px;border: 1px solid #B1B1B1;padding: 5px;text-align:right;background:#EBF4FF;">KRW '+DecimaltoString(D)+'</td>';
            }
        s+='</tr>';
        s+='</table>';
        return s;
    }  
    public static String DecimaltoString(Decimal D){
        String a = String.valueOf(D.setscale(2));
        String b = D.setscale(2).format();
        if(b.length()>a.length()) return b;
        return a;
    }
}