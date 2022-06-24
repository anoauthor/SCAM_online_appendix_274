/**
 * @name use of relational collection
 * @id useRelational
 * @kind problem
 * @description Checks via an aggregate if there exists a relational collection
 */
import javascript

class LookupOperator extends ObjectExpr {
    LookupOperator(){
        this.getAProperty().getName() = "$lookup" and
        this.getPropertyByName("$lookup").getInit() instanceof ObjectExpr
    }
    string getField(string fieldName) {
        result = this.getPropertyByName("$lookup").getInit().(ObjectExpr).getPropertyByName(fieldName).getInit().(StringLiteral).getValue()
    }
}
abstract class Aggregate2NetstedLookups extends MethodCallExpr{}

class Aggregate2NetstedLookupsArray extends Aggregate2NetstedLookups{
    Aggregate2NetstedLookupsArray(){
        this.getMethodName() = "aggregate" and
        exists( 
            LookupOperator lookup1, LookupOperator lookup2 |  
            this.getAnArgument().(ArrayExpr).getAnElement() = lookup1 and
            this.getAnArgument().(ArrayExpr).getAnElement() = lookup2 and
            lookup1 != lookup2 and
            lookup2.getField("localField").matches(lookup1.getField("as") + ".%") )
    }
}

class Aggregate2NetstedLookupsObjectExpr extends Aggregate2NetstedLookups{
    Aggregate2NetstedLookupsObjectExpr() {
        this.getMethodName() = "aggregate" and
        exists(LookupOperator lookup1, LookupOperator lookup2 |  
            this.getAnArgument() = lookup1 and
            this.getAnArgument() = lookup2 and
            lookup1 != lookup2 and
            lookup2.getField("localField").matches(lookup1.getField("as") + ".%") )
    }
}

from Aggregate2NetstedLookups mce
select mce, "This aggregate posesses 2 nested lookups"