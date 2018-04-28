# Using Table.View to Implement Query Folding

> This content is still under development. Entries may contain partial content.

One of the most powerful capabilities of Power Query and the M Language is *Query Folding* (also referred to as query delegation, and predicate push-down). Query Folding allows the M Engine to push the transformations expressed in an M query to the source, in the source's native query language, resulting in more efficient data processing.

Data sources will support different levels of query capabilities. To provide a consistent data transformation experience, the M engine  compensates (i.e. does the processing locally) for transformations that cannot be sent to the source. It is the Data Connector's responsibility to report its capabilities to the engine, carving off the transformations it can handle, generating the appropriate query syntax, and letting the M Engine handle the remaining work. Data Connectors can implement query folding behavior through the `Table.View` function.

`Table.View` is used to override default handlers for query operations. Most handlers are optional, allowing a source to implement folding for the operations it supports. If a handler encounters a query expression it cannot handle, it can raise an error to have the M engine fall back to its default operation handler.

The sections below describe the handlers supported by `Table.View`.

## Required Handlers

The following handlers are required for any implementation of `Table.View`.

| Handler       | Function Signature                                    | Summary                                                                 |
|:--------------|:------------------------------------------------------|:------------------------------------------------------------------------|
|GetRows        |`() as table`                                          |(**Required**) Returns the table result. Always the last handler called.|
|GetType        |`() as type`                                           |(**Required**) Returns the M `type` of the table expected from `GetRows`.|

### GetRows

The `GetRows` handler returns the result of your data source function (i.e. a table). It is the final handler invoked, and should take into account all of the query state info set by the other handlers.

### GetType

The `GetType` handler returns the M table type of the result of the call to `GetRows`. In the most basic implementation, this handler would call [Value.Type()](https://msdn.microsoft.com/query-bi/m/value-type) over the result of `GetRows`.
Sources that can determine the schema of the result without evaluating the query (by using fixed metadata, or querying a metadata/schema service) would perform those operations in this handler.

> Note that returning `Value.Type(GetRows())` will result in `GetRows()` being invoked twice. If the type cannot be determined without invoking `GetRows()`, it is recommended the results are stored in a common variable. Please see the sample below for an example.

(TODO - sample)

## Basic Handlers

The following handlers can be implemented without handling M `RowExpression` values, and are generally easier for an extension to implement.

| Handler       | Function Signature                                    | Summary                                                                 |
|:--------------|:------------------------------------------------------|:------------------------------------------------------------------------|
|GetRowCount    |`() as number`                                         |Returns a `number`. Used as an optimization where count can be determined without a call to `GetRows`.| 
|OnDistinct     |`(columns as list)`                                    |Called when as a result of `Table.Distinct`. |
|OnRenameColumns|`(renames as list)`                                    |Called when renaming columns (`Table.RenameColumns`).|
|OnSelectColumns|`(columns as list)`                                    |Called when selecting specific columns. |
|OnSkip         |`(count as number)`                                    |Called when using `Table.Skip`.|
|OnSort         |`(order as list)`                                      |Called when table is sorted (`Table.Sort`).|
|OnTake         |`(count as number)`                                    |Called when limiting the number of rows being retrieved (`Table.FirstN`).|

### GetRowCount

Returns a number. The default handler for the `GetRowCount` operation would be to call `Table.RowCount` over `GetRows`. Override this handler if your source is able to calculate the total row count without evaluating the query. 

### OnDistinct

Receives a list of column names. The handler must ensure that rows with duplicate values for the specified columns should be removed (i.e. remaining rows are distinct). See [Table.Distinct](https://msdn.microsoft.com/en-us/query-bi/m/table-distinct).

### OnRenameColumns

Receives a list of lists, the same as the arguments to `Table.RenameColumns`. Each inner list has two `text` members - the first member is the old column name, and the second member is the new column name.

### OnSelectColumns

Receives a list of column names that the user has selected. See [Table.SelectColumns](https://msdn.microsoft.com/en-us/query-bi/m/table-selectcolumns).

### OnSkip

Receives a number indicating the number of rows that should be skipped from the result set. See [Table.Skip](https://msdn.microsoft.com/en-us/query-bi/m/table-skip).

### OnSort

Receives a list of records of type:

```
type [ Name = text, Order = Int16.Type ]
```
Where `Name` is the name of the column, and `Order` is equal to `Order.Ascending` or `Order.Descending`. See [Table.Sort](https://msdn.microsoft.com/en-us/query-bi/m/table-sort).

### OnTake

Receives a number indicating the maximum number of rows that should be returned from `GetRows`. See [Table.FirstN](https://msdn.microsoft.com/en-us/query-bi/m/table-firstn).

## Expression Handlers

The following handlers require processing M `RowExpression` values.

| Handler       | Function Signature                                    | Summary                                                                 |
|:--------------|:------------------------------------------------------|:------------------------------------------------------------------------|
|OnAddColumns   |`(constructors)`                                       |Called when adding a calculated column (`Table.AddColumn`).|
|OnGroup        |`(keys, aggregates)`                                   |Called for various aggregation transformations. |
|OnJoin         |`(joinSide, leftTable, rightTable, joinKeys, joinKind)`|Called when performing a join of two tables. |
|OnSelectRows   |`(selector)`                                           |Called when selecting rows based on an expression (`Table.SelectRows`). |

### OnAddColumns

### OnGroup

### OnJoin

### OnSelectRows

## Direct Query Handlers

The following handlers are required to enable Direct Query capabilities from an extension. Note that an extension can implement query folding without declaring full Direct Query support. Direct Query support should only be enabled if the majority of the Table.View handlers are implemented.

| Handler       | Function Signature                                    | Summary                                                                 |
|:--------------|:------------------------------------------------------|:------------------------------------------------------------------------|
|GetExpression  |`() as record`                                         |
|OnInvoke       |`(function, arguments, index)`                         |Called to determine Direct Query capabilities. |

### GetExpression

### OnInvoke
