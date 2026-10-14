// =====================================================================
// NaijaAutoMart - Portfolio 4
// Script 05: Indexes (before and after) and validation tests
//
// explain('executionStats') shows HOW MongoDB ran a query:
//   COLLSCAN = read every document (like Seq Scan in PostgreSQL)
//   IXSCAN   = used an index       (like Index Scan in PostgreSQL)
//   totalDocsExamined = how many documents it had to read
//
// HOW TO RUN: paste ONE STEP at a time into the Compass mongosh shell.
// Run AFTER script 02.
// =====================================================================

// STEP 1: a small helper that prints the important numbers from an explain()
db = db.getSiblingDB('naijaautomart');
function summary(label, ex) {
  var s = ex.executionStats, stages = [], wp = ex.queryPlanner.winningPlan;
  var node = wp.queryPlan || wp;                 // newer MongoDB versions nest the plan one level down
  while (node) { stages.push(node.stage + (node.indexName ? ' (' + node.indexName + ')' : ''));
                 node = node.inputStage || null; }
  printjson({ query: label, plan: stages.join(' <- '), returned: s.nReturned,
              docsExamined: s.totalDocsExamined, keysExamined: s.totalKeysExamined, timeMs: s.executionTimeMillis });
}

// STEP 2: BEFORE - customer 4521's orders, newest first (no index yet)
db.orders.dropIndexes();      // start without extra indexes (the _id index always stays)
try { db.parts.dropIndex('fitsModels.make_1_fitsModels.model_1_fitsModels.year_1'); } catch (e) { /* not created yet: fine */ }
summary('Q1 orders of customer 4521 - BEFORE',
        db.orders.find({ customerId: 4521 }).sort({ orderDate: -1 }).explain('executionStats'));
summary('Q2 parts that fit a 2015 Corolla - BEFORE',
        db.parts.find({ fitsModels: { $elemMatch: { make: 'Toyota', model: 'Corolla', year: 2015 } } }).explain('executionStats'));

// STEP 3: create the indexes
// Compound index: finds one customer's orders AND keeps them in date order
db.orders.createIndex({ customerId: 1, orderDate: -1 });
// MULTIKEY index: fitsModels is a list, so MongoDB indexes every model in every part's list
db.parts.createIndex({ 'fitsModels.make': 1, 'fitsModels.model': 1, 'fitsModels.year': 1 });
printjson(db.orders.getIndexes().map(function (i) { return i.name; }));
printjson(db.parts.getIndexes().map(function (i) { return i.name; }));

// STEP 4: AFTER - the same two queries
summary('Q1 orders of customer 4521 - AFTER',
        db.orders.find({ customerId: 4521 }).sort({ orderDate: -1 }).explain('executionStats'));
summary('Q2 parts that fit a 2015 Corolla - AFTER',
        db.parts.find({ fitsModels: { $elemMatch: { make: 'Toyota', model: 'Corolla', year: 2015 } } }).explain('executionStats'));

// STEP 5: VALIDATION TESTS - each insert breaks a rule from script 01 and must be REJECTED
function mustFail(label, fn) {
  try { fn(); print('FAILED: ' + label + ' was accepted'); }
  catch (e) { print('PASSED (' + label + ' blocked): ' + (e.errmsg || e.message)); }
}
mustFail('negative price', function () {
  db.parts.insertOne({ partNumber: 'BAD-1', name: 'Bad part', brand: 'X', category: 'Tyres', price: -5000, stock: 1,
                       seller: { sellerId: 4, name: 'Ladipo AutoParts Ventures' }, fitsModels: [] });
});
mustFail('unknown category', function () {
  db.parts.insertOne({ partNumber: 'BAD-2', name: 'Bad part', brand: 'X', category: 'Snacks', price: 500, stock: 1,
                       seller: { sellerId: 4, name: 'Ladipo AutoParts Ventures' }, fitsModels: [] });
});
mustFail('order with no items', function () {
  db.orders.insertOne({ _id: 999999, customerId: 1, orderDate: new Date(), status: 'Pending', items: [] });
});
mustFail('VIN shorter than 17 characters', function () {
  db.cars.insertOne({ vin: 'ABC123', make: 'Toyota', model: 'Corolla', year: 2015, condition: 'Foreign Used',
                      price: 5000000, status: 'Available', dealer: { sellerId: 1, name: 'Lekki Prime Autos' } });
});
mustFail('duplicate customer email', function () {
  db.customers.insertOne({ name: { first: 'Fake', last: 'User' }, email: 'chinedu.okafor@gmail.com',
                           phone: '08000000001', address: { city: 'Ikeja', state: 'Lagos' } });
});
