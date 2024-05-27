/**
 * @description       : 
 * @author            : hj.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 2024-04-22
 * @last modified by  : vikrant.ks@samsung.com
 * Modifications Log 
 * Ver   Date         	Author             			 Modification
 * 1.0   2020-11-09     hj.lee@dkbmc.com   			 Initial Version
 * 1.0   2020-11-09     younghoon.kim@dkbmc.com   	 init 기능 수정(Sharing기능 사용 권한 수정)
 * 1.1   2024-01-30     divyam.gupta@samsung.com     Sales Lead Sharing Error Fix
 * 1.2   2024-02-01		vikrant.ks@samsung.com       Updating and Deleting Sales Lead Team Members in Case of Sales_Lead__Share(MySales-389)
 * 1.3   2024-04-22		vikrant.ks@samsung.com       I have removed all three query that were checking AccessLevel in init function and replaced it with one query.(MySales-512)
**/
public class ManualSharingController {
    /*
    * @Name             : init
    * @Description      : 해당 Object별 Manual Sharing 권한을 확인한 후 사용자의 Manual Sharing사용 가능여부를 반환해줌.
    */
    @AuraEnabled
    public static boolean init(Id recordId){
        Boolean result = false;
        String userId = UserInfo.getUserId();
		//V1.3 Start
        List<UserRecordAccess> permissionList = [SELECT RecordId, HasReadAccess FROM UserRecordAccess WHERE UserId = :userId AND RecordId = :recordId limit 1];
        if(permissionList.size() > 0){
            if(permissionList[0].HasReadAccess == true){
                result = true;
            }
        }
        //V1.3 End
        return result;
    }
    /*
    * @Name             : getSharingData
    * @Description      : 해당 Record에 공유 되어있는 권한 정보를 불러옴.
    */
    @AuraEnabled
    public static Map<String,Object> getSharingData(Id recordId){
        Map<String,Object> result = new Map<String,Object>();
        
        String shareObjAPiName = getShareObjectName(recordId);
        String objectAPiName = String.valueOf(recordId.getSObjectType());
        List <Group> groupList = [SELECT Id, Name, DeveloperName, Type FROM Group];
        Map<String, Group> groupMap = new Map<String, Group>();
        for(Group g : groupList){
            groupMap.put(g.Id, g);
        }
        
        List <User> userList = [SELECT Id, Name, Department, MediumPhotoUrl, UserRole.Name, Email, Title FROM User];
        Map<String, User> userMap = new Map<String, User>();
        for(User u : userList){
            userMap.put(u.Id, u);
        }
        Map<String, String> f = getField(shareObjAPiName, objectAPiName);

        String sql = 'SELECT Id, '+ f.get('PARENTID') +', UserOrGroupId, '+ f.get('ACCESSLEVEL')+', RowCause FROM ' + shareObjAPiName + ' WHERE '+ f.get('PARENTID') +' =\'' + recordId + '\'';
        List<sObject> shareobj = database.query(sql);
      
        List<UserRole> userRole = [SELECT Id, Name, DeveloperName FROM UserRole ];
        
        Map<String, String> roleName = new Map<String, String>();
        for(UserRole ur : userRole){
           roleName.put(ur.DeveloperName, ur.Name);            
        }
        System.debug('roleName' + roleName);
        
            
        for(sObject obj : shareobj){
            Map<String, Object> data = new Map<String, Object>();
            String type = 'User';
            String whatId = (String) obj.get('UserOrGroupId');
            
            data.put('Id', (String) obj.get('Id'));            
            data.put('ParentId', (String) obj.get( f.get('PARENTID') ));
            data.put('UserOrGroupId', (String) obj.get('UserOrGroupId'));
            data.put('AccessLevel', (String) obj.get( f.get('ACCESSLEVEL') ));
            data.put('RowCause', (String) obj.get('RowCause'));
            //V 1.1 Divyam gupta
             User user = userMap.get(whatId);
            if(user != null){
         //   if(whatId.indexOf('005') > -1){
                data.put('Name', user.Name);
                data.put('Department', user.Department);
                data.put('MediumPhotoUrl', user.MediumPhotoUrl);
                data.put('Role', user.UserRole.Name);
                data.put('Email', user.Email);
                data.put('EmailId', user.Email.split('@')[0]);
                data.put('Title', user.Title);
                data.put('Type', type);

            }else{                
                Group gro = groupMap.get(whatId);
                type = (String) gro.Type;
                if(type == 'Regular'){
                	data.put('Name', gro.DeveloperName);    
                }else{
                    data.put('Name', roleName.get(gro.DeveloperName));
                }                
                data.put('Type', type);  
            }
            String key = (String) obj.get('UserOrGroupId') + '_' + (type == 'Regular' ? 'PublicGroup' : type );
            System.debug('key' + key);
            result.put(key , data);
        }
        return result;
    }
    /*
    * @Name             : getSearchData
    * @Description      : Search Type 기준 검색 결과를 반환해줌.
    */
    @AuraEnabled
    public static List<Map<String,Object>> getSearchData(String search, String type, String condistion){        
        List<Map<String,Object>> result = new List<Map<String,Object>>(); 
        if(null == condistion) condistion = '';

        search = search.replace('\\','');

        String sQuery = 'SELECT Id, Name';
        
        System.debug('search :' + search);
        System.debug('type :' + type);
        System.debug('condistion :' + condistion);
        if('User' == type){
            sQuery += ', Department, MediumPhotoUrl, UserRole.Name, Email, Title' ;
            sQuery += ' FROM User' ;
            sQuery += ' WHERE Name LIKE \'%' + search + '%\' AND UserType =\'Standard\' AND IsActive=true' + condistion+ ' LIMIT 50';
            List<User> userList = Database.query(sQuery);
            
            System.debug('user :' + userList);
            
            for(User u : userList){
                Map<String, Object> us = new Map<String, Object>();
                us.put('Id', u.Id);
                us.put('Name', u.Name);
                us.put('Department', u.Department);
                us.put('Title', u.Title);
                us.put('MediumPhotoUrl', u.MediumPhotoUrl);
                us.put('Role', u.UserRole.Name);
                us.put('Email', u.Email);
                us.put('EmailId', u.Email.split('@')[0]);
                us.put('IsInclude', false);
                
                result.add(us);               
            }
            
        }else if('PublicGroup' == type){
            sQuery += ', DeveloperName' ;
            sQuery += ' FROM Group' ;
            sQuery += ' WHERE Name LIKE \'%' + search + '%\' AND Type = \'Regular\' ' + condistion+ ' LIMIT 50';
            List<Group> grList = Database.query(sQuery);
                        
            for(Group g : grList){
                Map<String, Object> gr = new Map<String, Object>();
                gr.put('Id', g.Id);
                gr.put('Name', g.DeveloperName);
                gr.put('IsInclude', false);                
                result.add(gr);               
            }            
        }else{
            sQuery += ', DeveloperName, Related.Name' ;
            sQuery += ' FROM Group' ;
            sQuery += ' WHERE Related.Name LIKE \'%' + search + '%\' AND Type = \'' + type + '\' ' + condistion + ' LIMIT 50';
            List<Group> grList = Database.query(sQuery);
                        
            for(Group g : grList){
                Map<String, Object> gr = new Map<String, Object>();
                gr.put('Id', g.Id);
                gr.put('Name', g.Related.Name);
                gr.put('IsInclude', false);                
                result.add(gr);               
            }  
        }
        
        return result;
    }
    /*
    * @Name             : insertData
    * @Description      : 해당 레코드에 대한 새로운 권한을 추가함.
    */
    @AuraEnabled
    public static Id insertData(Id recordId, String jsonParam){
        Map<String, Object> sharingMap = (Map<String, Object>)JSON.deserializeUntyped(jsonParam);
        String shareObjAPiName = getShareObjectName(recordId);     
        String objectAPiName =String.valueOf(recordId.getSObjectType());
        Map<String, String> f = getField(shareObjAPiName, objectAPiName);
        SObject data = schema.getGlobalDescribe().get(shareObjAPiName).newSObject();        
        data.put(f.get('PARENTID'), recordId);
        data.put('UserOrGroupId', (String) sharingMap.get('UserOrGroupId'));
        data.put(f.get('ACCESSLEVEL'), (String) sharingMap.get('AccessLevel'));
        data.put('RowCause','Manual');        
        insert data;          

        return data.Id;
        
    }
    /*
    * @Name             : updateData
    * @Description      : 대상의 권한을 업데이트함.
    */
    @AuraEnabled
    public static void updateData(Id recordId, String jsonParam){
        Map<String, Object> sharingMap = (Map<String, Object>)JSON.deserializeUntyped(jsonParam);
        String shareObjAPiName = getShareObjectName(recordId);
        String objectAPiName =String.valueOf(recordId.getSObjectType());
        Map<String, String> f = getField(shareObjAPiName, objectAPiName);
        SObject data = schema.getGlobalDescribe().get(shareObjAPiName).newSObject();     
        data.put('Id', (String) sharingMap.get('Id'));
        data.put(f.get('ACCESSLEVEL'), (String) sharingMap.get('AccessLevel'));       
        update data;          
        //V1.2 Start
        if(shareObjAPiName == 'Sales_Lead__Share'){
            List<Sales_Lead__Share> SLS = [Select Id, ParentId, UserOrGroupId, AccessLevel, RowCause from Sales_Lead__Share where ID = :data.Id];
            if(SLS.size()>0){
                Sales_Lead__Share temp = SLS[0];
            	List<Sales_Lead_Team__c> SLTList = [Select Id,  SalesLead_TeamMember__c, AccessLevel__c, Sales_Lead__c from Sales_Lead_Team__c where SalesLead_TeamMember__c = :temp.UserOrGroupId and Sales_Lead__c = :temp.ParentId Limit 1];
                if(SLTList.size()>0){
                    SLTList[0].AccessLevel__c = temp.AccessLevel;
                    update SLTList;
                }
            }
        }
        //V1.2 End
    }
    /*
    * @Name             : deleteData
    * @Description      : 해당 레코드에 대한 권한을 제거함.
    */
    @AuraEnabled
    public static void deleteData(Id recordId, Id delId){
        String shareObjAPiName = getShareObjectName(recordId);
        String sql = 'select id from ' + shareObjAPiName + ' where id = \'' + delId +'\'';
        sObject obj = Database.query(sql);
        //V1.2 Start
        List<Sales_Lead_Team__c> SLTList = new List<Sales_Lead_Team__c>();
        if(shareObjAPiName == 'Sales_Lead__Share'){
            List<Sales_Lead__Share> SLS = [Select Id, ParentId, UserOrGroupId from Sales_Lead__Share where ID = :delId];
            if(SLS.size()>0){
                Sales_Lead__Share temp = SLS[0];
                SLTList = [Select Id,  SalesLead_TeamMember__c, AccessLevel__c, Sales_Lead__c from Sales_Lead_Team__c where SalesLead_TeamMember__c = :temp.UserOrGroupId and Sales_Lead__c = :temp.ParentId Limit 1];
            }
        }
        //V1.2 End
        delete obj;
        //V1.2 Start
        if(shareObjAPiName == 'Sales_Lead__Share'){
        	if(SLTList.size()>0){ Delete SLTList; } 
        }
        //V1.2 End        
    }
    
    /*
    * @Name             : deleteDatas
    * @Description      : 해당 레코드에 대한 권한을 모두 제거함.
    */
    @AuraEnabled
    public static void deleteDatas(Id recordId){
        String shareObjAPiName = getShareObjectName(recordId);
        String sql = 'select id,ParentId, UserOrGroupId from ' + shareObjAPiName + ' WHERE  ParentId = \'' + recordId +'\' AND RowCause = \'Manual\'' ;
        List<sObject> obj = Database.query(sql);
        //V1.2 Start
        List<Sales_Lead_Team__c> SLTList = new List<Sales_Lead_Team__c>();
        if(shareObjAPiName == 'Sales_Lead__Share'){
            SLTList = [Select Id,  SalesLead_TeamMember__c, AccessLevel__c, Sales_Lead__c from Sales_Lead_Team__c where Sales_Lead__c = :recordId];
        }
        //V1.2 End
        delete obj;
        //V1.2 Start
        if(shareObjAPiName == 'Sales_Lead__Share'){
        	if(SLTList.size()>0){ Delete SLTList; } 
        }
        //V1.2 End
    }
    /*
    * @Name             : getShareObjectName
    * @Description      : Roecrd Id로 해당 Object의 Share Object Api Name을 반환함.
    */
    public static String getShareObjectName(Id recordId){        
        String objectAPiName =String.valueOf(recordId.getSObjectType());        
        if(objectAPiName.indexOf('__c') > -1 ){
            objectAPiName = objectAPiName.split('__c')[0];
            objectAPiName+= '__Share';    	
        }else{
            objectAPiName+= 'Share';
        }   
        return objectAPiName;
    }
    /*
    * @Name             : getField
    * @Description      : Object 의 공유 field 정보를 얻어옴
    */
    public static Map<String, String> getField(String shareObjAPiName , String objectAPiName){
        Map<String, String> result = new Map<String, String>();
        List<Schema.SObjectField> listField = Utils.getFieldList(shareObjAPiName);
        for(Schema.SObjectField f : listField){
            try{                    
                String fname =  f.getDescribe().getName();
                if(fname.indexOf('Level') > -1){
                    result.put('ACCESSLEVEL', fname);
                }else if(fname.indexOf(objectAPiName+'Id') > -1 || fname.indexOf('ParentId') > -1){
                    result.put('PARENTID', fname);
                }
            }catch(Exception e){}
        }
        return result;
    }
    
}