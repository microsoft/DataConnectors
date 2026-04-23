// Standard / Select test
// Projects a subset of columns from the customer table.
// For ODBC connectors this should fold to: SELECT customer_id, first_name, last_name FROM customer
// Expected output (.pqout) is generated on the first run when FailOnMissingOutputFile = false.
(parameter) =>
let
    Selected = Table.SelectColumns(parameter, {"customer_id", "first_name", "last_name"})
in
    Selected
