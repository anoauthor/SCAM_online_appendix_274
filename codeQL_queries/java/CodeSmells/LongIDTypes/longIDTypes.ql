/**
 * @id LongTypeIndexes
 * @kind problem
 * @description Long indexes
 */

import java
import semmle.code.java.dataflow.DataFlow
import codeql_queries.java.MongoOperations.mongoOperations

abstract class UseOfUUIDAsDocumentID extends ExprParent { }

class UUIDInBsonCreation extends UseOfUUIDAsDocumentID, NewBsonInstance {
  UUIDInBsonCreation() {
    this.getArgument(0).(StringLiteral).getValue().matches("_id") and
    isAnUUID(this.getArgument(1))
  }
}

class UUIDInBsonAppend extends UseOfUUIDAsDocumentID, BsonAppendMethodAccess {
  UUIDInBsonAppend() {
    this.getArgument(0).(StringLiteral).getValue().matches("_id")
    and isAnUUID(getArgument(1))
  }
}

class IndexedOdmField extends InstanceField{ 
  IndexedOdmField() {
    (
      this.hasAnnotation("org.mongodb.morphia.annotations", "Id")
      or
      this.hasAnnotation("org.mongodb.morphia.annotations", "Indexed")
      or
      this.hasAnnotation("dev.morphia.annotations", "Id")
      or
      this.hasAnnotation("dev.morphia.annotations", "Indexed")
      or
      this.hasAnnotation("org.springframework.data.annotation", "Id")
      or
      this.hasAnnotation("org.springframework.data.mongodb.core.index", "Indexed")
      or
      this.hasAnnotation("org.mongojack", "ObjectId")
      or
      this.getAnAnnotation().getAValue().toString().matches("_id")
      or
      this.getName().matches("%id") and
      this.getDeclaringType() instanceof MongoOdmEntityClass
    )
  }
}

class UUIDIndexedField extends UseOfUUIDAsDocumentID, IndexedOdmField {
  UUIDIndexedField() {
      this.getType().(RefType).getAnAncestor().hasQualifiedName("java.util", "UUID")
  }
}

class UUIDStringAssignationToIndexedField extends UseOfUUIDAsDocumentID, Expr{
  UUIDStringAssignationToIndexedField(){
    exists(IndexedOdmField f| f.getType().hasName("String") and f.getAnAssignedValue() = this) and
    isAnUUID(this)
  }
}

predicate isAnUUID(Expr expr) {
  expr.getType().(RefType).getAnAncestor().hasQualifiedName("java.util", "UUID")
  or expr instanceof MethodAccess and expr.(MethodAccess).getMethod().hasName("toString") and isAnUUID(expr.(MethodAccess).getQualifier()) 
}

from UseOfUUIDAsDocumentID u
select u, "Using UUIDs as a document ID or in an indexed field could cause performance issues and large indexes. You should consider using a more simple id or an ObjectID"