import java
import semmle.code.java.dataflow.DataFlow
import semmle.code.java.dataflow.Nullness
import codeql_queries.java.MongoOperations.mongoOperations
import codeql_queries.java.CodeSmells.TooManyIndexes.TooManyAnnotedIndex
import codeql_queries.java.bson

// ======== Mongo CreateIndex Generic Class ========
abstract class CreateIndexMethodCall extends MongoMethodCall {
  int maxIndexNumber;

  CreateIndexMethodCall() {
    not testAndMigrationFile(this.getFile()) and
    maxIndexNumber = 15 and
    exists(MongoMethod m | this.getMethod().getSourceDeclaration().overridesOrInstantiates*(m))
  }

  abstract predicate isDropingAllIndexes();

  abstract int numberOfCreateIndex();

  abstract int numberOfDropIndex();

  int totalIndexes() { result = 0 }

  abstract string getUsedAttribute();
}

// ======== MongoDB Driver And MongoJack ========
class IndexModelMethod extends Method {
  IndexModelMethod() {
      this.getDeclaringType().hasQualifiedName("com.mongodb.client.model", "Indexes")
  }
}

class IndexModelMethodAccess extends MethodAccess {
  IndexModelMethodAccess(){
      exists(IndexModelMethod imm|  
          this.getMethod().getSourceDeclaration().overridesOrInstantiates*(imm))
  }
}

class CompoundIndexMethodAccess extends IndexModelMethodAccess {
  CompoundIndexMethodAccess(){
      this.getMethod().hasName("compoundIndex")
  }

  override Expr getArgument(int index){
      result = this.getAnArgument().(IndexModelMethodAccess).getArgument(index)
  }
}


class CreateIndexMethod extends MongoMethod {
  CreateIndexMethod() { this.hasName("createIndex") or this.hasName("ensureIndex") }
}

class DropIndexMethodCall extends MongoMethodCall {
  DropIndexMethodCall() {
    not testAndMigrationFile(this.getFile()) and
    this.getMethod().hasName("dropIndex")
  }
}

class BsonAttributeField extends Expr {
  string attributeName;
  BsonAttributeField() {
    exists(MongoMethodCall m, BsonCreationPart p |
      this = p.getArgument(0) and findMostExternalBsonStructure(p) = m.getAnArgument()
    ) and
    attributeName = findStringFromLiteralOrVariable(this)
  }

  string getAttributeName() { result = attributeName }
}

class ClassicDriverCreateIndexMethodCall extends CreateIndexMethodCall {
  ClassicDriverCreateIndexMethodCall() {
    exists(CreateIndexMethod m |
      this.getMethod().getSourceDeclaration().overridesOrInstantiates*(m)
    )
  }

  /*
   * override string getCollectionName() {
   *      exists(AssignExpr expr |
   *        expr.getDest().getType() = this.getQualifier().getType() and
   *        expr.getSource().(MongoMethodCall).getMethod().hasName("getCollection") and
   *        expr.getDest().(VarAccess).getVariable().toString() = this.getQualifier().toString() and
   *        result = expr.getSource().(MongoMethodCall).getAnArgument().(StringLiteral).getValue())
   *    }
   */

  override int totalIndexes() { result = numberOfCreateIndex() }

  override predicate isDropingAllIndexes() {
    exists(DropIndexMethodCall dropIndex |
      this.getCollectionName().matches(dropIndex.getCollectionName()) and
      dropIndex
          .getAnEnclosingStmt()
          .(EnhancedForStmt)
          .getExpr()
          .(MongoMethodCall)
          .getMethod()
          .getName()
          .matches("getIndexInfo") and
      not dropIndex.getAnEnclosingStmt() instanceof ConditionalStmt
    )
  }

  override int numberOfCreateIndex() {
    result =
      count(ClassicDriverCreateIndexMethodCall callers |
        callers.getCollectionName().matches(this.getCollectionName())
      |
        callers
      )
  }

  override int numberOfDropIndex() {
    this.getCollectionName().matches(this.getCollectionName()) and
    if isDropingAllIndexes()
    then result = numberOfCreateIndex()
    else
      result =
        count(DropIndexMethodCall callers |
          not testAndMigrationFile(this.getFile()) and
          callers.getCollectionName().matches(this.getCollectionName())
        )
  }

  override string getUsedAttribute() {
    (
      this.getArgument(0) instanceof StringLiteral and
      result = findStringFromLiteralOrVariable(this.getArgument(0))
    ) or
    (
      this.getArgument(0) instanceof CastExpr and
      result = findStringFromLiteralOrVariable(this.getArgument(0).(CastExpr).getExpr().(IndexModelMethodAccess).getArgument(0))
    ) or
    (
      this.getArgument(0) instanceof IndexModelMethodAccess and
      result = findStringFromLiteralOrVariable(this.getArgument(0).(IndexModelMethodAccess).getArgument(0))
    ) or
    (
      this.getArgument(0) instanceof BsonCreationPart and
      result = findStringFromLiteralOrVariable(this.getArgument(0).(BsonCreationPart).getArgument(0))
    )
  }
}


// ======== SpringData ========
class EnsureIndexMethod extends MongoMethod {
  EnsureIndexMethod() { this.hasName("indexOps") }
}

class SpringDataDropIndexMethodCall extends MongoMethodCall {
  SpringDataDropIndexMethodCall() {
    exists(EnsureIndexMethod op |
      this.getMethod().getSourceDeclaration().overridesOrInstantiates*(op) and
      this.getParent().(MethodAccess).getMethod().hasName("dropIndex")
    )
  }
}

class SpringDataDropAllIndexes extends MongoMethodCall {
  SpringDataDropAllIndexes() {
    exists(EnsureIndexMethod op |
      this.getMethod().getSourceDeclaration().overridesOrInstantiates*(op) and
      this.getParent().(MethodAccess).getMethod().hasName("dropAllIndexes")
    )
  }
}

class SpringDataCreateIndexMethodCall extends CreateIndexMethodCall {
  SpringDataCreateIndexMethodCall() {
    exists(EnsureIndexMethod op |
      this.getMethod().getSourceDeclaration().overridesOrInstantiates*(op) and
      this.getParent().(MethodAccess).getMethod().hasName("ensureIndex")
    )
  }

  override predicate isDropingAllIndexes() {
    exists(SpringDataDropAllIndexes dropAllIndexes |
      this.getCollectionName().matches(dropAllIndexes.getCollectionName())
    )
  }

  int numberOfAnnotedIndex() {
    exists(SpringDataAnnotedClass annotedClass |
      annotedClass.getCollectionName().matches(this.getCollectionName()) and
      result = annotedClass.getTotalAnnotationIndexes())
  }

  override int numberOfCreateIndex() {
    result =
      count(SpringDataCreateIndexMethodCall call |
        call.getCollectionName().matches(this.getCollectionName())
      )
  }

  override int totalIndexes() { result = numberOfCreateIndex() + numberOfAnnotedIndex() }

  override int numberOfDropIndex() {
    this.getCollectionName().matches(this.getCollectionName()) and
    if isDropingAllIndexes()
    then result = numberOfCreateIndex()
    else
      result =
        count(SpringDataDropIndexMethodCall callers |
          not testAndMigrationFile(this.getFile()) and
          callers.getCollectionName().matches(this.getCollectionName())
        )
  }

  override string getUsedAttribute() {
    exists(MethodAccess ensureIndex, MethodAccess bsonMethod, DataFlow::Node source |
      ensureIndex = this.getParent() and
      ensureIndex.getMethod().hasName("ensureIndex") and
      bsonMethod = ensureIndex.getArgument(0).getAChildExpr*() and
      (
          bsonMethod.getMethod().hasName("on") 
        or
          bsonMethod.getMethod().hasName("named")
      ) and
      DataFlow::localFlow(source,
        DataFlow::exprNode(bsonMethod.getArgument(0))) and
      result = source.asExpr().(StringLiteral).getValue())
  }

}

// ======== Generic detector ========

// ----- General index infos ----- //

bindingset[collectionName]
int getTotalCreateIndex(string collectionName){
  result = getTotalCreateIndexClassicDriver(collectionName) + getTotalCreateIndexSpringData(collectionName)
}

bindingset[collectionName]
int getTotalCreateIndexClassicDriver(string collectionName){
  if exists(CreateIndexMethodCall call | call.getCollectionName().matches(collectionName) and call instanceof ClassicDriverCreateIndexMethodCall)
  then exists(ClassicDriverCreateIndexMethodCall createIndex |
    createIndex.getCollectionName().matches(collectionName) and
    result = createIndex.totalIndexes())
  else result = 0
}

bindingset[collectionName]
int getTotalCreateIndexSpringData(string collectionName){
  if exists(CreateIndexMethodCall call | call.getCollectionName().matches(collectionName) and call instanceof SpringDataCreateIndexMethodCall)
  then exists(SpringDataCreateIndexMethodCall createIndex |
    createIndex.getCollectionName().matches(collectionName) and
    result = createIndex.totalIndexes())
  else 
    if exists(SpringDataAnnotedClass annotedClass | annotedClass.getCollectionName().matches(collectionName) and annotedClass.getTotalAnnotationIndexes() > 0)
    then exists(SpringDataAnnotedClass annotedClass |
      annotedClass.getCollectionName().matches(collectionName) and
      result = annotedClass.getTotalAnnotationIndexes())
    else
      result = 0 
}

bindingset[collectionName]
predicate isTooMuchIndex(string collectionName) {
  getTotalCreateIndex(collectionName) >= 15
}

// ----- Field/attribute index infos ----- //

bindingset[collectionName]
int getNumberOfField(string collectionName){
  if exists(CreateIndexMethodCall createIndexMethodCall, AnnotedClass annotedClass |
    createIndexMethodCall.getCollectionName().matches(collectionName) and
    annotedClass.getCollectionName().matches(collectionName))
  then exists(AnnotedClass annotedClass | 
    annotedClass.getCollectionName().matches(collectionName) and
    result = annotedClass.getNumberOfFields())
  else
    result = count(MongoMethodCall call, BsonAttributeField attrib |
      call.getCollectionName().matches(collectionName) and
      call.getAnArgument() = attrib.getParent() and
      not call.getCollectionName().matches("Unknown") | attrib
      )
}

bindingset[collectionName]
string getMostUsedAttribute(string collectionName) {
    exists(CreateIndexMethodCall call, string attributeName, int numberOfAttributCall|
        attributeName = call.getUsedAttribute() and
        numberOfAttributCall = getTotalUseAttribute(collectionName, attributeName) and
        not exists(CreateIndexMethodCall calle, string attributeNamee | 
            attributeNamee = calle.getUsedAttribute() and 
            getTotalUseAttribute(collectionName, attributeNamee) > numberOfAttributCall) and
        result = attributeName)
}

bindingset[collectionName, attributeName]
int getTotalUseAttribute(string collectionName, string attributeName) {
    result = 
      count(CreateIndexMethodCall calls | 
        calls.getCollectionName().matches(collectionName) and calls.getUsedAttribute().matches(attributeName)) +
      count(SpringDataIndexAnnotation indexAnnotation, SpringDataAnnotedClass annotedClass | 
        annotedClass.getCollectionName().matches(collectionName) and
        indexAnnotation.getClass() = annotedClass and
        indexAnnotation.getUsedAttribute().matches(attributeName))
}