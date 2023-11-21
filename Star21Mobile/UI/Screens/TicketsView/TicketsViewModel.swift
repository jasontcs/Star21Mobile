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
        @Published var searchText = ""
        @Published var searchStatus: RequestStatus?

        private var cancellables = Set<AnyCancellable>()

        init() {
            appState.$requests
                .listen(in: &cancellables) { requests in
                    self.tickets = requests
                }
        }

        func fetchTickets() async {
            let statuses: [RequestStatus]? = {
                if let searchStatus { return [searchStatus] }
                return nil
            }()
            await ticketsService.fetchRequests(searchText: searchText, statuses: statuses)
        }

        func fetchUser() async {
            await ticketsService.fetchUser()
        }
    }
}
