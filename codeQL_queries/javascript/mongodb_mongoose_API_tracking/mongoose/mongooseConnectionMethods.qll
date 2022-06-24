predicate mongooseConnectionGeneric(string methodName) {
    methodName in ["collection", "createCollection", "deleteModel", "dropCollection", "dropDatabase", "model"]
}