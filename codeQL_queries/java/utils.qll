import java
import semmle.code.java.dataflow.DataFlow

string findStringFromLiteralOrVariable(Expr exp){
  if exp instanceof StringLiteral
  then result = exp.(StringLiteral).getValue()
  else
    if exp instanceof VarAccess
      then exists(StringToVariableFlowConfig c, StringLiteral sl | sl.getValue() = result  and c.hasFlow(DataFlow::exprNode(sl), DataFlow::exprNode(exp)))
        or result = findStringFromLiteralOrVariable(exp.(VarAccess).getVariable().getInitializer())
    else result = "Unknown"
}

class StringToVariableFlowConfig extends DataFlow::Configuration{
  StringToVariableFlowConfig() { this = "StringToVariableFlowConfig" }

  override predicate isSource(DataFlow::Node source) { source.asExpr() instanceof StringLiteral }

  override predicate isSink(DataFlow::Node sink) {
    sink.asExpr() instanceof VarAccess
  }
}

// Gets all the operations from a mongodb or mongojack collection except from the wrap's methods
class OperationOnCollection extends Method {
  OperationOnCollection() {
    (
      this.getDeclaringType().hasQualifiedName("org.mongojack", "JacksonDBCollection")
      or
      this.getDeclaringType().hasQualifiedName("com.mongodb", "DBCollection")
      or
      this.getDeclaringType().hasQualifiedName("com.mongodb.client", "MongoCollection")
      or
      this.getDeclaringType()
          .getASupertype()
          .getQualifiedName()
          .matches("org.springframework.data.mongodb%")
    ) and
    not this.hasName("wrap")
  }
}

class OperationOnDB extends Method {
  OperationOnDB() {
    this.getDeclaringType().hasQualifiedName("com.mongodb", "DB")
    or
    this.getDeclaringType().hasQualifiedName("com.mongodb.client", "MongoDatabase")
  }
}

class OperationCallOnDB extends MethodAccess {
  OperationCallOnDB() {
    exists(OperationOnDB op | this.getMethod().getSourceDeclaration().overridesOrInstantiates*(op))
  }
}

class OperationCallOnCollection extends MethodAccess {
  OperationCallOnCollection() {
    exists(OperationOnCollection m |
      this.getMethod().getSourceDeclaration().overridesOrInstantiates*(m)
    )
  }
}

// Gets the 'getCollection' operations from mongodb
class GetCollection extends Method {
  GetCollection() {
    (
      this.getDeclaringType().hasQualifiedName("com.mongodb.client", "MongoDatabase")
      or
      this.getDeclaringType().hasQualifiedName("com.mongodb", "DB")
    ) and
    this.hasName("getCollection")
  }
}

class GetCollectionCall extends MethodAccess {
  GetCollectionCall() {
    exists(GetCollection c | this.getMethod().getSourceDeclaration().overridesOrInstantiates*(c))
  }
}

// Gets the 'wrap' operations from mongojack
class JacksonCollectionWrap extends Method {
  JacksonCollectionWrap() {
    this.getDeclaringType().hasQualifiedName("org.mongojack", "JacksonDBCollection") and
    this.hasName("wrap")
  }
}

class JacksonCollectionWrapCall extends MethodAccess {
  JacksonCollectionWrapCall() {
    exists(JacksonCollectionWrap c |
      this.getMethod().getSourceDeclaration().overridesOrInstantiates*(c)
    )
  }
}

class JacksonCollectionBuilder extends Method {
  JacksonCollectionBuilder() {
    this.getDeclaringType().hasQualifiedName("org.mongojack", "JacksonMongoCollection") and
    this.hasName("builder")
  }
}

class JacksonCollectionBuilderCall extends MethodAccess {
  JacksonCollectionBuilderCall() {
    exists(JacksonCollectionBuilder c |
      this.getMethod().getSourceDeclaration().overridesOrInstantiates*(c)
    )
  }
}

class MongoFWPackage extends Package {
  MongoFWPackage() {
    this.getName().matches("%com.mongodb%") or
    this.getName().matches("%org.mongojack%") or
    this.getName().matches("%dev.morphia%") or
    this.getName().matches("%com.mongodb.morphia%") or
    this.getName().matches("%org.springframework.data.mongodb%")
  }
}

class MongoImport extends Import {
  MongoImport() {
    this.(ImportType).getImportedType().getPackage() instanceof MongoFWPackage
    or
    this.(ImportOnDemandFromPackage).getPackageHoldingImport() instanceof MongoFWPackage
    or
    this.(ImportOnDemandFromType).getTypeHoldingImport().getPackage() instanceof MongoFWPackage
  }

  abstract string getDriverName();
}

class MongoJackImport extends MongoImport {
  MongoJackImport() {
    this.(ImportType).getImportedType().getPackage().getName().matches("%org.mongojack%")
    or
    this.(ImportOnDemandFromPackage).getPackageHoldingImport().getName().matches("%org.mongojack%")
    or
    this.(ImportOnDemandFromType)
        .getTypeHoldingImport()
        .getPackage()
        .getName()
        .matches("%org.mongojack%")
  }

  override string getDriverName(){
    result = "MongoJack"
  }
}

class MorphiaImport extends MongoImport {
  MorphiaImport() {
    this.(ImportType).getImportedType().getPackage().getName().matches("%dev.morphia%")
    or
    this.(ImportOnDemandFromPackage).getPackageHoldingImport().getName().matches("%dev.morphia%")
    or
    this.(ImportOnDemandFromType)
        .getTypeHoldingImport()
        .getPackage()
        .getName()
        .matches("%dev.morphia%")
  }

  override string getDriverName(){
    result = "Morphia"
  }
}

class SpringDataImport extends MongoImport {
  SpringDataImport() {
    this.(ImportType)
        .getImportedType()
        .getPackage()
        .getName()
        .matches("%org.springframework.data.mongodb%")
    or
    this.(ImportOnDemandFromPackage)
        .getPackageHoldingImport()
        .getName()
        .matches("%org.springframework.data.mongodb%")
    or
    this.(ImportOnDemandFromType)
        .getTypeHoldingImport()
        .getPackage()
        .getName()
        .matches("%org.springframework.data.mongodb%")
  }

  override string getDriverName(){
    result = "Spring-Data Mongodb"
  }
}

class MongoDBImport extends MongoImport {
  MongoDBImport() {
    this.(ImportType).getImportedType().getPackage().getName().matches("%com.mongodb%")
    or
    this.(ImportOnDemandFromPackage).getPackageHoldingImport().getName().matches("%com.mongodb%")
    or
    this.(ImportOnDemandFromType)
        .getTypeHoldingImport()
        .getPackage()
        .getName()
        .matches("%com.mongodb%")
  }

  override string getDriverName(){
    result = "Mongodb Driver"
  }
}

predicate testAndMigrationFile(File file) {
  file.getAbsolutePath().matches("%/test/%") or
  file.getAbsolutePath().matches("%/migrations/%")
}

string determineOperationTypeFromMethod(Method m) {
  if m.getName().matches("%find%")
  then result = "Read"
  else
    if m.getName().matches("%delete%") or m.getName().matches("%remove%")
    then result = "Delete"
    else
      if m.getName().matches("%insert%")
      then result = "Create"
      else
        if m.getName().matches("%update%") or m.getName().matches("%save%")
        then result = "Update"
        else result = "Unknown"
}

class MongoJackCollectionAnnotation extends Annotation {
  MongoJackCollectionAnnotation() {
    this.getType().hasQualifiedName("org.mongojack", "MongoCollection")
  }
}

class JacksonCollectionBuild extends Method {
  JacksonCollectionBuild() {
    exists(JacksonCollectionBuilderCall c |
      this.hasName("build") and this = c.getParent*().(MethodAccess).getMethod()
    )
  }
}

class JacksonCollectionBuildCall extends MethodAccess {
  JacksonCollectionBuildCall() {
    exists(JacksonCollectionBuild c |
      this.getMethod().getSourceDeclaration().overridesOrInstantiates*(c)
    )
  }
}

class NewBsonInstance extends ClassInstanceExpr{
  NewBsonInstance(){
    this.getType().(RefType).getAnAncestor().hasQualifiedName("org.bson.conversions", "Bson")  }
}

class BsonAppendMethodAccess extends MethodAccess{
  BsonAppendMethodAccess(){
    this.getType().(RefType).getAnAncestor().hasQualifiedName("org.bson.conversions", "Bson")
  and this.getMethod().hasName("append")  }
}