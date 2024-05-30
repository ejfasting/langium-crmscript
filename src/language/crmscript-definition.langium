grammar CrmscriptDefinition

entry DefinitionUnit:
    (elements+=Element)*;

Element: Class
;

//Add other variable names to the name-property of the Class
Class: 'class' name=(ID | 'String') '{'
    members+=ClassMember*
'}'
;

ClassMember: MethodMember | FieldMember
;

MethodMember:
    returnType=TypeReference name=ID '(' (parameters+=Parameter (',' parameters+=Parameter)*)? ')' body=ExpressionBlock
;

FieldMember:
    type=TypeReference name=ID ';'
;

TypeReference: 
    reference=[Class:ID] |
   primitive=("String" | "Integer" | "Bool")
;

Parameter: type=TypeReference name=ID
;

ExpressionBlock: '{'
    (elements+=Element)*
'}' ';'
;

hidden terminal WS: /\s+/;
terminal ID: /[_a-zA-Z][\w_]*/;

hidden terminal ML_COMMENT: /\/\*[\s\S]*?\*\//;
hidden terminal SL_COMMENT: /\/\/[^\n\r]*/;