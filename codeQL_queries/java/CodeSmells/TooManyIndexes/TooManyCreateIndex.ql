/**
 * @id TooManyCreateIndex
 * @kind problem
 * @description Gets all the operation that create an index on a collection
 */

import codeql_queries.java.CodeSmells.TooManyIndexes.TooManyCreateIndex

from CreateIndexMethodCall createIndex, string collectionName, string attributeName
where 
  not createIndex.getCollectionName().matches("Unknown") and
  collectionName = createIndex.getCollectionName() and
  attributeName = getMostUsedAttribute(collectionName) and
  isTooMuchIndex(createIndex.getCollectionName())
select createIndex, "This index creation could cause performance issues because too many indexes (" + getTotalCreateIndex(collectionName) + 
  ") has been created for the collection '$@'. This collection has " + getNumberOfField(collectionName) + " fields and the most used field is '$@' (" + getTotalUseAttribute(collectionName, attributeName) + " times)." +
  "\nTry to get less that 15 indexes by collection !",
  createIndex, collectionName,
  createIndex.getArgument(0), attributeName
order by collectionName, attributeName asc