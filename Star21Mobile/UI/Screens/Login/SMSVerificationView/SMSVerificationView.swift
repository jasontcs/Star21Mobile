//
//  SMSVerificationView.swift
//  Star21Mobile
//
//  Created by Jason Tse on 19/12/2023.
//

import SwiftUI

struct SMSVerificationView: View {
    @StateObject var viewModel: ViewModel

    var body: some View {
        Form {
            TextField("SMS Verification Code", text: $viewModel.code)
                .navigationTitle("Mobile Verification")
            Button("Submit") {
                Task {
                    await viewModel.verifyMobile()
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

struct SMSVerificationView_Previews: PreviewProvider {
    static var previews: some View {
        SMSVerificationView(viewModel: .init())
    }
}
