trigger OpportunityTrigger on Opportunity (before update, before delete, after update) {
    if(Trigger.isBefore && Trigger.isUpdate){
        TriggerHandler.handleOpportunityBeforeUpdate(Trigger.new);
    }
    if(Trigger.isBefore && Trigger.isDelete){
        TriggerHandler.handleOpportunityBeforeDelete(Trigger.old);
    }
    if(Trigger.isAfter && Trigger.isUpdate){
        Triggerhandler.handleOpportunityAfterUpdate(Trigger.new);
    }
}