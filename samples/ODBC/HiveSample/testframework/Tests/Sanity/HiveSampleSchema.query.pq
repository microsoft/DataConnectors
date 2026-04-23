// Sanity / Schema test
// Verifies the column names and their M-type kinds for the customer table.
// The resulting schema table is stable across data changes, making it a reliable
// regression baseline for connector schema evolution.
// Expected output (.pqout) is generated on the first run when FailOnMissingOutputFile = false.
(parameter) =>
let
    Schema      = Table.Schema(parameter),
    NameAndKind = Table.SelectColumns(Schema, {"Name", "Kind"}),
    Sorted      = Table.Sort(NameAndKind, {{"Name", Order.Ascending}})
in
    Sorted
