# Normalisation: from an order form to clean tables

**Normalisation** means organising data so each fact is stored in **one place only**. That stops three problems:

- **Update problem**: change a seller's phone number in one row but forget the others, and the data now disagrees with itself.
- **Insert problem**: you cannot add a new part until somebody orders it.
- **Delete problem**: delete the only order for a part, and you lose the part's details too.

Below, a NaijaAutoMart parts order goes step by step from one messy record to the final tables.

---

## Step 0: Unnormalised data (UNF)

This is how an order might look if typed into one spreadsheet row:

| order_no | order_date | customer | customer_email | customer_phone | delivery_address | parts_ordered | fits_cars |
|---|---|---|---|---|---|---|---|
| 1 | 02-Sep-2026 | Chinedu Okafor | chinedu.okafor@gmail.com | 08031234501 | 14 Allen Avenue, Ikeja, Lagos | Front Brake Pads, Toyota, Brakes, Ladipo AutoParts, 08059990004, x1 @ ₦38,000; Oil Filter, Toyota, Filters, Ladipo AutoParts, 08059990004, x2 @ ₦6,500 | Corolla 2015; Corolla 2015, Camry 2018, Highlander 2014, RX 350 2016, ES 350 2019 |

**What's wrong:** one cell (`parts_ordered`) holds a whole list. You can't easily ask "how many oil filters did we sell?", and the seller's phone is repeated inside the text.

---

## Step 1: First Normal Form (1NF)

**Rule:** every cell holds **one value**, and there are no repeating groups.

**Fix:** give each part in the order its own row. The "fits cars" list moves to its own table, one row per part and car model pair (this becomes `part_fitment`).

| order_id | part_id | order_date | customer_name | customer_email | customer_phone | delivery_address | part_name | brand | category | seller_name | seller_phone | quantity | unit_price |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 3 | 02-Sep-2026 | Chinedu Okafor | chinedu.okafor@gmail.com | 08031234501 | 14 Allen Avenue… | Front Brake Pads | Toyota | Brakes | Ladipo AutoParts | 08059990004 | 1 | 38,000 |
| 1 | 4 | 02-Sep-2026 | Chinedu Okafor | chinedu.okafor@gmail.com | 08031234501 | 14 Allen Avenue… | Oil Filter | Toyota | Filters | Ladipo AutoParts | 08059990004 | 2 | 6,500 |

**Primary key:** (order_id, part_id), since together they identify one row.

**Still wrong:** Chinedu's details and the seller's details are repeated on every row.

---

## Step 2: Second Normal Form (2NF)

**Rule:** be in 1NF, **and** every column must depend on the **whole** key, not just part of it.

The key is (order_id, part_id). Check each column with **functional dependencies**, where "A → B" means "if you know A, you know B":

| Depends on… | Columns | Problem? |
|---|---|---|
| order_id only | order_date, customer details, delivery_address | Yes, depends on half the key |
| part_id only | part_name, brand, category, seller details | Yes, depends on half the key |
| (order_id, part_id) together | quantity, unit_price | No, this is correct |

**Fix:** split by what each column depends on.

- **ORDERS** (order_id, order_date, customer_name, customer_email, customer_phone, delivery_address)
- **PART** (part_id, part_name, brand, category_name, seller_name, seller_phone, price)
- **ORDER_ITEM** (order_id, part_id, quantity, unit_price)

**Still wrong:** inside ORDERS, the customer's email is repeated on every order they place. Inside PART, the seller's phone is repeated for every part they sell.

---

## Step 3: Third Normal Form (3NF)

**Rule:** be in 2NF, **and** no column may depend on another **non-key** column. This is called a *transitive dependency*: A → B → C.

| Table | Transitive dependency found | Fix |
|---|---|---|
| ORDERS | order_id → customer_id → name, email, phone | Move customer details to **CUSTOMER**; keep only `customer_id` (FK) in ORDERS |
| PART | part_id → seller_id → seller name, phone | Move seller details to **SELLER**; keep `seller_id` (FK) |
| PART | part_id → category_id → category_name | Move to **PART_CATEGORY**; keep `category_id` (FK) |

**Result: the final 3NF tables**

- **CUSTOMER** (customer_id PK, first_name, last_name, email, phone, city, state)
- **SELLER** (seller_id PK, business_name, seller_type, email, phone, city, state, is_verified)
- **PART_CATEGORY** (category_id PK, category_name)
- **PART** (part_id PK, seller_id FK, category_id FK, part_number, part_name, brand, price, stock_qty)
- **ORDERS** (order_id PK, customer_id FK, order_date, status, delivery_address, delivery_city, delivery_state)
- **ORDER_ITEM** (order_id PK/FK, part_id PK/FK, quantity, unit_price)
- **PART_FITMENT** (part_id PK/FK, model_id PK/FK)

The other tables (CAR_MODEL, CAR_LISTING, PAYMENT, DELIVERY, DELIVERY_AGENT, INSPECTION, REVIEW) were designed the same way. Each one describes one thing, and every column depends only on that table's key.

Now each fact lives in one place. If Ladipo AutoParts changes its phone number, only **one row** in SELLER changes.

---

## Step 4: A quick check for BCNF

**Boyce-Codd Normal Form (BCNF)** is a slightly stricter version of 3NF: every column that decides other columns must itself be a key. The design passes:

- In **CAR_MODEL**, (make, model_name, model_year) decides the row, and it is declared `UNIQUE`, so it is a candidate key.
- In **PART**, (seller_id, part_number) decides the row, and it is declared `UNIQUE`.
- In **CUSTOMER** and **SELLER**, email and phone each decide the row, and both are `UNIQUE`.

---

## Design choices that look like repetition but are on purpose

| Choice | Why it is correct |
|---|---|
| `unit_price` is stored in ORDER_ITEM even though PART has `price` | Part prices change. An order must remember what the customer **actually paid** on that day. This is a historical fact, not a copy. |
| The order **total is not stored** | It is calculated from the order items (see Query 4 in `04_check_queries.sql`), so it can never be wrong or out of date. |
| ORDERS has its own delivery address, separate from the customer's city | A customer may live in Ikeja but have parts delivered to their office or mechanic. The address belongs to the order. |
| `city` and `state` are both kept | City is typed in by users, and city names alone are not a reliable way to work out the state, so we do not treat city → state as a rule. A full address lookup table could be added later if needed. |
