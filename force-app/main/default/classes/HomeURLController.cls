/**
* @author            : younghoon.kim@dkbmc.com
* @group             : 
* @description       : 
* @last modified on  : 08-30-2023
* @last modified by  : atul.k1@samsung.com
* Modifications Log 
* Ver   Date         Author                    Modification
* 1.0   2021-08-03   younghoon.kim@dkbmc.com  Initial Version
* 1.1  2022-11-22   anish.jain@partner.samsung.com  Logic change of 'Biz. Opportunity 360' button based on Users Email
* 1.2  2023-08-30   atul.k1@samsung.com  Add default URLs in List when role matchs with HomeURL records.Also for sort the records list on the bases of order (MySales-285).
**/
public class HomeURLController {
    @AuraEnabled
    public static List<UrlInfo> urlSetting(){
        List<UrlInfo> rtnList = new List<UrlInfo>();
        Set<String> URLValues = new Set<String>();//Addes by Atul - v 1.2
        User user = [SELECT Id, Name, ProfileId, Profile.Name, UserRoleId, UserRole.Name, LanguageLocaleKey, IsActive,Email FROM User WHERE Id =: Userinfo.getUserId()]; //Modified by Anish - v 1.1
        Map<String, List<UrlInfo>> urlMap = new Map<String, List<UrlInfo>>();
        UrlInfo lstInfo = new UrlInfo();              //Added by Anish - v 1.1
        UrlInfo adminInfo = new UrlInfo();            //Added by Anish - v 1.1
        adminInfo.Name = user.LanguageLocaleKey == 'ko' ? 'BO대시보드' : 'BO Dashboard'; //Added by Anish - v 1.1
        adminInfo.URL = 'https://mybi.sds.samsung.net/views/36/BO_1?:tabs=n&:alerts=no&:embed=yes&:showShareOptions=false&:toolbar=no';  //Added by Anish - v 1.1
        List<Home_URL__c> urlList = [SELECT Id, Name, SystemName_EN__c, Role__c, URL__c, Order__c,User_Email__c FROM Home_URL__c ORDER BY Order__c];  //Modified by Anish - v 1.1
        if(urlList.size() > 0){
            for(Home_URL__c url : urlList){
                //Added by Atul - v 1.2
                if(url.Name == 'BO대시보드' || url.SystemName_EN__c == 'BO Dashboard'){
                    adminInfo.Order = url.Order__c;
                }
                /*End*/
                UrlInfo ui = new UrlInfo();
                ui.Name = user.LanguageLocaleKey == 'ko' ? url.Name : url.SystemName_EN__c;
                ui.Url = url.URL__c;
                if(url.Order__c != null){
                    ui.Order = url.Order__c;
                }
                //Start-Added by Atul - v 1.2
                if((url.Role__c == null || url.Role__c == '') && url.User_Email__c != null){
                    String Emails = url.User_Email__c;
                    List<String> emailValSeprated = new List<String>(Emails.split(';'));
                    For(String eachEmailCheck : emailValSeprated){
                        if(eachEmailCheck == user.Email){
                            lstInfo = ui; 
                        }
                    }
                }
                //End- Added by Atul - v 1.2
                else{      //Modified Start by Atul - v 1.2
                    if(urlMap.get(url.Role__c) != null){
                        Boolean checkingValToAdd = False;
                              if(URLValues.contains(ui.Url)){
                                    checkingValToAdd = True;
                                }
                        if(checkingValToAdd == false){
                            List<UrlInfo> old_urlList = urlMap.get(url.Role__c);
                            old_urlList.add(ui);
                            urlMap.put(url.Role__c, old_urlList);
                            URLValues.add(ui.Url);
                        }
                    }else{
                        List<UrlInfo> new_urlList = new List<UrlInfo>();
                            if(user.UserRole.Name == url.Role__c || url.Role__c == 'Default' ||user.Profile.Name == '시스템 관리자' || user.Profile.Name == 'System Administrator'){
                                if(URLValues == null  || !(URLValues.contains(ui.Url))){
                                   URLValues.add(ui.Url);
                                   new_urlList.add(ui);
                                   urlMap.put(url.Role__c, new_urlList); 
                                }
                                   
                            
                        }
                    }
                }
                system.debug('urlMap==>'+urlMap);
                  //Modified End by Atul - v 1.2
            }
            system.debug('urlMap==>OutSide'+urlMap);
        }
        //When User have the role matches with record
        if(urlMap.get(user.UserRole.Name) != null){
            //Start-Added by Anish - v 1.1
            //IF When There is lstInfo
            if(lstInfo.Name != null && lstInfo.URL != null){
                List<UrlInfo> returnList = urlMap.get(user.UserRole.Name); 
                returnList.add(lstInfo);
                
                //Start-Added by Atul - v 1.2
                if(urlMap.containsKey('Default')){
                    returnList.addAll(urlMap.get('Default'));
                }
                urlMap.put(user.UserRole.Name,returnList);
                System.debug('Returnmap Test123a:'+urlMap.get(user.UserRole.Name));
                return urlMap.get(user.UserRole.Name);   
            }
            else{
                //if there is no lstInfo and user is a system admin
                if(user.Profile.Name == '시스템 관리자' || user.Profile.Name == 'System Administrator'){
                    List<UrlInfo> returnList = urlMap.get(user.UserRole.Name); 
                    returnList.add(adminInfo);
                    //Start-Added by Atul - v 1.2
                    if(urlMap.containsKey('Default')){
                        returnList.addAll(urlMap.get('Default'));
                    }
                    urlMap.put(user.UserRole.Name,returnList);
                    System.debug('Returnmap Test123b:'+urlMap.get(user.UserRole.Name));
                    return urlMap.get(user.UserRole.Name);  
                }
                else{
                    //if There is no lstInfo and user is not a system admin
                    //Start-Added by Atul - v 1.2	
                    List<UrlInfo> returnList = new List<UrlInfo>();
                    if(urlMap.containsKey('Default')){
                        returnList =  urlMap.get('Default');
                    }
                    returnList.addAll(urlMap.get(user.UserRole.Name));
                    urlMap.put(user.UserRole.Name,returnList);
                    System.debug('Returnmap Test123d:'+urlMap.get(user.UserRole.Name));
                    //End-Added by Atul - v 1.2
                    return urlMap.get(user.UserRole.Name);
                }
            }
            //End-Added by Anish - v 1.1
        }else{
            //When User doesn't have the role matches
            //Start-Added by Anish - v 1.1
            // If lstInfo(BO) records present
            if(lstInfo.Name != null && lstInfo.URL != null) {
                List<UrlInfo> returnList = urlMap.get('Default'); 
                returnList.add(lstInfo);
                urlMap.put('Default',returnList);
                System.debug('Returnmap Test123e:'+urlMap.get('Default'));
                return urlMap.get('Default');   
            }
            else{
                //if there is no lstInfo and user is a system admin
                if(user.Profile.Name == '시스템 관리자' || user.Profile.Name == 'System Administrator') {
                    List<UrlInfo> returnList = urlMap.get('Default'); 
                    returnList.add(adminInfo);
                    //urlMap.put('Default',returnList);
                    For(String ItrKey : urlMap.KeySet()){
                        if(ItrKey != 'Default'){
                            returnList.addAll(urlMap.get(ItrKey));
                        }
                     }
                    urlMap.put('Default',returnList);
                    System.debug('Returnmap Test123f:'+urlMap.get('Default'));
                    return urlMap.get('Default'); 
                }
                else{
                    System.debug('Returnmap Test123g:'+urlMap.get('Default'));
                    return urlMap.get('Default');
                }
            }
            //End-Added by Anish - v 1.1
        }
    }
    public class UrlInfo {
        @AuraEnabled
        public String Name {get; set;}
        @AuraEnabled
        public String Url {get; set;}
        @AuraEnabled
        public Decimal Order {get; set;} // -Added by Atul - v 1.2
    }
}