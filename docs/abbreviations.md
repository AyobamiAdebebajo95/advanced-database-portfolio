# Abbreviations Used in This Portfolio

Each abbreviation is also spelled out the first time it appears on each page. This list grows as new portfolios are added.

## Course and general

| Abbreviation | Full meaning |
|---|---|
| **MIT** | Master of Information Technology (the course code MIT 8103) |
| **MIVA** | MIVA Open University (the university's name) |
| **CA** | Continuous Assessment |
| **AI** | Artificial Intelligence |
| **ID** | Identifier: a number or code that uniquely identifies a record |
| **PC** | Personal Computer |
| **FCT** | Federal Capital Territory (Abuja) |
| **IP** | Internet Protocol: an IP address identifies a computer on the internet |
| **GPS** | Global Positioning System |

## Databases

| Abbreviation | Full meaning | In simple words |
|---|---|---|
| **DB** | Database | An organised store of data |
| **SQL** | Structured Query Language | The language used to create and query relational databases |
| **NoSQL** | Not only SQL | Databases that store data in other forms, such as documents (used in Portfolio 4) |
| **ER** | Entity-Relationship | An ER diagram shows the things (entities) a database stores and how they are linked |
| **PK** | Primary Key | The column(s) that uniquely identify each row in a table |
| **FK** | Foreign Key | A column that points to a row in another table |
| **UK** | Unique Key | A column (or columns) where no two rows can have the same value |
| **UNF** | Unnormalised Form | Raw data before any normalisation, often with several values in one cell |
| **1NF** | First Normal Form | Every cell holds one value; no repeating groups |
| **2NF** | Second Normal Form | 1NF, and every column depends on the whole primary key |
| **3NF** | Third Normal Form | 2NF, and no column depends on another non-key column |
| **BCNF** | Boyce-Codd Normal Form | A stricter version of 3NF: everything that decides other columns must be a key |
| **Q1–Q6** | Query 1 to Query 6 | The numbered example queries in each portfolio's scripts |
| **ACID** | Atomicity, Consistency, Isolation, Durability | The four promises a transaction makes (Portfolio 3) |
| **PL/pgSQL** | Procedural Language / PostgreSQL | The language used to write database functions such as `place_order()` |
| **ms** | Millisecond | One thousandth of a second; used for query times |
| **KB / MB** | Kilobyte / Megabyte | Units of storage size (1 MB = 1,024 KB); a database page is 8 KB |
| **CRUD** | Create, Read, Update, Delete | The four basic things you do with data |
| **JSON** | JavaScript Object Notation | A text format for data made of `{ "field": value }` pairs; MongoDB documents look like JSON |
| **BSON** | Binary JSON | How MongoDB actually stores documents on disk (JSON plus extra types such as dates) |
| **COLLSCAN / IXSCAN** | Collection Scan / Index Scan | MongoDB's versions of Seq Scan and Index Scan in a query plan |
| **mongosh** | MongoDB Shell | The command line for MongoDB; built into Compass |
| **Atlas** | MongoDB Atlas | MongoDB's cloud database service (used for Portfolios 4 and 5) |
| **DBaaS** | Database as a Service | A cloud provider runs the database servers; you only connect to them (e.g. Atlas) |
| **M0 / M10 / M30** | Atlas cluster tiers | M0 is the free tier; M10 and above can test failover; M30 and above can be sharded |
| **oplog** | Operation log | The list of every change on the primary, which the secondaries copy (replication) |
| **mongos** | MongoDB Shard router | Sends each query to the shard(s) that hold the data |
| **CAP** | Consistency, Availability, Partition tolerance | When the network splits, a distributed database must choose between consistency and availability |
| **RPO** | Recovery Point Objective | How much data the business can afford to lose |
| **RTO** | Recovery Time Objective | How long the business can afford to be down |

## Cars and auto parts

| Abbreviation | Full meaning |
|---|---|
| **VIN** | Vehicle Identification Number: a unique 17-character code for every car |
| **Ah** | Ampere-hour: how much charge a car battery holds (e.g. 75Ah) |
| **R16 / R18** | Radial tyre for a 16-inch / 18-inch wheel rim (e.g. 205/55 R16) |
| **H4** | A standard headlight bulb type |

## Tools

| Abbreviation | Full meaning |
|---|---|
| **pgAdmin** | PostgreSQL Administration tool: the graphical app for managing PostgreSQL |
| **psql** | PostgreSQL's command-line tool |
| **VS Code** | Visual Studio Code: a free code editor |
| **WSL** | Windows Subsystem for Linux: lets Windows run Linux tools (used by Docker, which this portfolio did not need) |
| **PNG** | Portable Network Graphics: an image file format |
