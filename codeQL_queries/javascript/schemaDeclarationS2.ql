/**
 * @name Describe Schema defined with mongoose call
 * @id schemaDeclaration
 * @kind problem
 * @description outputs the schema structure
 */

import javascript
ASTNode getDescendant(ASTNode node) {
    result = node.getAChild() or
    result = getDescendant(node.getAChild())
}
string propToString(Property prop) {
    if prop.getInit().(ObjectExpr).getProperty(0).getName() = "type"
    then result = concat(
        Property prop2 |
        prop.getInit().(ObjectExpr).getAProperty() = prop2 |
        prop2.getName() + ": " + prop2.getInit().getStringValue()
        )
    else result = prop.getName() + ""
    // concat( 
    //     Property  prop2 |
    //     prop.getInit().(ObjectExpr).getAProperty() = prop2 | 
    //     propToString(prop2))
}
class MongooseSchemaS1 extends InvokeExpr {
    MongooseSchemaS1() {
        this.getCalleeName() = "Schema" and
        exists( 
            MethodCallExpr model | 
            model.getCalleeName() = "model" and this.getFile() = model.getFile())
    }
}
class MongooseSchemaS2 extends InvokeExpr {
    MongooseSchemaS2() {
        this.getCalleeName() = "Schema" and
        not exists(Property prop | getDescendant(prop) = this)
    }
    string getAnAttributeType() {
        result = this.getAProperty().getInit().(ObjectExpr).getPropertyByName("type").getInit().toString()
    }
    Property getAProperty() {
        result = this.getAnArgument().(ObjectExpr).getAProperty()
    }
    string getAllAttributesDescription() {
        result = concat( MongooseProperty prop | prop = this.getAnArgument().(ObjectExpr).getAProperty() | prop.describeAttribute(), ", " )
    }

}

abstract class MongooseProperty extends Property {
    string describeAttribute() {
        result = "!! should not be displayed " + this.getName() +" !!"
    }
}
class MongoosePropertyObjectExpr extends MongooseProperty {
    MongoosePropertyObjectExpr() {
        this.getInit().(ObjectExpr).getAProperty().getName() = "type"
    }
    override string describeAttribute() {
        result = this.getName() + ": " + this.getInit().(ObjectExpr).getPropertyByName("type").getInit().(VarRef).getName() or
        result = this.getName() + ": " + resolveDotExpr(this.getInit().(ObjectExpr).getPropertyByName("type").getInit().(DotExpr))
    }
}
class MongoosePropertyDirectType extends MongooseProperty {
    MongoosePropertyDirectType() {
        this.getInit() instanceof VarRef
    }
    override string describeAttribute() {
        result = this.getName() + ": " + this.getInit().(VarRef).getName() or
        result = this.getName() + ": " + resolveDotExpr(this.getInit().(DotExpr))
    }
}
class MongoosePropertyArray extends MongooseProperty {
    MongoosePropertyArray() {
        this.getInit() instanceof ArrayExpr
    }

    override string describeAttribute() {
        result = this.getName() + ": [ " + this.getInit().(ArrayExpr).getElement(0).(VarRef).getName() + " ]" or
        result = this.getName() + ": [ " + resolveDotExpr(this.getInit().(ArrayExpr).getElement(0).(DotExpr)) + " ]"
    }
}
class MongoosePropertyArrayObjectExpr extends MongoosePropertyArray {
    MongoosePropertyArrayObjectExpr() {
        this.getInit() instanceof ArrayExpr and
        this.getInit().(ArrayExpr).getElement(0) instanceof ObjectExpr
    }

    override string describeAttribute() {
        result = this.getName() + ": [ " + this.getInit().(ArrayExpr).getElement(0).(ObjectExpr).getPropertyByName("type").getInit().(VarRef).getName() + " ]" or
        result = this.getName() + ": [ " + resolveDotExpr(this.getInit().(ArrayExpr).getElement(0).(ObjectExpr).getPropertyByName("type").getInit().(DotExpr)) + " ]"
    }
}
class MongoosePropertySubSchema extends MongooseProperty {
    MongoosePropertySubSchema() {
        this.getInit() instanceof ObjectExpr and
        not(exists( Property prop | this.getInit().(ObjectExpr).getAProperty() = prop and  prop.getName() = "type")) 
        
    }

    override string describeAttribute() {
        result = this.getName() +  ": {" + concat(MongooseProp2 prop | this.getInit().(ObjectExpr).getAProperty() = prop | prop.describeAttribute() , ", ") + "}"
    }
    // override string describeAttribute() {
    //     result = this.getName() + ": { " + 
    // }

}

abstract class MongooseProp2 extends Property {
    string describeAttribute() {
        result = "!!! should not be displayed"
    }
}

class MongoosePropertyObjectExpr2 extends MongooseProp2 {
    MongoosePropertyObjectExpr2() {
        this.getInit().(ObjectExpr).getAProperty().getName() = "type"
    }
    override string describeAttribute() {
        result = this.getName() + ": " + this.getInit().(ObjectExpr).getPropertyByName("type").getInit().(VarRef).getName() or
        result = this.getName() + ": " + resolveDotExpr(this.getInit().(ObjectExpr).getPropertyByName("type").getInit().(DotExpr))
    }
}
class MongoosePropertyDirectType2 extends MongooseProp2 {
    MongoosePropertyDirectType2() {
        this.getInit() instanceof VarRef
    }
    override string describeAttribute() {
        result = this.getName() + ": " + this.getInit().(VarRef).getName() or
        result = this.getName() + ": " + resolveDotExpr(this.getInit().(DotExpr))
    }
}
class MongoosePropertyArray2 extends MongooseProp2 {
    MongoosePropertyArray2() {
        this.getInit() instanceof ArrayExpr
    }

    override string describeAttribute() {
        result = this.getName() + ": [ " + this.getInit().(ArrayExpr).getElement(0).(VarRef).getName() + " ]" or
        result = this.getName() + ": [ " + resolveDotExpr(this.getInit().(ArrayExpr).getElement(0).(DotExpr)) + " ]"
    }
}
class MongoosePropertyArrayObjectExpr2 extends MongoosePropertyArray2 {
    MongoosePropertyArrayObjectExpr2() {
        this.getInit() instanceof ArrayExpr and
        this.getInit().(ArrayExpr).getElement(0) instanceof ObjectExpr
    }

    override string describeAttribute() {
        result = this.getName() + ": [ " + this.getInit().(ArrayExpr).getElement(0).(ObjectExpr).getPropertyByName("type").getInit().(VarRef).getName() + " ]" or
        result = this.getName() + ": [ " + resolveDotExpr(this.getInit().(ArrayExpr).getElement(0).(ObjectExpr).getPropertyByName("type").getInit().(DotExpr)) + " ]"
    }
}


predicate testFile(File f) {
    //Jasmine test files
    f.getAbsolutePath().matches("%.spec.%") or 
    f.getAbsolutePath().matches("%test%") or
    f.getAbsolutePath().matches("%.jsx")
}
string resolveDotExpr(DotExpr de) {
    result = de.getBase().(VarRef).getName() + "." + de.getPropertyName() or
    result = resolveDotExpr(de.getBase()) + "." + de.getPropertyName()
}

from MongooseSchemaS2 schema
where 
    not testFile(schema.getFile())
select schema, schema.getAllAttributesDescription()