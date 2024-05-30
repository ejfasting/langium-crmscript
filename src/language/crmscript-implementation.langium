grammar CrmscriptImplementation

import "crmscript-definition";

entry ImplementationUnit:
    (types+=BuiltInType)*;

BuiltInType:
    class=([Class:ID]) name=ID;
