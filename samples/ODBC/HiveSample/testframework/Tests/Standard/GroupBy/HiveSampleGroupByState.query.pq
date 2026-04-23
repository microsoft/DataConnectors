// Standard / GroupBy test
// Groups customers by state and counts the number of customers in each state.
// For ODBC connectors this should fold to:
//   SELECT state, COUNT(*) AS customer_count FROM customer GROUP BY state ORDER BY state ASC
// Expected output (.pqout) is generated on the first run when FailOnMissingOutputFile = false.
(parameter) =>
let
    Grouped = Table.Group(
        parameter,
        {"state"},
        {{"customer_count", each Table.RowCount(_), Int64.Type}},
        GroupKind.Global
    ),
    Sorted = Table.Sort(Grouped, {{"state", Order.Ascending}})
in
    Sorted
