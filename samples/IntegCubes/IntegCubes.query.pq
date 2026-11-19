// Test query for IntegCubes Power BI Connector
let
    // Calls the connector with default or custom parameters
    result = IntegCubes.Contents("https://api.integcubes.com/v1", "All Products (MediCube & Quantus)")
in
    result
