//
//  NewTicketViewModel.swift
//  Star21Mobile
//
//  Created by Jason Tse on 17/11/2023.
//

import SwiftUI
import Combine
import Factory

extension NewTicketView {

    @MainActor
    final class ViewModel: ObservableObject {

        @Injected(\.appState) private var appState
        @Injected(\.ticketsService) private var ticketsService
        @Injected(\.appConfig) private var appConfig

        @Published var user: AsyncSnapshot<UserEntity> = .nothing
        @Published var forms: AsyncSnapshot<[TicketFormEntity]> = .nothing
        @Published var selectedForm: TicketFormEntity?
        @Published var formValues: [CustomFieldValueEntity] = []
        @Published var hiddenFields: [TicketFieldEntity] = []
        @Published var submittedRequest: OnlineRequestEntity?
        @Published var isSimCardActivationFormSelected = false
        @Published var attachments: [UploadAttachmentEntity] = []
        @Published var formBusy: Bool = false

        private var cancellables = Set<AnyCancellable>()

        init() {
            print("init")
            appState.$session
                .listen(in: &cancellables) { session in
                    self.user = session.map { $0.info }.unwrap()
                }
            //            appState.$activeRequest
            //                .removeDuplicates { prev, curr in
            //                    prev.value?.subject == curr.value?.subject
            //                }
            //                .listen(in: &cancellables) { request in
            //                    self.message = request.value?.subject ?? ""
            //                }
            appState.$ticketForms
                .listen(in: &cancellables) { forms in
                    self.forms = forms
                    self.selectedForm = self.selectedForm ?? forms.value?.first
                    self.selectedForm = forms.value?.first { $0.id == self.appConfig.simCardActivationFormId }
                }
            $selectedForm
                .listen(in: &cancellables) { form in
                    self.resetForm()
                    self.isSimCardActivationFormSelected = form == self.forms.value?.first { $0.id == self.appConfig.simCardActivationFormId }
                }
            $formValues
                .listen(in: &cancellables) { values in
                    self.hiddenFields = (self.selectedForm?.conditions ?? [])
                        .reduce([TicketFieldEntity]()) { prev, curr in
                            if values.first(where: { $0.field == curr.parent })?.value != curr.value {
                                return prev + curr.children
                            }
                            return prev
                        }
                }
            appState.$uploadAttachments
                .listen(in: &cancellables) { attachments in
                    self.attachments = attachments
                }
        }

        func fetchTickets() async {
            await ticketsService.fetchRequests(searchText: nil, statuses: nil)
        }

        func fetchUser() async {
            await ticketsService.fetchUser()
        }

        func fetchForms() async {
            await ticketsService.fetchForms()
        }

        func submitRequest() async {

            var customValues = [CustomFieldValueEntity]()

            var subject: String?
            var description: String?

            for value in formValues {
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
                ticketForm: selectedForm,
                customFields: customValues,
                priority: .normal,
                uploads: attachments
            )

            if isSimCardActivationFormSelected {
                await ticketsService.saveSimActivationRequest(draft)
            } else {
                await ticketsService.saveRequest(draft)
            }
            submittedRequest = appState.activeRequest.value as? OnlineRequestEntity
        }

        func simBarcodeOnScanned(_ code: Int) {
            if let index = formValues
                .firstIndex(where: { $0.field.title.contains("Barcode") }) {
                    formValues[index] = .init(field: formValues[index].field, value: .double(Double(code)))
                }
        }

        private func resetForm() {
            formValues = selectedForm?.fields.map { .init(field: $0, value: nil) } ?? []
        }

        func uploadImage(_ image: UIImage) async {
            await ticketsService.uploadAttachment(.init(data: image.pngData()!, status: .offline, fileName: Date().ISO8601Format() + ".png"))
        }

        func removeAttachment(_ attachment: UploadAttachmentEntity) {
            appState.uploadAttachments.removeAll { $0.fileName == attachment.fileName }
        }
    }

    struct FieldData: Hashable, Codable {
        var visible: Bool
        var value: Value?
    }

    enum PagingPath: Hashable {
        case question(TicketFieldEntity)
        case submit
    }
}
