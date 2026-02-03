-- =============================================
-- Script: Load Bronze Tables from CSV
-- =============================================
-- Purpose:
-- This script loads raw CSV data files into the Bronze layer tables in the 'bronze' schema.
-- The Bronze layer serves as the raw ingestion layer in the data pipeline.
-- It includes:
--   1. Customer Information (crm_cust_info)
--   2. Product Information (crm_prd_info)
--   3. Sales Details (crm_sales_details)
--   4. ERP Customer Data (erp_cust_az12)
--   5. ERP Location Data (erp_loc_a101)
--   6. ERP Product Category Data (erp_px_cat_g1v2)
-- 
-- Notes:
-- - CSV files must be present at the specified paths inside the Postgres container.
-- - Columns in the CSV files must match the table definitions.
-- - Date columns in crm_sales_details are now stored as INTEGER.
-- - CSV files must have headers; 'CSV HEADER' is used in COPY commands.
-- =============================================

-- ==========================
-- 1. Customer Information
-- ==========================
COPY bronze.crm_cust_info(
    cst_id, 
    cst_key, 
    cst_firstname, 
    cst_lastname, 
    cst_marital_status, 
    cst_gndr, 
    cst_create_date
)
FROM '/datasets/source_crm/crm_cust_info.csv'
DELIMITER ','
CSV HEADER;

-- ==========================
-- 2. Product Information
-- ==========================
COPY bronze.crm_prd_info(
    prd_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt
)
FROM '/datasets/source_crm/crm_prd_info.csv'
DELIMITER ','
CSV HEADER;

-- ==========================
-- 3. Sales Details (dates now integers)
-- ==========================
COPY bronze.crm_sales_details(
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
FROM '/datasets/source_crm/crm_sales_details.csv'
DELIMITER ','
CSV HEADER;

-- ==========================
-- 4. ERP Customer
-- ==========================
COPY bronze.erp_cust_az12(
    cid, bdate, GEN
)
FROM '/datasets/source_erp/CUST_AZ12.csv'
DELIMITER ','
CSV HEADER;

-- ==========================
-- 5. ERP Location
-- ==========================
COPY bronze.erp_loc_a101(
    cid, cntry
)
FROM '/datasets/source_erp/LOC_A101.csv'
DELIMITER ','
CSV HEADER;

-- ==========================
-- 6. ERP Product Category
-- ==========================
COPY bronze.erp_px_cat_g1v2(
    id, cat, subcat, maintenance
)
FROM '/datasets/source_erp/PX_CAT_G1V2.csv'
DELIMITER ','
CSV HEADER;

-- =============================================
-- End of Bronze Layer CSV Load Script
-- =============================================
