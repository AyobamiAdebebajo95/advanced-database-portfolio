-- =====================================================================
-- NaijaAutoMart - Portfolio 2
-- Script 02: Five real business queries, with their execution plans
--
-- Run this script TWICE:
--   1st time: BEFORE script 03 (no extra indexes)  -> the "before" results
--   2nd time: AFTER  script 03 (indexes created)   -> the "after" results
--
-- EXPLAIN ANALYZE runs the query and shows HOW PostgreSQL ran it
-- (the "execution plan") and how long it took ("Execution Time").
-- BUFFERS shows how many 8 KB pages of data it had to read.
--
-- Words to look for in the plan:
--   Seq Scan          = read EVERY row in the table (slow on big tables)
--   Index Scan        = jump straight to matching rows using an index (fast)
--   Bitmap Index Scan = use an index to find many matching rows, then fetch them
--   Rows Removed by Filter = rows read and then thrown away (wasted work)
--
-- In pgAdmin each plan appears in the Data Output tab. You can also
-- press F7 for a picture of the plan (Explain tab).
-- =====================================================================

-- Q1. Customer order history: "My Orders" page for customer 4521, newest first
EXPLAIN (ANALYZE, BUFFERS)
SELECT order_id, order_date, status
FROM orders
WHERE customer_id = 4521
ORDER BY order_date DESC;

-- Q2. Admin dashboard: all orders still waiting for payment, oldest first
EXPLAIN (ANALYZE, BUFFERS)
SELECT order_id, customer_id, order_date
FROM orders
WHERE status = 'Pending'
ORDER BY order_date;

-- Q3. Login: find a customer by email, ignoring capital letters
--     (people type Chinedu.Okafor@Gmail.com as well as chinedu.okafor@gmail.com)
EXPLAIN (ANALYZE, BUFFERS)
SELECT customer_id, first_name, last_name
FROM customer
WHERE lower(email) = lower('Chinedu.Okafor@Gmail.com');

-- Q4. Seller report: every sale of part 250, with the order date
EXPLAIN (ANALYZE, BUFFERS)
SELECT o.order_id, o.order_date, oi.quantity, oi.unit_price
FROM order_item oi
JOIN orders o ON o.order_id = oi.order_id
WHERE oi.part_id = 250
ORDER BY o.order_date;

-- Q5. Monthly report: revenue by part category for September 2026
EXPLAIN (ANALYZE, BUFFERS)
SELECT pc.category_name,
       COUNT(DISTINCT o.order_id)        AS orders,
       SUM(oi.quantity * oi.unit_price)  AS revenue
FROM orders o
JOIN order_item    oi ON oi.order_id    = o.order_id
JOIN part          p  ON p.part_id      = oi.part_id
JOIN part_category pc ON pc.category_id = p.category_id
WHERE o.order_date >= '2026-09-01' AND o.order_date < '2026-10-01'
  AND o.status <> 'Cancelled'
GROUP BY pc.category_name
ORDER BY revenue DESC;

-- Q6. The COST of indexes: time to insert 10,000 new orders.
--     Every index must also be updated on each insert, so this should get
--     a little SLOWER after script 03. ROLLBACK means nothing is kept.
--     (Status is 'Delivered', not 'Pending': rolled-back rows leave "dead"
--     entries behind until PostgreSQL cleans up, and we don't want them
--     cluttering the small Pending index used by Q2.)
BEGIN;
EXPLAIN (ANALYZE)
INSERT INTO orders (customer_id, order_date, status, delivery_address, delivery_city, delivery_state)
SELECT 1 + g % 20000, TIMESTAMP '2026-10-06' + g * INTERVAL '1 minute', 'Delivered',
       'Test Address', 'Ikeja', 'Lagos'
FROM generate_series(1, 10000) AS g;
ROLLBACK;
