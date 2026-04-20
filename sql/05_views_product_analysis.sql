-- ============================================================
-- FILE 05: PRODUCT ANALYSIS VIEWS
-- Project: NovaBay Executive Sales & Profitability Dashboard
-- Description: Category margin and product profitability views
-- ============================================================

USE novabay_db;

-- ----------------------
-- View 1: Category Margin
-- ----------------------
DROP VIEW IF EXISTS vw_category_margin;

CREATE VIEW vw_category_margin AS
SELECT
    category,
    ROUND(SUM(revenue), 2)                                      AS total_revenue,
    ROUND(SUM(profit), 2)                                       AS total_profit,
    ROUND(SUM(profit) / NULLIF(SUM(revenue), 0) * 100, 2)      AS profit_margin_pct,
    ROUND(AVG(discount_pct) * 100, 2)                           AS avg_discount_pct,
    ROUND(SUM(freight_cost), 2)                                 AS total_freight,
    RANK() OVER (
        ORDER BY ROUND(SUM(profit) / NULLIF(SUM(revenue), 0) * 100, 2) ASC
    )                                                           AS margin_rank
FROM fact_sales
GROUP BY category;

-- ----------------------
-- View 2: Product Profitability
-- ----------------------
DROP VIEW IF EXISTS vw_product_profitability;

CREATE VIEW vw_product_profitability AS
WITH product_base AS (
    SELECT
        product_id,
        product_name,
        category,
        ROUND(SUM(revenue), 2)                                  AS total_revenue,
        ROUND(SUM(profit), 2)                                   AS total_profit,
        ROUND(SUM(profit) / NULLIF(SUM(revenue), 0) * 100, 2)  AS profit_margin_pct,
        SUM(units_sold)                                         AS total_units
    FROM fact_sales
    GROUP BY product_id, product_name, category
)
SELECT
    product_id,
    product_name,
    category,
    total_revenue,
    total_profit,
    profit_margin_pct,
    total_units,
    RANK() OVER (ORDER BY total_profit DESC) AS profit_rank
FROM product_base;

-- ----------------------
-- Verify View 1
-- ----------------------
SELECT
    category,
    total_revenue,
    total_profit,
    profit_margin_pct,
    avg_discount_pct,
    total_freight,
    margin_rank
FROM vw_category_margin
ORDER BY margin_rank;

-- ----------------------
-- Verify View 2
-- ----------------------
SELECT
    product_name,
    category,
    total_revenue,
    total_profit,
    profit_margin_pct,
    profit_rank
FROM vw_product_profitability
ORDER BY profit_rank
LIMIT 10;