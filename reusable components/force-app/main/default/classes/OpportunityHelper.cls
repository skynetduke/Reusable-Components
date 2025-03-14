/**
 * @description This helper class processes Opportunity updates.
 * It identifies records where the GetReal_Inspection_Period__c field has changed
 * and calls ActionPlanHelper to update related tasks.
 *
 * @methods
 * - handleOpportunityUpdate(List<Opportunity>, Map<Id, Opportunity>)
 */
public without sharing class OpportunityHelper {
    /**
     * @description Identifies Opportunities where GetReal_Inspection_Period__c has changed and triggers task rescheduling.
     * @param newList List of updated Opportunity records.
     * @param oldMap Map of old Opportunity records for comparison.
     */
    public static void handleOpportunityUpdate(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
        Set<Id> opportunityIds = new Set<Id>();
        Map<Id, Date> newInspectionDates = new Map<Id, Date>();

        for (Opportunity opp : newList) {
            if (oldMap.containsKey(opp.Id)) {
                Opportunity oldOpp = oldMap.get(opp.Id);
                if (opp.GetReal_Inspection_Period__c != oldOpp.GetReal_Inspection_Period__c) {
                    opportunityIds.add(opp.Id);
                    newInspectionDates.put(opp.Id, opp.GetReal_Inspection_Period__c);
                }
            }
        }

        if (!opportunityIds.isEmpty()) {
            ActionPlanHelper.rescheduleTasks(opportunityIds, newInspectionDates);
        }
    }
}