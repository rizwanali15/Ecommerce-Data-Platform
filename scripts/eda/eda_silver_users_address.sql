/*
Script: eda_silver_users_address.sql
Purpose: Verify the quality of the Silver layer users table
         (duplicates, NULLs, spaces, standardization, invalid values, row count)
*/

-- Exploratory Data Analysis

-- Null + Duplicates Check
-- Expectations: No Results

SELECT 
Address_Id,
COUNT(*)
FROM silver.users_address
GROUP BY Address_Id
HAVING COUNT(*) > 1;

SELECT Address_Id FROM silver.users_address WHERE Address_Id IS NULL;

SELECT * FROM silver.users_address
WHERE Address IS NULL OR City IS NULL OR State IS NULL
   OR State_Code IS NULL OR Postal_Code IS NULL OR Latitude IS NULL
   OR Longitude IS NULL OR Country IS NULL;

-- Check for unwanted spaces
-- Expectations: No Results

SELECT Address FROM silver.users_address
WHERE Address != TRIM(Address);

SELECT City FROM silver.users_address
WHERE City != TRIM(City);

SELECT State FROM silver.users_address
WHERE State != TRIM(State);

SELECT State_Code FROM silver.users_address
WHERE State_Code != TRIM(State_Code);

SELECT Country FROM silver.users_address
WHERE Country != TRIM(Country);

-- Standardization & Consistency

SELECT DISTINCT City FROM silver.users_address;

SELECT DISTINCT State FROM silver.users_address;

SELECT DISTINCT State_Code FROM silver.users_address;

SELECT DISTINCT Country FROM silver.users_address;

-- Check for invalid values
-- Expectations: No Results

SELECT * FROM silver.users_address
WHERE Postal_Code <= 0 
   OR Latitude < -90 OR Latitude > 90
   OR Longitude < -180 OR Longitude > 180;

-- Row count: Bronze vs Silver

SELECT 
    (SELECT COUNT(*) FROM bronze.users) AS bronze_count,
    (SELECT COUNT(*) FROM silver.users_address) AS silver_count;