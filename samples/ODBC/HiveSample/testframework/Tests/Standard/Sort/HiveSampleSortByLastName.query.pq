// Standard / Sort test
// Sorts customer rows by last_name ascending and returns the first 5 rows.
// For ODBC connectors this should fold to: SELECT ... FROM customer ORDER BY last_name ASC LIMIT 5
// Expected output (.pqout) is generated on the first run when FailOnMissingOutputFile = false.
(parameter) =>
let
    Sorted   = Table.Sort(parameter, {{"last_name", Order.Ascending}}),
    FirstFive = Table.FirstN(Sorted, 5)
in
    FirstFive
