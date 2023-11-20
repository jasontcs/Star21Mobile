//
//  TicketFieldView.swift
//  Star21Mobile
//
//  Created by Jason Tse on 17/11/2023.
//

import SwiftUI

extension NewTicketView {
    struct TicketField: View {
        @ObservedObject private(set) var viewModel: NewTicketView.ViewModel
        let field: TicketFieldEntity
        let visible: Bool

        var body: some View {
            if visible {
                Section {
                    switch field.type {
                    case .text, .subject:
                        TextField(
                            field.title,
                            text: self.fieldBinding(field, defaultValue: "")
                        )
                    case .textarea, .description:
                        TextEditor(text: self.fieldBinding(field, defaultValue: ""))
                    case .checkbox:
                        Toggle(
                            field.title,
                            isOn: self.fieldBinding(field, defaultValue: false)
                        )
                    case .date:
                        DatePicker(
                            field.title,
                            selection: self.fieldBinding(field, defaultValue: Date()),
                            displayedComponents: .date
                        )
                    case .tagger:
                        Picker(
                            field.title,
                            selection: self.fieldBinding(field, defaultValue: Optional<Int>.none)
                        ) {
                            Text("-").tag(Optional<Int>.none)
                            ForEach(field.options!) { option in
                                Text(option.name).tag(Optional(option.id))
                            }
                        }
                    case .integer:
                        TextField(
                            field.title,
                            value: self.fieldBinding(field, defaultValue: Optional<Int>.none),
                            format: .number
                        ).keyboardType(.numberPad)
                    case .decimal:
                        TextField(
                            field.title,
                            value: self.fieldBinding(field, defaultValue: Optional<Double>.none),
                            format: .number
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
                            text: self.fieldBinding(field, defaultValue: "")
                        )
                    }
                } header: {
                    switch field.type {
                    case .textarea, .description:
                        Text(field.title)
                    default: EmptyView()
                    }
                } footer: {
                    if !field.description.isEmpty {
                        Text(field.description)
                    }
                }
            }
        }

        private func fieldBinding<T>(_ field: TicketFieldEntity, defaultValue: T) -> Binding<T> {
            Binding<T>(
                get: {
                    var value = viewModel.formValues.first { $0.field == field }?.value?.raw()

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

                    let fieldValue = CustomFieldValueEntity(field: field, value: try? Value.from(raw))
                    if let index = viewModel.formValues.firstIndex(where: { $0.field.id == field.id }) {
                        viewModel.formValues[index] = fieldValue
                    }

                }
            )
        }
    }
}

struct TicketField_Previews: PreviewProvider {
    static var previews: some View {
        NewTicketView.TicketField(viewModel: .init(), field: MockData.field, visible: true)
    }
}
