-- =============================================
-- Silver Customer Load Script
-- Purpose:
--   Clean and standardize customer data from Bronze
-- =============================================

-- Truncate Silver table before load
TRUNCATE TABLE silver.crm_cust_info;

INSERT INTO silver.crm_cust_info (
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date
) 
SELECT 
    cst_id,
    cst_key,
    TRIM(cst_firstname) AS cst_firstname,
    TRIM(cst_lastname) AS cst_lastname,
    CASE 
        WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
        WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
        ELSE 'n/a'
    END AS cst_marital_status,
    CASE 
        WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
        WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
        ELSE 'n/a'
    END AS cst_gndr,
    cst_create_date
FROM (
    SELECT *,
           ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
    FROM bronze.crm_cust_info
    WHERE cst_id IS NOT NULL
) AS cust 
WHERE flag_last = 1;


-- =============================================
-- Silver Product Load Script
-- =============================================

TRUNCATE TABLE silver.crm_prd_info;

INSERT INTO silver.crm_prd_info (
    prd_id,
    cat_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
)
SELECT
    prd_id,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
    SUBSTRING(prd_key, 7) AS prd_key,
    prd_nm,
    COALESCE(prd_cost, 0) AS prd_cost,
    CASE UPPER(TRIM(prd_line))
        WHEN 'M' THEN 'Mountain'
        WHEN 'R' THEN 'Road'
        WHEN 'S' THEN 'Other Sales'
        WHEN 'T' THEN 'Touring'
        ELSE 'n/a'
    END AS prd_line,
    prd_start_dt,
    LEAD(prd_start_dt) OVER (
        PARTITION BY SUBSTRING(prd_key, 7)
        ORDER BY prd_start_dt
    ) - INTERVAL '1 day' AS prd_end_dt
FROM bronze.crm_prd_info;


-- =============================================
-- Silver Sales Load Script
-- =============================================

TRUNCATE TABLE silver.crm_sales_details;

INSERT INTO silver.crm_sales_details (
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
)
SELECT
    b.sls_ord_num,
    b.sls_prd_key,
    b.sls_cust_id,
    CASE
        WHEN b.sls_order_dt = 0 OR LENGTH(b.sls_order_dt::TEXT) != 8 THEN NULL
        ELSE TO_DATE(b.sls_order_dt::TEXT, 'YYYYMMDD')
    END AS sls_order_dt,
    CASE
        WHEN b.sls_ship_dt = 0 OR LENGTH(b.sls_ship_dt::TEXT) != 8 THEN NULL
        ELSE TO_DATE(b.sls_ship_dt::TEXT, 'YYYYMMDD')
    END AS sls_ship_dt,
    CASE
        WHEN b.sls_due_dt = 0 OR LENGTH(b.sls_due_dt::TEXT) != 8 THEN NULL
        ELSE TO_DATE(b.sls_due_dt::TEXT, 'YYYYMMDD')
    END AS sls_due_dt,
    CASE
        WHEN b.sls_quantity IS NULL OR b.sls_quantity <= 0 THEN NULL
        WHEN b.sls_sales = b.sls_quantity * ABS(b.sls_price) THEN b.sls_sales
        WHEN b.sls_sales = ABS(b.sls_price) THEN b.sls_sales
        ELSE b.sls_quantity * ABS(b.sls_price)
    END AS sls_sales,
    b.sls_quantity,
    CASE
        WHEN b.sls_quantity IS NULL OR b.sls_quantity <= 0 THEN NULL
        WHEN b.sls_sales = b.sls_quantity * ABS(b.sls_price) THEN ABS(b.sls_price)
        WHEN b.sls_sales = ABS(b.sls_price) THEN ROUND(ABS(b.sls_price) / b.sls_quantity, 2)
        ELSE ROUND((b.sls_quantity * ABS(b.sls_price)) / b.sls_quantity, 2)
    END AS sls_price
FROM bronze.crm_sales_details b;


-- =============================================
-- Silver ERP Customer Load Script
-- =============================================

TRUNCATE TABLE silver.erp_cust_az12;

INSERT INTO silver.erp_cust_az12 (
    cid,
    bdate,
    gen
)
SELECT 
    CASE
        WHEN TRIM(b.cid) LIKE 'NAS%' THEN SUBSTRING(TRIM(b.cid) FROM 4)
        ELSE TRIM(b.cid)
    END AS cid,
    CASE
        WHEN b.bdate > CURRENT_DATE THEN NULL
        ELSE b.bdate
    END AS bdate,
    CASE
        WHEN LOWER(TRIM(b.gen)) IN ('f', 'female') THEN 'Female'
        WHEN LOWER(TRIM(b.gen)) IN ('m', 'male') THEN 'Male'
        ELSE 'n/a'
    END AS gen
FROM bronze.erp_cust_az12 b;


-- =============================================
-- Silver ERP Location Load Script
-- =============================================

TRUNCATE TABLE silver.erp_loc_a101;

INSERT INTO silver.erp_loc_a101 (
    cid,
    cntry
)
SELECT
    TRIM(REPLACE(b.cid, '-', '')) AS cid,
    CASE
        WHEN LOWER(TRIM(b.cntry)) = 'de' THEN 'Germany'
        WHEN LOWER(TRIM(b.cntry)) IN ('usa', 'us', 'united states') THEN 'United States'
        WHEN b.cntry IS NULL OR TRIM(b.cntry) = '' THEN 'n/a'
        ELSE TRIM(b.cntry)
    END AS cntry
FROM bronze.erp_loc_a101 b;


-- =============================================
-- Silver ERP Product Category Load Script
-- =============================================

TRUNCATE TABLE silver.erp_px_cat_g1v2;

INSERT INTO silver.erp_px_cat_g1v2 (
    id,
    cat,
    subcat,
    maintenance
)
SELECT
    TRIM(b.id) AS id,
    TRIM(b.cat) AS cat,
    TRIM(b.subcat) AS subcat,
    TRIM(b.maintenance) AS maintenance
FROM bronze.erp_px_cat_g1v2 b;
