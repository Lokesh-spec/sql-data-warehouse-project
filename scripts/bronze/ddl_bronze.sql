-- =============================================
-- Starter Script for Bronze Layer Tables
-- Drops existing tables and recreates them
-- =============================================

-- ==========================
-- Customer Information Table
-- ==========================
DROP TABLE IF EXISTS bronze.crm_cust_info;
CREATE TABLE bronze.crm_cust_info (
    cst_id INTEGER,
    cst_key VARCHAR(20),
    cst_firstname VARCHAR(50),
    cst_lastname VARCHAR(50),
    cst_marital_status CHAR(1),
    cst_gndr CHAR(1),
    cst_create_date DATE
);

-- ==========================
-- Product Information Table
-- ==========================
DROP TABLE IF EXISTS bronze.crm_prd_info;
CREATE TABLE bronze.crm_prd_info (
    prd_id INTEGER,
    prd_key VARCHAR(30),
    prd_nm VARCHAR(100),
    prd_cost NUMERIC(10,2),
    prd_line CHAR(1),
    prd_start_dt DATE,
    prd_end_dt DATE
);

-- ==========================
-- Sales Details Table
-- ==========================
DROP TABLE IF EXISTS bronze.crm_sales_details;
CREATE TABLE bronze.crm_sales_details (
    sls_ord_num VARCHAR(15),
    sls_prd_key VARCHAR(30),
    sls_cust_id INTEGER,
    sls_order_dt INTEGER,
    sls_ship_dt INTEGER,
    sls_due_dt INTEGER,
    sls_sales NUMERIC(10,2),
    sls_quantity INTEGER,
    sls_price NUMERIC(10,2)
);

-- ==========================
-- ERP Customer Table
-- ==========================
DROP TABLE IF EXISTS bronze.erp_cust_az12;
CREATE TABLE bronze.erp_cust_az12 (
    cid VARCHAR(25),
    bdate DATE,
    GEN VARCHAR(10)
);

-- ==========================
-- ERP Location Table
-- ==========================
DROP TABLE IF EXISTS bronze.erp_loc_a101;
CREATE TABLE bronze.erp_loc_a101 (
    cid VARCHAR(20),
    cntry VARCHAR(25)
);

-- ==========================
-- ERP Product Category Table
-- ==========================
DROP TABLE IF EXISTS bronze.erp_px_cat_g1v2;
CREATE TABLE bronze.erp_px_cat_g1v2 (
    id VARCHAR(10),
    cat VARCHAR(25),
    subcat VARCHAR(50),
    maintenance VARCHAR(5)
);

-- ==========================
-- End of Bronze Layer Tables
-- ==========================
