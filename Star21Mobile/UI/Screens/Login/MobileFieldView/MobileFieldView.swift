//
//  MobileFieldVerificationView.swift
//  Star21Mobile
//
//  Created by Jason Tse on 19/12/2023.
//

import SwiftUI

struct MobileFieldView: View {
    @StateObject var viewModel: ViewModel

    var body: some View {
        Form {
            TextField("Mobile Number", text: $viewModel.mobile)
                .navigationTitle("Mobile Number")
            Button("Submit") {
                Task {
                    await viewModel.login()
                }
            }
        }
    }
}

struct MobileFieldVerificationView_Previews: PreviewProvider {
    static var previews: some View {
        MobileFieldView(viewModel: .init())
    }
}
