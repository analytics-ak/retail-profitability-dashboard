-- ============================================================
-- FILE 06: REGIONAL ANALYSIS VIEW
-- Project: NovaBay Executive Sales & Profitability Dashboard
-- Description: Region and state level performance view
-- ============================================================

USE novabay_db;

DROP VIEW IF EXISTS vw_region_performance;

CREATE VIEW vw_region_performance AS
SELECT
    region,
    state,
    ROUND(SUM(revenue), 2)                                          AS total_revenue,
    ROUND(SUM(profit), 2)                                           AS total_profit,
    ROUND(SUM(profit) / NULLIF(SUM(revenue), 0) * 100, 2)          AS profit_margin_pct,
    COUNT(DISTINCT customer_id)                                     AS unique_customers,
    COUNT(DISTINCT order_id)                                        AS total_orders,
    ROUND(AVG(discount_pct) * 100, 2)                               AS avg_discount_pct,
    ROUND(SUM(profit) / NULLIF(COUNT(DISTINCT order_id), 0), 2)    AS profit_per_order
FROM fact_sales
GROUP BY region, state;

-- Verify: Region level summary
SELECT
    region,
    ROUND(SUM(total_revenue), 2)                                        AS region_revenue,
    ROUND(SUM(total_profit), 2)                                         AS region_profit,
    ROUND(SUM(total_profit) / NULLIF(SUM(total_revenue), 0) * 100, 2)  AS region_margin_pct,
    ROUND(AVG(avg_discount_pct), 2)                                     AS avg_discount,
    SUM(total_orders)                                                   AS total_orders
FROM vw_region_performance
GROUP BY region
ORDER BY region_revenue DESC;

-- Verify: State level detail
SELECT
    region,
    state,
    total_revenue,
    total_profit,
    profit_margin_pct,
    avg_discount_pct,
    profit_per_order
FROM vw_region_performance
ORDER BY region, total_revenue DESC;