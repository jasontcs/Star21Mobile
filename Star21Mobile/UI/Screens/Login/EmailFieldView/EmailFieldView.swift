//
//  EmailFieldView.swift
//  Star21Mobile
//
//  Created by Jason Tse on 19/12/2023.
//

import SwiftUI

struct EmailFieldView: View {
    @StateObject var viewModel: ViewModel

    var body: some View {
        Form {
            TextField("Email", text: $viewModel.email)
                .navigationTitle("Welcome")
            Button("Submit") {
                Task {
                    await viewModel.login()
                }
            }
        }
    }
}

struct EmailFieldView_Previews: PreviewProvider {
    static var previews: some View {
        EmailFieldView(viewModel: .init())
    }
}
