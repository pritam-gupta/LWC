public with sharing class UtilityClass {
    public UtilityClass() {

    }
    @AuraEnabled(cacheable=true)
    public static Map<Integer,String> mapDemo(){
        Map<Integer,String>  testMap= new Map<Integer,String>();
        testMap.put(1,'Shalu Gupta');
        testMap.put(2,'Pritam Gupta');
        testMap.put(3,'Vikas Gupta');
        testMap.put(4,'Vishal Gupta');
        return testMap;
    }
    @AuraEnabled(cacheable=true)
    public static String testName(){
        return 'Test String';
    }
}