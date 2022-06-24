/**
 * @name separating data accessed together
 * @id lookupUsage
 * @kind problem
 * @description Checks if an aggregate is performed with a lookup filter
 */
import javascript

from MethodCallExpr mce, ObjectExpr queryFilter
where 
    mce.getMethodName() = "aggregate" and
    mce.getAnArgument() = queryFilter and
    queryFilter.getAProperty().getName() = "$lookup"
select mce, "this aggregate calls use a $lookup operator"