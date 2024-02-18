//
//  MainView.swift
//  Star21Mobile
//
//  Created by Jason Tse on 10/11/2023.
//

import SwiftUI
import Factory

struct MainView: View {
    @StateObject var viewModel: ViewModel
    @EnvironmentObject private var appRouting: AppRouting

    var body: some View {
        VStack {
            switch appRouting.tab {
            case .home:
                HomeView(viewModel: .init())
            case .tickets:
                TicketsView(viewModel: .init())
            case .newTicket:
                NewTicketView(viewModel: .init())
            case .chat:
                ChatView()
            case .profile:
                ProfileView(viewModel: .init())
            }
            Spacer()
            BottomBar(selectedTab: $appRouting.tab)

        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HotlineButton()
            }
        }
        .navigationDestination(for: AppRouting.Ticket.self) { route in
            TicketView(viewModel: .init(), request: route)
        }
        .task {
            await viewModel.fetchUser()
        }
    }
}

extension MainView {
    @MainActor
    final class ViewModel: ObservableObject {
        @Injected(\.ticketsService) private var ticketsService

        func fetchUser() async {
            await ticketsService.fetchUser()
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(viewModel: .init())
    }
}
