-- =============================================
-- Script: load_bronze_csv.sql
-- Version: 1.0
-- Date: 2026-02-03
-- Author: Data Engineering Team
-- Purpose:
--   Load raw CSV files into Bronze layer tables in the 'bronze' schema.
--   This script assumes the following:
--     1. CSV files are mounted inside the container at /datasets/
--     2. Filenames exactly match those in /datasets/source_crm/ and /datasets/source_erp/
--     3. Columns in CSV match the table definitions
--     4. crm_sales_details date columns are stored as INTEGER
-- Notes:
--   - Run this script inside the Postgres container using psql:
--       docker exec -it my-postgres-container psql -U ${POSTGRES_USER} -d ${POSTGRES_SCHEMA} -f /path/to/load_bronze_csv.sql
-- =============================================

-- ==========================
-- 1. Customer Information
-- ==========================
COPY bronze.crm_cust_info(
    cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date
)
FROM '/datasets/source_crm/cust_info.csv'
DELIMITER ','
CSV HEADER;

-- ==========================
-- 2. Product Information
-- ==========================
COPY bronze.crm_prd_info(
    prd_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt
)
FROM '/datasets/source_crm/prd_info.csv'
DELIMITER ','
CSV HEADER;

-- ==========================
-- 3. Sales Details (dates stored as INTEGER)
-- ==========================
COPY bronze.crm_sales_details(
    sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt,
    sls_sales, sls_quantity, sls_price
)
FROM '/datasets/source_crm/sales_details.csv'
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
