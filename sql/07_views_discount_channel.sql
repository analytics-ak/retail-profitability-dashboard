-- ============================================================
-- FILE 07: DISCOUNT AND CHANNEL ANALYSIS VIEWS
-- Project: NovaBay Executive Sales & Profitability Dashboard
-- Description: Discount impact and channel efficiency views
-- ============================================================

USE novabay_db;

-- ----------------------
-- View 1: Discount Impact
-- ----------------------
DROP VIEW IF EXISTS vw_discount_impact;

CREATE VIEW vw_discount_impact AS
SELECT
    discount_bucket,
    COUNT(*)                                                    AS line_items,
    ROUND(SUM(revenue), 2)                                      AS total_revenue,
    ROUND(SUM(profit), 2)                                       AS total_profit,
    ROUND(SUM(profit) / NULLIF(SUM(revenue), 0) * 100, 2)      AS profit_margin_pct,
    ROUND(AVG(discount_pct) * 100, 2)                           AS avg_discount_pct
FROM fact_sales
GROUP BY discount_bucket;

-- ----------------------
-- View 2: Channel Efficiency
-- ----------------------
DROP VIEW IF EXISTS vw_channel_efficiency;

CREATE VIEW vw_channel_efficiency AS
SELECT
    sales_channel,
    ROUND(SUM(revenue), 2)                                          AS total_revenue,
    ROUND(SUM(profit), 2)                                           AS total_profit,
    ROUND(SUM(profit) / NULLIF(SUM(revenue), 0) * 100, 2)          AS profit_margin_pct,
    COUNT(DISTINCT order_id)                                        AS total_orders,
    ROUND(SUM(profit) / NULLIF(COUNT(DISTINCT order_id), 0), 2)    AS profit_per_order,
    ROUND(SUM(revenue) / SUM(SUM(revenue)) OVER () * 100, 2)       AS revenue_share_pct,
    ROUND(SUM(profit)  / SUM(SUM(profit))  OVER () * 100, 2)       AS profit_share_pct,
    ROUND(AVG(discount_pct) * 100, 2)                               AS avg_discount_pct
FROM fact_sales
GROUP BY sales_channel;

-- ----------------------
-- Verify View 1
-- ----------------------
SELECT
    discount_bucket,
    line_items,
    total_revenue,
    total_profit,
    profit_margin_pct,
    avg_discount_pct
FROM vw_discount_impact
ORDER BY avg_discount_pct;

-- ----------------------
-- Verify View 2
-- ----------------------
SELECT
    sales_channel,
    total_revenue,
    total_profit,
    profit_margin_pct,
    total_orders,
    profit_per_order,
    revenue_share_pct,
    profit_share_pct,
    avg_discount_pct
FROM vw_channel_efficiency
ORDER BY profit_per_order DESC;