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
        @Published var authenticated = false
        private var cancellables = Set<AnyCancellable>()

        init() {
            appState.$session
                .receive(on: DispatchQueue.main)
                .sink {_ in
                } receiveValue: { session in
                    self.authenticated = session.value?.token != nil
                }
                .store(in: &cancellables)
        }
    }
}
