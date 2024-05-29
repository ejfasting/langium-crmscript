import { AstUtils, DefaultScopeProvider, EMPTY_SCOPE, ReferenceInfo, Scope } from "langium";
import { /*Class, isClass,*/ Class, MemberCall, isClass } from "./generated/ast.js";
//import { isClassType } from "./type-system/descriptions.js";
//import { getClassChain, inferType } from "./type-system/infer.js";
import { LangiumServices } from "langium/lsp";
import { getClassChain, inferType } from "./type-system/infer.js";
import { isClassType, isStringType } from "./type-system/descriptions.js";

export class CrmscriptScopeProvider extends DefaultScopeProvider {

    constructor(services: LangiumServices) {
        super(services);
    }

    override getScope(context: ReferenceInfo): Scope {
        // target element of member calls
        if (context.property === 'element') {     
            // for now, `this` and `super` simply target the container class type
            if (context.reference.$refText === 'this' || context.reference.$refText === 'super') {
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
            if(isStringType(previousType)){
                return this.scopeVariableMembers(previousType.$type);
            }
            return EMPTY_SCOPE;
        }
        return super.getScope(context);
    }

    private scopeClassMembers(classItem: Class): Scope {
        const allMembers = getClassChain(classItem).flatMap(e => e.members);
        return this.createScopeForNodes(allMembers);
    }

    private scopeVariableMembers(typeDescription: string): Scope {
        //const allMembers = this.getVariableChain(typeDescription).flatMap(e => e.members);
        //console.log(typeDescription.$type);
        return this.createScopeForNodes([]);
    }
}