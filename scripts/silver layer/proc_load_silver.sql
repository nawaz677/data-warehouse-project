CREATE PROCEDURE silver.load_silver AS 
BEGIN 
	DECLARE @start_time DATETIME, @end_time DATETIME, 
	@batch_start_time DATETIME, @batch_end_time DATETIME 

	BEGIN TRY 
		PRINT '=========================================================='
		PRINT '================ Loading Silver Layer ===================='
		PRINT '=========================================================='
		PRINT ''

		SET @batch_start_time = GETDATE() ;
		PRINT '**************** Loading CRM Tables **********************'
		PRINT ''

		-- Table 1
		PRINT '------------ Loading silver.crm_cust_info ----------------'
		SET @start_time = GETDATE() ;
		TRUNCATE TABLE silver.crm_cust_info 

		INSERT INTO silver.crm_cust_info
		( cst_id, cst_key, cst_firstname, cst_lastname, 
		  cst_marital_status, cst_gndr, cst_create_date )
  
		SELECT 
			cst_id, 
			cst_key,
			COALESCE(TRIM(cst_firstname), 'n/a') AS cst_firstname, 
			COALESCE(TRIM(cst_lastname), 'n/a') AS cst_lastname,  
			CASE 
				WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
				WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
				ELSE 'n/a' 
			END cst_marital_status,
			CASE 
				WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
				WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
				ELSE 'n/a'
			END AS cst_gndr,
			cst_create_date
		FROM
			( SELECT *, 
			ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS Ranking
			FROM bronze.crm_cust_info ) o

			WHERE o.Ranking = 1 AND o.cst_id IS NOT NULL

		SET @end_time = GETDATE() ;
		PRINT 'Loading time of the table is : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds ' ;
		PRINT ''

		-- Table 2
		PRINT '-------------- Loading silver.crm_prd_info ----------------'
		SET @start_time = GETDATE() ;
		TRUNCATE TABLE silver.crm_prd_info 

		INSERT INTO silver.crm_prd_info 
		( prd_id, cat_id, prd_key, prd_nm, 
		  prd_cost, prd_line, prd_start_date, prd_end_date )

		SELECT 
			prd_id, 
			REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id, 
			SUBSTRING(prd_key, 7, len(prd_key)) AS prd_key, 
			TRIM(prd_nm) AS prd_nm, 
			COALESCE(prd_cost, 0) AS prd_cost, 
			CASE UPPER(TRIM(prd_line))
				WHEN 'M' THEN 'Mountain' 
				WHEN 'R' THEN 'Road'
				WHEN 'S' THEN 'Speciality' 
				WHEN 'T' THEN 'Track'
				ELSE 'n/a'
			END AS prd_line, 
			prd_start_date, 
			DATEADD(day, -1, LEAD(prd_start_date) OVER(PARTITION BY prd_key ORDER BY prd_start_date)) AS prd_end_date
		FROM bronze.crm_prd_info

		SET @end_time = GETDATE() ;
	    PRINT 'Loading time of the table is : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds ' ;
		PRINT ''
		
		-- Table 3
		 PRINT '------------ Loading silver.crm_sales_details ----------------'
		 SET @start_time = GETDATE() ;
		 TRUNCATE TABLE silver.crm_sales_details 

		 INSERT INTO silver.crm_sales_details 
		 ( sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, 
		   sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price )

		 SELECT 
			 sls_ord_num, 
			 sls_prd_key, 
			 sls_cust_id, 
			 CASE 
				WHEN len(sls_order_dt) != 8 THEN NULL 
				ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE) 
			 END AS sls_order_dt, 
			 CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE) AS sls_ship_dt, 
			 CAST(CAST(sls_due_dt AS VARCHAR) AS DATE) AS sls_due_dt, 
			 CASE 
				WHEN sls_sales != sls_quantity * abs(sls_price) OR sls_sales IS NULL 
				THEN sls_quantity * abs(sls_price) 
				ELSE sls_sales
			 END AS sls_sales, 
			 sls_quantity,
			 CASE 
				WHEN sls_price < 0 THEN abs(sls_price) 
				WHEN sls_price IS NULL OR sls_price = 0 THEN abs(sls_sales) / NULLIF(abs(sls_quantity), 0)
				ELSE sls_price 
			 END AS sls_price 
		 FROM bronze.crm_sales_details 

		 SET @end_time = GETDATE() ;
	     PRINT 'Loading time of the table is : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds ' ;
		 PRINT ''

		 SET @batch_end_time = GETDATE() ;
		 PRINT 'Loading time of CRM Batch is : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds ' ;
		 PRINT ''
		 PRINT ''

		 PRINT '****************** Loading ERP Tables **********************' ;
		 PRINT ''

		 -- Table 4
		 PRINT '------------ Loading silver.erp_cust_az12 ----------------'
		 SET @start_time = GETDATE() ;
		 TRUNCATE TABLE silver.erp_cust_az12 

		 INSERT INTO silver.erp_cust_az12
		 ( cid, bdate, gen )

		 SELECT 
			 CASE 
				WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid)) 
				ELSE cid
			 END AS cid, 
			 CASE 
				WHEN bdate > GETDATE() THEN NULL 
				ELSE bdate 
			 END AS bdate,
			 CASE 
				WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male' 
				WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
				ELSE 'n/a'
			 END AS gen
		 FROM bronze.erp_cust_az12

		 SET @end_time = GETDATE() ;
	     PRINT 'Loading time of the table is : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds ' ;
		 PRINT ''

		 -- Table 5
		 PRINT '------------ Loading silver.erp_loc_a101 ----------------'
		 SET @start_time = GETDATE() ;
		 TRUNCATE TABLE silver.erp_loc_a101  

		 INSERT INTO silver.erp_loc_a101 
		 ( cid, cntry ) 

		 SELECT  
		 REPLACE(cid, '-', '') as cid, 
		 CASE 
			WHEN UPPER(TRIM(cntry)) IN ('US', 'USA', 'UNITED STATES') THEN 'United States'
			WHEN UPPER(TRIM(cntry)) IN ('DE', 'GERMANY') THEN 'Germany' 
			WHEN cntry IS NULL OR TRIM(cntry) = '' THEN 'n/a' 
			ELSE TRIM(cntry) 
		 END AS cntry
		 FROM bronze.erp_loc_a101
		
		 SET @end_time = GETDATE() ;
	     PRINT 'Loading time of the table is : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds ' ;
		 PRINT ''

		 -- Table 6
		 PRINT '------------ Loading silver.erp_px_cat_g1v2 ----------------'
		 SET @start_time = GETDATE() ;
		 TRUNCATE TABLE silver.erp_px_cat_g1v2

		 INSERT INTO silver.erp_px_cat_g1v2
		 ( id, cat, subcat, maintenance )

		 SELECT 
			 id, 
			 cat, 
			 subcat, 
			 maintenance 
		 FROM bronze.erp_px_cat_g1v2
		
		 SET @end_time = GETDATE() ;
	     PRINT 'Loading time of the table is : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds ' ;
		 PRINT ''

		 SET @batch_end_time = GETDATE() ;
		 PRINT 'Loading time of ERP Batch is : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds ' ;

	END TRY 

	BEGIN CATCH 
		PRINT 'Failed To Load Table(s)' ;
		PRINT 'Error Message : ' + ERROR_MESSAGE() ; 
		PRINT 'Error Number : ' + CAST(ERROR_NUMBER() AS VARCHAR) ;
	END CATCH 
END 
