@isTest
private class Test5_Test {
    
    @isTest static void myTest1() {
        Account acc = new Account(Name='Test account');
		insert acc;
        Contact con = new Contact(FirstName='Test',LastName=' Contact');
		insert con;
        Test.startTest();
            Test5 obj= new Test5();
      		obj.processRecord(acc); 
        	obj.processRecord(con);
        Test.stopTest();
    }
    //test test class method will not pass since we cant update null value in mandatory field
    @isTest static void myTest2() {
        Account acc = new Account(Name='T');
		insert acc;
        Contact con = new Contact(LastName='T');
		insert con;
        Test.startTest();
            Test5 obj= new Test5();
      		obj.processRecord(acc);
        	obj.processRecord(con);
        Test.stopTest();
    }
    
}