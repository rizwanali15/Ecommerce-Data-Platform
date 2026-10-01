
-- Exploratory Data Analysis

-- Check for null and duplicates
-- Expectations: No Results

SELECT 
id,
COUNT(*) 
FROM bronze.products
GROUP BY id
HAVING COUNT(*) > 1;

SELECT
id
FROM bronze.products
WHERE id IS NULL;

SELECT 
sku,
COUNT(*)
FROM bronze.products
GROUP BY sku
HAVING COUNT(*) > 1;

-- Check for unwanted spaces
-- Expectations: No Results

SELECT title FROM bronze.products 
WHERE title != TRIM(title);

SELECT description FROM bronze.products 
WHERE description != TRIM(description);

SELECT category FROM bronze.products
WHERE category != TRIM(category);

SELECT brand FROM bronze.products
WHERE brand != TRIM(brand);

SELECT sku FROM bronze.products
WHERE sku != TRIM(sku);

SELECT warrantyInformation FROM bronze.products
WHERE warrantyInformation != TRIM(warrantyInformation);

SELECT shippingInformation FROM bronze.products
WHERE shippingInformation != TRIM(shippingInformation);

SELECT availabilityStatus FROM bronze.products
WHERE availabilityStatus != TRIM(availabilityStatus);

SELECT returnPolicy FROM bronze.products
WHERE returnPolicy != TRIM(returnPolicy);

SELECT thumbnail FROM bronze.products
WHERE thumbnail != TRIM(thumbnail);

-- Data Standardization & Consistency 
SELECT DISTINCT category
FROM bronze.products;

SELECT DISTINCT brand
FROM bronze.products;

SELECT * 
FROM bronze.products
WHERE brand IS NULL OR LTRIM(RTRIM(brand)) = '';

SELECT DISTINCT availabilityStatus
FROM bronze.products;

SELECT DISTINCT returnPolicy
FROM bronze.products;

SELECT DISTINCT warrantyInformation
FROM bronze.products;

SELECT DISTINCT shippingInformation
FROM bronze.products;

-- Check for invalid numeric values
SELECT * FROM bronze.products
WHERE price < 0 OR discountPercentage < 0 OR discountPercentage > 100
	OR rating < 0 OR rating > 5
	OR stock < 0
	OR weight < 0
	OR minimumOrderQuantity <= 0;

-- Validity check

SELECT * FROM bronze.products WHERE ISJSON(tags) = 0;
SELECT * FROM bronze.products WHERE ISJSON(dimensions) = 0;
SELECT * FROM bronze.products WHERE ISJSON(reviews) = 0;
SELECT * FROM bronze.products WHERE ISJSON(meta) = 0;
SELECT * FROM bronze.products WHERE ISJSON(images) = 0;
