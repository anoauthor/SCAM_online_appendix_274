/**
 * @id LookupAggregations
 * @kind problem
 * @description Detect if there exists several queries that make a lookup between the same collections
 */

import java
import semmle.code.java.dataflow.DataFlow
import codeql_queries.java.MongoOperations.mongoOperations

//Abstraction for lookup queries
abstract class Lookup extends Expr {
  abstract string getJoinedCollection();

  abstract string getCollection();
}

//Predicates used in several lookup classes
string normalizeLookupForRegex(StringLookupQuery l) {
  result =
    l.getValue().replaceAll(" ", "").replaceAll("\n", "").replaceAll("\"", "").replaceAll("'", "")
}

string findFromValueInBsonConstruction(Expr bsonConstr) {
  if
    bsonConstr instanceof ClassInstanceExpr and
    bsonConstr.(ClassInstanceExpr).getArgument(0).toString().matches("%from%")
  then result = findStringFromLiteralOrVariable(bsonConstr.(ClassInstanceExpr).getArgument(1))
  else
    if bsonConstr instanceof MethodAccess
    then
      if bsonConstr.(MethodAccess).getArgument(0).toString().matches("%from%")
      then result = bsonConstr.(MethodAccess).getArgument(1).toString()
      else result = findFromValueInBsonConstruction(bsonConstr.(MethodAccess).getQualifier())
    else result = "Unknown"
}

predicate isALookupConstruction(Expr e) {
  e instanceof ClassInstanceExpr and
  (
    e.(ClassInstanceExpr).getAnArgument().toString().matches("%$lookup%")
    or
    isALookupConstruction(e.(ClassInstanceExpr).getAnArgument())
  )
  or
  e instanceof MethodAccess and
  (
    e.(MethodAccess).getAnArgument().toString().matches("%$lookup%")
    or
    isALookupConstruction(e.(MethodAccess).getQualifier())
  )
}

predicate isASpringDataAggregateConstruction(Expr e) {
  e instanceof ClassInstanceExpr and
  (
    e.(ClassInstanceExpr).getAnArgument().toString().matches("%aggregate%")
    or
    isASpringDataAggregateConstruction(e.(ClassInstanceExpr).getAnArgument())
  )
  or
  e instanceof MethodAccess and
  (
    e.(MethodAccess).getAnArgument().toString().matches("%$aggregate%")
    or
    isASpringDataAggregateConstruction(e.(MethodAccess).getQualifier())
  )
}

//Lookups created from the Spring Data "Aggregation" builder
class SpringDataLookupFromBuilder extends MethodAccess, Lookup {
  MethodAccess aggregationCreation;
  MethodAccess aggregationExecution;

  SpringDataLookupFromBuilder() {
    this.getQualifier()
        .getType()
        .(RefType)
        .hasQualifiedName("org.springframework.data.mongodb.core.aggregation", "Aggregation") and
    this.getMethod().hasName("lookup") and
    aggregationExecution.getMethod().hasName("aggregate") and
    aggregationCreation.getMethod().hasName("newAggregation") and
    TaintTracking::localTaint(DataFlow::exprNode(this),
      DataFlow::exprNode(aggregationCreation.getArgument(0))) and
    TaintTracking::localTaint(DataFlow::exprNode(aggregationCreation),
      DataFlow::exprNode(aggregationExecution.getArgument(0)))
  }

  override string getJoinedCollection() {
    result = findStringFromLiteralOrVariable(this.getArgument(0))
  }

  override string getCollection() {
    if aggregationExecution.getArgument(1) instanceof TypeLiteral
    then
      result =
        getCollectionFromEntityType(aggregationExecution
              .getArgument(1)
              .(TypeLiteral)
              .getTypeName()
              .(TypeAccess)
              .getType()
              .(RefType))
    else result = findStringFromLiteralOrVariable(aggregationExecution.getArgument(1))
  }
}

//Lookup queries encoded as string litteral and then executed with Spring Data
class StringLookupQuery extends StringLiteral, Lookup {
  StringLookupQuery() { this.getValue().matches("%$lookup%") and this.getValue().matches("%from%") }

  override string getJoinedCollection() {
    result = normalizeLookupForRegex(this).regexpCapture(".*?from:(.*?),.*", 1)
  }

  override string getCollection() {
    if normalizeLookupForRegex(this).matches("%aggregate%")
    then result = normalizeLookupForRegex(this).regexpCapture(".*aggregate:(.*?),.*", 1)
    else
      if normalizeLookupForRegex(this).matches("%collection%")
      then result = normalizeLookupForRegex(this).regexpCapture(".*collection:(.*?),.*", 1)
      else result = "Unknown"
  }
}

//Lookups created from the "Aggregates" builder from Mongodb Driver
class LookupFromBuilder extends MethodAccess, MongoDBDriverLookup {
  LookupFromBuilder() {
    this.getQualifier()
        .getType()
        .(RefType)
        .hasQualifiedName("com.mongodb.client.model", "Aggregates")
      and this.getMethod().hasName("lookup")
  }

  override string getJoinedCollection() {
    result = findStringFromLiteralOrVariable(this.getArgument(0))
  }
}

class AggregationMethodCall extends MongoMethodCall {
  AggregationMethodCall() { this.getMethod().hasName("aggregate") }
}

abstract class MongoDBDriverLookup extends Lookup {
  AggregationMethodCall callingAggr;

  //Only works in the lookup is used in the same file, but it should be the case...
  MongoDBDriverLookup() {
    TaintTracking::localTaint(DataFlow::exprNode(this),
      DataFlow::exprNode(callingAggr.getAnArgument()))
  }

  override string getCollection() { result = callingAggr.getCollectionName() }
}

//Lookup queries in BSON for Spring data
class SpringDataBsonLookup extends ClassInstanceExpr, Lookup {
  ClassInstanceExpr aggregation;

  SpringDataBsonLookup() {
    this.getType().(RefType).getAnAncestor().hasQualifiedName("org.bson.conversions", "Bson") and
    isALookupConstruction(this) and
    isASpringDataAggregateConstruction(aggregation) and
    exists(MethodAccess m |
      m.getMethod().hasName("append") and
      TaintTracking::localTaint(DataFlow::exprNode(aggregation),
        DataFlow::exprNode(m.getQualifier())) and
      m.getAnArgument().getAChildExpr() = this
    )
  }

  override string getJoinedCollection() {
    result = findFromValueInBsonConstruction(this.(ClassInstanceExpr).getArgument(1))
  }

  override string getCollection() {
    result = findStringFromLiteralOrVariable(aggregation.getArgument(1))
  }
}

//Lookup queries in BSON for Mongodb Driver
class MongoDriverBsonLookup extends ClassInstanceExpr, MongoDBDriverLookup {
  MongoDriverBsonLookup() {
    this.getType().(RefType).getAnAncestor().hasQualifiedName("org.bson.conversions", "Bson") and
    isALookupConstruction(this)
  }

  override string getJoinedCollection() {
    result = findFromValueInBsonConstruction(this.(ClassInstanceExpr).getArgument(1))
  }
}

//Query
from Lookup l, int nbLookups
where
  not l.getJoinedCollection().matches("Unknown") and
  not l.getCollection().matches("Unknown") and
  nbLookups =
    count(Lookup l2 |
      (
        l2.getCollection() = l.getCollection() and
        l2.getJoinedCollection() = l.getJoinedCollection()
        or
        l2.getCollection() = l.getJoinedCollection() and
        l2.getJoinedCollection() = l.getCollection()
      )
    |
      l2
    ) and
  nbLookups > 1
select l.getEnclosingStmt(),
  "You have " + nbLookups.toString() +
    " queries that perform a lookup operation between the collections " + l.getCollection() +
    " and " + l.getJoinedCollection() +
    ". Maybe you should consider storing data in the same collection to avoid performance issues."
/*

from Lookup l
select l, l.getCollection(), l.getJoinedCollection()*/