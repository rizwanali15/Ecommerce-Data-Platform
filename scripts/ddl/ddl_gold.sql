/*
===============================================================================
DDL Script: Create Gold Tables (Star Schema)
===============================================================================
Dimensions : gold.dim_users, gold.dim_products, gold.dim_date
Facts      : gold.fact_sales   (grain: one product line inside one cart)
             gold.fact_reviews (grain: one review of one product)
Sensitive columns (Password, SSN, Ein, Card_Number, Iban, Wallet, Ip,
Mac_Address, User_Agent) are intentionally NOT carried into Gold.
Run this script once. Data is loaded by: EXEC gold.load_gold;
===============================================================================
*/

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'gold')
    EXEC('CREATE SCHEMA gold');
GO

-- Drop facts first, then dimensions
IF OBJECT_ID('gold.fact_sales',   'U') IS NOT NULL DROP TABLE gold.fact_sales;
IF OBJECT_ID('gold.fact_reviews', 'U') IS NOT NULL DROP TABLE gold.fact_reviews;
IF OBJECT_ID('gold.dim_users',    'U') IS NOT NULL DROP TABLE gold.dim_users;
IF OBJECT_ID('gold.dim_products', 'U') IS NOT NULL DROP TABLE gold.dim_products;
IF OBJECT_ID('gold.dim_date',     'U') IS NOT NULL DROP TABLE gold.dim_date;
GO

-- ============================================================================
-- DIMENSION: users (users + address + company + safe bank/crypto columns)
-- ============================================================================
CREATE TABLE gold.dim_users (
    user_key            INT IDENTITY(1,1) PRIMARY KEY,   -- surrogate key
    user_id             INT            NOT NULL,         -- natural key
    first_name          NVARCHAR(100),
    last_name           NVARCHAR(100),
    full_name           NVARCHAR(250),
    maiden_name         NVARCHAR(100),
    username            NVARCHAR(100),
    email               NVARCHAR(150),
    phone_no            NVARCHAR(50),
    gender              NVARCHAR(20),
    age                 INT,
    age_group           NVARCHAR(20),
    birth_date          DATE,
    blood_group         NVARCHAR(10),
    height              DECIMAL(10,2),
    weight              DECIMAL(10,2),
    eye_color           NVARCHAR(30),
    hair_color          NVARCHAR(30),
    hair_type           NVARCHAR(30),
    university          NVARCHAR(250),
    role                NVARCHAR(30),
    -- address
    address             NVARCHAR(250),
    city                NVARCHAR(100),
    state               NVARCHAR(100),
    state_code          NVARCHAR(10),
    postal_code         NVARCHAR(20),
    latitude            DECIMAL(9,6),
    longitude           DECIMAL(9,6),
    country             NVARCHAR(100),
    -- company
    company_name        NVARCHAR(250),
    department          NVARCHAR(100),
    job_title           NVARCHAR(150),
    company_city        NVARCHAR(100),
    company_state       NVARCHAR(100),
    company_country     NVARCHAR(100),
    -- bank / crypto (non-sensitive only)
    card_type           NVARCHAR(50),
    currency            NVARCHAR(20),
    crypto_coin         NVARCHAR(50),
    crypto_network      NVARCHAR(50),
    dwh_create_date     DATETIME2 DEFAULT SYSDATETIME()
);
GO

-- ============================================================================
-- DIMENSION: products (products + tags + review summary)
-- ============================================================================
CREATE TABLE gold.dim_products (
    product_key             INT IDENTITY(1,1) PRIMARY KEY,
    product_id              INT            NOT NULL,
    title                   NVARCHAR(250),
    description             NVARCHAR(MAX),
    category                NVARCHAR(100),
    brand                   NVARCHAR(100),
    sku                     NVARCHAR(100),
    price                   DECIMAL(18,2),
    discount_percentage     DECIMAL(10,2),
    rating                  DECIMAL(5,2),
    stock                   INT,
    availability_status     NVARCHAR(50),
    weight                  INT,
    width                   DECIMAL(10,2),
    height                  DECIMAL(10,2),
    depth                   DECIMAL(10,2),
    warranty_information    NVARCHAR(250),
    shipping_information    NVARCHAR(250),
    return_policy           NVARCHAR(250),
    minimum_order_quantity  INT,
    tags                    NVARCHAR(500),      -- STRING_AGG of products_tags
    review_count            INT,
    avg_review_rating       DECIMAL(5,2),
    created_at              DATETIME2,
    updated_at              DATETIME2,
    dwh_create_date         DATETIME2 DEFAULT SYSDATETIME()
);
GO

-- ============================================================================
-- DIMENSION: date (used by fact_reviews)
-- ============================================================================
CREATE TABLE gold.dim_date (
    date_key        INT         NOT NULL PRIMARY KEY,   -- yyyymmdd
    full_date       DATE        NOT NULL,
    year            INT,
    quarter         INT,
    month           INT,
    month_name      NVARCHAR(20),
    day             INT,
    day_name        NVARCHAR(20),
    week_of_year    INT,
    is_weekend      BIT
);
GO

-- ============================================================================
-- FACT: sales (carts_products + carts)
-- ============================================================================
CREATE TABLE gold.fact_sales (
    sales_key           INT IDENTITY(1,1) PRIMARY KEY,
    cart_product_id     INT,                 -- natural id of the cart line
    cart_id             INT,                 -- degenerate dimension
    user_key            INT,                 -- -> dim_users
    product_key         INT,                 -- -> dim_products
    quantity            INT,
    price               DECIMAL(18,2),
    discount_percentage DECIMAL(10,2),
    total               DECIMAL(18,2),
    discounted_total    DECIMAL(18,2),
    discount_amount     DECIMAL(18,2),       -- total - discounted_total
    dwh_create_date     DATETIME2 DEFAULT SYSDATETIME()
);
GO

-- ============================================================================
-- FACT: reviews (products_reviews)
-- ============================================================================
CREATE TABLE gold.fact_reviews (
    review_key          INT IDENTITY(1,1) PRIMARY KEY,
    review_id           INT,
    product_key         INT,                 -- -> dim_products
    date_key            INT,                 -- -> dim_date
    rating              DECIMAL(5,2),
    comment             NVARCHAR(MAX),
    reviewer_name       NVARCHAR(150),
    reviewer_email      NVARCHAR(150),
    dwh_create_date     DATETIME2 DEFAULT SYSDATETIME()
);
GO