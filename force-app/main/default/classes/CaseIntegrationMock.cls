@isTest
global class CaseIntegrationMock implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"id": 999}');
        res.setStatusCode(201);

        return res;
    }
}
