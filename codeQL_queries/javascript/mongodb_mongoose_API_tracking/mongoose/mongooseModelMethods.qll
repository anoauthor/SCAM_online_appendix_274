predicate mongooseModelCreate(string methodName) {
    methodName in ["create", "createCollection", "hydrate"]
}
predicate mongooseModelDelete(string methodName) {
    methodName in ["deleteMany", "deleteOne", "remove","findByIdAndDelete", "findByIdAndRemove", "findOneAndDelete", "findOneAndRemove"]
}
predicate mongooseModelInsert(string methodName) {
    methodName in ["insertMany", "save", "populate"]
}
predicate mongooseModelGeneric(string methodName) {
    methodName in ["bulkWrite", "cleanIndexes", "discriminator", "ensureIndexes", "estimatedDocumentCount", "validate", "createIndexes"]
}
predicate mongooseModelUpdate(string methodName) {
    methodName in ["findByIdAndUpdate", "findOneAndReplace", "findOneAndUpdate", "replaceOne", "update", "updateMany", "updateOne"]
}
predicate mongooseModelSelect(string methodName) {
    methodName in ["aggregate", "count", "countDocuments", "distinct", "exists", "find", "findById", "findOne", "geoSearch", "mapReduce", "where"]
}

predicate mongooseModelMethod(string methodName) {
    mongooseModelCreate(methodName) or
    mongooseModelDelete(methodName) or
    mongooseModelGeneric(methodName) or 
    mongooseModelInsert(methodName) or
    mongooseModelSelect(methodName) or
    mongooseModelUpdate(methodName)
}