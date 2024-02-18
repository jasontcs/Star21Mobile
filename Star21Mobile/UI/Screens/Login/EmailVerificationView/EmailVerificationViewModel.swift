//
//  EmailVerificationViewModel.swift
//  Star21Mobile
//
//  Created by Jason Tse on 19/12/2023.
//

import SwiftUI
import Combine
import Factory

extension EmailVerificationView {

    @MainActor
    final class ViewModel: ObservableObject {

        @Published var code = ""

        @Injected(\.authenticationService) private var authenticationService
        @Injected(\.appState) private var appState

        func verifyEmail() async {
            appState.showLoading = true
            await authenticationService.verifyEmail(code: code)
            appState.showLoading = false
        }

        func resend() async {
            appState.showLoading = true
            await authenticationService.resendEmailVerificationCode()
            appState.showLoading = false
        }
    }
}
