-- =====================================================================
-- NaijaAutoMart - Portfolio 2: Query Processing and Optimisation
-- Script 01: Load a LARGE amount of realistic test data
--
-- Why: indexes only make a difference when tables are big. With 8 orders
-- every query is instant. With 200,000 orders, slow queries show up.
--
-- Run AFTER Portfolio 1 scripts 01 and 02 (it adds to that data).
-- Run the WHOLE script at once (F5 with nothing highlighted).
-- Takes about 30-60 seconds. Pure SQL: nothing extra to install.
--
-- After this script the database has about:
--   20,000 customers | 2,000 parts | 200,000 orders | 500,000 order items
--
-- setseed() makes random() give the SAME "random" data every time,
-- so results can be repeated.
-- =====================================================================

SELECT setseed(0.42);

-- ---------------------------------------------------------------------
-- 1. More parts shops (seller_id 7 to 50)
-- ---------------------------------------------------------------------
INSERT INTO seller (business_name, seller_type, email, phone, city, state, is_verified)
SELECT 'AutoParts Hub ' || g,
       'Parts Shop',
       'shop' || g || '@naijaautomart.ng',
       '0809' || lpad(g::text, 7, '0'),
       (ARRAY['Lagos','Abuja','Kano','Port Harcourt','Ibadan','Onitsha','Aba','Enugu'])[1 + g % 8],
       (ARRAY['Lagos','FCT','Kano','Rivers','Oyo','Anambra','Abia','Enugu'])[1 + g % 8],
       TRUE
FROM generate_series(7, 50) AS g;

-- ---------------------------------------------------------------------
-- 2. More parts (part_id 16 to 2,000)
-- ---------------------------------------------------------------------
INSERT INTO part (seller_id, category_id, part_number, part_name, brand, price, stock_qty)
SELECT CASE WHEN g % 47 < 3 THEN 4 + g % 3 ELSE 7 + g % 44 END,     -- a parts shop
       1 + g % 7,                                                    -- category 1 to 7
       'NAM-' || lpad(g::text, 6, '0'),
       (ARRAY['Tyre','Battery','Brake Pads','Engine Mount','Oil Filter','Shock Absorber','Headlamp'])[1 + g % 7]
           || ' Type ' || g,
       (ARRAY['Bosch','Denso','Michelin','Exide','Mann','KYB','Philips','Toyota','Honda','NGK'])[1 + g % 10],
       round((3000 + random() * 247000) / 500) * 500,                -- N3,000 to N250,000
       floor(random() * 200)::int
FROM generate_series(16, 2000) AS g;

-- ---------------------------------------------------------------------
-- 3. More customers (customer_id 13 to 20,000)
-- ---------------------------------------------------------------------
INSERT INTO customer (first_name, last_name, email, phone, city, state, created_at)
SELECT f.first_name, l.last_name,
       lower(f.first_name || '.' || l.last_name || g) || '@example.ng',
       '07' || lpad(g::text, 9, '0'),
       loc.city, loc.state,
       TIMESTAMP '2024-01-01' + random() * INTERVAL '640 days'
FROM generate_series(13, 20000) AS g
CROSS JOIN LATERAL (SELECT (ARRAY['Chinedu','Aisha','Tunde','Ngozi','Ibrahim','Funke','Emeka','Halima',
        'Segun','Blessing','Yusuf','Kemi','Obinna','Zainab','Femi','Amaka','Musa','Bola','Ifeanyi','Hauwa'])
        [1 + (g * 7) % 20] AS first_name) f
CROSS JOIN LATERAL (SELECT (ARRAY['Okafor','Bello','Adeyemi','Eze','Musa','Adebayo','Nwosu','Abubakar',
        'Ogunleye','Udo','Danjuma','Oladipo','Okeke','Sani','Balogun','Obi','Lawal','Ibe','Yakubu','Akande'])
        [1 + (g * 13) % 20] AS last_name) l
CROSS JOIN LATERAL (SELECT
        (ARRAY['Ikeja','Lekki','Surulere','Abuja','Kano','Port Harcourt','Ibadan','Enugu',
               'Benin City','Kaduna','Abeokuta','Uyo','Jos','Onitsha','Warri','Ilorin'])[1 + g % 16] AS city,
        (ARRAY['Lagos','Lagos','Lagos','FCT','Kano','Rivers','Oyo','Enugu',
               'Edo','Kaduna','Ogun','Akwa Ibom','Plateau','Anambra','Delta','Kwara'])[1 + g % 16] AS state) loc;

-- ---------------------------------------------------------------------
-- 4. 200,000 orders spread from January 2025 to October 2026
--    About 2% Pending, 3% Paid, 3% Shipped, 4% Cancelled, 88% Delivered
-- ---------------------------------------------------------------------
WITH gen AS (
    SELECT g,
           1 + floor(random() * 20000)::int                      AS cust,
           TIMESTAMP '2025-01-01' + random() * INTERVAL '643 days' AS odate,
           random()                                              AS r
    FROM generate_series(1, 200000) AS g
)
INSERT INTO orders (customer_id, order_date, status, delivery_address, delivery_city, delivery_state)
SELECT gen.cust, gen.odate,
       CASE WHEN r < 0.02 THEN 'Pending'
            WHEN r < 0.05 THEN 'Paid'
            WHEN r < 0.08 THEN 'Shipped'
            WHEN r < 0.12 THEN 'Cancelled'
            ELSE 'Delivered' END,
       (1 + g % 200) || ' Market Road',
       c.city, c.state
FROM gen
JOIN customer c ON c.customer_id = gen.cust
ORDER BY gen.g;

-- ---------------------------------------------------------------------
-- 5. Order items: 1 to 4 different parts per new order (~500,000 rows)
-- ---------------------------------------------------------------------
INSERT INTO order_item (order_id, part_id, quantity, unit_price)
SELECT o.order_id, p.part_id, 1 + floor(random() * 4)::int, p.price
FROM orders o
CROSS JOIN LATERAL generate_series(1, 1 + o.order_id % 4) AS k
JOIN part p ON p.part_id = 1 + (o.order_id * 37 + k * 131) % 2000
WHERE o.order_id > 8;          -- orders 1-8 already have items from Portfolio 1

-- ---------------------------------------------------------------------
-- 6. Update the planner's statistics so it knows the tables are now big
-- ---------------------------------------------------------------------
ANALYZE;

-- Check the new sizes
SELECT 'customer' AS table_name, COUNT(*) AS rows FROM customer
UNION ALL SELECT 'part',       COUNT(*) FROM part
UNION ALL SELECT 'orders',     COUNT(*) FROM orders
UNION ALL SELECT 'order_item', COUNT(*) FROM order_item;
