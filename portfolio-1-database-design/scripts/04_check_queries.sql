-- =====================================================================
-- NaijaAutoMart - Portfolio 1
-- Script 04: Simple queries showing the design works
-- Run AFTER scripts 01 and 02.
-- Q1-Q5 = Query 1 to Query 5.
-- =====================================================================

-- Q1. How many rows are in each table?
SELECT 'customer' AS table_name, COUNT(*) AS rows FROM customer
UNION ALL SELECT 'seller',         COUNT(*) FROM seller
UNION ALL SELECT 'delivery_agent', COUNT(*) FROM delivery_agent
UNION ALL SELECT 'car_model',      COUNT(*) FROM car_model
UNION ALL SELECT 'car_listing',    COUNT(*) FROM car_listing
UNION ALL SELECT 'part_category',  COUNT(*) FROM part_category
UNION ALL SELECT 'part',           COUNT(*) FROM part
UNION ALL SELECT 'part_fitment',   COUNT(*) FROM part_fitment
UNION ALL SELECT 'orders',         COUNT(*) FROM orders
UNION ALL SELECT 'order_item',     COUNT(*) FROM order_item
UNION ALL SELECT 'payment',        COUNT(*) FROM payment
UNION ALL SELECT 'delivery',       COUNT(*) FROM delivery
UNION ALL SELECT 'inspection',     COUNT(*) FROM inspection
UNION ALL SELECT 'review',         COUNT(*) FROM review;

-- Q2. "Which parts fit my 2015 Toyota Corolla?"  (uses the many-to-many bridge table)
SELECT p.part_name, p.brand, pc.category_name, p.price, p.stock_qty, s.business_name AS sold_by
FROM car_model    m
JOIN part_fitment f  ON f.model_id    = m.model_id
JOIN part         p  ON p.part_id     = f.part_id
JOIN part_category pc ON pc.category_id = p.category_id
JOIN seller       s  ON s.seller_id   = p.seller_id
WHERE m.make = 'Toyota' AND m.model_name = 'Corolla' AND m.model_year = 2015
ORDER BY pc.category_name, p.price;

-- Q3. Cars available for sale, with dealer and location
SELECT m.make, m.model_name, m.model_year, c.car_condition, c.mileage_km,
       c.price, s.business_name AS dealer, s.city
FROM car_listing c
JOIN car_model m ON m.model_id  = c.model_id
JOIN seller    s ON s.seller_id = c.seller_id
WHERE c.status = 'Available'
ORDER BY c.price;

-- Q4. Order summary: the total is CALCULATED from the order items,
--     not stored, so it can never be out of date.
SELECT o.order_id, cu.first_name || ' ' || cu.last_name AS customer, o.status,
       COUNT(*)                         AS items,
       SUM(oi.quantity * oi.unit_price) AS order_total,
       d.status                         AS delivery_status
FROM orders     o
JOIN customer   cu ON cu.customer_id = o.customer_id
JOIN order_item oi ON oi.order_id    = o.order_id
LEFT JOIN delivery d ON d.order_id   = o.order_id
GROUP BY o.order_id, cu.first_name, cu.last_name, o.status, d.status
ORDER BY o.order_id;

-- Q5. Average rating for each reviewed part
SELECT p.part_name, p.brand, COUNT(r.review_id) AS reviews, ROUND(AVG(r.rating), 1) AS avg_rating
FROM part p
JOIN review r ON r.part_id = p.part_id
GROUP BY p.part_id, p.part_name, p.brand
ORDER BY avg_rating DESC, p.part_name;
