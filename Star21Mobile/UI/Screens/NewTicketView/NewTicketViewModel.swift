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

        let mobileDisplayFormOnly = Container.shared.appConfig().mobileDisplayFormOnly
        let inPagingUX = Container.shared.appConfig().inPagingUX

        @Injected(\.appState) private var appState
        @Injected(\.ticketsService) private var ticketsService
        @Injected(\.appConfig) private var appConfig

        @Published var user: AsyncSnapshot<UserEntity> = .nothing
        @Published var forms: AsyncSnapshot<[TicketFormEntity]> = .nothing
//        @Published var selectedForm: TicketFormEntity?
//        @Published var formValues: [CustomFieldValueEntity] = []
//        @Published var hiddenFields: [TicketFieldEntity] = []
//        @Published var submittedRequest: OnlineRequestEntity?
//        @Published var isSimCardActivationFormSelected = false
//        @Published var attachments: [UploadAttachmentEntity] = []
//        @Published var formBusy: Bool = false
//        @Published private (set) var availableFields: [TicketFieldEntity] = []
        @Published var formState: FormState?

        private var cancellables = Set<AnyCancellable>()

        init() {
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
//                    self.selectedForm = self.selectedForm ?? forms.value?.first
//                    self.selectedForm = forms.value?.first { $0.id == self.appConfig.simCardActivationFormId }
                }
//            $selectedForm
//                .listen(in: &cancellables) { form in
//                    self.ticketsService.selectForm(form)
//                }
            appState.$formState
                .listen(in: &cancellables) { state in
                    self.formState = state
//                    self.selectedForm = state?.form
                }
//            $formValues
//                .listen(in: &cancellables) { values in
//                    self.hiddenFields = (self.selectedForm?.conditions ?? [])
//                        .reduce([TicketFieldEntity]()) { prev, curr in
//                            if values.first(where: { $0.field == curr.parent })?.value != curr.value {
//                                return prev + curr.children
//                            }
//                            return prev
//                        }
//                }
//            appState.$uploadAttachments
//                .listen(in: &cancellables) { attachments in
//                    self.attachments = attachments
//                }
//            $selectedForm
//                .combineLatest($isSimCardActivationFormSelected)
//                .listen(in: &cancellables) { selected, isSimCardActivationFormSelected in
//                    self.availableFields = selected?.fields
//                        .filter({
//                            if isSimCardActivationFormSelected {
//                                switch $0.type {
//                                case .subject: return false
//                                case .description: return false
//                                default: return true
//                                }
//                            }
//                            return true
//                        }) ?? []
//                }
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

//            var customValues = [CustomFieldValueEntity]()
//
//            var subject: String?
//            var description: String?
//
//            for value in appState.formState?.values ?? [] {
//                switch value.field.type {
//                case .subject:
//                    subject = value.value?.raw() as? String
//                case .description:
//                    description = value.value?.raw() as? String
//                default:
//                    customValues.append(value)
//                }
//            }
//
//            let draft = DraftRequestEntity(
//                subject: subject ?? "",
//                description: description ?? "",
//                ticketForm: selectedForm,
//                customFields: customValues,
//                priority: .normal,
//                uploads: appState.formState?.attachments ?? []
//            )
//
//            if appState.formState?.isSimActivation ?? false {
//                await ticketsService.saveSimActivationRequest(draft)
//            } else {
//                await ticketsService.saveRequest(draft)
//            }
////            submittedRequest = appState.activeRequest.value as? OnlineRequestEntity
//            appState.formState?.status = .submitted
            await ticketsService.submitRequest()
        }

        func simBarcodeOnScanned(_ code: Int) {
//            if let index = appState.formState?.values
//                .firstIndex(where: { $0.field.title.contains("Barcode") }) {
//                appState.formState?.values[index] = .init(field: appState.formState?.values[index].field, value: .double(Double(code)))
//                }
            if let field = appState.formState?.form.fields.first { $0.title.contains("Barcode")  } {
                ticketsService.updateFieldValue(field: field, value: .double(Double(code)))
            }
        }

        func uploadImage(_ image: UIImage) async {
            await ticketsService.uploadAttachment(.init(data: image.pngData()!, status: .offline, fileName: Date().ISO8601Format() + ".png"))
        }

        func removeAttachment(_ attachment: UploadAttachmentEntity) {
            ticketsService.removeAttachment(attachment)
        }

        func selectForm(_ form: TicketFormEntity?) {
            ticketsService.selectForm(form)
        }

        func updateFieldValue(field: TicketFieldEntity, value: Value?) {
            ticketsService.updateFieldValue(field: field, value: value)
        }

        func nextQuestionFrom(_ field: TicketFieldEntity?) -> TicketFieldEntity? {
            guard let field else {
                return appState.formState?.displayFields.first
            }
            let currentIndex = appState.formState?.displayFields.firstIndex(of: field) ?? -1
            return appState.formState?.displayFields[safe: currentIndex + 1]
        }

        func previousQuestionFrom(_ field: TicketFieldEntity?) -> TicketFieldEntity? {
            guard let field else {
                return appState.formState?.displayFields.last
            }
            _ = ticketsService.removeAnswer(field)
            let currentIndex = appState.formState?.displayFields.firstIndex(of: field) ?? -1
            return appState.formState?.displayFields[safe: currentIndex - 1]
        }

        func onAppear() async {
            if appState.ticketForms.value != nil {
                return
            }
            self.formState?.status = .busy
            await self.fetchForms()
            await self.fetchUser()
            let simCardActivationForm = self.forms.value?.first { $0.id == appConfig.displayFormId }
            self.selectForm(mobileDisplayFormOnly ? simCardActivationForm : nil)
            self.formState?.status = .active
        }
    }
}
