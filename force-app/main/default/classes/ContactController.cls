public with sharing class ContactController {
    public ContactController() {

    }
    @AuraEnabled
    public static List<Contact> contactList(){
        List<Contact> conList= [Select Id,Name,Title from Contact];
        return conList;
    } 
}