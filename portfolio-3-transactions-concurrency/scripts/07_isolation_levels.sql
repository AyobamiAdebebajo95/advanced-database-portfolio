-- =====================================================================
-- NaijaAutoMart - Portfolio 3
-- Script 07: ISOLATION LEVELS - what one transaction can see of another
--
-- The ISOLATION LEVEL decides how much a transaction is protected from
-- other people's changes while it is running.
--
--   READ UNCOMMITTED  could see other people's UNSAVED changes ("dirty read").
--                     PostgreSQL never allows this: it treats it as READ COMMITTED.
--   READ COMMITTED    (PostgreSQL's default) each query sees the latest SAVED data,
--                     so reading the same row twice can give two different answers
--                     ("non-repeatable read").
--   REPEATABLE READ   the transaction works from a snapshot taken at its first
--                     query, so the same row always reads the same.
--   SERIALIZABLE      strictest: as if transactions ran one after another.
--
-- Example: a customer is checking out while an admin changes a price.
-- The Varta battery (part 2) costs N95,000. The admin raises it to N99,000.
--
-- HOW TO RUN: two Query Tool tabs. Run each STEP in the tab it names.
-- =====================================================================

-- SETUP - TAB A: reset the battery price
UPDATE part SET price = 95000 WHERE part_id = 2;

-- ---------------------------------------------------------------------
-- PART 1: No dirty reads in PostgreSQL
-- ---------------------------------------------------------------------

-- STEP 1 - TAB A: the admin changes the price but has NOT committed yet
BEGIN;
UPDATE part SET price = 1 WHERE part_id = 2;

-- STEP 2 - TAB B: asks for READ UNCOMMITTED, but still sees 95000, not the unsaved 1
BEGIN ISOLATION LEVEL READ UNCOMMITTED;
SELECT price AS price_seen FROM part WHERE part_id = 2;
COMMIT;

-- STEP 3 - TAB A: the admin cancels the mistake
ROLLBACK;

-- ---------------------------------------------------------------------
-- PART 2: READ COMMITTED - a non-repeatable read
-- ---------------------------------------------------------------------

-- STEP 4 - TAB A: the customer's checkout starts and reads the price (95000)
BEGIN ISOLATION LEVEL READ COMMITTED;
SELECT price AS price_first_read FROM part WHERE part_id = 2;

-- STEP 5 - TAB B: the admin raises the price and saves it
UPDATE part SET price = 99000 WHERE part_id = 2;

-- STEP 6 - TAB A: same transaction, same query, but now it says 99000
SELECT price AS price_second_read FROM part WHERE part_id = 2;
COMMIT;

-- ---------------------------------------------------------------------
-- PART 3: REPEATABLE READ - the price stays the same
-- ---------------------------------------------------------------------

-- STEP 7 - TAB A: reset the price, then start checkout at REPEATABLE READ (95000)
UPDATE part SET price = 95000 WHERE part_id = 2;
COMMIT;   -- closes any transaction still open, so the isolation level can be set
          -- (if nothing was open, PostgreSQL just warns "no transaction in progress")
BEGIN ISOLATION LEVEL REPEATABLE READ;
SELECT price AS price_first_read FROM part WHERE part_id = 2;

-- STEP 8 - TAB B: the admin raises the price and saves it
UPDATE part SET price = 99000 WHERE part_id = 2;

-- STEP 9 - TAB A: still 95000. The checkout keeps its own snapshot.
SELECT price AS price_second_read FROM part WHERE part_id = 2;

-- ---------------------------------------------------------------------
-- PART 4: REPEATABLE READ refuses to overwrite a newer change
-- ---------------------------------------------------------------------

-- STEP 10 - TAB A: the checkout (still in its REPEATABLE READ transaction) tries to update the same row
UPDATE part SET stock_qty = stock_qty - 1 WHERE part_id = 2;

-- STEP 11 - TAB A: PostgreSQL said "could not serialize access due to concurrent update". Cancel; the app would retry.
ROLLBACK;

-- CHECK - TAB A: put the price back
UPDATE part SET price = 95000 WHERE part_id = 2;
SELECT part_id, part_name, price, stock_qty FROM part WHERE part_id = 2;
