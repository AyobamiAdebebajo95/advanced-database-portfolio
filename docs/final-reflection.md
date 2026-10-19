# Individual Technical Reflection

**Adebajo Ayobamidele · Student ID 301931278 · MIT 8103 Advanced Database Systems**  
GitHub: [github.com/AyobamiAdebebajo95/advanced-database-portfolio](https://github.com/AyobamiAdebebajo95/advanced-database-portfolio)

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
- **Portfolio 3 (transactions and concurrency).** At first I thought error 25001 was a syntax error, but I realised that pgAdmin's Auto commit setting decides when a transaction starts, and it can cause an error if I don't take it into account. Seeing a lock in action showed me that one transaction can be held back until another one finishes. In the lost update test, the system could not tell that another transaction had already sold the last headlamp, so it was sold twice, but this was easy to fix. Where possible, I would use the one-step `UPDATE … WHERE` fix, because it is simple.
- **Portfolio 4 (NoSQL).** A syntax error happens when part of the JavaScript script is not pasted in full. I also realised that, without an index, MongoDB reads through every record to find what it needs (a COLLSCAN), just like a Seq Scan in PostgreSQL. This uses a lot of resources, and an index fixes it in both databases. A weakness I noticed is that seller and customer names copied into other documents can go out of date.
- **Portfolio 5 (distributed and cloud).** Because my free cluster is hosted in Cape Town, the distance from Nigeria affected the speed of every request, and also the speed of exporting and importing. I think payments and stock need strong consistency, but the catalogue needs less consistency.

## Lessons learned

1. **Prove it with evidence.** "It became faster" means nothing without a before-and-after plan and a time.
2. **Every speed-up has a cost:** indexes slow down writes, materialized views go stale, and safer write concerns can wait longer.
3. **Read the error message and find the real cause before changing code.** Most of my problems came from my environment, not from the logic.
4. **Use one case study throughout.** It made it easy to compare relational, document and distributed designs on the same data.
