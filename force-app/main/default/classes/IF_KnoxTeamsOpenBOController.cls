/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2020-12-15
 * @last modified by  : younghoon.kim@dkbmc.com
 * @call URL(Dev)     : https://sdssfa--dev.my.salesforce.com/services/apexrest/IF084/
 * @call URL(QA)      : https://sdssfa--qa.my.salesforce.com/services/apexrest/IF084/
 * @call URL(Prod)    : 
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2020-11-24   younghoon.kim@dkbmc.com   Initial Version
**/
@RestResource(urlMapping='/IF084/*')
global class IF_KnoxTeamsOpenBOController {
    private static final String INTERFACE_ID = 'IF-084';
    private static final String APEX_CLASS   = 'IF_KnoxTeamsOpenBOController';
    private static final String METHOD_NAME  = 'openbo';

    private static final Boolean DEBUG_FLAG = true;

    @HttpPost
    global static OutputHeader openbo(){
        String guId = IF_Util.generateGuid();
        
        IF_Log ifLog;
        IF_Log.InterfaceLog interfaceLog;
        List<String> errorMsgList = new List<String>();

        ifLog = new IF_Log();
        ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 시작' + ' ####################');
        System.debug('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 시작' + ' ####################');

        OutputHeader outHeader   = new OutputHeader();
        outHeader.requesterId = '';
        outHeader.messageId = '';
        outHeader.parentMessageId = '';
        outHeader.onlyVisibleSender = '';
        outHeader.adaptiveCards = '';
        outHeader.customElements = '';
        outHeader.expiredDatetime = '';

        // [S] RequestBody Check
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestRequest req = RestContext.request;
        Blob reqBody = req.requestBody;

        // 1. inputHeader Check
        String inputJsonData = reqBody.toString();
        InputHeader inputHeader = (InputHeader) JSON.deserialize( inputJsonData, InputHeader.class);
        ifLog.addLog('[InputHeader] ==> ' + inputJsonData);
        System.debug('[InputHeader] ==> ' + inputJsonData);
                
        // 1-1. userSingleId Check
        String userSingleId = inputHeader.userSingleId;
        ifLog.addLog('[userSingleId] ==> ' + userSingleId);
        System.debug('[userSingleId] ==> ' + userSingleId);

        String epId = '';
        List<Employee__c> empList = [SELECT Id, Name, EvUniqID__c, Knox_Id__c FROM Employee__c WHERE Knox_Id__c =: userSingleId];
        if(empList.size() > 0) epId = empList[0].EvUniqID__c;

        // 2. Keyword Check
        String keyword = inputHeader.query;
        String searchKeyword = '% %';
        // String keyword = req.params.get('keyword');
        // if(keyword != null) searchKeyword = '%' + String.valueOf(RestContext.request.params.get('keyword')) + '%';
        if(keyword != null) searchKeyword = '%' + keyword + '%';
        ifLog.addLog('[searchKeyword] ==> ' + searchKeyword);
        System.debug('[searchKeyword] ==> ' + searchKeyword);
        // [E] RequestBody 데이터 확인
        
        Savepoint sp = Database.setSavepoint();        

        try{            
            // Search target opportunity
            List<Opportunity> opptyList = new List<Opportunity>();
            if(!String.isBlank(epId)){
                opptyList = [SELECT Id, Name, AccountId, Account.Name, OpportunityCode__c, StageName, CloseDate, Amount 
                                     FROM Opportunity
                                   WHERE Owner.FederationIdentifier =: epId
                                       AND IsClosed = false
                                       AND Name LIKE: searchKeyword
                                   ORDER BY CreatedDate DESC LIMIT 1];
            }
            ifLog.addLog('[Target opportunity Search result - size] ==> ' + opptyList.size());
            ifLog.addLog('[Target opportunity Search result - value] ==> ' + opptyList);
            System.debug('[Target opportunity Search result - size] ==> ' + opptyList.size());
            System.debug('[Target opportunity Search result - value] ==> ' + opptyList);

            // Creat adaptiveCard
            outHeader.adaptiveCards = createAdaptiveCard(opptyList);

            ifLog.addLog('[Result] ==> Success');
            System.debug('[Result] ==> Success');

            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, inputJsonData, JSON.serialize(outHeader));
        }catch(Exception e){
            Database.rollback(sp);

            ifLog.addLog('[Result] ==> Error : ' + e.getMessage());
            System.debug('[Result] ==> Error : ' + e.getMessage());

            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, inputJsonData, JSON.serialize(outHeader), e);
        }

        ifLog.addLog('[outHeader] ==> ' + JSON.serialize(outHeader));
        System.debug('[outHeader] ==> ' + JSON.serialize(outHeader));

        ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 종료' + ' ####################');
        System.debug('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 종료' + ' ####################');

        ifLog.createLog(interfaceLog);

        return outHeader;
    }

    public static String createAdaptiveCard(List<Opportunity> opptyList){
        String rtnJSONStr = '';
        rtnJSONStr += '{';
        rtnJSONStr += '"type": "AdaptiveCard",';
        rtnJSONStr += '"$schema": "http://adaptivecards.io/schemas/adaptive-card.json",';
        rtnJSONStr += '"version": "1.3",';
        rtnJSONStr += '"body": ';

        if(opptyList.size() > 0){
            Integer totalPage = (opptyList.size() / 5) < 1 ? 1 : opptyList.size() / 5;
            Integer nowPage = 1;

            List<Payload_ColumnSet> columnSetList = new List<Payload_ColumnSet>();
            for(Opportunity oppty : opptyList){
                /*
                    LeftSide                                                    Right Side
                    1-1 Account Name                1-2 Opportunity Name        |
                    2-1 Opportunity Code            2-2 Opportunity Stage       |       Action
                    3-1 Opportunity Close Date      3-2 Opportunity Amount      |
                */

                // [S] Main
                List<Payload_Column> main_ColumnList = new List<Payload_Column>();

                List<Payload_ColumnSet> left_ColumnSetList = new List<Payload_ColumnSet>();
                // [S] 1
                // [S] 1-1
                List<Payload_Column> left_1_ColumnList = new List<Payload_Column>();

                List<Payload_TextBlock> left_1_1_TextList = new List<Payload_TextBlock>();

                Payload_TextBlock left_1_1_Text = new Payload_TextBlock();
                left_1_1_Text.type = 'TextBlock';
                left_1_1_Text.text = '[' + oppty.Account.Name + ']';
                left_1_1_Text.wrap = true;

                left_1_1_TextList.add(left_1_1_Text);

                Payload_Column left_1_1_Column = new Payload_Column();
                left_1_1_Column.type = 'Column';
                left_1_1_Column.items = left_1_1_TextList;
                left_1_1_Column.width = 'stretch';

                left_1_ColumnList.add(left_1_1_Column);
                // [E] 1-1

                // [S] 1-2
                List<Payload_TextBlock> left_1_2_TextList = new List<Payload_TextBlock>();

                Payload_TextBlock left_1_2_Text = new Payload_TextBlock();
                left_1_2_Text.type = 'TextBlock';
                left_1_2_Text.text = oppty.Name;
                left_1_2_Text.wrap = true;

                left_1_2_TextList.add(left_1_2_Text);

                Payload_Column left_1_2_Column = new Payload_Column();
                left_1_2_Column.type = 'Column';
                left_1_2_Column.items = left_1_2_TextList;
                left_1_2_Column.width = 'stretch';

                left_1_ColumnList.add(left_1_2_Column);
                // [E] 1-2

                Payload_ColumnSet left_1ColimnSet = new Payload_ColumnSet();
                left_1ColimnSet.type = 'ColumnSet';
                left_1ColimnSet.columns = left_1_ColumnList;
                // [E] 1

                // [S] 2
                // [S] 2-1
                List<Payload_Column> left_2_ColumnList = new List<Payload_Column>();

                List<Payload_TextBlock> left_2_1_TextList = new List<Payload_TextBlock>();

                Payload_TextBlock left_2_1_Text = new Payload_TextBlock();
                left_2_1_Text.type = 'TextBlock';
                left_2_1_Text.text = oppty.OpportunityCode__c;
                left_2_1_Text.wrap = true;

                left_2_1_TextList.add(left_2_1_Text);

                Payload_Column left_2_1_Column = new Payload_Column();
                left_2_1_Column.type = 'Column';
                left_2_1_Column.items = left_2_1_TextList;
                left_2_1_Column.width = 'stretch';

                left_2_ColumnList.add(left_2_1_Column);
                // [E] 2-1

                // [S] 2-2
                List<Payload_TextBlock> left_2_2_TextList = new List<Payload_TextBlock>();

                Payload_TextBlock left_2_2_Text = new Payload_TextBlock();
                left_2_2_Text.type = 'TextBlock';
                left_2_2_Text.text = oppty.StageName;
                left_2_2_Text.wrap = true;

                left_2_2_TextList.add(left_2_2_Text);

                Payload_Column left_2_2_Column = new Payload_Column();
                left_2_2_Column.type = 'Column';
                left_2_2_Column.items = left_2_2_TextList;
                left_2_2_Column.width = 'stretch';

                left_2_ColumnList.add(left_2_2_Column);
                // [E] 2-2

                Payload_ColumnSet left_2ColimnSet = new Payload_ColumnSet();
                left_2ColimnSet.type = 'ColumnSet';
                left_2ColimnSet.columns = left_2_ColumnList;
                // [E] 2

                // [S] 3
                // [S] 3-1
                List<Payload_Column> left_3_ColumnList = new List<Payload_Column>();

                List<Payload_TextBlock> left_3_1_TextList = new List<Payload_TextBlock>();

                Payload_TextBlock left_3_1_Text = new Payload_TextBlock();
                left_3_1_Text.type = 'TextBlock';
                left_3_1_Text.text = String.valueOf(oppty.CloseDate);
                left_3_1_Text.wrap = true;

                left_3_1_TextList.add(left_3_1_Text);

                Payload_Column left_3_1_Column = new Payload_Column();
                left_3_1_Column.type = 'Column';
                left_3_1_Column.items = left_3_1_TextList;
                left_3_1_Column.width = 'stretch';

                left_3_ColumnList.add(left_3_1_Column);
                // [E] 3-1

                // [S] 3-2
                List<Payload_TextBlock> left_3_2_TextList = new List<Payload_TextBlock>();

                Payload_TextBlock left_3_2_Text = new Payload_TextBlock();
                left_3_2_Text.type = 'TextBlock';
                left_3_2_Text.text = String.valueOf(oppty.Amount);
                left_3_2_Text.wrap = true;

                left_3_2_TextList.add(left_3_2_Text);

                Payload_Column left_3_2_Column = new Payload_Column();
                left_3_2_Column.type = 'Column';
                left_3_2_Column.items = left_3_2_TextList;
                left_3_2_Column.width = 'stretch';

                left_3_ColumnList.add(left_3_2_Column);
                // [E] 3-2

                Payload_ColumnSet left_3ColimnSet = new Payload_ColumnSet();
                left_3ColimnSet.type = 'ColumnSet';
                left_3ColimnSet.columns = left_3_ColumnList;
                // [E] 3

                left_ColumnSetList.add(left_1ColimnSet);
                left_ColumnSetList.add(left_2ColimnSet);
                left_ColumnSetList.add(left_3ColimnSet);

                Payload_Column left_Column = new Payload_Column();
                left_Column.type = 'Column';
                left_Column.items = left_ColumnSetList;
                left_Column.width = 'stretch';

                main_ColumnList.add(left_Column);

                // [S] Right

                List<Payload_ActionSet> actionSetList = new List<Payload_ActionSet>();

                List<Payload_Action> actionList = new List<Payload_Action>();

                Payload_ActionData actionData = new Payload_ActionData();
                actionData.requestUrl = System.Label.KNOX_ADDR_SHARE_URL; // Share 버튼을 눌렀을때 동작할 URL로 수정 필요
                actionData.x = 13;

                Payload_Action action = new Payload_Action();
                action.type = 'Action.Submit';
                action.title = 'Share';
                action.data = actionData;

                actionList.add(action);

                Payload_ActionSet actionSet = new Payload_ActionSet();
                actionSet.type = 'ActionSet';
                actionSet.actions = actionList;
            
                actionSetList.add(actionSet);

                Payload_Column right_Column = new Payload_Column();
                right_Column.type = 'Column';
                right_Column.items = actionSetList;
                right_Column.width = '100px';

                main_ColumnList.add(right_Column);
                // [E] Right

                Payload_ColumnSet main_ColimnSet = new Payload_ColumnSet();
                main_ColimnSet.type = 'ColumnSet';
                main_ColimnSet.columns = main_ColumnList;
                main_ColimnSet.separator = true;

                columnSetList.add(main_ColimnSet);
                // [E] Main
            }
            // [S] Footer
            // [S] Prev
            List<Payload_Column> footer_ColumnList = new List<Payload_Column>();

            List<Payload_ActionSet> footer_PrevActionSetList = new List<Payload_ActionSet>();

            List<Payload_Action> footer_PrevActionSubmitList = new List<Payload_Action>();

            Payload_ActionData footer_PrevAction = new Payload_ActionData();
            footer_PrevAction.requestUrl = System.Label.KNOX_ADDR_PREV_URL; // Share 버튼을 눌렀을때 동작할 URL로 수정 필요
            footer_PrevAction.currnentPage = nowPage;
            footer_PrevAction.buttonType = 'prev';
            footer_PrevAction.searchKeyword = 'test';

            Payload_Action footer_PrevActionSubmit = new Payload_Action();
            footer_PrevActionSubmit.type = 'Action.Submit';
            footer_PrevActionSubmit.title = '< Prev';
            footer_PrevActionSubmit.data = footer_PrevAction;

            footer_PrevActionSubmitList.add(footer_PrevActionSubmit);

            Payload_ActionSet footer_PrevActionSet = new Payload_ActionSet();
            footer_PrevActionSet.type = 'ActionSet';
            footer_PrevActionSet.actions = footer_PrevActionSubmitList;

            footer_PrevActionSetList.add(footer_PrevActionSet);

            Payload_Column footer_PrevColumn = new Payload_Column();
            footer_PrevColumn.type = 'Column';
            footer_PrevColumn.items = footer_PrevActionSetList;
            footer_PrevColumn.width = 'auto';

            footer_ColumnList.add(footer_PrevColumn);
            // [E] Prev

            // [S] Number
            List<Payload_TextBlock> footer_NumberTextBlockList = new List<Payload_TextBlock>();

            Payload_TextBlock footer_NumberTextBlock = new Payload_TextBlock();
            footer_NumberTextBlock.type = 'TextBlock';
            footer_NumberTextBlock.text = nowPage + '/' + totalPage;
            footer_NumberTextBlock.wrap = true;
            footer_NumberTextBlock.horizontalAlignment = 'Center';

            footer_NumberTextBlockList.add(footer_NumberTextBlock);

            Payload_Column footer_NumberColumn = new Payload_Column();
            footer_NumberColumn.type = 'Column';
            footer_NumberColumn.items = footer_NumberTextBlockList;
            footer_NumberColumn.width = 'stretch';
            footer_NumberColumn.height = 'stretch';
            footer_NumberColumn.verticalContentAlignment = 'Bottom';
            footer_NumberColumn.horizontalAlignment = 'Center';
            footer_NumberColumn.spacing = 'Small';

            footer_ColumnList.add(footer_NumberColumn);
            // [E] Number

            // [S] Next
            List<Payload_ActionSet> footer_NextActionSetList = new List<Payload_ActionSet>();

            List<Payload_Action> footer_NextActionSubmitList = new List<Payload_Action>();

            Payload_ActionData footer_NextAction = new Payload_ActionData();
            footer_NextAction.requestUrl = System.Label.KNOX_ADDR_NEXT_URL; // Share 버튼을 눌렀을때 동작할 URL로 수정 필요
            footer_NextAction.currnentPage = nowPage;
            footer_NextAction.buttonType = 'next';
            footer_NextAction.searchKeyword = 'test';

            Payload_Action footer_NextActionSubmit = new Payload_Action();
            footer_NextActionSubmit.type = 'Action.Submit';
            footer_NextActionSubmit.title = 'Next >';
            footer_NextActionSubmit.data = footer_NextAction;

            footer_NextActionSubmitList.add(footer_NextActionSubmit);

            Payload_ActionSet footer_NextActionSet = new Payload_ActionSet();
            footer_NextActionSet.type = 'ActionSet';
            footer_NextActionSet.actions = footer_NextActionSubmitList;

            footer_NextActionSetList.add(footer_NextActionSet);

            Payload_Column footer_NextColumn = new Payload_Column();
            footer_NextColumn.type = 'Column';
            footer_NextColumn.items = footer_NextActionSetList;
            footer_NextColumn.width = 'auto';

            footer_ColumnList.add(footer_NextColumn);
            // [E] Next
            Payload_ColumnSet footer_ColimnSet = new Payload_ColumnSet();
            footer_ColimnSet.type = 'ColumnSet';
            footer_ColimnSet.columns = footer_ColumnList;
            footer_ColimnSet.horizontalAlignment = 'Center';
            footer_ColimnSet.bleed = true;

            columnSetList.add(footer_ColimnSet);
            // [E] Footer
            rtnJSONStr += JSON.serialize(columnSetList);
        }else{
            List<Payload_TextBlock> textBlockList = new List<Payload_TextBlock>();
            Payload_TextBlock textBlock = new Payload_TextBlock();
            textBlock.type = 'TextBlock';
            textBlock.weight = 'Bolder';
            textBlock.text = 'No Search Opportunity Info';
            textBlock.wrap = true;

            textBlockList.add(textBlock);

            List<Payload_Column> columnList = new List<Payload_Column>();
            Payload_Column column = new Payload_Column();
            column.type = 'Column';
            column.items = textBlockList;
            column.width = 'stretch';

            columnList.add(column);

            List<Payload_ColumnSet> columnSetList = new List<Payload_ColumnSet>();

            Payload_ColumnSet columnSet = new Payload_ColumnSet();
            columnSet.type = 'ColumnSet';
            columnSet.columns = columnList;

            columnSetList.add(columnSet);

            rtnJSONStr += JSON.serialize(columnSetList);
        }
        rtnJSONStr += '}';
        return rtnJSONStr;
    }    

    @HttpGet
    global static Map<String, String> redirect(){
        Map<String, String> resMap = new Map<String, String>();

        String code = RestContext.request.params.get('code');
        String workspaceId = RestContext.request.params.get('workspaceId');

        resMap.put('code', code);
        resMap.put('workspaceId', workspaceId);

        return resMap;
    }

    public class InputHeader{
        @AuraEnabled
        public String workspaceId;          // action이 수행된 workspace의 ID
        @AuraEnabled
        public String workspaceName;        // action이 수행된 workspace의 Name
        @AuraEnabled
        public String channelId;            //action이 수행된 channel의 ID
        @AuraEnabled
        public String channelName;          //action이 수행된 channel의 Name
        @AuraEnabled
        public String userId;               // action을 수행한 사용자의 ID (Long 형 Teams 내부 ID)
        @AuraEnabled
        public String userName;             // action을 수행한 사용자의 Name
        @AuraEnabled
        public String userSingleId;         // action을 수행한 사용자의 Single Id
        @AuraEnabled
        public String value;                // value
        @AuraEnabled
        public String query;                // query
        @AuraEnabled
        public String localDate;            // 날짜
        @AuraEnabled
        public String localTime;            // 시간
        @AuraEnabled
        public String timeZone;             // 타임존
    }
    
    global class OutputHeader{
        @AuraEnabled
        public String requesterId;          // (optional) 요청자 정보 onlyVisibleSender와 함께 사용 / ex) 834955804706607100
        @AuraEnabled
        public String messageId;            // (optional) 기존 메시지를 업데이트 하는 경우 기존 메시지ID / ex) 9239235244226464
        @AuraEnabled
        public String parentMessageId;      // (optional) 메시지의 댓글로 전송하는 경우 부모 메시지ID / ex) 9239235244226001
        @AuraEnabled
        public String onlyVisibleSender;    // (optional) 요청자만 볼 수 있는 메시지 전송 / ex) true
        @AuraEnabled
        public String adaptiveCards;        // (required) Adaptive Card, richMessage 필드와 둘 중 하나만 사용 / ex) "${Adaptive Card Json}"
        @AuraEnabled
        public String customElements;       // (optional) Adaptive Card를 사용할 때 Client 별로 동작 구분이 필요한 경우 설정 / ex) [{"id": "firstName", "onlyShowOn": "ios, web"}]
        @AuraEnabled
        public String expiredDatetime;      // (optional) Adaptive Card 메시지가 특정시간 이후 Disable 되도록 처리 / ex) "2020-02-14T06:08:39Z"
    }

    global class Payload_ActionData{
        @AuraEnabled
        public String requestUrl;
        @AuraEnabled
        public Integer x;
        @AuraEnabled
        public Integer currnentPage;
        @AuraEnabled
        public String buttonType;
        @AuraEnabled
        public String searchKeyword;
    }

    global class Payload_Action{
        @AuraEnabled
        public String type;
        @AuraEnabled
        public String title;
        @AuraEnabled
        public Payload_ActionData data;
    }

    global class Payload_ActionSet{
        @AuraEnabled
        public String type;
        @AuraEnabled
        public List<Payload_Action> actions;
    }

    global class Payload_BackgroundImage{
        @AuraEnabled 
        public String verticalAlignment;
        @AuraEnabled 
        public String horizontalAlignment;
        @AuraEnabled 
        public String fillMode;
    }

    global class Payload_TextBlock{
        @AuraEnabled
        public String type;
        @AuraEnabled
        public String text;
        @AuraEnabled
        public Boolean wrap;
        @AuraEnabled
        public String horizontalAlignment;
        @AuraEnabled
        public String weight;
    }

    global class Payload_Column{
        @AuraEnabled
        public String type;
        @AuraEnabled
        public List<Object> items;
        @AuraEnabled
        public String width;
        @AuraEnabled 
        public String height;
        @AuraEnabled 
        public String verticalContentAlignment;
        @AuraEnabled 
        public String horizontalAlignment;
        @AuraEnabled 
        public String spacing;
        @AuraEnabled 
        public Payload_BackgroundImage backgroundImage;
        @AuraEnabled 
        public Boolean bleed;
    }

    global class Payload_ColumnSet{
        @AuraEnabled
        public String type;
        @AuraEnabled
        public List<Payload_Column> columns;
        @AuraEnabled
        public String horizontalAlignment;
        @AuraEnabled
        public Boolean separator;
        @AuraEnabled
        public Boolean bleed;
    }
}