/*
Script: eda_silver_products.sql
Purpose: Verify the quality of the Silver layer products table
         (duplicates, NULLs, spaces, standardization, invalid values, row count)
*/

-- Exploratory Data Analysis

-- Null + Duplicates Check
-- Expectations: No Results

SELECT 
id,
COUNT(*)
FROM silver.products
GROUP BY id
HAVING COUNT(*) > 1;

SELECT id FROM silver.products WHERE id IS NULL;

SELECT 
sku,
COUNT(*)
FROM silver.products
GROUP BY sku
HAVING COUNT(*) > 1;

SELECT * FROM silver.products
WHERE Title IS NULL OR Category IS NULL OR Price IS NULL
   OR Sku IS NULL OR Stock IS NULL OR Rating IS NULL
   OR Discount_Percentage IS NULL;

-- Check for unwanted spaces
-- Expectations: No Results

SELECT Title FROM silver.products 
WHERE Title != TRIM(Title);

SELECT Description FROM silver.products 
WHERE Description != TRIM(Description);

SELECT Category FROM silver.products
WHERE Category != TRIM(Category);

SELECT Brand FROM silver.products
WHERE Brand != TRIM(Brand);

SELECT Sku FROM silver.products
WHERE Sku != TRIM(Sku);

SELECT Warranty_Information FROM silver.products
WHERE Warranty_Information != TRIM(Warranty_Information);

SELECT Shipping_Information FROM silver.products
WHERE Shipping_Information != TRIM(Shipping_Information);

SELECT Availability_Status FROM silver.products
WHERE Availability_Status != TRIM(Availability_Status);

SELECT Return_Policy FROM silver.products
WHERE Return_Policy != TRIM(Return_Policy);

-- Standardization & Consistency

SELECT DISTINCT Category
FROM silver.products;

SELECT DISTINCT Brand
FROM silver.products;

-- Brand should not be NULL
-- Expectation: No results
SELECT Brand FROM silver.products WHERE Brand IS NULL;

-- Info only: how many products had a missing brand
SELECT COUNT(*) FROM silver.products WHERE Brand = 'n/a';

SELECT DISTINCT Availability_Status
FROM silver.products;

SELECT DISTINCT Return_Policy
FROM silver.products;

SELECT DISTINCT Warranty_Information
FROM silver.products;

SELECT DISTINCT Shipping_Information
FROM silver.products;

-- Check for invalid numeric values
-- Expectations: No Results

SELECT * FROM silver.products
WHERE Price <= 0 OR Discount_Percentage < 0 OR Discount_Percentage > 100
   OR Rating < 0 OR Rating > 5
   OR Stock < 0
   OR Weight <= 0
   OR Minimum_Order_Quantity <= 0;

SELECT * FROM silver.products
WHERE Width <= 0 OR Height <= 0 OR Depth <= 0;

-- Check for invalid dates
-- Expectations: No Results

SELECT * FROM silver.products
WHERE Created_At > GETDATE() OR Updated_At < Created_At;

-- Row count: Bronze vs Silver

SELECT 
    (SELECT COUNT(*) FROM bronze.products) AS bronze_count,
    (SELECT COUNT(*) FROM silver.products) AS silver_count;