# SSIS ETL Patterns

A SQL Server Integration Services (SSIS) project with 13 small packages-in-one, each demonstrating a classic ETL pattern: incremental loads with Lookup, conditional routing, Slowly Changing Dimensions, MERGE upserts, flat file / Excel / SQL Server sources and destinations, file handling and archiving, and execution logging.

> Built while learning SSIS. Every task has a descriptive name, all paths point to one portable project folder, and the repo includes fictional sample data and a SQL setup script, so it runs on any machine.

## Patterns

| # | Task | Pattern | Components |
|---|---|---|---|
| 01 | Incremental Insert with Lookup | Load only new rows: Lookup against the target, insert the **No Match** output | Flat File Source → Data Conversion → Lookup → OLE DB Destination |
| 02 | Flat File to SQL Table | Straight file-to-table load | Flat File Source → OLE DB Destination |
| 03 | Move Incoming File | Move a processed file from `incoming/` to `processed/` | File System Task |
| 04 | Export and Archive | Export a table to a file, then **zip it with PowerShell**; tasks chained in a Sequence Container | OLE DB Source → Flat File Destination; Execute Process Task |
| 05 / 05b | Excel to SQL Table, MERGE Staging into Employee | Excel load followed by a T-SQL **MERGE** upsert | Excel Source → OLE DB Destination; Execute SQL Task |
| 06 | Route by Marital Status | **Conditional Split** to different destinations | OLE DB Source (query) → Conditional Split → SQL table / flat file |
| 08 | Split by Gender and Marital Status | Multi-way Conditional Split into four files | OLE DB Source → Conditional Split → 4 Flat File Destinations |
| 09 | Filter by Salary Threshold | Conditional Split as a filter | Flat File Source → Conditional Split → Flat File Destination |
| 10 | Derived Pass Fail and Multicast | Computed column (`marks > 40 ? "Pass" : "Fail"`) and **Multicast** to several targets | Flat File Source → Derived Column → Multicast → SQL table + flat file |
| 11 | Lookup and Update Customer Status | Lookup + **OLE DB Command** row-by-row UPDATE | Flat File Source → Lookup → OLE DB Command |
| 12 | SCD Type 1 Employee Dimension | **Slowly Changing Dimension** wizard: new rows inserted, changed attributes overwritten | OLE DB Source → SCD → OLE DB Destination / OLE DB Command |
| 13 | Package Execution Log | Write package name, start/end time and duration to a log table | Execute SQL Task with parameters |



## Run it

Requirements: Visual Studio 2019+ with the **SQL Server Integration Services Projects** extension, and SQL Server (Developer or Express) on `localhost`.

1. Copy the `sample_data` folder to `C:\ssis-etl-patterns\sample_data` (every connection points there).
2. Run `sql/setup.sql` in SQL Server Management Studio. It creates the `SSIS` and `SSISlookup` databases with fictional data.
3. Open `ssisproj/ssisproj.sln` in Visual Studio.
4. All tasks are **disabled** so each pattern can be run on its own: right-click a task → **Enable**, then **Execute Task**.
5. The Excel task uses the 32-bit Jet provider: set **Project → Properties → Debugging → Run64BitRuntime = False**, or switch the connection to the ACE provider.

## Fixes made while documenting

- **06 Route by Marital Status:** the *married* output was loading into a table named `notmarried`. It now loads `dbo.PersonDetail_Married`.
- **08 Split by Gender and Marital Status:** the married-female condition tested `MaritalStatus == "S"`, identical to single-female, so married women were dropped and the single-female file stayed empty. It now tests `"M"`.
- Tasks, connection managers and output files renamed from exercise numbers (`q8`, `p10`, `try1.txt`) to what they do; hard-coded machine paths and server names replaced with one project folder and `localhost`.

## Known issues (left as-is, documented)

- **11 Lookup and Update:** the UPDATE runs on the Lookup's **No Match** output, so it never matches a row. It should run on **Match**, with **No Match** going to an insert.
- **12 SCD:** the source and the dimension are the same table (`EmployeeDim`), so changes can never be detected. The source should be a staging table.
- **05 → 05b:** the Excel step loads `Emp1`, but the MERGE reads `Employee_Staging`; the Excel step should load the staging table.
- **09 / 10:** the `high salary` output and `Multicast Output 4` are not connected, so those rows are discarded.
- **13 Package Execution Log:** all three parameters are named `NewParameterName`; with OLE DB they must be `0`, `1`, `2`. The start time should come from `System::StartTime`.
- **02 Flat File to SQL Table:** column names were taken from a header with spaces and a trailing `;` (`[ name]`, `[ joining_date;]`); they should be trimmed in the connection manager.
- Connections use the deprecated `SQLNCLI11` provider; new projects should use `MSOLEDBSQL`.

## Repo structure

```
ssisproj/      the SSIS project (open ssisproj.sln)
sql/setup.sql  databases, tables and seed data
sample_data/   input/ incoming/ files read by the package; output/ processed/ are written to
```
