CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '=============================================================';
		PRINT 'Loading Silver Layer';
		PRINT '=============================================================';

		PRINT '>> Disabling all FK constraints on silver schema';
		EXEC sp_MSforeachtable 
			@command1 = 'ALTER TABLE ? NOCHECK CONSTRAINT ALL',
			@whereand = 'AND SCHEMA_NAME(schema_id) = ''silver''';

		SET @start_time = GETDATE();
		PRINT '>> Deleting Table: silver.products';
		DELETE FROM silver.products;
		PRINT '>> Inserting Data Into: silver.products';
		INSERT INTO silver.products(
			Id,
			Title,
			Description,
			Category,
			Price,
			Discount_Percentage,
			Rating,
			Stock,
			Brand,
			Sku,
			Weight,
			Width,
			Height,
			Depth,
			Warranty_Information,
			Shipping_Information,
			Availability_Status,
			Return_Policy,
			Minimum_Order_Quantity,
			Created_At,
			Updated_At
		)
		SELECT 
			id, 
			title, 
			description,
			category,
			price, 
			discountPercentage,
			rating,
			stock,
			ISNULL(NULLIF(LTRIM(RTRIM(brand)), ''), 'n/a') AS Brand, 
			sku,
			weight,
			TRY_CAST(JSON_VALUE(dimensions, '$.width')  AS DECIMAL(10,2)),
			TRY_CAST(JSON_VALUE(dimensions, '$.height') AS DECIMAL(10,2)),
			TRY_CAST(JSON_VALUE(dimensions, '$.depth')  AS DECIMAL(10,2)),
			warrantyInformation,
			shippingInformation,
			availabilityStatus,
			returnPolicy, 
			minimumOrderQuantity, 
			GETDATE(), 
			GETDATE()
		FROM bronze.products;

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' seconds';
		PRINT '>> ----------------'

		SET @start_time = GETDATE();
		PRINT '>> Deleting Table: silver.products_reviews';
		DELETE FROM silver.products_reviews;
		PRINT '>> Inserting Data Into: silver.products_reviews';
		INSERT INTO silver.products_reviews(
			Product_ID,
			Rating, 
			Comment, 
			Review_Date,
			Reviewer_Name,
			Reviewer_Email
		)
		SELECT  
			p.id,
			TRY_CAST(JSON_VALUE(r.value, '$.rating') AS DECIMAL(10,2)),
			JSON_VALUE(r.value, '$.comment'),
			TRY_CAST(JSON_VALUE(r.value, '$.date') AS DATETIME2),
			JSON_VALUE(r.value, '$.reviewerName'),
			JSON_VALUE(r.value, '$.reviewerEmail')
		FROM bronze.products p
		CROSS APPLY OPENJSON(p.reviews) AS r;

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' seconds';
		PRINT '>> ----------------'

		SET @start_time = GETDATE();
		PRINT '>> Deleting Table: silver.products_tags';
		DELETE FROM silver.products_tags;
		PRINT '>> Inserting Data Into: silver.products_tags';
		INSERT INTO silver.products_tags(
			Product_Id, 
			Tag)
		SELECT p.Id, t.value
		FROM bronze.products p
		CROSS APPLY OPENJSON(p.tags) AS t;

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' seconds';
		PRINT '>> ----------------'

		SET @start_time = GETDATE();
		PRINT '>> Deleting Table: silver.users';
		DELETE FROM silver.users;
		PRINT '>> Inserting Data Into: silver.users';
		INSERT INTO silver.users(	
			Id,
			First_Name, 
			Last_Name,
			Maiden_Name,
			Age, 
			Gender,
			Email,
			Phone_No,
			Username,
			Password,
			Birth_Date,
			Blood_Group, 
			Height,
			Weight,
			Eye_Color,
			Hair_Color,
			Hair_Type,
			Ip,
			Mac_Address, 
			University, 
			Ein, 
			SSN, 
			User_Agent,
			Role
		)
		SELECT
			Id, 
			firstName,
			lastName, 
			maidenName, 
			age,
			gender, 
			email, 
			phone,
			username, 
			password, 
			birthDate,
			bloodGroup,
			height, weight, 
			eyeColor,
			JSON_VALUE(hair, '$.color'), 
			JSON_VALUE(hair, '$.type'),
			ip,
			macAddress,
			university,
			ein,
			ssn,
			userAgent,
			role
		FROM bronze.users;

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' seconds';
		PRINT '>> ----------------'

		SET @start_time = GETDATE();
		PRINT '>> Deleting Table: silver.users_address';
		DELETE FROM silver.users_address;
		PRINT '>> Inserting Data Into: silver.users_address';
		INSERT INTO silver.users_address(	
			User_Id, 
			Address,
			City, 
			State, 
			State_Code,
			Postal_Code,
			Latitude,
			Longitude,
			Country
		)
		SELECT
			Id, 
			JSON_VALUE(address, '$.address'), 
			JSON_VALUE(address, '$.city'),
			JSON_VALUE(address, '$.state'), 
			JSON_VALUE(address, '$.stateCode'),
			TRY_CAST(JSON_VALUE(address, '$.postalCode') AS INT),
			TRY_CAST(JSON_VALUE(address, '$.coordinates.lat') AS DECIMAL(9,6)),
			TRY_CAST(JSON_VALUE(address, '$.coordinates.lng') AS DECIMAL(9,6)),
			JSON_VALUE(address, '$.country')
		FROM bronze.users;

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' seconds';
		PRINT '>> ----------------'

		SET @start_time = GETDATE();
		PRINT '>> Deleting Table: silver.users_bank';
		DELETE FROM silver.users_bank;
		PRINT '>> Inserting Data Into: silver.users_bank';
		INSERT INTO silver.users_bank(
			User_Id, 
			Card_Expiry, 
			Card_Number, 
			Card_Type,
			Currency, 
			Iban
		)
		SELECT
			Id, 
			JSON_VALUE(bank, '$.cardExpire'), 
			JSON_VALUE(bank, '$.cardNumber'),
			JSON_VALUE(bank, '$.cardType'), 
			JSON_VALUE(bank, '$.currency'),
			JSON_VALUE(bank, '$.iban')
		FROM bronze.users;

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' seconds';
		PRINT '>> ----------------'

		SET @start_time = GETDATE();
		PRINT '>> Deleting Table: silver.users_company';
		DELETE FROM silver.users_company;
		PRINT '>> Inserting Data Into: silver.users_company';
		INSERT INTO silver.users_company(
			User_Id, 
			Department, 
			Name, 
			Title, 
			Address, 
			City, 
			State, 
			State_Code,
			Postal_Code, 
			Latitude, 
			Longitude, 
			Country
		)
		SELECT
			id, 
			JSON_VALUE(company, '$.department'), 
			JSON_VALUE(company, '$.name'),
			JSON_VALUE(company, '$.title'), 
			JSON_VALUE(company, '$.address.address'),
			JSON_VALUE(company, '$.address.city'), 
			JSON_VALUE(company, '$.address.state'),
			JSON_VALUE(company, '$.address.stateCode'),
			TRY_CAST(JSON_VALUE(company, '$.address.postalCode') AS INT),
			TRY_CAST(JSON_VALUE(company, '$.address.coordinates.lat') AS DECIMAL(9,6)),
			TRY_CAST(JSON_VALUE(company, '$.address.coordinates.lng') AS DECIMAL(9,6)),
			JSON_VALUE(company, '$.address.country')
		FROM bronze.users;

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' seconds';
		PRINT '>> ----------------'

		SET @start_time = GETDATE();
		PRINT '>> Deleting Table: silver.users_crypto';
		DELETE FROM silver.users_crypto;
		PRINT '>> Inserting Data Into: silver.users_crypto';
		INSERT INTO silver.users_crypto(
			User_Id, 
			Coin, 
			Wallet,
			Network)
		SELECT 
			id, 
			JSON_VALUE(crypto, '$.coin'), 
			JSON_VALUE(crypto, '$.wallet'),
			JSON_VALUE(crypto, '$.network')
		FROM bronze.users;

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' seconds';
		PRINT '>> ----------------'

		SET @start_time = GETDATE();
		PRINT '>> Deleting Table: silver.carts';
		DELETE FROM silver.carts;
		PRINT '>> Inserting Data Into: silver.carts';
		INSERT INTO silver.carts(
			Id,
			Total, 
			Discounted_Total,
			User_Id,
			Total_Products, 
			Total_Quantity
		)
		SELECT 
			id, 
			total, 
			discountedTotal,
			userId,
			totalProducts,
			totalQuantity
		FROM bronze.carts;

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' seconds';
		PRINT '>> ----------------'

		SET @start_time = GETDATE();
		PRINT '>> Deleting Table: silver.carts_products';
		DELETE FROM silver.carts_products;
		PRINT '>> Inserting Data Into: silver.carts_products';
		INSERT INTO silver.carts_products(
			Cart_ID,
			Product_Id,
			Title, 
			Price,
			Quantity, 
			Total,
			Discount_Percentage,
			Discounted_Total
		)
		SELECT
			c.id, 
			TRY_CAST(JSON_VALUE(p.value, '$.id') AS INT),
			JSON_VALUE(p.value, '$.title'),
			TRY_CAST(JSON_VALUE(p.value, '$.price') AS DECIMAL(10,2)),
			TRY_CAST(JSON_VALUE(p.value, '$.quantity') AS INT),
			TRY_CAST(JSON_VALUE(p.value, '$.total') AS DECIMAL(10,2)),
			TRY_CAST(JSON_VALUE(p.value, '$.discountPercentage') AS DECIMAL(10,2)),
			TRY_CAST(JSON_VALUE(p.value, '$.discountedTotal') AS DECIMAL(10,2))
		FROM bronze.carts c
		CROSS APPLY OPENJSON(c.products) AS p
		WHERE TRY_CAST(JSON_VALUE(p.value, '$.id') AS INT) IN (
			SELECT Id FROM silver.products
		);

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' seconds';
		PRINT '>> ----------------'

		PRINT '>> Re-enabling all FK constraints on silver schema';
		EXEC sp_MSforeachtable 
			@command1 = 'ALTER TABLE ? WITH CHECK CHECK CONSTRAINT ALL',
			@whereand = 'AND SCHEMA_NAME(schema_id) = ''silver''';

		SET @batch_end_time = GETDATE();
		PRINT '=============================================================';
		PRINT 'Silver Layer Loaded Successfully';
		PRINT 'Total Load Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS VARCHAR) + ' seconds';
		PRINT '=============================================================';
	END TRY
	BEGIN CATCH
		BEGIN TRY
			EXEC sp_MSforeachtable 
				@command1 = 'ALTER TABLE ? WITH CHECK CHECK CONSTRAINT ALL',
				@whereand = 'AND SCHEMA_NAME(schema_id) = ''silver''';
		END TRY
		BEGIN CATCH
		END CATCH
		PRINT '=============================================================';
		PRINT 'ERROR OCCURED DURING LOADING SILVER LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '=============================================================';
	END CATCH
END;

EXEC silver.load_silver;

SELECT * FROM silver.products