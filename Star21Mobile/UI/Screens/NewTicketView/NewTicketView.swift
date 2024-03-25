//
//  NewTicketView.swift
//  Star21Mobile
//
//  Created by Jason Tse on 17/11/2023.
//

import SwiftUI
import CodeScanner
import AVFoundation
import OSLog
import CoreLocationUI

struct NewTicketView: View {
    @ObservedObject private(set) var viewModel: ViewModel
    @EnvironmentObject private var appRouting: AppRouting

    @State private var expanded: Set<TicketFieldEntity> = []

    var body: some View {
        VStack {
            if let formState = viewModel.formState {
                Form {
                    if !viewModel.mobileDisplayFormOnly {
                        if let forms = viewModel.forms.value, let formState = viewModel.formState {
                            Section {
                                Picker("Select a form", selection: Binding(get: {
                                    formState.form
                                }, set: { form in
                                    viewModel.selectForm(form)
                                })) {
                                    ForEach(forms, id: \.self) { form in
                                        Text(form.name).tag(form)
                                    }
                                }
                                .pickerStyle(.menu)
                            }
                        }
                    }
                    if viewModel.inPagingUX {
                        PagingView(viewModel: viewModel)
                    } else {
                        List {
                            ForEach(formState.appAvailableFields, id: \.self) { field in
                                List {
                                    TicketFieldView(
                                        viewModel: viewModel,
                                        field: field,
                                        visible: !formState.hiddenFields.contains(where: { $0 == field }),
                                        isExpanded: Binding<Bool>(
                                            get: { expanded.contains(field) },
                                            set: { isExpanding in
                                                if isExpanding {
                                                    expanded.removeAll()
                                                    expanded.insert(field)
                                                } else {
                                                    expanded.remove(field)
                                                }
                                            }
                                        )
                                    )
                                }
                            }
                            Section {
                                Button("Submit") {
//                                LocationButton(.currentLocation) {
                                    Task {
                                        await viewModel.submitRequest()
                                    }
                                }
                                .disabled(viewModel.formState?.status == FormStatus.busy)
                            }
                        }
                    }
                }
                .navigationTitle("New Ticket")
                .onChange(of: formState.status) { status in
                    if case let .submitted(request) = status {
                        appRouting.navigateToTicket(.entity(request))
                    }
                }
//                .onChange(of: formState.displayFields) { fields in
//                    let titles = fields.map { field in
//                        field.title
//                    }
//                    Logger().log("fields: \(titles)")
//                    let tags = fields.map { field in
//                        field.tags.map { $0.description }
//                    }
//                    Logger().log("fields: \(tags)")
//                }
                .onChange(of: formState.values) { values in
                    let messages = values.map { item in
                        "\(item.field.title): \(item.value?.raw())"
                    }
                    Logger().log("values: \(messages)")
                }
            }
        }
        .task {
            await viewModel.onAppear()
            if viewModel.mobileDisplayFormOnly {
                let next = viewModel.nextQuestionFrom(nil)
                appRouting.newTicketPath.append(next != nil ? .question(next!) : .submit)
            }
        }
//        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing) {}
//        }
        .navigationDestination(for: AppRouting.NewTicket.self) { path in
            NewTicketPageView(viewModel: viewModel, path: path)
        }
    }
}

struct NewRequestView_Previews: PreviewProvider {
    static var previews: some View {
        NewTicketView(viewModel: .init())
    }
}
