-- =====================================================================
-- NaijaAutoMart - Portfolio 3
-- Script 03: A place_order() function - automatic rollback on error
--
-- Instead of trusting every app developer to write BEGIN/COMMIT correctly,
-- the whole "place an order" job lives in ONE database function.
-- A function call is a single transaction: if ANY step fails (e.g. not
-- enough stock), PostgreSQL undoes ALL its steps automatically.
--
-- It also LOCKS the part row (SELECT ... FOR UPDATE) while it checks
-- stock, so two customers cannot both buy the last one (see script 05).
--
-- HOW TO RUN: use ONE Query Tool tab. Highlight each STEP (from its
-- STEP line down to the next STEP line) and press F5. Look at the
-- Data Output tab (tables) and the Messages tab after each step.
-- (If you run the whole file at once, pgAdmin only shows the LAST result.)
-- =====================================================================

-- STEP 1 - TAB A: create the function
CREATE OR REPLACE FUNCTION place_order(
    p_customer_id INT,
    p_part_id     INT,
    p_quantity    INT,
    p_method      VARCHAR
) RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_price    NUMERIC(12,2);
    v_stock    INT;
    v_order_id INT;
BEGIN
    -- Lock the part row and read its price and stock
    SELECT price, stock_qty INTO v_price, v_stock
    FROM part WHERE part_id = p_part_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Part % does not exist', p_part_id;
    END IF;

    -- Create the order using the customer's own city and state
    INSERT INTO orders (customer_id, status, delivery_address, delivery_city, delivery_state)
    SELECT customer_id, 'Paid', 'Address on file', city, state
    FROM customer WHERE customer_id = p_customer_id
    RETURNING order_id INTO v_order_id;

    IF v_order_id IS NULL THEN
        RAISE EXCEPTION 'Customer % does not exist', p_customer_id;
    END IF;

    INSERT INTO order_item (order_id, part_id, quantity, unit_price)
    VALUES (v_order_id, p_part_id, p_quantity, v_price);

    INSERT INTO payment (order_id, amount, method, status)
    VALUES (v_order_id, v_price * p_quantity, p_method, 'Successful');

    -- Stock check is done LAST on purpose: if it fails, the order,
    -- item and payment created above must all be undone automatically.
    IF v_stock < p_quantity THEN
        RAISE EXCEPTION 'Not enough stock for part %: wanted %, only % left',
                        p_part_id, p_quantity, v_stock;
    END IF;

    UPDATE part SET stock_qty = stock_qty - p_quantity WHERE part_id = p_part_id;

    RETURN v_order_id;
END;
$$;

-- ---------------------------------------------------------------------
-- Test 1: a good order. Ibrahim Musa (customer 5) buys 1 NGK spark plug set.
-- ---------------------------------------------------------------------
-- STEP 2 - TAB A: a good order (result in Data Output)
SELECT place_order(5, 6, 1, 'Bank Transfer') AS new_order_id;

-- ---------------------------------------------------------------------
-- Test 2: a bad order. Part 14 has 0 in stock.
-- The function creates the order, item and payment, THEN fails the stock
-- check. Everything must be undone, so the counts below must not change.
-- ---------------------------------------------------------------------
-- STEP 3 - TAB A: a bad order (result in the Messages tab)
DO $$
DECLARE
    orders_before   INT := (SELECT COUNT(*) FROM orders);
    payments_before INT := (SELECT COUNT(*) FROM payment);
BEGIN
    BEGIN
        PERFORM place_order(9, 14, 1, 'Card');
        RAISE NOTICE 'UNEXPECTED: order for out-of-stock part was placed';
    EXCEPTION WHEN raise_exception THEN
        RAISE NOTICE 'Order refused: %', SQLERRM;
    END;
    RAISE NOTICE 'Orders   before: %, after: %', orders_before,   (SELECT COUNT(*) FROM orders);
    RAISE NOTICE 'Payments before: %, after: %', payments_before, (SELECT COUNT(*) FROM payment);
    RAISE NOTICE 'Same numbers = the half-finished order was rolled back automatically';
END $$;
