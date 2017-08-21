section UnitTestingUnitTests;

shared MyExtension.UnitTest =
[
    // Put any common variables here if you only want them to be evaluated once

    // Fact(<Name of the Test>, <Expected Value>, <Actual Value>)
    facts =
    {        
        Fact("Check that this function returns 'ABC'",  // name of the test
             "ABC",                                     // expected value
             UnitTesting.ReturnsABC()                   // expression to evaluate (let or single statement)
        ),
        Fact("Check that this function returns '123'",
             "124",                                   
             UnitTesting.Returns123()
        ),
        Fact("Result should contain 5 rows",
            5,
            Table.RowCount(UnitTesting.ReturnsTableWithFiveRows())
        ),
        Fact("Values should be equal (using a let statement)",
            "Hello World",
            let
                a = "Hello World"
            in
                a
        )
    },

    report = Facts.Summarize(facts)
][report];

/// COMMON UNIT TESTING CODE 
ValueToText = (value, optional depth) =>
[
        nextDepth = if depth = null then 3 else depth - 1,
        result = if depth = 0 then "..."
            else if value is null then "null"
            else if value is text then """"& value & """"
            else if value is function then Record.FieldOrDefault(Value.Metadata(Value.Type(value)), "Documentation.Name", "<function>")
            else if value is table then "#table({" & Text.Combine(Table.ColumnNames(value), ",") & "},{" & Text.Combine(
                List.Transform(Table.ToRows(Table.FirstN(value, 2)), each @ValueToText(_, nextDepth)), "},#(cr)#(lf){") & "})"
                //& "Row Count (" & Number.ToText(Table.RowCount(value)) & ")"
            else if value is list then "{" & Text.Combine(List.Transform(List.FirstN(value, 10), each @ValueToText(_, nextDepth)), ",") & "}"
            else if value is record then "[" & Text.Combine(List.Transform(Record.FieldNames(value), each _ & "=" & @ValueToText(Record.Field(value, _), nextDepth)), ",") & "]"
            else if value is type then List.First(Table.Schema(#table({"type"}, {{value}}))[TypeName], "<type>")
            else Text.From(value),
        text = try result otherwise "<error converting to text>"
][text];

Fact = (_subject as text, _expected, _actual) as record =>
[   expected = try _expected,
    safeExpected = if expected[HasError] then "Expected : "& @ValueToText(expected[Error]) else expected[Value],
    actual = try _actual,
    safeActual = if actual[HasError] then "Actual : "& @ValueToText(actual[Error]) else actual[Value],
    attempt = try safeExpected = safeActual,
    result = if attempt[HasError] or not attempt[Value] then "Failure ⛔" else "Success ✓",
    resultOp = if result = "Success ✓" then " = " else " <> ",
    addendumEvalAttempt = if attempt[HasError] then @ValueToText(attempt[Error]) else "",
    addendumEvalExpected = try @ValueToText(safeExpected) otherwise "...",
    addendumEvalActual = try @ValueToText (safeActual) otherwise "...",
    fact =
    [   Result = result &" "& addendumEvalAttempt,
        Notes =_subject,
        Details = " ("& addendumEvalExpected & resultOp & addendumEvalActual &")"
    ]
][fact];

Facts = (_subject as text, _predicates as list) => List.Transform(_predicates, each Fact(_subject,_{0},_{1}));

Facts.Summarize = (_facts as list) as table =>
[   Fact.CountSuccesses = (count, i) =>
    [   result = try i[Result],
        sum = if result[HasError] or not Text.StartsWith(result[Value], "Success") then count else count + 1
    ][sum],
    passed = List.Accumulate(_facts, 0, Fact.CountSuccesses),
    total = List.Count(_facts),
    format = if passed = total then "All #{0} Passed !!! ✓" else "#{0} Passed ☺  #{1} Failed ☹",
    result = if passed = total then "Success" else "⛔",
    rate = Number.IntegerDivide(100*passed, total),
    header =
    [   Result = result,
        Notes = Text.Format(format, {passed, total-passed}),
        Details = Text.Format("#{0}% success rate", {rate})
    ],
    report = Table.FromRecords(List.Combine({{header},_facts}))
][report];
