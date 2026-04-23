// Mock parameter query for offline SDK test runs (no ODBC dependency).
// Returns a customer table with the same core schema used by tests.
let
    Customer = Table.FromRecords({
        [customer_id = 1, first_name = "Alice", last_name = "Johnson", city = "New York", state = "NY"],
        [customer_id = 2, first_name = "Bob", last_name = "Smith", city = "Los Angeles", state = "CA"],
        [customer_id = 3, first_name = "Carol", last_name = "Williams", city = "Chicago", state = "IL"],
        [customer_id = 4, first_name = "David", last_name = "Brown", city = "Houston", state = "TX"],
        [customer_id = 5, first_name = "Eve", last_name = "Davis", city = "Phoenix", state = "AZ"]
    })
in
    Customer
