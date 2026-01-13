trigger CaseTrigger on Case (
    before insert,
    after insert,
    before update,
    after update
) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            CaseTriggerHandler.beforeInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            CaseTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            CaseTriggerHandler.afterInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            CaseTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}
