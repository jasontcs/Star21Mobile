//
//  LoginViewModel.swift
//  Star21Mobile
//
//  Created by Jason Tse on 9/11/2023.
//

import SwiftUI
import Combine
import Factory

extension LoginView {
    @MainActor
    final class ViewModel: ObservableObject {
        @Injected(\.authenticationService) private var authenticationService
        @Injected(\.appState) private var appState

        func login() {
            authenticationService.login()
        }
    }
}
