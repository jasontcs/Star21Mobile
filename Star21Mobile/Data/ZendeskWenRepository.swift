//
//  ZendeskWenRepository.swift
//  Star21Mobile
//
//  Created by Jason Tse on 6/11/2023.
//

import Foundation

protocol ZendeskWebRepositoryProtocol: WebRepository {
    func getSelf(_ identity: SessionEntity) async throws -> UserEntity
    func getRequests(_ identity: SessionEntity, forms: [TicketFormEntity], fields: [TicketFieldEntity]) async throws -> [OnlineRequestEntity]
    func searchRequests(_ identity: SessionEntity, forms: [TicketFormEntity], fields: [TicketFieldEntity], query: String?, statuses: [String]?) async throws -> [OnlineRequestEntity]
    func postRequest(_ identity: SessionEntity, request: DraftRequestEntity, fields: [TicketFieldEntity]) async throws -> OnlineRequestEntity
    func getTicketForms(_ identity: SessionEntity, fields: [TicketFieldEntity]) async throws -> [TicketFormEntity]
    func getTicketFields(_ identity: SessionEntity) async throws -> [TicketFieldEntity]
    func getTicketComments(_ identity: SessionEntity, request: OnlineRequestEntity) async throws -> [CommentEntity]
}

struct ZendeskWebRepository: ZendeskWebRepositoryProtocol {

    let session: URLSession
    let baseURL: String

    func getSelf(_ identity: SessionEntity) async throws -> UserEntity {

        guard identity.token != nil else {
            throw ZendeskAPIError.noToken
        }
        let response: GetUserResponse = try await call(
            endpoint: ZendeskAuthenticatedAPICall(
                path: "users/\(String(identity.uid!))",
                method: .GET,
                token: identity.token!
            )
        )
        return response.user.toEntity()
    }

    func getRequests(_ identity: SessionEntity, forms: [TicketFormEntity], fields: [TicketFieldEntity]) async throws -> [OnlineRequestEntity] {

        guard identity.token != nil && identity.uid != nil else {
            throw ZendeskAPIError.noToken
        }
        let response: GetRequestsResponse = try await call(
            endpoint: ZendeskAuthenticatedAPICall(
                path: "requests",
                method: .GET,
                token: identity.token!,
                onBehalfOf: identity.uid!
            )
        )
        return try response.requests.map { try $0.toEntity(forms: forms, fields: fields) }
    }

    func searchRequests(_ identity: SessionEntity, forms: [TicketFormEntity], fields: [TicketFieldEntity], query: String?, statuses: [String]?) async throws -> [OnlineRequestEntity] {

        guard identity.token != nil && identity.uid != nil else {
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
                token: identity.token!,
                params: params,
                onBehalfOf: identity.uid!
            )
        )
        return try response.requests.map { try $0.toEntity(forms: forms, fields: fields) }
    }

    func postRequest(_ identity: SessionEntity, request: DraftRequestEntity, fields: [TicketFieldEntity]) async throws -> OnlineRequestEntity {
        guard identity.token != nil && identity.uid != nil else {
            throw ZendeskAPIError.noToken
        }
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let body = try encoder.encode(PostRequestRequest(request: .from(request)))
        let response: PostRequestResponse = try await call(
            endpoint: ZendeskAuthenticatedAPICall(
                path: "requests",
                method: .POST,
                token: identity.token!,
                body: body,
                onBehalfOf: identity.uid!
            )
        )
        return try response.request.toEntity(forms: [request.ticketForm].compactMap { $0 }, fields: fields)
    }

    func getTicketForms(_ identity: SessionEntity, fields: [TicketFieldEntity]) async throws -> [TicketFormEntity] {

        guard identity.token != nil && identity.uid != nil else {
            throw ZendeskAPIError.noToken
        }
        let response: GetTicketFormsResponse = try await call(
            endpoint: ZendeskAuthenticatedAPICall(
                path: "ticket_forms",
                method: .GET,
                token: identity.token!,
                params: ["active": "true"],
                onBehalfOf: identity.uid!
            )
        )

        return response.ticketForms.map { form in
            form.toEntity(fields: fields)
        }
    }

    func getTicketFields(_ identity: SessionEntity) async throws -> [TicketFieldEntity] {

        guard identity.token != nil && identity.uid != nil else {
            throw ZendeskAPIError.noToken
        }
        let response: GetTicketFieldsResponse = try await call(
            endpoint: ZendeskAuthenticatedAPICall(
                path: "ticket_fields",
                method: .GET,
                token: identity.token!,
                onBehalfOf: identity.uid!
            )
        )
        return response.ticketFields.map { $0.toEntity() }
    }

    func getTicketComments(_ identity: SessionEntity, request: OnlineRequestEntity) async throws -> [CommentEntity] {

        guard identity.token != nil && identity.uid != nil else {
            throw ZendeskAPIError.noToken
        }

        guard request.comments == nil else {
            throw ZendeskAPIError.argument
        }

        let response: GetTicketCommentsResponse = try await call(
            endpoint: ZendeskAuthenticatedAPICall(
                path: "requests/\(request.id)/comments",
                method: .GET,
                token: identity.token!,
                onBehalfOf: identity.uid!
            )
        )
        return response.comments.map { $0.toEntity(
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

    init(path: String, method: HTTPMethod, token: String, body: Data? = nil, params: [String: String]? = nil, onBehalfOf: Int? = nil) {
        self.path = path
        self.method = method
        var headers = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        if onBehalfOf != nil {
            headers["X-On-Behalf-Of"] = String(onBehalfOf!)
        }
        self.headers = headers
        self.body = body
        self.params = params?.map { URLQueryItem(name: $0.key, value: $0.value) }
    }
}
