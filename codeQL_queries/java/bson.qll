import codeql_queries.java.utils

class BsonCreationPart extends Expr {
  BsonCreationPart() {
    this instanceof NewBsonInstance or
    this instanceof BsonAppendMethodAccess
  }

  Expr getAnArgument() {
    result = this.(NewBsonInstance).getAnArgument() or
    result = this.(BsonAppendMethodAccess).getAnArgument()
  }

  Expr getArgument(int i) {
    result = this.(NewBsonInstance).getArgument(i) or
    result = this.(BsonAppendMethodAccess).getArgument(i)
  }
}

Expr findMostExternalBsonStructure(BsonCreationPart bsonPart) {
  exists(NewBsonInstance i |
    bsonPart = i.getAnArgument() and
    result = findMostExternalBsonStructure(i)
  )
  or
  exists(BsonAppendMethodAccess m |
    bsonPart = m.getQualifier() and
    result = findMostExternalBsonStructure(m)
  )
  or
  bsonPart instanceof BsonAppendMethodAccess and
  exists(NewBsonInstance i |
    bsonPart.getParent() = i.getAnArgument() and
    result = findMostExternalBsonStructure(i)
  )
  or
  exists(MethodAccess m, BsonCreationPart b |
    bsonPart = m.getAnArgument() and
    m = b.getAnArgument() and
    result = findMostExternalBsonStructure(b)
  )
  or
  not exists(NewBsonInstance i | bsonPart = i.getAnArgument()) and
  not exists(BsonAppendMethodAccess m | bsonPart = m.getQualifier()) and
  not exists(MethodAccess m, BsonCreationPart b |
    bsonPart = m.getAnArgument() and m = b.getAnArgument()
  ) and
  result = bsonPart
}
