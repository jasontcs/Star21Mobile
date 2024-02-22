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

struct PostUploadResponse: Model {
    let upload: Upload
}

struct Upload: Model {
    let token: String
    let expiresAt: Date
    let attachments: [Attachment]
    let attachment: Attachment

    enum CodingKeys: String, CodingKey {
        case token
        case expiresAt = "expires_at"
        case attachments, attachment
    }
}

struct Attachment: IdentifiableModel {
    let url: String
    let id: Int
    let fileName: String
    let contentURL, mappedContentURL: String
    let contentType: String
    let size, width, height: Int
    let inline, deleted, malwareAccessOverride: Bool
    let malwareScanResult: String
    let thumbnails: [Attachment]?

    enum CodingKeys: String, CodingKey {
        case url, id
        case fileName = "file_name"
        case contentURL = "content_url"
        case mappedContentURL = "mapped_content_url"
        case contentType = "content_type"
        case size, width, height, inline, deleted
        case malwareAccessOverride = "malware_access_override"
        case malwareScanResult = "malware_scan_result"
        case thumbnails
    }
}
