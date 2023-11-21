//
//  TicketsService.swift
//  Star21Mobile
//
//  Created by Jason Tse on 8/11/2023.
//

import Combine
import Foundation

protocol TicketsServiceProtocol {

    func fetchUser  () async

    func fetchRequests (searchText: String?, statuses: [RequestStatus]?) async

    func saveRequest  (_ request: any RequestEntity) async

    func fetchForms () async

    func fetchRequestDetail () async
}

struct TicketsService: TicketsServiceProtocol {

    let appState: AppState

    let webRepository: ZendeskWebRepositoryProtocol

    func fetchUser() async {
        do {
            let cancelBag = CancelBag()

            appState.session.setIsWaiting(cancelBag: cancelBag)
            guard var session = appState.session.value else {
                throw ValueIsMissingError()
            }
            let user = try await webRepository.getSelf(session)
            session.info = user

            appState.session = .withData(session)
        } catch {
            appState.session = .withError(error)
        }
    }

    func fetchRequests(searchText: String?, statuses: [RequestStatus]?) async {
        do {
            let cancelBag = CancelBag()

            appState.requests.setIsWaiting(cancelBag: cancelBag)
            guard let session = appState.session.value else {
                throw ValueIsMissingError()
            }
            let fields = try await webRepository.getTicketFields(session)
            let forms = try await webRepository.getTicketForms(session, fields: fields)
            let requests: [OnlineRequestEntity] = try await {
                if searchText != nil || statuses != nil {
                    return try await webRepository.searchRequests(session, forms: forms, fields: fields, query: searchText, statuses: statuses?.map { $0.rawValue })
                } else {
                    return try await webRepository.getRequests(session, forms: forms, fields: fields)
                }
            }()

            appState.requests = .withData(requests)
        } catch {
            appState.requests = .withError(error)
        }
    }

    func saveRequest(_ request: any RequestEntity) async {
        do {
            appState.activeRequest = .withData(request)

            let cancelBag = CancelBag()

            appState.activeRequest.setIsWaiting(cancelBag: cancelBag)
            guard let session = appState.session.value else {
                throw ValueIsMissingError()
            }

            let submitted: OnlineRequestEntity

            let fields = try await webRepository.getTicketFields(session)

            switch request {
            case let request as DraftRequestEntity:
                submitted = try await webRepository.postRequest(session, request: request, fields: fields)
            case let request as OnlineRequestEntity:
                throw ValueIsMissingError()
            default:
                throw ValueIsMissingError()
            }

            appState.activeRequest = .withData(submitted)
        } catch {
            appState.requests = .withError(error)
        }
        await self.fetchRequests(searchText: nil, statuses: nil)
    }

    func fetchForms() async {
            do {
                let cancelBag = CancelBag()

                appState.ticketForms.setIsWaiting(cancelBag: cancelBag)
                guard var session = appState.session.value else {
                    throw ValueIsMissingError()
                }
                let fields = try await webRepository.getTicketFields(session)
                let forms = try await webRepository.getTicketForms(session, fields: fields)
                appState.ticketForms = .withData(forms)
//            } catch DecodingError.typeMismatch(let type, let context) {
//                print("Type '\(type)' mismatch:", context.debugDescription)
//                print("codingPath:", context.codingPath)
            } catch {
                appState.ticketForms = .withError(error)
            }
    }

    func fetchRequestDetail () async {
        do {
            let cancelBag = CancelBag()

            guard let active = appState.activeRequest.value as? OnlineRequestEntity else {
                throw ValueIsMissingError()
            }
            appState.activeRequest.setIsWaiting(cancelBag: cancelBag)

            guard let session = appState.session.value else {
                throw ValueIsMissingError()
            }

            let comments = try await webRepository.getTicketComments(session, request: active)
            appState.activeRequest = .withData(active.withComments(comments))
        } catch {
            appState.activeRequest = .withError(error)
        }
    }
}
