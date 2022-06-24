predicate mongoFindOperatorsMethod(string methodName) {
    methodName in ["delete", "deleteOne", "remove", "removeOne", "replaceOne", "update", "updateOne", "upsert"]
}