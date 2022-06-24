/**
 * @id GetMongoMethodCall
 * @kind problem
 * @description Gets the operations called on mongoDB Collections
 */

import java
import semmle.code.java.dataflow.DataFlow
import codeql_queries.java.MongoOperations.mongoOperations
import semmle.code.java.dataflow.Nullness

from 
MongoMethodCall call
  where not testAndMigrationFile(call.getFile())
select call, "Operation $@ of type '$@' called on mongodb collection $@ with driver $@",
  call.getMethod(), call.getMethod().getName() as operationName,
  call.getMethod(), call.getOperationType() as operationType,
  call, call.getCollectionName() as collectionName,
  call.getMethod().getDeclaringType() as driverPackage, call.getDriverName() as driverName

