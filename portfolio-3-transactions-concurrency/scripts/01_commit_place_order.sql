-- =====================================================================
-- NaijaAutoMart - Portfolio 3: Transactions and Concurrency
-- Script 01: COMMIT - placing an order as ONE transaction
--
-- A TRANSACTION groups several changes so they succeed or fail TOGETHER.
-- Placing an order touches 4 tables:
--   1. orders      (new order)
--   2. order_item  (the parts in it)
--   3. part        (reduce stock)
--   4. payment     (record the payment)
-- If only some of these were saved (e.g. stock reduced but no order),
-- the data would be wrong. BEGIN ... COMMIT makes it all-or-nothing.
--
-- HOW TO RUN: use ONE Query Tool tab. Highlight each STEP (from its
-- STEP line down to the next STEP line) and press F5. Look at the
-- Data Output tab (tables) and the Messages tab after each step.
-- (If you run the whole file at once, pgAdmin only shows the LAST result.)
--
-- Tunde Adeyemi (customer 3) buys 1 Varta battery (part 2) and
-- 2 pairs of Philips H4 bulbs (part 15).
-- =====================================================================

-- STEP 1 - TAB A: BEFORE - check the stock levels
SELECT part_id, part_name, brand, stock_qty AS stock_before
FROM part WHERE part_id IN (2, 15) ORDER BY part_id;

-- STEP 2 - TAB A: place the order as one transaction
BEGIN;   -- start the transaction

    -- 1. Create the order
    INSERT INTO orders (customer_id, status, delivery_address, delivery_city, delivery_state)
    VALUES (3, 'Paid', '18 Ring Road', 'Ibadan', 'Oyo');

    -- 2. Add the parts (currval = the order_id just created in THIS session)
    INSERT INTO order_item (order_id, part_id, quantity, unit_price) VALUES
        (currval('orders_order_id_seq'),  2, 1, 95000),
        (currval('orders_order_id_seq'), 15, 2,  9500);

    -- 3. Reduce stock
    UPDATE part SET stock_qty = stock_qty - 1 WHERE part_id = 2;
    UPDATE part SET stock_qty = stock_qty - 2 WHERE part_id = 15;

    -- 4. Record the payment (95,000 + 2 x 9,500 = 114,000)
    INSERT INTO payment (order_id, amount, method, status)
    VALUES (currval('orders_order_id_seq'), 114000, 'Card', 'Successful');

COMMIT;  -- save ALL four changes permanently, together

-- STEP 3 - TAB A: AFTER - stock has gone down
SELECT part_id, part_name, brand, stock_qty AS stock_after
FROM part WHERE part_id IN (2, 15) ORDER BY part_id;

-- STEP 4 - TAB A: AFTER - the order, its items and its payment all exist
SELECT o.order_id, o.status, oi.part_id, oi.quantity, oi.unit_price,
       pay.amount AS paid, pay.method
FROM orders o
JOIN order_item oi ON oi.order_id = o.order_id
JOIN payment pay   ON pay.order_id = o.order_id
WHERE o.order_id = currval('orders_order_id_seq');
