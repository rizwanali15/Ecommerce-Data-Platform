

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '==================================================='
		PRINT 'Loading Bronze Layer'
		PRINT '==================================================='

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.products';
		TRUNCATE TABLE bronze.products;
		PRINT '>> INSERTING DATA INTO: bronze.products';
		INSERT INTO bronze.products(
			id, title, description, category, price, discountPercentage, rating,
			stock, tags, brand, sku, weight, dimensions, warrantyInformation,
			shippingInformation, availabilityStatus, reviews, returnPolicy,
			minimumOrderQuantity, meta, images, thumbnail
		)
		SELECT 
			id, title, description, category, price, discountPercentage, rating,
			stock, tags, brand, sku, weight, dimensions, warrantyInformation,
			shippingInformation, availabilityStatus, reviews, returnPolicy,
			minimumOrderQuantity, meta, images, thumbnail
		FROM dbo.products;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' +CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' seconds';
		PRINT '>> ---------------';


		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.users';
		TRUNCATE TABLE bronze.users;
		PRINT '>> INSERTING DATA INTO: bronze.users';
		INSERT INTO bronze.users(
			id, firstName, lastName, maidenName, age, gender, email, phone, username,
			password, birthDate, image, bloodGroup, height, weight, eyeColor, hair, ip,
			address, macAddress, university, bank, company, ein, ssn, userAgent, crypto, role
		)
		SELECT
			id, firstName, lastName, maidenName, age, gender, email, phone, username,
			password, birthDate, image, bloodGroup, height, weight, eyeColor, hair, ip,
			address, macAddress, university, bank, company, ein, ssn, userAgent, crypto, role
		FROM dbo.users;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' +CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' seconds';
		PRINT '>> ---------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.carts';
		TRUNCATE TABLE bronze.carts;
		PRINT '>> INSERTING DATA INTO: bronze.carts';
		INSERT INTO bronze.carts(
			id, products, total, discountedTotal, userId, totalProducts, totalQuantity
		)
		SELECT 
			id, products, total, discountedTotal, userId, totalProducts, totalQuantity
		FROM dbo.carts
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' +CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + ' seconds';
		PRINT '>> ---------------';

		SET @batch_end_time = GETDATE();
		PRINT '==========================================================='
		PRINT 'Loading Bronze Layer is Completed';
		PRINT '		-- Total Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS VARCHAR) + ' seconds';
		PRINT '==========================================================='
	END TRY
	BEGIN CATCH
		PRINT '===========================================================';
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '===========================================================';
	END CATCH
END;

EXEC bronze.load_bronze;