// =====================================================================
// NaijaAutoMart - Portfolio 4: NoSQL (Not only SQL) and Advanced Data Models
// Script 01: Create the collections, with validation rules
//
// MongoDB stores DOCUMENTS (like JSON) in COLLECTIONS (like tables).
// Documents in one collection do not need identical fields, which suits
// auto parts: a tyre has a size, a battery has amp-hours, a filter has neither.
//
// "Schemaless" does not mean "no rules": $jsonSchema validation still
// rejects bad data, e.g. a negative price (tested in script 05).
//
// HOW TO RUN (MongoDB Compass connected to Atlas):
//   click ">_" (Open MongoDB shell) at the top of your connection,
//   then paste ONE STEP at a time and press Enter.
// =====================================================================

// STEP 1: switch to the naijaautomart database and start clean
db = db.getSiblingDB('naijaautomart');
['parts', 'cars', 'customers', 'orders'].forEach(function (c) { db.getCollection(c).drop(); });

// STEP 2: PARTS - one document per part, with its own attributes and the car models it fits
db.createCollection('parts', {
  validator: { $jsonSchema: {
    bsonType: 'object',
    required: ['partNumber', 'name', 'brand', 'category', 'price', 'stock', 'seller', 'fitsModels'],
    properties: {
      partNumber: { bsonType: 'string' },
      name:       { bsonType: 'string' },
      brand:      { bsonType: 'string' },
      category:   { enum: ['Tyres', 'Batteries', 'Brakes', 'Engine Parts', 'Filters', 'Suspension', 'Lighting'] },
      price:      { bsonType: 'number', minimum: 1,
                    description: 'price in Naira, must be more than 0' },
      stock:      { bsonType: 'number', minimum: 0,
                    description: 'stock can never go below zero' },
      attributes: { bsonType: 'object',
                    description: 'different fields for different kinds of part' },
      seller:     { bsonType: 'object', required: ['sellerId', 'name'] },
      fitsModels: { bsonType: 'array',
                    items: { bsonType: 'object', required: ['make', 'model', 'year'] } }
    }
  } }
});

// STEP 3: CARS - one document per car for sale; inspections are stored inside the car
db.createCollection('cars', {
  validator: { $jsonSchema: {
    bsonType: 'object',
    required: ['vin', 'make', 'model', 'year', 'condition', 'price', 'status', 'dealer'],
    properties: {
      vin:       { bsonType: 'string', minLength: 17, maxLength: 17 },
      year:      { bsonType: 'number', minimum: 1980, maximum: 2027 },
      condition: { enum: ['Brand New', 'Foreign Used', 'Nigerian Used'] },
      price:     { bsonType: 'number', minimum: 1 },
      status:    { enum: ['Available', 'Reserved', 'Sold'] }
    }
  } }
});

// STEP 4: CUSTOMERS
db.createCollection('customers', {
  validator: { $jsonSchema: {
    bsonType: 'object',
    required: ['name', 'email', 'phone', 'address'],
    properties: {
      email: { bsonType: 'string', pattern: '^.+@.+\\..+$' },
      phone: { bsonType: 'string' }
    }
  } }
});

// STEP 5: ORDERS - the items and payments are stored INSIDE the order
db.createCollection('orders', {
  validator: { $jsonSchema: {
    bsonType: 'object',
    required: ['customerId', 'orderDate', 'status', 'items'],
    properties: {
      customerId: { bsonType: 'number' },
      orderDate:  { bsonType: 'date' },
      status:     { enum: ['Pending', 'Paid', 'Shipped', 'Delivered', 'Cancelled'] },
      items: {
        bsonType: 'array', minItems: 1,
        items: { bsonType: 'object', required: ['partId', 'quantity', 'unitPrice'],
                 properties: { quantity:  { bsonType: 'number', minimum: 1 },
                               unitPrice: { bsonType: 'number', minimum: 1 } } }
      }
    }
  } }
});

// STEP 6: UNIQUE rules (same as Portfolio 1) and a check that everything exists
db.customers.createIndex({ email: 1 }, { unique: true });
db.cars.createIndex({ vin: 1 }, { unique: true });
db.parts.createIndex({ partNumber: 1 }, { unique: true });
printjson(db.getCollectionNames().sort());
