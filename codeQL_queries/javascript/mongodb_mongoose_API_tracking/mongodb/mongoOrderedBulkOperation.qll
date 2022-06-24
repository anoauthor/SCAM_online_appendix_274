predicate mongoOrderedBulkOperation(string methodName) {
    methodName in ["insert", "find", "raw"]
}