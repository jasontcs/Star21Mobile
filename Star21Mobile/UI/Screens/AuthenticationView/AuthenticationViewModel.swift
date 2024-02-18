//
//  AuthenticationViewModel.swift
//  Star21Mobile
//
//  Created by Jason Tse on 9/11/2023.
//

import SwiftUI
import Combine
import Factory

extension AuthenticationView {
    @MainActor
    final class ViewModel: ObservableObject {
        @Injected(\.appState) private var appState
        @Published var authenticated = true
        @Published var authenticationState: AuthenticationState = .emailPending
        private var cancellables = Set<AnyCancellable>()

        init() {
            appState.$session
                .removeDuplicates { prev, curr in
                    prev.value == curr.value
                }
                .listen(in: &cancellables) { session in
                    self.authenticated = session.value?.token != nil
                }
            appState.$authenticationState
                .listen(in: &cancellables) { state in
                    self.authenticationState = state
                }
        }
    }
}
