import javascript
predicate respectAxioms(MethodCallExpr mce) {
    findAxioms(mce) and
    allAxioms(mce) and
    createAxioms(mce) and
    deleteAxioms(mce) and
    getAxioms(mce) and
    loadashAxioms(mce) and
    jqueryAxioms(mce) and
    divAxioms(mce) and 
    importAxioms(mce)
}
predicate findAxioms(MethodCallExpr mce) {
    ( mce.getMethodName() = "find" and mce.getNumArgument() = 1 ) implies not (mce.getAnArgument() instanceof StringLiteral)
}
predicate allAxioms(MethodCallExpr mce) {
    mce.getMethodName() = "all" implies not(mce.getReceiver().toString().matches("Promise"))
}
predicate createAxioms(MethodCallExpr mce) {
    ( mce.getMethodName() = "create" and mce.getNumArgument() = 1 ) implies not ( mce.getAnArgument() instanceof ObjectExpr or mce.getReceiver().toString().matches("Object") )
}
predicate deleteAxioms(MethodCallExpr mce) {
    not ( mce.getMethodName() = "delete" and mce.getNumArgument() > 0)
}
predicate getAxioms(MethodCallExpr mce) {
    mce.getMethodName() = "get" implies mce.getNumArgument() = 1
}
predicate loadashAxioms(MethodCallExpr mce) {
    not mce.getReceiver().toString().matches("_")
}
predicate jqueryAxioms(MethodCallExpr mce) {
    not ( mce.getReceiver().toString().matches("$(%)") or mce.getReceiver().toString().matches("jQuery.%") )
}
predicate divAxioms(MethodCallExpr mce) {
    not mce.getReceiver().toString().matches("div")
}
predicate importAxioms(MethodCallExpr mce) {
    exists( Module mongoModule, Module mceModule | 
        mceModule.getFile() = mce.getFile() and 
        ( mongoModule.getAnImport().getImportedPath().getValue().matches("mongodb") or mongoModule.getAnImport().getImportedPath().getValue().matches("mongoose") ) and
        moduleImportChain(mceModule, mongoModule)

    )
    or
    exists( Import i | ( i.getImportedPath().getValue().matches("mongodb") or i.getImportedPath().getValue().matches("mongoose") ) and i.getFile() = mce.getFile() )
}
predicate moduleImportChain(Module m1, Module m2) {
    m1.getAnImportedModule() = m2 or 
    moduleImportChain(m1.getAnImportedModule(), m2)
}