# Data Catalog – CRM & ERP Sales Data Warehouse

## Dataset Overview
**Domain:** Sales & Customer Analytics
**Purpose:**
This dataset provides a unified analytical view of customers, products, and sales transactions by integrating CRM transactional data with ERP reference and enrichment data.

**Design Principles:**
	•	Raw schemas preserved
	•	Clear separation of concerns (CRM vs ERP)
	•	Layered warehouse architecture (Bronze → Silver → Gold)
	•	Analytics-ready modeling in Gold layer

---

## **Source Systems**
**CRM (Customer Relationship Management)**

**Role:** System of record for customers, products, and sales transactions.

**ERP (Enterprise Resource Planning)**

**Role:** System of record for customer demographics, location, and product categorization.

---

## **Bronze Layer – Raw Data Catalog**
**Definition:**
The Bronze layer stores raw, unmodified data exactly as received from source systems.
No cleansing, deduplication, or enrichment is performed at this layer.

### **Table: crm_cust_info**
**Source:** CRM
**Grain:** One row per customer
**Business Key:** cst_id

| Column Name         | Data Type     | Description                                  |
|---------------------|--------------|----------------------------------------------|
| cst_id              | INTEGER           | Unique customer identifier from CRM          |
| cst_key             | VARCHAR(20)   | Business customer key                        |
| cst_firstname       | VARCHAR(50)   | Customer first name                          |
| cst_lastname        | VARCHAR(50)   | Customer last name                           |
| cst_marital_status  | CHAR(1)   | Marital status                               |
| cst_gndr            | CHAR(1)       | Gender                                       |
| cst_create_date     | DATE          | Customer creation date in CRM                |

---

### **Table: crm_prod_info**
**Source:** CRM
**Grain:** One row per product version
**Business Key:** prd_id

| Column Name    | Data Type        | Description                          |
|---------------|------------------|--------------------------------------|
| prd_id        | INTEGER          | Product identifier                   |
| prd_key       | VARCHAR(30)      | Business product key                 |
| prd_nm        | VARCHAR(100)     | Product name                         |
| prd_cost      | NUMERIC(10,2)    | Product base cost                    |
| prd_line      | CHAR(1)          | Product line                         |
| prd_start_dt  | DATE             | Product effective start date         |
| prd_end_dt    | DATE             | Product effective end date           |

---

### **Table: crm_sales_details**

**Source:** CRM
**Grain:** One row per order line
**Business Key:** sls_ord_num

| Column Name     | Data Type        | Description                          |
|-----------------|------------------|--------------------------------------|
| sls_ord_num     | VARCHAR(15)      | Sales order number                   |
| sls_prd_key     | VARCHAR(30)      | Product business key                 |
| sls_cust_id     | INTEGER          | Customer identifier                  |
| sls_order_dt    | INTEGER          | Order placement date                 |
| sls_ship_dt     | INTEGER          | Shipping date                        |
| sls_due_dt      | INTEGER          | Due / expected completion date       |
| sls_sales       | NUMERIC(10,2)    | Total sales amount                   |
| sls_quantity    | INTEGER          | Quantity sold                        |
| sls_price       | NUMERIC(10,2)    | Unit price                           |


---

### **Table: cust_az12**

**Source:** ERP
**Grain:** One row per customer
**Business Key:** CID

| Column Name | Data Type     | Description           |
|-------------|--------------|-----------------------|
| cid         | VARCHAR(25)  | Customer identifier   |
| bdate       | DATE         | Birth date            |
| gen         | VARCHAR(10)  | Gender                |


---

### **Table: loc_a101**

**Source:** ERP
**Grain:** One row per customer
Business Key: CID

| Column Name | Data Type     | Description           |
|-------------|--------------|-----------------------|
| cid         | VARCHAR(25)  | Customer identifier   |
| cntry       | VARCHAR(50)  | Country               |

----

### **Table: px_cat_g1v2**

**Source:** ERP
**Grain:** One row per product
**Business Key:** ID

| Column Name  | Data Type     | Description           |
|--------------|--------------|-----------------------|
| id           | INTEGER      | Product identifier    |
| cat          | VARCHAR(50)  | Product category      |
| subcat       | VARCHAR(50)  | Product subcategory   |
| maintenance  | BOOLEAN      | Maintenance flag      |


---

## **Silver Layer – Curated Data (Logical Catalog)**

**Definition:**
The Silver layer standardizes, cleans, and integrates CRM and ERP data.

**Key Entities:**
- Customer (Curated)
- CRM customer + ERP demographics + ERP location
- Product (Curated)
- CRM product + ERP category
- Sales (Cleaned)
- Validated transactional records

**Responsibilities:**
- Deduplication
- Data quality checks
- Standardized naming
- Referential integrity enforcement

### **Table: crm_cust_info**

| Column Name        | Data Type   | Description                                                   |
| ------------------ | ----------- | ------------------------------------------------------------- |
| cst_id             | INTEGER     | Customer ID                                                   |
| cst_key            | VARCHAR(20) | Customer Key                                                  |
| cst_firstname      | VARCHAR(50) | Customer First Name                                           |
| cst_lastname       | VARCHAR(50) | Customer Last Name                                            |
| cst_marital_status | VARCHAR(10) | Marital Status                                                |
| cst_gndr           | VARCHAR(10) | Gender                                                        |
| cst_create_date    | DATE        | Customer Creation Date                                        |
| dwh_create_date    | TIMESTAMP   | Data warehouse creation timestamp (default CURRENT_TIMESTAMP) |

---

### **Table: crm_prd_info**

| Column Name     | Data Type     | Description                                                   |
| --------------- | ------------- | ------------------------------------------------------------- |
| prd_id          | INTEGER       | Product ID                                                    |
| cat_id          | VARCHAR(10)   | Product Category ID                                           |
| prd_key         | VARCHAR(30)   | Product Key                                                   |
| prd_nm          | VARCHAR(100)  | Product Name                                                  |
| prd_cost        | NUMERIC(10,2) | Product Cost                                                  |
| prd_line        | VARCHAR(15)   | Product Line                                                  |
| prd_start_dt    | DATE          | Product Start Date                                            |
| prd_end_dt      | DATE          | Product End Date                                              |
| dwh_create_date | TIMESTAMP     | Data warehouse creation timestamp (default CURRENT_TIMESTAMP) |

---

### **Table: crm_sales_details**

| Column Name     | Data Type     | Description                                                   |
| --------------- | ------------- | ------------------------------------------------------------- |
| sls_ord_num     | VARCHAR(15)   | Sales Order Number                                            |
| sls_prd_key     | VARCHAR(30)   | Product Key                                                   |
| sls_cust_id     | INTEGER       | Customer ID                                                   |
| sls_order_dt    | DATE          | Order Date                                                    |
| sls_ship_dt     | DATE          | Ship Date                                                     |
| sls_due_dt      | DATE          | Due Date                                                      |
| sls_sales       | NUMERIC(10,2) | Sales Amount                                                  |
| sls_quantity    | INTEGER       | Quantity Sold                                                 |
| sls_price       | NUMERIC(10,2) | Price                                                         |
| dwh_create_date | TIMESTAMP     | Data warehouse creation timestamp (default CURRENT_TIMESTAMP) |

---

### **Table: crm_sales_details**

| Column Name     | Data Type     | Description                                                   |
| --------------- | ------------- | ------------------------------------------------------------- |
| sls_ord_num     | VARCHAR(15)   | Sales Order Number                                            |
| sls_prd_key     | VARCHAR(30)   | Product Key                                                   |
| sls_cust_id     | INTEGER       | Customer ID                                                   |
| sls_order_dt    | DATE          | Order Date                                                    |
| sls_ship_dt     | DATE          | Ship Date                                                     |
| sls_due_dt      | DATE          | Due Date                                                      |
| sls_sales       | NUMERIC(10,2) | Sales Amount                                                  |
| sls_quantity    | INTEGER       | Quantity Sold                                                 |
| sls_price       | NUMERIC(10,2) | Price                                                         |
| dwh_create_date | TIMESTAMP     | Data warehouse creation timestamp (default CURRENT_TIMESTAMP) |

---

### **Table: erp_cust_az12**

| Column Name     | Data Type   | Description                                                   |
| --------------- | ----------- | ------------------------------------------------------------- |
| cid             | VARCHAR(25) | Customer identifier                                           |
| bdate           | DATE        | Birth Date                                                    |
| GEN             | VARCHAR(10) | Gender                                                        |
| dwh_create_date | TIMESTAMP   | Data warehouse creation timestamp (default CURRENT_TIMESTAMP) |

--- 

### **Table: erp_loc_a101**

| Column Name     | Data Type   | Description                                                   |
| --------------- | ----------- | ------------------------------------------------------------- |
| cid             | VARCHAR(20) | Customer identifier                                           |
| cntry           | VARCHAR(25) | Country                                                       |
| dwh_create_date | TIMESTAMP   | Data warehouse creation timestamp (default CURRENT_TIMESTAMP) |

--- 

### **Table: erp_px_cat_g1v2**

| Column Name     | Data Type   | Description                                                   |
| --------------- | ----------- | ------------------------------------------------------------- |
| id              | VARCHAR(10) | Category ID                                                   |
| cat             | VARCHAR(25) | Category Name                                                 |
| subcat          | VARCHAR(50) | Subcategory Name                                              |
| maintenance     | VARCHAR(5)  | Maintenance Flag                                              |
| dwh_create_date | TIMESTAMP   | Data warehouse creation timestamp (default CURRENT_TIMESTAMP) |


--- 

## **Gold Layer – Analytics Data Models**

**Definition:**
The Gold layer contains business-ready models optimized for analytics and BI.

### **Dimension: dim_customer**

**Grain:** One row per customer
**Description:**
Provides a consolidated customer profile combining CRM identity with ERP demographics and geography

| Column Name     | Data Type | Description                                      |
| --------------- | --------- | ------------------------------------------------ |
| customer_key    | INT       | Surrogate key generated via `ROW_NUMBER()`       |
| customer_id     | INT       | Original customer identifier from CRM (`cst_id`) |
| customer_number | VARCHAR   | Business customer key (`cst_key`)                |
| first_name      | VARCHAR   | Customer first name                              |
| last_name       | VARCHAR   | Customer last name                               |
| country         | VARCHAR   | Country from ERP location table                  |
| marital_status  | VARCHAR   | Marital status from CRM                          |
| gender          | VARCHAR   | Gender (CRM value preferred; fallback to ERP)    |
| birth_date      | DATE      | Birth date from ERP                              |
| create_date     | DATE      | Customer creation date from CRM                  |


**Notes:**
Surrogate key is generated for dimensional modeling.
Gender resolves n/a from CRM using ERP value.
Missing countries are handled via LEFT JOIN.


---
## **Dimension: dim_product**

**Grain:** One row per product
**Description:**
Provides a unified product view with product attributes and categorization.

| Column Name    | Data Type | Description                                |
| -------------- | --------- | ------------------------------------------ |
| product_key    | INT       | Surrogate key generated via `ROW_NUMBER()` |
| product_id     | INT       | Original product identifier (`prd_id`)     |
| product_number | VARCHAR   | Business product key (`prd_key`)           |
| product_name   | VARCHAR   | Product name                               |
| category_id    | INT       | Category ID from CRM                       |
| category       | VARCHAR   | Product category from ERP                  |
| sub_category   | VARCHAR   | Product subcategory from ERP               |
| maintenance    | BOOLEAN   | Maintenance flag from ERP                  |
| product_line   | CHAR(1)   | Product line from CRM                      |
| start_date     | DATE      | Effective start date of product            |

**Notes:**
Only active products (prd_end_dt IS NULL) are included.
Surrogate key is generated for dimensional modeling.

---

## **Fact: fact_sales**

**Grain:** One row per order line
**Description:**
Captures sales transactions with measures such as sales amount and quantity, linked to customer and product dimensions.


| Column Name    | Data Type     | Description                          | 
|----------------|---------------|--------------------------------------|
| order_number   | VARCHAR(15)   | Sales order number                   | 
| product_key    | INT           | Surrogate key for product            | 
| customer_key   | INT           | Surrogate key for customer           | 
| order_date     | DATE          | Order placement date                 | 
| shipping_date  | DATE          | Shipping date                        | 
| due_date       | DATE          | Expected / due completion date       | 
| sales_amount   | NUMERIC(10,2) | Total sales amount                   |
| quantity       | INTEGER       | Quantity sold                        |
| price          | NUMERIC(10,2) | Unit price                           |

