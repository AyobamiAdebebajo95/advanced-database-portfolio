-- =====================================================================
-- NaijaAutoMart - Portfolio 3
-- Script 04: THE PROBLEM - two customers buy the LAST headlamp
--            (a "lost update" causes overselling)
--
-- There is only 1 Depo headlamp (part 10) left.
-- Chinedu (Tab A) and Aisha (Tab B) open the product page at the same time.
-- Both apps read "1 in stock", both say "OK, buy it", and both write the
-- new stock as 1 - 1 = 0. Two headlamps are sold, but only one existed.
-- Aisha's update silently overwrote Chinedu's: a LOST UPDATE.
--
-- HOW TO RUN: open TWO Query Tool tabs on naijaautomart (Tab A and Tab B).
-- Highlight each STEP and run it (F5) in the tab it names, in order.
-- =====================================================================

-- SETUP - TAB A: reset: 1 headlamp left, remove old demo orders
DELETE FROM order_item WHERE order_id IN (SELECT order_id FROM orders WHERE delivery_address LIKE 'P3 demo%');
DELETE FROM orders WHERE delivery_address LIKE 'P3 demo%';
UPDATE part SET stock_qty = 1 WHERE part_id = 10;
SELECT part_id, part_name, stock_qty FROM part WHERE part_id = 10;

-- STEP 1 - TAB A: Chinedu opens the page and the app reads the stock (sees 1)
BEGIN;
SELECT stock_qty FROM part WHERE part_id = 10;

-- STEP 2 - TAB B: Aisha opens the page at the same moment (ALSO sees 1)
BEGIN;
SELECT stock_qty FROM part WHERE part_id = 10;

-- STEP 3 - TAB A: Chinedu's app: "1 left, so sell it". Writes 1 - 1 = 0, creates the order, commits
UPDATE part SET stock_qty = 0 WHERE part_id = 10;
INSERT INTO orders (customer_id, status, delivery_address, delivery_city, delivery_state)
VALUES (1, 'Paid', 'P3 demo - lost update', 'Ikeja', 'Lagos');
INSERT INTO order_item (order_id, part_id, quantity, unit_price)
VALUES (currval('orders_order_id_seq'), 10, 1, 150000);
COMMIT;

-- STEP 4 - TAB B: Aisha's app ALSO thinks "1 left". Writes 1 - 1 = 0, creates the order, commits
UPDATE part SET stock_qty = 0 WHERE part_id = 10;
INSERT INTO orders (customer_id, status, delivery_address, delivery_city, delivery_state)
VALUES (2, 'Paid', 'P3 demo - lost update', 'Kano', 'Kano');
INSERT INTO order_item (order_id, part_id, quantity, unit_price)
VALUES (currval('orders_order_id_seq'), 10, 1, 150000);
COMMIT;

-- CHECK - TAB A: 2 headlamps sold, stock says 0. One headlamp was OVERSOLD.
SELECT c.first_name AS customer, oi.quantity, o.delivery_address
FROM orders o
JOIN order_item oi ON oi.order_id = o.order_id
JOIN customer c    ON c.customer_id = o.customer_id
WHERE o.delivery_address = 'P3 demo - lost update' AND oi.part_id = 10;
SELECT stock_qty AS stock_now FROM part WHERE part_id = 10;
