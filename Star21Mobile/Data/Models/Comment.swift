//
//  Comment.swift
//  Star21Mobile
//
//  Created by Jason Tse on 20/11/2023.
//

import Foundation

struct GetTicketCommentsResponse: PagingResponseModel {
    let comments: [Comment]
    let users: [CommentUser]
    let organizations: [CommentOrganization]
    let nextPage, previousPage: String?
    let count: Int

    enum CodingKeys: String, CodingKey {
        case comments, users, organizations
        case nextPage = "next_page"
        case previousPage = "previous_page"
        case count
    }
}

// MARK: - Comment
struct Comment: IdentifiableModel {
    let url: String?
    let id: Int
    let type: String
    let requestID: Int?
    let body: String
    let htmlBody, plainBody: String?
    let commentPublic: Bool
    let authorID: Int
    let attachments: [Attachment]
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case url, id, type
        case requestID = "request_id"
        case body
        case htmlBody = "html_body"
        case plainBody = "plain_body"
        case commentPublic = "public"
        case authorID = "author_id"
        case attachments
        case createdAt = "created_at"
    }
}

struct Attachment: IdentifiableModel {
    let contentType: String
    let contentURL: String
    let fileName: String
    let id, size: Int

    enum CodingKeys: String, CodingKey {
        case contentType = "content_type"
        case contentURL = "content_url"
        case fileName = "file_name"
        case id, size
    }
}

struct CommentOrganization: IdentifiableModel {
    let id: Int
    let name: String
}

struct CommentUser: IdentifiableModel {
    let id: Int
    let name: String
    let agent: Bool
    let organizationID: Int

    enum CodingKeys: String, CodingKey {
        case id, name, agent
        case organizationID = "organization_id"
    }
}
