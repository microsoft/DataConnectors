// Standard / Join test
// Inner-joins the customer table with the sales_fact table on customer_id,
// then projects a small, stable result set.
// For ODBC connectors this should fold to an INNER JOIN in the generated SQL.
//
// The parameter query (HiveSampleCustomerAndSales.parameterquery.pq) returns a record
// with two fields: CustomerTable and SalesTable.
// Expected output (.pqout) is generated on the first run when FailOnMissingOutputFile = false.
(parameter) =>
let
    CustomerTable = parameter[CustomerTable],
    SalesTable    = parameter[SalesTable],
    Joined = Table.Join(
        CustomerTable, {"customer_id"},
        SalesTable,    {"customer_id"},
        JoinKind.Inner
    ),
    Selected = Table.SelectColumns(Joined, {"customer_id", "first_name", "last_name", "sale_id", "amount"}),
    Sorted   = Table.Sort(Selected, {{"customer_id", Order.Ascending}, {"sale_id", Order.Ascending}}),
    FirstTen = Table.FirstN(Sorted, 10)
in
    FirstTen
