//
//  ProfileViewModel.swift
//  Star21Mobile
//
//  Created by Jason Tse on 21/11/2023.
//

import Combine
import Foundation
import Factory

extension ProfileView {

    @MainActor
    final class ViewModel: ObservableObject {
        @Injected(\.authenticationService) private var authenticationService
        @Injected(\.appState) private var appState

        func logout() async {
            await authenticationService.logout()

        }
    }
}
