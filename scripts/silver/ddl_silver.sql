-- =============================================
-- Script for Silver Layer Tables
-- Drops existing tables and recreates them
-- =============================================

-- ==========================
-- Customer Information Table
-- ==========================
DROP TABLE IF EXISTS silver.crm_cust_info;
CREATE TABLE silver.crm_cust_info (
    cst_id INTEGER,
    cst_key VARCHAR(20),
    cst_firstname VARCHAR(50),
    cst_lastname VARCHAR(50),
    cst_marital_status VARCHAR(10),
    cst_gndr VARCHAR(10),
    cst_create_date DATE,
    dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========================
-- Product Information Table
-- ==========================
DROP TABLE IF EXISTS silver.crm_prd_info;
CREATE TABLE silver.crm_prd_info (
    prd_id INTEGER,
    cat_id VARCHAR(10),
    prd_key VARCHAR(30),
    prd_nm VARCHAR(100),
    prd_cost NUMERIC(10,2),
    prd_line VARCHAR(15),
    prd_start_dt DATE,
    prd_end_dt DATE,
    dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- ==========================
-- Sales Details Table
-- ==========================
DROP TABLE IF EXISTS silver.crm_sales_details;
CREATE TABLE silver.crm_sales_details (
    sls_ord_num VARCHAR(15),
    sls_prd_key VARCHAR(30),
    sls_cust_id INTEGER,
    sls_order_dt DATE,
    sls_ship_dt DATE,
    sls_due_dt DATE,
    sls_sales NUMERIC(10,2),
    sls_quantity INTEGER,
    sls_price NUMERIC(10,2),
    dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========================
-- ERP Customer Table
-- ==========================
DROP TABLE IF EXISTS silver.erp_cust_az12;
CREATE TABLE silver.erp_cust_az12 (
    cid VARCHAR(25),
    bdate DATE,
    GEN VARCHAR(10),
    dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========================
-- ERP Location Table
-- ==========================
DROP TABLE IF EXISTS silver.erp_loc_a101;
CREATE TABLE silver.erp_loc_a101 (
    cid VARCHAR(20),
    cntry VARCHAR(25),
    dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========================
-- ERP Product Category Table
-- ==========================
DROP TABLE IF EXISTS silver.erp_px_cat_g1v2;
CREATE TABLE silver.erp_px_cat_g1v2 (
    id VARCHAR(10),
    cat VARCHAR(25),
    subcat VARCHAR(50),
    maintenance VARCHAR(5),
    dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========================
-- End of Silver Layer Tables
-- ==========================
