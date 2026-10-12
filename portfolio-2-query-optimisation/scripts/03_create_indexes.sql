-- =====================================================================
-- NaijaAutoMart - Portfolio 2
-- Script 03: Add indexes to speed up the slow queries
--
-- An INDEX works like the index at the back of a textbook: instead of
-- reading every page (Seq Scan), PostgreSQL looks up where the rows are
-- and jumps straight to them.
--
-- Important: PostgreSQL automatically indexes PRIMARY KEY and UNIQUE
-- columns, but NOT foreign key columns. So orders.customer_id and
-- order_item.part_id had no index until now.
--
-- Run AFTER you have run script 02 once (the "before" results).
-- Then run script 02 again for the "after" results.
-- =====================================================================

-- For Q1 (customer order history).
-- Composite index: finds one customer's orders AND keeps them sorted by date,
-- so no separate sort step is needed.
CREATE INDEX idx_orders_customer_date ON orders (customer_id, order_date DESC);

-- For Q2 (pending orders dashboard).
-- PARTIAL index: only stores the ~2% of orders that are 'Pending',
-- so it is very small, and already sorted by date.
CREATE INDEX idx_orders_pending_date ON orders (order_date) WHERE status = 'Pending';

-- For Q3 (login by email, ignoring capitals).
-- EXPRESSION index on lower(email). The existing UNIQUE index on email
-- cannot be used, because the query searches lower(email), not email.
CREATE INDEX idx_customer_lower_email ON customer (lower(email));

-- For Q4 (sales of one part).
-- order_item's primary key is (order_id, part_id). It helps when searching
-- by order_id, but not by part_id alone, because part_id is the second column.
CREATE INDEX idx_order_item_part ON order_item (part_id);

-- For Q5 (monthly report).
-- Lets PostgreSQL find one month of orders without reading all 200,000.
CREATE INDEX idx_orders_date ON orders (order_date);

-- Update statistics so the planner knows about the new indexes
ANALYZE;

-- How much disk space did the indexes take? (Indexes are not free.)
SELECT indexrelname AS index_name,
       pg_size_pretty(pg_relation_size(indexrelid)) AS size
FROM pg_stat_user_indexes
WHERE indexrelname LIKE 'idx_%'
ORDER BY pg_relation_size(indexrelid) DESC;

-- -----------------------------------------------------------------------
-- To go back to the "before" state, run these:
-- DROP INDEX IF EXISTS idx_orders_customer_date, idx_orders_pending_date,
--     idx_customer_lower_email, idx_order_item_part, idx_orders_date;
-- -----------------------------------------------------------------------
