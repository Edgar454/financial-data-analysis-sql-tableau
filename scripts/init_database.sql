/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'FinancialDataAnalytics' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additionally, this script creates a schema called gold
	
WARNING:
    Running this script will drop the entire 'FinancialDataAnalytics' database if it exists. 
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.
*/

USE master;
GO

-- Drop and recreate the 'DataWarehouseAnalytics' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'FinancialDataAnalytics')
BEGIN
    ALTER DATABASE FinancialDataAnalytics SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE FinancialDataAnalytics;
END;
GO

-- Create the 'DataWarehouseAnalytics' database
CREATE DATABASE FinancialDataAnalytics;
GO

USE FinancialDataAnalytics ;
GO

-- Create Schemas

CREATE SCHEMA fin;
GO


CREATE TABLE fin.account(
	account_id int,
	district_id int,
	frequency nvarchar(50),
	[date] date,
);
GO

CREATE TABLE fin.client(
	client_id int,
	gender nvarchar(50),
	birth_date date,
	district_id int,
);
GO

CREATE TABLE fin.[card](
	card_id int,
	disp_id int,
	[type] nvarchar(50),
	issued date,
);
GO

CREATE TABLE fin.disp(
	disp_id int,
	client_id int,
	account_id int,
	[type] nvarchar(50),
);
GO

CREATE TABLE fin.district(
	district_id int,
	A2 nvarchar(50),
	A3 nvarchar(50),
	A4 int,
	A5 int,
	A6 int,
	A7 int,
	A8 int,
	A9 int,
	A10 decimal,
	A11 int,
	A12 decimal,
	A13 decimal,
	A14 int,
	A15 int,
	A16 int,
);
GO

CREATE TABLE fin.loan(
	loan_id int,
	account_id int,
	[date] date,
	amount int,
	duration int,
	payments decimal,
	[status] nvarchar(50),
);
GO

CREATE TABLE fin.[order](
	order_id int,
	account_id int,
	bank_to nvarchar(50),
	account_to int ,
	amount decimal,
	k_symbol nvarchar(50),
);
GO

CREATE TABLE fin.trans(
	trans_id int,
	account_id int,
	[date] date,
	[type] nvarchar(50),
	operation nvarchar(50),
	amount int,
	balance int ,
	k_symbol nvarchar(50),
	bank nvarchar(50),
	account int
);
GO

-- inserting the data

TRUNCATE TABLE fin.account;
GO

BULK INSERT fin.account
FROM 'D:\Personnal_projects\financial-data-analysis-sql-tableau\datasets\account_202507090021.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO


TRUNCATE TABLE fin.client;
GO

BULK INSERT fin.client
FROM 'D:\Personnal_projects\financial-data-analysis-sql-tableau\datasets\client_202507090022.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO


TRUNCATE TABLE fin.[card];
GO

BULK INSERT fin.[card]
FROM 'D:\Personnal_projects\financial-data-analysis-sql-tableau\datasets\card_202507090021.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO

TRUNCATE TABLE fin.disp;
GO

BULK INSERT fin.disp
FROM 'D:\Personnal_projects\financial-data-analysis-sql-tableau\datasets\disp_202507090022.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO


TRUNCATE TABLE fin.district;
GO

BULK INSERT fin.district
FROM 'D:\Personnal_projects\financial-data-analysis-sql-tableau\datasets\district_202507090022.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO

TRUNCATE TABLE fin.[order];
GO

BULK INSERT fin.[order]
FROM 'D:\Personnal_projects\financial-data-analysis-sql-tableau\datasets\_order__202507090023.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO


TRUNCATE TABLE fin.loan;
GO

BULK INSERT fin.loan
FROM 'D:\Personnal_projects\financial-data-analysis-sql-tableau\datasets\loan_202507090023.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO


TRUNCATE TABLE fin.trans;
GO

BULK INSERT fin.trans
FROM 'D:\Personnal_projects\financial-data-analysis-sql-tableau\datasets\trans_202507090130.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);
GO