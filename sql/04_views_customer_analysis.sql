-- ============================================================
-- FILE 04: CUSTOMER ANALYSIS VIEWS
-- Project: NovaBay Executive Sales & Profitability Dashboard
-- Description: Customer profitability view with ranking
-- ============================================================

USE novabay_db;

DROP VIEW IF EXISTS vw_customer_profitability;

CREATE VIEW vw_customer_profitability AS
WITH customer_base AS (
    SELECT
        customer_id,
        customer_name,
        customer_segment,
        SUM(revenue)                                        AS total_revenue,
        SUM(profit)                                         AS total_profit,
        COUNT(DISTINCT order_id)                            AS total_orders,
        ROUND(SUM(profit) / NULLIF(COUNT(DISTINCT order_id), 0), 2) AS profit_per_order,
        ROUND(AVG(discount_pct) * 100, 2)                  AS avg_discount_pct,
        ROUND(SUM(profit) / NULLIF(SUM(revenue), 0) * 100, 2) AS profit_margin_pct
    FROM fact_sales
    GROUP BY customer_id, customer_name, customer_segment
)
SELECT
    customer_id,
    customer_name,
    customer_segment,
    ROUND(total_revenue, 2)      AS total_revenue,
    ROUND(total_profit, 2)       AS total_profit,
    total_orders,
    profit_per_order,
    avg_discount_pct,
    profit_margin_pct,
    ROW_NUMBER() OVER (ORDER BY total_profit  DESC) AS profit_row_num,
    RANK()       OVER (ORDER BY total_profit  DESC) AS profit_rank,
    RANK()       OVER (ORDER BY total_revenue DESC) AS revenue_rank,
    CASE
        WHEN ROW_NUMBER() OVER (ORDER BY total_profit DESC) <= 10
        THEN 1 ELSE 0
    END AS is_top10_profit
FROM customer_base;

-- Verify
SELECT
    customer_id,
    customer_name,
    total_revenue,
    total_profit,
    profit_margin_pct,
    profit_rank,
    revenue_rank,
    is_top10_profit
FROM vw_customer_profitability
ORDER BY revenue_rank
LIMIT 15;