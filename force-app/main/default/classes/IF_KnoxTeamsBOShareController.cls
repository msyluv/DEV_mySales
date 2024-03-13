/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2020-12-11
 * @last modified by  : younghoon.kim@dkbmc.com
 * @call URL(Dev)     : https://sdssfa--dev.my.salesforce.com/services/apexrest/IF083/
 * @call URL(QA)      : https://sdssfa--qa.my.salesforce.com/services/apexrest/IF083/
 * @call URL(Prod)    : 
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2020-12-07   younghoon.kim@dkbmc.com   Initial Version
**/
@RestResource(urlMapping= '/IF083/*')
global class IF_KnoxTeamsBOShareController {
    private static final String INTERFACE_ID = 'IF-083';
    private static final String APEX_CLASS   = 'IF_KnoxTeamsBOShareController';
    private static final String METHOD_NAME  = 'shareBO';

    private static final Boolean DEBUG_FLAG = true;

    @HttpPost
    global static OutputHeader shareBO(){
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

        // // [S] RequestBody Check
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestRequest req = RestContext.request;
        Blob    reqBody = req.requestBody;

        // 1. inputHeader Check
        String inputJsonData = reqBody.toString();
        InputHeader inputHeader = (InputHeader) JSON.deserialize( inputJsonData, InputHeader.class);
        ifLog.addLog('[InputHeader] ==> ' + inputJsonData);
        System.debug('[InputHeader] ==> ' + inputJsonData);

        // 1-1. Opportunity Code Check
        String opptyCode = inputHeader.ID;
        ifLog.addLog('[opptyCode] ==> ' + opptyCode);
        System.debug('[opptyCode] ==> ' + opptyCode);
        
        Savepoint sp = Database.setSavepoint();

        try{
            List<Opportunity> opptyList = [SELECT Id, Name, AccountId, Account.Name, cOriginAcc__c, cOriginAcc__r.Name, OpportunityCode__c, CloseDate, Amount, StageName, Description 
                                             FROM Opportunity
                                            WHERE OpportunityCode__c = : opptyCode]; // (수정 필요...?) 협업 BO의 경우 동일한 Opportunity Code가 있을수 있어서 Owner정보도 받아와야할듯...
            ifLog.addLog('[Target opportunity Search result - size] ==> ' + opptyList.size());
            ifLog.addLog('[Target opportunity Search result - value] ==> ' + opptyList);
            System.debug('[Target opportunity Search result - size] ==> ' + opptyList.size());
            System.debug('[Target opportunity Search result - value] ==> ' + opptyList);

            Map<String, String> opptyValueMap = new Map<String, String>();
            if(opptyList.size() > 0){
                opptyValueMap.put('Opportunity Name', opptyList[0].Name);
                opptyValueMap.put('Account Name', opptyList[0].Account.Name == null ? ' ' : opptyList[0].Account.Name);
                opptyValueMap.put('Origin Account', opptyList[0].cOriginAcc__r.Name == null ? ' ' : opptyList[0].cOriginAcc__r.Name);
                opptyValueMap.put('Opporutnity Code', opptyList[0].OpportunityCode__c == null ? ' ' : opptyList[0].OpportunityCode__c);
                opptyValueMap.put('Closed Date', String.valueOf(opptyList[0].CloseDate));
                opptyValueMap.put('Amount', String.valueOf(opptyList[0].Amount) == null ? '0' : String.valueOf(opptyList[0].Amount));
                opptyValueMap.put('Stage', opptyList[0].StageName);
                opptyValueMap.put('Description', opptyList[0].Description == null ? ' ' : opptyList[0].Description);
                opptyValueMap.put('URL', System.Label.KNOX_ADDR_URL + opptyList[0].Id); // Test후 URL 변경 예정
            }
            
            // Creat adaptiveCard
            outHeader.adaptiveCards = createAdaptiveCard(opptyValueMap);

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

    public static String createAdaptiveCard(Map<String, String> opptyValueMap){
        String rtnJSONStr = '';
        rtnJSONStr += '{';
        rtnJSONStr += '"type": "AdaptiveCard",';
        rtnJSONStr += '"$schema": "http://adaptivecards.io/schemas/adaptive-card.json",';
        rtnJSONStr += '"version": "1.3",';
        rtnJSONStr += '"body": ';
        
        Set<String> opptyValueKeySet = opptyValueMap.keySet();
        if(opptyValueKeySet.size() > 0){
            List<Payload_ColumnSet> columnSetList = new List<Payload_ColumnSet>();
            for(String label : opptyValueKeySet){
                List<Payload_TextBlock> textBlockList = new List<Payload_TextBlock>();

                Payload_TextBlock textblock_Label = new Payload_TextBlock();
                textblock_Label.type = 'TextBlock';
                textblock_Label.weight = 'Bolder';
                textblock_Label.text = label;
                textblock_Label.wrap = true;

                textBlockList.add(textblock_Label);

                Payload_TextBlock textblock_value = new Payload_TextBlock();
                textblock_value.type = 'TextBlock';
                textblock_value.weight = 'Default';
                textblock_value.text = opptyValueMap.get(label);
                textblock_value.wrap = true;

                textBlockList.add(textblock_value);

                List<Payload_Column> columnList = new List<Payload_Column>();

                Payload_Column column = new Payload_Column();
                column.type = 'Column';
                column.items = textBlockList;
                column.width = 'stretch';

                columnList.add(column);

                Payload_ColumnSet columnSet = new Payload_ColumnSet();
                columnSet.type = 'ColumnSet';
                columnSet.columns = columnList;

                columnSetList.add(columnSet);

            }
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

    public class InputHeader{
        @AuraEnabled
        public String appId;                // 발신한 앱의 ID (msgBody 내에서 획득 가능)
        @AuraEnabled
        public String workspaceId;          // action이 수행된 workspace의 ID
        @AuraEnabled
        public String channelId;            // action이 수행된 channel의 ID
        @AuraEnabled
        public String userId;               // action을 수행한 사용자의 ID (Long 형 Teams 내부 ID)
        @AuraEnabled
        public String messageId;            // action이 수행된 message의 ID
        @AuraEnabled
        public String localDate;            // 날짜
        @AuraEnabled
        public String localTime;            // 시간
        @AuraEnabled
        public String timeZone;             // 타임존
        @AuraEnabled
        public String language;             // Client에 설정된 언어 정보
        @AuraEnabled
        public String requestUrl;           // App 서버의 API 주소(Adaptive Card의 Action.Data 에서 획득)
        @AuraEnabled
        public String ID;                   // Opportunity Code
    }

    global class OutputHeader{
        @AuraEnabled
        public String requesterId;          // (optional) 요청자 정보 onlyVisibleSender와 함께 사용 ex) 834955804706607100
        @AuraEnabled
        public String messageId;            // (optional) 기존 메시지를 업데이트 하는 경우 기존 메시지ID ex) 9239235244226464
        @AuraEnabled
        public String parentMessageId;      // (optional) 메시지의 댓글로 전송하는 경우 부모 메시지ID ex) 9239235244226001
        @AuraEnabled
        public String onlyVisibleSender;    // (optional) 요청자만 볼 수 있는 메시지 전송 ex) true
        @AuraEnabled
        public String adaptiveCards;        // (required) Adaptive Card, richMessage 필드와 둘 중 하나만 사용 ex) "${Adaptive Card Json}"
        @AuraEnabled
        public String customElements;       // (optional) Adaptive Card를 사용할 때 Client 별로 동작 구분이 필요한 경우 설정 ex) [{"id": "firstName", "onlyShowOn": "ios, web"}]
        @AuraEnabled
        public String expiredDatetime;      // (optional) Adaptive Card 메시지가 특정시간 이후 Disable 되도록 처리 ex) "2020-02-14T06:08:39Z"
    }

    global class Payload_TextBlock{
        @AuraEnabled
        public String type;
        @AuraEnabled
        public String weight;
        @AuraEnabled
        public String text;
        @AuraEnabled
        public Boolean wrap;
    }

    global class Payload_Column{
        @AuraEnabled
        public String type;
        @AuraEnabled
        public List<Payload_TextBlock> items;
        @AuraEnabled
        public String width;
    }

    global class Payload_ColumnSet{
        @AuraEnabled
        public String type;
        @AuraEnabled
        public List<Payload_Column> columns;
    }
}