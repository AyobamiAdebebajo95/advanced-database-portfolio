-- =====================================================================
-- NaijaAutoMart - Portfolio 2
-- Script 04: Speeding up the monthly report (Q5) with a MATERIALIZED VIEW
--
-- Problem: the index on order_date helped Q5 find September's orders,
-- but Q5 was still slow, because it then had to read ALL 500,000
-- order items to join them. An index cannot fix that.
--
-- Fix: a MATERIALIZED VIEW is a saved copy of a query's RESULT.
-- We calculate revenue for every month and category ONCE and store it.
-- The report then reads a handful of pre-calculated rows.
--
-- Trade-off: the saved result does not update by itself. It must be
-- refreshed (e.g. every night) with: REFRESH MATERIALIZED VIEW monthly_category_revenue;
-- That is fine for a monthly report, but not for live data like stock levels.
--
-- Run AFTER script 03.
-- =====================================================================

DROP MATERIALIZED VIEW IF EXISTS monthly_category_revenue;

CREATE MATERIALIZED VIEW monthly_category_revenue AS
SELECT date_trunc('month', o.order_date)::date AS month,
       pc.category_name,
       COUNT(DISTINCT o.order_id)              AS orders,
       SUM(oi.quantity * oi.unit_price)        AS revenue
FROM orders o
JOIN order_item    oi ON oi.order_id    = o.order_id
JOIN part          p  ON p.part_id      = oi.part_id
JOIN part_category pc ON pc.category_id = p.category_id
WHERE o.status <> 'Cancelled'
GROUP BY 1, 2;

CREATE INDEX idx_mcr_month ON monthly_category_revenue (month);
ANALYZE monthly_category_revenue;

-- Q5 again, now reading the materialized view instead of the raw tables
EXPLAIN (ANALYZE, BUFFERS)
SELECT category_name, orders, revenue
FROM monthly_category_revenue
WHERE month = '2026-09-01'
ORDER BY revenue DESC;

-- Same answer as the original Q5? (it should match)
SELECT category_name, orders, revenue
FROM monthly_category_revenue
WHERE month = '2026-09-01'
ORDER BY revenue DESC;
