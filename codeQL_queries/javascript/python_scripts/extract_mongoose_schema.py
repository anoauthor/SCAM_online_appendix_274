import json
import sqlite3
from xmlrpc.client import Boolean
import esprima
PATH = 'PATHTOSCHEMAFILE'


def give_schema_ast(node):
    if node.type == "Program":
        return give_schema_ast(node.body[0])

    elif node.type == "ExpressionStatement":
        return give_schema_ast(node.expression)

    elif node.type == "NewExpression":
        if node.callee.name == "Schema":
            return give_schema_ast(node.arguments[0])
    
    elif node.type == "CallExpression":
        if node.callee.property.name == "Schema":
            return node.arguments[0]

    else:
        return node



def visit_schema(node):
    if node.type == "ObjectExpression":
        return {name: value for name, value in [visit_schema(prop) for prop in node.properties]}
    
    elif node.type == "Property":
        return visit_schema(node.key), visit_schema(node.value)
    
    #leaf literal
    elif node.type == "Literal":
        return node.value

    elif node.type == "MemberExpression":
        return visit_schema(node.object) + "." + visit_schema(node.property)
    
    #leafidentifier
    elif node.type == "Identifier":
        return node.name
    
    #just before leaf, next el should always be leaf
    elif node.type == "ArrayExpression":
        return [visit_schema(el) for el in node.elements]
    
    #In case they define a schema inside the schema
    elif node.type == "NewExpression":
        return visit_schema(node.arguments[0])


def get_schema_dict(file_path, coordinates):
    """
    Returns the dict corresponding to schema at the given location

    parameters:
    -----------
    file_path: path to the file (str)
    coordinates: [start_line, start_column, end_line, end_column]

    returns:
    --------
    schema_dict: schema corresponding to the dict at the given location
    """
    start_line, start_column, end_line, end_column = coordinates
    schema = ''
    with open(file_path, 'r') as f:
        for i in range(end_line):
            if i >= start_line-1:
                line = f.readline()
                if i == start_line-1:
                    line = line[start_column-1:]
                elif i == end_line-1:
                    line = line[:end_column]
                schema += line
                
            else:
                f.readline()
    tree_out = esprima.parseScript(schema)
    schema_tree = give_schema_ast(tree_out)
    return visit_schema(schema_tree)
acc = []
def gather_attribute_names(schema_dict):
    """
    gather attribute names from a specific schema dict

    parameters:
    -----------
    schema_dict : dict holding a mongoose schema (dict)

    returns:
    ---------
    attributes : list holding all attribute names
    """

    if type(schema_dict) == list:
        [gather_attribute_names(el) for el in schema_dict]
    elif type(schema_dict) == dict:
        for key in schema_dict:
            if not(key in['type', 'default', 'enum', 'ref', 'index', 'alias']):
                acc.append(key)
                gather_attribute_names(schema_dict[key])

