//
//  TicketsService.swift
//  Star21Mobile
//
//  Created by Jason Tse on 8/11/2023.
//

import Combine
import Foundation
import Factory
import OSLog

protocol TicketsServiceProtocol {

    func fetchUser() async

    func fetchRequests(searchText: String?, statuses: [RequestStatus]?) async

    func uploadAttachment(_ attachment: UploadAttachmentEntity) async

    func saveRequest(_ request: any RequestEntity) async

    func saveAppDisplayForm (_ request: DraftRequestEntity) async

    func fetchForms() async

    func fetchRequestDetail() async

    func fetchRequestDetail(_ id: Int) async

    func selectForm(_ form: TicketFormEntity?)

    func updateFieldValue(field: TicketFieldEntity, value: Value?)

    func submitRequest() async

    func removeAttachment(_ attachment: UploadAttachmentEntity)

    func removeAnswer(_ field: TicketFieldEntity) -> CustomFieldValueEntity?
}

struct TicketsService: TicketsServiceProtocol {

    let appState: AppState

    let webRepository: ZendeskWebRepositoryProtocol

    let userInfoRepository: UserInfoRepositoryProtocol

    @Injected(\.appConfig) private var appConfig

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
                if searchText?.isEmpty == false || statuses != nil {
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

    private func simActivationRequestToMobileServiceRequest(_ request: DraftRequestEntity) async throws -> DraftRequestEntity {
        guard request.ticketForm?.id == appConfig.displayFormId else {
            throw InputError()
        }

        guard let form = appState.ticketForms.value?.first(where: { $0.id == appConfig.submitRequestFormId })  else {
            throw ValueIsMissingError()
        }

        guard let session = appState.session.value else {
            throw ValueIsMissingError()
        }

        let (location, address) = await userInfoRepository.getLocation()

        let ll = location != nil ? "\(location!.latitude),\(location!.longitude)" : nil

        let metadata = [
            ("Device Location", ll),
//            ("Address", address),
            ("Device", userInfoRepository.deviceModel),
            ("OS Version", userInfoRepository.osVersion),
            ("App Version", userInfoRepository.appVersion)
        ].map { pair in
            "\(pair.0): \(pair.1 ?? "-")"
        }
        .joined(separator: "<br>")

        let description = request.customFields
            .compactMap { field in
                guard let value = field.displayValue else { return nil }

                return "<strong>\(field.field.title)</strong><br>\(value)<br>&nbsp;<br>"
            }
            .joined(separator: "")
            .appending("<pre><code>\(metadata)</code></pre>")

        return .init(
            subject: "Mobile App Request",
            description: description,
            ticketForm: form,
            customFields: [],
            priority: .normal,
            uploads: request.uploads
        )
    }

    func uploadAttachment(_ attachment: UploadAttachmentEntity) async {
        do {
            guard case .offline = attachment.status else {
                return
            }

            appState.formState?.attachments.append(.init(data: attachment.data, status: .uploading, fileName: attachment.fileName))

            guard let session = appState.session.value else {
                throw ValueIsMissingError()
            }

            let online = try await webRepository.postAttachment(session, attachment: attachment)

            appState.formState?.attachments.removeLast()
            appState.formState?.attachments.append(online)

        } catch {
            appState.formState?.attachments.removeLast()
            appState.formState?.attachments.append(.init(data: attachment.data, status: .offline, fileName: attachment.fileName))
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

    func saveAppDisplayForm(_ request: DraftRequestEntity) async {
        do {
            let convertedRequest = try await simActivationRequestToMobileServiceRequest(request)

            await saveRequest(convertedRequest)

        } catch {
            appState.requests = .withError(error)
        }
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
                print(error)
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

    func fetchRequestDetail(_ id: Int) async {
        do {
            let cancelBag = CancelBag()

            appState.activeRequest.setIsWaiting(cancelBag: cancelBag)
            guard let session = appState.session.value else {
                throw ValueIsMissingError()
            }
            let fields = try await webRepository.getTicketFields(session)
            let forms = try await webRepository.getTicketForms(session, fields: fields)
            let request: OnlineRequestEntity = try await webRepository.getRequest(session, forms: forms, fields: fields, id: id)

            guard let session = appState.session.value else {
                throw ValueIsMissingError()
            }

            let comments = try await webRepository.getTicketComments(session, request: request)
            appState.activeRequest = .withData(request.withComments(comments))
        } catch {
            appState.activeRequest = .withError(error)
        }
    }

    func selectForm (_ form: TicketFormEntity?) {
        guard let forms = appState.ticketForms.value, !forms.isEmpty else {
            return
        }
        let selected: TicketFormEntity = form ?? appState.formState?.form ?? forms.first!
        appState.formState = .init(form: selected, isAppDisplayForm: selected.id == appConfig.displayFormId)
    }

    func updateFieldValue (field: TicketFieldEntity, value: Value?) {
        let existIndex = appState.formState?.values.firstIndex { $0.field == field }
        if let existIndex {
            if let value {
                appState.formState?.values[existIndex] = .init(field: field, value: value)
            } else {
                appState.formState?.values.remove(at: existIndex)
            }
        } else if let value {
            appState.formState?.values.append(.init(field: field, value: value))
        }
        let values = appState.formState?.values
    }

    func submitRequest() async {

        guard let formState = appState.formState else {
            return
        }

        var customValues = [CustomFieldValueEntity]()

        var subject: String?
        var description: String?

        for value in formState.values {
            switch value.field.type {
            case .subject:
                subject = value.value?.raw() as? String
            case .description:
                description = value.value?.raw() as? String
            default:
                customValues.append(value)
            }
        }

        let draft = DraftRequestEntity(
            subject: subject ?? "",
            description: description ?? "",
            ticketForm: formState.form,
            customFields: customValues,
            priority: .normal,
            uploads: formState.attachments
        )

        if appState.formState?.isAppDisplayForm ?? false {
            await self.saveAppDisplayForm(draft)
        } else {
            await self.saveRequest(draft)
        }
        if let submittedRequest = appState.activeRequest.value as? OnlineRequestEntity {
            appState.formState?.status = .submitted(submittedRequest)
        }
    }

    func removeAttachment(_ attachment: UploadAttachmentEntity) {
        appState.formState?.attachments.removeAll { $0.fileName == attachment.fileName }
    }

    func removeAnswer(_ field: TicketFieldEntity) -> CustomFieldValueEntity? {
        if let index = appState.formState?.values.firstIndex(where: { $0.field == field }) {
            return appState.formState?.values.remove(at: index)
        }
        return nil
    }
}
