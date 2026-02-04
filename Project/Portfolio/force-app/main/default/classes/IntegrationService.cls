/*
*   @Class: IntegrationService
*   @Description: This class handles the integration logic for the Case object (For now).
*   @CreationDate: 01/02/2026
*   @LastUpdate: 01/02/2026
*   @Author:Krure
*/
public class IntegrationService {

    public static void syncCases(List<Case> casesToSync) {

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

                if (res.getStatusCode() == 201) {
                    System.debug('Integration success: ' + res.getBody());
                } else {
                    System.debug('Integration failed: ' + res.getStatus());
                }

            } catch (Exception e) {
                //Future Log creation logic here
                System.debug('Callout error: ' + e.getMessage());
            }
        }
    }
}
    