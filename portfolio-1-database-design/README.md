# Portfolio 1: Database Design and Modelling

This portfolio designs the relational database for **NaijaAutoMart**, a made-up Nigerian online store for cars and auto parts, and builds it in **PostgreSQL 16**.

| Required by the brief | Where to find it |
|---|---|
| Chosen case study description | [Main README](../README.md#my-case-study-naijaautomart-online-store) and the summary below |
| ER diagram | [er-diagram.png](er-diagram.png) (shown below) |
| Relational schema | [Relational schema](#relational-schema) below, and [01_create_tables.sql](scripts/01_create_tables.sql) |
| Keys | [Keys and constraints](#keys-and-constraints) below |
| Constraints | [Keys and constraints](#keys-and-constraints), proved in [03_test_constraints.sql](scripts/03_test_constraints.sql) |
| Normalisation explanation | [normalisation.md](normalisation.md) |

---

## Case study in brief

NaijaAutoMart connects **car dealers** and **auto parts shops** with **customers** across Nigeria.
- **Cars:** dealers list cars for sale. Customers **book an inspection** before buying.
- **Parts:** shops sell parts online. Customers order them, pay, and a **delivery agent** brings them.
- Customers can check **which parts fit their car** and leave **reviews**.

---

## ER diagram

![NaijaAutoMart ER diagram](er-diagram.png)

*Crow's foot notation. PK = primary key, FK = foreign key, UK = unique. Source: [er-diagram.mmd](er-diagram.mmd). It can be edited at [mermaid.live](https://mermaid.live), or imported into draw.io under Arrange → Insert → Advanced → Mermaid.*

### How to read the relationships

| Type | Example | Meaning |
|---|---|---|
| One-to-many | CUSTOMER → ORDERS | One customer places many orders; each order belongs to one customer |
| Many-to-many | ORDERS ↔ PART (through **ORDER_ITEM**) | An order has many parts; a part appears in many orders |
| Many-to-many | PART ↔ CAR_MODEL (through **PART_FITMENT**) | A battery fits many cars; a car takes many parts |
| One-to-one | ORDERS → DELIVERY | Each order has at most one delivery (`UNIQUE` on `delivery.order_id`) |
| Optional | DELIVERY_AGENT → DELIVERY | A new delivery may not have an agent assigned yet (agent_id can be empty) |

A relational database can't store many-to-many links directly, so each one gets a **bridge table** (ORDER_ITEM, PART_FITMENT) with a two-column primary key.

---

## Relational schema

PK = primary key, FK = foreign key (→ the table it points to)

1. **CUSTOMER** (customer_id PK, first_name, last_name, email, phone, city, state, created_at)
2. **SELLER** (seller_id PK, business_name, seller_type, email, phone, city, state, is_verified)
3. **DELIVERY_AGENT** (agent_id PK, full_name, phone, city)
4. **CAR_MODEL** (model_id PK, make, model_name, model_year)
5. **CAR_LISTING** (listing_id PK, seller_id FK → SELLER, model_id FK → CAR_MODEL, vin, car_condition, mileage_km, colour, transmission, price, status, listed_at)
6. **PART_CATEGORY** (category_id PK, category_name)
7. **PART** (part_id PK, seller_id FK → SELLER, category_id FK → PART_CATEGORY, part_number, part_name, brand, price, stock_qty)
8. **PART_FITMENT** (part_id PK, FK → PART, model_id PK, FK → CAR_MODEL)
9. **ORDERS** (order_id PK, customer_id FK → CUSTOMER, order_date, status, delivery_address, delivery_city, delivery_state)
10. **ORDER_ITEM** (order_id PK, FK → ORDERS, part_id PK, FK → PART, quantity, unit_price)
11. **PAYMENT** (payment_id PK, order_id FK → ORDERS, amount, method, status, paid_at)
12. **DELIVERY** (delivery_id PK, order_id FK → ORDERS, agent_id FK → DELIVERY_AGENT, status, dispatched_at, delivered_at)
13. **INSPECTION** (inspection_id PK, customer_id FK → CUSTOMER, listing_id FK → CAR_LISTING, scheduled_for, status)
14. **REVIEW** (review_id PK, customer_id FK → CUSTOMER, part_id FK → PART, rating, comment, created_at)

---

## Keys and constraints

| Type | What it does | Examples in NaijaAutoMart |
|---|---|---|
| **Primary key** | Gives every row a unique ID | `customer_id`, `part_id`; composite `(order_id, part_id)` in ORDER_ITEM |
| **Foreign key** | Links to a real row in another table | An order's `customer_id` must exist in CUSTOMER |
| **UNIQUE** | No duplicates allowed | Customer email and phone; car VIN; one review per customer per part; no double-booking a car inspection |
| **NOT NULL** | Value must be filled in | Every car must have a VIN, price and condition |
| **CHECK** | Value must follow a rule | Price > 0; stock ≥ 0; rating 1–5; seller type is "Car Dealer" or "Parts Shop" |
| **DEFAULT** | Fills a value automatically | `order_date` = now; new orders start as 'Pending' |

### What happens when a linked row is deleted

| Rule | Used for | Why |
|---|---|---|
| `ON DELETE RESTRICT` | customer → orders, part → order items, order → payments | Order and payment history must never vanish |
| `ON DELETE CASCADE` | order → order items, part → fitment, customer → reviews | Child rows mean nothing without the parent |
| `ON DELETE SET NULL` | delivery agent → delivery | If an agent leaves, the delivery stays and simply has no agent |

### Proof the constraints work
[03_test_constraints.sql](scripts/03_test_constraints.sql) tries to save 12 kinds of bad data. **All 12 were blocked.** Full output: [evidence/03_constraint_test_results.txt](evidence/03_constraint_test_results.txt)

```
Test 1  PASSED (duplicate email blocked)
Test 2  PASSED (negative stock blocked)
Test 3  PASSED (rating 6 blocked)
Test 4  PASSED (unknown customer blocked)
Test 5  PASSED (order history protected)
Test 6  PASSED (zero quantity blocked)
Test 7  PASSED (duplicate fitment blocked)
Test 8  PASSED (second delivery blocked)
Test 9  PASSED (invalid seller type blocked)
Test 10 PASSED (missing VIN blocked)
Test 11 PASSED (impossible delivery date blocked)
Test 12 PASSED (double booking blocked)
```

---

## Normalisation

The tables are in **Third Normal Form (3NF)** and also pass the **BCNF** check. [normalisation.md](normalisation.md) walks through a real order step by step, from one messy row through 1NF, 2NF and 3NF, and explains the design choices that look like repetition but are deliberate (such as keeping `unit_price` on each order item).

---

## How to run it (pgAdmin)

1. Open **pgAdmin**, right-click the `naijaautomart` database and choose **Query Tool**.
2. Open each script with the folder icon and press **F5** (Run), in this order:

| Order | Script | What it does |
|---|---|---|
| 1 | [01_create_tables.sql](scripts/01_create_tables.sql) | Creates the 14 tables (safe to re-run) |
| 2 | [02_insert_sample_data.sql](scripts/02_insert_sample_data.sql) | Adds sample customers, sellers, cars, parts and orders |
| 3 | [03_test_constraints.sql](scripts/03_test_constraints.sql) | Tests the rules; results appear in the **Messages** tab |
| 4 | [04_check_queries.sql](scripts/04_check_queries.sql) | Five queries showing the design works |

## Evidence

| File | Shows |
|---|---|
| [01_tables_and_constraints.txt](evidence/01_tables_and_constraints.txt) | All 14 tables and every key and constraint, listed by PostgreSQL |
| [03_constraint_test_results.txt](evidence/03_constraint_test_results.txt) | All 12 constraint tests passing |
| [04_query_results.txt](evidence/04_query_results.txt) | Query results, e.g. "Which parts fit my 2015 Toyota Corolla?" |
| Screenshots (`evidence/*.png`) | pgAdmin screenshots of the same, taken on my own machine |
