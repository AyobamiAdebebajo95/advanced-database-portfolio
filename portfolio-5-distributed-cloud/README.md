# Portfolio 5: Distributed and Cloud Database Exercise

This portfolio takes the NaijaAutoMart MongoDB database from Portfolio 4, now running in the cloud on **MongoDB Atlas**, and shows how it works as a **distributed** database. It covers replication, consistency, transactions, a sharding design and backup/restore. Every test runs on the real Atlas cluster.

*Abbreviations are spelled out on first use. Full list: [abbreviations.md](../docs/abbreviations.md).*

| Required by the brief | Where to find it |
|---|---|
| Distributed/cloud setup based on the same case study | [The cloud deployment](#1-the-cloud-deployment), [01_replica_set.js](scripts/01_replica_set.js) |
| Replication | [Replication](#2-replication), [01_replica_set.js](scripts/01_replica_set.js) |
| Consistency | [Consistency](#3-consistency-how-up-to-date-is-each-read), [02_consistency.js](scripts/02_consistency.js), [03_distributed_transaction.js](scripts/03_distributed_transaction.js) |
| Sharding | [Sharding design](#4-sharding-design), [04_sharding_design.js](scripts/04_sharding_design.js) |
| Availability | [Availability](#5-availability-failover-and-backups), [05_backup_restore.js](scripts/05_backup_restore.js) |
| Deployment evidence | [Evidence](#evidence): Atlas screenshots and script output |

---

## 1. The cloud deployment

| Item | My setup |
|---|---|
| Service | MongoDB Atlas, a DBaaS (Database as a Service): MongoDB runs the servers, I only connect |
| Tier | **M0** (free) |
| Shape | **Replica set** `atlas-z2bk50-shard-0`: **3 nodes** (1 primary, 2 secondaries) |
| Database | `naijaautomart` (the 4 collections from Portfolio 4: 5,000 customers, 2,000 parts, 8 cars, 30,008 orders) |
| Client | MongoDB Compass and its built-in mongosh (MongoDB Shell), on my Windows PC |
| Security | Database user with a password; only my IP (Internet Protocol) address is allowed in (Network Access). The connection string and password are **never** stored in the scripts or on GitHub |

![Current architecture](architecture-now.png)

*How the app would use it: writes and important reads go to the primary; catalogue browsing can be served by a secondary; payments stay in PostgreSQL (the polyglot design from Portfolio 4).*

---

## 2. Replication

**What it is:** the same data is kept on 3 servers. The **primary** takes every write and records it in its **oplog** (operation log). The two **secondaries** read the oplog and repeat each change, so they hold copies of the data.

**Why NaijaAutoMart needs it:**
- **No single point of failure.** If one server dies, two copies remain and the shop stays open.
- **Read scaling.** Customers browsing parts can be served by secondaries, taking load off the primary.

**What script 01 shows:**

| Step | Shows |
|---|---|
| 1 | `hello()` lists the replica set name, the **3 member servers** and which one is the primary |
| 2 | `rs.status()` is **blocked** on the free tier: a real limit of M0 (see [Limits](#limits-of-the-free-tier-honestly)) |
| 3 | The same query sent with read preference `primary` and then `secondary` is answered by **different servers** (`explain().serverInfo.host`) |
| 4 | A delivery event written to the primary is read back from a **secondary**: the data really was copied |

---

## 3. Consistency: how up to date is each read?

With 3 copies, a secondary can be a few milliseconds behind the primary. MongoDB lets the application choose, **per operation**, between speed and safety:

| Setting | Options | In simple words |
|---|---|---|
| **Write concern** | `w: 1` | "Saved" once the primary has it. Fast, but if the primary crashes before copying it, the write can be lost |
| | `w: 'majority'` | "Saved" once **2 of 3** servers have it. Slower, but survives a failover |
| **Read concern** | `local` / `majority` | Read the newest data on that server, or only data a majority already has (can never be rolled back) |
| **Read preference** | `primary` / `secondary` | Which server answers |

**What script 02 tests:**
1. **Speed:** 100 inserts with `w: 1` vs 100 with `w: 'majority'`.
2. **`w: 5` on a 3-node set** is refused straight away (`UnsatisfiableWriteConcern`): the write concern really counts servers.
3. **Stale reads:** write with `w: 1`, then immediately read from a secondary, 100 times, counting how often the secondary has not caught up yet.
4. **Read your own writes:** the same test inside a **causally consistent session** (`w: 'majority'` + read concern `majority`). The secondary **waits** until it has the write, so a miss is impossible.

**Script 03: a transaction across the replica set.** Placing an order changes two collections (stock in `parts`, a new document in `orders`). A multi-document **ACID** (Atomicity, Consistency, Isolation, Durability) transaction with `writeConcern: 'majority'` makes it all-or-nothing:

| Step | Test | Expected result |
|---|---|---|
| 2 | Aisha buys 2 batteries | **COMMITTED**: stock 25 → 23, order 50001 saved |
| 3 | Emeka buys a sold-out stabiliser link | **ROLLED BACK** at the first step: nothing changed |
| 4 | Tunde buys a battery, but the order number is already used | **ROLLED BACK** at the last step: the stock change inside the transaction is undone, so stock stays at 23 |

### CAP theorem: what NaijaAutoMart chooses

The **CAP** theorem says that when the network between servers breaks (a **P**artition), a distributed database must choose between **C**onsistency (every read sees the latest write) and **A**vailability (every request gets an answer). A MongoDB replica set chooses **consistency** for writes: only the side of the partition with a majority of nodes can have a primary, and the minority side refuses writes rather than accept ones that could clash.

Different NaijaAutoMart data needs different trade-offs:

| Operation | Needs | Settings | Why |
|---|---|---|---|
| Payment, stock update, placing an order | **Strong consistency** | Primary, `w: 'majority'`, transaction | Selling stock twice or losing a paid order costs real money |
| "My orders" page after checkout | **Read your own writes** | Causal session, read concern `majority` | The customer must see the order they just placed |
| Browsing the parts catalogue, car listings | **Eventual consistency is fine** | Read preference `secondary` | A price that is 50 ms old does no harm; spreading reads keeps the site fast |
| Delivery tracking events, reviews | **Eventual consistency, fast writes** | `w: 1` | High volume; losing one GPS (Global Positioning System) update in a rare crash is acceptable |

**Synchronous vs asynchronous replication.** MongoDB copies data **asynchronously**: the primary does not wait for the secondaries unless the write concern asks it to. `w: 'majority'` makes a write wait for a second copy, which gives most of the safety of synchronous replication without waiting for every node.

---

## 4. Sharding design

**Replication copies** the data; **sharding splits** it. Each **shard** is its own replica set holding part of the data, and a **mongos router** sends each query to the right shard. NaijaAutoMart would need this once orders outgrow one server, or to keep Lagos traffic from slowing everyone else.

The free tier cannot be sharded (Atlas needs a paid M30 or larger cluster), so script 04 **simulates 3 shards** on the real 30,008 orders to choose the **shard key** for `orders`:

| Candidate key | What the simulation shows | Verdict |
|---|---|---|
| `delivery.state` | Only **11 different values**. **Lagos alone is about 18%** of orders and can never be split across shards, because all orders with the same key value stay together. Growth in Lagos would overload one shard | ❌ Low cardinality (few possible values), hotspot |
| `orderDate` (ranges) | Old orders spread evenly over 3 shards, but **every new order** (October 2026) lands on the shard holding the newest dates | ❌ Write hotspot: one shard takes all new orders |
| **`customerId` (hashed)** | Orders spread evenly over all 3 shards, and **new** orders spread evenly too | ✅ **Chosen** |

**Trade-off of the chosen key:**
- **Targeted queries are fast.** "My orders" for one customer goes to **one** shard, which is the most common query in the app.
- **Reports are scatter-gather.** "Revenue for September" must ask **all** shards and merge the answers. That is acceptable for a nightly report, and Portfolio 4's analysis could run on a secondary or an analytics node.
- **Rebalancing:** when a 4th shard is added, the balancer moves chunks (ranges of hash values) to it automatically, with no downtime.

**Possible next step:** add **zone sharding** with a key such as `{ region: 1, customerId: 'hashed' }` to keep each region's orders on servers in or near Nigeria.

![Target sharded architecture](architecture-target.png)

---

## 5. Availability: failover and backups

**Automatic failover.** If the primary stops answering heartbeats for about 10 seconds, the secondaries hold an **election** and one becomes the new primary. MongoDB drivers use **retryable writes**, so an order sent during the switch is retried once on the new primary instead of failing. With 3 nodes the cluster survives **1** server failing (2 of 3 is still a majority).

**Replication is not a backup.** If an admin deletes the parts catalogue by mistake, the delete is copied to all 3 servers within milliseconds. Script 05 tests a real **backup and restore**: export `parts` from Compass, delete every part, import the file, then check that the count, total stock and a sample part all match.

| Target | Meaning | NaijaAutoMart goal | How |
|---|---|---|---|
| **RPO** (Recovery Point Objective) | How much data we can afford to lose | Orders and payments: **0**. Catalogue: **24 hours** | `w: 'majority'` for orders; daily backups for the catalogue |
| **RTO** (Recovery Time Objective) | How long we can be down | Checkout: **under 1 minute**. Restore of a lost collection: **under 1 hour** | Automatic failover (seconds); restore time measured in script 05 |

### Limits of the free tier, honestly

| Limit on M0 | Effect on this portfolio | What a production NaijaAutoMart would use |
|---|---|---|
| No "Test Primary Failover" button (Atlas allows it on M10 and above) | Failover is explained, not triggered | M10+ cluster, and test failover before launch |
| Cannot be sharded | Sharding is simulated on real data (script 04) | M30+ sharded cluster with hashed `customerId` |
| `rs.status()` is blocked | Replica set shown with `hello()` and `explain()` instead | Full monitoring in Atlas |
| Fixed at 3 nodes in one region | Survives a server failure, not a whole-region outage | Nodes in 2–3 regions |

---

## How to run it

1. Run Portfolio 4's scripts first, so the `naijaautomart` data exists on Atlas.
2. In Compass, open the **`>_`** mongosh shell on your Atlas connection.
3. Paste **one STEP at a time** from scripts **01 → 05**, in order. Script 05 has two mouse steps in Compass, explained in the script.
4. Scripts can be re-run: each one resets its own test data first.

| Script | What it shows |
|---|---|
| [01_replica_set.js](scripts/01_replica_set.js) | The 3-node replica set; reads served by primary vs secondary; a write copied to a secondary |
| [02_consistency.js](scripts/02_consistency.js) | Write concern speed, `w: 5` refused, stale reads vs a causally consistent session |
| [03_distributed_transaction.js](scripts/03_distributed_transaction.js) | Place-order transaction: 1 commit and 2 rollbacks |
| [04_sharding_design.js](scripts/04_sharding_design.js) | Three shard keys compared on real data; targeted vs scatter-gather queries |
| [05_backup_restore.js](scripts/05_backup_restore.js) | Backup, accidental delete, restore, check |

*How these were checked: the script logic was tested in an in-memory MongoDB-compatible engine (mingo) with a stand-in replica set before running on Atlas. The real Atlas run is the evidence below.*

---

## Evidence

*Screenshots from MongoDB Atlas and Compass: to be added.*
