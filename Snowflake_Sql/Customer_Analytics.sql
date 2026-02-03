/* =========================================================
   SECTION 1: DATABASE & SCHEMA SETUP
   Purpose: Create database and raw schema for source data
   ========================================================= */

CREATE DATABASE IF NOT EXISTS analytics_db;
USE DATABASE analytics_db;

CREATE SCHEMA IF NOT EXISTS raw;
USE SCHEMA raw;


/* =========================================================
   SECTION 2: STAGE CREATION (FOR CSV FILES)
   Purpose: Stage to load CSV files from local/Snowflake UI
   ========================================================= */

CREATE OR REPLACE STAGE raw_stage;

SHOW STAGES IN SCHEMA analytics_db.raw;
LIST @raw_stage;


/* =========================================================
   SECTION 3: RAW TABLE CREATION
   Purpose: Create raw source tables (no transformations)
   ========================================================= */

DROP TABLE IF EXISTS customers;

CREATE OR REPLACE TABLE customers (
    customer_id STRING,
    customer_name STRING,
    city STRING,
    country STRING,
    signup_date DATE
);

DROP TABLE IF EXISTS orders;

CREATE OR REPLACE TABLE orders (
    order_id STRING,
    customer_id STRING,
    order_date DATE,
    amount NUMBER(10,2)
);


/* =========================================================
   SECTION 4: FILE FORMAT DEFINITION
   Purpose: Define CSV format for data loading
   ========================================================= */

CREATE OR REPLACE FILE FORMAT csv_semicolon_format
TYPE = 'CSV'
FIELD_DELIMITER = ';'
SKIP_HEADER = 1
FIELD_OPTIONALLY_ENCLOSED_BY = '"'
TRIM_SPACE = TRUE
ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE;


/* =========================================================
   SECTION 5: LOAD DATA INTO RAW TABLES
   Purpose: Copy CSV data from stage into raw tables
   ========================================================= */

COPY INTO orders
FROM (
    SELECT $1, $2, $3, $4
    FROM @raw_stage/orders.csv
)
FILE_FORMAT = csv_semicolon_format;

SELECT * FROM orders;

COPY INTO customers
FROM (
    SELECT $1, $2, $3, $4, $5
    FROM @raw_stage/customers.csv
)
FILE_FORMAT = csv_semicolon_format;

SELECT * FROM customers;


/* =========================================================
   SECTION 6: STAGING LAYER (CLEANED DATA)
   Purpose: Basic cleaning & standardization
   ========================================================= */

CREATE SCHEMA IF NOT EXISTS staging;

CREATE OR REPLACE TABLE staging.stg_orders AS
SELECT
    order_id,
    customer_id,
    TO_DATE(order_date) AS order_date,
    amount
FROM raw.orders;

SELECT * FROM staging.stg_orders;

CREATE OR REPLACE TABLE staging.stg_customers AS
SELECT
    customer_id,
    customer_name,
    city,
    country,
    signup_date
FROM raw.customers;

SELECT * FROM staging.stg_customers;


/* =========================================================
   SECTION 7: ANALYTICS LAYER (DIMENSIONS & FACTS)
   Purpose: Star schema for analytics & BI tools
   ========================================================= */

CREATE SCHEMA IF NOT EXISTS analytics;

CREATE OR REPLACE TABLE analytics.customers_dim AS
SELECT
    customer_id,
    customer_name,
    city,
    country,
    signup_date
FROM staging.stg_customers;

CREATE OR REPLACE TABLE analytics.orders_fact AS
SELECT
    o.order_id,
    o.customer_id,
    c.customer_name,
    o.order_date,
    o.amount
FROM staging.stg_orders o
JOIN staging.stg_customers c
    ON o.customer_id = c.customer_id;

SELECT * FROM analytics.orders_fact;
SELECT * FROM analytics.customers_dim;


/* =========================================================
   SECTION 8: ENVIRONMENT CHECKS
   Purpose: Verify Snowflake context
   ========================================================= */

SELECT
    CURRENT_ACCOUNT(),
    CURRENT_REGION(),
    CURRENT_WAREHOUSE(),
    CURRENT_DATABASE(),
    CURRENT_SCHEMA(),
    CURRENT_ROLE();


/* =========================================================
   SECTION 9: ROLE & ACCESS MANAGEMENT
   Purpose: Create ANALYST role with read-only access
   ========================================================= */

CREATE ROLE IF NOT EXISTS analyst;

GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE analyst;
GRANT USAGE ON DATABASE analytics_db TO ROLE analyst;
GRANT USAGE ON SCHEMA analytics_db.analytics TO ROLE analyst;

GRANT SELECT ON ALL TABLES IN SCHEMA analytics_db.analytics TO ROLE analyst;
GRANT SELECT ON FUTURE TABLES IN SCHEMA analytics_db.analytics TO ROLE analyst;

GRANT ROLE analyst TO USER meenakshisubramaniam;

USE ROLE analyst;

SELECT * 
FROM analytics_db.analytics.customer_metrics 
LIMIT 10;


/* =========================================================
   SECTION 10: CLEANUP (INCORRECT SCHEMAS)
   Purpose: Remove dbt-generated duplicate schemas
   ========================================================= */

DROP SCHEMA IF EXISTS analytics_db.analytics_analytics CASCADE;
DROP SCHEMA IF EXISTS analytics_db.analytics_staging CASCADE;
