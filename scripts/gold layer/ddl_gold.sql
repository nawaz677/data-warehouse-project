/*
	=====================================================
	================= Gold Layer ========================
	=====================================================
	Purpose : 
		The purpose of this script is to make the data from the silver
		layer ready for business uses. We make necessary adjustments 
		like data integration, renaming source column names to user
		friendly ones and filtering out the uncessary data 
	About Objects : 
		The objects are the Views in Gold Layer and not Tables...
*/


-- ================= Create View for Customers =====================
CREATE VIEW gold.dim_customers AS 
SELECT 
	ROW_NUMBER() OVER(ORDER BY ci.cst_id) AS customer_key, -- This is a surrogate key
	ci.cst_id AS customer_id,
	ci.cst_key AS customer_number,
	ci.cst_firstname AS first_name,
	ci.cst_lastname AS last_name,
	cl.cntry AS country, 
	CASE 
		WHEN ci.cst_gndr != 'n/a' THEN cst_gndr -- CRM is the master source
		ELSE COALESCE(ct.gen, 'n/a')
	END as gender,  
	ci.cst_marital_status AS marital_status, 
	ct.bdate AS birthdate,
	ci.cst_create_date  AS create_date
FROM silver.crm_cust_info AS ci 

LEFT JOIN silver.erp_cust_az12 AS ct 
ON		  ci.cst_key = ct.cid 
LEFT JOIN silver.erp_loc_a101 cl
ON	      ci.cst_key = cl.cid 


-- ================== Create View for Products =====================
CREATE VIEW gold.dim_products AS
SELECT 
	ROW_NUMBER() OVER (ORDER BY p.prd_start_date, p.prd_key) AS product_key,
	p.prd_id AS product_id,
	p.prd_key AS product_number,
	p.prd_nm AS product_name, 
	p.cat_id AS category_id, 
	pc.cat AS category,
	pc.subcat AS sub_category,
	pc.maintenance,
	p.prd_cost AS cost,
	p.prd_line AS product_line,
	p.prd_start_date AS product_start_date
FROM silver.crm_prd_info AS p

LEFT JOIN silver.erp_px_cat_g1v2 AS pc
ON		  p.cat_id = pc.id 
WHERE	  p.prd_end_date IS NULL -- Filtering out the historic data of the products


-- ==================== Create View for Sales ======================
CREATE VIEW gold.fact_sales AS 
SELECT 
	sd.sls_ord_num AS order_number,
	cst.customer_key, 
	pd.product_key,	
	sd.sls_order_dt AS order_date,
	sd.sls_ship_dt AS ship_date,
	sd.sls_due_dt AS due_date,
	sd.sls_sales AS sales,
	sd.sls_quantity AS quantity,
	sd.sls_price AS price
FROM silver.crm_sales_details sd

LEFT JOIN gold.dim_customers cst
ON		  sd.sls_cust_id = cst.customer_id
LEFT JOIN gold.dim_products pd
ON		  sd.sls_prd_key = pd.product_number



