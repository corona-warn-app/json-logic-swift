//
// json-functions-swift
//
//
// Copyright (c) 2022 SAP SE or an SAP affiliate company
//

import Foundation

extension JSON {

    func innerDescription() throws -> String {
        switch self {
        case .Null:
            return ""
        case .Array:
            return ""
        case .Dictionary:
            return ""
        case .Int(let int64):
            return "\(int64)"
        case .Double(let double):
            return "\(double)"
        case .String(let string):
            return string
        case .Date:
            return ""
        case .Bool(let bool):
            return bool ? "true" : "false"
        case .Error(let jSON2Error):
            throw jSON2Error
        }
    }

}
