//
// json-functions-swift
//
// Parts of this file are copied from file
// https://github.com/eu-digital-green-certificates/json-logic-swift/blob/master/Sources/jsonlogic/JsonLogic.swift
// in forked Repository
// https://github.com/eu-digital-green-certificates/json-logic-swift
//
//  JsonLogic.swift
//  jsonlogic
//
//  Created by Christos Koninis on 06/06/2018.
//  Licensed under MIT
//
// Modifications Copyright (c) 2022 SAP SE or an SAP affiliate company
//

import Foundation
import AnyCodable

/**
    Parses json functions strings and executes the rules on provided data.
*/
public final class JsonFunctions {

    // MARK: - Init

    public init() { }

    // MARK: - Public

    /**
     Parses the string containing a json rule and applies that rule, you can optionally pass data to be used for the rule.

    - parameters:
         - jsonRule: A valid json rule string
         - jsonDataOrNil: Data for the rule to operate on
         - customOperators: custom operations that will be used during evalution

    - throws:
     - `JsonFunctionsError.canNotParseJSONRule`
     If The jsonRule could not be parsed, possible the syntax is invalid
     - `ParseError.UnimplementedExpressionFor(_ operator: String)` :
     If you pass an json logic operation that is not currently implemented
     - `ParseError.InvalidParameters(String)` :
     An expression was called with invalid parameters
     - `ParseError.GenericError(String)` :
     An error occurred during parsing of the rule
     - `JsonFunctionsError.canNotConvertResultToType(Any.Type)` :
            When the result from the calculation can not be converted to the return type

            // This throws JsonFunctionsError.canNotConvertResultToType(Double)
            let r: Double = JsonFunctions("{ "===" : [1, 1] }").applyRule()
     - `JsonFunctionsError.canNotParseJSONData(String)` :
     If `jsonDataOrNil` is not valid json
    */
    public func applyRule<T>(_ jsonRule: String, to jsonData: String? = nil, customOperators: [String: (JSON?) -> JSON]? = nil) throws -> T {
        let result = try applyRule(jsonRule, to: jsonData, customOperators: customOperators)

        return try convertToSwiftType(result)
    }

    /**
     Parses the string containing a json rule and applies that rule, you can optionally pass data to be used for the rule.

    - parameters:
         - jsonRule: A valid json rule string
         - jsonDataOrNil: Data for the rule to operate on
         - customOperators: custom operations that will be used during evalution

    - throws:
     - `JsonFunctionsError.canNotParseJSONRule`
     If The jsonRule could not be parsed, possible the syntax is invalid
     - `ParseError.UnimplementedExpressionFor(_ operator: String)` :
     If you pass an json logic operation that is not currently implemented
     - `ParseError.InvalidParameters(String)` :
     An expression was called with invalid parameters
     - `ParseError.GenericError(String)` :
     An error occurred during parsing of the rule
     - `JsonFunctionsError.canNotConvertResultToType(Any.Type)` :
            When the result from the calculation can not be converted to the return type

            // This throws JsonFunctionsError.canNotConvertResultToType(Double)
            let r: Double = JsonFunctions("{ "===" : [1, 1] }").applyRule()
     - `JsonFunctionsError.canNotParseJSONData(String)` :
     If `jsonDataOrNil` is not valid json
    */
    public func applyRule<T: Decodable>(_ jsonRule: String, to jsonData: String? = nil, customOperators: [String: (JSON?) -> JSON]? = nil) throws -> T {
        let result = try applyRule(jsonRule, to: jsonData, customOperators: customOperators)

        return try result.decoded(to: T.self)
    }

    /**
     Registers a function so that it can be called using `evaluateFunction` or using the `call` expression.

    - parameters:
         - name: Name of the function
         - definition: parameters and logic of the function
    */
    public func registerFunction(name: String, definition: JsonFunctionDefinition) {
        registeredFunctions[name] = definition
    }

    /**
     Registers a function so that it can be called using `evaluateFunction` or using the `call` expression.

    - parameters:
         - jsonFunctionDescriptor: jsonFunctionDescriptor
    */

    public func registerFunction(jsonFunctionDescriptor: JsonFunctionDescriptor) {
        registerFunction(
            name: jsonFunctionDescriptor.name,
            definition: jsonFunctionDescriptor.definition
        )
    }

    /**
     Evaluates a function with the given parameters.

    - parameters:
         - name: Name of the function
         - parameters: Parameters passed to the function

    - throws:
     - `JsonFunctionsError.canNotParseJSONRule`
     If The jsonRule could not be parsed, possible the syntax is invalid
     - `ParseError.UnimplementedExpressionFor(_ operator: String)` :
     If you pass an json logic operation that is not currently implemented
     - `ParseError.InvalidParameters(String)` :
     An expression was called with invalid parameters
     - `ParseError.GenericError(String)` :
     An error occurred during parsing of the rule
     - `JsonFunctionsError.canNotConvertResultToType(Any.Type)` :
    When the result from the calculation can not be converted to the return type

    // This throws JsonFunctionsError.canNotConvertResultToType(Double)
    let r: Double = JsonFunctions("{ "===" : [1, 1] }").applyRule()
     - `JsonFunctionsError.canNotParseJSONData(String)` :
     If `jsonDataOrNil` is not valid json
    */
    public func evaluateFunction<T>(name: String, parameters: [String: AnyDecodable]) throws -> T {
        let result = try evaluateFunction(name: name, parameters: parameters)

        return try convertToSwiftType(result)
    }

    /**
     Evaluates a function with the given parameters.

    - parameters:
         - name: Name of the function
         - parameters: Parameters passed to the function

    - throws:
     - `JsonFunctionsError.canNotParseJSONRule`
     If The jsonRule could not be parsed, possible the syntax is invalid
     - `ParseError.UnimplementedExpressionFor(_ operator: String)` :
     If you pass an json logic operation that is not currently implemented
     - `ParseError.InvalidParameters(String)` :
     An expression was called with invalid parameters
     - `ParseError.GenericError(String)` :
     An error occurred during parsing of the rule
     - `JsonFunctionsError.canNotConvertResultToType(Any.Type)` :
            When the result from the calculation can not be converted to the return type

            // This throws JsonFunctionsError.canNotConvertResultToType(Double)
            let r: Double = JsonFunctions("{ "===" : [1, 1] }").applyRule()
     - `JsonFunctionsError.canNotParseJSONData(String)` :
     If `jsonDataOrNil` is not valid json
    */
    public func evaluateFunction<T: Decodable>(name: String, parameters: [String: AnyDecodable]) throws -> T {
        let result = try evaluateFunction(name: name, parameters: parameters)

        return try result.decoded(to: T.self)
    }

    // MARK: - Internal

    internal func applyRule(_ jsonRule: String, to jsonDataOrNil: String? = nil, customOperators: [String: (JSON?) -> JSON]? = nil) throws -> JSON {
        guard let rule = JSON(string: jsonRule) else {
            throw JsonFunctionsError.canNotParseJSONRule("Not valid JSON object")
        }

        var jsonData: JSON?

        if let jsonDataOrNil = jsonDataOrNil {
            jsonData = JSON(string: jsonDataOrNil)
        }

        return try self.applyRule(rule, to: jsonData, customOperators: customOperators)
    }

    internal func applyRule(_ jsonRule: JSON, to jsonData: JSON? = nil, customOperators: [String: (JSON?) -> JSON]? = nil) throws -> JSON {
        let parsedRule = try Parser(
            json: jsonRule,
            customOperators: customOperators,
            registeredFunctions: registeredFunctions
        ).parse()

        let data = jsonData ?? .Null

        return try parsedRule.eval(with: data)
    }

    internal func evaluateFunction(name: String, parameters: [String: AnyDecodable]) throws -> JSON {
        guard let definition = registeredFunctions[name] else {
            throw JsonFunctionsError.noSuchFunction
        }

        let data = definition.parameters.reduce(into: [String: JSON]()) {
            $0[$1.name] = JSON(parameters[$1.name]?.value ?? $1.`default`?.value as Any)
        }

        guard let logicArray = definition.logic.value as? Array<Any> else {
            throw ParseError.InvalidParameters("Logic in function definition must be array")
        }

        return try applyRule(JSON(["script": logicArray]), to: JSON(data))
    }

    internal func applyRule<T>(_ jsonRule: JSON, to jsonData: JSON? = nil, customOperators: [String: (JSON?) -> JSON]? = nil) throws -> T {
        let result = try applyRule(jsonRule, to: jsonData, customOperators: customOperators)

        return try convertToSwiftType(result)
    }

    internal func applyRule<T: Decodable>(_ jsonRule: JSON, to jsonData: JSON? = nil, customOperators: [String: (JSON?) -> JSON]? = nil) throws -> T {
        let result = try applyRule(jsonRule, to: jsonData, customOperators: customOperators)

        return try result.decoded(to: T.self)
    }

    // MARK: - Private

    private var registeredFunctions = [String: JsonFunctionDefinition]()

    private func convertToSwiftType<T>(_ json: JSON) throws -> T {
        let convertedToSwiftStandardType = try json.convertToSwiftTypes()

        switch convertedToSwiftStandardType {
        case let .some(value):
            guard let convertedResult = value as? T else {
                print("canNotConvertResultToType \(T.self) from \(type(of: value))")
                throw JsonFunctionsError.canNotConvertResultToType(T.self)
            }

            return convertedResult
        default:
            // workaround for swift bug that cause to fail when casting
            // from generic type that resolves to Any? in certain compilers, see SR-14356
            #if compiler(>=5) && swift(<5)
            guard let convertedResult = (convertedToSwiftStandardType as Any) as? T else {
                // print("canNotConvertResultToType \(T.self) from \(type(of: convertedToSwiftStandardType))")
                throw JsonFunctionsError.canNotConvertResultToType(T.self)
            }
            #else
            guard let convertedResult = convertedToSwiftStandardType as? T else {
                // print("canNotConvertResultToType \(T.self) from \(type(of: convertedToSwiftStandardType))")
                throw JsonFunctionsError.canNotConvertResultToType(T.self)
            }
            #endif

            return convertedResult
        }
    }

}
