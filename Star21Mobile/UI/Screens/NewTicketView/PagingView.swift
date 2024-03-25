//
//  PagingView.swift
//  Star21Mobile
//
//  Created by Jason Tse on 13/3/2024.
//

import SwiftUI

struct PagingView: View {
    @EnvironmentObject private var appRouting: AppRouting
    @ObservedObject private(set) var viewModel: NewTicketView.ViewModel

    var body: some View {
        let field: TicketFieldEntity? = {
            switch appRouting.newTicketPath.last {
            case .question(let field): return field
            case .submit: return nil
            case .none: return nil
            }
        }()
        return Button {
            let next = viewModel.nextQuestionFrom(field)
            appRouting.newTicketPath.append(next != nil ? .question(next!) : .submit)
        } label: {
            Text("Next")
        }
    }
}

#Preview {
    PagingView(viewModel: .init())
}
