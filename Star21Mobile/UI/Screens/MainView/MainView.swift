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
                    NavigationStack(path: $appRouting.homePath) {
                        HomeView(viewModel: .init())
                    }
                case .tickets:
                    NavigationStack(path: $appRouting.ticketsPath) {
                        TicketsView(viewModel: .init())
                    }
                case .newTicket:
                    NavigationStack(path: $appRouting.newTicketPath) {
                        NewTicketView(viewModel: .init())
                    }
                case .chat:
                    NavigationStack(path: $appRouting.chatPath) {
                        ChatView()
                    }
                case .profile:
                    NavigationStack(path: $appRouting.profilePath) {
                        ProfileView(viewModel: .init())
                    }
                }
            Spacer()
            BottomBar(selectedTab: $appRouting.tab)

        }
        .navigationViewStyle(StackNavigationViewStyle())
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HotlineButton()
            }
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
