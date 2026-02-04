-- =============================================
-- Start Script for Gold Layer
-- This script creates dimensional and fact views 
-- in the Gold layer based on the Silver layer tables
-- =============================================

-- ================================
-- 1. Create Customer Dimension View
-- ================================
-- Purpose: Build a unified customer dimension
-- by combining CRM customer info with ERP customer and location data
DROP VIEW IF EXISTS gold.dim_customers;

CREATE VIEW gold.dim_customers AS 
SELECT 
    -- Assign a unique surrogate key for the dimension
    ROW_NUMBER() OVER(ORDER BY ci.cst_id) AS customer_key,
    
    -- Natural keys from source systems
    ci.cst_id AS customer_id,
    ci.cst_key AS customer_number,
    
    -- Customer name fields
    ci.cst_firstname AS first_name,
    ci.cst_lastname AS last_name,
    
    -- Location information
    lo.cntry AS country,
    
    -- Marital status from CRM
    ci.cst_marital_status AS marital_status,
    
    -- Gender: prefer CRM if available, fallback to ERP
    CASE
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
        ELSE COALESCE(ca.gen, 'n/a')
    END AS gender,
    
    -- Birth date from ERP
    ca.bdate AS birth_date,
    
    -- Creation date from CRM
    ci.cst_create_date AS create_date

FROM silver.crm_cust_info ci

-- Join ERP customer info for additional attributes
LEFT JOIN silver.erp_cust_az12 ca
  ON ci.cst_key = ca.cid

-- Join ERP location info for country
LEFT JOIN silver.erp_loc_a101 lo
  ON ci.cst_key = lo.cid;


-- ================================
-- 2. Create Product Dimension View
-- ================================
-- Purpose: Build a unified product dimension 
-- by combining CRM product info with ERP product category data
DROP VIEW IF EXISTS gold.dim_products;

CREATE VIEW gold.dim_products AS 
SELECT 
    -- Surrogate key for product dimension
    ROW_NUMBER() OVER(ORDER BY pi.prd_start_dt, pi.prd_key) AS product_key,
    
    -- Natural keys from source systems
    pi.prd_id AS product_id,
    pi.prd_key AS product_number,
    
    -- Product descriptive fields
    pi.prd_nm AS product_name,
    pi.cat_id AS category_id,
    epc.cat AS category,
    epc.subcat AS sub_category,
    epc.maintenance,
    pi.prd_line AS product_line,
    pi.prd_start_dt AS start_date

FROM silver.crm_prd_info pi

-- Join ERP category table for descriptive attributes
LEFT JOIN silver.erp_px_cat_g1v2 epc
  ON epc.id = pi.cat_id

-- Only include active products
WHERE pi.prd_end_dt IS NULL;


-- ================================
-- 3. Create Fact Sales Table
-- ================================
-- Purpose: Build a fact table of sales transactions 
-- by linking to customer and product dimensions
-- Uncomment CREATE VIEW if you want to persist it as a view

-- DROP VIEW IF EXISTS gold.fact_sales;

-- CREATE VIEW gold.fact_sales AS
SELECT 
    csd.sls_ord_num AS order_number,
    
    -- Link to product dimension surrogate key
    dp.product_key,
    
    -- Link to customer dimension surrogate key
    dc.customer_key,
    
    -- Dates of the sales transaction
    csd.sls_order_dt AS order_date,
    csd.sls_ship_dt AS shipping_date,
    csd.sls_due_dt AS due_date,
    
    -- Sales metrics
    csd.sls_sales AS sales_amount,
    csd.sls_quantity AS quantity,
    csd.sls_price AS price

FROM silver.crm_sales_details AS csd

-- Join product dimension
LEFT JOIN gold.dim_products AS dp
  ON csd.sls_prd_key = dp.product_number

-- Join customer dimension
LEFT JOIN gold.dim_customers AS dc
  ON csd.sls_cust_id = dc.customer_id;
-- =============================================
