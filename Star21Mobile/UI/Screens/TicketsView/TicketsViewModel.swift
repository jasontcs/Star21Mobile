//
//  TicketsViewModel.swift
//  Star21Mobile
//
//  Created by Jason Tse on 6/11/2023.
//

import SwiftUI
import Combine
import Factory

extension TicketsView {
    @MainActor
    final class ViewModel: ObservableObject {
        @Injected(\.appState) private var appState
        @Injected(\.ticketsService) private var ticketsService

        @Published var tickets: AsyncSnapshot<[OnlineRequestEntity]> = .nothing

        private var cancellables = Set<AnyCancellable>()

        init() {
            appState.$requests
                .listen(in: &cancellables) { requests in
                    self.tickets = requests
                }
        }

        func fetchTickets() async {
            await ticketsService.fetchRequests()
        }

        func fetchUser() async {
            await ticketsService.fetchUser()
        }
    }
}
