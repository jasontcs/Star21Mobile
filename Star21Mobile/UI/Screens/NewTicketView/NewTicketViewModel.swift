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

        @Published var user: AsyncSnapshot<UserEntity> = .nothing
        @Published var forms: AsyncSnapshot<[TicketFormEntity]> = .nothing
        @Published var selectedForm: TicketFormEntity?
        @Published var formValues: [CustomFieldValueEntity] = []
        @Published var hiddenFields: [TicketFieldEntity] = []

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
                    self.selectedForm = self.selectedForm ?? forms.value?.first
                }
            $selectedForm
                .listen(in: &cancellables) { _ in
                    self.resetForm()
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
                priority: .normal
            )

            await ticketsService.saveRequest(draft)
        }

        private func resetForm() {
            formValues = selectedForm?.fields.map { .init(field: $0, value: nil) } ?? []
        }
    }

    struct FieldData: Hashable, Codable {
        var visible: Bool
        var value: Value?
    }
}
