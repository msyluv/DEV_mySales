/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 12-07-2021
 * @last modified by  : zenith21c@test.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2020-11-24   younghoon.kim@dkbmc.com   Initial Version
**/
@RestResource(urlMapping='/KnoxMessage/*')
global class KnoxMessageRestController {    

    @HttpPost
    global static String doSomethingPost(){ // https://cs113.salesforce.com/services/apexrest/KnoxMessage/doSomethingPost?keyword=[searchKeyword]
        String keyword = RestContext.request.params.get('keyword');

        return keyword + ' this is from post';
    }
    
    @HttpPut
    global static String doSomethingPut(){ // https://cs113.salesforce.com/services/apexrest/KnoxMessage/doSomethingPut?keyword=[searchKeyword]
        String rtnJSONStr = '';

        String keyword = RestContext.request.params.get('keyword');
        String searchKeyword = '% %';
        if(keyword != null) searchKeyword = '%' + String.valueOf(RestContext.request.params.get('keyword')) + '%';

        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        String jsonStr = req.requestBody.toString();
        /* requestBody는 아래와 같은 형식으로 들어옴
            {
                "workspaceId": 5317,
                "workspaceName": "test",
                "channelId": 98358986575187968,
                "channelName": "test channel",
                "userId": M200810085139C603253,
                "userName": "Gildong Hong",
                "userSingleId": "gildong.hong",
                "value": "search",
                "query": "test",
                "localDate": "2020-02-21",
                "localTime": "16:57:31",
                "timeZone": "+09:0"
            }
        */
        
        // Map<String, object> jsonMap = (Map<String, object>)JSON.deserializeUntyped(jsonStr);
        // // Map<String, object> jsonMap = jsonToMap(req, res);
        // String userEPId = (String)jsonMap.get('userId');
        // String workspaceId = (String)jsonMap.get('workspaceId');

        
        Integer nowPage = 1;
        Integer totalPage = nowPage;

        rtnJSONStr += '{';
        rtnJSONStr += '"type": "AdaptiveCard",';
        rtnJSONStr += '"$schema": "http://adaptivecards.io/schemas/adaptive-card.json",';
        rtnJSONStr += '"version": "1.3",';
        rtnJSONStr += '"body": [';
        rtnJSONStr += '{';
        rtnJSONStr += '"type": "ColumnSet",';
        rtnJSONStr += '"columns": [';
        rtnJSONStr += '{';
        rtnJSONStr += '"type": "Column",';
        rtnJSONStr += '"width": "stretch",';
        rtnJSONStr += '"items": [';
        rtnJSONStr += '{';
        rtnJSONStr += '"type": "ColumnSet",';
        rtnJSONStr += '"columns": [';
        rtnJSONStr += '{';
        rtnJSONStr += '"type": "Column",';
        rtnJSONStr += '"width": "stretch",';
        rtnJSONStr += '"items": [';
        rtnJSONStr += '{';
        rtnJSONStr += '"type": "TextBlock",';
        rtnJSONStr += '"text": "tttttttttttttttttttt",';
        rtnJSONStr += '"wrap": true';
        rtnJSONStr += '}';
        rtnJSONStr += ']';
        rtnJSONStr += '}';
        rtnJSONStr += ']';
        rtnJSONStr += '},';
        rtnJSONStr += '{';
        rtnJSONStr += '"type": "ColumnSet",';
        rtnJSONStr += '"columns": [';
        rtnJSONStr += '{';
        rtnJSONStr += '"type": "Column",';
        rtnJSONStr += '"width": "stretch",';
        rtnJSONStr += '"items": [';
        rtnJSONStr += '{';
        rtnJSONStr += '"type": "TextBlock",';
        rtnJSONStr += '"text": "tttttttttttttttttttt",';
        rtnJSONStr += '"wrap": true';
        rtnJSONStr += '}';
        rtnJSONStr += ']';
        rtnJSONStr += '},';
        rtnJSONStr += '{';
        rtnJSONStr += '"type": "Column",';
        rtnJSONStr += '"width": "stretch",';
        rtnJSONStr += '"items": [';
        rtnJSONStr += '{';
        rtnJSONStr += '"type": "TextBlock",';
        rtnJSONStr += '"text": "tttttttttttttttttttt",';
        rtnJSONStr += '"wrap": true';
        rtnJSONStr += '}';
        rtnJSONStr += ']';
        rtnJSONStr += '}';
        rtnJSONStr += ']';
        rtnJSONStr += '},';
        rtnJSONStr += '{';
        rtnJSONStr += '"type": "ColumnSet",';
        rtnJSONStr += '"columns": [';
        rtnJSONStr += '{';
        rtnJSONStr += '"type": "Column",';
        rtnJSONStr += '"width": "stretch",';
        rtnJSONStr += '"items": [';
        rtnJSONStr += '{';
        rtnJSONStr += '"type": "TextBlock",';
        rtnJSONStr += '"text": "tttttttttttttttttttt",'; // 시간 제거
        rtnJSONStr += '"wrap": true';
        rtnJSONStr += '}';
        rtnJSONStr += ']';
        rtnJSONStr += '},';
        rtnJSONStr += '{';
        rtnJSONStr += '"type": "Column",';
        rtnJSONStr += '"width": "stretch",';
        rtnJSONStr += '"items": [';
        rtnJSONStr += '{';
        rtnJSONStr += '"type": "TextBlock",';
        
        rtnJSONStr += '"text": "tttttttttttttttttttt",';
        rtnJSONStr += '"wrap": true';
        rtnJSONStr += '}';
        rtnJSONStr += ']';
        rtnJSONStr += '}';
        rtnJSONStr += ']';
        rtnJSONStr += '}';
        rtnJSONStr += ']';
        rtnJSONStr += '},';
        rtnJSONStr += '{';
        rtnJSONStr += '"type": "Column",';
        rtnJSONStr += '"width": "100px",';
        rtnJSONStr += '"items": [';
        rtnJSONStr += '{';
        rtnJSONStr += '"type": "ActionSet",';
        rtnJSONStr += '"actions": [';
        rtnJSONStr += '{';
        rtnJSONStr += '"type": "Action.Submit",';
        rtnJSONStr += '"title": "Share",';
        rtnJSONStr += '"data": {';
        rtnJSONStr += '"requestUrl": "https://www.naver.com",'; // jitterbit의 URL이 들어가면 되는것인지?
        rtnJSONStr += '"x": 13';
        rtnJSONStr += '}';
        rtnJSONStr += '}';
        rtnJSONStr += ']';
        rtnJSONStr += '}';
        rtnJSONStr += ']';
        rtnJSONStr += '}';
        rtnJSONStr += '],';
        rtnJSONStr += '"style": "default",';
        rtnJSONStr += '"bleed": true,';
        rtnJSONStr += '"separator": true';
        rtnJSONStr += '},';
          

        // Pagenation
        rtnJSONStr += '{';
        rtnJSONStr += '"type": "ColumnSet",';
        rtnJSONStr += '"columns": [';
        rtnJSONStr += '{';
        rtnJSONStr += '"type": "Column",';
        rtnJSONStr += '"width": "auto",';
        rtnJSONStr += '"items": [';
        rtnJSONStr += '{';
        rtnJSONStr += '"type": "ActionSet",';
        rtnJSONStr += '"actions": [';
        rtnJSONStr += '{';
        rtnJSONStr += '"type": "Action.Submit",';
        rtnJSONStr += '"title": "< Prev",';
        rtnJSONStr += '"data": {';
        rtnJSONStr += '"requestUrl": "https://www.naver.com",'; // prev 버튼 동작을 처리할 Jitterbit URL?
        rtnJSONStr += '"currnentPage": 1,';
        rtnJSONStr += '"buttonType": "prev",';
        rtnJSONStr += '"searchKeyword": "test"';
        rtnJSONStr += '}';
        rtnJSONStr += '}';
        rtnJSONStr += ']';
        rtnJSONStr += '}';
        rtnJSONStr += ']';
        rtnJSONStr += '},';
        rtnJSONStr += '{';
        rtnJSONStr += '"type": "Column",';
        rtnJSONStr += '"width": "stretch",';
        rtnJSONStr += '"items": [';
        rtnJSONStr += '{';
        rtnJSONStr += '"type": "TextBlock",';
        rtnJSONStr += '"text": "111",';
        rtnJSONStr += '"wrap": true,';
        rtnJSONStr += '"horizontalAlignment": "Center"';
        rtnJSONStr += '}';
        rtnJSONStr += '],';
        rtnJSONStr += '"height": "stretch",';
        rtnJSONStr += '"verticalContentAlignment": "Bottom",';
        rtnJSONStr += '"horizontalAlignment": "Center",';
        rtnJSONStr += '"spacing": "Small"';
        rtnJSONStr += '},';
        rtnJSONStr += '{';
        rtnJSONStr += '"type": "Column",';
        rtnJSONStr += '"width": "auto",';
        rtnJSONStr += '"items": [';
        rtnJSONStr += '{';
        rtnJSONStr += '"type": "ActionSet",';
        rtnJSONStr += '"actions": [';
        rtnJSONStr += '{';
        rtnJSONStr += '"type": "Action.Submit",';
        rtnJSONStr += '"title": "Next >",';
        rtnJSONStr += '"data": {';
        rtnJSONStr += '"requestUrl": "https://www.naver.com",';  // next 버튼 동작을 처리할 Jitterbit URL?
        rtnJSONStr += '"currnentPage": 22,';
        rtnJSONStr += '"buttonType": "prev",';
        rtnJSONStr += '"searchKeyword": "test"';
        rtnJSONStr += '}';
        rtnJSONStr += '}';
        rtnJSONStr += ']';
        rtnJSONStr += '}';
        rtnJSONStr += '],';
        rtnJSONStr += '"backgroundImage": {';
        rtnJSONStr += '"verticalAlignment": "Bottom",';
        rtnJSONStr += '"horizontalAlignment": "Center",';
        rtnJSONStr += '"fillMode": "Repeat"';
        rtnJSONStr += '}';
        rtnJSONStr += '}';
        rtnJSONStr += '],';
        rtnJSONStr += '"horizontalAlignment": "Center",';
        rtnJSONStr += '"bleed": true';
        rtnJSONStr += '}';
        rtnJSONStr += ']';
        rtnJSONStr += '}';
   
        return keyword+' this is from put';
    }
}