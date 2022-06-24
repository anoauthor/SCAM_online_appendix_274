/**
 * @id TooManyAnnotedIndex
 * @kind problem
 * @description Gets all the operation that create an index on a collection
 */

import java
import codeql_queries.java.MongoOperations.mongoOperations
import codeql_queries.java.CodeSmells.TooManyIndexes.TooManyAnnotedIndex
import codeql_queries.java.CodeSmells.TooManyIndexes.TooManyCreateIndex

from SpringDataAnnotedClass ia, SpringDataIndexAnnotation annotations ,string collectionName, string attributeName
where 
    isTooMuchIndex(ia.getCollectionName()) and
    collectionName = ia.getCollectionName() and 
    annotations = ia.getAnnotations() and
    attributeName = getMostUsedAttribute(collectionName) 
select annotations, "This index annotation could cause performance issues because too many indexes (" + getTotalCreateIndex(collectionName) + 
    ") has been created for the collection '$@'. This collection has " + getNumberOfField(collectionName) + " fields and the most used field is '$@' (" + getTotalUseAttribute(collectionName, attributeName) + " times)." +
    "\nTry to get less that 15 indexes by collection !",
    annotations, collectionName,
    ia, attributeName
order by collectionName asc, annotations asc
