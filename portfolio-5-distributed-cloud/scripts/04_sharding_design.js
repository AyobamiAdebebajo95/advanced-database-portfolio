// =====================================================================
// NaijaAutoMart - Portfolio 5: Distributed and Cloud Database Exercise
// Script 04: SHARDING design - choosing a shard key for the orders collection
//
// SHARDING splits ONE collection across several replica sets (shards), so no single
// server has to hold all the data or take all the writes. The SHARD KEY decides
// which shard each document goes to. A bad key creates a HOTSPOT: one busy shard
// while the others sit idle.
//
// The free Atlas tier cannot be sharded (Atlas needs a paid M30+ cluster), so this
// script SIMULATES 3 shards on the real 30,008 orders from Portfolio 4 and compares
// three candidate shard keys.
//
// HOW TO RUN: paste ONE STEP at a time into the Compass mongosh shell.
// =====================================================================

// STEP 1: Candidate A - shard by delivery STATE
// Only 11 different values, and every Lagos order would have to stay together on ONE shard.
db = db.getSiblingDB('naijaautomart');
var total = db.orders.countDocuments();
printjson(db.orders.aggregate([
  { $group: { _id: '$delivery.state', orders: { $sum: 1 } } },
  { $project: { _id: 0, state: '$_id', orders: 1,
                percent: { $round: [{ $multiply: [{ $divide: ['$orders', total] }, 100] }, 1] } } },
  { $sort: { orders: -1 } }
]).toArray());

// STEP 2: Candidate B - shard by ORDER DATE (ranges of dates)
// Old orders spread out fine, but every NEW order has the newest date, so ALL new writes
// land on the shard that holds the latest range: a write hotspot.
function dateShard() {
  return { $switch: { branches: [
    { case: { $lt: ['$orderDate', new Date('2025-08-01')] }, then: 'shard A (Jan-Jul 2025)' },
    { case: { $lt: ['$orderDate', new Date('2026-03-01')] }, then: 'shard B (Aug 2025-Feb 2026)' } ],
    default: 'shard C (Mar 2026 onwards)' } };
}
printjson({
  allOrders: db.orders.aggregate([{ $group: { _id: dateShard(), orders: { $sum: 1 } } }, { $sort: { _id: 1 } }]).toArray(),
  ordersInOctober2026: db.orders.aggregate([
    { $match: { orderDate: { $gte: new Date('2026-10-01') } } },
    { $group: { _id: dateShard(), orders: { $sum: 1 } } }, { $sort: { _id: 1 } }]).toArray()
});

// STEP 3: Candidate C - HASHED customerId
// MongoDB hashes the key and splits the hash values into equal ranges, one per shard.
// $toHashedIndexKey uses the same hash function as a hashed shard key.
// (If your MongoDB version does not know $toHashedIndexKey, the catch uses customerId mod 3 instead.)
function hashShard() {
  var B = NumberLong('3074457345618258602');          // 2^63 / 3: splits all hash values into 3 equal ranges
  return { $let: { vars: { h: { $toHashedIndexKey: '$customerId' } }, in: { $switch: { branches: [
    { case: { $lt: ['$$h', { $multiply: [B, -1] }] }, then: 'shard A' },
    { case: { $lt: ['$$h', B] }, then: 'shard B' } ], default: 'shard C' } } } };
}
function modShard() {
  return { $switch: { branches: [
    { case: { $eq: [{ $mod: ['$customerId', 3] }, 0] }, then: 'shard A' },
    { case: { $eq: [{ $mod: ['$customerId', 3] }, 1] }, then: 'shard B' } ], default: 'shard C' } };
}
var shardOf = hashShard, method = 'hashed customerId ($toHashedIndexKey)';
try {   // quick test on 300 orders: the real hash must spread them over more than one shard
  if (db.orders.aggregate([{ $limit: 300 }, { $group: { _id: hashShard() } }]).toArray().length < 2) throw new Error('no spread');
} catch (e) { shardOf = modShard; method = 'customerId mod 3 (stand-in for the hash)'; }
printjson({
  method: method,
  allOrders: db.orders.aggregate([{ $group: { _id: shardOf(), orders: { $sum: 1 } } }, { $sort: { _id: 1 } }]).toArray(),
  ordersInOctober2026: db.orders.aggregate([
    { $match: { orderDate: { $gte: new Date('2026-10-01') } } },
    { $group: { _id: shardOf(), orders: { $sum: 1 } } }, { $sort: { _id: 1 } }]).toArray()
});

// STEP 4: TARGETED vs SCATTER-GATHER queries under hashed customerId
// "My orders" for one customer goes to ONE shard. A company-wide report must ask ALL shards.
printjson({
  myOrders_customer1_shardsAsked: db.orders.aggregate([
    { $match: { customerId: 1 } }, { $group: { _id: shardOf() } }]).toArray().length,
  septemberRevenueReport_shardsAsked: db.orders.aggregate([
    { $match: { orderDate: { $gte: new Date('2026-09-01'), $lt: new Date('2026-10-01') } } },
    { $group: { _id: shardOf() } }]).toArray().length
});
