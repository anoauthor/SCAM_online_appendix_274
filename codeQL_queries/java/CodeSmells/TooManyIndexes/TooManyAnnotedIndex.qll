import java
import semmle.code.java.dataflow.DataFlow
import codeql_queries.java.utils
import codeql_queries.java.MongoOperations.mongoOperations
import codeql_queries.java.CodeSmells.TooManyIndexes.TooManyCreateIndex


class SpringDataIndexAnnotation extends Annotation {
  SpringDataIndexAnnotation(){
    this.getType().getPackage().hasName("org.springframework.data.mongodb.core.index")
  }

  abstract Class getClass();

  abstract string getUsedAttribute();

}

class SpringDataIndexedAnnotation extends SpringDataIndexAnnotation {
  SpringDataIndexedAnnotation(){
    this.getType().hasQualifiedName("org.springframework.data.mongodb.core.index", "Indexed")
  }

  override Class getClass(){
    exists(SpringDataAnnotedClass annotedClass |
      annotedClass.getAField() = this.getAnnotatedElement() and
      result = annotedClass)
  }

  override string getUsedAttribute() {
    result = this.getAnnotatedElement().getName()
  }
}

class SpringDataCompoundIndexAnnotation extends SpringDataIndexAnnotation {
  SpringDataCompoundIndexAnnotation(){
    this.getType().hasQualifiedName("org.springframework.data.mongodb.core.index", "CompoundIndex")
  }

  override Class getClass(){
    exists(SpringDataAnnotedClass annotedClass |
      annotedClass.getAnAnnotation().(CompoundIndexesAnnotation).getAValue().(ArrayInit).getAnInit() = this and
      result = annotedClass)
  }

  override string getUsedAttribute() {
    result = this.getValue("def").(StringLiteral).getValue().regexpCapture(".*'(.*?)':.*",1)
  }
}

class CompoundIndexesAnnotation extends Annotation {
    CompoundIndexesAnnotation(){
      this.getType().hasQualifiedName("org.springframework.data.mongodb.core.index", "CompoundIndexes")
    }
  }

class AnnotedClass extends Class {
  AnnotedClass(){
    this.getAnAnnotation().getType().hasQualifiedName("org.springframework.data.mongodb.core.mapping", "Document") or
    this.getAnAnnotation() instanceof MongoJackCollectionAnnotation
  }

  int getNumberOfFields() {
    result = count(this.getAField())
  }

  abstract string getCollectionName();
}

class MongoJackAnnotedClass extends AnnotedClass {
  MongoJackAnnotedClass(){
    this.getAnAnnotation() instanceof MongoJackCollectionAnnotation
  }

  override string getCollectionName(){
    result = getJacksonCollectionFromEntityType(this).getValue()
  }
}

class MongoJackAnnotedClassWithDataFlow extends AnnotedClass {
  DataFlow::Node sink;
  DataFlow::Node source;

  MongoJackAnnotedClassWithDataFlow(){
    exists(MongoJackCollNameFlowConfig c |
      this.getAnAnnotation().getValue("name") = sink.asExpr() and
      c.hasFlow(source, sink))
  }

  override string getCollectionName(){
    result = source.asExpr().(StringLiteral).getValue()
  }
}
  
class SpringDataAnnotedClass extends AnnotedClass {
  SpringDataAnnotedClass(){
    this.getAnAnnotation().getType().hasQualifiedName("org.springframework.data.mongodb.core.mapping", "Document")
  }

  int getNumberOfIndexedFields(){
    result = count(SpringDataIndexedAnnotation ia |
      ia.getAnnotatedElement() = this.getAField())
  }

  int getNumberOfCompoundIndexes(){
    result = count(SpringDataCompoundIndexAnnotation compoundIndex |
      compoundIndex = this.getAnAnnotation().(CompoundIndexesAnnotation).getAValue().(ArrayInit).getAnInit())
  }

  int getTotalAnnotationIndexes(){
    result = this.getNumberOfIndexedFields() + this.getNumberOfCompoundIndexes()
  }

  SpringDataIndexAnnotation getAnnotations(){
    exists(SpringDataIndexAnnotation indexAnnotation | 
      this = indexAnnotation.getClass() and
      result = indexAnnotation)
  }

  override string getCollectionName(){
    result = getCollectionFromEntityType(this)
  }
}

class SpringDataAnnotedClassWithDataFlow extends SpringDataAnnotedClass {
  DataFlow::Node sink;
  DataFlow::Node source;

  SpringDataAnnotedClassWithDataFlow(){
    exists(SpringDataCollNameFlowConfig c |
      this.getAnAnnotation().getValue("collection").toString() = sink.asExpr().toString() and
      c.hasFlow(source, sink))
  }

  override string getCollectionName(){
    result = source.asExpr().(StringLiteral).getValue()
  }
}