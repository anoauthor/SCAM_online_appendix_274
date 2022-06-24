import mongoAdminMethods
import mongoBulkOperationBase
import mongoCollectionMethod
import mongoDbMethods
import mongoFindOperators
import mongoGridstoreMehtods
import mongoOrderedBulkOperation
import mongoUnorderedBulkOperationMethods

predicate mongoMethodName(string methodName) {
    mongoAdminMethod(methodName) or
    mongoBulkOperationBaseMethod(methodName) or
    mongoCollectionMethod(methodName) or
    mongoDbMethod(methodName) or
    mongoFindOperatorsMethod(methodName) or
    mongoGridstoreMethod(methodName) or
    mongoOrderedBulkOperation(methodName) or
    mongoUnorderedBulkOperationMethod(methodName)
}