
Use master;
GO

-- Drop and recreate the 'EcommerceDWH' database
IF EXISTS(SELECT 1 FROM sys.databases WHERE name = 'EcommerceDWH')
BEGIN 
	ALTER DATABASE EcommerceDWH SET SIGNLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE EcommerceDWH;
END;
GO

-- Create Database 'EcommerceDWH'
CREATE DATABASE EcommerceDWH;
GO

USE EcommerceDWH;
GO

-- Create Schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO

-- Create Bronze Layer Tables

IF OBJECT_ID ('bronze.products', 'U') IS NOT NULL
	DROP TABLE bronze.products;
CREATE TABLE bronze.products(
	id INT,
	title VARCHAR(100),
	description VARCHAR(500),
	category VARCHAR(50),
	price DECIMAL(10,2),
	discountPercentage DECIMAL(10,2),
	rating DECIMAL(10,2),
	stock DECIMAL(10,2),
	tags NVARCHAR(200),
	brand VARCHAR(20),
	sku VARCHAR(20),
	weight INT,
	dimensions VARCHAR(100),
	warrantyInformation VARCHAR(20),
	shippingInformation VARCHAR(40),
	availabilityStatus VARCHAR(20),
	reviews NVARCHAR(MAX),
	returnPolicy VARCHAR(30),
	minimumOrderQuantity INT,
	meta VARCHAR(MAX),
	images VARCHAR(MAX),
	thumbnail VARCHAR(150)
);

IF OBJECT_ID ('bronze.users', 'U') IS NOT NULL 
	DROP TABLE bronze.users;
CREATE TABLE bronze.users(
	id INT,
	firstName VARCHAR(20),
	lastName VARCHAR(20),
	maidenName VARCHAR(20),
	age INT,
	gender VARCHAR(20),
	email VARCHAR(50),
	phone VARCHAR(20),
	username VARCHAR(20),
	password VARCHAR(20),
	birthDate DATE,
	image VARCHAR(150),
	bloodGroup VARCHAR(15),
	height DECIMAL(10,2),
	weight DECIMAL(10,2),
	eyeColor VARCHAR(20),
	hair VARCHAR(50),
	ip VARCHAR(20),
	address VARCHAR(MAX),
	macAddress VARCHAR(30),
	university VARCHAR(100),
	bank VARCHAR(300),
	company VARCHAR(300),
	ein VARCHAR(20),
	ssn VARCHAR(20),
	userAgent VARCHAR(255),
	crypto VARCHAR(200),
	role VARCHAR(20)
);

IF OBJECT_ID ('bronze.carts', 'U') IS NOT NULL
	DROP TABLE bronze.carts;
CREATE TABLE bronze.carts (
	id INT,
	products VARCHAR(max),
	total DECIMAL(10,2),
	discountedTotal DECIMAL(10,2),
	userId INT,
	totalProducts INT,
	totalQuantity INT
);