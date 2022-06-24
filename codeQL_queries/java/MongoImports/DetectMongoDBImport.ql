/**
 * @id DetectMongoDBImport
 * @kind problem
 * @description Gets all the mongo import in projects
 */

import codeql_queries.java.utils
import java

from MongoImport imports 
select imports, "Import from driver : $@",
 imports, imports.getDriverName() as driverName