//
//  DataType.swift
//  Star21Mobile
//
//  Created by Jason Tse on 16/11/2023.
//

import Foundation

enum Value: Codable, Hashable {
    case bool(Bool)
    case double(Double)
    case string(String)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let val = try? container.decode(Bool.self) {
            self = .bool(val)
            return
        }
        if let val = try? container.decode(Double.self) {
            self = .double(val)
            return
        }
        if let val = try? container.decode(String.self) {
            self = .string(val)
            return
        }
        throw DecodingError.typeMismatch(
            Value.self,
            DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "Wrong type for Value"
            )
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .bool(let val):
            try container.encode(val)
        case .double(let val):
            try container.encode(val)
        case .string(let val):
            try container.encode(val)
        }
    }

    static func from(_ value: Any) throws -> Value {
        let decoder = JSONDecoder()

        let data = try JSONSerialization.data(withJSONObject: value, options: .fragmentsAllowed)
        return try decoder.decode(Value.self, from: data)
    }

    func raw() -> Any {
        switch self {
        case .bool(let value):
            return value
        case .double(let value):
            return value
        case .string(let value):
            return value
        }
    }
}

protocol OptionalProtocol {
    func wrappedType() -> Any.Type
}

extension Optional: OptionalProtocol {
    func wrappedType() -> Any.Type {
        return Wrapped.self
    }
}

extension String {
func isValidEmail() -> Bool {
    // here, `try!` will always succeed because the pattern is valid
    guard let regex = try? NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive) else { return false }
    return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
   }
}
