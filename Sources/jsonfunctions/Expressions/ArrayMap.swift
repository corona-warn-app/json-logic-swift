//
// json-functions-swift
//
// Parts of this file are copied from file
// https://github.com/eu-digital-green-certificates/json-logic-swift/blob/master/Sources/jsonlogic/Parser.swift
// in forked Repository
// https://github.com/eu-digital-green-certificates/json-logic-swift
//
//  Parser.swift
//  jsonlogic
//
//  Created by Christos Koninis on 16/06/2018.
//  Licensed under MIT
//
// Modifications Copyright (c) 2022 SAP SE or an SAP affiliate company
//

import Foundation

struct ArrayMap: Expression {

    let expression: Expression

    func eval(with data: inout JSON) throws -> JSON {
        guard let array = self.expression as? ArrayOfExpressions,
            array.expressions.count >= 2,
            case let .Array(dataArray) = try array.expressions[0].eval(with: &data)
            else {
                return []
        }

        let mapOperation = array.expressions[1]

        if let elementKey = try array.expressions[safe: 2]?.eval(with: &data).string, var dataDictionary = data.dictionary {
            let mappedArray: [JSON] = try dataArray.map {
                dataDictionary[elementKey] = $0
                return try mapOperation.eval(with: JSON(dataDictionary))
            }

            return JSON(mappedArray)
        } else {
            let mappedArray = try dataArray.map {
                return try mapOperation.eval(with:$0)
            }

            return JSON(mappedArray)
        }
    }
    
}
