-- =====================================================================
-- NaijaAutoMart - Portfolio 3
-- Script 02: ROLLBACK and SAVEPOINT
--
-- ROLLBACK cancels EVERYTHING done since BEGIN, as if it never happened.
-- SAVEPOINT marks a point inside a transaction you can go back to,
-- undoing only part of the work.
--
-- HOW TO RUN: use ONE Query Tool tab. Highlight each STEP (from its
-- STEP line down to the next STEP line) and press F5. Look at the
-- Data Output tab (tables) and the Messages tab after each step.
-- (If you run the whole file at once, pgAdmin only shows the LAST result.)
-- =====================================================================

-- ---------------------------------------------------------------------
-- PART A: ROLLBACK - the card payment is declined, so cancel everything
-- Segun Ogunleye (customer 9) tries to buy a 100Ah battery (part 12).
-- ---------------------------------------------------------------------

-- STEP 1 - TAB A: BEFORE - count orders and check battery stock
SELECT (SELECT COUNT(*) FROM orders)                       AS orders_before,
       (SELECT stock_qty FROM part WHERE part_id = 12)     AS battery_stock_before;

-- STEP 2 - TAB A: start the order (the stock looks reduced INSIDE the transaction)
BEGIN;
    INSERT INTO orders (customer_id, status, delivery_address, delivery_city, delivery_state)
    VALUES (9, 'Pending', '3 Lafenwa Road', 'Abeokuta', 'Ogun');

    INSERT INTO order_item (order_id, part_id, quantity, unit_price)
    VALUES (currval('orders_order_id_seq'), 12, 1, 135000);

    UPDATE part SET stock_qty = stock_qty - 1 WHERE part_id = 12;

    -- Inside the transaction, the changes ARE visible to this session:
    SELECT stock_qty AS stock_inside_transaction FROM part WHERE part_id = 12;

-- STEP 3 - TAB A: the payment gateway says "Card declined", so undo everything
ROLLBACK;

-- STEP 4 - TAB A: AFTER - same number of orders, same stock. Nothing was saved.
SELECT (SELECT COUNT(*) FROM orders)                       AS orders_after,
       (SELECT stock_qty FROM part WHERE part_id = 12)     AS battery_stock_after;

-- ---------------------------------------------------------------------
-- PART B: SAVEPOINT - keep the order, but drop one item
-- Ngozi Eze (customer 4) orders an oil filter (part 4) and then adds a
-- stabiliser link (part 14). Part 14 is OUT OF STOCK, so only that item
-- is undone. The rest of the order is kept.
-- ---------------------------------------------------------------------

-- STEP 5 - TAB A: order with a SAVEPOINT, then undo only the second item
BEGIN;
    INSERT INTO orders (customer_id, status, delivery_address, delivery_city, delivery_state)
    VALUES (4, 'Paid', '9 Ogui Road', 'Enugu', 'Enugu');

    INSERT INTO order_item (order_id, part_id, quantity, unit_price)
    VALUES (currval('orders_order_id_seq'), 4, 1, 6500);
    UPDATE part SET stock_qty = stock_qty - 1 WHERE part_id = 4;

    SAVEPOINT before_second_item;      -- remember this point

    INSERT INTO order_item (order_id, part_id, quantity, unit_price)
    VALUES (currval('orders_order_id_seq'), 14, 1, 18000);

    -- The app checks stock for part 14 and finds 0 -> undo ONLY the second item
    SELECT stock_qty AS stabiliser_link_stock FROM part WHERE part_id = 14;
    ROLLBACK TO SAVEPOINT before_second_item;

COMMIT;   -- the order and the oil filter are saved

-- STEP 6 - TAB A: AFTER - the new order has ONE item (the oil filter), not two
SELECT o.order_id, o.customer_id, oi.part_id, p.part_name, oi.quantity
FROM orders o
JOIN order_item oi ON oi.order_id = o.order_id
JOIN part p        ON p.part_id   = oi.part_id
WHERE o.order_id = currval('orders_order_id_seq');
