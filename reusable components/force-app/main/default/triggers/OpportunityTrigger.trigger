/**
 * @description Trigger to detect changes in the GetReal_Inspection_Period__c field on Opportunity records.
 * If a change is detected, it calls the helper method to reschedule related tasks.
 * 
 * @triggerType before update
 */
trigger OpportunityTrigger on Opportunity (before update) {
    OpportunityHelper.handleOpportunityUpdate(Trigger.new, Trigger.oldMap);
}