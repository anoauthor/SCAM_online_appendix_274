import mongooseAggregateMethods
import mongooseConnectionMethods
import mongooseDocumentMethods
import mongooseModelMethods
import mongooseMongoose
import mongooseQueryMethod
import mongooseSchemaMethods
import mongooseSchemaType

predicate mongooseMethodName(string methodName) {
    mongooseAggregateMethod(methodName) or
    mongooseConnectionGeneric(methodName) or
    mongooseDocumentMethod(methodName) or
    mongooseModelMethod(methodName) or
    mongooseMongooseGeneric(methodName) or
    mongooseQueryMethod(methodName) or
    mongooseSchemaGeneric(methodName) or
    mongooseSchemaTypeGeneric(methodName)
}