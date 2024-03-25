//
//  TicketFieldView.swift
//  Star21Mobile
//
//  Created by Jason Tse on 17/11/2023.
//

import SwiftUI
import Factory

struct TicketFieldView: View {
    let inPagingUX = Container.shared.appConfig().inPagingUX

    @ObservedObject private(set) var viewModel: NewTicketView.ViewModel
    let field: TicketFieldEntity
    let visible: Bool
    @Binding var isExpanded: Bool
    @State private var isShowingScanner: TicketFieldEntity?
    @EnvironmentObject private var appRouting: AppRouting

    var body: some View {
        Section {
            if visible {
                if field.withTag(.attachments) {
                    ScrollView(.horizontal) {
                        LazyHStack(spacing: 8) {
                            if let attachments = viewModel.formState?.attachments {
                                ForEach(attachments, id: \.fileName) { item in
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
                                                    Button {
                                                        viewModel.removeAttachment(item)
                                                    } label: {
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
                            }

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
                } else {
                    //                        HStack {
                    switch field.type {
                    case .text, .subject:
                        TextField(
                            field.title,
                            value: self.fieldBinding(field, defaultValue: Optional<String>.none),
                            format: OptionalStringParseableFormatStyle()
                        )
                    case .textarea, .description:
                        TextEditorOptional(text: self.fieldBinding(field, defaultValue: Optional<String>.none))
                    case .checkbox:
                        //                        Toggle(
                        //                            field.title,
                        //                            isOn: self.fieldBinding(field, defaultValue: false)
                        //                        )
                        if inPagingUX {
                            List {
                                OptionRowButtonView("Yes") {
                                    update(field, anyValue: true)
                                    nextQuestionFrom(field)
                                }
                                OptionRowButtonView("No") {
                                    update(field, anyValue: false)
                                    nextQuestionFrom(field)
                                }
                            }
                        } else {
                            Picker(
                                field.title,
                                selection: self.fieldBinding(field, defaultValue: Optional<Bool>.none)
                            ) {
                                Text("-").tag(Optional<Bool>.none)
                                Text("Yes").tag(Optional(true))
                                Text("No").tag(Optional(false))
                            }
                        }
                    case .date:
                        //                        DatePicker(
                        //                            field.title,
                        //                            selection: self.fieldBinding(field, defaultValue: Date()),
                        //                            displayedComponents: .date
                        //                        )
                        DatePickerOptional(
                            field.title,
                            prompt: "Pick Date",
                            selection: self.fieldBinding(field, defaultValue: Optional<Date>.none)
                        )
                    case .tagger:
                        if inPagingUX {
                            if let options = field.options {
                                List(options) { option in
                                    OptionRowButtonView(option.name) {
                                        update(field, anyValue: option.value)
                                        nextQuestionFrom(field)
                                    }
                                }
                            }
                        } else {
                            Picker(
                                field.title,
                                selection: self.fieldBinding(field, defaultValue: Optional<String>.none)
                            ) {
                                Text("-").tag(Optional<String>.none)
                                if let options = field.options {
                                    ForEach(options) { option in
                                        Text(option.name).tag(Optional(option.value))
                                    }
                                }
                            }
                        }
                    case .integer:
                        TextField(
                            field.title,
                            value: self.fieldBinding(field, defaultValue: Optional<Int>.none),
                            format: .number
                                .grouping(.never)
                        ).keyboardType(.numberPad)
                    case .decimal:
                        TextField(
                            field.title,
                            value: self.fieldBinding(field, defaultValue: Optional<Double>.none),
                            format: .number
                                .grouping(.never)
                        )
                        .keyboardType(.decimalPad)
                        //                case .assignee:
                        //                    <#code#>
                        //                case .status:
                        //                    <#code#>
                        //                case .priority:
                        //                    <#code#>
                        //                case .tickettype:
                        //                    <#code#>
                        //                case .group:
                        //                    <#code#>
                        //                case .customStatus:
                        //                    <#code#>
                        //                case .regexp:
                        //                    <#code#>
                        //                case .partialcreditcard:
                        //                    <#code#>
                        //                case .multiselect:
                        //                    <#code#>
                        //                case .lookup:
                        //                    <#code#>
                        //                }
                    default:
                        TextField(
                            field.title,
                            value: self.fieldBinding(field, defaultValue: Optional<String>.none),
                            format: OptionalStringParseableFormatStyle()
                        )
                    }
                    if field.withTag(.scanBarcode) {
                        Button {
                            isShowingScanner = field
                        } label: {
                            Image(systemName: "barcode.viewfinder")
                        }
                    }
                    //                        }
                }
            }
        } header: {
            Text(field.title)
                .sheet(item: $isShowingScanner) { field in
                    VStack {
                        Text("Tap the SIM Barcode")
                            .font(.title)
                            .padding()
                        BarcodeScannerView(
                            onCodeTap: { code in
                                isShowingScanner = nil
                                if let intValue = Int(code) {
                                    update(field, anyValue: intValue)
                                }
                            },
                            simulatedData: "820011122223"
                        )
                        .navigationBarTitle("")
                        .navigationBarBackButtonHidden()
                    }
                }
        } footer: {
            if !field.description.isEmpty {
                Text(field.description)
            }
        }
    }

    private func fieldBinding<T>(_ field: TicketFieldEntity, defaultValue: T) -> Binding<T> {
        Binding<T>(
            get: {
                var value = viewModel.formState?.values.first { $0.field == field }?.value?.raw()

                if let double = value as? Double {
                    if let value1 = Int(double) as? T {
                        value = value1
                    }
                    if let value2 = double as? T {
                        value = value2
                    }
                }

                if let string = value as? String {
                    if let date = Constant.dateFormatter.date(from: string) {
                        value = date
                    }
                }

                return value as? T ?? defaultValue
            }, set: {

                var raw: Any = $0

                if let date = raw as? Date {
                    raw = Constant.dateFormatter.string(from: date)
                }
                update(field, anyValue: raw)
//                    let fieldValue = CustomFieldValueEntity(field: field, value: try? Value.from(raw))
//                    if let index = viewModel.formState?.values.firstIndex(where: { $0.field.id == field.id }) {
//                        viewModel.formState?.values[index] = fieldValue
//                    }
            }
        )
    }

    private func update(_ field: TicketFieldEntity, anyValue: Any) {
        viewModel.updateFieldValue(field: field, value: try? Value.from(Optional.some(anyValue)))
    }

    private func nextQuestionFrom(_ field: TicketFieldEntity) {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        let next = viewModel.nextQuestionFrom(field)
        appRouting.newTicketPath.append(next != nil ? .question(next!) : .submit)
    }
}

struct OptionalStringParseableFormatStyle: ParseableFormatStyle {

    var parseStrategy: Strategy = .init()

    func format(_ value: String?) -> String {
        value ?? ""
    }

    struct Strategy: ParseStrategy {

        func parse(_ value: String) throws -> String? {
            if value.isEmpty { return nil }
            return value
        }

    }

}

struct TicketFieldView_Previews: PreviewProvider {
    static var previews: some View {
        TicketFieldView(
            viewModel: .init(),
            field: MockData.field,
            visible: true,
            isExpanded: .constant(true)
        )
    }
}
