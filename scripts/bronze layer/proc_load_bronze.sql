CREATE PROCEDURE bronze.load_bronze AS 
BEGIN 

DECLARE @start_time DATETIME, @end_time DATETIME, 
	    @batch_start_time DATETIME, @batch_end_time DATETIME ;

	BEGIN TRY 

		PRINT '===================================================='
		PRINT '============= Loading Bronze Layer ================='
		PRINT '===================================================='
		PRINT ' ' 

		-- 1st Source
		PRINT '============== Loading Source CRM =================='
		PRINT ' '
		SET @batch_start_time = GETDATE() ;
		
		-- Table 1
		PRINT 'Truncating and Bulk Inserting Table bronze.crm_cust_info' ;
		SET @start_time = GETDATE() ;

		TRUNCATE TABLE bronze.crm_cust_info ;
		BULK INSERT bronze.crm_cust_info 
		FROM 'C:\Users\nawaz\Desktop\data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH ( 
			FIRSTROW = 2, 
			FIELDTERMINATOR = ',', 
			TABLOCK 
			) ;

		SET @end_time = GETDATE() ;
		PRINT 'Total Loading Time : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR ) + ' seconds ' ;
		PRINT ' ' ;


		-- Table 2
		PRINT 'Truncating and Bulk Inserting Table bronze.crm_prd_info' ;
		SET @start_time = GETDATE() ;

		TRUNCATE TABLE bronze.crm_prd_info ;
		BULK INSERT bronze.crm_prd_info 
		FROM 'C:\Users\nawaz\Desktop\data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH( 
			FIRSTROW = 2, 
			FIELDTERMINATOR = ',',
			TABLOCK 
			) ;

		SET @end_time = GETDATE() ;
		PRINT 'Total Loading Time : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR ) + ' seconds ' ;
		PRINT ' ' ;

		-- Table 3
		PRINT 'Truncating and Bulk Inserting Table bronze.crm_sales_details' ;
		SET @start_time = GETDATE() ;

		TRUNCATE TABLE bronze.crm_sales_details 
		BULK INSERT bronze.crm_sales_details 
		FROM 'C:\Users\nawaz\Desktop\data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH ( 
			FIRSTROW = 2, 
			FIELDTERMINATOR = ',', 
			TABLOCK 
			) 

		SET @end_time = GETDATE() ;
		PRINT 'Total Loading Time : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR ) + ' seconds ' ;
		PRINT ' ' ;

		SET @batch_end_time = GETDATE() ;
		PRINT 'Total time to Load Source CRM : ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS VARCHAR ) + ' seconds ' ;
		PRINT ' ' ;

		-- 2nd Source
		PRINT '============== Loading Source ERP =================' 
		PRINT ' ' 
		SET @batch_start_time = GETDATE() ;

		-- Table 4
		PRINT 'Truncating and Bulk Inserting Table bronze.erp_cust_az12';
		SET @start_time = GETDATE() ;

		TRUNCATE TABLE bronze.erp_cust_az12 ;
		BULK INSERT bronze.erp_cust_az12 
		FROM 'C:\Users\nawaz\Desktop\data-warehouse-project\datasets\source_erp\cust_az12.csv'
		WITH (
			FIRSTROW = 2, 
			FIELDTERMINATOR = ',',
			TABLOCK 
			) ;

		SET @end_time = GETDATE() ;
		PRINT 'Total Loading Time : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds ' ;


		-- Table 5
		PRINT 'Truncating and Bulk Inserting Table bronze.erp_loc_a101' ;
		SET @start_time = GETDATE() ;

		TRUNCATE TABLE bronze.erp_loc_a101 ;
		BULK INSERT bronze.erp_loc_a101 
		FROM 'C:\Users\nawaz\Desktop\data-warehouse-project\datasets\source_erp\loc_a101.csv'
		WITH ( 
			FIRSTROW = 2, 
			FIELDTERMINATOR = ',', 
			TABLOCK 
			) ;

		SET @end_time = GETDATE() ;
		PRINT 'Total Loading Time : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds ' ;


		-- Table 6
		PRINT 'Truncating and Bulk Inserting Table bronze.erp_px_cat_g1v2' ;
		SET @start_time = GETDATE() ;

		TRUNCATE TABLE bronze.erp_px_cat_g1v2 ;
		BULK INSERT bronze.erp_px_cat_g1v2 
		FROM 'C:\Users\nawaz\Desktop\data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
		WITH ( 
			FIRSTROW = 2, 
			FIELDTERMINATOR = ',', 
			TABLOCK 
			) ;
			
		SET @end_time = GETDATE() ;
		PRINT 'Total Loading Time : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds ' ;
		PRINT ' ' ;

		SET @batch_end_time = GETDATE() ;
		PRINT 'Total time to Load Source ERP : ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS VARCHAR ) + ' seconds ' ;

	END TRY 


	BEGIN CATCH 

		PRINT 'Failed To Load the Table(s) !';
		PRINT 'Error Message : ' + ERROR_MESSAGE() ;
		PRINT 'Error Number : ' + CAST(ERROR_NUMBER() AS VARCHAR ) ;

	END CATCH 

END 
