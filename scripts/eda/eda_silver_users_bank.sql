/*
Script: eda_silver_users_bank.sql
Purpose: Verify the quality of the Silver layer users table
         (duplicates, NULLs, spaces, standardization, invalid values, row count)
*/

-- Exploratory Data Analysis

-- Null + Duplicates Check
-- Expectations: No Results

SELECT 
Bank_Id,
COUNT(*)
FROM silver.users_bank
GROUP BY Bank_Id
HAVING COUNT(*) > 1;

SELECT Bank_Id FROM silver.users_bank WHERE Bank_Id IS NULL;

SELECT 
Card_Number,
COUNT(*)
FROM silver.users_bank
GROUP BY Card_Number
HAVING COUNT(*) > 1;

SELECT Card_Number FROM silver.users_bank WHERE Card_Number IS NULL;

SELECT * FROM silver.users_bank
WHERE Card_Expiry IS NULL OR Card_Type IS NULL 
   OR Currency IS NULL OR Iban IS NULL;

-- Check for unwanted spaces
-- Expectations: No Results

SELECT Card_Number FROM silver.users_bank
WHERE Card_Number != TRIM(Card_Number);

SELECT Card_Type FROM silver.users_bank
WHERE Card_Type != TRIM(Card_Type);

SELECT Currency FROM silver.users_bank
WHERE Currency != TRIM(Currency);

SELECT Iban FROM silver.users_bank
WHERE Iban != TRIM(Iban);

-- Standardization & Consistency

SELECT DISTINCT Card_Type FROM silver.users_bank;

SELECT DISTINCT Currency FROM silver.users_bank;

-- Row count: Bronze vs Silver

SELECT 
    (SELECT COUNT(*) FROM bronze.users) AS bronze_count,
    (SELECT COUNT(*) FROM silver.users_bank) AS silver_count;