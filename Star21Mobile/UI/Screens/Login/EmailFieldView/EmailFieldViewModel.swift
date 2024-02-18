//
//  EmailFieldViewModel.swift
//  Star21Mobile
//
//  Created by Jason Tse on 19/12/2023.
//

import SwiftUI
import Combine
import Factory

extension EmailFieldView {

    @MainActor
    final class ViewModel: ObservableObject {

        @Published var email = ""

        @Injected(\.authenticationService) private var authenticationService
        @Injected(\.appState) private var appState

        func login() async {
            appState.showLoading = true
            await authenticationService.login(email: email)
            appState.showLoading = false
        }
    }
}
