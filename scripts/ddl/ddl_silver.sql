/*
===============================================================================
DDL Script: Create Silver Tables
===============================================================================
Purpose:
    Creates Silver layer tables for cleaned, standardized, and structured data.

Source:
    Bronze layer tables populated from the E-commerce API.

Notes:
    - Nested JSON data is flattened into relational tables.
    - Data types are standardized.
    - Primary and foreign key relationships are applied.
    - Tables are recreated when the script is executed.
===============================================================================
*/

-- ============================================================================
-- products
-- ============================================================================

IF OBJECT_ID ('silver.products', 'U') IS NOT NULL
	DROP TABLE silver.products;
GO
	
CREATE TABLE silver.products(
	Id INT PRIMARY KEY,
	Title VARCHAR(100),
	Description VARCHAR(MAX),
	Category VARCHAR(50),
	Price DECIMAL(10,2),
	Discount_Percentage DECIMAL(10,2),
	Rating DECIMAL(10,2),
	Stock INT,
	Brand VARCHAR(50),
	Sku VARCHAR(50),
	Weight INT,
	Width DECIMAL(10,2),
	Height DECIMAL(10,2),
	Depth DECIMAL(10,2),
	Warranty_Information VARCHAR(50),
	Shipping_Information VARCHAR(50),
	Availability_Status VARCHAR(50),
	Return_Policy VARCHAR(50),
	Minimum_Order_Quantity INT,
	Created_At DATETIME2,
	Updated_At DATETIME2
);

-- ============================================================================
-- products_reviews
-- ============================================================================

IF OBJECT_ID ('silver.products_reviews', 'U') IS NOT NULL
	DROP TABLE silver.products_reviews;
GO
	
CREATE TABLE silver.products_reviews(
	Review_Id INT IDENTITY(1,1) PRIMARY KEY,
	Product_ID INT FOREIGN KEY REFERENCES silver.products(Id),
	Rating DECIMAL(3,2),
	Comment VARCHAR(255),
	Review_Date DATETIME2,
	Reviewer_Name VARCHAR(100),
	Reviewer_Email VARCHAR(150)
);

-- ============================================================================
-- products_tags
-- ============================================================================

IF OBJECT_ID('silver.products_tags', 'U') IS NOT NULL
	DROP TABLE silver.products_tags;
GO
	
CREATE TABLE silver.products_tags(
	Tag_id INT IDENTITY(1,1) PRIMARY KEY,
	Product_Id INT FOREIGN KEY REFERENCES silver.products(Id),
	Tag VARCHAR(50)
);	

-- ============================================================================
-- users
-- ============================================================================

IF OBJECT_ID('silver.users', 'U') IS NOT NULL
	DROP TABLE silver.users;
GO
	
CREATE TABLE silver.users(
	Id INT PRIMARY KEY,
	First_Name VARCHAR(50),
	Last_Name VARCHAR(50),
	Maiden_Name VARCHAR(50),
	Age INT,
	Gender VARCHAR(50),
	Email VARCHAR(100),
	Phone_No VARCHAR(50),
	Username VARCHAR(50),
	Password VARCHAR(50),
	Birth_Date DATE,
	Blood_Group VARCHAR(20),
	Height DECIMAL(5,2),
	Weight DECIMAL(5,2),
	Eye_Color VARCHAR(50),
	Hair_Color VARCHAR(30),
	Hair_Type VARCHAR(30),
	Ip VARCHAR(50),
	Mac_Address VARCHAR(50),
	University VARCHAR(255),
	Ein VARCHAR(50),
	SSN VARCHAR(50),
	User_Agent VARCHAR(MAX),
	Role VARCHAR(50)
);

-- ============================================================================
-- users_address
-- ============================================================================

IF OBJECT_ID('silver.users_address', 'U') IS NOT NULL
	DROP TABLE silver.users_address;
GO
	
CREATE TABLE silver.users_address(
	Address_Id INT IDENTITY(1,1) PRIMARY KEY,
	User_Id INT FOREIGN KEY REFERENCES silver.users(Id),
	Address VARCHAR(100),
	City VARCHAR(30),
	State VARCHAR(30),
	State_Code VARCHAR(30),
	Postal_Code VARCHAR(20),
	Latitude DECIMAL(9,6),
	Longitude DECIMAL(9,6),
	Country VARCHAR(30)
);

-- ============================================================================
-- users_bank
-- ============================================================================

IF OBJECT_ID('silver.users_bank', 'U') IS NOT NULL
	DROP TABLE silver.users_bank;
GO
	
CREATE TABLE silver.users_bank(
	Bank_Id INT IDENTITY(1,1) PRIMARY KEY,
	User_Id INT FOREIGN KEY REFERENCES silver.users(Id),
	Card_Expiry VARCHAR(10),
	Card_Number VARCHAR(20),
	Card_Type VARCHAR(50),
	Currency VARCHAR(20),
	Iban VARCHAR(50)
);

-- ============================================================================
-- users_company
-- ============================================================================

IF OBJECT_ID('silver.users_company', 'U') IS NOT NULL
	DROP TABLE silver.users_company;
GO
	
CREATE TABLE silver.users_company(
	Company_Id INT IDENTITY(1,1) PRIMARY KEY,
	User_Id INT FOREIGN KEY REFERENCES silver.users(Id),
	Department VARCHAR(30),
	Name VARCHAR(100),
	Title VARCHAR(50),
	Address VARCHAR(100),
	City VARCHAR(30),
	State VARCHAR(30),
	State_Code VARCHAR(20),
	Postal_Code VARCHAR(30),
	Latitude DECIMAL(9,6),
	Longitude DECIMAL(9,6),
	Country VARCHAR(50)
);

-- ============================================================================
-- users_crypto
-- ============================================================================

IF OBJECT_ID('silver.users_crypto', 'U') IS NOT NULL
	DROP TABLE silver.users_crypto;
GO
	
CREATE TABLE silver.users_crypto(
	Crypto_Id INT IDENTITY(1,1) PRIMARY KEY,
	User_Id INT FOREIGN KEY REFERENCES silver.users(Id),
	Coin VARCHAR(30),
	Wallet VARCHAR(150),
	Network VARCHAR(100)
);

-- ============================================================================
-- carts
-- ============================================================================

IF OBJECT_ID('silver.carts', 'U') IS NOT NULL
	DROP TABLE silver.carts;
GO
	
CREATE TABLE silver.carts(
	Id INT PRIMARY KEY,
	Total DECIMAL(10,2),
	Discounted_Total DECIMAL(10,2),
	User_Id INT FOREIGN KEY REFERENCES silver.users(Id),
	Total_Products INT,
	Total_Quantity INT
);

-- ============================================================================
-- carts_products
-- ============================================================================

IF OBJECT_ID('silver.carts_products', 'U') IS NOT NULL
	DROP TABLE silver.carts_products;
GO
	
CREATE TABLE silver.carts_products(
	Carts_Product_Id INT IDENTITY(1,1) PRIMARY KEY,
	Cart_ID INT FOREIGN KEY REFERENCES silver.carts(Id),
	Product_Id INT FOREIGN KEY REFERENCES silver.products(Id),
	Title VARCHAR(100),
	Price DECIMAL(10,2),
	Quantity INT, 
	Total DECIMAL(10,2),
	Discount_Percentage DECIMAL(10,2),
	Discounted_Total DECIMAL(10,2)
);
