//
//  TicketViewModel.swift
//  Star21Mobile
//
//  Created by Jason Tse on 17/11/2023.
//

import SwiftUI
import Combine
import Factory

extension TicketView {

    @MainActor
    final class ViewModel: ObservableObject {

        @Injected(\.appState) private var appState
        @Injected(\.ticketsService) private var ticketsService

        init() {
            appState.$activeRequest
                .compactMap { $0.value as? OnlineRequestEntity }
                .listen(in: &cancellables) { request in
                    self.request = .withData(request)
                }
        }

        @Published var request: AsyncSnapshot<OnlineRequestEntity> = .nothing

        private var cancellables = Set<AnyCancellable>()

        func setActiveRequest(_ request: OnlineRequestEntity?) {
            if let request {
                appState.activeRequest = .withData(request)
            } else {
                appState.activeRequest = .nothing
            }
        }

        func getActiveRequest(_ requestId: Int) async {
            await ticketsService.fetchRequestDetail(requestId)
        }

        func fetchDetails() async {
            await ticketsService.fetchRequestDetail()
        }
    }
}
