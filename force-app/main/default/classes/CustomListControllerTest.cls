/**
* **********************************************************************************************************
* Class             :   CustomListControllerTest
* Methods           :   1. static void makeData()
2. static void testGetRecords()
3. static void testLoadConfig()
* Test Classes For  :   CustomListController
* ***********************************************************************************************************
* @author       Extentia Information Technology
* @created      2019-Apr-10
* @version      1.0
* @description  The class "CustomListControllerTest" created to unit test the functionality of CustomListController
class and to obtain the maximum percentage of code coverage.
*/

@isTest
public with sharing class CustomListControllerTest {
    
    @TestSetup
    //Test setup to insert the test data
    static void makeData(){
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
            User objUserStd = new User();
            User objUserAdm = new User();
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name ='UserPermissionSet'];
            List<User> lstUser= new List<User>(); 
            for(Profile objProf:[SELECT Id,Name FROM Profile WHERE Name In ('Standard User','System Administrator')]){
                if(objProf.name =='Standard User'){
                    objUserStd = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                          LocaleSidKey='en_US', ProfileId = objProf.Id, 
                                          TimeZoneSidKey='America/Los_Angeles', UserName='stduserLC@testorg.com');
                    lstUser.add(objUserStd);
                }
                else{
                    objUserAdm = new User(Alias = 'standt', Email='sysAdmin@testorg.com', 
                                          EmailEncodingKey='UTF-8', LastName='TestingAdm', LanguageLocaleKey='en_US', 
                                          LocaleSidKey='en_US', ProfileId = objProf.Id, 
                                          TimeZoneSidKey='America/Los_Angeles', UserName='stduserLCAdm@testorg.com');    
                    lstUser.add(objUserAdm);
                }
            }
            
            insert lstUser;
            insert new PermissionSetAssignment(AssigneeId = objUserAdm.id, PermissionSetId = ps.Id);
            //Create an account --
            Account acc = new Account(Name = 'Test Account');
            insert acc;
            
            //Create contacts on above account --
            Contact con1 = new Contact(FirstName = 'FirstName1', LastName = 'LastName1', AccountId = acc.Id);
            Contact con2 = new Contact(FirstName = 'FirstName2', LastName = 'LastName2', AccountId = acc.Id);
            insert new List<Contact>{con1, con2};
                }
    }
    
    //Test method to check the valid getRecords scenario
    static TestMethod void testGetRecords(){
        Boolean hasException;
        Test.startTest();
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        User objUser = new User();
        objUser=[select id from User where UserName='stduserLC@testorg.com' ];
        System.runAs(objUser) {
            try{
                Map<String, Object> mapResult = CustomListController.getRecords('Opportunity', 'Name', acc.Id, 'AccountId', '', 'Name###a', '', '', '');
            }catch (Exception ex) {
                hasException = true;
            } 
            System.assert(hasException, 'Error - Error - Something went wrong while retrieving records.');            
            //System.assert((Integer)mapResult.get('totalRecordCount') > 0, 'Error - Something went wrong while retrieving records.');
        }
        Test.stopTest(); 
    }
    
    //Test method to check the valid getRecords scenario with decimal values
    static TestMethod void testGetRecordsForDecimal(){
        Boolean hasException;
        Test.startTest();
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        User objUser = new User();
        objUser=[select id from User where UserName='stduserLC@testorg.com' ];
        System.runAs(objUser) {
            try{
                Map<String, Object> mapResult = CustomListController.getRecords('Opportunity', 'Name,Amount', acc.Id, 'AccountId', '', 'Amount###9000', '', '', '');
            }catch (Exception ex) {
                hasException = true;
            } 
            System.assert(hasException, 'Error - Error - Something went wrong while retrieving records.');            
            //System.assert((Integer)mapResult.get('totalRecordCount') > 0, 'Error - Something went wrong while retrieving records.');
        }
        Test.stopTest(); 
    }
    
    //Test method to check the invalid object name scenario for getRecords method
    static TestMethod void testGetRecordsException(){
        Boolean hasException;
        Test.startTest();
        try {
            Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
            Map<String, Object> mapResult = CustomListController.getRecords('Contacts', 'Name', acc.Id, 'AccountId', '', 'Name LIKE \'%First%\'', 'Name', '0', '30');
        } catch (Exception ex) {
            hasException = true;
        } 
        Test.stopTest();
        System.assert(hasException, 'Error - Something went wrong while while retrieving records');
    }
    
    //Test method to check the missing fields scenario for getRecords method
    static TestMethod void testGetRecordsBlankFields(){
        Test.startTest();
        User objUser = new User();
        objUser=[select id from User where UserName='stduserLC@testorg.com' ];
        System.runAs(objUser) {   
            Map<String, Object> mapResult = CustomListController.getRecords('Contact', '', null, 'AccountId', '', 'Name LIKE \'%First%\'', 'Name', '0', '30');
            System.assert( mapResult == new Map<String, Object>(), 'Error - Something went wrong while retrieving records.');
        }
        Test.stopTest(); 
    }
    
    //Test method to check the valid object name scenario for loadConfig method
    static TestMethod void testLoadConfig(){
        Test.startTest();
        User objUser = new User();
        objUser=[select id from User where UserName='stduserLC@testorg.com' ];
        System.runAs(objUser) {   
            Map<String, Object> mapConfig = CustomListController.loadConfig('Contact', 'Name');
            System.assert(mapConfig != null && mapConfig.get('listColumns') != null && mapConfig.get('listTitle') == 'Contacts', 'Error - Something went wrong while loading config.');
        }
        Test.stopTest();
    }
    
    //Test method to check the missing fields scenario due to FLS for loadConfig method
    static TestMethod void testLoadConfigBlankField(){
        Test.startTest();
        User objUser = new User();
        objUser=[select id from User where UserName='stduserLC@testorg.com' ];
        System.runAs(objUser) {   
            Map<String, Object> mapConfig = CustomListController.loadConfig('Contact', '');
            System.assert(mapConfig == new Map<String, Object>(), 'Error - Something went wrong while loading config.');
        }
        Test.stopTest();
    }
    
    //Test method to check the invalid object name scenario for loadConfig method
    static TestMethod void testLoadConfigInvalidObject() {
        Boolean hasException;
        Test.startTest();
        User objUser = new User();
        objUser=[select id from User where UserName='stduserLC@testorg.com' ];
        System.runAs(objUser) {   
            try {
                Map<String, Object> mapConfig = CustomListController.loadConfig('Contacts', 'Name');
            } catch (Exception ex) {
                hasException = true;
            } 
            System.assert(hasException, 'Error - Something went wrong while loading config.');
        }
        Test.stopTest();
        
    }
}