/* Setup for the SSIS ETL patterns package. Run in SQL Server Management Studio.
   Creates the two databases the package's connection managers point to
   (SSIS_DB -> SSIS, SSISlookup_DB -> SSISlookup) with fictional seed data.
   Table and column names match what the package expects, including a few
   designer-generated names noted in the README. */

IF DB_ID('SSIS') IS NULL CREATE DATABASE SSIS;
GO
IF DB_ID('SSISlookup') IS NULL CREATE DATABASE SSISlookup;
GO

USE SSIS;
GO

-- 01 Incremental Insert with Lookup: rows already here are skipped, new ones inserted
CREATE TABLE dbo.Patient (
    PatientID INT PRIMARY KEY, FirstName VARCHAR(50), LastName VARCHAR(50),
    DOB DATETIME, Gender VARCHAR(50), ContactNumber VARCHAR(50), Address VARCHAR(50));
INSERT INTO dbo.Patient VALUES
    (1, 'Asha', 'Menon', '1985-03-14', 'F', '555-0101', '22 River Rd'),
    (2, 'David', 'Stone', '1979-07-02', 'M', '555-0102', '5 Hill St');

-- 02 Flat File to SQL Table (column names come from the file header, spaces included)
CREATE TABLE dbo.emp (
    id INT, [ name] VARCHAR(50), [ dob] DATETIME, [ address] VARCHAR(50), [ joining_date;] DATETIME);

-- 04 Export and Archive: exported to a flat file, then zipped
CREATE TABLE dbo.employee (
    EmployeeID INT PRIMARY KEY, Name NVARCHAR(50), DOB DATE, Address NVARCHAR(100), JoiningDate DATE);
INSERT INTO dbo.employee VALUES
    (1, 'Riya Desai', '1992-04-11', '12 Elm St', '2020-01-15'),
    (2, 'Mark Lee', '1988-09-30', '48 Oak Ave', '2019-06-01'),
    (3, 'Julia Gomez', '1995-02-18', '7 Pine Rd', '2022-03-21');

-- 05 Excel to SQL Table, 08 Split by Gender and Marital Status (reads Emp1)
CREATE TABLE dbo.Emp1 (
    BusinessEntityID INT, LoginID NVARCHAR(100), JobTitle NVARCHAR(100),
    BirthDate DATE, MaritalStatus NVARCHAR(5), Gender NVARCHAR(5));

-- 05b MERGE Staging into Employee
CREATE TABLE dbo.Employee_Staging (
    BusinessEntityID INT PRIMARY KEY, LoginID NVARCHAR(100), JobTitle NVARCHAR(100),
    BirthDate DATE, MaritalStatus NVARCHAR(5), Gender NVARCHAR(5));
CREATE TABLE dbo.Employee (
    BusinessEntityID INT PRIMARY KEY, LoginID NVARCHAR(100), JobTitle NVARCHAR(100),
    BirthDate DATE, MaritalStatus NVARCHAR(5), Gender NVARCHAR(5));
INSERT INTO dbo.Employee VALUES (1, 'corp\riya.d', 'Junior Analyst', '1992-04-11', 'S', 'F');
INSERT INTO dbo.Employee_Staging VALUES
    (1, 'corp\riya.d', 'Data Analyst', '1992-04-11', 'S', 'F'),   -- update
    (2, 'corp\mark.l', 'Engineer', '1988-09-30', 'M', 'M');       -- insert

-- 06 Route by Marital Status
CREATE TABLE dbo.PersonDetail (ID INT, Name NVARCHAR(50), Gender NVARCHAR(10), MaritalStatus NVARCHAR(10));
CREATE TABLE dbo.PersonDetail_Married (ID INT, Name NVARCHAR(50), Gender NVARCHAR(10), MaritalStatus NVARCHAR(10));
INSERT INTO dbo.PersonDetail VALUES
    (1, 'Leah Grant', 'F', 'Married'), (2, 'Ravi Kumar', 'M', 'Single'),
    (3, 'Chloe Adams', 'F', 'Single'), (4, 'Ethan Moore', 'M', 'Married');

-- 10 Derived Pass Fail and Multicast
CREATE TABLE dbo.student (
    sid VARCHAR(50), name VARCHAR(50), subject VARCHAR(50), marks VARCHAR(50), result NVARCHAR(4));

-- 11 Lookup and Update Customer Status
CREATE TABLE dbo.Customer (CustomerID INT PRIMARY KEY, CustomerName NVARCHAR(100), Status NVARCHAR(20));
INSERT INTO dbo.Customer VALUES
    (101, 'Northwind Supplies', 'Inactive'), (102, 'Blue Harbor Foods', 'Active'), (103, 'Summit Tools', 'Active');

-- 12 SCD Type 1 Employee Dimension
CREATE TABLE dbo.EmployeeDim (
    EmpSK INT IDENTITY(1,1) PRIMARY KEY, Eid INT, Ename NVARCHAR(100), Esalary NUMERIC(18,2),
    Edesignation NVARCHAR(100), StartDate DATETIME, EndDate DATETIME, IsCurrent BIT);
INSERT INTO dbo.EmployeeDim (Eid, Ename, Esalary, Edesignation, StartDate, EndDate, IsCurrent) VALUES
    (1, 'Riya Desai', 65000, 'Data Analyst', '2020-01-15', NULL, 1),
    (2, 'Mark Lee', 82000, 'Engineer', '2019-06-01', NULL, 1);
GO

USE SSISlookup;
GO
-- 13 Package Execution Log
CREATE TABLE dbo.SSISPackageLog (
    LogID INT IDENTITY(1,1) PRIMARY KEY, PackageName NVARCHAR(200),
    StartTime DATETIME, EndTime DATETIME, DurationInSeconds INT);
GO
