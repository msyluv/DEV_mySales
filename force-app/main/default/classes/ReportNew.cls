public class ReportNew{
    
    Public static List<Object> groupListFull = new List<Object>();
    public static List<tempData> tempList = new List<tempData>();
    public static Map<String,Integer> tempMap = new Map<String,Integer>();
    Public static String reportId;
    public static Integer Groups = 0;
    public static Integer Columns = 0;
    public static Integer first = 0;
    Public static String ReportName;
    
    @AuraEnabled
    @future(callout=true)
    Public static void ReportData(String repId,List<String> usersEmail){
        System.debug('ReportId:'+ repId);
         System.debug('usersEmail________'+ usersEmail);
        reportId = repId;                
        PageReference visualforcePage = new PageReference('/apex/sessionidgenerator'); //sessionidgenerator.vfp in migration log
        
        // Call the getSessionIdFromVFPage method and retrieve the session ID
        String sessionId = getSessionId.getSessionIdFromVFPage(visualforcePage); //getSessionId.apxc in migration log
        
        // Use the session ID as needed
        System.debug('Session ID: ' + sessionId);
        String dash_url = '/services/data/v35.0/analytics/reports/'+repId+'?includeDetails=true';
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization', 'Bearer ' + sessionId);
        request.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + dash_url);
        request.setMethod('GET');
        HttpResponse res = new Http().send(request);
        
        system.debug('RES:'+res);
        string responseValue = '';
        responseValue = res.getBody();
        system.debug('Response Body for File: ' + responseValue);
        
        if (res.getStatusCode() == 200){
            
            EmailTemplate em = [SELECT Id,subject FROM EmailTemplate WHERE DeveloperName = 'ReportDataTemplate'];
            Id templateId = em.Id;
            String emailBody = [SELECT HtmlValue FROM EmailTemplate WHERE Id = :templateId].HtmlValue;
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String[] toAddresses = usersEmail; 
            email.setToAddresses(toAddresses);
            email.setSenderDisplayName('User');
            email.setTemplateId(templateId);
            emailBody = emailBody.replace('{!DateValue}', String.valueof(Date.today()));
            emailBody = emailBody.replace('{!tableString}', JSONtoHTML(responseValue));
            system.debug('emailBody_________' + emailBody);
            emailBody = emailBody.replace('{!ReportName}', ReportName);
            email.setSubject('Report Name: '+ ReportName);
            email.setHtmlBody(emailBody);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email }); 
            
            //system.debug('emailmethodstring-->' + htmlString);
        /*String SENDER_EMAIL = 'mysales@samsung.com';
        List<IF_KnoxEmailSendController.Recipients> recipientsList = new List<IF_KnoxEmailSendController.Recipients>();
        EmailTemplate em = [SELECT Id,subject FROM EmailTemplate WHERE DeveloperName = 'ReportDataTemplate'];
        Id templateId = em.Id;
        
        Employee__c senderEmployee;
        
        
        
        
        if( Utils.getIsSandbox()){
            senderEmployee = Utils.getLoginEmployeeData('0051s000001E9SuAAK');
            senderEmployee.EvMailAddr__c = 'chae_ho.yang@stage.samsung.com';
        }else{
            List<User> userList = [SELECT Id, Name From User WHERE Username = :SENDER_EMAIL];
            if(userList.size() > 0) senderEmployee = Utils.getLoginEmployeeData(userList.get(0).Id);
        }
        
        String emailBody = [SELECT HtmlValue FROM EmailTemplate WHERE Id = :templateId].HtmlValue;
        String shadowCopyOfBody = emailBody;
        
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setTemplateId(templateId);
        emailBody = emailBody.replace('{!DateValue}', String.valueof(Date.today()));
        emailBody = emailBody.replace('{!tableString}', JSONtoHTML(responseValue));
        system.debug('emailBody_________' + emailBody);
        emailBody = emailBody.replace('{!ReportName}', ReportName);
        //end
        
        
        
        // Set the modified email body as the email body
        email.setHtmlBody(emailBody);
        
        
        //for knox
        recipientsList.clear();
        //for knox
        
        
        
        IF_KnoxEmailSendController.Recipients c = new IF_KnoxEmailSendController.Recipients('rakshit.s@stage.samsung.com', 'to');
        //c.remove
        recipientsList.add(c);
        
        ////system.debug('recipientsList' + recipientsList);
        IF_KnoxEmailSendController.Sender sender;
        if(test.isRunningTest()){
            sender = new IF_KnoxEmailSendController.Sender('mysales', 'mysales@samsung.com');
        }
        else{
            sender = new IF_KnoxEmailSendController.Sender(senderEmployee.EvMailAddr__c.split('@')[0], senderEmployee.EvMailAddr__c);
        }
        
        IF_KnoxEmailSendController.InputClass bodyMap = new IF_KnoxEmailSendController.InputClass();
        //bodyMap.subject = 'Group Wise Information of Opportunity Elapsed/Close To Elapse';
        bodyMap.subject = 'Report Name: '+ ReportName;
        bodyMap.contents = emailBody;
        bodyMap.contentType = 'HTML';
        bodyMap.docSecuType = 'PERSONAL';
        //bodyMap.sfdcId = Userinfo.getUserid();
        bodyMap.recipients = recipientsList;
        bodyMap.sender = sender;
        bodyMap.isMulti = true;
        
        Map<String,Object> resMap = new Map<String,Object>();
        Map<String,Object> response = new Map<String, Object>();
        
        response = IF_KnoxEmailSendController.send(bodyMap);*/
        
        }
        else{
            System.debug('Failed to retrieve the Report Data. Error: ' + res.getBody());}
    }   
    
    Public static String JSONtoHTML(String payload){
        
        String BaseURL = URL.getSalesforceBaseUrl().toExternalForm();
        String reportURL = BaseURL + '/lightning/r/Report/'+reportId+'/view';
        
        Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(payload);
        Map<String, Object> recordMap = (Map<String, Object>)jsonMap.get('factMap');
        Map<String, Object> attrMap = (Map<String, Object>)jsonMap.get('attributes');
        ReportName = (String)attrMap.get('reportName');
        
        String s = '<a style="text-decoration: none;background-color: #1F51FF;color: white;padding: 15px;text-align: center;display: inline-block;font-size: 14px;margin: 15px 5px;  border-radius: 5px;" href="'+reportURL+'">Open in Salesforce</a>';
        
        Map<String, Object> metadataMap = (Map<String, Object>)jsonMap.get('reportExtendedMetadata');
        Map<String, Object> fieldMap = (Map<String, Object>)metadataMap.get('detailColumnInfo');
        Map<String, Object> groupMap = (Map<String, Object>)metadataMap.get('groupingColumnInfo');
        Map<String, Object> aggregateMap = (Map<String, Object>)metadataMap.get('aggregateColumnInfo');
        List<aggtemp> subtotalFields = new List<aggtemp>();
        Map<String, Object> metaMap = (Map<String, Object>)jsonMap.get('reportMetadata');
        Boolean showSubtotals = (Boolean)metaMap.get('showSubtotals');
        Boolean showGrandTotal = (Boolean)metaMap.get('showGrandTotal');
        Boolean hasRecordCount = (Boolean)metaMap.get('hasRecordCount');
        Boolean hasDetailRows = (Boolean)metaMap.get('hasDetailRows');
        String reportFormat = (String)metaMap.get('reportFormat');
        
        List<String> columnLabel = new List<String>();
        Map<Integer,aggtemp> aggtempMap = new Map<Integer,aggtemp>();
        
        if(hasRecordCount || showGrandTotal){ 
            s += '<p style="font-weight: 500;font-size: 22px;margin: 5px;">Summary</p>';
        	s += '<table style=" border-width: 0px;margin: 5px;width: 1%;">';
        	s += '<tr>';
            if(hasRecordCount){ s += '<td style=" border-width: 0px;padding: 0px;font-weight: 100;font-size: 14px;white-space: nowrap;">Total records</td>';}
            
            for(String temp:fieldMap.keySet()){
                Map<String, Object> fields = (Map<String, Object>)fieldMap.get(temp);
                columnLabel.add(String.valueOf(fields.get('label')));
            }
            for(String aKey:aggregateMap.keySet()){
                if(akey != 'RowCount'){
                    Map<String, Object> aggdata = (Map<String, Object>)aggregateMap.get(aKey);
                    aggtemp aggt = new aggtemp();
                    aggt.label = String.valueOf(aggdata.get('label')).substring(7); 
                    aggt.value = 0;
                    aggt.index = columnLabel.indexOf(aggt.label);
                    aggtempMap.put(aggt.index,aggt);
                }
            }
            List<Integer> bKey = new List<Integer>(aggtempMap.keySet());
            bKey.sort();
            if(showGrandTotal){
                for(Integer aKey:bKey){      
                    s+= '<td style=" border-width: 0px;padding: 0px;font-weight: 100;font-size: 14px;white-space: nowrap;padding-left: 15px;">Total '+aggtempMap.get(aKey).label+'</td>';   
                    subtotalFields.add(aggtempMap.get(aKey));
                }
            }
            s += '</tr>';
            
            System.debug(subtotalFields);
            s += '<tr>';
            Map<String, Object> recTotal = (Map<String, Object>)recordMap.get('T!T');
            Map<String, Object> aMap;
            List<Object> agList;
            if(hasRecordCount){
                agList = (List<Object>)recTotal.get('aggregates');
                aMap = (Map<String, Object>)agList[agList.size()-1];
                s += '<td style=" border-width: 0px;padding: 0px;font-weight: 400;font-size: 20px;white-space: nowrap;">'+ aMap.get('label') +'</td>';
            }
            if(showGrandTotal){
                if(agList.size()>0){
                    for(Integer i=0;i<(agList.size()-1);i++){
                        aMap = (Map<String, Object>)agList[i];
                        s+= '<td style=" border-width: 0px;padding: 0px;font-weight: 400;font-size: 20px;white-space: nowrap;padding-left: 15px;">'+aMap.get('label') +'</td>';
                    } 
                }
            }   
            s += '</tr></table>';
    	}
        s += '<table style="border: 1px solid black;border-collapse: collapse;"><tr>';  
        
        Groups = groupMap.size();
        for(String temp:groupMap.keySet()){
            Map<String, Object> g = (Map<String, Object>)groupMap.get(temp);
            
            s+= '<th style="border: 1px solid black;text-align: center;padding:13px 10px;vertical-align:middle;">'+g.get('label')+'</th>';
        }
        Columns = fieldMap.size();
        
        for(String temp:fieldMap.keySet()){
            Map<String, Object> fields = (Map<String, Object>)fieldMap.get(temp);
            columnLabel.add(String.valueOf(fields.get('label')));
            s+= '<th style="border: 1px solid black;text-align: center;padding:13px 10px;vertical-align:middle;">'+fields.get('label')+'</th>';
        }
        s+= '</tr>';
        
        //subtotal
        System.debug('columnLabel: '+columnLabel);
        
        for(Integer i=subtotalFields.size()-1;i>=0;i--){
            subtotalFields[i].index = columnLabel.indexOf(subtotalFields[i].label);
            aggtempMap.put(subtotalFields[i].index,subtotalFields[i]);
        }

        Integer x = Columns;
        Integer y = 0;
        for(Integer i= subtotalFields.size()-1;i>=0;i--){
            y = subtotalFields[i].index;
            System.debug('Label: '+subtotalFields[i].label+ ' Index: '+y);
            subtotalFields[i].value = x - y;
            x = y;
        }
        first = x;
        
        Map<String, Object> groupingsDown = (Map<String, Object>)jsonMap.get('groupingsDown'); 
        List<Object> groupingList = (List<Object>)groupingsDown.get('groupings');
        groupListmaker(groupingList);
        System.debug('my list:' + tempList);
        System.debug('my Map:' + tempMap);
        
        Integer Total = 0;
        Integer point = 0;
                
        Map<Integer,List<Object>> aggrMap = new Map<Integer,List<Object>>(); 
        
        List<String> RecordKey = new List<String>(recordMap.keySet());
        
        RecordKey.sort();
        System.debug('RecordKey: '+RecordKey);
        for(String temp:RecordKey){
           
            Map<String, Object> records = (Map<String, Object>)recordMap.get(temp);
            List<Object> aggList = (List<Object>)records.get('aggregates');
            
            List<Object> rowList = (List<Object>)records.get('rows');
            Integer listSize = rowList.size();
            System.debug(temp + ' rowList: '+rowList);
            
            if(temp == 'T!T' && reportFormat != 'TABULAR'){
                aggrMap.put(1,aggList);
            }
            else if(listSize == 0){
                
                if(aggrMap.containsKey(temp.length())){
                    List<Integer> AggeKeySet = new List<Integer>( aggrMap.keySet());
                    AggeKeySet.sort();
                    
                    for(Integer i=AggeKeySet.size()-1;i>=0 && AggeKeySet[i]>=temp.length();i--){
                       if(subtotalFields.size() > 0 && showSubtotals){
                            s+= '<tr style="background-color: #D8D8D8;"><td colspan="'+ (Groups-Integer.valueof((AggeKeySet[i]-2))/2 + first) +'">Subtotal</td>';
                            for(Integer j = 0;j<(aggrMap.get(AggeKeySet[i]).size()-1);j++){
                                Map<String, Object> agMap = (Map<String, Object>)aggrMap.get(AggeKeySet[i])[j];
                                String ag= (String)agMap.get('label');
                                s+= '<td colspan="'+subtotalFields[j].value+'">'+ag+' </td>';
                            }
                            s+='</tr>';
                       }
                        aggrMap.remove(AggeKeySet[i]);
                    }
                }
                aggrMap.put(temp.length(),aggList);
                
                String rdata = '';
                Integer tt;
                if(hasRecordCount){
                    Map<String, Object> agMap = (Map<String, Object>)aggList[aggList.size()-1];
                    String agg = (String)agMap.get('label');
                    tt=Integer.valueof(agg.replaceall(',',''));
                    if(subtotalFields.size() > 0 && showSubtotals){
                        tt+=tempMap.get(tempList[point].label);
                    }
                    rdata = ' ('+ agg + ' record';
                    if(agg == '1' || agg == '0'){rdata +=  ')';}
                    else{rdata +=  's)';}
                }
                
                String str = tempList[point].label;
                if(validateId(tempList[point].value)){
                    str = '<a style="text-decoration: none;color: rgb(0,112,210);" href="'+BaseURL+'/'+tempList[point].value+'">'+str+'</a>';
                }
                s+= '<td rowspan="'+String.valueOf(tt)+'" style="border: 1px solid black;text-align: center;padding:13px 5px;">'+ str + rdata +'</td>';
                point++;
            }
            else{
                String str;
                
                if(Groups>0)
                {
                    String rdata = '';
                    String agg = '';
                    if(hasRecordCount){
                        Map<String, Object> aggMap = (Map<String, Object>)aggList[aggList.size()-1];
                        agg= (String)aggMap.get('label');
                        rdata = ' ('+ agg + ' record';
                        if(agg == '1' || agg == '0'){rdata +=  ')';}
                        else{rdata +=  's)';}
                    }
                    
                    str = tempList[point].label;
                    if(validateId(tempList[point].value)){
                        str = '<a style="text-decoration: none;color: rgb(0,112,210);" href="'+BaseURL+'/'+tempList[point].value+'">'+str+'</a>';
                    }
                    s+= '<td rowspan="'+agg+'" style="border: 1px solid black;text-align: center;padding:13px 5px;">'+ str + rdata +'</td>';
                    point++;
                }
                
                for(Object row:rowList){
                    Map<String, Object> dataMap = (Map<String, Object>)row;
                    List<Object> dataList = (List<Object>)dataMap.get('dataCells');
                    
                    for(Object value:dataList){
                        Map<String, Object> data = (Map<String, Object>)value;
                        str = String.valueOf(data.get('label'));
                        if(validateId(String.valueOf(data.get('value')))){
                            str = '<a style="text-decoration: none;color: rgb(0,112,210);" href="'+BaseURL+'/'+String.valueOf(data.get('value'))+'">'+str+'</a>';
                        }
                        s+= '<td style="border: 1px solid black;text-align: center;padding:13px 5px;vertical-align:middle;">'+str+'</td>';
                    }
                    s+= '</tr>';
                }
                if(subtotalFields.size() > 0 && showSubtotals){
                    s+= '<tr style="background-color: #D8D8D8;"><td colspan="'+ (first+1) +'">Subtotal</td>';
                    for(Integer j = 0;j<(aggList.size()-1);j++){
                        Map<String, Object> agMap = (Map<String, Object>)aggList[j];
                        String ag= (String)agMap.get('label');
                        s+= '<td colspan="'+subtotalFields[j].value+'">'+ag+' </td>';
                    }
                    s+='</tr>';
                }
            }
        }
        if(subtotalFields.size() > 0){  
            List<Integer> AggeKeySet = new List<Integer>( aggrMap.keySet());
            AggeKeySet.sort();
            for(Integer i=AggeKeySet.size()-1;i>=0;i--){
                if(AggeKeySet[i] == 1 && showGrandTotal){
                    s+= '<tr style="background-color: #B0B0B0;"><td colspan="'+ (Groups+first) +'">Total</td>';
                    for(Integer j = 0;j<(aggrMap.get(AggeKeySet[i]).size()-1);j++){
                        Map<String, Object> agMap = (Map<String, Object>)aggrMap.get(AggeKeySet[i])[j];
                        String ag= (String)agMap.get('label');
                        s+= '<td colspan="'+subtotalFields[j].value+'">'+ag+' </td>';
                    }
                    s+='</tr>';
                }
                else if(showSubtotals){
                    s+= '<tr style="background-color: #D8D8D8;"><td colspan="'+ (Groups-Integer.valueof((AggeKeySet[i]-2))/2+ first) +'">Subtotal</td>';
                    for(Integer j = 0;j<(aggrMap.get(AggeKeySet[i]).size()-1);j++){
                        Map<String, Object> agMap = (Map<String, Object>)aggrMap.get(AggeKeySet[i])[j];
                        String ag= (String)agMap.get('label');
                        s+= '<td colspan="'+subtotalFields[j].value+'">'+ag+' </td>';
                    }
                    s+='</tr>';
                }
                aggrMap.remove(AggeKeySet[i]);
            }
        }
        s+='</table>';
        return s;
    }
    
    
    Public static Integer groupListmaker(List<Object> groupingList){
      	
        if(groupingList.size()==0) return 0;
        Integer a=0;
        for(Object gr:groupingList){
            Integer total = 0;
            InputClass data = (InputClass)JSON.deserializeStrict(JSON.serialize(gr), InputClass.class);
            tempData tem = new tempData();
            tem.label = data.label; tem.value = data.value;
            tempList.add(tem);
            Integer temp = groupListmaker(data.groupings);
            total= temp + data.groupings.size();
            a += total;
            tempMap.put(data.label,total);
        }
        return a;
    }
    
   
    public class InputClass{
        public String escapedLabel;
        public String key;
        public String label;
        public String value;
        public List<InputClass> groupings = new List<InputClass>();
    }
    public class tempData{
        public String label;
        public String value;
        //public Integer rowSpan;
    }
    public class aggtemp{
        public String label;
        public Integer value;
        public Integer index;
    }
    public static Boolean validateId(String Idparam) {
        //system.debug('Idparam_____' + Idparam);  
        if(Idparam!=null){
            String id = String.escapeSingleQuotes(Idparam);        
        return ((id.length() == 15 || id.length() == 18) && Pattern.matches('^[a-zA-Z0-9]*$', id));
        }     
        
        else{
            return false;
        }
        //return false;
        
        
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Report> fetchReport (String searchKey){
        String query= 'SELECT Id, Name FROM Report';
        if ( searchKey != Null ) {
            String key = '%' + searchKey + '%';
            query += ' WHERE Name LIKE :key Limit 15';
        }system.debug(Database.query( query ));
        return Database.query( query );
    } 
   @AuraEnabled
    Public static List<User> getuserList(){        
        List<User> userList = [SELECT Id, Name,Email FROM User Where IsActive = true];
        return userList;
    }
}