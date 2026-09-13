/* 
	Written below is a stroed procedure, which is used to load
	the data from the csv files into the database tables. Print 
	statements are there to make it more readable on output.
	The helper 'sales_staging' table is also present. After populating
	the 'bronze.crm_sales_details' table you can drop it if you wish to.
	The stored procedure does not accept any arguments nor does
	it return any.
*/

create or alter procedure bronze.load_bronze as 
begin 
declare @start_time datetime, @end_time datetime, @bunch_start_time datetime, 
@bunch_end_time datetime
	begin try 
		print '=========================' ;
		print '   Loading Bronze Layer  ' ;
		print '=========================' ;

		set @bunch_start_time = getdate() ;

		set @start_time = getdate() ;
		print '<< Truncating table : bronze.crm_cust_info >>' ;
		truncate table bronze.crm_cust_info; 

		print '<< Loading table : bronze.crm_cust_info >>' ;
		bulk insert bronze.crm_cust_info 
		from 'C:\Users\nawaz\Desktop\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		with (
			firstrow = 2,
			fieldterminator = ',',
			tablock
			) ;
		set @end_time = getdate() ;
		print 'Load Duration : ' + CAST(datediff(second, @start_time, @end_time) as nvarchar )+ ' seconds ' ;


		set @start_time = getdate() ;
		print '<< Truncating table : bronze.crm_prd_info >>' ;
		truncate table bronze.crm_prd_info 

		print '<< Loading table : bronze.crm_prd_info >>' ;
		bulk insert bronze.crm_prd_info
		from 'C:\Users\nawaz\Desktop\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		with (
			firstrow = 2, 
			fieldterminator = ',',
			tablock 
			) ;
		set @end_time = getdate() ;
		print 'Load time : ' + CAST(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds ' ;


		/* As stated before this sales_staging below is a helper table. Here we are
		bulk inserting the data in this table first using the process known as 
		'staging', then we will move that data to bronze.crm_sales_details table. 
		*/
		set @start_time = getdate() ;
		print '<< Truncating table : sales_staging >>' ;
		truncate table sales_staging 

		print '<< Loading table : sales_staging >>' ;
		bulk insert sales_staging 
		from 'C:\Users\nawaz\Desktop\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		with (
			firstrow = 2, 
			fieldterminator = ',',
			tablock
			)
		set @end_time = getdate() ;
		print 'Load time : ' + CAST(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds ' ;


		-- Here we are transferring the data from sales_staging to bronze.crm_sales_details
		set @start_time = getdate() ;
		print '<< Truncating table : bronze.crm_sales_details >>' ; 
		truncate table bronze.crm_sales_details ;

		print '<< Loading table : bronze.crm_sales_details >>' ;
		insert into bronze.crm_sales_details 
		select sls_ord_num, sls_prd_key, sls_cust_id, 
		case 
			when len(sls_order_dt) = 8 then sls_order_dt 
			else null 
		end as sls_order_dt, sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, 
		sls_price 
		from sales_staging 
		set @end_time = getdate() ;
		print 'Load time : ' + CAST(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds ' ;


		set @start_time = getdate() ;
		print '<< Truncating table : bronze.erp_cust_az12 >>' ; 
		truncate table bronze.erp_cust_az12 

		print '<< Loading table : bronze.erp_cust_az12 >>' ;
		bulk insert bronze.erp_cust_az12 
		from 'C:\Users\nawaz\Desktop\sql-data-warehouse-project\datasets\source_erp\cust_az12.csv'
		with ( 
			firstrow = 2, 
			fieldterminator = ',',
			tablock 
			) ;
		set @end_time = getdate() ;
		print 'Load time : ' + CAST(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds ' ;


		set @start_time = getdate() ;
		print '<< Truncating table : bronze.erp_loc_a101 >>' ;
		truncate table bronze.erp_loc_a101 

		print '<< Loading table : bronze.erp_cust_az12 >>' ;
		bulk insert bronze.erp_loc_a101 
		from 'C:\Users\nawaz\Desktop\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
		with ( 
			firstrow = 2, 
			fieldterminator = ',',
			tablock 
			) ;
		set @end_time = getdate() ;
		print 'Loading time : ' + CAST(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds ' ;


		set @start_time = getdate() ;
		print '<< Truncating table : bronze.erp_px_cat_g1v2 >>' ;
		truncate table bronze.erp_px_cat_g1v2

		print '<< Loading table : bronze.erp_cust_az12 >>' ;
		bulk insert bronze.erp_px_cat_g1v2 
		from 'C:\Users\nawaz\Desktop\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
		with ( 
			firstrow = 2, 
			fieldterminator = ',',
			tablock 
			) ; 
		set @end_time = getdate() ; 
		print 'Loading time : ' + CAST(datediff(second, @start_time, @end_time) as nvarchar) + ' seconds ' ;

		set @bunch_end_time = getdate() ;
		print '=================================' ;
		print 'Loading time for the whole script : ' + CAST(datediff(second, @bunch_start_time, @bunch_end_time) as nvarchar) + ' seconds ' ;
		print '=================================' ;
	end try 

	begin catch 
		print '================================'
		print ' There was an error while loading the data in the tables! ' ;
		print ' Error Msg : ' + error_message() ;
		print ' Error Msg : ' + CAST(error_number() as nvarchar) ;
		print ' Error Msg : ' + CAST(error_state() as nvarchar) ;
		print '================================='
	end catch 

end 