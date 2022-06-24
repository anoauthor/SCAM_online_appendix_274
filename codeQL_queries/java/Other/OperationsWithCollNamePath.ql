/**
 * @id GetMongoDBCollectionCalls
 * @kind path-problem
 * @description Gets the operations called on mongoDB Collections 
 * and the name of the collection used
 */


 //Project used: graylog2-server
 //Example of found db access: 	findOne(...) at RoleServiceImpl:143[31-104]
 //Example of not detected db acces: findOneById(...) at RoleServiceImpl:134[27-72]

 import java
 import semmle.code.java.dataflow.DataFlow
 import DataFlow::PathGraph
 import utils
 
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
 
//   from DataFlow::Node src, DataFlow::Node sink,
//   DBCollectionFlowConfiguration dbCollectionFlowConfiguration,
//   OperationCallOnCollection call
//    where
   
//    dbCollectionFlowConfiguration.hasFlow(src , sink)
//    and sink.asExpr() = call.getQualifier()
//    and not testAndMigrationFile(call.getFile())
 
 
//  select call, src.asExpr(), call.getLocation()

// from
//   MethodAccess call
//    where call.getLocation().getFile().getBaseName().matches("RoleServiceImpl%")
//   select call, call.getLocation().toString()

// from OperationCallOnCollection call
//    where call.getLocation().getFile().getBaseName().matches("RoleServiceImpl%")
// select call, call.getLocation().toString()

from DataFlow::PathNode src, DataFlow::PathNode sink,
  DBCollectionFlowConfiguration dbCollectionFlowConfiguration
  where
    dbCollectionFlowConfiguration.hasFlowPath(src , sink)
    and sink.getNode().getLocation().getFile().getBaseName().matches("RoleServiceImpl%")
select sink.getNode(), src, sink, sink.getNode().getLocation().toString()