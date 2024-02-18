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

        init() {
            appState.$session
                .listen(in: &cancellables) { session in
                    self.session = session
                }
        }

        @Published var session: AsyncSnapshot<SessionEntity> = .nothing

        private var cancellables = Set<AnyCancellable>()

        func logout() async {
            await authenticationService.logout()

        }
    }
}
