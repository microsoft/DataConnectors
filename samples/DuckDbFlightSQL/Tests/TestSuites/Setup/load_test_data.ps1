# load_test_data.ps1
# Loads PQ SDK test framework data into the SQLFlite DuckDB Docker container.
# Uses varied DuckDB types (signed/unsigned integers, FLOAT/DOUBLE, DECIMAL, etc.)
# to maximize connector type coverage.

param(
    [Parameter(Mandatory=$true)]
    [string]$DataDir,
    [string]$ContainerName = "sqlflite",
    [string]$ServerHost = "localhost",
    [int]$ServerPort = 31337,
    [string]$Username = "sqlflite_username",
    [string]$Password = "sqlflite_password"
)

$ErrorActionPreference = "Stop"

# --- Helper: run SQL via sqlflite_client inside the container ---
function Invoke-FlightSQL {
    param(
        [string]$Query,
        [string]$Description
    )
    Write-Host "  $Description" -ForegroundColor Yellow
    $result = docker exec $ContainerName sqlflite_client `
        --command Execute `
        --host $ServerHost `
        --port $ServerPort `
        --username $Username `
        --password $Password `
        --query "$Query" 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error "SQL failed: $result"
        exit 1
    }
    return $result
}

# ============================================================
# Phase 1: Verify container is running
# ============================================================
Write-Host "`n=== Phase 1: Verifying container ===" -ForegroundColor Green
$container = docker ps --filter "name=$ContainerName" --format "{{.Names}}" 2>&1
if ($container -ne $ContainerName) {
    Write-Error "Container '$ContainerName' is not running. Start it first with:`n  docker run --name sqlflite --detach --rm --tty --init --publish 31337:31337 --env TLS_ENABLED=0 --env SQLFLITE_PASSWORD=sqlflite_password --env PRINT_QUERIES=1 --pull missing voltrondata/sqlflite:latest"
    exit 1
}
Write-Host "  Container '$ContainerName' is running." -ForegroundColor Yellow

# ============================================================
# Phase 2: Copy CSV files into the container
# ============================================================
Write-Host "`n=== Phase 2: Copying data files into container ===" -ForegroundColor Green
docker exec $ContainerName mkdir -p /tmp/testdata

$csvFiles = @(
    "nyc_taxi_tripdata.csv",
    "nyc_taxi_trip_date_data.csv",
    "taxi+_zone_lookup.csv",
    "misc_table.csv"
)

foreach ($file in $csvFiles) {
    $sourcePath = Join-Path $DataDir $file
    if (-not (Test-Path $sourcePath)) {
        Write-Error "File not found: $sourcePath"
        exit 1
    }
    Write-Host "  Copying $file..." -ForegroundColor Yellow
    docker cp "$sourcePath" "${ContainerName}:/tmp/testdata/$file"
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to copy $file into container."
        exit 1
    }
}
Write-Host "  All files copied." -ForegroundColor Yellow

# ============================================================
# Phase 3: Create tables and load data
# ============================================================
Write-Host "`n=== Phase 3: Creating tables and loading data ===" -ForegroundColor Green

# --- NycTaxiData ---
Write-Host "`n  [NycTaxiData]" -ForegroundColor Cyan
Invoke-FlightSQL -Query "DROP TABLE IF EXISTS NycTaxiData" -Description "Dropping existing table..."
Invoke-FlightSQL -Query "CREATE TABLE NycTaxiData (RecordID INTEGER, VendorID TINYINT, lpep_pickup_datetime TIMESTAMP, lpep_dropoff_datetime TIMESTAMP, store_and_fwd_flag BOOLEAN, RatecodeID UTINYINT, PULocationID SMALLINT, DOLocationID USMALLINT, passenger_count UTINYINT, trip_distance DECIMAL(10,2), fare_amount DECIMAL(10,2), extra DECIMAL(10,2), mta_tax DECIMAL(10,2), tip_amount DECIMAL(10,2), tolls_amount DECIMAL(10,2), ehail_fee DECIMAL(10,2), improvement_surcharge DECIMAL(10,2), total_amount DECIMAL(10,2), payment_type TINYINT, trip_type UTINYINT, congestion_surcharge DECIMAL(10,2))" -Description "Creating table..."
Invoke-FlightSQL -Query "INSERT INTO NycTaxiData SELECT * FROM read_csv('/tmp/testdata/nyc_taxi_tripdata.csv', auto_detect=true)" -Description "Loading data..."

# --- NycTaxiDateData ---
Write-Host "`n  [NycTaxiDateData]" -ForegroundColor Cyan
Invoke-FlightSQL -Query "DROP TABLE IF EXISTS NycTaxiDateData" -Description "Dropping existing table..."
Invoke-FlightSQL -Query "CREATE TABLE NycTaxiDateData (RecordID UBIGINT NOT NULL, lpep_pickup_date DATE NOT NULL, lpep_dropoff_date DATE)" -Description "Creating table..."
Invoke-FlightSQL -Query "INSERT INTO NycTaxiDateData SELECT * FROM read_csv('/tmp/testdata/nyc_taxi_trip_date_data.csv', auto_detect=true)" -Description "Loading data..."

# --- TaxiZoneLookup ---
Write-Host "`n  [TaxiZoneLookup]" -ForegroundColor Cyan
Invoke-FlightSQL -Query "DROP TABLE IF EXISTS TaxiZoneLookup" -Description "Dropping existing table..."
Invoke-FlightSQL -Query "CREATE TABLE TaxiZoneLookup (LocationID USMALLINT, Borough VARCHAR, Zone VARCHAR, service_zone VARCHAR)" -Description "Creating table..."
Invoke-FlightSQL -Query "INSERT INTO TaxiZoneLookup SELECT * FROM read_csv('/tmp/testdata/taxi+_zone_lookup.csv', auto_detect=true)" -Description "Loading data..."

# --- misc_table ---
Write-Host "`n  [misc_table]" -ForegroundColor Cyan
Invoke-FlightSQL -Query "DROP TABLE IF EXISTS misc_table" -Description "Dropping existing table..."
Invoke-FlightSQL -Query "CREATE TABLE misc_table (DATETIMEFIELD TIMESTAMP, BOOLEANFIELD BOOLEAN, BIGNUMERICFIELD DECIMAL(38,18), NUMERICFIELD DECIMAL(12,6), INTEGERFIELD SMALLINT, STRINGFIELD VARCHAR)" -Description "Creating table..."
Invoke-FlightSQL -Query "INSERT INTO misc_table SELECT * FROM read_csv('/tmp/testdata/misc_table.csv', auto_detect=true)" -Description "Loading data..."

# --- TEXT_SAMPLES ---
Write-Host "`n  [TEXT_SAMPLES]" -ForegroundColor Cyan
Invoke-FlightSQL -Query "DROP TABLE IF EXISTS TEXT_SAMPLES" -Description "Dropping existing table..."
Invoke-FlightSQL -Query "CREATE TABLE TEXT_SAMPLES (TEXTCOLUMN VARCHAR(255))" -Description "Creating table..."
Invoke-FlightSQL -Query "INSERT INTO TEXT_SAMPLES VALUES ('Email ''text'': user@example.com')" -Description "Loading data..."

# --- ExtendedTypes ---
Write-Host "`n  [ExtendedTypes]" -ForegroundColor Cyan
Invoke-FlightSQL -Query "DROP TABLE IF EXISTS ExtendedTypes" -Description "Dropping existing table..."
Invoke-FlightSQL -Query "CREATE TABLE ExtendedTypes (HugeIntCol HUGEINT, UuidCol UUID, JsonCol JSON, BlobCol BLOB)" -Description "Creating table..."
Invoke-FlightSQL -Query "INSERT INTO ExtendedTypes VALUES (1234567890123456::HUGEINT, 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', '{""key"": ""value"", ""num"": 42}', '\x48656C6C6F'::BLOB)" -Description "Loading data..."

# --- NestedTypes ---
Write-Host "`n  [NestedTypes]" -ForegroundColor Cyan
Invoke-FlightSQL -Query "DROP TABLE IF EXISTS NestedTypes" -Description "Dropping existing table..."
Invoke-FlightSQL -Query "CREATE TABLE NestedTypes (ArrayCol INTEGER[], StructCol STRUCT(name VARCHAR, age INTEGER))" -Description "Creating table..."
Invoke-FlightSQL -Query "INSERT INTO NestedTypes VALUES ([1, 2, 3], {'name': 'Alice', 'age': 30})" -Description "Loading data..."

# --- NycTaxiSummary (view) ---
Write-Host "`n  [NycTaxiSummary (view)]" -ForegroundColor Cyan
Invoke-FlightSQL -Query "CREATE OR REPLACE VIEW NycTaxiSummary AS SELECT RecordID, VendorID, fare_amount, tip_amount, total_amount, lpep_pickup_datetime FROM NycTaxiData" -Description "Creating view..."

# ============================================================
# Phase 4: Verify loaded data
# ============================================================
Write-Host "`n=== Phase 4: Verifying loaded data ===" -ForegroundColor Green

$tables = @(
    @{ Name = "NycTaxiData";     ExpectedRows = 10000 },
    @{ Name = "NycTaxiDateData"; ExpectedRows = 10000 },
    @{ Name = "TaxiZoneLookup";  ExpectedRows = 265 },
    @{ Name = "misc_table";      ExpectedRows = 1 },
    @{ Name = "TEXT_SAMPLES";    ExpectedRows = 1 },
    @{ Name = "ExtendedTypes";   ExpectedRows = 1 },
    @{ Name = "NestedTypes";     ExpectedRows = 1 },
    @{ Name = "NycTaxiSummary";  ExpectedRows = 10000 }
)

$allPassed = $true
foreach ($table in $tables) {
    $result = Invoke-FlightSQL -Query "SELECT COUNT(*) AS cnt FROM $($table.Name)" -Description "Counting rows in $($table.Name)..."
    # Extract the count value from sqlflite_client output (e.g. "cnt:   [\n    10000\n  ]")
    $resultText = ($result | Out-String)
    if ($resultText -match "cnt:\s*\[\s*(\d+)\s*\]") {
        $actualCount = [int]$Matches[1]
        if ($actualCount -eq $table.ExpectedRows) {
            Write-Host "    OK: $actualCount rows" -ForegroundColor Green
        } else {
            Write-Host "    FAIL: Expected $($table.ExpectedRows) rows, got $actualCount" -ForegroundColor Red
            $allPassed = $false
        }
    } else {
        Write-Host "    FAIL: Could not parse row count from output" -ForegroundColor Red
        $allPassed = $false
    }
}

if ($allPassed) {
    Write-Host "`n=== All tables loaded and verified successfully! ===" -ForegroundColor Green
} else {
    Write-Host "`n=== Some verifications failed. Check output above. ===" -ForegroundColor Red
    exit 1
}
