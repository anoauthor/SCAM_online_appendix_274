import java
import semmle.code.java.dataflow.DataFlow
import codeql_queries.java.utils
import semmle.code.java.dataflow.TaintTracking
import codeql_queries.java.MongoOperations.mongoOperations

//======== MongoJack ========
class MongoJackOperationOnCollection extends MongoMethod {
  MongoJackOperationOnCollection() {
    (
      this.getDeclaringType().hasQualifiedName("org.mongojack", "JacksonDBCollection") or
      this.getDeclaringType().hasQualifiedName("org.mongojack", "JacksonMongoCollection")
    ) and
    not this.hasName("wrap") and
    not this.hasName("build")
  }
}

class MongoJackOperationOnCollectionCall extends MongoMethodCall {
  MongoJackOperationOnCollectionCall() {
    exists(MongoJackOperationOnCollection op |
      this.getMethod().getSourceDeclaration().overridesOrInstantiates*(op) or
      this.getQualifier*().getType().(RefType).getASourceSupertype().getSourceDeclaration() =
        op.getDeclaringType()
    )
  }

  override string getCollectionName() {
    exists(JacksonCollectionBuildCall build |
      (
        this.getQualifier().(VarAccess).getVariable().getInitializer() = build or
        this.getQualifier() = build
      ) and
      if
        build.getAnArgument() instanceof TypeLiteral and
        build
            .getAnArgument()
            .(TypeLiteral)
            .getTypeName()
            .(TypeAccess)
            .getType()
            .(RefType)
            .getAnAnnotation() instanceof MongoJackCollectionAnnotation
      then
        result =
          getJacksonCollectionFromEntityType(build
                .getAnArgument()
                .(TypeLiteral)
                .getTypeName()
                .(TypeAccess)
                .getType()
                .(RefType)).(StringLiteral).getValue()
      else
        if
          build
              .getArgument(0)
              .getType()
              .(RefType)
              .hasQualifiedName("com.mongodb.client", "MongoDatabase") and
          not build.getArgument(1) instanceof TypeLiteral
        then result = build.getArgument(1).(StringLiteral).getValue()
        else
          if build.getArgument(2) instanceof StringLiteral
          then result = build.getArgument(2).(StringLiteral).getValue()
          else result = "Unknown"
    )
  }

  override string getDriverName() { result = "MongoJack" }
}

class MongoJackOpCallWithDataFlow extends MongoJackOperationOnCollectionCall {
  DataFlow::Node sink;
  DataFlow::Node source;

  MongoJackOpCallWithDataFlow() {
    exists(MongoJackCollNameFlowConfig c |
      c.hasFlow(source, sink) and sink.asExpr() = this.getQualifier()
    )
  }

  override string getCollectionName() { result = source.asExpr().(StringLiteral).getValue() }
}

class MongoJackCollNameFlowConfig extends DataFlow::Configuration {
  MongoJackCollNameFlowConfig() { this = "MongoJackCollNameFlowConfig" }

  override predicate isSource(DataFlow::Node source) { source.asExpr() instanceof StringLiteral }

  override predicate isAdditionalFlowStep(DataFlow::Node node1, DataFlow::Node node2) {
    exists(JacksonCollectionWrapCall wrap |
      node2.asExpr() = wrap and
      wrap.getArgument(0).(MethodAccess).getArgument(0) = node1.asExpr()
    )
    or
    exists(JacksonCollectionBuildCall build |
      node2.asExpr() = build and
      if
        build.getAnArgument() instanceof TypeLiteral and
        build
            .getAnArgument()
            .(TypeLiteral)
            .getTypeName()
            .(TypeAccess)
            .getType()
            .(RefType)
            .getAnAnnotation() instanceof MongoJackCollectionAnnotation
      then
        node1.asExpr() =
          getJacksonCollectionFromEntityType(build
                .getAnArgument()
                .(TypeLiteral)
                .getTypeName()
                .(TypeAccess)
                .getType()
                .(RefType))
      else
        if
          build
              .getArgument(0)
              .getType()
              .(RefType)
              .getSourceDeclaration()
              .hasQualifiedName("com.mongodb.client", "MongoDatabase") and
          not build.getArgument(1) instanceof TypeLiteral
        then node1.asExpr() = build.getArgument(1)
        else
          if
            build
                .getArgument(0)
                .getType()
                .(RefType)
                .getSourceDeclaration()
                .hasQualifiedName("com.mongodb.client", "MongoCollection")
          then node1.asExpr() = build.getArgument(0)
          else node1.asExpr() = build.getArgument(2)
    )
    or
    exists(GetCollectionCall call |
      node2.asExpr() = call and
      call.getArgument(0) = node1.asExpr()
    )
  }

  override predicate isSink(DataFlow::Node sink) {
    exists(MongoJackOperationOnCollectionCall call | sink.asExpr() = call.getQualifier())
  }
}

StringLiteral getJacksonCollectionFromEntityType(RefType entityType) {
  //Collection name is given as string literal in annotation
  if entityType.getAnAnnotation().getValue("name") instanceof StringLiteral
  then result = entityType.getAnAnnotation().getValue("name")
  else
    //Collection element is not a string literal and then hasn't been resolved by dataflow
    //Maybe make a recursive function if needed
    result =
      entityType.getAnAnnotation().getValue("name").(VarAccess).getVariable().getInitializer()
}
