global class DF_DeleteOldCustomFieldHistorySchedular implements Schedulable {

    global void execute(SchedulableContext sc) {
        Database.executeBatch(new DF_DeleteOldCustomFieldHistoryBatch(), 200);
    }
}