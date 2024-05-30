grammar CrmscriptImplementation

import "crmscript-definition";

entry ImplementationUnit:
    (types+=BuiltInType | vars+=VariableDeclaration)*;

BuiltInType:
    class=([Class:ID]) name=ID;
