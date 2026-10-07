-- =====================================================================
-- NaijaAutoMart - Portfolio 1
-- Script 03: Prove the keys and constraints work
-- Each test tries to save BAD data. The database should refuse it.
-- "PASSED" means the bad data was rejected, as it should be.
-- In pgAdmin, the results appear in the "Messages" tab.
-- Run AFTER scripts 01 and 02.
-- =====================================================================

-- Test 1: UNIQUE - two customers cannot share an email
DO $$ BEGIN
    INSERT INTO customer (first_name, last_name, email, phone, city, state)
    VALUES ('Fake', 'User', 'chinedu.okafor@gmail.com', '08000000001', 'Ikeja', 'Lagos');
    RAISE NOTICE 'Test 1 FAILED: duplicate email was accepted';
EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'Test 1 PASSED (duplicate email blocked): %', SQLERRM;
END $$;

-- Test 2: CHECK - stock can never be negative
DO $$ BEGIN
    UPDATE part SET stock_qty = -5 WHERE part_id = 1;
    RAISE NOTICE 'Test 2 FAILED: negative stock was accepted';
EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'Test 2 PASSED (negative stock blocked): %', SQLERRM;
END $$;

-- Test 3: CHECK - a rating must be between 1 and 5
DO $$ BEGIN
    INSERT INTO review (customer_id, part_id, rating) VALUES (3, 1, 6);
    RAISE NOTICE 'Test 3 FAILED: rating of 6 was accepted';
EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'Test 3 PASSED (rating 6 blocked): %', SQLERRM;
END $$;

-- Test 4: FOREIGN KEY - an order must belong to a real customer
DO $$ BEGIN
    INSERT INTO orders (customer_id, delivery_address, delivery_city, delivery_state)
    VALUES (999, '1 Nowhere Street', 'Ikeja', 'Lagos');
    RAISE NOTICE 'Test 4 FAILED: order for a customer that does not exist was accepted';
EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'Test 4 PASSED (unknown customer blocked): %', SQLERRM;
END $$;

-- Test 5: FOREIGN KEY (ON DELETE RESTRICT) - cannot delete a customer who has orders
DO $$ BEGIN
    DELETE FROM customer WHERE customer_id = 1;
    RAISE NOTICE 'Test 5 FAILED: customer with orders was deleted';
EXCEPTION WHEN foreign_key_violation THEN
    RAISE NOTICE 'Test 5 PASSED (order history protected): %', SQLERRM;
END $$;

-- Test 6: CHECK - you cannot order zero of something
DO $$ BEGIN
    INSERT INTO order_item (order_id, part_id, quantity, unit_price) VALUES (6, 2, 0, 95000);
    RAISE NOTICE 'Test 6 FAILED: quantity of 0 was accepted';
EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'Test 6 PASSED (zero quantity blocked): %', SQLERRM;
END $$;

-- Test 7: COMPOSITE PRIMARY KEY - the same part-to-car link cannot be saved twice
DO $$ BEGIN
    INSERT INTO part_fitment (part_id, model_id) VALUES (3, 1);
    RAISE NOTICE 'Test 7 FAILED: duplicate fitment was accepted';
EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'Test 7 PASSED (duplicate fitment blocked): %', SQLERRM;
END $$;

-- Test 8: UNIQUE (one-to-one) - an order can only have one delivery
DO $$ BEGIN
    INSERT INTO delivery (order_id, agent_id) VALUES (1, 2);
    RAISE NOTICE 'Test 8 FAILED: second delivery for the same order was accepted';
EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'Test 8 PASSED (second delivery blocked): %', SQLERRM;
END $$;

-- Test 9: CHECK - seller type must be Car Dealer or Parts Shop
DO $$ BEGIN
    INSERT INTO seller (business_name, seller_type, email, phone, city, state)
    VALUES ('Mama Nkechi Mechanic', 'Mechanic', 'nkechi@mail.ng', '08000000009', 'Aba', 'Abia');
    RAISE NOTICE 'Test 9 FAILED: invalid seller type was accepted';
EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'Test 9 PASSED (invalid seller type blocked): %', SQLERRM;
END $$;

-- Test 10: NOT NULL - a car listing must have a VIN
DO $$ BEGIN
    INSERT INTO car_listing (seller_id, model_id, vin, car_condition, mileage_km, colour, transmission, price)
    VALUES (1, 1, NULL, 'Foreign Used', 50000, 'Black', 'Automatic', 9000000);
    RAISE NOTICE 'Test 10 FAILED: car without a VIN was accepted';
EXCEPTION WHEN not_null_violation THEN
    RAISE NOTICE 'Test 10 PASSED (missing VIN blocked): %', SQLERRM;
END $$;

-- Test 11: CHECK - a parcel cannot be delivered before it was dispatched
DO $$ BEGIN
    UPDATE delivery SET delivered_at = '2026-09-18 00:00' WHERE order_id = 4;
    RAISE NOTICE 'Test 11 FAILED: delivery date before dispatch date was accepted';
EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'Test 11 PASSED (impossible delivery date blocked): %', SQLERRM;
END $$;

-- Test 12: UNIQUE - the same car cannot be booked for two inspections at the same time
DO $$ BEGIN
    INSERT INTO inspection (customer_id, listing_id, scheduled_for)
    VALUES (9, 4, '2026-10-08 10:00');
    RAISE NOTICE 'Test 12 FAILED: double booking was accepted';
EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'Test 12 PASSED (double booking blocked): %', SQLERRM;
END $$;
