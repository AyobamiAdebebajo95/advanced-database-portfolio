// =====================================================================
// NaijaAutoMart - Portfolio 5: Distributed and Cloud Database Exercise
// Script 03: An ACID transaction on the replica set (place an order)
//
// ACID = Atomicity, Consistency, Isolation, Durability.
// Placing an order reads the customer, then changes TWO documents in TWO collections:
//   1. parts  - take the quantity off the stock
//   2. orders - create the order (with the customer's delivery address)
// Both must happen, or neither. MongoDB runs this as a multi-document transaction
// on the replica set. writeConcern 'majority' means the commit is only confirmed
// once 2 of the 3 servers have it, so it survives the primary failing.
// This is the MongoDB version of Portfolio 3's place_order() function.
//
// HOW TO RUN: paste ONE STEP at a time into the Compass mongosh shell.
// =====================================================================

// STEP 1: reset the test data and create placeOrder()
db = db.getSiblingDB('naijaautomart');
db.orders.deleteMany({ _id: { $gte: 50001, $lte: 50003 } });
db.parts.updateOne({ _id: 2 },  { $set: { stock: 25 } });   // Car Battery 75Ah: 25 in stock
db.parts.updateOne({ _id: 14 }, { $set: { stock: 0 } });    // Stabiliser Link: sold out

function placeOrder(orderId, customerId, partId, qty) {
  var session = db.getMongo().startSession();
  var sdb = session.getDatabase('naijaautomart');
  session.startTransaction({ readConcern: { level: 'snapshot' }, writeConcern: { w: 'majority' } });
  try {
    var part = sdb.parts.findOne({ _id: partId });
    var cust = sdb.customers.findOne({ _id: customerId });
    // 1. take stock off, ONLY if there is enough (same idea as Portfolio 3, Fix 2)
    var r = sdb.parts.updateOne({ _id: partId, stock: { $gte: qty } }, { $inc: { stock: -qty } });
    if (r.modifiedCount !== 1) throw new Error('not enough stock for ' + part.name);
    // 2. create the order
    sdb.orders.insertOne({ _id: orderId, customerId: customerId,
      customerName: cust.name.first + ' ' + cust.name.last, orderDate: new Date(), status: 'Paid',
      items: [ { partId: partId, name: part.name, category: part.category, quantity: qty, unitPrice: part.price } ],
      payments: [ { amount: qty * part.price, method: 'Card', status: 'Successful' } ],
      delivery: { city: cust.address.city, state: cust.address.state } });
    session.commitTransaction();
    return 'COMMITTED: order ' + orderId + ' saved, stock reduced by ' + qty;
  } catch (e) {
    session.abortTransaction();
    return 'ROLLED BACK: ' + (e.errmsg || e.message);
  } finally {
    session.endSession();
  }
}
function check() {
  printjson({ batteryStock: db.parts.findOne({ _id: 2 }).stock,
              stabiliserStock: db.parts.findOne({ _id: 14 }).stock,
              testOrdersSaved: db.orders.find({ _id: { $gte: 50001, $lte: 50003 } }).toArray().map(function (o) { return o._id; }) });
}
check();   // battery 25, stabiliser 0, no test orders

// STEP 2: COMMIT - Aisha (customer 2) buys 2 batteries
print(placeOrder(50001, 2, 2, 2));
check();   // battery 23, order 50001 saved

// STEP 3: ROLLBACK at the first step - Emeka (customer 7) wants a stabiliser link, but stock is 0
print(placeOrder(50002, 7, 14, 1));
check();   // nothing changed, no order 50002

// STEP 4: ROLLBACK at the LAST step - Tunde (customer 3) buys 1 battery, but the order
// number 50001 is already used. The stock WAS reduced inside the transaction, then the
// order insert failed, so the whole transaction is undone: the battery stock stays at 23.
print(placeOrder(50001, 3, 2, 1));
check();   // still battery 23 - atomicity: all or nothing
