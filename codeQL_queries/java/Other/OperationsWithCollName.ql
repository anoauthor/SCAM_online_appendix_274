/**
 * @id GetMongoDBCollectionCalls
 * @kind problem
 * @description Gets the operations called on mongoDB Collections 
 * and the name of the collection used
 */

 import java
 import semmle.code.java.dataflow.DataFlow
 import utils
 import semmle.code.java.dataflow.Nullness
 
 class DBCollectionFlowConfiguration extends DataFlow::Configuration {
   DBCollectionFlowConfiguration() {
     this = "db collection obtention to usage"
   }
 
   override predicate isSource(DataFlow::Node source) {
     source.asExpr() instanceof StringLiteral
   }
 
   override predicate isAdditionalFlowStep(DataFlow::Node node1, DataFlow::Node node2){
     exists(GetCollectionCall call |
       node2.asExpr() = call 
       and
       call.getArgument(0) = node1.asExpr()
     )
     or
     exists(JacksonCollectionWrapCall wrap | 
       node2.asExpr() = wrap
       and
       wrap.getArgument(0).(MethodAccess).getArgument(0) = node1.asExpr()
     )
   }
 
   override predicate isSink(DataFlow::Node sink){
    exists(OperationCallOnCollection call |
      sink.asExpr() = call.getQualifier())
  }

 
 }

from DataFlow::Node src, DataFlow::Node sink,
  DBCollectionFlowConfiguration dbCollectionFlowConfiguration,
  OperationCallOnCollection call, string collectionName
where 
  not call.getFile().getAbsolutePath().matches("%/test/%")
  and not call.getFile().getAbsolutePath().matches("%/migrations/%")
  and dbCollectionFlowConfiguration.hasFlow(src , sink)
  and if call.getQualifier() = sink.asExpr()
    then collectionName = src.toString()
    else collectionName = "Not resolved"
  
select call , "operation " + call.getMethod().getName() + " called on collection: " + collectionName