predicate mongooseAggregateSelect(string methodName) {
    methodName in ["count"]
}
predicate mongooseAggregateUpdate(string methodName) {
    methodName in ["addFields"]
}
predicate mongooseAggregateGeneric(string methodName) {
    methodName in ["append"]
}
predicate mongooseAggregateMethod(string methodName) {
    mongooseAggregateSelect(methodName) or
    mongooseAggregateUpdate(methodName) or
    mongooseAggregateGeneric(methodName)
}