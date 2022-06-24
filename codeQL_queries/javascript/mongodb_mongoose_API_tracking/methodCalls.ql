/**
 * @id methodCalls
 * @name Finds mongo/mongoose calls
 * @description Checks method calls corresponding to CRUD query for mongo/mongoose, based on method name, not included in function. We exclude call to object here
 * @kind problem
 */

import javascript
import mongodb.mongoRecap
import mongoose.mongooseRecap
import axioms
import codeGen
import blackList

predicate testFile(File f) {
    //Jasmine test files
    f.getAbsolutePath().matches("%.spec.%") or 
    f.getAbsolutePath().matches("%test%") or
    f.getAbsolutePath().matches("%.jsx")
}

from MethodCallExpr mce
where 
    (mongooseMethodName(mce.getMethodName())  or mongoDbMethod(mce.getMethodName()))and
    respectAxioms(mce) and
    recap(mce) and
    not(blackList(mce)) and
    not testFile(mce.getFile())
select mce, mce.getMethodName() + " with receiver " + mce.getReceiver()