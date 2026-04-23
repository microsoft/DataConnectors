// HiveSample Unit Tests
// Uses the idiomatic Fact / Facts.Summarize pattern from the official Power Query
// unit-testing sample: https://learn.microsoft.com/en-us/power-query/handling-unit-testing
//
// To test the REAL connector replace MockDatabase below with:
//   HiveSample.Contents("127.0.0.1", 10500)
let
    // =========================================================================
    // MOCK DATA
    // =========================================================================
    MockCustomerTable = Table.FromRecords({
        [customer_id = 1, first_name = "Alice", last_name = "Johnson", city = "New York",    state = "NY"],
        [customer_id = 2, first_name = "Bob",   last_name = "Smith",   city = "Los Angeles", state = "CA"],
        [customer_id = 3, first_name = "Carol", last_name = "Williams",city = "Chicago",     state = "IL"],
        [customer_id = 4, first_name = "David", last_name = "Brown",   city = "Houston",     state = "TX"],
        [customer_id = 5, first_name = "Eve",   last_name = "Davis",   city = "Phoenix",     state = "AZ"]
    }),
    MockSalesTable = Table.FromRecords({
        [sale_id = 101, customer_id = 1, amount = 150.50, sale_date = "2024-01-15"],
        [sale_id = 102, customer_id = 2, amount = 200.00, sale_date = "2024-01-16"],
        [sale_id = 103, customer_id = 1, amount =  75.25, sale_date = "2024-01-17"],
        [sale_id = 104, customer_id = 3, amount = 300.00, sale_date = "2024-01-18"],
        [sale_id = 105, customer_id = 2, amount = 120.75, sale_date = "2024-01-19"]
    }),
    MockProductTable = Table.FromRecords({
        [product_id = 1, product_name = "Widget A", category = "Electronics", price = 29.99],
        [product_id = 2, product_name = "Widget B", category = "Electronics", price = 49.99],
        [product_id = 3, product_name = "Gadget X", category = "Accessories", price = 15.99]
    }),
    MockSampleTable = Table.FromRecords({
        [id = 1, name = "Sample1", value = 100],
        [id = 2, name = "Sample2", value = 200],
        [id = 3, name = "Sample3", value = 300]
    }),
    MockFoodmartSchema = Table.FromRecords({
        [Name = "customer",   Kind = "Table", Data = MockCustomerTable],
        [Name = "sales_fact", Kind = "Table", Data = MockSalesTable],
        [Name = "product",    Kind = "Table", Data = MockProductTable]
    }),
    MockDefaultSchema = Table.FromRecords({
        [Name = "sample_table", Kind = "Table", Data = MockSampleTable]
    }),
    MockHiveSchema = Table.FromRecords({
        [Name = "foodmart", Kind = "Schema", Data = MockFoodmartSchema],
        [Name = "default",  Kind = "Schema", Data = MockDefaultSchema]
    }),
    MockDatabase = Table.FromRecords({
        [Name = "HIVE",     Kind = "Database", Data = MockHiveSchema],
        [Name = "OTHER_DB", Kind = "Database", Data = #table({"Name"}, {})]
    }),

    // =========================================================================
    // FACTS (tests)
    // Fact(<name>, <expected>, <actual>)
    // =========================================================================
    facts = {
        // Schema navigation returns the customer table with 5 rows
        Fact("BasicQuery: customer table has 5 rows",
            5,
            Table.RowCount(
                MockDatabase
                    {[Name = "HIVE",     Kind = "Database"]}[Data]
                    {[Name = "foodmart", Kind = "Schema"]}[Data]
                    {[Name = "customer", Kind = "Table"]}[Data]
            )
        ),
        // Filter by state = "CA" returns exactly 1 row (Bob)
        Fact("FilteredQuery: state = CA returns 1 row",
            1,
            Table.RowCount(Table.SelectRows(MockCustomerTable, each [state] = "CA"))
        ),
        // Customer 1 has two sales totalling 225.75
        Fact("Aggregation: customer 1 total sales = 225.75",
            225.75,
            Table.Group(MockSalesTable, {"customer_id"},
                {{"total_sales", each List.Sum([amount]), type number}})
                    {[customer_id = 1]}[total_sales]
        ),
        // Joined table has 5 customer columns + 1 nested "sales" column = 6
        Fact("Join: result has 6 columns",
            6,
            List.Count(Table.ColumnNames(
                Table.NestedJoin(MockCustomerTable, {"customer_id"},
                    MockSalesTable, {"customer_id"}, "sales")
            ))
        ),
        // Column selection keeps only the 3 requested columns
        Fact("ColumnSelection: result has 3 columns",
            3,
            List.Count(Table.ColumnNames(
                Table.SelectColumns(MockCustomerTable, {"customer_id", "first_name", "last_name"})
            ))
        )
    },

    // =========================================================================
    // UNIT TESTING FRAMEWORK
    // Source: https://github.com/Microsoft/DataConnectors/tree/master/samples/UnitTesting
    // =========================================================================
    ValueToText = (value, optional depth) =>
        let
            List.TransformAndCombine = (list, transform, separator) =>
                Text.Combine(List.Transform(list, transform), separator),
            Serialize.List = (x) => "{" & List.TransformAndCombine(x, Serialize, ", ") & "} ",
            Serialize.Record = (x) =>
                "[ "
                & List.TransformAndCombine(
                    Record.FieldNames(x),
                    (item) => Serialize.Identifier(item) & " = " & Serialize(Record.Field(x, item)),
                    ", "
                )
                & " ] ",
            Serialize.Table = (x) =>
                "#table( type " & _serialize_table_type(Value.Type(x)) & ", "
                & Serialize(Table.ToRows(x)) & ") ",
            Serialize.Identifier = Expression.Identifier,
            Serialize.Type = (x) => "type " & _serialize_typename(x),
            _serialize_typename = (x, optional funtype as logical) =>
                let
                    isFunctionType = (x as type) =>
                        try if Type.FunctionReturn(x) is type then true else false otherwise false,
                    isTableType = (x as type) =>
                        try if Type.TableSchema(x) is table then true else false otherwise false,
                    isRecordType = (x as type) =>
                        try if Type.ClosedRecord(x) is type then true else false otherwise false,
                    isListType = (x as type) =>
                        try if Type.ListItem(x) is type then true else false otherwise false
                in
                    if funtype = null and isTableType(x) then _serialize_table_type(x)
                    else if funtype = null and isListType(x) then "{ " & @_serialize_typename(Type.ListItem(x)) & " }"
                    else if funtype = null and isFunctionType(x) then "function " & _serialize_function_type(x)
                    else if funtype = null and isRecordType(x) then _serialize_record_type(x)
                    else if x = type any then "any"
                    else
                        let base = Type.NonNullable(x)
                        in (if Type.IsNullable(x) then "nullable " else "")
                            & (if base = type anynonnull then "anynonnull"
                               else if base = type binary    then "binary"
                               else if base = type date      then "date"
                               else if base = type datetime  then "datetime"
                               else if base = type datetimezone then "datetimezone"
                               else if base = type duration  then "duration"
                               else if base = type logical   then "logical"
                               else if base = type none      then "none"
                               else if base = type null      then "null"
                               else if base = type number    then "number"
                               else if base = type text      then "text"
                               else if base = type time      then "time"
                               else if base = type type      then "type"
                               else if base = type function  then "function"
                               else if base = type table     then "table"
                               else if base = type record    then "record"
                               else if base = type list      then "list"
                               else "any /*unknown*/"),
            _serialize_table_type = (x) =>
                let schema = Type.TableSchema(x)
                in "table "
                    & (if Table.IsEmpty(schema) then ""
                       else "["
                            & List.TransformAndCombine(
                                Table.ToRecords(Table.Sort(schema, "Position")),
                                each Serialize.Identifier(_[Name]) & " = " & _[Kind],
                                ", ")
                            & "] "),
            _serialize_record_type = (x) =>
                let flds = Type.RecordFields(x)
                in if Record.FieldCount(flds) = 0 then "record"
                   else "["
                        & List.TransformAndCombine(
                            Record.FieldNames(flds),
                            (item) => Serialize.Identifier(item) & "=" & _serialize_typename(Record.Field(flds, item)[Type]),
                            ", ")
                        & (if Type.IsOpenRecord(x) then ", ..." else "") & "]",
            _serialize_function_type = (x) =>
                _serialize_function_param_type(Type.FunctionParameters(x), Type.FunctionRequiredParameters(x))
                & " as " & _serialize_function_return_type(x),
            _serialize_function_param_type = (t, n) =>
                let funsig = Table.ToRecords(
                        Table.TransformColumns(
                            Table.AddIndexColumn(Record.ToTable(t), "isOptional", 1),
                            {"isOptional", (x) => x > n}))
                in "("
                    & List.TransformAndCombine(
                        funsig,
                        (item) => (if item[isOptional] then "optional " else "")
                                    & Serialize.Identifier(item[Name])
                                    & " as " & _serialize_typename(item[Value], true),
                        ", ")
                    & ")",
            _serialize_function_return_type = (x) => _serialize_typename(Type.FunctionReturn(x), true),
            Serialize = (x) as text =>
                if x is binary   then try "#binary(...)" otherwise "null"
                else if x is date         then try Expression.Constant(x) otherwise "null"
                else if x is datetime     then try Expression.Constant(x) otherwise "null"
                else if x is datetimezone then try Expression.Constant(x) otherwise "null"
                else if x is duration     then try Expression.Constant(x) otherwise "null"
                else if x is function     then try "(function)" otherwise "null"
                else if x is list         then try Serialize.List(x) otherwise "null"
                else if x is logical      then try Expression.Constant(x) otherwise "null"
                else if x is null         then try Expression.Constant(x) otherwise "null"
                else if x is number       then try Expression.Constant(x) otherwise "null"
                else if x is record       then try Serialize.Record(x) otherwise "null"
                else if x is table        then try Serialize.Table(x) otherwise "null"
                else if x is text         then try Expression.Constant(x) otherwise "null"
                else if x is time         then try Expression.Constant(x) otherwise "null"
                else if x is type         then try Serialize.Type(x) otherwise "null"
                else "[#_unable_to_serialize_#]"
        in
            try Serialize(value) otherwise "<serialization failed>",

    Fact = (_subject as text, _expected, _actual) as record =>
        [
            expected      = try _expected,
            safeExpected  = if expected[HasError] then "Expected : " & @ValueToText(expected[Error]) else expected[Value],
            actual        = try _actual,
            safeActual    = if actual[HasError]   then "Actual : "   & @ValueToText(actual[Error])   else actual[Value],
            attempt       = try safeExpected = safeActual,
            result        = if attempt[HasError] or not attempt[Value] then "Failure " & Character.FromNumber(9940) else "Success " & Character.FromNumber(10003),
            resultOp      = if result = "Success " & Character.FromNumber(10003) then " = " else " <> ",
            addendumEvalAttempt  = if attempt[HasError] then @ValueToText(attempt[Error]) else "",
            addendumEvalExpected = try @ValueToText(safeExpected) otherwise "...",
            addendumEvalActual   = try @ValueToText(safeActual)   otherwise "...",
            fact = [
                Result  = result & " " & addendumEvalAttempt,
                Notes   = _subject,
                Details = " (" & addendumEvalExpected & resultOp & addendumEvalActual & ")"
            ]
        ][fact],

    Facts.Summarize = (_facts as list) as table =>
        [
            Fact.CountSuccesses = (count, i) =>
                [
                    result = try i[Result],
                    sum    = if result[HasError] or not Text.StartsWith(result[Value], "Success") then count else count + 1
                ][sum],
            passed = List.Accumulate(_facts, 0, Fact.CountSuccesses),
            total  = List.Count(_facts),
            format = if passed = total then "All #{0} Passed !!! " & Character.FromNumber(10003) else "#{0} Passed  #{1} Failed",
            result = if passed = total then "Success" else "Failure " & Character.FromNumber(9940),
            rate   = Number.IntegerDivide(100 * passed, total),
            header = [
                Result  = result,
                Notes   = Text.Format(format, {passed, total - passed}),
                Details = Text.Format("#{0}% success rate", {rate})
            ],
            report = Table.FromRecords(List.Combine({{header}, _facts}))
        ][report]

in
    Facts.Summarize(facts)
