import java
import semmle.code.java.dataflow.DataFlow
import codeql_queries.java.utils
import semmle.code.java.dataflow.TaintTracking
import codeql_queries.java.MongoOperations.mongoOperations

//======== Spring Data MongoDB ========
//MongoOperations
class SpringDataOperation extends MongoMethod {
  SpringDataOperation() {
    this.getDeclaringType()
        .hasQualifiedName("org.springframework.data.mongodb.core", "MongoOperations")
  }
}

class SpringDataOperationCallWithEntityType extends SpringDataOperationCall {
  RefType entityType;

  SpringDataOperationCallWithEntityType() {
    entityType = this.getAnArgument().(TypeLiteral).getTypeName().(TypeAccess).getType().(RefType) and
    entityType.hasAnnotation("org.springframework.data.mongodb.core.mapping", "Document")
  }

  override string getCollectionName() { result = getCollectionFromEntityType(entityType) }
}

class SpringDataOpCallWithEntityTypeAndDataFlow extends SpringDataOperationCallWithEntityType {
  DataFlow::Node source;
  DataFlow::Node sink;

  SpringDataOpCallWithEntityTypeAndDataFlow() {
    exists(SpringDataCollNameFlowConfig conf |
      conf.hasFlow(source, sink) and
      entityType.getAnAnnotation().getValue("collection").toString() = sink.asExpr().toString()
    )
  }

  override string getCollectionName() { result = source.asExpr().(StringLiteral).getValue() }
}

class SpringDataOperationCall extends MongoMethodCall {
  SpringDataOperationCall() {
    exists(SpringDataOperation op |
      this.getMethod().getSourceDeclaration().overridesOrInstantiates*(op)
    )
  }

  override string getDriverName() { result = "Spring-Data Mongodb" }

  override string getCollectionName() {
    //Collection name given as n-2 argument
    if
      this.getMethod().hasName("executeQuery") and
      this.getArgument(this.getNumArgument() - 2) instanceof StringLiteral
    then result = this.getArgument(this.getNumArgument() - 2).(StringLiteral).getRepresentedString()
    else
      //Collection name given as n-1 argument
      if this.getArgument(this.getNumArgument() - 1) instanceof StringLiteral
      then
        result = this.getArgument(this.getNumArgument() - 1).(StringLiteral).getRepresentedString()
      else result = "Unknown"
  }
}

string getCollectionFromEntityType(RefType entityType) {
  exists(Annotation documentAnnotation |
    documentAnnotation = entityType.getAnAnnotation() and
    documentAnnotation
        .getType()
        .hasQualifiedName("org.springframework.data.mongodb.core.mapping", "Document")
  |
    //Annotation has "collection" element
    if not documentAnnotation.getValue("collection").(StringLiteral).getValue().matches("")
    then result = findStringFromLiteralOrVariable(documentAnnotation.getValue("collection"))
    else
      if not documentAnnotation.getValue("value").(StringLiteral).getValue().matches("")
      then result = findStringFromLiteralOrVariable(documentAnnotation.getValue("value"))
      else
        //@Document annotation doesn't have collection or value element -> The name of the entity class is used as colelction name
        result = entityType.getName()
  )
}

class SpringDataOpCallWithDataFlow extends SpringDataOperationCall {
  DataFlow::Node sink;
  DataFlow::Node source;

  SpringDataOpCallWithDataFlow() {
    exists(SpringDataCollNameFlowConfig c |
      (
        sink.asExpr() = this.getArgument(this.getNumArgument() - 1)
        or
        sink.asExpr() = this.getArgument(this.getNumArgument() - 2)
      ) and
      c.hasFlow(source, sink)
    )
  }

  override string getCollectionName() { result = source.asExpr().(StringLiteral).getValue() }
}

class SpringDataCollNameFlowConfig extends DataFlow::Configuration {
  SpringDataCollNameFlowConfig() { this = "SpringDataCollNameFlowConfig" }

  override predicate isSource(DataFlow::Node source) { source.asExpr() instanceof StringLiteral }

  override predicate isSink(DataFlow::Node sink) {
    exists(Annotation a |
      a.getType().hasQualifiedName("org.springframework.data.mongodb.core.mapping", "Document") and
      (
        a.getValue("collection") = sink.asExpr() 
        or
        a.getValue("value") = sink.asExpr()
      )
    )
    or
    exists(SpringDataOperationCall call |
      call.getArgument(call.getNumArgument() - 1) = sink.asExpr()
      or
      call.getArgument(call.getNumArgument() - 2) = sink.asExpr()
    )
  }
}

//MongoRepository
class SpringDataRepositoryOperation extends MongoMethod {
  SpringDataRepositoryOperation() {
    this.getDeclaringType()
        .getASourceSupertype()
        .hasQualifiedName("org.springframework.data.mongodb.repository", "MongoRepository")
  }
}

class SpringDataRepositoryOperationCall extends MongoMethodCall {
  ParameterizedType repoType;

  SpringDataRepositoryOperationCall() {
    exists(SpringDataRepositoryOperation op |
      this.getMethod().getSourceDeclaration().overridesOrInstantiates*(op) and
      this.getQualifier().getType().(RefType).hasSupertype(repoType)
    )
  }

  override string getDriverName() { result = "Spring-Data Mongodb (Repository)" }

  override string getCollectionName() {
    result = getCollectionFromEntityType(repoType.getTypeArgument(0))
  }
}

class SpringDataRepositoryOperationCallWithDataFlow extends SpringDataRepositoryOperationCall {
  DataFlow::Node source;
  DataFlow::Node sink;

  SpringDataRepositoryOperationCallWithDataFlow() {
    exists(SpringDataCollNameFlowConfig flow |
      repoType
          .getTypeArgument(0)
          .hasAnnotation("org.springframework.data.mongodb.core.mapping", "Document") and
      flow.hasFlow(source, sink) and
      (
        repoType.getTypeArgument(0).getAnAnnotation().getValue("collection") = sink.asExpr()
        or
        repoType.getTypeArgument(0).getAnAnnotation().getValue("value") = sink.asExpr()
      )
    )
  }

  override string getCollectionName() { result = source.asExpr().(StringLiteral).getValue() }

  override string getDriverName() { result = "Spring-Data Mongodb (Repository)" }
}
