// =====================================================================
// NaijaAutoMart - Portfolio 4
// Script 02: Insert the data as DOCUMENTS
//
// STEPS 1-4 load the SAME customers, parts, cars and orders as the
// Portfolio 1 PostgreSQL database, reshaped as documents.
// STEP 5 adds generated data (2,000 parts, 5,000 customers, 30,000 orders)
// so the index test in script 04 has enough data to show a difference.
//
// HOW TO RUN: paste ONE STEP at a time into the Compass mongosh shell.
// Use the SAME shell tab for all steps: STEP 5 reuses names made in STEPS 2-4.
// STEP 5 takes about 30-60 seconds on Atlas.
// =====================================================================

// STEP 1: CUSTOMERS (the 12 from Portfolio 1)
db = db.getSiblingDB('naijaautomart');
db.customers.insertMany([
  { _id: 1,  name: { first: 'Chinedu',  last: 'Okafor' },   email: 'chinedu.okafor@gmail.com',  phone: '08031234501', address: { city: 'Ikeja',         state: 'Lagos' } },
  { _id: 2,  name: { first: 'Aisha',    last: 'Bello' },    email: 'aisha.bello@yahoo.com',     phone: '08061234502', address: { city: 'Kano',          state: 'Kano' } },
  { _id: 3,  name: { first: 'Tunde',    last: 'Adeyemi' },  email: 'tunde.adeyemi@gmail.com',   phone: '08021234503', address: { city: 'Ibadan',        state: 'Oyo' } },
  { _id: 4,  name: { first: 'Ngozi',    last: 'Eze' },      email: 'ngozi.eze@outlook.com',     phone: '08091234504', address: { city: 'Enugu',         state: 'Enugu' } },
  { _id: 5,  name: { first: 'Ibrahim',  last: 'Musa' },     email: 'ibrahim.musa@gmail.com',    phone: '07031234505', address: { city: 'Abuja',         state: 'FCT' } },
  { _id: 6,  name: { first: 'Funke',    last: 'Adebayo' },  email: 'funke.adebayo@gmail.com',   phone: '08121234506', address: { city: 'Lekki',         state: 'Lagos' } },
  { _id: 7,  name: { first: 'Emeka',    last: 'Nwosu' },    email: 'emeka.nwosu@yahoo.com',     phone: '08051234507', address: { city: 'Port Harcourt', state: 'Rivers' } },
  { _id: 8,  name: { first: 'Halima',   last: 'Abubakar' }, email: 'halima.abubakar@gmail.com', phone: '09031234508', address: { city: 'Kaduna',        state: 'Kaduna' } },
  { _id: 9,  name: { first: 'Segun',    last: 'Ogunleye' }, email: 'segun.ogunleye@gmail.com',  phone: '08161234509', address: { city: 'Abeokuta',      state: 'Ogun' } },
  { _id: 10, name: { first: 'Blessing', last: 'Udo' },      email: 'blessing.udo@outlook.com',  phone: '08141234510', address: { city: 'Uyo',           state: 'Akwa Ibom' } },
  { _id: 11, name: { first: 'Yusuf',    last: 'Danjuma' },  email: 'yusuf.danjuma@gmail.com',   phone: '07061234511', address: { city: 'Jos',           state: 'Plateau' } },
  { _id: 12, name: { first: 'Kemi',     last: 'Oladipo' },  email: 'kemi.oladipo@yahoo.com',    phone: '08171234512', address: { city: 'Benin City',    state: 'Edo' } }
]);

// STEP 2: PARTS (the 15 from Portfolio 1). Notice that each kind of part has
// DIFFERENT attributes, and the car models it fits are a list INSIDE the part.
var LADIPO = { sellerId: 4, name: 'Ladipo AutoParts Ventures', city: 'Mushin' };
var KANO   = { sellerId: 5, name: 'Kano Auto Spares',          city: 'Kano' };
var NNEWI  = { sellerId: 6, name: 'Nnewi Genuine Parts Ltd',   city: 'Nnewi' };
function m(make, model, year) { return { make: make, model: model, year: year }; }
var COROLLA = m('Toyota', 'Corolla', 2015), CAMRY = m('Toyota', 'Camry', 2018), HIGHLANDER = m('Toyota', 'Highlander', 2014),
    ACCORD = m('Honda', 'Accord', 2017), CIVIC = m('Honda', 'Civic', 2016), RX350 = m('Lexus', 'RX 350', 2016),
    ES350 = m('Lexus', 'ES 350', 2019), ELANTRA = m('Hyundai', 'Elantra', 2020), RIO = m('Kia', 'Rio', 2019),
    C300 = m('Mercedes-Benz', 'C300', 2017);
db.parts.insertMany([
  { _id: 1,  partNumber: 'DUN-205-55R16', name: 'Tyre 205/55 R16', brand: 'Dunlop', category: 'Tyres', price: 65000, stock: 40, seller: LADIPO,
    attributes: { widthMm: 205, aspectRatio: 55, rimInches: 16, loadIndex: 91, speedRating: 'V' }, fitsModels: [COROLLA, CIVIC, ELANTRA] },
  { _id: 2,  partNumber: 'VAR-75AH', name: 'Car Battery 75Ah', brand: 'Varta', category: 'Batteries', price: 95000, stock: 25, seller: LADIPO,
    attributes: { capacityAh: 75, voltage: 12, coldCrankingAmps: 680, warrantyMonths: 24 }, fitsModels: [COROLLA, CAMRY, ACCORD, CIVIC, ELANTRA, RIO],
    rating: { count: 1, average: 5 },
    recentReviews: [ { customerId: 2, name: 'Aisha B.', rating: 5, comment: 'Battery delivered the next day in Kano. Car starts first time.' } ] },
  { _id: 3,  partNumber: 'TOY-04465-02220', name: 'Front Brake Pads', brand: 'Toyota', category: 'Brakes', price: 38000, stock: 30, seller: LADIPO,
    attributes: { position: 'Front', material: 'Ceramic', genuine: true }, fitsModels: [COROLLA],
    rating: { count: 1, average: 5 },
    recentReviews: [ { customerId: 1, name: 'Chinedu O.', rating: 5, comment: 'Original Toyota pads, fit my Corolla perfectly.' } ] },
  { _id: 4,  partNumber: 'TOY-90915-YZZD2', name: 'Oil Filter', brand: 'Toyota', category: 'Filters', price: 6500, stock: 120, seller: LADIPO,
    attributes: { filterType: 'Oil', thread: 'M20 x 1.5', genuine: true }, fitsModels: [COROLLA, CAMRY, HIGHLANDER, RX350, ES350],
    rating: { count: 1, average: 4 },
    recentReviews: [ { customerId: 1, name: 'Chinedu O.', rating: 4, comment: 'Good filter, fair price.' } ] },
  { _id: 5,  partNumber: 'HON-15400-PLM-A02', name: 'Oil Filter', brand: 'Honda', category: 'Filters', price: 7000, stock: 80, seller: KANO,
    attributes: { filterType: 'Oil', genuine: true }, fitsModels: [ACCORD, CIVIC],
    rating: { count: 1, average: 4 }, recentReviews: [ { customerId: 5, name: 'Ibrahim M.', rating: 4 } ] },
  { _id: 6,  partNumber: 'NGK-ILKAR7B11', name: 'Spark Plugs (set of 4)', brand: 'NGK', category: 'Engine Parts', price: 28000, stock: 50, seller: KANO,
    attributes: { piecesInSet: 4, electrode: 'Iridium', gapMm: 1.1 }, fitsModels: [CAMRY, ACCORD, CIVIC, ES350],
    rating: { count: 1, average: 5 },
    recentReviews: [ { customerId: 5, name: 'Ibrahim M.', rating: 5, comment: 'Genuine NGK plugs. Engine runs smoother.' } ] },
  { _id: 7,  partNumber: 'HON-45022-T2A', name: 'Front Brake Pads', brand: 'Honda', category: 'Brakes', price: 42000, stock: 20, seller: KANO,
    attributes: { position: 'Front', material: 'Semi-metallic', genuine: true }, fitsModels: [ACCORD] },
  { _id: 8,  partNumber: 'MIC-235-60R18', name: 'Tyre 235/60 R18', brand: 'Michelin', category: 'Tyres', price: 120000, stock: 16, seller: KANO,
    attributes: { widthMm: 235, aspectRatio: 60, rimInches: 18, loadIndex: 103, speedRating: 'H' }, fitsModels: [HIGHLANDER, RX350] },
  { _id: 9,  partNumber: 'KYB-339040', name: 'Front Shock Absorber', brand: 'KYB', category: 'Suspension', price: 85000, stock: 12, seller: NNEWI,
    attributes: { position: 'Front', type: 'Gas' }, fitsModels: [CAMRY] },
  { _id: 10, partNumber: 'DEP-212-11C4', name: 'Headlamp Assembly', brand: 'Depo', category: 'Lighting', price: 150000, stock: 6, seller: NNEWI,
    attributes: { side: 'Left', bulbType: 'H4' }, fitsModels: [COROLLA] },
  { _id: 11, partNumber: 'AIS-WPT-190', name: 'Water Pump', brand: 'Aisin', category: 'Engine Parts', price: 55000, stock: 10, seller: NNEWI,
    attributes: { includesGasket: true }, fitsModels: [HIGHLANDER, RX350] },
  { _id: 12, partNumber: 'EXI-100AH', name: 'Car Battery 100Ah', brand: 'Exide', category: 'Batteries', price: 135000, stock: 15, seller: NNEWI,
    attributes: { capacityAh: 100, voltage: 12, coldCrankingAmps: 850, warrantyMonths: 18 }, fitsModels: [HIGHLANDER, RX350, C300] },
  { _id: 13, partNumber: 'MAN-HU7008Z', name: 'Oil Filter', brand: 'Mann', category: 'Filters', price: 12000, stock: 40, seller: NNEWI,
    attributes: { filterType: 'Oil', cartridge: true }, fitsModels: [C300] },
  { _id: 14, partNumber: 'MOO-K750', name: 'Stabiliser Link', brand: 'Moog', category: 'Suspension', price: 18000, stock: 0, seller: LADIPO,
    attributes: { position: 'Front' }, fitsModels: [ELANTRA, RIO] },
  { _id: 15, partNumber: 'PHI-H4-12V', name: 'Headlight Bulbs H4 (pair)', brand: 'Philips', category: 'Lighting', price: 9500, stock: 200, seller: KANO,
    attributes: { bulbType: 'H4', watts: 60, piecesInSet: 2 }, fitsModels: [COROLLA, ELANTRA, RIO] }
]);

// STEP 3: CARS (the 8 from Portfolio 1). Each car has its own extra details,
// and its inspection bookings are stored INSIDE the car.
var LEKKI  = { sellerId: 1, name: 'Lekki Prime Autos', city: 'Lekki' };
var ABUJA  = { sellerId: 2, name: 'Abuja Motor Hub',   city: 'Abuja' };
var GARDEN = { sellerId: 3, name: 'Garden City Cars',  city: 'Port Harcourt' };
db.cars.insertMany([
  { _id: 1, vin: '4T1B11HK5JU512345', make: 'Toyota', model: 'Camry', year: 2018, condition: 'Foreign Used', mileageKm: 68000, colour: 'Black',
    transmission: 'Automatic', price: 18500000, status: 'Available', dealer: LEKKI,
    features: ['Reverse camera', 'Keyless entry'], engine: { litres: 2.5, cylinders: 4, fuel: 'Petrol' } },
  { _id: 2, vin: '2T2BZMCA6GC023456', make: 'Lexus', model: 'RX 350', year: 2016, condition: 'Foreign Used', mileageKm: 92000, colour: 'White',
    transmission: 'Automatic', price: 24000000, status: 'Reserved', dealer: LEKKI,
    features: ['Sunroof', 'Leather seats', 'Navigation'],
    inspections: [ { customerId: 6, scheduledFor: new Date('2026-09-28T10:00:00Z'), status: 'Completed' } ] },
  { _id: 3, vin: '2T1BURHE5FC334567', make: 'Toyota', model: 'Corolla', year: 2015, condition: 'Nigerian Used', mileageKm: 130000, colour: 'Silver',
    transmission: 'Automatic', price: 7800000, status: 'Sold', dealer: LEKKI,
    previousOwners: 2, customsPapers: true,
    inspections: [ { customerId: 1, scheduledFor: new Date('2026-09-01T11:00:00Z'), status: 'Completed' } ] },
  { _id: 4, vin: '1HGCV1F30HA045678', make: 'Honda', model: 'Accord', year: 2017, condition: 'Foreign Used', mileageKm: 75000, colour: 'Grey',
    transmission: 'Automatic', price: 14500000, status: 'Available', dealer: ABUJA,
    features: ['Lane assist'],
    inspections: [ { customerId: 5, scheduledFor: new Date('2026-10-08T10:00:00Z'), status: 'Booked' } ] },
  { _id: 5, vin: '55SWF4KB8HU156789', make: 'Mercedes-Benz', model: 'C300', year: 2017, condition: 'Foreign Used', mileageKm: 60000, colour: 'Blue',
    transmission: 'Automatic', price: 21000000, status: 'Available', dealer: ABUJA,
    features: ['Panoramic roof', 'Ambient lighting'], engine: { litres: 2.0, cylinders: 4, turbo: true, fuel: 'Petrol' },
    inspections: [ { customerId: 11, scheduledFor: new Date('2026-10-02T14:00:00Z'), status: 'Cancelled' } ] },
  { _id: 6, vin: '58ADZ1B10KU067890', make: 'Lexus', model: 'ES 350', year: 2019, condition: 'Foreign Used', mileageKm: 40000, colour: 'Red',
    transmission: 'Automatic', price: 32000000, status: 'Available', dealer: ABUJA, features: ['Mark Levinson audio'] },
  { _id: 7, vin: '5NPD84LF2LH178901', make: 'Hyundai', model: 'Elantra', year: 2020, condition: 'Brand New', mileageKm: 0, colour: 'White',
    transmission: 'Automatic', price: 26500000, status: 'Available', dealer: GARDEN, warrantyYears: 3,
    inspections: [ { customerId: 7, scheduledFor: new Date('2026-10-10T13:00:00Z'), status: 'Booked' } ] },
  { _id: 8, vin: '3KPA24AD0KE289012', make: 'Kia', model: 'Rio', year: 2019, condition: 'Nigerian Used', mileageKm: 85000, colour: 'Red',
    transmission: 'Manual', price: 6200000, status: 'Available', dealer: GARDEN, previousOwners: 1 }
]);

// STEP 4: ORDERS (the 8 from Portfolio 1). The items, payments and delivery
// are stored INSIDE the order, so one read gets the whole order.
function item(partId, name, category, quantity, unitPrice) {
  return { partId: partId, name: name, category: category, quantity: quantity, unitPrice: unitPrice };
}
db.orders.insertMany([
  { _id: 1, customerId: 1, customerName: 'Chinedu Okafor', orderDate: new Date('2026-09-02T10:15:00Z'), status: 'Delivered',
    items: [ item(3, 'Front Brake Pads', 'Brakes', 1, 38000), item(4, 'Oil Filter', 'Filters', 2, 6500) ],
    payments: [ { amount: 51000, method: 'Card', status: 'Successful' } ],
    delivery: { address: '14 Allen Avenue', city: 'Ikeja', state: 'Lagos', agent: 'Samuel Ajayi', status: 'Delivered' } },
  { _id: 2, customerId: 2, customerName: 'Aisha Bello', orderDate: new Date('2026-09-05T13:40:00Z'), status: 'Delivered',
    items: [ item(2, 'Car Battery 75Ah', 'Batteries', 1, 95000) ],
    payments: [ { amount: 95000, method: 'Bank Transfer', status: 'Successful' } ],
    delivery: { address: '22 Zoo Road', city: 'Kano', state: 'Kano', agent: 'Abdullahi Sani', status: 'Delivered' } },
  { _id: 3, customerId: 5, customerName: 'Ibrahim Musa', orderDate: new Date('2026-09-10T09:05:00Z'), status: 'Delivered',
    items: [ item(5, 'Oil Filter', 'Filters', 2, 7000), item(6, 'Spark Plugs (set of 4)', 'Engine Parts', 1, 28000) ],
    payments: [ { amount: 42000, method: 'Card', status: 'Failed' }, { amount: 42000, method: 'Bank Transfer', status: 'Successful' } ],
    delivery: { address: '7 Aminu Kano Crescent, Wuse 2', city: 'Abuja', state: 'FCT', agent: 'Musa Ibrahim', status: 'Delivered' } },
  { _id: 4, customerId: 7, customerName: 'Emeka Nwosu', orderDate: new Date('2026-09-18T16:20:00Z'), status: 'Shipped',
    items: [ item(8, 'Tyre 235/60 R18', 'Tyres', 4, 120000) ],
    payments: [ { amount: 480000, method: 'Card', status: 'Successful' } ],
    delivery: { address: '31 Aba Road', city: 'Port Harcourt', state: 'Rivers', agent: 'Godwin Amadi', status: 'In Transit' } },
  { _id: 5, customerId: 6, customerName: 'Funke Adebayo', orderDate: new Date('2026-09-25T11:00:00Z'), status: 'Paid',
    items: [ item(10, 'Headlamp Assembly', 'Lighting', 1, 150000), item(15, 'Headlight Bulbs H4 (pair)', 'Lighting', 1, 9500) ],
    payments: [ { amount: 159500, method: 'Card', status: 'Successful' } ],
    delivery: { address: '5 Admiralty Way', city: 'Lekki', state: 'Lagos', status: 'Awaiting Pickup' } },
  { _id: 6, customerId: 3, customerName: 'Tunde Adeyemi', orderDate: new Date('2026-10-01T08:30:00Z'), status: 'Pending',
    items: [ item(1, 'Tyre 205/55 R16', 'Tyres', 4, 65000) ], payments: [],
    delivery: { address: '18 Ring Road', city: 'Ibadan', state: 'Oyo' } },
  { _id: 7, customerId: 4, customerName: 'Ngozi Eze', orderDate: new Date('2026-10-03T15:10:00Z'), status: 'Cancelled',
    items: [ item(9, 'Front Shock Absorber', 'Suspension', 2, 85000) ],
    payments: [ { amount: 170000, method: 'Card', status: 'Refunded' } ],
    delivery: { address: '9 Ogui Road', city: 'Enugu', state: 'Enugu' } },
  { _id: 8, customerId: 12, customerName: 'Kemi Oladipo', orderDate: new Date('2026-10-05T12:45:00Z'), status: 'Paid',
    items: [ item(12, 'Car Battery 100Ah', 'Batteries', 1, 135000), item(13, 'Oil Filter', 'Filters', 1, 12000) ],
    payments: [ { amount: 147000, method: 'Bank Transfer', status: 'Successful' } ],
    delivery: { address: '40 Airport Road', city: 'Benin City', state: 'Edo', status: 'Awaiting Pickup' } }
]);

// STEP 5: GENERATED DATA - 1,985 more parts, 4,988 more customers, 30,000 more orders.
// rnd() is a simple seeded random number generator, so the data is the same every run.
var seed = 42;
function rnd() { seed = (seed * 1103515245 + 12345) % 2147483648; return seed / 2147483648; }
function pick(list) { return list[Math.floor(rnd() * list.length)]; }
var MODELS   = [COROLLA, CAMRY, HIGHLANDER, ACCORD, CIVIC, RX350, ES350, ELANTRA, RIO, C300];
var SHOPS    = [LADIPO, KANO, NNEWI];
var CATS     = ['Tyres', 'Batteries', 'Brakes', 'Engine Parts', 'Filters', 'Suspension', 'Lighting'];
var BRANDS   = ['Bosch', 'Denso', 'Michelin', 'Exide', 'Mann', 'KYB', 'Philips', 'Toyota', 'Honda', 'NGK'];
var FIRST    = ['Chinedu', 'Aisha', 'Tunde', 'Ngozi', 'Ibrahim', 'Funke', 'Emeka', 'Halima', 'Segun', 'Blessing', 'Yusuf', 'Kemi', 'Obinna', 'Zainab', 'Femi', 'Amaka'];
var LAST     = ['Okafor', 'Bello', 'Adeyemi', 'Eze', 'Musa', 'Adebayo', 'Nwosu', 'Abubakar', 'Ogunleye', 'Udo', 'Danjuma', 'Oladipo', 'Okeke', 'Sani', 'Balogun', 'Obi'];
var PLACES   = [['Ikeja', 'Lagos'], ['Lekki', 'Lagos'], ['Abuja', 'FCT'], ['Kano', 'Kano'], ['Port Harcourt', 'Rivers'], ['Ibadan', 'Oyo'],
                ['Enugu', 'Enugu'], ['Benin City', 'Edo'], ['Kaduna', 'Kaduna'], ['Abeokuta', 'Ogun'], ['Uyo', 'Akwa Ibom'], ['Jos', 'Plateau']];
var STATUSES = ['Delivered', 'Delivered', 'Delivered', 'Delivered', 'Delivered', 'Delivered', 'Delivered', 'Shipped', 'Paid', 'Pending', 'Cancelled'];
function attributesFor(cat) {
  if (cat === 'Tyres')     return { widthMm: pick([185, 195, 205, 215, 225, 235]), aspectRatio: pick([50, 55, 60, 65]), rimInches: pick([15, 16, 17, 18]) };
  if (cat === 'Batteries') return { capacityAh: pick([45, 60, 75, 100]), voltage: 12 };
  if (cat === 'Brakes')    return { position: pick(['Front', 'Rear']), material: pick(['Ceramic', 'Semi-metallic', 'Organic']) };
  if (cat === 'Filters')   return { filterType: pick(['Oil', 'Air', 'Fuel', 'Cabin']) };
  if (cat === 'Lighting')  return { bulbType: pick(['H4', 'H7', 'LED']) };
  return { position: pick(['Front', 'Rear']) };
}
var parts = [];
for (var p = 16; p <= 2000; p++) {
  var cat = pick(CATS), fits = [];
  for (var k = 0, n = 1 + Math.floor(rnd() * 3); k < n; k++) {
    var mm = pick(MODELS);
    if (fits.indexOf(mm) < 0) fits.push(mm);
  }
  parts.push({ _id: p, partNumber: 'NAM-' + ('000000' + p).slice(-6), name: cat + ' item ' + p, brand: pick(BRANDS), category: cat,
               price: Math.round((3000 + rnd() * 247000) / 500) * 500, stock: Math.floor(rnd() * 200), seller: pick(SHOPS),
               attributes: attributesFor(cat), fitsModels: fits });
}
db.parts.insertMany(parts);
var custs = [];
for (var c = 13; c <= 5000; c++) {
  var place = pick(PLACES), f = pick(FIRST), l = pick(LAST);
  custs.push({ _id: c, name: { first: f, last: l }, email: (f + '.' + l + c).toLowerCase() + '@example.ng',
               phone: '07' + ('000000000' + c).slice(-9), address: { city: place[0], state: place[1] } });
}
db.customers.insertMany(custs);
var start = new Date('2025-01-01T00:00:00Z').getTime(), span = 643 * 24 * 3600 * 1000;
for (var batch = 0; batch < 30; batch++) {
  var docs = [];
  for (var i = 1; i <= 1000; i++) {
    var id = 8 + batch * 1000 + i, cust = 1 + Math.floor(rnd() * 5000), place2 = pick(PLACES), items = [], used = {};
    for (var j = 0, ni = 1 + Math.floor(rnd() * 3); j < ni; j++) {
      var part = parts[Math.floor(rnd() * parts.length)];
      if (used[part._id]) continue;
      used[part._id] = true;
      items.push(item(part._id, part.name, part.category, 1 + Math.floor(rnd() * 3), part.price));
    }
    var total = items.reduce(function (s, it) { return s + it.quantity * it.unitPrice; }, 0), status = pick(STATUSES);
    docs.push({ _id: id, customerId: cust, orderDate: new Date(start + Math.floor(rnd() * span)), status: status, items: items,
                payments: status === 'Pending' ? [] : [ { amount: total, method: pick(['Card', 'Bank Transfer', 'Pay on Delivery']),
                                                          status: status === 'Cancelled' ? 'Refunded' : 'Successful' } ],
                delivery: { city: place2[0], state: place2[1] } });
  }
  db.orders.insertMany(docs);
}

// STEP 6: check the counts
printjson({ customers: db.customers.countDocuments(), parts: db.parts.countDocuments(),
            cars: db.cars.countDocuments(), orders: db.orders.countDocuments() });
