/*
Script: eda_silver_users_crypto.sql
Purpose: Verify the quality of the Silver layer users table
         (duplicates, NULLs, spaces, standardization, invalid values, row count)
*/

-- Exploratory Data Analysis

-- Null + Duplicates Check
-- Expectations: No Results

SELECT 
Crypto_Id,
COUNT(*)
FROM silver.users_crypto
GROUP BY Crypto_Id
HAVING COUNT(*) > 1;

SELECT Crypto_Id FROM silver.users_crypto WHERE Crypto_Id IS NULL;

SELECT * FROM silver.users_crypto
WHERE Coin IS NULL OR Wallet IS NULL OR Network IS NULL;

-- Check for unwanted spaces
-- Expectations: No Results

SELECT Coin FROM silver.users_crypto
WHERE Coin != TRIM(Coin);

SELECT Wallet FROM silver.users_crypto
WHERE Wallet != TRIM(Wallet);

SELECT Network FROM silver.users_crypto
WHERE Network != TRIM(Network);

-- Standardization & Consistency

SELECT DISTINCT Coin FROM silver.users_crypto;

SELECT DISTINCT Wallet FROM silver.users_crypto;

SELECT DISTINCT Network FROM silver.users_crypto;

-- Row count: Bronze vs Silver

SELECT 
    (SELECT COUNT(*) FROM bronze.users) AS bronze_count,
    (SELECT COUNT(*) FROM silver.users_crypto) AS silver_count;