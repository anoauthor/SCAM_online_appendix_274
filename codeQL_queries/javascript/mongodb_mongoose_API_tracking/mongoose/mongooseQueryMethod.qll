predicate mongooseQueryDelete(string methodName) {
    methodName in ["deleteMany", "deleteOne", "remove", "findOneAndDelete", "findOneAndRemove"]
}
predicate mongooseQueryInsert(string methodName) {
    methodName in ["populate"]
}
predicate mongooseQuerySelect(string methodName) {
    methodName in ["$where", "all", "and", "box", "centerSphere", "circle", "count", "countDocuments", "distinct", "elemMatch", "equals", "exists", "find", "findOne", "get", "near", "nor", "or", "orFall", "polygon", "where"]
}
predicate mongooseQueryUpdate(string methodName) {
    methodName in ["findOneAndReplace", "findOneAndUpdate", "replaceOne", "update", "updateMany", "updateOne"]
}
predicate mongooseQueryGeneric(string methodName) {
    methodName in ["estimatedDocumentCount"]
}
predicate mongooseQueryMethod(string methodName) {
    mongooseQueryDelete(methodName) or
    mongooseQueryInsert(methodName) or
    mongooseQuerySelect(methodName) or
    mongooseQueryUpdate(methodName) or
    mongooseQueryGeneric(methodName)
}