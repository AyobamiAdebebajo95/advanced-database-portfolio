// =====================================================================
// NaijaAutoMart - Portfolio 4
// Script 04: Reports with the AGGREGATION PIPELINE
//
// An aggregation pipeline passes documents through stages, like an
// assembly line:  $match (filter) -> $unwind (split a list) -> $group (total)
// -> $sort -> $lookup (join to another collection) -> $project (shape output)
//
// HOW TO RUN: paste ONE STEP at a time into the Compass mongosh shell.
// =====================================================================

// STEP 1: revenue by part category for September 2026 (same report as Portfolio 2's Q5)
// No join to a parts table is needed: each order item already stores its category.
db = db.getSiblingDB('naijaautomart');
printjson(db.orders.aggregate([
  { $match: { orderDate: { $gte: new Date('2026-09-01T00:00:00Z'), $lt: new Date('2026-10-01T00:00:00Z') },
              status: { $ne: 'Cancelled' } } },
  { $unwind: '$items' },
  { $group: { _id: '$items.category',
              orders: { $addToSet: '$_id' },
              revenue: { $sum: { $multiply: ['$items.quantity', '$items.unitPrice'] } } } },
  { $project: { _id: 0, category: '$_id', orders: { $size: '$orders' }, revenue: 1 } },
  { $sort: { revenue: -1 } }
]).toArray());

// STEP 2: best-rated parts (reads the rating summary stored inside each part)
printjson(db.parts.aggregate([
  { $match: { 'rating.count': { $gte: 1 } } },
  { $project: { _id: 0, name: 1, brand: 1, average: '$rating.average', reviews: '$rating.count' } },
  { $sort: { average: -1, name: 1 } }
]).toArray());

// STEP 3: number of orders and money spent per state (top 5)
printjson(db.orders.aggregate([
  { $match: { status: { $ne: 'Cancelled' } } },
  { $unwind: '$items' },
  { $group: { _id: '$delivery.state', orders: { $addToSet: '$_id' },
              spent: { $sum: { $multiply: ['$items.quantity', '$items.unitPrice'] } } } },
  { $project: { _id: 0, state: '$_id', orders: { $size: '$orders' }, spent: 1 } },
  { $sort: { spent: -1 } },
  { $limit: 5 }
]).toArray());

// STEP 4: $lookup - JOIN orders to customers (customers are REFERENCED, not embedded)
// The 8 Portfolio 1 orders, each with the customer's name and city from the customers collection
printjson(db.orders.aggregate([
  { $match: { _id: { $lte: 8 } } },
  { $lookup: { from: 'customers', localField: 'customerId', foreignField: '_id', as: 'customer' } },
  { $unwind: '$customer' },
  { $project: { _id: 1, status: 1,
                customer: { $concat: ['$customer.name.first', ' ', '$customer.name.last'] },
                city: '$customer.address.city',
                total: { $sum: { $map: { input: '$items', as: 'i', in: { $multiply: ['$$i.quantity', '$$i.unitPrice'] } } } } } },
  { $sort: { _id: 1 } }
]).toArray());

// STEP 5: which car models have the most parts available? ($unwind on the fitsModels list)
printjson(db.parts.aggregate([
  { $unwind: '$fitsModels' },
  { $group: { _id: { make: '$fitsModels.make', model: '$fitsModels.model', year: '$fitsModels.year' }, parts: { $sum: 1 } } },
  { $sort: { parts: -1 } },
  { $limit: 5 }
]).toArray());
