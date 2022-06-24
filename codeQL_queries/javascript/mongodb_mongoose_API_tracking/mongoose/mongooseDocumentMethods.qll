predicate mongooseDocumentInsert(string methodName) {
    methodName in ["execPopulate", "save", "populate"]
}
predicate mongooseDocumentSelect(string methodName) {
    methodName in ["$getAllSubdocs", "get"]
}
predicate mongooseDocumentUpdate(string methodName) {
    methodName in ["overwrite", "replaceOne", "update", "updateOne"]
}
predicate mongooseDocumentGeneric(string methodName) {
    methodName in ["$ignore", "set"]
}
predicate mongooseDocumentMethod(string methodName) {
    mongooseDocumentInsert(methodName) or
    mongooseDocumentSelect(methodName) or
    mongooseDocumentUpdate(methodName) or
    mongooseDocumentGeneric(methodName)
}