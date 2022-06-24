import java
import semmle.code.java.dataflow.DataFlow
import codeql_queries.java.utils
import semmle.code.java.dataflow.TaintTracking
import codeql_queries.java.MongoOperations.mongoOperations

// ======== Official MongoDB Driver ========
//Operations on Database
class MongoDriverOperationOnDatabase extends MongoMethod {
  MongoDriverOperationOnDatabase() {
    (
      this.getDeclaringType().hasQualifiedName("com.mongodb.client", "MongoDatabase")
      or
      this.getDeclaringType().hasQualifiedName("com.mongodb", "DB")
    )
  }
}

class MongoDriverOperationOnDatabaseCall extends MongoMethodCall {
  MongoDriverOperationOnDatabaseCall() {
    exists(MongoDriverOperationOnDatabase op |
      this.getMethod().getSourceDeclaration().overridesOrInstantiates*(op)
    )
  }

  override string getDriverName() { result = "Mongodb Driver" }
}

//Operations on collections
class MongoDriverOperationOnCollection extends MongoMethod {
  MongoDriverOperationOnCollection() {
    (
      this.getDeclaringType().hasQualifiedName("com.mongodb", "DBCollection")
      or
      this.getDeclaringType().hasQualifiedName("com.mongodb.client", "MongoCollection")
    )
  }
}

class MongoDriverOperationOnCollectionCall extends MongoMethodCall {

  MongoDriverOperationOnCollectionCall() {
    exists(MongoDriverOperationOnCollection op |
      this.getMethod().getSourceDeclaration().overridesOrInstantiates*(op) and
      // There is maybe a better solution
      not this instanceof MongoJackOperationOnCollectionCall
    )
  }

  override string getDriverName() { result = "Mongodb Driver" }
  override string getCollectionName() {
    exists(GetCollectionCall c | TaintTracking::localTaint(DataFlow::exprNode(c), DataFlow::exprNode(this.getQualifier())) and result =findStringFromLiteralOrVariable(c.getArgument(0)) )
    or
    not exists(GetCollectionCall c | TaintTracking::localTaint(DataFlow::exprNode(c), DataFlow::exprNode(this.getQualifier()))) and result = "Unknown" 
    
  }

}

class MongoDriverOpCallWithDataFlow extends MongoDriverOperationOnCollectionCall {
  DataFlow::Node sink;
  DataFlow::Node source;

  MongoDriverOpCallWithDataFlow() {
    exists(MongoDriverCollNameFlowConfig c |
      c.hasFlow(source, sink) and sink.asExpr() = this.getQualifier()
    )
  }

  override string getCollectionName() { result = source.asExpr().(StringLiteral).getValue() }
}

class MongoDriverCollNameFlowConfig extends DataFlow::Configuration {
  MongoDriverCollNameFlowConfig() { this = "MongoDriverCollNameFlowConfig" }

  override predicate isSource(DataFlow::Node source) { source.asExpr() instanceof StringLiteral }

  override predicate isAdditionalFlowStep(DataFlow::Node node1, DataFlow::Node node2) {
    exists(GetCollectionCall call |
      node2.asExpr() = call and
      call.getArgument(0) = node1.asExpr()
    )
  }

  override predicate isSink(DataFlow::Node sink) {
    exists(MongoDriverOperationOnCollectionCall call | sink.asExpr() = call.getQualifier())
  }
}
