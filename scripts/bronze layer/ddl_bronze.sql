/* 
	============ DDL BRONZE LAYER =================
	
	Purpose : 
		This script creates the schema/table structure for all the bronze
		layer tables.

*/

USE data_warehouse

-- ================== Source: CRM =======================

-- 1st Table 
DROP TABLE IS EXISTS bronze.ctm_cust_info ;
CREATE TABLE bronze.crm_cust_info ( 
cst_id int, 
cst_key varchar(50), 
cst_firstname varchar(50), 
cst_lastname varchar(50), 
cst_marital_status char(1), 
cst_gndr char(1), 
cst_create_date date ) ;


-- 2nd Table 
DROP TABLE IF EXISTS bronze.crm_prd_info ;
CREATE TABLE bronze.crm_prd_info (
prd_id int, 
prd_key varchar(50), 
prd_nm varchar(50), 
prd_cost int, 
prd_line varchar(5), 
prd_start_date date, 
prd_end_date date ) ;


-- 3rd Table 
DROP TABLE IF EXISTS bronze.crm_sales_details ; 
CREATE TABLE bronze.crm_sales_details (
sls_ord_num varchar(50), 
sls_prd_key varchar(50), 
sls_cust_id int, 
sls_order_dt int, 
sls_ship_dt int, 
sls_due_dt int, 
sls_sales int, 
sls_quantity int, 
sls_price int ) ;


-- ===================== Source: ERP ==========================

-- 4th Table 
DROP TABLE IF EXISTS bronze.erp_cust_az12 ;
CREATE TABLE bronze.erp_cust_az12 ( 
cid varchar(50), 
bdate date, 
gen varchar(15) ) ;


-- 5th Table
DROP TABLE IF EXISTS bronze.erp_loc_a101 ;
CREATE TABLE bronze.erp_loc_a101 ( 
cid varchar(50), 
cntry varchar(50) ) ;


-- 6th Table
DROP TABLE IF EXISTS bronze.erp_px_cat_g1v2 ;
CREATE TABLE bronze.erp_px_cat_g1v2 (
id varchar(10), 
cat varchar(50), 
subcat varchar(50), 
maintenance varchar(3) )
