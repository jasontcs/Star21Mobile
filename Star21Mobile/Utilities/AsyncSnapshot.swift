//
//  AsyncSnapshot.swift
//  Star21Mobile
//
//  Created by Jason Tse on 9/11/2023.
//

import SwiftUI
import Combine

enum AsyncSnapshot<T> {

    case nothing
    case waiting(last: T?, cancelBag: CancelBag)
    case withData(T)
    case withError(Error)

    var value: T? {
        switch self {
        case let .withData(value): return value
        case let .waiting(last, _): return last
        default: return nil
        }
    }
    var error: Error? {
        switch self {
        case let .withError(error): return error
        default: return nil
        }
    }
}

extension AsyncSnapshot {

    mutating func setIsWaiting(cancelBag: CancelBag) {
        self = .waiting(last: value, cancelBag: cancelBag)
    }

    mutating func cancelLoading() {
        switch self {
        case let .waiting(last, cancelBag):
            cancelBag.cancel()
            if let last {
                self = .withData(last)
            } else {
                let error = NSError(
                    domain: NSCocoaErrorDomain, code: NSUserCancelledError,
                    userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Cancelled by user",
                                                                            comment: "")])
                self = .withError(error)
            }
        default: break
        }
    }

    func map<V>(_ transform: (T) throws -> V) -> AsyncSnapshot<V> {
        do {
            switch self {
            case .nothing: return .nothing
            case let .withError(error): return .withError(error)
            case let .waiting(value, cancelBag):
                return .waiting(last: try value.map { try transform($0) },
                                cancelBag: cancelBag)
            case let .withData(value):
                return .withData(try transform(value))
            }
        } catch {
            return .withError(error)
        }
    }
}

protocol SomeOptional {
    associatedtype Wrapped
    func unwrap() throws -> Wrapped
}

struct ValueIsMissingError: Error {
    var localizedDescription: String {
        NSLocalizedString("Data is missing", comment: "")
    }
}

struct InputError: Error {
    var localizedDescription: String {
        NSLocalizedString("Input error", comment: "")
    }
}

extension Optional: SomeOptional {
    func unwrap() throws -> Wrapped {
        switch self {
        case let .some(value): return value
        case .none: throw ValueIsMissingError()
        }
    }
}

extension AsyncSnapshot where T: SomeOptional {
    func unwrap() -> AsyncSnapshot<T.Wrapped> {
        map { try $0.unwrap() }
    }
}

extension AsyncSnapshot: Equatable where T: Equatable {
    static func == (lhs: AsyncSnapshot<T>, rhs: AsyncSnapshot<T>) -> Bool {
        switch (lhs, rhs) {
        case (.nothing, .nothing): return true
        case let (.waiting(lhsV, _), .waiting(rhsV, _)): return lhsV == rhsV
        case let (.withData(lhsV), .withData(rhsV)): return lhsV == rhsV
        case let (.withError(lhsE), .withError(rhsE)):
            return lhsE.localizedDescription == rhsE.localizedDescription
        default: return false
        }
    }
}
