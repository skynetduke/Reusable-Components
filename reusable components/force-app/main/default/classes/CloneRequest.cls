public with sharing class CloneRequest {
    public CloneRequest() {
         // Constructor to handle WHERE Clause not used in the invocable method
         this.whereClause = this.whereClause != null ? String.escapeSingleQuotes(this.whereClause) : '';
    }
        @InvocableVariable(label='Source Record ID' required=true)
        public Id sourceRecordId;
        
        @InvocableVariable(label='Object API Name' required=true)
        public String objectApiName;

        @InvocableVariable(label='Related Object API Name' required=true)
        public String relatedObjectApiName;
    
        @InvocableVariable(label='Parent Field API Name' required=true)
        public String parentField;
    
        @InvocableVariable(label='WHERE Clause')
        public String whereClause;
        
}
