// =====================================================================
// NaijaAutoMart - Portfolio 5: Distributed and Cloud Database Exercise
// Script 02: CONSISTENCY - write concern, read concern and stale reads
//
// In a replica set the application chooses, per operation, how safe or how fast it wants to be:
//   WRITE CONCERN  w: 1          -> "OK" once the PRIMARY has the write (fast, can be lost in a failover)
//                  w: 'majority' -> "OK" once 2 of the 3 nodes have it (survives a failover)
//   READ CONCERN   'local'       -> newest data on that node, even if it could still be rolled back
//                  'majority'    -> only data that a majority of nodes have (can't be rolled back)
//   READ PREFERENCE primary / secondary -> which node answers the read
//
// Uses a deliveryEvents collection: GPS-style "where is my parcel" updates from delivery agents.
// HOW TO RUN: paste ONE STEP at a time into the Compass mongosh shell.
// =====================================================================

// STEP 1: start clean
db = db.getSiblingDB('naijaautomart');
db.deliveryEvents.drop();
db.createCollection('deliveryEvents');
print('deliveryEvents ready');

// STEP 2: SPEED - 100 inserts with w: 1, then 100 with w: 'majority'
// (Run this step twice and use the second result: the first run also warms up the connection.)
function timeInserts(label, wc, n) {
  var t0 = Date.now();
  for (var i = 0; i < n; i++) {
    db.deliveryEvents.insertOne({ test: label, orderId: 1 + (i % 8), status: 'Location update', at: new Date() },
                                { writeConcern: wc });
  }
  var ms = Date.now() - t0;
  return { writeConcern: label, inserts: n, totalMs: ms, averageMsPerInsert: Math.round(ms / n * 10) / 10 };
}
printjson([ timeInserts('w: 1', { w: 1 }, 100),
            timeInserts('w: majority', { w: 'majority' }, 100) ]);

// STEP 3: ask for MORE copies than exist. There are only 3 nodes, so w: 5 can never be met.
// MongoDB refuses instead of waiting forever. This shows w really counts servers.
try {
  db.deliveryEvents.insertOne({ test: 'w: 5' }, { writeConcern: { w: 5, wtimeout: 3000 } });
  print('accepted (unexpected)');
} catch (e) {
  print('REFUSED: ' + (e.codeName ? e.codeName + ' - ' : '') + (e.errmsg || e.message));
}

// STEP 4: STALE READS. Write with w: 1, then IMMEDIATELY read the same document from a secondary.
// If the secondary has not copied it yet, the read finds nothing: an "eventual consistency" miss.
var plainMisses = 0, n = 100;
for (var i = 0; i < n; i++) {
  db.deliveryEvents.insertOne({ _id: 'plain-' + i, orderId: 4, status: 'In transit' }, { writeConcern: { w: 1 } });
  if (db.deliveryEvents.find({ _id: 'plain-' + i }).readPref('secondary').toArray().length === 0) plainMisses++;
}
printjson({ test: 'w: 1, then read from a secondary', writesAndReads: n, notFoundOnSecondary: plainMisses });

// STEP 5: the SAFE way - a causally consistent session.
// w: 'majority' + readConcern 'majority' + causalConsistency means the secondary
// WAITS until it has my write before answering. "Read your own writes" is guaranteed.
var s = db.getMongo().startSession({ causalConsistency: true });
var sdb = s.getDatabase('naijaautomart');
var safeMisses = 0, t0 = Date.now();
for (var i = 0; i < n; i++) {
  sdb.deliveryEvents.insertOne({ _id: 'safe-' + i, orderId: 4, status: 'In transit' }, { writeConcern: { w: 'majority' } });
  if (sdb.deliveryEvents.find({ _id: 'safe-' + i }).readPref('secondary').readConcern('majority').toArray().length === 0) safeMisses++;
}
s.endSession();
printjson({ test: 'causal session: w majority + read concern majority, read from a secondary',
            writesAndReads: n, notFoundOnSecondary: safeMisses, totalMs: Date.now() - t0 });

// STEP 6: what is in deliveryEvents now
printjson(db.deliveryEvents.aggregate([
  { $group: { _id: { $cond: [ { $eq: [{ $type: '$_id' }, 'string'] },
                               { $arrayElemAt: [{ $split: ['$_id', '-'] }, 0] },   // 'plain-7' -> 'plain'
                               '$test' ] },
              documents: { $sum: 1 } } },
  { $sort: { _id: 1 } }
]).toArray());
