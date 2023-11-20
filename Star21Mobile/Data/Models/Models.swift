//
//  Models.swift
//  Star21Mobile
//
//  Created by Jason Tse on 4/11/2023.
//

import Foundation

typealias Model = Codable & Hashable

typealias ResponseModel = Decodable & Hashable

typealias RequestModel = Encodable & Hashable

protocol PagingResponseModel: ResponseModel {
    var nextPage: String? { get }
    var previousPage: String? { get }
    var count: Int { get }

    typealias RawValue = PagingResponseKeys
}

enum PagingResponseKeys: String, CodingKey {
    case nextPage = "next_page"
    case previousPage = "previous_page"
    case count
}

typealias IdentifiableModel = Model & Identifiable

protocol CaseIterableDefaultsLast: Codable & CaseIterable & RawRepresentable & Hashable
where RawValue: Codable, AllCases: BidirectionalCollection { }

extension CaseIterableDefaultsLast {
    init(from decoder: Decoder) throws {
        self = try Self(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? Self.allCases.last!
    }
}
