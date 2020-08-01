public with sharing class WarehouseCalloutService {

    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';
    
    @future(callout=true)
    public static void runWarehouseEquipmentSync() {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(WAREHOUSE_URL);
        req.setMethod('GET');
        HttpResponse resp = http.send(req);
        if (resp.getStatusCode() == 200) {
            List<Equipment> equipmentList = new Equipment().parseEquipment(resp.getBody());
            List<Product2> equipmentToUpsert = new List<Product2>();
            for(Equipment i : equipmentList) {
                equipmentToUpsert.add(new Product2(Replacement_Part__c = true,
                                                    Cost__c = i.cost,
                                                    Current_Inventory__c = i.quantity,
                                                    Lifespan_Months__c = i.lifespan,
                                                    Maintenance_Cycle__c = i.maintenanceperiod,
                                                    ExternalId = i.sku,
                                                    Warehouse_SKU__c = i.sku,
                                                    name = i.name));
            }
            upsert equipmentToUpsert;
        }
    }

    private class Equipment {
        private String id;
        private String replacement;
        private Integer quantity;
        private String name;
        private Integer maintenanceperiod;
        private Integer lifespan;
        private Integer cost;
        private String sku;

        private List<Equipment> parseEquipment(String jsonString) {
            return (List<Equipment>)JSON.deserialize(jsonString, List<Equipment>.class);
        }
    }
}