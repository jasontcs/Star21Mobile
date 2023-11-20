//
//  Form.swift
//  Star21Mobile
//
//  Created by Jason Tse on 13/11/2023.
//

import Foundation

struct GetTicketFormsResponse: PagingResponseModel {
    let ticketForms: [TicketForm]
    let nextPage: String?
    let previousPage: String?
    let count: Int

    enum CodingKeys: String, CodingKey {
        case ticketForms = "ticket_forms"
        case nextPage = "next_page"
        case previousPage = "previous_page"
        case count
    }
}

struct TicketForm: IdentifiableModel {
    let url: String
    let name, displayName: String
    let id: Int
    let rawName, rawDisplayName: String
    let endUserVisible: Bool
    let position: Int
    let ticketFieldIDS: [Int]
    let active, ticketFormDefault: Bool
    let createdAt, updatedAt: Date
    let inAllBrands: Bool
    let restrictedBrandIDS: [Int]
    let endUserConditions: [EndUserCondition]

    enum CodingKeys: String, CodingKey {
        case url, name
        case displayName = "display_name"
        case id
        case rawName = "raw_name"
        case rawDisplayName = "raw_display_name"
        case endUserVisible = "end_user_visible"
        case position
        case ticketFieldIDS = "ticket_field_ids"
        case active
        case ticketFormDefault = "default"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case inAllBrands = "in_all_brands"
        case restrictedBrandIDS = "restricted_brand_ids"
        case endUserConditions = "end_user_conditions"
    }
}

struct EndUserCondition: Model {
    let parentFieldID: Int
    let parentFieldType: ParentFieldType
    let value: Value
    let childFields: [ChildField]

    enum CodingKeys: String, CodingKey {
        case parentFieldID = "parent_field_id"
        case parentFieldType = "parent_field_type"
        case value
        case childFields = "child_fields"
    }
}

struct ChildField: IdentifiableModel {
    let id: Int
    let isRequired: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case isRequired = "is_required"
    }
}

enum ParentFieldType: String, Codable {
    case checkbox = "checkbox"
}
