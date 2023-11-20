//
//  Entities.swift
//  Star21Mobile
//
//  Created by Jason Tse on 10/11/2023.
//

import Foundation

struct SessionEntity: Hashable {
    var uid: Int?
    var token: String?
    var info: UserEntity?
}

enum Priority: String, CaseIterable, Codable {
    case urgent, high, normal, low
}

protocol RequestEntity: Hashable {
    var subject: String { get }
    var description: String { get }
    var ticketForm: TicketFormEntity? { get }
    var customFields: [CustomFieldValueEntity] { get }
    var priority: Priority { get }
}

struct CustomFieldValueEntity: Hashable, Identifiable {
    let field: TicketFieldEntity
    let value: Value?

    var id: Int { field.id }
}

struct DraftRequestEntity: RequestEntity {
    let subject: String
    let description: String
    let ticketForm: TicketFormEntity?
    let customFields: [CustomFieldValueEntity]
    let priority: Priority
}

struct OnlineRequestEntity: RequestEntity, Identifiable {
    let id: Int
    let subject: String
    let description: String
    let status: RequestStatus
    let ticketForm: TicketFormEntity?
    let customFields: [CustomFieldValueEntity]
    let priority: Priority
    let createdAt: Date
    let updatedAt: Date
    let comments: [CommentEntity]?
}

struct CommentEntity: Hashable, Identifiable {
    let id: Int
    let body: String
    let author: String
    let organization: String
    let isAgent: Bool
    let createdAt: Date
}

extension OnlineRequestEntity {
    func withComments(_ comments: [CommentEntity]) -> OnlineRequestEntity {
        .init(
            id: id,
            subject: subject,
            description: description,
            status: status,
            ticketForm: ticketForm,
            customFields: customFields,
            priority: priority,
            createdAt: createdAt,
            updatedAt: updatedAt,
            comments: comments
        )
    }
}
enum RequestStatus: String, CaseIterable {
    case new, open, pending, hold, solved, closed
}

struct UserEntity: Hashable, Identifiable {
    let id: Int
    let name: String
    let email: String
    let tags: [String]
}

struct TicketFormEntity: Hashable, Identifiable {
    let id: Int
    let name: String
    let fields: [TicketFieldEntity]
    let conditions: [TicketFormCondition]
}

struct TicketFieldEntity: Hashable, Identifiable {
    let id: Int
    let title: String
    let description: String
    let type: TicketFieldType
    let required: Bool
    let options: [TicketFieldOption]?
    let regexForValidation: String?
}

enum TicketFieldType: String, CaseIterableDefaultsLast {

    case subject
    case description
    case assignee
    case status
    case priority
    case tickettype
    case group
    case customStatus = "custom_status"

    case text
    case textarea
    case checkbox
    case date
    case integer
    case decimal
    case regexp
    case partialcreditcard
    case multiselect
    case tagger
    case lookup
}

struct TicketFieldOption: Hashable, Identifiable {
    let id: Int
    let name: String
    let value: String
    let isDefault: Bool
}

struct TicketFormCondition: Hashable {
    let parent: TicketFieldEntity
    let value: Value
    let children: [TicketFieldEntity]
}
