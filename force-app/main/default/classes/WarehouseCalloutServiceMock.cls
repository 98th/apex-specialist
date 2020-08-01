public class WarehouseCalloutServiceMock implements HttpCalloutMock {

    public  HTTPResponse respond (HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('[{"_id":"55d66226726b611100aaf753","replacement":true,"quantity":100,"name":"Radiator Pump","maintenanceperiod":0,"lifespan":0,"cost":500,"sku":"100021"}]');
        response.setStatusCode(200);
        return response; 
    }
}