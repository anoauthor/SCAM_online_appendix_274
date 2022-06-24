/**
 * @id GetQueryAndArguments
 * @kind path-problem
 * @description Gets all the sources of the arguments used by a method call on a MongoDb collection
 */
import java
import semmle.code.java.dataflow.DataFlow
import DataFlow::PathGraph
import utils


class DbCollectionFlowConfiguration extends DataFlow::Configuration {
    DbCollectionFlowConfiguration() { this = "GetDbCollectionConfiguration" }

  override predicate isSource(DataFlow::Node source) {
    source.asExpr() instanceof ClassInstanceExpr 
        or source.asExpr() instanceof Literal
        or source.asExpr() instanceof MongoCollectionCall
  }

  override predicate isSink(DataFlow::Node sink) {
    exists(OperationCallOnCollection call |
        sink.asExpr() = call.getAnArgument())
  }
}



from DataFlow::PathNode src,
    DataFlow::PathNode sink, DbCollectionFlowConfiguration config

where
    config.hasFlowPath(src, sink)
    and not testAndMigrationFile(sink.getNode().getLocation().getFile())
    
select sink.getNode(), src, sink, sink.getNode().getLocation().toString()
