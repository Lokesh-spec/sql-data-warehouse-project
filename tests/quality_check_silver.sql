-- ========================================================
-- Silver Layer Quality Checks Starter Script
-- Purpose: Validate data quality, standardization, and consistency
-- for all Silver tables after ETL load
-- ========================================================


-- ========================================================
-- 1. crm_cust_info Quality Checks
-- ========================================================

-- 1a. Check for NULLs or duplicates in Primary Key
-- Expectation: No result
-- Purpose: Ensure each customer has a unique ID
SELECT cst_id,
       COUNT(*) AS cnt
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- 1b. Check for unwanted spaces in first name
-- Expectation: No result
-- Purpose: Ensure names are properly trimmed
SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

-- 1c. Check for valid gender values
-- Expectation: Only 'Male', 'Female', or 'n/a'
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info;


-- ========================================================
-- 2. crm_prd_info Quality Checks
-- ========================================================

-- 2a. Check for NULLs or duplicates in Primary Key
-- Expectation: No result
SELECT prd_id,
       COUNT(*) AS cnt
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- 2b. Check for unwanted spaces in product name
-- Expectation: No result
SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- 2c. Check for invalid product cost
-- Expectation: No nulls or negative numbers
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost IS NULL OR prd_cost < 0;

-- 2d. Check for valid product lines
-- Expectation: Only 'Mountain', 'Road', 'Touring', 'Other Sales', 'n/a'
SELECT DISTINCT prd_line
FROM silver.crm_prd_info;

-- 2e. Check for invalid product date ranges
-- Expectation: No rows
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;


-- ========================================================
-- 3. crm_sales_details Quality Checks
-- ========================================================

-- 3a. Check for invalid due dates in Bronze source
-- Expectation: No rows
SELECT NULLIF(sls_due_dt, 0) AS sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0
   OR LENGTH(sls_due_dt::TEXT) != 8
   OR sls_due_dt > 20250101
   OR sls_due_dt < 19000101;

-- 3b. Check for logical order vs. ship dates
-- Expectation: No rows
SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
   OR sls_order_dt > sls_due_dt;

-- 3c. Check data consistency between sales, quantity, and price
-- Expectation: No rows
SELECT
    sls_ord_num,
    sls_sales AS old_sls_sales,
    sls_quantity,
    sls_price AS old_sls_price,
    CASE
        WHEN sls_quantity IS NULL OR sls_quantity <= 0 THEN NULL
        WHEN sls_sales = sls_quantity * ABS(sls_price) THEN sls_sales
        WHEN sls_sales = ABS(sls_price) THEN sls_sales
        ELSE sls_quantity * ABS(sls_price)
    END AS sls_sales_calc,
    CASE
        WHEN sls_quantity IS NULL OR sls_quantity <= 0 THEN NULL
        WHEN sls_sales = sls_quantity * ABS(sls_price) THEN ABS(sls_price)
        WHEN sls_sales = ABS(sls_price) THEN ROUND(ABS(sls_price) / sls_quantity, 2)
        ELSE ROUND((sls_quantity * ABS(sls_price)) / sls_quantity, 2)
    END AS sls_price_calc
FROM silver.crm_sales_details
WHERE sls_sales IS NULL
   OR sls_quantity IS NULL
   OR sls_price IS NULL
   OR sls_sales <= 0
   OR sls_quantity <= 0
   OR sls_price <= 0
   OR sls_sales != sls_quantity * ABS(sls_price);


-- ========================================================
-- 4. erp_cust_az12 Quality Checks
-- ========================================================

-- 4a. Check for invalid birth dates
-- Expectation: No rows
SELECT DISTINCT bdate
FROM silver.erp_cust_az12
WHERE bdate < '1900-01-01'::date
   OR bdate = CURRENT_DATE;

-- 4b. Check for valid gender values
-- Expectation: Only 'Male', 'Female', or 'n/a'
SELECT DISTINCT gen
FROM silver.erp_cust_az12;


-- ========================================================
-- 5. erp_loc_a101 Quality Checks
-- ========================================================

-- 5a. Check for valid country values
-- Expectation: Only standardized country names or 'n/a'
SELECT DISTINCT cntry
FROM silver.erp_loc_a101;


-- ========================================================
-- 6. erp_px_cat_g1v2 Quality Checks
-- ========================================================

-- 6a. Check for unwanted spaces in category fields
-- Expectation: No rows
SELECT *
FROM bronze.erp_px_cat_g1v2
WHERE TRIM(cat) != cat
   OR TRIM(subcat) != subcat
   OR TRIM(maintenance) != maintenance;
