-- =====================================================================
-- NaijaAutoMart - Portfolio 1
-- Script 02: Sample data (all names and businesses are made up)
-- Run AFTER 01_create_tables.sql. Prices are in Naira.
-- =====================================================================

-- Customers --------------------------------------------------------
INSERT INTO customer (first_name, last_name, email, phone, city, state) VALUES
('Chinedu',  'Okafor',    'chinedu.okafor@gmail.com',   '08031234501', 'Ikeja',         'Lagos'),
('Aisha',    'Bello',     'aisha.bello@yahoo.com',      '08061234502', 'Kano',          'Kano'),
('Tunde',    'Adeyemi',   'tunde.adeyemi@gmail.com',    '08021234503', 'Ibadan',        'Oyo'),
('Ngozi',    'Eze',       'ngozi.eze@outlook.com',      '08091234504', 'Enugu',         'Enugu'),
('Ibrahim',  'Musa',      'ibrahim.musa@gmail.com',     '07031234505', 'Abuja',         'FCT'),
('Funke',    'Adebayo',   'funke.adebayo@gmail.com',    '08121234506', 'Lekki',         'Lagos'),
('Emeka',    'Nwosu',     'emeka.nwosu@yahoo.com',      '08051234507', 'Port Harcourt', 'Rivers'),
('Halima',   'Abubakar',  'halima.abubakar@gmail.com',  '09031234508', 'Kaduna',        'Kaduna'),
('Segun',    'Ogunleye',  'segun.ogunleye@gmail.com',   '08161234509', 'Abeokuta',      'Ogun'),
('Blessing', 'Udo',       'blessing.udo@outlook.com',   '08141234510', 'Uyo',           'Akwa Ibom'),
('Yusuf',    'Danjuma',   'yusuf.danjuma@gmail.com',    '07061234511', 'Jos',           'Plateau'),
('Kemi',     'Oladipo',   'kemi.oladipo@yahoo.com',     '08171234512', 'Benin City',    'Edo');

-- Sellers: 3 car dealers, 3 parts shops --------------------------
INSERT INTO seller (business_name, seller_type, email, phone, city, state, is_verified) VALUES
('Lekki Prime Autos',          'Car Dealer', 'sales@lekkiprimeautos.ng',  '08029990001', 'Lekki',         'Lagos',   TRUE),
('Abuja Motor Hub',            'Car Dealer', 'info@abujamotorhub.ng',     '08039990002', 'Abuja',         'FCT',     TRUE),
('Garden City Cars',           'Car Dealer', 'hello@gardencitycars.ng',   '08049990003', 'Port Harcourt', 'Rivers',  TRUE),
('Ladipo AutoParts Ventures',  'Parts Shop', 'orders@ladipoparts.ng',     '08059990004', 'Mushin',        'Lagos',   TRUE),
('Kano Auto Spares',           'Parts Shop', 'kanoautospares@gmail.com',  '08069990005', 'Kano',          'Kano',    TRUE),
('Nnewi Genuine Parts Ltd',    'Parts Shop', 'sales@nnewigenuine.ng',     '08079990006', 'Nnewi',         'Anambra', FALSE);

-- Delivery agents --------------------------------------------------
INSERT INTO delivery_agent (full_name, phone, city) VALUES
('Samuel Ajayi',     '08088880001', 'Lagos'),
('Musa Ibrahim',     '08088880002', 'Abuja'),
('Godwin Amadi',     '08088880003', 'Port Harcourt'),
('Abdullahi Sani',   '08088880004', 'Kano');

-- Car models (reference list) ------------------------------------
INSERT INTO car_model (make, model_name, model_year) VALUES
('Toyota',        'Corolla',    2015),   -- 1
('Toyota',        'Camry',      2018),   -- 2
('Toyota',        'Highlander', 2014),   -- 3
('Honda',         'Accord',     2017),   -- 4
('Honda',         'Civic',      2016),   -- 5
('Lexus',         'RX 350',     2016),   -- 6
('Lexus',         'ES 350',     2019),   -- 7
('Hyundai',       'Elantra',    2020),   -- 8
('Kia',           'Rio',        2019),   -- 9
('Mercedes-Benz', 'C300',       2017);   -- 10

-- Cars for sale (dealers 1-3) -------------------------------------
INSERT INTO car_listing (seller_id, model_id, vin, car_condition, mileage_km, colour, transmission, price, status) VALUES
(1, 2,  '4T1B11HK5JU512345', 'Foreign Used',  68000,  'Black',  'Automatic', 18500000, 'Available'),
(1, 6,  '2T2BZMCA6GC023456', 'Foreign Used',  92000,  'White',  'Automatic', 24000000, 'Reserved'),
(1, 1,  '2T1BURHE5FC334567', 'Nigerian Used', 130000, 'Silver', 'Automatic',  7800000, 'Sold'),
(2, 4,  '1HGCV1F30HA045678', 'Foreign Used',  75000,  'Grey',   'Automatic', 14500000, 'Available'),
(2, 10, '55SWF4KB8HU156789', 'Foreign Used',  60000,  'Blue',   'Automatic', 21000000, 'Available'),
(2, 7,  '58ADZ1B10KU067890', 'Foreign Used',  40000,  'Red',    'Automatic', 32000000, 'Available'),
(3, 8,  '5NPD84LF2LH178901', 'Brand New',     0,      'White',  'Automatic', 26500000, 'Available'),
(3, 9,  '3KPA24AD0KE289012', 'Nigerian Used', 85000,  'Red',    'Manual',     6200000, 'Available');

-- Part categories --------------------------------------------------
INSERT INTO part_category (category_name) VALUES
('Tyres'), ('Batteries'), ('Brakes'), ('Engine Parts'), ('Filters'), ('Suspension'), ('Lighting');

-- Parts (parts shops 4-6) -----------------------------------------
INSERT INTO part (seller_id, category_id, part_number, part_name, brand, price, stock_qty) VALUES
(4, 1, 'DUN-205-55R16',     'Tyre 205/55 R16',           'Dunlop',   65000,  40),  -- 1
(4, 2, 'VAR-75AH',          'Car Battery 75Ah',          'Varta',    95000,  25),  -- 2
(4, 3, 'TOY-04465-02220',   'Front Brake Pads',          'Toyota',   38000,  30),  -- 3
(4, 5, 'TOY-90915-YZZD2',   'Oil Filter',                'Toyota',    6500, 120),  -- 4
(5, 5, 'HON-15400-PLM-A02', 'Oil Filter',                'Honda',     7000,  80),  -- 5
(5, 4, 'NGK-ILKAR7B11',     'Spark Plugs (set of 4)',    'NGK',      28000,  50),  -- 6
(5, 3, 'HON-45022-T2A',     'Front Brake Pads',          'Honda',    42000,  20),  -- 7
(5, 1, 'MIC-235-60R18',     'Tyre 235/60 R18',           'Michelin',120000,  16),  -- 8
(6, 6, 'KYB-339040',        'Front Shock Absorber',      'KYB',      85000,  12),  -- 9
(6, 7, 'DEP-212-11C4',      'Headlamp Assembly',         'Depo',    150000,   6),  -- 10
(6, 4, 'AIS-WPT-190',       'Water Pump',                'Aisin',    55000,  10),  -- 11
(6, 2, 'EXI-100AH',         'Car Battery 100Ah',         'Exide',   135000,  15),  -- 12
(6, 5, 'MAN-HU7008Z',       'Oil Filter',                'Mann',     12000,  40),  -- 13
(4, 6, 'MOO-K750',          'Stabiliser Link',           'Moog',     18000,   0),  -- 14 (out of stock)
(5, 7, 'PHI-H4-12V',        'Headlight Bulbs H4 (pair)', 'Philips',   9500, 200);  -- 15

-- Which part fits which car model ---------------------------------
INSERT INTO part_fitment (part_id, model_id) VALUES
(1, 1), (1, 5), (1, 8),                     -- 205/55 R16 tyre: Corolla, Civic, Elantra
(2, 1), (2, 2), (2, 4), (2, 5), (2, 8), (2, 9),
(3, 1),                                     -- Toyota brake pads: Corolla only
(4, 1), (4, 2), (4, 3), (4, 6), (4, 7),     -- Toyota oil filter fits Toyota and Lexus
(5, 4), (5, 5),
(6, 2), (6, 4), (6, 5), (6, 7),
(7, 4),
(8, 3), (8, 6),
(9, 2),
(10, 1),
(11, 3), (11, 6),
(12, 3), (12, 6), (12, 10),
(13, 10),
(14, 8), (14, 9),
(15, 1), (15, 8), (15, 9);

-- Orders for parts -------------------------------------------------
INSERT INTO orders (customer_id, order_date, status, delivery_address, delivery_city, delivery_state) VALUES
(1,  '2026-09-02 10:15', 'Delivered', '14 Allen Avenue',            'Ikeja',         'Lagos'),   -- 1
(2,  '2026-09-05 13:40', 'Delivered', '22 Zoo Road',                'Kano',          'Kano'),    -- 2
(5,  '2026-09-10 09:05', 'Delivered', '7 Aminu Kano Crescent, Wuse 2', 'Abuja',      'FCT'),     -- 3
(7,  '2026-09-18 16:20', 'Shipped',   '31 Aba Road',                'Port Harcourt', 'Rivers'),  -- 4
(6,  '2026-09-25 11:00', 'Paid',      '5 Admiralty Way',            'Lekki',         'Lagos'),   -- 5
(3,  '2026-10-01 08:30', 'Pending',   '18 Ring Road',               'Ibadan',        'Oyo'),     -- 6
(4,  '2026-10-03 15:10', 'Cancelled', '9 Ogui Road',                'Enugu',         'Enugu'),   -- 7
(12, '2026-10-05 12:45', 'Paid',      '40 Airport Road',            'Benin City',    'Edo');     -- 8

-- Parts in each order (unit_price = price on the day of the order) -
INSERT INTO order_item (order_id, part_id, quantity, unit_price) VALUES
(1, 3,  1,  38000), (1, 4, 2,   6500),
(2, 2,  1,  95000),
(3, 5,  2,   7000), (3, 6, 1,  28000),
(4, 8,  4, 120000),
(5, 10, 1, 150000), (5, 15, 1,  9500),
(6, 1,  4,  65000),
(7, 9,  2,  85000),
(8, 12, 1, 135000), (8, 13, 1, 12000);

-- Payments (order 3 had a failed card payment first; order 7 was refunded)
INSERT INTO payment (order_id, amount, method, status, paid_at) VALUES
(1,  51000, 'Card',          'Successful', '2026-09-02 10:17'),
(2,  95000, 'Bank Transfer', 'Successful', '2026-09-05 13:55'),
(3,  42000, 'Card',          'Failed',     '2026-09-10 09:06'),
(3,  42000, 'Bank Transfer', 'Successful', '2026-09-10 09:20'),
(4, 480000, 'Card',          'Successful', '2026-09-18 16:22'),
(5, 159500, 'Card',          'Successful', '2026-09-25 11:02'),
(7, 170000, 'Card',          'Refunded',   '2026-10-03 15:12'),
(8, 147000, 'Bank Transfer', 'Successful', '2026-10-05 13:00');
-- Order 6 is Pay on Delivery, so it has no payment yet.

-- Deliveries --------------------------------------------------------
INSERT INTO delivery (order_id, agent_id, status, dispatched_at, delivered_at) VALUES
(1, 1,    'Delivered',       '2026-09-03 08:00', '2026-09-03 14:30'),
(2, 4,    'Delivered',       '2026-09-06 09:00', '2026-09-06 12:10'),
(3, 2,    'Delivered',       '2026-09-11 10:00', '2026-09-11 15:45'),
(4, 3,    'In Transit',      '2026-09-19 07:30', NULL),
(5, NULL, 'Awaiting Pickup', NULL,               NULL),
(8, NULL, 'Awaiting Pickup', NULL,               NULL);

-- Car inspection bookings -------------------------------------------
INSERT INTO inspection (customer_id, listing_id, scheduled_for, status) VALUES
(1,  3, '2026-09-01 11:00', 'Completed'),
(6,  2, '2026-09-28 10:00', 'Completed'),
(11, 5, '2026-10-02 14:00', 'Cancelled'),
(5,  4, '2026-10-08 10:00', 'Booked'),
(7,  7, '2026-10-10 13:00', 'Booked');

-- Reviews (only from customers whose orders were delivered) -------
INSERT INTO review (customer_id, part_id, rating, comment) VALUES
(1, 3, 5, 'Original Toyota pads, fit my Corolla perfectly.'),
(1, 4, 4, 'Good filter, fair price.'),
(2, 2, 5, 'Battery delivered the next day in Kano. Car starts first time.'),
(5, 5, 4, NULL),
(5, 6, 5, 'Genuine NGK plugs. Engine runs smoother.');
