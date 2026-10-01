/*
===============================================================================
Create Database and Schemas
===============================================================================
Script Purpose:
    Creates the 'EcommerceDWH' database. If it already exists, it is dropped
    and recreated. Then creates three schemas, one per layer of the
    Medallion Architecture:
        bronze : raw API data, loaded as-is
        silver : cleaned and structured data
        gold   : business-ready star schema (dimensions + facts)
 
WARNING:
    Running this script drops the entire 'EcommerceDWH' database if it exists.
    All data in it will be permanently deleted. Proceed with caution and make
    sure you have a backup before running it.
===============================================================================
*/

Use master;
GO

-- Drop and recreate the 'EcommerceDWH' database
IF EXISTS(SELECT 1 FROM sys.databases WHERE name = 'EcommerceDWH')
BEGIN 
	ALTER DATABASE EcommerceDWH SET SIGNLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE EcommerceDWH;
END;
GO

-- Create Database 'EcommerceDWH'
CREATE DATABASE EcommerceDWH;
GO

USE EcommerceDWH;
GO

-- Create Schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO