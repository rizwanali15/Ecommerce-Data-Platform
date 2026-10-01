
/*Script: eda_silver_carts.sql
Purpose: Verify the quality of the Silver layer carts table 
         (duplicates, NULLs, spaces, standardization, invalid values, row count)*/

-- Exploratory Data Analysis

-- Null + Duplicates Check
-- Expectations: No Results

SELECT 
    Id,
    COUNT(*)
FROM silver.carts
GROUP BY Id
HAVING COUNT(*) > 1;

SELECT Id FROM silver.carts WHERE Id IS NULL;

SELECT * FROM silver.carts
WHERE Total IS NULL 
   OR Discounted_Total IS NULL 
   OR User_Id IS NULL 
   OR Total_Products IS NULL 
   OR Total_Quantity IS NULL;

-- Check for invalid or negative values
-- Expectations: No Results

SELECT * FROM silver.carts
WHERE Total <= 0 
   OR Discounted_Total < 0 
   OR Total_Products <= 0 
   OR Total_Quantity <= 0;

-- Standardization & Consistency

SELECT DISTINCT Total_Products FROM silver.carts ORDER BY Total_Products;

-- Row count: Bronze vs Silver

SELECT 
    (SELECT COUNT(*) FROM bronze.carts) AS bronze_count,
    (SELECT COUNT(*) FROM silver.carts) AS silver_count;