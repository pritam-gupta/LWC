/**
* **********************************************************************************************************
* Class         :   CustomListController
* Methods       :   1. public static List<sObject> getRecords()
                    2. public static Map<String, Object> loadConfig()
* Test Classes  :   CustomListControllerTest
* ***********************************************************************************************************
* @author       Extentia Information Technology
* @created      2019-Apr-10
* @version      1.0
* @description  The class "CustomListController" refers to the 'customList' lightning web component. It performs 
                operation for this component such as loading config(list title, preparing list of columns), 
                retrieving records, etc. to show the records in the related lists.
*/
public with sharing class CustomListController {

    public static final String STR_SELECT   = 'SELECT ';
    public static final String STR_FROM     = ' FROM ';
    public static final String STR_WHERE    = ' WHERE ';
    public static final String STR_AND      = ' AND ';
    public static final String STR_ORDER_BY = ' ORDER BY ';
    public static final String STR_LIMIT    = ' LIMIT ';
    public static final String STR_OFFSET   = ' OFFSET ';
    public static final String STR_COUNT    = ' COUNT() ';
    public static final String STR_NO_READ  = 'No read access to the ';

    /**
    * @description  The method 'getRecords' return the subset of records of the related list by applying filters specified.
                    The records will be sorted if default sort field is opted.
    * @param        String objApi - Object api name for which you want to fetch the records to show in related list.
    * @param        String fields - comma separated api names of fields that you want to show as columns in related list.
    * @param        Id relatedId - Id of the related record on which related list component is placed.
    * @param        String relatedField - Related object's field api name.
    * @param        String filterLogic - The WHERE clause to filter out the records of the related list. Excluded 'WHERE'.
    * @param        String searchTerm - The search text on selected field by user to search the records in related list.
    * @param        String orderBy - The field's api name by which records will be sorted initially.
    * @param        String offset - Use offset to specify the starting row offset into the result set returned by your query.

    * @return       Map<String, Object> - Map of result which contains the subset of records of related list and total number of records.
    */
    @AuraEnabled(Cacheable=true)
    public static Map<String, Object> getRecords(String objApi, String fields, Id relatedId, String relatedField, String filterLogic, String searchTerm, String orderBy, String offset, String limitSize) {

        Map<String, Object> mapResult = new Map<String, Object>();

        if( String.isBlank(fields) ) {
            return mapResult;
        }

        try{
            String searchField ='',searchValue ='',newSearchTerm =''; // we are declaring variables 
            if(searchTerm!=null && searchTerm!=''){
            string[] searchTermVal  = searchTerm.split('###'); //serchterm contains searchfield and search value
            // assign values to searchfield and search value 
            searchField=searchTermVal[0];
            searchValue=searchTermVal[1];
            // we are getting the object details
            Schema.SObjectType t = Schema.getGlobalDescribe().get(objApi);
    
            Schema.DescribeSObjectResult r = t.getDescribe();
            // search field values will store in descriptionfieldresult
            Schema.DescribeFieldResult f = r.fields.getMap().get(searchField).getDescribe();
            //we aree getting the field type
            if(String.ValueOf(f.getType())=='CURRENCY' || String.ValueOf(f.getType())=='DECIMAL' || String.ValueOf(f.getType())=='INTEGER'){
                searchValue=searchValue.replaceAll(',','');
                searchValue=searchValue.replace('$','');
                //search value is numeric or not
                if(searchValue.isNumeric()){
                    newSearchTerm=searchField + ' >= ' + searchValue;
                }
                
            }
            else{
                newSearchTerm=searchField + ' LIKE \'%' + searchValue + '%\'';
            }
        }
            //Set the order by clause --
            String orderByClause = String.isNotBlank(orderBy) ? STR_ORDER_BY + orderBy : '';
            //Set where clause with filter logic and search term --
            String whereClause = STR_WHERE + relatedField + ' = \'' + relatedId + '\'';
            whereClause += String.isNotBlank(filterLogic) ? STR_AND + filterLogic : '';
            whereClause += String.isNotBlank(newSearchTerm) ? STR_AND + newSearchTerm : '';

            //Retrieve the records and set it in the map of result --
            String strQuery = STR_SELECT + 'Id, ' + String.escapeSingleQuotes(fields) + STR_FROM + String.escapeSingleQuotes(objApi) + whereClause + orderByClause + STR_LIMIT + limitSize + STR_OFFSET + offset;
 
            mapResult.put('records', Database.query(strQuery));

            //Count the total number of records and set it in the map of result --
            String strCountQuery = STR_SELECT + STR_COUNT + STR_FROM + objApi + whereClause;
            mapResult.put('totalRecordCount', Database.countQuery(strCountQuery));

        } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        return mapResult;
    }

    /**
    * @description  The method 'loadConfig' return the map of configurations required to display the records in related list table.
                    The configuration contains list of columns with their types, list of searchable fields, default title for related list.
    * @param        String objApi - Object api name for which you want to fetch the records to show in related list.
    * @param        String fields - comma separated api names of fields that you want to show as columns in related list.
    * 
    * @return       Map<String, Object> - Map of result which contains the configurations mentioned in description.
    */
    @AuraEnabled(Cacheable=true)
    public static Map<String, Object> loadConfig(String objApi, String fields) {

        Schema.DescribeSObjectResult[] descResult;
        Map<String, Object> mapConfig = new Map<String, Object>();

        if( String.isBlank(fields) ) {
            return mapConfig;
        }

        try{
            //Get the object schema and all its field map --
            descResult = Schema.describeSObjects( new String[]{ objApi } );
            Map<String, Schema.SObjectField> fieldMap = descResult[0].fields.getMap();
            Set<String> setFields = new Set<String>(fields.split(','));
            for( String field : setFields ) {
                field = field.trim();
                Schema.DescribeFieldResult dfr = fieldMap.get(field).getDescribe();
            }
        } catch(Exception ex) {
            throw new AuraHandledException('Please check the API names for the related list object and fields in the object record page>component configuration.');
        }

        if( false== descResult[0].isAccessible() ) {
            throw new AuraHandledException( STR_NO_READ + objApi + ' object.' );
        }

        try {
            List<AccessAction> accessActionList = new List<AccessAction>();

            mapConfig.put( 'isCreateable', descResult[0].isCreateable() );

            accessActionList.add( new AccessAction('View', 'view', 'utility:preview') );

           if( true == descResult[0].isUpdateable() ) {
                accessActionList.add( new AccessAction('Edit', 'edit', 'utility:edit') );
           }

           if( true == descResult[0].isDeletable() ) {
                accessActionList.add( new AccessAction('Delete', 'delete', 'utility:delete') );
           }

            Map<String, Schema.SObjectField> mapFields = descResult[0].fields.getMap();

            //Set custom list label --
            mapConfig.put( 'listTitle', descResult[0].getLabelPlural() );

            List<ColumnDetails> lstColumns = new List<ColumnDetails>();
            List<String> lstSearchFields = new List<String>();
            Set<String> setFields = new Set<String>(fields.split(','));


            for( String field : setFields ) {
                field = field.trim();

                if( false == mapFields.containsKey( field.toLowerCase() ) 
                 || false == mapFields.get(field.toLowerCase()).getDescribe().isAccessible() ) {
                    setFields.remove(field);
                    continue;
                }

                String fieldType = (String.valueOf(mapFields.get(field.toLowerCase()).getDescribe().getType())).toLowerCase();
                //Prepare a list of columns in the form of { label: <label>, fieldName: <fieldName>, type: <type_of_field>, sortable: true } --

                lstColumns.add(new ColumnDetails(mapFields.get(field).getDescribe().getLabel(), field, fieldType, true));

                //Prepare list of searchable fields --
                if( !fieldType.containsIgnoreCase('date') && !fieldType.containsIgnoreCase('boolean')) {
                    lstSearchFields.add( '{ "label": "' + mapFields.get(field).getDescribe().getLabel() + '", "value": "' + field + '" }' );
                }
            }

            //Set the value of list of objects for columns
            mapConfig.put('listColumns', lstColumns);

            //Deserialize the list of strings to list of objects for searchable fields and set it in map of configurations --
            mapConfig.put('searchableFields', (List<Object>)JSON.deserializeUntyped('[' + String.join(lstSearchFields, ',') + ']') );

            //Deserialize the set of strings to list of objects for fields list and set it in map of configurations --
            mapConfig.put('listFilterFields', String.join(new List<String>(setFields), ',') );

            //Set the value of accessActionList to render the available CRUD options 
            mapConfig.put('accessActionList', accessActionList);

        } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        return mapConfig;
    }

    //Wrapper class for Access Action details 
    public class AccessAction {
        @AuraEnabled public String label;
        @AuraEnabled public String name;
        @AuraEnabled public String iconName;

        public AccessAction(String label, String name, String iconName) {
            this.label = label;
            this.name = name;
            this.iconName = iconName;
        }
    }

    //Wrapper class for Column Details to display in table
    public class ColumnDetails {
        @AuraEnabled public String label;
        @AuraEnabled public String fieldName;
        @AuraEnabled public String type;
        @AuraEnabled public Boolean sortable;

        public ColumnDetails(String label, String fieldName, String type, Boolean sortable) {
            this.label = label;
            this.fieldName = fieldName;
            this.type = type;
            this.sortable = sortable;
        }
    }
}



/*------------------------------------------------------------------------*/