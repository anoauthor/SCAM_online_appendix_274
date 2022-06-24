import javascript

predicate blackList(MethodCallExpr mce) {
    mce.getMethodName() in ["get"]
}