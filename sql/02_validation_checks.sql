-- ============================================================
-- FILE 02: VALIDATION CHECKS
-- Project: NovaBay Executive Sales & Profitability Dashboard
-- Description: Sanity checks on sales_raw before creating fact_sales
-- Run all checks. Every result should match the expected value.
-- ============================================================

USE novabay_db;

-- Check 1: Total row count
SELECT COUNT(*) AS total_rows
FROM sales_raw;
-- Expected: 15000

-- Check 2: Date range
SELECT 
    MIN(order_date) AS earliest_date,
    MAX(order_date) AS latest_date
FROM sales_raw;
-- Expected: 2022-01-01 to 2024-12-31

-- Check 3: NULL check on critical columns
SELECT
    SUM(CASE WHEN order_id       IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN order_date     IS NULL THEN 1 ELSE 0 END) AS null_order_date,
    SUM(CASE WHEN customer_id    IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
    SUM(CASE WHEN product_id     IS NULL THEN 1 ELSE 0 END) AS null_product_id,
    SUM(CASE WHEN unit_price     IS NULL THEN 1 ELSE 0 END) AS null_unit_price,
    SUM(CASE WHEN units_sold     IS NULL THEN 1 ELSE 0 END) AS null_units_sold,
    SUM(CASE WHEN revenue        IS NULL THEN 1 ELSE 0 END) AS null_revenue,
    SUM(CASE WHEN profit         IS NULL THEN 1 ELSE 0 END) AS null_profit
FROM sales_raw;
-- Expected: all zeros

-- Check 4: Negative revenue
SELECT COUNT(*) AS negative_revenue_rows
FROM sales_raw
WHERE revenue < 0;
-- Expected: 0

-- Check 5: Negative or zero units
SELECT COUNT(*) AS bad_units_rows
FROM sales_raw
WHERE units_sold <= 0;
-- Expected: 0

-- Check 6: Discount outside valid range
SELECT COUNT(*) AS bad_discount_rows
FROM sales_raw
WHERE discount_pct < 0 OR discount_pct > 0.40;
-- Expected: 0

-- Check 7: Duplicate line items (same order + same product)
SELECT 
    order_id,
    product_id,
    COUNT(*) AS occurrences
FROM sales_raw
GROUP BY order_id, product_id
HAVING COUNT(*) > 1
LIMIT 10;
-- Expected: empty result set

-- Check 8: Profit formula validation
SELECT COUNT(*) AS formula_mismatch_rows
FROM sales_raw
WHERE ABS(profit - (revenue - (cogs_per_unit * units_sold) - freight_cost)) > 0.01;
-- Expected: 0

-- Check 9: Unique counts
SELECT
    COUNT(DISTINCT customer_id)  AS unique_customers,
    COUNT(DISTINCT product_id)   AS unique_products,
    COUNT(DISTINCT region)       AS unique_regions,
    COUNT(DISTINCT category)     AS unique_categories,
    COUNT(DISTINCT sales_channel) AS unique_channels
FROM sales_raw;
-- Expected: 50 customers, 20 products, 4 regions, 5 categories, 3 channels

-- Check 10: Revenue by region (confirm West is highest)
SELECT 
    region,
    ROUND(SUM(revenue), 2)        AS total_revenue,
    ROUND(SUM(profit), 2)         AS total_profit,
    ROUND(SUM(profit)/SUM(revenue)*100, 2) AS margin_pct
FROM sales_raw
GROUP BY region
ORDER BY total_revenue DESC;
-- Expected: West highest revenue, West lowest margin