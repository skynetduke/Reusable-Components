/**
 * @description Helper class for managing task rescheduling based on Opportunity updates.
 * When an Opportunity's GetReal_Inspection_Period__c field changes, this class updates the due dates of related tasks.
 *
 * @methods
 * - rescheduleTasks(Set<Id>, Map<Id, Date>)
 */
public without sharing class ActionPlanHelper {
    /**
     * @description Reschedules tasks linked to an Action Plan when an Opportunity's inspection date changes.
     * @param opportunityIds Set of Opportunity IDs with updated inspection dates.
     * @param newInspectionDates Map of Opportunity IDs to their new inspection dates.
     */
    public static void rescheduleTasks(Set<Id> opportunityIds, Map<Id, Date> newInspectionDates) {
        if (opportunityIds.isEmpty()) return;

        // Fetch related Action Plans
        // Map of Opportunity Id as key and Action Plan Id as value
        Map<Id, Id> opportunityToActionPlan = new Map<Id, Id>();
        for (Action_Plan__c plan : [SELECT Id, Opportunity__c FROM Action_Plan__c WHERE Opportunity__c IN :opportunityIds]) {
            opportunityToActionPlan.put(plan.Opportunity__c,plan.Id);
        }

        // Fetch related Tasks and update due dates
        List<Task> tasksToUpdate = new List<Task>();
        Map<Id, Id> actionPlanToOpportunity = = new Map<Id, Id>();
        // To Reverse opportunity To ActionPlan mapping
        for (Id oppId : opportunityToActionPlan.keySet()) {
            Id actionPlanId = opportunityToActionPlan.get(oppId);
            actionPlanToOpportunity.put(actionPlanId, oppId);
        }
        // SOQL query to fetch tasks related to Action Plans
        for (Task t : [SELECT Id, WhatId, Subject, ActivityDate FROM Task WHERE WhatId IN :opportunityToActionPlan.values()]) {
            if (actionPlanToOpportunity.containsKey(t.WhatId)) {
                Id oppId = actionPlanToOpportunity.get(t.WhatId);
                if (newInspectionDates.containsKey(oppId)) {
                    t.ActivityDate = newInspectionDates.get(oppId);
                    tasksToUpdate.add(t);
                }
            }
        }

        if (!tasksToUpdate.isEmpty()) {
            update tasksToUpdate;
        }
    }
}