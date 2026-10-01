/*
Script: eda_silver_products_reviews.sql
Purpose: Verify the quality of the Silver layer products_reviews table
         (duplicates, NULLs, spaces, standardization, invalid values, referential integrity, row count)
*/

-- Exploratory Data Analysis

-- Null + Duplicates Check
-- Expectations: No Results

SELECT Review_Id, COUNT(*)
FROM silver.products_reviews
GROUP BY Review_Id
HAVING COUNT(*) > 1;

SELECT Review_Id FROM silver.products_reviews WHERE Review_Id IS NULL;

SELECT * FROM silver.products_reviews
WHERE Product_Id IS NULL OR Rating IS NULL OR Review_Date IS NULL
   OR Reviewer_Email IS NULL OR Comment IS NULL OR Reviewer_Name IS NULL;

-- Info only: same reviewer + product + timestamp but different Review_Id (source data quirk)
SELECT Product_Id, Reviewer_Email, Review_Date, COUNT(*)
FROM silver.products_reviews
GROUP BY Product_Id, Reviewer_Email, Review_Date
HAVING COUNT(*) > 1;

-- Check for unwanted spaces
-- Expectations: No Results

SELECT Comment FROM silver.products_reviews
WHERE Comment != TRIM(Comment);

SELECT Reviewer_Name FROM silver.products_reviews
WHERE Reviewer_Name != TRIM(Reviewer_Name);

SELECT Reviewer_Email FROM silver.products_reviews
WHERE Reviewer_Email != TRIM(Reviewer_Email);

-- Standardization & Consistency

-- Email format and casing
-- Expectation: No results
SELECT Reviewer_Email FROM silver.products_reviews
WHERE Reviewer_Email NOT LIKE '%_@_%._%'
   OR Reviewer_Email COLLATE Latin1_General_CS_AS != LOWER(Reviewer_Email);

-- Check for invalid values
-- Expectations: No Results

SELECT * FROM silver.products_reviews
WHERE Rating < 1 OR Rating > 5;

SELECT * FROM silver.products_reviews
WHERE Review_Date > GETDATE();

-- Referential integrity: every review must belong to an existing product
-- Expectation: No results
SELECT r.*
FROM silver.products_reviews r
LEFT JOIN silver.products p ON r.Product_Id = p.Id
WHERE p.Id IS NULL;

-- Row count: Bronze vs Silver
SELECT
    (SELECT COUNT(*) FROM bronze.products_reviews) AS bronze_count,
    (SELECT COUNT(*) FROM silver.products_reviews) AS silver_count;