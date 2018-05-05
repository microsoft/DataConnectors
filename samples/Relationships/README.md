# Relationships Sample

This sample demonstrates the declaration of table relationships that will be detected
by Power BI Desktop. The sample connector has three functions:

## Relationships.None

Returns a simple navigation table, with no relationships defined. 

## Relationships.Nested

Returns a navigation table with relationships defined on the `Orders` table.
The relationships are created using the `Table.NestedJoin` function. The joined columns
are left on the `Orders` table, making it easier for the user to expand the related tables
inline. This approach similuates the navigation properties that the Power Query experience
adds for sources with built-in relationship discovery, such as OData and SQL Server.

## Relationships.Implicit

Returns a navigation table with relationships defined on the `Orders` table.
The relationships are created using the `Table.NestedJoin` function, but the join columns
are removed from the result. This version demonstrates that even though the join columns are
removed, the relationships are maintained.

## Testing

1. Load the connector in Power BI Desktop
2. Find one of the "Relationships" functions in the Get Data dialog
3. Import all tables from the navigation table 
4. View the relationships tab in Power BI Desktop

