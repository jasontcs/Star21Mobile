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
                    if !viewModel.isSimCardActivationFormSelected {
                        Section(header: Text("Attachments")) {
                            ScrollView(.horizontal) {
                                LazyHStack(spacing: 8) {
                                    ForEach(viewModel.attachments, id: \.fileName) { item in
                                        ZStack {
                                            Image(uiImage: UIImage(data: item.data) ?? UIImage())
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 84, height: 84)
                                                .clipped()

                                            switch item.status {
                                            case .offline:
                                                Image(systemName: "xmark")
                                                    .background(.gray.opacity(0.7))
                                            case .uploading:
                                                ProgressView()
                                                    .background(.gray.opacity(0.7))
                                            case .online(let token):
                                                VStack {
                                                    HStack {
                                                        Spacer()
                                                        Button(action: {
                                                            viewModel.removeAttachment(item)
                                                        }) {
                                                            Image(systemName: "xmark.circle.fill")
                                                                .foregroundColor(.red)
                                                                .padding(5)
                                                        }
                                                    }
                                                    .padding(.top, 5)
                                                    Spacer()
                                                }
                                            }
                                        }
                                    }
                                    .listStyle(.plain)

                                    MediaPicker(image: Binding {
                                        nil
                                    } set: { image in
                                        if let image {
                                            Task { await viewModel.uploadImage(image) }
                                        }
                                    }) {
                                        Image(systemName: "plus")
                                            .foregroundColor(.white)

                                    }
                                    .frame(width: 84, height: 84)
                                    .background(.gray)
                                }
                            }
                        }
                    }
                    Section {
                        Button("Submit") {
                            Task {
                                viewModel.formBusy = true
                                await viewModel.submitRequest()
                                viewModel.formBusy = false
                            }
                        }
                        .disabled(viewModel.formBusy)
                    }
                }
            }
            .navigationTitle("New Ticket")
        }
        .task {
            viewModel.formBusy = true
            await viewModel.fetchForms()
            await viewModel.fetchUser()
            viewModel.formBusy = false
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
//            CodeScannerView(
//                codeTypes: [.code128],
//                simulatedData: "8200111122223",
//                videoCaptureDevice: .bestForVideo,
//                completion: handleScan
//            )

            VStack {
                Text("Tap the SIM Barcode")
                    .font(.title)
                    .padding()
                BarcodeScannerView(
                    onCodeTap: handleScan,
                    simulatedData: "8200111122223"
                )
                    .navigationBarTitle("")
                    .navigationBarHidden(true)
            }
        }
    }

    private func handleScan(result: String) {
        isShowingScanner = false
        if let intValue = Int(result) {
            viewModel.simBarcodeOnScanned(intValue)
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
                            await viewModel.submitRequest()
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
