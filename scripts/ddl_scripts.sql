/* ======= This script defines the structure of the tables that will be used in our
project. There are a total of 6 csv files from the source systems so 6 tables will be
created along with an additional table 'sales_staging' which is necessary for the 
staging process. While loading the data due to type mismatch Sql Server will 
throw an error, it happens mostly with 'int' and 'date' data-types. Try to load the 
data using the given datasets and you will understand everything. This extra table
is only for 'crm_sales_details' table which caused error(s) while loading...
*/

drop table if exists bronze.crm_cust_info ;
create table bronze.crm_cust_info (
cst_id int, 
cst_key varchar(50), 
cst_firstname varchar(50),
cst_lastname varchar(50),
cst_marital_status char(1), 
cst_gndr char(1),
cst_create_date date ) ;

drop table if exists bronze.crm_prd_info ;
create table bronze.crm_prd_info (
prd_id int, 
prd_key varchar(50), 
prd_nm varchar(50),
prd_cost int, 
prd_line varchar(50),
prd_start_date date,
prd_end_date date ) ;


/* The sales_staging table below is just a helper table. We will first bulk
insert the data in this table and then move it to the crm_sales_details table.
We accept the dates from the csv file as varchar so that we don't get any errors
for values that are not in correct date format. Do this method only for MS Sql Server
*/

drop table if exists sales_staging ;
create table sales_staging (
sls_ord_num varchar(50), 
sls_prd_key varchar(50), 
sls_cust_id int, 
sls_order_dt varchar(50),
sls_ship_dt varchar(50), 
sls_due_dt varchar(50),
sls_sales int, 
sls_quantity int,
sls_price int ) ;


drop table if exists bronze.crm_sales_details ;
create table bronze.crm_sales_details (
sls_ord_num varchar(50), 
sls_prd_key varchar(50), 
sls_cust_id int, 
sls_order_dt date,
sls_ship_dt date, 
sls_due_dt date,
sls_sales int, 
sls_quantity int,
sls_price int ) ;

drop table if exists bronze.erp_cust_az12 ;
create table bronze.erp_cust_az12 (
cid varchar(50), 
bdate date, 
gen varchar(20) ) ;

drop table if exists bronze.erp_loc_a101 ;
create table bronze.erp_loc_a101 ( 
cid varchar(50), 
cntry varchar(50) ) ;

drop table if exists bronze.erp_px_cat_g1v2 ;
create table bronze.erp_px_cat_g1v2 ( 
id varchar(50),
cat varchar(50), 
subcat varchar(50),
maintenance varchar(50) ) ;













