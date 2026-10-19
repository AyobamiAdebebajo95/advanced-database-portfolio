// =====================================================================
// NaijaAutoMart - Portfolio 5: Distributed and Cloud Database Exercise
// Script 05: AVAILABILITY - backup and restore test
//
// Replication protects against a SERVER failing, but not against a MISTAKE:
// if someone deletes the parts catalogue, the delete is copied to all 3 nodes
// within milliseconds. Only a BACKUP brings it back.
//
// Backup method (free tier): MongoDB Compass Export and Import.
// HOW TO RUN: steps 1, 3 and 5 are pasted into the mongosh shell;
// steps 2 and 4 are done with the mouse in Compass.
// =====================================================================

// STEP 1 (shell): record what the parts collection looks like BEFORE the backup
db = db.getSiblingDB('naijaautomart');
printjson({ parts: db.parts.countDocuments(),
            totalStockUnits: (db.parts.aggregate([{ $group: { _id: null, s: { $sum: '$stock' } } }]).toArray()[0] || { s: 0 }).s,
            battery: db.parts.findOne({ _id: 2 }, { name: 1, price: 1, stock: 1 }) });

// STEP 2 (Compass, mouse): BACKUP
//   naijaautomart > parts > Export Data (or "Export Collection") > Export the full collection
//   > JSON > Export. Save it as  naijaautomart.parts.json  on your PC.

// STEP 3 (shell): DISASTER - an admin deletes the whole parts catalogue by mistake
printjson(db.parts.deleteMany({}));
printjson({ partsLeft: db.parts.countDocuments() });     // 0

// STEP 4 (Compass, mouse): RESTORE
//   naijaautomart > parts > Add Data > Import JSON or CSV file > choose naijaautomart.parts.json > Import.
//   Note the time the import took: that is the RTO (Recovery Time Objective) for this collection.

// STEP 5 (shell): check the restore - every number should match step 1
printjson({ parts: db.parts.countDocuments(),
            totalStockUnits: (db.parts.aggregate([{ $group: { _id: null, s: { $sum: '$stock' } } }]).toArray()[0] || { s: 0 }).s,
            battery: db.parts.findOne({ _id: 2 }, { name: 1, price: 1, stock: 1 }),
            corollaPartsStillFound: db.parts.countDocuments({ fitsModels: { $elemMatch: { make: 'Toyota', model: 'Corolla', year: 2015 } } }) });
