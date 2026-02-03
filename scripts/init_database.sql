-- ===============================================
-- SQL Data Warehouse Setup Script (PostgreSQL)
-- Author: Lokesh K V
-- Purpose: Create data warehouse database and schemas
-- ===============================================

-- 1. Create the data warehouse database if it does not exist
-- Note: In PostgreSQL, CREATE DATABASE cannot be run inside a transaction block.
-- You may need to connect as a superuser or admin user to execute this.
DO
$$
BEGIN
    IF NOT EXISTS (
        SELECT FROM pg_database WHERE datname = 'datawarehouse'
    ) THEN
        PERFORM dblink_exec('dbname=postgres', 'CREATE DATABASE datawarehouse');
    END IF;
END
$$;

-- Connect to the new database (run this in your client after creating DB)
-- \c datawarehouse;

-- 2. Create schemas for different data layers
-- Bronze: Raw, ingested data
-- Silver: Cleaned and validated data
-- Gold: Aggregated/analytics-ready data
CREATE SCHEMA IF NOT EXISTS bronze;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;


-- ===============================================
-- End of Data Warehouse Header Script
-- ===============================================
