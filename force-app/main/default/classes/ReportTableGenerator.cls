public class ReportTableGenerator {
    
     
    @auraenabled
    @future(callout=true)
    public static void generateHtmlTable(String repId , List<String> receivers , Boolean isImmediate) {
        system.debug('repid-->' + repId);
        system.debug('users-->' + receivers);
        List<String> htmlTableList = new List<String>(); 
        PageReference visualforcePage = new PageReference('/apex/sessionidgenerator'); //sessionidgenerator.vfp in migration log
        String sessionId = getSessionId.getSessionIdFromVFPage(visualforcePage); //getSessionId.apxc in migration log
        String BaseURL = URL.getOrgDomainURL().toExternalForm();
        String reportURL = BaseURL + '/lightning/r/Report/'+repId+'/view';
        htmlTableList.add('<table style="border: 1px solid black;border-collapse: collapse;">');
        htmlTableList.add('<tr style="style="background-color: #D8D8D8; vertical-align: top;">');
        String dash_url = '/services/data/v35.0/analytics/reports/'+repId+'?includeDetails=true';
        
         // String sampleUrl = '/services/data/v36.0/sobjects/Account/';
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization', 'Bearer ' + sessionId);
        request.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + dash_url);
        request.setMethod('GET');
        HttpResponse res = new Http().send(request);
        
        string responseValue = '';  
        responseValue = res.getBody();
        
        system.debug('Response Body for File: ' + responseValue);
        
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(responseValue);
        Map<String, Object> reportMetadata = (Map<String, Object>) responseMap.get('reportMetadata');
        Map<String, Object> groupingsDown = (Map<String, Object>) responseMap.get('groupingsDown');
        Map<String, Object> attributeMap = (Map<String, Object>)responseMap.get('attributes');
        String ReportName;
        ReportName = (String)attributeMap.get('reportName');
        htmlTableList.add('<a style="text-decoration: none;background-color: #1F51FF;color: white;padding: 15px;text-align: center;display: inline-block;font-size: 14px;margin: 15px 5px;  border-radius: 5px;" href="'+reportURL+'">Open in Salesforce</a>');
        htmlTableList.add('<p style="font-weight: 500;font-size: 22px;margin: 5px;">Summary</p>');
        htmlTableList.add('<table style=" border-width: 0px;margin: 5px;width: 1%;">');
        
        Map<String, Object> factMap = new Map<String , Object>();
        factMap = (Map<String, Object>)responseMap.get('factMap');  
        system.debug('factmap->' + JSON.serialize(factMap));
        system.debug('groupingsDown-->' + JSON.serialize(groupingsDown.get('groupings')));
        
        if(responseMap.get('reportExtendedMetadata')!=null){
            Map<String, Object> extMetaData = (Map<String, Object>) responseMap.get('reportExtendedMetadata');
            if(extMetaData.get('groupingColumnInfo') !=null){
                Map<String,Object> groupingColumnInfo  = (Map<String , Object>) extMetaData.get('groupingColumnInfo');
                for(String key : groupingColumnInfo.keyset()){
                    //system.debug('groupingcolumnkey-->' + groupingColumnInfo.get(key));
                    Map<String , Object> groupCOlDetail = (Map<String,Object>) groupingColumnInfo.get(key);
                    htmlTableList.add('<th style=border:1px solid; text-align:center;width:20%;font-weight: bold;>'+groupCOlDetail.get('label')+'</th>');
                }
                
            }
            
            if(extMetaData.get('detailColumnInfo') !=null){
                Map<String,Object> detailColumnInfo  = (Map<String , Object>) extMetaData.get('detailColumnInfo');
                for(String key : detailColumnInfo.keyset()){
                    //system.debug('groupingcolumnkey-->' + detailColumnInfo.get(key));
                    Map<String , Object> detailCOlDetail = (Map<String,Object>) detailColumnInfo.get(key);
                    htmlTableList.add('<th style=border:1px solid; text-align:center;width:20%;font-weight: bold;>'+detailCOlDetail.get('label')+'</th>');
                }
                
            }
            htmlTableList.add('</tr>');
            
        }
        
        List<Object> groupingsDownList = (List<Object>) groupingsDown.get('groupings');
        
        if(groupingsDown!=null && groupingsDownList.size() >0){
            
            
            calculateGroupingsRecursion( groupingsDownList , false , factMap , ReportName , htmlTableList , receivers , isImmediate);
            
        }
        
        else{
            //system.debug('inside else');
            Map<String,Object> finalFact = (Map<String,Object>) factMap.get('T!T'); //This gives us initial Map containing Aggregates and rows to print in table.
            List<Object> tableRows = (List<Object>) finalFact.get('rows');
            for(Integer i=0; i < tableRows.size(); i++){
                //system.debug('inside first loop');
                Map<String,Object> nextRow = (Map<String,Object>) tableRows[i];
                
                List<Object> datCellList = (List<Object>) nextRow.get('dataCells');
                
                for(Integer j=0 ; j< datCellList.size(); j++){
                    
                    //system.debug('inside second loop');
                    Map<String,Object> finalMap = (Map<String,Object>) datCellList[j];
                    if(j == 0){
                        htmlTableList.add('<tr style=" style="background-color: #D8D8D8; vertical-align: top;">');
                    }
                    if(String.valueOf(finalMap.get('label')) == 'true' || String.valueOf(finalMap.get('label')) == 'false'){
                        htmlTableList.add('<td style="border:1px solid; text-align:center; padding:13px 0 12px 20px; font-weight: bold;" rowspan="1">'+checkBoxRenderer(String.valueOf(finalMap.get('label')))+'</td>');
                    }
                    else{
                        htmlTableList.add('<td style="border:1px solid; text-align:center; padding:13px 0 12px 20px; font-weight: bold;" rowspan="1">'+String.valueOf(finalMap.get('label'))+'</td>');
                    }
                    
                    if(j == datCellList.size() - 1){
                        htmlTableList.add('</tr>');
                    } 
                    
                    
                    
                }
            }
            
            htmlTableList.add('</table>');
            //htmlTable += '</table>';
            
            
             sendEmailNormal(String.join(htmlTableList,'') , ReportName,receivers , isImmediate);
            //sendEmail(String.join(htmlTableList,'') , ReportName,receivers);
            
        }
        
        //system.debug('htmlrow-->' + htmlTable);
    }
    
    
    
    public static void calculateGroupingsRecursion(List<Object> prevList , boolean isSecondIteration , Map<String, Object> factMap , String ReportName , List<String> htmlTableList , List<String> receivers , boolean isImmediate){
        
        for(Integer i=0 ; i< prevList.size(); i++){
            Map<String , object> groupingListMap = (Map<String ,Object>) prevList[i];
            List<Object> innerGroupings = (List<Object>) groupingListMap.get('groupings');
            //system.debug('innerGroupings-->' + innerGroupings); 
            if(innerGroupings.size() == 0 /*&& !isSecondIteration*/){
                String temp = (String) groupingListMap.get('key')+'!T';
                Map<String , Object> factMapInternal = (Map<String ,Object>) factMap.get(temp);
                List<Object> groupSpanList =  (List<Object>) factMapInternal.get('rows');
                List<Object> aggregaTes = (List<Object>) factMapInternal.get('aggregates');
                Map<String,Object> rowCountMap = (Map<String,Object>) aggregaTes[aggregaTes.size()-1];
                // Map<String , Object> simpleCells = (Map<String , Object>) groupSpanList[0].get('rows');
                
                //system.debug('simplecells-->' + groupSpanList);
                htmlTableList.add('<tr style=" style="background-color: #D8D8D8; vertical-align: top;"><td style="border:1px solid; text-align:center; padding:13px 0 12px 20px; font-weight: bold;" rowspan="'+groupSpanList.size()+'">'+String.valueOf(groupingListMap.get('label'))+'('+rowCountMap.get('label')+')'+'</td>');
                for(Integer j=0 ; j <groupSpanList.size(); j++){
                    
                    //system.debug('insidegroupSpanLisloop' + groupSpanList[j]);
                    Map<String ,Object> finalRowsMap = (Map<String,Object>) groupSpanList[j];
                    List<Object> dataCells = (List<Object>) finalRowsMap.get('dataCells');
                    Integer batchSize = dataCells.size();
                    Integer dataSize = dataCells.size();
                    Integer rowCounter = 0;
                    //system.debug('dataCellsfor' +j+ + dataCells.size());
                    for(Integer z=0 ; z < dataSize; z++){
                        
                        //system.debug('datacell-->' + z + dataCells[z]);
                        Map<String ,Object> finalData = (Map<String ,Object>) dataCells[z];
                        htmlTableList.add('<td style="border:1px solid; text-align:center; padding:13px 0 12px 20px; font-weight: bold;" rowspan="1">'+String.valueOf(finalData.get('label'))+'</td>');
                        rowCounter++;
                        if (rowCounter == batchSize || z == dataSize - 1) {
                            // Close the current row and start a new row after every 12th iteration or at the end
                            htmlTableList.add('</tr>');
                            if (z != dataSize - 1) {
                                htmlTableList.add('<tr style="style="background-color: #D8D8D8; vertical-align: top;">');
                            }
                            rowCounter = 0; // Reset the row counter for the next batch
                        }
                        
                    }
                    
                }
            }
            
            else if(innerGroupings.size()>0){
                String firstGroupSPanFactKey = (String) groupingListMap.get('key')+'!T';
                Map<String , Object> factMapInternal2 = (Map<String ,Object>) factMap.get(firstGroupSPanFactKey);
                List<Object> spanNotLastGroup1 = (List<Object>) factMapInternal2.get('aggregates');
                Map<String , Object> mapSpanNotLastGroup2 = (Map<String , Object>) spanNotLastGroup1[spanNotLastGroup1.size()-1];
                Map<String,Object> rowCountMap2 = (Map<String,Object>) spanNotLastGroup1[spanNotLastGroup1.size()-1];
                //creating list for nextLevelGroupings
                List<Object> nextLevelGroupings =  (List<Object>)groupingListMap.get('groupings'); //check grouping data after the first grouping.
                //creating list for nextLevelGroupings end.
                //span check end
                htmlTableList.add('<tr style="style="background-color: #D8D8D8; vertical-align: top;"><td style="border:1px solid; text-align:center; padding:13px 0 12px 20px; font-weight: bold;" rowspan="'+mapSpanNotLastGroup2.get('value')+'">'+String.valueOf(groupingListMap.get('label'))+'('+rowCountMap2.get('label')+')'+'</td>');
                //creation of first grouping element ends.
                
                //geenrating data after first grouping start
                for(Integer a = 0 ; a <nextLevelGroupings.size(); a++){
                    generateSecondaryROwData(nextLevelGroupings[a] , factMap ,  htmlTableList);
                }
                //geenrating data after first grouping end                
                
            }
            
            
            
        }
        
        
        sendEMailNormal(String.join(htmlTableList,'') , ReportName,receivers , isImmediate);
        //sendEmail(String.join(htmlTableList,'') , ReportName,receivers);
        // system.debug('htmlTable-->' + htmlTable);
        
        
    }
    
    public static void generateSecondaryROwData(Object nextLevelGroupArray , Map<String,Object> factMap , List<String> htmlTableList){
        
        Map<String,Object> nextLevelGroupmap = (Map<String,Object>) nextLevelGroupArray;
        List<Object> groups = (List<Object>) nextLevelGroupmap.get('groupings'); 
        //system.debug('groupsize-->' + groups.size());
        
        String nextLevelKey = nextLevelGroupmap.get('key')+'!T';
        Map<String , Object> nextLevelfactMapInternal = (Map<String ,Object>) factMap.get(nextLevelKey);
        List<Object> spanNotLastGroup1 = (List<Object>) nextLevelfactMapInternal.get('aggregates');
        Map<String , Object> mapSpanNotLastGroup2 = (Map<String , Object>) spanNotLastGroup1[spanNotLastGroup1.size()-1];
        Map<String,Object> rowCountMap2 = (Map<String,Object>) spanNotLastGroup1[spanNotLastGroup1.size()-1];
        //system.debug('span length-->' + mapSpanNotLastGroup2.get('value'));
        htmlTableList.add('<td style="border:1px solid; text-align:center; padding:13px 0 12px 20px; font-weight: bold;" rowspan="'+mapSpanNotLastGroup2.get('value')+'">'+String.valueOf(nextLevelGroupmap.get('label'))+'('+rowCountMap2.get('label')+')'+'</td>');
        
        if(groups.size()>0){
            
            for(Integer a=0 ; a < groups.size(); a++){
                
                generateSecondaryROwData(groups[a] , factmap , htmlTableList);
                
                
            }
        }
        
        else{
            Map<String,Object> lastMap = (Map<String,Object>) nextLevelGroupArray;
            String LastLevelKey = nextLevelGroupmap.get('key')+'!T';
            Map<String , Object> lastLevelfactMapInternal = (Map<String ,Object>) factMap.get(nextLevelKey);
            List<Object> lastRows = (List<Object>) lastLevelfactMapInternal.get('rows');
            Integer hardLimit = 0;
            for(Integer j=0 ; j <lastRows.size(); j++){
                
                //system.debug('insidegroupSpanLisloop' + lastRows[j]);
                Map<String ,Object> finalRowsMap = (Map<String,Object>) lastRows[j];
                List<Object> dataCells = (List<Object>) finalRowsMap.get('dataCells');
                Integer batchSize = dataCells.size();
                Integer dataSize = dataCells.size();
                
                Integer rowCounter = 0;
                //system.debug('dataCellsfor' +j+ + dataCells.size());
                for(Integer z=0 ; z < dataSize; z++){
                    
                    
                    
                    //system.debug('datacell-->' + z + dataCells[z]);
                    hardLimit = hardLimit+1;
                    Map<String ,Object> finalData = (Map<String ,Object>) dataCells[z];
         		
                    htmlTableList.add('<td style="border:1px solid;text-align:center; padding:13px 0 12px 20px; font-weight: bold;" rowspan="1">'+String.valueOf(finalData.get('label'))+'</td>');
                    
                    rowCounter++;
                    if (rowCounter == batchSize || z == dataSize - 1) {
                        // Close the current row and start a new row after every 12th iteration or at the end
                        htmlTableList.add('</tr>');
                        
                        if (z != dataSize - 1) {
                            htmlTableList.add('<tr style="style="background-color: #D8D8D8; vertical-align: top;">');
                            
                        }
                        rowCounter = 0; // Reset the row counter for the next batch
                    }
                    
                    
                }
                
                
                
            }
        }
        
        
    }
    
    public static String checkBoxRenderer(String isChecked){
        if(isChecked == 'true'){
            return '<input type="checkbox" checked>';
        }
        
        else{
            return '<input type="checkbox">';
        }
    }
    
    public static void sendEMail(String htmlString, String ReportName , List<String> receivers , Boolean isImmediate){
        
        //system.debug('emailmethodstring-->' + htmlString);
        String SENDER_EMAIL = 'mysales@samsung.com';
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
        emailBody = emailBody.replace('{!tableString}', htmlString);
        system.debug('emailBody_________' + emailBody);
        emailBody = emailBody.replace('{!ReportName}', ReportName);
        //end
        
        
        
        // Set the modified email body as the email body
        email.setHtmlBody(emailBody);
        
        
        //for knox
        recipientsList.clear();
        //for knox
        IF_KnoxEmailSendController.Recipients c;
        
        for(String ss : receivers){
            c = new IF_KnoxEmailSendController.Recipients(ss, 'to');
        }
        
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
        
        response = IF_KnoxEmailSendController.send(bodyMap);
        
    }
    
    public static void sendEmailNormal(String htmlString, String ReportName , List<String> receivers   , Boolean isImmediate){
        EmailTemplate em = [SELECT Id,subject FROM EmailTemplate WHERE DeveloperName = 'ReportDataTemplate'];
        Id templateId = em.Id;
        String emailBody = [SELECT HtmlValue FROM EmailTemplate WHERE Id = :templateId].HtmlValue;
        List<String> usersEmail = new List<String>();
        if(isImmediate){
            //usersEmail.add('oldman.sea@samsung.com');
            usersEmail.add('rakshit.s@samsung.com');
        }
        else{
            usersEmail.addAll(receivers);
        }
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String[] toAddresses = usersEmail; 
        email.setToAddresses(toAddresses);
        email.setSenderDisplayName('User');
        email.setTemplateId(templateId);
        emailBody = emailBody.replace('{!DateValue}', String.valueof(Date.today()));
        emailBody = emailBody.replace('{!tableString}', htmlString);
        system.debug('emailBody_________' + emailBody);
        emailBody = emailBody.replace('{!ReportName}', ReportName);
        email.setSubject('Report Name: '+ ReportName);
        email.setHtmlBody(emailBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email }); 
    }
    
}