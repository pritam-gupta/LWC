@isTest
private class Test2_Test {
    
    @isTest static void myTest() {
        Account acc = new Account();
        acc.Name='Test Name';
        acc.BillingCity='Test city';
        insert acc;
        
        List<Contact> conList= new List<Contact>();
       
        Contact cont1 = new Contact(LastName='test contact1',AccountId = acc.id,MailingCity = acc.BillingCity);
        Contact cont2 = new Contact(LastName='test contact2',AccountId = acc.id,MailingCity = acc.BillingCity);
        conList.add(cont1);
        conList.add(cont2);
        insert conList;
        
        Test.startTest();    
      		acc.Name='Test Account 2';
        	update acc;
        Test.stopTest();
        
        List<Account> accList=[Select MatchingCity__c from Account where Id=:acc.Id ];
        System.assertEquals(2,accList[0].MatchingCity__c);
    }
}