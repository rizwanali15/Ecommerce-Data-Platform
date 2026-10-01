
/*Script: eda_silver_carts_products.sql
Purpose: Verify the quality of the Silver layer carts_products table 
         (duplicates, NULLs, spaces, standardization, invalid values, row count)*/

-- Exploratory Data Analysis

-- Null + Duplicates Check
-- Expectations: No Results

SELECT 
    Carts_Product_Id,
    COUNT(*)
FROM silver.carts_products
GROUP BY Carts_Product_Id
HAVING COUNT(*) > 1;

SELECT Carts_Product_Id FROM silver.carts_products WHERE Carts_Product_Id IS NULL;

SELECT * FROM silver.carts_products
WHERE Cart_Id IS NULL 
   OR Product_Id IS NULL 
   OR Price IS NULL 
   OR Quantity IS NULL 
   OR Total IS NULL;

-- Check for invalid or negative values
-- Expectations: No Results

SELECT * FROM silver.carts_products
WHERE Price <= 0 
   OR Quantity <= 0 
   OR Total <= 0 
   OR Discount_Percentage < 0 
   OR Discounted_Total < 0;

-- Check for unwanted spaces
-- Expectations: No Results

SELECT Title FROM silver.carts_products
WHERE Title != TRIM(Title);

-- Standardization & Consistency

SELECT DISTINCT Quantity 
FROM silver.carts_products 
ORDER BY Quantity;

-- Row count: Bronze vs Silver

SELECT 
    (SELECT COUNT(*) FROM bronze.carts) AS bronze_count,
    (SELECT COUNT(*) FROM silver.carts_products) AS silver_count;