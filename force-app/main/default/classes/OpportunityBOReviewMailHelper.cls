/**
* @description       : 
* @author            : seonju.jin@dkbmc.com
* @group             : 
* @last modified on  : 05-25-2023
* @last modified by  : saurav.k@partner.samsung.com
* Modifications Log 
* Ver   Date         Author                            Modification
* 1.0   2021-01-29   seonju.jin@dkbmc.com              Initial Version
* 1.1   2023-05-25   chae_ho.yang@samsung.com          stage toSet modi
* 1.2   2023-05-25   saurav.k@partner.samsung.com      Code Enhancement regarding 24th/May Developer Script Exception(MySales - 211)
**/	
public class OpportunityBOReviewMailHelper implements Queueable, Database.AllowsCallouts {
    private static String TH = '<TH>{0}</TH>';
    private static String TH_TD = '<TH>{0}</TH><TD>{1}</TD>';
    private static String TH_TD_SPAN = '<TH>{1}</TH><TD colspan="{0}">{2}</TD>';
    private static String TD = '<TD>{0}</TD>';
    private static String TD_C = '<TD  align="center">{0}</TD>';
    private static String TR = '<TR>';
    private static String TR_END = '</TR>'; 
    
    private final static String CHANGE_APPROVAL = 'CHANGE_APPROVAL';
    private final static String REVIEW_COMPLETED = 'REVIEW_COMPLETED';
    
    private Opportunity oppty;
    private List<Service__c> lservice;
    private List<Solution__c> lsolution;
    String emailType;
    
    public OpportunityBOReviewMailHelper(){}
    
    public OpportunityBOReviewMailHelper(Opportunity oppty, List<Service__c> lservice, List<Solution__c> lsolution, String type){
        this.oppty = oppty;
        this.lservice = sortList(lservice);
        this.lsolution = sortList(lsolution);
        this.emailType = type;
    }
    
    /**
* Service ItemNumber 기준으로 정렬
*/
    public List<Service__c> sortList(List<Service__c> serviceList){
        ServiceWrapper[] wrapperList = new List<ServiceWrapper>();
        for(Service__c svc: serviceList){
            wrapperList.add(new ServiceWrapper(svc));
        }
        wrapperList.sort();
        
        serviceList.clear();
        for(ServiceWrapper wrapper: wrapperList){
            serviceList.add(wrapper.svc);
        }
        
        return serviceList;
    }
    
    /**
* Solution ItemNumber 기준으로 정렬
*/
    public List<Solution__c> sortList(List<Solution__c> solutionList){
        SolutionWrapper[] wrapperList = new List<SolutionWrapper>();
        for(Solution__c sol: solutionList){
            wrapperList.add(new SolutionWrapper(sol));
        }
        wrapperList.sort();
        
        solutionList.clear();
        for(SolutionWrapper wrapper: wrapperList){
            solutionList.add(wrapper.sol);
        }
        
        return solutionList;
    }
    
    public void execute(QueueableContext context) {
        sendMailInfo();
    }
    
    public void sendMailInfo(){
        String html = '';
        String subject= '';
        
        Set<String> toSet = new Set<String>();
        if(emailType == CHANGE_APPROVAL){
            String deliveryDeptEmail = oppty.cPrimarySalesDepartment__r.DeptManagerEmail__c;         //매출부서장
            String salesDeptEmail = oppty.SalesDepartment__r.DeptManagerEmail__c ;      //수주부서장
            
            System.debug('delivery Manager Email:' + deliveryDeptEmail);
            System.debug('Sales Manager Email:' + salesDeptEmail);
            
            if(String.isNotBlank(deliveryDeptEmail)) toSet.add(deliveryDeptEmail);
            if(String.isNotBlank(salesDeptEmail)) toSet.add(salesDeptEmail);
            
            subject= '[Notice]Change Approval (Change Service Solution) Completed';
            html = makeChangeApprovalHTML(oppty, lservice, lsolution);
        }else if(emailType == REVIEW_COMPLETED){
            //-HQ수주부서 담당자(본사 사업기회 Owner)
            //-법인 영업대표 본인(Owner), 소속 부서장
            
            //본사 담당자 Email정보
            List<String> userFederIds = new List<String>();
            userFederIds.add(oppty.CollaborationBOId__r.Owner.FederationIdentifier);    //본사담당
            userFederIds.add(oppty.Owner.FederationIdentifier);                         //영업대표
            
            //Status__c <> 'R' 대상에 한해 발송.
            List<Employee__c> employeeLst= [SELECT Id, Name, EvEName__c, EvSdeptNM__c, EvKostl__c, EvMailAddr__c, EvUniqID__c FROM  
                                            Employee__c WHERE EvUniqID__c =:userFederIds AND Status__c != 'R'];
            
            for(Employee__c emp: employeeLst){
                String deptCenterCode = emp.EvKostl__c;
                String EvUniqID = emp.EvUniqID__c;
                
                System.debug('EvEName__c:' + emp.EvEName__c + ' EvUniqID:' + EvUniqID);
                System.debug('mail:' + emp.EvMailAddr__c );
                
                if(String.isNotBlank(emp.EvMailAddr__c )) toSet.add(emp.EvMailAddr__c );
                if(EvUniqID == oppty.Owner.FederationIdentifier){           //영업대표일 경우 영업대표 소속 부서장 이메일 정보를 획득
                    //영업대표 소속 부서장 이메일 정보
                    List<CostCenter__c> costCenterList = [SELECT Id, Name, DeptManager__c, DeptManagerEmail__c FROM CostCenter__c WHERE CostCenter__c =:deptCenterCode LIMIT 1];
                    if(costCenterList.size() > 0){
                        if(String.isNotBlank(costCenterList[0].DeptManagerEmail__c)) toSet.add(costCenterList[0].DeptManagerEmail__c);
                        System.debug('DeptManagerEmail__c:' + costCenterList[0].DeptManagerEmail__c);
                    }
                }
            }
            subject = '[Notice] Opportunity Review Completed';
            html = makeReviewCompletedHTML(oppty, lservice, lsolution);
        }
        
        Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        if(isSandbox){
            //toSet.clear();
            // v1.1 stage 수신인 변경
           // toSet.add('chae_ho.yang@stage.samsung.com');
              toSet.add('sm78.lim@stage.samsung.com');
              toSet.add('sbest.han@stage.samsung.com');
              toSet.add('saavi.r@stage.samsung.com');
        }
        
        List<String> toList = new List<String>();
        toList.addAll(toSet);
        
        sendMail(oppty,toList,subject, html);
    }
    
    private void sendMail(Opportunity oppty, List<String> toList, String subject, String html){
        Id recordId = oppty.Id;
        Map<String,Object> mailResultMap = new Map<String,Object>();
        sendKnoxEmail(recordId,toList, new List<String>(), new List<String>(), subject, html, new List<Map<String, Object>>(), new List<Map<String, String>>());
    }
    
    private static String RES_RESULT_SUCCESS = 'success';
    private static String RES_RESULT_ERROR = 'fail';
    @TestVisible 
    private void sendKnoxEmail( Id recordId, List<String> toList, List<String> ccList, 
                               List<String> bccList ,String subject,  String description, 
                               List<Map<String, Object>> efileList, List<Map<String, String>> nfileList){                                   
                                   Map<String,Object> resMap = new Map<String,Object>();                                   
                                   Employee__c senderEmployee = Utils.getLoginEmployeeData(oppty.OwnerId);
                                   system.debug('senderEmployee_______' + senderEmployee);
                                   if(senderEmployee != null){ 
                                       String empId = senderEmployee.Id;//V 1.2- (MYSALES: 211)
                                       system.debug('empId_______' + empId);
                                       if(String.isNotBlank(empId) && String.isNotEmpty(empId)){//V 1.2- (MYSALES: 211)
                                           system.debug('empId1_______' + empId);
                                           IF_KnoxEmailSendController.InputClass bodyMap = new IF_KnoxEmailSendController.InputClass();
                                           
                                           bodyMap.isMulti = true;
                                           bodyMap.subject = subject;
                                           bodyMap.contents = description;
                                           // contentType : 1) TEXT : 텍스트, 2) MIME : 마임, 3) HTML : HTML
                                           bodyMap.contentType = 'HTML';
                                           // doSecuType : 1) PERSONAL : 개인, 2) OFFICIAL : 공문
                                           bodyMap.docSecuType = 'PERSONAL';
                                           bodyMap.sfdcId = recordId;
                                           
                                           if(Test.isRunningTest()) senderEmployee.EvMailAddr__c = 'test@test.com';
                                           
                                           IF_KnoxEmailSendController.Sender sender = new IF_KnoxEmailSendController.Sender(senderEmployee.EvMailAddr__c.split('@')[0], senderEmployee.EvMailAddr__c);
                                           bodyMap.sender = sender;
                                           
                                           // recipientType : 1) 수신 : TO, 2) 참조 : CC, 3) 비밀참조 : BCC
                                           List<IF_KnoxEmailSendController.Recipients> recipientsList = new List<IF_KnoxEmailSendController.Recipients>();
                                           for(String t : toList){
                                               IF_KnoxEmailSendController.Recipients r = new IF_KnoxEmailSendController.Recipients(t, 'TO');
                                               recipientsList.add(r);
                                           }
                                           
                                           bodyMap.recipients = recipientsList;
                                           
                                           List<IF_KnoxEmailSendController.Attachments> attachmentsList = new List<IF_KnoxEmailSendController.Attachments>();
                                           for(Map<String, Object> file : efileList){
                                               IF_KnoxEmailSendController.Attachments attachments = new IF_KnoxEmailSendController.Attachments('file', String.valueOf(file.get('name')), String.valueOf(file.get('fileContents')));
                                               attachmentsList.add(attachments);
                                           }
                                           bodyMap.attachments = attachmentsList;
                                           
                                           System.debug('bodyMap : ' + bodyMap);
                                           
                                           Map<String,Object> response = new Map<String, Object>();
                                           if(!Test.isRunningTest()){
                                               response = IF_KnoxEmailSendController.send(bodyMap);
                                           } else {
                                               response.put('result', RES_RESULT_SUCCESS);
                                               response.put('mailId', 'testMailId');
                                           }
                                           System.debug(response);
                                           
                                           createInterfaceLog(response.get('INTERFACE_LOG'));
                                           
                                           String responseResult = String.valueOf(response.get('result'));
                                           if(responseResult == RES_RESULT_ERROR){
                                               resMap.put('result', RES_RESULT_ERROR);
                                               
                                               Map<String, Object> approvalResponseErrorDetail = (Map<String,Object>)response.get('errorDetail');
                                               resMap.put('Message', String.valueOf(approvalResponseErrorDetail.get('errorMessage')));
                                               
                                           }else if(responseResult == RES_RESULT_SUCCESS){
                                               resMap.put('result', RES_RESULT_SUCCESS);
                                               
                                               String knoxEmailId = String.valueOf(response.get('mailId'));
                                               insertKnoxEmailObj(recordId, senderEmployee.Id, toList, ccList, bccLIst, subject, description, knoxEmailId);
                                           }
                                       }
                                       else{   /* Start -V 1.2- (MYSALES: 211)  */ 
                                           system.debug('empId2_______' + empId);
                                           IF_Log__c logUserIsNotActive = new IF_Log__c();
                                           logUserIsNotActive.StatusCode__c = 'F';
                                           logUserIsNotActive.StartDatetime__c = system.now();
                                           logUserIsNotActive.EndDatetime__c = system.now();
                                           logUserIsNotActive.InterfaceId__c = 'UserIsNotActive';
                                           logUserIsNotActive.LogType__c = 'Queueable';
                                           logUserIsNotActive.ExceptionType__c = 'Sales_Rep_Status_is_R';                                       
                                           logUserIsNotActive.ErrorMessage__c = 'Please check subsidiary BOs Opportunity Sales Rep status' + ' Opportunity : ' + oppty.Id + ', SalesRep : ' + oppty.OwnerId;
                                           logUserIsNotActive.ApexName__c = 'OpportunityBOReviewMailHelper';
                                           logUserIsNotActive.ApexMethod__c = 'sendKnoxEmail';
                                           insert logUserIsNotActive;                                          
                                       }
                                       /* End -V 1.2- (MYSALES: 211)  */
                                   } else{   /* Start -V 1.2- (MYSALES: 211)  */      
                                           IF_Log__c logUserIsNotActive = new IF_Log__c();
                                           logUserIsNotActive.StatusCode__c = 'F';
                                           logUserIsNotActive.StartDatetime__c = system.now();
                                           logUserIsNotActive.EndDatetime__c = system.now();
                                           logUserIsNotActive.InterfaceId__c = 'UserIsNotActive';
                                           logUserIsNotActive.LogType__c = 'Queueable';
                                           logUserIsNotActive.ExceptionType__c = 'Sales_Rep_Status_is_R';                                       
                                           logUserIsNotActive.ErrorMessage__c = 'Please check subsidiary BOs Opportunity Sales Rep status' + ' Opportunity : ' + oppty.Id + ', SalesRep : ' + oppty.OwnerId;
                                           logUserIsNotActive.ApexName__c = 'OpportunityBOReviewMailHelper';
                                           logUserIsNotActive.ApexMethod__c = 'sendKnoxEmail';
                                           insert logUserIsNotActive;  
                                       }
                                       /* End -V 1.2- (MYSALES: 211)  */     
                               }
    
    private void insertKnoxEmailObj(Id recordId, String senderEmpId, List<String> toList, List<String> ccList, List<String> bccList,
                                    String subject,  String description, String knoxEmailId){
                                        KnoxEmail__c knoxEmail = new KnoxEmail__c(
                                            RecordId__c = recordId
                                            , Sender__c = senderEmpId
                                            , ToAddress__c = String.join(toList, ',')
                                            , CcAddress__c = String.join(ccList, ',')
                                            , BccAddress__c = String.join(bccList, ',')
                                            , Name = subject
                                            , HtmlBody__c = description
                                            , MailId__c = knoxEmailId
                                            , Status__c = 'Send'
                                        );
                                        
                                        if(recordId != null) {
                                            String objApiName =String.valueOf(recordId.getSObjectType()); 
                                            if(objApiName == 'Opportunity') knoxEmail.Opportunity__c = recordId;
                                        }
                                        
                                        insert knoxEmail;
                                    }
    
    /**
* @description Interface Log Create
* @author seonju.jin@dkbmc.com | 2020-12-11 
* @param Object IFLog 
**/
    public static void createInterfaceLog(Object IFLOGObj){
        try{
            IF_Log log = new IF_Log();
            if(IFLOGObj != null){
                IF_Log.InterfaceLog iflog_interfaceLog = (IF_Log.InterfaceLog)IFLOGObj;
                log.createLog(iflog_interfaceLog);
            } 
        }catch(Exception e){
            System.debug(LoggingLevel.ERROR, e.getStackTraceString());
        }
    }
    
    private String makeChangeApprovalHTML(Opportunity Oppty, List<Service__c> lchangeService, List<Solution__c> lchangeSolution){
        Map<String,String> svcSolMap = makeSvcSolInfoRow(lchangeService, lchangeSolution);
        
        String HTML_STYLE = '<style>.wrap{width:900px;}.wrap_table{border:0;border-collapse: collapse;}.wrap_table > tbody > tr > td {padding-left:3px;padding:8px 10px 6px; }'
            + 'h1{text-align:center; font-size:24px; color:#000;}h2{margin: 20px 0 0 0; padding:0;font-family:arial; font-size:15px; color:#000;}.wrap>div{padding:0 40px 40px;}'
            + '.tb_style01{border-collapse: collapse;border: solid 1px #a3a9b1;width: 100%;}'
            + '.tb_style01 > tbody > tr > th{background-color:#fafafa;border:solid 1px #a3a9b1;padding:6px 10px; vertical-align:middle;color: #597385; }'
            + '.tb_style01 > tbody > tr > td{padding:5px;border: solid 1px #a3a9b1; }'
            + '.wrap_link{padding:15px 20px;margin-top:15px; background-color:#f8f9fa;}'
            + '.wrap_link > strong{display:inline-block; padding:5px 0 0 0; color:#325179;}'
            + '.wrap_link > a{display:inline-block; float:right; height:22px; line-height:22px; padding:0 12px 0 8px; border-radius:4px; text-decoration:none; background:#eef1f5; border:solid 1px #cbd0d7;}</style>';
        
        String html = '';
        html += '<HTML><HEAD>';
        html += HTML_STYLE;
        html += '</HEAD><body>';
        html += '<TABLE class="wrap_table"';
        html += '<TBODY><TR><TD><DIV class="wrap" style="width:100%;';
        html += '<DIV style="padding:35px 0;">';
        html += '<H1 style="text-align:center; font-size:24px; color:#000;">Change Approval Request</H1></DIV>';
        html += '<DIV>';
        html += '<H2>Information</H2>';
        html += '<P style="font-size:11px; color:#597385; text-align:right; margin-top:-22px;">Currency: '+ oppty.CurrencyIsoCode + '</P>';
        html += '<DIV>';
        html += '<TABLE class="tb_style01"><COLGROUP><COL withd="25%"><COL withd=""><COL withd="25%"><COL withd=""></COLGROUP><TBODY>';
        //make tbody
        html += TR;
        html += String.format(TH_TD, new String[]{'Opportunity Code', Util_String.nvlStr(oppty.OpportunityCode__c)});
        html += String.format(TH_TD, new String[]{'Opportunity Stage', Util_String.nvlStr(oppty.StageName)});
        html += TR_END;
        html += TR;
        html += String.format(TH_TD_SPAN, new String[]{'3','Description', Util_String.nvlStr(oppty.Name)});
        html += TR_END;
        html += TR;
        html += String.format(TH_TD, new String[]{'Origin Account', Util_String.nvlStr(oppty.cOriginAcc__r.Name)});
        html += String.format(TH_TD, new String[]{'Contract Account', Util_String.nvlStr(oppty.Account.Name)});
        html += TR_END;
        html += TR;
        html += String.format(TH_TD, new String[]{'Internal/External', (oppty.GroupInternal__c ? 'Iternal' : 'External')});
        html += String.format(TH_TD, new String[]{'Korea/Non-Korea',(oppty.KoreaDomestic__c ? 'Korea' : 'Non-Korea')});
        html += TR_END;
        html += TR;
        html += String.format(TH_TD, new String[]{'Opportunity Owner', Util_String.nvlStr(oppty.Owner.Name)});
        html += String.format(TH_TD, new String[]{'Proposal PM', Util_String.nvlStr(oppty.ProposalPM_User__r.Name)});
        html += TR_END;
        html += TR;
        html += String.format(TH_TD, new String[]{'Primary Sales Department', Util_String.nvlStr(oppty.SalesDepartment__r.CostCenterName__c)});
        html += String.format(TH_TD, new String[]{'Primary Delivery Department', Util_String.nvlStr(oppty.cPrimarySalesDepartment__r.CostCenterName__c)});
        html += TR_END;
        html += TR;
        html += String.format(TH_TD, new String[]{'Opportunity Class', Util_String.nvlStr(oppty.FinalBusinessLevel__c)});
        html += String.format(TH_TD, new String[]{'Review Method', Util_String.nvlStr(oppty.VRBMethod__c)});
        html += TR_END;
        html += TR;
        Integer amount = (oppty.Amount).intValue();
        html += String.format(TH_TD, new String[]{'Total Contract Amt', Util_String.nvlStr(String.valueOf(amount) + '(' + oppty.CurrencyIsoCode) + ')'});
        Date closeDate = oppty.CloseDate; 
        html += String.format(TH_TD, new String[]{'Contract Date', convertDateFormat(oppty.cRevenueStartDate__c )});
        html += TR_END;
        html += TR;
        //html += '<TH>Business Info</TH><TD colspan="3">이스토어 운영 사업</TD>';   //FIXME Business Info?
        html += String.format(TH_TD_SPAN, new String[]{'3', 'Business Info',getLineBreakText(oppty.Description)});
        html += TR_END;
        html += '</TBODY></TABLE></DIV>';
        html += '<H2>Changed Information</H2>';
        html += '<DIV>';
        html += '<TABLE class="tb_style01"><COLGROUP><COL width="450px"><COL width="450px"></COLGROUP><TBODY><TR>';
        html += '<TH class="noline"> Reason for Changed Approval Request</TH>';
        html += '<TD>Change Service / Solution</TD></TR>';
        html += '</TBODY></TABLE></DIV>';
        html += '<H2 class="tit_con_s">Before Service / Solution</H2>';
        html += '<DIV>';
        html += '<TABLE class="tb_style01">';
        html += '<COLGROUP><COL width=""><COL width=""><COL width=""><COL width=""><COL width=""><COL width=""><COL width=""></COLGROUP><TBODY>';
        html += TR;
        html += String.format(TH, new String[]{'Service', 'Service'});
        html += String.format(TH, new String[]{'Sales Dept.', 'Sales Dept.'});
        html += String.format(TH, new String[]{'Delivery Dept.', 'Delivery Dept.'});
        html += String.format(TH, new String[]{'Solution', 'Solution'});
        html += String.format(TH, new String[]{'Biz. Attribute', 'Biz. Attribute'});
        html += String.format(TH, new String[]{'Solution Category', 'Solution Category'});
        html += String.format(TH, new String[]{'WBS Class', 'WBS Class'});
        html += TR_END;
        html += svcSolMap.get('BEFORE');
        html += '</TBODY></TABLE></DIV>';
        
        html += '<H2>After Service / Solution</H2>';
        html += '<DIV >';
        html += '<TABLE class="tb_style01">';
        html += '<COLGROUP><COL width=""><COL width=""><COL width=""><COL width=""><COL width=""><COL width=""><COL width=""></COLGROUP><TBODY>';
        html += TR;
        html += String.format(TH, new String[]{'Service', 'Service'});
        html += String.format(TH, new String[]{'Sales Dept.', 'Sales Dept.'});
        html += String.format(TH, new String[]{'Delivery Dept.', 'Delivery Dept.'});
        html += String.format(TH, new String[]{'Solution', 'Solution'});
        html += String.format(TH, new String[]{'Biz. Attribute', 'Biz. Attribute'});
        html += String.format(TH, new String[]{'Solution Category', 'Solution Category'});
        html += String.format(TH, new String[]{'WBS Class', 'WBS Class'});
        html += TR_END;
        html += svcSolMap.get('AFTER');
        html += '</TBODY></TABLE></DIV>';
        
        html += '<H2 class="tit_con_s">Delete Service / Solution</H2>';
        html += '<DIV class="tbl_type02">';
        html += '<TABLE class="tb_style01">';
        html += '<COLGROUP><COL width=""><COL width=""><COL width=""><COL width=""><COL width=""><COL width=""><COL width=""></COLGROUP><TBODY>';
        html += TR;
        html += String.format(TH, new String[]{'Service', 'Service'});
        html += String.format(TH, new String[]{'Sales Dept.', 'Sales Dept.'});
        html += String.format(TH, new String[]{'Delivery Dept.', 'Delivery Dept.'});
        html += String.format(TH, new String[]{'Solution', 'Solution'});
        html += String.format(TH, new String[]{'Biz. Attribute', 'Biz. Attribute'});
        html += String.format(TH, new String[]{'Solution Category', 'Solution Category'});
        html += String.format(TH, new String[]{'WBS Class', 'WBS Class'});
        html += TR_END;
        html += svcSolMap.get('DELETE');
        html += '</TBODY></TABLE></DIV>';
        
        html += '<H2>Add Service / Solution</H2>';
        html += '<DIV>';
        html += '<TABLE class="tb_style01">';
        html += '<COLGROUP><COL width=""><COL width=""><COL width=""><COL width=""><COL width=""><COL width=""><COL width=""></COLGROUP><TBODY>';
        html += TR;
        html += String.format(TH, new String[]{'Service', 'Service'});
        html += String.format(TH, new String[]{'Sales Dept.', 'Sales Dept.'});
        html += String.format(TH, new String[]{'Delivery Dept.', 'Delivery Dept.'});
        html += String.format(TH, new String[]{'Solution', 'Solution'});
        html += String.format(TH, new String[]{'Biz. Attribute', 'Biz. Attribute'});
        html += String.format(TH, new String[]{'Solution Category', 'Solution Category'});
        html += String.format(TH, new String[]{'WBS Class', 'WBS Class'});
        html += TR_END;
        html += TR;
        html += svcSolMap.get('ADD');
        html += '</TBODY></TABLE></DIV>';
        
        // String mydomain = getMyDomain();
        
        html += '<DIV class="wrap_link"><STRONG>Go to Business Opportunity</STRONG>';
        html += '<A href="https://' + getMyDomain() + '.lightning.force.com/lightning/r/Opportunity/' + oppty.Id + '/view" target="_blank" style="margin-left: 5px;">mySales</A> ';
        html += '<A href="'+ System.Label.BO_REVIEW_URL + '?orderId=' + oppty.OpportunityCode__c +'&sapCompany=' + oppty.CompanyCode__c + '" target="_blank">BO Detail</A> ';
        html += '</DIV>';
        html += '</DIV></DIV></TD></TR></TBODY></TD></TR></TBODY></TABLE></TD></TR></TBODY></TABLE></body></HTML>';
        return html;
    }
    
    
    private Map<String,String> makeSvcSolInfoRow(List<Service__c> lchangeService, List<Solution__c> lchangeSolution){
        List<Map<String,String>> solutionTypeMap = Utils.getPicklistOptionType('Master_Solution__c', 'SolutionType__c');
        Map<String,String> svcSolInfoMap = new Map<String,String>();
        
        String addHTML = '';
        String beforeHTML = '';
        String afterHTML = '';
        String delHTML = '';
        for(Service__c svc: lchangeService){
            Boolean sendSAP = svc.SendSAP__c;
            
            String service = svc.sService__r.Name;
            String sales = svc.sSalesDepartment__r.CostCenterName__c;
            String delivery = svc.sDeliveryDepartment__r.CostCenterName__c; 
            
            String bService = svc.Service__r.Name;
            String bSales = svc.SalesDepartment__r.CostCenterName__c;
            String bDelivery = svc.DeliveryDepartment__r.CostCenterName__c; 
            
            Boolean beforeDelete = false;
            
            //서비스 정보는 제외
            if(svc.SendSAP__c){
                if(svc.sService__r.Code__c != svc.Service__r.Code__c) beforeDelete = true;
                Boolean deptChange = false;
                if((sales != bSales) || (delivery != bDelivery)) deptChange = true;
                if(!beforeDelete){
                    if(deptChange){
                        beforeHTML += TR;
                        beforeHTML += String.format(TD_C,new String[]{bService});
                        beforeHTML += String.format(TD_C,new String[]{bSales});
                        beforeHTML += String.format(TD_C,new String[]{bDelivery});
                        beforeHTML += String.format(TD_C,new String[]{''});
                        beforeHTML += String.format(TD_C,new String[]{''});
                        beforeHTML += String.format(TD_C,new String[]{''});
                        beforeHTML += String.format(TD_C,new String[]{''});
                        beforeHTML += TR_END;
                        
                        //change info(after)
                        afterHTML += TR;
                        afterHTML += String.format(TD_C,new String[]{service});
                        afterHTML += String.format(TD_C,new String[]{sales});
                        afterHTML += String.format(TD_C,new String[]{delivery});
                        afterHTML += String.format(TD_C,new String[]{''});
                        afterHTML += String.format(TD_C,new String[]{''});
                        afterHTML += String.format(TD_C,new String[]{''});
                        afterHTML += String.format(TD_C,new String[]{''});
                        afterHTML += TR_END;
                    }
                }
                
                /* if(svc.sDeletionFlag__c){
delHTML += TR;
delHTML += String.format(TD_C,new String[]{bService});
delHTML += String.format(TD_C,new String[]{bSales});
delHTML += String.format(TD_C,new String[]{bDelivery});
delHTML += TR_END;

}else{
if(beforeDelete){
//del
delHTML += TR;
delHTML += String.format(TD_C,new String[]{bService});
delHTML += String.format(TD_C,new String[]{bSales});
delHTML += String.format(TD_C,new String[]{bDelivery});
delHTML += String.format(TD_C,new String[]{''});
delHTML += String.format(TD_C,new String[]{''});
delHTML += String.format(TD_C,new String[]{''});
delHTML += String.format(TD_C,new String[]{''});
delHTML += TR_END;

//add
addHTML += TR;
addHTML += String.format(TD_C,new String[]{service});
addHTML += String.format(TD_C,new String[]{sales});
addHTML += String.format(TD_C,new String[]{delivery});
addHTML += String.format(TD_C,new String[]{''});
addHTML += String.format(TD_C,new String[]{''});
addHTML += String.format(TD_C,new String[]{''});
addHTML += String.format(TD_C,new String[]{''});
addHTML += TR_END;
}else{
//change info(before)
beforeHTML += TR;
beforeHTML += String.format(TD_C,new String[]{bService});
beforeHTML += String.format(TD_C,new String[]{bSales});
beforeHTML += String.format(TD_C,new String[]{bDelivery});
beforeHTML += String.format(TD_C,new String[]{''});
beforeHTML += String.format(TD_C,new String[]{''});
beforeHTML += String.format(TD_C,new String[]{''});
beforeHTML += String.format(TD_C,new String[]{''});
beforeHTML += TR_END;

//change info(after)
afterHTML += TR;
afterHTML += String.format(TD_C,new String[]{service});
afterHTML += String.format(TD_C,new String[]{sales});
afterHTML += String.format(TD_C,new String[]{delivery});
afterHTML += String.format(TD_C,new String[]{''});
afterHTML += String.format(TD_C,new String[]{''});
afterHTML += String.format(TD_C,new String[]{''});
afterHTML += String.format(TD_C,new String[]{''});
afterHTML += TR_END;
}
} */
            }else{
                /* addHTML += TR;
addHTML += String.format(TD_C,new String[]{service});
addHTML += String.format(TD_C,new String[]{sales});
addHTML += String.format(TD_C,new String[]{delivery});
addHTML += String.format(TD_C,new String[]{''});
addHTML += String.format(TD_C,new String[]{''});
addHTML += String.format(TD_C,new String[]{''});
addHTML += String.format(TD_C,new String[]{''});
addHTML += TR_END; */
            }
            
            for(Solution__c sol: lchangeSolution){
                if(svc.ItemNumber__c == sol.ItemNumber__c){
                    String solution = sol.sSolution__r.Name;
                    String bizAttr = sol.sBizAttribute__r.Name;
                    String wbsClass = sol.sWBSClass__c;
                    
                    String solutionType = (sol.sSolutionType__c == null) ? '' : sol.sSolutionType__c;
                    String solutionCategory = '';
                    for(Map<String,String> map1 : solutionTypeMap){
                        if(map1.get('value').toUpperCase() == (solutionType).toUpperCase()){
                            solutionCategory = map1.get('label');
                            break;
                        } 
                    }
                    
                    String bSolution = sol.Solution__r.Name;
                    String bBizAttr = sol.BizAttribute__r.Name;
                    String bWbsClass = sol.WBSClass__c;
                    String bSolutionType = (sol.SolutionType__c == null) ? '' : sol.SolutionType__c;
                    String bSolutionCategory = '';
                    for(Map<String,String> map1 : solutionTypeMap){
                        if(map1.get('value').toUpperCase() == (bSolutionType).toUpperCase()){
                            bSolutionCategory = map1.get('label');
                            break;
                        } 
                    }
                    
                    
                    Boolean beforeSolDelete = false;
                    Boolean solSendSAP = sol.SendSAP__c;
                    if(solSendSAP){
                        if(sol.Service__r.Service__c != sol.Service__r.sService__c) beforeDelete = true;
                        if(sol.sPSType__c != sol.PSType__c) beforeDelete = true;
                        
                        
                        if(sol.sDeletionFlag__c){
                            delHTML += TR;
                            delHTML += String.format(TD_C,new String[]{bService});
                            delHTML += String.format(TD_C,new String[]{bSales});
                            delHTML += String.format(TD_C,new String[]{bDelivery});
                            delHTML += String.format(TD_C,new String[]{bSolution});
                            delHTML += String.format(TD_C,new String[]{bBizAttr});
                            delHTML += String.format(TD_C,new String[]{bSolutionCategory});
                            delHTML += String.format(TD_C,new String[]{bWbsClass});
                            delHTML += TR_END;
                            
                        }else{
                            if(beforeSolDelete){
                                delHTML += TR;
                                delHTML += String.format(TD_C,new String[]{bService});
                                delHTML += String.format(TD_C,new String[]{bSales});
                                delHTML += String.format(TD_C,new String[]{bDelivery});
                                delHTML += String.format(TD_C,new String[]{bSolution});
                                delHTML += String.format(TD_C,new String[]{bBizAttr});
                                delHTML += String.format(TD_C,new String[]{bSolutionCategory});
                                delHTML += String.format(TD_C,new String[]{bWbsClass});
                                delHTML += TR_END;
                                
                                addHTML += TR;
                                addHTML += String.format(TD_C,new String[]{service});
                                addHTML += String.format(TD_C,new String[]{sales});
                                addHTML += String.format(TD_C,new String[]{delivery});
                                addHTML += String.format(TD_C,new String[]{solution});
                                addHTML += String.format(TD_C,new String[]{bizAttr});
                                addHTML += String.format(TD_C,new String[]{solutionCategory});
                                addHTML += String.format(TD_C,new String[]{wbsClass});
                                addHTML += TR_END;
                            }else{
                                //change info(before)
                                beforeHTML += TR;
                                beforeHTML += String.format(TD_C,new String[]{bService});
                                beforeHTML += String.format(TD_C,new String[]{bSales});
                                beforeHTML += String.format(TD_C,new String[]{bDelivery});
                                beforeHTML += String.format(TD_C,new String[]{bSolution});
                                beforeHTML += String.format(TD_C,new String[]{bBizAttr});
                                beforeHTML += String.format(TD_C,new String[]{bSolutionCategory});
                                beforeHTML += String.format(TD_C,new String[]{bWbsClass});
                                beforeHTML += TR_END;
                                
                                //change info(after)
                                afterHTML += TR;
                                afterHTML += String.format(TD_C,new String[]{service});
                                afterHTML += String.format(TD_C,new String[]{sales});
                                afterHTML += String.format(TD_C,new String[]{delivery});
                                afterHTML += String.format(TD_C,new String[]{solution});
                                afterHTML += String.format(TD_C,new String[]{bizAttr});
                                afterHTML += String.format(TD_C,new String[]{solutionCategory});
                                afterHTML += String.format(TD_C,new String[]{wbsClass});
                                afterHTML += TR_END;
                            }
                        }
                    }else{
                        addHTML += TR;
                        addHTML += String.format(TD_C,new String[]{service});
                        addHTML += String.format(TD_C,new String[]{sales});
                        addHTML += String.format(TD_C,new String[]{delivery});
                        addHTML += String.format(TD_C,new String[]{solution});
                        addHTML += String.format(TD_C,new String[]{bizAttr});
                        addHTML += String.format(TD_C,new String[]{solutionCategory});
                        addHTML += String.format(TD_C,new String[]{wbsClass});
                        addHTML += TR_END;
                    }
                }
            } 
        }
        
        svcSolInfoMap.put('ADD', addHTML);
        svcSolInfoMap.put('BEFORE', beforeHTML);
        svcSolInfoMap.put('AFTER', afterHTML);
        svcSolInfoMap.put('DELETE', delHTML);
        return svcSolInfoMap;
    }
    
    private String makeReviewCompletedHTML(Opportunity oppty, List<Service__c> lchangeService, List<Solution__c> lchangeSolution){
        List<Map<String,String>> solutionTypeMap = Utils.getPicklistOptionType('Master_Solution__c', 'SolutionType__c');
        
        String html = '';
        html += '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3c.org/TR/1999/REC-html401-19991224/loose.dtd">';
        html += '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">';
        html += '<HTML lang="en">';
        html += '<HEAD><META content="IE=11.0000" http-equiv="X-UA-Compatible"><META http-equiv="X-UA-Compatible" content="IE=edge"><TITLE>Opportunity Review Completed</TITLE><META http-equiv="Content-Type" content="text/html;charset=UTF-8">';
        html += '<STYLE type="text/css">body,div,dd,ul,ol,li,h1,h2,form,fieldset,p,button {margin:0; padding:0;}body,h1,h2,input,button{font-family:arial; font-size:12px; color:#000;}li {list-style:none;}hr {display:none;}table {width:100%; table-layout:fixed; border-spacing:0;}';
        html += '.space_mt5{margin-top:5px;}.space_mt10{margin-top:10px;}.space_mt35{margin-top:35px;}.body_wrap{width:900px;}.body_wrap .tit_wrap{padding:35px 0;}.body_wrap .tit_wrap h1{text-align:center; font-size:24px; color:#000;}.body_wrap .cont_wrap{padding:0 40px 40px;}.body_wrap .tit_con{margin:35px 0 10px; font-size:16px; color:#333;}.body_wrap .box_info{background-color:#f2f5f9; padding:20px; color:#666; line-height:1.5; }';
        html += '.body_wrap .box_info strong.tit{display:block; margin:0 0 10px 0;padding:0 0 0 18px; font-size:15px; color:#325179;}.body_wrap .list_type_dot li{ padding:1px 10px 2px;}.body_wrap table th, table td{vertical-align:top;}.body_wrap table td.a_c{text-align:center; padding:0;}.body_wrap table td.a_r{text-align:right; padding:0 10px 0 0;}.body_wrap .tbl_type01 > table{border-top:solid 1px #a3a9b1;border-left:solid 1px #a3a9b1; border-right:solid 1px #a3a9b1;}';
        html += '.body_wrap .tbl_type01 table tr:last-child th,.body_wrap .tbl_type01 table tr:last-child td{border-bottom:solid 1px #a3a9b1;}.body_wrap .tbl_type01 table th{width:140px; vertical-align:top;padding:13px 0 12px 20px; text-align:left; color:#4d6da7;}';
        html += '.body_wrap .tbl_type01 table td{padding:12px 20px 10px 0; line-height:1.4;}.body_wrap .tbl_type02 > table{border-top:solid 1px #a3a9b1; border-bottom:solid 1px #a3a9b1;border-left:solid 1px #cfd3d7; border-right:solid 1px #cfd3d7;}.body_wrap .tbl_type02 table th{padding:6px 10px; vertical-align:middle; background-color:#fafafa;border-bottom:solid 1px #a3a9b1; border-right:solid 1px #cfd3d7; color:#597385;}';
        html += '.body_wrap .tbl_type02 table td{padding:8px 10px 6px;border-right:solid 1px #cfd3d7; border-bottom:solid 1px #cfd3d7;}.body_wrap .link_wrap{padding:15px 20px; background-color:#f8f9fa;}.body_wrap .link_wrap strong{display:inline-block; padding:5px 0 0 0; color:#325179;}.body_wrap .link_wrap .link_go{float:right; display:inline-block; height:22px;line-height:22px; padding:0 12px 0 8px; border-radius:4px; text-decoration:none;border:solid 1px #cbd0d7; color:#606772;}</STYLE>';
        html += '</HEAD> ';
        html += '<BODY class="NoMargin"><DIV id="Contents" style="width: 100%;"><TABLE width="100%" height="100%"><TBODY><TR><TD valign="top" style="padding: 0px 10px 20px;"><P class="Margin10"></P><TABLE width="100%" border="0" cellspacing="0" cellpadding="0">';
        html += '<TBODY><TR><TD class="ListColA"><TABLE width="100%" border="0" cellspacing="0" cellpadding="0"><TBODY><TR><TD>';
        html += '<TABLE border="0"><TBODY><TR><TD><DIV class="body_wrap"><DIV class="tit_wrap">';
        html += '<H1>BO Review Completed</H1></DIV>';
        
        Date today = System.today();
        String todayStr = ((today.Month() < 10) ? '0'  : '' ) + today.Month() + ' / ' + today.year();
        html += '<DIV class="cont_wrap"><P>Opportunity Review of Statement on&nbsp;'+ todayStr +'.</P><DIV class="box_info space_mt10">';
        
        html += '<STRONG class="tit">Guide on approval of BO for sub-standard businesses and validity of biz information.(Business Unit Leader, Sales Team Leader)</STRONG>';
        html += '<UL class="list_type_dot"><LI>For unqualifed opportunity from evalution of customer/product(process),employee or manager responsible\'s review should be requested after the business team\'s decision on participation.</LI>';
        html += '<LI>Approver (Biz team leader, Biz group leader) should review the validity of business information typed in ERP system prior to approval.</LI>';
        html += '<LI>Entered information shall be shared with delivery and relevant departments in compliance withthe post-approval internal regulation and be used as a basis for business support and follow-up process operation.</LI>';
        html += '<LI>In addition, please give instructions so that newly acquired biz information can be constantly updated.</LI></UL></DIV>';
        html += '<H2 class="tit_con">Basic Information Of Opportunity</H2>';
        html += '<DIV class="tbl_type01"><TABLE><TBODY>';
        html += TR;
        html += String.format(TH_TD_SPAN, new String[]{'3', 'Opportunity Description (Code)', oppty.Name + '(' + oppty.OpportunityCode__c + ')'});
        html += TR_END;
        html += TR;
        html += String.format(TH_TD, new String[]{'Origin Account', oppty.cOriginAcc__r.Name});
        html += String.format(TH_TD, new String[]{'Contract Account', oppty.Account.Name});
        html += TR_END;
        html += TR;
        html += String.format(TH_TD, new String[]{'Primary Delivery Dept.', oppty.SalesDepartment__r.CostCenterName__c});
        html += String.format(TH_TD, new String[]{'Primary Sales Dept.', oppty.cPrimarySalesDepartment__r.CostCenterName__c});
        html += TR_END;
        html += TR;
        html += String.format(TH_TD, new String[]{'Estimated Contract Amount(' + oppty.CurrencyIsoCode + ')', String.valueOf(oppty.Amount)});
        html += String.format(TH_TD, new String[]{'',''});
        html += TR_END;
        html += '</TBODY></TABLE></DIV>';
        html += '<H2 class="tit_con">Department Information By Service/Solution</H2><DIV class="tbl_type02 space_mt5">';
        html += '<TABLE><COLGROUP><COL width="17%"><COL width="17%"><COL width="17%"><COL width="17%"><COL width="16%"><COL width="16%"></COLGROUP>';
        //html += '<TABLE><COLGROUP><COL width="10%"><COL width="14%"><COL width="14%"><COL width="14%"><COL width="14%"><COL width="14%"><COL width="14%"><COL width="6%"></COLGROUP>';
        html += '<TBODY>';
        html += TR;
        html += String.format(TH, new String[]{'Item'});
        html += String.format(TH, new String[]{'Service'});
        html += String.format(TH, new String[]{'Sales Dept.'});
        html += String.format(TH, new String[]{'Sales Dept. Name'});
        html += String.format(TH, new String[]{'Delivery Dept.'});
        html += String.format(TH, new String[]{'Delivery Dept.Name'});
        html += TR_END;
        
        //make Service Info
        if(lchangeService != null){
            for(Service__c svc: lchangeService){
                String item = String.valueOf(svc.ItemNumber__c);
                String ServiceNm = svc.sService__r.Name;
                String sales = svc.sSalesDepartment__r.CostCenter__c;
                String salesNm = svc.sSalesDepartment__r.CostCenterName__c;
                String delivery = svc.sDeliveryDepartment__r.CostCenter__c;
                String deliveryNm = svc.sDeliveryDepartment__r.CostCenterName__c;
                
                html += TR;
                html += String.format(TD_C, new String[]{item});
                html += String.format(TD_C, new String[]{ServiceNm});
                html += String.format(TD_C, new String[]{sales});
                html += String.format(TD_C, new String[]{salesNm});
                html += String.format(TD_C, new String[]{delivery});
                html += String.format(TD_C, new String[]{deliveryNm});
                html += TR_END;
                
            }
        }
        html += '</TBODY></TABLE>';
        html += '<TABLE><COLGROUP><COL width="17%"><COL width="17%"><COL width="17%"><COL width="17%"><COL width="16%"><COL width="16%"></COLGROUP>';
        html += '<TBODY>';
        html += TR;
        html += String.format(TH, new String[]{'Service'});
        html += String.format(TH, new String[]{'Solution'});
        html += String.format(TH, new String[]{'Biz Attribute'});
        html += String.format(TH, new String[]{'Solution Type'});
        html += String.format(TH, new String[]{'Sales Dept. Name'});
        html += String.format(TH, new String[]{'Delivery Dept. Name'});
        html += TR_END;
        //make Solution Info
        if(lchangeSolution!= null){
            for(Solution__c sol: lchangeSolution){
                String item = String.valueOf(sol.ItemNumber__c);
                String ServiceNm = sol.Service__r.sService__r.Name;
                String solutuion = sol.sSolution__r.Name;
                String bizAttr = sol.sBizAttribute__r.Name;
                String solutionType = (sol.sSolutionType__c == null) ?  '' : sol.sSolutionType__c;
                String solutionCategory = '';
                for(Map<String,String> map1 : solutionTypeMap){
                    if(map1.get('value').toUpperCase() == (solutionType).toUpperCase()){
                        solutionCategory = map1.get('label');
                        break;
                    } 
                }
                
                String saelsNm = sol.Service__r.sSalesDepartment__r.CostCenter__c;
                String deliveryNm = sol.Service__r.sDeliveryDepartment__r.CostCenterName__c;
                
                html += TR;
                html += String.format(TD_C, new String[]{item + ':' + ServiceNm});
                //html += String.format(TD_C, new String[]{ServiceNm});
                html += String.format(TD_C, new String[]{solutuion});
                html += String.format(TD_C, new String[]{bizAttr});
                html += String.format(TD_C, new String[]{solutionCategory});
                html += String.format(TD_C, new String[]{saelsNm});
                html += String.format(TD_C, new String[]{deliveryNm});
                html += TR_END;
            }
        }
        
        html += '</TBODY></TABLE></DIV>';
        
        html += '<H2 class="tit_con">Review/Adjust Biz Grade (Business Unit Leader)</H2>';
        html += '<DIV class="tbl_type02">';
        html += '<TABLE><COLGROUP><COL width="34%"><COL width="33%"><COL width="33%"></COLGROUP>';
        html += '<TBODY>';
        html += TR;
        html += String.format(TH, new String[]{'Calculated Item '});
        html += String.format(TH, new String[]{'Item Data'});
        html += String.format(TH, new String[]{'Grade'});
        html += TR_END;
        html += TR;
        html += String.format(TD, new String[]{'Total Contract Amount(' + oppty.CurrencyIsoCode +')'});
        html += '<TD class="a__r"><SPAN class="a_c">' + oppty.Amount +'</SPAN></TD>';
        html += '<TD class="a__r"><SPAN class="a_c">' + oppty.FinalBusinessLevel__c +'</SPAN></TD>';
        html += TR_END;
        html += '</TBODY></TABLE></DIV>';
        html += '<DIV class="link_wrap fix space_mt35">';
        
        String companyCode = (String.isEmpty(oppty.CompanyCode__c))? '' : oppty.CompanyCode__c;
        String companyCodeHQ = (String.isEmpty(oppty.CollaborationBOId__r.CompanyCode__c)) ? '' : oppty.CollaborationBOId__r.CompanyCode__c;
        
        html += '<STRONG>[Business Opportunity]'+  oppty.Name + '(' + companyCode +')'+ '</STRONG>';
        html += '<A class="link_go" href="https://' + getMyDomain() + '.lightning.force.com/lightning/r/Opportunity/' + oppty.Id + '/view" target="_blank">Go</A></DIV>';
        html += '<DIV class="link_wrap fix space_mt35">';
        html += '<STRONG>[Business Opportunity]'+  oppty.Name + '(' + companyCodeHQ + ')' + '</STRONG>';
        html += '<A class="link_go" href="https://' + getMyDomain() + '.lightning.force.com/lightning/r/Opportunity/' + oppty.CollaborationBOId__c + '/view" target="_blank">Go</A></DIV>';
        html += '</DIV></DIV>';
        html += '</TD></TR></TBODY></TABLE></TD></TR></TBODY></TABLE>';
        html += '</TD></TR></TBODY></TABLE></TABLE></BODY></HTML>';
        
        return html;
    }
    
    private string getMyDomain(){
        String domain = '';
        try {
            String urlInstance=String.valueof(System.URL.getSalesforceBaseURL().gethost());
            domain = urlInstance.removeEndIgnoreCase('.my.salesforce.com');
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return domain;
    }
    
    private String getLineBreakText(String text){
        if(text == null) return '';
        try{
            return text.replaceAll('\r\n', '<br/>');
        }catch(Exception e){
            return text;
        }
    }
    
    public static String convertDateFormat(Date dateInfo){
        if(dateInfo == null) return '';
        String monthStr = String.valueOf(dateInfo.month());
        String dayStr = String.valueOf(dateInfo.day());
        return dateInfo.year() + '.' + (((monthStr.length()== 1)) ? '0' : '')  +dateInfo.month() + '.' + (((dayStr.length()== 1)) ? '0' : '') + dateInfo.day();
    }
    
    public class ServiceWrapper implements Comparable{
        public Service__c svc;
        
        public ServiceWrapper(Service__c svc){
            this.svc = svc;
        }
        public Integer compareTo(Object compareTo) 
        {
            ServiceWrapper svcWrapper = (ServiceWrapper) compareTo;
            if (Integer.valueOf(svc.ItemNumber__c) == Integer.valueOf(svcWrapper.svc.ItemNumber__c)) return 0;
            if (Integer.valueOf(svc.ItemNumber__c) > Integer.valueOf(svcWrapper.svc.ItemNumber__c)) return 1;
            return -1;        
        }
    }
    
    public class SolutionWrapper implements Comparable{
        public Solution__c sol;
        
        public SolutionWrapper(Solution__c sol){
            this.sol = sol;
        }
        
        public Integer compareTo(Object compareTo) 
        {
            SolutionWrapper solWrapper = (SolutionWrapper) compareTo;
            if (Integer.valueOf(sol.ItemNumber__c) == Integer.valueOf(solWrapper.sol.ItemNumber__c)) return 0;
            if (Integer.valueOf(sol.ItemNumber__c) > Integer.valueOf(solWrapper.sol.ItemNumber__c)) return 1;
            return -1;        
        }
    }
}