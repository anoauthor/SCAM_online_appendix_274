predicate mongoDbMethod(string methodName) {
    methodName in ["createCollection", "dropCollection", "dropDatabase", "aggregate", "collection", "collections", "command", "createIndex", "ensureIndex", "executeDbAdminCommand", "listCollections", "renameCollections", "withTransaction"]
}