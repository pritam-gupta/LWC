public class Test5 {
    public void processRecord(SObject obj){
        
       
        Id recordId=obj.id;
        String objectName=String.ValueOf(recordId.getSObjectType());
        if(objectName=='Account' && ((String)obj.get('Name')).length()<2){
             SObject o1 = recordId.getSObjectType().newSObject(recordId);
             o1.put('Name', null);//if we update mandateory field with null then it will be error:"first error: REQUIRED_FIELD_MISSING, Required fields are missing: [Name]:" 
            update o1;
        }
        else if(objectName=='Contact' && ((String)obj.get('FirstName')+(String)obj.get('LastName')).length()<2 ) {
             SObject o1 = recordId.getSObjectType().newSObject(recordId);
             o1.put('LastName', null);//if we update mandateory field with null then it will be error:"first error: REQUIRED_FIELD_MISSING, Required fields are missing: [Name]:" 
            update o1;
        }
        
    }
}