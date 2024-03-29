//
//  ZendeskWebRepository.swift
//  Star21Mobile
//
//  Created by Jason Tse on 6/11/2023.
//

import Foundation
import Factory

protocol ZendeskWebRepositoryProtocol: WebRepository {
    func getSelf(_ identity: SessionEntity) async throws -> UserEntity
    func getRequests(_ identity: SessionEntity, forms: [TicketFormEntity], fields: [TicketFieldEntity]) async throws -> [OnlineRequestEntity]
    func getRequest(_ identity: SessionEntity, forms: [TicketFormEntity], fields: [TicketFieldEntity], id: Int) async throws -> OnlineRequestEntity
    func searchRequests(_ identity: SessionEntity, forms: [TicketFormEntity], fields: [TicketFieldEntity], query: String?, statuses: [String]?) async throws -> [OnlineRequestEntity]
    func postRequest(_ identity: SessionEntity, request: DraftRequestEntity, fields: [TicketFieldEntity]) async throws -> OnlineRequestEntity
    func getTicketForms(_ identity: SessionEntity, fields: [TicketFieldEntity]) async throws -> [TicketFormEntity]
    func getTicketFields(_ identity: SessionEntity) async throws -> [TicketFieldEntity]
    func getTicketComments(_ identity: SessionEntity, request: OnlineRequestEntity) async throws -> [CommentEntity]
    func postAttachment(_ identity: SessionEntity, attachment: UploadAttachmentEntity) async throws -> UploadAttachmentEntity
}

struct ZendeskWebRepository: ZendeskWebRepositoryProtocol {

    let session: URLSession
    let baseURL: String

    let logging = Container.shared.appConfig().networkLogging

    func getSelf(_ identity: SessionEntity) async throws -> UserEntity {

        guard let token = identity.token, let uid = identity.uid else {
            throw ZendeskAPIError.noToken
        }
        let response: GetUserResponse = try await call(
            endpoint: ZendeskAuthenticatedAPICall(
                path: "users/\(String(uid))",
                method: .GET,
                token: token
            )
        )
        return response.user.toEntity()
    }

    func getRequests(_ identity: SessionEntity, forms: [TicketFormEntity], fields: [TicketFieldEntity]) async throws -> [OnlineRequestEntity] {

        guard let token = identity.token, let uid = identity.uid else {
            throw ZendeskAPIError.noToken
        }
        let response: GetRequestsResponse = try await call(
            endpoint: ZendeskAuthenticatedAPICall(
                path: "requests",
                method: .GET,
                token: token,
                onBehalfOf: uid
            )
        )
        return try response.requests.map { try $0.toEntity(forms: forms, fields: fields) }
    }

    func getRequest(_ identity: SessionEntity, forms: [TicketFormEntity], fields: [TicketFieldEntity], id: Int) async throws -> OnlineRequestEntity {

        guard let token = identity.token, let uid = identity.uid else {
            throw ZendeskAPIError.noToken
        }
        let response: GetRequestResponse = try await call(
            endpoint: ZendeskAuthenticatedAPICall(
                path: "requests/\(String(id))",
                method: .GET,
                token: token,
                onBehalfOf: uid
            )
        )
        return try response.request.toEntity(forms: forms, fields: fields)
    }
    func searchRequests(_ identity: SessionEntity, forms: [TicketFormEntity], fields: [TicketFieldEntity], query: String?, statuses: [String]?) async throws -> [OnlineRequestEntity] {

        guard let token = identity.token, let uid = identity.uid else {
            throw ZendeskAPIError.noToken
        }

        let params: [String: String] = {

            var params = [String: String]()

            if let query {
                params["query"] = query
            }

            if let statuses {
                params["status"] = statuses.joined(separator: ",")
            }

            return params
        }()

        let response: GetRequestsResponse = try await call(
            endpoint: ZendeskAuthenticatedAPICall(
                path: "requests/search.json",
                method: .GET,
                token: token,
                params: params,
                onBehalfOf: uid
            )
        )
        return try response.requests.map { try $0.toEntity(forms: forms, fields: fields) }
    }

    func postRequest(_ identity: SessionEntity, request: DraftRequestEntity, fields: [TicketFieldEntity]) async throws -> OnlineRequestEntity {

        guard let token = identity.token, let uid = identity.uid else {
            throw ZendeskAPIError.noToken
        }

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let body = try encoder.encode(PostRequestRequest(request: .from(request)))
        let response: PostRequestResponse = try await call(
            endpoint: ZendeskAuthenticatedAPICall(
                path: "requests",
                method: .POST,
                token: token,
                body: body,
                onBehalfOf: uid
            )
        )
        return try response.request.toEntity(forms: [request.ticketForm].compactMap { $0 }, fields: fields)
    }

    func postAttachment(_ identity: SessionEntity, attachment: UploadAttachmentEntity) async throws -> UploadAttachmentEntity {

        guard let token = identity.token, let uid = identity.uid else {
            throw ZendeskAPIError.noToken
        }

        let params: [String: String] = [
            "filename": attachment.fileName
        ]

        let headers: [String: String] = [
            "Content-Type": "image/png"
        ]

        let response: PostUploadResponse = try await call(
            endpoint: ZendeskAuthenticatedAPICall(
                path: "uploads",
                method: .POST,
                token: token,
                body: attachment.data,
                params: params,
                onBehalfOf: uid,
                headers: headers
            )
        )
        return try response.upload.toEntity(original: attachment)
    }

    func getTicketForms(_ identity: SessionEntity, fields: [TicketFieldEntity]) async throws -> [TicketFormEntity] {

        guard let token = identity.token, let uid = identity.uid else {
            throw ZendeskAPIError.noToken
        }

        let response: GetTicketFormsResponse = try await call(
            endpoint: ZendeskAuthenticatedAPICall(
                path: "ticket_forms",
                method: .GET,
                token: token
//                params: ["active": "true"],
//                onBehalfOf: uid
            )
        )

        return try response.ticketForms.map { form in
            try form.toEntity(fields: fields)
        }
    }

    func getTicketFields(_ identity: SessionEntity) async throws -> [TicketFieldEntity] {

        guard let token = identity.token, let uid = identity.uid else {
            throw ZendeskAPIError.noToken
        }

        let response: GetTicketFieldsResponse = try await call(
            endpoint: ZendeskAuthenticatedAPICall(
                path: "ticket_fields",
                method: .GET,
                token: token
//                onBehalfOf: uid
            )
        )
        return response.ticketFields.map { $0.toEntity() }
    }

    func getTicketComments(_ identity: SessionEntity, request: OnlineRequestEntity) async throws -> [CommentEntity] {

        guard let token = identity.token, let uid = identity.uid else {
            throw ZendeskAPIError.noToken
        }

        guard request.comments == nil else {
            throw ZendeskAPIError.argument
        }

        let response: GetTicketCommentsResponse = try await call(
            endpoint: ZendeskAuthenticatedAPICall(
                path: "requests/\(request.id)/comments",
                method: .GET,
                token: token,
                onBehalfOf: uid
            )
        )
        return try response.comments.map { try $0.toEntity(
            users: response.users,
            organizations: response.organizations
        ) }
    }
}

enum ZendeskAPIError: Swift.Error {
    case noToken
    case decoding
    case argument
}

struct ZendeskAuthenticatedAPICall: APICall {
    let path: String
    let method: HTTPMethod
    let headers: [String: String]?
    let body: Data?
    let params: [URLQueryItem]?

    init(path: String, method: HTTPMethod, token: String, body: Data? = nil, params: [String: String]? = nil, onBehalfOf: Int? = nil, headers: [String: String]? = nil) {
        self.path = path
        self.method = method
        var finalHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        if let onBehalfOf {
            finalHeaders["X-On-Behalf-Of"] = String(onBehalfOf)
        }
        if let headers {
            finalHeaders = finalHeaders.merging(headers) { _, new in new }
        }
        self.headers = finalHeaders
        self.body = body
        self.params = params?.map { URLQueryItem(name: $0.key, value: $0.value) }
    }
}
