predicate mongoCollectionDelete(string methodName) {
    methodName in ["deleteMany", "remove", "deleteOne", "findAndRemove", "findOneAndRemove"]
}
predicate mongoCollectionSelect(string methodName) {
    methodName in ["estimatedDocumentCount", "aggregate", "count", "countDocuments", "distinct", "find", "findOne", "group", "indexes"]
}
predicate mongoCollectionUpdate(string methodName) {
    methodName in ["rename", "replaceOne", "save", "update", "updateMany", "updateOne"]
}
predicate mongoCollectionInsert(string methodName) {
    methodName in ["insert", "insertMany", "insertOne"]
}
predicate mongoCollectionDrop(string methodName) {
    methodName in ["drop", "dropIndex", "dropIndexes"]
}
predicate mongoCollectionWrite(string methodName) {
    methodName in ["bulkWrite"]
}
predicate mongoCollectionMethod(string methodName) {
    mongoCollectionDelete(methodName) or
    mongoCollectionSelect(methodName) or
    mongoCollectionUpdate(methodName) or
    mongoCollectionInsert(methodName) or
    mongoCollectionDrop(methodName) or
    mongoCollectionWrite(methodName)
}