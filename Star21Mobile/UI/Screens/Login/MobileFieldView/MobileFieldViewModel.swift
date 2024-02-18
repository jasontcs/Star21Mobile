//
//  MobileFieldViewModel.swift
//  Star21Mobile
//
//  Created by Jason Tse on 19/12/2023.
//

import SwiftUI
import Combine
import Factory

extension MobileFieldView {

    @MainActor
    final class ViewModel: ObservableObject {

        @Published var mobile = ""

        @Injected(\.authenticationService) private var authenticationService
        @Injected(\.appState) private var appState

        func login() async {
            guard let mobile = Int(mobile) else { return }
            appState.showLoading = true
            await authenticationService.login(mobile: mobile)
            appState.showLoading = false
        }
    }
}
