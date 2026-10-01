/*
===============================================================================
Stored Procedure: Load Gold Layer (Silver -> Gold)
===============================================================================
Usage: EXEC gold.load_gold;
Order: truncate facts -> truncate dims -> load dims -> load facts
(No physical FK constraints, so TRUNCATE works; keys are matched on load.)
===============================================================================
*/

CREATE OR ALTER PROCEDURE gold.load_gold AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME,
            @batch_start_time DATETIME, @batch_end_time DATETIME;

    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '================================================';
        PRINT 'Loading Gold Layer';
        PRINT '================================================';

        -- Clear facts first, then dimensions
        TRUNCATE TABLE gold.fact_sales;
        TRUNCATE TABLE gold.fact_reviews;
        TRUNCATE TABLE gold.dim_users;
        TRUNCATE TABLE gold.dim_products;
        TRUNCATE TABLE gold.dim_date;

        -- --------------------------------------------------------------------
        -- dim_users
        -- --------------------------------------------------------------------
        SET @start_time = GETDATE();
        PRINT '>> Loading: gold.dim_users';
        INSERT INTO gold.dim_users (
            user_id, first_name, last_name, full_name, maiden_name, username,
            email, phone_no, gender, age, age_group, birth_date, blood_group,
            height, weight, eye_color, hair_color, hair_type, university, role,
            address, city, state, state_code, postal_code, latitude, longitude, country,
            company_name, department, job_title, company_city, company_state, company_country,
            card_type, currency, crypto_coin, crypto_network
        )
        SELECT
            u.Id,
            u.First_Name,
            u.Last_Name,
            CONCAT(u.First_Name, ' ', u.Last_Name),
            u.Maiden_Name,
            u.Username,
            u.Email,
            u.Phone_No,
            u.Gender,
            u.Age,
            CASE
                WHEN u.Age < 25 THEN 'Under 25'
                WHEN u.Age < 35 THEN '25-34'
                WHEN u.Age < 45 THEN '35-44'
                WHEN u.Age < 55 THEN '45-54'
                WHEN u.Age >= 55 THEN '55+'
                ELSE 'n/a'
            END,
            u.Birth_Date,
            u.Blood_Group,
            u.Height,
            u.Weight,
            u.Eye_Color,
            u.Hair_Color,
            u.Hair_Type,
            u.University,
            u.Role,
            a.Address, a.City, a.State, a.State_Code, a.Postal_Code,
            a.Latitude, a.Longitude, a.Country,
            c.Name, c.Department, c.Title, c.City, c.State, c.Country,
            b.Card_Type, b.Currency,
            cr.Coin, cr.Network
        FROM silver.users u
        LEFT JOIN silver.users_address a  ON a.User_Id  = u.Id
        LEFT JOIN silver.users_company c  ON c.User_Id  = u.Id
        LEFT JOIN silver.users_bank    b  ON b.User_Id  = u.Id
        LEFT JOIN silver.users_crypto  cr ON cr.User_Id = u.Id;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        -- --------------------------------------------------------------------
        -- dim_products
        -- --------------------------------------------------------------------
        SET @start_time = GETDATE();
        PRINT '>> Loading: gold.dim_products';
        INSERT INTO gold.dim_products (
            product_id, title, description, category, brand, sku, price,
            discount_percentage, rating, stock, availability_status,
            weight, width, height, depth, warranty_information,
            shipping_information, return_policy, minimum_order_quantity,
            tags, review_count, avg_review_rating, created_at, updated_at
        )
        SELECT
            p.Id, p.Title, p.Description, p.Category, p.Brand, p.Sku, p.Price,
            p.Discount_Percentage, p.Rating, p.Stock, p.Availability_Status,
            p.Weight, p.Width, p.Height, p.Depth, p.Warranty_Information,
            p.Shipping_Information, p.Return_Policy, p.Minimum_Order_Quantity,
            t.tags,
            ISNULL(r.review_count, 0),
            r.avg_review_rating,
            p.Created_At, p.Updated_At
        FROM silver.products p
        LEFT JOIN (
            SELECT Product_Id,
                   STRING_AGG(Tag, ', ') WITHIN GROUP (ORDER BY Tag) AS tags
            FROM silver.products_tags
            GROUP BY Product_Id
        ) t ON t.Product_Id = p.Id
        LEFT JOIN (
            SELECT Product_ID,
                   COUNT(*) AS review_count,
                   CAST(AVG(Rating) AS DECIMAL(5,2)) AS avg_review_rating
            FROM silver.products_reviews
            GROUP BY Product_ID
        ) r ON r.Product_ID = p.Id;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        -- --------------------------------------------------------------------
        -- dim_date (covers full years of the review dates)
        -- --------------------------------------------------------------------
        SET @start_time = GETDATE();
        PRINT '>> Loading: gold.dim_date';
        DECLARE @d_start DATE = ISNULL((SELECT DATEFROMPARTS(YEAR(MIN(Review_Date)), 1, 1)  FROM silver.products_reviews), '2024-01-01');
        DECLARE @d_end   DATE = ISNULL((SELECT DATEFROMPARTS(YEAR(MAX(Review_Date)), 12, 31) FROM silver.products_reviews), '2025-12-31');

        ;WITH dates AS (
            SELECT @d_start AS dt
            UNION ALL
            SELECT DATEADD(DAY, 1, dt) FROM dates WHERE dt < @d_end
        )
        INSERT INTO gold.dim_date (
            date_key, full_date, year, quarter, month, month_name,
            day, day_name, week_of_year, is_weekend
        )
        SELECT
            CONVERT(INT, FORMAT(dt, 'yyyyMMdd')),
            dt,
            YEAR(dt),
            DATEPART(QUARTER, dt),
            MONTH(dt),
            DATENAME(MONTH, dt),
            DAY(dt),
            DATENAME(WEEKDAY, dt),
            DATEPART(ISO_WEEK, dt),
            CASE WHEN DATENAME(WEEKDAY, dt) IN ('Saturday', 'Sunday') THEN 1 ELSE 0 END
        FROM dates
        OPTION (MAXRECURSION 0);
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        -- --------------------------------------------------------------------
        -- fact_sales
        -- --------------------------------------------------------------------
        SET @start_time = GETDATE();
        PRINT '>> Loading: gold.fact_sales';
        INSERT INTO gold.fact_sales (
            cart_product_id, cart_id, user_key, product_key, quantity, price,
            discount_percentage, total, discounted_total, discount_amount
        )
        SELECT
            cp.Carts_Product_Id,
            cp.Cart_ID,
            du.user_key,
            dp.product_key,
            cp.Quantity,
            cp.Price,
            cp.Discount_Percentage,
            cp.Total,
            cp.Discounted_Total,
            cp.Total - cp.Discounted_Total
        FROM silver.carts_products cp
        LEFT JOIN silver.carts        c  ON c.Id         = cp.Cart_ID
        LEFT JOIN gold.dim_users      du ON du.user_id    = c.User_Id
        LEFT JOIN gold.dim_products   dp ON dp.product_id = cp.Product_Id;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        -- --------------------------------------------------------------------
        -- fact_reviews
        -- --------------------------------------------------------------------
        SET @start_time = GETDATE();
        PRINT '>> Loading: gold.fact_reviews';
        INSERT INTO gold.fact_reviews (
            review_id, product_key, date_key, rating, comment,
            reviewer_name, reviewer_email
        )
        SELECT
            r.Review_Id,
            dp.product_key,
            CONVERT(INT, FORMAT(r.Review_Date, 'yyyyMMdd')),
            r.Rating,
            r.Comment,
            r.Reviewer_Name,
            r.Reviewer_Email
        FROM silver.products_reviews r
        LEFT JOIN gold.dim_products dp ON dp.product_id = r.Product_ID;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        SET @batch_end_time = GETDATE();
        PRINT '================================================';
        PRINT 'Loading Gold Layer is Completed';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
        PRINT '================================================';
    END TRY
    BEGIN CATCH
        PRINT '================================================';
        PRINT 'ERROR OCCURRED DURING LOADING GOLD LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number : ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error State  : ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '================================================';
    END CATCH
END;
GO

/*
===============================================================================
Quality Checks: Gold Layer
===============================================================================
Run after: EXEC gold.load_gold;
Expected: row counts match, no orphan keys, no duplicate natural keys.
===============================================================================
*/

EXEC gold.load_gold;

-- Row count must match silver
SELECT COUNT(*) AS gold_rows   FROM gold.fact_sales;
SELECT COUNT(*) AS silver_rows FROM silver.carts_products;

-- Orphan keys (expect 0)
SELECT COUNT(*) AS orphan_users    FROM gold.fact_sales WHERE user_key    IS NULL;
SELECT COUNT(*) AS orphan_products FROM gold.fact_sales WHERE product_key IS NULL;

-- Duplicate natural keys (expect 0 rows)
SELECT user_id,    COUNT(*) FROM gold.dim_users    GROUP BY user_id    HAVING COUNT(*) > 1;
SELECT product_id, COUNT(*) FROM gold.dim_products GROUP BY product_id HAVING COUNT(*) > 1;

-- Quick look
SELECT TOP 10 * FROM gold.fact_sales;
SELECT TOP 10 * FROM gold.dim_users;
SELECT TOP 10 * FROM gold.dim_products;