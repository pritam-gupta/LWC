public class Test4 {
    public Test4(List<Contact> conList){
        if(conList!=null && conList.size()>0){
           for (Integer i = (conList.size()-1) ; i>= 0 ; i--){   
                processRecords(conList[i].Id);//The reason why sObjects can’t be passed as arguments to future methods is because the sObject might change between the time you call the method and the time it executes. In this case, the future method will get the old sObject values and might overwrite them. 
   				conList.remove(i);
                
            }
        }
    }

    @future
    public static void processRecords(Id recordId)
    {   
         // Get those records based on the IDs
         List<Contact> conList = [SELECT Name FROM Contact WHERE Id=:recordId LIMIT 1];
         if(conList!=null && conList.size()>0){
            conList[0].MailingCity='Melbourne';
             update conList;
         }
         
    }
}