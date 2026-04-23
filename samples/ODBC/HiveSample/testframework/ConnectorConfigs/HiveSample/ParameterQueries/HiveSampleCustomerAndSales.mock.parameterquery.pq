// Mock parameter query for offline SDK test runs (no ODBC dependency).
// Returns both customer and sales_fact tables as a record for join tests.
let
    Customer = Table.FromRecords({
        [customer_id = 1, first_name = "Alice", last_name = "Johnson", city = "New York", state = "NY"],
        [customer_id = 2, first_name = "Bob", last_name = "Smith", city = "Los Angeles", state = "CA"],
        [customer_id = 3, first_name = "Carol", last_name = "Williams", city = "Chicago", state = "IL"],
        [customer_id = 4, first_name = "David", last_name = "Brown", city = "Houston", state = "TX"],
        [customer_id = 5, first_name = "Eve", last_name = "Davis", city = "Phoenix", state = "AZ"]
    }),
    Sales = Table.FromRecords({
        [sale_id = 101, customer_id = 1, amount = 150.50, sale_date = "2024-01-15"],
        [sale_id = 102, customer_id = 2, amount = 200.00, sale_date = "2024-01-16"],
        [sale_id = 103, customer_id = 1, amount = 75.25, sale_date = "2024-01-17"],
        [sale_id = 104, customer_id = 3, amount = 300.00, sale_date = "2024-01-18"],
        [sale_id = 105, customer_id = 2, amount = 120.75, sale_date = "2024-01-19"]
    })
in
    [CustomerTable = Customer, SalesTable = Sales]
