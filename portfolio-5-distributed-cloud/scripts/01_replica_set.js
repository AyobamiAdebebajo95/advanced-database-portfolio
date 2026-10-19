// =====================================================================
// NaijaAutoMart - Portfolio 5: Distributed and Cloud Database Exercise
// Script 01: Look inside the cloud deployment - the REPLICA SET
//
// My MongoDB Atlas cluster is not one server. It is a REPLICA SET:
// 3 servers (nodes) holding the same data.
//   - the PRIMARY takes every write
//   - the 2 SECONDARIES copy each change from the primary (replication)
// If the primary fails, the secondaries hold an ELECTION and one of them
// becomes the new primary, usually within a few seconds.
//
// HOW TO RUN: MongoDB Compass > your Atlas connection > ">_" (Open MongoDB shell).
// Paste ONE STEP at a time and press Enter. Run Portfolio 4's scripts first
// (this script reads the naijaautomart orders).
// =====================================================================

// STEP 1: who is in the replica set?
// hello() is the same command every MongoDB driver uses to find the primary.
db = db.getSiblingDB('naijaautomart');
var h = db.hello();
printjson({ replicaSet: h.setName, members: h.hosts, currentPrimary: h.primary,
            iAmConnectedTo: h.me, isThisNodeThePrimary: h.isWritablePrimary,
            mongodbVersion: db.version() });

// STEP 2: the full replica set status (rs.status)
// On the FREE M0 tier Atlas blocks this admin command, so the error message
// itself is evidence of a free-tier limit (see the README). On a paid tier it lists each node.
try {
  var st = rs.status();
  printjson(st.members.map(function (m) { return { node: m.name, role: m.stateStr, healthy: m.health === 1 }; }));
} catch (e) {
  print('rs.status() is not allowed here: ' + (e.errmsg || e.message));
}

// STEP 3: which server actually answers a read?
// explain() reports the server that ran the query (serverInfo.host).
// Read preference "primary" vs "secondary" sends the SAME query to DIFFERENT servers.
function servedBy(mode) {
  db.getMongo().setReadPref(mode);
  var ex = db.orders.find({ _id: 1 }).explain('executionStats');
  db.getMongo().setReadPref('primary');                       // always switch back
  return ex.serverInfo ? ex.serverInfo.host + ':' + ex.serverInfo.port : 'not shown';
}
printjson({ readPreference_primary: servedBy('primary'),
            readPreference_secondary: servedBy('secondary'),
            readPreference_secondary_again: servedBy('secondary') });

// STEP 4: write on the primary, read the same document back from a SECONDARY.
// This proves the data was copied (replicated) to another server.
db.deliveryEvents.drop();
printjson(db.deliveryEvents.insertOne(
  { _id: 'evt-1', orderId: 3, status: 'Out for delivery', city: 'Abuja', at: new Date() },
  { writeConcern: { w: 'majority' } }));
db.getMongo().setReadPref('secondary');
printjson({ readFromSecondary: db.deliveryEvents.findOne({ _id: 'evt-1' }) });
db.getMongo().setReadPref('primary');
