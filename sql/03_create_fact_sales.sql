-- ============================================================
-- FILE 03: CREATE FACT_SALES
-- Project: NovaBay Executive Sales & Profitability Dashboard
-- Description: Clean sales_raw and create analysis-ready fact table
-- ============================================================

USE novabay_db;

-- Drop if rebuilding
DROP TABLE IF EXISTS fact_sales;

-- Create fact_sales with derived columns
CREATE TABLE fact_sales AS
SELECT
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
    profit,

    -- Derived Column 1: Discount Bucket
    CASE
        WHEN discount_pct <= 0.10 THEN '0-10%'
        WHEN discount_pct <= 0.20 THEN '11-20%'
        WHEN discount_pct <= 0.30 THEN '21-30%'
        ELSE '31%+'
    END AS discount_bucket,

    -- Derived Column 2: Profit Margin %
    ROUND(profit / NULLIF(revenue, 0) * 100, 2) AS profit_margin_pct,

    -- Derived Column 3: Order Year
    YEAR(order_date) AS order_year,

    -- Derived Column 4: Order Month
    MONTH(order_date) AS order_month,

    -- Derived Column 5: Year-Month label
    DATE_FORMAT(order_date, '%Y-%m') AS order_year_month

FROM sales_raw
WHERE revenue >= 0
  AND units_sold > 0
  AND customer_id IS NOT NULL
  AND product_id IS NOT NULL;

-- Add indexes for faster Power BI queries
CREATE INDEX idx_order_date ON fact_sales(order_date);
CREATE INDEX idx_customer   ON fact_sales(customer_id);
CREATE INDEX idx_category   ON fact_sales(category);
CREATE INDEX idx_region     ON fact_sales(region);

-- Verify
SELECT COUNT(*) AS fact_sales_rows FROM fact_sales;
-- Expected: 15000 (same as sales_raw since data is clean)

-- Spot check derived columns
SELECT
    discount_pct,
    discount_bucket,
    profit_margin_pct,
    order_year,
    order_month,
    order_year_month
FROM fact_sales
LIMIT 10;