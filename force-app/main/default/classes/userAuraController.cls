public class userAuraController {
 @AuraEnabled
    Public static List<User> getuserList(){
        //get all contact list
        List<User> userList = [SELECT Id, Name,Email FROM User LIMIT 10];
        return userList;
    }
}