// =====================================================================
// NaijaAutoMart - Portfolio 4
// Script 03: Everyday queries and updates (CRUD = Create, Read, Update, Delete)
//
// HOW TO RUN: paste ONE STEP at a time into the Compass mongosh shell.
// Run AFTER scripts 01 and 02.
// =====================================================================

// STEP 1 (READ): "Which parts fit my 2015 Toyota Corolla?"
// In PostgreSQL this needed 4 tables joined. Here the list of models is inside
// each part, so one query on one collection answers it.
db = db.getSiblingDB('naijaautomart');
printjson(db.parts.find(
  { fitsModels: { $elemMatch: { make: 'Toyota', model: 'Corolla', year: 2015 } }, _id: { $lte: 15 } },
  { _id: 1, name: 1, brand: 1, category: 1, price: 1, stock: 1, 'seller.name': 1 }
).sort({ category: 1, price: 1 }).toArray());

// STEP 2 (READ): search INSIDE the flexible attributes - 16-inch tyres only.
// Batteries and filters have no rimInches field at all, and that is fine.
printjson(db.parts.find(
  { category: 'Tyres', 'attributes.rimInches': 16, _id: { $lte: 15 } },
  { name: 1, brand: 1, price: 1, attributes: 1 }
).toArray());

// STEP 3 (READ): available automatic cars under N20 million, cheapest first
printjson(db.cars.find(
  { status: 'Available', transmission: 'Automatic', price: { $lt: 20000000 } },
  { _id: 0, make: 1, model: 1, year: 1, price: 1, 'dealer.name': 1, features: 1 }
).sort({ price: 1 }).toArray());

// STEP 4 (READ): one order, complete, in ONE read - items, payments and delivery included
printjson(db.orders.findOne({ _id: 3 }));

// STEP 5 (UPDATE): sell the last headlamp SAFELY.
// The condition (stock >= 1) and the change ($inc -1) happen in ONE atomic step,
// the same idea as Fix 2 in Portfolio 3. The second attempt finds no stock.
db.parts.updateOne({ _id: 10 }, { $set: { stock: 1 } });                 // reset to 1 headlamp
printjson(db.parts.updateOne({ _id: 10, stock: { $gte: 1 } }, { $inc: { stock: -1 } }));   // Chinedu: modifiedCount 1
printjson(db.parts.updateOne({ _id: 10, stock: { $gte: 1 } }, { $inc: { stock: -1 } }));   // Aisha:   modifiedCount 0
printjson(db.parts.findOne({ _id: 10 }, { name: 1, stock: 1 }));

// STEP 6 (UPDATE): add a new review and keep only the 5 most recent inside the part,
// updating the rating summary at the same time
printjson(db.parts.updateOne({ _id: 1 }, {
  $push: { recentReviews: { $each: [ { customerId: 3, name: 'Tunde A.', rating: 4, comment: 'Good grip on Ibadan roads.' } ], $slice: -5 } },
  $set:  { rating: { count: 1, average: 4 } }
}));
printjson(db.parts.findOne({ _id: 1 }, { name: 1, rating: 1, recentReviews: 1 }));

// STEP 7 (CREATE then DELETE): a test customer is added and removed again
printjson(db.customers.insertOne({ _id: 99999, name: { first: 'Test', last: 'User' }, email: 'test.user@example.ng',
                                   phone: '08000000000', address: { city: 'Ikeja', state: 'Lagos' } }));
printjson(db.customers.deleteOne({ _id: 99999 }));
