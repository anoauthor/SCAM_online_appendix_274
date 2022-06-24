predicate mongoUnorderedBulkOperationMethod(string methodName) {
    methodName in["insert", "find", "raw"]
}