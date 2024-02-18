//
//  EmailVerificationView.swift
//  Star21Mobile
//
//  Created by Jason Tse on 18/12/2023.
//

import SwiftUI

struct EmailVerificationView: View {
    @StateObject var viewModel: ViewModel

    var body: some View {
        Form {
            TextField("Email Verification Code", text: $viewModel.code)
                .navigationTitle("Email Verification")
            Button("Submit") {
                Task {
                    await viewModel.verifyEmail()
                }
            }
            Button("Resend") {
                Task {
                    await viewModel.resend()
                }
            }
        }
    }
}

struct EmailVerificationView_Previews: PreviewProvider {
    static var previews: some View {
        EmailVerificationView(viewModel: .init())
    }
}
