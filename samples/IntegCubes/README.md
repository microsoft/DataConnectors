# IntegCubes Power BI Custom Connector (MediCube & Quantus)

Official Power BI Custom Connector (`.mez`) for **IntegCubes**, supporting both **MediCube** and **Quantus** product suites.

---

## 🌟 Key Features

1. **Multitasking / Multi-Product Navigation Table:**
   - **MediCube Solution:**
     - Devices & Assets (`/medicube/devices`)
     - Telemetry & Sensor Readings (`/medicube/telemetry`)
     - Alerts & Incidents (`/medicube/alerts`)
     - Operations & Maintenance Logs (`/medicube/operations`)
   - **Quantus Solution:**
     - KPIs & Performance Metrics (`/quantus/kpis`)
     - Advanced Analytics (`/quantus/analytics`)
     - Forecasts & Budgets (`/quantus/forecasts`)
     - Sites & Projects (`/quantus/projects`)
   - **Dynamic Query Engine:**
     - Custom Endpoint Function allowing ad-hoc queries to any endpoint with custom parameters.

2. **Dynamic Configuration:**
   - User-defined Base URL (defaults to `https://api.integcubes.com/v1`, easily points to On-Premise, Dev, Staging, or Cloud).
   - Product filter dropdown (`All Products`, `MediCube Only`, `Quantus Only`).

3. **Multi-Authentication Support:**
   - **API Key** (sent securely via `X-API-Key` & `Authorization: Bearer`).
   - **Basic Auth** (Username & Password with Base64 encoding).
   - **Anonymous / Dev**.

4. **Dynamic JSON Flattener:**
   - Automatically unrolls nested JSON records, objects, and lists into Power BI tables.

---

## 📁 Project Structure

```
D:\Connectors\IntegCubes\
├── IntegCubes.pq           # Main Power Query M logic & Navigation Table
├── IntegCubes.query.pq     # Test query
├── IntegCubes.mez          # Compiled Power BI extension package
├── build.ps1               # 1-Click build & deploy script
├── [Content_Types].xml     # Open Packaging Conventions manifest
├── resources.resx          # UI strings & labels
├── IntegCubes_Logo.png     # Full high-res branding logo
├── IntegCubes16.png        # 16x16 icon
├── IntegCubes20.png        # 20x20 icon
├── IntegCubes24.png        # 24x24 icon
├── IntegCubes32.png        # 32x32 icon
└── README.md               # Documentation
```

---

## 🚀 How to Enable & Test in Power BI Desktop

1. **Connector Location:**
   The connector is already deployed to:
   `C:\Users\<YourUsername>\Documents\Power BI Desktop\Custom Connectors\IntegCubes.mez`

2. **Enable Custom Extensions in Power BI Desktop:**
   - Open **Power BI Desktop**.
   - Go to **File** > **Options and settings** > **Options**.
   - Under **Global**, select **Security**.
   - Under **Data Extensions**, select:
     > **"(Not Recommended) Allow any extension to load without validation or warning"**
   - Click **OK**.
   - **Restart Power BI Desktop**.

3. **Connect to IntegCubes:**
   - Click **Get Data** > Search for **IntegCubes**.
   - Select **IntegCubes** and click **Connect**.
   - Enter your Server URL (or leave default) and select your product.
   - Enter your credentials (API Key, Username/Password, or Anonymous).
   - Check the tables you want to load from MediCube or Quantus!
