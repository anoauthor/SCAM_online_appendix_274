import javascript
predicate createCollectionGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "createCollection") implies (mce.getNumArgument() >= 1 and mce.getNumArgument() <= 26)}

predicate dropCollectionGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "dropCollection") implies (mce.getNumArgument() >= 1 and mce.getNumArgument() <= 8)}

predicate dropDatabaseGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "dropDatabase") implies (mce.getNumArgument() >= 0 and mce.getNumArgument() <= 3)}

predicate aggregateGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "aggregate") implies (mce.getNumArgument() >= 1 and mce.getNumArgument() <= 20)}

predicate collectionGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "collection") implies (mce.getNumArgument() >= 0 and mce.getNumArgument() <= 14)}

predicate collectionsGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "collections") implies (mce.getNumArgument() >= 0 and mce.getNumArgument() <= 3)}

predicate commandGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "command") implies (mce.getNumArgument() >= 1 and mce.getNumArgument() <= 5)}

predicate createIndexGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "createIndex") implies (mce.getNumArgument() >= 2 and mce.getNumArgument() <= 20)}

predicate ensureIndexGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "ensureIndex") implies (mce.getNumArgument() >= 2 and mce.getNumArgument() <= 18)}

predicate executeDbAdminCommandGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "executeDbAdminCommand") implies (mce.getNumArgument() >= 1 and mce.getNumArgument() <= 5)}

predicate listCollectionsGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "listCollections") implies (mce.getNumArgument() >= 1 and mce.getNumArgument() <= 7)}

predicate renameCollectionGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "renameCollection") implies (mce.getNumArgument() >= 2 and mce.getNumArgument() <= 6)}

predicate validateCollectionGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "validateCollection") implies (mce.getNumArgument() >= 1 and mce.getNumArgument() <= 5)}

predicate deleteManyGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "deleteMany") implies (mce.getNumArgument() >= 1 and mce.getNumArgument() <= 14)}

predicate deleteOneGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "deleteOne") implies (mce.getNumArgument() >= 0 and mce.getNumArgument() <= 14)}

predicate removeGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "remove") implies (mce.getNumArgument() >= 0 and mce.getNumArgument() <= 10)}

predicate findOneAndDeleteGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "findOneAndDelete") implies (mce.getNumArgument() >= 1 and mce.getNumArgument() <= 6)}

predicate findOneAndRemoveGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "findOneAndRemove") implies (mce.getNumArgument() >= 1 and mce.getNumArgument() <= 6)}

predicate populateGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "populate") implies (mce.getNumArgument() >= 1 and mce.getNumArgument() <= 11)}

predicate boxGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "box") implies (mce.getNumArgument() >= 2 and mce.getNumArgument() <= 3)}

predicate centerSphereGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "centerSphere") implies (mce.getNumArgument() >= 2 and mce.getNumArgument() <= 3)}

predicate countGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "count") implies (mce.getNumArgument() >= 1 and mce.getNumArgument() <= 10)}

predicate countDocumentsGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "countDocuments") implies (mce.getNumArgument() >= 1 and mce.getNumArgument() <= 8)}

predicate distinctGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "distinct") implies (mce.getNumArgument() >= 2 and mce.getNumArgument() <= 9)}

predicate findGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "find") implies (mce.getNumArgument() >= 1 and mce.getNumArgument() <= 33)}

predicate findOneGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "findOne") implies (mce.getNumArgument() >= 1 and mce.getNumArgument() <= 29)}

predicate getGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "get") implies (mce.getNumArgument() >= 1 and mce.getNumArgument() <= 6)}

predicate nearGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "near") implies (mce.getNumArgument() >= 2 and mce.getNumArgument() <= 3)}

predicate findOneAndReplaceGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "findOneAndReplace") implies (mce.getNumArgument() >= 2 and mce.getNumArgument() <= 14)}

predicate findOneAndUpdateGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "findOneAndUpdate") implies (mce.getNumArgument() >= 2 and mce.getNumArgument() <= 15)}

predicate replaceOneGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "replaceOne") implies (mce.getNumArgument() >= 1 and mce.getNumArgument() <= 16)}

predicate updateGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "update") implies (mce.getNumArgument() >= 1 and mce.getNumArgument() <= 18)}

predicate updateManyGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "updateMany") implies (mce.getNumArgument() >= 2 and mce.getNumArgument() <= 18)}

predicate updateOneGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "updateOne") implies (mce.getNumArgument() >= 1 and mce.getNumArgument() <= 18)}

predicate estimatedDocumentCountGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "estimatedDocumentCount") implies (mce.getNumArgument() >= 0 and mce.getNumArgument() <= 3)}

predicate createGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "create") implies (mce.getNumArgument() >= 1 and mce.getNumArgument() <= 26)}

predicate insertManyGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "insertMany") implies (mce.getNumArgument() >= 1 and mce.getNumArgument() <= 14)}

predicate saveGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "save") implies (mce.getNumArgument() >= 0 and mce.getNumArgument() <= 11)}

predicate bulkWriteGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "bulkWrite") implies (mce.getNumArgument() >= 1 and mce.getNumArgument() <= 14)}

predicate validateGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "validate") implies (mce.getNumArgument() >= 1 and mce.getNumArgument() <= 5)}

predicate addGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "add") implies (mce.getNumArgument() >= 1 and mce.getNumArgument() <= 3)}

predicate pickGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "pick") implies (mce.getNumArgument() >= 1 and mce.getNumArgument() <= 3)}

predicate execPopulateGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "execPopulate") implies (mce.getNumArgument() >= 0 and mce.getNumArgument() <= 1)}

predicate overwriteGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "overwrite") implies (mce.getNumArgument() >= 1 and mce.getNumArgument() <= 2)}

predicate setGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "set") implies (mce.getNumArgument() >= 3 and mce.getNumArgument() <= 5)}

predicate addFieldsGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "addFields") implies (mce.getNumArgument() >= 1 and mce.getNumArgument() <= 2)}

predicate appendGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "append") implies (mce.getNumArgument() >= 1 and mce.getNumArgument() <= 2)}

predicate findAndRemoveGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "findAndRemove") implies (mce.getNumArgument() >= 2 and mce.getNumArgument() <= 9)}

predicate groupGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "group") implies (mce.getNumArgument() >= 6 and mce.getNumArgument() <= 10)}

predicate indexesGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "indexes") implies (mce.getNumArgument() >= 0 and mce.getNumArgument() <= 3)}

predicate renameGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "rename") implies (mce.getNumArgument() >= 1 and mce.getNumArgument() <= 6)}

predicate insertGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "insert") implies (mce.getNumArgument() >= 1 and mce.getNumArgument() <= 14)}

predicate insertOneGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "insertOne") implies (mce.getNumArgument() >= 1 and mce.getNumArgument() <= 13)}

predicate dropGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "drop") implies (mce.getNumArgument() >= 0 and mce.getNumArgument() <= 9)}

predicate dropIndexGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "dropIndex") implies (mce.getNumArgument() >= 0 and mce.getNumArgument() <= 9)}

predicate dropIndexesGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "dropIndexes") implies (mce.getNumArgument() >= 0 and mce.getNumArgument() <= 4)}

predicate deleteModelGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "deleteModel") implies (mce.getNumArgument() >= 1 and mce.getNumArgument() <= 2)}

predicate modelGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "model") implies (mce.getNumArgument() >= 2 and mce.getNumArgument() <= 5)}

predicate immutableGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "immutable") implies (mce.getNumArgument() >= 1 and mce.getNumArgument() <= 2)}

predicate indexGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "index") implies (mce.getNumArgument() >= 0 and mce.getNumArgument() <= 3)}

predicate requiredGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "required") implies (mce.getNumArgument() >= 1 and mce.getNumArgument() <= 2)}

predicate sparseGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "sparse") implies (mce.getNumArgument() >= 1 and mce.getNumArgument() <= 2)}

predicate textGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "text") implies (mce.getNumArgument() >= 1 and mce.getNumArgument() <= 2)}

predicate uniqueGenAxioms(MethodCallExpr mce){ (mce.getMethodName() = "unique") implies (mce.getNumArgument() >= 1 and mce.getNumArgument() <= 2)}

predicate recap(MethodCallExpr mce) {
createCollectionGenAxioms(mce) and
dropCollectionGenAxioms(mce) and
dropDatabaseGenAxioms(mce) and
aggregateGenAxioms(mce) and
collectionGenAxioms(mce) and
collectionsGenAxioms(mce) and
commandGenAxioms(mce) and
createIndexGenAxioms(mce) and
ensureIndexGenAxioms(mce) and
executeDbAdminCommandGenAxioms(mce) and
listCollectionsGenAxioms(mce) and
renameCollectionGenAxioms(mce) and
validateCollectionGenAxioms(mce) and
deleteManyGenAxioms(mce) and
deleteOneGenAxioms(mce) and
removeGenAxioms(mce) and
findOneAndDeleteGenAxioms(mce) and
findOneAndRemoveGenAxioms(mce) and
populateGenAxioms(mce) and
boxGenAxioms(mce) and
centerSphereGenAxioms(mce) and
countGenAxioms(mce) and
countDocumentsGenAxioms(mce) and
distinctGenAxioms(mce) and
findGenAxioms(mce) and
findOneGenAxioms(mce) and
getGenAxioms(mce) and
nearGenAxioms(mce) and
findOneAndReplaceGenAxioms(mce) and
findOneAndUpdateGenAxioms(mce) and
replaceOneGenAxioms(mce) and
updateGenAxioms(mce) and
updateManyGenAxioms(mce) and
updateOneGenAxioms(mce) and
estimatedDocumentCountGenAxioms(mce) and
createGenAxioms(mce) and
insertManyGenAxioms(mce) and
saveGenAxioms(mce) and
bulkWriteGenAxioms(mce) and
validateGenAxioms(mce) and
addGenAxioms(mce) and
pickGenAxioms(mce) and
execPopulateGenAxioms(mce) and
overwriteGenAxioms(mce) and
setGenAxioms(mce) and
addFieldsGenAxioms(mce) and
appendGenAxioms(mce) and
findAndRemoveGenAxioms(mce) and
groupGenAxioms(mce) and
indexesGenAxioms(mce) and
renameGenAxioms(mce) and
insertGenAxioms(mce) and
insertOneGenAxioms(mce) and
dropGenAxioms(mce) and
dropIndexGenAxioms(mce) and
dropIndexesGenAxioms(mce) and
deleteModelGenAxioms(mce) and
modelGenAxioms(mce) and
immutableGenAxioms(mce) and
indexGenAxioms(mce) and
requiredGenAxioms(mce) and
sparseGenAxioms(mce) and
textGenAxioms(mce) and
uniqueGenAxioms(mce) }