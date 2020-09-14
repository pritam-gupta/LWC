@isTest
private class Test4_Test {
    
    @isTest static void myTest() {
        List<Contact> conList= new List<Contact>();
        
        for(Integer i=0;i<10;i++){
            Contact con = new Contact(LastName='Test Contact'+i,MailingCity='Sydney');
            conList.add(con);
        }
        insert conList;
        Test.startTest();    
      		Test4 tes= new Test4(conList);
        Test.stopTest();
    }
    
}