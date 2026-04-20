-- =============================================================================
-- NOVA BAY E-COMMERCE: RAW SALES IMPORT TABLE
-- Purpose: Staging for CSV load (order-line grain: 1 order → many products)
-- =============================================================================

CREATE DATABASE IF NOT EXISTS novabay_db;
USE novabay_db;

DROP TABLE IF EXISTS sales_raw;

CREATE TABLE sales_raw (
    -- Order Identifiers
    order_id         VARCHAR(20)    NOT NULL  COMMENT 'Order ref (duplicates OK)',
    order_date       DATE           NOT NULL  COMMENT 'Transaction date',
    
    -- Customer
    customer_id      VARCHAR(10)    NOT NULL  COMMENT 'Customer ID',
    customer_name    VARCHAR(100)             COMMENT 'Customer name',
    customer_segment VARCHAR(20)              COMMENT 'Consumer|Corp|Small Biz',
    
    -- Location
    region           VARCHAR(20)              COMMENT 'Region name',
    state            VARCHAR(50)               COMMENT 'State/Province',
    sales_channel    VARCHAR(20)              COMMENT 'Online|Offline',
    
    -- Product
    product_id       VARCHAR(20)    NOT NULL  COMMENT 'SKU/Product code',
    product_name     VARCHAR(100)             COMMENT 'Product name',
    category         VARCHAR(50)               COMMENT 'Category',
    
    -- Financials
    unit_price       DECIMAL(10,2)  NOT NULL  COMMENT 'Price per unit',
    units_sold       INT            NOT NULL  COMMENT 'Quantity sold',
    discount_pct     DECIMAL(4,2)   DEFAULT 0.00  COMMENT 'Discount %',
    
    -- Costs & Metrics
    cogs_per_unit    DECIMAL(10,2)            COMMENT 'COGS per unit',
    freight_cost     DECIMAL(10,2)            COMMENT 'Shipping cost',
    revenue          DECIMAL(10,2)            COMMENT 'Net revenue',
    profit           DECIMAL(10,2)            COMMENT 'Order-line profit'
);

-- ===============================================
-- SECTION 3: Verify Table Structure
-- ===============================================

-- Display the table structure to confirm column definitions and data types
DESCRIBE sales_raw;

-- =============================================================================
-- NOVA BAY E-COMMERCE: LOAD RAW SALES DATA FROM CSV
-- Purpose: Import ~15k order-line records into staging table
-- =============================================================================

SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE '...\\novabay_sales_data.csv'
INTO TABLE sales_raw
FIELDS TERMINATED BY ','          -- CSV columns separated by commas
ENCLOSED BY '"'                   -- Text fields in double quotes
LINES TERMINATED BY '\r\n'         -- Each row ends with newline
IGNORE 1 ROWS                     -- Skip CSV header row
(
	order_id,
    order_date,
    customer_id,
    customer_name,
    customer_segment,
    region,
    state,
    sales_channel,
    product_id,
    product_name,
    category,
    unit_price,
    units_sold,
    discount_pct,
    cogs_per_unit,
    freight_cost,
    revenue,
    profit
);

SELECT COUNT(*) as Total_Rows FROM sales_raw;