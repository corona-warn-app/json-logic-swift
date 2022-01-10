//
// json-functions-swift
//

import Foundation
import JSON

struct Concatenate: Expression {

    let expression: Expression

    func evalWithData(_ data: JSON?) throws -> JSON {
        let result = try expression.evalWithData(data)

        guard let values = result.array else {
            throw ParseError.InvalidParameters
        }

        let joinedDescription = try values.map { try $0.innerDescription() }.joined()

        return JSON(joinedDescription)
    }

}
