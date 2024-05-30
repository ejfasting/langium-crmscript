import { AstUtils, DefaultScopeProvider, EMPTY_SCOPE, ReferenceInfo, Scope } from "langium";
import { /*Class, isClass,*/ Class, MemberCall, StringExpression, Struct, isClass, isStruct } from "./generated/ast.js";
//import { isClassType } from "./type-system/descriptions.js";
//import { getClassChain, inferType } from "./type-system/infer.js";
import { LangiumServices } from "langium/lsp";
import { getClassChain, getStructChain, inferType } from "./type-system/infer.js";
import { isClassType, isStringType, isStructType } from "./type-system/descriptions.js";

export class CrmscriptScopeProvider extends DefaultScopeProvider {

    constructor(services: LangiumServices) {
        super(services);
    }

    override getScope(context: ReferenceInfo): Scope {
        // target element of member calls
        if (context.property === 'element') {     
            // for now, `this` and `super` simply target the container class type
            if (context.reference.$refText === 'this' || context.reference.$refText === 'super') {
                /*Test */
                const structItem = AstUtils.getContainerOfType(context.container, isStruct);
                if (structItem) {
                    console.log(structItem.members);
                    return this.scopeStructMembers(structItem);
                }
                const classItem = AstUtils.getContainerOfType(context.container, isClass);
                if (classItem) {
                    return this.scopeClassMembers(classItem);
                } else {
                    return EMPTY_SCOPE;
                }
            }
            const memberCall = context.container as MemberCall;
            const previous = memberCall.previous;
            if (!previous) {
                return super.getScope(context);
            }
            const previousType = inferType(previous, new Map());
            if (isClassType(previousType)) {
                return this.scopeClassMembers(previousType.literal);
            }
            if (isStructType(previousType)) {
                return this.scopeStructMembers(previousType.literal);
            }
            //TODO: Implement variable scope
            if(isStringType(previousType)){
                return this.scopeVariableMembers(previousType.literal);
            }
            return EMPTY_SCOPE;
        }
        return super.getScope(context);
    }

    private scopeClassMembers(classItem: Class): Scope {
        const allMembers = getClassChain(classItem).flatMap(e => e.members);
        return this.createScopeForNodes(allMembers);
    }

    private scopeStructMembers(structItem: Struct): Scope {
        const allMembers = getStructChain(structItem).flatMap(e => e.members);
        return this.createScopeForNodes(allMembers);
    }

    private scopeVariableMembers(typeDescription?: StringExpression): Scope {
        //const allMembers = this.getVariableChain(typeDescription).flatMap(e => e.members);
        //console.log(typeDescription.$type);
        return this.createScopeForNodes([]);
    }
}