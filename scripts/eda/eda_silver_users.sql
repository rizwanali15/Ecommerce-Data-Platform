/*
Script: eda_silver_users.sql
Purpose: Verify the quality of the Silver layer users table
         (duplicates, NULLs, spaces, standardization, invalid values, row count)
*/

-- Exploratory Data Analysis

-- Null + Duplicates Check
-- Expectations: No Results

SELECT 
Id,
COUNT(*)
FROM silver.users
GROUP BY Id
HAVING COUNT(*) > 1;

SELECT Id FROM silver.users WHERE Id IS NULL;

SELECT 
Email,
COUNT(*)
FROM silver.users
GROUP BY Email
HAVING COUNT(*) > 1;

SELECT 
Username,
COUNT(*)
FROM silver.users
GROUP BY Username
HAVING COUNT(*) > 1;

SELECT * FROM silver.users
WHERE First_Name IS NULL OR Last_Name IS NULL OR Age IS NULL
   OR Gender IS NULL OR Email IS NULL OR Phone_No IS NULL
   OR Username IS NULL OR Birth_Date IS NULL OR Blood_Group IS NULL
   OR Height IS NULL OR Weight IS NULL OR Role IS NULL;

-- Info only: how many rows have NULL / empty / 'n/a' in Maiden_Name
SELECT
    SUM(CASE WHEN Maiden_Name IS NULL THEN 1 ELSE 0 END) AS null_count,
    SUM(CASE WHEN LTRIM(RTRIM(Maiden_Name)) = '' THEN 1 ELSE 0 END) AS empty_count,
    SUM(CASE WHEN Maiden_Name = 'n/a' THEN 1 ELSE 0 END) AS na_count
FROM silver.users;

-- Check for unwanted spaces
-- Expectations: No Results

SELECT First_Name FROM silver.users
WHERE First_Name != TRIM(First_Name);

SELECT Last_Name FROM silver.users
WHERE Last_Name != TRIM(Last_Name);

SELECT Maiden_Name FROM silver.users
WHERE Maiden_Name != TRIM(Maiden_Name);

SELECT Email FROM silver.users
WHERE Email != TRIM(Email);

SELECT Phone_No FROM silver.users
WHERE Phone_No != TRIM(Phone_No);

SELECT Username FROM silver.users
WHERE Username != TRIM(Username);

SELECT University FROM silver.users
WHERE University != TRIM(University);

SELECT Role FROM silver.users
WHERE Role != TRIM(Role);

-- Standardization & Consistency

SELECT DISTINCT Gender FROM silver.users;

SELECT DISTINCT Blood_Group FROM silver.users;

SELECT DISTINCT Eye_Color FROM silver.users;

SELECT DISTINCT Hair_Color FROM silver.users;

SELECT DISTINCT Hair_Type FROM silver.users;

SELECT DISTINCT Role FROM silver.users;

SELECT DISTINCT University FROM silver.users ORDER BY University;

-- Email format and casing
-- Expectation: No results
SELECT Email FROM silver.users
WHERE Email NOT LIKE '%_@_%._%'
   OR Email != LOWER(Email);

-- Info only: phone length can vary (15-16) because of country codes
SELECT LEN(Phone_No) AS phone_length, COUNT(*) AS cnt
FROM silver.users
GROUP BY LEN(Phone_No);

-- Phone pattern: +CC XXX-XXX-XXXX
-- Expectation: No results
SELECT Phone_No FROM silver.users
WHERE Phone_No NOT LIKE '+% [0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]';

-- Check for invalid values
-- Expectations: No Results

SELECT * FROM silver.users
WHERE Age <= 0 OR Age > 120
   OR Height <= 0 OR Weight <= 0;

SELECT * FROM silver.users
WHERE Birth_Date > GETDATE();

-- Info only: mismatch between Age and Birth_Date (common in DummyJSON data)
SELECT Id, Age, Birth_Date,
       DATEDIFF(YEAR, Birth_Date, GETDATE()) AS calculated_age
FROM silver.users
WHERE ABS(Age - DATEDIFF(YEAR, Birth_Date, GETDATE())) > 1;

-- Row count: Bronze vs Silver
SELECT 
    (SELECT COUNT(*) FROM bronze.users) AS bronze_count,
    (SELECT COUNT(*) FROM silver.users) AS silver_count;