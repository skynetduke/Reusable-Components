public with sharing class DeepClone {
    @InvocableMethod(label='Deep Clone Lead Or Contact' description='Clones a Lead or Contact including related records.')
    public static List<Id> deepClone(List<CloneRequest> requests) {
        List<Id> clonedIdList = new List<Id>();

        for (CloneRequest cr : requests) {
            if (cr.sourceRecordId == null || String.isEmpty(cr.objectApiName)) continue;

            try {
                // Fetch all fields dynamically
                Schema.SObjectType objType = Schema.getGlobalDescribe().get(cr.objectApiName);
                if (objType == null) continue;

                Map<String, Schema.SObjectField> fields = objType.getDescribe().fields.getMap();
                String query = 'SELECT ' + String.join(fields.keySet(), ',') + ' FROM ' + cr.objectApiName + ' WHERE Id = :cr.sourceRecordId';
                
                SObject sourceRecord = Database.query(query);
                SObject newRecord = sourceRecord.clone();
                insert newRecord;

                clonedIdList.add((Id)newRecord.get('Id'));

                // Clone related records
                for (CloneRequest relatedrec : requests) {
                    if (String.isEmpty(relatedrec.relatedObjectApiName) || String.isEmpty(relatedrec.parentField)) continue;

                    Schema.SObjectType relatedType = Schema.getGlobalDescribe().get(relatedrec.relatedObjectApiName);
                    if (relatedType == null) continue;

                    Map<String, Schema.SObjectField> relatedFields = relatedType.getDescribe().fields.getMap();
                    String relatedQuery = 'SELECT ' + String.join(relatedFields.keySet(), ',') + ' FROM ' + relatedrec.relatedObjectApiName + ' WHERE ' + relatedrec.parentField + ' = :cr.sourceRecordId';
                    
                    if (!String.isEmpty(relatedrec.whereClause)) {
                        relatedQuery += ' AND ' + relatedrec.whereClause;
                    }

                    List<SObject> relatedRecords = Database.query(relatedQuery);
                    List<SObject> clonedRelatedRecords = new List<SObject>();

                    for (SObject record : relatedRecords) {
                        SObject clonedRelated = record.clone();
                        clonedRelated.put(relatedrec.parentField, newRecord.get('Id')); // Link to new record
                        clonedRelatedRecords.add(clonedRelated);
                    }

                    if (!clonedRelatedRecords.isEmpty()) {
                        insert clonedRelatedRecords;
                    }
                }
            } catch (Exception e) {
                System.debug('Error cloning record: ' + e.getMessage());
            }
        }
        return clonedIdList;
    }
}