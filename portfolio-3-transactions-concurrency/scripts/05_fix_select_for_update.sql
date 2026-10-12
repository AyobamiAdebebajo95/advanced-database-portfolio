-- =====================================================================
-- NaijaAutoMart - Portfolio 3
-- Script 05: FIX 1 - lock the row with SELECT ... FOR UPDATE
--            (pessimistic locking)
--
-- Same situation as script 04: 1 headlamp left, two buyers.
-- This time the app reads the stock with FOR UPDATE. That LOCKS the row:
-- anyone else who tries to lock it must WAIT until the first transaction
-- finishes. When Aisha's read finally runs, she sees the TRUE stock (0).
--
-- HOW TO RUN: two Query Tool tabs (Tab A and Tab B). Run each STEP in the
-- tab it names, in order. In STEP 2, Tab B will keep spinning ("waiting")
-- - that is the lock working. Go to Tab A and run STEP 3.
-- =====================================================================

-- SETUP - TAB A: reset: 1 headlamp left, remove old demo orders
DELETE FROM order_item WHERE order_id IN (SELECT order_id FROM orders WHERE delivery_address LIKE 'P3 demo%');
DELETE FROM orders WHERE delivery_address LIKE 'P3 demo%';
UPDATE part SET stock_qty = 1 WHERE part_id = 10;
SELECT part_id, part_name, stock_qty FROM part WHERE part_id = 10;

-- STEP 1 - TAB A: Chinedu's app reads AND LOCKS the row (sees 1)
BEGIN;
SELECT stock_qty FROM part WHERE part_id = 10 FOR UPDATE;

-- STEP 2 - TAB B: Aisha's app tries to read and lock the same row. It WAITS.
BEGIN;
SELECT stock_qty FROM part WHERE part_id = 10 FOR UPDATE;

-- STEP 3 - TAB A: Chinedu buys it and commits. This releases the lock.
UPDATE part SET stock_qty = stock_qty - 1 WHERE part_id = 10;
INSERT INTO orders (customer_id, status, delivery_address, delivery_city, delivery_state)
VALUES (1, 'Paid', 'P3 demo - for update', 'Ikeja', 'Lagos');
INSERT INTO order_item (order_id, part_id, quantity, unit_price)
VALUES (currval('orders_order_id_seq'), 10, 1, 150000);
COMMIT;

-- STEP 4 - TAB B: Aisha's STEP 2 has now finished and shows 0. Her app says "Sold out" and cancels.
ROLLBACK;

-- CHECK - TAB A: only ONE headlamp sold, stock is 0. No overselling.
SELECT c.first_name AS customer, oi.quantity, o.delivery_address
FROM orders o
JOIN order_item oi ON oi.order_id = o.order_id
JOIN customer c    ON c.customer_id = o.customer_id
WHERE o.delivery_address = 'P3 demo - for update' AND oi.part_id = 10;
SELECT stock_qty AS stock_now FROM part WHERE part_id = 10;
