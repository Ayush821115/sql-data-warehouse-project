SELECT DISTINCT
	ci.cst_gndr,
	ca.gen,
	CASE 
		WHEN cst_gndr != 'n/a' THEN ci.cst_gndr --CRM is the Master for gender info
		ELSE COALESCE(ca.gen, 'n/a')
	END AS new_gen
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
ON		  ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 AS la
ON		  ci.cst_key = la.cid
ORDER BY 1,2
;

SELECT distinct gender FROM gold.dim_customers;


SELECT prd_key, COUNT(*) FROM(
SELECT 
	pn.prd_id,
	pn.cat_id,
	pn.prd_key,
	pn.prd_nm,
	pn.prd_cost,
	pn.prd_line,
	pn.prd_start_dt,
	pn.prd_end_dt,
	pc.cat,
	pc.subcat,
	pc.maintenance
FROM silver.crm_prd_info AS pn
LEFT JOIN silver.erp_px_cat_g1v2 AS pc
ON pn.cat_id = pc.id
WHERE pn.prd_end_dt IS NULL -- Filter out all historical data ,i.e, only includes the current data
)t GROUP BY prd_key
HAVING COUNT(*) > 1
;


SELECT * FROM gold.dim_products;

-- Foreign Key Integrity (Dimensins)
SELECT * FROM gold.fact_sales;

SELECT * FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
WHERE c.customer_key IS NULL
;

SELECT * FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products P
ON p.product_key = f.product_key
WHERE p.product_key IS NULL
;