/*
Script: eda_silver_users_company.sql
Purpose: Verify the quality of the Silver layer users table
         (duplicates, NULLs, spaces, standardization, invalid values, row count)
*/

-- Exploratory Data Analysis

-- Null + Duplicates Check
-- Expectations: No Results

SELECT 
Company_Id,
COUNT(*)
FROM silver.users_company
GROUP BY Company_Id
HAVING COUNT(*) > 1;

SELECT Company_Id FROM silver.users_address WHERE Company_Id IS NULL;

SELECT * FROM silver.users_company
WHERE User_Id IS NULL OR Department IS NULL OR Name IS NULL OR Title IS NULL
   OR Address IS NULL OR City IS NULL OR State IS NULL
   OR State_Code IS NULL OR Country IS NULL;

-- Check for unwanted spaces
-- Expectations: No Results

SELECT Department FROM silver.users_company
WHERE Department != TRIM(Department);

SELECT Name FROM silver.users_company
WHERE Name != TRIM(Name);

SELECT Title FROM silver.users_company
WHERE Title != TRIM(Title);

SELECT Address FROM silver.users_company
WHERE Address != TRIM(Address);

SELECT City FROM silver.users_company
WHERE City != TRIM(City);

SELECT State FROM silver.users_company
WHERE State != TRIM(State);

SELECT State_Code FROM silver.users_company
WHERE State_Code != TRIM(State_Code);

SELECT Country FROM silver.users_company
WHERE Country != TRIM(Country);

-- Standardization & Consistency

SELECT DISTINCT Department FROM silver.users_company;

SELECT DISTINCT Title FROM silver.users_company;

SELECT DISTINCT City FROM silver.users_company;

SELECT DISTINCT State FROM silver.users_company;

SELECT DISTINCT State_Code FROM silver.users_company;

SELECT DISTINCT Country FROM silver.users_company;

-- Check for invalid values
-- Expectations: No Results

SELECT * FROM silver.users_company
WHERE Postal_Code <= 0 
   OR Latitude < -90 OR Latitude > 90
   OR Longitude < -180 OR Longitude > 180;

-- Row count: Bronze vs Silver

SELECT 
    (SELECT COUNT(*) FROM bronze.users) AS bronze_count,
    (SELECT COUNT(*) FROM silver.users_company) AS silver_count;