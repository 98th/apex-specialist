public  class MaintenanceRequestHelper {
    
    public static final String TYPE_REPAIR = 'Repair';
    public static final String TYPE_ROUTINE_MAINTENANCE = 'Routine Maintenance';
    public static final String SUBJECT_ROUTINE_MAINTENANCE = 'Routine Maintenance';
    public static final String STATUS_CLOSED = 'Closed';
    public static final String STATUS_NEW = 'New';
    public static final String STATUS_WORKING = 'Working';


    public static void updateWorkOrders(Map<Id, Case> newCaseMap, Map<Id, Case> oldCaseMap) {
        List<Case> suitableCases = new List<Case>();
        
        for(Id caseId : newCaseMap.keySet()) {
            Case newCase = newCaseMap.get(caseId);
            Case oldCase = oldCaseMap.get(caseId);
            if((newCase.Type == TYPE_REPAIR || newCase.Type == TYPE_ROUTINE_MAINTENANCE) && 
                (oldCase.Status !=  STATUS_CLOSED && newCase.Status == STATUS_CLOSED)) {
                    suitableCases.add(newCase);
                }
        }
        
         if(suitableCases.size() == 0) {
            return;
        }
        
       
        List<Case> casesToInsert = new List<Case>();
		Map<Id, Decimal> maintenanceCycleMap = getCycleDays(suitableCases);
        for(Case c : suitableCases) {
            Date dueDate = null;
            if(maintenanceCycleMap.containsKey(c.id)) {
                dueDate = System.today().addDays(Integer.valueOf(maintenanceCycleMap.get(c.Id)));
            } else {
                dueDate = System.today();
            }
            Case newCase = generateCase(c, dueDate);
            casesToInsert.add(newCase);
        }
      
        insert casesToInsert;
    }             

	public static Map<Id, Decimal> getCycleDays (List<Case> cases) {
  		AggregateResult[] result = [SELECT Maintenance_Request__c, MIN(Equipment__r.Maintenance_Cycle__c)cycle
           								  FROM Work_Part__c WHERE Maintenance_Request__c IN :cases
            							  Group By Maintenance_Request__c];
		
		Map<Id, Decimal> cycleMap = new Map<Id, Decimal>();        
        for (AggregateResult i : result) {
            cycleMap.put((Id)i.get('Maintenance_Request__c'), (Decimal)i.get('cycle'));
        }
        return cycleMap;
    }
    

    private static Case generateCase (Case oldCase, Date dueDate) {
        return new Case( 	Date_Reported__c = Date.today(), 
                               Date_Due__c = dueDate, 
                                   Type = TYPE_ROUTINE_MAINTENANCE, 
                                   Subject = String.isBlank(oldCase.Subject) ? SUBJECT_ROUTINE_MAINTENANCE : oldCase.Subject,  
                                   Status = STATUS_NEW,
                                   Origin = oldCase.Origin,
                                   Equipment__c = oldCase.Equipment__c,
                                   Vehicle__c = oldCase.Vehicle__c
                                   );
    }
}