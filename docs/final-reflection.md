# Individual Technical Reflection

**Adebajo Ayobamidele · Student ID 301931278 · MIT 8103 Advanced Database Systems**

*Built from my weekly [reflection log](reflection-log.md). Abbreviations are explained in [abbreviations.md](abbreviations.md).*

## Design choices

I chose a cars and auto parts store because I have a soft spot for cars, and they make transport easier in busy Nigerian cities. My main design decision was to model **which part fits which car** (the PART_FITMENT table in Portfolio 1, and the `fitsModels` list in Portfolio 4). I wanted a customer to answer "does this fit my 2015 Corolla?" in one search.

Two choices changed how I think about design:
- **The same data, modelled two ways.** In PostgreSQL the order is spread over four tables and kept correct by keys and constraints. In MongoDB the whole order is one document. That is faster to read, but it has no foreign keys, so names copied into orders can go out of date.
- **The best design depends on the data.** For NaijaAutoMart I would keep payments and stock in PostgreSQL, and the catalogue, car listings and reviews in MongoDB.

## Challenges and how I solved them

- **Different versions behave differently (Portfolio 1).** Test 5 did not print PASSED on my PostgreSQL 18. It reported the blocked delete as `restrict_violation` (23001), while the test expected `foreign_key_violation` (23503). The fix was to accept both errors.
- **Never assume ID numbers (Portfolio 2).** My data script failed with a foreign key error because a failed insert in the Portfolio 1 tests had used up seller ID 7. I changed the script to look up real IDs instead of assuming them.
- **Not every index helps (Portfolio 2).** The composite index made the customer order-history query about 270× faster on my PC, but the monthly report did not improve until I used a materialized view. The indexes also made bulk inserts about 35% slower.
- **Transactions must start cleanly (Portfolio 3).** Error 25001 appeared because I set an isolation level after a query had already started a transaction in that tab. I learned that pgAdmin's Auto commit setting decides when a transaction begins.
- **Locks are real waits (Portfolio 3).** One tab waited 1 minute 6 seconds for the other tab's lock before it could see the true stock of 0. Seeing that explained the lost update problem better than any definition.
- **Results can surprise you (Portfolio 4).** Customer 4521 had no orders, yet without an index MongoDB still read all 30,008 orders to find that out. With the index, it read none.
- **Cloud limits (Portfolio 5).** The free Atlas tier cannot trigger a failover or be sharded, so I simulated sharding on my real data. A `w: 5` write was refused but still saved, which taught me that a write concern error does not undo a write.
- **Wait for confirmation (Portfolio 5).** My first restore check showed 0 parts because I ran it before the import had finished. A restore is only finished when the tool confirms it.

## Lessons learned

1. **Prove it with evidence.** "It became faster" means nothing without a before-and-after plan and a time.
2. **Every speed-up has a cost:** indexes slow down writes, materialized views go stale, and safer write concerns wait longer.
3. **Read the error message and find the real cause before changing code.** Most of my problems came from my environment, not from the logic.
4. **Use one case study throughout.** It made it easy to compare relational, document and distributed designs on the same data.
