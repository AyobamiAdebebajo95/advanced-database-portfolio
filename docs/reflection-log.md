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
