//
//  NewTicketView.swift
//  Star21Mobile
//
//  Created by Jason Tse on 17/11/2023.
//

import SwiftUI

struct NewTicketView: View {
    @ObservedObject private(set) var viewModel: ViewModel

    var body: some View {
        VStack {
            Form {
                if let forms = viewModel.forms.value {
                    Section {
                        Picker("Select a form", selection: $viewModel.selectedForm) {
                            ForEach(forms, id: \.self) { form in
                                Text(form.name).tag(Optional(form))
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }

                if let selectedForm = viewModel.selectedForm {
                    List {
                        ForEach(selectedForm.fields, id: \.self) { field in
                            List {
                                TicketField(
                                    viewModel: viewModel,
                                    field: field,
                                    visible: !viewModel.hiddenFields.contains(where: { $0 == field })
                                )
                            }
                        }
                    }
                    Section {
                        Button("Submit") {
                            Task {
                                await viewModel.submitRequest()
                            }
                        }
                    }
                }
            }
            .navigationTitle("New Ticket")
        }
        .task {
            Task { await viewModel.fetchUser() }
            Task { await viewModel.fetchForms() }
        }
    }
}

struct NewRequestView_Previews: PreviewProvider {
    static var previews: some View {
        NewTicketView(viewModel: .init())
    }
}
