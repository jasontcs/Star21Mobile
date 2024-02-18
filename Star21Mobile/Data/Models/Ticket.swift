//
//  Ticket.swift
//  Star21Mobile
//
//  Created by Jason Tse on 13/11/2023.
//

import Foundation

struct GetRequestsResponse: PagingResponseModel {
    let requests: [Request]
    let nextPage: String?
    let previousPage: String?
    let count: Int
}

struct GetRequestResponse: Model {
    let request: Request
}

struct Request: IdentifiableModel {
    let id: Int
    let subject: String
    let description: String
    let status: String
    let ticketFormId: Int?
    let customFields: [CustomFieldValue]
    let priority: Priority
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case subject
        case description
        case status
        case ticketFormId = "ticket_form_id"
        case customFields = "custom_fields"
        case priority
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct PostRequestRequest: RequestModel {
    let request: DraftRequest
}

struct DraftRequest: Model {
    let subject: String
    let customFields: [CustomFieldValue]
    let comment: DraftComment
    let collaborators: [String]
    let ticketFormId: Int?
    let priority: Priority
    enum CodingKeys: String, CodingKey {
        case subject
        case customFields = "custom_fields"
        case comment
        case collaborators
        case ticketFormId = "ticket_form_id"
        case priority
    }
}

struct DraftComment: Model {
    let body: String
    enum CodingKeys: String, CodingKey {
        case body = "html_body"
    }
}

struct PostRequestResponse: ResponseModel {
    let request: Request
}
