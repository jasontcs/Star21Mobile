//
//  AuthenticationView.swift
//  Star21Mobile
//
//  Created by Jason Tse on 9/11/2023.
//

import SwiftUI

struct AuthenticationView: View {
    @StateObject var viewModel: ViewModel

    @ViewBuilder
    var body: some View {
        if viewModel.authenticated {
            MainView(viewModel: .init())
        } else {
            switch viewModel.authenticationState {
            case .emailPending:
                EmailFieldView(viewModel: .init())
            case .emailChallenge(token: let token):
                EmailVerificationView(viewModel: .init())
            case .mobilePending(token: let token):
                MobileFieldView(viewModel: .init())
            case .mobileChallenge(token: let token):
                SMSVerificationView(viewModel: .init())
            case .complete:
                EmptyView()
            }
        }
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView(viewModel: .init())
    }
}
