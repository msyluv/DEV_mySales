/**
        * @description       : Controller Class for customFullCalendar LWC 
        * @author            : divyam.gupta@samsung.com
        * @group             : 
        * @last modified on  : 2024-05-24
        * @last modified by  : divyam.gupta@samsung.com
        * Modifications Log 
        * Ver   Date         Author                      Modification
        * 1.0   2024-05-24   divyam.gupta@samsung.com   Initial Version for MYSALES-264
        **/
public class EventknoxscheduleCont {

    @AuraEnabled
    public static String getknoxscheduledata(String eventid){
        Event eve = [SELECT Id,
                            Knox_Schedule_ID__c,
                            Description,
                            Isrecurrence__c,
                            recurrence_con__c,
                            EndType__c,
                            Count_rec__c,
                            freqInterval__c,
                            Frequence__c,
                            OwnerId 
                       FROM Event 
                      WHERE Id =: eventid 
                        AND ownerid =: UserInfo.getUserId()];

        UserRecordAccess usr = [SELECT RecordId,
                                       HasEditAccess 
                                  FROM UserRecordAccess 
                                 WHERE UserId =:UserInfo.getUserId() 
                                   AND RecordId =:eventid];
        try {
				if(usr.HasEditAccess) {    
                	String descrption = '';
                	String userid = UserInfo.getUserId();
                	String msg = 'success';
            
                	List<IF_KnoxCalendar> knoxData = if_KnoxSingletaskCallController.getSingleknoxSchedule(eventid);
					system.debug('knoxDatasize '+knoxData.size());
                	system.debug('knoxdata '+knoxData);
                	

                	if(knoxData != Null && eve.OwnerId == userid){
            			for(IF_KnoxCalendar record : knoxData){   
                			
                    		String base64Content = record.contents;
                    		system.debug('base64Content'+base64Content);

                    		if(base64Content != null && base64Content != ''){
                        		String base64String = base64Content.substringAfter('Content-Transfer-Encoding: base64\n').substringBefore('\n\n');
                        		Blob decodeBlob;
                        		String descValue;

								if((base64String == '' || base64String == null) && base64Content.contains('html')){
									descValue = base64Content;
								} else {
									decodeBlob = EncodingUtil.base64Decode(base64String);
									descValue = decodeBlob.toString();
								}

                    			system.debug('descvauebeforehtml'+descValue);
                    
								String addline = descValue.replaceAll('</p>','linex');
								system.debug('addlinevalue'+addline);
						
								String extractedText = addline.stripHTMLTags();
								system.debug('Desccoming'+extractedText);

								String extractedText2 = extractedText.replaceAll('linex', '\n');
						
								if(extractedText2 == '' || extractedText2 == null){
									descrption =  base64Content;
									system.debug('Desccomingnull'+base64Content);
								} else {
									system.debug('descriptionmsg'+extractedText2);
									descrption = extractedText2;  
								}
                			}

            				eve.Description = descrption;
            				eve.IsIF_152__c = true;

            				if(record.recurrence != null){
								system.debug('recurrence_____' + record.recurrence);
								
								eve.Isrecurrence__c = true;
								eve.recurrence_con__c = record.recurrence.condition;
								eve.EndType__c = record.recurrence.endType;
								eve.Count_rec__c = record.recurrence.count;
								eve.freqInterval__c = Integer.valueof(record.recurrence.freqInterval);
								eve.Frequence__c =  record.recurrence.freq;
								eve.Until_RecurrenceDate__c = record.recurrence.until;
								
            				} else {
                 				eve.Isrecurrence__c = false;
							}
        				}//end for

            			update eve;
        			}
         
        			system.debug('knoxDataIF-194'+knoxData);
        		}
			} catch (Exception e){               
			
			} 
		return 'success';
    }
}