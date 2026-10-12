-- =====================================================================
-- NaijaAutoMart - Portfolio 3
-- Script 06: FIX 2 - check and reduce stock in ONE statement
--            (atomic conditional update)
--
-- Instead of "read the stock, then write it back", do both at once:
--     UPDATE part SET stock_qty = stock_qty - 1
--     WHERE part_id = 10 AND stock_qty >= 1;
-- PostgreSQL locks the row while updating it. The second buyer waits,
-- then re-checks "stock_qty >= 1" on the NEW value (0), so their update
-- changes 0 rows ("UPDATE 0"). The app sees 0 rows changed = sold out.
--
-- Extra safety net: the CHECK (stock_qty >= 0) rule from Portfolio 1
-- would block the stock going negative even if the app forgot the WHERE.
--
-- HOW TO RUN: two Query Tool tabs. Run each STEP in the tab it names.
-- In STEP 2, Tab B WAITS until Tab A commits in STEP 3.
-- =====================================================================

-- SETUP - TAB A: reset: 1 headlamp left, remove old demo orders
DELETE FROM order_item WHERE order_id IN (SELECT order_id FROM orders WHERE delivery_address LIKE 'P3 demo%');
DELETE FROM orders WHERE delivery_address LIKE 'P3 demo%';
UPDATE part SET stock_qty = 1 WHERE part_id = 10;
SELECT part_id, part_name, stock_qty FROM part WHERE part_id = 10;

-- STEP 1 - TAB A: Chinedu takes the headlamp (Messages tab shows UPDATE 1 = success)
BEGIN;
UPDATE part SET stock_qty = stock_qty - 1 WHERE part_id = 10 AND stock_qty >= 1;

-- STEP 2 - TAB B: Aisha tries at the same moment. She WAITS for Chinedu's transaction.
BEGIN;
UPDATE part SET stock_qty = stock_qty - 1 WHERE part_id = 10 AND stock_qty >= 1;

-- STEP 3 - TAB A: Chinedu's order is saved and committed
INSERT INTO orders (customer_id, status, delivery_address, delivery_city, delivery_state)
VALUES (1, 'Paid', 'P3 demo - atomic update', 'Ikeja', 'Lagos');
INSERT INTO order_item (order_id, part_id, quantity, unit_price)
VALUES (currval('orders_order_id_seq'), 10, 1, 150000);
COMMIT;

-- STEP 4 - TAB B: Aisha's STEP 2 now finishes with UPDATE 0 (no stock). Her app cancels.
ROLLBACK;

-- CHECK - TAB A: one sale, stock 0
SELECT c.first_name AS customer, oi.quantity, o.delivery_address
FROM orders o
JOIN order_item oi ON oi.order_id = o.order_id
JOIN customer c    ON c.customer_id = o.customer_id
WHERE o.delivery_address = 'P3 demo - atomic update' AND oi.part_id = 10;
SELECT stock_qty AS stock_now FROM part WHERE part_id = 10;
