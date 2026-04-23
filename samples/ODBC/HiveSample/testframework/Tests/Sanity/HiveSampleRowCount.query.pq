// Sanity / RowCount test
// Verifies that the customer table is accessible and returns a non-zero row count.
// Expected output (.pqout) is generated on the first run when FailOnMissingOutputFile = false.
(parameter) =>
let
    RowCount = Table.RowCount(parameter)
in
    RowCount
