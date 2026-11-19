// IntegCubes Power BI Custom Connector
// Built for IntegCubes (MediCube & Quantus Solutions)
// Features: Dual-Mode (Demo/Mock & Live API), Dynamic Navigation, Auto-Typing, and Auto-Packaging

[Version = "1.1.0"]
section IntegCubes;

// ==========================================
// 1. MAIN CONNECTOR ENTRY POINT
// ==========================================
[DataSource.Kind="IntegCubes", Publish="IntegCubes.Publish"]
shared IntegCubes.Contents = Value.ReplaceType(IntegCubesImpl, IntegCubesType);

// UI Type Definition with Dynamic Documentation & Dropdowns
IntegCubesType = type function (
    optional mode as (type text meta [
        Documentation.FieldCaption = "Connection Mode",
        Documentation.FieldDescription = "Select Demo/Mock Mode to test immediately with realistic data, or Live API to connect to your real server.",
        Documentation.AllowedValues = {"Demo / Mock Data Mode (Instant Test)", "Live API Server"}
    ]),
    optional baseUrl as (type text meta [
        Documentation.FieldCaption = "IntegCubes API / Server URL (Live Mode)",
        Documentation.FieldDescription = "Base URL of IntegCubes Server (only used when Live API Server mode is chosen)",
        Documentation.SampleValues = {"https://api.integcubes.com/v1", "http://localhost:8000"}
    ]),
    optional product as (type text meta [
        Documentation.FieldCaption = "Product View Filter",
        Documentation.FieldDescription = "Filter navigation to MediCube, Quantus, or show All Products",
        Documentation.AllowedValues = {"All Products (MediCube & Quantus)", "MediCube Only", "Quantus Only"}
    ])
) as table meta [
    Documentation.DisplayName = "IntegCubes Data Platform",
    Documentation.Description = "Connects dynamically to IntegCubes to explore MediCube IoT/telemetry and Quantus KPI/analytics data in Power BI.",
    Documentation.LongDescription = "IntegCubes connector provides seamless access to MediCube and Quantus product datasets with instant Demo/Mock mode, automated schema typing, and live REST API integration."
];

// Implementation of the Entry Point
IntegCubesImpl = (optional mode as text, optional baseUrl as text, optional product as text) =>
    let
        selectedMode = if (mode = null or mode = "") then "Demo / Mock Data Mode (Instant Test)" else mode,
        actualBaseUrl = if (baseUrl = null or Text.Trim(baseUrl) = "") then "https://api.integcubes.com/v1" else Text.TrimEnd(Text.Trim(baseUrl), "/"),
        selectedProduct = if (product = null or product = "") then "All Products (MediCube & Quantus)" else product,
        isDemo = Text.StartsWith(selectedMode, "Demo"),
        navTable = CreateNavigationTable(isDemo, actualBaseUrl, selectedProduct)
    in
        navTable;

// ==========================================
// 2. DYNAMIC NAVIGATION TABLE GENERATOR
// ==========================================
CreateNavigationTable = (isDemo as logical, baseUrl as text, selectedProduct as text) as table =>
    let
        // MediCube Tables Definition
        mediCubeRows = {
            { "MediCube Devices & Assets", "MediCube_Devices", GetMediCubeDevices(isDemo, baseUrl), "Table", "Table", true },
            { "MediCube Telemetry & Readings", "MediCube_Telemetry", GetMediCubeTelemetry(isDemo, baseUrl), "Table", "Table", true },
            { "MediCube Alerts & Incidents", "MediCube_Alerts", GetMediCubeAlerts(isDemo, baseUrl), "Table", "Table", true },
            { "MediCube Operations & Logs", "MediCube_Operations", GetMediCubeOperations(isDemo, baseUrl), "Table", "Table", true }
        },
        
        // Quantus Tables Definition
        quantusRows = {
            { "Quantus KPIs & Performance", "Quantus_KPIs", GetQuantusKPIs(isDemo, baseUrl), "Table", "Table", true },
            { "Quantus Analytics & Metrics", "Quantus_Analytics", GetQuantusAnalytics(isDemo, baseUrl), "Table", "Table", true },
            { "Quantus Forecasts & Budgets", "Quantus_Forecasts", GetQuantusForecasts(isDemo, baseUrl), "Table", "Table", true },
            { "Quantus Sites & Projects", "Quantus_Projects", GetQuantusProjects(isDemo, baseUrl), "Table", "Table", true }
        },

        // Universal Dynamic Custom Endpoint Reader
        dynamicRows = {
            { "Custom Endpoint Query", "IntegCubes_CustomQuery", (endpoint as text, optional queryParams as record) => IntegCubes.FetchDynamic(isDemo, baseUrl, endpoint, queryParams), "Function", "Function", true }
        },

        // Build Nav Structure based on Selection
        allRows = if (selectedProduct = "MediCube Only") then
            mediCubeRows & dynamicRows
        else if (selectedProduct = "Quantus Only") then
            quantusRows & dynamicRows
        else
            let
                mediCubeNav = Table.ToNavigationTable(
                    Table.FromRows(mediCubeRows, {"Name", "Key", "Data", "ItemKind", "ItemName", "IsLeaf"}),
                    {"Key"}, "Name", "Data", "ItemKind", "ItemName", "IsLeaf"
                ),
                quantusNav = Table.ToNavigationTable(
                    Table.FromRows(quantusRows, {"Name", "Key", "Data", "ItemKind", "ItemName", "IsLeaf"}),
                    {"Key"}, "Name", "Data", "ItemKind", "ItemName", "IsLeaf"
                ),
                rootRows = {
                    { "MediCube Solution", "Folder_MediCube", mediCubeNav, "Folder", "Folder", false },
                    { "Quantus Solution", "Folder_Quantus", quantusNav, "Folder", "Folder", false },
                    { "Custom Dynamic Query", "IntegCubes_CustomQuery", (endpoint as text, optional queryParams as record) => IntegCubes.FetchDynamic(isDemo, baseUrl, endpoint, queryParams), "Function", "Function", true }
                }
            in
                rootRows,

        navSource = Table.FromRows(allRows, {"Name", "Key", "Data", "ItemKind", "ItemName", "IsLeaf"}),
        navTable = Table.ToNavigationTable(navSource, {"Key"}, "Name", "Data", "ItemKind", "ItemName", "IsLeaf")
    in
        navTable;

// ==========================================
// 3. PRODUCT ENDPOINT WRAPPERS
// ==========================================
// MediCube Endpoints
GetMediCubeDevices = (isDemo as logical, baseUrl as text) => 
    if isDemo then MockData.MediCubeDevices() else IntegCubes.FetchDynamic(isDemo, baseUrl, "/medicube/devices");

GetMediCubeTelemetry = (isDemo as logical, baseUrl as text) => 
    if isDemo then MockData.MediCubeTelemetry() else IntegCubes.FetchDynamic(isDemo, baseUrl, "/medicube/telemetry");

GetMediCubeAlerts = (isDemo as logical, baseUrl as text) => 
    if isDemo then MockData.MediCubeAlerts() else IntegCubes.FetchDynamic(isDemo, baseUrl, "/medicube/alerts");

GetMediCubeOperations = (isDemo as logical, baseUrl as text) => 
    if isDemo then MockData.MediCubeOperations() else IntegCubes.FetchDynamic(isDemo, baseUrl, "/medicube/operations");

// Quantus Endpoints
GetQuantusKPIs = (isDemo as logical, baseUrl as text) => 
    if isDemo then MockData.QuantusKPIs() else IntegCubes.FetchDynamic(isDemo, baseUrl, "/quantus/kpis");

GetQuantusAnalytics = (isDemo as logical, baseUrl as text) => 
    if isDemo then MockData.QuantusAnalytics() else IntegCubes.FetchDynamic(isDemo, baseUrl, "/quantus/analytics");

GetQuantusForecasts = (isDemo as logical, baseUrl as text) => 
    if isDemo then MockData.QuantusForecasts() else IntegCubes.FetchDynamic(isDemo, baseUrl, "/quantus/forecasts");

GetQuantusProjects = (isDemo as logical, baseUrl as text) => 
    if isDemo then MockData.QuantusProjects() else IntegCubes.FetchDynamic(isDemo, baseUrl, "/quantus/projects");

// ==========================================
// 4. CORE ENGINE: DATA FETCHER (LIVE OR DEMO FALLBACK)
// ==========================================
shared IntegCubes.FetchDynamic = (isDemo as logical, baseUrl as text, endpoint as text, optional queryParams as record) as table =>
    if isDemo then
        #table({"Endpoint", "Status", "Message", "SampleTimestamp"}, {
            { endpoint, "Success (Demo Mode)", "Dynamic endpoint executed in Demo Mode. Connect to Live API for real server responses.", DateTimeZone.UtcNow() }
        })
    else
        let
            cleanEndpoint = if Text.StartsWith(endpoint, "/") then Text.Range(endpoint, 1) else endpoint,
            authHeaders = GetAuthHeaders(),
            commonHeaders = [
                #"Accept" = "application/json",
                #"User-Agent" = "IntegCubes-PowerBI-Connector/1.1"
            ],
            allHeaders = Record.Combine({commonHeaders, authHeaders}),
            
            requestOptions = [
                RelativePath = cleanEndpoint,
                Headers = allHeaders,
                ManualStatusHandling = {400, 401, 403, 404, 500}
            ] & (if queryParams <> null then [Query = queryParams] else []),

            // Safe Live Execution with graceful fallback
            fetchResult = try Web.Contents(baseUrl, requestOptions),
            
            result = if fetchResult[HasError] then
                #table({"ErrorType", "Details", "HelpNote"}, {
                    { "Live Connection Failed", fetchResult[Error][Message], "Check if your IntegCubes server URL is reachable, or switch to 'Demo / Mock Data Mode' in the connector settings." }
                })
            else
                let
                    response = fetchResult[Value],
                    responseMeta = Value.Metadata(response),
                    responseCode = responseMeta[Response.Status]?,
                    parsed = if responseCode <> null and responseCode >= 400 then
                        #table({"StatusCode", "Error"}, {{ responseCode, "HTTP Error " & Text.From(responseCode) }})
                    else
                        let
                            json = Json.Document(response),
                            tbl = TransformJsonToTable(json)
                        in
                            tbl
                in
                    parsed
        in
            result;

// Helper: Secure Auth Headers extractor
GetAuthHeaders = () as record =>
    let
        credential = Extension.CurrentCredential(),
        authType = credential[AuthenticationKind]?,
        headers = if authType = "Key" then
            [
                #"X-API-Key" = credential[Key],
                #"Authorization" = "Bearer " & credential[Key]
            ]
        else if authType = "UsernamePassword" then
            let
                userPass = credential[Username] & ":" & credential[Password],
                encoded = Binary.ToText(Text.ToBinary(userPass, TextEncoding.Utf8), BinaryEncoding.Base64)
            in
                [ #"Authorization" = "Basic " & encoded ]
        else
            []
    in
        headers;

// Helper: Converts nested or standard JSON payloads into tabular format automatically
TransformJsonToTable = (json as any) as table =>
    let
        rawList = if Value.Is(json, type list) then
            json
        else if Value.Is(json, type record) then
            if Record.HasFields(json, "data") and Value.Is(json[data], type list) then
                json[data]
            else if Record.HasFields(json, "items") and Value.Is(json[items], type list) then
                json[items]
            else if Record.HasFields(json, "results") and Value.Is(json[results], type list) then
                json[results]
            else if Record.HasFields(json, "records") and Value.Is(json[records], type list) then
                json[records]
            else
                {json}
        else
            {json},

        tableFromList = Table.FromList(rawList, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
        
        expandedTable = if Table.RowCount(tableFromList) > 0 then
            let
                sampleRecord = tableFromList{0}[Column1],
                colNames = if Value.Is(sampleRecord, type record) then Record.FieldNames(sampleRecord) else {"Value"}
            in
                if Value.Is(sampleRecord, type record) then
                    Table.ExpandRecordColumn(tableFromList, "Column1", colNames, colNames)
                else
                    tableFromList
        else
            #table({"Result"}, {})
    in
        expandedTable;

// ==========================================
// 5. RICH MOCK / DEMO DATASETS
// ==========================================
MockData.MediCubeDevices = () as table =>
    let
        source = Table.FromRecords({
            [ DeviceId = "DEV-MC-001", DeviceName = "Multi-Parameter Monitor 900", Model = "MediCube Ultra", Department = "Intensive Care Unit (ICU)", Location = "Tower A - Floor 3", Status = "Online / Operational", FirmwareVersion = "v3.4.1", BatteryPercent = 98, LastCalibrationDate = #date(2026, 9, 15) ],
            [ DeviceId = "DEV-MC-002", DeviceName = "Smart Infusion Pump Pro", Model = "MediCube Flow-2", Department = "Cardiology Ward", Location = "Tower B - Floor 2", Status = "Online / Operational", FirmwareVersion = "v2.8.0", BatteryPercent = 84, LastCalibrationDate = #date(2026, 8, 20) ],
            [ DeviceId = "DEV-MC-003", DeviceName = "Critical Care Ventilator V4", Model = "MediCube BreathMaster", Department = "Emergency Room (ER)", Location = "Ground Floor - ER-04", Status = "Online / Operational", FirmwareVersion = "v4.1.2", BatteryPercent = 100, LastCalibrationDate = #date(2026, 10, 5) ],
            [ DeviceId = "DEV-MC-004", DeviceName = "Portable ECG Analyzer", Model = "MediCube CardioScan", Department = "Ambulatory Clinic", Location = "Clinic 12", Status = "Under Maintenance", FirmwareVersion = "v1.9.5", BatteryPercent = 42, LastCalibrationDate = #date(2026, 5, 11) ],
            [ DeviceId = "DEV-MC-005", DeviceName = "Hemodialysis Unit Delta", Model = "MediCube Renal-X", Department = "Nephrology", Location = "Dialysis Center - Bay 3", Status = "Online / Operational", FirmwareVersion = "v3.0.0", BatteryPercent = 95, LastCalibrationDate = #date(2026, 10, 18) ],
            [ DeviceId = "DEV-MC-006", DeviceName = "Digital Syringe Pump SP1", Model = "MediCube Flow-1", Department = "Neonatal ICU", Location = "NICU - Room 104", Status = "Online / Operational", FirmwareVersion = "v2.6.4", BatteryPercent = 78, LastCalibrationDate = #date(2026, 9, 30) ],
            [ DeviceId = "DEV-MC-007", DeviceName = "Defibrillator & Pacer Pro", Model = "MediCube PulseLife", Department = "Operating Theatre 2", Location = "OT Block - Room 2", Status = "Standby", FirmwareVersion = "v3.2.0", BatteryPercent = 100, LastCalibrationDate = #date(2026, 11, 1) ],
            [ DeviceId = "DEV-MC-008", DeviceName = "Central Diagnostic Hub", Model = "IntegCube Gateway 100", Department = "Biomedical Engineering", Location = "Server Room 1", Status = "Online / Master", FirmwareVersion = "v5.0.1", BatteryPercent = 100, LastCalibrationDate = #date(2026, 11, 10) ]
        }),
        typed = Table.TransformColumnTypes(source, {
            {"DeviceId", type text}, {"DeviceName", type text}, {"Model", type text}, {"Department", type text},
            {"Location", type text}, {"Status", type text}, {"FirmwareVersion", type text}, {"BatteryPercent", Int64.Type}, {"LastCalibrationDate", type date}
        })
    in
        typed;

MockData.MediCubeTelemetry = () as table =>
    let
        source = Table.FromRecords({
            [ ReadingId = 1001, DeviceId = "DEV-MC-001", Timestamp = #datetime(2026, 11, 19, 21, 0, 0), MetricType = "Heart Rate", Value = 74.5, Unit = "bpm", MinThreshold = 50.0, MaxThreshold = 120.0, Status = "Normal" ],
            [ ReadingId = 1002, DeviceId = "DEV-MC-001", Timestamp = #datetime(2026, 11, 19, 21, 0, 0), MetricType = "SpO2 (Oxygen Saturation)", Value = 98.2, Unit = "%", MinThreshold = 92.0, MaxThreshold = 100.0, Status = "Normal" ],
            [ ReadingId = 1003, DeviceId = "DEV-MC-001", Timestamp = #datetime(2026, 11, 19, 21, 0, 0), MetricType = "Systolic Blood Pressure", Value = 124.0, Unit = "mmHg", MinThreshold = 90.0, MaxThreshold = 140.0, Status = "Normal" ],
            [ ReadingId = 1004, DeviceId = "DEV-MC-002", Timestamp = #datetime(2026, 11, 19, 21, 5, 0), MetricType = "Infusion Flow Rate", Value = 12.5, Unit = "mL/hr", MinThreshold = 1.0, MaxThreshold = 50.0, Status = "Normal" ],
            [ ReadingId = 1005, DeviceId = "DEV-MC-003", Timestamp = #datetime(2026, 11, 19, 21, 10, 0), MetricType = "Tidal Volume", Value = 480.0, Unit = "mL", MinThreshold = 350.0, MaxThreshold = 600.0, Status = "Normal" ],
            [ ReadingId = 1006, DeviceId = "DEV-MC-003", Timestamp = #datetime(2026, 11, 19, 21, 10, 0), MetricType = "Inspiratory Pressure", Value = 19.4, Unit = "cmH2O", MinThreshold = 10.0, MaxThreshold = 30.0, Status = "Normal" ],
            [ ReadingId = 1007, DeviceId = "DEV-MC-004", Timestamp = #datetime(2026, 11, 19, 21, 15, 0), MetricType = "Internal Temperature", Value = 41.8, Unit = "°C", MinThreshold = 20.0, MaxThreshold = 40.0, Status = "Warning - High Temp" ],
            [ ReadingId = 1008, DeviceId = "DEV-MC-005", Timestamp = #datetime(2026, 11, 19, 21, 20, 0), MetricType = "Dialysate Flow Rate", Value = 500.0, Unit = "mL/min", MinThreshold = 300.0, MaxThreshold = 800.0, Status = "Normal" ]
        }),
        typed = Table.TransformColumnTypes(source, {
            {"ReadingId", Int64.Type}, {"DeviceId", type text}, {"Timestamp", type datetime}, {"MetricType", type text},
            {"Value", type number}, {"Unit", type text}, {"MinThreshold", type number}, {"MaxThreshold", type number}, {"Status", type text}
        })
    in
        typed;

MockData.MediCubeAlerts = () as table =>
    let
        source = Table.FromRecords({
            [ AlertId = "ALT-801", DeviceId = "DEV-MC-004", Timestamp = #datetime(2026, 11, 19, 20, 45, 0), Severity = "High", AlertType = "Thermal Warning", Description = "Internal temperature exceeded 40°C threshold. Cooling fan inspection required.", Acknowledged = true, AssignedTechnician = "Omar Khalid", Status = "In Progress" ],
            [ AlertId = "ALT-802", DeviceId = "DEV-MC-002", Timestamp = #datetime(2026, 11, 19, 19, 30, 0), Severity = "Medium", AlertType = "Low Battery", Description = "Battery charge at 15%. Unit disconnected from AC mains.", Acknowledged = true, AssignedTechnician = "Sara Al-Mansoor", Status = "Resolved" ],
            [ AlertId = "ALT-803", DeviceId = "DEV-MC-007", Timestamp = #datetime(2026, 11, 18, 14, 15, 0), Severity = "Low", AlertType = "Calibration Notice", Description = "Annual preventive maintenance due in 12 days.", Acknowledged = false, AssignedTechnician = "Biomedical Team A", Status = "Open" ],
            [ AlertId = "ALT-804", DeviceId = "DEV-MC-003", Timestamp = #datetime(2026, 11, 17, 08, 00, 0), Severity = "Critical", AlertType = "Sensor Occlusion", Description = "Patient circuit pressure spike detected during self-test.", Acknowledged = true, AssignedTechnician = "Dr. Tariq / BioEng", Status = "Closed" ]
        }),
        typed = Table.TransformColumnTypes(source, {
            {"AlertId", type text}, {"DeviceId", type text}, {"Timestamp", type datetime}, {"Severity", type text},
            {"AlertType", type text}, {"Description", type text}, {"Acknowledged", type logical}, {"AssignedTechnician", type text}, {"Status", type text}
        })
    in
        typed;

MockData.MediCubeOperations = () as table =>
    let
        source = Table.FromRecords({
            [ LogId = "LOG-501", DeviceId = "DEV-MC-001", Timestamp = #datetime(2026, 11, 15, 10, 30, 0), Operation = "Firmware Update v3.4.1", PerformedBy = "Fahad Rahman", DurationMinutes = 25, Status = "Completed Successfully", Notes = "Applied telemetry compression patch" ],
            [ LogId = "LOG-502", DeviceId = "DEV-MC-005", Timestamp = #datetime(2026, 11, 10, 14, 00, 0), Operation = "Fluid Filter Replacement", PerformedBy = "Zaid Al-Harbi", DurationMinutes = 45, Status = "Completed Successfully", Notes = "Routine 6-month consumable change" ],
            [ LogId = "LOG-503", DeviceId = "DEV-MC-003", Timestamp = #datetime(2026, 11, 01, 09, 15, 0), Operation = "Pressure Sensor Zeroing", PerformedBy = "Fahad Rahman", DurationMinutes = 15, Status = "Completed Successfully", Notes = "Verified against calibrated manometer" ],
            [ LogId = "LOG-504", DeviceId = "DEV-MC-008", Timestamp = #datetime(2026, 10, 25, 16, 20, 0), Operation = "Network TLS Certificate Renewal", PerformedBy = "Cloud SecOps", DurationMinutes = 10, Status = "Completed Successfully", Notes = "Updated IntegCubes MQTT endpoint certs" ]
        }),
        typed = Table.TransformColumnTypes(source, {
            {"LogId", type text}, {"DeviceId", type text}, {"Timestamp", type datetime}, {"Operation", type text},
            {"PerformedBy", type text}, {"DurationMinutes", Int64.Type}, {"Status", type text}, {"Notes", type text}
        })
    in
        typed;

MockData.QuantusKPIs = () as table =>
    let
        source = Table.FromRecords({
            [ KPI_Code = "KPI-AVAIL-01", Category = "Operational Efficiency", MetricName = "Asset Availability Index", Target = 99.2, Actual = 99.6, Unit = "%", Variance = 0.4, Status = "Target Met", Period = "Q4 2026" ],
            [ KPI_Code = "KPI-MTBF-02", Category = "Reliability", MetricName = "Mean Time Between Failures (MTBF)", Target = 2400.0, Actual = 2650.0, Unit = "Hours", Variance = 250.0, Status = "Target Exceeded", Period = "Q4 2026" ],
            [ KPI_Code = "KPI-MTTR-03", Category = "Maintenance", MetricName = "Mean Time to Repair (MTTR)", Target = 45.0, Actual = 38.2, Unit = "Minutes", Variance = -6.8, Status = "Target Met", Period = "Q4 2026" ],
            [ KPI_Code = "KPI-COMP-04", Category = "HSSE & Quality", MetricName = "Preventive Maintenance Compliance", Target = 98.0, Actual = 99.1, Unit = "%", Variance = 1.1, Status = "Target Met", Period = "Q4 2026" ],
            [ KPI_Code = "KPI-ENERGY-05", Category = "Sustainability", MetricName = "Energy Intensity Ratio", Target = 85.0, Actual = 81.4, Unit = "kWh/unit", Variance = -3.6, Status = "Optimized", Period = "Q4 2026" ],
            [ KPI_Code = "KPI-COST-06", Category = "Financial", MetricName = "Operating Cost Variance", Target = 0.0, Actual = -4.2, Unit = "%", Variance = -4.2, Status = "Cost Saved", Period = "Q4 2026" ]
        }),
        typed = Table.TransformColumnTypes(source, {
            {"KPI_Code", type text}, {"Category", type text}, {"MetricName", type text}, {"Target", type number},
            {"Actual", type number}, {"Unit", type text}, {"Variance", type number}, {"Status", type text}, {"Period", type text}
        })
    in
        typed;

MockData.QuantusAnalytics = () as table =>
    let
        source = Table.FromRecords({
            [ Month = "2026-06", Facility = "Riyadh Complex", ProductionOutput_MWh = 42500, PerformanceRatio = 98.4, HeatRate_Btu = 7120, CarbonOffset_Tons = 18200, Opex_USD = 312000 ],
            [ Month = "2026-07", Facility = "Riyadh Complex", ProductionOutput_MWh = 44800, PerformanceRatio = 98.9, HeatRate_Btu = 7080, CarbonOffset_Tons = 19100, Opex_USD = 318000 ],
            [ Month = "2026-08", Facility = "Riyadh Complex", ProductionOutput_MWh = 46200, PerformanceRatio = 99.1, HeatRate_Btu = 7050, CarbonOffset_Tons = 19700, Opex_USD = 325000 ],
            [ Month = "2026-09", Facility = "Jeddah Plant", ProductionOutput_MWh = 38400, PerformanceRatio = 97.6, HeatRate_Btu = 7210, CarbonOffset_Tons = 16400, Opex_USD = 289000 ],
            [ Month = "2026-10", Facility = "Jeddah Plant", ProductionOutput_MWh = 40100, PerformanceRatio = 98.2, HeatRate_Btu = 7160, CarbonOffset_Tons = 17100, Opex_USD = 295000 ],
            [ Month = "2026-11", Facility = "Eastern Desal", ProductionOutput_MWh = 51200, PerformanceRatio = 99.4, HeatRate_Btu = 6990, CarbonOffset_Tons = 21900, Opex_USD = 360000 ]
        }),
        typed = Table.TransformColumnTypes(source, {
            {"Month", type text}, {"Facility", type text}, {"ProductionOutput_MWh", Int64.Type},
            {"PerformanceRatio", type number}, {"HeatRate_Btu", Int64.Type}, {"CarbonOffset_Tons", Int64.Type}, {"Opex_USD", Int64.Type}
        })
    in
        typed;

MockData.QuantusForecasts = () as table =>
    let
        source = Table.FromRecords({
            [ ForecastId = "FC-2026-Q4", Department = "Operations & Maintenance", PlannedBudget_USD = 1850000, ProjectedSpend_USD = 1780000, ActualSpend_USD = 1745000, Variance_USD = -105000, ForecastAccuracy = 96.5 ],
            [ ForecastId = "FC-2026-Q4", Department = "Asset Digitalization", PlannedBudget_USD = 920000, ProjectedSpend_USD = 910000, ActualSpend_USD = 895000, Variance_USD = -25000, ForecastAccuracy = 98.2 ],
            [ ForecastId = "FC-2026-Q4", Department = "HSSE & Environmental", PlannedBudget_USD = 450000, ProjectedSpend_USD = 440000, ActualSpend_USD = 432000, Variance_USD = -18000, ForecastAccuracy = 97.0 ],
            [ ForecastId = "FC-2027-Q1", Department = "Operations & Maintenance", PlannedBudget_USD = 1920000, ProjectedSpend_USD = 1890000, ActualSpend_USD = 0, Variance_USD = -30000, ForecastAccuracy = 95.0 ],
            [ ForecastId = "FC-2027-Q1", Department = "Capital Spares & Upgrades", PlannedBudget_USD = 1400000, ProjectedSpend_USD = 1380000, ActualSpend_USD = 0, Variance_USD = -20000, ForecastAccuracy = 94.5 ]
        }),
        typed = Table.TransformColumnTypes(source, {
            {"ForecastId", type text}, {"Department", type text}, {"PlannedBudget_USD", Int64.Type},
            {"ProjectedSpend_USD", Int64.Type}, {"ActualSpend_USD", Int64.Type}, {"Variance_USD", Int64.Type}, {"ForecastAccuracy", type number}
        })
    in
        typed;

MockData.QuantusProjects = () as table =>
    let
        source = Table.FromRecords({
            [ ProjectCode = "PRJ-QC-101", ProjectName = "Al-Noor Solar Energy Phase 2", Country = "Saudi Arabia", Technology = "Solar PV & Storage", Capacity_MW = 1500, Capex_M_USD = 980, CommissionDate = #date(2027, 3, 1), Stage = "Under Construction", OverallProgress = 76.5 ],
            [ ProjectCode = "PRJ-QC-102", ProjectName = "Green Desalination Unit C", Country = "Saudi Arabia", Technology = "Reverse Osmosis (SWRO)", Capacity_MW = 600, Capex_M_USD = 450, CommissionDate = #date(2026, 12, 15), Stage = "Commissioning", OverallProgress = 94.2 ],
            [ ProjectCode = "PRJ-QC-103", ProjectName = "Gulf Wind Farm Project", Country = "UAE", Technology = "Onshore Wind", Capacity_MW = 400, Capex_M_USD = 320, CommissionDate = #date(2027, 8, 30), Stage = "EPC Execution", OverallProgress = 42.0 ],
            [ ProjectCode = "PRJ-QC-104", ProjectName = "Hydrogen Hub Pilot Alpha", Country = "Uzbekistan", Technology = "Green Hydrogen & Ammonia", Capacity_MW = 100, Capex_M_USD = 210, CommissionDate = #date(2028, 1, 10), Stage = "Feasibility / FEED", OverallProgress = 18.5 ]
        }),
        typed = Table.TransformColumnTypes(source, {
            {"ProjectCode", type text}, {"ProjectName", type text}, {"Country", type text}, {"Technology", type text},
            {"Capacity_MW", Int64.Type}, {"Capex_M_USD", Int64.Type}, {"CommissionDate", type date}, {"Stage", type text}, {"OverallProgress", type number}
        })
    in
        typed;

// ==========================================
// 6. NAVIGATION TABLE HELPER
// ==========================================
Table.ToNavigationTable = (
    table as table,
    keyColumns as list,
    nameColumn as text,
    dataColumn as text,
    itemKindColumn as text,
    itemNameColumn as text,
    isLeafColumn as text
) as table =>
    let
        tableType = Value.Type(table),
        newTableType = Type.AddTableKey(tableType, keyColumns, true) meta 
        [
            NavigationTable.NameColumn = nameColumn,
            NavigationTable.DataColumn = dataColumn,
            NavigationTable.ItemKindColumn = itemKindColumn,
            Preview.DelayColumn = itemNameColumn,
            NavigationTable.IsLeafColumn = isLeafColumn
        ],
        navigationTable = Value.ReplaceType(table, newTableType)
    in
        navigationTable;

// ==========================================
// 7. DATA SOURCE DEFINITION & PUBLISH
// ==========================================
IntegCubes = [
    TestConnection = (dataSourcePath) =>
        let
            json = Json.Document(dataSourcePath),
            mode = json[mode]? ?? "Demo / Mock Data Mode (Instant Test)",
            baseUrl = json[baseUrl]? ?? "https://api.integcubes.com/v1"
        in
            { "IntegCubes.Contents", mode, baseUrl },
            
    Authentication = [
        Key = [
            KeyLabel = "IntegCubes API Key",
            ButtonText = "API Key Authentication"
        ],
        UsernamePassword = [
            UsernameLabel = "Username / Email",
            PasswordLabel = "Password"
        ],
        Anonymous = []
    ],
    Label = "IntegCubes (MediCube & Quantus)"
];

IntegCubes.Publish = [
    Beta = false,
    Category = "Online Services",
    ButtonText = { "IntegCubes", "Connect to IntegCubes Data Platform" },
    TooltipLabel = "Access MediCube IoT and Quantus Analytics",
    LearnMoreUrl = "https://integcubes.com",
    SourceImage = IntegCubes.Icons,
    SourceTypeImage = IntegCubes.Icons
];

IntegCubes.Icons = [
    Icon16 = { Extension.Contents("IntegCubes16.png"), "image/png" },
    Icon20 = { Extension.Contents("IntegCubes20.png"), "image/png" },
    Icon24 = { Extension.Contents("IntegCubes24.png"), "image/png" },
    Icon32 = { Extension.Contents("IntegCubes32.png"), "image/png" }
];
