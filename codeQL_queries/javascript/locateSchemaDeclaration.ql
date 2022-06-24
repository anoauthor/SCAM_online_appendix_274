/**
 * @name locate Mongoose Schema
 * @id locateSchemaDeclaration
 * @kind problem
 * @description outputs the schema structure
 */

import javascript

ASTNode getDescendant(ASTNode node) {
    result = node.getAChild() or
    result = getDescendant(node.getAChild())
}

class MongooseSchemaS2 extends InvokeExpr {
    MongooseSchemaS2() {
        this.getCalleeName() = "Schema" and
        not exists(Property prop | getDescendant(prop) = this)
}
}
predicate testFile(File f) {
    //Jasmine test files
    f.getAbsolutePath().matches("%.spec.%") or 
    f.getAbsolutePath().matches("%test%") or
    f.getAbsolutePath().matches("%.jsx")
}

from MongooseSchemaS2 schema
where 
    not testFile(schema.getFile())
select schema, schema.getLocation().getStartLine() + ":" + schema.getLocation().getStartColumn() + ", " + schema.getLocation().getEndLine() + ":" + schema.getLocation().getEndColumn()