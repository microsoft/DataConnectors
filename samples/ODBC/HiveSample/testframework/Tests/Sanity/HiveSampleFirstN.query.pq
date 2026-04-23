// Sanity / FirstN test
// Verifies the connector can read at least one record from the customer table.
// Expected output (.pqout) is generated on the first run when FailOnMissingOutputFile = false.
(parameter) =>
let
    FirstRow = Table.FirstN(parameter, 1)
in
    FirstRow
