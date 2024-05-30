import { type ValidationChecks } from 'langium';
//import { BinaryExpression, ExpressionBlock, FunctionDeclaration, MethodMember, TypeReference, UnaryExpression, VariableDeclaration, isReturnStatement, type Class, type Struct, type CrmscriptAstType} from './generated/ast.js';
import type { CrmscriptServices } from './crmscript-module.js';
import { CrmscriptAstType } from './generated/ast.js';

/**
 * Register custom validation checks.
 */
export function registerValidationChecks(services: CrmscriptServices) {
    const registry = services.validation.ValidationRegistry;
    const validator = services.validation.CrmscriptValidator;
    const checks: ValidationChecks<CrmscriptAstType> = {
    };
    registry.register(checks, validator);
}

/**
 * Implementation of custom validations.
 */
export class CrmscriptValidator {

}
