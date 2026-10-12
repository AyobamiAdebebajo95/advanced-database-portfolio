-- =====================================================================
-- NaijaAutoMart - Portfolio 3
-- Script 08: DEADLOCK - and how to prevent it
--
-- A DEADLOCK is when two transactions each hold a lock the other needs,
-- so both would wait forever.
--   Chinedu's basket: battery (part 2) THEN brake pads (part 3)
--   Aisha's basket:   brake pads (part 3) THEN battery (part 2)
-- PostgreSQL notices the circle after about 1 second and cancels ONE
-- of the transactions with "deadlock detected", so the other can finish.
--
-- HOW TO RUN: two Query Tool tabs. Run each STEP in the tab it names.
-- In STEP 3 Tab A will wait. Then run STEP 4 in Tab B: within about
-- 1 second one of the tabs gets the deadlock error.
-- =====================================================================

-- ---------------------------------------------------------------------
-- PART 1: Causing a deadlock
-- ---------------------------------------------------------------------

-- STEP 1 - TAB A: Chinedu's checkout reduces battery stock (locks part 2)
BEGIN;
UPDATE part SET stock_qty = stock_qty - 1 WHERE part_id = 2;

-- STEP 2 - TAB B: Aisha's checkout reduces brake pad stock (locks part 3)
BEGIN;
UPDATE part SET stock_qty = stock_qty - 1 WHERE part_id = 3;

-- STEP 3 - TAB A: Chinedu now needs part 3, which Aisha holds. Tab A WAITS.
UPDATE part SET stock_qty = stock_qty - 1 WHERE part_id = 3;

-- STEP 4 - TAB B: Aisha now needs part 2, which Chinedu holds. Circle! PostgreSQL cancels Aisha.
UPDATE part SET stock_qty = stock_qty - 1 WHERE part_id = 2;

-- STEP 5 - TAB B: Aisha's transaction was cancelled, so roll it back (her app would retry)
ROLLBACK;

-- STEP 6 - TAB A: Chinedu's STEP 3 has finished, so his checkout completes. Then undo the demo.
ROLLBACK;

-- ---------------------------------------------------------------------
-- PART 2: The fix - always lock parts in the SAME order (lowest part_id first)
-- ---------------------------------------------------------------------

-- STEP 7 - TAB A: lock ALL the parts in the basket at once, in part_id order
BEGIN;
SELECT part_id, stock_qty FROM part WHERE part_id IN (2, 3) ORDER BY part_id FOR UPDATE;

-- STEP 8 - TAB B: Aisha's basket has the same parts, so she locks them in the SAME order. She simply WAITS - no deadlock.
BEGIN;
SELECT part_id, stock_qty FROM part WHERE part_id IN (2, 3) ORDER BY part_id FOR UPDATE;

-- STEP 9 - TAB A: Chinedu finishes (undo the demo), releasing the locks
ROLLBACK;

-- STEP 10 - TAB B: Aisha's STEP 8 has now finished normally. Finish (undo the demo).
ROLLBACK;
