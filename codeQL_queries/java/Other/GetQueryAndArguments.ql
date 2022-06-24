/**
 * @id GetQueryAndArguments
 * @kind problem
 * @description Gets all the sources of the arguments used by a method call on a MongoDb collection
 */
import java
import semmle.code.java.dataflow.DataFlow
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

from OperationCallOnCollection call, DataFlow::Node src,
    DataFlow::Node sink, DbCollectionFlowConfiguration config,
    Expr srcExpr, Expr sinkExpr

where not testAndMigrationFile(call.getFile())
    and config.hasFlow(src, sink)
    and
      if not exists(call.getAnArgument())
      then 
        // There may be a better ways than putting the call in the source and sink.
        (srcExpr = call and sinkExpr = call)
      else 
        (sink.asExpr() = call.getAnArgument()
        and srcExpr = src.asExpr()
        and sinkExpr = sink.asExpr())

    
select srcExpr, call, sinkExpr

