// Standard / Filter test
// Applies a WHERE predicate to the customer table and verifies query folding.
// For ODBC connectors this should fold to: SELECT ... FROM customer WHERE state = 'CA'
// Expected output (.pqout) is generated on the first run when FailOnMissingOutputFile = false.
(parameter) =>
let
    Filtered = Table.SelectRows(parameter, each [state] = "CA")
in
    Filtered
