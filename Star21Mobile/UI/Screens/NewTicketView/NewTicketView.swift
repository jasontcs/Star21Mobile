//
//  NewTicketView.swift
//  Star21Mobile
//
//  Created by Jason Tse on 17/11/2023.
//

import SwiftUI
import CodeScanner
import AVFoundation

struct NewTicketView: View {
    @ObservedObject private(set) var viewModel: ViewModel
    @EnvironmentObject private var appRouting: AppRouting

    @State private var expanded: Set<TicketFieldEntity> = []
    @State private var isShowingScanner = false

    let simActivationTicket = false

    var body: some View {
        VStack {
            Form {
                if !simActivationTicket {
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
                }

                if let fields = viewModel.selectedForm?.fields
                    .filter({
                        if viewModel.isSimCardActivationFormSelected {
                            switch $0.type {
                            case .subject: return false
                            case .description: return false
                            default: return true
                            }
                        }
                        return true
                    }) {
//                    pagedView
                    List {
                        ForEach(fields, id: \.self) { field in
                            List {
                                TicketFieldView(
                                    viewModel: viewModel,
                                    field: field,
                                    visible: !viewModel.hiddenFields.contains(where: { $0 == field }),
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
                    }
                    Section {
                        Button("Submit") {
                            Task {
                                await viewModel.submitRequest(isSimCardActivation: viewModel.isSimCardActivationFormSelected)
                            }
                        }
                    }
                }
            }
            .navigationTitle("New Ticket")
        }
        .task {
            await viewModel.fetchForms()
            await viewModel.fetchUser()
        }
        .onChange(of: viewModel.submittedRequest) { request in
            if let request {
                appRouting.navigateToTicket(.entity(request))
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isShowingScanner = true
                } label: {
                    Image(systemName: "barcode.viewfinder")
                }
            }
        }
        .sheet(isPresented: $isShowingScanner) {
            CodeScannerView(
                codeTypes: [.code128],
                simulatedData: "8200111122223",
                videoCaptureDevice: .bestForVideo,
                completion: handleScan
            )
        }
    }

    private func handleScan(result: Result<ScanResult, ScanError>) {
        isShowingScanner = false
        switch result {
        case .success(let result):
            print("Scanning succeeded: \(result.string)")
            if let intValue = Int(result.string) {
                viewModel.simBarcodeOnScanned(intValue)
            }

        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
    }

    private func nextPage(_ current: PagingPath?) {
        let validFields = Array(Set(viewModel.selectedForm?.fields ?? []).subtracting(viewModel.hiddenFields))
        var index = 0
        if case let .question(field) = current {
            if let local = validFields.firstIndex(of: field) {
                index = local + 1
            }
        }
        if let next = validFields[safe: index] {
            appRouting.path.append(PagingPath.question(next))
        } else {
            appRouting.path.append(PagingPath.submit)
        }
    }

    var pagedView: some View {
        Button {
            nextPage(nil)
        } label: {
            Text("Next")
        }
        .navigationDestination(for: PagingPath.self) { path in
            switch path {
            case .question(let field):
                Form {
                    Section {
                        TicketFieldView(
                            viewModel: viewModel,
                            field: field,
                            visible: !viewModel.hiddenFields.contains(where: { $0 == field }),
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
                    Section {
                        Button {
                            nextPage(path)
                        } label: {
                            Text("Next")
                        }
                    }
                }
            case .submit:
                Section {
                    Button("Submit") {
                        Task {
                            await viewModel.submitRequest(isSimCardActivation: viewModel.isSimCardActivationFormSelected)
                        }
                    }
                }
            }
        }
    }
}

struct NewRequestView_Previews: PreviewProvider {
    static var previews: some View {
        NewTicketView(viewModel: .init())
    }
}
