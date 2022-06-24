/**
 * @id LongFieldName
 * @kind problem
 * @description Find field names exceeding a given size limit
 */

import java
import codeql_queries.java.MongoOperations.mongoOperations
import codeql_queries.java.bson

int maxAttributeLentgh() { result = 1 }

predicate hasDocumentAttributeAnnotation(InstanceField f) {
  exists(Annotation a | a = f.getAnAnnotation() and a instanceof DocumentAttributeAnnotation)
}

abstract class LongAttributeName extends ExprParent {
  abstract string getAttributeName();
}

class EntityAttributeWithLongName extends LongAttributeName, InstanceField {
  string attributeName;

  EntityAttributeWithLongName() {
    this.getDeclaringType() instanceof MongoOdmEntityClass and
    not hasDocumentAttributeAnnotation(this) and
    attributeName = this.getName() and
    attributeName.length() > maxAttributeLentgh()
  }

  override string getAttributeName() { result = attributeName }
}

class DocumentAttributeAnnotation extends Annotation {
  DocumentAttributeAnnotation() {
    this.getType().hasQualifiedName("com.fasterxml.jackson.annotation", "JsonProperty") and
    exists(JacksonCollectionBuildCall build |
      build.getAnArgument().(TypeLiteral).getTypeName().getType() =
        this.getAnnotatedElement().(InstanceField).getDeclaringType()
    )
    or
    this.getType().hasQualifiedName("org.springframework.data.mongodb.core.mapping", "Field")
    or
    this.getType().hasQualifiedName("dev.morphia.annotations", "Field")
    or
    this.getType().hasQualifiedName("com.mongodb.morphia.annotations", "Field")
  }
}

class LongNameInAttributeAnnotation extends LongAttributeName, DocumentAttributeAnnotation {
  string attributeName;

  LongNameInAttributeAnnotation() {
    (
      not this.getValue("value").(StringLiteral).getValue().matches("") and
      attributeName = findStringFromLiteralOrVariable(this.getValue("value"))
      or
      not this.getValue("name").(StringLiteral).getValue().matches("") and
      attributeName = findStringFromLiteralOrVariable(this.getValue("name"))
    ) and
    attributeName.length() > maxAttributeLentgh()
  }

  override string getAttributeName() { result = attributeName }
}

class BsonAttributeWithLongName extends LongAttributeName, Expr {
  string attributeName;

  BsonAttributeWithLongName() {
    (this instanceof StringLiteral or this instanceof VarAccess) and
    exists(MongoMethodCall m, BsonCreationPart p |
      m.getOperationType() = "Create" and
      this = p.getArgument(0) and
      DataFlow::localFlow(DataFlow::exprNode(findMostExternalBsonStructure(p)),
        DataFlow::exprNode(m.getAnArgument()))
    ) and
    attributeName = findStringFromLiteralOrVariable(this) and
    attributeName.length() > maxAttributeLentgh()
  }

  override string getAttributeName() { result = attributeName }
}


from LongAttributeName l
where not testAndMigrationFile(l.getFile())
select l,
  "Avoid using long attribute names as they are stored in DB for every document and may waste a lot of space ("
    + l.getAttributeName() + ")"
