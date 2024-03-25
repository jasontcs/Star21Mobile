//
//  NewTicketPageView.swift
//  Star21Mobile
//
//  Created by Jason Tse on 22/3/2024.
//

import SwiftUI

struct NewTicketPageView: View {
    @ObservedObject private(set) var viewModel: NewTicketView.ViewModel
    @EnvironmentObject private var appRouting: AppRouting
    let path: AppRouting.NewTicket

    init(viewModel: NewTicketView.ViewModel, path: AppRouting.NewTicket) {
        self.viewModel = viewModel
        self.path = path
    }

    var body: some View {
        CustomBackButtonView(visible: appRouting.newTicketPath.count > 1) {
            Form {
                switch path {
                case .question(let field):
                    TicketFieldView(
                        viewModel: viewModel,
                        field: field,
                        visible: true,
                        isExpanded: .constant(true)
                    )
                    if viewModel.inPagingUX && field.type != .checkbox && field.type != .tagger {
                        Section {
                            Button {
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                let next = viewModel.nextQuestionFrom(field)
                                appRouting.newTicketPath.append(next != nil ? .question(next!) : .submit)
                            } label: {
                                Text("Next")
                            }
                        }
                    }
                case .submit:
                    Section {
                        Button("Submit") {
//                            LocationButton(.currentLocation) {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            Task {
                                await viewModel.submitRequest()
                            }
                        }
                    }
                }
            }
        } onBack: {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            let field: TicketFieldEntity? = {
                switch path {
                case .question(let field): return field
                case .submit: return nil
                }
            }()

            guard let previous = viewModel.previousQuestionFrom(field) else {
                appRouting.newTicketPath = []
                return
            }

            appRouting.newTicketPath = appRouting.newTicketPath
                .reversed()
                .drop(while: { $0 != .question(previous) })
                .reversed()
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NewTicketPageView(viewModel: .init(), path: .submit)
}
