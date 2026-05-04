/* 
============================================================
	ATP Tour Data Warehouse
	Script: Database and Schema Initialization
	Description: Creates the database and three schemas following
	              the medallion architecture (Bronze > Silver > Gold)
	Run this script first before any other SQL scripts
	============================================================ 
*/

-- Create Database
USE master;
GO

CREATE DATABASE atp_datawarehouse;
GO

USE atp_datawarehouse;
GO

-- Create Schemas
-- Bronze: raw data as-is from source CSV files
CREATE SCHEMA bronze;
GO

-- Silver: cleaned and standardized data
CREATE SCHEMA silver;
GO

-- Gold: business-ready star schema for Power BI
CREATE SCHEMA gold;
GO