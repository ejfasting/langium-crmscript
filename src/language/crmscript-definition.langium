grammar CrmscriptDefinition

entry DefinitionUnit:
    (elements+=Element)*;

Element: 
    Class
    | ExpressionBlock
    | FunctionDeclaration
    | VariableDeclaration ';'
    | Expression ';'
    | ReturnStatement ';'
;

VariableDeclaration:
    {infer VariableDeclaration} type=TypeReference name=ID (assignment?='=' value=Expression)?
;

//Add other variable names to the name-property of the Class, to support Keywords as Identifiers => https://langium.org/docs/recipes/keywords-as-identifiers/
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

FunctionDeclaration:
    returnType=TypeReference name=ID '(' (parameters+=Parameter (',' parameters+=Parameter)*)? ')' body=ExpressionBlock
;

TypeReference: 
    reference=[Class:ID] 
    | primitive=("String" | "Integer" | "Bool") 
    | '(' ( parameters+=LambdaParameter (',' parameters+=LambdaParameter)*)? ')' '=>' returnType=TypeReference
;

//TODO: Remove this? It could be Parameter instead
LambdaParameter: type=TypeReference (name=ID)? 
;

Parameter: type=TypeReference name=ID
;

ExpressionBlock: '{'
    (elements+=Element)*
'}'
;

Expression:
    Assignment
;

Assignment infers Expression:
    Addition ({infer BinaryExpression.left=current} operator=('=') right=Addition)*
;

Addition infers Expression:
    Multiplication ({infer BinaryExpression.left=current} operator=('+' | '-') right=Multiplication)*
;

Multiplication infers Expression:
    Logical ({infer BinaryExpression.left=current} operator=('*' | '/') right=Logical)*
;

Logical infers Expression:
    Comparison ({infer BinaryExpression.left=current} operator=('and' | 'or') right=Comparison)*
;

Comparison infers Expression:
    MemberCall ({infer BinaryExpression.left=current} operator=('<' | '<=' | '>' | '>=' | '==' | '!=') right=MemberCall)*
;

MemberCall infers Expression:
    Primary
	({infer MemberCall.previous=current} 
        // Member call with function call
        ("." element=[NamedElement:ID] (
		explicitOperationCall?='('
		(
		    arguments+=Expression (',' arguments+=Expression)*
		)?
		')')? 
        // Chained function call
        | (
		explicitOperationCall?='('
		(
		    arguments+=Expression (',' arguments+=Expression)*
		)?
		')'))
    )*
;

Primary infers Expression:
    '(' Expression ')' |
    UnaryExpression |
    StringExpression |
    BooleanExpression |
    IntegerExpression |
    NilExpression |
    FeatureCall
;

FeatureCall infers Expression:
	{infer MemberCall}
	(element=[NamedElement:ID] | element=[NamedElement:'this'] | element=[NamedElement:'super'])
    // Optional function call after referencing an element
    (explicitOperationCall?='('
	(
	    arguments+=Expression (',' arguments+=Expression)*
	)?
	')')?
;

UnaryExpression:
   operator=('!' | '-' | '+') value=Expression
;

IntegerExpression: value=NUMBER
;

StringExpression: value=STRING
;

BooleanExpression: value?='true' | 'false'
;

NilExpression: value='nil'
;

ReturnStatement:
    'return' value=Expression?
;

type NamedElement = Parameter | FunctionDeclaration | VariableDeclaration | MethodMember | FieldMember | Class
;
hidden terminal WS: /\s+/;
terminal ID: /[_a-zA-Z][\w_]*/;
terminal NUMBER returns number: /[0-9]+(\.[0-9]+)?/;
terminal STRING: /"[^"]*"/;

hidden terminal ML_COMMENT: /\/\*[\s\S]*?\*\//;
hidden terminal SL_COMMENT: /\/\/[^\n\r]*/;