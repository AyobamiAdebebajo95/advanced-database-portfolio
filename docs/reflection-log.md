# Reflection Log

One short entry each week: what I decided, what went wrong, and what I learned.

## Week 1 – Setup and Portfolio 1: Database Design (6–7 Oct 2026)

**Why I chose this case study?**
I chose a cars and auto parts store (an online e-commerce store) because I have a soft spot for cars, and they make transportation easier in busy urban cities. Creating a database system for them allows car enthusiasts ease of navigation and could make the world better.

**Design decisions?**
The reason I gave more explicit direction to the design with regard to model fits, part fits and more is to dive deep into product fit and ease of use for the customers: what they truly need, and what level of ease I can give them when purchasing vehicle parts or cars.

**Problems I faced and what I learned?**
When I ran Test 5, it didn't print PASSED on my PC. My PostgreSQL 18 reported the blocked delete as `restrict_violation` (23001), but the test only expected `foreign_key_violation` (23503). I was a bit confused about why that test script failed, but I was able to realise that different database versions behave differently based on which conditions have been set for certain queries to fly.

I also realised that when highlighting queries to run, it is better to highlight all parts of the query block and not leave any part unhighlighted, because the result would be an error.

Also, always make sure to refresh pgAdmin, so that the most recently created or inserted tables show up.

**Looking ahead to query optimisation?**
For query optimisation, I am looking forward to running queries that would make the system work efficiently and return results faster.

## Week 2 – Portfolio 2: Query Optimisation (12 Oct 2026)

**Problem I faced and what I learned?**
When the Portfolio 2 data script failed, my first thought was that it was a primary key issue caused by conflicting data. After a few minutes of reflection, I realised the real cause was how rows had been inserted earlier: a failed insert in my Portfolio 1 tests had used up seller ID 7, so seller 7 never existed and the foreign key on the part table stopped my script from running. Going forward, I will test my scripts to make sure they do not assume ID numbers, so there are no ID collisions.

## Week 3 – Portfolio 3: Transactions and Concurrency (13 Oct 2026)

**Problem I faced and what I learned?**
At first I thought error 25001 was a syntax error, but I realised that pgAdmin's Auto commit setting decides when a transaction starts, and it can cause an error if I don't take it into account. Seeing a lock in action showed me that one transaction can be held back until another one finishes. In the lost update test, the system could not tell that another transaction had already sold the last headlamp, so it was sold twice, but this was easy to fix. Where possible, I would use the one-step `UPDATE … WHERE` fix, because it is simple.

## Week 4 – Portfolio 4: NoSQL and Advanced Data Models (14 Oct 2026)

**Problem I faced and what I learned?**
A syntax error happens when part of the JavaScript script is not pasted in full. I also realised that, without an index, MongoDB reads through every record to find what it needs (a COLLSCAN), just like a Seq Scan in PostgreSQL. This uses a lot of resources, and an index fixes it in both databases. A weakness I noticed is that seller and customer names copied into other documents can go out of date.

## Week 5 – Portfolio 5: Distributed and Cloud Database (19 Oct 2026)

**Problem I faced and what I learned?**
Because my free cluster is hosted in Cape Town, the distance from Nigeria affected the speed of every request, and also the speed of exporting and importing. I think payments and stock need strong consistency, but the catalogue needs less consistency.
