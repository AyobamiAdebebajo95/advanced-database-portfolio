-- =====================================================================
-- NaijaAutoMart - Portfolio 1: Database Design and Modelling
-- Script 01: Create all tables with keys and constraints
-- Database: PostgreSQL 16   |   Run on the database: naijaautomart
-- Safe to re-run: it drops the old tables first.
--
-- Abbreviations: SQL = Structured Query Language, PK = Primary Key,
-- FK = Foreign Key, VIN = Vehicle Identification Number.
-- Full list: docs/abbreviations.md
-- =====================================================================

DROP TABLE IF EXISTS review, inspection, delivery, delivery_agent, payment,
    order_item, orders, part_fitment, part, part_category,
    car_listing, car_model, seller, customer CASCADE;

-- ---------------------------------------------------------------------
-- PEOPLE
-- ---------------------------------------------------------------------

-- Customers who buy parts and book car inspections
CREATE TABLE customer (
    customer_id   SERIAL       PRIMARY KEY,
    first_name    VARCHAR(50)  NOT NULL,
    last_name     VARCHAR(50)  NOT NULL,
    email         VARCHAR(100) NOT NULL UNIQUE,          -- one account per email
    phone         VARCHAR(15)  NOT NULL UNIQUE,
    city          VARCHAR(50)  NOT NULL,
    state         VARCHAR(30)  NOT NULL,
    created_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_customer_email CHECK (email LIKE '%_@_%._%')
);

-- Car dealers and auto parts shops that sell on the platform
CREATE TABLE seller (
    seller_id     SERIAL       PRIMARY KEY,
    business_name VARCHAR(100) NOT NULL UNIQUE,
    seller_type   VARCHAR(20)  NOT NULL,
    email         VARCHAR(100) NOT NULL UNIQUE,
    phone         VARCHAR(15)  NOT NULL UNIQUE,
    city          VARCHAR(50)  NOT NULL,
    state         VARCHAR(30)  NOT NULL,
    is_verified   BOOLEAN      NOT NULL DEFAULT FALSE,   -- admin checks sellers first
    CONSTRAINT chk_seller_type CHECK (seller_type IN ('Car Dealer', 'Parts Shop'))
);

-- Riders and drivers who deliver parts orders
CREATE TABLE delivery_agent (
    agent_id      SERIAL       PRIMARY KEY,
    full_name     VARCHAR(100) NOT NULL,
    phone         VARCHAR(15)  NOT NULL UNIQUE,
    city          VARCHAR(50)  NOT NULL
);

-- ---------------------------------------------------------------------
-- CARS
-- ---------------------------------------------------------------------

-- Reference list of car models (e.g. Toyota Corolla 2015).
-- Used by car listings AND by parts, to say which parts fit which car.
CREATE TABLE car_model (
    model_id      SERIAL       PRIMARY KEY,
    make          VARCHAR(30)  NOT NULL,                 -- Toyota, Honda, Lexus...
    model_name    VARCHAR(30)  NOT NULL,                 -- Corolla, Accord, RX 350...
    model_year    SMALLINT     NOT NULL,
    CONSTRAINT uq_car_model UNIQUE (make, model_name, model_year),
    CONSTRAINT chk_model_year CHECK (model_year BETWEEN 1980 AND 2027)
);

-- A specific car for sale by a dealer
CREATE TABLE car_listing (
    listing_id    SERIAL        PRIMARY KEY,
    seller_id     INT           NOT NULL REFERENCES seller(seller_id)   ON DELETE RESTRICT,
    model_id      INT           NOT NULL REFERENCES car_model(model_id) ON DELETE RESTRICT,
    vin           CHAR(17)      NOT NULL UNIQUE,         -- VIN = Vehicle Identification Number, unique per car
    car_condition VARCHAR(20)   NOT NULL,
    mileage_km    INT           NOT NULL,
    colour        VARCHAR(20)   NOT NULL,
    transmission  VARCHAR(10)   NOT NULL,
    price         NUMERIC(14,2) NOT NULL,                -- in Naira
    status        VARCHAR(10)   NOT NULL DEFAULT 'Available',
    listed_at     TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_car_condition CHECK (car_condition IN ('Brand New', 'Foreign Used', 'Nigerian Used')),
    CONSTRAINT chk_mileage       CHECK (mileage_km >= 0),
    CONSTRAINT chk_transmission  CHECK (transmission IN ('Automatic', 'Manual')),
    CONSTRAINT chk_car_price     CHECK (price > 0),
    CONSTRAINT chk_car_status    CHECK (status IN ('Available', 'Reserved', 'Sold'))
);

-- ---------------------------------------------------------------------
-- AUTO PARTS
-- ---------------------------------------------------------------------

CREATE TABLE part_category (
    category_id   SERIAL      PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL UNIQUE             -- Tyres, Batteries, Brakes...
);

-- A part sold by a parts shop; stock_qty is how many are in stock
CREATE TABLE part (
    part_id       SERIAL        PRIMARY KEY,
    seller_id     INT           NOT NULL REFERENCES seller(seller_id)          ON DELETE RESTRICT,
    category_id   INT           NOT NULL REFERENCES part_category(category_id) ON DELETE RESTRICT,
    part_number   VARCHAR(30)   NOT NULL,
    part_name     VARCHAR(100)  NOT NULL,
    brand         VARCHAR(50)   NOT NULL,
    price         NUMERIC(12,2) NOT NULL,                -- in Naira
    stock_qty     INT           NOT NULL DEFAULT 0,
    CONSTRAINT uq_seller_part_number UNIQUE (seller_id, part_number),
    CONSTRAINT chk_part_price CHECK (price > 0),
    CONSTRAINT chk_stock      CHECK (stock_qty >= 0)     -- stock can never go below zero
);

-- Which parts fit which car models.
-- One part can fit many models and one model takes many parts (many-to-many),
-- so this "bridge" table links them.
CREATE TABLE part_fitment (
    part_id       INT NOT NULL REFERENCES part(part_id)           ON DELETE CASCADE,
    model_id      INT NOT NULL REFERENCES car_model(model_id)     ON DELETE CASCADE,
    PRIMARY KEY (part_id, model_id)                       -- composite key: no duplicate links
);

-- ---------------------------------------------------------------------
-- ORDERS, PAYMENTS AND DELIVERY (parts are bought online)
-- ---------------------------------------------------------------------

-- "order" is a reserved word in SQL, so the table is called orders
CREATE TABLE orders (
    order_id         SERIAL       PRIMARY KEY,
    customer_id      INT          NOT NULL REFERENCES customer(customer_id) ON DELETE RESTRICT,
    order_date       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status           VARCHAR(15)  NOT NULL DEFAULT 'Pending',
    delivery_address VARCHAR(200) NOT NULL,
    delivery_city    VARCHAR(50)  NOT NULL,
    delivery_state   VARCHAR(30)  NOT NULL,
    CONSTRAINT chk_order_status CHECK (status IN ('Pending', 'Paid', 'Shipped', 'Delivered', 'Cancelled'))
);

-- The parts inside each order.
-- One order has many parts and one part appears in many orders (many-to-many).
CREATE TABLE order_item (
    order_id      INT           NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    part_id       INT           NOT NULL REFERENCES part(part_id)    ON DELETE RESTRICT,
    quantity      INT           NOT NULL,
    unit_price    NUMERIC(12,2) NOT NULL,   -- price at the time of buying (kept on purpose)
    PRIMARY KEY (order_id, part_id),
    CONSTRAINT chk_quantity   CHECK (quantity > 0),
    CONSTRAINT chk_unit_price CHECK (unit_price > 0)
);

-- An order can have more than one payment attempt (e.g. a failed card, then a transfer)
CREATE TABLE payment (
    payment_id    SERIAL        PRIMARY KEY,
    order_id      INT           NOT NULL REFERENCES orders(order_id) ON DELETE RESTRICT,
    amount        NUMERIC(12,2) NOT NULL,
    method        VARCHAR(20)   NOT NULL,
    status        VARCHAR(10)   NOT NULL,
    paid_at       TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_pay_amount CHECK (amount > 0),
    CONSTRAINT chk_pay_method CHECK (method IN ('Card', 'Bank Transfer', 'Pay on Delivery')),
    CONSTRAINT chk_pay_status CHECK (status IN ('Successful', 'Failed', 'Refunded'))
);

-- One delivery per order (UNIQUE on order_id makes it one-to-one)
CREATE TABLE delivery (
    delivery_id   SERIAL      PRIMARY KEY,
    order_id      INT         NOT NULL UNIQUE REFERENCES orders(order_id) ON DELETE CASCADE,
    agent_id      INT         REFERENCES delivery_agent(agent_id) ON DELETE SET NULL, -- may be unassigned
    status        VARCHAR(15) NOT NULL DEFAULT 'Awaiting Pickup',
    dispatched_at TIMESTAMP,
    delivered_at  TIMESTAMP,
    CONSTRAINT chk_delivery_status CHECK (status IN ('Awaiting Pickup', 'In Transit', 'Delivered', 'Returned')),
    CONSTRAINT chk_delivery_dates  CHECK (delivered_at IS NULL OR delivered_at >= dispatched_at)
);

-- ---------------------------------------------------------------------
-- CAR INSPECTIONS AND REVIEWS
-- ---------------------------------------------------------------------

-- Customers book an inspection before buying a car
CREATE TABLE inspection (
    inspection_id SERIAL      PRIMARY KEY,
    customer_id   INT         NOT NULL REFERENCES customer(customer_id)   ON DELETE CASCADE,
    listing_id    INT         NOT NULL REFERENCES car_listing(listing_id) ON DELETE CASCADE,
    scheduled_for TIMESTAMP   NOT NULL,
    status        VARCHAR(10) NOT NULL DEFAULT 'Booked',
    CONSTRAINT uq_inspection_slot UNIQUE (listing_id, scheduled_for),  -- no double-booking a car
    CONSTRAINT chk_inspection_status CHECK (status IN ('Booked', 'Completed', 'Cancelled'))
);

-- Customer reviews of parts (one review per customer per part)
CREATE TABLE review (
    review_id     SERIAL    PRIMARY KEY,
    customer_id   INT       NOT NULL REFERENCES customer(customer_id) ON DELETE CASCADE,
    part_id       INT       NOT NULL REFERENCES part(part_id)         ON DELETE CASCADE,
    rating        SMALLINT  NOT NULL,
    comment       TEXT,
    created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_one_review_each UNIQUE (customer_id, part_id),
    CONSTRAINT chk_rating CHECK (rating BETWEEN 1 AND 5)
);
