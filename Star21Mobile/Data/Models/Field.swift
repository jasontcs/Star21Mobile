//
//  Field.swift
//  Star21Mobile
//
//  Created by Jason Tse on 13/11/2023.
//

import Foundation

struct GetTicketFieldsResponse: PagingResponseModel {
    let ticketFields: [TicketField]
    let nextPage: String?
    let previousPage: String?
    let count: Int

    enum CodingKeys: String, CodingKey {
        case ticketFields = "ticket_fields"
        case nextPage = "next_page"
        case previousPage = "previous_page"
        case count
    }
}

struct TicketField: IdentifiableModel {
    let url: String
    let id: Int
    let type: TicketFieldType
    let title, rawTitle, description, rawDescription: String
    let position: Int
    let active, required, collapsedForAgents: Bool
    let regexpForValidation: String?
    let titleInPortal, rawTitleInPortal: String
    let visibleInPortal, editableInPortal, requiredInPortal: Bool
    let tag: String?
    let createdAt, updatedAt: Date
    let removable: Bool
    let agentDescription: String?
    let systemFieldOptions: [SystemFieldOption]?
    let subTypeID: Int?
    let customFieldOptions: [CustomFieldOption]?
    let customStatuses: [CustomStatus]?

    enum CodingKeys: String, CodingKey {
        case url, id, type, title
        case rawTitle = "raw_title"
        case description
        case rawDescription = "raw_description"
        case position, active
        case required = "required"
        case collapsedForAgents = "collapsed_for_agents"
        case regexpForValidation = "regexp_for_validation"
        case titleInPortal = "title_in_portal"
        case rawTitleInPortal = "raw_title_in_portal"
        case visibleInPortal = "visible_in_portal"
        case editableInPortal = "editable_in_portal"
        case requiredInPortal = "required_in_portal"
        case tag
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case removable
        case agentDescription = "agent_description"
        case systemFieldOptions = "system_field_options"
        case subTypeID = "sub_type_id"
        case customFieldOptions = "custom_field_options"
        case customStatuses = "custom_statuses"
    }
}

struct CustomFieldOption: IdentifiableModel {
    let id: Int
    let name, rawName, value: String
    let isDefault: Bool

    enum CodingKeys: String, CodingKey {
        case id, name
        case rawName = "raw_name"
        case value
        case isDefault = "default"
    }
}

struct CustomStatus: IdentifiableModel {
    let url: String
    let id: Int
    let statusCategory, agentLabel, endUserLabel, description: String
    let endUserDescription: String
    let active, customStatusDefault: Bool
    let createdAt, updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case url, id
        case statusCategory = "status_category"
        case agentLabel = "agent_label"
        case endUserLabel = "end_user_label"
        case description
        case endUserDescription = "end_user_description"
        case active
        case customStatusDefault = "default"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct SystemFieldOption: Model {
    let name, value: String
}

struct CustomFieldValue: IdentifiableModel {
    let id: Int
    let value: Value?
}
