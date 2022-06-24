/**
 * This file define classes that represents mongoDB access methods for several drivers
 */

import java
import semmle.code.java.dataflow.DataFlow
import codeql_queries.java.utils
import semmle.code.java.dataflow.TaintTracking
import codeql_queries.java.MongoOperations.MongoDBDriverOperations
import codeql_queries.java.MongoOperations.MongoJackOperations
import codeql_queries.java.MongoOperations.SpringDataOperations

//======== Parent classes ========
class MongoMethod extends Method {
  MongoMethod() {
    (
      this.getDeclaringType().hasQualifiedName("com.mongodb", "DBCollection")
      or
      this.getDeclaringType().hasQualifiedName("com.mongodb.client", "MongoCollection")
      or
      (
        this.getDeclaringType().hasQualifiedName("org.mongojack", "JacksonDBCollection") or
        this.getDeclaringType().hasQualifiedName("org.mongojack", "JacksonMongoCollection")
      )
      or
      this.getDeclaringType()
          .hasQualifiedName("org.springframework.data.mongodb.core", "MongoOperations")
      or
      this.getDeclaringType()
          .getASourceSupertype()
          .hasQualifiedName("org.springframework.data.mongodb.repository", "MongoRepository")
      or
      this.getDeclaringType().hasQualifiedName("com.mongodb.client", "MongoDatabase")
      or
      this.getDeclaringType().hasQualifiedName("com.mongodb", "DB")
    )
  }
}

class MongoMethodCall extends MethodAccess {
  MongoMethodCall() {
    exists(MongoMethod m |
      this.getMethod().getSourceDeclaration().overridesOrInstantiates*(m) and not m.isPrivate()
    )
  }

  string getCollectionName() { result = "Unknown" }

  string getDriverName() { result = "Unknown" }

  Package getDriverPackage() { result = this.getMethod().getDeclaringType().getPackage() }

  string getOperationType() { result = determineOperationTypeFromMethod(this.getMethod()) }
}

class MongoOdmEntityClass extends Class {
  MongoOdmEntityClass() {
    this.hasAnnotation("org.springframework.data.mongodb.core.mapping", "Document")
    or
    this.hasAnnotation("org.mongojack", "MongoCollection")
    or
    this.hasAnnotation("dev.morphia.annotations", "Entity")
    or
    this.hasAnnotation("com.mongodb.morphia.annotations", "Entity")
    or
    exists(MongoMethodCall call |
      (
        call.getAnArgument().getType() = this.(Type) and call.getOperationType() = "Create"
        or
        call.getAnArgument().(TypeLiteral).getTypeName().(TypeAccess).getType().(RefType) =
          this.(RefType)
      )
    )
  }
}
