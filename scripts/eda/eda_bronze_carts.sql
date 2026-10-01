

-- Exploratory Data Analysis

-- Check for null and duplicates
-- Expectations: No Result

SELECT 
id,
COUNT(*)
FROM bronze.carts
GROUP BY id
HAVING COUNT(*) > 1;

SELECT id FROM bronze.carts WHERE id IS NULL;

SELECT 
userId,
COUNT(*)
FROM bronze.carts
GROUP BY userId
HAVING COUNT(*) > 1;

SELECT userId FROM bronze.carts WHERE userId IS NULL;

SELECT c.* FROM bronze.carts c
LEFT JOIN bronze.users u
ON c.userId = u.id
WHERE u.id IS NULL;

SELECT * FROM bronze.carts
WHERE userId IS NULL OR products IS NULL OR total IS NULL;

-- Check for invalid numeric values

SELECT * FROM bronze.carts
WHERE total < 0 OR discountedTotal < 0 OR discountedTotal > total
	OR totalProducts < 0
	OR totalQuantity < 0 OR totalQuantity < totalProducts;

SELECT c.id, c.totalProducts,
(SELECT COUNT(*) FROM OPENJSON(c.products)) AS actual_product_count
FROM bronze.carts c
WHERE c.totalProducts != (SELECT COUNT(*) FROM OPENJSON(c.products));

-- Validity check

SELECT * FROM bronze.carts WHERE ISJSON(products) = 0;