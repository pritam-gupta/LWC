public with sharing class Test2 {
    public static void triggerAfterAccountsUpdate(Map<Id,Account> accountsUpdated) {
    
       for (Contact con : [SELECT Id,MailingCity,AccountId FROM Contact WHERE AccountId IN :accountsUpdated.keySet()]) {
 			Account ac  = accountsUpdated.get(con.AccountId);
 			if (ac.MatchingCity__c==null) { 
 				 ac.MatchingCity__c = 0;
            }
            if (con.MailingCity!=null && ac.BillingCity!=null && ac.BillingCity==con.MailingCity) {
 				ac.MatchingCity__c+=1;
            }
            
 		}
 
        //update accountsUpdated.values();//we dont have to update records in before update trigger.
 
    }
}