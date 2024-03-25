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

    var valueOptions: [TicketFieldOption]? {
        switch field.type {
        case .tagger:
            return field.options?.filter { $0.value == value?.raw() as? String }
        default:
            return nil
        }
    }

    var displayValue: String? {
        switch value {
        case .bool(let val):
            return val ? "YES" : "NO"
        case .double(let val):
            return val.removeZerosFromEnd()
        case .string(let val):
            switch field.type {
            case .tagger:
                return valueOptions?.first { $0.value == val }?.name
            case .multiselect:
                return val.split(separator: ",").compactMap { _ in valueOptions?.first { $0.value == val }?.name ?? nil }.joined(separator: ",")
            default:
                return val
            }
        case .none:
            return nil
        }

    }
}

struct DraftRequestEntity: RequestEntity {
    let subject: String
    let description: String
    let ticketForm: TicketFormEntity?
    let customFields: [CustomFieldValueEntity]
    let priority: Priority
    let uploads: [UploadAttachmentEntity]
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
    let attachments: [AttachmentEntity]
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
    let phone: String
    let tags: [String]
}

struct TicketFormEntity: Hashable, Identifiable {
    let id: Int
    let name: String
    let fields: [TicketFieldEntity]
    let conditions: [TicketFormCondition]
}

enum TicketFieldTag: String, CaseIterableDefaultsLast {
    case scanBarcode = "scan_barcode"
    case mobileForm = "mobile_form"
    case subject
    case description
    case attachments
}

struct TicketFieldEntity: Hashable, Identifiable {
    let id: Int
    let title: String
    let description: String
    let type: TicketFieldType
    let required: Bool
    let options: [TicketFieldOption]?
    let regexForValidation: String?
    let tags: [TicketFieldTag]?

    func withTag(_ tag: TicketFieldTag) -> Bool {
        tags?.contains(where: {
            $0 == tag
        }) ?? false
    }
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
    case text
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

enum AuthenticationState: Hashable {
    case emailPending
    case emailChallenge(token: String)
    case mobilePending(token: String)
    case mobileChallenge(token: String)
    case complete
}

struct NotificationEntity: Hashable, Identifiable {
    let id: Int
    let title: String
    let description: String
    let content: String?
    let avatarUrl: URL?
    let redirectUrl: URL?
    let createdAt: Date
    let updatedAt: Date
    let status: NotificationStatus
}

enum NotificationStatus: String, CaseIterableDefaultsLast {
    case read
    case unread
}

struct UploadAttachmentEntity: Hashable {
    let data: Data
    let status: UploadAttachmentStatus
    let fileName: String
}

enum UploadAttachmentStatus: Hashable {
    case offline
    case uploading
    case online(token: String)
}

struct AttachmentEntity: Hashable, Identifiable {
    let id: Int
    let type: AttachmentType
    let url: String
}

enum AttachmentType: Hashable {
    case image
}
