/*
*   @Class: IntegrationService
*   @Description: This class handles the integration logic for the Case object (For now).
*   @CreationDate: 01/02/2026
*   @LastUpdate: 01/02/2026
*   @Author:Krure
*/
public class IntegrationService {

    //We will create an obect wrapper for the response(could be moved to another class):
    public class CaseResponseDto {
        public String status;
        public String priority;
        public String subject;
        public String caseNumber;
        public String id;
    }




    public static void syncCases(List<Case> casesToSync) {
        list<Case> casesToUpdate = new list<Case>();
        Http http = new Http();

        for (Case c : casesToSync) {

            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:Case_Integration/posts');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');

            Map<String, Object> payload = new Map<String, Object>{
                'caseNumber' => c.CaseNumber,
                'subject' => c.Subject,
                'priority' => c.Priority,
                'status' => c.Status
            };

            req.setBody(JSON.serialize(payload));

            try {
                HttpResponse res = http.send(req);
                CaseResponseDTO ResponseObj= (CaseResponseDTO)JSON.deserialize(res.getBody(), CaseResponseDTO.class);
                if (res.getStatusCode() == 201) {
                    System.debug('Integration success: ' + res.getBody());
                    c.Integration_Status__c = 'Sent';
                    c.External_Id__c= ResponseObj.id;
                    casesToUpdate.add(c);
                } else {
                    System.debug('Integration failed: ' + res.getStatus());
                    c.Integration_Status__c = 'Failed';
                    c.Last_Integration_Error__c='Integration Error: ' + res.getStatus()+' '+res.getBody();
                    casesToUpdate.add(c);
                }

            } catch (Exception e) {
                //Future Log creation logic here
                System.debug('Callout error: ' + e.getMessage());
                c.Last_Integration_Error__c='Callout Error: '+e.getMessage();
                casesToUpdate.add(c);
            }
        }
        try{
             update casesToUpdate;
           
           
        }catch(DmlException DException){
            system.debug('DML Exception: '+DException.getMessage());
            //Rethrow for now , we will handle this in a future error log custom object
            throw DException;
        }
        
    }
}

    