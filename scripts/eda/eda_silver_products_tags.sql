/*
Script: eda_silver_products_tags.sql
Purpose: Verify the quality of the Silver layer products_tags table
         (NULLs, duplicates, spaces, standardization, referential integrity, row count)
*/

-- Exploratory Data Analysis

-- Null + Duplicates Check
-- Expectations: No Results

SELECT * FROM silver.products_tags
WHERE Product_Id IS NULL OR Tag IS NULL;

-- The same tag should not repeat for the same product
SELECT Product_Id, Tag, COUNT(*)
FROM silver.products_tags
GROUP BY Product_Id, Tag
HAVING COUNT(*) > 1;

-- Check for unwanted spaces
-- Expectations: No Results

SELECT Tag FROM silver.products_tags
WHERE Tag != TRIM(Tag);

-- Standardization & Consistency

SELECT DISTINCT Tag
FROM silver.products_tags
ORDER BY Tag;

-- All tags should be lowercase
-- Expectation: No results
SELECT Tag FROM silver.products_tags
WHERE Tag COLLATE Latin1_General_CS_AS != LOWER(Tag);

-- Referential integrity: every tag must belong to an existing product
-- Expectation: No results
SELECT t.*
FROM silver.products_tags t
LEFT JOIN silver.products p ON t.Product_Id = p.Id
WHERE p.Id IS NULL;

-- Row count: Bronze vs Silver
SELECT
    (SELECT COUNT(*) FROM bronze.products) AS bronze_count,
    (SELECT COUNT(*) FROM silver.products_tags) AS silver_count;